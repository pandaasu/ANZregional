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
    pde_name                        varchar2(120 char)            not null
    pde_pet_status                  number                        not null,
    pde_upd_user                    varchar2(30 char)             not null,
    pde_upd_date                    date                          not null,
    pde_pet_type                    number                        null,
    pde_household                   number                        not null,
    pde_birth_year                  number                        not null,
    pde_del_notifier                number                        not null,
    pde_test_date                   date                          not null,
    pde_feed_comment                varchar2(4000 char)           not null,
    pde_health_comment              varchar2(4000 char)           not null);

/**/
/* Comments
/**/
comment on table pts.pts_pet_definition is 'Pet Definition Table';
comment on column pts.pts_pet_definition.pde_pet is 'Pet definition sequence number (sequence generated)';
comment on column pts.pts_pet_definition.pde_name is 'Pet definition name';
comment on column pts.pts_pet_definition.pde_status is 'Pet definition status (*AVAILABLE, *ONTEST, *SUSPENDED, *SUSPENDED_ONTEST, *DELETED)';
comment on column pts.pts_pet_definition.pde_upd_user is 'Pet definition update user';
comment on column pts.pts_pet_definition.pde_upd_date is 'Pet definition update date';
comment on column pts.pts_pet_definition.pde_pet_type is 'Pet definition type code';
comment on column pts.pts_pet_definition.pde_pet_breed is 'Pet definition breed code';
comment on column pts.pts_pet_definition.pde_ent_type is 'Pet definition entity type code';
comment on column pts.pts_pet_definition.pde_household is 'Pet definition household sequence number';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_pet_definition
   add constraint pts_pde_pk primary key (pde_pet);

/**/
/* Indexes
/**/
create index pts_pde_ix01 on pts.pts_pet_definition
   (pde_pet_type, pde_status);
create index pts_pde_ix02 on pts.pts_pet_definition
   (pde_pet_breed, pde_status);
create index pts_pde_ix03 on pts.pts_pet_definition
   (pde_household, pde_status);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_pet_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_pet_definition for pts.pts_pet_definition;         