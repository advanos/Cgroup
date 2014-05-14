#!/bin/bash

# ----------------------------------------------------------------------
# Filename:   FileOps.sh
# Version:    1.1
# Date:       2014/02/11
# Author:     kun.he
# Email:      kun.he@cs2c.com.cn
# Summary:    File or Dir operations
# Notes:      Include create,delete,unmount dir; get the absolute path
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/11/26
#             - add file functions, CreateDir, DeleteDir, UnmountDir, RealPwd
#             Version 1.1, 2014/02/11
#             - Modified function CreateDir.
#             - Modified function DeleteDir.
#             - Modified function UnmountDir.
#             - Modified function RealPwd.
#             Version 1.2, 2014/03/25
#             - Modified function UnmountDir,logical error.
# ----------------------------------------------------------------------

source "${SFROOT}/lib/Echo.sh"
##! @TODO: Create directory more compatiblely.
##!        1. Judge according to the Return_Value. 0 => PASS; else => FAIL
##! @AUTHOR: kun.he
##! @VERSION: 1.1 
##! @OUT:  return value.
function CreateDir()
{
    local RET=0
    if [ $# -eq 1 ]
    then
        if [ -e "$1" ]
        then
            mv "$1" "$1.$(date +%Y.%m.%d-%H:%M:%S).bak"
            mkdir "$1" && EchoInfo "File name confict. The raw file backuped as $1"."$(date +%Y.%m.%d-%H:%M:%S)".bak". You might need recover this file MANUALLY after this test if it's necessary. Directory $1 create successfully." || RET=1
        else
            mkdir $1 && EchoInfo "Directory create successfully." || RET=1
        fi
    else
        EchoInfo "You should use the function like this: CreateDir dir_name"
        RET=1
    fi
    return $RET
}

##! @TODO: Delete directories and files more compatiblely.
##!        1. Judge according to the Return_Value. 0 => PASS; else => FAIL
##! @AUTHOR: kun.he
##! @VERSION: 1.1 
##! @OUT:  return value.
function DeleteDir()
{
    local RET=0
    if [ $# -eq 1 ]
    then
        if [ -e "$1" ]
        then
            rm -rf $1 && EchoInfo "The '$1' directory deleted successfully." || RET=1
        else
            EchoInfo "The '$1' directory doesn't exist."
        fi
    else
        EchoInfo "You should use the function like this: DeleteDir dir_name."
        RET=1
    fi
    return $RET 
} 


##! @TODO: Unmount filesystem more compatiblely.
##!        1. Judge according to the Return_Value. 0 => PASS; else => FAIL
##! @AUTHOR: kun.he
##! @VERSION: 1.2 
##! @OUT:  return value.
function UnmountDir()
{
    local RET=0
    if [ $# -eq 1 ]
    then
        local INPUT_DIR=$(echo $1 | sed  's#/\{1,\}#/#g')"/"
        local INPUT_DIR=$(echo $INPUT_DIR | sed 's#/$##g')
        if [ -d "$INPUT_DIR" ]
        then
            MOUNT_COUNT=$(mount | awk -v mount="$INPUT_DIR" '{if($3==mount){print "found mounted!"}}' | wc -l)
            if [ ${MOUNT_COUNT} -gt 0 ]
            then
                umount $INPUT_DIR 
                if [ $? -eq 0 ] 
		then
		    EchoInfo "The filesystem unmounted successfully."
                else
                    EchoInfo "The filesystem umounting faild."
                    RET=1
	        fi
            else
                EchoInfo "There isn't any filesystem mounted to $INPUT_DIR."
            	RET=1
            fi
        else
            EchoInfo "$INPUT_DIR directory that gonna umount does'nt exist."
            RET=1
        fi
    else
        EchoInfo "You should use the function like this: UnmountDir mount_point"
        RET=1
    fi
    return $RET
}

##! @TODO: Get the real path of the runtime function.
##!        1. Judge according to the Return_Value. 0 => PASS; else => FAIL
##! @AUTHOR: kun.he
##! @VERSION: 1.1 
##! @OUT:  return value.
function RealPwd()
{
    local RET=0
    if [ $# -eq 0 ]
    then
        echo $(cd $(dirname $0); pwd) || \
        RET=1
    else
        EchoInfo "There're some mistake about the input parameters. The 'RealPwd' function doesn't need any input parameter."
        RET=1
    fi
    return $RET
}
