/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dw_mart_sales01_wrk
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Mart Sales 01 Work

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/10  Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dw_mart_sales01_wrk
   (company_code varchar2(6 char) null,
    data_segment varchar2(32 char) null,
    matl_group varchar2(20 char) null,
    ship_to_cust_code varchar2(10 char) null,
    matl_code varchar2(18 char) null,
    acct_assgnmnt_grp_code varchar2(10 char) null,
    demand_plng_grp_code varchar2(10 char) null,
    mfanz_icb_flag varchar2(10 char) null,
    data_type varchar2(10 char) null,
    cdy_ord_value number null,
    cdy_inv_value number null,
    ptd_inv_value number null,
    ptw_inv_value number null,
    ptg_fcst_value number null,
    cpd_out_value number null,
    cpd_ord_value number null,
    cpd_inv_value number null,
    cpd_op_value number null,
    cpd_rob_value number null,
    cpd_br_value number null,
    cpd_brm1_value number null,
    lpd_brm1_value number null,
    cpd_brm2_value number null,
    cpd_fcst_value number null,
    lpd_inv_value number null,
    fpd_out_value number null,
    fpd_ord_value number null,
    fpd_inv_value number null,
    lyr_cpd_inv_value number null,
    lyr_lpd_inv_value number null,
    lyr_ytp_inv_value number null,
    lyr_yee_inv_value number null,
    lyrm1_yee_inv_value number null,
    lyrm2_yee_inv_value number null,
    cyr_ytp_inv_value number null,
    cyr_mat_inv_value number null,
    cyr_ytg_rob_value number null,
    cyr_ytg_br_value number null,
    cyr_ytg_fcst_value number null,
    cyr_yee_op_value number null,
    cyr_yee_rob_value number null,
    cyr_yee_br_value number null,
    cyr_yee_brm1_value number null,
    cyr_yee_brm2_value number null,
    cyr_yee_fcst_value number null,
    nyr_yee_br_value number null,
    nyr_yee_brm1_value number null,
    nyr_yee_brm2_value number null,
    nyr_yee_fcst_value number null,
    p01_lyr_value number null,
    p02_lyr_value number null,
    p03_lyr_value number null,
    p04_lyr_value number null,
    p05_lyr_value number null,
    p06_lyr_value number null,
    p07_lyr_value number null,
    p08_lyr_value number null,
    p09_lyr_value number null,
    p10_lyr_value number null,
    p11_lyr_value number null,
    p12_lyr_value number null,
    p13_lyr_value number null,
    p01_op_value number null,
    p02_op_value number null,
    p03_op_value number null,
    p04_op_value number null,
    p05_op_value number null,
    p06_op_value number null,
    p07_op_value number null,
    p08_op_value number null,
    p09_op_value number null,
    p10_op_value number null,
    p11_op_value number null,
    p12_op_value number null,
    p13_op_value number null,
    p01_rob_value number null,
    p02_rob_value number null,
    p03_rob_value number null,
    p04_rob_value number null,
    p05_rob_value number null,
    p06_rob_value number null,
    p07_rob_value number null,
    p08_rob_value number null,
    p09_rob_value number null,
    p10_rob_value number null,
    p11_rob_value number null,
    p12_rob_value number null,
    p13_rob_value number null,
    p01_br_value number null,
    p02_br_value number null,
    p03_br_value number null,
    p04_br_value number null,
    p05_br_value number null,
    p06_br_value number null,
    p07_br_value number null,
    p08_br_value number null,
    p09_br_value number null,
    p10_br_value number null,
    p11_br_value number null,
    p12_br_value number null,
    p13_br_value number null,
    p14_br_value number null,
    p15_br_value number null,
    p16_br_value number null,
    p17_br_value number null,
    p18_br_value number null,
    p19_br_value number null,
    p20_br_value number null,
    p21_br_value number null,
    p22_br_value number null,
    p23_br_value number null,
    p24_br_value number null,
    p25_br_value number null,
    p26_br_value number null,
    p01_brm1_value number null,
    p02_brm1_value number null,
    p03_brm1_value number null,
    p04_brm1_value number null,
    p05_brm1_value number null,
    p06_brm1_value number null,
    p07_brm1_value number null,
    p08_brm1_value number null,
    p09_brm1_value number null,
    p10_brm1_value number null,
    p11_brm1_value number null,
    p12_brm1_value number null,
    p13_brm1_value number null,
    p14_brm1_value number null,
    p15_brm1_value number null,
    p16_brm1_value number null,
    p17_brm1_value number null,
    p18_brm1_value number null,
    p19_brm1_value number null,
    p20_brm1_value number null,
    p21_brm1_value number null,
    p22_brm1_value number null,
    p23_brm1_value number null,
    p24_brm1_value number null,
    p25_brm1_value number null,
    p26_brm1_value number null,
    p01_brm2_value number null,
    p02_brm2_value number null,
    p03_brm2_value number null,
    p04_brm2_value number null,
    p05_brm2_value number null,
    p06_brm2_value number null,
    p07_brm2_value number null,
    p08_brm2_value number null,
    p09_brm2_value number null,
    p10_brm2_value number null,
    p11_brm2_value number null,
    p12_brm2_value number null,
    p13_brm2_value number null,
    p14_brm2_value number null,
    p15_brm2_value number null,
    p16_brm2_value number null,
    p17_brm2_value number null,
    p18_brm2_value number null,
    p19_brm2_value number null,
    p20_brm2_value number null,
    p21_brm2_value number null,
    p22_brm2_value number null,
    p23_brm2_value number null,
    p24_brm2_value number null,
    p25_brm2_value number null,
    p26_brm2_value number null,
    p01_fcst_value number null,
    p02_fcst_value number null,
    p03_fcst_value number null,
    p04_fcst_value number null,
    p05_fcst_value number null,
    p06_fcst_value number null,
    p07_fcst_value number null,
    p08_fcst_value number null,
    p09_fcst_value number null,
    p10_fcst_value number null,
    p11_fcst_value number null,
    p12_fcst_value number null,
    p13_fcst_value number null,
    p14_fcst_value number null,
    p15_fcst_value number null,
    p16_fcst_value number null,
    p17_fcst_value number null,
    p18_fcst_value number null,
    p19_fcst_value number null,
    p20_fcst_value number null,
    p21_fcst_value number null,
    p22_fcst_value number null,
    p23_fcst_value number null,
    p24_fcst_value number null,
    p25_fcst_value number null,
    p26_fcst_value number null)
   partition by list (company_code)
      (partition C147 VALUES ('147'),
       partition C149 VALUES ('149'));

