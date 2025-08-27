#!/bin/bash

PATH=/mnt/a/tabTools:$PATH

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

find /mnt/a/tv/tscollect -mindepth 1 -maxdepth 1 -type d|awk {'print "tt-prunedups.sh "$0'}|bash
find /mnt/a/tv/tscollect -type f -name "*.mp?" -size 0 | awk {'print "chmod o-x "$0'}

find /mnt/a/tv/tscollect -mindepth 2 -maxdepth 2 -type f -name "*@*.mp4"|cut -d\@ -f1|sort|uniq|awk {'print "ls -S "$0"@*.mp4 | tail -n+2"'}|grep -v -e \( -e \)|bash|grep -v -e \( -e \)|awk {'print "rm \""$0"\""'}|bash
