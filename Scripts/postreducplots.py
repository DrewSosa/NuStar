# -*- coding: utf-8 -*-

"""Author @Andrew Sosanya, NASA NuStar Team @Caltech

Script to produce conjoined del-chi, flux, and contnour plots to aid spectral analysis 
of ULXs and other X-ray sources."

Notes from XSPEC about what each of these plots mean:

delchi-Plot the residuals in terms of sigmas with error bars of size one. 
In the case of the cstat and related statistics this plots (data-model)/error
where error is calculated as the square root of the model predicted number of counts. 
Note that in this case this is not the same as contributions to the statistic.

Contour - Plot the results of the last steppar run. If this was over one parameter then a plot of statistic versus
parameter value is produced while a steppar over two parameters results in a fit-statistic contour plot.

The fit statistic confidence contours are often drawn based on a relatively small grid (i.e., 5x5).
 To understand fully what these plots are telling you, it is useful to know a couple of points 
 concerning how the software chooses the location of the contour lines. 
 The contour plot is drawn based only on the information contained in the sample grid. 
 For example, if the minimum fit statistic occurs when parameter 1 equals 2.25 and you use steppar 1 1.0 5.0 4, 
 then the grid values closest to the minimum are 2.0 and 3.0. This could mean that there are no grid points where delta-fit statistic is less than your lowest level (which defaults to 1.0). 
 As a result, the lowest contour will not be drawn.
 This effect can be minimized by always selecting a steppar range that causes XSPEC to step very close to the true minima.



Last updated 8/13/18
andrew.sosanya.20@dartmouth.edu"""


from __future__ import unicode_literals
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma
import datetime
import os
import matplotlib.dates as mdates
from os.path import expanduser


matplotlib.rcParams['text.usetex'] = True
matplotlib.rcParams['text.latex.unicode'] = True


plt.rc('text', usetex=True)
plt.rc('font', family='serif')


home = "/Users/Anne/Documents/Caltech/"
M32_dir="/Users/Anne/Documents/Caltech/M32"


#list to hold values for plotting
nodes = []
#IDs to test
ids = ["0206890101","0206890401"]

#######for Poster Presentation plot. #######
    #change directory to that of the current obs_id
    #create a 2x1 plot canvas, give it a title and autoscale it.
os.chdir(home+"/"+"M32_Chandra"+"/"+"ULX")
fig, axarray = plt.subplots(2, 1, figsize=(9, 13), sharex=True)

axarray[1].set_xlabel(r'\textbf{Energy} (keV)', size=25)
axarray[1].set_ylabel(r'textbf Flux $\phi\ $ ', size=25)
axarray[0].set_ylabel(r'\ Chi-Squared $\Delta\ $$\chi\ $ ' , size=25)



# plt.suptitle(obs_id,fontsize=20, horizontalalignment='center')
axarray[0].autoscale()

nodes = []
#Contour Plots
chi_energy_data = open("fit_contour_tbabscutoffpl+zgauss.dat")
energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
chi_energy_data.seek(0)
chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
delta_chi = [float(x) - (max(chi)) for x in chi]
nodes.append([energy, delta_chi, "M32_Chandra"])
axarray[0].set_xscale("log")
Chancontour, = axarray[0].plot(nodes[0][0], nodes[0][1], color="r")
Chancontour.set_label("Chandra")

nodes = []

#Flux
axarray[1].autoscale()
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

nodes.append([energy, flux,err_energy, err_flux, model_flux, "M32_Chandra"])

axarray[1].set_yscale("log")
axarray[1].set_xscale("log")
Chanmodel, = axarray[1].plot(nodes[0][0], nodes[0][4], color='y')
Chanmodel.set_label("XMM Model")
Chandata = axarray[1].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)
Chandata.set_label("Chandra Spectrum")
nodes = []

os.chdir(home+"/"+"0672130101"+"/"+"ULX")

chi_energy_data = open("fit_contour_tbabscutoffpl+zgauss.dat")
energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
chi_energy_data.seek(0)
chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
delta_chi = [float(x) - (max(chi)) for x in chi]
nodes.append([energy, delta_chi, "0672130101"])
axarray[0].set_xscale("log")
XMMCon, = axarray[0].plot(nodes[0][0], nodes[0][1], color="b")
XMMCon.set_label("XMM")
axarray[0].legend(loc=6, prop={'size': 17})


