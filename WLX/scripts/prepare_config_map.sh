#!/bin/bash

usage()
{
  echo "Usage: --name <config map name> [mandatory]"
  echo "     : --config-dir <shared configuration folder> [mandatory]"
  echo "     : --config-list <file with configurations will be taken from config-dir> [optional - when absent all files under config-dir will be used]"
  echo "     : --env <use to create environment config map> [optional]"
  echo "     : --secret <use to create secret resource> [optional]"
  echo "     : --namespace <desired namespace> [optional]"
  echo "     : --override <override resource if exists> [optional]"
  echo "     : --update <updates existed resource; creates new if resource does not exist> [optional]"
  echo "     : --engine [optional; possible values: kubernetes or openshift; default kubernetes]"
}

check_config_dir_validity()
{
if [ -e "$config_dir" ]
then
    if [ -f "$config_dir" ]
    then
        echo "specified configuration directory " $config_dir " is not directory"
        to_continue=false
    fi
    #echo "desired configuration directory is - " $config_dir
else
   echo "desired configuration directory " $config_dir " does not exist; skip resource creation"
   to_continue=false
fi
}

validate_shared_configs()
{
   file=$config_dir/$1
   if [ -e "$file" ]
   then
     echo "$file - OK"
   else
     echo "shared configuration file $1 does not exist in shared directory $config_dir; execution canceled"
     exit 1
   fi
}

load_config_list()
{
    _file=$1

    if [ -f "$_file" ]
    then
        c=0
        while IFS=$'\r' read line #IFS= in case you want to preserve leading and trailing spaces
        do
            shared_files[c]=$line # put line in the array
            c=$((c+1))            # increase counter by 1
        done < "$_file"
    else
        to_continue=false
    fi
}

check_config_list_validity()
{
    #echo "check_config_list_validity"
    # use for loop read all nameservers
    for (( i=0; i<${#shared_files[@]}; i++ ));
    do
        _cnf_file=$config_dir/${shared_files[$i]}

        #echo ${shared_files[$i]}
        #echo $_cnf_file

        if [ -e "$_cnf_file" ]
        then
            echo "$_cnf_file - OK"
        else
            echo "shared configuration file ${shared_files[$i]} does not exist in shared directory $config_dir"
            to_continue=false
        fi
    done
}

#! Main Script

config_dir=
namespace=
config_list=
name=
env_type=false
secret_type=false
to_continue=true
cleanFirst=false
update=false
command=""


while [ "$1" != "" ]; do
    case $1 in
        --config-dir  ) shift
                       config_dir=$1
                       ;;

        --namespace   )  shift
                       namespace="--namespace "$1
                       ;;

        --config-list ) shift
                       config_list=$1
                       ;;

        --name        ) shift
                       name=$1
                       ;;

        --engine        )shift
                         if [ "$1" == "kubernetes" ]; then
                            command="kubectl"
                         elif [ "$1" == "openshift" ]; then
                            command="oc"
                         else
                            echo "unsupported engine type"
                            usage
                            exit 1
                         fi
                         ;;

        --env         ) env_type=true
                       ;;

        --secret      ) secret_type=true
                       ;;

        --override    ) cleanFirst=true
                       ;;

        --update     ) update=true
                       ;;

        * )            usage
                       exit 1
                       ;;
    esac
    shift
done

iter_num=1
# single iteration only
while [ $iter_num -le 1 ]
do
    check_config_dir_validity
    if [ "$to_continue" != "true" ]
    then
        echo stop creation procedure
        break
    fi

    shared_files=()
    from_file_key="--from-file "

    if [ "$env_type" == "true" ]
    then
        from_file_key="--from-env-file "
    fi

    from_file_path=" "

    if [ "$config_list" != "" ]
    then
        load_config_list "$config_list"
        check_config_list_validity

        if [ "$to_continue" != "true" ]
        then
            echo stop creation procedure due to problem with config list
            break
        fi

        shared_files_len=${#shared_files[@]}
        for (( i=0; i<${shared_files_len}; i++ ));
        do
            from_file_path=$from_file_path$from_file_key" "
            from_file_path=$from_file_path\""$config_dir/${shared_files[$i]}"\"
            from_file_path=$from_file_path" "
        done
    else
        from_file_path=$from_file_path$from_file_key$config_dir
    fi



    iter_num=$(( $iter_num + 1 ))
done


    if [ "$to_continue" == "true" ]
    then
        _secretVar=""

        if [ "$secret_type" == "true" ]
        then
            if [ "$cleanFirst" == "true" ]; then
                _notFound=$($command get secret $name $namespace 2>&1 > /dev/null )
                 if [ "$_notFound" == "" ]; then
                     eval $command delete secret $name $namespace
                 fi
	        fi
            eval ${0%/*}/prepare_config_map_resource.sh --name $name $namespace $from_file_path --temp-dir /tmp --secret
            eval $command apply -f /tmp/$name
            rm -f /tmp/$name
            #eval kubectl create secret generic $name $from_file_path $namespace
        else
	    if $update; then
                 eval ${0%/*}/prepare_config_map_resource.sh --name $name $namespace $from_file_path --temp-dir /tmp $_secretVar
                 eval $command apply -f /tmp/$name
                 rm -f /tmp/$name
	    else
                if [ "$cleanFirst" == "true" ]; then
                    _notFound=$($command get configmap $name $namespace 2>&1 > /dev/null )
                    if [ "$_notFound" == "" ]; then
                        eval $command delete configmap $name $namespace
                    fi
                fi
                eval $command create configmap --save-config $name $from_file_path $namespace
	    fi
        fi

        #${0%/*}/prepare_config_map_resource.sh --name $name $namespace $from_file_path --temp-dir /tmp $_secretVar
        #eval kubectl apply -f /tmp/$name
        #rm -f /tmp/$name

    else
        usage
        exit 1
    fi
