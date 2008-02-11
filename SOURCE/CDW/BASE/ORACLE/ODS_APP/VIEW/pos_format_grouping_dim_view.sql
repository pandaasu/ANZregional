/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : pos_format_grouping_dim_view  
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - POS Format Grouping Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.pos_format_grouping_dim_view as
select trim(t02.atwrt) as pos_format_grpg_code,
  t01.atwtb as pos_format_grpg_desc
from sap_chr_mas_dsc t01,
  sap_chr_mas_val t02,
  sap_chr_mas_hdr t03 
where t01.atnam = t02.atnam
  and t01.atnam = t03.atnam
  and t01.valseq = t02.valseq
  and t01.spras = 'E'
  and t01.atnam = 'CLFFERT41'
  and t03.valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.pos_format_grouping_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym pos_format_grouping_dim_view for ods_app.pos_format_grouping_dim_view;