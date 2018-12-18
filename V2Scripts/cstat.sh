#!/bin/bash
#Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu


project="/Users/Anne/Documents/Caltech/ReducedDec"
    
barred_ids=("040560101" ,"0301860101", "0301860101","0405090101","0106860301","01510651201", "0142830101", "0142770101" "0505760201" "0150651101" "0150651201" "0150280301")

cstat=("0500750101/" "0653380501/" "0653380301/")


# while [ $dirnum -le $numobsids ]
cd $project

for source in *; do
    echo $source
    #echo $(ls) #====ATTN #why does it skip over the pps directory?
    cd $project/$source
    for id in */; do
        cd 
        cd $project/$source/$id/ULX
        marker=false
        
        for element in "${barred_ids[@]}";do
            if [ "$element" = "$id" ]; then 
                marker=true
                break
            fi
        done 
       
        if [ "$marker" = true ] ; then
            continue
        fi 
    
        echo "+++++++++++"
        echo $source
        echo $id
        echo "+++++++++++"
        # Standard initial XSPEC commands
        
        #Grab the data, resp, bg, & arf files

        # attempt to substring check for the files..ask murray
        #for a better way

        #outputs something like -rw-r--r--@ 1 sosa staff 16113 Dec 20 2012 P0093640901PNS003BGSPEC0001.FTZ



        datafile="$(ls | grep "pn_pat0-4_src_30_pi_1.fits")"
        arf="$(ls | grep ".arf")"
        bgfile="$(ls | grep "pn_pat0-4_bgd2_pi.fits")"
        respdata="$(ls | grep ".rmf")"
           
            #flux
            rm cstat_tbabscutoffpl_ld.dat
            rm flux.txt
            rm cstat_tbabscutoffpl.xcm
            # rm fit_tbabscutoffpl+zgauss_con_e.txt
            # Standard initial XSPEC commands
            echo "query yes" >> flux.txt
            echo "statistic cstat" >> flux.txt
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
            echo "save all cstat_tbabscutoffpl.xcm" >> flux.txt
            echo "setplot energy" >> flux.txt
            echo "setplot rebin 3 10" >> flux.txt

            # Write out the spectrum to a file (for plotting later)
            echo "plot ldata" >> flux.txt
            echo "setplot command wdata wdata.dat" >> flux.txt
            echo "plot ldata" >> flux.txt
            echo "mv wdata.dat cstat_tbabscutoffpl_ld.dat" >> flux.txt


            echo "log none" >> flux.txt
            echo "exit" >> flux.txt

            xspec - flux.txt

            rm chisq.xco 

            echo "query yes" >> chisq.xco

            echo "statistic cstat" >> chisq.xco

            echo "cpd /null" >> chisq.xco

            echo "data none" >> chisq.xco

            echo "model none" >> chisq.xco

            echo "data $datafile" >> chisq.xco
            echo "back $bgfile" >> chisq.xco
            echo "resp $respdata" >> chisq.xco
            echo "arf $arf" >> chisq.xco


            echo "ignore **-0.2 10.-**" >> chisq.xco

            echo "ignore bad" >> chisq.xco

            echo "model tbabs*ztbabs*cutoffpl" >> chisq.xco

            echo "0.015,-1" >> chisq.xco

            echo "1.0,0.1" >> chisq.xco

            echo "0.002,-1" >> chisq.xco

            echo "2, 0.01" >> chisq.xco

            echo "15, 0.01" >> chisq.xco

            echo "1.E-4 1E-5" >> chisq.xco

            echo "fit" >> chisq.xco

            echo "setplot energy" >> chisq.xco

            echo "setplot rebin 3 10" >> chisq.xco

            echo "addc 4 zgauss" >> chisq.xco

            echo "5 0.01 2 2 10.0 10.0" >> chisq.xco

            echo "0.1,-1" >> chisq.xco

            echo "0.002,-1" >> chisq.xco

            echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> chisq.xco

            echo "fit" >> chisq.xco

            echo "steppar 7 2 10. 30" >> chisq.xco

            echo "setplot command wdata wdata.dat" >> chisq.xco

            echo "plot contour" >> chisq.xco

            echo "mv wdata.dat cstat_tbabscutoffpl+zgauss_con_e.dat" >> chisq.xco


            echo "exit" >> chisq.xco 

        

        xspec - chisq.xco    
        
       
        rm wdata.dat
        rm cstat_tbabscutoffpl.xcm

        #Deltachi

        rm cstat_tbabscutoffpl_delc.dat
        rm delta_chi.txt
        rm cstat_tbabscutoffpl.xcm
        # rm fit_tbabscutoffpl+zgauss_con_e.txt
        # Standard initial XSPEC commands
            echo "query yes" >> delta_chi.txt
            echo "statistic cstat" >> delta_chi.txt
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
            echo "save all cstat_tbabscutoffpl.xcm" >> delta_chi.txt
            echo "setplot energy" >> delta_chi.txt
            echo "setplot rebin 3 10" >> delta_chi.txt


            # Plot delta-chi and write out to a file
            echo "plot delchi" >> delta_chi.txt
            echo "setplot command wdata wdata.dat" >> delta_chi.txt
            echo "plot delchi" >> delta_chi.txt
            echo "mv wdata.dat cstat_tbabscutoffpl_delc.dat" >> delta_chi.txt

            echo "log none" >> delta_chi.txt
            echo "exit" >> delta_chi.txt

        xspec - delta_chi.txt

    done
done
