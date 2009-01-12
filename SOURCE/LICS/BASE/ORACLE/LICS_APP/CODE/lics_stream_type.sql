/*****************/
/* Package Types */
/*****************/
create or replace type lics_stream_object as object
   (str_depth                    number,
    str_type                     varchar2(1 char),
    str_parent                   varchar2(32 char),
    str_code                     varchar2(32 char),
    str_text                     varchar2(128 char),
    str_lock                     varchar2(32 char),
    str_proc                     varchar2(512 char),
    str_job_group                varchar2(10 char),
    str_opr_alert                varchar2(256 char),
    str_ema_group                varchar2(64 char));
/

create or replace type lics_stream_table as table of lics_stream_object;
/