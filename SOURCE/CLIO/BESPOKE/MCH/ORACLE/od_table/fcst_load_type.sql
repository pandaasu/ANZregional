/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_load_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Load Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_load_type
   (load_type                             varchar2(32 char)      not null,
    load_type_description                 varchar2(128 char)     not null,
    load_type_version                     varchar2(32 char)      not null);

/**/
/* Comments
/**/
comment on table od.fcst_load_type is 'Forecast Load Type Table';
comment on column od.fcst_load_type.load_type is 'Load type';
comment on column od.fcst_load_type.load_type_description is 'Load type description';
comment on column od.fcst_load_type.load_type_version is 'Load type version - *PERIOD or *YEAR';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_load_type
   add constraint fcst_load_type_pk primary key (load_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_load_type to od_app;
grant select, insert, update, delete on od.fcst_load_type to dw_app;
grant select on od.fcst_load_type to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_load_type for od.fcst_load_type;