#!/bin/bash

 sqlite3 q.db "select length(question), count(*) from questions where next_scheduled is not null group by length(question) order by length(question)"

exit 0

