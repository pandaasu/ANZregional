/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : uom_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - UOM Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.uom_dim_view as
select uom_code,  -- SAP UOM Code 
  uom_abbrd_desc, -- UOM Abbrev. Description 
  uom_desc,       -- UOM Description 
  uom_dim         -- UOM Dimension 
from uom
where valdtn_status = 'VALID';

/*-*/
/* Authority 
/*-*/
grant select on ods_app.uom_dim_vieww to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym uom_dim_view for ods_app.uom_dim_view;