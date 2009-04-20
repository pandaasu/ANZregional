/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_value
 Owner  : pts

 Description
 -----------
 Product Testing System - System Value Table

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
create table pts.pts_sys_value
   (sva_tab_code                    varchar2(32 char)             not null,
    sva_fld_code                    number                        not null,
    sva_val_code                    number                        not null,
    sva_val_text                    varchar2(120 char)            not null,
    sva_val_status                  varchar2(1 char)              not null,
    sva_val_rul_sql                 varchar2(4000)                null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_value is 'System Value Table';
comment on column pts.pts_sys_value.sva_tab_code is 'System table code';
comment on column pts.pts_sys_value.sva_fld_code is 'System field code';
comment on column pts.pts_sys_value.sva_val_code is 'System value code';
comment on column pts.pts_sys_value.sva_val_text is 'System value text';
comment on column pts.pts_sys_value.sva_val_status is 'System value status (0=Inactive or 1=Active)';
comment on column pts.pts_sys_value.sva_val_rul_sql is 'System value rule SQL';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_value
   add constraint pts_sys_value_pk primary key (sva_tab_code, sva_fld_code, sva_val_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_value to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_value for pts.pts_sys_value;