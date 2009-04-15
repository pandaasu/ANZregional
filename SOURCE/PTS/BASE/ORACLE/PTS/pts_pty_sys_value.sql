/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_pty_sys_value
 Owner  : pts

 Description
 -----------
 Product Testing System - Pet Type System Value Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_pty_sys_value
   (psv_pet_type                    number                        not null,
    psv_tab_code                    varchar2(32 char)             not null,
    psv_fld_code                    varchar2(32 char)             not null,
    psv_val_code                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_pty_sys_value is 'Pet Type System Value Table';
comment on column pts.pts_pty_sys_value.psv_pet_type is 'Pet type code';
comment on column pts.pts_pty_sys_value.psv_tab_code is 'System table code';
comment on column pts.pts_pty_sys_value.psv_fld_code is 'System field code';
comment on column pts.pts_pty_sys_value.psv_val_code is 'System value code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_pty_sys_value
   add constraint pts_pty_sys_value_pk primary key (psv_pet_type, psv_tab_code, psv_fld_code, psv_val_code);

/**/
/* Indexes
/**/
create index pts_pty_sys_value_ix01 on pts.pts_pty_sys_value
   (psv_tab_code, psv_fld_code, psv_val_code, psv_pet_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_pty_sys_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_pty_sys_value for pts.pts_pty_sys_value;