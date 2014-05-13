#!/bin/bash

# ----------------------------------------------------------------------
# Filename:   Check.sh
# Version:    1.0
# Date:       2013/11/26
# Author:     huijing.hei, Kun.he
# Email:      huijing.hei@cs2c.com.cn, kun.he@cs2c.com.cn
# Summary:    Check the env or status of operations or scripts
# Notes:      Include CmdCheck, UserCheck, TimeoutCheck
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/11/26
#             - add functions, CmdCheck, UserCheck, TimeoutCheck
# ----------------------------------------------------------------------


source "${SFROOT}/lib/Echo.sh"

##! @TODO: Check the command exists or not
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0
##! @OUT:  return value.
function CmdCheck()
{
    for cmd in $*; do
        if ! command -v $cmd >/dev/null 2>&1; then
            EchoInfo "$1 not exists, pls check"
            return 1
        fi
    done
}

##! @TODO: Check the user exists or not
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0
##! @OUT:  return value.
function UserCheck()
{
    if id $1  >/dev/null 2>&1; then
        return 0
    else
        EchoInfo "user $1 not exists, pls check"
        return 1
    fi
}

##! @TODO: Launch the process and kill it when time is out.
##! @AUTHOR: kun.he
##! @VERSION: 1.0 
##! @OUT:  return value.
function TimeoutCheck()
{
    local RET=0
    if [ $# -eq 3 ]
    then
        local PROCESS=$1
        local TIME_GAP=$2
        local COUNT=$3
        $PROCESS &
        local PID=$!
        for ((i=0; i<$COUNT; i++))
        do
            if [ $i -eq 0 ]
            then
                sleep 2
            else
                sleep $TIME_GAP
            fi
            local FIND_PID=$(ps -p $PID | wc -l)
            if [ $FIND_PID -eq 1 ]
            then
                EchoInfo "The '${PROCESS}' exit normal."
                RET=0
                break
            elif [ $FIND_PID -eq 2 ]
            then
                if [ $i -eq $((COUNT - 1)) ]
                then
                    kill -9 $PID
                    RET=1
                    EchoInfo "The '${PROCESS}' run timeout."
                else
                    continue
                fi
            else
                RET=2
                break
            fi
        done
    else
        RET=1
    fi
    return $RET
}
