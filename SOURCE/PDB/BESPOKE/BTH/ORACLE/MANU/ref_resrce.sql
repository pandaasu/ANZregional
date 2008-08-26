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
create or replace force view bds_app.ref_resrce_ics as
  select t01.resrc_code as resrce_code,
    t01.resrc_text as resrce_desc,
    t01.resrc_plant_code as plant,
    sysdate as upd_datime
  from bds_prodctn_resrc_en t01
  where t01.resrc_plant_code in ('AU20', 'AU21', 'AU22', 'AU23', 'AU24', 'AU25');
    
/**/
/* Authority 
/**/
--grant select on bds_app.ref_resrce_ics to bds_app with grant option;
grant select on bds_app.ref_resrce_ics to pt_app with grant option;
grant select on bds_app.ref_resrce_ics to manu_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym ref_resrce_ics for bds_app.ref_resrce_ics;  