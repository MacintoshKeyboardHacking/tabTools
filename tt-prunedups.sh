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
	(find $srcDir $findSpec -type f) |grep -v S00E00 |sed -e "s/^\(.*-S[0-9][0-9]E[0-9][0-9]\).*/\1/"|grep -v ^$ | sort |uniq -d \
	|awk {'print "ls -S \""$0"\"*.mp? |tail -n+2 |xargs -d\\\\n echo truncate -s0"'} |bash|bash
#
done


#	(find $srcDir $findSpec -type f) |grep -v S00E00 |sed -e "s/@[0-9]*-/@*-/"|sort |uniq -d \
#	|awk {'print "ls -S "$0" |tail -n+2 |xargs -d\\\\n echo truncate -s0"'}


mv -n $LOC/*/*.mp? $LOC/



# hide zero-length files for samba
find $LOC -type f -size 0 -name "*.mp?"|xargs chmod o+x



exit




#	ripVid=`echo $ripRes |sed -e "s/.*\ Video\:\ \(.*\)\ *Stream\ .*/\1/"`
#	ripAud=`echo $ripRes |sed -e "s/.*\ Audio\:\ \(.*\)$/\1/"`
#	echo $ripVid |sed -e "s/ .*yuv420p\(.*)\), \(.*\]\),.*, \(.*fps\).*/ \2 \1 \3/"
#	ripExt=`echo $ripChan|sed -e s/^.*\\\.//`




cd $LOC

for file in `find $LOC -type f -name "*.mp?" ! -size 0 |sort`; do
	fExt=`echo $file |sed -e "s/.*\.//"`		# existing file extension
	fOld=`echo $file |sed -e "s/\(.*\)\.mp./\1/"`	# existing file basename


	fNew=`echo $fOld |sed -e "s/\(.*\)@.*/\1/"`	# clean basename (no @)
#	mv -n "$file" "$fNew.$fExt"


done
exit

#	find $LOC -type f -name "*@*-$ripType" ! -size 0 |grep -v S00E00 |sed -e "s/@[0-9]*-/@*-/"|sort |uniq -d \
#		|awk {'print "ls -S "$0" |tail -n+2 |xargs -d\\\\n echo truncate -s0"'}
#find . -type f -name "*.mp?" ! -size 0| sed -e s/[-_]/?/g|sort|uniq -d|awk {'print "ls -S "$0"|tail -n+2"'}|bash

#for ripType in `(find $LOC -type f -name "*@*-*.mp?"; find $LOCALT -type f -name "*@*-*.mp?") |cut -d\@ -f2|cut -d\- -f2-|grep -v S00E00|sort|uniq`; do

	# ignore PBS for right now, pledge drive...
	if ( [ "$ripType" == "42852.mpg" ] || [ "$ripType" == "42860.mpg" ] || [ "$ripType" == "42864.mpg" ] || [ "$ripType" == "66385.mpg" ] || [ "$ripType" == "66389.mpg" ] \
	|| [ "$ripType" == "42852.mp4" ] || [ "$ripType" == "42860.mp4" ] || [ "$ripType" == "42864.mp4" ] || [ "$ripType" == "66385.mp4" ] || [ "$ripType" == "66389.mp4" ] ); then

#find /mnt/a/tsout -type f -name *\ *|strings|rev|cut -d\. -f2-|rev|_despacefiles|sed -e "s/\(.*\)_\[\(........-....\)\]\(.*\)/\1\3@\2/" -e "s/'\ /.ts\' /" -e "s/$/.ts/" -e "s/\ \//\ \//" -e "s/ \.\// \//"|bash
#find /mnt/a/tsout -type f -name *\ *.ts|strings|rev|cut -d\. -f2-|rev|_despacefiles|sed -e "s/\(.*\)_\[\(........-....\)\]\(.*\)/\1\3@\2/" -e "s/'\ /.ts\' /" -e "s/$/.ts/" -e "s/\ \//\ \//" -e "s/ \.\// \//"|bash  


EXT=mp?


LOC=$*

#keepNum=1


cd $LOC

