/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 View   : site_shiftlog_fg_matl_vw  
 Owner   : manu
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - site_shiftlog_fg_matl_vw

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   ????           Created
 2008/11   Trevor Keon    Changed to use site_shiftlog_fg_matl table 

*******************************************************************************/

/**/
/* View creation 
/**/
create or replace force view manu_app.site_shiftlog_fg_matl_vw as
  select t01.matl_code,
    t01.matl_desc,
    t01.units_per_case,
    t01.gross_wght,
    t01.gross_wght_uom
  from site_shiftlog_fg_matl t01
  order by t01.matl_code;

/**/
/* Authority 
/**/
grant select on manu_app.site_shiftlog_fg_matl_vw to manu_user;
grant select on manu_app.site_shiftlog_fg_matl_vw to shiftlog with grant option;
grant select on manu_app.site_shiftlog_fg_matl_vw to shiftlog_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym site_shiftlog_fg_matl_vw for manu_app.site_shiftlog_fg_matl_vw;