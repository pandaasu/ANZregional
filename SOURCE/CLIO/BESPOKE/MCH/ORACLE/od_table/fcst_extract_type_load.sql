/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_extract_type_load
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Extract Type Load Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_extract_type_load
   (extract_type                    varchar2(32 char)      not null,
    load_type                       varchar2(32 char)      not null);

/**/
/* Comments
/**/
comment on table od.fcst_extract_type_load is 'Forecast Extract Type Load Table';
comment on column od.fcst_extract_type_load.extract_type  is 'Extract type';
comment on column od.fcst_extract_type_load.load_type  is 'Load type';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_extract_type_load
   add constraint fcst_extract_type_load_pk primary key (extract_type, load_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_extract_type_load to od_app;
grant select, insert, update, delete on od.fcst_extract_type_load to dw_app;
grant select on od.fcst_extract_type_load to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_extract_type_load for od.fcst_extract_type_load;