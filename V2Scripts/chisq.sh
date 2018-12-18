   
    




#!/bin/bash
#Andrew Sosanya Dec 2018 Research Assistant  andrew.sosanya.20@dartmouth.edu

project="/Users/Anne/Documents/Caltech/ReducedDec"




barred_ids=("040560101" "0301860101" "0301860101" "0405090101" "0106860301" "01510651201" "0142830101" "0142770101" "0505760201" "0150651101" "0150651201" "0150280301")

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


        rm fit3.xco 

        echo "query yes" >> fit3.xco

        echo "statistic chi" >> fit3.xco

        echo "cpd /null" >> fit3.xco

        echo "data none" >> fit3.xco

        echo "model none" >> fit3.xco

        echo "data $datafile" >> fit3.xco
        echo "back $bgfile" >> fit3.xco
        echo "resp $respdata" >> fit3.xco
        echo "arf $arf" >> fit3.xco


        echo "ignore **-0.2 10.-**" >> fit3.xco

        echo "ignore bad" >> fit3.xco

        echo "model tbabs*ztbabs*cutoffpl" >> fit3.xco

        echo "0.015,-1" >> fit3.xco

        echo "1.0,0.1" >> fit3.xco

        echo "0.002,-1" >> fit3.xco

        echo "2, 0.01" >> fit3.xco

        echo "15, 0.01" >> fit3.xco

        echo "1.E-4 1E-5" >> fit3.xco

        echo "fit" >> fit3.xco

        echo "setplot energy" >> fit3.xco

        echo "setplot rebin 3 10" >> fit3.xco

        echo "addc 4 zgauss" >> fit3.xco

        echo "5 0.01 2 2 10.0 10.0" >> fit3.xco

        echo "0.1,-1" >> fit3.xco

        echo "0.002,-1" >> fit3.xco

        echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> fit3.xco

        echo "fit" >> fit3.xco

        echo "steppar 7 2 10. 30" >> fit3.xco

        echo "setplot command wdata wdata.dat" >> fit3.xco

        echo "plot contour" >> fit3.xco

        echo "mv wdata.dat fit_tbabscutoffpl+zgauss_con_e.dat" >> fit3.xco


        echo "exit" >> fit3.xco 

        

        xspec - fit3.xco    
        
       
        rm wdata.dat
        rm fit_tbabscutoffpl.xcm
            
        done
    done