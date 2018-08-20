#!/bin/bash
#Manual parts. You have to enter these in. They depend on what source you are looking at.

#works in conjunction with log_chi_spec.sh
#Change into the correct directory.
cd
cd Documents/Caltech/0206890401

export SAS_DIR=/Users/Anne/Documents/Caltech/SAS/xmmsas_20180620_1732/
export SAS_ODF=/Users/Anne/Documents/Caltech/0206890401/
export SAS_CCFPATH=/Users/Anne/Documents/Caltech/CCFs/

#Build the CCF file
cifbuild

export SAS_CCF=/Users/Anne/Documents/Caltech/0206890401/ccf.cif

#No need for odfingest if the pps files exist already? I don't know. - Andrew.
# odfingest

# export SAS_ODF=/Users/Anne/Documents/Caltech/xmmdata/0672130701/odf/3391_0830191301_SCX00000SUM.SAS

#Make the ULX folder. Up to the user to decide where the working directory is.
# mkdir ULX

cd ULX
# ls pps/*PIEVLI*
# mv pps/P0505760201PNS003PIEVLI0000.FTZ ./pn.fits


### Check for flaring background by creating a lightcurve in the 10-12 keV band
#fv pn_ltcrv_en10-12_pat${pattern}__${radius}_${rate//.}.fits

#Automated part starts here
read -p "Files are generally ordered such that [pattern -> radius-> rate//.].fits Press enter to continue" warning
read -p "WARNING! Correct Observation and Detector coordinates (via DS9) must appear in script before running the automated script! Press enter to continue" warning


#List of parameters that we want to vary.
radii=("40" "50" "60")
patterns=("0")
rates=("10")
#For loop for combinations of varied parameters.
for pattern in ${patterns[@]}; do
	if [ $pattern="0" ]
	then
		patnumber="0"
	fi
	if [ $pattern="0-4" ]
	then
		patnumber="4"
		
		
	fi
	for radius in ${radii[@]}; do
		for rate in ${rates[@]}; do


			#Calculate the detector radius. ****** MAKE SURE THIS WORKS
			detector_radius=$(expr $radius \* 20)

			#I usually don't automate the line below, but we don't necessarily care about the light curve in this script.
			evselect table=pn.fits withfilteredset=yes expression='(PATTERN <= '"${patnumber}"')&&(PI in [10000:12000])&&#XMMEA_EP' filteredset=pn_en10-12_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_ltcrv_en10-12_pat${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes


			# For further detail, the syntax of the below $rate variable is ${string//substring/replacement},
			# where apparently the lack of the final forward slash and replacement string are interpreted as delete.
			tabgtigen table=pn_ltcrv_en10-12_pat${pattern}_${radius}_${rate//.}.fits expression='RATE<='"${rate}"'' gtiset=lowbg_gti.fits

			

			#spectrum
			evselect table='pn.fits' withfilteredset=yes expression='(PATTERN<='"${patnumber}"')&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(28369,23708,'"${detector_radius}"'))' filteredset=pn_src_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_src_ltcrv_en0.2-10_${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='pn_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

			#background
			evselect table='pn.fits' withfilteredset=yes expression='(PATTERN<='"${patnumber}"')&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(26002,21973,1565))' filteredset=pn_bgd2_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_src_bgd2_ltcrv_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='pn_bgd2_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

			#backscale
			backscale spectrumset='pn_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'
			backscale spectrumset='pn_bgd2_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'

			#rmf
			rmfgen rmfset=pn_src_pat${pattern}_${radius}_${rate//.}.rmf spectrumset='pn_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'

			#arf
			arfgen arfset=pn_src_pat${pattern}_${radius}_${rate//.}.arf spectrumset='pn_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' withrmfset=yes rmfset=pn_src_pat${pattern}_${radius}_${rate//.}.rmf

			#check if grouped spectrum exists. If not, group the spectrum!
			if [ ! -f pn_src_pat${pattern}_${radius}_${rate//.}_pi_20.fits ] || [! -f pn_src_pat${pattern}_${radius}_${rate//.}_pi_1.fits] ; then
				grppha pn_src_pat${pattern}_${radius}_${rate//.}_pi.fits pn_src_pat${pattern}_${radius}_${rate//.}_pi_20.fits "group min 20" exit
				grppha pn_src_pat${pattern}_${radius}_${rate//.}_pi.fits pn_src_pat${pattern}_${radius}_${rate//.}_pi_1.fits "group min 1" exit
    			
			fi

		done
	done
done

