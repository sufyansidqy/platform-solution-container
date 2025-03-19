#!/bin/bash

usage()
{
  echo "Usage: --namespace <desired namespace>"
}

namespace=""

if [ "$1" = "" ]
then
	usage
	exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        --namespace   )  shift
                       namespace="--namespace $1"
                       ;;
        * )            usage
                       exit 1
                       ;;
    esac
    shift
done

p=$0
path=${p%/*}

kubectl delete configmap \
wlx-config \
wlx-ais-config \
wlx-db \
wlx-entrpnt-lctn \
$namespace

kubectl delete secret \
license \
$namespace
