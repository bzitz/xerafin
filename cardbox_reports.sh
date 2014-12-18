#!/bin/bash

sid=$((3600*24)) # seconds in a day
DAYS=10

while [ 1 ] ; do

clear
echo Reports Available:
echo "1 - Total Cards"
echo "2 - Total Cards (by cardbox)"
echo "3 - Total Cards (by length)"
echo "4 - Cards by Day, Next $DAYS Days"
echo "5 - Cards by Day, Next $DAYS Days (one cardbox)"
echo "6 - Cards by Hours, 24 hour period"
echo "7 - Cards by Hours, 24 hour period (one cardbox)"
echo "8 - Date of Next Five Cards (one cardbox)"
echo "9 - Date of Next Ten Cards"
echo "0 - Exit"
echo

read report
case "$report" in 
	'0' )
		exit 0
		;;
	'1' )
		sqlite3 q.db "select count(*) from questions where cardbox is not null"
		echo "(press enter)"
		read dummy
		;;
	'2' ) 
		sqlite3 q.db "select cardbox, count(*) from questions where cardbox is not null group by cardbox order by cardbox"
		echo "(press enter)"
		read dummy
		;;
	'3' )
		sqlite3 q.db "select length(question), count(*) from questions where cardbox is not null group by length(question) order by length(question)"
		echo "(press enter)"
		read dummy
		;;
	'4' )
		now=$(date +%s)
		sqlite3 q.db "select (next_scheduled-$now)/$sid, count(*) from questions where cardbox is not null and (next_scheduled-$now)/$sid < $DAYS group by (next_scheduled-$now)/$sid order by (next_scheduled-$now)/$sid"
		echo "(press enter)"
		read dummy
		;;
	'5' )
		now=$(date +%s)
		echo "Enter cardbox to search"
		read cb
		sqlite3 q.db "select (next_scheduled-$now)/$sid, count(*) from questions where cardbox = $cb and (next_scheduled-$now)/$sid < $DAYS group by (next_scheduled-$now)/$sid order by (next_scheduled-$now)/$sid"
		echo "(press enter)"
		read dummy
		;;
	'6' )
		now=$(date +%s)
		echo "Enter day to search (today is 1)"
		read dy
		hr=$((dy*24))
		sqlite3 q.db "select (next_scheduled-$now)/3600, count(*) from questions where cardbox is not null and (next_scheduled-$now)/3600 >= ($hr-24) and (next_scheduled-$now)/3600 < $hr group by (next_scheduled-$now)/3600 order by (next_scheduled-$now)/3600"
		echo "(press enter)"
		read dummy
		;;
	'7' )
		now=$(date +%s)
		echo "Enter day to search (today is 1)"
		read dy
		hr=$((dy*24))
		echo "Enter cardbox to search"
		read cb
		sqlite3 q.db "select (next_scheduled-$now)/3600, count(*) from questions where cardbox = $cb and (next_scheduled-$now)/3600 >= ($hr-24) and (next_scheduled-$now)/3600 < $hr group by (next_scheduled-$now)/3600 order by (next_scheduled-$now)/3600"
		echo "(press enter)"
		read dummy
		;;
	'8' )
		now=$(date +%s)
		echo "Enter cardbox to search"
		read cb
		for date in $(sqlite3 q.db "select next_scheduled from questions where cardbox = $cb order by next_scheduled limit 5") 
		do
			date -r $date
		done
		echo "(press enter)"
		read dummy
		;;
	'9' )
		now=$(date +%s)
		for date in $(sqlite3 q.db "select next_scheduled from questions where cardbox is not null order by next_scheduled limit 10") 
		do
			date -r $date
		done
		echo "(press enter)"
		read dummy
		;;
	* )
		echo Hunh?
		echo "(press enter)"
		read dummy
esac	

done
