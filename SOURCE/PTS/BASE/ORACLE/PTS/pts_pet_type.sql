/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_pet_type
 Owner  : pts

 Description
 -----------
 Product Testing System - Pet Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_pet_type
   (pty_pet_type                    number                        not null,
    pty_typ_text                    varchar2(120 char)            not null,
    pty_typ_status                  number                        not null,
    pty_upd_user                    varchar2(30 char)             not null,
    pty_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table pts.pts_pet_type is 'Pet Type Table';
comment on column pts.pts_pet_type.pty_pet_type is 'Pet type code';
comment on column pts.pts_pet_type.pty_typ_text is 'Pet type text';
comment on column pts.pts_pet_type.pty_typ_status is 'Pet type status';
comment on column pts.pts_pet_type.pty_upd_user is 'Pet type update user';
comment on column pts.pts_pet_type.pty_upd_date is 'Pet type update date';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_pet_type
   add constraint pts_pet_type_pk primary key (pty_pet_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_pet_type to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_pet_type for pts.pts_pet_type;