#!/bin/bash

usage()
{
  echo "Usage: --namespace <desired namespace> [optional]"
  echo "     : --override <deletes resource if exists and creates new one> [optional; does not work with update]"
  echo "     : --update <updates existed resourcewithout be deleted; recreates if not exists> [optional; does not work with override]"
  echo "     : --add-ons <updates existed resourcewithout be deleted; recreates if not exists> [optional; does not work with override]"
  echo "     : --cluster-type [optional; possible values: kubernetes or openshift; default kubernetes]"
}

namespace=""
createCommand=""
use_add_ons=false
engine="--engine kubernetes"


while [ "$1" != "" ]; do
    case $1 in

        --namespace   )  shift
                       namespace="--namespace $1"
                       ;;

        --override )  if [[ -z $createCommand ]]; then
			createCommand="--override "
	             else
			     echo "--override could not be used with --update"
			     usage
			     exit 1
	             fi
		     ;;

        --update)  if [[ -z $createCommand ]]; then
			createCommand="--update"
	             else
			     echo "--update could not be used with --override"
			     usage
			     exit 1
	             fi
		     ;;

        --add-ons)
            use_add_ons=true
		     ;;

        --cluster-type ) shift
                         if [ "$1" == "kubernetes" ]; then
                            engine="--engine kubernetes"
                         elif [ "$1" == "openshift" ]; then
                            engine="--engine openshift"
                         else
                            echo "unsupported cluster type"
                            usage
                            exit 1
                         fi
                         ;;

        * )            usage
                       exit 1
                       ;;
    esac
    shift
done


p=$0
path=${p%/*}

# SSL configuration
# prepare SSL configuration because it effects on server config map content
#$path/configure_ssl.sh --config-dir $path/../config $namespace --ais --gsoap --webservices $createCommand $engine

#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/wlx-initial-config/webserver"          --config-list "$path/../config/cdd-initial-config/cdd-config-groups/webserver-config.lst" --name cdd-webserver    $namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config"                     --config-list "$path/../config/cdd-initial-config/cdd-config-groups/ais-config.lst"       --name cdd-server       $namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config"                     --config-list "$path/../config/cdd-initial-config/cdd-config-groups/ais-secret.lst"       --name cdd-secret-keystore  $namespace --secret $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config"                     --config-list "$path/../config/cdd-initial-config/cdd-config-groups/amq-config.lst"       --name cdd-amq          $namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config"                     --config-list "$path/../config/cdd-initial-config/cdd-config-groups/log-config.lst"       --name cdd-logs         $namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/license"             --config-list "$path/../config/cdd-initial-config/cdd-config-groups/license.lst"          --name license              $namespace  --secret $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/db"                  --config-list "$path/../config/cdd-initial-config/cdd-config-groups/db-config.lst"        --name cdd-db           $namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/k8s_env_vars"        --config-list "$path/../config/cdd-initial-config/cdd-config-groups/cdd-k8s-env.lst"      --name cdd-env          $namespace  --env $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/secret_cnf/metadata" --name cdd-secret-metadata  $namespace  --secret $engine
#
#if [ -e "$path/../config/cdd-initial-config/secret_cnf/ssl" ]
#then
#  "$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/secret_cnf/ssl" --name cdd-secret-ssl  $namespace  --secret $engine
#fi
#
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/cdd-entrpnt-lctn"  --config-list "$path/../config/cdd-initial-config/cdd-config-groups/cdd-entrpnt-lctn.lst" --name cdd-entrpnt-lctn    	$namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/cdd-config/CDD_Config"   --config-list "$path/../config/cdd-initial-config/cdd-config-groups/cdd-config.lst" --name cdd-cdd     		$namespace $engine
#"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/cdd-initial-config/cdd-config/IDW"	   --config-list "$path/../config/cdd-initial-config/cdd-config-groups/idw-config.lst" --name cdd-idw    				$namespace $engine

"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/wlx-initial-config/wlx-entrpnt-lctn"  --config-list "$path/../config/wlx-initial-config/wlx-config-groups/wlx-entrpnt-lctn.lst" --name wlx-entrpnt-lctn    	$namespace $engine
"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/wlx-initial-config/wlx-config"  --config-list "$path/../config/wlx-initial-config/wlx-config-groups/wlx-config.lst" --name wlx-config   	$namespace $engine
"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/wlx-initial-config/ais-config"  --config-list "$path/../config/wlx-initial-config/wlx-config-groups/ais-config.lst" --name wlx-ais-config   	$namespace $engine
"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/wlx-initial-config/db"  --config-list "$path/../config/wlx-initial-config/wlx-config-groups/db-config.lst" --name wlx-db   	$namespace $engine
"$path/prepare_config_map.sh" $createCommand --config-dir "$path/../config/wlx-initial-config/license"  --config-list "$path/../config/wlx-initial-config/wlx-config-groups/license.lst"  --name license   $namespace  --secret $engine