#!/bin/bash
	#specific
	read -p "Observation ID: " obs_id

	#Change into the correct directory.
	cd
	cd Documents/Caltech/${obs_id}/ULX

	

	#Lists that allow for easy variation of parameters
 	radii=("60")
 	energies=("6.15")
 	widths=("0.1")
 	patterns=("0")
 	rates=("2")
 	ids=("0672130101" "0672130701" "M32_Chandra" "0505760201" "0672130501")


 	

	#Iterate through different combinations of parameters.
	for pattern in ${patterns[@]}; do
		for radius in ${radii[@]}; do
			for energy in ${energies[@]}; do
				for width in ${widths[@]}; do
					for rate in ${rates[@]}; do


					#To avoid periods in the files.
					

						#Clean documentation files.
						
						

						# Look for files that correspond to the given parameters ands assign them to a variable.
						datafile="$(ls | grep "pat${pattern}_" | grep "$radius" | grep "${rate//.}_"| grep "20.fits")"
						respdata="$(ls | grep "pat${pattern}_${radius}_${rate//.}.rmf")"
						arf="$(ls | grep "pat${pattern}_${radius}_${rate//.}.arf")"
						bgfile="$(ls | grep "bgd2_pat${pattern}_${radius}_${rate//.}_pi.fits")"
					
						# datafile="ULX1_grp.pi"
						# respdata="ULX1.rmf"
						# arf="ULX1.corr.arf"
						# bgfile="ULX1_bkg.pi"


						echo "query yes" > contour.txt

						#Put in the correct files and output them to a parameter specific XSPEC file.
						echo "data $datafile" >> contour.txt
						echo "back $bgfile" >> contour.txt
						echo "resp $respdata" >> contour.txt
						echo "arf $arf" >> contour.txt
						echo "ignore **-2.0 10.0-**" >> contour.txt
						echo "ignore bad" >> contour.txt


						echo "log contour.log" >> contour.txt
						# Define the model
						echo "model tbabs*cutoffpl" >> contour.txt
						#Absoprtion
						echo "1 , 0.1" >> contour.txt
						#powerlaw index/gamma
						echo "2, 0.01" >> contour.txt
						#Cuttoff energy
						echo "15, 0.01" >> contour.txt
						#Normalization
						echo "1.E-4 1E-5" >> contour.txt
						echo "fit" >> contour.txt

						# echo "save all fit_contour_tbabscutoffpl.xcm" >> contour.txt
						echo "setplot energy" >> contour.txt
						echo "setplot rebin 3 10" >> contour.txt


						#echo "hardcopy plot_${radius}_${pattern} color" >> contour.txt
						echo "addc 3 zgauss" >> contour.txt
						#energy
						echo "$energy 0.01 0.5 0.5 9.0 9.0" >> contour.txt
						#width
						echo "$width,-1" >> contour.txt
						#normalization
						echo "0.002,-1" >> contour.txt

						# Add a Gaussian absorption line (any energy)
						echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> contour.txt
						echo "fit" >> contour.txt
						echo "step 5 5.0 9.0 20" >> contour.txt
						# echo "steppar log" >> contour.txt
						echo "thaw 6" >> contour.txt
						echo "fit" >> contour.txt
						#fix the plot.
				
						echo "plot contour" >> contour.txt
					
						echo "setplot command wdata wdata.dat" >> contour.txt
					    echo "plot contour" >> contour.txt
						echo "mv wdata.dat fit_contour_tbabscutoffpl+zgauss.dat" >> contour.txt
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
						echo "data $datafile" >> flux.txt
						echo "back $bgfile" >> flux.txt
						echo "resp $respdata" >> flux.txt
						echo "arf $arf" >> flux.txt
						echo "ignore **-2.0 10.0-**" >> flux.txt #changed range to 2 keV from 0.2 keV
						echo "ignore bad" >> flux.txt


					    # Define the model
						echo "model tbabs*cutoffpl" >> flux.txt
						echo "1.0,0.1" >> flux.txt
						echo "2, 0.01" >> flux.txt
						echo "15, 0.01" >> flux.txt
						echo "1.E-4 1E-5" >> flux.txt
						echo "fit" >> flux.txt

					    # Save the best-fit model
					    # echo "save all fit_flux_tbabscutoffpl.xcm" >> flux.txt
						echo "setplot energy" >> flux.txt
						echo "setplot rebin 3 10" >> flux.txt

					    # Write out the spectrum to a file (for plotting later)
					    echo "plot ldata" >> flux.txt
					  	echo "setplot command wdata wdata.dat" >> flux.txt
					    echo "plot ldata" >> flux.txt
						echo "mv wdata.dat fit_flux_tbabscutoffpl_ld.dat" >> flux.txt


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
						echo "data $datafile" >> delta_chi.txt
						echo "back $bgfile" >> delta_chi.txt
						echo "resp $respdata" >> delta_chi.txt
						echo "arf $arf" >> delta_chi.txt
						echo "ignore **-2.0 10.0-**" >> delta_chi.txt #changed range to 2 keV from 0.2 keV
						echo "ignore bad" >> delta_chi.txt

					    # Define the model
						echo "model tbabs*cutoffpl" >> delta_chi.txt
						echo "1.0,0.1" >> delta_chi.txt
						echo "2, 0.01" >> delta_chi.txt
						echo "15, 0.01" >> delta_chi.txt
						echo "1.E-4 1E-5" >> delta_chi.txt
						echo "fit" >> delta_chi.txt

					    # Save the best-fit model
					    # echo "save all fit_delchi_tbabscutoffpl.xcm" >> delta_chi.txt
						echo "setplot energy" >> delta_chi.txt
						echo "setplot rebin 3 10" >> delta_chi.txt

						# Plot delta-chi and write out to a file
					    echo "plot delchi" >> delta_chi.txt
					    echo "setplot command wdata wdata.dat" >> delta_chi.txt
					    echo "plot delchi" >> delta_chi.txt
						echo "mv wdata.dat fit_deltachi_tbabscutoffpl_delc.dat" >> delta_chi.txt

					    echo "log none" >> delta_chi.txt
						echo "exit" >> delta_chi.txt

						xspec - delta_chi.txt

					done
					
				done
				
			done
		done
	done
#thaw 6" / "error 6" "rerun0 40 5.75 0.1, get plot"
