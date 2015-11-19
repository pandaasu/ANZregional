--------------------------------------------------------
--  DDL for Type LICS_STREAM_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE TYPE "LICS"."LICS_STREAM_OBJECT" as object
   (str_depth                    number,
    str_type                     varchar2(1 char),
    str_pcde                     varchar2(32 char),
    str_code                     varchar2(32 char),
    str_text                     varchar2(128 char),
    str_lock                     varchar2(32 char),
    str_proc                     varchar2(512 char),
    str_job_group                varchar2(10 char),
    str_opr_alert                varchar2(256 char),
    str_ema_group                varchar2(64 char));

/
