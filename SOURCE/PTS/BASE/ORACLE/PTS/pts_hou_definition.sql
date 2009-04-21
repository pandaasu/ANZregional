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