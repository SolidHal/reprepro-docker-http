#!/bin/bash

CONFIG_FOLDER=$1
WEBSERVER_PORT=$2
SSH_PORT=$3

IMAGE_NAME="solidhal/reprepro"

echo -e "Configuration from: '$CONFIG_FOLDER'\n" \
        "Webserver mapped to: '$WEBSERVER_PORT'\n" \
        "SSH daemon mapped to: '$SSH_PORT'\n" \
        ""

echo "Image built succesfully; starting the build command!"
docker run -v $CONFIG_FOLDER:/srv/ -p $WEBSERVER_PORT:80 -p $SSH_PORT:22 -it $IMAGE_NAME
