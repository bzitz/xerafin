#!/bin/bash

if [ -z $1 ] ; then
	echo Usage: add_words.sh word
	exit 0
fi

curdate=$(date +%s)
IN_CARDBOX=$(sqlite3 q.db "select count(*) from questions where question = \"$1\" and next_scheduled is not null")

date >> add_words.dat

if [ $IN_CARDBOX -ne 0 ] ; then
	echo $1 is already in cardbox >> add_words.dat
	exit 0
fi

VALID_ALPHA=$(sqlite3 a.db "select count(*) from words where alphagram = \"$1\" ")

if [ $VALID_ALPHA -eq 0 ] ; then
	echo $1 is not a valid alphagram >> add_words.dat
	exit 0
fi

sqlite3 q.db "delete from questions where question = \"$1\" "

sqlite3 q.db "insert into questions (question, correct, incorrect, streak, last_correct, difficulty, cardbox, next_scheduled) values (\"$1\", 0, 0, 0, null, 0, 0, $curdate)"
sqlite3 q.db "update study_order set cardbox_flag = 1 where alphagram = \"$1\""

echo $1 added to cardbox 0 >> add_words.dat
exit 0

