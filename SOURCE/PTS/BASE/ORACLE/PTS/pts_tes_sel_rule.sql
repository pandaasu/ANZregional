/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_sel_rule
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Selection Rule Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_sel_rule
   (tsr_tes_code                    number                        not null,
    tsr_sel_group                   varchar2(32 char)             not null,
    tsr_tab_code                    varchar2(32 char)             not null,
    tsr_fld_code                    number                        not null,
    tsr_rul_code                    varchar2(32 char)             not null,
    tsr_dsp_seqn                    number                        not null,
    tsr_req_pan_count               number                        not null,
    tsr_req_res_count               number                        not null,
    tsr_sel_pan_count               number                        not null,
    tsr_sel_res_count               number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_sel_rule is 'Test Selection Rule Table';
comment on column pts.pts_tes_sel_rule.tsr_tes_code is 'Test code';
comment on column pts.pts_tes_sel_rule.tsr_sel_group is 'Selection group (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_sel_rule.tsr_tab_code is 'System table code';
comment on column pts.pts_tes_sel_rule.tsr_fld_code is 'System field code';
comment on column pts.pts_tes_sel_rule.tsr_rul_code is 'System rule code';
comment on column pts.pts_tes_sel_rule.tsr_dsp_seqn is 'Display sequence';
comment on column pts.pts_tes_sel_rule.tsr_req_pan_count is 'Selection rule requested panel count';
comment on column pts.pts_tes_sel_rule.tsr_req_res_count is 'Selection rule requested reserve count';
comment on column pts.pts_tes_sel_rule.tsr_sel_pan_count is 'Selection rule selected panel count';
comment on column pts.pts_tes_sel_rule.tsr_sel_res_count is 'Selection rule selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_sel_rule
   add constraint pts_tes_sel_rule_pk primary key (tsr_tes_code, tsr_sel_group, tsr_tab_code, tsr_fld_code);

/**/
/* Indexes
/**/
create index pts_tes_sel_rule_ix01 on pts.pts_tes_sel_rule
   (tsr_tes_code, tsr_sel_group, tsr_dsp_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_sel_rule to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_sel_rule for pts.pts_tes_sel_rule;            