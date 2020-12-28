# -*- coding: utf-8 -*-
"""
Created on Wed Jul 17 09:36:56 2019

@author: Viney Kharbanda
"""

import numpy as np
import pandas as pd
#from pygeocoder import Geocoder
from uszipcode import SearchEngine, SimpleZipcode, Zipcode
if __name__=="__main__":
    
    df = pd.read_csv('OpenRefineCleaned.csv', sep=",")
	# list that will store calculated zip
    zipcalc=[]
	# intialize counters to 0
    matchcount=0
    notmatchcount=0
    notfound=0
    latmisscount=0
    nazipcount=0
    search = SearchEngine(simple_zipcode=True)
    for rowcount in range(0,len(df)):
        flag=0
        stateflag=0
		# if latitude/logitude is missing then zipcalc will be empty
        if(pd.isnull(df['y'][rowcount]) or pd.isnull(df['x'][rowcount])):
            latmisscount=latmisscount+1
            zipcalc.append("")
		# executes below when latitude/logitude is not empty
        else:
		# gets 30 mile radius list of zip codes
            data=search.by_coordinates(df['y'][rowcount], df['x'][rowcount],radius=50,returns=10)
			# if actual zipcode is empty count this as mismatch
            if(pd.isnull(df.zip[rowcount])):
                nazipcount=nazipcount+1
                notfound=notfound+1
                    #zipcalc.append(df.zip[rowcount])
				# is zipcode is empty and database was not able to find any zipcodes leave the zipcalc to empty
                if(len(data)==0):
                    zipcalc.append("")
                else:
				# if zipcode is empty but database is not then set zipcalc to closest zipcode
                    zipcalc.append(data[0].zipcode) 
            else:
				#if zipcode is found in database then loop through data t osee if zipcode is in 30mile radius of datbase data
                if(len(data)>0):
                    for datacount in range(0,len(data)):
                        if(data[datacount].zipcode==df.zip[rowcount]):
                            flag=1
                            zipcalc.append(data[datacount].zipcode)
                            break;
                     
                if((len(data)==0) or (flag==0)):
                    notfound=notfound+1
                   # zipcalc.append(df.zip[rowcount])
                    zipcalc.append("")
            
        if(zipcalc[rowcount]==df.zip[rowcount]):
            matchcount=matchcount+1
        else:
            notmatchcount=notmatchcount+1
    print("{} Rows had empty zip codes were found, {} zip codes were added for these rows in ZipcodeCalc Column" .format(nazipcount,nazipcount))
    print("{}  Mismatch between zip codes in data and zipcodes from latitude/logitude were found that were not empty. Our database was not able to find zip code for these" .format(notfound-nazipcount))
    df['ZipcodeCalc']=zipcalc
    df.to_csv('OpenRefineCleaned_pythonZipCodeCalcadded.csv',index=False)