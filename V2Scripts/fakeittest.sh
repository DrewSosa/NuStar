#!/bin/bash 

# The fakeit command is used to create a number of spectrum files,
# where the current model is multiplied by the response curves and then added to a realization of any background.
# Statistical fluctuations can be included. The integration time and correction norm are requested for each file. 
# The file names input as command line arguments are used as background. The number of faked spectra produced is the maximum of the number of spectra currently 
# loaded and the number of file specifications in the command line arguments. 



#Get Obs_iD to perform simulations on.
read -p "Observation ID: " obs_id
read -p "Source " source
#Place to store results.
RESULTS="/Users/Anne/Documents/Caltech/M32/sim/${obs_id}/6kev"

# if (-e $RESULTS) rm $RESULTS
# touch $RESULTS

#Number of Simulations.
numsims=10


for ((i=1;i<=$numsims;i++)); do


		cd
		cd Documents/Caltech/ReducedDec/$source/${obs_id}/ULX
		mkdir sim
		RESULTS="/Users/Anne/Documents/Caltech/ReducedDec/$source/$obs_id/ULX/sim/8keV"
	   	
		#load only the XCM file to get datax
		echo "query yes" > sim.xco
		echo "statistic chi" >> sim.xco
		echo "cpd /null" >> sim.xco
		echo "data none" >> sim.xco
		echo "model none" >> sim.xco
		echo "energies reset" >> sim.xco
		echo "@fit_tbabscutoffpl.xcm" >> sim.xco
		echo "fakeit" >> sim.xco
		echo "y" >> sim.xco
		echo " " >> sim.xco
		echo "sim_tbabscutoffpl.fak" >> sim.xco
		#set default value for exposure tie
		echo "40000" >> sim.xco
		echo " " >> sim.xco
		
		#Only include valid energies for XMM

		#for chandra, do **-0.5-8kev---
		# echo "ignore **-0.2 10.-**" >> sim.xco
		echo "ignore **-0.5 8.-**" >> sim.xco
		echo "fit" >> sim.xco
		echo "log fit_tbabscutoffpl_fak.log" >> sim.xco
		echo "show all" >> sim.xco
		echo "log none" >> sim.xco
		echo "addc 3 zgauss" >> sim.xco
	#	echo "1 0.01 0.5 0.5 8.0 8.0" >> sim.xco
		echo "3.3 0.01 2.5 2.5 10.0 10.0" >> sim.xco
	#	echo "0.01,-1" >> sim.xco
		echo "0.1,-1" >> sim.xco
		echo "0.002,-1" >> sim.xco
		echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> sim.xco
		echo "fit" >> sim.xco
		echo "log fit_tbabscutoffpl+zgauss_fak.log" >> sim.xco
		echo "show all" >> sim.xco
		echo "log none" >> sim.xco
	   	echo "exit" >> sim.xco	

		rm *fak*
		xspec - sim.xco	

			#Get the two Chi-Squared values and find their difference. 

	        chisq0=$(awk '/Fit statistic : Chi-Squared/ {chisq=$6}; END {print chisq}' fit_tbabscutoffpl_fak.log)
	        chisq1=$(awk '/Fit statistic : Chi-Squared/ {chisq=$6}; END {print chisq}' fit_tbabscutoffpl+zgauss_fak.log)
	        delc=$(bc <<< "${chisq0}-${chisq1}")

	        #Write the results to the results file declared earlier.

	        echo $i  $chisq0  $chisq1  $delc  >> $RESULTS


		
done

