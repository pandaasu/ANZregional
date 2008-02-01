/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : order_type_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Order Type Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.order_type_dim_view
   (sap_order_type_code,
    order_type_desc) as
   select t01.sap_order_type_code,
          t01.order_type_desc
     from order_type t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.order_type_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym order_type_dim_view for od_app.order_type_dim_view;