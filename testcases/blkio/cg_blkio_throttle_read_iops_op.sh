#!/bin/bash
# Prepare for the test.
# Havn't check for the cgroup setting.
hierarchy01=blkio

# Set iostat watch time.
watch_delay=1
watch_count=16

# Set test cgroup names.
cg01="$1"

# set device.
dev01="$2"

# Set testfiles' path.
testfile_path01="$3"

# Do the test.
# Starting read processes in cgroup.
# Flush all filesystem buffer and free pagecache, dentries and inodes.
sync && echo 3 > /proc/sys/vm/drop_caches
sleep 5
sh -c "echo \$$ >> /cgroup/${hierarchy01}/${cg01}/tasks && dd if=${testfile_path01} of=/dev/null" &

# Get the ppids of the read processes.
ppid01=`ps --ppid $$ | grep sh | head -1 | awk '{print $1}'`
# Get the pid of the read processes by their ppids.
pid01=`ps --ppid $ppid01 | tail -1 | awk '{print $1}'`
trap "kill -9 $pid01 >/dev/null 2>&1" EXIT

# Set the temporary file's name to buffer the result of iotop.
tmp_file=$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`

# Watch the bandwidths by iotop, and log the information to the tmporary file.
iostat -x -p ${watch_delay} ${watch_count} | grep "^${dev01}" > "/tmp/${tmp_file}"
[ -f "/tmp/${tmp_file}" ] && trap "kill -9 $pid01 >/dev/null 2>&1;rm -rf /tmp/${tmp_file}" EXIT

# Deal with the temporary file and print the results out.
awk 'BEGIN {
	sum01=0;
	count01=0;
} 
{
	if (NR>1)
	{
		count01++;
		sum01+=$2;
		sum01+=$4;
	}
}
END {
	cg01="'"$cg01"':";
	printf("%-16s%f ops\n", cg01, (sum01)/(count01));
}' "/tmp/${tmp_file}"

