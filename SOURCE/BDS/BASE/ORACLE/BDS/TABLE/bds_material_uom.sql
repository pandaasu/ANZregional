/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_UOM
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Unit Of Measure Conversions (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_uom
   (sap_material_code               varchar2(18 char)     not null, 
    uom_code                        varchar2(3 char)      not null, 
    sap_function                    varchar2(3 char)      null, 
    base_uom_numerator              number                null, 
    base_uom_denominator            number                null, 
    bds_factor_to_base_uom          number                null,
    bds_factor_from_base_uom        number                null,
    interntl_article_no             varchar2(18 char)     null, 
    interntl_article_no_ctgry       varchar2(2 char)      null, 
    length                          number                null, 
    width                           number                null, 
    height                          number                null, 
    dimension_uom                   varchar2(3 char)      null, 
    volume                          number                null, 
    volume_unit                     varchar2(3 char)      null, 
    gross_weight                    number                null, 
    gross_weight_unit               varchar2(3 char)      null, 
    lower_level_hierachy_uom        varchar2(3 char)      null, 
    global_trade_item_variant       varchar2(2 char)      null, 
    mars_mutli_convrsn_uom_indctr   varchar2(1 char)      null, 
    mars_pc_item_code               varchar2(18 char)     null, 
    mars_pc_level                   number                null, 
    mars_order_uom_prfrnc_indctr    varchar2(1 char)      null, 
    mars_sales_uom_prfrnc_indctr    varchar2(1 char)      null, 
    mars_issue_uom_prfrnc_indctr    varchar2(1 char)      null, 
    mars_wm_uom_prfrnc_indctr       varchar2(1 char)      null, 
    mars_rprsnttv_material_code     varchar2(18 char)     null);
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_uom
   add constraint bds_material_uom_pk primary key (sap_material_code, uom_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_uom is 'Business Data Store - Material Unit Of Measure Conversions (MATMAS)';
comment on column bds_material_uom.sap_material_code is 'Material Number - lads_mat_uom.matnr';
comment on column bds_material_uom.uom_code is 'Alternative Unit of Measure for Stockkeeping Unit - lads_mat_uom.meinh';
comment on column bds_material_uom.sap_function is 'Function - lads_mat_uom.msgfn';
comment on column bds_material_uom.base_uom_numerator is 'Numerator for Base Units of Measure Conversion - lads_mat_uom.umrez';
comment on column bds_material_uom.base_uom_denominator is 'Denominator for Base Units of Measure Conversion - lads_mat_uom.umren';
comment on column bds_material_uom.bds_factor_to_base_uom is 'Factor (Numberator/Denominator) to Base Units of Measure - lads_mat_uom.umrez/lads_mat_uom.umren';
comment on column bds_material_uom.interntl_article_no is 'International Article Number (EAN/UPC) - lads_mat_uom.ean11';
comment on column bds_material_uom.interntl_article_no_ctgry is 'Category of International Article Number (EAN) - lads_mat_uom.numtp';
comment on column bds_material_uom.length is 'Length - lads_mat_uom.laeng';
comment on column bds_material_uom.width is 'Width - lads_mat_uom.breit';
comment on column bds_material_uom.height is 'Height - lads_mat_uom.hoehe';
comment on column bds_material_uom.dimension_uom is 'Unit of dimension for length/width/height - lads_mat_uom.meabm';
comment on column bds_material_uom.volume is 'Volume - lads_mat_uom.volum';
comment on column bds_material_uom.volume_unit is 'Volume unit - lads_mat_uom.voleh';
comment on column bds_material_uom.gross_weight is 'Gross weight - lads_mat_uom.brgew';
comment on column bds_material_uom.gross_weight_unit is 'Weight Unit - lads_mat_uom.gewei';
comment on column bds_material_uom.lower_level_hierachy_uom is 'Lower-Level Unit of Measure in a Packing Hierarchy - lads_mat_uom.mesub';
comment on column bds_material_uom.global_trade_item_variant is 'Global Trade Item Number Variant - lads_mat_uom.gtin_variant';
comment on column bds_material_uom.mars_mutli_convrsn_uom_indctr is 'Indicator: Unit of measure with multiple Conversion factors - lads_mat_uom.zzmultitdu';
comment on column bds_material_uom.mars_pc_item_code is 'PC Item Code. - lads_mat_uom.zzpcitem';
comment on column bds_material_uom.mars_pc_level is 'Level in PC. - lads_mat_uom.zzpclevel';
comment on column bds_material_uom.mars_order_uom_prfrnc_indctr is 'Indicator of preference for Unit Measure (Order) - lads_mat_uom.zzpreforder';
comment on column bds_material_uom.mars_sales_uom_prfrnc_indctr is 'Indicator of preference for Unit Measure (Sales) - lads_mat_uom.zzprefsales';
comment on column bds_material_uom.mars_issue_uom_prfrnc_indctr is 'Indicator of preference for Unit Measure (Issue) - lads_mat_uom.zzprefissue';
comment on column bds_material_uom.mars_wm_uom_prfrnc_indctr is 'Indicator of preference for Unit Measure (WM) - lads_mat_uom.zzprefwm';
comment on column bds_material_uom.mars_rprsnttv_material_code is 'Rep. Material Number - lads_mat_uom.zzrefmatnr';



/**/
/* Synonym
/**/
create or replace public synonym bds_material_uom for bds.bds_material_uom;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_uom to lics_app;
grant select,update,delete,insert on bds_material_uom to bds_app;
grant select,update,delete,insert on bds_material_uom to lads_app;
