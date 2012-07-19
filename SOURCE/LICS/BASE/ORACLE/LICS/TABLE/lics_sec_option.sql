/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_sec_option
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_sec_option

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_sec_option
   (seo_option                   varchar2(32 char)               not null,
    seo_description              varchar2(128 char)              not null,
    seo_script                   varchar2(256 char)              not null,
    seo_status                   varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_sec_option is 'LICS Security Option Table';
comment on column lics_sec_option.seo_option is 'Security Option - option code';
comment on column lics_sec_option.seo_description is 'Security Option - option description';
comment on column lics_sec_option.seo_script is 'Security Option - option script';
comment on column lics_sec_option.seo_status is 'Security Option - option status';

/**/
/* Primary Key Constraint
/**/
alter table lics_sec_option
   add constraint lics_sec_option_pk primary key (seo_option);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_sec_option to lics_app;
grant select on lics_sec_option to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_sec_option for lics.lics_sec_option;
