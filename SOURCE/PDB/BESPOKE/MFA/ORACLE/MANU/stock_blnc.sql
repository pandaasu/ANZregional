/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : stock_blnc
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Stock Balance View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.stock_blnc as
  select t01.plant_code as plant,
    t01.storage_location_code as strg_lctn,
    t01.stock_balance_date as stock_blnc_date,
    t01.stock_balance_time as stock_blnc_time,
    t01.material_code as matl_code,
    t01.inspection_stock_flag as spcl_stock_indctr,
    t01.stock_quantity as qty_in_stock,
    t01.stock_uom_code as stock_uom,
    t01.stock_best_before_date as best_bfr_date,
    t01.consignment_cust_vend as cnsgnmnt_cust_or_vend,
    t01.rcv_isu_storage_location_code as rcvng_or_issng_lctn,
    t01.stock_type_code as stock_type
  from bds_stock_balance t01;
  
/**/
/* Authority 
/**/
grant select on manu.stock_blnc to bds_app with grant option;
grant select on manu.stock_blnc to pt_app with grant option;
grant select on manu.stock_blnc to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym stock_blnc for manu.stock_blnc;  