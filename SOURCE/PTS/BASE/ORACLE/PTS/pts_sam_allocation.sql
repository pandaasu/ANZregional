/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sam_allocation
 Owner  : pts

 Description
 -----------
 Product Testing System - Sample Allocation Table

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
create table pts.pts_sam_allocation
   (sal_alo_code                    number                        not null,
    sal_alo_text                    varchar2(120 char)            not null,
    sal_alo_procedure               varchar2(120 char)            not null);

/**/
/* Comments
/**/
comment on table pts.pts_sam_allocation is 'Sample Allocation Table';
comment on column pts.pts_sam_allocation.sal_alo_code is 'Sample allocation code';
comment on column pts.pts_sam_allocation.sal_alo_text is 'Sample allocation text';
comment on column pts.pts_sam_allocation.sal_alo_procedure is 'Sample allocation package';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sam_allocation
   add constraint pts_sam_allocation_pk primary key (sal_alo_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sam_allocation to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sam_allocation for pts.pts_sam_allocation;