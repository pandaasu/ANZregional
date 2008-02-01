/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 View    : sales_01_mart_det
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Sales Mart 01 Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created

*******************************************************************************/

/**/
/* View creation
/**/
create or replace force view dds.sales_01_mart_det as
   select t01.*,
          t02.cyr_maa_inv_value,
          t02.cyr_yee_variance,
          t02.nyr_yee_variance
     from --
          -- Data mart fields aggregated to primary keys
          --
          (select t01.company_code,
                  t01.matl_code,
                  t01.demand_plng_grp_code,
                  t01.data_type,
                  sum(t01.lyr_yte_inv_value) as lyr_yte_inv_value,
                  sum(t01.cyr_ytd_inv_value) as cyr_ytd_inv_value,
                  sum(t01.cyr_ytw_inv_value) as cyr_ytw_inv_value,
                  sum(t01.cyr_mat_inv_value) as cyr_mat_inv_value,
                  sum(t01.cyr_yte_op_value) as cyr_yte_op_value,
                  sum(t01.cyr_yte_rob_value) as cyr_yte_rob_value,
                  sum(t01.cyr_ytg_br_value) as cyr_ytg_br_value,
                  sum(t01.cyr_ytg_fcst_value) as cyr_ytg_fcst_value,
                  sum(t01.nyr_yte_br_value) as nyr_yte_br_value,
                  sum(t01.nyr_yte_fcst_value) as nyr_yte_fcst_value,
                  sum(t01.cyr_yee_inv_fcst_value) as cyr_yee_inv_fcst_value,
                  sum(t01.cyr_yee_inv_br_value) as cyr_yee_inv_br_value,
                  sum(t01.p01_value) as p01_value,
                  sum(t01.p02_value) as p02_value,
                  sum(t01.p03_value) as p03_value,
                  sum(t01.p04_value) as p04_value,
                  sum(t01.p05_value) as p05_value,
                  sum(t01.p06_value) as p06_value,
                  sum(t01.p07_value) as p07_value,
                  sum(t01.p08_value) as p08_value,
                  sum(t01.p09_value) as p09_value,
                  sum(t01.p10_value) as p10_value,
                  sum(t01.p11_value) as p11_value,
                  sum(t01.p12_value) as p12_value,
                  sum(t01.p13_value) as p13_value,
                  sum(t01.p14_value) as p14_value,
                  sum(t01.p15_value) as p15_value,
                  sum(t01.p16_value) as p16_value,
                  sum(t01.p17_value) as p17_value,
                  sum(t01.p18_value) as p18_value,
                  sum(t01.p19_value) as p19_value,
                  sum(t01.p20_value) as p20_value,
                  sum(t01.p21_value) as p21_value,
                  sum(t01.p22_value) as p22_value,
                  sum(t01.p23_value) as p23_value,
                  sum(t01.p24_value) as p24_value,
                  sum(t01.p25_value) as p25_value,
                  sum(t01.p26_value) as p26_value,
                  sum(t01.p27_value) as p27_value 
             from sales_01_mart_t02 t01
            group by t01.company_code,
                     t01.matl_code,
                     t01.demand_plng_grp_code,
                     t01.data_type) t01,
          --
          -- Data mart calculations aggregated to primary keys
          --
          (select t01.company_code,
                  t01.matl_code,
                  t01.demand_plng_grp_code,
                  t01.data_type,
                  sum(cyr_mat_inv_value) / 52 as cyr_maa_inv_value,
                  sum(cyr_yee_inv_fcst_value) - sum(cyr_yee_inv_br_value) as cyr_yee_variance,
                  sum(nyr_yte_fcst_value) - sum(nyr_yte_br_value) as nyr_yee_variance
             from sales_01_mart_t02 t01
            group by t01.company_code,
                     t01.matl_code,
                     t01.demand_plng_grp_code,
                     t01.data_type) t02
    --
    -- Data mart join - fields/calculations
    --
    where t01.company_code = t02.company_code
      and t01.matl_code = t02.matl_code
      and t01.demand_plng_grp_code = t02.demand_plng_grp_code
      and t01.data_type = t02.data_type;

/*-*/
/* Authority
/*-*/
grant select on sales_01_mart_det to public with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sales_01_mart_det for dds.sales_01_mart_det;