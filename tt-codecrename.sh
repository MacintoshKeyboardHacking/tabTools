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

# make sure files are what they say they are!
echo -n "codec rename "
for srcFile in `(find $LOC $findSpec -type f -name "*.mp?" ! -size 0) |sort`; do
	fExt=`echo $srcFile |sed -e "s/.*\.//"`			# existing file extension
	fOld=`echo $srcFile |sed -e "s/\(.*\)\.mp./\1/"`	# existing file basename
#	fNew=`echo $fOld |sed -e "s/\(.*\)@.*/\1/"`	# clean basename (no @)

	ripRes=`ffprobe -hide_banner "$srcFile" 2>&1|grep -e \#|tr -d \\\\n;echo`
	ripVid=`echo $ripRes |sed -e "s/^.*\ Video\:\ //" -e "s/\ .*//"`

	if [ "$ripVid" == "h264" ]; then
		fExt="mp4"
	elif [ "$ripVid" == "mpeg2video" ]; then
		fExt="mpg"
	else
		echo unknow codec $ripVid fail
		exit 1
	fi

	fOld+=".$fExt"
 	mv -n $srcFile $fOld


	# too crazy?  fix appledouble from linux
#	mv -n ._$srcFile ._$fOld # would work if we were PWD
	crap1=`echo $srcFile|rev|sed -e "s/\//_.\//"|rev`
	crap2=`echo $fOld|rev|sed -e "s/\//_.\//"|rev`
	mv -n $crap1 $crap2 &>/dev/null


	if [ $fOld == $srcFile ]; then
		echo -n :
	elif [ "$fExt" == "mp4" ]; then
		echo -n +
	else
		echo -n -
	fi
done
echo

