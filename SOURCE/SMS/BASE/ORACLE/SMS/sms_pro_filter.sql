/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_pro_filter
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Profile Filter Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_pro_filter
   (pfi_prf_code                    varchar2(64 char)              not null,
    pfi_flt_code                    varchar2(64 char)              not null);

/**/
/* Comments
/**/
comment on table sms.sms_pro_filter is 'Profile Filter Table';
comment on column sms.sms_pro_filter.pfi_prf_code is 'Profile code';
comment on column sms.sms_pro_filter.pfi_flt_code is 'Filter code';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_pro_filter
   add constraint sms_pro_filter_pk primary key (pfi_prf_code, pfi_flt_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_pro_filter to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_pro_filter for sms.sms_pro_filter;    