#!/usr/bin/env python
import os
import re
from common import *

class Cgroup:
    def __init__(self, name, parent, subsystem = ''):
        self.mounts = os.path.abspath('/proc/mounts')
        self.root = os.path.abspath('/cgroup')
        self.name = name
        self.type = ''
        self.subsystem = []
        self.hierarchy = ''
        self.parent = self
        self.path = ''
        self.rootpath = ''
        if subsystem == '':
            if isinstance(parent, Cgroup):
                self.type = 'sub_cgroup'
                self.subsystem = parent.subsystem
                self.hierarchy = parent.hierarchy
                self.parent = parent
                self.path = os.path.join(parent.path, name)
                self.rootpath = parent.rootpath
            else :
                print("The second parameter should be instance of 'Cgroup'!")
                return None
        else :
            if isinstance(subsystem, list):
                self.type = 'root_cgroup'
                self.subsystem = subsystem
                self.hierarchy = name
                self.parent = ''
                self.path = os.path.join(self.root, name)
                self.rootpath = self.path
            else:
                print("The third parameter should be instance of 'List'!")
                return None 

    def create(self):
        if self.type == 'sub_cgroup':
            if self.is_cgroup_exist():
                print("The sub-cgroup '%s' of '%s' already exists." % (self.name, self.parent.name))
                return -1
            else :
                pass
            if not self.is_parent_exist():
                print("The parent cgroup of '%s' does not exist." % self.name)
                return -1
            else :
                os.system('mkdir -p ' + self.path)
        else :
            self.create_hierarchy()

    def delete(self):
        if self.type == 'root_cgroup':
            for file in os.listdir(self.path):
                if os.path.isdir(file):
                    self.rrm(file)
                else : 
                    pass
            self.delete_hierarchy()
        elif self.type == 'sub_cgroup':
            self.rrm(self.path)
        else:
            pass
    
    def rrm(self, path):
        if os.path.isdir(path):
            for file in os.listdir(path):
                self.rrm(file)
            os.rmdir(path)
        else :
            pass

    def create_hierarchy(self):
        if not self.is_hierarchy_creatable():
            print("The hierarchy '%s' is not createble!" % self.hierarchy)
            return -1
        else :
            pass
        if self.type == 'root_cgroup':
            os.system('mkdir -p ' + self.path)
            op = ''
            for ss in self.subsystem:
                op = op + ',' + ss
            op = op[1:]
            os.system('mount -t cgroup -o ' + op + ' ' + self.name + ' ' + self.path)
            return 0
        else :
            print("sub_cgroup cann't create hierarchy!")
            return -2

    def delete_hierarchy(self):
        os.system('umount -d ' + os.path.join(self.root, self.hierarchy))
        os.rmdir(os.path.join(self.root, self.hierarchy))
    

    def is_hierarchy_exist(self, name, subsystem, path):
        for line in open(self.mounts, 'r'):
            if line.split()[2] == 'cgroup':
                line_subsystem = line.split()[3].split(',')[len(line.split()[3].split(',')) - len(subsystem):]
                if (line.split()[0] == name and
                    os.path.abspath(line.split()[1]) == os.path.abspath(path) and
                    sorted(line_subsystem) == sorted(subsystem)):
                    return True
            else : 
                pass
        return False

    def is_hname_used(self, name):
        if os.path.isdir(os.path.join(self.root, name)):
            if len(os.listdir(os.path.join(self.root, name))) == 0:
                #print("The path '%s' already exist, but it's empty." % os.path.join(self.root, name))
                return False
            else :
                print("The hierarchy '%s' already exist!" % name)
                return True
        elif os.path.exists(os.path.join(self.root, name)):
            print("The path '%s' already exist!" % os.path.join(self.root, name))
            return True
        else :
            #print("The hierarchy name '%s' is not used!" % name)
            return False

    def is_hsystem_mounted(self, system):
        for line in open(self.mounts):
            if line.split()[2] == 'cgroup':
                if system in line.split()[3]:
                    print("The subsystem '%s' is mounted!" % system)
                    return True
                else :
                    pass
            else :
                pass
        #print("The subsystem '%s' is not mounted!" % system)
        return False
    
    def is_hpath_used(self, path):
        for line in open(self.mounts):
            if line.split()[2] == 'cgroup':
                if os.path.samefile(path, line.split()[1]):
                    print("The path '%s' is already used!" % path)
                    return True
                else :
                    pass
            else :
                pass
        #print("The path '%s' is not used!" % path)
        return False

    def is_hierarchy_creatable(self):
        if self.is_hname_used(self.hierarchy):
            return False
        elif self.is_hpath_used(self.rootpath):
            return False
        else :
            for system in self.subsystem:
                if self.is_hsystem_mounted(system):
                    return False
                else :
                    pass
            return True

    def is_cgroup_exist(self):
        if os.path.exists(self.path):
            if 'cgroup.procs' in os.listdir(self.path):
                return True
            else :
                print("The '%s' dir exist, but it's not a cgroup." % self.path)
                return False
        else :
            print("The '%s' does not exist." % self.path)
            return False

    def is_parent_exist(self):
        if self.type == 'root_cgroup':
            return self.is_hierarchy_exist(self.hierarchy, self.subsystem, self.path)
        elif self.type == 'sub_cgroup':
            return self.parent.is_cgroup_exist()
        else :
            print("Cgroup type error.")
            return False
