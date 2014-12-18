#!/bin/bash

function store {

	while [ 1 ] ; do
	echo "You have $coins in the bank."
	echo "What would you like to buy?"
	echo
	cnt=$(sqlite3 xerafin.db "select count(*) from custom_list")
	if [ $cnt -ge 100 ] && [ $coins -ge 3 ] ; then 
		echo "1. 50 words from your Custom List. 3 coins"
		cnt=50
	elif [ $coins -ge 3 ] ; then
		echo "1. $cnt words from your custom list. 3 coins"
	else echo "Get more coins!"
		return 0
	fi
	echo
	read dummy
	case $dummy in
	1 ) 
	echo Purchasing Option One
	coins=$(($coins-3))
	sqlite3 xerafin.db "update piggy_bank set coins=$coins"
	sqlite3 xerafin.db "insert into next_added select question from custom_list limit $cnt"
	sqlite3 xerafin.db "delete from custom_list where question in (select question from next_added)"
	echo "Your next $cnt words added will be from your custom list."
	echo "Press enter to continue"
	read dummy
	unset dummy
	;;
	* ) return
	;;
	esac
	done

}

function getRank {

echo "$((100-$1)) left until the next."

}
	

function getNext {
#send in new cardbox
now=$(date +%s)
DAY=$((3600*24))
string=$( (echo $2 && date) | md5)
rnd=$(($(perl -le "print hex('$(echo ${string:0:7})')") % $DAY ))
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
# display_word outputs extraneous periods
       echo "$row" | sed -e 's/:.*//' | ./display_word | tr -d '.'
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
    echo ". $row2" | sed -e 's/|//' | ./display_word | tr -d '.'
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
       echo "$row" | sed -e 's/:.*//' | ./display_word | tr -d '.'
       echo "$row" | sed -e 's/[^:]*//'

    done

# display extensions
if [ "$SHOW_EXTENSIONS" = "YES" ] ; then
sqlite3 a.db "Select word from words where alphagram = \"$1\"" | while read row
  do
    sqlite3 a.db "Select lexicon_symbols, word from words where word like '%$row%' and length(word) > length('$row')+1 limit 15" | while read row2
    do
    echo ". $row2" | sed -e 's/|//' | ./display_word | tr -d '.'
  done
  echo

done
fi
} # end function right

function right_silent {

     current=$(date +%s)
     curr_cbx=$(sqlite3 xerafin.db "select cardbox from questions where question=\"$1\"")
     next_cbx=$((curr_cbx+1))
     next_sch=$(getNext $next_cbx $1)

     sqlite3 xerafin.db "update questions set cardbox=$next_cbx, next_scheduled=$next_sch, correct=correct+1,streak=streak+1,last_correct=$current where question=\"$1\""

} # end function right_silent

function wrong_silent {

    current=$(date +%s)
    next=$(($current + (3600*15) + $RANDOM ))
    sqlite3 xerafin.db "update questions set cardbox = 0, next_scheduled = $next, incorrect = incorrect + 1, streak = 0 where question = \"$1\""

} #end function wrong_silent

function setwhere {

	NOW=$(date +%s)
	# If there are fewer than 20 due, just show everything
	if [ $(sqlite3 xerafin.db "select count(*) from questions where next_scheduled < '$NOW'") -lt 20 ] ; then
		choice=1
	else
	echo
	echo
	echo "Which cards should appear in this quiz unit?"
	echo
	echo "0: return to main menu"
	echo "1: all cards"
	echo "2: cardbox < x"
	echo "3: due more recent than x days ago"
	echo "4: length < x"
	echo "5: cardbox = x and alphagram begins with y"
	echo "6: due exactly x days ago"
	echo "7: alphagram contains letter(s)"
	echo "8: cards due today"
	echo
	read -p " > " choice
	fi

	case "$choice" in

	"0" ) 

		mainmenu
		getquestions;;

	"2" )
		read -p "Enter x: " x
		where="cardbox < $x";;

	"3" )
	
		read -p "Enter x: " x
		DAYS_AGO=$((86400*$x))
		where="next_scheduled > $(($NOW - $DAYS_AGO))" ;;

	"4" )
		read -p "Enter x: " x
		where="length(question) < $x";;
	"5" )
		read -p "Enter x: " x
		read -p "Enter y: " y
		where="cardbox = $x and question like '$y%'";;
	"6" )
		read -p "Enter x: " x
		DAYS_AGO=$((86400*$x))
		where="next_scheduled < $(($NOW - $DAYS_AGO)) and next_scheduled > $(($NOW - $DAYS_AGO - 86400))";;
	"7" )
		read -p "Enter letter: " x
		where="question like '%$x%'";;
	"8" )
	
		where="next_scheduled > $(($NOW - 86400))" ;;
	* )
		where="1=1" ;;
	esac

} # end function setwhere

