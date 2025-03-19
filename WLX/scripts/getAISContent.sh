#!/bin/bash

usage()
{
    echo "getAISContent - copy configuration and AIS objects files from server."
    echo "Usage:"
    echo "    --local-server-source <The local server from which the files are copied>
        --instance <Mandatory. The source AIS instance name>
        --k8s-namespace <Optional. Kubernetes namespace name>
        --k8s-pod-name <Optional. Kubernetes pod name>

    --remote-server-source <The remote server from which the files are copied>
        --server <Mandatory. The source server address>
        --instance <Mandatory. The source AIS instance name>
        --user <Mandatory. The user name used to connect to the source server>
        --ssh-keystore-path <Optional. The path to the local keystore>
        --k8s-namespace <Optional. Kubernetes namespace name>
        --k8s-pod-name <Optional. Kubernetes pod name>

    --targetPath <Mandatory. The path to which the files must be copied>

    --to-server <Optional. Upload files to the AIS server >

    --preserve-folder-structure <Optional. Copy each file, matching the structure of the source path.>

    --include-ais-objects  <Optional. When provided, the relevant AIS internal files will be also copied and processes >

    --file <Optional. The relative file path of the file to copy. Multiple usage is allowed in a single command>

    --files-list <Optional. The path to the file that contains the list of files to copy, separated by new line. Multiple usage is allowed in a single command>

    --ais-object-file <Optional. The relative file path of the ais object file to copy to the AIS server. Multiple usage is allowed in a single command. Demands --include-ais-objects key>

    -h <Optional. Shows this text>

Examples:
    1) getAISContent.sh --local-server-source --instance actimize_server_1 --file ais_config.xml --file webserver/eh.ini --targetPath .
    The command above will copy the files ais_config.xml and webserver/eh.ini from AIS instance actimize_server_1 that is running in localhost to the
    current directory

    2) getAISContent.sh --local-server-source --k8s-namespace ais-ns --k8s-pod-name ais-inst-1 --instance actimize_server_1 --file ais_config.xml --file webserver/eh.ini --targetPath .
    The command above will copy files ais_config.xml and webserver/eh.ini from AIS instance actimize_server_1 is running in Kubernetes pod
    ais-ns/ais-inst-1 to current directory. Kubernetes cluster is managed by localhost.

    3) getAISContent.sh --remote-server-source --server 10.220.199.129 --user ec2-user --ssh-keystore-path ./ci.pem --k8s-namespace ais-ns --k8s-pod-name ais-inst-1 --instance actimize_server_1 --file ais_config.xml --file webserver/eh.ini --targetPath .

    The command above will copy files ais_config.xml and webserver/eh.ini from AIS instance actimize_server_1 is running in Kubernetes pod ais-ns/ais-inst-1
    to current directory. Kubernetes cluster is managed by host 10.220.199.129. Remote host demands following credentials to be available:
    user name - ec2-user and keystore file - ./ci.pem

    4) getAISContent.sh --local-server-source --k8s-namespace ais-ns --k8s-pod-name ais-inst-1 --instance actimize_server_1 --to-server --preserve-folder-structure --file ais_config.xml --file webserver/eh.ini --targetPath .
    The command above will copy files ais_config.xml and webserver/eh.ini from current directory to AIS instance actimize_server_1 is running in
    Kubernetes pod ais-ns/ais-inst-1. Target path is relative to the instance directory. Kubernetes cluster is managed by localhost."

}

