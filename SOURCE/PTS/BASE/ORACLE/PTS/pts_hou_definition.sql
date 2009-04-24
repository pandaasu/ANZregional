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
    hde_hou_status                  number                        not null,
    hde_upd_user                    varchar2(30 char)             not null,
    hde_upd_date                    date                          not null,
    hde_geo_type                    number                        null,
    hde_geo_zone                    number                        null,
    hde_del_notifier                number                        null,
    hde_dat_joined                  date                          null,
    hde_dat_used                    date                          null,
    hde_loc_street                  varchar2(120 char)            null,
    hde_loc_town                    varchar2(120 char)            null,
    hde_loc_postcode                varchar2(32 char)             null,
    hde_loc_country                 varchar2(32 char)             null,
    hde_tel_areacode                varchar2(32 char)             null,
    hde_tel_number                  varchar2(32 char)             null,
    hde_con_surname                 varchar2(120 char)            null,
    hde_con_fullname                varchar2(120 char)            null,
    hde_con_birth_year              number                        null,
    hde_notes                       varchar2(2000 char)           null);                                                                                                                                                                              

/**/
/* Comments
/**/
comment on table pts.pts_hou_definition is 'Household Definition Table';
comment on column pts.pts_hou_definition.hde_hou_code is 'Household code';
comment on column pts.pts_hou_definition.hde_hou_status is 'Household status';
comment on column pts.pts_hou_definition.hde_upd_user is 'Household update user';
comment on column pts.pts_hou_definition.hde_upd_date is 'Household update date';
comment on column pts.pts_hou_definition.hde_geo_type is 'Household geographic type code';
comment on column pts.pts_hou_definition.hde_geo_zone is 'Household geographic zone code';
comment on column pts.pts_hou_definition.hde_del_notifier is 'Household deletion notifier';
comment on column pts.pts_hou_definition.hde_dat_joined is 'Household date joined';
comment on column pts.pts_hou_definition.hde_dat_used is 'Household date last used';
comment on column pts.pts_hou_definition.hde_loc_street is 'Household location street';
comment on column pts.pts_hou_definition.hde_loc_town is 'Household location town';
comment on column pts.pts_hou_definition.hde_loc_postcode is 'Household location postcode';
comment on column pts.pts_hou_definition.hde_loc_country is 'Household location country';
comment on column pts.pts_hou_definition.hde_tel_areacode is 'Household telephone areacode';
comment on column pts.pts_hou_definition.hde_tel_number is 'Household telephone number';
comment on column pts.pts_hou_definition.hde_con_surname is 'Household contact surname';
comment on column pts.pts_hou_definition.hde_con_fullname is 'Household contact full name';
comment on column pts.pts_hou_definition.hde_con_birth_year is 'Household contact birth year';
comment on column pts.pts_hou_definition.hde_notes is 'Household notes';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_hou_definition
   add constraint pts_hou_definition_pk primary key (hde_household);

/**/
/* Indexes
/**/
create index pts_hou_definition_ix01 on pts.pts_hou_definition
   (hde_geo_type, hde_geo_zone, hde_hou_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_hou_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_hou_definition for pts.pts_hou_definition;