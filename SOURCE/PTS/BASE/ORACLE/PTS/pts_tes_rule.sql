/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_rule
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Rule Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_rule
   (tru_tes_code                    number                        not null,
    tru_sel_group                   varchar2(32 char)             not null,
    tru_tab_code                    varchar2(32 char)             not null,
    tru_fld_code                    number                        not null,
    tru_rul_code                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_rule is 'Test Rule Table';
comment on column pts.pts_tes_rule.tru_tes_code is 'Test code';
comment on column pts.pts_tes_rule.tru_sel_group is 'Selection group (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_rule.tru_tab_code is 'System table code';
comment on column pts.pts_tes_rule.tru_fld_code is 'System field code';
comment on column pts.pts_tes_rule.tru_rul_code is 'System rule code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_rule
   add constraint pts_tes_rule_pk primary key (tru_tes_code, tru_sel_group, tru_tab_code, tru_fld_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_rule to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_rule for pts.pts_tes_rule;            