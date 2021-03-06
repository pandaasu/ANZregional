/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_fcst_mart
 Owner  : dds

 Description
 -----------
 Data Warehouse - Forecast Base Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.dw_fcst_mart
   (fcst_identifier                   varchar2(32 char)    not null,
    company_code                      varchar2(10 char)    not null,
    sales_org_code                    varchar2(4 char)     not null,
    distbn_chnl_code                  varchar2(2 char)     not null,
    division_code                     varchar2(2 char)     null,
    fcst_type_code                    varchar2(4 char)     not null,
    fcst_yyyypp                       number(6,0)          not null,
    fcst_yyyyppw                      number(7,0)          null,
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
    fcst_value                        number(16,2)         not null,
    fcst_value_aud                    number(16,2)         not null,
    fcst_value_usd                    number(16,2)         not null,
    fcst_value_eur                    number(16,2)         not null,
    fcst_qty                          number(16,2)         not null,
    fcst_qty_gross_tonnes             number(16,6)         not null,
    fcst_qty_net_tonnes               number(16,6)         not null,
    moe_code                          varchar2(4 char)     null,
    matl_tdu_code                     varchar2(18 char)    null,
    base_value                        number(16,2)         not null,
    base_qty                          number(16,2)         not null,
    aggreg_mkt_actvty_value           number(16,2)         not null,
    aggreg_mkt_actvty_qty             number(16,2)         not null,
    lock_value                        number(16,2)         not null,
    lock_qty                          number(16,2)         not null,
    rcncl_value                       number(16,2)         not null,
    rcncl_qty                         number(16,2)         not null,
    auto_adjmt_value                  number(16,2)         not null,
    auto_adjmt_qty                    number(16,2)         not null,
    override_value                    number(16,2)         not null,
    override_qty                      number(16,2)         not null,
    mkt_actvty_value                  number(16,2)         not null,
    mkt_actvty_qty                    number(16,2)         not null,
    data_driven_event_value           number(16,2)         not null,
    data_driven_event_qty             number(16,2)         not null,
    tgt_impact_value                  number(16,2)         not null,
    tgt_impact_qty                    number(16,2)         not null,
    dfn_adjmt_value                   number(16,2)         not null,
    dfn_adjmt_qty                     number(16,2)         not null)
   partition by list (fcst_identifier)
      (partition BRM1_COM147 VALUES ('BRM1_COM147'),
       partition BRM1_COM149 VALUES ('BRM1_COM149'),
       partition BRM2_COM147 VALUES ('BRM2_COM147'),
       partition BRM2_COM149 VALUES ('BRM2_COM149'));

