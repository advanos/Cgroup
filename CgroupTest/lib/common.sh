# ------------------------------------------------------------------------
# Filename:     common.sh
# Version:      0.1
# Date:         2014/05/14
# Author:       Kun He
# Email:        kun.he@cs2c.com.cn
# Summary:      Some useful common assistant functions which would help 
#               people to enhance the shell scripts.
# Notes:        Include Usage, InserTrap，etc.
# Copyright:    China Standard Software Co., Ltd.
# History：     
#               Version 0.1, 2014/05/14
#               - The first one.
# ------------------------------------------------------------------------

#! /bin/bash

##! ----------------------------------------------------------------------
##! @FUNCTION:  Usage 
##! @VERSION:   0.1 
##! @AUTHOR:    Kun He
##! @EMAIL:     kun.he@cs2c.com.cn
##! @TODO:      Show the usage of function if some error occur while 
##!             calling the function.
##! @USAGE:     Usage function_name command_sample counts_of_input 
##!             counts_of_input_setting
##! @PARA_1:    string  function_name
##!             TYPE:   input
##!             VALUE:  The function name. Suggest to use shell built-in
##!                     variable $FUNCNAME.
##! @PARA_2:    string  command_sample
##!             TYPE:   input
##!             VALUE:  The simple usage of function call.
##! @PARA_3:    int     counts_of_input
##!             TYPE:   input
##!             VALUE:  The number of paremeters. Suggest to use $#.
##! @PARA_4:    int     counts_fo_input_setting
##!             TYPE:   input
##!             VALUE:  The number of paremeters that it should be.
##! @OUT:       SUCCESS:The useage information of the target function.
##!             FAILURE:Error information.
##! @RETURN:    0 ----- Success
##!             1 ----- Failure in the parameters of the target function.
##!             2 ----- Failure in the parameters of this function.
##! @CHANGELOG: Version 0.1, 2014/05/14
##!             - The first one.
##! -----------------------------------------------------------------------
function Usage()
{
    if [ $# != 4 ] 
    then
        printf "Usage Error: You should use this function like this: \nUsage function_name
 command_sample counts_of_cmdline set_counts_value\n"
        return 2
    else
        [ $3 -ne $4 ] && printf "Usage of '%s': %s\n" "$1" "$2" && return 1
    fi  
    return 0
}

##! ----------------------------------------------------------------------
##! @FUNCTION:  TrapInsert
##! @VERSION:   0.1 
##! @AUTHOR:    Kun He
##! @EMAIL:     kun.he@cs2c.com.cn
##! @TODO:      Insert newer command to the old one for trap to calling
##!             while signal 'EXIT'.
##! @USAGE:     TrapInsert old_command new_command
##! @PARA_1:    string  old_command
##!             TYPE:   input
##!             VALUE:  The old command line of trap.
##! @PARA_2:    string  new_command
##!             TYPE:   input
##!             VALUE:  The new command which is to be inserted.
##! @OUT:       SUCCESS:The combined command.
##!             FAILURE:Error information.
##! @RETURN:    0 ----- Success
##!             1 ----- Echo faild.
##!             6 ----- Failure in the parameters of this function.
##! @CHANGELOG: Version 0.1, 2014/05/15
##!             - The first one.
##! -----------------------------------------------------------------------
function TrapInsert()
{
    Usage "${FUNCNAME}" "${FUNCNAME} old_command new_command" $# 2 || \
    return 6
    
    echo "$2; $1" && return 0 || return 1
}

##! ----------------------------------------------------------------------
##! @FUNCTION:  GetStrRtn
##! @VERSION:   0.1 
##! @AUTHOR:    Kun He
##! @EMAIL:     kun.he@cs2c.com.cn
##! @TODO:      When a function's output is a string, first judge the 
##!             return value, if success then print the output, else print
##!             noting, but return error.
##! @USAGE:     TrapInsert old_command new_command
##! @PARA_1:    string  old_command
##!             TYPE:   input
##!             VALUE:  The old command line of trap.
##! @PARA_2:    string  new_command
##!             TYPE:   input
##!             VALUE:  The new command which is to be inserted.
##! @OUT:       SUCCESS:The combined command.
##!             FAILURE:Error information.
##! @RETURN:    0 ----- Success
##!             1 ----- Echo faild.
##!             6 ----- Failure in the parameters of this function.
##! @CHANGELOG: Version 0.1, 2014/05/15
##!             - The first one.
##! -----------------------------------------------------------------------
function TrapInsert()
{
    Usage "${FUNCNAME}" "${FUNCNAME} old_command new_command" $# 2 || \
    return 6
     
    echo "$2; $1" && return 0 || return 1
}
