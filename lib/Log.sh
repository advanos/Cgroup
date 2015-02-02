#!/bin/bash

# ----------------------------------------------------------------------
# Filename:   Log.sh
# Version:    1.0
# Date:       2013/03/31
# Author:     xunwei.fan
# Email:      xunwei.fan@cs2c.com.cn
# Summary:    Start\Format\Analyz the logs
# Notes:      Include LogStart\LogComponent\LogSummary\LogResult\LogAnalyse
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/03/31
#             - The first one
# ----------------------------------------------------------------------

##! @TODO: Start Log
##!        1. create the log dir named as run-${TIME}   
##!        2. create the result file
##!        3. create the debug file 
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @OUT: 0 => success; else => failure
function LogStart()
{
    ROOT_DIR="$(pwd)/logs"
    local LOG_TIME="$(date +%Y-%m-%d-%T)"
    
    local CUR_TIME="$(date +"%Y-%m-%d %H:%M:%S")"
    START_TIME=$(date -d "${CUR_TIME}" +%s)
    LOGDIR="${ROOT_DIR}/run-${LOG_TIME}"

    mkdir ${LOGDIR}
    touch ${LOGDIR}/results
    touch ${LOGDIR}/debug.log
    
    return 0
}

##! @TODO: Write the component into logs
##! @AUTHOR: xunwei.fan
##! @CHANGELOG: 01 Make the output much easier to read by xunwei.fan@cs2c.com.cn 2013-11-25
##! @VERSION: 1.0 
##! @OUT: 0 => success; else => failure
function LogComponent()
{
    local INDEX=0
    
    echo "***********************************************************************" | tee -a ${LOGDIR}/debug.log

    echo "Component:$1" | tee -a ${LOGDIR}/debug.log
    
    #If the component is already in the result file, do not write again
    while read LINE
    do
        if [ ${LINE} == $1 ]
        then
            INDEX=1
        fi
    done < ${LOGDIR}/results

    if [ $INDEX -ne 1 ]
    then
        echo "$1"  >> ${LOGDIR}/results
    fi
 
    return 0
}

##! @TODO: Write the summary into logs
##! @AUTHOR: xunwei.fan
##! @CHANGELOG: 01 Make the output much easier to read by xunwei.fan@cs2c.com.cn 2013-11-25
##! @VERSION: 1.0 
##! @OUT: 0 => success; else => failure
function LogSummary()
{
    echo "---------------------------------------------------------------------->" | tee -a ${LOGDIR}/debug.log
    CASENUM=`printf "%03d" $2`
    echo "Case-"$CASENUM":$1 is running" | tee -a ${LOGDIR}/debug.log
    
    return 0
}

##! @TODO: Automatically judge and Format the result of each testcase
##!        1. Judge according to the Return_Value. 0 => PASS; else => FAIL
##!        2. Output following this format "PASS|${Summary}"
##! @AUTHOR: xunwei.fan
##! @CHANGELOG: 01 Print the result with colour by kun.he@cs2c.com.cn 2013-11-25
##! @VERSION: 1.0 
##! @OUT:  The formatted result
function LogResult()
{
    local RESULT="$?"
     
    if [ ${RESULT} -eq 0 ]
    then
        
        echo -e "\033[32mPASS\033[0m|$1" | tee -a ${LOGDIR}/results
    else
        echo -e "\033[31mFAIL\033[0m|$1" | tee -a ${LOGDIR}/results
    fi
    sed -i 's/[[:cntrl:]]\[[[:digit:]]*m//g' ${LOGDIR}/results
    return 0   
}

##! @TODO: Convert seconds into **h:**m:**s
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @OUT: The formatted time
function TimeConvert()
{
    local HOUR=$[$1/3600]
    local MINUTE=$[$[$1/60]%60]
    local SECOND=$[$1 % 60]

    printf "%02dh:%02dm:%02ds" $HOUR $MINUTE $SECOND
}

##! @TODO: Analyz the log, get the count of the pass cases, the fail cases, the success rate and the cost time
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @OUT: 0 => success; else => failure
function LogAnalyse()
{
    local PASS_COUNT=$(grep 'PASS|' ${LOGDIR}/results | wc -l)  
    local FAIL_COUNT=$(grep 'FAIL|' ${LOGDIR}/results | wc -l)
    local ALL_COUNT=$(expr ${PASS_COUNT} + ${FAIL_COUNT})
    local PASS_RATE=$(echo "scale=2;${PASS_COUNT}*100/${ALL_COUNT}"|bc)%
    local CUR_TIME="$(date +"%Y-%m-%d %H:%M:%S")"
    END_TIME=$(date -d "${CUR_TIME}" +%s)    
    COST_TIME=$(expr ${END_TIME} - ${START_TIME})
    COST_TIME=$(TimeConvert ${COST_TIME})

    echo -e "****************************\nTests passed: ${PASS_COUNT}\nTests failed: ${FAIL_COUNT}\nSuccess rate: ${PASS_RATE}\nTests   time: ${COST_TIME}\n****************************" |tee -a ${LOGDIR}/results
    
    if [ -f ${ROOT_DIR}/ResultsForAutoTest ];then
       rm -rf ${ROOT_DIR}/ResultsForAutoTest
    fi
    cp ${LOGDIR}/results ${ROOT_DIR}/ResultsForAutoTest
      
    return 0
}