if [ $# == 0 ] ; then
    usage
    exit 0
fi

server=""
user=""
pem_key=""
k8s=false
namespace=""
fileName=""
fromDir=""
toDir=""
metadata=false
podName=""
localServer=true
preserve_folder_structure=false
copy_parameter=""
screen_char=""
direction="from"

listArray=()
filesArray=()
aisObjectsArray=()

while [ "$1" != "" ]; do
    case $1 in
        --local-server-source   ) localServer=true ;;
        --remote-server-source  ) localServer=false ;;

        --server                ) shift
                                  if ! $localServer ; then
                                    server=$1
                                  fi
                                ;;

        --user                  ) shift
                                  if ! $localServer ; then
                                    user=$1
                                  fi
                                ;;

        --ssh-keystore-path     ) shift
                                  if ! $localServer ; then
                                    pem_key="-i "$1
                                  fi
                                ;;

        --k8s-pod-name          ) shift
                                k8s=true
                                podName=$1
                                ;;

        --k8s-namespace         ) shift
                                k8s=true
                                namespace="-n "$1
                                ;;

        --file                  ) shift
                                filesArray+=("$1")
                                ;;

        --files-list            ) shift
                                listArray+=("$1")
                                ;;

        --instance              ) shift
                                fromDir=$1
                                ;;

        --targetPath            ) shift
                                toDir=$1
                                ;;

        --preserve-folder-structure ) preserve_folder_structure=true
                                      copy_parameter="-r"
                                ;;

        --to-server             ) direction="to"
                                  ;;

        --include-ais-objects   ) metadata=true
                                ;;

        --ais-object-file       ) shift
                                aisObjectsArray+=("$1")
                                ;;

        -h                      ) usage
                                  exit 0
                                  ;;

        *                       ) echo "incorrect key is $1"
                                  usage
                                  exit 1
                                  ;;
    esac
    shift
done

if $localServer ; then
    server=""
else
    server=$user@$server
fi

copy_metadata()
{
    # stop ais server first
    to_exec="$exec_command $instance_path/ais_status"
    res=$( eval $shell_command "$to_exec" 2>/dev/null )

    local wasStarted=false

    if [ "$res" != "$fromDir down" ]
    then
        wasStarted=true
        to_exec="$exec_command $instance_path/ais_stop"
        eval $shell_command "$to_exec" >/dev/null 2>/dev/null
    fi

    to_exec="$exec_command $instance_path/../../ais_container_mgr -I\"$fromDir\" -reset_table -t\"../metadata/metadata.db\""
    eval $shell_command "$to_exec" >/dev/null 2>/dev/null

    to_exec="$exec_command $instance_path/../../ais_container_mgr -I\"$fromDir\" -reset_table -t\"../metadata/objects_repository.db\""
    eval $shell_command "$to_exec" >/dev/null 2>/dev/null

    to_exec="$exec_command cp $instance_path/metadata/metadata.db $instance_path/temp/"
    eval $shell_command "$to_exec" >/dev/null 2>/dev/null

    to_exec="$exec_command cp $instance_path/metadata/objects_repository.db $instance_path/temp/"
    eval $shell_command "$to_exec" >/dev/null 2>/dev/null

    if $wasStarted ; then
        to_exec="$exec_command $instance_path/ais_start"
        eval $shell_command "$to_exec" >/dev/null 2>/dev/null
    fi

    copy_file "temp/metadata.db"
    copy_file "temp/objects_repository.db"
}

