/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_division_hier_view
 Owner  : dd_app

 DESCRIPTION
 -----------
 Operational Data Store - Sales Division Hierarchy View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dd_app.sales_division_hier_view
   (sap_cust_code_level_1,
    cust_name_en_level_1,
    cust_name_ja_level_1,
    sap_sales_org_code_level_1,
    sap_distbn_chnl_code_level_1, 
    sap_division_code_level_1) as
   select distinct
          t01.sap_cust_code_level_1, 
          t01.cust_name_en_level_1, 
          t01.cust_name_ja_level_1, 
          t01.sap_sales_org_code_level_1, 
          t01.sap_distbn_chnl_code_level_1, 
          t01.sap_division_code_level_1
     from sales_force_geo_hier t01;

/*-*/
/* Authority
/*-*/
grant select on dd_app.sales_division_hier_view to dw_app;
grant select on dd_app.sales_division_hier_view to bo_user;

/*-*/
/* Synonym
/*-*/
create public synonym sales_division_hier_view for dd_app.sales_division_hier_view;
