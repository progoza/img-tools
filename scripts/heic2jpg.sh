#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Error: provide the directory to search&covert images!"
    echo "Usage: heic2jpg.sh <directory>"
    echo "All HEIC files will be searched recusively and converted to JPG"
    exit 0
fi

DIR=$1

TMP_FILE=`mktemp`
TMP_FILE2=`mktemp`

find "$DIR" -type f -name "*.heic" | while read file; do
    dir=$(dirname -- "$file")
    base=$(basename -- "$file" .heic)
    mv -- "$file" "$dir/$base.HEIC"
done

find "$DIR" -name "*.HEIC" > $TMP_FILE

TOTAL_FILES=`cat $TMP_FILE | wc -l`
CNT=0

echo "Found $TOTAL_FILES files."
echo "Log :" > $TMP_FILE2

while read file; do
  FILENAME=$(dirname "${file}")/$(basename "$file" HEIC)
  NEW_FILENAME="$FILENAME"JPG
  magick "$file" "$NEW_FILENAME"

  exiftool '-FileCreateDate<DateTimeOriginal' '-FileModifyDate<DateTimeOriginal' "$NEW_FILENAME" >> $TMP_FILE2

  rm "$file"

  CNT=$(($CNT+1))
  PROGRESS_PREC=$(($CNT*1000/$TOTAL_FILES))
  PROGRESS_P=$(($PROGRESS_PREC/10))
  PROGRESS_D=$(($PROGRESS_PREC%10))
    
  echo -ne "Done ${PROGRESS_P}.${PROGRESS_D}%  "\\r
done < $TMP_FILE

rm $TMP_FILE

echo "Processed $CNT files." >> $TMP_FILE2
cat $TMP_FILE2 | grep -v "    1 image files updated"
rm $TMP_FILE2
