#!/bin/bash

# Define Variables
odoo_conf_file="/etc/odoo.conf"
odoo_username="odoo"  # Odoo Username (change as needed)
odoo_home="/opt/odoo"  # Odoo Home Directory (change as needed)
server_domain="odoo.narwal25.site"
odoo_version="17.0"  # Variable for Odoo version
source .env

# Enable Debugging and Exit on Error
set -xe

# Function to Install System Packages
install_system_packages() {
    sudo apt-get update -y
    sudo apt-get install -y python3-pip
    sudo apt-get install -y python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev
    sudo apt-get install -y npm
    sudo apt install python3-cffi libldap2-dev libpq-dev libsasl2-dev -y
    sudo apt install xfonts-75dpi xfonts-base -y
    sudo apt-get install postgresql -y
    sudo apt install nginx -y
}

# Function to Install Node.js and Dependencies
install_nodejs_and_dependencies() {
    if [ ! -f "/usr/bin/node" ]; then
      sudo ln -s /usr/bin/nodejs /usr/bin/node  
    fi
    sudo npm install -g less less-plugin-clean-css
    sudo apt-get install -y node-less
    sudo npm install -g rtlcss
}

# Function to Setup PostgreSQL Database and User
setup_postgresql() {
    role_exists=$(su - postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname = '$odoo_username'\"")
    if [ "$role_exists" = "1" ]; then
        echo "Role '$odoo_username' already exists."
    else
      su - postgres -c "psql -U postgres -c \"CREATE ROLE $odoo_username WITH NOCREATEROLE NOSUPERUSER CREATEDB LOGIN;\""
    fi
    su - postgres -c "psql -U postgres -c \"ALTER ROLE $odoo_username WITH PASSWORD 'odoo';\""
    su - postgres -c "psql -U postgres -c \"ALTER USER $odoo_username WITH SUPERUSER;\""
}

# Function to Setup Odoo User and Install Odoo from Git
setup_odoo_user_and_install() {
    sudo adduser --system --home=$odoo_home --group $odoo_username
    sudo apt-get install git
    if [ -d "$odoo_home/odoo" ]; then
      CURRENT_TIME=$(date | cut -d" " -f5)
      mv $odoo_home/odoo $odoo_home/odoo_backup_"${CURRENT_TIME}"
    fi
    su - $odoo_username -s /bin/bash -c "git clone https://www.github.com/odoo/odoo --depth 1 --branch $odoo_version --single-branch $odoo_home/odoo"
}

# Function to Install Python Requirements for Odoo
install_python_requirements() {
    sudo sed -i "s/gevent==21.8.0/gevent==21.12.0/g"  $odoo_home/odoo/requirements.txt
    sudo pip install -r $odoo_home/odoo/requirements.txt
}

# Function to Install wkhtmltopdf
install_wkhtmltopdf() {
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
    dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb
    sudo apt install -f
}

# Function to Create and Configure Odoo Configuration File
create_odoo_config() {
    sudo cp $odoo_home/odoo/debian/odoo.conf $odoo_conf_file
    sudo touch $odoo_conf_file

    echo "[options]
   ; This is the password that allows database operations:
   admin_passwd = admin
   db_host = False
   db_port = False
   db_user = $odoo_username
   db_password = odoo
   addons_path = $odoo_home/odoo/addons
   logfile = /var/log/odoo/odoo.log
   proxy_mode = True
   " > $odoo_conf_file

    sudo chown $odoo_username: $odoo_conf_file
    sudo chmod 640 $odoo_conf_file
}

# Function to Setup Odoo Service
setup_odoo_service() {
    sudo mkdir /var/log/odoo
    sudo chown $odoo_username:root /var/log/odoo
    sudo touch /etc/systemd/system/odoo.service

    echo "[Unit]
   Description=Odoo$odoo_version
   Documentation=http://www.odoo.com
   [Service]
   # Ubuntu/Debian convention:
   Type=simple
   User=$odoo_username
   ExecStart=$odoo_home/odoo/odoo-bin -c $odoo_conf_file
   [Install]
   WantedBy=default.target
   " > /etc/systemd/system/odoo.service

    sudo chmod 755 /etc/systemd/system/odoo.service
    sudo chown root: /etc/systemd/system/odoo.service

    sudo systemctl enable odoo.service
    sudo systemctl start odoo.service
}

# Function to Configure Nginx for Odoo
configure_nginx() {
    touch /etc/nginx/sites-enabled/${server_domain}.conf

    echo "#odoo server
upstream odoo {
  server 127.0.0.1:8069;
}
upstream odoochat {
  server 127.0.0.1:8072;
}
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  ''      close;
}

# http -> https
server {
  listen 80;
  server_name ${server_domain};
  rewrite ^(.*) https://\$host\$1 permanent;
}

server {
  listen 443 ssl;
  server_name ${server_domain};
  proxy_read_timeout 720s;
  proxy_connect_timeout 720s;
  proxy_send_timeout 720s;

  # SSL parameters
  ssl_certificate /etc/letsencrypt/live/${server_domain}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${server_domain}/privkey.pem;
  ssl_session_timeout 30m;
  ssl_protocols TLSv1.2;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_prefer_server_ciphers off;

  # log
  access_log /var/log/nginx/odoo.access.log;
  error_log /var/log/nginx/odoo.error.log;

  # Redirect websocket requests to odoo gevent port
  location /websocket {
    proxy_pass http://odoochat;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;

    add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains';
  }

  # Redirect requests to odoo backend server
  location / {
    # Add Headers for odoo proxy mode
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_redirect off;
    proxy_pass http://odoo;

    add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains';
  }

  # common gzip
  gzip_types text/css text/scss text/plain text/xml application/xml application/json application/javascript;
  gzip on;
}" > /etc/nginx/sites-enabled/${server_domain}.conf

    nginx_test_output=$(nginx -t 2>&1)

    if [ $? -eq 0 ]; then
        sudo systemctl restart nginx
    else
        echo "$nginx_test_output"
    fi
}

# Main Execution
install_odoo_stack(){
    install_system_packages
    install_nodejs_and_dependencies
    setup_postgresql
    setup_odoo_user_and_install
    install_python_requirements
    install_wkhtmltopdf
    create_odoo_config
    setup_odoo_service
    configure_nginx
}

install_odoo_stack
