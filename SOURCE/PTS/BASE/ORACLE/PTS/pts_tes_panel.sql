/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_panel
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Panel Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_panel
   (tpa_tes_code                    number                        not null,
    tpa_pan_code                    number                        not null,
    tpa_pan_status                  varchar2(32 char)             not null,
    tpa_sel_group                   varchar2(32 char)             not null,
    tpa_pet_code                    number                        null,
    tpa_pet_status                  number                        null,
    tpa_pet_name                    varchar2(120 char)            null,
    tpa_pet_type                    number                        null,
    tpa_birth_year                  number                        null,
    tpa_feed_comment                varchar2(2000 char)           null,
    tpa_health_comment              varchar2(2000 char)           null,
    tpa_hou_code                    number                        null,
    tpa_hou_status                  number                        null,
    tpa_geo_type                    number                        null,
    tpa_geo_zone                    number                        null,
    tpa_loc_street                  varchar2(120 char)            null,
    tpa_loc_town                    varchar2(120 char)            null,
    tpa_loc_postcode                varchar2(32 char)             null,
    tpa_loc_country                 varchar2(32 char)             null,
    tpa_tel_areacode                varchar2(32 char)             null,
    tpa_tel_number                  varchar2(32 char)             null,
    tpa_con_surname                 varchar2(120 char)            null,
    tpa_con_fullname                varchar2(120 char)            null,
    tpa_con_birth_year              number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_panel is 'Test Panel Table';
comment on column pts.pts_tes_panel.tpa_tes_code is 'Test code';
comment on column pts.pts_tes_panel.tpa_pan_code is 'Panel code (household or pet)';
comment on column pts.pts_tes_panel.tpa_pan_status is 'Panel status (*MEMBER, *RESERVE, *RECRUITED)';
comment on column pts.pts_tes_panel.tpa_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_panel.tpa_pet_code is 'Pet code';
comment on column pts.pts_tes_panel.tpa_pet_status is 'Pet status';
comment on column pts.pts_tes_panel.tpa_pet_name is 'Pet name';
comment on column pts.pts_tes_panel.tpa_pet_type is 'Pet type code';
comment on column pts.pts_tes_panel.tpa_birth_year is 'Pet birth year';
comment on column pts.pts_tes_panel.tpa_feed_comment is 'Pet feeding comments';
comment on column pts.pts_tes_panel.tpa_health_comment is 'Pet health comments';
comment on column pts.pts_tes_panel.tpa_hou_code is 'Household code';
comment on column pts.pts_tes_panel.tpa_hou_status is 'Household status';
comment on column pts.pts_tes_panel.tpa_geo_type is 'Household geographic type code';
comment on column pts.pts_tes_panel.tpa_geo_zone is 'Household geographic zone code';
comment on column pts.pts_tes_panel.tpa_loc_street is 'Household location street';
comment on column pts.pts_tes_panel.tpa_loc_town is 'Household location town';
comment on column pts.pts_tes_panel.tpa_loc_postcode is 'Household location postcode';
comment on column pts.pts_tes_panel.tpa_loc_country is 'Household location country';
comment on column pts.pts_tes_panel.tpa_tel_areacode is 'Household telephone areacode';
comment on column pts.pts_tes_panel.tpa_tel_number is 'Household telephone number';
comment on column pts.pts_tes_panel.tpa_con_surname is 'Household contact surname';
comment on column pts.pts_tes_panel.tpa_con_fullname is 'Household contact full name';
comment on column pts.pts_tes_panel.tpa_con_birth_year is 'Household contact birth year';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_panel
   add constraint pts_tes_panel_pk primary key (tpa_tes_code, tpa_pan_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_panel to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_panel for pts.pts_tes_panel;           