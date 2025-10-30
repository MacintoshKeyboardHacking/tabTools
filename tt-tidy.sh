#!/bin/bash

PATH=/mnt/a/tabTools:$PATH


LOCKFILE=/tmp/tx2.lock
if [ -f $LOCKFILE ]; then exit 1; fi


LOCKFILE=/tmp/tabTool.lock
if [ -f $LOCKFILE ]; then exit 1; fi



cd /mnt/a/tv/tsout

for FOLDER in `find . -mindepth 1 -maxdepth 1 -type d`; do
	mkdir -p ../tscollect/$FOLDER
	cp -nv $FOLDER/folder.jpg ../tscollect/$FOLDER/
	chmod o+x ../tscollect/$FOLDER/folder.jpg
	cp -nv $FOLDER/folder.ico ../tscollect/$FOLDER/
	chmod o+x ../tscollect/$FOLDER/folder.ico
	cp -nv $FOLDER/desktop.ini ../tscollect/$FOLDER/
	chmod 777 ../tscollect/$FOLDER/desktop.ini
	chmod 555 ../tscollect/$FOLDER
done

find /mnt/a/tv/tsout -mindepth 1 -maxdepth 1 -type d|awk {'print "tt-codecrename.sh "$0'}|bash
find . -mindepth 2 -maxdepth 2 -type f -name "*mp?"| grep -v -e \( -e \) |awk {'print "mv -n \""$0"\" ../tscollect/"$0'}|bash
find . -type d|xargs rmdir
find . -type d|xargs rmdir
find . -type d|xargs rmdir
find . -type d|xargs rmdir

# a very conservative cleanup script that prunes each channel's recording independently
find /mnt/a/tv/tscollect -mindepth 1 -maxdepth 1 -type d|awk {'print "tt-prunedups.sh "$0'}|bash

### severe file erasure hazard!!!!!
# this one shouldn't find much
find /mnt/a/tv/tscollect -mindepth 2 -maxdepth 2 -type f -name "*@*.mp4" ! -size 0|cut -d\@ -f1|sort|uniq|awk {'print "ls -S "$0"@*.mp4 | tail -n+2"'}|grep -v -e \( -e \)|bash|grep -v -e \( -e \)|awk {'print "truncate -s0 \""$0"\""'}|bash  -v

# for each .mpg, check if we've got a better .mp4 option.  if so, nuke the .mpg
find /mnt/a/tv/tscollect -mindepth 2 -maxdepth 2 -type f -name "*@*.mpg" ! -size 0|cut -d\@ -f1|sort|uniq|awk {'print "ls -S "$0"@*.mp? | tail -n+2"'}|grep -v -e \( -e \)|bash|grep -v -e \( -e \)|awk {'print "truncate -s0 \""$0"\""'}|bash  -v

# an agressive library maintenance function:
# Once upon a time, my library got randomly corrupt.  I started over but kept the old files, because, something better than nothing... this search deletes obsoleted old files
#(find . -type f -name "*S[0-9][0-9]E[0-9][0-9][-_]*mp?" ! -size 0|grep -v -e \( -e \) -e \" -e \' -e "S00" -e "E00"|cut -d\/ -f3-|sort|cut -d\@ -f1|awk {'print "find /mnt/a/tv.bad/ -type f -name \""$0"\"*.mp? "'}|bash) | tee killem
#find . -type f -name "*.mp?" -size 0 -mtime +15 -print0|xargs -0 -r rm
###

# hide the 0 length files from Samba clients
find /mnt/a/tv/tscollect -type f -name "*.mp?" -size 0 | awk {'print "chmod o-x "$0'}
