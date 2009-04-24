/*****************/
/* Package Types */
/*****************/
create or replace type pts_cla_list_object as object (val_code number, val_text varchar2(120 char));
/

create or replace type pts_cla_list_type as table of pts_cla_list_object;
/