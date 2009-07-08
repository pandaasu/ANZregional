/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_profile
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Profile Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_profile
   (pro_prf_code                    varchar2(64 char)              not null,
    pro_prf_text                    varchar2(120 char)             not null,
    pro_status                      varchar2(1 char)               not null,
    pro_upd_user                    varchar2(30 char)              not null,
    pro_upd_date                    date                           not null,
    pro_qry_code                    varchar2(64 char)              not null,
    pro_snd_day01                   varchar2(1 char)               not null,
    pro_snd_day02                   varchar2(1 char)               not null,
    pro_snd_day03                   varchar2(1 char)               not null,
    pro_snd_day04                   varchar2(1 char)               not null,
    pro_snd_day05                   varchar2(1 char)               not null,
    pro_snd_day06                   varchar2(1 char)               not null,
    pro_snd_day07                   varchar2(1 char)               not null);

/**/
/* Comments
/**/
comment on table sms.sms_profile is 'Profile Table';
comment on column sms.sms_profile.pro_prf_code is 'Profile code';
comment on column sms.sms_profile.pro_prf_text is 'Profile text';
comment on column sms.sms_profile.pro_status is 'Profile status (0=inactive or 1=active)';
comment on column sms.sms_profile.pro_upd_user is 'Profile last updated user';
comment on column sms.sms_profile.pro_upd_date is 'Profile last updated date';
comment on column sms.sms_profile.pro_qry_code is 'Query code';
comment on column sms.sms_profile.pro_dim_val01 is 'Dimension 01 value';
comment on column sms.sms_profile.pro_dim_val02 is 'Dimension 02 value';
comment on column sms.sms_profile.pro_dim_val03 is 'Dimension 03 value';
comment on column sms.sms_profile.pro_dim_val04 is 'Dimension 04 value';
comment on column sms.sms_profile.pro_dim_val05 is 'Dimension 05 value';
comment on column sms.sms_profile.pro_dim_val06 is 'Dimension 06 value';
comment on column sms.sms_profile.pro_dim_val07 is 'Dimension 07 value';
comment on column sms.sms_profile.pro_dim_val08 is 'Dimension 08 value';
comment on column sms.sms_profile.pro_dim_val09 is 'Dimension 09 value';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_profile
   add constraint sms_profile_pk primary key (pro_prf_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_profile to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_profile for sms.sms_profile;    