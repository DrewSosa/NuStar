#! /bin/tcsh -f

set project = "/Users/Anne/Documents/Caltech/ReducedDec"


set RESULTS = "Users/Anne/Documents/Caltech/NuStar/V2Scripts/ulx8_ewlims0_3sig.csv"

if (-e $RESULTS) rm $RESULTS
touch $RESULTS

DIRS = "$project/scripts/ULX-8_all_dirs.txt"
set alldirs = `cat $DIRS` 
@ numdirs = $#alldirs

set OBSIDS = "$project/scripts/ULX-8_all_obsids.txt"
set allobsids = `cat $OBSIDS` 

set ENERGIES = "$project/scripts/energies_2-10keV.csv"
set allenergies = `cat $ENERGIES` 
@ numenergies = $#allenergies
    

echo "number of obs IDs: $numdirs"
echo "number of energies: $numenergies"

@ dirnum = 1
while ( $dirnum <= $numdirs )
 
	set dir = $alldirs[${dirnum}]
	set obsid = $allobsids[${dirnum}]

   	cd $dir

    	echo "================================================="
    	echo "$dir"
    	echo ""
   	echo "-------------------------------------------------"

	@ ennum = 1
	while ( $ennum <= $numenergies )

	    set energy = $allenergies[${ennum}]

	    echo $energy

	    echo "query yes" >! ewlim.xco
	    echo "statistic chi" >> ewlim.xco
	    echo "cpd /null" >> ewlim.xco
	    echo "data none" >> ewlim.xco
	    echo "@fit_tbabscutoffpl.xcm" >> ewlim.xco
	    echo "fit" >> ewlim.xco
	    echo "freeze 2 5" >> ewlim.xco
	    echo "addc 4 zgauss" >> ewlim.xco
	    echo "${energy} -1" >> ewlim.xco
	    echo "0.1,-1" >> ewlim.xco
	    echo "0.002,-1" >> ewlim.xco
	    echo "-1e-6 1e-7 -1e10 -1e10 -1e-10 -1e-10" >> ewlim.xco
	    echo "fit" >> ewlim.xco
	    echo "log ewlim.log" >> ewlim.xco
	    echo "eqwidth 4 err 100 99.7" >> ewlim.xco
	    echo "log none" >> ewlim.xco	
	    echo "exit" >> ewlim.xco	

	    xspec - ewlim.xco	

	    set eqw1 = `awk '/Additive group equiv width/ {eqw=$8}; END {print eqw}' ewlim.log`
	    set eqw1_err1 = `awk '/Equiv width error range/ {err=$5}; END {print err}' ewlim.log`
	    set eqw1_err2 = `awk '/Equiv width error range/ {err=$7}; END {print err}' ewlim.log`

	    echo $obsid , $energy , $eqw1 , $eqw1_err1 , $eqw1_err2 >> $RESULTS

	    @ ennum ++
	    end
	@ dirnum ++
	end    
