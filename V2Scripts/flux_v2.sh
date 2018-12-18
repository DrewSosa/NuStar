#!/bin/bash
#Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu


project="/Users/Anne/Documents/Caltech/ReducedDec"
    
barred_ids=("040560101" ,"0301860101", "0301860101","0405090101","0106860301","01510651201", "0142830101", "0142770101" "0505760201" "0150651101" "0150651201" "0150280301")



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
        if [ "$marker" = "true" ] ; then
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



        datafile="$(ls | grep "pn_pat0-4_src_30_pi_20.fits")"
        arf="$(ls | grep ".arf")"
        bgfile="$(ls | grep "pn_pat0-4_bgd2_pi.fits")"
        respdata="$(ls | grep ".rmf")"


    
            rm fit_tbabscutoffpl_ld.dat
            rm flux.txt
            rm fit_tbabscutoffpl.xcm
            # rm fit_tbabscutoffpl+zgauss_con_e.txt
            # Standard initial XSPEC commands
            echo "query yes" >> flux.txt
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
            echo "save all fit_tbabscutoffpl.xcm" >> flux.txt
            echo "setplot energy" >> flux.txt
            echo "setplot rebin 3 10" >> flux.txt

            # Write out the spectrum to a file (for plotting later)
            echo "plot ldata" >> flux.txt
            echo "setplot command wdata wdata.dat" >> flux.txt
            echo "plot ldata" >> flux.txt
            echo "mv wdata.dat fit_tbabscutoffpl_ld.dat" >> flux.txt


            echo "log none" >> flux.txt
            echo "exit" >> flux.txt

            xspec - flux.txt

    done
done
