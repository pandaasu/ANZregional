/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_allocation
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Allocation Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_tes_allocation
   (tal_tes_code                    number                        not null,
    tal_hou_code                    number                        not null,
    tal_pet_code                    number                        not null,
    tal_day_code                    number                        not null,
    tal_sam_code                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_allocation is 'Test Allocation Table';
comment on column pts.pts_tes_allocation.tal_tes_code is 'Test code';
comment on column pts.pts_tes_allocation.tal_hou_code is 'Household code';
comment on column pts.pts_tes_allocation.tal_pet_code is 'Pet code (product test type *HHOLD = zero)';
comment on column pts.pts_tes_allocation.tal_day_code is 'Day code';
comment on column pts.pts_tes_allocation.tal_sam_code is 'Sample code';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_allocation
   add constraint pts_tes_allocation_pk primary key (tal_tes_code, tal_hou_code, tal_pet_code, tal_day_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_allocation to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_allocation for pts.pts_tes_allocation;           