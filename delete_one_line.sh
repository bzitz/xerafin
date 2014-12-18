#!/bin/bash

#
FILE=results.txt
if [ -n $1 ] 
then 
	LINE=$1
else

cat -n $FILE
echo -n "Delete line: "
read LINE

fi

ex $FILE -c "${LINE}d" -c "wq"

exit 0

