#!/bin/bash

TMP_FILE=files.txt

if [ ! -d "./in" ] || [ ! -d "./out" ] ; then
	echo "Usage - in current directory create two sub-directories 'in' and 'out'. Save original videos in 'in' and edited vieos in 'out'"
	echo "Application will search all the files wioth same name in both directories. It will copy metadata from 'in' and audio/video tracks from 'out'"
	echo "And finally - it will save resulting files to current directories (will overwrite without prompting)."
	exit 0
fi

FFMPEG_FOUND=`which ffmpeg | wc -l`

if [ "$FFMPEG_FOUND" -eq 0 ] ; then
	echo "Required tool ffmpeg not found."
#	exit 1
fi


find .in -name "*.mp4" > $TMP_FILE

while read FILENAME; do

	FILE=`basename $FILENAME`
	echo "ffmpeg -i ./in/${FILE} -i ./out/${FILE} -map 1 -map_metadata 0 -c copy ./${FILE}"

done < ${TMP_FILE}

echo Finihed processing
