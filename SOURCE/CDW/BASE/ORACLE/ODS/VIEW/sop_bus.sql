/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/** 
 Object : sop_bus   
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - S&OP Business View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/12   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.sop_bus as
select trim(t02.atwrt) as sop_bus_code, -- SAP S&OP Business Code 
  trim(t03.atwtb) as sop_bus_desc,      -- S&OP Business Description 
  t01.objek
from sap_cla_chr t01,
  sap_chr_mas_val t02,
  sap_chr_mas_dsc t03
where t01.atnam (+) = 'Z_APCHAR4'
    and t01.atnam = t02.atnam (+)
    and t01.atwrt = t02.atwrt (+)
    and t02.atnam = t03.atnam (+)
    and t02.valseq = t03.valseq (+)
    and t03.spras_iso (+) = 'EN';
    
/*-*/
/* Authority
/*-*/
grant select on ods.sop_bus to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sop_bus for ods.sop_bus;