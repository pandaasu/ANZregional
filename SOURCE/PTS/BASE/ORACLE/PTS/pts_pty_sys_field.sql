/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_pty_sys_field
 Owner  : pts

 Description
 -----------
 Product Testing System - Pet Type System Field Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_pty_sys_field
   (psf_pet_type                    number                        not null,
    psf_tab_code                    varchar2(32 char)             not null,
    psf_fld_code                    varchar2(32 char)             not null,
    psf_val_type                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_pty_sys_field is 'Pet Type System Field Table';
comment on column pts.pts_pty_sys_field.psf_pet_type is 'Pet type code';
comment on column pts.pts_pty_sys_field.psf_tab_code is 'System table code';
comment on column pts.pts_pty_sys_field.psf_fld_code is 'System field code';
comment on column pts.pts_pty_sys_field.psf_val_type is 'System field value type (*ALL or *SELECT)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_pty_sys_field
   add constraint pts_pty_sys_field_pk primary key (psf_pet_type, psf_tab_code, psf_fld_code);

/**/
/* Indexes
/**/
create index pts_pty_sys_field_ix01 on pts.pts_pty_sys_field
   (psf_tab_code, psf_fld_code, psf_pet_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_pty_sys_field to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_pty_sys_field for pts.pts_pty_sys_field;