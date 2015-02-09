#!/usr/bin/env python

from cgroup import *

if __name__ == '__main__':
    cg1 = Cgroup('cpu_cpuset', '', ['cpu', 'cpuset'])
    cg1.create()
    #print cg1.is_hname_used('cpu___cpuset')
    #print cg1.is_hsystem_mounted('ns')
    #print cg1.is_hpath_used('/cgroup/cpu')
