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
 2. Rows should only be deleted when no references.

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
    sfi_fld_maintainable            varchar2(1 char)              not null,
    sfi_fld_selectable              varchar2(1 char)              not null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_field is 'System Field Table';
comment on column pts.pts_sys_field.sfi_tab_code is 'System table code';
comment on column pts.pts_sys_field.sfi_fld_code is 'System field code';
comment on column pts.pts_sys_field.sfi_fld_text is 'System field text';
comment on column pts.pts_sys_field.sfi_fld_maintainable is 'System field user maintainable (0=No, 1=Yes)';
comment on column pts.pts_sys_field.sfi_fld_selectable is 'System field selectable (0=No, 1=Yes)';

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