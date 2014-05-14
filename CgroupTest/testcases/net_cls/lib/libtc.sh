#! /bin/bash

source $SFROOT/lib/common.sh

function ClearDeviceTcSet()
{
    Usage "${FUNCNAME}" "${FUNCNAME} deivce_name" $# 1 || return 6
    tc qdisc del dev $1 root > /dev/null 2>&1
    if [ $? -eq 0 -o $? -eq 2 ]
    then
        printf "The root qdisc on device $1 deleted.\n"
        return 0
    else
        printf "Error on line ${LINENO}: '${FUNCNAME}' error, please check your command.\n"
        return 5
    fi
}

function SetDeviceTcHtb() 
{
    local PARENT=""
    Usage "${FUNCNAME}" "${FUNCNAME} device_name major: minor bandwidth" $# 4 || return 6
    if ClearDeviceTcSet $1 
    then
        tc qdisc add dev $1 root handle $2 htb || return 1
        tc class add dev $1 parent $2 classid $2$3 htb rate $4 || return 1
        tc filter add dev $1 parent $2 protocol ip prio 1 handle $3: cgroup || return 1
        printf "The tc with handle $2$3 set the limits of $1 is $4.\n"
        return 0
    else
        return 2
    fi
}
