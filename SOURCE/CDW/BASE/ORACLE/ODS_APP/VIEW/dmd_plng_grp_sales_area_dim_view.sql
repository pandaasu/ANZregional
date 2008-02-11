--/******************************************************************************/
--/* View Definition                                                            */
--/******************************************************************************/
--/**
-- Object : dmd_plng_grp_sales_area_dim_view 
-- Owner  : ods_app 

-- DESCRIPTION 
-- -----------
-- Operational Data Store - Demand Planning Group Sales Area Dimension View 

-- YYYY/MM   Author         Description 
-- -------   ------         ----------- 
-- 2007/10   Trevor Keon    Created 

--*******************************************************************************/

--/*-*/ 
--/* View creation 
--/*-*/ 
create or replace force view ods_app.dmd_plng_grp_sales_area_dim_view as
select cust_code,
  sales_org_code,
  distbn_chnl_code,
  division_code,
  max(demand_plng_grp_code)
from
(
  select t01.kunnr as cust_code,        -- SAP Customer Code 
    t02.vkorg as sales_org_code,        -- Sale Org Code 
    t02.vtweg as distbn_chnl_code,      -- Distribution Channel Code 
    t02.spart as division_code,         -- Division Code 
    t03.kunn2 as demand_plng_grp_code   -- Demand Planning Group Code (SAP Customer Code) 
  from sap_cus_hdr t01,
    sap_cus_sad t02,
    sap_cus_pfr t03
  where t01.kunnr = t02.kunnr
    and t01.kunnr = t03.kunnr
    and t02.sadseq = t03.sadseq
    and t01.valdtn_status = 'VALID'
    and t01.ktokd <> '0012'
    and t03.parvw = 'ZC'
    
  union
  
  select distinct t03.kunnr as cust_code,             -- SAP Customer Code (Ship To) 
    t01.sales_org_code as sales_org_code,             -- Sale Org Code 
    t01.distbn_chnl_code as distbn_chnl_code,         -- Distribution Channel Code 
    t01.division_code as division_code,               -- Division Code 
    t02.demand_plng_grp_code as demand_plng_grp_code  -- Demand Planning Group Code (SAP Customer Code) 
  from fcst_hdr t01,
    fcst_dtl t02,
    sap_cus_pfr t03,
    sap_cus_sad t04
  where t01.fcst_hdr_code = t02.fcst_hdr_code
    and t01.sales_org_code = t04.vkorg
    and t01.distbn_chnl_code = t04.vtweg
    and t01.division_code = t04.spart
    and t03.kunnr = t04.kunnr
    and t03.sadseq = t04.sadseq
    and t02.cust_code = t03.kunn2
    and t02.cust_code is not null
    and t02.demand_plng_grp_code is not null
    and t01.current_fcst_flag = 'Y'
    and t01.valdtn_status = 'VALID'
    and t01.fcst_type_code = 'FCST'
    and t03.parvw in ('RE','WE')  
)
group by cust_code, 
  sales_org_code, 
  distbn_chnl_code, 
  division_code;  
  
  /*-*/
/* Authority 
/*-*/
grant select on ods_app.dmd_plng_grp_sales_area_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym dmd_plng_grp_sales_area_dim_view for ods_app.dmd_plng_grp_sales_area_dim_view;