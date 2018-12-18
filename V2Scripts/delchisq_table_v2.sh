#!/bin/bash
	#specific
    #Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu

project="/Users/Anne/Documents/Caltech/ReducedDec/"

barred_ids=("040560101" ,"0301860101", "0301860101","0405090101","0106860301","01510651201", "0142830101", "0142770101" "0505760201" "0150651101" "0150651201" "0150280301")
echo "HEY"


# while [ $dirnum -le $numobsids ]
cd $project

for source in */; do
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
	#Clean DelC document each run
	rm delc_document.txt

			#Lists that allow for easy variation of parameters
			radii=("30")
			energies=("5" "6" "3.3")
			widths=("0.1")
			patterns=("0")
			rates=("0.4")

			#Title

			rm delc_document.txt
			echo "${obs_id}" >> delc_document.txt
			echo " Delc Pattern Radius Energy Width Rate" >> delc_document.txt

			#Iterate through different combinations of parameters.
			for pattern in ${patterns[@]}; do
				for radius in ${radii[@]}; do
					for energy in ${energies[@]}; do
						for width in ${widths[@]}; do
							for rate in ${rates[@]}; do

								echo $source, $id
								#To avoid periods in the files.


								#Clean documentation files.

								rm ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								rm ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log
								rm fit_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xcm

								rm zgauss_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log
								rm tbabs_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log

								#Look for files that correspond to the given parameters ands assign them to a variable.
								# datafile="$(ls | grep "pat${pattern}_" | grep "$radius" | grep "${rate//.}_"| grep "20.fits")"
								# respdata="$(ls | grep "pat${pattern}_${radius}_${rate//.}.rmf")"
								# arf="$(ls | grep "pat${pattern}_${radius}_${rate//.}.arf")"
								# bgfile="$(ls | grep "bgd2_pat${pattern}_${radius}_${rate//.}_pi.fits")"

								datafile="$(ls | grep "pn_pat0-4_src_30_pi_20.fits")"
								arf="$(ls | grep ".arf")"
								bgfile="$(ls | grep "pn_pat0-4_bgd2_pi.fits")"
								respdata="$(ls | grep ".rmf")"

								#MOS DATA
								# datafile="$(ls | grep "pat${pattern}_" | grep "$radius" | grep "${rate//.}_"| grep "20.fits")"
								# respdata="$(ls | grep "pat${pattern}_${radius}_${rate//.}.rmf")"
								# arf="$(ls | grep "pat${pattern}_${radius}_${rate//.}.arf")"
								# bgfile="$(ls | grep "bgd2_pat${pattern}_${radius}_${rate//.}_pi.fits")"



								echo "query yes" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								#Put in the correct files and output them to a parameter specific XSPEC file.
								echo "data $datafile" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "back $bgfile" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "resp $respdata" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "arf $arf" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "ignore **-2.0 10.0-**" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "ignore bad" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco



								# Define the model
								echo "model tbabs*cutoffpl" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#Absoprtion
								echo "1 ,0.1" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#powerlaw index/gamma
								echo "2, 0.01" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#Cuttoff energy
								echo "15, 0.01" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#Normalization
								echo "1.E-4 1E-5" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "fit" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								#Create a log file, and list spectrum characteristics
								echo "log tbabs_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "show all" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "log none" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								# Save the best-fit model, what is rebin 3 10?
								echo "setplot energy" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "setplot rebin 3 10" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "plot ldata" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								#echo "hardcopy plot_${radius}_${pattern} color" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "addc 3 zgauss" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#energy
								echo "$energy 0.01 0.5 0.5 9.0 9.0" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#width
								echo "$width,-1" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#normalization
								echo "0.002,-1" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "fit" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "thaw 6" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "fit" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#fix the plot.

								echo "setplot energy" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "setplot rebin 3 10" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "plot ld delc" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#echo "save all ${radius}_plot.xcm" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#Create a log file, and list spectrum characteristics
								echo "log zgauss_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "show all" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "log none" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								#save the plot
								echo "save all fit_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xcm" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								# echo "hardcopy plot_${pattern}_${radius}_${energy//.}_${width//.}_delc color" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								echo "exit" >> ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco

								#launch XSPEC
								xspec - ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								rm ${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.xco
								#strip the chi squared value from both tbabs and zgauss models and perform arithmetic to get delc.
								tbabs_file="/Users/Anne/Documents/Caltech/${obs_id}/ULX/tbabs_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log"
								tbabs_chi=$(awk  '/Fit statistic : Chi-Squared =/ {print $6}' $tbabs_file)

								zgauss_file="/Users/Anne/Documents/Caltech/${obs_id}/ULX/zgauss_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log"
								zgauss_chi=$(awk  '/Fit statistic : Chi-Squared =/ {print $6}' $zgauss_file)
								LineE=$(awk  '/LineE      keV / {print $7}' $zgauss_file)
								delc=$(bc <<< "${tbabs_chi}-${zgauss_chi}")

								echo "$delc ${pattern} ${radius} ${LineE} ${width} ${rate}	" >> delc_document.txt
								# rm tbabs_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log
								# rm zgauss_${pattern}_${radius}_${energy//.}-${width//.}_${rate//.}.log


						done

					done

				done
			done
		done
	#Easy indicators to format and observation.
	echo "Observation ID operated on: $obs_id"

	#formal text into a readable table!
	column -t  delc_document.txt >> table.txt

	done
done
	
#thaw 6" / "error 6" "rerun0 40 5.75 0.1, get plot"
