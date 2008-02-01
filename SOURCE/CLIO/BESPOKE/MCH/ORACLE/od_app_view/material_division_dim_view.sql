/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_division_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Material Division Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.material_division_dim_view
   (sap_material_division_code,
    material_division_desc) as
   select t01.sap_material_division_code,
          t01.material_division_desc
     from material_division t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.material_division_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym material_division_dim_view for od_app.material_division_dim_view;
