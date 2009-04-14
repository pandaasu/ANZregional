/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_pet_classification
 Owner  : pts

 Description
 -----------
 Product Testing System - Pet Classification Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_pet_classification
   (pcl_pet_code                    number                        not null,
    pcl_sit_code                    varchar2(32 char)             not null,
    pcl_tab_code                    varchar2(32 char)             not null,
    pcl_fld_code                    varchar2(32 char)             not null,
    pcl_fld_value                   varchar2(4000 char)           not null);

/**/
/* Comments
/**/
comment on table pts.pts_pet_classification is 'Pet Classification Table';
comment on column pts.pts_pet_classification.pcl_pet_code is 'Pet code';
comment on column pts.pts_pet_classification.pcl_sit_code is 'Site code';
comment on column pts.pts_pet_classification.pcl_tab_code is 'System table code';
comment on column pts.pts_pet_classification.pcl_fld_code is 'System field code';
comment on column pts.pts_pet_classification.pcl_fld_value is 'Classification field value';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_pet_classification
   add constraint pts_pet_classification_pk primary key (pcl_pet_code, pcl_sit_code, pcl_tab_code, pcl_fld_code, pcl_fld_value);

/**/
/* Indexes
/**/
create index pts_pet_classification_ix01 on pts.pts_pet_classification
   (pcl_sit_code, pcl_tab_code, pcl_fld_code, pcl_fld_value, pcl_pet_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_pet_classification to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_pet_classification for pts.pts_pet_classification;