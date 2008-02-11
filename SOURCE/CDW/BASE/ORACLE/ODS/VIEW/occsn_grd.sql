/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : occsn_grd  
 Owner  : ods 

 DESCRIPTION 
 -----------
 Operational Data Store - Occasion View (GRD) 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/11   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods.occsn_grd as
select trim(substr(t01.z_data,4,2)) as occsn_code,  -- SAP Occasion Code 
  substr(t01.z_data,6,12) as occsn_abbrd_desc,      -- Occasion Abbreviated Description  
  substr(t01.z_data,18,30) as occsn_desc,           -- Occasion Description 
  t02.objek 
from sap_ref_dat t01,
  grd_cla_chr t02
where t01.z_tabname = '/MARS/MD_CHC011'
  and t02.atnam (+) = 'CLFFERT11'
  and t02.atwrt = trim(substr(t01.z_data (+), 4, 2));

/*-*/
/* Authority
/*-*/
grant select on ods.occsn_grd to ods_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym occsn_grd for ods.occsn_grd;