#!/bin/sh

aos helord2 --data ./dist/index.html \
 --tag-name FrameID --tag-value {default html tx id}  \
 --tag-name Content-Type --tag-value text/html
 
 