#!/bin/bash

if [ -z $1 ] ; then 
   echo Usage: $0 filename 
   exit 0
fi

./not_in_cardbox.sh $1 | while read word 
do
	echo "insert into custom_list values ('$word');" >> temp/tmp.sql
done

	sqlite3 q.db < temp/tmp.sql
	sqlite3 q.db "delete from custom_list where rowid not in (select max(rowid) from custom_list group by question)"
	sqlite3 q.db "delete from custom_list where question in (select alphagram from study_order where cardbox_flag = 1)"
	sqlite3 q.db "delete from custom_list where question in (select question from next_added)"

rm temp/tmp.sql

exit 0


