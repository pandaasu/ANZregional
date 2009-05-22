/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_stm_value
 Owner  : pts

 Description
 -----------
 Product Testing System - Selection Template Value Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_stm_value
   (stv_stm_code                    number                        not null,
    stv_sel_group                   varchar2(32 char)             not null,
    stv_tab_code                    varchar2(32 char)             not null,
    stv_fld_code                    number                        not null,
    stv_val_code                    number                        not null,
    stv_val_text                    varchar2(256 char)            null,
    stv_val_pcnt                    number                        null,
    stv_req_mem_count               number                        not null,
    stv_req_res_count               number                        not null,
    stv_sel_mem_count               number                        not null,
    stv_sel_res_count               number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_stm_value is 'Selection Template Value Table';
comment on column pts.pts_stm_value.stv_stm_code is 'Selection template code';
comment on column pts.pts_stm_value.stv_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_stm_value.stv_tab_code is 'System table code';
comment on column pts.pts_stm_value.stv_fld_code is 'System field code';
comment on column pts.pts_stm_value.stv_val_code is 'System value code';
comment on column pts.pts_stm_value.stv_val_text is 'Value text';
comment on column pts.pts_stm_value.stv_val_pcnt is 'Value percent';
comment on column pts.pts_stm_value.stv_req_mem_count is 'Value requested member count';
comment on column pts.pts_stm_value.stv_req_res_count is 'Value requested reserve count';
comment on column pts.pts_stm_value.stv_sel_mem_count is 'Value selected member count';
comment on column pts.pts_stm_value.stv_sel_res_count is 'Value selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_stm_value
   add constraint pts_stm_value_pk primary key (stv_stm_code, stv_sel_group, stv_tab_code, stv_fld_code, stv_val_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_stm_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_stm_value for pts.pts_stm_value;           