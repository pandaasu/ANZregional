/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dmnd_sku_mapping
 Owner   : df
 Author  : Steve Gregan

 Description
 -----------
 Demand Financials - Demand Mapping

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table df.dmnd_sku_mapping
   (model_code                  varchar2(32)               not null,
    dmd_unit                    varchar2(32)               not null,
    dmd_group                   varchar2(32)               not null,
    dfu_locn                    varchar2(32)               not null,
    item                        varchar2(32)               not null,
    sku_locn                    varchar2(32)               not null,
    str_date                    date                       not null,
    end_date                    date                       not null,
    alloc_factor                number                     not null,
    conv_factor                 number                     not null);

/**/
/* Indexes
/**/
create index dmnd_sku_mapping_ix01 on df.dmnd_sku_mapping
   (dmd_unit, dmd_group, dfu_locn, str_date, end_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on df.dmnd_sku_mapping to df_app;

/**/
/* Synonym
/**/
create or replace public synonym dmnd_sku_mapping for df.dmnd_sku_mapping;

