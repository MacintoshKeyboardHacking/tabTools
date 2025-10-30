#!/usr/bin/python3

# (251030)
# extracts recording metadata from Tablo.db
#
# for demo and discussion see my livestreams, https://www.youtube.com/@MacintoshKeyboardHacking/streams

import re
import os
import sqlite3
import sys

tabloHD="/mnt/b"
tabloDB="/tmp/Tablo.db"

outdir="/mnt/a/tv/tsout"

if ( not sys.argv[1:] ):
	print("fail, need a recID to extract")
	exit()

recID=sys.argv[1]
recordingId=recID

con = sqlite3.connect(tabloDB)
cur = con.cursor()

for tRid in cur.execute("SELECT distinct title,episodeTitle,seasonNum,episodeNum,origAirDate,stationID,parentID FROM Recording where ID="+recID):
    title, episodeTitle, seasonNum, episodeNum, origAirDate, stationID, parentID=tRid
#    my_regex = r"\b(?=\w)" + re.escape(TEXTO) + r"\b(?!\w)"
#xiepisodeT

    si=str(parentID)
    for iSub in cur.execute("SELECT distinct ID,text3 from image where num2="+si+" and text3=\'cover\';"):
        myimg, tmp=iSub


    title=re.sub(" ","_",title)
    title=re.sub(":","-",title)
    title=re.sub(";","-",title)
    title=re.sub("\?","-",title)
    title=re.sub("\/","-",title)
    title=re.sub("&","-",title)
    title=re.sub(",","",title)
    title=re.sub("@","",title)
    title=re.sub("'","",title)
    title=re.sub("\"","",title)
    title=re.sub("\.","",title)
    title=re.sub("_-","-",title)
    title=re.sub("-_","-",title)
    title=re.sub("--","-",title)
    title=re.sub("__","_",title)
    title=re.sub("_-_","-",title)
#    
    episodeTitle=re.sub(" ","_",episodeTitle)
    episodeTitle=re.sub(":","-",episodeTitle)
    episodeTitle=re.sub(";","-",episodeTitle)
    episodeTitle=re.sub("\?","-",episodeTitle)
    episodeTitle=re.sub("\/","-",episodeTitle)
    episodeTitle=re.sub("&","-",episodeTitle)
    episodeTitle=re.sub(",","",episodeTitle)
    episodeTitle=re.sub("@","",episodeTitle)
    episodeTitle=re.sub("'","",episodeTitle)
    episodeTitle=re.sub("\"","",episodeTitle)
    episodeTitle=re.sub("\.","",episodeTitle)
    episodeTitle=re.sub("_-","-",episodeTitle)
    episodeTitle=re.sub("-_","-",episodeTitle)
    episodeTitle=re.sub("--","-",episodeTitle)
    episodeTitle=re.sub("__","_",episodeTitle)
    episodeTitle=re.sub("_-_","-",episodeTitle)

    origAirDate=re.sub("T.*|-","",origAirDate)

    sn=""
    if (int(seasonNum)): sn="S"+str(seasonNum)
    if (int(seasonNum)<10): sn="S0"+str(seasonNum)

    en=""
    if (int(episodeNum)): en="E"+str(episodeNum)
    if (int(episodeNum)<10): en="E0"+str(episodeNum)

    FILE=title
    if (int(seasonNum+episodeNum)):
        FILE+="-"+sn+en
        if origAirDate:
            FILE+="_"+origAirDate
    else:
        if origAirDate:
            FILE+="-"+origAirDate


    if episodeTitle:	FILE+="-"+episodeTitle

    BASEFILE=FILE
    FILE=FILE+"@"+str(recID)
    if stationID: FILE=FILE+"-"+str(stationID)

    outfile=outdir+"/"+title+"/"+FILE+".mp4"
    print (outfile)

    outjpg=outdir+"/"+title+".jpg"

    #    if (myimg):
    #    cmd="curl -L --url http://198.19.4.61:8887/images/"+str(myimg)+" >"+outjpg
    #    print (cmd)

con.close()
###############################################
# mv -n 'What_If-Planet_Earth-S01E12_-Earth'$'\342\200\231''s_Extremes@640963-999042505.mp4' 'What_If-Planet_Earth-S01E12_-Earths_Extremes@640963-999042505.mp4'
#-rw-rw-rw-  1 root root 1139093399 Apr 20 03:22 'Posthuman-S00E00_20241111-Robots_'$'\342\200\224''_The_Aliens_We_Made@123628-123870.mp
#640961: /mnt/a/tsout/What_If-Planet_Earth/What_If-Planet_Earth-S01E12-Earth<E2><80><99>s_Extremes@640961-999042505.mp4; ffmpeg... MP4Bo
