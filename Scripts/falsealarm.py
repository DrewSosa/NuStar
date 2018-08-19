"""Calculates the false alarm rate
@Andrew Sosanya, WAVE Astrophyscs Fellow at Caltech Space radiation Lab/NuStar, andrew.sosanya.20@dartmouth.edu"""
from statistics import stdev

sources = open("/Users/Anne/Documents/Caltech/M32/sim/M32_Chandra/65kev")
counter = 0 

for i in  sources.readlines():
	if float(i.split()[3]) > 11: counter+=1

sources.seek(0)

data = [float(x.split()[3]) for x in sources.readlines()]

print (counter)
d = stdev(data)
print (d)
print (len(data))