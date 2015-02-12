#!/usr/bin/env python

class CpuStatus:
        def __init__(self, nr_periods, nr_throttled, throttled_time):
            self.nr_periods = nr_periods
            self.nr_throttled = nr_throttled
            self.nr_throttled_time = throttled_time
            self.cpustatus = (
                                'nr_periods ' + 
                                str(nr_periods) + 
                                '\nnr_throttled ' +
                                str(nr_throttled) +
                                '\nthrottled_time' +
                                str(throttled_time)) 

class IoOperation:
    (
        All, 
        read, 
        write, 
        sync, 
        async) = range(0, 5)

class Subsystem:
    (
        blkio, 
        cpu, 
        cpuset, 
        cpuacct, 
        devices, 
        freezer, 
        memory, 
        net_cls, 
        net_prio, 
        ns, 
        perf_event) = range(1, 12)


class Device:
    def __init__(self, major, minor):
        if str(major).isdigit() and str(minor).isdigit():
            self.device = str(major) + ':' + str(minor)

class Cpuset:
    def __init__(self, cpusets):
        cpulist = []
        for cpuset in cpusets.split(','):
            if cpuset.find('-') != -1:
                cputemp = cpuset.split('-')
                if len(cputemp) != 2:
                    raise ValueError('input value error.')
                else :
                    for cpu in cputemp:
                        if not cpu.isdigit():
                            raise ValueError('input value error.')
                        else:
                            cpulist += range(int(cputemp[0]), int(cputemp[1]) + 1)
            else :
                if cpuset.isdigit():
                    cpulist.append(int(cpuset))
                else :
                    raise ValueError('input value error.')
       
        self.cpuset = list(set(sorted(cpulist)))

#if __name__ == '__main__':
a = Cpuset('1,1-2,5-6,2-3')
print a.cpuset