copy_file()
{
    #local _path=${1%/*}
    local _name=${1##*/}
    echo -n "copy $_name file ..."
    local _from="$instance_path/"

    if $k8s ; then
        _from="$_from\"$1\""
        to_exec="kubectl $namespace cp $podName:$_from /tmp/\"$_name\""
        echo -n "..."
        $eval_command $shell_command $to_exec >/dev/null 2>/dev/null
        _from="/tmp/$_name"
    else
        _from="$_from$1"
    fi

    echo -n "..."
    _from="${_from//\ /\\ }"
    local _toDir="$toDir"

    if $preserve_folder_structure ; then
        if [[ "${1}" == *"/"* ]] ;then
            _toDir="$toDir/${1%/*}"
            if [ ! -e "$toDir/${1%/*}" ] ; then
                mkdir -p "$toDir/${1%/*}"
            fi
            _toDir="${_toDir//\ /\\ }"
        fi
    fi

    eval $copy_command$server$screen_char$_from$screen_char $_toDir

    if $k8s ; then
        #eval
        $shell_command "rm -f $_from" >/dev/null 2>/dev/null
    fi
    echo "finished"
}

copy_file_to()
{
    #local _path=${1%/*}
    local _name=${1##*/}
    local _toDir="$instance_path/$toDir"
    local _sourceFile=$1
    local _destPlace=$_toDir/$_name
    echo -n "copy $_name file ..."

    if $preserve_folder_structure ; then
        if [[ "${1}" == *"/"* ]] ;then
            _to="$_toDir/${1%/*}"
            exec_command=" mkdir -p \"$_toDir/${1%/*}\" "
            if $k8s ; then
                exec_command="kubectl $namespace exec -it $podName -- $exec_command"
            fi
            $eval_command $shell_command $exec_command >/dev/null 2>/dev/null
        fi
        _destPlace=$_toDir/$1
    else
        exec_command=" mkdir -p \"$_toDir\" "
        if $k8s ; then
            exec_command="kubectl $namespace exec -it $podName -- $exec_command"
        fi
        $eval_command $shell_command $exec_command >/dev/null 2>/dev/null
    fi

    echo -n "..."

    _destPlace="${_destPlace//\ /\\ }"
    _sourceFile="${_sourceFile//\ /\\ }"

    if ( $k8s ) && (! $localServer ); then
        eval $copy_command $_sourceFile $server"/tmp/" >/dev/null 2>/dev/null
        _sourceFile="/tmp/$_name"
        _sourceFile="${_sourceFile//\ /\\ }"

        exec_command="$screen_char kubectl $namespace cp $_sourceFile $podName:$_destPlace $screen_char"
        eval $shell_command $exec_command >/dev/null 2>/dev/null

        exec_command="$screen_char rm -f $_sourceFile $screen_char"
        eval $shell_command $exec_command >/dev/null 2>/dev/null
    elif $k8s; then
        exec_command="kubectl $namespace cp $_sourceFile $podName:$_destPlace"
        eval $shell_command $exec_command >/dev/null 2>/dev/null
    else
        eval $copy_command $_sourceFile $server$screen_char$_destPlace$screen_char >/dev/null 2>/dev/null
    fi

    echo -n "..."

    echo "finished"
}

getInstancePath()
{
    to_exec="$exec_command env | grep AIS_SERVER_DIR"
    server_path=$( eval $shell_command "$to_exec" 2>/dev/null )

    #======= remove white spaces
    server_path=${server_path#*=}
    NL=$'\n'    # define a variable to reference 'newline'
    server_path=${server_path%$NL}
    CR=$'\r'    # define a variable to reference 'newline'
    server_path=${server_path%$CR}
    #=======

    to_exec="$exec_command head -n 1 $server_path/ais_instances_path"
    server_path=$( eval $shell_command "$to_exec" 2>/dev/null )

    if [ "$server_path" == "" ] ; then
        echo "$fromDir"
    else
        echo "$server_path/$fromDir"
    fi
}

updateFilesList()
{
    local _file=$1

    if [ -f "$_file" ]
    then

        while IFS= read -r line  || [[ -n "$line" ]] #IFS= in case you want to preserve leading and trailing spaces
        do
            filesArray+=("$line")
        done < "$_file"
    fi
}

#===============================================================
# end of functions
#===============================================================
if [ "$server" == "" ] || [ "$server" == "localhost" ]
then
    shell_command=""
    copy_command="cp $copy_parameter "
    eval_command="eval"
else
    shell_command="ssh -q $pem_key $server "
    server=$server":"
    copy_command="scp $copy_parameter $pem_key "
    eval_command=""
    screen_char="\""
fi

if $k8s ; then
    exec_command="kubectl $namespace exec -it $podName -- "
else
    exec_command=""
fi

#===============================================================
# retrieve instance path
#===============================================================
#getInstancePath
instance_path=$(getInstancePath)

#===============================================================
# prepare files list
#===============================================================
for (( i=0; i<${#listArray[@]}; i++ ));
do
    #echo "${listArray[$i]}"
    updateFilesList "${listArray[$i]}"
done

#===============================================================
# copy files
#===============================================================
for (( i=0; i<${#filesArray[@]}; i++ ));
do
    #echo "${filesArray[$i]}"
    if [ "$direction" == "from" ]
    then
        copy_file "${filesArray[$i]}"
    else
        copy_file_to "${filesArray[$i]}"
    fi
    #echo "copy_file \"${filesArray[$i]}\""
done

#===============================================================
# copy ais objects
#===============================================================
if $metadata ; then
    if [ "$direction" == "from" ]
    then
        copy_metadata
    else
        toDir="metadata"
        preserve_folder_structure=false

        for (( i=0; i<${#aisObjectsArray[@]}; i++ ));
        do
            #echo "${aisObjectsArray[$i]}"
            if [ -d "${aisObjectsArray[$i]}" ] ; then
                for _f in "${aisObjectsArray[$i]}"/*; do
                    #echo "$_f"
                    copy_file_to "$_f"
                done
            else
                copy_file_to "${aisObjectsArray[$i]}"
            fi
        done
    fi
fi
