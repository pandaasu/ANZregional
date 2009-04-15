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
    pde_pet_breed                   number                        null,
    pde_household                   number                        not null,
    pde_birth_year                  number                        not null,
    pde_del_notifier                varchar2(32 char)             not null,
    pde_test_date                   date                          not null,
    pde_feed_comment                varchar2(4000 char)           not null,
    pde_health_comment              varchar2(4000 char)           not null);




--PET_CODE	NUMBER(6,0)
--U_VERSION	CHAR(1 BYTE)
--HHOLD_CODE	NUMBER(6,0)
--PET_TYPE_CODE	NUMBER(6,0)
--PET_BREED_CODE	NUMBER(6,0)
--PET_NAME	CHAR(30 BYTE)
--PET_LAST_TESTED	DATE
PET_STATUS_TYPE_CODE	NUMBER(2,0)
PET_STATUS	NUMBER(2,0)
--PET_YEAR_OF_BIRTH	NUMBER(4,0)

*******
PET_SEX_TYPE_CODE	NUMBER(2,0)
PET_SEX	NUMBER(2,0)
PET_DESEXED_TYPE_CODE	NUMBER(2,0)
PET_DESEXED	NUMBER(2,0)
PET_PEDIGREE_TYPE_CODE	NUMBER(2,0)
PET_PEDIGREE	NUMBER(2,0)
PET_RELATIONSHIP_TYPE_CODE	NUMBER(2,0)
PET_RELATIONSHIP	NUMBER(2,0)
PET_SIZE_TYPE_CODE	NUMBER(2,0)
PET_SIZE	NUMBER(2,0)
PET_ACT_LEVEL_TYPE_CODE	NUMBER(2,0)
PET_ACT_LEVEL	NUMBER(2,0)
PET_AWAKE_TYPE_CODE	NUMBER(2,0)
PET_AWAKE	NUMBER(2,0)
PET_ASLEEP_TYPE_CODE	NUMBER(2,0)
PET_ASLEEP	NUMBER(2,0)
PET_FUSSINESS_TYPE_CODE	NUMBER(2,0)
PET_FUSSINESS	NUMBER(2,0)
PET_MEALS_TYPE_CODE	NUMBER(2,0)
PET_MEALS	NUMBER(2,0)
MAIN_MEAL_TYPE_CODE	NUMBER(2,0)
MAIN_MEAL	NUMBER(2,0)
CAN_FREQ_TYPE_CODE	NUMBER(2,0)
CAN_FREQ	NUMBER(2,0)
CHUB_FREQ_TYPE_CODE	NUMBER(2,0)
CHUB_FREQ	NUMBER(2,0)
DRY_FREQ_TYPE_CODE	NUMBER(2,0)
DRY_FREQ	NUMBER(2,0)
SCRAP_RAW_FREQ_TYPE_CODE	NUMBER(2,0)
SCRAP_RAW_FREQ	NUMBER(2,0)
MEAT_FISH_FREQ_TYPE_CODE	NUMBER(2,0)
MEAT_FISH_FREQ	NUMBER(2,0)
BONES_FREQ_TYPE_CODE	NUMBER(2,0)
BONES_FREQ	NUMBER(2,0)
MILK_SPECIAL_DRINKS_TYPE_CODE	NUMBER(2,0)
MILK_SPECIAL_DRINKS	NUMBER(2,0)
SNAK_FREQ_TYPE_CODE	NUMBER(2,0)
SNAK_FREQ	NUMBER(2,0)
FEEDING_PREFERENCE_TYPE_CODE	NUMBER(2,0)
FEEDING_PREFERENCE	NUMBER(2,0)
DELETE_NOTED_BY_TYPE_CODE	NUMBER(2,0)
--DELETE_NOTED_BY	NUMBER(2,0)
HEALTH_RSTRCT_TYPE_CODE	NUMBER(2,0)
HEALTH_RSTRCT	NUMBER(2,0)
CHILLED_FREQ_TYPE_CODE	NUMBER(2,0)
CHILLED_FREQ	NUMBER(2,0)
SEMI_MOIST_FREQ_TYPE_CODE	NUMBER(2,0)
SEMI_MOIST_FREQ	NUMBER(2,0)
CAN_FED_PERCENTAGE	NUMBER(3,0)
DRY_FED_PERCENTAGE	NUMBER(3,0)
FRESH_MEAT_FED_PERCENTAGE	NUMBER(3,0)
SCRAPS_FED_PERCENTAGE	NUMBER(3,0)
CHUB_FED_PERCENTAGE	NUMBER(3,0)
CHILLED_FED_PERCENTAGE	NUMBER(3,0)
SEMI_MOIST_FED_PERCENTAGE	NUMBER(3,0)
FEEDING_COMMENTS	VARCHAR2(2000 BYTE)
PET_HEALTH_COMMENTS	VARCHAR2(2000 BYTE)
********

LAST_UPD_PRSN_ID	CHAR(8 BYTE)
LAST_UPD_TIME	DATE

******
FORMAT_TYPE_CODE	NUMBER(2,0)
FORMAT	NUMBER(2,0)
PET_ENVIRONMENT_TYPE_CODE	NUMBER(2,0)
PET_ENVIRONMENT	NUMBER(2,0)
******

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