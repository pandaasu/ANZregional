/*****************/
/* Package Types */
/*****************/
create or replace type pts_cla_value_object as object (val_code number);
/

create or replace type pts_cla_value_type as table of pts_cla_value_object;
/