function aerolith {

clear
echo
echo "Exporting words to be quizzed on WordWalls at aerolith.org"

limit=501
echo "How many words should be exported? Default sorting used. Multiples of 50 work well. (Max 500)."
echo "Type main to return to the main menu"
until [ $limit -le 500 2> /dev/null ] && [ $limit -gt 0 2> /dev/null ]
do
read -p " > " limit
if [ "$limit" = "main" ] ; then return
fi
done

due_now=$(sqlite3 xerafin.db "select count(*) from questions where next_scheduled  < $(date +%s)")

# If I ask for more words than are due, read ahead / add new words to fulfill the request

if [ $due_now -lt $limit ] ; then
./ra_mobile $limit
fi

sqlite3 xerafin.db "select question from questions where difficulty = 0 and next_scheduled < $(date +%s) order by cardbox limit $limit" > aerolith.txt
echo "$(cat aerolith.txt | wc -l) words exported. Upload the file called aerolith.txt to Aerolith as a custom list."
# initialize the exported words in an array
# 1 means correct, 0 means incorrect
while read line
do
result[$(sqlite3 xerafin.db "select study_order from study_order where alphagram=\"$line\"")]=1
done < aerolith.txt

echo "Enter the words you miss on Aerolith here. Type :done when you are complete."
echo "To mark something correct that you mismarked as wrong, prefix the word with :right"
echo "To scrap this thing and return to the main menu without adjusting your cardbox, type :main"
i=1
read -p "$i " dummy1 dummy2
while [ "$dummy1" != ":done" -a "$dummy1" != ":main" ] ; do
	if [ "$dummy1" = ":right" ] ; then
		if [ "$dummy2" ] ; then
			x=$(echo $dummy2 | ./word_list_to_alpha_list.sh)
			result[$(sqlite3 xerafin.db "select study_order from study_order where alphagram=\"$x\"")]=1
		fi
	else 
		x=$(echo $dummy1 | ./word_list_to_alpha_list.sh)
		result[$(sqlite3 xerafin.db "select study_order from study_order where alphagram=\"$x\"")]=0
	fi
	i=$(($i+1))
	read -p "$i " dummy1 dummy2
done

if [ "$dummy1" = ":main" ] ; then
	unset result
	return
fi

echo "Processing Aerolith results"
touch a_right.dat
touch a_wrong.dat
rm a_right.dat a_wrong.dat
while read line
do
	x=$(sqlite3 xerafin.db "select study_order from study_order where alphagram=\"$line\"")
	if [ ${result[$x]} -eq 1 ] ; then
		right_silent $line
		echo $line >> a_right.dat
	elif [ ${result[$x]} -eq 0 ] ; then
		wrong_silent $line
		echo $line >> a_wrong.dat
	fi

done < aerolith.txt
touch a_right.dat
touch a_wrong.dat
echo "$(cat a_right.dat | wc -l) answers correct."
echo "$(cat a_wrong.dat | wc -l) answers wrong."
echo
echo "Make sure you delete this custom list in Aerolith now that it is completed."

read -p "Press enter to return to the main menu." dummy

} # end function aerolith

