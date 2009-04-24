/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_geo_zone
 Owner  : pts

 Description
 -----------
 Product Testing System - Geographic Zone Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_geo_zone
   (gzo_geo_type                    number                        not null,
    gzo_geo_zone                    number                        not null,
    gzo_zon_text                    varchar2(120 char)            not null,
    gzo_zon_status                  varchar2(1 char)              not null,
    gzo_upd_user                    varchar2(30 char)             not null,
    gzo_upd_date                    date                          not null,
    gzo_par_type                    number                        null,
    gzo_par_zone                    number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_geo_zone is 'Geographic Zone Table';
comment on column pts.pts_geo_zone.gzo_geo_type is 'Geographic zone type';
comment on column pts.pts_geo_zone.gzo_geo_zone is 'Geographic zone code';
comment on column pts.pts_geo_zone.gzo_zon_text is 'Geographic zone text';
comment on column pts.pts_geo_zone.gzo_zon_status is 'Geographic zone status (0=Inactive or 1=Active)';
comment on column pts.pts_geo_zone.gzo_upd_user is 'Geographic zone update user';
comment on column pts.pts_geo_zone.gzo_upd_date is 'Geographic zone update date';
comment on column pts.pts_geo_zone.gzo_par_type is 'Geographic parent type (null or geographic type)';
comment on column pts.pts_geo_zone.gzo_par_zone is 'Geographic parent code (null or geographic code)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_geo_zone
   add constraint pts_geo_zone_pk primary key (gzo_geo_type, gzo_geo_zone);

/**/
/* Indexes
/**/
create index pts_geo_zone_ix01 on pts.pts_geo_zone
   (gzo_par_type, gzo_par_zone, gzo_geo_type, gzo_geo_zone);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_geo_zone to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_geo_zone for pts.pts_geo_zone;