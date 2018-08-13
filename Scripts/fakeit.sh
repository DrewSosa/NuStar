#! /bin/tcsh -f

set RESULTS = "/Users/murray/work/M51/sims/0830191401/fit_tbabscutoffpl_e7.0_s0.1_chisq.csv"

if (-e $RESULTS) rm $RESULTS
touch $RESULTS

@ numsims = 1000

@ dirnum = 1
while ( $dirnum <= $numsims )
 
	set dir = /Users/murray/work/xmm/raw/0830191401/ULX-8

   	cd $dir

	echo "query yes" >! sim.xco
	echo "statistic chi" >> sim.xco
	echo "cpd /null" >> sim.xco
	echo "data none" >> sim.xco
	echo "model none" >> sim.xco
	echo "@fit_tbabscutoffpl.xcm" >> sim.xco
	echo "fakeit" >> sim.xco
	echo "y" >> sim.xco
	echo " " >> sim.xco
	echo "sim_tbabscutoffpl.fak" >> sim.xco
	echo "8.012e+04, 1.00000, 8.012e+04" >> sim.xco
	echo "ignore **-0.2 10.-**" >> sim.xco
	echo "fit" >> sim.xco
        echo "log fit_tbabscutoffpl_fak.log" >> sim.xco
        echo "show all" >> sim.xco
        echo "log none" >> sim.xco
	echo "addc 4 zgauss" >> sim.xco
#	echo "1 0.01 0.5 0.5 8.0 8.0" >> sim.xco
	echo "7.0 0.01 2.5 2.5 10.0 10.0" >> sim.xco
#	echo "0.01,-1" >> sim.xco
	echo "0.1,-1" >> sim.xco
	echo "0.002,-1" >> sim.xco
	echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> sim.xco
        echo "fit" >> sim.xco
        echo "log fit_tbabscutoffpl+zgauss_fak.log" >> sim.xco
        echo "show all" >> sim.xco
        echo "log none" >> sim.xco
   	echo "exit" >> sim.xco	

	rm *fak*
	xspec - sim.xco	

        set chisq0 = `awk '/Fit statistic : Chi-Squared/ {chisq=$6}; END {print chisq}' fit_tbabscutoffpl_fak.log`
        set chisq1 = `awk '/Fit statistic : Chi-Squared/ {chisq=$6}; END {print chisq}' fit_tbabscutoffpl+zgauss_fak.log`

        echo $dirnum , $chisq0 , $chisq1 >> $RESULTS


	@ dirnum ++
end
