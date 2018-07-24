#!/bin/bash

# The following commands will download selected data products.
#
# Note: The network utility wget is included with most
# systems.  To download wget or get more information visit the
# GNU website http://www.gnu.org/software/wget/wget.html
#
wget -q -nH --no-check-certificate --cut-dirs=6  -r -l0 -c -N -np -R 'index*'  -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/FTP/nustar/data/obs/00/3//30002150002/

# Total size of data product files local to the HEASARC system: 10 GB
# File sizes of remote data products are not available