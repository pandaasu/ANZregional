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
    hde_status                      number                        not null,
    hde_upd_user                    varchar2(30 char)             not null,
    hde_upd_date                    date                          not null,
    hde_del_notifier                number                        null,
    hde_jon_date                    date                          null,
    hde_lst_date                    date                          null,
    hde_loc_street                  varchar2(120 char)            null,
    hde_loc_town                    varchar2(120 char)            null,
    hde_loc_postcode                varchar2(120 char)            null,
    hde_loc_country                 varchar2(32 char)             null,
    hde_tel_areacode                varchar2(32 char)             null,
    hde_tel_number                  varchar2(32 char)             null,
   -- hde_tel_mobile                  varchar2(32 char)             not null,
    hde_con_surname                 varchar2(120 char)            null,
    hde_con_fullname                varchar2(120 char)            null,
    hde_con_birth_year              number                        null,
    hde_notes                       varchar2(4000 char)           null,
    hde_test_status                 varchar2(32 char)             null,
    hde_geo_type                    varchar2(32 char)             null,
    hde_geo_zone                    varchar2(32 char)             null);

);

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



56 Plavlova Court
Wodonga
3690 
Australia
060
565656
Mr. Sniggers                  


GEOG_ZONE_TYPE_CODE	NUMBER(6,0)
GEOG_ZONE_CODE	NUMBER(6,0)
??ALLOCATED_TO_TEST_TYPE_CODE	NUMBER(2,0)
??ALLOCATED_TO_TEST	NUMBER(2,0)
HOUSEHOLD_STATUS_TYPE_CODE	NUMBER(2,0)
HOUSEHOLD_STATUS	NUMBER(2,0)

--HHOLD_LOCN_STREET	CHAR(50 BYTE)
--HHOLD_LOCN_TOWN	CHAR(30 BYTE)
--HHOLD_LOCN_POSTCODE	CHAR(8 BYTE)
--HHOLD_LOCN_COUNTRY	CHAR(30 BYTE)
--HHOLD_PHONE_AREACODE	CHAR(5 BYTE)
--HHOLD_PHONE_NUM	CHAR(10 BYTE)
--PRCPT_NAME	CHAR(30 BYTE)
??PRCPT_YEAR_OF_BIRTH	NUMBER(4,0)
--OCC_ADULT_MALE	NUMBER(2,0)
--OCC_ADULT_FEMALE	NUMBER(2,0)
--OCC_CHILD_15_18	NUMBER(2,0)
--OCC_CHILD_5_14	NUMBER(2,0)
--OCC_CHILD_UNDER_5	NUMBER(2,0)
--HHOLD_NOTES	VARCHAR2(2000 BYTE)
--HHOLD_LAST_USED	DATE
--PANEL_JOINED_DATE	DATE

--FEMALE_OCC_CHILD_15_18	NUMBER(2,0)
--FEMALE_OCC_CHILD_5_14	NUMBER(2,0)
--FEMALE_OCC_CHILD_UNDER_5	NUMBER(2,0)
FOOD_TEST_STATUS	NUMBER(2,0)
FOOD_TEST_STATUS_TYPE_CODE	NUMBER(2,0)


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