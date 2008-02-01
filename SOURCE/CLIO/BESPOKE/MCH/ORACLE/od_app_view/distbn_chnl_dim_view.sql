/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : distbn_chnl_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Distribution Channel Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.distbn_chnl_dim_view
   (sap_distbn_chnl_code,
    distbn_chnl_desc) as
   select t01.sap_distbn_chnl_code,
          t01.distbn_chnl_desc
     from distbn_chnl t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.distbn_chnl_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym distbn_chnl_dim_view for od_app.distbn_chnl_dim_view;