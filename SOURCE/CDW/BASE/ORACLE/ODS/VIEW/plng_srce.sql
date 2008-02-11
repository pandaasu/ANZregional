/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : plng_srce   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Planning Source View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/12   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.plng_srce as
select trim(t02.atwrt) as plng_srce_code, -- SAP Planning Source Code 
  trim(t03.atwtb) as plng_srce_desc,      -- Planning Source Description 
  t01.objek
from sap_cla_chr t01,
  sap_chr_mas_val t02,
  sap_chr_mas_dsc t03
where t01.atnam (+) = 'Z_APCHAR8'
    and t01.atnam = t02.atnam (+)
    and t01.atwrt = t02.atwrt (+)
    and t02.atnam = t03.atnam (+)
    and t02.valseq = t03.valseq (+)
    and t03.spras_iso (+) = 'EN';
    
/*-*/
/* Authority
/*-*/
grant select on ods.plng_srce to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym plng_srce for ods.plng_srce;    