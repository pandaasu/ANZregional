/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_office_hier_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Sales Office Heirarchy View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.sales_office_hier_view as
select decode(t01.sap_cust_code_level_2, null, t01.sap_cust_code_level_1,
    decode(t01.sap_cust_code_level_3, null, t01.sap_cust_code_level_2,
      decode(t01.sap_cust_code_level_4, null, t01.sap_cust_code_level_3,
        decode(t01.sap_cust_code_level_5, null, t01.sap_cust_code_level_4,
          decode(t01.sap_cust_code_level_6, null, t01.sap_cust_code_level_5,
            decode(t01.sap_cust_code_level_7, null, t01.sap_cust_code_level_6,
              decode(t01.sap_cust_code_level_8, null, t01.sap_cust_code_level_7,
                decode(t01.sap_cust_code_level_9, null, t01.sap_cust_code_level_8,
                  decode(t01.sap_cust_code_level_10, null, t01.sap_cust_code_level_9,
                  t01.sap_cust_code_level_10))))))))) as cust_code,
  decode(t01.sap_cust_code_level_2, null, t01.sap_sales_org_code_level_1,
    decode(t01.sap_cust_code_level_3, null, t01.sap_sales_org_code_level_2,
      decode(t01.sap_cust_code_level_4, null, t01.sap_sales_org_code_level_3,
        decode(t01.sap_cust_code_level_5, null, t01.sap_sales_org_code_level_4,
          decode(t01.sap_cust_code_level_6, null, t01.sap_sales_org_code_level_5,
            decode(t01.sap_cust_code_level_7, null, t01.sap_sales_org_code_level_6,
              decode(t01.sap_cust_code_level_8, null, t01.sap_sales_org_code_level_7,
                decode(t01.sap_cust_code_level_9, null, t01.sap_sales_org_code_level_8,
                  decode(t01.sap_cust_code_level_10, null, t01.sap_sales_org_code_level_9,
                  t01.sap_sales_org_code_level_10))))))))) as sales_org_code,
  decode(t01.sap_cust_code_level_2, null, t01.sap_distbn_chnl_code_level_1,
    decode(t01.sap_cust_code_level_3, null, t01.sap_distbn_chnl_code_level_2,
      decode(t01.sap_cust_code_level_4, null, t01.sap_distbn_chnl_code_level_3,
        decode(t01.sap_cust_code_level_5, null, t01.sap_distbn_chnl_code_level_4,
          decode(t01.sap_cust_code_level_6, null, t01.sap_distbn_chnl_code_level_5,
            decode(t01.sap_cust_code_level_7, null, t01.sap_distbn_chnl_code_level_6,
              decode(t01.sap_cust_code_level_8, null, t01.sap_distbn_chnl_code_level_7,
                decode(t01.sap_cust_code_level_9, null, t01.sap_distbn_chnl_code_level_8,
                  decode(t01.sap_cust_code_level_10, null, t01.sap_distbn_chnl_code_level_9,
                  t01.sap_distbn_chnl_code_level_10))))))))) as distbn_chnl_code,
  decode(t01.sap_cust_code_level_2, null, t01.sap_division_code_level_1,
    decode(t01.sap_cust_code_level_3, null, t01.sap_division_code_level_2,
      decode(t01.sap_cust_code_level_4, null, t01.sap_division_code_level_3,
        decode(t01.sap_cust_code_level_5, null, t01.sap_division_code_level_4,
          decode(t01.sap_cust_code_level_6, null, t01.sap_division_code_level_5,
            decode(t01.sap_cust_code_level_7, null, t01.sap_division_code_level_6,
              decode(t01.sap_cust_code_level_8, null, t01.sap_division_code_level_7,
                decode(t01.sap_cust_code_level_9, null, t01.sap_division_code_level_8,
                  decode(t01.sap_cust_code_level_10, null, t01.sap_division_code_level_9,
                  t01.sap_division_code_level_10))))))))) as division_code,
  t01.sap_cust_code_level_1,
  t02.name as sap_cust_name_en_level_1,
  t01.sap_sales_org_code_level_1,
  t01.sap_distbn_chnl_code_level_1,
  t01.sap_division_code_level_1,
  t01.cust_hier_sort_level_1,
  t01.node_vldty_start_date_level_1,
  t01.node_vldty_end_date_level_1,
  t01.sap_cust_code_level_2,
  t03.name as sap_cust_name_en_level_2,
  t01.sap_sales_org_code_level_2,
  t01.sap_distbn_chnl_code_level_2,
  t01.sap_division_code_level_2,
  t01.cust_hier_sort_level_2,
  t01.node_vldty_start_date_level_2,
  t01.node_vldty_end_date_level_2,
  t01.sap_cust_code_level_3,
  t04.name as sap_cust_name_en_level_3,
  t01.sap_sales_org_code_level_3,
  t01.sap_distbn_chnl_code_level_3,
  t01.sap_division_code_level_3,
  t01.cust_hier_sort_level_3,
  t01.node_vldty_start_date_level_3,
  t01.node_vldty_end_date_level_3,
  t01.sap_cust_code_level_4,
  t05.name as sap_cust_name_en_level_4,
  t01.sap_sales_org_code_level_4,
  t01.sap_distbn_chnl_code_level_4,
  t01.sap_division_code_level_4,
  t01.cust_hier_sort_level_4,
  t01.node_vldty_start_date_level_4,
  t01.node_vldty_end_date_level_4,
  t01.sap_cust_code_level_5,
  t06.name as sap_cust_name_en_level_5,
  t01.sap_sales_org_code_level_5,
  t01.sap_distbn_chnl_code_level_5,
  t01.sap_division_code_level_5,
  t01.cust_hier_sort_level_5,
  t01.node_vldty_start_date_level_5,
  t01.node_vldty_end_date_level_5,
  t01.sap_cust_code_level_6,
  t07.name as sap_cust_name_en_level_6,
  t01.sap_sales_org_code_level_6,
  t01.sap_distbn_chnl_code_level_6,
  t01.sap_division_code_level_6,
  t01.cust_hier_sort_level_6,
  t01.node_vldty_start_date_level_6,
  t01.node_vldty_end_date_level_6,
  t01.sap_cust_code_level_7,
  t08.name as sap_cust_name_en_level_7,
  t01.sap_sales_org_code_level_7,
  t01.sap_distbn_chnl_code_level_7,
  t01.sap_division_code_level_7,
  t01.cust_hier_sort_level_7,
  t01.node_vldty_start_date_level_7,
  t01.node_vldty_end_date_level_7,
  t01.sap_cust_code_level_8,
  t09.name as sap_cust_name_en_level_8,
  t01.sap_sales_org_code_level_8,
  t01.sap_distbn_chnl_code_level_8,
  t01.sap_division_code_level_8,
  t01.cust_hier_sort_level_8,
  t01.node_vldty_start_date_level_8,
  t01.node_vldty_end_date_level_8,
  t01.sap_cust_code_level_9,
  t10.name as sap_cust_name_en_level_9,
  t01.sap_sales_org_code_level_9,
  t01.sap_distbn_chnl_code_level_9,
  t01.sap_division_code_level_9,
  t01.cust_hier_sort_level_9,
  t01.node_vldty_start_date_level_9,
  t01.node_vldty_end_date_level_9,
  t01.sap_cust_code_level_10,
  t11.name as sap_cust_name_en_level_10,
  t01.sap_sales_org_code_level_10,
  t01.sap_distbn_chnl_code_level_10,
  t01.sap_division_code_level_10,
  t01.cust_hier_sort_level_10,
  t01.node_vldty_start_date_level_10,
  t01.node_vldty_end_date_level_10
