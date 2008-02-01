/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cust_ship_to_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Customer Ship To View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.cust_ship_to_view
   (sap_sales_org_code,
    sales_org_desc,
    sap_division_code,
    division_desc,
    sap_distbn_chnl_code,
    distbn_chnl_desc,
    sap_cust_code,
    cust_name_ja,
    sap_partner_funcn_code,
    sap_cust_partner_code) as
   select t3.sap_sales_org_code, 
          t3.sales_org_desc, 
          t4.sap_division_code, 
          t4.division_desc, 
          t5.sap_distbn_chnl_code, 
          t5.distbn_chnl_desc, 
          t2.sap_cust_code, 
          t2.cust_name_ja, 
          t1.sap_partner_funcn_code, 
          t1.sap_cust_partner_code 
     from od.cust_partner_funcn t1, 
          dd.cust_dim t2, 
          dd.sales_org_dim t3, 
          dd.division_dim t4, 
          dd.distbn_chnl_dim t5 
    where t1.sap_partner_funcn_code = 'WE' 
      and t3.sap_sales_org_code in ('131','132') 
      and t1.sap_sales_org_code = t3.sap_sales_org_code(+) 
      and t1.sap_division_code = t4.sap_division_code(+) 
      and t1.sap_distbn_chnl_code = t5.sap_distbn_chnl_code(+) 
      and t1.sap_cust_code = t2.sap_cust_code(+) 
    group by t3.sap_sales_org_code, 
             t3.sales_org_desc, 
             t4.sap_division_code, 
             t4.division_desc,  
             t5.sap_distbn_chnl_code, 
             t5.distbn_chnl_desc, 
             t2.sap_cust_code, 
             t2.cust_name_ja, 
             t1.sap_partner_funcn_code, 
             t1.sap_cust_partner_code;

/*-*/
/* Authority
/*-*/
grant select on dw_app.cust_ship_to_view to bo_user;

/*-*/
/* Synonym
/*-*/
create public synonym cust_ship_to_view for dw_app.cust_ship_to_view;





