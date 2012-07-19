/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_rtg_detail
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_rtg_detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_rtg_detail
   (rde_source                   varchar2(32 char)               not null,
    rde_prefix                   varchar2(32 char)               not null,
    rde_interface                varchar2(32 char)               not null);

/**/
/* Comments
/**/
comment on table lics_rtg_detail is 'LICS Routing Detail Table';
comment on column lics_rtg_detail.rde_source is 'Routing detail - source code';
comment on column lics_rtg_detail.rde_prefix is 'Routing detail - prefix';
comment on column lics_rtg_detail.rde_interface is 'Routing detail - interface';

/**/
/* Primary Key Constraint
/**/
alter table lics_rtg_detail
   add constraint lics_rtg_detail_pk primary key (rde_source, rde_prefix);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_rtg_detail
--   add constraint lics_rtg_detail_fk01 foreign key (rde_source)
--      references lics_routing (rou_source);

--alter table lics_rtg_detail
--   add constraint lics_rtg_detail_fk02 foreign key (rde_interface)
--      references lics_interface (int_interface);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_rtg_detail to lics_app;
grant select on lics_rtg_detail to lics_exec;

/**/
/* Synonym
/**/
create public synonym lics_rtg_detail for lics.lics_rtg_detail;
