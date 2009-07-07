/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_rpt_data
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Report Data Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_rpt_data
   (rda_qry_code                    varchar2(64 char)             not null,
    rda_rpt_date                    varchar2(8 char)              not null,
    rda_dat_seqn                    number                        not null,
    rda_dim_cod01                   varchar2(256 char)            null,
    rda_dim_cod02                   varchar2(256 char)            null,
    rda_dim_cod03                   varchar2(256 char)            null,
    rda_dim_cod04                   varchar2(256 char)            null,
    rda_dim_cod05                   varchar2(256 char)            null,
    rda_dim_cod06                   varchar2(256 char)            null,
    rda_dim_cod07                   varchar2(256 char)            null,
    rda_dim_cod08                   varchar2(256 char)            null,
    rda_dim_cod09                   varchar2(256 char)            null,
    rda_dim_val01                   varchar2(256 char)            null,
    rda_dim_val02                   varchar2(256 char)            null,
    rda_dim_val03                   varchar2(256 char)            null,
    rda_dim_val04                   varchar2(256 char)            null,
    rda_dim_val05                   varchar2(256 char)            null,
    rda_dim_val06                   varchar2(256 char)            null,
    rda_dim_val07                   varchar2(256 char)            null,
    rda_dim_val08                   varchar2(256 char)            null,
    rda_dim_val09                   varchar2(256 char)            null,
    rda_val_code                    varchar2(256 char)            null,
    rda_val_data                    varchar2(256 char)            null);

/**/
/* Comments
/**/
comment on table sms.sms_rpt_data is 'Report Data Table';
comment on column sms.sms_rpt_data.rda_qry_code is 'Query code';
comment on column sms.sms_rpt_data.rda_rpt_date is 'Report date';
comment on column sms.sms_rpt_data.rda_dat_seqn is 'Data sequence';
comment on column sms.sms_rpt_data.rda_dim_cod01 is 'Dimension 01 code';
comment on column sms.sms_rpt_data.rda_dim_cod02 is 'Dimension 02 code';
comment on column sms.sms_rpt_data.rda_dim_cod03 is 'Dimension 03 code';
comment on column sms.sms_rpt_data.rda_dim_cod04 is 'Dimension 04 code';
comment on column sms.sms_rpt_data.rda_dim_cod05 is 'Dimension 05 code';
comment on column sms.sms_rpt_data.rda_dim_cod06 is 'Dimension 06 code';
comment on column sms.sms_rpt_data.rda_dim_cod07 is 'Dimension 07 code';
comment on column sms.sms_rpt_data.rda_dim_cod08 is 'Dimension 08 code';
comment on column sms.sms_rpt_data.rda_dim_cod09 is 'Dimension 09 code';
comment on column sms.sms_rpt_data.rda_dim_val01 is 'Dimension 01 value';
comment on column sms.sms_rpt_data.rda_dim_val02 is 'Dimension 02 value';
comment on column sms.sms_rpt_data.rda_dim_val03 is 'Dimension 03 value';
comment on column sms.sms_rpt_data.rda_dim_val04 is 'Dimension 04 value';
comment on column sms.sms_rpt_data.rda_dim_val05 is 'Dimension 05 value';
comment on column sms.sms_rpt_data.rda_dim_val06 is 'Dimension 06 value';
comment on column sms.sms_rpt_data.rda_dim_val07 is 'Dimension 07 value';
comment on column sms.sms_rpt_data.rda_dim_val08 is 'Dimension 08 value';
comment on column sms.sms_rpt_data.rda_dim_val09 is 'Dimension 09 value';
comment on column sms.sms_rpt_data.rda_val_code is 'Value code';
comment on column sms.sms_rpt_data.rda_val_data is 'Value data';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_data
   add constraint sms_rpt_data_pk primary key (rda_qry_code, rda_rpt_date, rda_dat_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_data to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_data for sms.sms_rpt_data;    