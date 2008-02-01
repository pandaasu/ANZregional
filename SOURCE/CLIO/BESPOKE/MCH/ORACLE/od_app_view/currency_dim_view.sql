/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : currency_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Currency Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.currency_dim_view
   (sap_currcy_code,
    currcy_desc) as
   select t01.sap_currcy_code,
          t01.currcy_desc
     from currency t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.currency_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym currency_dim_view for od_app.currency_dim_view;