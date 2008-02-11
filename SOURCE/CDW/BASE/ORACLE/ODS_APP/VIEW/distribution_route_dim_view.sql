/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : distribution_route_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Distribution Route Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.distribution_route_dim_view as
select t01.atwrt as distbn_route_code,
  t02.atwtb as distbn_route_desc
from sap_chr_mas_val t01,
  sap_chr_mas_dsc t02
where t01.atnam = t02.atnam
  and t01.valseq = t02.valseq
  and t01.atnam = 'CLFFERT106'; 
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.distribution_route_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym distribution_route_dim_view for ods_app.distribution_route_dim_view;