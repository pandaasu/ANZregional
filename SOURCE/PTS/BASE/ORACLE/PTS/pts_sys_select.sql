/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_select
 Owner  : pts

 Description
 -----------
 Product Testing System - System Select Table

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
create table pts.pts_sys_select
   (sse_tab_code                    varchar2(32 char)             not null,
    sse_fld_code                    number                        not null,
    sse_sel_code                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_select is 'System Select Table';
comment on column pts.pts_sys_select.sse_tab_code is 'System table code';
comment on column pts.pts_sys_select.sse_fld_code is 'System field code';
comment on column pts.pts_sys_select.sse_sel_code is 'System select code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_select
   add constraint pts_sys_select_pk primary key (sse_tab_code, sse_fld_code, sse_sel_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_select to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_select for pts.pts_sys_select;