	
	
	
	
	read -p "Observation ID: " obs_id
	# read -p "Detector Radius: " radius
	# read -p "Absorption energy to fit: " energy
	# read -p "Gaussian width: " width
	# read -p "Pattern 0 or 0-4?: " pattern
	cd 
	
	cd Documents/Caltech/${obs_id}/ULX


 	radii=("30" "40" "50" "60"); 
 	energies=("5" "6"  "7"  "8")
 	widths=("0.1" "0.3")
 	pattern="0-4"
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

				rm $radius.xco
				
				
				rm plot_${radius}_delc
				rm plot_${radius}
				rm ${radius}_${energy}-${filewidth}_${pattern}.log
				rm plot_${radius}_${energy}_${filewidth}_${pattern}_delc
				rm plot_${radius}_${pattern}

				datafile="$(ls | grep "pat0-4" | grep "$radius" | grep "20.fits")"
				respdata="$(ls | grep "pat0-4"| grep "$radius" | grep ".rmf")"
			    arf="$(ls | grep "pat0-4"| grep "$radius" | grep ".arf")"
			    bgfile="pn_pat0-4_bgd2_pi.fits"
			    

			    echo "query yes" >> $radius.xco
				echo "log ${radius}_${energy}-${filewidth}_${pattern}.log" >> $radius.xco
				echo "data $datafile" >> $radius.xco
				echo "back $bgfile" >> $radius.xco
				echo "resp $respdata" >> $radius.xco
				echo "arf $arf" >> $radius.xco
				echo "ignore **-2.0 10.0-**" >> $radius.xco 
				echo "ignore bad" >> $radius.xco



			    # Define the model
				echo "model tbabs*cutoffpl" >> $radius.xco
				#Absoprtion
				echo "1.0 ,0.1" >> $radius.xco
				#powerlaw index/gamma
				echo "2, 0.01" >> $radius.xco
				#Cuttoff energy
				echo "15, 0.01" >> $radius.xco
				#Normalization
				echo "1.E-4 1E-5" >> $radius.xco
				echo "fit" >> $radius.xco

			    # Save the best-fit model, what is rebin 3 10?
				echo "setplot energy" >> $radius.xco
				echo "setplot rebin 3 10" >> $radius.xco
				echo "plot ldata" >> $radius.xco

				echo "hardcopy plot_${radius}_${pattern} color" >> $radius.xco

				echo "addc 3 zgauss" >> $radius.xco
				#energy
				echo "$energy 0.01 0.5 0.5 8.0 8.0" >> $radius.xco
				#width
				echo "$width, -1" >> $radius.xco
				#normalization
				echo "0.002,-1" >> $radius.xco

				echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> $radius.xco
				echo "fit" >> $radius.xco
				#fix the plot.
				echo "setplot energy" >> $radius.xco
				echo "setplot rebin 3 10" >> $radius.xco
				echo "plot ld delc" >> $radius.xco
				#echo "save all ${radius}_plot.xcm" >> $radius.xco

				echo "hardcopy plot_${radius}_${energy}_${filewidth}_${pattern}_delc color" >> $radius.xco
				echo "exit" >> $radius.xco
				
				xspec - $radius.xco

				echo "$obs_id"
				echo "files ordered such that [radius]_[energy]-[width]_[pattern]"
			done
		done
	done
