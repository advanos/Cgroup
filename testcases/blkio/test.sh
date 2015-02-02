#! /bin/bash
for ((i=1;i<10; i++))
do
	cgexec -g blkio:/cgtest02 dd if=/tmp/sdb8/testfile01 of=/dev/null bs=1k &
done