#for ripType in `(find $LOC -type f -name "*@*-*.mp?"; find $LOCALT -type f -name "*@*-*.mp?") |cut -d\@ -f2|cut -d\- -f2-|grep -v S00E00|sort|uniq`; do
for ripType in `(find $LOC -type f -name "*@*-*.mp?") |cut -d\@ -f2|cut -d\- -f2-|grep -v S00E00|sort|uniq`; do
	ripExt=`echo $ripType|sed -e s/^.*\\\.//`
	echo \# $ripType provider identified

	(find $LOC -type f -name "*@*-$ripType" ! -size 0) \
	|grep -v S00E00 |sed -e "s/@[0-9]*-/@*-/"|sort |uniq -d \
	|awk {'print "ls -S "$0" |tail -n+2 |xargs -d\\\\n echo truncate -s0"'}

	echo
	fi
done





#	find $LOC -type f -name "*@*-$ripType" ! -size 0 |grep -v S00E00 |sed -e "s/@[0-9]*-/@*-/"|sort |uniq -d \
#		|awk {'print "ls -S "$0" |tail -n+2 |xargs -d\\\\n echo truncate -s0"'}
#	fi
#!/bin/bash
rm -f /tmp/FIXMYDATE
find /home/hts/ -mindepth 1 -maxdepth 1 -type d -exec stat -c 'touch --no-create -d @%Y "%n"' {} \; |sort > /tmp/FIXMYDATE
find /home/hts/ -mindepth 2 -maxdepth 2 -type f -name "*.mkv" -mtime +9 -print0|xargs -0 -r rm
find /home/hts/ -mindepth 2 -maxdepth 2 -type f -name "*.mkv" -mtime +2 -size -10000 -print0|xargs -0 -r rm
(find /home/hts/ -mindepth 2 -maxdepth 2 -type f -name "*.mkv"|rev|cut -d\/ -f2-|rev|sort|uniq|awk {'print "ls -t \""$0"/\"*.mkv|tail -n+11"'})|bash|awk {'print "rm \""$0"\""'}|bash
find /home/hts/ -type d -print0|xargs -0 rmdir
bash < /tmp/FIXMYDATE
rm -f /tmp/FIXMYDATE
#find /home/hts/ -mtime +1 -type d -print0|xargs -0 rmdir
#!/bin/bash
FILE=$*
CMD=$0

cd /tmp/
cd /mnt/a/inactive/
if [ ! "$FILE" ]; then
	echo Main run, identify candidates.

	# old naming convention, taken directly from hdhomerun filesystem
	find . -type f -name "*.mpg"|grep -v "S00E00" | cut -d\[ -f1|rev|cut -b2-|rev|sort|uniq -d|awk {'print "'$CMD' \""$0"\""'}|bash -v

	# new naming convention, _deletespaces
	find /mnt/a/inactive -type f -name "*S[0-9][0-9]E[0-9][0-9]*mpg" | grep -v "S00E00" | sed -e "s/\(.*S[0-9][0-9]E[0-9][0-9]\).*/\1/" | sort|uniq -d|awk {'print "'$CMD' \""$0"\""'}|bash -v

	find /mnt/a/tsout -type f -name "*S[0-9][0-9]E[0-9][0-9]*ts" | grep -v "S00E00" | sed -e "s/\(.*S[0-9][0-9]E[0-9][0-9]\).*/\1/" | sort|uniq -d|awk {'print "'$CMD' \""$0"\""'}|bash -v

else
	if [ ! -f "$FILE.active" ]; then
		ls -S "$FILE"*.mpg "$FILE"*.ts |tail -n+2|xargs -d\\n echo remove

# WATCH OUT THE $FILE.active match was failing because trailing space....

		ls -S "$FILE"*.mpg "$FILE"*.ts |tail -n+2|xargs -d\\n rm
	else
		echo nope, $FILE still active
	fi
fi
#for tablo: find . -type f -name "*ts"|cut -d\@ -f2-|cut -d\- -f1|sort|uniq -d|awk {'print "ls -S */*@"$0"-*.ts |tail -n+2|xargs -d\\\\n rm"'}|bash -v
#more tablo: find . -type f -name "*@*-*.ts"|cut -d\@ -f1|grep -v S00E00 | sort|uniq -d|awk {'print "ls -S "$0"@*.ts |tail -n+2|xargs -d\\\\n rm"'}|bash -v
#find . -type f -name "*@*-*.ts"|cut -d\@ -f1|grep -v S0x0E00 | sort|uniq -d|awk {'print "ls -S \""$0"@\"*.ts |tail -n+2|xargs -d\\\\n rm"'}|bash
