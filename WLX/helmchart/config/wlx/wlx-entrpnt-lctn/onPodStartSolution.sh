#!/bin/bash

instance_name=$AIS_SERVER_DIR/Instances/actimize_server_1

# WLX configuration mapping
for file_name in AML_WLF_app_gui_items_internal.ini AML_WLF_DJLoadingConfig.ini AML_WLF_environment.ini INFRA_DBQ_EP_internal_config.ini INFRA_DBQ_internal_config.ini AML_WLF_autoRunServicesConfig.ini
do
	rm -f $instance_name/$file_name
    if [ -n "$AAF_AIS_FLOW" ]
    then
        cp $instance_name/temp/wlx-cnf-wlx/$file_name $instance_name/$file_name
    else
        ln -s $instance_name/temp/wlx-cnf-wlx/$file_name $instance_name/$file_name
    fi
done

# WLX mxparserconfig mapping

for file_name in AddtlPmtInf.config BkToCstmrDbtCdtNtfctn.config ClmNonRct.config CstmrCdtTrfInitn.config Dplct.config FICdtTrf.config FIToFICstmrCdtTrf.config FIToFICstmrDrctDbt.config FIToFIPmtCxlReq.config FIToFIPmtRvsl.config FIToFIPmtStsRpt.config PmtRtr.config ReqForDplct.config RjctInvstgtn.config RsltnOfInvstgtn.config UblToApply.config
do
    rm -f $instance_name/mx_parser_config/$file_name
    if [ -n "$AAF_AIS_FLOW" ]
    then
        cp $instance_name/temp/wlx_mx_parser_config/$file_name $instance_name/mx_parser_config/$file_name
    else
        ln -s $instance_name/temp/wlx_mx_parser_config/$file_name $instance_name/mx_parser_config/$file_name
    fi
done

# Creating WLX related folder
mkdir -p $instance_name/dump
