/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_statistic
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Statistic Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_statistic
   (tst_tes_code                    number                        not null,
    tst_pan_code                    number                        not null,
    tst_pet_type                    number                        not null,
    tst_pet_count                   number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_statistic is 'Test Statistic Table';
comment on column pts.pts_tes_statistic.tst_tes_code is 'Test code';
comment on column pts.pts_tes_statistic.tst_pan_code is 'Panel code';
comment on column pts.pts_tes_statistic.tst_pet_type is 'Pet type code';
comment on column pts.pts_tes_statistic.tst_pet_count is 'Pet type count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_statistic
   add constraint pts_tes_statistic_pk primary key (tst_tes_code, tst_pan_code, tst_pet_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_statistic to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_statistic for pts.pts_tes_statistic;            