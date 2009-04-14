/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_cla_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Classification Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_cla_definition
   (cde_cla_code                    varchar2(32 char)             not null,
    cde_cla_text                    varchar2(120 char)            not null,
    cde_cla_status                  varchar2(1 char)              not null,
    cde_upd_user                    varchar2(30 char)             not null,
    cde_upd_date                    date                          not null,
    cde_ent_code                    varchar2(32 char)             not null,
    cde_val_mand                    varchar2(1 char)              not null,
    cde_val_type                    varchar2(20 char)             not null,
    cde_val_dflt                    varchar2(4000)                null);

/**/
/* Comments
/**/
comment on table pts.pts_cla_definition is 'Classification Definition Table';
comment on column pts.pts_cla_definition.cde_cla_code is 'Classification code';
comment on column pts.pts_cla_definition.cde_text is 'Classification definition text';
comment on column pts.pts_cla_definition.cde_status is 'Classification definition status (0=Inactive or 1=Active)';
comment on column pts.pts_cla_definition.cde_upd_user is 'Classification definition update user';
comment on column pts.pts_cla_definition.cde_upd_date is 'Classification definition update date';
comment on column pts.pts_cla_definition.cde_ent_code is 'System entity code';
comment on column pts.pts_cla_definition.cde_val_mand is 'Classification definition mandatory (0=No or 1=Yes)';
comment on column pts.pts_cla_definition.cde_val_type is 'Classification definition type (*SINGLE_LIST, *MULTIPLE_LIST, *SINGLE_TEXT, *SINGLE_NUMBER, *SINGLE_PERCENT)';
comment on column pts.pts_cla_definition.cde_val_dflt is 'Classification definition default';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_cla_definition
   add constraint pts_cla_definition_pk primary key (cde_cla_code);

/**/
/* Indexes
/**/
create index pts_cla_definition_ix01 on pts.pts_cla_definition
   (cde_ent_code, cde_cla_status);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_cla_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_cla_definition for pts.pts_cla_definition;