/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_usage_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Order Usage Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.order_usage_dim_view
   (sap_order_usage_code,
    order_usage_desc) as
   select t01.sap_order_usage_code,
          t01.order_usage_desc
     from order_usage t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.order_usage_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym order_usage_dim_view for od_app.order_usage_dim_view;