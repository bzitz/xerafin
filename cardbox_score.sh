#!/bin/bash

total=0

for row in $(sqlite3 q.db "select cardbox, count(*) from questions where next_scheduled is not null group by cardbox order by cardbox")
do

cb=$(echo $row | cut -d '|' -f 1)
cnt=$(echo $row | cut -d '|' -f 2)
total=$(($total+(cb*cnt)))

#echo "Cardbox $cb	$cnt"

done

#echo "Total Score: 	$total"
echo $total

