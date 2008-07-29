/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_MATERIAL_PLANT_FORECAST
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Material Forecast Values (MATMAS)

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Linden Glen    Created

*******************************************************************************/


/**/
/* Table creation
/**/
create table bds_material_plant_forecast
   (sap_material_code               varchar2(18 char)     not null,
    plant_code                      varchar2(4 char)      not null, 
    period_first_day                varchar2(8 char)      not null, 
    sap_function                    varchar2(3 char)      null, 
    forecast_value                  number                null, 
    corrected_forecast_value        number                null, 
    seasonal_index                  number                null, 
    consumption_value_fixed_indctr  varchar2(1 char)      null, 
    expost_forecast_value           number                null, 
    forecast_values_ratio           number                null);
    
    
/**/
/* Primary Key Constraint
/**/
alter table bds_material_plant_forecast
   add constraint bds_material_plant_forecast_pk primary key (sap_material_code, plant_code, period_first_day);

    
/**/
/* Indexes
/**/

/**/
/* Comments
/**/
comment on table bds_material_plant_forecast is 'Business Data Store - Material Forecast Values (MATMAS)';
comment on column bds_material_plant_forecast.sap_material_code is 'Material Number - lads_mat_mpm.matnr';
comment on column bds_material_plant_forecast.plant_code is 'Plant - lads_mat_mrc.werks';
comment on column bds_material_plant_forecast.period_first_day is 'First day of the period to which the values refer - lads_mat_mpm.ertag';
comment on column bds_material_plant_forecast.sap_function is 'Function - lads_mat_mpm.msgfn';
comment on column bds_material_plant_forecast.forecast_value is 'Forecast value - lads_mat_mpm.prwrt';
comment on column bds_material_plant_forecast.corrected_forecast_value is 'Corrected value for forecast - lads_mat_mpm.koprw';
comment on column bds_material_plant_forecast.seasonal_index is 'Seasonal index - lads_mat_mpm.saiin';
comment on column bds_material_plant_forecast.consumption_value_fixed_indctr is 'Indicator: consumption value is fixed - lads_mat_mpm.fixkz';
comment on column bds_material_plant_forecast.expost_forecast_value is 'Ex-post forecast value - lads_mat_mpm.exprw';
comment on column bds_material_plant_forecast.forecast_values_ratio is 'Ratio of the corrected value to the original value (CV:OV) - lads_mat_mpm.antei';


/**/
/* Synonym
/**/
create or replace public synonym bds_material_plant_forecast for bds.bds_material_plant_forecast;


/**/
/* Authority
/**/
grant select,update,delete,insert on bds_material_plant_forecast to lics_app;
grant select,update,delete,insert on bds_material_plant_forecast to bds_app;
grant select,update,delete,insert on bds_material_plant_forecast to lads_app;
