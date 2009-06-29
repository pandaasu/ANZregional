/*****************/
/* Package Types */
/*****************/
create or replace type pts_tty_list_object as object (tty_code number, tty_text varchar2(120 char), tty_status number, tty_target number, tty_sam_count number, tty_alc_proc varchar2(120 char));
/

create or replace type pts_tty_list_type as table of pts_tty_list_object;
/