/**/
/* Comments
/**/
comment on table dds.dw_fcst_mart is 'Forecast Mart Table';
comment on column dds.dw_fcst_mart.fcst_identifier IS 'Forecast Identifier - Unique identifier for the forecast';
comment on column dds.dw_fcst_mart.company_code is 'Company Code - Source Data ODS.FCST_HDR.SALES_ORG_CODE';
comment on column dds.dw_fcst_mart.sales_org_code is 'Sales Organisation Code - Source Data ODS.FCST_HDR.SALES_ORG_CODE';
comment on column dds.dw_fcst_mart.distbn_chnl_code is 'Distribution Channel Code - Source Data ODS.FCST_HDR.DISTBN_CHNL_CODE';
comment on column dds.dw_fcst_mart.division_code is 'Division Code - Source Data ODS.FCST_HDR.DIVISION_CODE';
comment on column dds.dw_fcst_mart.fcst_type_code is 'Forecast Type Code - Source Data ODS.FCST_HDR.FCST_TYPE_CODE';
comment on column dds.dw_fcst_mart.fcst_yyyypp is 'Forecast YYYYPP - Source Data ODS.FCST_DTL.FCST_YEAR | FCST_PERIOD';
comment on column dds.dw_fcst_mart.fcst_yyyyppw is 'Forecast YYYYPPW - Source Data ODS.FCST_DTL.FCST_YEAR | FCST_PERIOD | FCST_WEEK';
comment on column dds.dw_fcst_mart.demand_plng_grp_code is 'Demand Planning Group Code - Source Data ODS.FCST_DTL.DEMAND_PLNG_GRP_CODE';
comment on column dds.dw_fcst_mart.cntry_code is 'Country Code - Source Data ODS.FCST_DTL.CNTRY_CODE';
comment on column dds.dw_fcst_mart.region_code is 'Region Code - Source Data ODS.FCST_DTL.REGION_CODE';
comment on column dds.dw_fcst_mart.multi_mkt_acct_code is 'Multi-Market Account Code - Source Data ODS.FCST_DTL.MULTI_MKT_ACCT_CODE';
comment on column dds.dw_fcst_mart.banner_code is 'Banner Code - Source Data ODS.FCST_DTL.BANNER_CODE';
comment on column dds.dw_fcst_mart.cust_buying_grp_code is 'Customer Buying Group Code - Source Data ODS.FCST_DTL.CUST_BUYING_GRP_CODE';
comment on column dds.dw_fcst_mart.acct_assgnmnt_grp_code is 'Account Assignment Group - Source Data ODS.FCST_DTL.ACCT_ASSGNMNT_GRP_CODE';
comment on column dds.dw_fcst_mart.pos_format_grpg_code is 'POS Format Grouping Code - Source Data ODS.FCST_DTL.POS_FORMAT_GRPG_CODE';
comment on column dds.dw_fcst_mart.distbn_route_code is 'Distribution Route Code - Source Data ODS.FCST_DTL.DISTBN_ROUTE_CODE';
comment on column dds.dw_fcst_mart.cust_code is 'Customer Code - Source Data ODS.FCST_DTL.CUST_CODE';
comment on column dds.dw_fcst_mart.matl_zrep_code is 'Material Code - Source Data ODS.FCST_DTL.MATL_CODE';
comment on column dds.dw_fcst_mart.currcy_code is 'Currency Code - Source Data ODS.FCST_DTL.CURRCY_CODE';
comment on column dds.dw_fcst_mart.fcst_value is 'Forecast Value (Market) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.fcst_value_aud is 'Forecast Value (AUD) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.fcst_value_usd is 'Forecast Value (USD) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.fcst_value_eur is 'Forecast Value (EUR) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.fcst_qty is 'Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.fcst_qty_gross_tonnes is 'Forecast Quantity Gross Tonnes - Source Data ODS.SAP_MAT_HDR.BRGEW';
comment on column dds.dw_fcst_mart.fcst_qty_net_tonnes is 'Forecast Quantity Net Tonnes - Source Data ODS.SAP_MAT_HDR.NTGEW';
comment on column dds.dw_fcst_mart.moe_code is 'MOE Code - Source Data ODS.FCST_HDR.MOE_CODE';
comment on column dds.dw_fcst_mart.matl_tdu_code is 'Material TDU Level Code - Source Data ODS.FCST_DTL.MATL_TDU_CODE';
comment on column dds.dw_fcst_mart.base_value is 'Base Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.base_qty is 'Base Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.aggreg_mkt_actvty_value is 'Aggregate Market Activity Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.aggreg_mkt_actvty_qty is 'Aggregate Market Activity Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.lock_value is 'Lock Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.lock_qty is 'Lock Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.rcncl_value is 'Reconcile Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.rcncl_qty is 'Reconcile Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.auto_adjmt_value is 'Auto-adjustment Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.auto_adjmt_qty is 'Auto-adjustment Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.override_value is 'Override Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.override_qty is 'Override Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.mkt_actvty_value is 'Market Activity Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.mkt_actvty_qty is 'Market Activity Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.data_driven_event_value is 'Data Driven Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.data_driven_event_qty is 'Data Driven Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.tgt_impact_value is 'Target Impacts Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.tgt_impact_qty is 'Target Impacts Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.dw_fcst_mart.dfn_adjmt_value is 'Demand Financials Adjustment Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.dw_fcst_mart.dfn_adjmt_qty is 'Demand Financials Adjustment Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';

/**/
/* Indexes
/**/
create index dds.dw_fcst_mart_ix01 on dds.dw_fcst_mart (company_code, fcst_type_code, fcst_yyyypp) local;
create index dds.dw_fcst_mart_ix02 on dds.dw_fcst_mart (company_code, fcst_type_code, fcst_yyyyppw) local;
create index dds.dw_fcst_mart_ix03 on dds.dw_fcst_mart (matl_zrep_code) local;
create index dds.dw_fcst_mart_ix04 on dds.dw_fcst_mart (fcst_identifier, fcst_yyyyppw) local;
create index dds.dw_fcst_mart_ix05 on dds.dw_fcst_mart (fcst_identifier, fcst_yyyypp) local;

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_fcst_mart to dw_app;
grant select on dds.dw_fcst_mart to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_fcst_mart for dds.dw_fcst_mart;