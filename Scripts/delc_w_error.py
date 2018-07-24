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


fig, ax1 = plt.subplots(1,1, sharey=True)

nodes = []

counter = 0
global_counter = 0
for obs_id in os.listdir(spectra_dir):
    if obs_id == ".DS_Store": continue
    tags = get_ra_dec()

    os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
    deltachi_energy_data = open("fit_tbabscutoffpl_delc.dat")

    energy = [float(x.split()[0]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
    deltachi_energy_data.seek(0)
    delta_chi = [float(x.split()[2]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
    deltachi_energy_data.seek(0)
    err_energy = [float(x.split()[1]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
    deltachi_energy_data.seek(0)
    err_chi = [float(x.split()[3]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]

    nodes.append([energy, delta_chi,err_energy, err_chi, obs_id])
    counter += 1
    global_counter += 1

    if counter > 3 or global_counter == 43:

        fig, axarray = plt.subplots(2, 2)
        axarray[0, 0].set_xscale("log")
        axarray[0, 0].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r')
        axarray[0, 0].set_title(tags[nodes[0][4]])



        axarray[0, 1].set_xscale("log")
        axarray[0, 1].errorbar(nodes[1][0], nodes[1][1], nodes[1][3], nodes[1][2], ecolor="r", elinewidth=.5, c='r')
        axarray[0, 1].set_title(tags[nodes[1][4]])

        axarray[1, 0].set_xscale("log")
        axarray[1, 0].errorbar(nodes[2][0], nodes[2][1], nodes[2][3], nodes[2][2], ecolor="r", elinewidth=.5, c='r')
        axarray[1, 0].set_title(tags[nodes[2][4]])

        if counter > 3:

            axarray[1, 1].set_xscale("log")
            axarray[1, 1].errorbar(nodes[3][0], nodes[3][1], nodes[3][3], nodes[3][2], ecolor="r", elinewidth=.5, c='r')
            axarray[1, 1].set_title(tags[nodes[3][4]])

        fig.subplots_adjust(hspace=0.6)
        counter = 0
        #Have to backpedal into original directory so that we can save the plots.
        os.chdir("..")
        os.chdir("..")
        os.chdir("..")

        os.chdir("/Users/sosa/Documents/Caltech/delta_chi_plots/")
        plt.savefig('/Users/sosa/Documents/Caltech/delta_chi_plots/' + str(nodes[0][4]))
        nodes = []