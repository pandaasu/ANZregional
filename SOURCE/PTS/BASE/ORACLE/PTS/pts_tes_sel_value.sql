/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_sel_value
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Selection Value Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_sel_value
   (tsv_tes_code                    number                        not null,
    tsv_sel_group                   varchar2(32 char)             not null,
    tsv_tab_code                    varchar2(32 char)             not null,
    tsv_fld_code                    number                        not null,
    tsv_val_code                    number                        not null,
    tsv_val_text                    varchar2(256 char)            null,
    tsv_val_pcnt                    number                        null,
    tsv_req_pan_count               number                        not null,
    tsv_req_res_count               number                        not null,
    tsv_sel_pan_count               number                        not null,
    tsv_sel_res_count               number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_sel_value is 'Test Selection Value Table';
comment on column pts.pts_tes_sel_value.tsv_tes_code is 'Test code';
comment on column pts.pts_tes_sel_value.tsv_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_sel_value.tsv_tab_code is 'System table code';
comment on column pts.pts_tes_sel_value.tsv_fld_code is 'System field code';
comment on column pts.pts_tes_sel_value.tsv_val_code is 'System value code';
comment on column pts.pts_tes_sel_value.tsv_val_text is 'Value text';
comment on column pts.pts_tes_sel_value.tsv_val_pcnt is 'Value percent';
comment on column pts.pts_tes_sel_value.tsv_req_pan_count is 'Value requested panel count';
comment on column pts.pts_tes_sel_value.tsv_req_res_count is 'Value requested reserve count';
comment on column pts.pts_tes_sel_value.tsv_sel_pan_count is 'Value selected panel count';
comment on column pts.pts_tes_sel_value.tsv_sel_res_count is 'Value selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_sel_value
   add constraint pts_tes_sel_value_pk primary key (tsv_tes_code, tsv_sel_group, tsv_tab_code, tsv_fld_code, tsv_val_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_sel_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_sel_value for pts.pts_tes_sel_value;           