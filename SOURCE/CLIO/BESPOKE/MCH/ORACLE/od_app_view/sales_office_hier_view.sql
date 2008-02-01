/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_office_hier_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Sales Office Hierarchy View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/04   Steve Gregan   Removed Japanese descriptions

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.sales_office_hier_view
   (sap_hier_cust_code,
    sap_sales_org_code,
    sap_distbn_chnl_code,
    sap_division_code,
    sap_cust_code_level_1,
    cust_name_en_level_1,
    sap_sales_org_code_level_1,
    sap_distbn_chnl_code_level_1,
    sap_division_code_level_1,
    cust_hier_sort_level_1,
    sap_cust_code_level_2,
    cust_name_en_level_2,
    sap_sales_org_code_level_2,
    sap_distbn_chnl_code_level_2,
    sap_division_code_level_2,
    cust_hier_sort_level_2,
    sap_cust_code_level_3,
    cust_name_en_level_3,
    sap_sales_org_code_level_3,
    sap_distbn_chnl_code_level_3,
    sap_division_code_level_3,
    cust_hier_sort_level_3,
    sap_cust_code_level_4,
    cust_name_en_level_4,
    sap_sales_org_code_level_4,
    sap_distbn_chnl_code_level_4,
    sap_division_code_level_4,
    cust_hier_sort_level_4,
    sap_cust_code_level_5,
    cust_name_en_level_5,
    sap_sales_org_code_level_5,
    sap_distbn_chnl_code_level_5,
    sap_division_code_level_5,
    cust_hier_sort_level_5,
    sap_cust_code_level_6,
    cust_name_en_level_6,
    sap_sales_org_code_level_6,
    sap_distbn_chnl_code_level_6,
    sap_division_code_level_6,
    cust_hier_sort_level_6,
    sap_cust_code_level_7,
    cust_name_en_level_7,
    sap_sales_org_code_level_7,
    sap_distbn_chnl_code_level_7,
    sap_division_code_level_7,
    cust_hier_sort_level_7,
    sap_cust_code_level_8,
    cust_name_en_level_8,
    sap_sales_org_code_level_8,
    sap_distbn_chnl_code_level_8,
    sap_division_code_level_8,
    cust_hier_sort_level_8,
    sap_cust_code_level_9,
    cust_name_en_level_9,
    sap_sales_org_code_level_9,
    sap_distbn_chnl_code_level_9,
    sap_division_code_level_9,
    cust_hier_sort_level_9,
    sap_cust_code_level_10,
    cust_name_en_level_10,
    sap_sales_org_code_level_10,
    sap_distbn_chnl_code_level_10,
    sap_division_code_level_10,
    cust_hier_sort_level_10) as
   select decode(t01.sap_cust_code_level_2,null,t01.sap_cust_code_level_1,
             decode(t01.sap_cust_code_level_3,null,t01.sap_cust_code_level_2,
                decode(t01.sap_cust_code_level_4,null,t01.sap_cust_code_level_3,
                   decode(t01.sap_cust_code_level_5,null,t01.sap_cust_code_level_4,
                      decode(t01.sap_cust_code_level_6,null,t01.sap_cust_code_level_5,
                         decode(t01.sap_cust_code_level_7,null,t01.sap_cust_code_level_6,
                            decode(t01.sap_cust_code_level_8,null,t01.sap_cust_code_level_7,
                               decode(t01.sap_cust_code_level_9,null,t01.sap_cust_code_level_8,
                                  decode(t01.sap_cust_code_level_10,null,t01.sap_cust_code_level_9))))))))) as sap_hier_cust_code,
          decode(t01.sap_cust_code_level_2,null,t01.sap_sales_org_code_level_1,
             decode(t01.sap_cust_code_level_3,null,t01.sap_sales_org_code_level_2,
                decode(t01.sap_cust_code_level_4,null,t01.sap_sales_org_code_level_3,
                   decode(t01.sap_cust_code_level_5,null,t01.sap_sales_org_code_level_4,
                      decode(t01.sap_cust_code_level_6,null,t01.sap_sales_org_code_level_5,
                         decode(t01.sap_cust_code_level_7,null,t01.sap_sales_org_code_level_6,
                            decode(t01.sap_cust_code_level_8,null,t01.sap_sales_org_code_level_7,
                               decode(t01.sap_cust_code_level_9,null,t01.sap_sales_org_code_level_8,
                                  decode(t01.sap_cust_code_level_10,null,t01.sap_sales_org_code_level_9))))))))) as sap_sales_org_code,
          decode(t01.sap_cust_code_level_2,null,t01.sap_distbn_chnl_code_level_1,
             decode(t01.sap_cust_code_level_3,null,t01.sap_distbn_chnl_code_level_2,
                decode(t01.sap_cust_code_level_4,null,t01.sap_distbn_chnl_code_level_3,
                   decode(t01.sap_cust_code_level_5,null,t01.sap_distbn_chnl_code_level_4,
                      decode(t01.sap_cust_code_level_6,null,t01.sap_distbn_chnl_code_level_5,
                         decode(t01.sap_cust_code_level_7,null,t01.sap_distbn_chnl_code_level_6,
                            decode(t01.sap_cust_code_level_8,null,t01.sap_distbn_chnl_code_level_7,
                               decode(t01.sap_cust_code_level_9,null,t01.sap_distbn_chnl_code_level_8,
                                  decode(t01.sap_cust_code_level_10,null,t01.sap_distbn_chnl_code_level_9))))))))) as sap_distbn_chnl_code,
          decode(t01.sap_cust_code_level_2,null,t01.sap_division_code_level_1,
             decode(t01.sap_cust_code_level_3,null,t01.sap_division_code_level_2,
                decode(t01.sap_cust_code_level_4,null,t01.sap_division_code_level_3,
                   decode(t01.sap_cust_code_level_5,null,t01.sap_division_code_level_4,
                      decode(t01.sap_cust_code_level_6,null,t01.sap_division_code_level_5,
                         decode(t01.sap_cust_code_level_7,null,t01.sap_division_code_level_6,
                            decode(t01.sap_cust_code_level_8,null,t01.sap_division_code_level_7,
                               decode(t01.sap_cust_code_level_9,null,t01.sap_division_code_level_8,
                                  decode(t01.sap_cust_code_level_10,null,t01.sap_division_code_level_9))))))))) as sap_division_code,
          t01.sap_cust_code_level_1,
          t03.addr_name as cust_name_en_level_1,
          t01.sap_sales_org_code_level_1,
          t01.sap_distbn_chnl_code_level_1,
          t01.sap_division_code_level_1,
          t01.cust_hier_sort_level_1,
          t01.sap_cust_code_level_2,
          t05.addr_name as cust_name_en_level_2,
          t01.sap_sales_org_code_level_2,
          t01.sap_distbn_chnl_code_level_2,
          t01.sap_division_code_level_2,
          t01.cust_hier_sort_level_2,
          t01.sap_cust_code_level_3,
          t07.addr_name as cust_name_en_level_3,
          t01.sap_sales_org_code_level_3,
          t01.sap_distbn_chnl_code_level_3,
          t01.sap_division_code_level_3,
          t01.cust_hier_sort_level_3,
          t01.sap_cust_code_level_4,
          t09.addr_name as cust_name_en_level_4,
          t01.sap_sales_org_code_level_4,
          t01.sap_distbn_chnl_code_level_4,
          t01.sap_division_code_level_4,
          t01.cust_hier_sort_level_4,
          t01.sap_cust_code_level_5,
          t11.addr_name as cust_name_en_level_5,
          t01.sap_sales_org_code_level_5,
          t01.sap_distbn_chnl_code_level_5,
          t01.sap_division_code_level_5,
          t01.cust_hier_sort_level_5,
          t01.sap_cust_code_level_6,
          t13.addr_name as cust_name_en_level_6,
          t01.sap_sales_org_code_level_6,
          t01.sap_distbn_chnl_code_level_6,
          t01.sap_division_code_level_6,
          t01.cust_hier_sort_level_6,
          t01.sap_cust_code_level_7,
          t15.addr_name as cust_name_en_level_7,
          t01.sap_sales_org_code_level_7,
          t01.sap_distbn_chnl_code_level_7,
          t01.sap_division_code_level_7,
          t01.cust_hier_sort_level_7,
          t01.sap_cust_code_level_8,
          t17.addr_name as cust_name_en_level_8,
          t01.sap_sales_org_code_level_8,
          t01.sap_distbn_chnl_code_level_8,
          t01.sap_division_code_level_8,
          t01.cust_hier_sort_level_8,
          t01.sap_cust_code_level_9,
          t19.addr_name as cust_name_en_level_9,
          t01.sap_sales_org_code_level_9,
          t01.sap_distbn_chnl_code_level_9,
          t01.sap_division_code_level_9,
          t01.cust_hier_sort_level_9,
          t01.sap_cust_code_level_10,
          t21.addr_name as cust_name_en_level_10,
          t01.sap_sales_org_code_level_10,
          t01.sap_distbn_chnl_code_level_10,
          t01.sap_division_code_level_10,
          t01.cust_hier_sort_level_10
     from cust_hier t01,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t03,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t05,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t07,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t09,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t11,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t13,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t15,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t17,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t19,
          (select t01.sap_cust_vendor_code, t01.addr_name from address t01 where t01.sap_addr_type_code = 'KNA1' and t01.addr_vrsn is null) t21
    where t01.sap_cust_hier_type_code = 'N'
      and t01.sap_cust_code_level_1 = t03.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_1 <= sysdate and
            t01.node_vldty_end_date_level_1 >= sysdate) or
           (t01.node_vldty_start_date_level_1 is null and
            t01.node_vldty_end_date_level_1 is null))
      and t01.sap_cust_code_level_2 = t05.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_2 <= sysdate and
            t01.node_vldty_end_date_level_2 >= sysdate) or
           (t01.node_vldty_start_date_level_2 is null and
            t01.node_vldty_end_date_level_2 is null))
      and t01.sap_cust_code_level_3 = t07.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_3 <= sysdate and
            t01.node_vldty_end_date_level_3 >= sysdate) or
           (t01.node_vldty_start_date_level_3 is null and
            t01.node_vldty_end_date_level_3 is null))
      and t01.sap_cust_code_level_4 = t09.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_4 <= sysdate and
            t01.node_vldty_end_date_level_4 >= sysdate) or
           (t01.node_vldty_start_date_level_4 is null and
            t01.node_vldty_end_date_level_4 is null))
      and t01.sap_cust_code_level_5 = t11.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_5 <= sysdate and
            t01.node_vldty_end_date_level_5 >= sysdate) or
           (t01.node_vldty_start_date_level_5 is null and
            t01.node_vldty_end_date_level_5 is null))
      and t01.sap_cust_code_level_6 = t13.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_6 <= sysdate and
            t01.node_vldty_end_date_level_6 >= sysdate) or
           (t01.node_vldty_start_date_level_6 is null and
            t01.node_vldty_end_date_level_6 is null))
      and t01.sap_cust_code_level_7 = t15.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_7 <= sysdate and
            t01.node_vldty_end_date_level_7 >= sysdate) or
           (t01.node_vldty_start_date_level_7 is null and
            t01.node_vldty_end_date_level_7 is null))
      and t01.sap_cust_code_level_8 = t17.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_8 <= sysdate and
            t01.node_vldty_end_date_level_8 >= sysdate) or
           (t01.node_vldty_start_date_level_8 is null and
            t01.node_vldty_end_date_level_8 is null))
      and t01.sap_cust_code_level_9 = t19.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_9 <= sysdate and
            t01.node_vldty_end_date_level_9 >= sysdate) or
           (t01.node_vldty_start_date_level_9 is null and
            t01.node_vldty_end_date_level_9 is null))
      and t01.sap_cust_code_level_10 = t21.sap_cust_vendor_code(+)
      and ((t01.node_vldty_start_date_level_10 <= sysdate and
            t01.node_vldty_end_date_level_10 >= sysdate) or
           (t01.node_vldty_start_date_level_10 is null and
            t01.node_vldty_end_date_level_10 is null));

/*-*/
/* Authority
/*-*/
grant select on od_app.sales_office_hier_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_office_hier_view for od_app.sales_office_hier_view;

