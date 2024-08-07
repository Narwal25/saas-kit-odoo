##################################################################
######################## Setup Variables #########################
#### Setting up variables is must to use most of the commands ####
##################################################################

odoo_saas_custom_path=/opt/odoo/odoo-17-saas-webkul/
odoo_saas_files_path=/root/saas/

odoo_conf_file=/etc/oddo.conf
odoo_server_systemctl_name=odoo
odoo_server_log_file_location=/var/log/odoo/odoo.log
odoo_username=odoo
odoo_python_pip_path="/home/odoo/.pyenv/versions/odoo-17-env/bin/python -m pip"

postgres_odoo_saas_username=odoosaas
postgres_odoo_saas_password=odoosaas
postgres_pg_hba_conf_path=/etc/postgresql/14/main/pg_hba.conf
postgres_postgresql_conf_path=/etc/postgresql/14/main/postgresql.conf

server_domain=saas-testing.vachak.com
server_public_ip=102.223.38.107
server_email=admin@saas_testing.vachak.com

sudoers_file_path=/etc/sudoers
