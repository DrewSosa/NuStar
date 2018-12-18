"""Andrew Sosanya 2018 Visiting Student andrew.sosanya.20@dartmouth.edu"""


import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma
import datetime
import os
import matplotlib.dates as mdates


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
        fig, axarray = plt.subplots(3, 1, figsize=(9, 13), sharex=True)
        plt.suptitle(source+ ":"+obs_id ,fontsize=20, horizontalalignment='center')
        axarray[0].autoscale()
        print (obs_id, source)
        #delta-chi Plot
        deltachi_energy_data = open("chisq_tbabscutoffpl_delc.dat")

        energy = [float(x.split()[0]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        deltachi_energy_data.seek(0)
        delta_chi = [float(x.split()[2]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        deltachi_energy_data.seek(0)
        err_energy = [float(x.split()[1]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        deltachi_energy_data.seek(0)
        err_chi = [float(x.split()[3]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]

        nodes.append([energy, delta_chi,err_energy, err_chi, obs_id])


        axarray[0].set_xscale("log")
        # axarray[0].set_ylim(min(nodes[0][1]),max(nodes[0][1]))
        # print min(nodes[0][1]),max(nodes[0][1])
        axarray[0].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r')


        nodes = []
        #Chi-Squared
        #
        #0.3

        chi_energy_data = open("chisq_tbabscutoffpl+zgauss_con_e.dat")
        energy = [float(x.split()[0]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
        chi_energy_data.seek(0)
        chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
        delta_chi = [float(x) - (max(chi)) for x in chi]

        nodes.append([energy, delta_chi, obs_id])

        axarray[1].set_xscale("log")
        plot_03, = axarray[1].plot(nodes[0][0], nodes[0][1], c='r')
        plot_03.set_label("0.1 gauss wdith")
        axarray[1].legend()

        nodes = []
        #Flux

        flux_energy_data = open("chisq_tbabscutoffpl_ld.dat")
        energy = [float(x.split()[0]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        flux_energy_data.seek(0)
        flux = [float(x.split()[2]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        flux_energy_data.seek(0)
        err_energy = [float(x.split()[1]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        flux_energy_data.seek(0)
        err_flux = [float(x.split()[3]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        flux_energy_data.seek(0)
        model_flux = [float(x.split()[4]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]

        nodes.append([energy, flux,err_energy, err_flux, model_flux, obs_id])

        axarray[2].set_yscale("log")
        axarray[2].set_xscale("log")
        axarray[2].plot(nodes[0][0], nodes[0][4], color='g')
        axarray[2].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)

        nodes = []

        fig.subplots_adjust(hspace=0.0)

        #Have to backpedal into original directory so that we can save the plots.
       

        os.chdir("/Users/Anne/Documents/Caltech/V2plots/")
        plt.savefig('/Users/Anne/Documents/Caltech/V2plots/' + source + "-"+obs_id+"_chisq.jpg" )
