/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_wor_sel_rule
 Owner  : pts

 Description
 -----------
 Product Testing System - Work Selection Rule Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table pts.pts_wor_sel_rule
   (wsr_sel_group                   varchar2(32 char)             not null,
    wsr_tab_code                    varchar2(32 char)             not null,
    wsr_fld_code                    number                        not null,
    wsr_rul_code                    varchar2(32 char)             not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table pts.pts_wor_sel_rule is 'Work Selection Rule Table';
comment on column pts.pts_wor_sel_rule.wsr_sel_group is 'Selection group (*GROUP01 - *GROUP99)';
comment on column pts.pts_wor_sel_rule.wsr_tab_code is 'System table code';
comment on column pts.pts_wor_sel_rule.wsr_fld_code is 'System field code';
comment on column pts.pts_wor_sel_rule.wsr_rul_code is 'System rule code';

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_wor_sel_rule to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_wor_sel_rule for pts.pts_wor_sel_rule;            