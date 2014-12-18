#/bin/bash

clear

echo Welcome to XERAFIN Word Study System
echo

if [ -e xerafin.db ] ; then
echo "You already have a xerafin.db file"
echo "If you really want to install a fresh copy of XERAFIN, delete this file."
echo "If you have an existing cardbox you want to import into a fresh XERAFIN, name it Anagrams.db"
echo
echo "Exiting installation."
echo
exit 0
fi

echo Please, before you begin, put a copy of your existing cardbox db in a safe place.
echo "If you have an Anagrams.db file you wish to import into XERAFIN, put it in the xerafin directory."
read -p "Press enter when you have done this." dummy

if [ -e Anagrams.db ] ; then

echo Anagrams.db file found
echo
mv -i Anagrams.db xerafin.db

else cp study_order.db xerafin.db

fi

echo Initializing xerafin.db
#echo This may take a bit of time...
sqlite3 xerafin.db < cr_xerafin_tables.sql 2> /dev/null
touch $HOME/.bash_profile

if ! (grep -q xerafin $HOME/.bash_profile) ; then

   echo "alias xerafin='cd $HOME/xerafin && $HOME/xerafin/xerafin.sh'" >> $HOME/.bash_profile

fi

if [ ! -e Dropbox ] ; then
read -p "Do you want to sync XERAFIN with a Zyzzyva/Dropbox installation? (YES or NO): " dummy

if [ "$dummy" = "YES" ] || [ "$dummy" = "yes" ] ; then
	read -p "Enter Dropbox path (default $HOME/Dropbox/Apps/Zyzzyva/quiz/data/CSW12): $HOME/" d_path 
	if [ ! "$d_path" ] ; then
		d_path="Dropbox/Apps/Zyzzyva/quiz/data/CSW12"
	fi
	ln -s $HOME/$d_path Dropbox
	cp Dropbox/Anagrams.db backup.db
	cp xerafin.db Dropbox/Anagrams.db
	if ! (grep -q USE_DROPBOX wsetup.sh) ; then
	echo "USE_DROPBOX=YES" >> wsetup.sh
	fi
else if ! (grep -q USE_DROPBOX wsetup.sh) ; then 
	echo "USE_DROPBOX=NO" >> wsetup.sh
fi
fi
fi

unset d_path

if [ ! -e karatasi ] ; then
read -p "Do you want to sync XERAFIN with a local Karatasi repository for mobile quizzing? (YES or NO): " dummy
if [ "$dummy" = "YES" ] || [ "$dummy" = "yes" ] ; then
	read -p "Enter Karatasi path (default $HOME/Library/Karatasi): $HOME/" d_path 
	if [ ! "$d_path" ] ; then
		d_path="Library/Karatasi"
	fi
	ln -s $HOME/$d_path karatasi
	cp l_empty.db karatasi/l_cardbox.db
	if ! (grep -q USE_KARATASI wsetup.sh) ; then
	echo "USE_KARATASI=YES" >> wsetup.sh
	fi
else if ! (grep -q USE_KARATASI wsetup.sh) ; then
	echo "USE_KARATASI=NO" >> wsetup.sh
fi
fi
fi


echo "Choose one of the following."
echo " A ) Use XERAFIN to study all words length 4 and longer (RECOMMENDED)"
echo " B ) Use XERAFIN to study all words length 5 and longer"
echo " C ) Use XERAFIN to study all words length 6 and longer"

echo " D ) Use XERAFIN to study all words length 7 and longer"
dummy=NO
while [ "$dummy" = "NO" ] ; do
echo
read -p " > " dummy1

case "$dummy1" in

[aA] )
	dummy=YES;;
[bB] )
	sqlite3 xerafin.db "delete from study_order where length(alphagram) = 4"
	dummy=YES;;
[cC] ) 
	sqlite3 xerafin.db "delete from study_order where length(alphagram) < 6"
	dummy=YES;;
[dD] ) 
	sqlite3 xerafin.db "delete from study_order where length(alphagram) < 7"
	dummy=YES;;
* )
	echo "Invalid choice. Please choose one of an option (A-D)";;
esac

done

	
ln -s xerafin.db q.db
mkdir tmp
mkdir backup


sqlite3 xerafin.db "delete from last_score"
sqlite3 xerafin.db "insert into last_score values ($(./cardbox_score.sh))"

dummy=$(sqlite3 xerafin.db "select count(*) from piggy_bank")
if [ $dummy -eq 0 ] ; then
sqlite3 xerafin.db "insert into piggy_bank values (0);"
fi

touch NEW_WORDS
date +%s > cleared_until


