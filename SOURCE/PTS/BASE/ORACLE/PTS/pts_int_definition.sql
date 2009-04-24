/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_int_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Interviewer Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_int_definition
   (ide_int_code                    number                        not null,
    ide_int_status                  number                        not null,
    ide_upd_user                    varchar2(30 char)             not null,
    ide_upd_date                    date                          not null,
    ide_geo_type                    number                        null,
    ide_geo_zone                    number                        null,
    ide_int_name                    varchar2(120 char)            null,
    ide_loc_street                  varchar2(120 char)            null,
    ide_loc_town                    varchar2(120 char)            null,
    ide_loc_postcode                varchar2(32 char)             null,
    ide_loc_country                 varchar2(32 char)             null,
    ide_tel_areacode                varchar2(32 char)             null,
    ide_tel_number                  varchar2(32 char)             null);

/**/
/* Comments
/**/
comment on table pts.pts_int_definition is 'Interviewer Definition Table';
comment on column pts.pts_int_definition.ide_int_code is 'Interviewer code';
comment on column pts.pts_int_definition.ide_int_status is 'Interviewer status (0=Inactive or 1=Active)';
comment on column pts.pts_int_definition.ide_upd_user is 'Interviewer update user';
comment on column pts.pts_int_definition.ide_upd_date is 'Interviewer update date';
comment on column pts.pts_int_definition.ide_geo_type is 'Interviewer geographic type';
comment on column pts.pts_int_definition.ide_geo_zone is 'Interviewer geographic zone';
comment on column pts.pts_int_definition.ide_int_name is 'Interviewer name';
comment on column pts.pts_int_definition.ide_loc_street is 'Interviewer location street';
comment on column pts.pts_int_definition.ide_loc_town is 'Interviewer location town';
comment on column pts.pts_int_definition.ide_loc_postcode is 'Interviewer location postcode';
comment on column pts.pts_int_definition.ide_loc_country is 'Interviewer location country';
comment on column pts.pts_int_definition.ide_tel_areacode is 'Interviewer telephone areacode';
comment on column pts.pts_int_definition.ide_tel_number is 'Interviewer telephone number';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_int_definition
   add constraint pts_int_definition_pk primary key (ide_int_code);

/**/
/* Indexes
/**/
create index pts_int_definition_ix01 on pts.pts_int_definition
   (ide_geo_type, ide_geo_zone, ide_int_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_int_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_int_definition for pts.pts_int_definition;