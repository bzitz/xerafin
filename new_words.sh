#!/bin/bash

cp NEW_WORDS nw.bck
if [ -z "$1" ] ; then
   echo Usage: new_words.sh number
   exit 0
fi

date >> added_today.dat

# this isn't quite right. 
# if we ask for 10 new words, and there are only 8
# in the file, this will give us 8, not 8 + 2 from the study list

if [ -s NEW_WORDS ] 
then

head -$1 NEW_WORDS | while read word
do
   ./add_word.sh $word
   echo $word >> added_words.dat
done

cat NEW_WORDS | sed -e "1,$1 d" > qqq
mv qqq NEW_WORDS

else
  x=0
  while [ $x -lt $1 ]
  do
      na=$(sqlite3 q.db "select count(*) from next_added")
      if [ $na -gt 0 ] ; then
	   word=$(sqlite3 q.db "select question from next_added limit 1")
           sqlite3 q.db "delete from next_added where question='$word'"
      else
      idx=$(sqlite3 q.db "select min(study_order) from study_order where cardbox_flag = 0")
      word=$(sqlite3 q.db "select alphagram from study_order where study_order = $idx")
	# cardbox_flag set to 1 in add_word.sh for all words
      fi
      ./add_word.sh $word
      echo $word >> added_words.dat
      x=$(($x+1))
  done
fi 

exit 0

