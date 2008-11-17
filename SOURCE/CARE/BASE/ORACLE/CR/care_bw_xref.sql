/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : Care
 Table   : care_bw_xref
 Owner   : cr
 Author  : Steve Gregan

 Description
 -----------
 Care - care_bw_xref

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table cr.care_bw_xref
   (code                         varchar2(10 char)               not null,
    type                         varchar2(20 char)               not null,
    desc                         varchar2(60 char)               not null,
    bw_code                      varchar2(18 char)               not null);

/**/
/* Comments
/**/
comment on table cr.care_bw_xref is 'Care BW Cross Reference Table';
comment on column cr.care_bw_xref.code is 'The CARE code being mapped';
comment on column cr.care_bw_xref.type is 'Type of code being mapped. Used for filtering by user. Not required for processing.';
comment on column cr.care_bw_xref.desc is 'User description of the code';
comment on column cr.care_bw_xref.bw_code is 'Equivalent code in BW';

/**/
/* Primary Key Constraint
/**/
alter table cr.care_bw_xref
   add constraint care_bw_xref_pk primary key (code);

/**/
/* Authority
/**/
grant select, insert, update, delete on cr.care_bw_xref to cr_app;

/**/
/* Synonym
/**/
create or replace public synonym care_bw_xref for cr.care_bw_xref;

