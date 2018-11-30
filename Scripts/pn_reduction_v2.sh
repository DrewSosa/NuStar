#!/bin/bash

#Andrew Sosanya, @andrew.sosanya.20@dartmouth.edu , NuStar WAVE Research Fellow
cd /Users/Anne/Documents/Caltech/ReducedDec/

for folder in *; do
    cd 
    cd /Users/Anne/Documents/Caltech/ReducedDec/$folder/
    for id in *; do 
        echo $folder, $id

        cd
        cd Documents/Caltech/ReducedDec/${folder}/${id}

        export SAS_DIR=/Users/Anne/Documents/Caltech/SAS/xmmsas_20180620_1732/
        export SAS_ODF=/Users/Anne/Documents/Caltech/ReducedDec/${folder}/${id}/
        export SAS_CCFPATH=/Users/Anne/Documents/Caltech/CCFs/

        cifbuild

        export SAS_CCF=/Users/Anne/Documents/Caltech/ReducedDec/${folder}/${id}/ccf.cif

#only do if you don't have PPS files.
    # odfingest
    # export SAS_ODF=/Users/Anne/Documents/Caltech/xmmdata/0672130701/odf/3391_0830191301_SCX00000SUM.SAS

#Change directory
        tar -zxvf *.TAR
        mkdir ULX
        cd ULX

# ls pps/*PIEVLI*
# mv pps/P0200470101PNS003PIEVLI0000.FTZ ./pn.fits
        #from murray
        odfingest
        sasfile=$(find . -iname "*.SAS")
        echo $sasfile
        export SAS_ODF=$sasfile
        epproc
        imagev=$(find . -iname "*ImagingEvts.ds")
        echo $imagev
        
        cp $imagev ./pn.fits

        echo $folder
        echo $id
        read -p "Detector X Coordinate?" detx
        if [$detx -eq break]; then
        continue
        fi 

        read -p "Detector Y Coordinate?" dety
        # read -p "Detector Radius?" detrad
        read -p "Background X Coordinate?" bgdy
        read -p "Background Y Coordinate?" bgdy
        read -p "Background Radius?" bgdrad


        evselect table=pn.fits withfilteredset=yes expression='(PATTERN <= 4)&&(PI in [10000:12000])&&#XMMEA_EP' filteredset=pn_pat0-4_en10-12.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat0-4_en10-12_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=100 makeratecolumn=yes
        ### Check for flaring background by creating a lightcurve in the 10-12 keV band

        fv pn_pat0-4_en10-12_ltcrv.fits


        tabgtigen table=pn_pat0-4_en10-12_ltcrv.fits expression='RATE<=0.7' gtiset=lowbg_gti.fits

        #DS9!!!!


        #spectrum
        evselect table='pn.fits' withfilteredset=yes expression='(PATTERN<=4)&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE($detx,$dety,600))' filteredset=pn_pat0-4_en0.2-10_src_30.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat0-4_en0.2-10_src_30_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='pn_pat0-4_src_30_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

        #background
        evselect table='pn.fits' withfilteredset=yes expression='(PATTERN<=4)&&(PI in [200:10000])&&#XMMEA_EP&&gti(lowbg_gti.fits,TIME)&&((X,Y) in CIRCLE($bgdx,$bgdy,bgdrad))' filteredset=pn_pat0-4_en0.2-10_bgd2.fits filtertype=expression keepfilteroutput=yes updateexposure=yes filterexposure=yes withrateset=yes rateset=pn_pat0-4_en0.2-10_bgd2_ltcrv.fits maketimecolumn=yes timecolumn=TIME timebinsize=0.074 makeratecolumn=yes energycolumn='PI' withspectrumset=yes spectrumset='pn_pat0-4_bgd2_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479

        #backscale
        backscale spectrumset='pn_pat0-4_src_30_pi.fits'
        backscale spectrumset='pn_pat0-4_bgd2_pi.fits'

        #rmf
        rmfgen rmfset=pn_pat0-4_src_30.rmf spectrumset='pn_pat0-4_src_30_pi.fits'

        #arf
        arfgen arfset=pn_pat0-4_src_30.arf spectrumset='pn_pat0-4_src_30_pi.fits' withrmfset=yes rmfset=pn_pat0-4_src_30.rmf

        #group the spectrum
        grppha pn_pat0-4_src_30_pi.fits pn_pat0-4_src_30_pi_20.fits "group min 20" exit
        grppha pn_pat0-4_src_30_pi.fits pn_pat0-4_src_30_pi_1.fits "group min 1" exit

        #awk command --> log show all, get the chi-squared statisti, do int () type ... vary the pattern, and radius and rate, just test 0.1 width.
    
    
    done 
    
done
