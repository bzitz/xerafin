PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE status (
        key text primary key, value text
    );
INSERT INTO "status" VALUES('version','3');
INSERT INTO "status" VALUES('maturity','2');
INSERT INTO "status" VALUES('htmltag','<html>');
INSERT INTO "status" VALUES('fullname','Cardbox');
INSERT INTO "status" VALUES('created','16357');
INSERT INTO "status" VALUES('dbwz_type','1');
INSERT INTO "status" VALUES('dbwz_cat_q','1');
INSERT INTO "status" VALUES('dbwz_cat_q_q','0');
INSERT INTO "status" VALUES('dbwz_cat_q_a','1');
INSERT INTO "status" VALUES('dbwz_cat_q_com','2');
INSERT INTO "status" VALUES('committed','16357');
INSERT INTO "status" VALUES('currindrill','0');
INSERT INTO "status" VALUES('lastrun','16358');
INSERT INTO "status" VALUES('lastmodified','1413424015');
INSERT INTO "status" VALUES('test_1','0');
INSERT INTO "status" VALUES('test_2','0');
INSERT INTO "status" VALUES('test_3','0');
INSERT INTO "status" VALUES('test_4','0');
INSERT INTO "status" VALUES('test_5','0');
INSERT INTO "status" VALUES('test_6','0');
CREATE TABLE card (
        id integer primary key autoincrement, cat_id integer default 0, data_s0 text default '',
        data_s1 text default '', data_s2 text default '', data_s3 text default '',
        data_s4 text default '', data_s5 text default '', data_b0 blob, data_b1 blob,
        sort0 text default '', created integer default 0, committed integer default 0,
        next_test integer default 0, recalls integer default 0, lapses integer default 0,
        curr_intervall integer default 0, prev_intervall integer default 0, curr_diffic integer default 0,
        prev_diffic integer default 0, curr_rating integer default 0, prev_rating integer default 0
    );
CREATE TABLE category (
        id integer primary key autoincrement, seq integer default 0,
        name text default '', field_title0 text default '', field_title1 text default '', field_title2 text default '',
        field_title3 text default '', field_title4 text default '', field_title5 text default '',
        field_title6 text default '', field_title7 text default '', sort_l text default '2', sort_l_ok integer default 0,
        field_type0 text default '', field_type1 text default '', 
        disp_l integer default 0, disp_r integer default 1, quest_form text default '', answer_form text default ''
    );
INSERT INTO "category" VALUES(1,0,'questions','question','answer','note','unused','unused','unused','','','0',1,'','',0,1,'<p align=center><font  face="arial narrow,sans-serif" size=5><b><!--0--></b></font></p>','<p align=center><font  face="arial narrow,sans-serif" size=5><b><!--1--></b></font></p><p align=center><font  face="sans-serif" size=4><!--0--></font></p><p align=center><font  face="sans-serif" size=3><!--2--></font></p><p align=center><font  face="sans-serif" size=3><!--3--></font></p><p align=center><font  face="sans-serif" size=3><!--4--></font></p><p align=center><font  face="sans-serif" size=3><!--5--></font></p>');
CREATE TABLE sorting (id integer primary key autoincrement, name text default '', locale text default '',
    front text default '', space text default '',ignore text default '');
INSERT INTO "sorting" VALUES(0,'q','en','-','.,;()','-');
INSERT INTO "sorting" VALUES(1,'a','en','-','.,;()','-');
INSERT INTO "sorting" VALUES(2,'n','en','-','.,;()','-');
CREATE TABLE list (type integer, idx integer default 0, card_id integer);
CREATE TABLE statistics (
        id integer primary key autoincrement,
        date integer default 0, source integer default 0, type integer default 0, value integer
    );
INSERT INTO "statistics" VALUES(1,0,4,0,0);
INSERT INTO "statistics" VALUES(2,0,5,0,0);
INSERT INTO "statistics" VALUES(3,0,6,0,0);
INSERT INTO "statistics" VALUES(4,0,7,0,0);
INSERT INTO "statistics" VALUES(5,0,8,0,0);
INSERT INTO "statistics" VALUES(6,0,9,0,0);
INSERT INTO "statistics" VALUES(7,16357,1,0,1);
INSERT INTO "statistics" VALUES(8,16357,2,0,1);
INSERT INTO "statistics" VALUES(9,16357,3,0,0);
INSERT INTO "statistics" VALUES(10,16357,4,0,0);
INSERT INTO "statistics" VALUES(11,16357,5,0,0);
INSERT INTO "statistics" VALUES(12,16357,6,0,0);
INSERT INTO "statistics" VALUES(13,16357,7,0,0);
INSERT INTO "statistics" VALUES(14,16357,8,0,0);
INSERT INTO "statistics" VALUES(15,16357,9,0,0);
INSERT INTO "statistics" VALUES(16,16358,1,0,1);
INSERT INTO "statistics" VALUES(17,16358,2,0,1);
INSERT INTO "statistics" VALUES(18,16358,3,0,0);
DELETE FROM sqlite_sequence;
INSERT INTO "sqlite_sequence" VALUES('sorting',2);
INSERT INTO "sqlite_sequence" VALUES('category',1);
INSERT INTO "sqlite_sequence" VALUES('card',1);
INSERT INTO "sqlite_sequence" VALUES('statistics',18);
CREATE INDEX card_i0 on card ( cat_id, sort0 asc);
CREATE INDEX list_idx on list ( type, idx asc );
COMMIT;
