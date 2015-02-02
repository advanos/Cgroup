#!/bin/bash

function StartProcessFromCg()
{
    if [ $# -ne 5 ] 
    then
        echo "usage:"
        exit 1
    fi
    
    local CGROUP="$1"
    local COMMAND="$2"
    local ARGS="$3"
    local SN=$4
    local PROCESS="${COMMAND} ${ARGS}"
    local PROCESS_PPID=0
    local PROCESS_PID=0
    local EXEC_PROCESS=""

    # Check for the test cgroup.
    if [ -f "${CGROUP}/tasks" ]
    then
        sh -c "echo \$$ >> ${CGROUP}/tasks && ${PROCESS}" & 
    else
        echo "ERROR: The '${CGROUP}/tasks' file cannot find."
        return 1
    fi

    EXEC_PROCESS='sh -c echo $$ >> '"${CGROUP}/tasks && ${PROCESS}"

    sleep 10
    # Get the ppids of the write processes.
    PROCESS_PPID=`ps -f --ppid $$ | awk '{if($8=="sh") {$8="#=#=#sh";print $0}}' | awk -vsn="${SN}" '{if (NR==sn) print $2}'`
    
    # Get the pid of the write processes by their ppids.
    PROCESS_PID=`ps --ppid ${PROCESS_PPID} | tail -1 | awk '{print $1}'`
    eval $5='$PROCESS_PID'
}

function GetCfsFromToplog()
{
    if [ $# -ne 5 ] 
    then
        echo "usage:"
        exit 1
    fi

    local TOP_LOG="$1"
    
    # Check for the top log.
    if [ ! -f "${TOP_LOG}" ] && [ `wc -l ${TOP_LOG} | awk '{print $1}'` -gt 2 ]
    then
        echo "The ${TOP_LOG} top log error."
        exit 1
    fi
    
    sed -i '$d' "${TOP_LOG}"

    awk '
    {
    }' "${TOP_LOG}"
}
