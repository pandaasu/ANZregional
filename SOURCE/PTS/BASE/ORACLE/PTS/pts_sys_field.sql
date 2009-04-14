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
    sfi_fld_code                    varchar2(32 char)             not null,
    sfi_fld_text                    varchar2(120 char)            not null,
    sfi_fld_status                  varchar2(1 char)              not null,
    sfi_upd_user                    varchar2(30 char)             not null,
    sfi_upd_date                    date                          not null
    sfi_fld_maintainable            varchar2(1 char)              not null,
    sfi_fld_selectable              varchar2(1 char)              not null,
    sfi_fld_mandatory               varchar2(1 char)              not null,
    sfi_fld_type                    varchar2(20 char)             not null,
    sfi_fld_default                 varchar2(4000)                null);

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
comment on column pts.pts_sys_field.sfi_fld_maintainable is 'System field user maintainable (0=No, 1=Yes)';
comment on column pts.pts_sys_field.sfi_fld_selectable is 'System field selectable (0=No, 1=Yes)';
comment on column pts.pts_sys_field.sfi_fld_mandatory is 'System field mandatory (0=No or 1=Yes)';
comment on column pts.pts_sys_field.sfi_fld_type is 'System field type (*SINGLE_LIST, *MULTIPLE_LIST, *SINGLE_TEXT, *SINGLE_NUMBER, *SINGLE_PERCENT)';
comment on column pts.pts_sys_field.sfi_fld_default is 'System field default (text representation of value)';

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