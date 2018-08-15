#!/bin/bash
	#specific
	read -p "Observation ID: " obs_id
	read -p "XMM or Chandra? " sata

	#Change into the correct directory.
	cd
	cd Documents/Caltech/${obs_id}/ULX

	

	#Lists that allow for easy variation of parameters
 	
	if [ ${sata} = "Chandra"]; then
	do 
		pndata="ULX1_grp.pi"
		pnresp="ULX1.rmf"
		pnarf="ULX1.corr.arf"
		pnbgd="ULX1_bkg.pi"
	else
		datafile="$(ls | grep "pat0" | grep "60" | grep "12"| grep "20.fits")"
		respdata="$(ls | grep "pat0_60_12.rmf")"
		arf="$(ls | grep "pat0_60_12.arf")"
		bgfile="$(ls | grep "bgd2_pat0_60_12_pi.fits")"
					


					
	
	m1data="m1_spectrum_grp.fits"
	m1resp="m1.rmf"
	m1arf="m1_arf"
	m1bgfile="m1_background_spectrum.fits"

	m2data="m2_spectrum_grp.fits"
	m2resp="m2.rmf"
	m2arf="m2_arf"
	m2bgfile="m2_background_spectrum.fits"


	echo "query yes" > contour.txt

	#Put in the correct files and output them to a parameter specific XSPEC file.
	echo "data 1:1 ${m1data} 2:2 ${m2data}" >> contour.txt
	echo "back 1:1 ${m1bgfile} 2:2 ${m2bgfile}" >> contour.txt
	echo "resp 1:1 ${m1resp} 2:2 ${m2resp}" >> contour.txt
	echo "arf 1:1 ${m1_arf} 2:2 ${m2arf}" >> contour.txt
	echo "ignore **-2.0 10.0-**" >> contour.txt
	echo "ignore bad" >> contour.txt


	echo "log contour.log" >> contour.txt
	# Define the model
	echo "model tbabs*cutoffpl" >> contour.txt
	
	#Data Group 1
	#Absorption
	echo "1 , 0.1" >> contour.txt
	#powerlaw index/gamma
	echo "2, 0.01" >> contour.txt
	#Cuttoff energy
	echo "15, 0.01" >> contour.txt
	#Normalization
	echo "1.E-4 1E-5" >> contour.txt
	
	#Data Group 2
	echo " " >> contour.txt
	echo " " >> contour.txt
	echo " " >> contour.txt
	echo " " >> contour.txt

	echo "fit" >> contour.txt

	# echo "save all fit_contour_tbabscutoffpl.xcm" >> contour.txt
	echo "setplot energy" >> contour.txt
	echo "setplot rebin 3 10" >> contour.txt


	#echo "hardcopy plot_${radius}_${pattern} color" >> contour.txt
	echo "addc 3 zgauss" >> contour.txt
	#Data Group 1
	#energy
	echo "6 0.01 0.5 0.5 9.0 9.0" >> contour.txt
	#width
	echo "0.1,-1" >> contour.txt
	#normalization
	echo "0.002,-1" >> contour.txt
	# Add a Gaussian absorption line (any energy)
	echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> contour.txt

	#Data Group 2
	#energy
	echo " " >> contour.txt
	#width
	echo " " >> contour.txt
	#normalization
	echo " " >> contour.txt
	# Add a Gaussian absorption line (any energy)
	echo " " >> contour.txt
	
	echo "fit" >> contour.txt
	echo "step 5 5.0 9.0 20" >> contour.txt
	echo "step 13 5.0 9.0 20" >> contour.txt
	# echo "steppar log" >> contour.txt
	echo "thaw 6" >> contour.txt
	echo "thaw 14" >> contour.txt

	echo "fit" >> contour.txt
	#fix the plot.

	echo "plot contour" >> contour.txt

	echo "setplot command wdata wdata.dat" >> contour.txt
	echo "plot contour" >> contour.txt
	echo "mv wdata.dat mosfit_contour_tbabscutoffpl+zgauss.dat" >> contour.txt
	echo "log none" >> contour.txt
	#save the plot
	# echo "save all fit_contour.xcm" >> contour.txt
	echo "exit" >> contour.txt

	#launch XSPEC
	xspec - contour.txt
						
	#FLUX

	echo "query yes" > flux.txt
	echo "statistic chi" >> flux.txt
	echo "cpd /null" >> flux.txt
	echo "data none" >> flux.txt
	echo "model none" >> flux.txt

	#Load the data and restrict energy range

	echo "log flux.log" >> flux.txt
	echo "data 1:1 ${m1data} 2:2 ${m2data}" >> flux.txt
	echo "back 1:1 ${m1bgfile} 2:2 ${m2bgfile}" >> flux.txt
	echo "resp 1:1 ${m1resp} 2:2 ${m2resp}" >> flux.txt
	echo "arf 1:1 ${m1_arf} 2:2 ${m2arf}" >> flux.txt
	echo "ignore **-2.0 10.0-**" >> flux.txt #changed range to 2 keV from 0.2 keV
	echo "ignore bad" >> flux.txt


	# Define the model
	#Data Group 1
	echo "model tbabs*cutoffpl" >> flux.txt
	echo "1.0,0.1" >> flux.txt
	echo "2, 0.01" >> flux.txt
	echo "15, 0.01" >> flux.txt
	echo "1.E-4 1E-5" >> flux.txt

	#Data Group 2
	echo "model tbabs*cutoffpl" >> flux.txt
	echo " " >> flux.txt
	echo " " >> flux.txt
	echo " " >> flux.txt
	echo " " >> flux.txt
	#Fit the model
	echo "fit" >> flux.txt

	# Save the best-fit model
	# echo "save all fit_flux_tbabscutoffpl.xcm" >> flux.txt
	echo "setplot energy" >> flux.txt
	echo "setplot rebin 3 10" >> flux.txt

	# Write out the spectrum to a file (for plotting later)
	echo "plot ldata" >> flux.txt
	echo "setplot command wdata wdata.dat" >> flux.txt
	echo "plot ldata" >> flux.txt
	echo "mv wdata.dat mosfit_flux_tbabscutoffpl_ld.dat" >> flux.txt


	echo "log none" >> flux.txt
	echo "exit" >> flux.txt

	xspec - flux.txt

	#DELTA CHI 
	echo "query yes" > delta_chi.txt
	echo "statistic chi" >> delta_chi.txt
	echo "cpd /null" >> delta_chi.txt
	echo "data none" >> delta_chi.txt
	echo "model none" >> delta_chi.txt

	#Load the data and restrict energy range

	echo "log delta_chi.log" >> delta_chi.txt
	echo "data 1:1 ${m1data} 2:2 ${m2data}" >> delta_chi.txt
	echo "back 1:1 ${m1bgfile} 2:2 ${m2bgfile}" >> delta_chi.txt
	echo "resp 1:1 ${m1resp} 2:2 ${m2resp}" >> delta_chi.txt
	echo "arf 1:1 ${m1_arf} 2:2 ${m2arf}" >> delta_chi.txt
	echo "ignore **-2.0 10.0-**" >> delta_chi.txt #changed range to 2 keV from 0.2 keV
	echo "ignore bad" >> delta_chi.txt

	# Define the model
	#Data Group 1
	echo "model tbabs*cutoffpl" >> delta_chi.txt
	echo "1.0,0.1" >> delta_chi.txt
	echo "2, 0.01" >> delta_chi.txt
	echo "15, 0.01" >> delta_chi.txt
	echo "1.E-4 1E-5" >> delta_chi.txt
	#Data Group 2
	echo " " >> delta_chi.txt
	echo " " >> delta_chi.txt
	echo " " >> delta_chi.txt
	echo " " >> delta_chi.txt

	echo "fit" >> delta_chi.txt

	# Save the best-fit model
	# echo "save all fit_delchi_tbabscutoffpl.xcm" >> delta_chi.txt
	echo "setplot energy" >> delta_chi.txt
	echo "setplot rebin 3 10" >> delta_chi.txt

	# Plot delta-chi and write out to a file
	echo "plot delchi" >> delta_chi.txt
	echo "setplot command wdata wdata.dat" >> delta_chi.txt
	echo "plot delchi" >> delta_chi.txt
	echo "mv wdata.dat mosfit_deltachi_tbabscutoffpl_delc.dat" >> delta_chi.txt

	echo "log none" >> delta_chi.txt
	echo "exit" >> delta_chi.txt

	xspec - delta_chi.txt

