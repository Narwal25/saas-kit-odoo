#!/bin/bash
# /lib/systemd/system/docker.service
# ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375

ssh_setup_remote_server() {
    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S sshpass --no-confirm
        elif [ -x "$(command -v apt)" ]; then
        sudo apt update
        sudo apt install sshpass -y
        elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install sshpass -y
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install"
        exit 1
    fi
    
    ssh-keyscan -H $remote_server_ip >> ~/.ssh/known_hosts
    KEY_PATH="/root/.ssh/id_rsa"
    if [ -f "$KEY_PATH" ]; then
        echo "SSH key already exists at $KEY_PATH. No new key generated."
    else
        ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
        echo "New SSH key generated at $KEY_PATH."
    fi
    sshpass -p $remote_server_ssh_password ssh-copy-id ${remote_server_ssh_user}@$remote_server_ip
}

sshremoteserver() {
    ssh ${remote_server_ssh_user}@${remote_server_ip} "if [ -f /tmp/remote_server.sh ]; then source /tmp/remote_server.sh; fi && if [ -f /tmp/.env ]; then source /tmp/.env; fi && $1"
}

packages_install_remote_server() {
    ##### Install certbot and nginx if not installed
    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S python3-pip sed gawk libpq-dev --no-confirm
        elif [ -x "$(command -v apt)" ]; then
        sudo apt update
        sudo apt install python3-pip sed gawk libpq-dev -y
        elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install python3-pip sed gawk libpq-dev -y
    else
        echo "FAILED TO INSTALL PACKAGE: Package manager not found. You must manually install"
        exit 1
    fi
}

python_packages_install_remote_server() {
    ##### Install python depencencies
    python_version=$(python3 --version 2>&1)
    echo "Python Version: $python_version"
    if [[ "$python_version" == *"Python 3.12"* ]]; then
        if [ -x "$(command -v dnf)" ]; then
            sudo dnf install python3-docker python3-paramiko python3-crontab python3-psycopg2 -y
            
            elif [ -x "$(command -v apt)" ]; then
            sudo apt update
            sudo apt install python3-docker python3-paramiko python3-crontab python3-psycopg2 -y
        fi
        
        echo "Install with --break-system-packages flag"
        sudo pip install --break-system-packages erppeek
        
    else
        echo "Else"
        sudo pip install docker erppeek paramiko python-crontab psycopg2
    fi
}

docker_install_remote_server() {
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    ##### Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    ##### Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ##### Install Docker pkgs
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    
}

odoo_user_variables() {
    {
        echo "odoo_user_id=$(id -u $odoo_username)"
        echo "odoo_user_gid=$(id -g $odoo_username)"
        echo "odoo_user_home_dir=$(getent passwd $odoo_username | cut -d: -f6)"
    } >> .env
}

odoo_user_add_remote_server() {
    sudo groupadd --gid $odoo_user_gid $odoo_username
    sudo adduser --system --home $odoo_user_home_dir --shell /bin/bash --uid $odoo_user_id --gid $odoo_user_gid $odoo_username
    sudo echo -e "newpassword\nnewpassword" | passwd $odoo_username
}

docker_image_save() {
    sudo docker save odoobywebkul:15.0 > odoobywebkul15.tar
    sudo docker save odoobywebkul:16.0 > odoobywebkul16.tar
    sudo docker save odoobywebkul:17.0 > odoobywebkul17.tar
}

docker_image_copy_remote_server() {
    scp -r odoobywebkul15.tar ${remote_server_ssh_user}@$remote_server_ip:$remote_server_ssh_user_home_dir
    scp -r odoobywebkul16.tar ${remote_server_ssh_user}@$remote_server_ip:$remote_server_ssh_user_home_dir
    scp -r odoobywebkul17.tar ${remote_server_ssh_user}@$remote_server_ip:$remote_server_ssh_user_home_dir
}

docker_load_image_remote_server() {
    sudo docker load < ~/odoobywebkul15.tar
    sudo docker load < ~/odoobywebkul16.tar
    sudo docker load < ~/odoobywebkul17.tar
}

saas_data_directory_create_remote_server() {
    sudo mkdir -pv $odoo_saas_custom_path
    sudo mkdir -pv "$odoo_saas_custom_path"Odoo-SAAS-Data
    sudo mkdir -pv "$odoo_saas_custom_path"common-addons_v15
    sudo mkdir -pv "$odoo_saas_custom_path"common-addons_v16
    sudo mkdir -pv "$odoo_saas_custom_path"common-addons_v17
    sudo chown -R "$remote_server_ssh_user": $odoo_saas_custom_path
}

saas_data_files_copy_remote_server() {
    scp -r "$odoo_saas_custom_path"Odoo-SAAS-Data/* ${remote_server_ssh_user}@$remote_server_ip:"$odoo_saas_custom_path"Odoo-SAAS-Data/
    scp -r "$odoo_saas_custom_path"common-addons_v15/* ${remote_server_ssh_user}@$remote_server_ip:"$odoo_saas_custom_path"common-addons_v15/
    scp -r "$odoo_saas_custom_path"common-addons_v16/* ${remote_server_ssh_user}@$remote_server_ip:"$odoo_saas_custom_path"common-addons_v16/
    scp -r "$odoo_saas_custom_path"common-addons_v17/* ${remote_server_ssh_user}@$remote_server_ip:"$odoo_saas_custom_path"common-addons_v17/
}

odoo_change_ownership_remote_server() {
    sudo chown -R "$odoo_username": $odoo_saas_custom_path
}

update_docker_service_file_remote_server() {
    entry_exists() {
        grep -qw  tcp://0.0.0.0:2375 /lib/systemd/system/docker.service
    }
    if ! entry_exists; then
        sudo sed -i.bak 's|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375|' /lib/systemd/system/docker.service
        
        echo "Updated Docker Service file"
    else
        echo "tcp://0.0.0.0:2375 already present"
    fi
    
}

restart_services_remote_server() {
    sudo systemctl daemon-reload
    sudo service docker restart
}
