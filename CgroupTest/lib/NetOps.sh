#!/bin/sh

# ----------------------------------------------------------------------
# Filename:   NetOps.sh
# Version:    1.0
# Date:       2013/11/08
# Author:     huijing.hei
# Email:      huijing.hei@cs2c.com.cn
# Summary:    Network operations with systemctl or service
# Notes:      Include start_daemon stop_daemon restart_daemon status_daemon
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/11/08
#             - add service functions, start_daemon, stop_daemon, restart_daemon, status_daemon
# ----------------------------------------------------------------------

##! @TODO: redirect rsh to /usr/bin/rsh
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0 
export RSH="/usr/bin/rsh"

##! @TODO: redirect rcp to /usr/bin/rcp
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0 
export RCP="/usr/bin/rcp"

#################################
#
# start, stop, restart service
#
#################################
if command -v systemctl >/dev/null 2>&1
then
    HAVE_SYSTEMCTL=1
else
    HAVE_SYSTEMCTL=0
fi

##! @TODO: Start the service
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0 
function StartDaemon()
{
        if [ $HAVE_SYSTEMCTL -eq 1 ]; then
                systemctl start $1.service > /dev/null 2>&1
        else
                service $1 start > /dev/null 2>&1
        fi

}

##! @TODO: Stop the service
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0 
function StopDaemon()
{
        if [ $HAVE_SYSTEMCTL -eq 1 ]; then
                systemctl stop $1.service > /dev/null 2>&1
        else
                service $1 stop > /dev/null 2>&1
        fi


}

##! @TODO: Get the status of the service
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0 
function StatusDaemon()
{
        if [ $HAVE_SYSTEMCTL -eq 1 ]; then
                systemctl status $1.service > /dev/null 2>&1
        else
                service $1 status > /dev/null 2>&1
        fi
}

##! @TODO: Restart the service
##! @AUTHOR: huijing.hei
##! @VERSION: 1.0 
function RestartDaemon()
{
        if [ $HAVE_SYSTEMCTL -eq 1 ]; then
                systemctl restart $1.service > /dev/null 2>&1
        else
                service $1 restart > /dev/null 2>&1
        fi


}
