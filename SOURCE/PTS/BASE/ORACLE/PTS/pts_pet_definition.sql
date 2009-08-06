/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_pet_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Pet Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_pet_definition
   (pde_pet_code                    number                        not null,
    pde_pet_status                  number                        not null,
    pde_upd_user                    varchar2(30 char)             not null,
    pde_upd_date                    date                          not null,
    pde_pet_name                    varchar2(120 char)            null,
    pde_pet_type                    number                        null,
    pde_hou_code                    number                        null,
    pde_birth_year                  number                        null,
    pde_del_notifier                number                        null,
    pde_test_date                   date                          null,
    pde_feed_comment                varchar2(2000 char)           null,
    pde_health_comment              varchar2(2000 char)           null,
    pde_tes_code                    number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_pet_definition is 'Pet Definition Table';
comment on column pts.pts_pet_definition.pde_pet_code is 'Pet code';
comment on column pts.pts_pet_definition.pde_pet_status is 'Pet status';
comment on column pts.pts_pet_definition.pde_upd_user is 'Pet update user';
comment on column pts.pts_pet_definition.pde_upd_date is 'Pet update date';
comment on column pts.pts_pet_definition.pde_pet_name is 'Pet name';
comment on column pts.pts_pet_definition.pde_pet_type is 'Pet type code';
comment on column pts.pts_pet_definition.pde_hou_code is 'Household code';
comment on column pts.pts_pet_definition.pde_birth_year is 'Pet birth year';
comment on column pts.pts_pet_definition.pde_del_notifier is 'Pet deletion notifier';
comment on column pts.pts_pet_definition.pde_test_date is 'Pet last tested date';
comment on column pts.pts_pet_definition.pde_feed_comment is 'Pet feeding comments';
comment on column pts.pts_pet_definition.pde_health_comment is 'Pet health comments';
comment on column pts.pts_pet_definition.pde_tes_code is 'Pet current test code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_pet_definition
   add constraint pts_pde_pk primary key (pde_pet_code);

/**/
/* Indexes
/**/
create index pts_pde_ix01 on pts.pts_pet_definition
   (pde_pet_type, pde_pet_code);
create index pts_pde_ix02 on pts.pts_pet_definition
   (pde_hou_code, pde_pet_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_pet_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_pet_definition for pts.pts_pet_definition;         