function getNext {
#send in new cardbox
now=$(date +%s)
DAY=$((3600*24))
rnd=$(( ($RANDOM*$RANDOM)%$DAY))
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

function wrong {

    tput setaf 1
    echo "		Incorrect!"
    tput sgr0

    current=$(date +%s)
    next=$(($current + (3600*15) + $RANDOM ))
    sqlite3 xerafin.db "update questions set cardbox = 0, next_scheduled = $next, incorrect = incorrect + 1, streak = 0 where question = \"$1\""
    echo Next $(date -r $next)
    echo 
    sqlite3 a.db "select front_hooks, lexicon_symbols, word, back_hooks, definition from words where alphagram = \"$1\"" | while read row
    do
       row=$(echo "$row" | sed -e 's/|/. /')
#comment the next line out with no #'s
       row=$(echo "$row" | sed -e 's/|//')
       row=$(echo "$row" | sed -e 's/|/ /')
       row=$(echo "$row" | sed -e 's/|/: /')
       row=$(echo "$row" | tr -d '\n')
#       echo "DEBUG '$row'"
       echo "$row" | sed -e 's/:.*//' | ./display_word
       echo "$row" | sed -e 's/[^:]*//'
	
#	if (echo $row | grep -q [A-Z]#); then
#		tput setaf 6
#		echo -n $(echo $row | sed -e 's/:.*//')
#		tput sgr0
#		echo $row | sed -e 's/[^:]*//'
#	else
#		tput setaf 5
#		echo -n $(echo $row | sed -e 's/:.*//')
#		tput sgr0
#		echo $row | sed -e 's/[^:]*//'
#	fi
    done
    echo 

# display extensions
if [ "$SHOW_EXTENSIONS" = "YES" ] ; then
sqlite3 a.db "Select word from words where alphagram = \"$1\"" | while read row
  do
    sqlite3 a.db "Select lexicon_symbols, word from words where word like '%$row%' and length(word) > length('$row')+1 limit 15" | while read row2
    do
    echo ". $row2" | sed -e 's/|//' | ./display_word
  done
  echo

done

fi

}  # end function wrong

function right {

     tput setaf 2
     echo "		Correct!"
     echo

     current=$(date +%s)
     curr_cbx=$2
     next_cbx=$((curr_cbx+1))
     next_sch=$(getNext $next_cbx)

     sqlite3 xerafin.db "update questions set cardbox=$next_cbx, next_scheduled=$next_sch, correct=correct+1,streak=streak+1,last_correct=$current where question=\"$1\""

     echo New Cardbox $next_cbx
     echo Next Sched $(date -r $next_sch) 
     echo 

    sqlite3 a.db "select front_hooks, lexicon_symbols, word, back_hooks, definition from words where alphagram = \"$1\"" | while read row
    do
       row=$(echo "$row" | sed -e 's/|/. /')
#comment the next line out with no #'s
       row=$(echo "$row" | sed -e 's/|//')
       row=$(echo "$row" | sed -e 's/|/ /')
       row=$(echo "$row" | sed -e 's/|/: /')
       row=$(echo "$row" | tr -d '\n')
#       echo "DEBUG '$row'"
       echo "$row" | sed -e 's/:.*//' | ./display_word
       echo "$row" | sed -e 's/[^:]*//'

    done

# display extensions
if [ "$SHOW_EXTENSIONS" = "YES" ] ; then
sqlite3 a.db "Select word from words where alphagram = \"$1\"" | while read row
  do
    sqlite3 a.db "Select lexicon_symbols, word from words where word like '%$row%' and length(word) > length('$row')+1 limit 15" | while read row2
    do
    echo ". $row2" | sed -e 's/|//' | ./display_word
  done
  echo

done
fi
} # end function right

