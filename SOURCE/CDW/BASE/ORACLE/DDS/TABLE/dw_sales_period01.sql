/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_sales_period01
 Owner  : dds

 Description
 -----------
 Data Warehouse - Sales Period 01 Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.dw_sales_period01
   (company_code                      varchar2(10 char)    not null,
    order_type_code                   varchar2(10 char)    null,
    invc_type_code                    varchar2(10 char)    not null,
    billing_eff_yyyypp                number(6,0)          not null,
    hdr_sales_org_code                varchar2(10 char)    not null,
    hdr_distbn_chnl_code              varchar2(10 char)    not null,
    hdr_division_code                 varchar2(10 char)    not null,
    doc_currcy_code                   varchar2(10 char)    not null,
    company_currcy_code               varchar2(10 char)    not null,
    exch_rate                         number               not null,
    order_reasn_code                  varchar2(10 char)    null,
    sold_to_cust_code                 varchar2(10 char)    null,
    bill_to_cust_code                 varchar2(10 char)    null,
    payer_cust_code                   varchar2(10 char)    null,
    order_qty                         number               not null,
    billed_qty                        number               not null,
    billed_qty_base_uom               number               null,
    billed_qty_gross_tonnes           number               null,
    billed_qty_net_tonnes             number               null,
    ship_to_cust_code                 varchar2(10 char)    null,
    matl_code                         varchar2(18 char)    not null,
    matl_entd                         varchar2(35 char)    null,
    billed_uom_code                   varchar2(10 char)    null,
    billed_base_uom_code              varchar2(10 char)    null,
    plant_code                        varchar2(10 char)    null,
    storage_locn_code                 varchar2(10 char)    null,
    gen_sales_org_code                varchar2(10 char)    null,
    gen_distbn_chnl_code              varchar2(10 char)    null,
    gen_division_code                 varchar2(10 char)    null,
    order_usage_code                  varchar2(10 char)    null,
    billed_gsv                        number               not null,
    billed_gsv_xactn                  number               not null,
    billed_gsv_aud                    number               not null,
    billed_gsv_usd                    number               not null,
    billed_gsv_eur                    number               not null,
    mfanz_icb_flag                    varchar2(1)          not null,
    demand_plng_grp_division_code     varchar2(2 char)     null)
   partition by range (billing_eff_yyyypp)
      subpartition by list (company_code)
      (partition the_rest values less than (maxvalue));

/**/
/* Indexes
/**/
--create index dds.dw_sales_period01_ix01 on dds.dw_sales_period01 (company_code, billing_eff_yyyypp);

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_sales_period01 to dw_app;
grant select on dds.dw_sales_period01 to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_sales_period01 for dds.dw_sales_period01;