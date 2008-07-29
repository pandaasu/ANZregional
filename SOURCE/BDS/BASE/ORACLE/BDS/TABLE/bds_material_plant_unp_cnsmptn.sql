/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PLANT_UNP_CNSMPTN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Plant Unplanned Consumption (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_plant_unp_cnsmptn
   (sap_material_code                 varchar2(18 char)     not null, 
    plant_code                        varchar2(4 char)      not null, 
    period_first_day                  varchar2(8 char)      not null, 
    sap_function                      varchar2(3 char)      null, 
    consumption_value_fixed_indctr    number                null, 
    corrected_consumption_value       number                null, 
    checkbox                          varchar2(1 char)      null, 
    consumption_values_ratio         number                null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_plant_unp_cnsmptn
   add constraint bds_matl_plant_unp_cnsmptn_pk primary key (sap_material_code, plant_code, period_first_day);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_plant_unp_cnsmptn is 'Business Data Store - Material Plant Unplanned Consumption (MATMAS)';
comment on column bds_material_plant_unp_cnsmptn.sap_material_code is 'Material Number - lads_mat_mum.matnr';
comment on column bds_material_plant_unp_cnsmptn.plant_code is 'Plant - lads_mat_mrc.werks';
comment on column bds_material_plant_unp_cnsmptn.sap_function is 'Function - lads_mat_mum.msgfn';
comment on column bds_material_plant_unp_cnsmptn.period_first_day is 'First day of the period to which the values refer - lads_mat_mum.ertag';
comment on column bds_material_plant_unp_cnsmptn.consumption_value_fixed_indctr is 'Consumption value - lads_mat_mum.vbwrt';
comment on column bds_material_plant_unp_cnsmptn.corrected_consumption_value is 'Corrected consumption value - lads_mat_mum.kovbw';
comment on column bds_material_plant_unp_cnsmptn.checkbox is 'Checkbox - lads_mat_mum.kzexi';
comment on column bds_material_plant_unp_cnsmptn.consumption_values_ratio is 'Ratio of the corrected value to the original value (CV:OV) - lads_mat_mum.antei';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_plant_unp_cnsmptn for bds.bds_material_plant_unp_cnsmptn;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_plant_unp_cnsmptn to lics_app;
grant select,update,delete,insert on bds_material_plant_unp_cnsmptn to bds_app;
grant select,update,delete,insert on bds_material_plant_unp_cnsmptn to lads_app;
