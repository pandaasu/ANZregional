/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cust_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Customer Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.cust_dim_view
   (sap_cust_code,
    cust_name_en,
    addr_sort_en,
    addr_street_en,
    addr_city_en,
    addr_postl_code_en,
    sap_addr_regn_code_en,
    addr_regn_desc_en,
    addr_time_zone_en,
    sap_lang_code_en,
    lang_desc_en,
    sap_cntry_code_en,
    cntry_desc_en,
    cust_name_ja, 
    addr_sort_ja,
    addr_street_ja,
    addr_city_ja,
    addr_postl_code_ja,
    sap_addr_regn_code_ja,
    addr_regn_desc_ja,
    addr_time_zone_ja,
    sap_lang_code_ja,
    lang_desc_ja,
    sap_cntry_code_ja,
    cntry_desc_ja,
    sap_cust_distbn_role_code,
    cust_distbn_role_abbrd_desc,
    cust_distbn_role_desc,
    sap_cust_acct_grp_code,
    cust_acct_grp_desc,
    grp_key) as
   select t01.sap_cust_code,
          t02.addr_name as cust_name_en,
          t02.addr_sort as addr_sort_en,
          t02.addr_street as addr_street_en,
          t02.addr_city as addr_city_en,
          t02.addr_postl_code as addr_postl_code_en,
          t02.sap_addr_regn_code as sap_addr_regn_code_en,
          t02.addr_regn_desc as addr_regn_desc_en,
          t02.addr_time_zone as addr_time_zone_en,
          t02.sap_lang_code as sap_lang_code_en,
          t02.lang_desc as lang_desc_en,
          t02.sap_cntry_code as sap_cntry_code_en,
          t02.cntry_desc as cntry_desc_en,
          t03.addr_name as cust_name_ja,
          t03.addr_sort as addr_sort_ja,
          t03.addr_street as addr_street_ja,
          t03.addr_city as addr_city_ja,
          t03.addr_postl_code as addr_postl_code_ja,
          t03.sap_addr_regn_code as sap_addr_regn_code_ja,
          t03.addr_regn_desc as addr_regn_desc_ja,
          t03.addr_time_zone as addr_time_zone_ja,
          t03.sap_lang_code as sap_lang_code_ja,
          t03.lang_desc as lang_desc_ja,
          t03.sap_cntry_code as sap_cntry_code_ja,
          t03.cntry_desc as cntry_desc_ja,
          t04.sap_cust_distbn_role_code,
          t04.cust_distbn_role_abbrd_desc,
          t04.cust_distbn_role_desc,
          t05.sap_cust_acct_grp_code,
          t05.cust_acct_grp_desc,
          t01.grp_key
     from cust t01,
          (select t21.sap_cust_vendor_code sap_cust_code,
                  t21.addr_name,
                  t21.addr_sort,
                  t21.addr_street,
                  t21.addr_city,
                  t21.addr_postl_code,
                  t23.sap_addr_regn_code,
                  t23.addr_regn_desc,
                  t21.addr_time_zone,
                  t22.sap_lang_code,
                  t22.lang_desc,
                  t24.sap_cntry_code,
                  t24.cntry_desc
             from address t21,
                  language t22,
                  address_regn t23,
                  country t24
            where t21.sap_addr_lang_code = t22.sap_lang_code
              and t21.sap_addr_type_code = 'KNA1'
              and t21.sap_addr_context_code = '0001'
              and t21.sap_addr_regn_code = t23.sap_addr_regn_code(+)
              and t21.sap_addr_cntry_code = t24.sap_cntry_code
              and t21.addr_vrsn is null) t02,
          (select t31.sap_cust_vendor_code sap_cust_code,
                  t31.addr_name,
                  t31.addr_sort,
                  t31.addr_street,
                  t31.addr_city,
                  t31.addr_postl_code,
                  t33.sap_addr_regn_code,
                  t33.addr_regn_desc,
                  t31.addr_time_zone,
                  t32.sap_lang_code,
                  t32.lang_desc,
                  t34.sap_cntry_code,
                  t34.cntry_desc
             from address t31,
                  language t32,
                  address_regn t33,
                  country t34
            where t31.sap_addr_lang_code = t32.sap_lang_code
              and t31.sap_addr_type_code = 'KNA1'
              and t31.sap_addr_context_code = '0001'
              and t31.sap_addr_regn_code = t33.sap_addr_regn_code(+)
              and t31.sap_addr_cntry_code = t34.sap_cntry_code
              and t31.addr_vrsn = 'K') t03,
          cust_distbn_role t04,
          cust_acct_grp t05
    where t01.sap_cust_code = t02.sap_cust_code(+)
      and t01.sap_cust_code = t03.sap_cust_code(+)
      and t01.sap_cust_distbn_role_code = t04.sap_cust_distbn_role_code(+)
      and t01.sap_cust_acct_grp_code = t05.sap_cust_acct_grp_code;

/*-*/
/* Authority
/*-*/
grant select on od_app.cust_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym cust_dim_view for od_app.cust_dim_view;


