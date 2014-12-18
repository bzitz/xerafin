#!/bin/bash

now=$(date +%s)

sqlite3	"q.db" "update questions set next_scheduled = 1268500000 - ((11-cardbox)*200000+(next_scheduled%10000)) where next_scheduled < $now"

sqlite3 "q.db" "select count(*) from questions where next_scheduled < $now"

