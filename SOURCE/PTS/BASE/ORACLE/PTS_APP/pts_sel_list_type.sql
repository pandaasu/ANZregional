/*****************/
/* Package Types */
/*****************/
create or replace type pts_sel_list_object as object (sel_code number);
/

create or replace type pts_sel_list_type as table of pts_sel_list_object;
/