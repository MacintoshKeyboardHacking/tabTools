#!/bin/bash


# folder to prune
LOC=$*


# tunables...
# number to keep
# by res?
# remove @.*'s


echo "Processing folder $LOC"

# the depth spec makes sure you don't clobber a whole collection by mistake...
findSpec="-mindepth 1 -maxdepth 1"

echo
echo duplicates per channelID...
# sort into channelbins if available (ie: 1st tier import)
( \
for srcFile in `(find $LOC $findSpec -type f -name "*@*-*.mp?" ! -size 0) |sort`; do
       	ripChan=`echo $srcFile |sed -e "s/^.*@[0-9]*-\([0-9]*\)\.mp.$/\1/"`
	mkdir -p $LOC/$ripChan/
	mv -n $srcFile $LOC/$ripChan/
	echo $ripChan/$srcFile
done \
) | cut -d\@ -f1 |sort |uniq -dc


echo
# sort into resolutionbins (ie: 2nd tier folddown)


# truncate on 1st tier import as placeholder

for srcDir in `(find $LOC $findSpec -type d) |sort`; do
	(find $srcDir $findSpec -type f) |grep -v S00E00 |sed -e "s/^\(.*-S[0-9][0-9]E[0-9][0-9]\)[-_].*/\1/"|grep -v ^$ | sort |uniq -d \
	|awk {'print "ls -S \""$0"\"*.mp? |tail -n+2 |xargs -d\\\\n echo truncate -s0"'} |bash|bash
#
done


#	(find $srcDir $findSpec -type f) |grep -v S00E00 |sed -e "s/@[0-9]*-/@*-/"|sort |uniq -d \
#	|awk {'print "ls -S "$0" |tail -n+2 |xargs -d\\\\n echo truncate -s0"'}


mv -n $LOC/*/*.mp? $LOC/


# hide zero-length files for samba
find $LOC -type f -size 0 -name "*.mp?"|xargs chmod o+x

exit
