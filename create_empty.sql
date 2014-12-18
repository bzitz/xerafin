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
CREATE TABLE list (type integer, idx integer default 0, card_id integer);
CREATE TABLE sorting (id integer primary key autoincrement, name test default '', locale text default '',
    front text default '', space text default '',ignore text default '');
CREATE TABLE statistics (
        id integer primary key autoincrement,
        date integer default 0, source integer default 0, type integer default 0, value integer
    );
CREATE TABLE status (
        key text primary key, value text
    );
CREATE INDEX card_i0 on card ( cat_id, sort0 asc);
CREATE INDEX list_idx on list ( type, idx asc );
