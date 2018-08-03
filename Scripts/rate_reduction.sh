#!/bin/bash

cd 
cd Documents/Caltech/0112520701

export SAS_DIR=/Users/Anne/Documents/Caltech/SAS/xmmsas_20180620_1732/
export SAS_ODF=/Users/Anne/Documents/Caltech/0112520701/
export SAS_CCFPATH=/Users/Anne/Documents/Caltech/CCFs/

cifbuild

export SAS_CCF=/Users/Anne/Documents/Caltech/0112520701/ccf.cif

# odfingest

# export SAS_ODF=/Users/Anne/Documents/Caltech/xmmdata/0672130701/odf/3391_0830191301_SCX00000SUM.SAS


mkdir ULX
cd ULX

ls pps/*PIEVLI*
mv pps/P0200470101PNS003PIEVLI0000.FTZ ./pn.fits


evselect table=pn.fits withfilteredset=yes expression='(PATTERN <= 4)&&(PI in [10000:12000])&&#XMMEA_EP' filteredset=pn_pat${pattern}_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat${pattern}_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes
### Check for flaring background by creating a lightcurve in the 10-12 keV band

#fv pn_pat${pattern}_en10-12_ltcrv.fits
radii=("30" "40"  "50"  "60")
patterns=("${pattern}" "0")
rates=("0.7" "3" "7" "10" )
for pattern in ${patterns[@]}; do
	for radius in ${radii[@]}; do
		for rate in ${rates[@]}; do
			detector_radius=$(expr $rate \* 200)
			evselect table=pn.fits withfilteredset=yes expression='(PATTERN <= 4)&&(PI in [10000:12000])&&#XMMEA_EP' filteredset=pn_pat${pattern}_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat${pattern}_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes

			tabgtigen table=pn_pat${pattern}_en10-12_ltcrv.fits expression='RATE<=${rate}' gtiset=lowbg_gti.fits

			#DS9!!!!


			#spectrum
			evselect table='pn.fits' withfilteredset=yes expression='(PATTERN<=${pattern})&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(26667,27766,${detector_radius}))' filteredset=pn_pat${pattern}_en0.2-10_src_${radius}.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat${pattern}_en0.2-10_src_${radius}_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='pn_pat${pattern}_src_${radius}_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

			#background
			evselect table='pn.fits' withfilteredset=yes expression='(PATTERN<=${pattern})&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(28138,23487,2099))' filteredset=pn_pat${pattern}_en0.2-10_bgd2.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat${pattern}_en0.2-10_bgd2_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='pn_pat${pattern}_bgd2_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

			#backscale
			backscale spectrumset='pn_pat${pattern}_src_${radius}_pi.fits'
			backscale spectrumset='pn_pat${pattern}_bgd2_pi.fits'

			#rmf
			rmfgen rmfset=pn_pat${pattern}_src_${radius}.rmf spectrumset='pn_pat${pattern}_src_${radius}_pi.fits'

			#arf
			arfgen arfset=pn_pat${pattern}_src_${radius}.arf spectrumset='pn_pat${pattern}_src_${radius}_pi.fits' withrmfset=yes rmfset=pn_pat${pattern}_src_${radius}.rmf

			#group the spectrum 
			grppha pn_pat${pattern}_src_${radius}_pi.fits pn_pat${pattern}_src_${radius}_pi_20.fits "group min 20" exit
			grppha pn_pat${pattern}_src_${radius}_pi.fits pn_pat${pattern}_src_${radius}_pi_1.fits "group min 1" exit
		done
	done
done

			#awk command --> log show all, get the chi-squared statisti, do int () type ... vary the pattern, and radius and rate, just test 0.1 width. 
