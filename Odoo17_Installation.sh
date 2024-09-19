source .env

sudo apt-get update -y
sudo apt-get install -y python3-pip
sudo apt-get install python-dev python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential libssl-dev libffi-dev libmysqlclient-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev
sudo apt-get install -y npm
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g less less-plugin-clean-css
sudo apt-get install -y node-less
sudo apt install python3-pip libldap2-dev libpq-dev libsasl2-dev -y
sudo apt-get install postgresql -y
sudo npm install -g rtlcss


su - postgres -c "psql -U postgres -c \"CREATE ROLE $odoo_username WITH NOCREATEROLE NOSUPERUSER CREATEDB LOGIN;\""
su - postgres -c "psql -U postgres -c \"ALTER ROLE $odoo_username WITH PASSWORD 'odoo';\""
su - postgres -c "psql -U postgres -c \"ALTER USER $odoo_username WITH SUPERUSER;;\""

sudo adduser --system --home=/opt/odoo --group $odoo_username
sudo apt-get install git

sudo su - odoo -s /bin/bash
git clone https://www.github.com/odoo/odoo --depth 1 --branch 17.0 --single-branch odoo/
exit

sudo apt install python3-cffi -y
sudo pip install -r /opt/odoo/odoo/requirements.txt

apt install xfonts-75dpi xfonts-base -y 
apt --fix-broken install -y
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
dpkg -i wkhtmltox_0.12.6.1-3.jammy_amd64.deb 
sudo apt install -f

sudo cp /opt/odoo/odoo/debian/odoo.conf $odoo_conf_file
sudo touch $odoo_conf_file


echo "[options]
   ; This is the password that allows database operations:
   admin_passwd = admin
   db_host = False
   db_port = False
   db_user = $odoo_username
   db_password = odoo
   addons_path = /opt/odoo/odoo/addons
   logfile = /var/log/odoo/odoo.log
   proxy_mode = True
   " > $odoo_conf_file

sudo chown $odoo_username: $odoo_conf_file
sudo chmod 640 $odoo_conf_file

sudo mkdir /var/log/odoo
sudo chown odoo:root /var/log/odoo

sudo touch /etc/systemd/system/odoo.service


echo "[Unit]
   Description=Odoo17
   Documentation=http://www.odoo.com
   [Service]
   # Ubuntu/Debian convention:
   Type=simple
   User=$odoo_username
   ExecStart=/opt/odoo/odoo/odoo-bin -c $odoo_conf_file
   [Install]
   WantedBy=default.target
   " > /etc/systemd/system/odoo.service

sudo chmod 755 /etc/systemd/system/odoo.service
sudo chown root: /etc/systemd/system/odoo.service


sudo systemctl enable odoo.service
sudo systemctl start odoo.service

sudo apt install nginx -y
systemctl start nginx

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
    #proxy_cookie_flags session_id samesite=lax secure;  # requires nginx 1.19.8
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
    #proxy_cookie_flags session_id samesite=lax secure;  # requires nginx 1.19.8
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