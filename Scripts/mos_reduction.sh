#!/bin/bash


export SAS_DIR=/Users/Anne/Documents/Caltech/SAS/xmmsas_20180620_1732
export SAS_ODF=/Users/Anne/Documents/Caltech/xmmdata/obs_id/odf/
export SAS_CCFPATH=/Users/Anne/Caltech/Documents/ccf/

echo cifbuild

export SAS_CCF=/Users/Anne/Documents/Caltech/obs_id/ccf.cif

odfingest

export SAS_ODF=/Users/Anne/Documents/Caltech/xmmdata/obs_id/odf/3391_0830191601_SCX00000SUM.SAS


mkdir ULX
cd ULX


mv P0112520701M1S001MIEVLI0000.FTZ ./m1.fits
mv P0112520701M2S002MIEVLI0000.FTZ ./m2.fits

evselect table=m1.fits withfilteredset=yes expression='(PATTERN == 0)&&(PI in [10000:12000])&&#XMMEA_EP' filteredset=m1_pat0_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_pat0_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes

fv m1_pat0_en10-12_ltcrv.fits


tabgtigen table=m1_pat0_en10-12_ltcrv.fits expression='RATE<=0.4' gtiset=lowbg_gti.fits


#spectrum
evselect table='m1.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(26667,27765,600))' filteredset=m1_pat0_en0.2-10_src_30.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_pat0_en0.2-10_src_30_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m1_pat0_src_30_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

#background
evselect table='m1.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(27768,24383,2389))' filteredset=m1_pat0_en0.2-10_bgd2.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m1_pat0_en0.2-10_bgd2_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m1_pat0_bgd2_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

#backscale
backscale spectrumset='m1_pat0_src_30_pi.fits'
backscale spectrumset='m1_pat0_bgd2_pi.fits'

#rmf
rmfgen rmfset=m1_pat0_src_30.rmf spectrumset='m1_pat0_src_30_pi.fits'

#arf
arfgen arfset=m1_pat0_src_30.arf spectrumset='m1_pat0_src_30_pi.fits' withrmfset=yes rmfset=m1_pat0_src_30.rmf

#group the spectrum 
grppha m1_pat0_src_30_pi.fits m1_pat0_src_30_pi_20.fits "group min 20" exit
grppha m1_pat0_src_30_pi.fits m1_pat0_src_30_pi_1.fits "group min 1" exit

evselect table=m2.fits withfilteredset=yes expression='(PATTERN == 0)&&(PI in [10000:12000])&&#XMMEA_EP' filteredset=m2_pat0_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_pat0_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes

fv m2_pat0_en10-12_ltcrv.fits


tabgtigen table=m2_pat0_en10-12_ltcrv.fits expression='RATE<=0.4' gtiset=lowbg_gti.fits


#spectrum
evselect table='m2.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(26667,27765,600))' filteredset=m2_pat0_en0.2-10_src_30.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_pat0_en0.2-10_src_30_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m2_pat0_src_30_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

#background
evselect table='m2.fits' withfilteredset=yes expression='(PATTERN ==0)&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE(27768,24383,2389))' filteredset=m2_pat0_en0.2-10_bgd2.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=m2_pat0_en0.2-10_bgd2_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='m2_pat0_bgd2_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

#backscale
backscale spectrumset='m2_pat0_src_30_pi.fits'
backscale spectrumset='m2_pat0_bgd2_pi.fits'

#rmf
rmfgen rmfset=m2_pat0_src_30.rmf spectrumset='m2_pat0_src_30_pi.fits'

#arf
arfgen arfset=m2_pat0_src_30.arf spectrumset='m2_pat0_src_30_pi.fits' withrmfset=yes rmfset=m2_pat0_src_30.rmf

#group the spectrum 
grppha m2_pat0_src_30_pi.fits m2_pat0_src_30_pi_20.fits "group min 20" exit
grppha m2_pat0_src_30_pi.fits m2_pat0_src_30_pi_1.fits "group min 1" exit
