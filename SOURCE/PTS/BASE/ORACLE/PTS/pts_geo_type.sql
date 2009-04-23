/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_geo_type
 Owner  : pts

 Description
 -----------
 Product Testing System - Geographic Type Table

 **NOTES**
 ---------
 1. This is a system table and therefore has no maintenance facility.
 2. Rows should never be deleted.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_geo_type
   (gty_geo_type                    number                        not null,
    gty_typ_text                    varchar2(120 char)            not null,
    gty_typ_status                  varchar2(1 char)              not null,
    gty_upd_user                    varchar2(30 char)             not null,
    gty_upd_date                    date                          not null,
    gty_par_type                    number                        null);

/**/
/* Comments
/**/
comment on table pts.pts_geo_type is 'Geographic Type Table';
comment on column pts.pts_geo_type.gty_geo_type is 'Geographic type code';
comment on column pts.pts_geo_type.gty_typ_text is 'Geographic type text';
comment on column pts.pts_geo_type.gty_typ_status is 'Geographic type status (0=Inactive or 1=Active)';
comment on column pts.pts_geo_type.gty_upd_user is 'Geographic type update user';
comment on column pts.pts_geo_type.gty_upd_date is 'Geographic type update date';
comment on column pts.pts_geo_type.gty_par_type is 'Geographic parent type (null or geographic type code)';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_geo_type
   add constraint pts_geo_type_pk primary key (gty_geo_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_geo_type to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_geo_type for pts.pts_geo_type;