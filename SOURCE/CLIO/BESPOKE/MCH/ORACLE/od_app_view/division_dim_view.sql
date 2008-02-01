/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : division_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Division Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.division_dim_view
   (sap_division_code,
    division_desc) as
   select t01.sap_division_code,
          t01.division_desc
     from division t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.division_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym division_dim_view for od_app.division_dim_view;
