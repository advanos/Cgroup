#!/usr/bin/env python

from cgroup import *
from unittest import *

if __name__ == '__main__':
    cg1 = Cgroup('cpu_cpuset', '', ['cpu', 'cpuset'])
    cg1.create()
    cg2 = Cgroup('cpu_qwe', cg1)
    cg2.create()
