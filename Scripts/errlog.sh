	
	echo "cd" >> errorlog.xco
	echo "cd Documents/Caltech/0206890101/ULX" >> errorlog.xco
	echo "@fit_0_60_3-01_2.xcm" >> errorlog.xco
	echo "fit" >> errorlog.xco
	echo "error 5" >> errorlog.xco
	echo "error 6" >> errorlog.xco

	
	
	echo "exit" >> errorlog.xco

	#launch XSPEC
	xspec - errorlog.xco
