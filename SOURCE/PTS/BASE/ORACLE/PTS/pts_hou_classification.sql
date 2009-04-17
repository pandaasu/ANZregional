/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_hou_classification
 Owner  : pts

 Description
 -----------
 Product Testing System - Household Classification Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_hou_classification
   (hcl_hou_code                    number                        not null,
    hcl_tab_code                    varchar2(32 char)             not null,
    hcl_fld_code                    varchar2(32 char)             not null,
    hcl_fld_value                   number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_hou_classification is 'Household Classification Table';
comment on column pts.pts_hou_classification.hcl_hou_code is 'Household code';
comment on column pts.pts_hou_classification.hcl_tab_code is 'System table code';
comment on column pts.pts_hou_classification.hcl_fld_code is 'System field code';
comment on column pts.pts_hou_classification.hcl_fld_value is 'Classification field value';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_hou_classification
   add constraint pts_hou_classification_pk primary key (hcl_hou_code, hcl_tab_code, hcl_fld_code, hcl_fld_value);

/**/
/* Indexes
/**/
create index pts_hou_classification_ix01 on pts.pts_hou_classification
   (hcl_tab_code, hcl_fld_code, hcl_fld_value, hcl_hou_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_hou_classification to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_hou_classification for pts.pts_hou_classification;