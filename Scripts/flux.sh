#!/bin/bash
#Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu

project="/Users/sosa/Documents/Caltech"
OBSIDS="$project/Positions/obsid.txt"
allobsids=`cat $OBSIDS`

numobsids=$(awk 'END {print NR}' $OBSIDS)



echo "number of obs IDs:" $numobsids

# while [ $dirnum -le $numobsids ]
cd $project/Spectra
for filename in *; do
    echo filename
    #echo $(ls) #====ATTN #why does it skip over the pps directory?
    cd $project/Spectra/$filename/pps

    # echo TEST
    # obsid=${allobsids[$dirnum]}
    # echo $obsid
    # dir=/Users/sosa/Documents/Caltech/Spectra/$obsid/pps
    # echo $dir
    # echo TESTING
    # cd $dir

    #     echo "================================================="
    # 	echo "$dir"
    # 	echo ""
   	# echo "-------------------------------------------------"
# Standard initial XSPEC commands



#Grab the data, resp, bg, & arf files

    # attempt to substring check for the files..ask murray
    #for a better way

    #outputs something like -rw-r--r--@ 1 sosa staff 16113 Dec 20 2012 P0093640901PNS003BGSPEC0001.FTZ
    #ask sean how to fix this
    if ! (ls | grep -q "PN") then
    echo HEY
    echo BREAKPOINT
    continue
    fi


    datafile="$(ls | grep "PN" | grep "SRSPEC")"
    arf="$(ls | grep "PN" | grep "SRCARF")"
    bgfile="$(ls | grep "PN" | grep "BGSPEC")"



    respdata=""

    for ((a=2000; a < 2007; a++)); do
    if (fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep -q "$a") then
        echo downloaded e1
        cp /Users/sosa/Documents/Caltech/rmf/epn_e1_ff20_sY9_v16.0.rmf .
        respdata=epn_e1_ff20_sY9_v16.0.rmf
    fi
    done
    for ((a=2007; a < 2014; a++)); do
    if (fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep -q "$a") then
        echo downloaded e2
        cp /Users/sosa/Documents/Caltech/rmf/epn_e2_ff20_sY9_v16.0.rmf .
        respdata=epn_e2_ff20_sY9_v16.0.rmf
        fi
    done
    for ((a=2014; a <= 2018; a++)); do
    if (fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep -q "$a") then
        echo downloaded e3
        cp /Users/sosa/Documents/Caltech/rmf/epn_e3_ff20_sY9_v16.0.rmf .
        respdata=epn_e3_ff20_sY9_v16.0.rmf
        fi
    done
    
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
