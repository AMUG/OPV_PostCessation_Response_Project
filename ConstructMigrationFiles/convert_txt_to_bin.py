from struct import pack
from sys import argv

filename = argv[1]
outfilename = argv[2]
route = argv[3] 

fopen=open(filename)
fout=open(outfilename + '_' + route + '_migration.bin','wb')
net={}
net_rate={}

MAX_DESTINATIONS_BY_ROUTE = {'local': 8,
                             'regional': 30,
                             'sea': 5,
                             'air': 60}

for line in fopen:
    s=line.strip().split()
    ID1=int(float(s[0]))
    ID2=int(float(s[1]))
    rate=float(s[2])
    #print(ID1,ID2,rate)
    if ID1 not in net:
        net[ID1]=[]
        net_rate[ID1]=[]
    net[ID1].append(ID2)
    net_rate[ID1].append(rate)

for ID in net:
    ID_write=[]
    ID_rate_write=[]
    
    if len(net[ID]) > MAX_DESTINATIONS_BY_ROUTE[route]:
        print('There are %d destinations from ID=%d.  Trimming to %d (%s migration max) with largest rates.' % (len(net[ID]), ID, MAX_DESTINATIONS_BY_ROUTE[route], route))
        dest_rates = zip(net[ID], net_rate[ID])
        dest_rates.sort(key=lambda tup: tup[1], reverse=True)
        trimmed_rates = dest_rates[:MAX_DESTINATIONS_BY_ROUTE[route]]
        #print(len(trimmed_rates))
        (net[ID], net_rate[ID]) = zip(*trimmed_rates)
        #print(net[ID], net_rate[ID])

    for i in xrange(MAX_DESTINATIONS_BY_ROUTE[route]):
        ID_write.append(0)
        ID_rate_write.append(0)
    for i in xrange(len(net[ID])):
        ID_write[i]=net[ID][i]
        ID_rate_write[i]=net_rate[ID][i]
    s_write=pack('L'*len(ID_write), *ID_write)
    s_rate_write=pack('d'*len(ID_rate_write),*ID_rate_write)
    fout.write(s_write)
    fout.write(s_rate_write)

fopen.close()
fout.close()
    
