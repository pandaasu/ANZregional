/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : bom_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - BOM Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.bom_dim_view as
select ltrim(matl_code, '0') as matl_code,
  ltrim(rsu_matl_code, '0') as rsu_matl_code,
  to_rsu_buom_conv_fctr
from
  (select t01.matnr as matl_code,                                                     -- Material Number 
      t02.idnrk as rsu_matl_code,                                                     -- Component (Material Number) 
      (t02.menge_c / t01.bmeng_c) * (t03.umrez / t03.umren) as to_rsu_buom_conv_fctr  -- Component Qty 
    from sap_mat_bom_hdr t01,
      sap_mat_bom_det t02,
      sap_mat_uom t03
    where t01.stlal = '01'
      and t01.stlan = 5
      and t01.stlnr = t02.stlnr
      and t01.stlal = t02.stlal
      and t01.datuv < to_char(sysdate, 'YYYYMMDD')
      and t02.idnrk = t03.matnr
      and t03.meinh = t02.meins
      and t01.valdtn_status = 'VALID'
    
    union
  
    select t04.matl_code as matl_code,
      t04.matl_code as rsu_matl_code,
      1 as to_rsu_buom_conv_fctr
    from matl_dim t04
    where t04.matl_type_flag_rsu = 'X'
      and decode(t04.matl_type_flag_tdu, 'X', 1, 
        decode(t04.matl_type_flag_mcu, 'X', 1)) = 1
  );

/*-*/
/* Authority 
/*-*/
grant select on ods_app.bom_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym bom_dim_view for ods_app.bom_dim_view;