/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : invc_type_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Invoice Type Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.invc_type_dim_view
   (sap_invc_type_code,
    invc_type_desc,
    invc_type_sign) as
   select t01.sap_invc_type_code,
          t01.invc_type_desc,
          t01.invc_type_sign
     from invc_type t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.invc_type_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym invc_type_dim_view for od_app.invc_type_dim_view;
