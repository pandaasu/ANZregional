/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_definition
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
create table pts.pts_tes_definition
   (tde_tes_code                    number                        not null,
    tde_tes_text                    varchar2(120 char)            not null,
    tde_tes_status                  number                        not null,
    tde_upd_user                    varchar2(30 char)             not null,
    tde_upd_date                    date                          not null,
    tde_uni_code                    number                        null,
    tde_stm_code                    number                        null,
    tde_glo_status                  number                        null,
    tde_tes_type                    number                        null,
    tde_tes_target                  number                        null,
    tde_tes_requestor               varchar2(30 char)             null,
    tde_tes_aim                     varchar2(2000 char)           null,
    tde_tes_reason                  varchar2(2000 char)           null,
    tde_tes_prediction              varchar2(2000 char)           null,
    tde_tes_comment                 varchar2(2000 char)           null,
    tde_day_count                   number                        null,
    tde_req_mem_count               number                        null,
    tde_req_res_count               number                        null,
    tde_hou_pet_multiple            varchar2(1 char)              null,
    tde_tes_error                   varchar2(2000 char)           null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_definition is 'Product Test Table';
--comment on column pts.pts_tes_definition.tde_site is 'Product test site';
--comment on column pts.pts_tes_definition.tde_test is 'Product test code';
--comment on column pts.pts_tes_definition.tde_text is 'Product test text';
--comment on column pts.pts_tes_definition.tde_status is 'Product test status';
--comment on column pts.pts_tes_definition.tde_upd_user is 'Product test update user';
--comment on column pts.pts_tes_definition.tde_upd_date is 'Product test update date';
--comment on column pts.pts_tes_definition.tde_tes_type is 'Product test type (*HHOLD or *PET)';
--comment on column pts.pts_tes_definition.tde_req_mem_count is 'Product test requested member count';
--comment on column pts.pts_tes_definition.tde_req_res_count is 'Product test requested reserve count';
--comment on column pts.pts_tes_definition.tde_hou_pet_multiple is 'Product test household pet multiple (0=No or 1=Yes)';
--comment on column pts.pts_tes_definition.tde_notes is 'Product test notes';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_definition
   add constraint pts_tes_definition_pk primary key (tde_tes_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_definition for pts.pts_tes_definition;    