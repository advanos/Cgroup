# -*- coding: UTF-8 -*-
#!/usr/bin/python -f

# ----------------------------------------------------------------------
# Filename:   BaseLdtp.py
# Version:    1.0
# Date:       2013/11/27
# Author:     kun.he
# Email:      kun.he@cs2c.com.cn
# Summary:    Some base function to make ldtp easier to user.
# Notes:      Include IsWndExt IsObjExt etc. Before you use these function, 
#             you must make should the ldtp installed correctly.
# Copyright:  China Standard Software Co., Ltd.
# History：     
#             Version 1.0, 2013/11/27
#             - The first one
# ----------------------------------------------------------------------

import os,sys
from ldtp import *
from ldtputils import *
##! @TODO: Judge if the window exist or not.
##! @AUTHOR: kun.he
##! @VERSION: 1.0 
##! @OUT: return value: 0 = > exist; eles = > doesn't exist.
def IsWndExt(wnd):
    flag = 0
    ret = 0 
    windowList = getwindowlist()
    for window in windowList:
        if window.encode('utf-8') == wnd:
            flag += 1
    if flag == 1:
        print "The '%s' window is found." %(wnd)
        ret = 0
    else:
        print "The '%s' window is Not found." %(wnd)
        ret = 1
    return ret

##! @TODO: Judge if the object of the window exist or not.
##! @AUTHOR: kun.he
##! @VERSION: 1.0 
##! @OUT: return value: 0 = > exist; eles = > doesn't exist.
def IsObjExt(wnd, obj):
    flag = 0
    ret = 0
    if IsWndExt(wnd) == 0:
        objectlist = getobjectlist(wnd)
        for object in objectlist:
            if object.encode('utf-8') == obj:
                flag += 1
        if flag == 1:
            print "The '%s' object of the '%s' window is found." %(obj, wnd)
            ret = 0
        else:
            print "The '%s' object of the '%s' window is NOT found." %(obj, wnd)
            ret = 1
    else:
        print "Parent window '%s' is not found." %(wnd)
        ret = 1
    return ret