function prefs {

clear
echo "XERAFIN Default Preferences"
echo 
echo "Enter a number to change the default for each preference below."
echo
echo "1) Endless Mode - will automatically continue a quiz with new words when you finish, without prompting."
echo "		CURRENT VALUE: $(cat .prefs/AUTOADD)"
echo "2) New Words at Once - When Xerafin adds new words to the cardbox, how many should it add at once?"
echo "		CURRENT VALUE: $(cat .prefs/NEW_WORDS_AT_ONCE)"
echo "3) How many hours ahead in your cardbox should you be before Xerafin adds new words?"
echo "		CURRENT VALUE: $(cat .prefs/RESCHED_HRS)"
echo "4) Should Xerafin show you the number of solutions when you're doing a quiz?"
echo "		CURRENT VALUE: $(cat .prefs/SHOW_NUMBER_OF_SOLUTIONS)"
echo "5) Do you have Dropbox set up to sync Xerfain with Zyzzyva (or just to back up your database)?"
echo "		CURRENT VALUE: $(cat .prefs/USE_DROPBOX)"
echo "6) Do you have Karatasi set up to export cardbox quizzes for mobile quizzing?"
echo "		CURRENT VALUE: $(cat .prefs/USE_KARATASI)"
echo
read -p "Enter a number to edit the preference or type main to return to the main menu: " dummy

       case "$dummy" in
        1 ) 
		if [ $(cat .prefs/AUTOADD) = "YES" ] ; then
			echo NO > .prefs/AUTOADD
		else echo YES > .prefs/AUTOADD
		fi 
		prefs;;
	2 ) 
		echo
		read -p "Please enter a number between 1 and 20: " i
		if [ $i -le 20 2>/dev/null ] ; then
			if [ $i -gt 0 ] ; then
				echo $i > .prefs/NEW_WORDS_AT_ONCE
			fi
		else read -p "Invalid number, or number out of the range. Press enter to continue." x
		fi
		prefs;; 
	3) 
		echo
		read -p "Please enter a number: " i
		if [ $i -eq $i 2>/dev/null ] ; then
			echo $i > .prefs/RESCHED_HRS
		else read -p "Invalid number. Press enter to continue." x
		fi
		prefs;; 
        4 ) 
		if [ $(cat .prefs/SHOW_NUMBER_OF_SOLUTIONS) = "YES" ] ; then
			echo NO > .prefs/SHOW_NUMBER_OF_SOLUTIONS
		else echo YES > .prefs/SHOW_NUMBER_OF_SOLUTIONS
		fi 
		prefs;;
        5 ) 
		if [ $(cat .prefs/USE_DROPBOX) = "YES" ] ; then
			echo NO > .prefs/USE_DROPBOX
		elif [ -d Dropbox ] ; then
			echo YES > .prefs/USE_DROPBOX
		else echo "Please create a symlink called Dropbox pointing to your Dropbox directory before enabling this."
		read -p "Press enter to continue" x
		fi 
		prefs;;
        6 ) 
		if [ $(cat .prefs/USE_KARATASI) = "YES" ] ; then
			echo NO > .prefs/USE_KARATASI
		elif [ -d karatasi ] ; then
			echo YES > .prefs/USE_KARATASI
		else echo "Please create a symlink called karatasi pointing to the Karatasi data directory before enabling this."
		read -p "Press enter to continue" x
		fi 
		prefs;;
	'main' ) 
		return 0;;
	* ) 
		prefs;;

	esac

} # end function prefs

function mainmenu {

while [ 1 ] ; do

clear
echo "WELCOME TO X E R A F I N    Word Study System"
cat VERSION
echo 

echo "MAIN MENU: Choose from the following options:"
echo "Type quiz to start a cardbox quiz"
echo "Type stats to view cardbox stats"
echo "Type aerolith to create a file to study on aerolith.org"
if [ "$USE_KARATASI" = "YES" ] ; then
echo "Type import to import quiz results from the mobile Karatasi app"
echo "Type export to export quiz questions to the mobile Karatasi app"
fi
echo "Type load to load a list of words to be available in the store under Custom List"
echo "Type prefs to view and edit the default program preferences."
echo "Type exit to exit the program"

read -p " > " m

case "$m" in

	"exit" )

		echo "Come again soon!"
		exit 0;;

	"quiz" )
		setwhere
		return;;

	"stats" )

		./cardbox_reports.sh;;

	"import" )

		if [ $USE_KARATASI = "YES" ] ; then
		echo "Working..."
		cp l_empty.db l_backup.db
		cp karatasi/l_cardbox.db l_empty.db
		./process_karatasi.sh
		touch l_right.txt
		touch l_wrong.txt
		echo Correct: $(cat l_right.txt | wc -l)
		echo Incorrect: $(cat l_wrong.txt | wc -l)
		else echo "Please set up Karatasi syncing to use this command."
		fi
		echo "Press enter to continue"
		read dummy;;

	"export" )

		if [ $USE_KARATASI = "YES" ] ; then
		echo "How many questions should be exported? Default sorting will be used."
		read x
		./export_karatasi.sh $x
		echo "Done - ready to sync with your device using the Karatasi Java app."
		else echo "Please set up Karatasi syncing to use this command."
		fi
		echo "Press enter to continue"
		read dummy;;

	"load" )

		echo "This will allow you to buy these words to the front of the line"
		echo "to be added next to your cardbox using the :store command from within a quiz."
		read -p "Enter filename: " file
		./word_list_to_alpha_list.sh $file >> temp/alphas
		./load_custom_list.sh temp/alphas
		rm temp/alphas
		unset file;;

	"prefs" )

		prefs;;

	"quit" )

		exit;;

	"aerolith" )

		aerolith;;

	* )

		clear;;

