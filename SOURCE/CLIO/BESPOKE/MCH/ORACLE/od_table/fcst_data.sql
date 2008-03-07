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
   (material_code                   varchar2(18 char)       not null,
    dmnd_group                      varchar2(32 char)       not null,
    plant_code                      varchar2(32 char)       not null,
    fcst_yyyymmdd                   varchar2(8 char)        not null,
    fcst_yyyyppw                    number                  not null,
    fcst_yyyypp                     number                  not null,
    fcst_cover                      number                  not null,
    fcst_qty                        number                  not null,
    fcst_prc                        number                  not null,
    fcst_gsv                        number                  not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table od.fcst_data is 'Forecast Data Table';
comment on column od.fcst_data.material_code is 'Material code';
comment on column od.fcst_data.dmnd_group is 'Demand group';
comment on column od.fcst_data.plant_code is 'Plant code';
comment on column od.fcst_data.fcst_yyyymmdd is 'Forecast date';
comment on column od.fcst_data.fcst_yyyyppw is 'Forecast period week';
comment on column od.fcst_data.fcst_yyyypp is 'Forecast period';
comment on column od.fcst_data.fcst_cover is 'Forecast cover days';
comment on column od.fcst_data.fcst_qty is 'Forecast quantity';
comment on column od.fcst_data.fcst_prc is 'Forecast price';
comment on column od.fcst_data.fcst_gsv is 'Forecast gross sales value';

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_data to od_app;
grant select, insert, update, delete on od.fcst_data to dw_app;
grant select on od.fcst_data to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_data for od.fcst_data;
