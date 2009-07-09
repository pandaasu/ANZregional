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
    mli_msg_lnum                    number                         not null,
    mli_msg_pnum                    number                         not null,
    mli_dim_val01                   varchar2(256 char)             null,
    mli_dim_val02                   varchar2(256 char)             null,
    mli_dim_val03                   varchar2(256 char)             null,
    mli_dim_val04                   varchar2(256 char)             null,
    mli_dim_val05                   varchar2(256 char)             null,
    mli_dim_val06                   varchar2(256 char)             null,
    mli_dim_val07                   varchar2(256 char)             null,
    mli_dim_val08                   varchar2(256 char)             null,
    mli_dim_val09                   varchar2(256 char)             null
    mli_sms_text                    varchar2(1024 char)            not null);  

/**/
/* Comments
/**/
comment on table sms.sms_mes_line is 'Message Line Table';
comment on column sms.sms_mes_line.mli_msg_code is 'Message code';
comment on column sms.sms_mes_line.mli_msg_lnum is 'Message line number';
comment on column sms.sms_mes_line.mli_msg_pnum is 'Message line parent';
comment on column sms.sms_mes_line.mli_dim_val01 is 'Dimension 01 value';
comment on column sms.sms_mes_line.mli_dim_val02 is 'Dimension 02 value';
comment on column sms.sms_mes_line.mli_dim_val03 is 'Dimension 03 value';
comment on column sms.sms_mes_line.mli_dim_val04 is 'Dimension 04 value';
comment on column sms.sms_mes_line.mli_dim_val05 is 'Dimension 05 value';
comment on column sms.sms_mes_line.mli_dim_val06 is 'Dimension 06 value';
comment on column sms.sms_mes_line.mli_dim_val07 is 'Dimension 07 value';
comment on column sms.sms_mes_line.mli_dim_val08 is 'Dimension 08 value';
comment on column sms.sms_mes_line.mli_dim_val09 is 'Dimension 09 value';
comment on column sms.sms_mes_line.mli_sms_text is 'Message SMS text';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_mes_line
   add constraint sms_mes_line_pk primary key (mli_msg_code, mli_msg_lnum);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_mes_line to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_mes_line for sms.sms_mes_line;    