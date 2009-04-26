/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sam_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_sam_definition
   (sde_sam_code                    number                        not null,
    sde_sam_text                    varchar2(120 char)            not null,
    sde_sam_status                  varchar2(1 char)              not null,
    sde_upd_user                    varchar2(30 char)             not null,
    sde_upd_date                    date                          not null,
    sde_uom_code                    number                        null,
    sde_uom_size                    number                        null,
    sde_pre_locn                    number                        null,
    sde_pre_date                    date                          null,
    sde_ext_rec_refnr               varchar2(32 char)             null,
    sde_plop_code                   varchar2(32 char)             null);

/**/
/* Comments
/**/
comment on table pts.pts_sam_definition is 'Sample Definition Table';
comment on column pts.pts_sam_definition.sde_sam_code is 'Sample code';
comment on column pts.pts_sam_definition.sde_sam_text is 'Sample text';
comment on column pts.pts_sam_definition.sde_sam_status is 'Sample status (0=Inactive or 1=Active)';
comment on column pts.pts_sam_definition.sde_upd_user is 'Sample update user';
comment on column pts.pts_sam_definition.sde_upd_date is 'Sample update date';
comment on column pts.pts_sam_definition.sde_uom_code is 'Unit of measure code';
comment on column pts.pts_sam_definition.sde_uom_size is 'Unit of measure size';
comment on column pts.pts_sam_definition.sde_pre_locn is 'Prepared location code';
comment on column pts.pts_sam_definition.sde_pre_date is 'Prepared date';
comment on column pts.pts_sam_definition.sde_ext_rec_refnr is 'External recipe reference';
comment on column pts.pts_sam_definition.sde_plop_code is 'PLOP code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sam_definition
   add constraint pts_sam_definition_pk primary key (sde_sam_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sam_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sam_definition for pts.pts_sam_definition;    