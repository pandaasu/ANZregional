/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sel_tem_rule
 Owner  : pts

 Description
 -----------
 Product Testing System - Selection Template Rule Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_sel_tem_rule
   (str_stm_code                    number                        not null,
    str_sel_group                   varchar2(32 char)             not null,
    str_tab_code                    varchar2(32 char)             not null,
    str_fld_code                    number                        not null,
    str_rul_code                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_sel_tem_rule is 'Selection Template Rule Table';
comment on column pts.pts_sel_tem_rule.str_stm_code is 'Selection template code';
comment on column pts.pts_sel_tem_rule.str_sel_group is 'Selection group (*GROUP01 - *GROUP99)';
comment on column pts.pts_sel_tem_rule.str_tab_code is 'System table code';
comment on column pts.pts_sel_tem_rule.str_fld_code is 'System field code';
comment on column pts.pts_sel_tem_rule.str_rul_code is 'System rule code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sel_tem_rule
   add constraint pts_sel_tem_rule_pk primary key (str_stm_code, str_sel_group, str_tab_code, str_fld_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sel_tem_rule to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sel_tem_rule for pts.pts_sel_tem_rule;            