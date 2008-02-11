/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : dmd_plng_grp_matl_div_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Demand Planning Group Material Division Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.dmd_plng_grp_matl_div_dim_view as
select cust_code,
  division_code,
  demand_plng_grp_code
from
  (
    select distinct cust_code,
      case when (sales_org_code = '147' and distbn_chnl_code = '10' and division_code in ('51','56')) then '05' 
           when (sales_org_code = '147' and distbn_chnl_code = '11' and division_code = '56') then '05' 
           when (sales_org_code = '147' and distbn_chnl_code = '18' and division_code = '56') then '05' 
           when (sales_org_code = '147' and distbn_chnl_code = '20' and division_code = '51') then '05' 
           when (sales_org_code = '147' and distbn_chnl_code = '99' and division_code = '51') then '05'
           when (sales_org_code = '147' and distbn_chnl_code = '12' and division_code in ('51','57')) then '02'  
           when (sales_org_code = '147' and distbn_chnl_code = '10' and division_code = '57') then '02'
           when (sales_org_code = '149') then '05' 
           else null  -- not match the above condition 
      end as division_code,
      demand_plng_grp_code
    from demand_plng_grp_sales_area_dim
  )
where division_code is not null; -- only pick the defined division 

/*-*/
/* Authority 
/*-*/
grant select on ods_app.dmd_plng_grp_matl_div_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym dmd_plng_grp_matl_div_dim_view for ods_app.dmd_plng_grp_matl_div_dim_view;