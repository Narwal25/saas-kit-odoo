packages_install() {
    ##### Install certbot and nginx if not installed
    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S nginx certbot python3-pip sed gawk --no-confirm
        elif [ -x "$(command -v apt)" ]; then
        sudo apt update
        sudo apt install nginx certbot python3-pip sed gawk -y
        elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install nginx certbot python3-pip sed gawk -y
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install"
        exit 1
    fi
}

python_packages_install() {
    ##### Install python depencencies
    python_version=$(python3 --version 2>&1)
    echo "Python Version: $python_version"
    if [[ "$python_version" == *"Python 3.12"* ]] && { [[ "$odoo_python_pip_path" == "pip" ]] || [[ "$odoo_python_pip_path" == "pip3" ]]; }; then
        if [ -x "$(command -v dnf)" ]; then
            sudo dnf install python3-docker python3-paramiko python3-crontab -y
            elif [ -x "$(command -v apt)" ]; then
            sudo apt update
            sudo apt install python3-docker python3-paramiko python3-crontab -y
        fi
        
        prompt_erppeek_choice() {
            echo "Do you want to install with --break-system-packages flag? (y/n): "
            read -r choice
            
            case "$choice" in
                [Yy]* )
                    echo "Install with --break-system-packages flag"
                    $odoo_python_pip_path install --break-system-packages erppeek
                ;;
                [Nn]* )
                    echo "Exiting the script."
                    echo "You should use a python virtual environment to install odoo"
                    exit 0
                ;;
                * )
                    echo "Invalid input. Please enter 'y' or 'n'."
                    prompt_erppeek_choice
                ;;
            esac
        }

        echo "Python package erppeek deb is not available"
        echo "You can install it with --break-system-packages flag"
        echo "It can break some system dependencies if conflict arise"
        prompt_erppeek_choice

    else
        echo "Else"
        $odoo_python_pip_path install docker erppeek paramiko python-crontab
    fi
}

odoo_user_docker_add() {
    ##### Add User odoo to docker group
    sudo usermod -a -G docker $odoo_username
    
    ##### verify if user is added into docker group
    id $odoo_username
}

saas_directory_create() {
    ##### Create saas custom directory
    mkdir -pv $odoo_saas_custom_path
    
    ##### Make these directory in your custom folder
    mkdir -pv "$odoo_saas_custom_path"Odoo-SAAS-Data
    mkdir -pv "$odoo_saas_custom_path"webkul_addons
    mkdir -pv "$odoo_saas_custom_path"common-addons_v16
    mkdir -pv "$odoo_saas_custom_path"common-addons_v17
    mkdir -pv "$odoo_saas_custom_path"common-addons_v18
    
    ##### Make these directories in your custom folder
    mkdir -pv "$odoo_saas_custom_path"dockerv16
    mkdir -pv "$odoo_saas_custom_path"dockerv17
    mkdir -pv "$odoo_saas_custom_path"dockerv18
    
    echo "Directories created"
    ls $odoo_saas_custom_path
}

saas_docker_files_copy() {
    ##### Copy files from docker files to dockerv16, dockerv17, docker18 a
    cp -ruv "$odoo_saas_files_path"docker_files-all/dockerv16/docker-data/ "$odoo_saas_custom_path"dockerv16
    cp -ruv "$odoo_saas_files_path"docker_files-all/dockerv17/docker-data/ "$odoo_saas_custom_path"dockerv17
    cp -ruv "$odoo_saas_files_path"docker_files-all/dockerv18/docker-data/ "$odoo_saas_custom_path"dockerv18
    
    echo "Copied Docker files"
}

saas_docker_build() {
    ##### Build your docker images
    ##### If you get any error you might not have docker files in the
    ##### specified directory
    docker build --build-arg ODOO_USER_UID=$(id -u $odoo_username) --build-arg ODOO_USER_GID=$(id -g $odoo_username) -t odoobywebkul:16.0 "$odoo_saas_custom_path"dockerv16/docker-data/.
    
    docker build --build-arg ODOO_USER_UID=$(id -u $odoo_username) --build-arg ODOO_USER_GID=$(id -g $odoo_username) -t odoobywebkul:17.0 "$odoo_saas_custom_path"dockerv17/docker-data/.
    
    docker build --build-arg ODOO_USER_UID=$(id -u $odoo_username) --build-arg ODOO_USER_GID=$(id -g $odoo_username) -t odoobywebkul:18.0 "$odoo_saas_custom_path"dockerv18/docker-data/.
    
    echo "Docker Images Created"
    docker images
    
}

