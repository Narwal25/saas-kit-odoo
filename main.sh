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
for arg in "$@"; do
    case $arg in
        --non-interactive)
        NON_INTERACTIVE=true
        shift
        ;;
    esac
done

# Source required files
source .env
source check_variables.sh
source variables-prompt.sh
source prompts.sh
source docker_install.sh
source postgres.sh
source saas_kit.sh

# Function for interactive mode
run_interactive() {
    echo "Running in interactive mode..."

    variable-prompt
    check_variables
    prompt_variables_choice

    packages_install
    python_packages_install
    docker_install
    oddo_user_docker_add

    prompt_ssl_choice

    postgres_create_role
    postgres_update_pg_hba
    postgres_upadate_postgres_conf

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
    view_logs
}

# Function for non-interactive mode
run_non_interactive() {
    echo "Running in non-interactive mode..."
    
    check_variables
    packages_install
    python_packages_install
    docker_install
    oddo_user_docker_add

    postgres_create_role
    postgres_update_pg_hba
    postgres_upadate_postgres_conf

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
    view_logs
}

# Main script logic based on mode
if [ "$NON_INTERACTIVE" = true ]; then
    run_non_interactive
else
    run_interactive
fi
