#!/usr/bin/env python

from cgroup import *

if __name__ == '__main__':
    cg1 = Cgroup('cpu_cpuset', '', ['cpu', 'cpuset'])
    print cg1.is_hierarchy_exist("test_cgroup", ['blkio','cpu','cpuset','net_cls','memory'], '/cgroup/cpu')
            

"""
    cg1.create()
    cg2 = Cgroup('test', cg1)
    cg2.create()
    cg2.delete()
    cg1.delete()
"""