esac	

done

	
} # end function mainmenu

function getquestions {

x=0
unset qn
unset cx
unset lt
while read q c l
do
	qn[x]="$q"
	cx[x]="$c"
	lt[x]="$l"
	x=$(($x+1))
done < <(sqlite3 xerafin.db "select question, cardbox, last_correct from questions where next_scheduled <= $(date +%s) and difficulty = 0 and $where order by cardbox desc, length(question) desc " | sed -e 's/|/ /g')

} # end function getquestions

clear


# Pull database from Dropbox, if it's more recent

USE_DROPBOX=$(cat .prefs/USE_DROPBOX)

if [ "$USE_DROPBOX" = "YES" ] && [ Dropbox/Anagrams.db -nt xerafin.db ]
  then echo "Updating Cardbox from Dropbox"
       cp Dropbox/Anagrams.db xerafin.db
fi

RESCHED_HRS=$(cat .prefs/RESCHED_HRS)
NEW_WORDS_AT_ONCE=$(cat .prefs/NEW_WORDS_AT_ONCE)
AUTOADD=$(cat .prefs/AUTOADD)
SHOW_EXTENSION=$(cat .prefs/SHOW_EXTENSION)
SHOW_NUMBER_OF_SOLUTIONS=$(cat .prefs/SHOW_NUMBER_OF_SOLUTIONS)
USE_KARATASI=$(cat .prefs/USE_KARATASI)

source wsetup.sh

# Database consistency stuff
sqlite3 xerafin.db "update study_order set cardbox_flag = (Select count(*) from questions where question = study_order.alphagram and next_scheduled is not null)"
sqlite3 xerafin.db "delete from custom_list where question in (Select question from next_added)"
sqlite3 xerafin.db "delete from custom_list where question in (select alphagram from study_order where cardbox_flag = 1)"
sqlite3 xerafin.db "delete from next_added where question in (select alphagram from study_order where cardbox_flag = 1)"

# Coins you earned in another study program

OLD_SCORE=$(sqlite3 xerafin.db "select * from last_score")
temp=$(($SCORE_START-$OLD_SCORE))
if [ $temp -ge 100 ] ; then
	new_coins=$(($temp/100))
	echo "Since your last visit you have earned $new_coins more coins!"
	sqlite3 xerafin.db "update piggy_bank set coins = coins+$new_coins"
	sqlite3 xerafin.db "update last_score set score = $SCORE_START"
fi
unset new_coins
unset OLD_SCORE
unset temp
	
mainmenu
getquestions
REFRESH_NOW="NO"

while [ 1 ] ; do

if [ "$v_main" = "y" ] ; then
	unset v_main
	mainmenu
	getquestions
	continue
fi
	

clear
touch results.txt
rm results.txt 

cbs=$(./cardbox_score.sh)

if [ $(($cbs-$SCORE_START)) -eq 100 ] ; then
	sqlite3 xerafin.db "update piggy_bank set coins = coins+1"
	SCORE_START=$cbs
fi


