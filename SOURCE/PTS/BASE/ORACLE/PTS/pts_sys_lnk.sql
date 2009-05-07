/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_link
 Owner  : pts

 Description
 -----------
 Product Testing System - System Link Table

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
create table pts.pts_sys_link
   (sli_ent_code                    varchar2(32 char)             not null,
    sli_tab_code                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_link is 'System Link Table';
comment on column pts.pts_sys_link.sli_ent_code is 'System entity code';
comment on column pts.pts_sys_link.sli_tab_code is 'System table code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_link
   add constraint pts_sys_link_pk primary key (sli_ent_code, sli_tab_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_link to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_link for pts.pts_sys_link;