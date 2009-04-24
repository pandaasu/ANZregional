/*****************/
/* Package Types */
/*****************/
create or replace type pts_cla_text_object as object (val_text varchar2(256));
/

create or replace type pts_cla_text_type as table of pts_cla_text_object;
/