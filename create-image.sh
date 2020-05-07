#!/bin/bash

BOXES=$(which boxes)
if [ -z "$BOXES" ]; then
    BOXES=./forward.sh
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCAL_DIR=$(basename $SCRIPT_DIR)
IMAGE_NAME="iomoss/$LOCAL_DIR"

echo -e "\n" \
        "Building image: '$IMAGE_NAME'\n" \
        "" | $BOXES -d stone |
echo -e "$(cat -)\n\n" \
        "" | $BOXES -d columns

docker build --tag=$IMAGE_NAME .

if [ $? -eq 0 ]; then
    echo -e "\n" \
            "Image built succesfully!\n" \
            "" | $BOXES -d stone
else
    echo -e "\n" \
            "Error: Image building failed.\n" \
            " - please check build log and try again.\n" \
            "" | $BOXES -d stone 1>&2
fi
