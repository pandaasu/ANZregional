/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : demand_plng_grp_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Demand Planning Group Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.demand_plng_grp_dim_view as
select t03.kunn2 as demand_plng_grp_code,	-- Demand Planning Group Code (SAP Customer Code) 
  t03.zz_partn_nam as demand_plng_grp_desc	-- Demand Planning Group Description (SAP Customer Description) 
from sap_cus_hdr t01,
  sap_cus_sad t02,
  sap_cus_pfr t03
where t01.kunnr = t02.kunnr
  and t01.kunnr = t03.kunnr
  and t02.sadseq = t03.sadseq
  and t01.valdtn_status = 'VALID'
  and t01.ktokd = '0012'
  and t03.parvw = 'ZC'
  
union

select t01.obj_id as demand_plng_grp_code,	-- Demand Planning Group Code (SAP Customer Code) 
  t01.name as demand_plng_grp_desc		-- Demand Planning Group Description (SAP Customer Description) 
from sap_adr_det t01
where t01.sort2 like 'DMD GRP%';

/*-*/
/* Authority 
/*-*/
grant select on ods_app.demand_plng_grp_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym demand_plng_grp_dim_view for ods_app.demand_plng_grp_dim_view;