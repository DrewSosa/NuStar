#!/bin/bash

cd
cd Documents/Caltech/0672130101

export SAS_DIR=/Users/Anne/Documents/Caltech/SAS/xmmsas_20180620_1732/
export SAS_ODF=/Users/Anne/Documents/Caltech/0672130101/
export SAS_CCFPATH=/Users/Anne/Documents/Caltech/CCFs/

#Build the CCF file
cifbuild

export SAS_CCF=/Users/Anne/Documents/Caltech/0672130101/ccf.cif

# mkdir ULX
cd ULX

# mv pps/P0672130101M1S001MIEVLI0000.FTZ ./m1.fits
# mv pps/P0672130101M2S003MIEVLI0000.FTZ ./m2.fits

# read -p "Files are generally ordered such that [pattern -> radius-> rate//.].fits Press enter to continue" warning
# read -p "WARNING! Correct Observation and Detector coordinates (via DS9) must appear in script before running the automated script! Press enter to continue" warning


#List of parameters that we want to vary.
radii=("40" "50" "60")
patterns=("12")
rates=("0.4")

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

			#Vary M1 Parameters

			#Calculate the detector radius. ****** MAKE SURE THIS WORKS
			detector_radius=$(expr $radius \* 20)

			#I usually don't automate the line below, but we don't necessarily care about the light curve in this script.
			evselect table=m1.fits withfilteredset=yes expression='(PATTERN <= '"${patnumber}"')&&(PI>10000)&&#XMMEA_EM' filteredset=m1_en10-12_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_ltcrv_en10-12_pat${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes


			# For further detail, the syntax of the below $rate variable is ${string//substring/replacement},
			# where apparently the lack of the final forward slash and replacement string are interpreted as delete.
			tabgtigen table=m1_ltcrv_en10-12_pat${pattern}_${radius}_${rate//.}.fits expression='RATE<='"${rate}"'' gtiset=lowbg_gti.fits

			

			#spectrum
			evselect table='m1.fits' withfilteredset=yes expression='(PATTERN<='"${patnumber}"')&&(PI in [200:10000])&& #XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(24125,24618,'"${detector_radius}"'))' filteredset=m1_src_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_src_ltcrv_en0.2-10_${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m1_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999

			#background
			evselect table='m1.fits' withfilteredset=yes expression='(PATTERN<='"${patnumber}"')&&(PI in [200:10000])&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(20821,27105,2092))' filteredset=m1_bgd2_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_src_bgd2_ltcrv_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m1_bgd2_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999

			#backscale
			backscale spectrumset='m1_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'
			backscale spectrumset='m1_bgd2_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'

			#rmf
			rmfgen rmfset=m1_src_pat${pattern}_${radius}_${rate//.}.rmf spectrumset='m1_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'

			#arf
			arfgen arfset=m1_src_pat${pattern}_${radius}_${rate//.}.arf spectrumset='m1_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' withrmfset=yes rmfset=m1_src_pat${pattern}_${radius}_${rate//.}.rmf

			#check if grouped spectrum exists. If not, group the spectrum!
			if [ ! -f m1_src_pat${pattern}_${radius}_${rate//.}_pi_20.fits ] || [! -f m1_src_pat${pattern}_${radius}_${rate//.}_pi_1.fits] ; then
				grppha m1_src_pat${pattern}_${radius}_${rate//.}_pi.fits m1_src_pat${pattern}_${radius}_${rate//.}_pi_20.fits "group min 20" exit
				grppha m1_src_pat${pattern}_${radius}_${rate//.}_pi.fits m1_src_pat${pattern}_${radius}_${rate//.}_pi_1.fits "group min 1" exit
    			
			fi

			#Vary M2 Detector parameters

			#Calculate the detector radius. ****** MAKE SURE THIS WORKS
			detector_radius=$(expr $radius \* 20)

			#I usually don't automate the line below, but we don't necessarily care about the light curve in this script.
			evselect table=m2.fits withfilteredset=yes expression='(PATTERN <= '"${patnumber}"')&&(PI>10000)&&#XMMEA_EM' filteredset=m2_en10-12_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_ltcrv_en10-12_pat${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes


			# For further detail, the syntax of the below $rate variable is ${string//substring/replacement},
			# where apparently the lack of the final forward slash and replacement string are interpreted as delete.
			tabgtigen table=m2_ltcrv_en10-12_pat${pattern}_${radius}_${rate//.}.fits expression='RATE<='"${rate}"'' gtiset=lowbg_gti.fits

			

			#spectrum
			evselect table='m2.fits' withfilteredset=yes expression='(PATTERN<='"${patnumber}"')&&(PI in [200:10000])&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(24124,24618,'"${detector_radius}"'))' filteredset=m2_src_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_src_ltcrv_en0.2-10_${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m2_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999

			#background
			evselect table='m2.fits' withfilteredset=yes expression='(PATTERN<='"${patnumber}"')&&(PI in [200:10000])&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(20821,27105,2092))' filteredset=m2_bgd2_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_src_bgd2_ltcrv_en0.2-10_pat${pattern}_${radius}_${rate//.}.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m2_bgd2_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999

			#backscale
			backscale spectrumset='m2_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'
			backscale spectrumset='m2_bgd2_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'

			#rmf
			rmfgen rmfset=m2_src_pat${pattern}_${radius}_${rate//.}.rmf spectrumset='m2_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits'

			#arf
			arfgen arfset=m2_src_pat${pattern}_${radius}_${rate//.}.arf spectrumset='m2_src_pat'"${pattern}"'_'"${radius}"'_'"${rate//.}"'_pi.fits' withrmfset=yes rmfset=m2_src_pat${pattern}_${radius}_${rate//.}.rmf

			#check if grouped spectrum exists. If not, group the spectrum!
			if [ ! -f m2_src_pat${pattern}_${radius}_${rate//.}_pi_20.fits ] || [! -f m2_src_pat${pattern}_${radius}_${rate//.}_pi_1.fits] ; then
				grppha m2_src_pat${pattern}_${radius}_${rate//.}_pi.fits m2_src_pat${pattern}_${radius}_${rate//.}_pi_20.fits "group min 20" exit
				grppha m2_src_pat${pattern}_${radius}_${rate//.}_pi.fits m2_src_pat${pattern}_${radius}_${rate//.}_pi_1.fits "group min 1" exit
    			
			fi

		done
	done
done


# evselect table=m1.fits withfilteredset=yes expression='(PATTERN == 0)&&(PI in [10000:12000])&&#XMMEA_EM' filteredset=m1_pat0_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_pat0_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes

# fv m1_pat0_en10-12_ltcrv.fits


# tabgtigen table=m1_pat0_en10-12_ltcrv.fits expression='RATE<=0.4' gtiset=lowbg_gti.fits


# #spectrum
# evselect table='m1.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI>10000)&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(26667,27765,600))' filteredset=m1_pat0_en0.2-10_src_30.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_pat0_en0.2-10_src_30_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m1_pat0_src_30_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

# #background
# evselect table='m1.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI>10000)&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(27768,24383,2389))' filteredset=m1_pat0_en0.2-10_bgd2.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_pat0_en0.2-10_bgd2_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m1_pat0_bgd2_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

# #backscale
# backscale spectrumset='m1_pat0_src_30_pi.fits'
# backscale spectrumset='m1_pat0_bgd2_pi.fits'

# #rmf
# rmfgen rmfset=m1_pat0_src_30.rmf spectrumset='m1_pat0_src_30_pi.fits'

# #arf
# arfgen arfset=m1_pat0_src_30.arf spectrumset='m1_pat0_src_30_pi.fits' withrmfset=yes rmfset=m1_pat0_src_30.rmf

# #group the spectrum 
# grppha m1_pat0_src_30_pi.fits m1_pat0_src_30_pi_20.fits "group min 20" exit
# grppha m1_pat0_src_30_pi.fits m1_pat0_src_30_pi_1.fits "group min 1" exit

# evselect table=m2.fits withfilteredset=yes expression='(PATTERN == 0)&&(PI in [10000:12000])&&#XMMEA_EM' filteredset=m2_pat0_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_pat0_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes

# fv m2_pat0_en10-12_ltcrv.fits


# tabgtigen table=m2_pat0_en10-12_ltcrv.fits expression='RATE<=0.4' gtiset=lowbg_gti.fits


# #spectrum
# evselect table='m2.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI>10000)&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(26667,27765,600))' filteredset=m2_pat0_en0.2-10_src_30.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_pat0_en0.2-10_src_30_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m2_pat0_src_30_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

# #background
# evselect table='m2.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI>10000)&&#XMMEA_EM&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(27768,24383,2389))' filteredset=m2_pat0_en0.2-10_bgd2.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_pat0_en0.2-10_bgd2_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m2_pat0_bgd2_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

# #backscale
# backscale spectrumset='m2_pat0_src_30_pi.fits'
# backscale spectrumset='m2_pat0_bgd2_pi.fits'

# #rmf
# rmfgen rmfset=m2_pat0_src_30.rmf spectrumset='m2_pat0_src_30_pi.fits'

# #arf
# arfgen arfset=m2_pat0_src_30.arf spectrumset='m2_pat0_src_30_pi.fits' withrmfset=yes rmfset=m2_pat0_src_30.rmf

# #group the spectrum 
# grppha m2_pat0_src_30_pi.fits m2_pat0_src_30_pi_20.fits "group min 20" exit
# grppha m2_pat0_src_30_pi.fits m2_pat0_src_30_pi_1.fits "group min 1" exit