nodes = []

axarray[1].autoscale()
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

nodes.append([energy, flux,err_energy, err_flux, model_flux, "0672130101"])

XMMmodel, = axarray[1].plot(nodes[0][0], nodes[0][4], color='k')
XMMmodel.set_label("XMM Model")
XMMdata = axarray[1].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="b", elinewidth=.5, c='b', alpha=0.7)
XMMdata.set_label("XMM Spectrum")
axarray[1].legend(loc=8, prop={'size': 15})

#Label axes



fig.subplots_adjust(hspace=0.0)

#Have to backpedal into original directory so that we can save the plots.

os.chdir(M32_dir)

plt.savefig('./' + "poster_plot")
 


# for obs_id in ids:
    
#     #change directory to that of the current obs_id
#     #create a 3x1 plot canvas, give it a title and autoscale it. 
#     os.chdir(home+"/"+obs_id+"/"+"ULX")
#     fig, axarray = plt.subplots(3, 1, figsize=(9, 13), sharex=True)
#     plt.suptitle(obs_id,fontsize=20, horizontalalignment='center')
#     axarray[0].autoscale()

#     #delta-chi Plot
#     deltachi_energy_data = open("fit_deltachi_tbabscutoffpl_delc.dat")

#     energy = [float(x.split()[0]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     deltachi_energy_data.seek(0)
#     delta_chi = [float(x.split()[2]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     deltachi_energy_data.seek(0)
#     err_energy = [float(x.split()[1]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     deltachi_energy_data.seek(0)
#     err_chi = [float(x.split()[3]) for x in deltachi_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]

#     nodes.append([energy, delta_chi,err_energy, err_chi, obs_id])

#     axarray[0].set_xscale("log")
#     # axarray[0].set_ylim(min(nodes[0][1]),max(nodes[0][1]))
#     # print min(nodes[0][1]),max(nodes[0][1])
#     axarray[0].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r')


#     nodes = []
#     #Contour Plots
#     chi_energy_data = open("fit_contour_tbabscutoffpl+zgauss.dat")
#     energy = [x.split()[0] for x in chi_energy_data.readlines() if len(x.split()) > 1]
#     chi_energy_data.seek(0)
#     chi = [float(x.split()[1]) for x in chi_energy_data.readlines() if len(x.split()) > 1]
#     delta_chi = [float(x) - (max(chi)) for x in chi]

#     nodes.append([energy, delta_chi, obs_id])

#     axarray[1].set_xscale("log")
#     contour_plot, = axarray[1].plot(nodes[0][0], nodes[0][1])
#     contour_plot.set_label("0.1 gauss wdith")

#     nodes = []

#     #Flux

#     flux_energy_data = open("fit_flux_tbabscutoffpl_ld.dat")
#     energy = [float(x.split()[0]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     flux_energy_data.seek(0)
#     flux = [float(x.split()[2]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     flux_energy_data.seek(0)
#     err_energy = [float(x.split()[1]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     flux_energy_data.seek(0)
#     err_flux = [float(x.split()[3]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]
#     flux_energy_data.seek(0)
#     model_flux = [float(x.split()[4]) for x in flux_energy_data.readlines() if len(x.split()) > 1 if "SERR" not in x.split()]

#     nodes.append([energy, flux,err_energy, err_flux, model_flux, obs_id])

#     axarray[2].set_yscale("log")
#     axarray[2].set_xscale("log")
#     axarray[2].plot(nodes[0][0], nodes[0][4], color='g')
#     axarray[2].errorbar(nodes[0][0], nodes[0][1], nodes[0][3], nodes[0][2], ecolor="r", elinewidth=.5, c='r', alpha=0.7)

#     nodes = []

#     fig.subplots_adjust(hspace=0.0)

#     #Have to backpedal into original directory so that we can save the plots.

#     os.chdir(M32_dir)
#     plt.savefig('./' + obs_id)
     

