#!/bin/bash

if read -t 0; then
    cat
else
    echo "$*"
fi
