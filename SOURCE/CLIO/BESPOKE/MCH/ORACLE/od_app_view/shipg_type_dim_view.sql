/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : shipg_type_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Shipping Type Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.shipg_type_dim_view
   (sap_shipg_type_code,
    shipg_type_desc) as
   select t01.sap_shipg_type_code,
          t01.shipg_type_desc
     from shipg_type t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.shipg_type_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym shipg_type_dim_view for od_app.shipg_type_dim_view;