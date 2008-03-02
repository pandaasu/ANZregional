/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_data
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Data Table (Global Temporary Table)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table fcst_data
   (cast_yyyymmdd                   varchar2(8 char)        not null,
    material_code                   varchar2(18 char)       not null,
    plant_code                      varchar2(4 char)        not null,
    fcst_yyyymmdd                   varchar2(8 char)        not null,
    fcst_qty                        number                  not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table od.fcst_data is 'Forecast Data Table';
comment on column od.fcst_data.cast_yyyymmdd is 'Casting date';
comment on column od.fcst_data.fcst_matl_code is 'Forecast material code';
comment on column od.fcst_data.fcst_yyyymmdd is 'Forecast date';
comment on column od.fcst_data.fcst_qty is 'Forecast QTY';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_data
   add constraint fcst_data_pk primary key (cast_yyyymmdd, material_code, plant_code, fcst_yyyymmdd);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_data to dw_app;
grant select on od.fcst_data to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_data for od.fcst_data;
