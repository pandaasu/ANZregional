/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_stm_group
 Owner  : pts

 Description
 -----------
 Product Testing System - Selection Template Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/04   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table pts.pts_stm_group
   (stg_stm_code                    number                        not null,
    stg_sel_group                   varchar2(32 char)             not null,
    stg_sel_text                    varchar2(120 char)            not null,
    stg_sel_pcnt                    number                        not null,
    stg_req_mem_count               number                        not null,
    stg_req_res_count               number                        not null,
    stg_sel_mem_count               number                        not null,
    stg_sel_res_count               number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_stm_group is 'Selection Template Group Table';
comment on column pts.pts_stm_group.stg_stm_code is 'Selection template code';
comment on column pts.pts_stm_group.stg_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_stm_group.stg_sel_text is 'Selection group text';
comment on column pts.pts_stm_group.stg_sel_pcnt is 'Selection mix percentage';
comment on column pts.pts_stm_group.stg_req_mem_count is 'Selection group requested member count';
comment on column pts.pts_stm_group.stg_req_res_count is 'Selection group requested reserve count';
comment on column pts.pts_stm_group.stg_sel_mem_count is 'Selection group selected member count';
comment on column pts.pts_stm_group.stg_sel_res_count is 'Selection group selected reserve count';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_stm_group
   add constraint pts_stm_group_pk primary key (stg_stm_code, stg_sel_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_stm_group to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_stm_group for pts.pts_stm_group;            