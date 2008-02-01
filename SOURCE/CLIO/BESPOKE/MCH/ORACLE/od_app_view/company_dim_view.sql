/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : company_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Company Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.company_dim_view
   (sap_company_code,
    company_desc,
    sap_currcy_code) as
   select t01.sap_company_code,
          t01.company_desc,
          t01.sap_currcy_code
     from company t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.company_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym company_dim_view for od_app.company_dim_view;
