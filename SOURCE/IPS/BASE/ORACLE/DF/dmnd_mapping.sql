/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dmnd_mapping
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
create table df.dmnd_mapping
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
/* Primary Key Constraint
/**/
alter table df.dmnd_mapping
   add constraint dmnd_mapping_pk primary key (fcst_id, source_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on df.dmnd_mapping to df_app;

/**/
/* Synonym
/**/
create or replace public synonym dmnd_mapping for df.dmnd_mapping;

