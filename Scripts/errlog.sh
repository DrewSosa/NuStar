	#!/bin/bash


	echo "cd" >> errorlog.xco
	echo "cd Documents/Caltech/0206890101/ULX" >> errorlog.xco
	echo "@fit_0_60_3-01_2.xcm" >> errorlog.xco
	echo "fit" >> errorlog.xco

	echo "query yes" >! errorlog.xco
	echo "statistic chi" >> errorlog.xco
	echo "cpd /null" >> errorlog.xco
	echo "data none" >> errorlog.xco
	echo "@fit_0_60_3-01_2.xcm" >> errorlog.xco
	echo "fit" >> errorlog.xco
	echo "log errorlog.log" >> errorlog.xco
	#Estimate the 90% ranges for parameters 5 and 6
	echo "err 2.71 5" >> errorlog.xco
	echo "err 2.71 6" >> errorlog.xco
	echo "show all" >> errorlog.xco
	echo "log none" >> errorlog.xco
	
	echo "exit" >> errorlog.xco

	#launch XSPEC
	xspec - errorlog.xco

	 # chisq0=$(awk '/Fit statistic : Chi-Squared/ {chisq=$6}; END {print chisq}' cutoffpl.log`)
	 # dof0=$(awk '/degrees of freedom/ {dof=$7}; END {print dof}' cutoffpl.log`)
	 # znh0=$(awk '/zTBabs     nH/ {znh=$7}; END {print znh}' cutoffpl.log`)
	 # znh0_err1=$(awk '/#     2  / {err=$3}; END {print err}' cutoffpl.log`)
	 # znh0_err2=$(awk '/#     2  / {err=$4}; END {print err}' cutoffpl.log`)
	 # gamma0=$(awk '/cutoffpl   PhoIndex/ {gam=$6}; END {print gam}' cutoffpl.log`)
	 # gamma0_err1=$(awk '/#     4  / {err=$3}; END {print err}' cutoffpl.log`)
	 # gamma0_err2=$(awk '/#     4  / {err=$4}; END {print err}' cutoffpl.log`)
	 # cut0=$(awk '/cutoffpl   HighECut/ {cut=$7}; END {print cut}' cutoffpl.log`)
	 # cut0_err1=$(awk '/#     5  / {err=$3}; END {print err}' cutoffpl.log`)
	 # cut0_err2=$(awk '/#     5  / {err=$4}; END {print err}' cutoffpl.log`)
	 
	 # flux0=$(awk '/cflux      lg10Flux/ {flux=$7}; END {print flux}' cutoffpl_flux.log`)
	 # flux0_err1=$(awk '/#     6  / {err=$3}; END {print err}' cutoffpl_flux.log`)
	 # flux0_err2=$(awk '/#     6  / {err=$4}; END {print err}' cutoffpl_flux.log`)
