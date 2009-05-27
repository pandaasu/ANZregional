/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_field
 Owner  : pts

 Description
 -----------
 Product Testing System - System Field Table

 **NOTES**
 ---------
 1. This is a system table and therefore has no maintenance facility.
 2. Rows should never be deleted only inactivated.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_sys_field
   (sfi_tab_code                    varchar2(32 char)             not null,
    sfi_fld_code                    number                        not null,
    sfi_fld_text                    varchar2(120 char)            not null,
    sfi_fld_status                  varchar2(1 char)              not null,
    sfi_upd_user                    varchar2(30 char)             not null,
    sfi_upd_date                    date                          not null,
    sfi_fld_upd_user                varchar2(1 char)              not null,
    sfi_fld_tes_rule                varchar2(1 char)              not null,
    sfi_fld_inp_leng                number                        not null,
    sfi_fld_sel_type                varchar2(32 char)             not null,
    sfi_fld_rul_type                varchar2(32 char)             not null,
    sfi_fld_rul_sql                 varchar2(4000)                null,
    sfi_fld_dsp_seqn                number                        null,
    sfi_fld_val_type                varchar2(32 char)             null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_field is 'System Field Table';
comment on column pts.pts_sys_field.sfi_tab_code is 'System table code';
comment on column pts.pts_sys_field.sfi_fld_code is 'System field code';
comment on column pts.pts_sys_field.sfi_fld_text is 'System field text';
comment on column pts.pts_sys_field.sfi_fld_status is 'System field status (0=Inactive or 1=Active)';
comment on column pts.pts_sys_field.sfi_upd_user is 'System field update user';
comment on column pts.pts_sys_field.sfi_upd_date is 'System field update date';
comment on column pts.pts_sys_field.sfi_fld_upd_user is 'System field user updatable (0=No, 1=Yes)';
comment on column pts.pts_sys_field.sfi_fld_tes_rule is 'System field test rule allowable (0=No, 1=Yes)';
comment on column pts.pts_sys_field.sfi_fld_inp_leng is 'System field input length for select and rule - *TEXT(1 to 256), *NUMBER(1 to 15), all other types (0)';
comment on column pts.pts_sys_field.sfi_fld_sel_type is 'System field selection type (*LOGIC, *OPT_SINGLE_LIST, *OPT_MULTIPLE_LIST, *MAN_SINGLE_LIST, *MAN_MULTIPLE_LIST, *TEXT, *NUMBER, *PERCENT)';
comment on column pts.pts_sys_field.sfi_fld_rul_type is 'System field rule type (*LIST, *TEXT, *NUMBER, *PERCENT)';
comment on column pts.pts_sys_field.sfi_fld_rul_sql is 'System field rule SQL';
comment on column pts.pts_sys_field.sfi_fld_dsp_seqn is 'System field display sequence';
comment on column pts.pts_sys_field.sfi_fld_val_type is 'System field value type (*ALL or *SELECT)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_field
   add constraint pts_sys_field_pk primary key (sfi_tab_code, sfi_fld_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_field to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_field for pts.pts_sys_field;