/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mkt_ctgry   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Market Category View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/12   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.mkt_ctgry as
select trim(t02.atwrt) as mkt_ctgry_code, -- SAP Market Category Code 
  trim(t03.atwtb) as mkt_ctgry_desc,      -- Market Category Description 
  t01.objek
from sap_cla_chr t01,
  sap_chr_mas_val t02,
  sap_chr_mas_dsc t03
where t01.atnam (+) = 'Z_APCHAR1'
    and t01.atnam = t02.atnam (+)
    and t01.atwrt = t02.atwrt (+)
    and t02.atnam = t03.atnam (+)
    and t02.valseq = t03.valseq (+)
    and t03.spras_iso (+) = 'EN';
    
/*-*/
/* Authority
/*-*/
grant select on ods.mkt_ctgry to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mkt_ctgry for ods.mkt_ctgry;    