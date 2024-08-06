############## Check Variables ##############

check_variables() {
    echo "Look carefully if all variables are set correctly."
    echo "If not, Set those and Re-run it"
    
    echo "odoo_saas_custom_path = " $odoo_saas_custom_path
    echo "odoo_saas_files_path= " $odoo_saas_files_path
    
    echo "odoo_conf_file= " $odoo_conf_file
    echo "odoo_server_systemctl_name= " $odoo_server_systemctl_name
    echo "odoo_server_log_file_location= " $odoo_server_log_file_location
    echo "odoo_username= " $odoo_username
    echo "odoo_python_pip_path= " $odoo_python_pip_path
    
    echo "postgres_odoo_saas_username= " $postgres_odoo_saas_username
    echo "postgres_odoo_saas_password= " $postgres_odoo_saas_password
    echo "postgres_pg_hba_conf_path= " $postgres_pg_hba_conf_path
    echo "postgres_postgresql_conf_path= " $postgres_postgresql_conf_path
    
    echo "server_domain= " $server_domain
    echo "server_public_ip= " $server_public_ip
    echo "server_email= " $server_email
    
    echo "sudoers_file_path= " $sudoers_file_path
}