/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_value
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Value Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_value
   (tva_tes_code                    number                        not null,
    tva_sel_group                   varchar2(32 char)             not null,
    tva_tab_code                    varchar2(32 char)             not null,
    tva_fld_code                    number                        not null,
    tva_val_code                    number                        not null,
    tva_val_text                    varchar2(256 char)            null,
    tva_val_pcnt                    number                        null,
    tva_req_mem_count               number                        not null,
    tva_req_res_count               number                        not null,
    tva_sel_mem_count               number                        not null,
    tva_sel_res_count               number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_value is 'Test Value Table';
comment on column pts.pts_tes_value.tva_tes_code is 'Test code';
comment on column pts.pts_tes_value.tva_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_value.tva_tab_code is 'System table code';
comment on column pts.pts_tes_value.tva_fld_code is 'System field code';
comment on column pts.pts_tes_value.tva_val_code is 'System value code';
comment on column pts.pts_tes_value.tva_val_text is 'Value text';
comment on column pts.pts_tes_value.tva_val_pcnt is 'Value percent mix';
comment on column pts.pts_tes_value.tva_req_mem_count is 'Value requested member count';
comment on column pts.pts_tes_value.tva_req_res_count is 'Value requested reserve count';
comment on column pts.pts_tes_value.tva_sel_mem_count is 'Value selected member count';
comment on column pts.pts_tes_value.tva_sel_res_count is 'Value selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_value
   add constraint pts_tes_value_pk primary key (tva_tes_code, tva_sel_group, tva_tab_code, tva_fld_code, tva_val_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_value for pts.pts_tes_value;           