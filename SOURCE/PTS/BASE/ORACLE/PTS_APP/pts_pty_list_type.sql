/*****************/
/* Package Types */
/*****************/
create or replace type pts_pty_list_object as object (pty_code number, pty_text varchar2(120 char), pty_status number);
/

create or replace type pts_pty_list_type as table of pts_pty_list_object;
/