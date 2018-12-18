"""Calculates the false alarm rate
@Andrew Sosanya, WAVE Astrophyscs Fellow at Caltech Space radiation Lab/NuStar, andrew.sosanya.20@dartmouth.edu"""
from statistics import stdev


source = input("Source")
obs_id = input("Observation ID?")
sim = open("/Users/Anne/Documents/Caltech/ReducedDec/" +source + "/" +obs_id+"/ULX/sim/8keV", 'r')
counter = 0 

for i in  sim.readlines():
	if float(i.split()[3]) > 12.0: counter+=1

sim.seek(0)

data = [float(x.split()[3]) for x in sim.readlines()]

print (counter)
d = stdev(data)
print (d)
print (len(data))