/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : plant_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Plant Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.plant_dim_view as
select plant_code,  -- SAP Plant Code 
  plant_desc        -- Plant Description 
from plant
where valdtn_status = 'VALID';

/*-*/
/* Authority 
/*-*/
grant select on ods_app.plant_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_dim_view for ods_app.plant_dim_view;