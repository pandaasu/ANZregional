/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : demand_plng_fcst_fact
 Owner  : dds

 Description
 -----------
 Data Warehouse - Demand Planning Forecast Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2010/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.demand_plng_fcst_fact
   (company_code                      varchar2(10 char)    not null,
    sales_org_code                    varchar2(4 char)     not null,
    distbn_chnl_code                  varchar2(2 char)     not null,
    division_code                     varchar2(2 char)     null,
    fcst_type_code                    varchar2(4 char)     not null,
    casting_yyyypp                    number(6,0)          not null,
    casting_yyyyppw                   number(7,0)          null,
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
    base_value                        number(16,2)         null,
    base_qty                          number(16,2)         null,
    aggreg_mkt_actvty_value           number(16,2)         null,
    aggreg_mkt_actvty_qty             number(16,2)         null,
    lock_value                        number(16,2)         null,
    lock_qty                          number(16,2)         null,
    rcncl_value                       number(16,2)         null,
    rcncl_qty                         number(16,2)         null,
    auto_adjmt_value                  number(16,2)         null,
    auto_adjmt_qty                    number(16,2)         null,
    override_value                    number(16,2)         null,
    override_qty                      number(16,2)         null,
    mkt_actvty_value                  number(16,2)         null,
    mkt_actvty_qty                    number(16,2)         null,
    data_driven_event_value           number(16,2)         null,
    data_driven_event_qty             number(16,2)         null,
    tgt_impact_value                  number(16,2)         null,
    tgt_impact_qty                    number(16,2)         null,
    dfn_adjmt_value                   number(16,2)         null,
    dfn_adjmt_qty                     number(16,2)         null)
   partition by list (company_code)
      (partition COM147 VALUES ('147'),
       partition COM149 VALUES ('149'));

/**/
/* Comments
/**/
comment on table dds.demand_plng_fcst_fact is 'Demand Planning Forecast Base Fact Table';
comment on column dds.demand_plng_fcst_fact.company_code is 'Company Code - Source Data ODS.FCST_HDR.SALES_ORG_CODE';
comment on column dds.demand_plng_fcst_fact.sales_org_code is 'Sales Organisation Code - Source Data ODS.FCST_HDR.SALES_ORG_CODE';
comment on column dds.demand_plng_fcst_fact.distbn_chnl_code is 'Distribution Channel Code - Source Data ODS.FCST_HDR.DISTBN_CHNL_CODE';
comment on column dds.demand_plng_fcst_fact.division_code is 'Division Code - Source Data ODS.FCST_HDR.DIVISION_CODE';
comment on column dds.demand_plng_fcst_fact.fcst_type_code is 'Forecast Type Code - Source Data ODS.FCST_HDR.FCST_TYPE_CODE';
comment on column dds.demand_plng_fcst_fact.casting_yyyypp is 'Casting YYYYPP - Source Data ODS.FCST_HDR.CASTING_YEAR | CASTING_PERIOD';
comment on column dds.demand_plng_fcst_fact.casting_yyyyppw is 'Casting YYYYPPW - Source Data ODS.FCST_HDR.CASTING_YEAR | CASTING_PERIOD | CASTING_WEEK';
comment on column dds.demand_plng_fcst_fact.fcst_yyyypp is 'Forecast YYYYPP - Source Data ODS.FCST_DTL.FCST_YEAR | FCST_PERIOD';
comment on column dds.demand_plng_fcst_fact.fcst_yyyyppw is 'Forecast YYYYPPW - Source Data ODS.FCST_DTL.FCST_YEAR | FCST_PERIOD | FCST_WEEK';
comment on column dds.demand_plng_fcst_fact.demand_plng_grp_code is 'Demand Planning Group Code - Source Data ODS.FCST_DTL.DEMAND_PLNG_GRP_CODE';
comment on column dds.demand_plng_fcst_fact.cntry_code is 'Country Code - Source Data ODS.FCST_DTL.CNTRY_CODE';
comment on column dds.demand_plng_fcst_fact.region_code is 'Region Code - Source Data ODS.FCST_DTL.REGION_CODE';
comment on column dds.demand_plng_fcst_fact.multi_mkt_acct_code is 'Multi-Market Account Code - Source Data ODS.FCST_DTL.MULTI_MKT_ACCT_CODE';
comment on column dds.demand_plng_fcst_fact.banner_code is 'Banner Code - Source Data ODS.FCST_DTL.BANNER_CODE';
comment on column dds.demand_plng_fcst_fact.cust_buying_grp_code is 'Customer Buying Group Code - Source Data ODS.FCST_DTL.CUST_BUYING_GRP_CODE';
comment on column dds.demand_plng_fcst_fact.acct_assgnmnt_grp_code is 'Account Assignment Group - Source Data ODS.FCST_DTL.ACCT_ASSGNMNT_GRP_CODE';
comment on column dds.demand_plng_fcst_fact.pos_format_grpg_code is 'POS Format Grouping Code - Source Data ODS.FCST_DTL.POS_FORMAT_GRPG_CODE';
comment on column dds.demand_plng_fcst_fact.distbn_route_code is 'Distribution Route Code - Source Data ODS.FCST_DTL.DISTBN_ROUTE_CODE';
comment on column dds.demand_plng_fcst_fact.cust_code is 'Customer Code - Source Data ODS.FCST_DTL.CUST_CODE';
comment on column dds.demand_plng_fcst_fact.matl_zrep_code is 'Material Code - Source Data ODS.FCST_DTL.MATL_CODE';
comment on column dds.demand_plng_fcst_fact.currcy_code is 'Currency Code - Source Data ODS.FCST_DTL.CURRCY_CODE';
comment on column dds.demand_plng_fcst_fact.fcst_value is 'Forecast Value (Market) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.fcst_value_aud is 'Forecast Value (AUD) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.fcst_value_usd is 'Forecast Value (USD) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.fcst_value_eur is 'Forecast Value (EUR) - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.fcst_qty is 'Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.fcst_qty_gross_tonnes is 'Forecast Quantity Gross Tonnes - Source Data ODS.SAP_MAT_HDR.BRGEW';
comment on column dds.demand_plng_fcst_fact.fcst_qty_net_tonnes is 'Forecast Quantity Net Tonnes - Source Data ODS.SAP_MAT_HDR.NTGEW';
comment on column dds.demand_plng_fcst_fact.moe_code is 'MOE Code - Source Data ODS.FCST_HDR.MOE_CODE';
comment on column dds.demand_plng_fcst_fact.matl_tdu_code is 'Material TDU Level Code - Source Data ODS.FCST_DTL.MATL_TDU_CODE';
comment on column dds.demand_plng_fcst_fact.base_value is 'Base Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.base_qty is 'Base Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.aggreg_mkt_actvty_value is 'Aggregate Market Activity Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.aggreg_mkt_actvty_qty is 'Aggregate Market Activity Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.lock_value is 'Lock Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.lock_qty is 'Lock Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.rcncl_value is 'Reconcile Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.rcncl_qty is 'Reconcile Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.auto_adjmt_value is 'Auto-adjustment Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.auto_adjmt_qty is 'Auto-adjustment Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.override_value is 'Override Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.override_qty is 'Override Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.mkt_actvty_value is 'Market Activity Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.mkt_actvty_qty is 'Market Activity Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.data_driven_event_value is 'Data Driven Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.data_driven_event_qty is 'Data Driven Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.tgt_impact_value is 'Target Impacts Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.tgt_impact_qty is 'Target Impacts Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';
comment on column dds.demand_plng_fcst_fact.dfn_adjmt_value is 'Demand Financials Adjustment Type Forecast Value - Source Data ODS.FCST_DTL.FCST_VALUE';
comment on column dds.demand_plng_fcst_fact.dfn_adjmt_qty is 'Demand Financials Adjustment Type Forecast Quantity - Source Data ODS.FCST_DTL.FCST_QTY';

