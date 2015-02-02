#!/bin/sh

# ----------------------------------------------------------------------
# Filename:   Echo.sh
# Version:    1.0
# Date:       2013/03/30
# Author:     xunwei.fan
# Email:      xunwei.fan@cs2c.com.cn
# Summary:    Format the output of steps in each testcase
# Notes:      Include EchoInfo and EchoResult
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/03/30
#             - The first one
# ----------------------------------------------------------------------

##! @TODO: Echo Time "**:**:**"
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @OUT: Time
function EchoTime()
{
    date +%T
}

##! @TODO: Format Output
##!        Output following this format "${Time} INFO | ${output information}"
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @OUT: The formatted output
function EchoInfo()
{
    local TIME=$(EchoTime)
    echo "${TIME} INFO | $1"
    return 0
}

##! @TODO: Automatically judge and Format the result of each step
##!        1. Judge according to the Return_Value. 0 => PASS; else => FAIL
##!        2. Output following this format "${Time} PASS | ${Step's Name}"
##! @AUTHOR: xunwei.fan
##! @CHANGELOG: 01 Print the result with colour by kun.he@cs2c.com.cn 2013-11-25
##! @VERSION: 1.0 
##! @OUT:  The formatted result of each step
function EchoResult()
{
    local RESULT="$?"
    local TIME=$(EchoTime)

    if [ ${RESULT} -eq 0 ]
    then
        echo -e "${TIME}\033[32m PASS\033[0m | $1"
        return 0
    else
        echo -e "${TIME}\033[31m FAIL\033[0m | $1"
        exit 1
    fi
    return 0
}
