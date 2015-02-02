#!/bin/bash

# ------------------------------------------------------------------------------
# Filename:     Trap.sh
# Version:      0.1
# Date:         2014/11/14
# Author:       HE KUN
# Email:        kun.he@cs2c.com.cn
# Summary:
# Notes:
# Copyright:    China Standard Software Co., Ltd.
# History:
#               Version 0.1, 2014/11/14
#               - The first one.
#               Define function Trapadd.
# ------------------------------------------------------------------------------

##! @TODO: Add the command to excute for trap meets signal EXIT.
##! @AUTHOR: kun.he
##! @VERSION: 0.1 
##! @OUT:  
function TrapAdd() 
{
    TRAP_EXCUTE="$1;${TRAP_EXCUTE}"
    trap "${TRAP_EXCUTE}" EXIT
}
