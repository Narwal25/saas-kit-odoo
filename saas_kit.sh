ubuntu_packages_install() {
    ##### Install certbot and nginx if not installed
    apt install nginx certbot python3-pip sed awk -y
}

python_packages_install() {
    ##### Install python depencencies in virtual env
    $odoo_python_pip_path install docker erppeek paramiko python-crontab
}

oddo_user_docker_add() {
    ##### Add User odoo to docker group
    usermod -a -G docker $odoo_username
    
    ##### verify if user is added into docker group
    id $odoo_username
}

saas_directory_create() {
    ##### Create saas custom directory
    mkdir -p $odoo_saas_custom_path
    
    ##### Make these directory in your custom folder
    mkdir "$odoo_saas_custom_path"Odoo-SAAS-Data
    mkdir "$odoo_saas_custom_path"webkul_addons
    mkdir "$odoo_saas_custom_path"common-addons_v15
    mkdir "$odoo_saas_custom_path"common-addons_v16
    mkdir "$odoo_saas_custom_path"common-addons_v17
    
    ##### Make these directories in your custom folder
    mkdir "$odoo_saas_custom_path"dockerv15
    mkdir "$odoo_saas_custom_path"dockerv16
    mkdir "$odoo_saas_custom_path"dockerv17
}

saas_docker_files_copy() {
    ##### Copy files from docker files to dockerv15, dockerv16, docker17 a
    cp -r "$odoo_saas_files_path"docker_files-all/dockerv15/docker-data/ "$odoo_saas_custom_path"dockerv15
    cp -r "$odoo_saas_files_path"docker_files-all/dockerv16/docker-data/ "$odoo_saas_custom_path"dockerv16
    cp -r "$odoo_saas_files_path"docker_files-all/dockerv17/docker-data/ "$odoo_saas_custom_path"dockerv17
    
}

saas_docker_build() {
    ##### Build your docker images
    ##### If you get any error you might not have docker files in the
    ##### specified directory
    docker build --build-arg ODOO_USER_UID=$(id -u $odoo_username) --build-arg ODOO_USER_GID=$(id -g $odoo_username) -t odoobywebkul:15.0 "$odoo_saas_custom_path"dockerv15/.
    
    docker build --build-arg ODOO_USER_UID=$(id -u $odoo_username) --build-arg ODOO_USER_GID=$(id -g $odoo_username) -t odoobywebkul:16.0 "$odoo_saas_custom_path"dockerv16/.
    
    docker build --build-arg ODOO_USER_UID=$(id -u $odoo_username) --build-arg ODOO_USER_GID=$(id -g $odoo_username) -t odoobywebkul:17.0 "$odoo_saas_custom_path"dockerv17/.
}

