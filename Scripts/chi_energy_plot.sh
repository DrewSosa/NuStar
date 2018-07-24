#!/bin/bash
#Andrew Sosanya 2018 SURF/WAVE Student andrew.sosanya.20@dartmouth.edu

project="/Users/sosa/Documents/Caltech"

cd $project/Spectra
num=0
for filename in *; do
    #echo $(ls) #====ATTN #why does it skip over the pps directory?
    let "num++"
    cd $project/Spectra/$filename/pps
    echo $filename
    #convert files
    data="$(ls | grep "PN" | grep "tbabs")"



#    for file in *.dat; do
#     mv "$file" "$(basename "$file" .dat).txt"
#     done
echo $num
done




