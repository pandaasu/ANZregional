/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_load_detail
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Load Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_load_detail
   (load_identifier                 varchar2(64 char)      not null,
    sap_material_code               varchar2(18 char)      not null,
    fcst_qty_01                     number                 not null,
    fcst_qty_02                     number                 not null,
    fcst_qty_03                     number                 not null,
    fcst_qty_04                     number                 not null,
    fcst_qty_05                     number                 not null,
    fcst_qty_06                     number                 not null,
    fcst_qty_07                     number                 not null,
    fcst_qty_08                     number                 not null,
    fcst_qty_09                     number                 not null,
    fcst_qty_10                     number                 not null,
    fcst_qty_11                     number                 not null,
    fcst_qty_12                     number                 not null,
    fcst_qty_13                     number                 not null,
    fcst_prc_01                     number                 not null,
    fcst_prc_02                     number                 not null,
    fcst_prc_03                     number                 not null,
    fcst_prc_04                     number                 not null,
    fcst_prc_05                     number                 not null,
    fcst_prc_06                     number                 not null,
    fcst_prc_07                     number                 not null,
    fcst_prc_08                     number                 not null,
    fcst_prc_09                     number                 not null,
    fcst_prc_10                     number                 not null,
    fcst_prc_11                     number                 not null,
    fcst_prc_12                     number                 not null,
    fcst_prc_13                     number                 not null,
    fcst_gsv_01                     number                 not null,
    fcst_gsv_02                     number                 not null,
    fcst_gsv_03                     number                 not null,
    fcst_gsv_04                     number                 not null,
    fcst_gsv_05                     number                 not null,
    fcst_gsv_06                     number                 not null,
    fcst_gsv_07                     number                 not null,
    fcst_gsv_08                     number                 not null,
    fcst_gsv_09                     number                 not null,
    fcst_gsv_10                     number                 not null,
    fcst_gsv_11                     number                 not null,
    fcst_gsv_12                     number                 not null,
    fcst_gsv_13                     number                 not null,
    err_message                     varchar2(4000 char)    null);

/**/
/* Comments
/**/
comment on table od.fcst_load_detail is 'Forecast Load Detail Table';
comment on column od.fcst_load_detail.load_identifier is 'Load identifier';
comment on column od.fcst_load_detail.sap_material_code is 'Material code';
comment on column od.fcst_load_detail.fcst_qty_01 is 'Forecast quantity (BUOM) 01';
comment on column od.fcst_load_detail.fcst_qty_02 is 'Forecast quantity (BUOM) 02';
comment on column od.fcst_load_detail.fcst_qty_03 is 'Forecast quantity (BUOM) 03';
comment on column od.fcst_load_detail.fcst_qty_04 is 'Forecast quantity (BUOM) 04';
comment on column od.fcst_load_detail.fcst_qty_05 is 'Forecast quantity (BUOM) 05';
comment on column od.fcst_load_detail.fcst_qty_06 is 'Forecast quantity (BUOM) 06';
comment on column od.fcst_load_detail.fcst_qty_07 is 'Forecast quantity (BUOM) 07';
comment on column od.fcst_load_detail.fcst_qty_08 is 'Forecast quantity (BUOM) 08';
comment on column od.fcst_load_detail.fcst_qty_09 is 'Forecast quantity (BUOM) 09';
comment on column od.fcst_load_detail.fcst_qty_10 is 'Forecast quantity (BUOM) 10';
comment on column od.fcst_load_detail.fcst_qty_11 is 'Forecast quantity (BUOM) 11';
comment on column od.fcst_load_detail.fcst_qty_12 is 'Forecast quantity (BUOM) 12';
comment on column od.fcst_load_detail.fcst_qty_13 is 'Forecast quantity (BUOM) 13';
comment on column od.fcst_load_detail.fcst_prc_01 is 'Selling price 01';
comment on column od.fcst_load_detail.fcst_prc_02 is 'Selling price 02';
comment on column od.fcst_load_detail.fcst_prc_03 is 'Selling price 03';
comment on column od.fcst_load_detail.fcst_prc_04 is 'Selling price 04';
comment on column od.fcst_load_detail.fcst_prc_05 is 'Selling price 05';
comment on column od.fcst_load_detail.fcst_prc_06 is 'Selling price 06';
comment on column od.fcst_load_detail.fcst_prc_07 is 'Selling price 07';
comment on column od.fcst_load_detail.fcst_prc_08 is 'Selling price 08';
comment on column od.fcst_load_detail.fcst_prc_09 is 'Selling price 09';
comment on column od.fcst_load_detail.fcst_prc_10 is 'Selling price 10';
comment on column od.fcst_load_detail.fcst_prc_11 is 'Selling price 11';
comment on column od.fcst_load_detail.fcst_prc_12 is 'Selling price 12';
comment on column od.fcst_load_detail.fcst_prc_13 is 'Selling price 13';
comment on column od.fcst_load_detail.fcst_gsv_01 is 'Forecast GSV value 01';
comment on column od.fcst_load_detail.fcst_gsv_02 is 'Forecast GSV value 02';
comment on column od.fcst_load_detail.fcst_gsv_03 is 'Forecast GSV value 03';
comment on column od.fcst_load_detail.fcst_gsv_04 is 'Forecast GSV value 04';
comment on column od.fcst_load_detail.fcst_gsv_05 is 'Forecast GSV value 05';
comment on column od.fcst_load_detail.fcst_gsv_06 is 'Forecast GSV value 06';
comment on column od.fcst_load_detail.fcst_gsv_07 is 'Forecast GSV value 07';
comment on column od.fcst_load_detail.fcst_gsv_08 is 'Forecast GSV value 08';
comment on column od.fcst_load_detail.fcst_gsv_09 is 'Forecast GSV value 09';
comment on column od.fcst_load_detail.fcst_gsv_10 is 'Forecast GSV value 10';
comment on column od.fcst_load_detail.fcst_gsv_11 is 'Forecast GSV value 11';
comment on column od.fcst_load_detail.fcst_gsv_12 is 'Forecast GSV value 12';
comment on column od.fcst_load_detail.fcst_gsv_13 is 'Forecast GSV value 13';
comment on column od.fcst_load_detail.err_message is 'Error message';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_load_detail
   add constraint fcst_load_detail_pk primary key (load_identifier, sap_material_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_load_detail to od_app;
grant select, insert, update, delete on od.fcst_load_detail to dw_app;
grant select on od.fcst_load_detail to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_load_detail for od.fcst_load_detail;


