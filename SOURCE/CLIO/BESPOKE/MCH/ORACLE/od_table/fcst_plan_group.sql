/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_plan_group
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Planning Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_plan_group
   (plan_group                             varchar2(32 char)      not null,
    plan_group_description                 varchar2(128 char)     not null);

/**/
/* Comments
/**/
comment on table od.fcst_plan_group is 'Forecast Planning Group Table';
comment on column od.fcst_plan_group.plan_group is 'Planning group';
comment on column od.fcst_plan_group.plan_group_description is 'Planning group description';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_plan_group
   add constraint fcst_plan_group_pk primary key (plan_group);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_plan_group to od_app;
grant select, insert, update, delete on od.fcst_plan_group to dw_app;
grant select on od.fcst_plan_group to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_plan_group for od.fcst_plan_group;