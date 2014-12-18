#!/bin/bash

# $1 is a file with alphagrams
# only output the alphagrams which are NOT in cardbox

if [ -z $1 ] ; then
	echo Usage: not_in_cardbox.sh file
	exit 0
fi

cat $1 | while read word
do

IN_CARDBOX=$(sqlite3 q.db "select count(*) from questions where question = \"$word\" and next_scheduled is not null")

VALID_ALPHA=$(sqlite3 a.db "select count(*) from words where alphagram = \"$word\" ")

if [ $VALID_ALPHA -ne 0 ] && [ $IN_CARDBOX -eq 0 ] ; then
	echo $word
fi

done

exit 0

