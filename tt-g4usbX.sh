#!/bin/bash

# (251030)
# extracts recordings from a directly connected Tablo filesystem
# I use a 1TB diskimage file on an SSD, which connects to my Tablo using a Raspberry Pi 4 in USB gadget mode
# I mount that same image, read-only, from the Pi to copy the content out.
#
# for demo and discussion see my livestreams, https://www.youtube.com/@MacintoshKeyboardHacking/streams

LOCKFILE=/tmp/tx2.lock

if [ -f $LOCKFILE ]; then date >> $LOCKFILE; exit 1; fi
date > $LOCKFILE
#touch $LOCKFILE

# 250425: remaining issues...
#	_- file naming, related issue with ( and )
#	interrupted recordings (better then nothing?) - multiple tsIDs
#	mpg/mp4 detect
#	

# where to mount the Tablo drive
TSRC=/mnt/b

umount $TSRC
mount -oro,norecovery $TSRC

# define for partial range
LASTID=0
MINAGE=0
#MINAGE=0

# cleanup
rm /tmp/pl*.txt

# tmps
TMPD=/mnt/c/.cache/

TMPF=$TMPD/tmpremux-`date +%s`.mp4
rm -f $TMPF

TDBF=/tmp/Tablo.db

# for a hacked t4g, we can download the current DB
#wget http://198.19.4.62/pvr/.../data/pcslip/mnt/storage/Tablo.db -O $TDBF
wget -q --limit-rate=30M --show-progress --retry-connrefused http://198.19.4.62/pvr/.../data/pcslip/mnt/storage/Tablo.db -O $TDBF

# otherwise, copy the backup DB
if [ $? -ne 0 ]; then
	cp $TSRC/db/Tablo.db $TDBF
fi


export TSLOC=$TSRC/rec

# completed 'segs' are HLS transport streams, select 24 hour old, marked done
#for TQ in `find "$TSLOC" -type f -mtime +$MINAGE -name snap_done |sed -e "s/.*\/\(.*\)\/snap_done/\1/" |sort -n |uniq |sort -n |uniq |grep -v ^$`; do

# mtime function above is not working...
for TQ in `find "$TSLOC" -type f -name snap_done |sed -e "s/.*\/\(.*\)\/snap_done/\1/" |sort -n |uniq |sort -n |uniq |grep -v ^$`; do
    echo -n "$TQ: "
    if [ "$TQ" -ge "$LASTID" ]; then

	# generate playlist _ DOUBLECHECK does need sort -n?
	find "$TSLOC/$TQ/segs" -type f -name "*.ts" |sort |awk {'print "file "$0'} > /tmp/pl$TQ.txt

	# pass to recID to database parser to generate filename
	FILE=`/mnt/a/tabTools/tt-g4meta.py $TQ`

	FOLDER=`echo $FILE|sed -e "s/^\(.*\/\).*/\1/"`
	mkdir -p $FOLDER
	if [ -d $FOLDER ]; then
		echo -n "$FILE; "

	FALT=`echo $FILE|sed -e "s/tsout\//tscollect\//"`
	FAL1=`echo $FALT|sed -e "s/mp4$/mpg/"`
	FAL2=`echo $FILE|sed -e "s/mp4$/mpg/"`

	if [ ! -f $FILE ] && [ ! -f $FALT ] && [ ! -f $FAL1 ] && [ ! -f $FAL2 ]; then
#	if [ ! -f $FILE ]; then
#	rm $FALT $FAL1 $FAL2

		echo -n "ffmpeg... "
		ionice -c3 nice nocache \
			ffmpeg -y -nostdin -hide_banner -loglevel error -err_detect ignore_err \
			-fflags +bitexact -f concat -safe 0 -i /tmp/pl$TQ.txt \
			-map 0:v -map 0:a:0 -map 0:s? -c copy -strict -2 -movflags +use_metadata_tags -f mp4 $TMPF &> /dev/null && \

		(echo -n "MP4Box... " ; \
		ionice -c3 nice nocache \
			MP4Box -tmp $TMPD -isma -inter 250 -add $TMPF -noprog -new $FILE &> /dev/null) && \

		rm $TMPF

		## RPi errata: either create 2X RAM worth of swap partition or do the following:
		## flush data to disk and cleanup ram, sometimes process runaway and consume swap
		# sync; echo 3 >/proc/sys/vm/drop_caches

		echo "#done"
		sleep 1
	else
		echo "#skip"
	fi
	fi
    fi
done

umount $TSRC
rm $LOCKFILE
exit

# previously, was using -fflags +genpts+discardcorrupt+bitexact, -avoid_negative_ts make_zero, -ss 0 on input.  -flags +global_header -movflags +faststart+use_metadata_tags for direct mp4 output, but it seems better to let MP4Box produce the final output.  ffmpeg is still needed to convert bitstream framing on input.

# there's still an issue with h265 input (fails completely?), and occasionally something about '32 bit' signed container timestamps 
# "[mp4 @ 0xe570d0] Application provided duration: 13872374798 / timestamp: 13917296878 is out of range for mov/mp4 format"
# but the output still works, surely can fix later if necessary

# I would prefer to just '-map 0' the whole input, but ffmpeg doesn't like the SCTE.35 commerical timing packets
#https://github.com/futzu/threefive/blob/master/threefive-ffmpeg.md;  -copyts -muxpreload 0 -muxdelay 0

#		ionice -c3 nice nocache /home/src/ffmpeg-5.1.6/ffmpeg -y -nostdin -hide_banner -loglevel error -fflags +genpts+discardcorrupt+bitexact -err_detect ignore_err -ignore_unknown -ss 0 -f concat -safe 0 -i /tmp/pl$TQ.txt -map 0:v -map 0:a -map 0:s? -c copy -movflags +faststart $FILE
