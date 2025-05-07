#!/bin/bash
# more infos youtube/macintoshkeyboardhacking

# tablo's IP - I've only tested on my hdmi4
TIP=198.19.4.60

# a read-write location to copy the database
DBF=/tmp/TabTest.db

# where to store GB's worth of temp files needed to remux with MP4Box
TMPD=/mnt/c/.cache/




TBU=http://$TIP:18080/pvr/

# tmps
TMPF=$TMPD/tmpremux-`date +%s`.mp4
rm -f $TMPF

# you need to mount their ext4 and ln -s .. ... in the root
curl --url $TBU/.../mnt/storage/Tablo.db -o $DBF

for recID in `curl --url $TBU/rec/|grep ^\<tr|cut -d\" -f6|grep ^[0-9]*\/ |sed -e "s/\/$//" |sort -n`; do
	echo -n "$recID: "
	if $(curl -fsSL $TBU/rec/$recID/snap_done &>/dev/null); then
		TT=(`tt-metaproc.py $recID`)

		FOLDER=`echo ${TT[0]} |sed -e "s/\(.*\)\/.*/\1/"`
		mkdir -p $FOLDER/
		chmod 777 $FOLDER/

		FILE=${TT[0]}.mpg
		echo -n "$FILE: "

		if [ ! -f $FILE ]; then
		curl -L --url http://$TIP:8887/images/${TT[1]} > $FOLDER.jpg

		# windows folder icon
		convert $FOLDER.jpg -background transparent -filter catrom -resize 256x224 -gravity center -extent 256x256+0-16 -define icon $FOLDER/folder.ico
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

		urList=" -protocol_whitelist concat,http,tcp -i concat:"
		for b in `curl --url $TBU/rec/$recID/segs/|grep MP2T|cut -d\" -f4|sort -n`; do
			urList+="$TBU/rec/$recID/segs/$b|"
		done

		tmp=`echo $urList|sed -e "s/|$//"`
		urList=$tmp

		echo -n "ffmpeg... "
		ionice -c3 nice nocache \
			ffmpeg -y -nostdin -hide_banner -loglevel info -err_detect ignore_err \
			-fflags +bitexact $urList \
			-map 0:v -map 0:a:0 -map 0:s? -c copy -strict -2 -movflags +use_metadata_tags -f mp4 $TMPF  && \

		(echo -n "MP4Box... " ; \
		ionice -c3 nice nocache \
			MP4Box -tmp $TMPD -isma -inter 250 -add $TMPF -new $FILE ) && \

		rm $TMPF
		fi

		echo "#done"
		sleep 1
	fi
done
