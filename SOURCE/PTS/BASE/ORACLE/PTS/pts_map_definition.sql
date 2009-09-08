/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_map_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Map Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_map_definition
   (mde_map_code                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_map_definition is 'Map Definition Table';
comment on column pts.pts_map_definition.mde_map_code is 'Map code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_map_definition
   add constraint pts_map_definition_pk primary key (mde_map_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_map_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_map_definition for pts.pts_map_definition;    