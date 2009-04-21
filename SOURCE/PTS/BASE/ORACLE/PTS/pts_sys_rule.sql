/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_rule
 Owner  : pts

 Description
 -----------
 Product Testing System - System Rule Table

 **NOTES**
 ---------
 1. This is a system table and therefore has no maintenance facility.
 2. Rows should never be deleted.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_sys_rule
   (sru_rul_code                    varchar2(32 char)             not null,
    sru_rul_cond                    varchar2(32 char)             not null,
    sru_rul_test                    varchar2(32 char)             not null,
    sru_rul_lnot                    varchar2(1 char)              not null,
    sru_rul_tflg                    varchar2(1 char)              not null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_rule is 'System Rule Table';
comment on column pts.pts_sys_rule.sru_rul_code is 'System rule code';
comment on column pts.pts_sys_rule.sru_rul_cond is 'System rule condition';
comment on column pts.pts_sys_rule.sru_rul_test is 'System rule test';
comment on column pts.pts_sys_rule.sru_rul_lnot is 'System rule logical not (0=no or 1=yes)';
comment on column pts.pts_sys_rule.sru_rul_tflg is 'System rule test only flag (0=no or 1=yes)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_rule
   add constraint pts_sys_rule_pk primary key (sru_rul_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_rule to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_rule for pts.pts_sys_rule;