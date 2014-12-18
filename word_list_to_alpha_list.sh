#!/bin/bash

## grep -o . munges unicode vowels
## DO NOT USE THIS with Norwegian words
cat $1 | tr [:lower:] [:upper:] | while read line 
do
echo $line | grep -o . | sort | tr -d '\n' 
echo
done | sed -e '/^$/d' 

