attach database "a.db" as a;
attach database "l_empty.db" as k;

delete from card;
delete from k.list;
delete from statistics;

insert into card (data_s0, data_s1, data_s2)
select alphagram, group_concat(coalesce(replace(front_hooks, '#', ''), '') || ' ' ||
		word || ' ' || coalesce(replace(back_hooks, '#', ''), ''), '
'), group_concat(word || ' - ' || coalesce(definition, 'a word'), '
')
from main.questions as q
join a.words as w on (q.question = w.alphagram)
where next_scheduled < round((julianday('now')-2440587.5)*86400)
and difficulty = 0
group by alphagram
order by cardbox, length(alphagram)
--order by next_scheduled
limit WORDLIMIT;

update card
set cat_id = length(data_s0)-2, sort0 = 'a' || data_s0, 
created = round(julianday('now')-2440609.5), 
committed = round(julianday('now')-2440609.5),
next_test = round(julianday('now')-2440609.5), 
recalls = 0, lapses = 0;

update card
set data_s3 = (select cardbox from questions
		where question = card.data_s0);

update card
set next_test = next_test + data_s3;

update status
set value = round(julianday('now')-2440609.5) 
where key in ('created', 'committed', 'lastrun');

update status 
set value = datetime('now')
where key = 'fullname';

update questions set difficulty = 1
where question in (select data_s0 from card);


