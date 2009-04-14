/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sys_entity
 Owner  : pts

 Description
 -----------
 Product Testing System - System Entity Table

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
create table pts.pts_sys_entity
   (sen_ent_code                    varchar2(32 char)             not null,
    sen_ent_text                    varchar2(120 char)            not null);

/**/
/* Comments
/**/
comment on table pts.pts_sys_entity is 'System Entity Table';
comment on column pts.pts_sys_entity.sen_ent_code is 'System entity code';
comment on column pts.pts_sys_entity.sen_ent_text is 'System entity text';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sys_entity
   add constraint pts_sys_entity_pk primary key (sen_ent_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sys_entity to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sys_entity for pts.pts_sys_entity;