saas_kit_files_copy() {
    ##### copy wk_saas_tool files in common addons in wk_saas_tool folder
    ##### In your saas folder
    cp -ruv "$odoo_saas_files_path"wk_saas_tool-16.0/ "$odoo_saas_custom_path"common-addons_v16/wk_saas_tool
    cp -ruv "$odoo_saas_files_path"wk_saas_tool-17.0/ "$odoo_saas_custom_path"common-addons_v17/wk_saas_tool
    cp -ruv "$odoo_saas_files_path"wk_saas_tool-18.0/ "$odoo_saas_custom_path"common-addons_v18/wk_saas_tool
    
    echo "Copied files in custom addons"
    
    ##### In your saas folder copy wk-sass-kit to Odoo-saas-data folder
    cp -ruv "$odoo_saas_files_path"odoo_saas_kit-18.0/* "$odoo_saas_custom_path"Odoo-SAAS-Data/
    
    ##### Copy config files to Odoo-Saas-data
    ##### from your saas folder
    cp -ruv "$odoo_saas_files_path"common-configuration-files-18.0/* "$odoo_saas_custom_path"Odoo-SAAS-Data/
    
    echo "Copied files in Odoo-SAAS-Data"
    
    ##### addons to webkul addons folder
    cp -ruv "$odoo_saas_files_path"odoo_saas_kit-18.0/ "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit
    cp -ruv "$odoo_saas_files_path"saas_kit_backup-18.0/ "$odoo_saas_custom_path"webkul_addons/saas_kit_backup
    cp -ruv "$odoo_saas_files_path"saas_kit_custom_plans-18.0/ "$odoo_saas_custom_path"webkul_addons/saas_kit_custom_plans
    cp -ruv "$odoo_saas_files_path"saas_kit_trial-18.0/ "$odoo_saas_custom_path"webkul_addons/saas_kit_trial
    cp -ruv "$odoo_saas_files_path"wk_backup_restore-18.0/ "$odoo_saas_custom_path"webkul_addons/wk_backup_restore
    
    ##### depend on requirement you might not need custom plan trail
    ##### cp -ruv "$odoo_saas_files_path"custom_plans_trial-18.0/ "$odoo_saas_custom_path"webkul_addons/custom_plans_trial
    
    echo "Copied files in webkul-addons"
    
}

saas_conf_paths_update() {
    ##### change path in webkul_addons/odoo_saas_kit/models/lib/saas.conf file
    
    # using echo
    saas_conf_path="$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf
    cp -v $saas_conf_path $saas_conf_path".bak"
    
    {
        echo "[options]"
        echo "template_master =  wjTA28njWT9R3czg"
        echo "container_master = JkM5DvrD3wWSSMGP"
        echo "container_user = odooadmin"
        echo "container_passwd = 4ac97Zj2fhaKEC5k"
        echo "odoo_image_v18 = odoobywebkul:18.0"
        echo "odoo_image_v17 = odoobywebkul:17.0"
        echo "odoo_image_v16 = odoobywebkul:16.0"
        echo ""
        echo "nginx_vhosts = ${odoo_saas_custom_path}Odoo-SAAS-Data/docker_vhosts/"
        echo "data_dir_path = /opt/data-dir"
        echo "default_version = 18.0"
        echo "odoo_saas_data = ${odoo_saas_custom_path}Odoo-SAAS-Data"
        echo ""
        echo "odoo_template_v18 = odoo18_template_cont"
        echo "common_addons_v18 = ${odoo_saas_custom_path}common-addons_v18"
        echo "template_odoo_port_v18 = 8818"
        echo "template_odoo_lport_v18 = 8828"
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
    } > ${saas_conf_path}
    
    ##### Copy saas.conf file to custom_plans saas.conf
    cp -vu "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf "$odoo_saas_custom_path"webkul_addons/saas_kit_custom_plans/models/lib/saas.conf
    
    echo "Updated saas.conf file"
    cat $saas_conf_path
    
}

vhost_template_file_update() {
    
    ##### copy vhosttemplete from odoo_saas_kit/models/lib/vhosts to Odoo-SAAS_data/docker_vhosts/
    cp -ruv "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/vhosts/* "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/
    
    ##### Copy vhosttemplatehttps.txt to vhosttemplate.txt
    cp -uv "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplatehttps.txt "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    
    
    ##### Edit the tls certificate path in vhosttemplate.txt file
    
    # using sed
    vhost_template_path="$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    cp -uv $vhost_template_path $vhost_template_path".bak"
    
    temp_certificate_path=/etc/letsencrypt/live/$server_domain"/fullchain.pem"
    temp_certificate_key_path=/etc/letsencrypt/live/$server_domain"/privkey.pem"
    
    # Prompt user for new paths with default values pre-filled
    echo -n "Enter the new path for the SSL certificate (default: $temp_certificate_path): "
    read -r new_certificate_path
    
    echo -n "Enter the new path for the SSL certificate key (default: $temp_certificate_key_path): "
    read -r new_certificate_key_path
    
    # Use current values if user input is empty
    ssl_certificate_path=${new_certificate_path:-$temp_certificate_path}
    ssl_certificate_key_path=${new_certificate_key_path:-$temp_certificate_key_path}
    
    sed -i "s|^\s*ssl_certificate\s\+.*;|ssl_certificate $ssl_certificate_path;|" $vhost_template_path
    sed -i "s|^\s*ssl_certificate_key\s\+.*;|ssl_certificate_key $ssl_certificate_key_path;|" $vhost_template_path
    
    echo "Updated saas.conf file"
    cat $vhost_template_path
}

vhost_template_file_update_non_interactive() {
    
    ##### copy vhosttemplete from odoo_saas_kit/models/lib/vhosts to Odoo-SAAS_data/docker_vhosts/
    cp -ruv "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/vhosts/* "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/
    
    ##### Copy vhosttemplatehttps.txt to vhosttemplate.txt
    cp -uv "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplatehttps.txt "$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    
    
    ##### Edit the tls certificate path in vhosttemplate.txt file
    
    # using sed
    vhost_template_path="$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/vhosttemplate.txt
    cp -uv $vhost_template_path $vhost_template_path".bak"
    
    ssl_certificate_path=/etc/letsencrypt/live/$server_domain"/fullchain.pem"
    ssl_certificate_key_path=/etc/letsencrypt/live/$server_domain"/privkey.pem"
    
    sed -i "s|^\s*ssl_certificate\s\+.*;|ssl_certificate $ssl_certificate_path;|" $vhost_template_path
    sed -i "s|^\s*ssl_certificate_key\s\+.*;|ssl_certificate_key $ssl_certificate_key_path;|" $vhost_template_path
    
    echo "Updated saas.conf file"
    cat $vhost_template_path
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
    
    echo "Updated odoo.conf file"
    cat $odoo_conf_file
}

odoo_change_ownership() {
    ##### Change file ownership to Odoo user
    chown -R "$odoo_username": $odoo_saas_custom_path
    chown -R "$odoo_username": $odoo_conf_file
}

sudoer_file_edit() {
    ##### Edit sudoer file to give nginx and certbot access to oddo user
    entry_exists() {
        grep -q "$odoo_username ALL=(ALL) NOPASSWD: /usr/sbin/nginx" $sudoers_file_path && \
        grep -q "$odoo_username ALL=(ALL) NOPASSWD: /usr/bin/certbot" $sudoers_file_path
    }
    
    if ! entry_exists; then
        
        # using echo
        cp -uv $sudoers_file_path "$sudoers_file_path".tmp
        {
            echo "# Custom rules added by OdooSaas"
            echo "$odoo_username ALL=(ALL) NOPASSWD: /usr/sbin/nginx"
            echo "$odoo_username ALL=(ALL) NOPASSWD: /usr/bin/certbot"
        } >> "$sudoers_file_path".tmp
    else
        echo "Entries already present"
    fi
    
    if visudo -c -f "$sudoers_file_path".tmp; then
        mv "$sudoers_file_path".tmp "$sudoers_file_path"
    else
        echo "unable to edit sudoer file edit it manually"
    fi
    
    echo "Updated sudoers file"
    cat $sudoers_file_path
}

nginx_conf_update() {
    ##### Edit nginx.conf file to include docker vhost configs
    
    docker_vhosts_path=$odoo_saas_custom_path"Odoo-SAAS-Data/docker_vhosts/*.conf;"
    
    entry_exists() {
        grep -q "$docker_vhosts_path" /etc/nginx/nginx.conf
    }
    
    if ! entry_exists; then
        
        # using sed
        sed -i.bak -e "/include \/etc\/nginx\/sites-enabled/i include $docker_vhosts_path" /etc/nginx/nginx.conf
        echo "ubdated /etc/nginx/nginx.conf file"
    else
        echo "All enteries are alredy present"
    fi
    
    echo "Updated nginx.conf file"
    cat /etc/nginx/nginx.conf
}

restart_services() {
    ##### restart services
    systemctl restart postgresql
    systemctl restart $odoo_server_systemctl_name
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
