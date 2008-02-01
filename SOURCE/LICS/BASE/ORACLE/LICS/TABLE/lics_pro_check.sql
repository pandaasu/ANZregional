/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_pro_check
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_pro_check

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/08   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_pro_check
   (prc_group                    varchar2(32 char)               not null,
    prc_process                  varchar2(32 char)               not null,
    prc_exist                    varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_pro_check is 'LICS Processing Check Table';
comment on column lics_pro_check.prc_group is 'Processing Check - group code';
comment on column lics_pro_check.prc_process is 'Processing Check - process code';
comment on column lics_pro_check.prc_exist is 'Processing Check - exist test (Y/N)';

/**/
/* Primary Key Constraint
/**/
alter table lics_pro_check
   add constraint lics_pro_check_pk primary key (prc_group, prc_process);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_pro_check to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_pro_check for lics.lics_pro_check;
