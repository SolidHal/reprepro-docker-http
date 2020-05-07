#!/bin/bash

BOXES=$(which boxes)
if [ -z "$BOXES" ]; then
    BOXES=./forward.sh
fi

if [ $# -lt "3" ]; then
    echo -e "\n" \
            "Error: Missing an argument.\n" \
            "Usage: ./run.sh [CONFIGURATION_FOLDER] [WEBSERVER_PORT] [SSH_PORT]\n" \
            "" | $BOXES -d stone 1>&2
    exit -1
fi

CONFIG_FOLDER=$1
WEBSERVER_PORT=$2
SSH_PORT=$3

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCAL_DIR=$(basename $SCRIPT_DIR)
IMAGE_NAME="iomoss/$LOCAL_DIR"

echo -e "\n" \
        "Building image: '$IMAGE_NAME'\n" \
        "" | $BOXES -d stone |
echo -e "$(cat -)\n\n" \
        "Configuration from: '$CONFIG_FOLDER'\n" \
        "Webserver mapped to: '$WEBSERVER_PORT'\n" \
        "SSH daemon mapped to: '$SSH_PORT'\n" \
        "" | $BOXES -d columns

echo "Image built succesfully; starting the build command!"
docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -it $IMAGE_NAME
