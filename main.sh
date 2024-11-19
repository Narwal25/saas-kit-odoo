############################################
######### Odoo SAAS Setup ##################
########### Version 17 #####################
############################################

############################################
##### This is working Script         #######
##### Some commands need manual input   ####
############################################

set -eu

NON_INTERACTIVE=false
REMOTE_SERVER=false
REMOTE_DATABASE=false
REMOTE_BACKUP=false
ENTERPRISE=false
for arg in "$@"; do
    case $arg in
        --non-interactive)
            NON_INTERACTIVE=true
            shift
        ;;
        --remote-server)
            REMOTE_SERVER=true
            shift
        ;;
        --remote-database)
            REMOTE_DATABASE=true
            shift
        ;;
        --remote-backup)
            REMOTE_BACKUP=true
            shift
        ;;
        --enterprise)
            ENTERPRISE=true
            shift
        ;;
    esac
done

# Source required files
source .env
source colors.sh
source check_variables.sh
source variables-prompt.sh
source prompts.sh
source docker_install.sh
source postgres.sh
source saas_kit.sh
source enterprise.sh
source remote_server.sh
source remote_backup.sh


run_setup_variables() {
    variable-prompt
    check_variables
    prompt_variables_choice
}

run_setup_database() {
    
    if  [ "$REMOTE_DATABASE" = true ]; then
        ssh_setup_database_server
        scp -r postgres.sh .env ${db_server_ssh_user}@${db_server_ip}:/tmp/
        sshdatabaseserver 'postgres_create_role'
        sshdatabaseserver 'postgres_update_pg_hba'
        sshdatabaseserver 'postgres_upadate_postgres_conf'
        if  [ "$REMOTE_SERVER" = true ]; then
            sshdatabaseserver 'postgres_update_pg_hba_remote_server'
        fi
    else
        postgres_create_role
        postgres_update_pg_hba
        postgres_upadate_postgres_conf
        if  [ "$REMOTE_SERVER" = true ]; then
            postgres_update_pg_hba_remote_server
        fi
    fi
    
}

# Function for interactive mode
run_interactive() {
    echo "Running in interactive mode..."
    
    packages_install
    python_packages_install
    docker_install
    odoo_user_docker_add
    
    prompt_ssl_choice
    
    run_setup_database
    
    saas_directory_create
    saas_docker_files_copy
    saas_docker_build
    saas_kit_files_copy
    saas_conf_paths_update
    vhost_template_file_update
    odoo_addons_add_path
    odoo_change_ownership
    
    sudoer_file_edit
    nginx_conf_update
    
    restart_services
}

# Function for non-interactive mode
run_non_interactive() {
    echo "Running in non-interactive mode..."
    
    check_variables
    packages_install
    python_packages_install
    docker_install
    odoo_user_docker_add
    
    run_setup_database
    
    saas_directory_create
    saas_docker_files_copy
    saas_docker_build
    saas_kit_files_copy
    saas_conf_paths_update
    vhost_template_file_update_non_interactive
    odoo_addons_add_path
    odoo_change_ownership
    
    sudoer_file_edit
    nginx_conf_update
    
    restart_services
}

run_remote_server() {
    odoo_user_variables
    ssh_setup_remote_server
    scp -r remote_server.sh .env ${remote_server_ssh_user}@${remote_server_ip}:/tmp/
    sshremoteserver 'source /tmp/remote_server.sh'
    sshremoteserver 'source /tmp/.env'
    sshremoteserver 'packages_install_remote_server'
    sshremoteserver 'python_packages_install_remote_server'
    sshremoteserver 'docker_install_remote_server'
    sshremoteserver 'odoo_user_add_remote_server'
    sshremoteserver 'sudo usermod -a -G docker $odoo_username'
    run_setup_database
    docker_image_save
    docker_image_copy_remote_server
    sshremoteserver 'docker_load_image_remote_server'
    sshremoteserver 'saas_data_directory_create_remote_server'
    saas_data_files_copy_remote_server
    sshremoteserver 'odoo_change_ownership_remote_server'
    sshremoteserver 'update_docker_service_file_remote_server'
    sshremoteserver 'restart_services_remote_server'
}

run_enterprise() {
    update_odoo_version_files
    saas_conf_paths_update_enterprise
    enterprise_path_and_files_add
}

run_remote_backup() {
    echo "Not Implemented yet"
}

# Main script logic based on mode
if [ "$NON_INTERACTIVE" = true ]; then
    run_non_interactive
else
    run_setup_variables
    run_interactive
fi

if  [ "$ENTERPRISE" = true ]; then
    run_enterprise
fi

if  [ "$REMOTE_SERVER" = true ]; then
    run_remote_server
fi

if  [ "$REMOTE_BACKUP" = true ]; then
    run_remote_backup
fi


view_logs