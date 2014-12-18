#!/bin/bash

# bingos.txt is a file with bingos (words)
# fives, sixes, sevens, eights, nines are alphagrams

./word_list_to_alpha_list.sh bingos.txt > tmp

#ten sevens, ten eights

wc -l NEW_WORDS *.txt
echo Adding $(($(cat bingos.txt | wc -l) + 33)) to NEW_WORDS
cp *.txt backup/
cp NEW_WORDS backup/

head -8 sevens.txt >> tmp
head -8 eights.txt >> tmp
head -5 sixes.txt >> tmp
head -5 fives.txt >> tmp
head -1 nines.txt >> tmp

cat sevens.txt | sed -e '1,8d' > tmp7
cat eights.txt | sed -e '1,8d' > tmp8
cat sixes.txt | sed -e '1,5d' > tmp6
cat fives.txt | sed -e '1,5d' > tmp5
cat nines.txt | sed -e '1d' > tmp9

mv tmp5 fives.txt
mv tmp6 sixes.txt
mv tmp7 sevens.txt
mv tmp8 eights.txt
mv tmp9 nines.txt

./randomize_file.sh tmp >> NEW_WORDS
rm tmp
rm bingos.txt
touch bingos.txt

echo AFTER
wc -l NEW_WORDS *.txt
cp NEW_WORDS Dropbox/


