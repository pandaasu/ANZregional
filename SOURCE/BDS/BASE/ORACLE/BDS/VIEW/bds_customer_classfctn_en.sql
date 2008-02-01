 /******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CUSTOMER_CLASSFCTN_EN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Customer Characteristic/Classification View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2007/09   Linden Glen    Added ZZAUCUST01

*******************************************************************************/


/**/
/* Table creation
/**/

create or replace view bds_customer_classfctn_en as  
   select t01.sap_customer_code as sap_customer_code,
          t01.sap_pos_frmt_grp_code as sap_pos_frmt_grp_code,
          t02.sap_charistic_value_desc as sap_pos_frmt_grp_desc,
          t01.sap_pos_frmt_code as sap_pos_frmt_code,
          t03.sap_charistic_value_desc as sap_pos_frmt_desc,
          t01.sap_pos_frmt_size_code as sap_pos_frmt_size_code,
          t04.sap_charistic_value_desc as sap_pos_frmt_size_desc,
          t01.sap_pos_place_code as sap_pos_place_code,
          t05.sap_charistic_value_desc as sap_pos_place_desc,
          t01.sap_banner_code as sap_banner_code,
          t06.sap_charistic_value_desc as sap_banner_desc,
          t01.sap_ultmt_prnt_acct_code as sap_ultmt_prnt_acct_code,
          t07.sap_charistic_value_desc as sap_ultmt_prnt_acct_desc,
          t01.sap_multi_mrkt_acct_code as sap_multi_mrkt_acct_code,
          t08.sap_charistic_value_desc as sap_multi_mrkt_acct_desc,
          t01.sap_cust_buying_grp_code as sap_cust_buying_grp_code,
          t09.sap_charistic_value_desc as sap_cust_buying_grp_desc,
          t01.sap_dstrbtn_route_code as sap_dstrbtn_route_code,
          t10.sap_charistic_value_desc as sap_dstrbtn_route_desc,
          t01.sap_prim_route_to_cnsmr_code as sap_prim_route_to_cnsmr_code,
          t11.sap_charistic_value_desc as sap_prim_route_to_cnsmr_desc,
          t01.sap_operation_bus_model_code as sap_operation_bus_model_code,
          t12.sap_charistic_value_desc as sap_operation_bus_model_desc,
          t01.sap_fundrsng_sales_trrtry_code as sap_fundrsng_sales_trrtry_code,
          t13.sap_charistic_value_desc as sap_fundrsng_sales_trrtry_desc
   from bds_customer_classfctn t01,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT41') t02,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT101') t03,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT102') t04,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT103') t05,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT104') t06,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT105') t07,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT37') t08,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT36') t09,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT106') t10,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT107') t11,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'CLFFERT108') t12,
        (select a.sap_charistic_value_code,
                a.sap_charistic_value_desc
         from bds_charistic_value_en a
         where sap_charistic_code = 'ZZAUCUST01') t13
   where t01.sap_pos_frmt_grp_code = t02.sap_charistic_value_code(+)
     and t01.sap_pos_frmt_code = t03.sap_charistic_value_code(+)
     and t01.sap_pos_frmt_size_code = t04.sap_charistic_value_code(+)
     and t01.sap_pos_place_code = t05.sap_charistic_value_code(+)
     and t01.sap_banner_code = t06.sap_charistic_value_code(+)
     and t01.sap_ultmt_prnt_acct_code = t07.sap_charistic_value_code(+)
     and t01.sap_multi_mrkt_acct_code = t08.sap_charistic_value_code(+)
     and t01.sap_cust_buying_grp_code = t09.sap_charistic_value_code(+)
     and t01.sap_dstrbtn_route_code = t10.sap_charistic_value_code(+)
     and t01.sap_prim_route_to_cnsmr_code = t11.sap_charistic_value_code(+)
     and t01.sap_operation_bus_model_code = t12.sap_charistic_value_code(+)
     and t01.sap_fundrsng_sales_trrtry_code = t13.sap_charistic_value_code(+);
/

/**/
/* Synonym
/**/
create or replace public synonym bds_customer_classfctn_en for bds.bds_customer_classfctn_en;


/**/
/* Authority
/**/
grant select on bds_customer_classfctn_en to public with grant option;