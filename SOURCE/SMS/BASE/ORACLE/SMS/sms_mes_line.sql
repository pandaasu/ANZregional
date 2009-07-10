/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_mes_line
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Message Line Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_mes_line
   (mli_msg_code                    varchar2(64 char)              not null,
    mli_msg_line                    varchar2(64 char)              not null,
    mli_det_text                    varchar2(2000 char)            not null,
    mli_tot_text                    varchar2(2000 char)            not null,
    mli_tot_child                   varchar2(1 char)               not null);  


/**/
/* Comments
/**/
comment on table sms.sms_mes_line is 'Message Line Table';
comment on column sms.sms_mes_line.mli_msg_code is 'Message code';
comment on column sms.sms_mes_line.mli_msg_line is 'Message line';
comment on column sms.sms_mes_line.mli_det_text is 'Message detail SMS text';
comment on column sms.sms_mes_line.mli_tot_text is 'Message total SMS text';
comment on column sms.sms_mes_line.mli_tot_child is 'Message total children (1=All totals, 2=Multiple children totals only)';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_mes_line
   add constraint sms_mes_line_pk primary key (mli_msg_code, mli_msg_line);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_mes_line to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_mes_line for sms.sms_mes_line;    