if [ ${#qn[@]} -eq 0 ] ; then
unset question
else
final=$((${#qn[@]}-1))
question="${qn[$final]}"
cardbox="${cx[$final]}"
last_correct="${lt[$final]}"
unset qn[$final]
fi

unset dummy
if [ -z "$question" ] ; then 
   # there are no more questions. We either need to 
   # quit, or add new cards / go another hour ahead
   if [ "$AUTOADD" = "ON" ] ; then
	dummy='quiz'
   else
	echo "Your quiz unit is complete".
	echo
	echo "Type main to return to the main menu"
	echo "Type quiz to start a new quiz"
	echo "Type endless to start a new quiz (endless mode)"
	if [ $USE_DROPBOX = "YES" ] ; then
	echo "Type w to save to Dropbox and exit"
	fi
	echo "Press q to exit"
	read dummy
   fi

if [ $dummy = "endless" ] ; then
	dummy=quiz
	AUTOADD=ON
fi

if [ $dummy = "main" ] ; then
	mainmenu
	getquestions
	continue
fi

if [ "$dummy" = "Q" ] || [ "$dummy" = "q" ] ; then
	exit 0
elif [ $dummy = 'quiz' ] ; then
     if [ "$where" = "1=1" ] ; then
        hrs_ahead=0
	until [ $hrs_ahead -gt $HOURS_AHEAD_CNT ] 
	do
	   if [ $(./peek_ahead $hrs_ahead) -eq 0 ] ; then
		hrs_ahead=$(($hrs_ahead+1))
	   else
	      ./read_ahead $hrs_ahead > /dev/null
           break
	   fi
	done
	if [ $hrs_ahead -gt $HOURS_AHEAD_CNT ] ; then
	./new_words.sh $NEW_WORDS_AT_ONCE  >> added_today.dat
	cp xerafin.db backup.db
	HOURS_AHEAD_CNT=$(($HOURS_AHEAD_CNT+1))
	echo $(($(date +%s) + ($HOURS_AHEAD_CNT*3600))) > cleared_until
	fi
      else setwhere
      fi
	getquestions
	continue
elif [ $dummy = 'w' ] || [ $dummy = 'W' ] ; then
	   if [ $USE_DROPBOX = "YES" ] ; then
	   cp xerafin.db Dropbox/Anagrams.db
	   fi 
	
	echo "Goodbye!"
	sqlite3 xerafin.db "update last_score set score = $(./cardbox_score.sh)"
	exit 0
fi
fi
	  	
##echo "Current Score: $cbs  Starting Score: $SCORE_START"
coins=$(sqlite3 xerafin.db "select coins from piggy_bank")
echo "Type :help to see a list of commands."
echo "You have $coins coins in the bank. $(getRank $(($cbs-$SCORE_START)))" 
echo Last Correct: $(date -r "$last_correct")
echo "You have $(($final+1)) more words in this quiz unit."

   echo
if [ -z "$hrs_ahead" ] ; then
   echo Now : From Cardbox $cardbox
   if  [ "$SHOW_NUMBER_OF_SOLUTIONS" = "YES" ] ; then
	echo Number of solutions: $(sqlite3 a.db "select count(*) from words where alphagram = '$question'")
   fi
else
#   echo From $hrs_ahead hours in the future:
   echo  + $hrs_ahead hours ahead : From Cardbox $cardbox
   if  [ "$SHOW_NUMBER_OF_SOLUTIONS" = "YES" ] ; then
	echo Number of solutions: $(sqlite3 a.db "select count(*) from words where alphagram = '$question'")
   fi
fi
   echo "	$question"
   pnum=1
   echo -n " $pnum " 
   skipped=y
   read ans1 ans2
   until [ -z "$ans1" ]
   do
       case "$ans1" in
        :[uU] )
	   ./upcoming
	   echo -n " $pnum " 
	   read ans1 ans2 ;;
	 :[Cc] )
	   clear
	   echo $question
	   cat -n results.txt
	   echo -n " $pnum " 
	   read ans1 ans2 ;;
         :[dD] )
	   ./delete_one_line.sh $ans2
	   pnum=$(($(cat results.txt | wc -l)+1))
	   clear
	   echo $question
	   echo 
	   cat -n results.txt
	   echo -n " $pnum " 
           read ans1 ans2 ;;
	 :[qQ] )
           echo "Goodbye!"
	   sqlite3 xerafin.db "update last_score set score = $cbs"
           exit 0 ;;
	 :[hH][Ee][Ll][Pp] )
	   echo
	   echo "Enter : and the command listed to run."
	   echo
	   echo List of Commands:
	   echo "	c: clear the screen"
	   echo "	d: delete a line from your answer"
	   echo "	f: define a word"
	   echo "	help: this help screen"
	   echo "	hint: first letter of the answer(s)"
	   echo "	l: look up a word"
	   echo "	main: end this quiz unit and return to main menu"
	   echo "	n: toggle auto-add of new cards"
	   echo "       revert: undo last committed word"
	   echo "       refresh: refresh questions"
	   echo "	q: exit"
	   echo "	u: see upcoming cards by cardbox" 
	   if [ $USE_DROPBOX = "YES" ] ; then
	   echo "	w: save current progress to Dropbox" 
	   fi
	   echo -n " $pnum "
	   read ans1 ans2;;
	 :[Hh][Ii][Nn][Tt] )
	   sqlite3 a.db  "select substr(word, 1, 1) from words where alphagram=\"$question\";"
	   echo -n " $pnum "
	   read ans1 ans2;;
	 :[Ll] )
	   ans3=$(echo $ans2 | tr [a-z] [A-Z])
	   if [ -z $(sqlite3 a.db "select word from words where word=\"$ans3\";") ] ; then
		echo NO
	   else echo YES
	   fi
	   echo -n " $pnum "
	   read ans1 ans2;; 
	 :[Ff] )
	   ans3=$(echo $ans2 | tr [a-z] [A-Z])
	   sqlite3 a.db "select definition from words where word=\"$ans3\";"
	   echo -n " $pnum "
	   read ans1 ans2;; 
	 :[Mm][Aa][Ii][nN] )
		v_main=y
		unset ans1
		continue;;
	 :[Nn] )
	   if [ $AUTOADD = "ON" ] ; then
		AUTOADD=OFF
		echo "Auto-add new cards is OFF"
	   else AUTOADD=ON
		echo "Auto-add new cards is ON"
	   fi
	   echo -n " $pnum "
	   read ans1 ans2 ;;
	  :[Rr][Ee][Ff][Rr][Ee][Ss][Hh] )
	     REFRESH_NOW="YES"
	     echo "		Quiz will be refreshed after this question"
	     echo
	     echo -n " $pnum "
	     read ans1 ans2 ;;
	  :[Ww] )
	   if [ $USE_DROPBOX = "YES" ] ; then
	   cp xerafin.db Dropbox/Anagrams.db
	   fi
	   echo -n " $pnum "
	   read ans1 ans2 ;;
	  :[Rr][Ee][Vv][Ee][Rr][Tt] )
	   cp backup.db xerafin.db
	   echo "		Last question undone"
	   echo
	   echo -n " $pnum "
	   read ans1 ans2 ;;
	  :[Ss][Tt][Oo][Rr][Ee] )
		clear
		store
	   echo $question
	   echo 
	   cat -n results.txt
	   echo -n " $pnum " 
           read ans1 ans2 ;;
	  * )
              unset skipped
	      echo "$ans1 $ans2" >> results.txt
	      pnum=$(($pnum+1))
	      echo -n " $pnum "
	      read ans1 ans2 ;;
         esac