from ods_cust_hier t01,
  sap_adr_det t02,
  sap_adr_det t03,
  sap_adr_det t04,
  sap_adr_det t05,
  sap_adr_det t06,
  sap_adr_det t07,
  sap_adr_det t08,
  sap_adr_det t09,
  sap_adr_det t10,
  sap_adr_det t11
where t01.sap_cust_hier_type_code = 'N'
  and ((t01.node_vldty_start_date_level_1 <= sysdate and
      t01.node_vldty_end_date_level_1 >= sysdate) or
     (t01.node_vldty_start_date_level_1 is null and
      t01.node_vldty_end_date_level_1 is null))
  and ((t01.node_vldty_start_date_level_2 <= sysdate and
      t01.node_vldty_end_date_level_2 >= sysdate) or
     (t01.node_vldty_start_date_level_2 is null and
      t01.node_vldty_end_date_level_2 is null))
  and ((t01.node_vldty_start_date_level_3 <= sysdate and
      t01.node_vldty_end_date_level_3 >= sysdate) or
     (t01.node_vldty_start_date_level_3 is null and
      t01.node_vldty_end_date_level_3 is null))
  and ((t01.node_vldty_start_date_level_4 <= sysdate and
      t01.node_vldty_end_date_level_4 >= sysdate) or
     (t01.node_vldty_start_date_level_4 is null and
      t01.node_vldty_end_date_level_4 is null))
  and ((t01.node_vldty_start_date_level_5 <= sysdate and
      t01.node_vldty_end_date_level_5 >= sysdate) or
     (t01.node_vldty_start_date_level_5 is null and
      t01.node_vldty_end_date_level_5 is null))
  and ((t01.node_vldty_start_date_level_6 <= sysdate and
      t01.node_vldty_end_date_level_6 >= sysdate) or
     (t01.node_vldty_start_date_level_6 is null and
      t01.node_vldty_end_date_level_6 is null))
  and ((t01.node_vldty_start_date_level_7 <= sysdate and
      t01.node_vldty_end_date_level_7 >= sysdate) or
     (t01.node_vldty_start_date_level_7 is null and
      t01.node_vldty_end_date_level_7 is null))
  and ((t01.node_vldty_start_date_level_8 <= sysdate and
      t01.node_vldty_end_date_level_8 >= sysdate) or
     (t01.node_vldty_start_date_level_8 is null and
      t01.node_vldty_end_date_level_8 is null))
  and ((t01.node_vldty_start_date_level_9 <= sysdate and
      t01.node_vldty_end_date_level_9 >= sysdate) or
     (t01.node_vldty_start_date_level_9 is null and
      t01.node_vldty_end_date_level_9 is null))
  and ((t01.node_vldty_start_date_level_10 <= sysdate and
      t01.node_vldty_end_date_level_10 >= sysdate) or
     (t01.node_vldty_start_date_level_10 is null and
      t01.node_vldty_end_date_level_10 is null))                                            
  and t01.sap_cust_code_level_1 = t02.obj_id (+)
  and t01.sap_cust_code_level_2 = t03.obj_id (+)
  and t01.sap_cust_code_level_3 = t04.obj_id (+)
  and t01.sap_cust_code_level_4 = t05.obj_id (+)
  and t01.sap_cust_code_level_5 = t06.obj_id (+)
  and t01.sap_cust_code_level_6 = t07.obj_id (+)
  and t01.sap_cust_code_level_7 = t08.obj_id (+)
  and t01.sap_cust_code_level_8 = t09.obj_id (+)
  and t01.sap_cust_code_level_9 = t10.obj_id (+)
  and t01.sap_cust_code_level_10 = t11.obj_id (+);
  
/*-*/
/* Authority 
/*-*/
grant select on ods_app.sales_office_hier_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym sales_office_hier_view for ods_app.sales_office_hier_view;