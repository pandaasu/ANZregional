/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : uom_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Unit Of Measure Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.uom_dim_view
   (sap_uom_code,
    uom_abbrd_desc,
    uom_desc,
    uom_dim) as
   select t01.sap_uom_code,
          t01.uom_abbrd_desc,
          t01.uom_desc,
          t01.uom_dim
     from uom t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.uom_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym uom_dim_view for od_app.uom_dim_view;