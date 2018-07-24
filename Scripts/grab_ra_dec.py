"""Finds Counts within the table and records their observer IDs
@Andrew Sosanya, WAVE Astrophyscs Fellow at Caltech Space ra_listdiation Lab/NuStar, andrew.sosanya.20@dartmouth.edu"""


sources = open("/Users/sosa/Documents/Caltech/Positions/potential_sources.txt")

def get_ra_dec():
    tag = {}
    for name, obs_id, ra, dec in zip(name_list, id_list, ra_list, dec_list):
        if tag.has_key(obs_id): continue
        tag[obs_id] = name + ": "+ ra[:8]+ra[-4:]+"- " + dec[:8]+dec[-4:]+ "(" +obs_id +")"
    return tag

name_list = [x.split()[0] +" " + x.split()[1] for x in sources.readlines() if len(x.split()) > 4 if x.split()[0][0] != "S" if x.split()[0][0] != "J"]
sources.seek(0)
src_id = [x.split()[2] for x in sources.readlines() if len(x.split()) > 4 if x.split()[0][0] != "S" if x.split()[0][0] != "J"]
sources.seek(0)
id_list = [x.split()[3] for x in sources.readlines() if len(x.split()) > 4 if x.split()[0][0] != "S" if x.split()[0][0] != "J"]
sources.seek(0)
ra_list = [x.split()[4] for x in sources.readlines() if len(x.split()) > 4 if x.split()[0][0] != "S" if x.split()[0][0] != "J"] #put an if statement here to stop the errors..if len(x.split()) > 4
sources.seek(0)
dec_list = [x.split()[5] for x in sources.readlines() if len(x.split()) > 4 if x.split()[0][0] != "S" if x.split()[0][0] != "J"]
sources.seek(0)
counts = [x.split()[6].split("\n")[0] for x in sources.readlines() if len(x.split()) > 4 if x.split()[0][0] != "S" if x.split()[0][0] != "J"]


# potentials = [id_list[x] + " " + ra_list[x] + " " + dec_list[x]+ " " + counts[x] +"\n" for x in indices]
# xmmuploads  = [ra_list[x] + " " + dec_list[x] +"\n" for x in indices]
# ids = [id_list[x] + "\n" for x in indices]
# obsid.writelines(ids)

# for source in enumera_listte(potentials): print source
# potential_sources.writelines(potentials)
# xmm_upload.writelines(xmmuploads)





