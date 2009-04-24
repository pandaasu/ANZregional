/*****************/
/* Package Types */
/*****************/
create or replace type pts_cla_numb_object as object (val_number number);
/

create or replace type pts_cla_numb_type as table of pts_cla_numb_object;
/