saas_kit_files_copy() {
    ##### copy wk_saas_tool files in common addons in wk_saas_tool folder
    ##### In your saas folder
    cp -r "$odoo_saas_files_path"wk_saas_tool-15.0/ "$odoo_saas_custom_path"common-addons_v15/wk_saas_tool
    cp -r "$odoo_saas_files_path"wk_saas_tool-16.0/ "$odoo_saas_custom_path"common-addons_v16/wk_saas_tool
    cp -r "$odoo_saas_files_path"wk_saas_tool-17.0/ "$odoo_saas_custom_path"common-addons_v17/wk_saas_tool
    
    ##### In your saas folder copy wk-sass-kit to Odoo-saas-data folder
    cp -r "$odoo_saas_files_path"odoo_saas_kit-17.0/ "$odoo_saas_custom_path"Odoo-SAAS-Data
    
    ##### Copy config files to Odoo-Saas-data
    ##### from your saas folder
    cp -r "$odoo_saas_files_path"common-configuration-files-17.0/* "$odoo_saas_custom_path"Odoo-SAAS-Data/
    
    
    ##### addons to webkul addons folder
    cp -r "$odoo_saas_files_path"odoo_saas_kit-17.0/ "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit
    cp -r "$odoo_saas_files_path"saas_kit_backup-17.0/ "$odoo_saas_custom_path"webkul_addons/saas_kit_backup
    cp -r "$odoo_saas_files_path"saas_kit_custom_plans-17.0/ "$odoo_saas_custom_path"webkul_addons/saas_kit_custom_plans
    cp -r "$odoo_saas_files_path"saas_kit_trial-17.0/ "$odoo_saas_custom_path"webkul_addons/saas_kit_trial
    cp -r "$odoo_saas_files_path"wk_backup_restore-17.0/ "$odoo_saas_custom_path"webkul_addons/wk_backup_restore
    
    ##### depend on requirement you might not need custom plan trail
    ##### cp -r "$odoo_saas_files_path"custom_plans_trial-17.0/ "$odoo_saas_custom_path"webkul_addons/custom_plans_trial
    
}

saas_conf_paths_update() {
    ##### change path in webkul_addons/odoo_saas_kit/models/lib/saas.conf file
    
    # using nano
    # nano "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf
    
    ########################################
    # change following paths
    # nginx_vhosts = /opt/odoo17/Odoo-SAAS-Data/docker_vhosts/
    # odoo_saas_data = /opt/odoo17/Odoo-SAAS-Data/
    # odoo_template_v17 = odoo17_template_cont
    # common_addons_v17 = /opt/odoo/common-addons_v17
    # template_odoo_port_v17 = 8817
    # template_odoo_lport_v17 = 8827
    # odoo_template_v16 = odoo16_template_cont
    # common_addons_v16 = /opt/odoo/common-addons_v16
    # template_odoo_port_v16 = 8816
    # template_odoo_lport_v16 = 8826
    # odoo_template_v15 = odoo15_template_cont
    # common_addons_v15 = /opt/odoo/common-addons_v15
    # template_odoo_port_v15 = 8815
    # template_odoo_lport_v15 = 8825
    ########################################
    
    # using echo
    
    saas_conf_path="$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf
    cp $saas_conf_path $saas_conf_path".bak"
    
    {
        echo "[options]"
        echo "template_master =  wjTA27njWT9R3czg"
        echo "container_master = JkM5DvrD3wWSSMGP"
        echo "container_user = odooadmin"
        echo "container_passwd = 4ac97Zj2fhaKEC5k"
        echo "odoo_image_v17 = odoobywebkul:17.0"
        echo "odoo_image_v16 = odoobywebkul:16.0"
        echo "odoo_image_v15 = odoobywebkul:15.0"
        echo ""
        echo "nginx_vhosts = ${odoo_saas_custom_path}Odoo-SAAS-Data/docker_vhosts/"
        echo "data_dir_path = /opt/data-dir"
        echo "default_version = 17.0"
        echo "odoo_saas_data = ${odoo_saas_custom_path}Odoo-SAAS-Data"
        echo ""
        echo "odoo_template_v17 = odoo17_template_cont"
        echo "common_addons_v17 = ${odoo_saas_custom_path}common-addons_v17"
        echo "template_odoo_port_v17 = 8817"
        echo "template_odoo_lport_v17 = 8827"
        echo ""
        echo "odoo_template_v16 = odoo16_template_cont"
        echo "common_addons_v16 = ${odoo_saas_custom_path}common-addons_v16"
        echo "template_odoo_port_v16 = 8816"
        echo "template_odoo_lport_v16 = 8826"
        echo ""
        echo "odoo_template_v15 = odoo15_template_cont"
        echo "common_addons_v15 = ${odoo_saas_custom_path}common-addons_v15"
        echo "template_odoo_port_v15 = 8815"
        echo "template_odoo_lport_v15 = 8825"
    } > ${saas_conf_path}
    
    ##### Copy saas.conf file to custom_plans saas.conf
    cp "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf "$odoo_saas_custom_path"webkul_addons/saas_kit_custom_plans/models/lib/saas.conf
    
    
}

vhost_template_file_update() {
    
    ##### copy vhosttemplete from odoo_saas_kit/models/lib/vhosts to Odoo-SAAS_data/docker_vhosts/
    cp -r "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/vhosts/* "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/
    
    ##### Copy vhosttemplatehttps.txt to vhosttemplate.txt
    cp "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplatehttps.txt "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    
    
    ##### Edit the tls certificate path in vhosttemplate.txt file
    
    # using sed
    vhost_template_path="$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    cp $vhost_template_path $docker_vhosts_path".bak"
    
    temp_certificate_path=/etc/letsencrypt/live/$server_domain"/fullchain.pem"
    temp_certificate_key_path=/etc/letsencrypt/live/$server_domain"/privkey.pem"
    
    # Prompt user for new paths with default values pre-filled
    echo -n "Enter the new path for the SSL certificate (default: $temp_certificate_path): "
    read -r new_certificate_path
    
    echo -n "Enter the new path for the SSL certificate key (default: $temp_certificate_key_path): "
    read -r new_certificate_key_path
    
    # Use current values if user input is empty
    ssl_certificate_path="${new_certificate_path:-$temp_certificate_path}"
    ssl_certificate_key_path="${new_certificate_key_path:-$temp_certificate_key_path}"
    
    
    # Use current values if user input is empty
    ssl_certificate_path=${new_certificate_path:-$temp_certificate_path}
    ssl_certificate_key_path=${new_certificate_key_path:-$temp_certificate_key_path}
    
    sed -i "s|^\s*ssl_certificate\s\+.*;|ssl_certificate $ssl_certificate_path;|" $vhost_template_path
    sed -i "s|^\s*ssl_certificate_key\s\+.*;|ssl_certificate_key $ssl_certificate_key_path;|" $vhost_template_path
    
    # using nano
    # nano "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    
    ################################
    # Change these SSL parameters
    # ssl_certificate /etc/letsencrypt/live/ulii.tech/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/ulii.tech/privkey.pem;
    ################################
}

odoo_addons_add_path() {
    
    ##### Add your addons path to odoo-server config files
    
    # using awk
    append_path="$odoo_saas_custom_path"webkul_addons
    cp $odoo_conf_file $odoo_conf_file".bak"
    
    awk -v new_path="$append_path" '
BEGIN { FS=OFS="=" }
{
    if ($1 ~ /^addons_path[ \t]*$/) {
    gsub(/[ \t]*#[^\n]*$/, "", $2);
    gsub(/[ \t]*,[ \t]*$/, "", $2);
    if ($2 == "") {
      $2 = new_path;
    } else {
      $2 = $2 "," new_path;
    }
    print "addons_path = " $2;
    found=1;
  } else {
    print;
  }
}
END {
  if (!found) {
    print "addons_path = " new_path;
  }
}
    ' "$odoo_conf_file" > "${odoo_conf_file}.tmp"
    
    mv ${odoo_conf_file}.tmp $odoo_conf_file
    
    # using nano
    # nano $odoo_conf_file
    
    ################################
    # Add your webkul addons path in addons
    # addons_path = /home/odoo/odoo-17/odoo/addons,/home/odoo/odoo-17-saas-webkul/webkul_addons
    ###############################
    
}

odoo_change_ownership() {
    ##### Change file ownership to Odoo user
    chown -R "$odoo_username": $odoo_saas_custom_path
    chown -R "$odoo_username": $odoo_conf_file
}

sudoer_file_edit() {
    ##### Edit sudoer file to give nginx and certbot access to oddo user
    # using echo
    cp $sudoers_file_path "$sudoers_file_path".tmp
    {
        echo "# Custom rules added by OdooSaas"
        echo "$odoo_username ALL=(ALL) NOPASSWD: /usr/sbin/nginx"
        echo "$odoo_username ALL=(ALL) NOPASSWD: /usr/bin/certbot"
    } >> "$sudoers_file_path".tmp
    if visudo -c -f "$sudoers_file_path".tmp; then
        mv "$sudoers_file_path".tmp "$sudoers_file_path"
    else
        echo "unable to edit sudoer file edit it manually"
    fi
    
    # using visudo
    # visudo
    #########################################
    # Add these lines in suoders file
    # odoo ALL=(ALL)NOPASSWD:/usr/sbin/nginx
    # odoo ALL=(ALL)NOPASSWD:/usr/bin/certbot
    #########################################
}

nginx_conf_update() {
    ##### Edit nginx.conf file to include docker vhost configs
    
    # using sed
    docker_vhosts_path=$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/*.conf;"
    sed -i.bak -e "/include \/etc\/nginx\/sites-enabled\/\*.conf;/i include $docker_vhosts_path" nginx.conf
    
    # using nano
    # nano /etc/ngnix/nginx.conf
    
    #########################################
    # Add this line before nginx sites enabled conf file
    # include /home/odoo/odoo-17-saas-webkul/Odoo-SAAS-Data/docker_vhosts/*.conf;
    #########################################
}

restart_services() {
    ##### restart services
    systemctl restart postgresql
    systemctl restart odoo-17.service
    systemctl restart nginx
}

view_logs() {
    ##### View logs while Doing UI Part to catch errors
    tail -f $odoo_server_log_file_location
}


##############################################
################### UI Part ##################
##############################################

# Activate addons one by one
# Create Server config
# Create SAAS Plan
# Create Sales Product with this plan
# Create contract
# Create Client
# Create Multiple Odoo versions
