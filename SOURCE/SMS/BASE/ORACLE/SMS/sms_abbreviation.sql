/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_abbreviation
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Abbreviation Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_abbreviation
   (abb_dim_data                    varchar2(256 char)             not null,
    abb_dim_abbr                    varchar2(32 char)              null);  

/**/
/* Comments
/**/
comment on table sms.sms_abbreviation is 'Abbreviation Table';
comment on column sms.sms_abbreviation.abb_dim_data is 'Dimension data';
comment on column sms.sms_abbreviation.abb_dim_abbr is 'Dimemsion abbreviation';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_abbreviation
   add constraint sms_abbreviation_pk primary key (abb_dim_data);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_abbreviation to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_abbreviation for sms.sms_abbreviation;    