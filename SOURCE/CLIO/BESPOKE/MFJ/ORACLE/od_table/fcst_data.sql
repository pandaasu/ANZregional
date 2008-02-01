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
 2006/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create global temporary table fcst_data
   (sap_material_code               varchar2(18 char)       not null,
    fcst_qty01                      number                  not null,
    fcst_qty02                      number                  not null,
    fcst_qty03                      number                  not null,
    fcst_qty04                      number                  not null,
    fcst_qty05                      number                  not null,
    fcst_qty06                      number                  not null,
    fcst_qty07                      number                  not null,
    fcst_qty08                      number                  not null,
    fcst_qty09                      number                  not null,
    fcst_qty10                      number                  not null,
    fcst_qty11                      number                  not null,
    fcst_qty12                      number                  not null,
    fcst_qty13                      number                  not null,
    fcst_bps01                      number                  not null,
    fcst_bps02                      number                  not null,
    fcst_bps03                      number                  not null,
    fcst_bps04                      number                  not null,
    fcst_bps05                      number                  not null,
    fcst_bps06                      number                  not null,
    fcst_bps07                      number                  not null,
    fcst_bps08                      number                  not null,
    fcst_bps09                      number                  not null,
    fcst_bps10                      number                  not null,
    fcst_bps11                      number                  not null,
    fcst_bps12                      number                  not null,
    fcst_bps13                      number                  not null,
    fcst_gsv01                      number                  not null,
    fcst_gsv02                      number                  not null,
    fcst_gsv03                      number                  not null,
    fcst_gsv04                      number                  not null,
    fcst_gsv05                      number                  not null,
    fcst_gsv06                      number                  not null,
    fcst_gsv07                      number                  not null,
    fcst_gsv08                      number                  not null,
    fcst_gsv09                      number                  not null,
    fcst_gsv10                      number                  not null,
    fcst_gsv11                      number                  not null,
    fcst_gsv12                      number                  not null,
    fcst_gsv13                      number                  not null)
on commit preserve rows;

/**/
/* Comments
/**/
comment on table od.fcst_data is 'Forecast Split Table';
comment on column od.fcst_data.sap_material_code is 'Forecast SAP material code';
comment on column od.fcst_data.fcst_qty01 is 'Forecast QTY 01';
comment on column od.fcst_data.fcst_qty02 is 'Forecast QTY 02';
comment on column od.fcst_data.fcst_qty03 is 'Forecast QTY 03';
comment on column od.fcst_data.fcst_qty04 is 'Forecast QTY 04';
comment on column od.fcst_data.fcst_qty05 is 'Forecast QTY 05';
comment on column od.fcst_data.fcst_qty06 is 'Forecast QTY 06';
comment on column od.fcst_data.fcst_qty07 is 'Forecast QTY 07';
comment on column od.fcst_data.fcst_qty08 is 'Forecast QTY 08';
comment on column od.fcst_data.fcst_qty09 is 'Forecast QTY 09';
comment on column od.fcst_data.fcst_qty10 is 'Forecast QTY 10';
comment on column od.fcst_data.fcst_qty11 is 'Forecast QTY 11';
comment on column od.fcst_data.fcst_qty12 is 'Forecast QTY 12';
comment on column od.fcst_data.fcst_qty13 is 'Forecast QTY 13';
comment on column od.fcst_data.fcst_bps01 is 'Forecast BPS 01';
comment on column od.fcst_data.fcst_bps02 is 'Forecast BPS 02';
comment on column od.fcst_data.fcst_bps03 is 'Forecast BPS 03';
comment on column od.fcst_data.fcst_bps04 is 'Forecast BPS 04';
comment on column od.fcst_data.fcst_bps05 is 'Forecast BPS 05';
comment on column od.fcst_data.fcst_bps06 is 'Forecast BPS 06';
comment on column od.fcst_data.fcst_bps07 is 'Forecast BPS 07';
comment on column od.fcst_data.fcst_bps08 is 'Forecast BPS 08';
comment on column od.fcst_data.fcst_bps09 is 'Forecast BPS 09';
comment on column od.fcst_data.fcst_bps10 is 'Forecast BPS 10';
comment on column od.fcst_data.fcst_bps11 is 'Forecast BPS 11';
comment on column od.fcst_data.fcst_bps12 is 'Forecast BPS 12';
comment on column od.fcst_data.fcst_bps13 is 'Forecast BPS 13';
comment on column od.fcst_data.fcst_gsv01 is 'Forecast GSV 01';
comment on column od.fcst_data.fcst_gsv02 is 'Forecast GSV 02';
comment on column od.fcst_data.fcst_gsv03 is 'Forecast GSV 03';
comment on column od.fcst_data.fcst_gsv04 is 'Forecast GSV 04';
comment on column od.fcst_data.fcst_gsv05 is 'Forecast GSV 05';
comment on column od.fcst_data.fcst_gsv06 is 'Forecast GSV 06';
comment on column od.fcst_data.fcst_gsv07 is 'Forecast GSV 07';
comment on column od.fcst_data.fcst_gsv08 is 'Forecast GSV 08';
comment on column od.fcst_data.fcst_gsv09 is 'Forecast GSV 09';
comment on column od.fcst_data.fcst_gsv10 is 'Forecast GSV 10';
comment on column od.fcst_data.fcst_gsv11 is 'Forecast GSV 11';
comment on column od.fcst_data.fcst_gsv12 is 'Forecast GSV 12';
comment on column od.fcst_data.fcst_gsv13 is 'Forecast GSV 13';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_data
   add constraint fcst_data_pk primary key (sap_material_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_data to dw_app;
grant select on od.fcst_data to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_data for od.fcst_data;
