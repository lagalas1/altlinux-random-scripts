#!/bin/bash
IFS=$'\n'
RABOTADIRECTORY=/opt/RABOTA1/
if [[ -d "$RABOTADIRECTORY" ]]; then
    echo "$RABOTADIRECTORY" not found
    exit 1
fi
FILES=$(find $RABOTADIRECTORY -name ".~lock*")

if [[ -n $FILES ]]; then
    for FILE in $FILES; do
        echo Removed "$FILE"
        rm "$FILE"
    done
    exit 0
else
    echo "nothing to remove"
    exit 0
fi
