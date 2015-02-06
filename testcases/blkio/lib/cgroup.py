#!/usr/bin/env python
import os
import re

class Cgroup:
    def __init__(self, name, parent, subsystem = ''):
        self.root = '/cgroup'
        self.name = name
        if subsystem == '':
            if isinstance(parent, Cgroup):
                self.type = 'sub_cgroup'
                self.subsystem = parent.subsystem
                self.hierarchy = parent.hierarchy
                self.parent = parent 
                self.path = os.path.join(parent.path, name)
            else :
                print("The second parameter should be instance of 'Cgroup'!")
                return -1
        else :
            if isinstance(subsystem, list):
                self.type = 'root_cgroup'
                self.subsystem = subsystem
                self.hierarchy = name
                self.parent = ''
                self.path = os.path.join(self.root, name)
            else:
                print("The third parameter should be instance of 'List'!")
                return None 

    def create(self):
        if self.type == 'sub_cgroup':
            os.system('mkdir -p ' + self.path)
        else :
            self.create_hierarchy()

    def delete(self):
        if self.type == 'root_cgroup':
            for file in os.listdir(self.path):
                if os.path.isdir(file):
                    self.rrm(file)
                else : pass
            self.delete_hierarchy()
        else :
            self.rrm(self.path)

    def create_hierarchy(self):
        if self.type == 'root_cgroup':
            os.system('mkdir -p ' + self.path)
            op = ''
            for ss in self.subsystem:
                op = op + ',' + ss
            op = op[1:]
            os.system('mount -t cgroup -o ' + op + ' ' + self.name + ' ' + self.path)
        else :
            print("sub_cgroup cann't create hierarchy!")
            return -1

    def delete_hierarchy(self):
        os.system('umount -d ' + os.path.join(self.root, self.hierarchy))
    

    def is_hierarchy_exist(self, name, subsystem, path):
        for line in open('/proc/mounts', 'r'):
            if line.split()[2] == 'cgroup':
                line_subsystem = line.split()[3].split(',')[len(line.split()[3].split(',')) - len(subsystem):]
                if line.split()[0] == name and \
                os.path.abspath(line.split()[1]) == os.path.abspath(path) and \
                sorted(line_subsystem) == sorted(subsystem):
                    return True
            else : pass
        return False

    @staticmethod
    def is_hname_inuse(name);
        for line in open()

    def is_hierarchy_creatable(self):
        
            
