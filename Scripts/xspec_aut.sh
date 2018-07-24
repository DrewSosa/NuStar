#!/bin/bash

project="/Users/sosa/Documents/Caltech"
OBSIDS="$project/Positions/obsid.txt"
allobsids=`cat $OBSIDS`

numobsids=$(awk 'END {print NR}' $OBSIDS)
echo $numobsids


echo "number of obs IDs:" $numobsids

dirnum=1
echo $dirnum
# while [ $dirnum -le $numobsids ]
cd $project/Spectra
for filename in *; do
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


# Standard initial XSPEC commands
	# echo "query yes" >! fit3.xco
	# echo "statistic chi" >> fit3.xco
	# echo "cpd /null" >> fit3.xco
	# echo "data none" >> fit3.xco
	# echo "model none" >> fit3.xco

#Grab the data, resp, bg, & arf files

    # attempt to substring check for the files..ask murray
    #for a better way

    #outputs something like -rw-r--r--@ 1 sosa staff 16113 Dec 20 2012 P0093640901PNS003BGSPEC0001.FTZ
    #ask sean how to fix this
    datafile="$(ls | grep "PN" | grep "SRSPEC")"
    arf="$(ls | grep "PN" | grep "SRCARF")"
    bgfile="$(ls | grep "PN" | grep "BGSPEC")"
    echo $datafile
    echo HEY
    respdata=""
    #echo "$(fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep "2001")"
    for ((a=2000; a < 2007; a++)); do
    if (fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep -q "$a") then
        echo TEST1
        cp /Users/sosa/Documents/Caltech/rmf/epn_e1_ff20_sY9_v16.0.rmf .
        respdata=epn_e1_ff20_sY9_v16.0.rmf
    fi
    done
    for ((a=2007; a < 2014; a++)); do
    if (fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep -q "$a") then
        echo TEST2
        cp /Users/sosa/Documents/Caltech/rmf/epn_e2_ff20_sY9_v16.0.rmf .
        respdata=epn_e2_ff20_sY9_v16.0.rmf
        fi
    done
    for ((a=2007; a <= 2018; a++)); do
    if (fkeyprint /Users/sosa/Documents/Caltech/Spectra/$filename/pps/$datafile[0] expstart | grep -q "$a") then
        echo TEST3
        cp /Users/sosa/Documents/Caltech/rmf/epn_e3_ff20_sY9_v16.0.rmf .
        respdata=epn_e3_ff20_sY9_v16.0.rmf
        fi
    done




    #Load the data and restrict energy range
	echo "data $datafile" >> fit3.xco
	echo "back $bgfile" >> fit3.xco
	echo "resp $respdata" >> fit3.xco
	echo "arf $arf" >> fit3.xco
	echo "ignore **-0.2. 10.0-**" >> fit3.xco
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
	echo "plot ldata" >> fit3.xco

# Write out the spectrum to a file (for plotting later)
  	# echo "setplot command wdata wdata.dat" >> fit3.xco
	# echo "mv wdata.dat fit_tbabscutoffpl_ld.dat" >> fit3.xco


# Plot delta-chi and write out to a file
    # echo "plot delchi" >> fit3.xco
	# echo "setplot command wdata wdata.dat" >> fit3.xco
	# echo "mv wdata.dat fit_tbabscutoffpl_delc.dat" >> fit3.xco

# Add a Gaussian absorption line (any energy)
	echo "addc 3 zgauss" >> fit3.xco
	echo "1 0.01 0.5 0.5 8.0 8.0" >> fit3.xco
	echo "0.01,-1" >> fit3.xco
	echo "0.002,-1" >> fit3.xco
	echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> fit3.xco
	echo "fit" >> fit3.xco

# Step/search over the energy range looking for absorption lines
  	echo "steppar 6 0.2 10. 30" >> fit3.xco

# Plot the chi^2 as a function of energy
	echo "plot contour" >> fit3.xco

# Write the plot to a file
	# echo "setplot command wdata wdata.dat" >> fit3.xco
	# echo "mv wdata.dat fit_tbabscutoffpl+zgauss_con_e.dat" >> fit3.xco

	echo "exit" >> fit3.xco

	xspec - fit3.xco

done