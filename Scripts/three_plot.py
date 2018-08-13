"""Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu"""


import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma
import datetime
import os
import matplotlib.dates as mdates
from spacepy import pycdf
from scipy import interpolate
import urllib
from os.path import expanduser

from grab_ra_dec import get_ra_dec

home = expanduser("~")
NEWPATH = "/Users/sosa/Documents/Caltech/fig"
spectra_dir="/Users/sosa/Documents/Caltech/Spectra"

freq = {}


nodes = []

counter = 0
global_counter = 0
for obs_id in os.listdir(spectra_dir):
    if obs_id == ".DS_Store": continue
    tags = get_ra_dec()

    os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
    fig, axarray = plt.subplots(3, 1, figsize=(9, 13), sharex=True)
    plt.suptitle(tags[obs_id],fontsize=20, horizontalalignment='center')
    axarray[0].autoscale()

    #delta-chi Plot
    deltachi_energy_data = open("fit_tbabscutoffpl_delc.dat")

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
    #0.03
    os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
    chi_energy_data = open("fit_tbabscutoffpl+zgauss_con_e_0.01.dat")
    energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
    chi_energy_data.seek(0)
    chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
    delta_chi = [float(x) - (max(chi)) for x in chi]

    nodes.append([energy, delta_chi, obs_id])

    axarray[1].set_xscale("log")
    plot_003, = axarray[1].plot(nodes[0][0], nodes[0][1])
    plot_003.set_label("0.01 gauss wdith")

    nodes = []


    #0.3
    os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
    chi_energy_data = open("fit_tbabscutoffpl+zgauss_con_e_0.1.dat")
    energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
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

    flux_energy_data = open("fit_tbabscutoffpl_ld.dat")
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
    os.chdir("..")
    os.chdir("..")
    os.chdir("..")

    if tags[obs_id] not in freq.keys(): freq[tags[obs_id]] = 1
    else: freq[tags[obs_id]] +=1


    os.chdir("/Users/sosa/Documents/Caltech/1x10_plots/")
    plt.savefig('/Users/sosa/Documents/Caltech/1x10_plots/' + str(tags[obs_id])+"-"+ str(freq[tags[obs_id]]) + ".jpg" )
