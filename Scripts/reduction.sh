	
	
	read -p "Observation ID: " obs_id
	cd 
	
	cd Documents/Caltech/${obs_id}/ULX
	
	
	read -p "Radius: " radius

	rm $radius.xco
	rm $radius.
	rm $radius_plot.xcm
	rm plot_${radius}_delc
	rm plot_${radius}

	datafile="$(ls | grep "$radius" | grep "20.fits")"
	respdata="$(ls | grep "$radius" | grep ".rmf")"
    arf="$(ls | grep "$radius" | grep ".arf")"
    bgfile="pn_pat0_bgd2_pi.fits"
    

    echo "query yes" >> $radius.xco
	echo "log $radius.log" >> $radius.xco
	echo "data $datafile" >> $radius.xco
	echo "back $bgfile" >> $radius.xco
	echo "resp $respdata" >> $radius.xco
	echo "arf $arf" >> $radius.xco
	echo "ignore **-2.0 10.0-**" >> $radius.xco 
	echo "ignore bad" >> $radius.xco



    # Define the model
	echo "model tbabs*cutoffpl" >> $radius.xco
	#Absoprtion
	echo "1.0,0.1" >> $radius.xco
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

	echo "hardcopy plot_${radius} color" >> $radius.xco

	echo "addc 3 zgauss" >> $radius.xco
	#energy
	echo "5 0.01 0.5 0.5 8.0 8.0" >> $radius.xco
	#width
	echo "0.3, -1" >> $radius.xco
	#normalization
	echo "0.002,-1" >> $radius.xco

	echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> $radius.xco
	echo "fit" >> $radius.xco

	echo "plot ld delc" >> $radius.xco
	echo "save all ${radius}_plot.xcm" >> $radius.xco
	echo "hardcopy plot_${radius}_delc color" >> $radius.xco
	echo "exit" >> $radius.xco

	xspec - $radius.xco