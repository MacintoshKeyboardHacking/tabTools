#!/bin/bash
# more infos youtube "MacintoshKeyboardHacking release"

# tablo's IP - I've only tested on my hdmi4
TIP=198.19.4.60

# a read-write location to copy the database
DBF=/tmp/TabTest.db

# where to store GB's worth of temp files needed to remux with MP4Box
TMPD=/mnt/c/.cache/


MODE=DL


TBU=http://$TIP:18080/pvr/

# tmps
TMPF=$TMPD/tmpremux-`date +%s`.mp4
rm -f $TMPF

# you need to mount their ext4 and ln -s .. ... in the root
curl -sS --url $TBU/.../mnt/storage/Tablo.db -o $DBF

for recID in `curl -sS --url $TBU/rec/|grep ^\<tr|cut -d\" -f6|grep ^[0-9]*\/ |sed -e "s/\/$//" |sort -n`; do
	echo -n "$recID: "
	if $(curl -sS -fL $TBU/rec/$recID/snap_done &>/dev/null); then
		TT=(`tt-metaproc.py $recID`)

		FOLDER=`echo ${TT[0]} |sed -e "s/\(.*\)\/.*/\1/"`
		mkdir -p $FOLDER/

		FILE=${TT[0]}.mpg
		echo -n "$FILE: "

		if [ ! -f $FILE ]; then
		curl -sS -L --url http://$TIP:8887/images/${TT[1]} > $FOLDER/folder.jpg

		# windows folder icon
		convert $FOLDER/folder.jpg -background transparent -filter catrom -resize 256x224 -gravity center -extent 256x256+0-16 -define icon $FOLDER/folder.ico
		chmod 666 $FOLDER/folder.ico

	echo "[ViewState]
Mode=
Vid=
FolderType=Videos
Logo=folder.ico

[.ShellClassInfo]
IconResource=folder.ico,0" > $FOLDER/desktop.ini
chmod 777 $FOLDER/desktop.ini
chmod 555 $FOLDER/


	if [ $MODE == "ST" ]; then
		# had problems with Tablo server truncating connection with this
		urList=" -protocol_whitelist concat,http,tcp -i concat:"
		for b in `curl -sS --url $TBU/rec/$recID/segs/|grep MP2T|cut -d\" -f4|sort -n`; do
			urList+="$TBU/rec/$recID/segs/$b|"
		done

		tmp=`echo $urList|sed -e "s/|$//"`
		urList=$tmp

		echo -n "ffmpeg... "
		ionice -c3 nice nocache \
			ffmpeg -y -nostdin -hide_banner -loglevel info -err_detect ignore_err \
			-fflags +bitexact $urList \
			-map 0:v -map 0:a:0 -map 0:s? -c copy -strict -2 -movflags +use_metadata_tags -f mp4 $TMPF
				      #	&& \
	elif [ $MODE == "DL" ]; then
		echo "download from $TBU/rec/$recID/segs/"
		rm $TMPD/playlist.pl
		rm $TMPD/00*.ts
		for b in `curl -sS --url $TBU/rec/$recID/segs/|grep MP2T|cut -d\" -f4|sort -n`; do
#			curl ftp://server/dir/file[01-30].ext --user user:pass -O --retry 999 --retry-max-time 0 -C -
#			curl $TBU/rec/$recID/segs/$b -retry 999 --retry-max-time 0 -o $TMPD/$b -C -
#			wget -c $TBU/rec/$recID/segs/$b -O $TMPD/$b
			wget -q --limit-rate=30M --show-progress --retry-connrefused -c $TBU/rec/$recID/segs/$b -O $TMPD/$b
			echo "file $TMPD/$b" >> $TMPD/playlist.pl
		done
		echo -n "ffmpeg... "
#			ffmpeg -y -nostdin -hide_banner -loglevel info -err_detect ignore_err \
		ionice -c3 nice nocache \
			ffmpeg -y -nostdin -hide_banner -loglevel warning -stats -err_detect ignore_err \
			-fflags +bitexact -f concat -safe 0 -i $TMPD/playlist.pl \
			-map 0:v -map 0:a:0 -map 0:s? -c copy -strict -2 -movflags +use_metadata_tags -f mp4 $TMPF
	else
		echo ftal no MODE
		exit 1
	fi
	

		(echo -n "MP4Box... " ; \
		ionice -c3 nice nocache \
			MP4Box -tmp $TMPD -isma -inter 250 -add $TMPF -new $FILE ) && \

		rm $TMPF
		fi

		echo "#done"
		sleep 1
	fi
done
