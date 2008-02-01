/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_REGIONAL
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Regional Code Conversions (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_regional
   (sap_material_code         varchar2(18 char)     not null, 
    regional_code_id          varchar2(5 char)      not null, 
    regional_code             varchar2(18 char)     not null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_regional
   add constraint bds_material_regional_pk primary key (sap_material_code, regional_code_id, regional_code);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_regional is 'Business Data Store - Material Regional Code Conversions (MATMAS)';
comment on column bds_material_regional.sap_material_code is 'Material Number - lads_mat_lcd.matnr';
comment on column bds_material_regional.regional_code_id is 'Regional code Id - lads_mat_lcd.z_lcdid';
comment on column bds_material_regional.regional_code is 'Regional code number - lads_mat_lcd.z_lcdnr';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_regional for bds.bds_material_regional;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_regional to lics_app;
grant select,update,delete,insert on bds_material_regional to bds_app;
grant select,update,delete,insert on bds_material_regional to lads_app;
