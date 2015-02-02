#!/bin/bash

source lib/settc.sh
source $SFROOT/lib/common.sh

function InitTest()
{
    
    local DEVICE
    local BANDWIDTH
    local TEST_SIZE=0
    
    # Check for inputs.
    Usage "${FUNCNAME}" "${FUNCNAME} device[s] bandwidth[s]" $# 2 || return 6 
    # Set device name and testsize.
    eval DEVICE=(\${$1[@]})
    TEST_SIZE=${#DEVICE[@]}
    # Set bandwidth, then check for the inputs.
    eval BANDWIDTH=(\${$2[@]})
    [ ${#BANDWIDTH[@]} -ne ${TEST_SIZE} ] && printf "Input error, please check!\n" && return 6

    # TC setup for devices.
    for i in ${TEST_SIZE}
    do
        ! InitDevice ${DEVICE[$i]} ${BANDWIDTH[$i]} && printf "Failure in the test initializing, please check for it!\n" && return 5

    done
    return 0
}


# Set device.
DEV=("sda8" "sdb8")
if [ ${#DEV[@]} -ne ${TEST_SIZE} ]
then
    echo "Some mistake in device setting."
    exit 1
fi

# Set testfile.
for ((i=0;i<${TEST_SIZE};i++))
{
    TESTFILE[$i]="$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`testfile_$i"
    TESTFILE_PATH[$i]=""
}

# Get root fs.
ROOT_FS_PATH=`df | awk '{if ($6=="/") {print $1}}'`

# Set iostat arguments.
IOSTAT_ARG="-x -p ${WATCH_DELAY} ${WATCH_COUNT}"

# Set trap comands.
TRAP_COMMAND=""

# Starting write processes in cgroup.
# Flush all filesystem buffer and free pagecache, dentries and inodes.
sync && echo 3 > /proc/sys/vm/drop_caches
sleep 5

for ((COUNT=0;COUNT<$((TEST_SIZE));COUNT++))
do
    if [ "_`echo ${ROOT_FS_PATH} | sed 's/[0-9][0-9]*//'`" == "_/dev/${DEV[$COUNT]}" ] || [ "_${ROOT_FS_PATH}" == "_/dev/${DEV[$COUNT]}" ]
    then
	    TESTFILE_PATH[$COUNT]="/tmp/${TESTFILE[$COUNT]}"
    else
	    TESTFILE_PATH[$COUNT]="/tmp/${DEV[$COUNT]}/${TESTFILE[$COUNT]}"
    fi

    # Do the test.
    StartProcessFromCg "/cgroup/${HIERARCHY[$COUNT]}${CG[$COUNT]}" "dd" "if=/dev/zero of=${TESTFILE_PATH[$COUNT]}" $((COUNT+1)) PIDS[$COUNT]
    TRAP_COMMAND="${TRAP_COMMAND}kill -9 ${PIDS[$COUNT]};[ -f ${TESTFILE_PATH[$COUNT]} ] && rm -rf ${TESTFILE_PATH[$COUNT]};"
done
trap "${TRAP_COMMAND}" EXIT

# Set the temporary file's name to buffer the result of iostat.
TMP_FILE="$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`_tmpfile"
TRAP_COMMAND="$TRAP_COMMAND rm -rf /tmp/${TMP_FILE};"

# Watch the iops by iostat, and log the information to the tmporary file.
iostat -x -p ${WATCH_DELAY} ${WATCH_COUNT} | awk -vshdev="${DEV[*]}" -vtestsize="${TEST_SIZE}" '
BEGIN {
    split(shdev,dev);
}
{
    for (i=1;i<=testsize;i++)
    {
        if (dev[i]==$1) 
        {
            print $0;
        }
    }
}'> "/tmp/${TMP_FILE}"
trap "${TRAP_COMMAND}" EXIT

# Deal with the temporary file and print the results out.
awk -vshdev="${DEV[*]}" -vshcg="${CG[*]}" -vtestsize="${TEST_SIZE}" -vdelay="${TIME_DELAY}" '
BEGIN {
    split(shdev,dev);
    split(shcg,cg);
    for (i=1;i<=testsize;i++)
    {
        sum[i]=0;
        count[i]=0;
    }
}
{   
    for (i=1;i<=testsize;i++)
    {
        if ($1==dev[i])
        {
            if (++count[i]>delay)
            {
                sum[i]+=$3;
                sum[i]+=$5;
            }
        }
    }
}
END {
	printf("%-16s%-16s%s\n", "CGROUP", "DEVICE", "IOPS(ops)");
    for (i=1;i<=testsize;i++)
    {
	    printf("%-16s%-16s%f ops\n", cg[i], dev[i], (sum[i])/(count[i]-delay));
    }
}' "/tmp/${TMP_FILE}"
