#!/bin/bash

cat $1 | while read line 
do 
echo "$RANDOM $line"
done | sort -n | sed -e 's/[0-9]* //'

