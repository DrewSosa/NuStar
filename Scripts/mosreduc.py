#!/usr/bin/bash python
#@Hannah Earnshaw, emailed to Andrew Sosanya for easy EPIC-MOS Reduction.
# Extract light curve and spectrum using SAS
from __future__ import print_function
from __future__ import division
from builtins import input
import os, sys, re
from subprocess import call
from subprocess import Popen
from astropy.io import fits

if __name__ == "__main__":
    
    #export SAS_CCF=./elist/ccf.cif
    #call(['export','SAS_CCF=./elist/ccf.cif'])
    
    min_counts = '20'
    
    # Load the three event lists
    # event_lists = [f for f in os.listdir('.') \
    #                if re.match('^clean.*\.ds$', f) is not None]


    # Grab the three start and end times and define longest time range
    os.chdir("/Users/Anne/Documents/Caltech/0672130101/ULX/")
    st = []
    et = []
    el = "m2.fits"
    
    table = fits.open(el)
    table_data = table[1].data
    time = table_data['TIME']
    st.append(min(time))
    et.append(max(time))
    starttime = str(min(st))
    stime = min(st)
    endtime = str(max(et))
    camid = "m2"
    # Grab the three coordinate sets
    
    
    
    # img_fname = camid+'image.img'
    # call(['evselect', 'table='+el, 'imagebinning=binSize', \
    #       'imageset='+img_fname, 'withimageset=Y', 'xcolumn=X', \
    #       'ycolumn=Y', 'ximagebinsize=80', 'yimagebinsize=80'])
    # call(['imgdisplay','withimagefile=T','imagefile='+img_fname])

    # Get user input for coords and radius of src and bkgd
    cox, coy, rad = input('Enter src phys coords and rad:').split()
    bgcox, bgcoy, bgrad = input('Enter bkgd phys coords and rad:').split()

    # Go ahead with extraction
    
    expression = '#XMMEA_EM && (PATTERN<=12) && '
    specchannelmax = '11999'


    # Uncomment for time interval filtering
    #camid = camid+'_t4'
    #expression = expression+'(TIME IN ['+str(stime + 40000)+':'+str(stime + 50000)+']) && '



    src_expression = expression+'((X,Y) IN circle('+cox+','+coy+','+rad+')) && (PI in [200:10000])'
    bkgd_expression = expression+'((X,Y) IN circle('+bgcox+','+bgcoy+','+bgrad+')) && (PI in [200:10000])'

    print('######################', camid, '##########################')
    # Generate light curve and background
    call(['evselect', 'table='+el, 'energycolumn=PI', \
          'expression='+src_expression, 'withrateset=Y', \
          'rateset='+camid+'_src_ltcrv.fits', \
          'timebinsize=0.074', 'maketimecolumn=Y', 'makeratecolumn=Y', \
          'timemin='+starttime, 'timemax='+endtime])
    call(['evselect', 'table='+el, 'energycolumn=PI', \
          'expression='+bkgd_expression, 'withrateset=Y', \
          'rateset='+camid+'_bgd_ltcrv.fits', \
          'timebinsize=0.074', 'maketimecolumn=Y', 'makeratecolumn=Y', \
          'timemin='+starttime, 'timemax='+endtime])
    call(['epiclccorr','srctslist='+camid+'_source_lightcurve_raw.lc', \
          'eventlist='+el,'outset='+camid+'_lccorr.lc', \
          'bkgtslist='+camid+'_background_lightcurve_raw.lc', \
          'withbkgset=Y','applyabsolutecorrections=Y'])

    # Generate spectrum
    call(['evselect', 'table='+el, 'energycolumn=PI', \
          'expression='+src_expression, 'withspectrumset=Y', \
          'spectrumset='+camid+'_source_spectrum.fits', \
          'spectralbinsize=5', 'withspecranges=Y', 'specchannelmin=0', \
          'specchannelmax='+specchannelmax])
    call(['evselect', 'table='+el, 'energycolumn=PI', \
          'expression='+bkgd_expression, 'withspectrumset=Y', \
          'spectrumset='+camid+'_background_spectrum.fits', \
          'spectralbinsize=5', 'withspecranges=Y', 'specchannelmin=0', \
          'specchannelmax='+specchannelmax])
    call(['backscale','spectrumset='+camid+'_source_spectrum.fits', \
          'badpixlocation='+el])
    call(['backscale','spectrumset='+camid+'_background_spectrum.fits', \
          'badpixlocation='+el])
    call(['rmfgen','spectrumset='+camid+'_source_spectrum.fits', \
          'rmfset='+camid+'.rmf'])
    call(['arfgen','spectrumset='+camid+'_source_spectrum.fits', \
          'arfset='+camid+'.arf', 'withrmfset=Y', 'rmfset='+camid+'.rmf', \
          'badpixlocation=clean'+el, 'detmaptype=psf'])
    call(['specgroup', 'spectrumset='+camid+'_source_spectrum.fits', \
          'mincounts='+min_counts, 'oversample=3', 'rmfset='+camid+'.rmf', \
          'arfset='+camid+'.arf', \
          'backgndset='+camid+'_background_spectrum.fits', \
          'groupedset='+camid+'_spectrum_grp.fits'])

    # # Add up light curves
    # call(['lcmath', 'infile=M1_lccorr.lc', 'bgfile=M2_lccorr.lc', \
    #       'outfile=MOS_lccorr.lc', 'addsubr=yes', 'multi=1', 'multb=1'])
    # call(['lcmath', 'infile=MOS_lccorr.lc', 'bgfile=PN_lccorr.lc', \
    #       'outfile=combined_lccorr.lc', 'addsubr=yes', 'multi=1', 'multb=1'])

    # # Add up background light curves
    # call(['lcmath', 'infile=M1_background_lightcurve_raw.lc', \
    #       'bgfile=M2_background_lightcurve_raw.lc', \
    #       'outfile=MOS_lcbg.lc', 'addsubr=yes', 'multi=1', 'multb=1'])
    # call(['lcmath', 'infile=MOS_lcbg.lc', \
    #       'bgfile=PN_background_lightcurve_raw.lc', \
    #       'outfile=combined_lcbg.lc', 'addsubr=yes', 'multi=1', 'multb=1'])
