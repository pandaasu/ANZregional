/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_table
 Owner  : pts

 Description
 -----------
 Product Testing System - System Table Table

 **NOTES**
 ---------
 1. This is a system table and therefore has no maintenance facility.
 2. Rows should never be deleted.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_sys_table
   (sta_tab_code                    varchar2(32 char)             not null,
    sta_tab_text                    varchar2(120 char)            not null,
    sta_ent_code                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_table is 'System Table Table';
comment on column pts.pts_sys_table.sta_tab_code is 'System table code';
comment on column pts.pts_sys_table.sta_tab_text is 'System table text';
comment on column pts.pts_sys_table.sta_ent_code is 'System entity code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_table
   add constraint pts_sys_table_pk primary key (sta_tab_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_table to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_table for pts.pts_sys_table;