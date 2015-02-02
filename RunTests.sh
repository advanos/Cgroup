#!/bin/bash

# ----------------------------------------------------------------------
# Filename:   RunTests.sh
# Version:    1.2
# Date:       2013/04/01
# Author:     xunwei.fan
# Email:      xunwei.fan@cs2c.com.cn
# Summary:    Test Driver
# Notes:      ***
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/03/21
#             - The first one, can parse the TestCases XML, find the script for each testcase, and excute them by order 
#             Version 1.1, 2013/03/31
#             - Add log
#             Version 1.2, 2013/04/01
#             - Pick up the function "RunCase"
#             Version 1.3, 2013/11/26
#             - Add SFROOT;
#             - Change Runcase $arguments
#             - Add 'debug.log' file color control character handle
#             - Change CURRENT_DIR with SFROOT 
# ----------------------------------------------------------------------

function Usage()
{
    echo -e "--USAGE--\n\"Normal Run\":sh `basename $0`\n\"Autotest Run\":sh `basename $0` -f xml_name"
}

##! @TODO: Run a case and log its result
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @IN: $1 => the order number of the case
##! @OUT: Put results into the results-stored file
function RunCase()
{
    LogSummary ${CASE_SUMMARY["$1"]} $2
    cd ${TESTCASE_DIR}/${CASE_DIR["$1"]}
    sh ${TESTCASE_DIR}/${CASE_DIR["$1"]}/${CASE_SCRIPT["$1"]} >> ${LOGDIR}/debug.log 2>&1
    LogResult ${CASE_SUMMARY["$1"]}
}

##! @TODO: Run Tests by order
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @IN: $1 => XmlParse.sh Log.sh
##! @IN: $2 => TestGroup.xml 
##! @OUT: 0 => success; else => failure
function RunTest()
{
    local TESTCASE_DIR="${SFROOT}/testcases"
    local CONFIG_DIR="${SFROOT}/config"
    local LIB_DIR="${SFROOT}/lib"
    local TESTGROUP_XML="${CONFIG_DIR}/TestGroup.xml"
    local i=0
    local j=0
    local k=0
    
    #Load APIs in lib/XmlPrase.sh lib/Log.sh
    source ${LIB_DIR}/XmlParse.sh
    source ${LIB_DIR}/Log.sh
    
    #Parse the TestGroup XML, put all the labels into arrays
    XmlParse ${TESTGROUP_XML}
   
    #Get the count of components
    GetNumber GROUP_NUM GroupName
   
    #Get the necessary informations of each component
    GetValue GROUP_NAME GroupName
    GetValue COMPONENT Component
    GetValue GROUP_RUN GroupRun
    GetValue GROUP_ALL GroupAll

    #Start Log
    LogStart

    #According to the Run_Flag, Run the tests
    for((i=0;i<${GROUP_NUM};i++))
    do
        if [ ${GROUP_RUN[i]} == "True" ]
        then
            local p=0
            #Log the information of the component
            LogComponent ${COMPONENT[i]}

            SINGLE_GROUP_XML="${CONFIG_DIR}/${GROUP_NAME[i]}.xml"

            #Parse the specific group XML，put all the labels into arrays
            XmlParse ${SINGLE_GROUP_XML}

            #Get the count of cases
            GetNumber CASE_NUM Summary

            #Get the necessary informations of each case
            GetValue CASE_SUMMARY Summary
            GetValue CASE_DIR Dir
            GetValue CASE_SCRIPT Script
            GetValue CASE_RUN CaseRun

            #According to the Run_Flag, execute each case by order
            if [ ${GROUP_ALL[i]} == "True" ]
            then
                for((j=0;j<${CASE_NUM};j++))
                do
                    #Run cases and log results
                        p=`expr $p + 1`
                        RunCase $j $p
                done
            else
                for((k=0;k<${CASE_NUM};k++))
                do
                    if [ ${CASE_RUN[k]} == "True" ]
                    then
                        p=`expr $p + 1`
                        RunCase $k $p
                    fi
                done
            fi
        fi
    done

    sed -i 's/[[:cntrl:]]\[[[:digit:]]*m//g' ${LOGDIR}/debug.log
    #Analyz the Log
    LogAnalyse
    
    return 0
}

#! @TODO: Run Tests for autotest
##! @AUTHOR: xunwei.fan
##! @VERSION: 1.0 
##! @IN: $1 => XmlParse.sh Log.sh
##! @IN: $2 => TestRun.xml 
##! @OUT: 0 => success; else => failure
function RunForAutotest()
{
    local TESTCASE_DIR="${SFROOT}/testcases"
    local CONFIG_DIR="${SFROOT}/config"
    local LIB_DIR="${SFROOT}/lib"
    local TESTRUN_XML="${CONFIG_DIR}/$1"
    local m=0

    #Load APIs in lib/XmlPrase.sh lib/Log.sh
    source ${LIB_DIR}/XmlParse.sh
    source ${LIB_DIR}/Log.sh

    #Parse the TestGroup XML, put all the labels into arrays
    XmlParse ${TESTRUN_XML}
    
    GetNumber CASE_NUM Summary
    
    GetValue CASE_COMPONENT Component
    GetValue CASE_SUMMARY Summary
    GetValue CASE_DIR Dir
    GetValue CASE_SCRIPT Script
    
    #Start log
    LogStart
    
    for((m=0;m<${CASE_NUM};m++))
    do
        #Log the information of the component
        LogComponent ${CASE_COMPONENT[m]}
        RunCase $m $m
    done

    sed -i 's/[[:cntrl:]]\[[[:digit:]]*m//g' ${LOGDIR}/debug.log
    #Analyz the Log
    LogAnalyse
   
    return 0
}

# shellframe root path
PROFILE="/root/.bashrc"
export SFROOT=`echo $(cd $(dirname $0); pwd)`
sed -i '/SFROOT/d' ${PROFILE}
echo "export SFROOT=${SFROOT}" >> ${PROFILE}
source ${PROFILE}

unset PROFILE
###

if [ $# -ne 0 ]
then 
    while getopts "hf:" OPTION
    do
        case $OPTION
        in
            f)XML_NAME=$OPTARG;;
            h)Usage
              exit 0;;
           \?)Usage
              exit 1;;
        esac
    done
    RunForAutotest ${XML_NAME}
else
    RunTest
fi
