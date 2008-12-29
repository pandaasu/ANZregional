/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : ref_resrce
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - Reference Plant View

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/06   Trevor Keon    Created 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu.ref_resrce as
  select t01.resrc_code as resrce_code,
    t01.resrc_text as resrce_desc,
    t01.resrc_plant_code as plant,
    sysdate as upd_datime
  from bds_prodctn_resrc_en t01
  where t01.resrc_plant_code in ('AU30');
    
/**/
/* Authority 
/**/
grant select on manu.ref_resrce to bds_app with grant option;
grant select on manu.ref_resrce to pt_app with grant option;
grant select on manu.ref_resrce to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_resrce for manu.ref_resrce;  