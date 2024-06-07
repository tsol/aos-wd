#!/bin/sh

process_name=$1

if [ -z "$process_name" ]
then
    echo "Please provide the process name to create"
    exit 1
fi

if [ ! -e ./dist/index.html ]
then
    echo "Please build the project first"
    exit 1
fi

if [ ! -e ./blueprints/ui-library.lua ]
then
    echo "File ui-library.lua not found in blueprints folder"
    exit 1
fi

aos $process_name --data ./dist/index.html --load ./blueprints/ui-library.lua --tag-name Content-Type --tag-value text/html
 
 