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

    rm fit_tbabscutoffpl+zgauss_con_e.dat
    rm contour.txt
    rm fit_tbabscutoffpl.xcm
    # rm fit_tbabscutoffpl+zgauss_con_e.txt
    # Standard initial XSPEC commands
	echo "query yes" >> contour.txt
	echo "statistic chi" >> contour.txt
	echo "cpd /null" >> contour.txt
	echo "data none" >> contour.txt
	echo "model none" >> contour.txt



    #Load the data and restrict energy range

	echo "log contour.log" >> contour.txt
	echo "data $datafile" >> contour.txt
	echo "back $bgfile" >> contour.txt
	echo "resp $respdata" >> contour.txt
	echo "arf $arf" >> contour.txt
	echo "ignore **-2.0 10.0-**" >> contour.txt #changed range to 2 keV from 0.2 keV
	echo "ignore bad" >> contour.txt



    # Define the model
	echo "model tbabs*cutoffpl" >> contour.txt
	echo "1.0,0.1" >> contour.txt
	echo "2, 0.01" >> contour.txt
	echo "15, 0.01" >> contour.txt
	echo "1.E-4 1E-5" >> contour.txt
	echo "fit" >> contour.txt

    # Save the best-fit model
    echo "save all fit_tbabscutoffpl.xcm" >> contour.txt
	echo "setplot energy" >> contour.txt
	echo "setplot rebin 3 10" >> contour.txt

# Add a Gaussian absorption line (any energy)
	echo "addc 3 zgauss" >> contour.txt
	echo "1 0.01 0.5 0.5 8.0 8.0" >> contour.txt
	echo "0.01,-1" >> contour.txt #change this to 0.3
	echo "0.002,-1" >> contour.txt
	echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> contour.txt
	echo "fit" >> contour.txt

# Step/search over the energy range looking for absorption lines
  	echo "steppar 5 2 10. 30" >> contour.txt

# Plot the chi^2 as a function of energy
	echo "plot contour" >> contour.txt

# Write the plot to a file
	echo "setplot command wdata wdata.dat" >> contour.txt
    echo "plot contour" >> contour.txt
	echo "mv wdata.dat fit_tbabscutoffpl+zgauss_con_e_0.01.dat" >> contour.txt

	echo "log none" >> contour.txt
	echo "exit" >> contour.txt

	xspec - contour.txt

done