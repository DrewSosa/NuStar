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

    rm fit_tbabscutoffpl_delc.dat
    rm delta_chi.txt
    rm fit_tbabscutoffpl.xcm
    # rm fit_tbabscutoffpl+zgauss_con_e.txt
    # Standard initial XSPEC commands
	echo "query yes" >> delta_chi.txt
	echo "statistic chi" >> delta_chi.txt
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
    echo "save all fit_tbabscutoffpl.xcm" >> delta_chi.txt
	echo "setplot energy" >> delta_chi.txt
	echo "setplot rebin 3 10" >> delta_chi.txt


# Plot delta-chi and write out to a file
    echo "plot delchi" >> delta_chi.txt
    echo "setplot command wdata wdata.dat" >> delta_chi.txt
    echo "plot delchi" >> delta_chi.txt
	echo "mv wdata.dat fit_tbabscutoffpl_delc.dat" >> delta_chi.txt

    echo "log none" >> delta_chi.txt
	echo "exit" >> delta_chi.txt

	xspec - delta_chi.txt

done