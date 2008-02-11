/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : banner_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Banner Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.banner_dim_view as
select t01.atwrt as banner_code,  -- SAP Banner Code 
  t02.atwtb as banner_desc        -- Banner Desc 
from sap_chr_mas_val t01,
  sap_chr_mas_dsc t02
where t01.atnam = t02.atnam
  and t01.valseq = t02.valseq
  and t01.atnam = 'CLFFERT104'

/*-*/
/* Authority 
/*-*/
grant select on ods_app.banner_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym banner_dim_view for ods_app.banner_dim_view;