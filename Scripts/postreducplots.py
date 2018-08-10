import datetime
import os
import matplotlib.dates as mdates
from spacepy import pycdf
from scipy import interpolate
import urllib
from os.path import expanduser

from grab_ra_dec import get_ra_dec

home = expanduser("~")
NEWPATH = "/Users/Anne/Documents/Caltech/M32"
M32_dir="/Users/Anne/Documents/Caltech/M32"

freq = {}


nodes = []
ids = ["0672130101" "0672130701" "M32_Chandra" "0505760201" "0672130501"]
counter = 0
global_counter = 0
for obs_id in os.listdir(M32_dir):
    if obs_id == ".DS_Store": continue
    if obs_id not in 
    tags = get_ra_dec()

    os.chdir(M32_dir+"/"+obs_id+"/"+"ULX")
    fig, axarray = plt.subplots(3, 1, figsize=(9, 13), sharex=True)
    plt.suptitle(tags[obs_id],fontsize=20, horizontalalignment='center')
    axarray[0].autoscale()

    #delta-chi Plot
    deltachi_energy_data = open("fit_flux_tbabscutoffpl_ld.dat")

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
    os.chdir(M32_dir+"/"+obs_id+"/"+"ULX")
    chi_energy_data = open("fit_contour_tbabscutoffpl+zgauss.dat")
    energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
    chi_energy_data.seek(0)
    chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
    delta_chi = [float(x) - (max(chi)) for x in chi]

    nodes.append([energy, delta_chi, obs_id])

    axarray[1].set_xscale("log")
    plot_003, = axarray[1].plot(nodes[0][0], nodes[0][1])
    plot_003.set_label("0.1 gauss wdith")

    nodes = []

    #Flux

    flux_energy_data = open("fit_flux_tbabscutoffpl_ld.dat")
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

    os.chdir("/Users/Anne/Documents/Caltech/M32/")
    plt.savefig('/Users/Anne/Documents/Caltech/1x10_plots/' + str(tags[obs_id])+ ".jpg" )
