/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_type
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_type
   (tty_tes_type                    number                        not null,
    tty_typ_text                    varchar2(120 char)            not null,
    tty_typ_status                  number                        not null,
    tty_upd_user                    varchar2(30 char)             not null,
    tty_upd_date                    date                          not null,
    tty_typ_target                  number                        not null,
    tty_sam_count                   number                        not null,
    tty_alc_proc                    varchar2(120 char)            not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_type is 'Test Type Table';
comment on column pts.pts_tes_type.tty_tes_type is 'Test type code';
comment on column pts.pts_tes_type.tty_typ_text is 'Test type text';
comment on column pts.pts_tes_type.tty_typ_status is 'Test type status';
comment on column pts.pts_tes_type.tty_upd_user is 'Test type update user';
comment on column pts.pts_tes_type.tty_upd_date is 'Test type update date';
comment on column pts.pts_tes_type.tty_typ_target is 'Test type target (1=*PET or 2=*HOUSEHOLD)';
comment on column pts.pts_tes_type.tty_sam_count is 'Sample count per day';
comment on column pts.pts_tes_type.tty_alc_proc is 'Allocation procedure';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_type
   add constraint pts_tes_type_pk primary key (tty_tes_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_type to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_type for pts.pts_tes_type;