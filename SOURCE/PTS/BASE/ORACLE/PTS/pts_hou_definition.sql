/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_hou_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Household Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_hou_definition
   (hde_hou_code                    number                        not null,
    hde_text                        varchar2(120 char)            not null,
    hde_status                      varchar2(20 char)             not null,
    hde_upd_user                    varchar2(30 char)             not null,
    hde_upd_date                    date                          not null,
    hde_geo_area                    varchar2(32 char)             not null,
    hde_nam_title                    varchar2(32 char)             not null,
    hde_nam_first                    varchar2(32 char)             not null,
    hde_nam_last                   varchar2(32 char)             not null,
    hde_nam_full                   varchar2(32 char)             not null,
    hde_adr_street                    varchar2(32 char)             not null,
    hde_adr_suburb                    varchar2(32 char)             not null,
    hde_adr_city                    varchar2(32 char)             not null,
    hde_adr_postcode                    varchar2(32 char)             not null,
    hde_adr_country                    varchar2(32 char)             not null,
    hde_tel_areacode                    varchar2(32 char)             not null,
    hde_tel_number                    varchar2(32 char)             not null,
    hde_tel_mobile                    varchar2(32 char)             not null,
    hde_notes                    varchar2(4000 char)             not null,
    hde_test_status                    varchar2(32 char)             not null,
    hde_geo_type                    varchar2(32 char)             not null,
    hde_geo_zone                    varchar2(32 char)             not null);

/**/
/* Comments
/**/
comment on table pts.pts_hou_definition is 'Household Definition Table';
comment on column pts.pts_hou_definition.hde_household is 'Household sequence number (sequence generated)';
comment on column pts.pts_hou_definition.hde_text is 'Household text';
comment on column pts.pts_hou_definition.hde_status is 'Household status (*ACTIVE or *INACTIVE)';
comment on column pts.pts_hou_definition.hde_upd_user is 'Household update user';
comment on column pts.pts_hou_definition.hde_upd_date is 'Household update date';
comment on column pts.pts_hou_definition.hde_geo_type is 'Household geographic type code';
comment on column pts.pts_hou_definition.hde_geo_zone is 'Household geographic zone code';


GEOG_ZONE_TYPE_CODE	NUMBER(6,0)
GEOG_ZONE_CODE	NUMBER(6,0)
HHOLD_GROSS_INCOME_TYPE_CODE	NUMBER(2,0)
HHOLD_GROSS_INCOME	NUMBER(2,0)
PRCPT_SEX_TYPE_CODE	NUMBER(2,0)
PRCPT_SEX	NUMBER(2,0)
PRCPT_WORK_STATUS_TYPE_CODE	NUMBER(2,0)
PRCPT_WORK_STATUS	NUMBER(2,0)
PRCPT_EDUCATION_TYPE_CODE	NUMBER(2,0)
PRCPT_EDUCATION	NUMBER(2,0)
PRCPT_MRTL_STATUS_TYPE_CODE	NUMBER(2,0)
PRCPT_MRTL_STATUS	NUMBER(2,0)
PRCPT_AGE_RANGE_TYPE_CODE	NUMBER(2,0)
PRCPT_AGE_RANGE	NUMBER(2,0)
ALLOCATED_TO_TEST_TYPE_CODE	NUMBER(2,0)
ALLOCATED_TO_TEST	NUMBER(2,0)
HOUSEHOLD_STATUS_TYPE_CODE	NUMBER(2,0)
HOUSEHOLD_STATUS	NUMBER(2,0)
DELETE_NOTED_BY_TYPE_CODE	NUMBER(2,0)
DELETE_NOTED_BY	NUMBER(2,0)
HHOLD_LOCN_STREET	CHAR(50 BYTE)
HHOLD_LOCN_TOWN	CHAR(30 BYTE)
HHOLD_LOCN_POSTCODE	CHAR(8 BYTE)
HHOLD_LOCN_COUNTRY	CHAR(30 BYTE)
HHOLD_PHONE_AREACODE	CHAR(5 BYTE)
HHOLD_PHONE_NUM	CHAR(10 BYTE)
PRCPT_NAME	CHAR(30 BYTE)
PRCPT_YEAR_OF_BIRTH	NUMBER(4,0)
OCC_ADULT_MALE	NUMBER(2,0)
OCC_ADULT_FEMALE	NUMBER(2,0)
OCC_CHILD_15_18	NUMBER(2,0)
OCC_CHILD_5_14	NUMBER(2,0)
OCC_CHILD_UNDER_5	NUMBER(2,0)
HHOLD_NOTES	VARCHAR2(2000 BYTE)
HHOLD_LAST_USED	DATE
PANEL_JOINED_DATE	DATE
LAST_UPD_PRSN_ID	CHAR(8 BYTE)
LAST_UPD_TIME	DATE
FEMALE_OCC_CHILD_15_18	NUMBER(2,0)
FEMALE_OCC_CHILD_5_14	NUMBER(2,0)
FEMALE_OCC_CHILD_UNDER_5	NUMBER(2,0)
FOOD_TEST_STATUS	NUMBER(2,0)
FOOD_TEST_STATUS_TYPE_CODE	NUMBER(2,0)
URBANISATION_TYPE_CODE	NUMBER(2,0)
URBANISATION	NUMBER(2,0)

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_hou_definition
   add constraint pts_hou_definition_pk primary key (hde_household);

/**/
/* Indexes
/**/
create index pts_hou_definition_ix01 on pts.pts_hou_definition
   (hde_geo_area, hde_status);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_hou_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_hou_definition for pts.pts_hou_definition;