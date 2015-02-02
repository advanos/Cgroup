#!/usr/bin/python
import os,re,sys

from autotest.client import utils, test
from autotest.client.pytohtml import *

casename = 'CgroupTest'

class CgroupTest(test.test):
    version = 1

    def initialize(self):
        self.results = []

    def run_once(self,args = ''):
        os.chdir(self.bindir)
        os.system('./RunTests.sh -f TestRun.xml')

        os.system("sed -i '$d' logs/ResultsForAutoTest")
        os.system("sed -i '$d' logs/ResultsForAutoTest")
        os.system("sed -i '$d' logs/ResultsForAutoTest")
        os.system("sed -i '$d' logs/ResultsForAutoTest")
        os.system("sed -i '$d' logs/ResultsForAutoTest")
        os.system("sed -i '$d' logs/ResultsForAutoTest")

        page = PytoHTML()
        page.addtxt('logs/ResultsForAutoTest')
        page.toresult(casename)
        resultdir = '/usr/local/autotest/results/default/' + casename + '/results/result'
        os.system('cp logs/ResultsForAutoTest ' + resultdir)

