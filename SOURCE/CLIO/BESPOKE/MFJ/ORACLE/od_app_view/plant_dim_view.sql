/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : plant_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Plant Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.plant_dim_view
   (sap_plant_code,
    plant_desc) as
   select t01.sap_plant_code,
          t01.plant_desc
     from plant t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.plant_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym plant_dim_view for od_app.plant_dim_view;