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
    rm fit3.xco
    rm fit_tbabscutoffpl.xcm
    # rm fit_tbabscutoffpl+zgauss_con_e.txt
    # Standard initial XSPEC commands
	echo "query yes" >> fit3.xco
	echo "statistic chi" >> fit3.xco
	echo "cpd /null" >> fit3.xco
	echo "data none" >> fit3.xco
	echo "model none" >> fit3.xco



    #Load the data and restrict energy range

	echo "log fit3.log" >> fit3.xco
	echo "data $datafile" >> fit3.xco
	echo "back $bgfile" >> fit3.xco
	echo "resp $respdata" >> fit3.xco
	echo "arf $arf" >> fit3.xco
	echo "ignore **-2.0 10.0-**" >> fit3.xco #changed range to 2 keV from 0.2 keV
	echo "ignore bad" >> fit3.xco



    # Define the model
	echo "model tbabs*cutoffpl" >> fit3.xco
	echo "1.0,0.1" >> fit3.xco
	echo "2, 0.01" >> fit3.xco
	echo "15, 0.01" >> fit3.xco
	echo "1.E-4 1E-5" >> fit3.xco
	echo "fit" >> fit3.xco

    # Save the best-fit model
    echo "save all fit_tbabscutoffpl.xcm" >> fit3.xco
	echo "setplot energy" >> fit3.xco
	echo "setplot rebin 3 10" >> fit3.xco


# # Write out the spectrum to a file (for plotting later)
  	# echo "setplot command wdata wdata.dat" >> fit3.xco
    # echo "plot ldata" >> fit3.xco
	# echo "mv wdata.dat fit_tbabscutoffpl_ld.dat" >> fit3.xco


# # Plot delta-chi and write out to a file
    # echo "setplot command wdata wdata.dat" >> fit3.xco
    # echo "plot delchi" >> fit3.xco
	# echo "mv wdata.dat fit_tbabscutoffpl_delc.dat" >> fit3.xco

# Add a Gaussian absorption line (any energy)
	echo "addc 3 zgauss" >> fit3.xco
	echo "1 0.01 0.5 0.5 8.0 8.0" >> fit3.xco
	echo "0.1,-1" >> fit3.xco #change this to 0.1
	echo "0.002,-1" >> fit3.xco
	echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> fit3.xco
	echo "fit" >> fit3.xco

# Step/search over the energy range looking for absorption lines
  	echo "steppar 5 2 10. 30" >> fit3.xco

# Plot the chi^2 as a function of energy
	echo "plot contour" >> fit3.xco

# Write the plot to a file
	echo "setplot command wdata wdata.dat" >> fit3.xco
    echo "plot contour" >> fit3.xco
	echo "mv wdata.dat fit_tbabscutoffpl+zgauss_con_e.dat" >> fit3.xco

	echo "log none" >> fit3.xco
	echo "exit" >> fit3.xco

	xspec - fit3.xco

done