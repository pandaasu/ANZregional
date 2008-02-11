/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : storage_location_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Storage Location Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.storage_location_dim_view as
select storage_locn_code, -- SAP Storage Location Code 
  plant_code,             -- SAP Plant Code 
  storage_locn_desc       -- Storage Location Description 
from storage_locn
where valdtn_status = 'VALID';

/*-*/
/* Authority 
/*-*/
grant select on ods_app.storage_location_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym storage_location_dim_view for ods_app.storage_location_dim_view;