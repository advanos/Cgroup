#! /bin/bash

function Usage()
{
    if [ $# != 4 ] 
    then
        printf "Usage Error: You should use this function like this: \nUsage function_name
 command_sample counts_of_cmdline set_counts_value\n"
        return 2
    else
        if [ $3 -ne $4 ]
        then
            printf "Usage of '%s': %s\n" "$1" "$2"
            return 1
        fi  
    fi  
    return 0
}
