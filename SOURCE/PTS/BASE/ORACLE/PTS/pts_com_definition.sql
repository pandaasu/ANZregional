/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_com_definition
 Owner  : pts

 Description
 -----------
 Product Testing System - Research Company Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_com_definition
   (cde_com_code                    number                        not null,
    cde_com_status                  number                        not null,
    cde_upd_user                    varchar2(30 char)             not null,
    cde_upd_date                    date                          not null,
    cde_com_name                    varchar2(120 char)            null,
    cde_loc_street                  varchar2(120 char)            null,
    cde_loc_town                    varchar2(120 char)            null,
    cde_loc_postcode                varchar2(32 char)             null,
    cde_loc_country                 varchar2(32 char)             null,
    cde_tel_areacode                varchar2(32 char)             null,
    cde_tel_number                  varchar2(32 char)             null,
    cde_con_fullname                varchar2(120 char)            null);  

/**/
/* Comments
/**/
comment on table pts.pts_com_definition is 'Research Company Table';
comment on column pts.pts_com_definition.cde_com_code is 'Company code';
comment on column pts.pts_com_definition.cde_com_status is 'Company status';
comment on column pts.pts_com_definition.cde_upd_user is 'Company update user';
comment on column pts.pts_com_definition.cde_upd_date is 'Company update date';
comment on column pts.pts_com_definition.cde_com_name is 'Company name';
comment on column pts.pts_com_definition.cde_loc_street is 'Company location street';
comment on column pts.pts_com_definition.cde_loc_town is 'Company location town';
comment on column pts.pts_com_definition.cde_loc_postcode is 'Company location postcode';
comment on column pts.pts_com_definition.cde_loc_country is 'Company location country';
comment on column pts.pts_com_definition.cde_tel_areacode is 'Company telephone areacode';
comment on column pts.pts_com_definition.cde_tel_number is 'Company telephone number';
comment on column pts.pts_com_definition.cde_con_fullname is 'Company contact full name';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_com_definition
   add constraint pts_com_definition_pk primary key (cde_com_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_com_definition to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_com_definition for pts.pts_com_definition;    