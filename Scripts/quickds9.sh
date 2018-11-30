#!/bin/bash

#Andrew Sosanya, @andrew.sosanya.20@dartmouth.edu , NuStar WAVE Research Fellow

while true; do 

    read -p "Enter Source" folder
    read -p "Enter ObsID" id 

    cd /Users/Anne/Documents/Caltech/ReducedDec/$folder/$id/ULX

    
    ds9 pn.fits
done