/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : pts_sel_tem_group
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
create table pts.pts_sel_tem_group
   (stg_sel_template                number                        not null,
    stg_sel_group                   varchar2(32 char)             not null,
    stg_sel_text                    varchar2(120 char)            not null,
    stg_sel_pcnt                    number                        not null);

/**/
/* Comments
/**/
comment on table pts.pts_sel_tem_group is 'Selection Template Group Table';
comment on column pts.pts_sel_tem_group.stg_sel_template is 'Selection template code';
comment on column pts.pts_sel_tem_group.stg_sel_group is 'Selection group code (*GROUP01 - *GROUP99)';
comment on column pts.pts_sel_tem_group.stg_sel_text is 'Selection group text';
comment on column pts.pts_sel_tem_group.stg_sel_pcnt is 'Selection mix percentage';

/**/
/* Primary Key Constraint
/**/
alter table pts.pts_sel_tem_group
   add constraint pts_sel_tem_group_pk primary key (stg_sel_template, stg_sel_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on pts.pts_sel_tem_group to pts_app;

/**/
/* Synonym
/**/
create or replace public synonym pts_sel_tem_group for pts.pts_sel_tem_group;            