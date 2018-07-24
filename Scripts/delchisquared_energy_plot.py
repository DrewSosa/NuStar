"""Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu"""
#fixed for ra/dec

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
plots = []
fig, ax1 = plt.subplots(1,1, sharey=True)
nodes = []
counter = 0
global_counter = 0

for obs_id in os.listdir(spectra_dir):
    if obs_id == ".DS_Store": continue
    tags = get_ra_dec()


    os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
    chi_energy_data = open("fit_tbabscutoffpl+zgauss_con_e.dat")
    energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
    chi_energy_data.seek(0)
    chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
    delta_chi = [float(x) - (max(chi)) for x in chi]

    nodes.append([energy, delta_chi, obs_id])


    counter += 1
    global_counter += 1
    if counter > 3 or global_counter == 43:

            fig, axarray = plt.subplots(2, 2)


            axarray[0, 0].set_xscale("log")
            axarray[0, 0].plot(nodes[0][0], nodes[0][1])
            axarray[0, 0].set_title(tags[nodes[0][2]])

            axarray[0, 1].set_xscale("log")
            axarray[0, 1].plot(nodes[1][0], nodes[1][1])
            axarray[0, 1].set_title(tags[nodes[1][2]])

            axarray[1, 0].set_xscale("log")
            axarray[1, 0].plot(nodes[2][0], nodes[2][1])
            axarray[1, 0].set_title(tags[nodes[2][2]])

            if counter > 3:

                axarray[1, 1].set_xscale("log")
                axarray[1, 1].plot(nodes[3][0], nodes[3][1])
                axarray[1, 1].set_title(tags[nodes[3][2]])

            fig.subplots_adjust(hspace=0.4)
            counter = 0

            os.chdir("..")
            os.chdir("..")
            os.chdir("..")

            os.chdir("/Users/sosa/Documents/Caltech/chi_squared_plots")

            plt.savefig('/Users/sosa/Documents/Caltech/chi_squared_plots/' + str(nodes[0][2]) + "log")
            nodes = []

            # plt.show()

