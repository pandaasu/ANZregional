/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : prodn_line 
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Production Line View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/12   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.prodn_line as
select trim(t02.atwrt) as prodn_line_code, -- SAP Production Line Code 
  trim(t03.atwtb) as prodn_line_desc,      -- Production Line Description
  t01.objek
from sap_cla_chr t01,
  sap_chr_mas_val t02,
  sap_chr_mas_dsc t03
where t01.atnam (+) = 'Z_APCHAR5'
    and t01.atnam = t02.atnam (+)
    and t01.atwrt = t02.atwrt (+)
    and t02.atnam = t03.atnam (+)
    and t02.valseq = t03.valseq (+)
    and t03.spras_iso (+) = 'EN';
    
/*-*/
/* Authority
/*-*/
grant select on ods.prodn_line to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym prodn_line for ods.prodn_line;