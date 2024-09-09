#!/bin/bash

variable-prompt() {
    # Check if whiptail is installed
    if ! command -v whiptail &> /dev/null; then
        echo "whiptail is not installed."
        
        # Try to install whiptail based on the package manager available
        if command -v apt-get &> /dev/null; then
            echo "Installing whiptail using apt-get..."
            apt-get update
            apt-get install -y whiptail
            elif command -v yum &> /dev/null; then
            echo "Installing whiptail using yum..."
            yum install -y whiptail
            elif command -v dnf &> /dev/null; then
            echo "Installing whiptail using dnf..."
            dnf install -y whiptail
            elif command -v brew &> /dev/null; then
            echo "Installing whiptail using brew..."
            brew install whiptail
        else
            echo "Package manager not found. Please install whiptail manually."
            exit 1
        fi
    fi
    
    # Proceed with the rest of the script if whiptail is installed
    echo "whiptail is installed. Proceeding with the script..."
    
    # Check if the .env file exists
    if [[ -f .env ]]; then
        # Source the .env file to load environment variables
        source .env
        echo ".env file found and variables loaded."
    else
        echo ".env file not found. Continuing without loading variables."
    fi
    
    # Function to prompt user for input with default values using whiptail
    prompt_for_input() {
        local var_name=$1
        local default_value=$2
        local input
        
        input=$(whiptail --inputbox "Enter value for $var_name (default: $default_value):" 10 60 "$default_value" 3>&1 1>&2 2>&3)
        
        # Check if user pressed Cancel
        if [[ $? -ne 0 ]]; then
            echo "$default_value"
        else
            echo "$input"
        fi
    }
    
    # Get user inputs with defaults
    odoo_saas_custom_path=$(prompt_for_input "odoo_saas_custom_path" "$odoo_saas_custom_path")
    odoo_saas_files_path=$(prompt_for_input "odoo_saas_files_path" "$odoo_saas_files_path")
    odoo_conf_file=$(prompt_for_input "odoo_conf_file" "$odoo_conf_file")
    odoo_server_systemctl_name=$(prompt_for_input "odoo_server_systemctl_name" "$odoo_server_systemctl_name")
    odoo_server_log_file_location=$(prompt_for_input "odoo_server_log_file_location" "$odoo_server_log_file_location")
    odoo_username=$(prompt_for_input "odoo_username" "$odoo_username")
    odoo_python_pip_path=$(prompt_for_input "odoo_python_pip_path" "$odoo_python_pip_path")
    postgres_odoo_saas_username=$(prompt_for_input "postgres_odoo_saas_username" "$postgres_odoo_saas_username")
    postgres_odoo_saas_password=$(prompt_for_input "postgres_odoo_saas_password" "$postgres_odoo_saas_password")
    postgres_pg_hba_conf_path=$(prompt_for_input "postgres_pg_hba_conf_path" "$postgres_pg_hba_conf_path")
    postgres_postgresql_conf_path=$(prompt_for_input "postgres_postgresql_conf_path" "$postgres_postgresql_conf_path")
    server_domain=$(prompt_for_input "server_domain" "$server_domain")
    server_public_ip=$(prompt_for_input "server_public_ip" "$server_public_ip")
    server_email=$(prompt_for_input "server_email" "$server_email")
    sudoers_file_path=$(prompt_for_input "sudoers_file_path" "$sudoers_file_path")
    if  [ "$REMOTE_SERVER" = true ]; then
        remote_server_ip=$(prompt_for_input "remote_server_ip" "$remote_server_ip")
        remote_server_ssh_user=$(prompt_for_input "remote_server_ssh_user" "$remote_server_ssh_user")
        remote_server_ssh_password=$(prompt_for_input "remote_server_ssh_password" "$remote_server_ssh_password")
        remote_server_ssh_user_home_dir=$(prompt_for_input "remote_server_ssh_user_home_dir" "$remote_server_ssh_user_home_dir")
    fi
    if  [ "$REMOTE_DATABASE" = true ]; then
        db_server_ip=$(prompt_for_input "db_server_ip" "$db_server_ip")
        db_server_ssh_user=$(prompt_for_input "db_server_ssh_user" "$db_server_ssh_user")
        db_server_ssh_password=$(prompt_for_input "db_server_ssh_password" "$db_server_ssh_password")
    fi
    
    # Create the .env file
    {
        echo "odoo_saas_custom_path=$odoo_saas_custom_path"
        echo "odoo_saas_files_path=$odoo_saas_files_path"
        echo "odoo_conf_file=$odoo_conf_file"
        echo "odoo_server_systemctl_name=$odoo_server_systemctl_name"
        echo "odoo_server_log_file_location=$odoo_server_log_file_location"
        echo "odoo_username=$odoo_username"
        echo "odoo_python_pip_path=$odoo_python_pip_path"
        echo "postgres_odoo_saas_username=$postgres_odoo_saas_username"
        echo "postgres_odoo_saas_password=$postgres_odoo_saas_password"
        echo "postgres_pg_hba_conf_path=$postgres_pg_hba_conf_path"
        echo "postgres_postgresql_conf_path=$postgres_postgresql_conf_path"
        echo "server_domain=$server_domain"
        echo "server_public_ip=$server_public_ip"
        echo "server_email=$server_email"
        echo "sudoers_file_path=$sudoers_file_path"
    } > .env
    
    {
        echo "remote_server_ip=$remote_server_ip"
        echo "remote_server_ssh_user=$remote_server_ssh_user"
        echo "remote_server_ssh_password=$remote_server_ssh_password"
        echo "remote_server_ssh_user_home_dir=$remote_server_ssh_user_home_dir"
    } >> .env
    
    {
        echo "db_server_ip=$db_server_ip"
        echo "db_server_ssh_user=$db_server_ssh_user"
        echo "db_server_ssh_password=$db_server_ssh_password"
    } >> .env
    
    echo "Environment variables have been saved to .env"
    
}