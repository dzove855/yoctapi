#!/bin/bash

# We use the defaul main.sh from yosh

if [[ -f "/usr/share/yosh/main.sh" ]] 
then
    source /usr/share/yosh/main.sh
else
    echo "Yosh is missing!"
fi
