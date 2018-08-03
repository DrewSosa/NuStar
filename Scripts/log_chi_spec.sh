
	read -p "Observation ID: " obs_id

	cd
	cd Documents/Caltech/${obs_id}/ULX

	rm delc_document
 	radii=("30" "40" "50" "60");
 	energies=("5" "6"  "7"  "8")
 	widths=("0.1" "0.3")
 	patterns={"0" "0-4"}
 	echo "Delc Energy Width Patter" >> delc_document.txt
	for pattern in ${patterns}; do
		for radius in ${radii[@]}; do
			echo $radius
			for energy in ${energies[@]}; do
				for width in ${widths[@]}; do

					if [ $width = "0.1" ]
					then
						filewidth="01"
					fi
					if [ $width = "0.3" ]
					then
						filewidth="03"
					fi
					#Clean documentation files.

					rm ${radius}_${energy}-${filewidth}_${pattern}.xco
					rm plot_${radius}_delc
					rm ${radius}_${energy}-${filewidth}_${pattern}.log
					rm plot_${radius}_${energy}_${filewidth}_${pattern}_delc
					rm zgauss_${radius}_${energy}-${filewidth}_${pattern}.log
					rm log tbabs_${radius}_${energy}-${filewidth}_${pattern}.log

					datafile="$(ls | grep "${pattern}" | grep "$radius" | grep "20.fits")"
					respdata="$(ls | grep "${pattern}"| grep "$radius" | grep ".rmf")"
					arf="$(ls | grep "${pattern}" | grep "$radius" | grep ".arf")"
					bgfile="pn_${pattern}_bgd2_pi.fits"


					echo "query yes" >> ${radius}_${energy}-${filewidth}_${pattern}.xco

					echo "data $datafile" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "back $bgfile" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "resp $respdata" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "arf $arf" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "ignore **-2.0 10.0-**" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "ignore bad" >> ${radius}_${energy}-${filewidth}_${pattern}.xco



					# Define the model
					echo "model tbabs*cutoffpl" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#Absoprtion
					echo "1.0 ,0.1" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#powerlaw index/gamma
					echo "2, 0.01" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#Cuttoff energy
					echo "15, 0.01" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#Normalization
					echo "1.E-4 1E-5" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "fit" >> ${radius}_${energy}-${filewidth}_${pattern}.xco

					#Create a log file, and list spectrum characteristics
					echo "log tbabs_${radius}_${energy}-${filewidth}_${pattern}.log" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "show all" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "log none" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					filename="/Users/Anne/Documents/Caltech/${obs_id}/ULX/tbabs_${radius}_${energy}-${filewidth}_${pattern}.log"
					tbabs_chi=$(awk  '/Fit statistic : Chi-Squared =/ {print $6}' $filename)

					# Save the best-fit model, what is rebin 3 10?
					echo "setplot energy" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "setplot rebin 3 10" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "plot ldata" >> ${radius}_${energy}-${filewidth}_${pattern}.xco

					echo "hardcopy plot_${radius}_${pattern} color" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "addc 3 zgauss" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#energy
					echo "$energy 0.01 0.5 0.5 8.0 8.0" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#width
					echo "$width, -1" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#normalization
					echo "0.002,-1" >> ${radius}_${energy}-${filewidth}_${pattern}.xco

					echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "fit" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#fix the plot.
					echo "setplot energy" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "setplot rebin 3 10" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "plot ld delc" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#echo "save all ${radius}_plot.xcm" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					#Create a log file, and list spectrum characteristics
					echo "log zgauss_${radius}_${energy}-${filewidth}_${pattern}.log" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "show all" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "log none" >> ${radius}_${energy}-${filewidth}_${pattern}.xco

					#save the plot
					echo "hardcopy plot_${radius}_${energy}_${filewidth}_${pattern}_delc color" >> ${radius}_${energy}-${filewidth}_${pattern}.xco
					echo "exit" >> ${radius}_${energy}-${filewidth}_${pattern}.xco

					#launch XSPEC
					xspec - ${radius}_${energy}-${filewidth}_${pattern}.xco

					#strip the chi squared value and perform arithmetic to get delc.
					filename1="/Users/Anne/Documents/Caltech/${obs_id}/ULX/tbabs_${radius}_${energy}-${filewidth}_${pattern}.log"
					tbabs_chi=$(awk  '/Fit statistic : Chi-Squared =/ {print $6}' $filename1)

					filename2="/Users/Anne/Documents/Caltech/${obs_id}/ULX/zgauss_${radius}_${energy}-${filewidth}_${pattern}.log"
					zgauss_chi=$(awk  '/Fit statistic : Chi-Squared =/ {print $6}' $filename2)

					echo $zgauss_chi
					delc=$(bc <<< "${tbabs_chi}-${zgauss_chi}")

					echo "$delc ${radius} ${energy} ${width} ${pattern}	" >> delc_document.txt
					echo "$obs_id"

					echo "files ordered such that [radius]_[energy]-[width]_[pattern]"

				done
			done
		done
	done
	#formal text into a readable table!
	column -t  delc_document.txt >> table_${radius}_${energy}_${width}_${pattern}.txt.txt
