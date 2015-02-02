#! /bin/bash

source $SFROOT/lib/common.sh
source `dirname $BASH_SOURCE`/libtc.sh

function InitDevice 
{
    Usage "${FUNCNAME}" "${FUNCNAME} device bandwitdh(tc bandwitdh unit)" $# 2 || return 6 
    SetDeviceTcHtb $1 100: 1 $2
    return $?
}