/**/
/* Comments
/**/
comment on table dw_mart_sales01_wrk is 'Mart Sales 01 Work Table';
comment on column dw_mart_sales01_wrk.company_code is 'Company code';
comment on column dw_mart_sales01_wrk.data_segment is 'Data segment';
comment on column dw_mart_sales01_wrk.matl_group is 'Material group - *ALL or group code';
comment on column dw_mart_sales01_wrk.ship_to_cust_code is 'Ship to customer code';
comment on column dw_mart_sales01_wrk.matl_code is 'Material code';
comment on column dw_mart_sales01_wrk.acct_assgnmnt_grp_code is 'Account assignment group code';
comment on column dw_mart_sales01_wrk.demand_plng_grp_code is 'Demand planning group code';
comment on column dw_mart_sales01_wrk.mfanz_icb_flag is 'MFANZ ICB flag';
comment on column dw_mart_sales01_wrk.data_type is 'Data type - *QTY, *TON, *GSV';
comment on column dw_mart_sales01_wrk.cdy_ord_value is 'Current day - ordered value';
comment on column dw_mart_sales01_wrk.cdy_inv_value is 'Current day - invoiced value';
comment on column dw_mart_sales01_wrk.ptd_inv_value is 'Period to date - invoiced value';
comment on column dw_mart_sales01_wrk.ptw_inv_value is 'Period to week - invoiced value';
comment on column dw_mart_sales01_wrk.ptg_fcst_value is 'Period to go - forecast value';
comment on column dw_mart_sales01_wrk.cpd_out_value is 'Current period - outstanding value';
comment on column dw_mart_sales01_wrk.cpd_ord_value is 'Current period - order delivered value';
comment on column dw_mart_sales01_wrk.cpd_inv_value is 'Current period - invoiced value';
comment on column dw_mart_sales01_wrk.cpd_op_value is 'Current period - operating plan value';
comment on column dw_mart_sales01_wrk.cpd_rob_value is 'Current period - review of business value';
comment on column dw_mart_sales01_wrk.cpd_br_value is 'Current period - business review value';
comment on column dw_mart_sales01_wrk.cpd_brm1_value is 'Current period - business review minus 1 value';
comment on column dw_mart_sales01_wrk.lpd_brm1_value is 'Last period - business review minus 1 value';
comment on column dw_mart_sales01_wrk.cpd_brm2_value is 'Current period - business review minus 2 value';
comment on column dw_mart_sales01_wrk.cpd_fcst_value is 'Current period - forecast value';
comment on column dw_mart_sales01_wrk.lpd_inv_value is 'Last period - invoiced value';
comment on column dw_mart_sales01_wrk.fpd_out_value is 'Future periods - outstanding value';
comment on column dw_mart_sales01_wrk.fpd_ord_value is 'Future periods - order delivered value';
comment on column dw_mart_sales01_wrk.fpd_inv_value is 'Future periods - invoice delivered value';
comment on column dw_mart_sales01_wrk.lyr_cpd_inv_value is 'Last year - current period - invoiced value';
comment on column dw_mart_sales01_wrk.lyr_lpd_inv_value is 'Last year - last period - invoiced value';
comment on column dw_mart_sales01_wrk.lyr_ytp_inv_value is 'Last year - year to period - invoiced value';
comment on column dw_mart_sales01_wrk.lyr_yee_inv_value is 'Last year - year end estimate - invoiced value';
comment on column dw_mart_sales01_wrk.lyrm1_yee_inv_value is 'Last year minus 1 - year end estimate - invoiced value';
comment on column dw_mart_sales01_wrk.lyrm2_yee_inv_value is 'Last year minus 2 - year end estimate - invoiced value';
comment on column dw_mart_sales01_wrk.cyr_ytp_inv_value is 'Current year - year to period - invoiced value';
comment on column dw_mart_sales01_wrk.cyr_mat_inv_value is 'Current year - moving annual total - invoiced value';
comment on column dw_mart_sales01_wrk.cyr_ytg_rob_value is 'Current year - year to go - review of business value';
comment on column dw_mart_sales01_wrk.cyr_ytg_br_value is 'Current year - year to go - business review value';
comment on column dw_mart_sales01_wrk.cyr_ytg_fcst_value is 'Current year - year to go - forecast value';
comment on column dw_mart_sales01_wrk.cyr_yee_op_value is 'Current year - year end estimate - operating plan';
comment on column dw_mart_sales01_wrk.cyr_yee_rob_value is 'Current year - year end estimate - review of business';
comment on column dw_mart_sales01_wrk.cyr_yee_br_value is 'Current year - year end estimate - business review value';
comment on column dw_mart_sales01_wrk.cyr_yee_brm1_value is 'Current year - year end estimate - business review minus 1 value';
comment on column dw_mart_sales01_wrk.cyr_yee_brm2_value is 'Current year - year end estimate - business review minus 2 value';
comment on column dw_mart_sales01_wrk.cyr_yee_fcst_value is 'Current year - year end estimate - forecast value';
comment on column dw_mart_sales01_wrk.nyr_yee_br_value is 'Next year - year end estimate - business review value';
comment on column dw_mart_sales01_wrk.nyr_yee_brm1_value is 'Next year - year end estimate - business review minus 1 value';
comment on column dw_mart_sales01_wrk.nyr_yee_brm2_value is 'Next year - year end estimate - business review minus 2 value';
comment on column dw_mart_sales01_wrk.nyr_yee_fcst_value is 'Next year - year end estimate - forecast value';
comment on column dw_mart_sales01_wrk.p01_lyr_value is 'P01 Last year value';
comment on column dw_mart_sales01_wrk.p02_lyr_value is 'P02 Last year value';
comment on column dw_mart_sales01_wrk.p03_lyr_value is 'P03 Last year value';
comment on column dw_mart_sales01_wrk.p04_lyr_value is 'P04 Last year value';
comment on column dw_mart_sales01_wrk.p05_lyr_value is 'P05 Last year value';
comment on column dw_mart_sales01_wrk.p06_lyr_value is 'P06 Last year value';
comment on column dw_mart_sales01_wrk.p07_lyr_value is 'P07 Last year value';
comment on column dw_mart_sales01_wrk.p08_lyr_value is 'P08 Last year value';
comment on column dw_mart_sales01_wrk.p09_lyr_value is 'P09 Last year value';
comment on column dw_mart_sales01_wrk.p10_lyr_value is 'P10 Last year value';
comment on column dw_mart_sales01_wrk.p11_lyr_value is 'P11 Last year value';
comment on column dw_mart_sales01_wrk.p12_lyr_value is 'P12 Last year value';
comment on column dw_mart_sales01_wrk.p13_lyr_value is 'P13 Last year value';
comment on column dw_mart_sales01_wrk.p01_op_value is 'P01 OP value';
comment on column dw_mart_sales01_wrk.p02_op_value is 'P02 OP value';
comment on column dw_mart_sales01_wrk.p03_op_value is 'P03 OP value';
comment on column dw_mart_sales01_wrk.p04_op_value is 'P04 OP value';
comment on column dw_mart_sales01_wrk.p05_op_value is 'P05 OP value';
comment on column dw_mart_sales01_wrk.p06_op_value is 'P06 OP value';
comment on column dw_mart_sales01_wrk.p07_op_value is 'P07 OP value';
comment on column dw_mart_sales01_wrk.p08_op_value is 'P08 OP value';
comment on column dw_mart_sales01_wrk.p09_op_value is 'P09 OP value';
comment on column dw_mart_sales01_wrk.p10_op_value is 'P10 OP value';
comment on column dw_mart_sales01_wrk.p11_op_value is 'P11 OP value';
comment on column dw_mart_sales01_wrk.p12_op_value is 'P12 OP value';
comment on column dw_mart_sales01_wrk.p13_op_value is 'P13 OP value';
comment on column dw_mart_sales01_wrk.p01_rob_value is 'P01 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p02_rob_value is 'P02 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p03_rob_value is 'P03 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p04_rob_value is 'P04 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p05_rob_value is 'P05 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p06_rob_value is 'P06 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p07_rob_value is 'P07 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p08_rob_value is 'P08 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p09_rob_value is 'P09 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p10_rob_value is 'P10 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p11_rob_value is 'P11 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p12_rob_value is 'P12 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p13_rob_value is 'P13 ACT/ROB value';
comment on column dw_mart_sales01_wrk.p01_br_value is 'P01 ACT/BR value';
comment on column dw_mart_sales01_wrk.p02_br_value is 'P02 ACT/BR value';
comment on column dw_mart_sales01_wrk.p03_br_value is 'P03 ACT/BR value';
comment on column dw_mart_sales01_wrk.p04_br_value is 'P04 ACT/BR value';
comment on column dw_mart_sales01_wrk.p05_br_value is 'P05 ACT/BR value';
comment on column dw_mart_sales01_wrk.p06_br_value is 'P06 ACT/BR value';
comment on column dw_mart_sales01_wrk.p07_br_value is 'P07 ACT/BR value';
comment on column dw_mart_sales01_wrk.p08_br_value is 'P08 ACT/BR value';
comment on column dw_mart_sales01_wrk.p09_br_value is 'P09 ACT/BR value';
comment on column dw_mart_sales01_wrk.p10_br_value is 'P10 ACT/BR value';
comment on column dw_mart_sales01_wrk.p11_br_value is 'P11 ACT/BR value';
comment on column dw_mart_sales01_wrk.p12_br_value is 'P12 ACT/BR value';
comment on column dw_mart_sales01_wrk.p13_br_value is 'P13 ACT/BR value';
comment on column dw_mart_sales01_wrk.p14_br_value is 'P14 ACT/BR value';
comment on column dw_mart_sales01_wrk.p15_br_value is 'P15 ACT/BR value';
comment on column dw_mart_sales01_wrk.p16_br_value is 'P16 ACT/BR value';
comment on column dw_mart_sales01_wrk.p17_br_value is 'P17 ACT/BR value';
comment on column dw_mart_sales01_wrk.p18_br_value is 'P18 ACT/BR value';
comment on column dw_mart_sales01_wrk.p19_br_value is 'P19 ACT/BR value';
comment on column dw_mart_sales01_wrk.p20_br_value is 'P20 ACT/BR value';
comment on column dw_mart_sales01_wrk.p21_br_value is 'P21 ACT/BR value';
comment on column dw_mart_sales01_wrk.p22_br_value is 'P22 ACT/BR value';
comment on column dw_mart_sales01_wrk.p23_br_value is 'P23 ACT/BR value';
comment on column dw_mart_sales01_wrk.p24_br_value is 'P24 ACT/BR value';
comment on column dw_mart_sales01_wrk.p25_br_value is 'P25 ACT/BR value';
comment on column dw_mart_sales01_wrk.p26_br_value is 'P26 ACT/BR value';
comment on column dw_mart_sales01_wrk.p01_brm1_value is 'P01 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p02_brm1_value is 'P02 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p03_brm1_value is 'P03 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p04_brm1_value is 'P04 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p05_brm1_value is 'P05 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p06_brm1_value is 'P06 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p07_brm1_value is 'P07 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p08_brm1_value is 'P08 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p09_brm1_value is 'P09 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p10_brm1_value is 'P10 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p11_brm1_value is 'P11 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p12_brm1_value is 'P12 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p13_brm1_value is 'P13 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p14_brm1_value is 'P14 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p15_brm1_value is 'P15 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p16_brm1_value is 'P16 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p17_brm1_value is 'P17 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p18_brm1_value is 'P18 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p19_brm1_value is 'P19 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p20_brm1_value is 'P20 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p21_brm1_value is 'P21 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p22_brm1_value is 'P22 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p23_brm1_value is 'P23 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p24_brm1_value is 'P24 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p25_brm1_value is 'P25 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p26_brm1_value is 'P26 ACT/BR minus 1 value';
comment on column dw_mart_sales01_wrk.p01_brm2_value is 'P01 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p02_brm2_value is 'P02 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p03_brm2_value is 'P03 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p04_brm2_value is 'P04 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p05_brm2_value is 'P05 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p06_brm2_value is 'P06 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p07_brm2_value is 'P07 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p08_brm2_value is 'P08 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p09_brm2_value is 'P09 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p10_brm2_value is 'P10 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p11_brm2_value is 'P11 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p12_brm2_value is 'P12 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p13_brm2_value is 'P13 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p14_brm2_value is 'P14 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p15_brm2_value is 'P15 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p16_brm2_value is 'P16 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p17_brm2_value is 'P17 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p18_brm2_value is 'P18 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p19_brm2_value is 'P19 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p20_brm2_value is 'P20 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p21_brm2_value is 'P21 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p22_brm2_value is 'P22 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p23_brm2_value is 'P23 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p24_brm2_value is 'P24 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p25_brm2_value is 'P25 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p26_brm2_value is 'P26 ACT/BR minus 2 value';
comment on column dw_mart_sales01_wrk.p01_fcst_value is 'P01 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p02_fcst_value is 'P02 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p03_fcst_value is 'P03 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p04_fcst_value is 'P04 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p05_fcst_value is 'P05 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p06_fcst_value is 'P06 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p07_fcst_value is 'P07 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p08_fcst_value is 'P08 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p09_fcst_value is 'P09 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p10_fcst_value is 'P10 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p11_fcst_value is 'P11 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p12_fcst_value is 'P12 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p13_fcst_value is 'P13 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p14_fcst_value is 'P14 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p15_fcst_value is 'P15 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p16_fcst_value is 'P16 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p17_fcst_value is 'P17 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p18_fcst_value is 'P18 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p19_fcst_value is 'P19 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p20_fcst_value is 'P20 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p21_fcst_value is 'P21 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p22_fcst_value is 'P22 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p23_fcst_value is 'P23 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p24_fcst_value is 'P24 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p25_fcst_value is 'P25 ACT/FCST value';
comment on column dw_mart_sales01_wrk.p26_fcst_value is 'P26 ACT/FCST value';

/**/
/* Authority
/**/
grant select, insert, update, delete on dw_mart_sales01_wrk to dw_app;

/**/
/* Synonym
/**/
create or replace public synonym dw_mart_sales01_wrk for dds.dw_mart_sales01_wrk;
