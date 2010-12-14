/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_dtl
 Owner  : ods

 Description
 -----------
 Operational Data Store - Forecast Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/-**/
create table ods.fcst_dtl
   (fcst_hdr_code                     number(8)            not null,
    fcst_dtl_code                     number               not null,
    fcst_year                         number(4)            not null,
    fcst_period                       number(2)            not null,
    fcst_week                         number(1)            null,
    demand_plng_grp_code              varchar2(10 char)    null,
    cntry_code                        varchar2(3 char)     null,
    region_code                       varchar2(3 char)     null,
    multi_mkt_acct_code               varchar2(30 char)    null,
    banner_code                       varchar2(5 char)     null,
    cust_buying_grp_code              varchar2(30 char)    null,
    acct_assgnmnt_grp_code            varchar2(2 char)     null,
    pos_format_grpg_code              varchar2(30 char)    null,
    distbn_route_code                 varchar2(3 char)     null,
    cust_code                         varchar2(10 char)    null,
    matl_zrep_code                    varchar2(18 char)    not null,
    currcy_code                       varchar2(3 char)     not null,
    fcst_value                        number(13,4)         not null,
    fcst_qty                          number(13,4)         not null,
    fcst_dtl_lupdp                    varchar2(8 char)     not null,
    fcst_dtl_lupdt                    date                 not null,
    batch_code                        number(5)            not null,
    matl_tdu_code                     varchar2(18 char)    null,
    fcst_dtl_type_code                varchar2(1 char)     null)
   partition by list (fcst_hdr_code)
   (partition the_rest values (default));

/*-*/
/* Primary Key Constraint 
/*-*/
alter table ods.fcst_dtl add constraint fcst_dtl_pk primary key (fcst_hdr_code, fcst_dtl_code) using index local;

/*-*/
/* Comments
/*-*/
comment on table ods.fcst_dtl is 'Forecast Detail Table';
comment on column ods.fcst_dtl.fcst_identifier is 'Forecast Header Code (Internal Data Warehouse surrogate key)';
comment on column ods.fcst_dtl.fcst_dtl_code is 'Forecast Detail Code (Internal Data Warehouse surrogate key)';
comment on column ods.fcst_dtl.fcst_year is 'Forecast Year';
comment on column ods.fcst_dtl.fcst_period is 'Forecast Period';
comment on column ods.fcst_dtl.fcst_week is 'Forecast Week';
comment on column ods.fcst_dtl.demand_plng_grp_code is 'Demand Planning Group Code';
comment on column ods.fcst_dtl.cntry_code is 'Country Code';
comment on column ods.fcst_dtl.region_code is 'Region Code';
comment on column ods.fcst_dtl.multi_mkt_acct_code is 'Multi-Market Account Code';
comment on column ods.fcst_dtl.banner_code is 'Banner Code';
comment on column ods.fcst_dtl.cust_buying_grp_code is 'Customer Buying Group Code';
comment on column ods.fcst_dtl.acct_assgnmnt_grp_code is 'Account Assignment Group Code';
comment on column ods.fcst_dtl.pos_format_grpg_code is 'POS Format Grouping Code';
comment on column ods.fcst_dtl.distbn_route_code is 'Distribution Route Code';
comment on column ods.fcst_dtl.cust_code is 'Customer Code';
comment on column ods.fcst_dtl.matl_zrep_code is 'Material Code';
comment on column ods.fcst_dtl.currcy_code is 'Currency Code';
comment on column ods.fcst_dtl.fcst_value is 'Forecast Value';
comment on column ods.fcst_dtl.fcst_qty is 'Forecast Quantity';
comment on column ods.fcst_dtl.fcst_dtl_lupdp is 'Last Updated Person';
comment on column ods.fcst_dtl.fcst_dtl_lupdt is 'Last Updated Time';
comment on column ods.fcst_dtl.batch_code is 'Batch Code';
comment on column ods.fcst_dtl.matl_tdu_code is 'Material TDU Level Code';
comment on column ods.fcst_dtl.fcst_dtl_type_code is 'Forecast Detail Type Code';

/*-*/
/* Indexes
/*-*/
create index ods.fcst_dtl_ix01 on ods.fcst_dtl (matl_zrep_code) local;

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on ods.fcst_dtl to ods_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym fcst_dtl for ods.fcst_dtl;