/**/
/* Indexes
/**/
create bitmap index dds.demand_plng_fcst_fact_i1 on dds.demand_plng_fcst_fact (CASTING_YYYYPP, FCST_YYYYPP, COMPANY_CODE) local;
create index dds.demand_plng_fcst_fact_i2 on dds.demand_plng_fcst_fact (MATL_ZREP_CODE) local;
create bitmap index dds.demand_plng_fcst_fact_i3 on dds.demand_plng_fcst_fact (COMPANY_CODE, CASTING_YYYYPPW, FCST_YYYYPPW, CASTING_YYYYPP, FCST_YYYYPP) local;
create index dds.demand_plng_fcst_fact_i4 on dds.demand_plng_fcst_fact (COMPANY_CODE, FCST_TYPE_CODE, SALES_ORG_CODE, DISTBN_CHNL_CODE, DIVISION_CODE, MOE_CODE, CASTING_YYYYPPW) local;
create index dds.demand_plng_fcst_fact_i5 on dds.demand_plng_fcst_fact (COMPANY_CODE, FCST_TYPE_CODE, SALES_ORG_CODE, DISTBN_CHNL_CODE, DIVISION_CODE, MOE_CODE, CASTING_YYYYPP) local;
create index dds.demand_plng_fcst_fact_i6 on dds.demand_plng_fcst_fact (COMPANY_CODE, FCST_TYPE_CODE, CASTING_YYYYPPW) local;

/**/
/* Authority
/**/
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO APPSUPPORT;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO BO_USER;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO BW_READER;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO CDW_READER_ROLE;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO DDS_APP WITH GRANT OPTION;
GRANT DELETE, INSERT, UPDATE ON DEMAND_PLNG_FCST_FACT TO DDS_APP;
GRANT DELETE, INSERT, SELECT, UPDATE ON DEMAND_PLNG_FCST_FACT TO DDS_MAINT;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO DDS_SELECT;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO DDS_USER;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO DW_APP;
GRANT SELECT ON DEMAND_PLNG_FCST_FACT TO KPI_APP;
GRANT DELETE, INSERT, SELECT, UPDATE ON DEMAND_PLNG_FCST_FACT TO ODS_APP;

/**/
/* Synonym
/**/
create or replace public synonym demand_plng_fcst_fact for dds.demand_plng_fcst_fact;