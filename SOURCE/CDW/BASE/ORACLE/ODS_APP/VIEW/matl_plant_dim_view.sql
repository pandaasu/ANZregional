/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : matl_plant_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Material Plant Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.matl_plant_dim_view as
select ltrim(t02.matnr, '0'),  -- Material Code 
  t02.werks                    -- Plant Code 
from sap_mat_hdr t01,
  sap_mat_mrc t02
where t01.matnr = t02.matnr
  and t01.valdtn_status = 'VALID'
group by ltrim(t02.matnr, '0'),
  t02.werks;
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.matl_plant_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym matl_plant_dim_view for ods_app.matl_plant_dim_view;