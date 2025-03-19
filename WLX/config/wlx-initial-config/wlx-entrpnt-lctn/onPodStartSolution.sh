#!/bin/bash

instance_name=$AIS_SERVER_DIR/Instances/actimize_server_1

# WLX configuration mapping
for file_name in AML_WLF_app_gui_items_internal.ini AML_WLF_DJLoadingConfig.ini AML_WLF_environment.ini INFRA_DBQ_EP_internal_config.ini INFRA_DBQ_internal_config.ini
do
	rm -f $instance_name/$file_name
    if [ -n "$AAF_AIS_FLOW" ]
    then
        cp $instance_name/temp/wlx-cnf-wlx/$file_name $instance_name/$file_name
    else
        ln -s $instance_name/temp/wlx-cnf-wlx/$file_name $instance_name/$file_name
    fi
done

#AIS config
for file_name in ais_config.xml
do
	rm -f $instance_name/ais_config/$file_name
    if [ -n "$AAF_AIS_FLOW" ]
    then
        cp $instance_name/temp/ais-cnf-ais/$file_name $instance_name/ais_config/$file_name
    else
        ln -s $instance_name/temp/ais-cnf-ais/$file_name $instance_name/ais_config/$file_name
    fi
done

# DB configuration mapping
for file_name in odbc.ini
do
	rm -f /etc/odbc/$file_name
    if [ -n "$AAF_AIS_FLOW" ]
    then
        cp $instance_name/temp/ais-cnf-db/$file_name /etc/odbc/$file_name
    else
        ln -s $instance_name/temp/ais-cnf-db/$file_name /etc/odbc/$file_name
    fi
done

for file_name in tnsnames.ora
do
	rm -f /usr/lib/oracle/19.5/client64/lib/network/admin/$file_name
    if [ -n "$AAF_AIS_FLOW" ]
    then
        cp $instance_name/temp/ais-cnf-db/$file_name /usr/lib/oracle/19.5/client64/lib/network/admin/$file_name
    else
        ln -s $instance_name/temp/ais-cnf-db/$file_name /usr/lib/oracle/19.5/client64/lib/network/admin/$file_name
    fi
done



# Creating WLX related folder
mkdir -p $instance_name/dump
