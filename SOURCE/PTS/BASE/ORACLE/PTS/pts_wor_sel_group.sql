/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_wor_sel_group
 Owner  : pts

 Description
 -----------
 Product Testing System - Test Selection Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table pts.pts_wor_sel_group
   (wsg_sel_group                   varchar2(32 char)             not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table pts.pts_wor_sel_group is 'Work Selection Group Table';
comment on column pts.pts_wor_sel_group.wsg_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_wor_sel_group to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_wor_sel_group for pts.pts_wor_sel_group;            