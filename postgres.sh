postgres_create_role() {
    ##### Create role in postgres
    role_exists=$(su - postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname = '$postgres_odoo_saas_username'\"")
    if [ "$role_exists" = "1" ]; then
        echo "Role '$postgres_odoo_saas_username' already exists."
    else
        echo "Creating role '$postgres_odoo_saas_username'..."
        su - postgres -c "psql -c \"CREATE ROLE $postgres_odoo_saas_username WITH NOCREATEROLE NOSUPERUSER CREATEDB LOGIN;\""
        echo "Role '$postgres_odoo_saas_username' created successfully."
    fi
    su - postgres -c "psql -U postgres -c \"ALTER ROLE $postgres_odoo_saas_username WITH PASSWORD '$postgres_odoo_saas_password';\""

    ##### Restart postgresql service
    systemctl restart postgresql
}

postgres_update_pg_hba() {
    ##### Add docker and your public ip in pg_hba.conf file
    
    # Check if already present
    entry_exists() {
        grep -qw $server_public_ip/32 $postgres_pg_hba_conf_path && \
        grep -qw '172.17.0.0/16' $postgres_pg_hba_conf_path && \
        grep -qw '127.0.0.1/32' $postgres_pg_hba_conf_path
    }
    
    if ! entry_exists; then
        awk -v spip="$server_public_ip" '
            BEGIN {
                print "# Entries for odoosaas";
                print "host    all     all     127.0.0.1/32    md5";
                print "host    all     all     172.17.0.0/16    md5";
                print "host    all     all     " spip "/32    md5";
                print "";
            }
            {
                print
        }' "$postgres_pg_hba_conf_path" > temp && mv temp "$postgres_pg_hba_conf_path"
        
        echo "Updated pg_hba.conf file"
    else
        echo "All enteries are alredy present"
    fi
    
    head $postgres_pg_hba_conf_path
    
    ##### Restart postgresql service
    systemctl restart postgresql
}


postgres_upadate_postgres_conf() {
    ##### Edit postgresql.conf file to listen to * and max connection to 1500
    
    # using sed
    sed -i.bak -e 's/^#*\s*listen_addresses\s*=.*/listen_addresses = '\''*'\''/' \
    -e 's/^#*\s*max_connections\s*=.*/max_connections = 1500/' \
    $postgres_postgresql_conf_path
    
    ##### Restart postgresql service
    systemctl restart postgresql
    
    echo "Updated postgresql.conf file"
    grep listen_addresses $postgres_postgresql_conf_path
    grep max_connections $postgres_postgresql_conf_path
    
}

postgres_update_pg_hba_remote_server() {
    ##### Add docker and your public ip in pg_hba.conf file
    
    # Check if already present
    entry_exists() {
        grep -qw $remote_server_ip/32 $postgres_pg_hba_conf_path 
    }
    
    if ! entry_exists; then
        awk -v spip="$remote_server_ip" '
            BEGIN {
                print "# Entry for odoosaas remote server";
                print "host    all     all     " spip "/32    md5";
                print "";
            }
            {
                print
        }' "$postgres_pg_hba_conf_path" > temp && mv temp "$postgres_pg_hba_conf_path"
        
        echo "Updated pg_hba.conf file"
    else
        echo "Remote server entry is alredy present"
    fi
    
    head $postgres_pg_hba_conf_path
    
    ##### Restart postgresql service
    systemctl restart postgresql
}

ssh_setup_database_server() {
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
    
    ssh-keyscan -H $db_server_ip >> ~/.ssh/known_hosts
    sshpass -p $db_server_ssh_password ssh-copy-id ${db_server_ssh_user}@$db_server_ip
    
}

sshdatabaseserver() {
    ssh ${db_server_ssh_user}@${db_server_ip} "if [ -f /tmp/postgres.sh ]; then source /tmp/postgres.sh; fi && if [ -f /tmp/.env ]; then source /tmp/.env; fi && $1"
}
