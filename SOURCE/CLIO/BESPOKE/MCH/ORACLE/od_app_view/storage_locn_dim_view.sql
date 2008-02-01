/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : storage_locn_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Storage Location Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.storage_locn_dim_view
   (sap_storage_locn_code,
    storage_locn_desc) as
   select t01.sap_storage_locn_code,
          t01.storage_locn_desc 
     from storage_locn t01;

/*-*/
/* Authority
/*-*/
grant select on od_app.storage_locn_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym storage_locn_dim_view for od_app.storage_locn_dim_view;