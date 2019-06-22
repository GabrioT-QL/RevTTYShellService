#!/bin/bash
if [ ! $1 ]; then
    echo "usage: $0 <port>"
    exit 1
fi

stty raw -echo
nc -lvp $1 
stty -raw echo
