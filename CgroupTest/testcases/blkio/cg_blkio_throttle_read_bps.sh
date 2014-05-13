#!/bin/bash
# Prepare for the test.
# Havn't check for the cgroup setting.
hierarchy01=blkio

# Set iotop watch time.
watch_delay=1
watch_count=16

# Set test cgroup names.
cg=("/cgtest01")

# Set testfiles' path.
testfile_path=("/tmp/sdb8/testfile01" "/tmp/sdb9/testfile2")

# Do the test.
# Starting read processes in cgroup.
for ((i=0;i<${#cg[@]};i++))
do
	for ((j=0;j<${#testfile_path[@]};j++))
	do
		# Flush all filesystem buffer and free pagecache, dentries and inodes.
		sync && echo 3 > /proc/sys/vm/drop_caches
		sleep 5
		sh -c "echo \$$ >> /cgroup/${hierarchy01}/${cg[$i]}/tasks && dd if=${testfile_path[$j]} of=/dev/null" &

		# Get the ppids of the read processes.
		ppid01=`ps --ppid $$ | grep sh | head -1 | awk '{print $1}'`

		# Get the pid of the read processes by their ppids.
		pid01=`ps --ppid $ppid01 | tail -1 | awk '{print $1}'`
		trap "kill -9 $pid01 >/dev/null 2>&1" EXIT

		# Set the temporary file's name to buffer the result of iotop.
		tmp_file=$0.`head -1 /dev/urandom | cksum | awk '{print $1}'`

		# Watch the bandwidths by iotop, and log the information to the tmporary file.
		iotop -b -k -n ${watch_count} -d ${watch_delay} -p $pid01 >> "/tmp/${tmp_file}"
		[ -f "/tmp/${tmp_file}" ] && trap "kill -9 $pid01 >/dev/null 2>&1;rm -rf /tmp/${tmp_file}" EXIT
		cg01=${cg[$i]}
		# Deal with the temporary file and print the results out.
		awk 'BEGIN {
			sum01=0;
			count01=0;
		} 
		{
			if ($1 == '"$pid01"')
			{
				count01++;
				sum01+=$4;
			}
		}
		END {
			cg01="'"$cg01"':";
			printf("%-16s%f KB/s\n", cg01, (sum01)/(count01-1));
		}' "/tmp/${tmp_file}"
		kill -9 $pid01 >/dev/null 2>&1;
	done
done
