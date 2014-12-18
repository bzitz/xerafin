#!/bin/bash

# Precondition: $1 is a number 
# Also -- if it is more than 500, don't add more than 500 words to the cardbox
# We don't want to go crazy here

due_now=$(sqlite3 xerafin.db "select count(*) from questions where next_scheduled < $(date +%s)")

if [  $1 -gt $due_now ] ; then
    if [ $1 -gt 500 ] ; then
		./ra_mobile 500
    else ./ra_mobile $1
    fi
fi

cat l_populate.sql | sed -e "s/WORDLIMIT/$1/" | sqlite3 q.db 
cp l_empty.db karatasi/l_cardbox.db

