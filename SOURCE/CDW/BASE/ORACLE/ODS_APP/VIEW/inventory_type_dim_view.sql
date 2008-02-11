/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : inventory_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Inventory Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.inventory_type_dim_view as
select inv_type_code,
  inv_type_desc
from inv_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.inventory_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym inventory_type_dim_view for ods_app.inventory_type_dim_view;