CREATE TABLE custom_list(question varchar(16));
CREATE TABLE last_score (score integer);
CREATE TABLE next_Added(question varchar(16));
CREATE TABLE piggy_bank (coins integer);
CREATE TABLE questions (question varchar(16), correct integer, incorrect integer, streak integer, last_correct integer, difficulty integer, cardbox integer, next_scheduled integer);
CREATE TABLE study_order (ALPHAGRAM text primary key, STUDY_ORDER int, CARDBOX_FLAG int);
CREATE INDEX cardbox_idx on questions (cardbox);
CREATE INDEX next_sch_idx on questions (next_scheduled);
CREATE UNIQUE INDEX question_index ON questions (question);

-- this is fine to run a bunch of times
-- the main xerafin.sh will make sure it's consistent with what's in your cardbox already

attach database "study_order.db" as s;

delete from main.study_order;
insert into main.study_order select * from s.study_order;


