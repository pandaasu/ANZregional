/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_routing
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_routing

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_routing
   (rou_source                   varchar2(32 char)               not null,
    rou_description              varchar2(128 char)              not null,
    rou_pre_length               number(2,0)                     not null);

/**/
/* Comments
/**/
comment on table lics_routing is 'LICS Routing Table';
comment on column lics_routing.rou_source is 'Routing - source code';
comment on column lics_routing.rou_description is 'Routing - source description';
comment on column lics_routing.rou_pre_length is 'Routing - prefix length';

/**/
/* Primary Key Constraint
/**/
alter table lics_routing
   add constraint lics_routing_pk primary key (rou_source);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_routing to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_routing for lics.lics_routing;
