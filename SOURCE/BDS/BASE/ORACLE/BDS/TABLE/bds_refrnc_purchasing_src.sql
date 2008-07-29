/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_PURCHASING_SRC
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Reference Data - Characteristic Value Codes (ZDISTR)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/01   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_purchasing_src
   (sap_material_code                  varchar2(18 char)     not null, 
    plant_code                         varchar2(4 char)      not null, 
    record_no                          varchar2(5 char)      not null, 
    creatn_date                        date                  null, 
    creatn_user                        varchar2(12 char)     null, 
    src_list_valid_from                date                  null, 
    src_list_valid_to                  date                  null, 
    vendor_code                        varchar2(10 char)     null, 
    fixed_vendor_indctr                varchar2(1 char)      null, 
    agreement_no                       varchar2(10 char)     null, 
    agreement_item                     varchar2(5 char)      null, 
    fixed_purchase_agreement_item      varchar2(1 char)      null, 
    plant_procured_from                varchar2(4 char)      null, 
    sto_fixed_issuing_plant            varchar2(1 char)      null, 
    manufctr_part_refrnc_material      varchar2(18 char)     null, 
    blocked_supply_src_flag            varchar2(1 char)      null, 
    purchasing_organisation            varchar2(4 char)      null, 
    purchasing_document_ctgry          varchar2(1 char)      null, 
    src_list_ctgry                     varchar2(1 char)      null, 
    src_list_planning_usage            varchar2(1 char)      null, 
    order_unit                         varchar2(3 char)      null, 
    logical_system                     varchar2(10 char)     null, 
    special_stock_indctr               varchar2(1 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_purchasing_src
   add constraint bds_refrnc_purchasing_src_pk primary key (sap_material_code, plant_code, record_no);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_purchasing_src is 'Business Data Store - Reference Data - Purchasing Source List (ZDISTR - EORD)';
comment on column bds_refrnc_purchasing_src.sap_material_code is 'Material Number - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.plant_code is 'Plant - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.record_no is 'Number of source list record - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.creatn_date is 'Date on which the record was created - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.creatn_user is 'Name of Person who Created the Object - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.src_list_valid_from is 'Source list record valid from - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.src_list_valid_to is 'Source list record valid to - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.vendor_code is 'Account Number of the Vendor - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.fixed_vendor_indctr is 'Indicator: Fixed vendor - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.agreement_no is 'Agreement number - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.agreement_item is 'Agreement item - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.fixed_purchase_agreement_item is 'Fixed outline purchase agreement item - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.plant_procured_from is 'Plant from which material is procured - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.sto_fixed_issuing_plant is 'Fixed issuing plant in case of stock transport order - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.manufctr_part_refrnc_material is 'Material number corresponding to manufacturer part number - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.blocked_supply_src_flag is 'Blocked source of supply - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.purchasing_organisation is 'Purchasing Organization - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.purchasing_document_ctgry is 'Purchasing document category - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.src_list_ctgry is 'Category of source list record - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.src_list_planning_usage is 'Source list usage in materials planning and control - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.order_unit is 'Order unit - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.logical_system is 'Logical System - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src.special_stock_indctr is 'Special Stock Indicator - LADS_REF_DAT.Z_TABNAME';




/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_purchasing_src for bds.bds_refrnc_purchasing_src;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_purchasing_src to lics_app;
grant select,update,delete,insert on bds_refrnc_purchasing_src to bds_app;
grant select,update,delete,insert on bds_refrnc_purchasing_src to lads_app;
