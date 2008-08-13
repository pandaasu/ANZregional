/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_sales_month01
 Owner  : dds

 Description
 -----------
 Data Warehouse - Sales Month 01 Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.dw_sales_month01
   (company_code                      varchar2(10 char)    not null,
    order_type_code                   varchar2(10 char)    null,
    invc_type_code                    varchar2(10 char)    not null,
    billing_eff_yyyymm                number(6,0)          not null,
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
   partition by range (billing_eff_yyyymm)
      subpartition by list (company_code)
      subpartition template (subpartition C147 VALUES ('147'),
                             subpartition C149 VALUES ('149'),
                             subpartition the_rest values (default))
      (partition the_rest values less than (maxvalue));

/**/
/* Indexes
/**/
create index dds.dw_sales_month01_ix01 on dds.dw_sales_month01 (company_code, billing_eff_yyyymm) local;

create index dds.dw_sales_month01_ix02 on dds.dw_sales_month01 (MATL_CODE) local;
create index dds.dw_sales_month01_ix03 on dds.dw_sales_month01 (SOLD_TO_CUST_CODE) local;
create index dds.dw_sales_month01_ix04 on dds.dw_sales_month01 (SHIP_TO_CUST_CODE) local;

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_sales_month01 to dw_app;
grant select on dds.dw_sales_month01 to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_sales_month01 for dds.dw_sales_month01;