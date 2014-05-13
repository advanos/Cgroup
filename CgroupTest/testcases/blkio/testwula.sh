#!/bin/bash
# Prepare for the test.
# Havn't check for the cgroup setting.
function get_read_iops()
{
        pre=`awk -vdev="$1" '{if ($3==dev){print $4+$5}}' /proc/diskstats;`
        sleep 1;
        end=`awk -vdev="$1" '{if ($3==dev){print $4+$5}}' /proc/diskstats;`
        awk -vpre="$pre" -vend="$end" 'BEGIN {print end-pre}'
}


get_read_iops "sdb"
