#!/usr/bin/env python

from cgtypes import *

class CgroupParameter:
    base = {
                'cgroup.event_control':'', 
                'cgroup.procs':[],
                'notify_on_release':False,
                'release_agent':'',
                'tasks':[]
            }

class BlkioParameter(CgroupParameter):
    parameter = {
                    'blkio.io_merged':'',# reports the number of BIOS requests merged into requests for I/O operations by a cgroup.
                    'blkio.io_queued':'',# reports the number of requests queued for I/O operations by a cgroup. 
                    'blkio.io_service_bytes':'', # reports the number of bytes transferred to or from specific devices by a cgroup as seen by the CFQ scheduler.
                    'blkio.io_serviced':'', # reports the number of bytes transferred to or from specific devices by a cgroup as seen by the CFQ scheduler.
                    'blkio.io_service_time':'',# reports the total time between request dispatch and request completion for I/O operations on specific devices by a cgroup as seen by the CFQ scheduler.
                    'blkio.io_wait_time':'', # reports the number of bytes transferred to or from specific devices by a cgroup as seen by the CFQ scheduler.
                    'blkio.reset_stats':'', # reports the number of bytes transferred to or from specific devices by a cgroup as seen by the CFQ scheduler.
                    'blkio.sectors':'', # reports the number of sectors transferred to or from specific devices by a cgroup.
                    'blkio.throttle.io_service_bytes':'', # reports the number of bytes transferred to or from specific devices by a cgroup.
                    'blkio.throttle.io_serviced':'', # reports the number of I/O operations performed on specific devices by a cgroup as seen by the throttling policy.
                    'blkio.throttle.io_read_bps_device':'', # specifies the upper limit on the number of read operations a device can perform.
                    'blkio.throttle.io_read_iops_device':'', # specifies the upper limit on the number of read operations a device can perform.
                    'blkio.throttle.io_write_bps_device':'', # specifies the upper limit on the number of write operations a device can perform.
                    'blkio.throttle.io_write_iops_device':'', # specifies the upper limit on the number of write operations a device can perform.
                    'blkio.time':'', # reports the time that a cgroup had I/O access to specific devices.
                    'blkio.weight':1000, # specifies the relative proportion (weight) of block I/O access available by default to a cgroup, in the range 100 to 1000.
                    'blkio.weight_device':'' # specifies the relative proportion (weight) of I/O access on specific devices available to a cgroup, in the range 100 to 1000.
                }

class CpuParameter(CgroupParameter):
    parameter = {
                    'cpu.cfs_period_us':100000, # specifies a period of time in microseconds (us, represented here as "us") for how regularly a cgroup's access to CPU resources should be reallocated.
                    'cpu.cfs_quota_us':-1, # specifies the total amount of time in microseconds (us, represented here as "us") for which alltasks in a cgroup can run during one period (as defined by cpu.cfs_period_us).
                    'cpu.rt_period_us':1000000, # applicable to real-time scheduling tasks only, this parameter specifies a period of time in microseconds (us, represented here as "us") for how regularly a cgroup's access to CPU resources should be reallocated.
                    'cpu.rt_runtime_us':0, # applicable to real-time scheduling tasks only, this parameter specifies a period of time in microseconds (us, represented here as "us") for the longest continuous period in which the tasks in a cgroup have access to CPU resources.
                    'cpu.shares':1024, # contains an integer value that specifies a relative share of CPU time available to the tasks in a cgroup.
                    'cpu.stat':CpuStatus(0, 0, 0) # reports CPU time statistics.
                }

class CpusetParameter(CgroupParameter):
    parameter = {
                    'cpuset.cpu_exclusive':False, # contains a flag (0 or 1) that specifies whether cpusets other than this one and its parents and children can share the CPUs specified for this cpuset.
                    'cpuset.cpus':'', # specifies the CPUs that tasks in this cgroup are permitted to access.
                    'cpuset.mem_exclusive':False, # contains a flag (0 or 1) that specifies whether other cpusets can share the memory nodes specified for this cpuset.
                    'cpuset.mem_hardwall':False, # contains a flag (0 or 1) that specifies whether kernel allocations of memory page and buffer data should be restricted to the memory nodes specified for this cpuset.
                    'cpuset.memory_migrate':False, # contains a flag (0 or 1) that specifies whether a page in memory should migrate to a new node if the values in cpuset.m em s change.
                    'cpuset.memory_pressure':'',
                    'cpuset.memory_pressure_enabled':'',
                    'cpuset.memory_spread_page':'',
                    'cpuset.memory_spread_slab':'',
                    'cpuset.mems':'', # specifies the memory nodes that tasks in this cgroup are permitted to access.
                    'cpuset.sched_load_balance':'',
                    'cpuset.sched_relax_domain_level':''
                }

class CpuacctParameter(CgroupParameter):
    parameter = {
                    'cpuacct.stat':'',
                    'cpuacct.usage':'',
                    'cpuacct.usage_percpu':''
                }

class DevicesParameter(CgroupParameter):
    parameter = {
                    'devices.allow':'',
                    'devices.deny':'',
                    'devices.list':''
                }

class FreezerParameter(CgroupParameter):
    parameter = {
                    'freezer.state':''
                }

class MemoryParameter(CgroupParameter):
    parameter = {
                    'memory.failcnt':'',
                    'memory.force_empty':'',
                    'memory.limit_in_bytes':'',
                    'memory.max_usage_in_bytes':'',
                    'memory.memsw.failcnt':'',
                    'memory.memsw.limit_in_bytes':'',
                    'memory.memsw.max_usage_in_bytes':'',
                    'memory.memsw.usage_in_bytes':'',
                    'memory.move_charge_at_immigrate':'',
                    'memory.oom_control':'',
                    'memory.soft_limit_in_bytes':'',
                    'memory.stat':'',
                    'memory.swappiness':'',
                    'memory.usage_in_bytes':'',
                    'memory.use_hierarchy':''
                }

class Net_clsParameter(CgroupParameter):
    parameter = {
                    'net_cls.classid':''
                }

if __name__ == '__main__':
    a = CpuParameter()
    print a.parameter['cpu.stat'].cpustatus
