#!/bin/bash

source lib/libcgtest.sh

# Set iostat watch time. The 'TIME_DELAY' must be small than 'WATCH_COUNT'.
TIME_DELAY=10
WATCH_DELAY=1
WATCH_COUNT=61
if [ ${TIME_DELAY} -ge ${WATCH_COUNT} ]
then
    echo "Some mistake in test time setting."
    exit 1
fi

# Prepare for the test.
TEST_SIZE=1

# Havn't check for the cgroup setting.
HIERARCHY=$1
if [ ${#HIERARCHY[@]} -ne ${TEST_SIZE} ]
then
    echo "Some mistake in hierarchy setting."
    exit 1
fi


# Set test cgroup names.
CG=$2
if [ ${#CG[@]} -ne ${TEST_SIZE} ]
then
    echo "Some mistake in control group setting."
    exit 1
fi

# Set device.
DEV=$3
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

# Set iotop arguments.
IOTOP_ARG="-b -k -n ${WATCH_COUNT} -d ${WATCH_DELAY}"

# Set awk arguments for read the informations from the log file of iotop.
IOTOP_AWK_ARG=""

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
    IOTOP_ARG="${IOTOP_ARG} -p ${PIDS[$COUNT]}"
    IOTOP_AWK_ARG="${IOTOP_AWK_ARG} -vdev${COUNT} -vcg${COUNT}"
    TRAP_COMMAND="${TRAP_COMMAND}kill -9 ${PIDS[$COUNT]};[ -f ${TESTFILE_PATH[$COUNT]} ] && rm -rf ${TESTFILE_PATH[$COUNT]};"
done
trap "${TRAP_COMMAND}" EXIT

# Set the temporary file's name to buffer the result of iotop.
TMP_FILE="$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`_tmpfile"
TRAP_COMMAND="$TRAP_COMMAND rm -rf /tmp/${TMP_FILE};"

# Watch the bandwidths by iotop, and log the information to the tmporary file.
iotop ${IOTOP_ARG} >> "/tmp/${TMP_FILE}"
trap "${TRAP_COMMAND}" EXIT

# Deal with the temporary file and print the results out.
awk -vshdev="${DEV[*]}" -vshcg="${CG[*]}" -vshpid="${PIDS[*]}" -vdelay="${TIME_DELAY}" '
BEGIN {
    split(shdev,dev);
    split(shcg,cg);
    split(shpid,pid);
    number=length(pid);
    for (i=1;i<=number;i++)
    {
        sum[i]=0;
        count[i]=0;
    }
}
{   
    for (i=1;i<=number;i++)
    {
        if ($1==pid[i])
        {
            if (++count[i]>delay)
            {
                sum[i]+=$6;
            }
        }
    }
}
END {
	    printf("%-16s%-16s%s\n", "CGROUP", "DEVICE", "BANDWIDTH(KB/s)");
    for (i=1;i<=number;i++)
    {
	    printf("%-16s%-16s%f KB/s\n", cg[i], dev[i], (sum[i])/(count[i]-delay));
    }
}' "/tmp/${TMP_FILE}"
