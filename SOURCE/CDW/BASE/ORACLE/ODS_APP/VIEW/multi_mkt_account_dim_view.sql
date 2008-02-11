/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : multi_mkt_account_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Multi Market Account Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.multi_mkt_account_dim_view as
select trim(t02.atwrt) as multi_mkt_acct_code,  -- SAP Multi-Market Account Code 
  t01.atwtb as multi_mkt_acct_desc              -- Multi-Market Account Desc 
from sap_chr_mas_dsc t01,
  sap_chr_mas_val t02,
  sap_chr_mas_hdr t03
where t01.atnam = t02.atnam
  and t01.atnam = t03.atnam
  and t01.valseq = t02.valseq
  and t01.spras = 'E'
  and t01.atnam = 'CLFFERT37'
  and t03.valdtn_status = 'VALID';
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.multi_mkt_account_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym multi_mkt_account_dim_view for ods_app.multi_mkt_account_dim_view;