/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sales_org_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Sales Organisation Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.sales_org_dim_view
   (sap_sales_org_code,
    sales_org_desc) as
   select t01.sap_sales_org_code,
          t01.sales_org_desc
     from sales_org t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.sales_org_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_org_dim_view for od_app.sales_org_dim_view;