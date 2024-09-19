############## Check Variables ##############

check_variables() {
    echo -e "${red}${bold}Look carefully if all variables are set correctly."
    echo -e "If not, Set those and Re-run it ${reset}"
    
    echo -e "${reset}odoo_saas_custom_path= ${green}" $odoo_saas_custom_path
    echo -e "${reset}odoo_saas_files_path= ${green}" $odoo_saas_files_path
    
    echo -e "${reset}odoo_conf_file= ${green}" $odoo_conf_file
    echo -e "${reset}odoo_server_systemctl_name= ${green}" $odoo_server_systemctl_name
    echo -e "${reset}odoo_server_log_file_location= ${green}" $odoo_server_log_file_location
    echo -e "${reset}odoo_username= ${green}" $odoo_username
    echo -e "${reset}odoo_python_pip_path= ${green}" $odoo_python_pip_path
    
    echo -e "${reset}postgres_odoo_saas_username= ${green}" $postgres_odoo_saas_username
    echo -e "${reset}postgres_odoo_saas_password= ${green}" $postgres_odoo_saas_password
    echo -e "${reset}postgres_pg_hba_conf_path= ${green}" $postgres_pg_hba_conf_path
    echo -e "${reset}postgres_postgresql_conf_path= ${green}" $postgres_postgresql_conf_path
    
    echo -e "${reset}server_domain= ${green}" $server_domain
    echo -e "${reset}server_public_ip= ${green}" $server_public_ip
    echo -e "${reset}server_email= ${green}" $server_email
    
    echo -e "${reset}sudoers_file_path= ${green}" $sudoers_file_path
    
    if  [ "$REMOTE_SERVER" = true ]; then
        echo -e "${reset}remote_server_ip= ${green}" $remote_server_ip
        echo -e "${reset}remote_server_ssh_user= ${green}" $remote_server_ssh_user
        echo -e "${reset}remote_server_ssh_password= ${green}" $remote_server_ssh_password
        echo -e "${reset}remote_server_ssh_user_home_dir= ${green}" $remote_server_ssh_user_home_dir
    fi
    
    if [ "$REMOTE_DATABASE" = true ]; then
        echo -e "${reset}db_server_ip= ${green}" $db_server_ip
        echo -e "${reset}db_server_ssh_user= ${green}" $db_server_ssh_user
        echo -e "${reset}db_server_ssh_password= ${green}" $db_server_ssh_password
    fi
    echo -e "${reset}"
}