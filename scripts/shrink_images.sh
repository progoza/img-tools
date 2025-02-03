#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Error: provide the directory to search&resize images!"
    echo "Usage: shrink <directory>"
    exit 0
fi

if [ ! -d "$1" ] ; then
    echo "Error: ${1} is not a directory."
    exit 1
fi


TMP_FILE=`mktemp`
TMP_FILE2=`mktemp`

echo "Finding images to shrink.."

find ${1} -iname "*.jpg" -size +2M > $TMP_FILE
TOTAL_FILES=`cat $TMP_FILE | wc -l`
CNT=0

echo "Found $TOTAL_FILES files."
echo "Log :" > $TMP_FILE2

while read FILENAME; do
    NEW_FILENAME=${FILENAME}-r.JPG

    magick "$FILENAME" -resize 50% "$NEW_FILENAME"
    exiftool '-FileCreateDate<DateTimeOriginal' '-FileModifyDate<DateTimeOriginal' "$NEW_FILENAME" >> $TMP_FILE2

    if [ -f "$NEW_FILENAME" ] ; then
      mv $NEW_FILENAME $FILENAME
    fi

    CNT=$(($CNT+1))
    PROGRESS_PREC=$(($CNT*1000/$TOTAL_FILES))
    PROGRESS_P=$(($PROGRESS_PREC/10))
    PROGRESS_D=$(($PROGRESS_PREC%10))
    
    echo -ne "\rDone ${PROGRESS_P}.${PROGRESS_D}%  "\\r

done < ${TMP_FILE}

echo "."
echo "Finished."
rm $TMP_FILE

echo "Processed $CNT files." >> $TMP_FILE2
cat $TMP_FILE2 | grep -v "    1 image files updated"
rm $TMP_FILE2

