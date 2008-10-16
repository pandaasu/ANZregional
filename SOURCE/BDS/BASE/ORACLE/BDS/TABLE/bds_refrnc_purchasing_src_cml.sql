/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_REFRNC_PURCHASING_SRC_CML
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Reference Data - EORD (Material/Vendor) Cumulative

  * The EORD reference table sent via ATLLAD10 is a full replace each time. 
    If Material/Vendor records are purged/deleted from SAP, then on next send they
    will also be removed from BDS due the full resend nature of the interface.
    This table will store a cumulative set of records, that will only be updated/inserted
    to on receiving the EORD interface. Records not resent by a subsequent EORD interface
    will remain in this table.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/10   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_refrnc_purchasing_src_cml
   (sap_material_code                  varchar2(18 char)     not null, 
    plant_code                         varchar2(4 char)      not null, 
    src_list_valid_from                date                  not null, 
    src_list_valid_to                  date                  not null, 
    purchasing_organisation            varchar2(4 char)      not null, 
    vendor_code                        varchar2(10 char)     not null,
    agreement_no                       varchar2(10 char)     not null, 
    agreement_item                     varchar2(5 char)      not null,  
    plant_procured_from                varchar2(4 char)      not null, 
    src_list_planning_usage            varchar2(4 char)      not null,
    fixed_vendor_indctr                varchar2(4 char)      not null, 
    creatn_date                        date                  null, 
    creatn_user                        varchar2(12 char)     null,  
    fixed_purchase_agreement_item      varchar2(1 char)      null, 
    sto_fixed_issuing_plant            varchar2(1 char)      null, 
    manufctr_part_refrnc_material      varchar2(18 char)     null, 
    blocked_supply_src_flag            varchar2(1 char)      null, 
    purchasing_document_ctgry          varchar2(1 char)      null, 
    src_list_ctgry                     varchar2(1 char)      null, 
    order_unit                         varchar2(3 char)      null, 
    logical_system                     varchar2(10 char)     null, 
    special_stock_indctr               varchar2(1 char)      null);

    
/**/
/* Primary Key Constraint
/**/
alter table bds_refrnc_purchasing_src_cml
   add constraint bds_refrnc_prchsng_src_cml_pk primary key (sap_material_code, 
                                                             plant_code,  
                                                             src_list_valid_from,  
                                                             src_list_valid_to,
                                                             purchasing_organisation,  
                                                             vendor_code,  
                                                             agreement_no,  
                                                             agreement_item,  
                                                             plant_procured_from,  
                                                             src_list_planning_usage,  
                                                             fixed_vendor_indctr);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_refrnc_purchasing_src_cml is 'Business Data Store - Reference Data - Purchasing Source List Cumulative (ZDISTR - EORD)';
comment on column bds_refrnc_purchasing_src_cml.sap_material_code is 'Material Number - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.plant_code is 'Plant - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.creatn_date is 'Date on which the record was created - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.creatn_user is 'Name of Person who Created the Object - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.src_list_valid_from is 'Source list record valid from - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.src_list_valid_to is 'Source list record valid to - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.vendor_code is 'Account Number of the Vendor - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.fixed_vendor_indctr is 'Indicator: Fixed vendor - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.agreement_no is 'Agreement number - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.agreement_item is 'Agreement item - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.fixed_purchase_agreement_item is 'Fixed outline purchase agreement item - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.plant_procured_from is 'Plant from which material is procured - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.sto_fixed_issuing_plant is 'Fixed issuing plant in case of stock transport order - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.manufctr_part_refrnc_material is 'Material number corresponding to manufacturer part number - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.blocked_supply_src_flag is 'Blocked source of supply - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.purchasing_organisation is 'Purchasing Organization - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.purchasing_document_ctgry is 'Purchasing document category - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.src_list_ctgry is 'Category of source list record - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.src_list_planning_usage is 'Source list usage in materials planning and control - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.order_unit is 'Order unit - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.logical_system is 'Logical System - LADS_REF_DAT.Z_TABNAME';
comment on column bds_refrnc_purchasing_src_cml.special_stock_indctr is 'Special Stock Indicator - LADS_REF_DAT.Z_TABNAME';


/**/
/* Synonym
/**/
create or replace public synonym bds_refrnc_purchasing_src_cml for bds.bds_refrnc_purchasing_src_cml;

/**/
/* Authority
/**/
grant select,update,delete,insert on bds_refrnc_purchasing_src_cml to lics_app;
grant select,update,delete,insert on bds_refrnc_purchasing_src_cml to bds_app;
grant select,update,delete,insert on bds_refrnc_purchasing_src_cml to lads_app;
grant select on bds_refrnc_purchasing_src_cml to public with grant option;
