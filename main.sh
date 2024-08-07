
############################################
######### Odoo SAAS Setup ##################
########### Version 17 #####################
############################################

############################################
##### This is working Script         #######
##### Some commands need manual input   ####
############################################

source variables.sh
source check_variables.sh
source prompts.sh
source docker_install.sh
source postgres.sh
source saas_kit.sh

check_variables
prompt_variables_choice

ubuntu_packages_install
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