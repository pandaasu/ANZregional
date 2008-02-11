/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : cust_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 ----------- 
 Operational Data Store - Customer Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.cust_dim_view as
  select t01.kunnr as cust_code,                                  -- SAP Customer Code 
    t02.name as cust_name_en,                                     -- Customer Name EN 
    t02.sort1 as addr_sort_en,                                    -- Address Sort EN 
    t02.city as addr_city_en,                                     -- Address City EN 
    t02.pcode as addr_postl_code_en,                              -- Address Postal Code EN 
    t02.region as addr_regn_code_en,                              -- SAP Address Region Code 
    t02.country as cntry_code_en,                                 -- SAP Address Country Code 
    t01.ktokd as cust_acct_grp_code,                              -- SAP Customer Account Group Code 
    null as cust_acct_grp_desc,                                   -- Customer Account Group Description (Not Loaded) 
    t03.sap_pos_place_code as pos_place_code,                     -- SAP POS Place Code 
    t09.sap_pos_place_desc as pos_place_desc,                     -- POS Place Description 
    t03.sap_pos_format_code as pos_format_code,                   -- SAP POS Format Code 
    t10.sap_pos_format_desc as pos_format_desc,                   -- POS Format Description 
    t03.sap_pos_format_grpg_code as pos_format_grpg_code,         -- SAP POS Format Grouping Code 
    t03.sap_multi_mkt_acct_code as multi_mkt_acct_code,           -- SAP Multi-Market Account Code 
    t05.sap_banner_code as banner_code,                           -- SAP Banner Code 
    t04.sap_cust_group_code as cust_buying_grp_code,              -- SAP Customer Buying Group Code 
    t03.sap_cntry_regn_code as cntry_regn_code,                   -- SAP Country Region Code 
    t07.ods_cntry_region_desc as cntry_regn_desc,                 -- Country Region Description 
    t06.sap_loc_type_code as distbn_route_code,                   -- SAP Distribution Route Code 
    t03.sap_prim_route_to_cnsmr_code as prim_route_to_cnsmr_code, -- SAP Primary Route to Consumer Code 
    t08.sap_prim_route_to_cnsmr_desc as prim_route_to_cnsmr_desc  -- SAP Primary Route to Consumer Description 
  from sap_cus_hdr t01,
  (select t21.obj_id as kunnr,
      t22.name as name,
      t22.sort1 as sort1,
      t22.city as city,
      t22.postl_cod1 as pcode,
      t22.street as street,
      t22.house_no as house_no,
      t22.country as country,
      t22.transpzone as transpzone,
      t22.region
    from sap_adr_hdr t21,
      sap_adr_det t22
    where t21.obj_type = t22.obj_type(+)
      and t21.obj_id = t22.obj_id(+)
      and t21.context = t22.context(+)
      and t21.valdtn_status = 'VALID'
      and t21.obj_type = 'KNA1'
      and t21.context = '0001'
      and t22.addr_vers is null) t02,
  (select t21.objek as kunnr,
      max(case when t22.atnam = 'CLFFERT36' then t22.atwrt end) as sap_cust_group_code,             -- Customer Buying Group 
      max(case when t22.atnam = 'CLFFERT104' then t22.atwrt end) as sap_banner_code,                -- Banner 
      max(case when t22.atnam = 'CLFFERT106' then t22.atwrt end) as sap_loc_type_code,              -- Distribtuion Route 
      max(case when t22.atnam = 'CLFFERT41' then t22.atwrt end) as sap_pos_format_grpg_code,        -- POS Format Grouping 
      max(case when t22.atnam = 'CLFFERT37' then t22.atwrt end) as sap_multi_mkt_acct_code,         -- Multi-Market Account 
      max(case when t22.atnam = 'CLFFERT107' then t22.atwrt end) as sap_prim_route_to_cnsmr_code,   -- Primary Route To Consumer Code/Desc 
      max(case when t22.atnam = 'CLFFERT109' then t22.atwrt end) as sap_cntry_regn_code,            -- Country Region 
      max(case when t22.atnam = 'CLFFERT101' then t22.atwrt end) as sap_pos_format_code,            -- POS Format 
      max(case when t22.atnam = 'CLFFERT103' then t22.atwrt end) as sap_pos_place_code              -- POS Place 
    from sap_cla_hdr t21,
      sap_cla_chr t22              
    where t21.obtab = 'KNA1'
      and t21.klart = '011'
      and t21.obtab = t22.obtab(+)
      and t21.klart = t22.klart(+)
      and t21.objek = t22.objek(+)
      group by t21.objek) t03,
  (select t01.atwrt as sap_cust_group_code,
      t02.atwtb as sap_cust_group_desc
    from sap_chr_mas_val t01,
      sap_chr_mas_dsc t02
    where t01.atnam = t02.atnam(+)
      and t01.valseq = t02.valseq(+)
      and t01.atnam = 'CLFFERT36'
      and t02.spras = 'E') t04,
  (select t01.atwrt as sap_banner_code,
      t02.atwtb as sap_banner_desc
    from sap_chr_mas_val t01,
      sap_chr_mas_dsc t02
    where t01.atnam = t02.atnam(+)
      and t01.valseq = t02.valseq(+)
      and t01.atnam = 'CLFFERT104'
      and t02.spras = 'E') t05,
  (select t01.atwrt as sap_loc_type_code,
      t02.atwtb as sap_loc_type_desc
    from sap_chr_mas_val t01,
      sap_chr_mas_dsc t02
    where t01.atnam = t02.atnam(+)
      and t01.valseq = t02.valseq(+)
      and t01.atnam = 'CLFFERT106'
      and t02.spras = 'E') t06,
  (select t01.cntry_region_code as ods_cntry_region_code,
      t01.cntry_region_desc as ods_cntry_region_desc
    from cntry_region t01
    where t01.cntry_region_lang = 'E') t07,
  (select t01.atwrt as sap_prim_route_to_cnsmr_code,
      t02.atwtb as sap_prim_route_to_cnsmr_desc
    from sap_chr_mas_val t01,
      sap_chr_mas_dsc t02
    where t01.atnam = t02.atnam(+)
      and t01.valseq = t02.valseq(+)
      and t01.atnam = 'CLFFERT107'
      and t02.spras = 'E') t08,
  (select t01.atwrt as sap_pos_place_code,
      t02.atwtb as sap_pos_place_desc
    from sap_chr_mas_val t01,
      sap_chr_mas_dsc t02
    where t01.atnam = t02.atnam(+)
      and t01.valseq = t02.valseq(+)
      and t01.atnam = 'CLFFERT103'
      and t02.spras = 'E') t09,  -- POS Place Description 
  (select t01.atwrt as sap_pos_format_code,
      t02.atwtb as sap_pos_format_desc
    from sap_chr_mas_val t01,
      sap_chr_mas_dsc t02
    where t01.atnam = t02.atnam(+)
      and t01.valseq = t02.valseq(+)
      and t01.atnam = 'CLFFERT101'
      and t02.spras = 'E') t10  -- POS Format Description 
  where t01.kunnr = t02.kunnr(+)
    and t01.kunnr = t03.kunnr(+)
    and t03.sap_cust_group_code = t04.sap_cust_group_code(+)
    and t03.sap_banner_code = t05.sap_banner_code(+)
    and t03.sap_loc_type_code = t06.sap_loc_type_code(+)
    and t03.sap_cntry_regn_code = t07.ods_cntry_region_code(+)
    and t03.sap_prim_route_to_cnsmr_code = t08.sap_prim_route_to_cnsmr_code(+)
    and t03.sap_pos_place_code = t09.sap_pos_place_code(+)
    and t03.sap_pos_format_code = t10.sap_pos_format_code(+)
    and t01.valdtn_status = 'VALID';

/*-*/
/* Authority 
/*-*/
grant select on ods_app.cust_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym cust_dim_view for ods_app.cust_dim_view;
