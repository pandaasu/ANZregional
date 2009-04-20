/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_tes_sel_group
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
create table pts.pts_tes_sel_group
   (tsg_tes_code                    number                        not null,
    tsg_sel_group                   varchar2(32 char)             not null,
    tsg_sel_text                    varchar2(120 char)            not null,
    tsg_req_pan_count               number                        not null,
    tsg_req_res_count               number                        not null,
    tsg_sel_pan_count               number                        not null,
    tsg_sel_res_count               number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_tes_sel_group is 'Test Selection Group Table';
comment on column pts.pts_tes_sel_group.tsg_test is 'Test code';
comment on column pts.pts_tes_sel_group.tsg_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_tes_sel_group.tsg_sel_text is 'Selection group text';
comment on column pts.pts_tes_sel_group.tsg_req_pan_count is 'Selection group requested panel count';
comment on column pts.pts_tes_sel_group.tsg_req_res_count is 'Selection group requested reserve count';
comment on column pts.pts_tes_sel_group.tsg_sel_pan_count is 'Selection group selected panel count';
comment on column pts.pts_tes_sel_group.tsg_sel_res_count is 'Selection group selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_tes_sel_group
   add constraint pts_tes_sel_group_pk primary key (tsg_tes_code, tsg_sel_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_tes_sel_group to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_tes_sel_group for pts.pts_tes_sel_group;            