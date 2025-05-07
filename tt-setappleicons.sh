#!/bin/bash -v
# run from a Mac to generate folder icons (the extract script handles windows already)

FOLDER=$1
convert $FOLDER.jpg -background transparent -filter catrom -resize 256x224 -gravity center -extent 256x256+0-16 +repage $FOLDER.png
rm icns.png
cp $FOLDER\.png icns.png
sips -i icns.png
DeRez -only icns icns.png > icns.rsrc
Rez -append icns.rsrc -o $FOLDER$'/Icon\r'
SetFile -a C $FOLDER/
SetFile -a V $FOLDER$'/Icon\r'
