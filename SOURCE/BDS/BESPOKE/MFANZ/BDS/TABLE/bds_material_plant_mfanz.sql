/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PLANT_MFANZ
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material/Plant MFANZ (MATMAS)

   *NOTE : This is a custom table specific for the needs of the MFANZ Plant/Factory systems
           It provides a single table that can be used for Oracle Fast Refreshes.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created
 2007/01   Linden Glen    Added PCE and SB UOM columns
 2007/08   Steve Gregan   Added columns mrp_type, max_storage_prd, max_storage_prd_unit

*******************************************************************************/

/**/
/* Table creation
/**/
create table bds_material_plant_mfanz
   (sap_material_code                      varchar2(18 char)     not null, 
    plant_code                             varchar2(4 char)      not null, 
    bds_material_desc_en                   varchar2(40 char)     null,
    material_type                          varchar2(4 char)      null,
    material_grp                           varchar2(9 char)      null,
    base_uom                               varchar2(3 char)      null,
    order_unit                             varchar2(3 char)      null,
    gross_weight                           number                null,
    net_weight                             number                null,
    gross_weight_unit                      varchar2(3 char)      null,
    length                                 number                null,
    width                                  number                null,
    height                                 number                null,
    dimension_uom                          varchar2(3 char)      null,
    interntl_article_no                    varchar2(18 char)     null,
    total_shelf_life                       number                null,
    mars_intrmdt_prdct_compnt_flag         varchar2(1 char)      null,
    mars_merchandising_unit_flag           varchar2(1 char)      null,
    mars_prmotional_material_flag          varchar2(1 char)      null,
    mars_retail_sales_unit_flag            varchar2(1 char)      null,
    mars_semi_finished_prdct_flag          varchar2(1 char)      null,
    mars_rprsnttv_item_flag                varchar2(1 char)      null,
    mars_traded_unit_flag                  varchar2(1 char)      null,
    xplant_status                          varchar2(2 char)      null,
    xplant_status_valid                    date                  null,
    batch_mngmnt_reqrmnt_indctr            varchar2(2 char)      null,
    mars_plant_material_type               number                null,
    procurement_type                       varchar2(1 char)      null,
    special_procurement_type               varchar2(2 char)      null,
    issue_storage_location                 varchar2(4 char)      null,
    mrp_controller                         varchar2(3 char)      null,
    plant_specific_status_valid            date                  null,
    deletion_indctr                        varchar2(1 char)      null,
    plant_specific_status                  varchar2(2 char)      null,
    assembly_scrap_percntg                 number                null,
    component_scrap_percntg                number                null,
    backflush_indctr                       varchar2(1 char)      null,
    mars_rprsnttv_item_code                varchar2(18 char)     null,
    sales_text_147                         varchar2(2000 char)   null,
    sales_text_149                         varchar2(2000 char)   null,
    regional_code_10                       varchar2(18 char)     null,
    regional_code_18                       varchar2(18 char)     null,
    regional_code_17                       varchar2(18 char)     null,
    regional_code_19                       varchar2(18 char)     null,
    bds_unit_cost                          number                null,
    future_planned_price_1                 number                null,
    vltn_class                             varchar2(4 char)      null,
    bds_pce_factor_from_base_uom           number                null,
    mars_pce_item_code                     varchar2(18 char)     null,
    mars_pce_interntl_article_no           varchar2(18 char)     null,
    bds_sb_factor_from_base_uom            number                null,
    mars_sb_item_code                      varchar2(18 char)     null,
    effective_out_date                     date                  null, 
    discontinuation_indctr                 varchar2(1 char)      null, 
    followup_material                      varchar2(18 char)     null,
    material_division                      varchar2(2 char)      null,
    mrp_type                               varchar2(2 char)      null,
    max_storage_prd                        number                null,
    max_storage_prd_unit                   varchar2(3 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_plant_mfanz
   add constraint bds_material_plant_mfanz_pk primary key (sap_material_code, plant_code);

    
/**/
/* Indexes
/**/


/**/
/* Comments
/**/
comment on table bds_material_plant_mfanz is 'Business Data Store - Material/Plant for MFANZ (MATMAS)';
comment on column bds_material_plant_mfanz.sap_material_code is 'Material Number - bds_material_hdr.sap_material_code';
comment on column bds_material_plant_mfanz.plant_code is 'Plant Code - bds_material_plant.plant_code';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_plant_mfanz for bds.bds_material_plant_mfanz;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_plant_mfanz to lics_app;
grant select,update,delete,insert on bds_material_plant_mfanz to bds_app;
grant select,update,delete,insert on bds_material_plant_mfanz to lads_app;
grant select on bds_material_plant_mfanz to lads with grant option;
grant select on bds_material_plant_mfanz to manu with grant option;
grant select on bds_material_plant_mfanz to ics_app;
grant select on bds_material_plant_mfanz to vds_app;
grant select on bds_material_plant_mfanz to site_app;
grant select on bds_material_plant_mfanz to ics_reader;
