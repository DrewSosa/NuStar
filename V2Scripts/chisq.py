"""Andrew Sosanya 2018 Visiting Student andrew.sosanya.20@dartmouth.edu"""


import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma
import datetime
import os
import matplotlib.dates as mdates

from scipy import interpolate
import urllib
from os.path import expanduser


home = expanduser("~")
NEWPATH = "/Users/Anne/Documents/Caltech/fig"
spectra_dir="/Users/Anne/Documents/Caltech/ReducedDec/"

freq = {}

barred_list = ["040560101" ,"0301860101", "0301860101","0405090101","0106860301","01510651201", "0142830101", "0142770101", "0505760201" ,"0150651101", "0150651201", "0150280301"]
nodes = []

counter = 0
global_counter = 0
for source in os.listdir(spectra_dir):
    if source == ".DS_Store": continue
    source_folder = spectra_dir + source
    for obs_id in os.listdir(source_folder):
        if obs_id == ".DS_Store": continue
        if obs_id in barred_list: continue
        
        pn_loc = source_folder +  "/" + obs_id + "/"+"ULX"
        os.chdir(pn_loc)
        
        
        fig, axarray = plt.subplots(1, 1, figsize=(9, 13), sharex=True)
        plt.suptitle(source+ ":"+obs_id ,fontsize=20, horizontalalignment='center')
        

        chi_energy_data = open("fit_tbabscutoffpl+zgauss_con_e.dat")
        energy = [float(x.split()[0]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
        chi_energy_data.seek(0)
        chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
        delta_chi = [float(x) - (max(chi)) for x in chi]

        nodes.append([energy, delta_chi, obs_id])
        axarray.set_xscale("log")
        
        plot_03, = axarray.plot(energy, delta_chi, c='r')
        
        plot_03.set_label("0.1 gauss width")
        axarray.legend()
        
        os.chdir("/Users/Anne/Documents/Caltech/V2plots/")
        plt.savefig('/Users/Anne/Documents/Caltech/V2plots/'+ source + "-"+obs_id+ ".png" )
        print (nodes[0][0])
        print ("++++")
        print (nodes[0][1])

        break
  