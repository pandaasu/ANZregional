/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_VLTN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Valuation (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_vltn
   (sap_material_code                    varchar2(18 char)     not null, 
    vltn_area                            varchar2(4 char)      not null, 
    vltn_type                            varchar2(10 char)     not null, 
    deletion_indctr                      varchar2(1 char)      null, 
    cmmrcl_law_level_1_price             number                null, 
    cmmrcl_law_level_2_price             number                null, 
    cmmrcl_law_level_3_price             number                null, 
    cost_element_sub_origin_grp          varchar2(4 char)      null, 
    costed_qty_structure                 varchar2(1 char)      null, 
    costing_overhead_grp                 varchar2(10 char)     null, 
    curr_prd                             number                null, 
    curr_prd_fiscal_year                 number                null, 
    curr_prd_stndrd_cost_estimate        varchar2(1 char)      null, 
    curr_prd_stndrd_cost_indctr          varchar2(1 char)      null, 
    curr_stndrd_cost_fiscal_year         number                null, 
    curr_stndrd_cost_vltn_vrnt           varchar2(3 char)      null, 
    curr_stndrd_costing_vrsn             number                null, 
    future_planned_price                 number                null, 
    future_planned_price_1               number                null, 
    future_planned_price_1_valid         date                  null, 
    future_planned_price_2               number                null, 
    future_planned_price_2_valid         date                  null, 
    future_planned_price_3               number                null, 
    future_planned_price_3_valid         date                  null, 
    future_prd_stndrd_cost               number                null, 
    future_price                         number                null, 
    future_stndrd_cost_fiscal_year       number                null, 
    future_stndrd_cost_vltn_vrnt         varchar2(3 char)      null, 
    future_stndrd_costing_vrsn           number                null, 
    ledger_active                        varchar2(1 char)      null, 
    lifo_vltn_pool_no                    varchar2(4 char)      null, 
    lowest_value_indctr                  number                null, 
    maint_status                         varchar2(15 char)     null, 
    moving_price                         number                null, 
    order_relevant                       varchar2(1 char)      null, 
    origin_1                             varchar2(1 char)      null, 
    origin_2                             varchar2(1 char)      null, 
    prd_curr_stndrd_cost                 number                null, 
    prd_prev_stndrd_cost                 number                null, 
    prdct_cost_estimate_1                number                null, 
    prdct_cost_estimate_2                number                null, 
    prev_planned_price                   number                null, 
    prev_prd_moving_price                number                null, 
    prev_prd_price_cntrl_indctr          varchar2(1 char)      null, 
    prev_prd_price_unit                  number                null, 
    prev_prd_stndrd_price                number                null, 
    prev_prd_vltn_class                  varchar2(4 char)      null, 
    prev_stndrd_cost_fiscal_year         number                null, 
    prev_stndrd_cost_vltn_vrnt           varchar2(3 char)      null, 
    prev_stndrd_costing_vrsn             number                null, 
    prev_year_moving_price               number                null, 
    prev_year_price_cntrl_indctr         varchar2(1 char)      null, 
    prev_year_price_unit                 number                null, 
    prev_year_stndrd_price               number                null, 
    prev_year_vltn_class                 varchar2(4 char)      null, 
    price_cntrl_indctr                   varchar2(1 char)      null, 
    price_determination_cntrl            varchar2(1 char)      null, 
    price_unit                           number                null, 
    produced_inhouse                     varchar2(1 char)      null, 
    project_stock_vltn_class             varchar2(4 char)      null, 
    sales_order_stock_vltn_class         varchar2(4 char)      null, 
    stndrd_price                         number                null, 
    tax_cmmrcl_price_unit                number                null, 
    tax_law_level_1_price                number                null, 
    tax_law_level_2_price                number                null, 
    tax_law_level_3_price                number                null, 
    total_stock_in_prd_bfr_last          number                null, 
    total_stock_in_year_bfr_last         number                null, 
    usage                                varchar2(1 char)      null, 
    valid_from_date                      date                  null, 
    vltn_class                           varchar2(4 char)      null, 
    vltn_ctgry                           varchar2(1 char)      null, 
    value_stock_in_prd_bfr_last          number                null,
    sap_function                         varchar2(3 char)      null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_vltn
   add constraint bds_material_vltn_pk primary key (sap_material_code, vltn_area, vltn_type);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_vltn is 'Business Data Store - Material Valuation (MATMAS)';
comment on column bds_material_vltn.sap_material_code is 'Material Number - lads_mat_mbe.matnr';
comment on column bds_material_vltn.vltn_area is 'vltn area - lads_mat_mbe.bwkey';
comment on column bds_material_vltn.vltn_type is 'vltn Type - lads_mat_mbe.bwtar';
comment on column bds_material_vltn.deletion_indctr is 'Deletion Indicator - lads_mat_mbe.lvorm';
comment on column bds_material_vltn.cmmrcl_law_level_1_price is 'vltn price based on commercial law: level 1 - lads_mat_mbe.bwprh';
comment on column bds_material_vltn.cmmrcl_law_level_2_price is 'vltn price based on commercial law: level 2 - lads_mat_mbe.bwph1';
comment on column bds_material_vltn.cmmrcl_law_level_3_price is 'vltn price based on commercial law: level 3 - lads_mat_mbe.vjbwh';
comment on column bds_material_vltn.cost_element_sub_origin_grp is 'Origin Group as Subdivision of Cost Element - lads_mat_mbe.hrkft';
comment on column bds_material_vltn.costed_qty_structure is 'Material Is Costed with Quantity Structure - lads_mat_mbe.ekalr';
comment on column bds_material_vltn.costing_overhead_grp is 'Costing Overhead Group - lads_mat_mbe.kosgr';
comment on column bds_material_vltn.curr_prd is 'Current period (posting period) - lads_mat_mbe.lfmon';
comment on column bds_material_vltn.curr_prd_fiscal_year is 'Fiscal Year of Current Period - lads_mat_mbe.lfgja';
comment on column bds_material_vltn.curr_prd_stndrd_cost_estimate is 'Standard Cost Estimate for Current Period - lads_mat_mbe.kalkl';
comment on column bds_material_vltn.curr_prd_stndrd_cost_indctr is 'Indicator: Standard cost estimate for the period - lads_mat_mbe.kalkz';
comment on column bds_material_vltn.curr_stndrd_cost_fiscal_year is 'Fiscal Year of Current Standard Cost Estimate - lads_mat_mbe.pdatl';
comment on column bds_material_vltn.curr_stndrd_cost_vltn_vrnt is 'vltn Variant for Current Standard Cost Estimate - lads_mat_mbe.bwva2';
comment on column bds_material_vltn.curr_stndrd_costing_vrsn is 'Costing Version of Current Standard Cost Estimate - lads_mat_mbe.vers2';
comment on column bds_material_vltn.future_planned_price is 'Future planned price - lads_mat_mbe.zplpr';
comment on column bds_material_vltn.future_planned_price_1 is 'Future Planned Price 1 - lads_mat_mbe.zplp1';
comment on column bds_material_vltn.future_planned_price_1_valid is 'Date from Which Future Planned Price 1 Is Valid - lads_mat_mbe.zpld1';
comment on column bds_material_vltn.future_planned_price_2 is 'Future Planned Price 2 - lads_mat_mbe.zplp2';
comment on column bds_material_vltn.future_planned_price_2_valid is 'Date from Which Future Planned Price 2 Is Valid - lads_mat_mbe.zpld2';
comment on column bds_material_vltn.future_planned_price_3 is 'Future Planned Price 3 - lads_mat_mbe.zplp3';
comment on column bds_material_vltn.future_planned_price_3_valid is 'Date from Which Future Planned Price 3 Is Valid - lads_mat_mbe.zpld3';
comment on column bds_material_vltn.future_prd_stndrd_cost is 'Period of Future Standard Cost Estimate - lads_mat_mbe.pprdz';
comment on column bds_material_vltn.future_price is 'Future price - lads_mat_mbe.zkprs';
comment on column bds_material_vltn.future_stndrd_cost_fiscal_year is 'Fiscal Year of Future Standard Cost Estimate - lads_mat_mbe.pdatz';
comment on column bds_material_vltn.future_stndrd_cost_vltn_vrnt is 'vltn Variant for Future Standard Cost Estimate - lads_mat_mbe.bwva1';
comment on column bds_material_vltn.future_stndrd_costing_vrsn is 'Costing Version of Future Standard Cost Estimate - lads_mat_mbe.vers1';
comment on column bds_material_vltn.ledger_active is 'Material ledger activated at material level - lads_mat_mbe.mlmaa';
comment on column bds_material_vltn.lifo_vltn_pool_no is 'Pool number for LIFO vltn - lads_mat_mbe.mypol';
comment on column bds_material_vltn.lowest_value_indctr is 'Lowest value: devltn indicator - lads_mat_mbe.abwkz';
comment on column bds_material_vltn.maint_status is 'Maintenance status - lads_mat_mbe.pstat';
comment on column bds_material_vltn.moving_price is 'Moving Average Price/Periodic Unit Price - lads_mat_mbe.verpr';
comment on column bds_material_vltn.order_relevant is 'LIFO/FIFO-relevant - lads_mat_mbe.xlifo';
comment on column bds_material_vltn.origin_1 is 'Material Origin - lads_mat_mbe.hkmat';
comment on column bds_material_vltn.origin_2 is 'Origin of the material - lads_mat_mbe.mtorg';
comment on column bds_material_vltn.prd_curr_stndrd_cost is 'Period of Current Standard Cost Estimate - lads_mat_mbe.pprdl';
comment on column bds_material_vltn.prd_prev_stndrd_cost is 'Period of Previous Standard Cost Estimate - lads_mat_mbe.pprdv';
comment on column bds_material_vltn.prdct_cost_estimate_1 is 'Cost Estimate Number - Product Costing - lads_mat_mbe.kaln1';
comment on column bds_material_vltn.prdct_cost_estimate_2 is 'Cost Estimate Number for Cost Est. w/o Qty Structure - lads_mat_mbe.kalnr';
comment on column bds_material_vltn.prev_planned_price is 'Previous planned price - lads_mat_mbe.vplpr';
comment on column bds_material_vltn.prev_prd_moving_price is 'Moving Average Price/Periodic Unit Price in Previous Period - lads_mat_mbe.vmver';
comment on column bds_material_vltn.prev_prd_price_cntrl_indctr is 'Price Control Indicator in Previous Period - lads_mat_mbe.vmvpr';
comment on column bds_material_vltn.prev_prd_price_unit is 'Price unit of previous period - lads_mat_mbe.vmpei';
comment on column bds_material_vltn.prev_prd_stndrd_price is 'Standard price in the previous period - lads_mat_mbe.vmstp';
comment on column bds_material_vltn.prev_prd_vltn_class is 'vltn Class in Previous Period - lads_mat_mbe.vmbkl';
comment on column bds_material_vltn.prev_stndrd_cost_fiscal_year is 'Fiscal Year of Previous Standard Cost Estimate - lads_mat_mbe.pdatv';
comment on column bds_material_vltn.prev_stndrd_cost_vltn_vrnt is 'vltn Variant for Previous Standard Cost Estimate - lads_mat_mbe.bwva3';
comment on column bds_material_vltn.prev_stndrd_costing_vrsn is 'Costing Version of Previous Standard Cost Estimate - lads_mat_mbe.vers3';
comment on column bds_material_vltn.prev_year_moving_price is 'Moving Average Price/Periodic Unit Price in Previous Year - lads_mat_mbe.vjver';
comment on column bds_material_vltn.prev_year_price_cntrl_indctr is 'Price Control Indicator in Previous Year - lads_mat_mbe.vjvpr';
comment on column bds_material_vltn.prev_year_price_unit is 'Price unit of previous year - lads_mat_mbe.vjpei';
comment on column bds_material_vltn.prev_year_stndrd_price is 'Standard price in previous year - lads_mat_mbe.vjstp';
comment on column bds_material_vltn.prev_year_vltn_class is 'vltn Class in Previous Year - lads_mat_mbe.vjbkl';
comment on column bds_material_vltn.price_cntrl_indctr is 'Price Control Indicator - lads_mat_mbe.vprsv';
comment on column bds_material_vltn.price_determination_cntrl is 'Material Price Determination: Control - lads_mat_mbe.mlast';
comment on column bds_material_vltn.price_unit is 'Price Unit - lads_mat_mbe.peinh';
comment on column bds_material_vltn.produced_inhouse is 'Produced in-house - lads_mat_mbe.ownpr';
comment on column bds_material_vltn.project_stock_vltn_class is 'vltn Class for Project Stock - lads_mat_mbe.qklas';
comment on column bds_material_vltn.sales_order_stock_vltn_class is 'vltn Class for Sales Order Stock - lads_mat_mbe.eklas';
comment on column bds_material_vltn.sap_function is 'Function - lads_mat_mbe.msgfn';
comment on column bds_material_vltn.stndrd_price is 'Standard Price - lads_mat_mbe.stprs';
comment on column bds_material_vltn.tax_cmmrcl_price_unit is 'Price unit for vltn prices based on tax/commercial law - lads_mat_mbe.bwpei';
comment on column bds_material_vltn.tax_law_level_1_price is 'vltn price based on tax law: level 1 - lads_mat_mbe.bwprs';
comment on column bds_material_vltn.tax_law_level_2_price is 'vltn price based on tax law: level 2 - lads_mat_mbe.bwps1';
comment on column bds_material_vltn.tax_law_level_3_price is 'vltn price based on tax law: level 3 - lads_mat_mbe.vjbws';
comment on column bds_material_vltn.total_stock_in_prd_bfr_last is 'Total valuated stock in period before last - lads_mat_mbe.vvmlb';
comment on column bds_material_vltn.total_stock_in_year_bfr_last is 'Total valuated stock in year before last - lads_mat_mbe.vvjlb';
comment on column bds_material_vltn.usage is 'Usage of the material - lads_mat_mbe.mtuse';
comment on column bds_material_vltn.valid_from_date is 'Date as of which the price is valid - lads_mat_mbe.zkdat';
comment on column bds_material_vltn.vltn_class is 'vltn Class - lads_mat_mbe.bklas';
comment on column bds_material_vltn.vltn_ctgry is 'vltn Category - lads_mat_mbe.bwtty';
comment on column bds_material_vltn.value_stock_in_prd_bfr_last is 'Value of total valuated stock in period before last - lads_mat_mbe.vvsal';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_vltn for bds.bds_material_vltn;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_vltn to lics_app;
grant select,update,delete,insert on bds_material_vltn to bds_app;
grant select,update,delete,insert on bds_material_vltn to lads_app;
