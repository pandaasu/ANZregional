/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_DSTRBTN_CHAIN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Distribution Chain (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_dstrbtn_chain
   (sap_material_code               varchar2(18 char)     not null, 
    sales_organisation              varchar2(4 char)      not null, 
    dstrbtn_channel                 varchar2(2 char)      not null, 
    sap_function                    varchar2(3 char)      null, 
    dstrbtn_chain_delete_indctr     varchar2(1 char)      null, 
    material_stats_grp              varchar2(1 char)      null, 
    volume_rebate_grp               varchar2(2 char)      null, 
    commission_grp                  varchar2(2 char)      null, 
    cash_discount_indctr            varchar2(1 char)      null, 
    dstrbtn_chain_status            varchar2(2 char)      null, 
    bds_dstrbtn_chain_valid         date                  null, 
    base_uom_min_order_qty          number                null, 
    min_delivery_qty                number                null, 
    min_make_order_qty              number                null, 
    delivery_unit                   number                null, 
    delivery_unit_uom               varchar2(3 char)      null, 
    sales_unit                      varchar2(3 char)      null, 
    item_ctgry_grp                  varchar2(4 char)      null, 
    delivering_plant                varchar2(4 char)      null, 
    prdct_hierachy                  varchar2(18 char)     null, 
    pricing_refrnc_material         varchar2(18 char)     null, 
    material_pricing_grp            varchar2(2 char)      null, 
    accnt_assgnmnt_grp              varchar2(2 char)      null, 
    crpc_material_ctgry             varchar2(3 char)      null, 
    material_grp_2                  varchar2(3 char)      null, 
    material_grp_3                  varchar2(3 char)      null, 
    material_grp_4                  varchar2(3 char)      null, 
    material_grp_5                  varchar2(3 char)      null, 
    assortment_grade                varchar2(2 char)      null, 
    external_assortment_priority    varchar2(1 char)      null, 
    store_list_prcdr                varchar2(2 char)      null, 
    dstrbtn_center_list_prcdr       varchar2(2 char)      null, 
    list_function_actv              varchar2(1 char)      null, 
    prdct_attribute_id_1            varchar2(1 char)      null, 
    prdct_attribute_id_2            varchar2(1 char)      null, 
    prdct_attribute_id_3            varchar2(1 char)      null, 
    prdct_attribute_id_4            varchar2(1 char)      null, 
    prdct_attribute_id_5            varchar2(1 char)      null, 
    prdct_attribute_id_6            varchar2(1 char)      null, 
    prdct_attribute_id_7            varchar2(1 char)      null, 
    prdct_attribute_id_8            varchar2(1 char)      null, 
    prdct_attribute_id_9            varchar2(1 char)      null, 
    prdct_attribute_id_10           varchar2(1 char)      null, 
    block_variable_sales_unit       varchar2(1 char)      null, 
    rounding_profile                varchar2(4 char)      null, 
    uom_grp                         varchar2(4 char)      null, 
    long_material_code              varchar2(40 char)     null, 
    vrsn_number                     varchar2(10 char)     null, 
    external_guid                   varchar2(32 char)     null,
    mars_logistics_point            number                null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_dstrbtn_chain
   add constraint bds_material_dstrbtn_chain_pk primary key (sap_material_code, sales_organisation, dstrbtn_channel);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_dstrbtn_chain is 'Business Data Store - Material Distribution Chain (MATMAS)';
comment on column bds_material_dstrbtn_chain.sap_material_code is 'Material Number - lads_mat_sad.matnr';
comment on column bds_material_dstrbtn_chain.sap_function is 'Function - lads_mat_sad.msgfn';
comment on column bds_material_dstrbtn_chain.sales_organisation is 'Sales Organization - lads_mat_sad.vkorg';
comment on column bds_material_dstrbtn_chain.dstrbtn_channel is 'Distribution Channel - lads_mat_sad.vtweg';
comment on column bds_material_dstrbtn_chain.dstrbtn_chain_delete_indctr is 'Ind.: Flag material for deletion at distribution chain level - lads_mat_sad.lvorm';
comment on column bds_material_dstrbtn_chain.material_stats_grp is 'Material statistics group - lads_mat_sad.versg';
comment on column bds_material_dstrbtn_chain.volume_rebate_grp is 'Volume rebate group - lads_mat_sad.bonus';
comment on column bds_material_dstrbtn_chain.commission_grp is 'Commission group - lads_mat_sad.provg';
comment on column bds_material_dstrbtn_chain.cash_discount_indctr is 'Cash discount indicator - lads_mat_sad.sktof';
comment on column bds_material_dstrbtn_chain.dstrbtn_chain_status is 'Distribution-chain-specific material status - lads_mat_sad.vmsta';
comment on column bds_material_dstrbtn_chain.bds_dstrbtn_chain_valid is 'Date from which distr.-chain-spec. material status is valid - lads_mat_sad.vmstd';
comment on column bds_material_dstrbtn_chain.base_uom_min_order_qty is 'Minimum order quantity in base unit of measure - lads_mat_sad.aumng';
comment on column bds_material_dstrbtn_chain.min_delivery_qty is 'Minimum delivery quantity in delivery note processing - lads_mat_sad.lfmng';
comment on column bds_material_dstrbtn_chain.min_make_order_qty is 'Minimum make-to-order quantity - lads_mat_sad.efmng';
comment on column bds_material_dstrbtn_chain.delivery_unit is 'Delivery unit - lads_mat_sad.scmng';
comment on column bds_material_dstrbtn_chain.delivery_unit_uom is 'Unit of measure of delivery unit - lads_mat_sad.schme';
comment on column bds_material_dstrbtn_chain.sales_unit is 'Sales unit - lads_mat_sad.vrkme';
comment on column bds_material_dstrbtn_chain.item_ctgry_grp is 'Item category group from material master - lads_mat_sad.mtpos';
comment on column bds_material_dstrbtn_chain.delivering_plant is 'Delivering Plant - lads_mat_sad.dwerk';
comment on column bds_material_dstrbtn_chain.prdct_hierachy is 'Product hierarchy - lads_mat_sad.prodh';
comment on column bds_material_dstrbtn_chain.pricing_refrnc_material is 'Pricing reference material - lads_mat_sad.pmatn';
comment on column bds_material_dstrbtn_chain.material_pricing_grp is 'Material Pricing Group - lads_mat_sad.kondm';
comment on column bds_material_dstrbtn_chain.accnt_assgnmnt_grp is 'Account assignment group for this material - lads_mat_sad.ktgrm';
comment on column bds_material_dstrbtn_chain.crpc_material_ctgry is 'CRPC Material Category - lads_mat_sad.mvgr1';
comment on column bds_material_dstrbtn_chain.material_grp_2 is 'Material group 2 - lads_mat_sad.mvgr2';
comment on column bds_material_dstrbtn_chain.material_grp_3 is 'Material group 3 - lads_mat_sad.mvgr3';
comment on column bds_material_dstrbtn_chain.material_grp_4 is 'Material Group 4 - lads_mat_sad.mvgr4';
comment on column bds_material_dstrbtn_chain.material_grp_5 is 'Material group 5 - lads_mat_sad.mvgr5';
comment on column bds_material_dstrbtn_chain.assortment_grade is 'Assortment grade - lads_mat_sad.sstuf';
comment on column bds_material_dstrbtn_chain.external_assortment_priority is 'External assortment priority - lads_mat_sad.pflks';
comment on column bds_material_dstrbtn_chain.store_list_prcdr is 'Listing procedure for store or other assortment categories - lads_mat_sad.lstfl';
comment on column bds_material_dstrbtn_chain.dstrbtn_center_list_prcdr is 'Listing procedure for distr. center assortment categories - lads_mat_sad.lstvz';
comment on column bds_material_dstrbtn_chain.list_function_actv is 'Listing functions (assortments) are active - lads_mat_sad.lstak';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_1 is 'ID for product attribute 1 - lads_mat_sad.prat1';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_2 is 'ID for product attribute 2 - lads_mat_sad.prat2';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_3 is 'ID for product attribute 3 - lads_mat_sad.prat3';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_4 is 'ID for product attribute 4 - lads_mat_sad.prat4';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_5 is 'ID for product attribute 5 - lads_mat_sad.prat5';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_6 is 'ID for product attribute 6 - lads_mat_sad.prat6';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_7 is 'ID for product attribute 7 - lads_mat_sad.prat7';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_8 is 'ID for product attribute 8 - lads_mat_sad.prat8';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_9 is 'ID for product attribute 9 - lads_mat_sad.prat9';
comment on column bds_material_dstrbtn_chain.prdct_attribute_id_10 is 'ID for product attribute 10 - lads_mat_sad.prata';
comment on column bds_material_dstrbtn_chain.block_variable_sales_unit is 'Variable Sales Unit Not Allowed - lads_mat_sad.vavme';
comment on column bds_material_dstrbtn_chain.rounding_profile is 'Rounding profile - lads_mat_sad.rdprf';
comment on column bds_material_dstrbtn_chain.uom_grp is 'Unit of measure group - lads_mat_sad.megru';
comment on column bds_material_dstrbtn_chain.long_material_code is 'Long material number (future development) for field PMATN - lads_mat_sad.pmatn_external';
comment on column bds_material_dstrbtn_chain.vrsn_number is 'Version number (future development) for field PMATN - lads_mat_sad.pmatn_version';
comment on column bds_material_dstrbtn_chain.external_guid is 'External GUID (future development) for field PMATN - lads_mat_sad.pmatn_guid';
comment on column bds_material_dstrbtn_chain.mars_logistics_point is 'Mars Logistics Point - lads_mat_zsd.zzlogist_point';



/**/
/* Synonym
/**/
create or replace public synonym bds_material_dstrbtn_chain for bds.bds_material_dstrbtn_chain;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_dstrbtn_chain to lics_app;
grant select,update,delete,insert on bds_material_dstrbtn_chain to bds_app;
grant select,update,delete,insert on bds_material_dstrbtn_chain to lads_app;
