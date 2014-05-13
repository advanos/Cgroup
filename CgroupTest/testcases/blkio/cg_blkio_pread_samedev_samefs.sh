#!/bin/bash
# Prepare for the test.
# Havn't check for the cgroup setting.
# Flush all filesystem buffer and free pagecache, dentries and inodes.
sync && echo 3 > /proc/sys/vm/drop_caches
sleep 5
hierarchy01=blkio

# Set iotop watch time.
watch_delay=1
watch_count=61

# Set test cgroup names.
cg01="/cgtest01"
cg02="/cgtest02"

# Set testfiles' path.
testfile_path01="/tmp/testfile01"
testfile_path02="/tmp/testfile02"

# Do the test.
# Starting read processes in cgroup.
sh -c "echo \$$ >> /cgroup/${hierarchy01}/${cg01}/tasks && dd if=${testfile_path01} of=/dev/null" &
sh -c "echo \$$ >> /cgroup/${hierarchy01}/${cg02}/tasks && dd if=${testfile_path02} of=/dev/null" &

# Get the ppids of the read processes.
ppid01=`ps --ppid $$ | grep sh | head -1 | awk '{print $1}'`
ppid02=`ps --ppid $$ | grep sh | tail -1 | awk '{print $1}'`

# Get the pid of the read processes by their ppids.
pid01=`ps --ppid $ppid01 | tail -1 | awk '{print $1}'`
pid02=`ps --ppid $ppid02 | tail -1 | awk '{print $1}'`
trap "kill -9 $pid01 $pid02 >/dev/null 2>&1" EXIT

# Set the temporary file's name to buffer the result of iotop.
tmp_file=$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`

# Watch the bandwidths by iotop, and log the information to the tmporary file.
iotop -b -k -n ${watch_count} -d ${watch_delay} -p $pid01 -p $pid02 >> /tmp/${tmp_file}
[ -f /tmp/${tmp_file} ] && trap "kill -9 $pid01 $pid02 >/dev/null 2>&1;rm -rf /tmp/${tmp_file}" EXIT

# Deal with the temporary file and print the results out.
awk 'BEGIN {
	sum01=0;
	sum02=0;
	count01=0;
	count02=0;
} 
{
	if ($1 == '"$pid01"')
	{
		count01++;
		sum01+=$4;
	}
	if ($1 == '"$pid02"')
	{
		count02++;
		sum02+=$4;
	}
}
END {
	cg01="'"$cg01"':";
	cg02="'"$cg02"':";
	printf("%-16s%f KB/s\n", cg01, (sum01)/(count01-1));
	printf("%-16s%f KB/s\n", cg02, (sum02)/(count02-1));
}' /tmp/${tmp_file}
