#!/bin/sh

aos helord5 --data ./dist/index.html \
 --tag-name FrameID --tag-value {default html tx id}  \
 --tag-name Content-Type --tag-value text/html
 
 