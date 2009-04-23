/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sel_tem_value
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
create table pts.pts_sel_tem_value
   (stv_sel_template                number                        not null,
    stv_sel_group                   varchar2(32 char)             not null,
    stv_tab_code                    varchar2(32 char)             not null,
    stv_fld_code                    number                        not null,
    stv_val_code                    number                        not null,
    stv_val_text                    varchar2(256 char)            null,
    stv_val_pcnt                    number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_sel_tem_value is 'Selection Template Value Table';
comment on column pts.pts_sel_tem_value.stv_sel_template is 'Selection template code';
comment on column pts.pts_sel_tem_value.stv_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_sel_tem_value.stv_tab_code is 'System table code';
comment on column pts.pts_sel_tem_value.stv_fld_code is 'System field code';
comment on column pts.pts_sel_tem_value.stv_val_code is 'System value code';
comment on column pts.pts_sel_tem_value.stv_val_text is 'Value text';
comment on column pts.pts_sel_tem_value.stv_val_pcnt is 'Value percent mix';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sel_tem_value
   add constraint pts_sel_tem_value_pk primary key (stv_sel_template, stv_sel_group, stv_tab_code, stv_fld_code, stv_val_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sel_tem_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sel_tem_value for pts.pts_sel_tem_value;           