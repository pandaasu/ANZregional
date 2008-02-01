/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : material_ms_bf_bsf_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Material Market Segment / Brand Flag / Brand Sub Flag Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.material_ms_bf_bsf_dim_view
   (sap_mkt_sgmnt_code,
    mkt_sgmnt_abbrd_desc,
    mkt_sgmnt_desc,
    sap_brand_flag_code,
    brand_flag_abbrd_desc,
    brand_flag_desc,
    sap_brand_sub_flag_code, 
    brand_sub_flag_abbrd_desc,
    brand_sub_flag_desc) as
   select distinct
          t01.sap_mkt_sgmnt_code,
          t01.mkt_sgmnt_abbrd_desc,
          t01.mkt_sgmnt_desc,
          t02.sap_brand_flag_code,
          t02.brand_flag_abbrd_desc,
          t02.brand_flag_desc,
          t03.sap_brand_sub_flag_code,
          t03.brand_sub_flag_abbrd_desc,
          t03.brand_sub_flag_desc
     from mkt_sgmnt t01,
          brand_flag t02,
          brand_sub_flag t03,
          material t04
    where t01.sap_mkt_sgmnt_code = t04.sap_mkt_sgmnt_code
      and t02.sap_brand_flag_code = t04.sap_brand_flag_code
      and t03.sap_brand_sub_flag_code = t04.sap_brand_sub_flag_code;

/*-*/
/* Authority
/*-*/
grant select on od_app.material_ms_bf_bsf_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym material_ms_bf_bsf_dim_view for od_app.material_ms_bf_bsf_dim_view;
