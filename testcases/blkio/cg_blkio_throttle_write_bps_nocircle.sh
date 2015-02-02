#!/bin/bash
# Prepare for the test.
# Havn't check for the cgroup setting.
hierarchy01=blkio
hierarchy02=blkio

# Set iostat watch time.
watch_delay=1
watch_count=61

# Set test cgroup names.
cg01="/"
cg02="/"

# set device.
dev01="sda8"
dev02="sdb8"

# set testfile.
testfile01="$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`testfile_01"
testfile02="$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`testfile_02"

# Set testfiles' path.
root_fs_path=`df | awk '{if ($6=="/") {print $1}}'`
if [ "_`echo ${root_fs_path} | sed 's/[0-9][0-9]*//'`" == "_/dev/${dev01}" ] || [ "_${root_fs_path}" == "_/dev/${dev01}" ]
then
	testfile_path01="/tmp/$testfile01"
else
	testfile_path01="/tmp/$dev01/$testfile01"
fi
if [ "_`echo ${root_fs_path} | sed 's/[0-9][0-9]*//'`" == "_/dev/${dev02}" ] || [ "_${root_fs_path}" == "_/dev/${dev02}" ]
then
	testfile_path02="/tmp/$testfile02"
else
	testfile_path02="/tmp/$dev02/$testfile02"
fi

# Starting write processes in cgroup.
# Flush all filesystem buffer and free pagecache, dentries and inodes.
sync && echo 3 > /proc/sys/vm/drop_caches
sleep 5

# Do the test.
sh -c "echo \$$ >> /cgroup/${hierarchy01}/${cg01}/tasks && dd if=/dev/zero of=${testfile_path01}" &
# Get the ppids of the write processes.
ppid01=`ps --ppid $$ | grep sh | head -1 | awk '{print $1}'`
# Get the pid of the write processes by their ppids.
pid01=`ps --ppid $ppid01 | tail -1 | awk '{print $1}'`
trap "kill -9 $pid01 >/dev/null 2>&1; [ -f "${testfile_path01}" ] && rm -rf ${testfile_path01}" EXIT

sh -c "echo \$$ >> /cgroup/${hierarchy02}/${cg02}/tasks && dd if=/dev/zero of=${testfile_path02}" &
# Get the ppids of the write processes.
ppid02=`ps --ppid $$ | grep sh | tail -1 | awk '{print $1}'`
# Get the pid of the write processes by their ppids.
pid02=`ps --ppid $ppid02 | tail -1 | awk '{print $1}'`
trap "kill -9 $pid01 $pid02 >/dev/null 2>&1; [ -f ${testfile_path01} ] && rm -rf ${testfile_path01}; [ -f ${testfile_path02} ] && rm -rf ${testfile_path02}" EXIT

# Set the temporary file's name to buffer the result of iotop.
tmp_file="$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`_tmpfile"

# Watch the bandwidths by iotop, and log the information to the tmporary file.
iotop -b -k -n ${watch_count} -d ${watch_delay} -p $pid01 -p $pid02 >> "/tmp/${tmp_file}"
trap "kill -9 $pid01 $pid02 >/dev/null 2>&1; [ -f ${testfile_path01} ] && rm -rf ${testfile_path01}; [ -f ${testfile_path02} ] && rm -rf ${testfile_path02}; [ -f ${tmp_file} ] && rm -rf ${tmp_file}" EXIT

# Deal with the temporary file and print the results out.
awk -vdev01="$dev01" -vdev02="$dev02" -vcg01="$cg01" -vcg02="$cg02" -vpid01="$pid01" -vpid02="$pid02" 'BEGIN {
	sum01=0;
	count01=0;
	sum02=0;
	count02=0;
} 
{
	if ($1==pid01)
	{
		if (++count01>1)
		{
			sum01+=$6;
		}
	}
	if ($1==pid02)
	{
		if (++count02>1)
		{
			sum02+=$6;
		}
	}
}
END {
	printf("%-16s%-16s%f KB/s\n", cg01, dev01, (sum01)/(count01-1));
	printf("%-16s%-16s%f KB/s\n", cg02, dev02, (sum02)/(count02-1));
}' "/tmp/${tmp_file}"

