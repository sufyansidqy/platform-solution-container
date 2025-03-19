#!/bin/bash
usage()
{
  echo "Usage: --name <config map name> [mandatory]"
  echo "     : --from-file <path to config map source> [mandatory; multiple] - could not be used together with from-env-file"
  echo "     : --from-env-file <path to environment config map source> [mandatory; multiple] - could not be used together with from-file"
  echo "     : --secret <use to create secret resource> [optional]"
  echo "     : --namespace <desired namespace> [optional]"
  echo "     : --temp-dir <directory to store temporary files> [optional]"
}

_temp_dir="/tmp"
_namespace="default"
_create_from=()
_env=false
_data=false
_secret=false

while [ "$1" != "" ]; do
    case $1 in
        --temp-dir  ) shift
                       _temp_dir=$1
                       ;;

        --namespace   )  shift
                       _namespace=$1
                       ;;

        --from-file   ) shift

                        if $_env; then
                            echo "different configmap source types simultaneous usage"
                            usage
                            exit 1
                        fi

                        _data=true
                        _create_from+=("$1")
                        ;;

        --from-env-file   )  shift
                        if $_data; then
                            echo "different configmap source types simultaneous usage"
                            usage
                            exit 1
                        fi
                        _env=true
                       _create_from+=("$1")
                       ;;

        --name        ) shift
                       _name=$1
                       ;;

        --secret        ) _secret=true
                       ;;


        * )
                        echo $1
                        usage
                       exit 1
                       ;;
    esac
    shift
done

if [ -e $_temp_dir/$_name ] ; then
    rm -f $_temp_dir/$_name
fi

if $_secret && $_env; then
    echo unable to create secret from environment source
    usage
    exit 1
fi

process_secret_resource_file()
{
    _filePath=$1
    _base64Line=$(base64 -w 0 $_filePath)
    _fileName=${_filePath##*/*/}
    echo "  $_fileName: $_base64Line"  >>  $_temp_dir/$_name
}

process_configmap_resource_file()
{
    _filePath="$1"
    _fileName=${_filePath##*/*/}

    if $_data; then
        echo "  $_fileName: |" >> $_temp_dir/$_name
    fi

    while IFS= read -r line  || [[ -n "$line" ]] #IFS= in case you want to preserve leading and trailing spaces
    do
        if $_data; then
            # data path
            echo "    $line" >> $_temp_dir/$_name
        else
            # environment path
	    if [[ -n "$line" ]]; then
                __key=${line%=*}
                __value=${line#*=}
               echo -n "  $__key: \"$__value\"" >> $_temp_dir/$_name
               echo "" >> $_temp_dir/$_name
            fi
        fi
    done < "$_filePath"
 }

create_secret_resource_file()
{
    echo "apiVersion: v1" >> $_temp_dir/$_name
    echo "kind: Secret" >> $_temp_dir/$_name
    echo "metadata:" >> $_temp_dir/$_name
    echo "  name: $_name" >> $_temp_dir/$_name
    echo "  namespace: $_namespace" >> $_temp_dir/$_name
    echo "data:"  >>  $_temp_dir/$_name

    for (( i=0; i<${#_create_from[@]}; i++ ));
    do
        if [ -f "${_create_from[$i]}" ]; then
            process_secret_resource_file "${_create_from[$i]}"

        elif [ -d "${_create_from[$i]}" ]; then
            for _entry in "${_create_from[$i]}"/*
            do
                process_secret_resource_file $_entry
            done
        else
            echo unsupported
            echo "${_create_from[$i]}"
            usage
            exit 1
        fi
     done
}

create_configmap_resource_file()
{
    echo "apiVersion: v1" >> $_temp_dir/$_name
    echo "kind: ConfigMap" >> $_temp_dir/$_name
    echo "metadata:" >> $_temp_dir/$_name
    echo "  name: $_name" >> $_temp_dir/$_name
    echo "  namespace: $_namespace" >> $_temp_dir/$_name
    echo "data:"  >>  $_temp_dir/$_name

    for (( i=0; i<${#_create_from[@]}; i++ ));
    do
        if [ -f "${_create_from[$i]}" ]; then
            process_configmap_resource_file "${_create_from[$i]}"

        elif [ -d "${_create_from[$i]}" ]; then
            for _entry in "${_create_from[$i]}"/*
            do
                process_configmap_resource_file "$_entry"
            done
        else
            echo unsupported
            echo "${_create_from[$i]}"
            usage
            exit 1
        fi
    done
}

if $_secret; then
    create_secret_resource_file
else
    create_configmap_resource_file
fi
