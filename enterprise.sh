#!/bin/bash

source .env

update_odoo_version_files() {
    local static_custom_plan_path="$odoo_saas_custom_path"webkul_addons/saas_kit_custom_plans/models/static_custom_plan.py
    local static_saas_kit_path="$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/static_saas_kit.py
    cp -v $static_custom_plan_path $static_custom_plan_path".bak"
    cp -v $static_saas_kit_path $static_saas_kit_path".bak"
    sed -i 's/.*SAAS_ODOO_VERSIONS.*/SAAS_ODOO_VERSIONS = ["15.0","16.0","17.0","15e.0","16e.0","17e.0"]/' $static_custom_plan_path
    sed -i 's/.*SAAS_ODOO_VERSIONS.*/SAAS_ODOO_VERSIONS = ["15.0","16.0","17.0","15e.0","16e.0","17e.0"]/' $static_saas_kit_path
}

saas_conf_paths_update_enterprise() {
    saas_conf_path="$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf
    cp -v $saas_conf_path $saas_conf_path".bak"
    
    {
        echo "[options]"
        echo "template_master =  wjTA27njWT9R3czg"
        echo "container_master = JkM5DvrD3wWSSMGP"
        echo "container_user = odooadmin"
        echo "container_passwd = 4ac97Zj2fhaKEC5k"
        echo "odoo_image_v17 = odoobywebkul:17.0"
        echo "odoo_image_v16 = odoobywebkul:16.0"
        echo "odoo_image_v15 = odoobywebkul:15.0"
        echo "odoo_image_v17e = odoobywebkul:17.0"
        echo "odoo_image_v16e = odoobywebkul:16.0"
        echo "odoo_image_v15e = odoobywebkul:15.0"
        echo ""
        echo "nginx_vhosts = ${odoo_saas_custom_path}Odoo-SAAS-Data/docker_vhosts/"
        echo "data_dir_path = /opt/data-dir"
        echo "default_version = 17.0"
        echo "odoo_saas_data = ${odoo_saas_custom_path}Odoo-SAAS-Data/"
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
        echo ""
        echo "odoo_template_v15 = odoo15_template_cont"
        echo "common_addons_v15 = ${odoo_saas_custom_path}common-addons_v15"
        echo "template_odoo_port_v15 = 8815"
        echo "template_odoo_lport_v15 = 8825"
        echo ""
        echo "odoo_template_v15e = odoo15e_template_cont"
        echo "common_addons_v15e = ${odoo_saas_custom_path}common-addons_v15e"
        echo "template_odoo_port_v15e = 8835"
        echo "template_odoo_lport_v15e = 8845"
        echo ""
        echo "odoo_template_v16e = odoo16e_template_cont"
        echo "common_addons_v16e = ${odoo_saas_custom_path}common-addons_v16e"
        echo "template_odoo_port_v16e = 8836"
        echo "template_odoo_lport_v16e = 8846"
        echo ""
        echo "odoo_template_v17e = odoo17e_template_cont"
        echo "common_addons_v17e = ${odoo_saas_custom_path}common-addons_v17e"
        echo "template_odoo_port_v17e = 8837"
        echo "template_odoo_lport_v17e = 8847"
    } > ${saas_conf_path}
    
    ##### Copy saas.conf file to custom_plans saas.conf
    cp -vu "$odoo_saas_custom_path"webkul_addons/odoo_saas_kit/models/lib/saas.conf "$odoo_saas_custom_path"webkul_addons/saas_kit_custom_plans/models/lib/saas.conf
    
    echo "Updated saas.conf file"
    cat $saas_conf_path
    
}

enterprise_path_and_files_add() {
    mkdir -pv "$odoo_saas_custom_path"common-addons_v15e
    mkdir -pv "$odoo_saas_custom_path"common-addons_v16e
    mkdir -pv "$odoo_saas_custom_path"common-addons_v17e
    cp -ruv "$odoo_saas_custom_path"common-addons_v15/wk_saas_tool/ "$odoo_saas_custom_path"common-addons_v15e/wk_saas_tool
    cp -ruv "$odoo_saas_custom_path"common-addons_v16/wk_saas_tool/ "$odoo_saas_custom_path"common-addons_v16e/wk_saas_tool
    cp -ruv "$odoo_saas_custom_path"common-addons_v17/wk_saas_tool/ "$odoo_saas_custom_path"common-addons_v17e/wk_saas_tool
    chown -R "$odoo_username": $odoo_saas_custom_path
}