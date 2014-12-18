#!/bin/bash

function getNext {
#send in new cardbox
now=$(date +%s)
DAY=$((3600*24))
string=$(echo $1 $2 | md5)
rnd=$(($(perl -le "print hex('$(echo ${string:0:7})')") % $DAY ))
#rnd=$(( ($RANDOM*$RANDOM)%$DAY))
# cardbox 1 = 3-5 days
case $1 in
1) NEXT=$((now + (3*DAY) + (2*rnd) ))
   ;;
2) NEXT=$((now + (5*DAY) + (4*rnd) ))
   ;;
3) NEXT=$((now + (9*DAY) + (6*rnd) ))
   ;;
4) NEXT=$((now + (15*DAY) + (10*rnd) ))
   ;;
5) NEXT=$((now + (23*DAY) + (14*rnd) ))
   ;;
6) NEXT=$((now + (50*DAY) + (20*rnd) ))
   ;;
7) NEXT=$((now + (75*DAY) + (30*rnd) ))
   ;;
8) NEXT=$((now + (130*DAY) + (40*rnd) ))
   ;;
9) NEXT=$((now + (300*DAY) + (60*rnd) ))
   ;;
*) NEXT=$((now + (430*DAY) + (100*rnd) ))
   ;;
esac
echo $NEXT
}

# for now let's assume any LAPSE sends it to cardbox 0
# in the future we can try to make this more sophisticated

touch l_wrong.txt
touch l_right.txt
rm l_wrong.txt
rm l_right.txt

if [ karatasi/l_cardbox.db -nt l_empty.db ] ; then
	echo "Getting file from Karatasi"
	cp l_empty.db l_backup.db
	cp karatasi/l_cardbox.db l_empty.db
fi
sqlite3 l_empty.db "update card set lapses=1, recalls=0 where data_s4 = 'x'"
sqlite3 l_empty.db "select data_s0 from card where recalls + lapses > 0" | while read alpha
do
LAPSES=$(sqlite3 l_empty.db "select lapses from card where data_s0 = '$alpha'")
if [ $LAPSES -gt 0 ] ; then

    current=$(date +%s)
    next=$(($current + (3600*15) + $RANDOM ))
    sqlite3 xerafin.db "update questions set cardbox = 0, next_scheduled = $next, incorrect = incorrect + 1, streak = 0 where question = \"$alpha\""
    echo Wrong: $alpha >> l_wrong.txt
else

     current=$(date +%s)
     curr_cbx=$(sqlite3 l_empty.db "select data_s3 from card where data_s0 = '$alpha'")
     next_cbx=$((curr_cbx+1))
     next_sch=$(getNext $next_cbx $alpha)
     echo Right: $alpha $next_cbx $(date -r $next_sch) >> l_right.txt

     sqlite3 xerafin.db "update questions set cardbox=$next_cbx, next_scheduled=$next_sch, correct=correct+1,streak=streak+1,last_correct=$current where question=\"$alpha\""
fi

done

sqlite3 xerafin.db "update questions set difficulty = 0"
sqlite3 l_empty.db "delete from card"


	
