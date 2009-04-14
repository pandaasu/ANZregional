/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_hou_pet_type
 Owner  : pts

 Description
 -----------
 Product Testing System - Household Pet Type Table

 **NOTES**
 ---------
 1. This table is maintained automatically via pet maintenance.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_hou_pet_type
   (hpt_hou_code                    number                        not null,
    hpt_pet_type                    number                        not null,
    hpt_pet_count                   number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_hou_pet_type is 'Household Pet Type Table';
comment on column pts.pts_hou_pet_type.hpt_hou_code is 'Household code';
comment on column pts.pts_hou_pet_type.hpt_pet_type is 'Pet type code';
comment on column pts.pts_hou_pet_type.hpt_pet_count is 'Pet type count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_hou_pet_type
   add constraint pts_hou_pet_type_pk primary key (hpt_hou_code, hpt_pet_type);

/**/
/* Indexes
/**/
create index pts_hou_pet_type_ix01 on pts.pts_hou_pet_type
   (hpt_pet_type, hpt_hou_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_hou_pet_type to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_hou_pet_type for pts.pts_hou_pet_type;