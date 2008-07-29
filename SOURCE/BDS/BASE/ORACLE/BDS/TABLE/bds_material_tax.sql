/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_TAX
 Owner   : BDS
 Author  : Linden Glen

 taxription
 -----------
 Business Data Store - Material Tax Classification (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_tax
   (sap_material_code             varchar2(18 char)     not null, 
    departure_cntry               varchar2(3 char)      not null, 
    tax_ctgry_01                  varchar2(4 char)      null, 
    tax_classfctn_01              varchar2(1 char)      null, 
    tax_ctgry_02                  varchar2(4 char)      null, 
    tax_classfctn_02              varchar2(1 char)      null, 
    tax_ctgry_03                  varchar2(4 char)      null, 
    tax_classfctn_03              varchar2(1 char)      null, 
    tax_ctgry_04                  varchar2(4 char)      null, 
    tax_classfctn_04              varchar2(1 char)      null, 
    tax_ctgry_05                  varchar2(4 char)      null, 
    tax_classfctn_05              varchar2(1 char)      null, 
    tax_ctgry_06                  varchar2(4 char)      null, 
    tax_classfctn_06              varchar2(1 char)      null, 
    tax_ctgry_07                  varchar2(4 char)      null, 
    tax_classfctn_07              varchar2(1 char)      null, 
    tax_ctgry_08                  varchar2(4 char)      null, 
    tax_classfctn_08              varchar2(1 char)      null, 
    tax_ctgry_09                  varchar2(4 char)      null, 
    tax_classfctn_09              varchar2(1 char)      null, 
    tax_indctr                    varchar2(1 char)      null, 
    sap_function                  varchar2(3 char)      null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_tax
   add constraint bds_material_tax_pk primary key (sap_material_code, departure_cntry);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_tax is 'Business Data Store - Material Tax Classification (MATMAS)';
comment on column bds_material_tax.sap_material_code is 'Material Number - lads_mat_tax.matnr';
comment on column bds_material_tax.sap_function is 'Function - lads_mat_tax.msgfn';
comment on column bds_material_tax.departure_cntry is 'Departure country (country from which the goods are sent) - lads_mat_tax.aland';
comment on column bds_material_tax.tax_ctgry_01 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty1';
comment on column bds_material_tax.tax_classfctn_01 is 'Tax classification material - lads_mat_tax.taxm1';
comment on column bds_material_tax.tax_ctgry_02 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty2';
comment on column bds_material_tax.tax_classfctn_02 is 'Tax classification material - lads_mat_tax.taxm2';
comment on column bds_material_tax.tax_ctgry_03 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty3';
comment on column bds_material_tax.tax_classfctn_03 is 'Tax classification material - lads_mat_tax.taxm3';
comment on column bds_material_tax.tax_ctgry_04 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty4';
comment on column bds_material_tax.tax_classfctn_04 is 'Tax classification material - lads_mat_tax.taxm4';
comment on column bds_material_tax.tax_ctgry_05 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty5';
comment on column bds_material_tax.tax_classfctn_05 is 'Tax classification material - lads_mat_tax.taxm5';
comment on column bds_material_tax.tax_ctgry_06 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty6';
comment on column bds_material_tax.tax_classfctn_06 is 'Tax classification material - lads_mat_tax.taxm6';
comment on column bds_material_tax.tax_ctgry_07 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty7';
comment on column bds_material_tax.tax_classfctn_07 is 'Tax classification material - lads_mat_tax.taxm7';
comment on column bds_material_tax.tax_ctgry_08 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty8';
comment on column bds_material_tax.tax_classfctn_08 is 'Tax classification material - lads_mat_tax.taxm8';
comment on column bds_material_tax.tax_ctgry_09 is 'Tax category (sales tax, federal sales tax,...) - lads_mat_tax.taty9';
comment on column bds_material_tax.tax_classfctn_09 is 'Tax classification material - lads_mat_tax.taxm9';
comment on column bds_material_tax.tax_indctr is 'Tax indicator for material (Purchasing) - lads_mat_tax.taxim';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_tax for bds.bds_material_tax;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_tax to lics_app;
grant select,update,delete,insert on bds_material_tax to bds_app;
grant select,update,delete,insert on bds_material_tax to lads_app;
