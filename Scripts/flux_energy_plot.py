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
plots = []

fig, ax1 = plt.subplots(1,1, sharey=True)

nodes = []

counter = 0
global_counter = 0
for obs_id in os.listdir(spectra_dir):
    if obs_id == ".DS_Store": continue
    tags = get_ra_dec()


    # reasoning for this is that I had no shorthand way to get plots of fours while
    # combing through all the data. So this uses the subplots 2-d array method, described
    # in subplots_demo, which can also be found online.

        # plt.show()
        #to account for the 37th element, does basically the same thing as the above, with just one subplot.


    os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
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
    counter += 1
    global_counter += 1
    if counter > 3 or global_counter == 43:
        print global_counter
        plt.yscale("log")
        plt.xscale("log")
        fig, axarray = plt.subplots(2, 2)
        axarray[0, 0].set_yscale("log")
        axarray[0, 0].set_xscale("log")

        model,  = axarray[0, 0].plot(nodes[0][0], nodes[0][4], color='g')
        model.set_label("Model")
        data = axarray[0, 0].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)
        data.set_label("Data")

        #RA DEC using the get_ra_dec

        axarray[0, 0].set_title(tags[nodes[0][5]])
        axarray[0,0].legend()


        axarray[0, 1].set_yscale("log")
        axarray[0, 1].set_xscale("log")
        axarray[0, 1].plot(nodes[1][0], nodes[1][4], color='g')
        axarray[0, 1].errorbar(nodes[1][0], nodes[1][1], nodes[1][3], nodes[1][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)

        axarray[0, 1].set_title(tags[nodes[1][5]])


        axarray[1, 0].set_yscale("log")
        axarray[1, 0].set_xscale("log")
        axarray[1, 0].plot(nodes[2][0], nodes[2][4], color='g')
        axarray[1, 0].errorbar(nodes[2][0], nodes[2][1], nodes[2][3], nodes[2][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)
        axarray[1, 0].set_title(tags[nodes[2][5]])

        if counter > 3:

            axarray[1, 1].set_yscale("log")
            axarray[1, 1].set_xscale("log")
            axarray[1, 1].plot(nodes[3][0], nodes[3][4], color='g')
            axarray[1, 1].errorbar(nodes[3][0], nodes[3][1], nodes[3][3], nodes[3][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)
            axarray[1, 1].set_title(tags[nodes[3][5]])



        fig.subplots_adjust(hspace=0.4)
        counter = 0

        #Have to backpedal into original directory so that we can save the plots.
        os.chdir("..")
        os.chdir("..")
        os.chdir("..")

        os.chdir("/Users/sosa/Documents/Caltech/flux_plots/")
        plt.savefig('/Users/sosa/Documents/Caltech/flux_plots/' + str(nodes[0][5]) +"_log")
        nodes = []




 # if global_counter == 9:

        #     os.chdir(spectra_dir+"/"+obs_id+"/"+"pps")
        #     flux_energy_data = open("fit_tbabscutoffpl_ld.dat")
        #     energy = [float(x.split()[0]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        #     flux_energy_data.seek(0)
        #     flux = [float(x.split()[2]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        #     flux_energy_data.seek(0)
        #     err_energy = [float(x.split()[1]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        #     flux_energy_data.seek(0)
        #     err_flux = [float(x.split()[3]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
        #     fig, ax1 = plt.subplots()
        #     flux_energy_data.seek(0)
        #     model_flux = [float(x.split()[4]) for x in flux_energy_data.readlines() if len(x.split()) > 2 if "SERR" not in x.split()]
        #     nodes.append([energy, flux,err_energy, err_flux, model_flux, obs_id])



        #     ax1.set_yscale("log")
        #     ax1.set_xscale("log")
        #     data = ax1.errorbar(nodes[0][0], nodes[0][1], nodes[0][2], nodes[0][3], ecolor="r", elinewidth=.5, c='r', alpha=0.7)
        #     data.set_label("Data")
        #     model, = ax1.plot(nodes[0][0], nodes[0][4])
        #     model.set_label("Model")
        #     ax1.set_title(nodes[0][5])

        #    #save plot
        #     os.chdir("..")
        #     os.chdir("..")
        #     os.chdir("..")
        #     print os.getcwd()
        #     plt.savefig('/Users/sosa/Documents/Caltech/flux_plots/'+ str(nodes[0][5])+"_log")
        #     # plt.show()
        #     break