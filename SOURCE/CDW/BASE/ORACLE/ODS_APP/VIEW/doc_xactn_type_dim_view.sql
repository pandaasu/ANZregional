/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : doc_xactn_type_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Document Transaction Type Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.doc_xactn_type_dim_view as
select doc_xactn_type_code, -- SAP Document Transaction Type Code 
  doc_xactn_type_desc       -- Document Transaction Type Description 
from doc_xactn_type;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.doc_xactn_type_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym doc_xactn_type_dim_view for ods_app.doc_xactn_type_dim_view;