done #until loop

if [ "$v_main" = "y" ] ; then 
	continue
fi

if [ -n "$skipped" ]
then 
sqlite3 xerafin.db "update questions set next_scheduled = $(($(date +%s)-1)) where question = '$question'"
continue
fi

  cp xerafin.db backup.db

   i=0
   correct=0
   for a in $(sqlite3 a.db "select word from words where alphagram=\"$question\"")
   do
	   w[i]=$a
	   defn[i]=$(sqlite3 a.db "select definition from words where word = \"${w[i]}\"")
   
	   i=$(($i+1))

   done

   if [ $(cat results.txt | wc -l) -ne $i ]
   then 
      wrong $question
   else 

   while read wd etc
   do

   wd=$(echo $wd | tr [a-z] [A-Z])

   j=0
	   while [ $j -lt $i ]
	   do

	      if [ -n "${w[j]}" ] && [ "${w[j]}" = "$wd" ]
	      then
		  correct=$(($correct+1))
		  unset w[j]
		  break
	      else
		  j=$(($j+1))
	      fi
	    done      
  done < results.txt
  
  if [ $correct -lt $i ]
  then
     wrong $question
  else
     right $question $cardbox
  fi
  fi

  tput sgr0


if [ "$REFRESH_NOW" = "YES" ] ; then
	getquestions
	REFRESH_NOW="NO"
fi

echo Press enter to continue
read foo


done # while forever loop

