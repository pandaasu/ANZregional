/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dw_mart_sales01_det
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Mart Sales 01 Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/06   Steve Gregan   Created
 2008/08   Steve Gregan   Added ICB_FLAG
 2008/08   Steve Gregan   Added ship to customer
 2008/10   Steve Gregan   Added PTW/PTG/LYRM1/LYRM2/P01-26FCST/P01-26BR
 2009/05   Steve Gregan   Added measures

*******************************************************************************/

/**/
/* Table creation
/**/
create table dw_mart_sales01_det
   (company_code varchar2(6 char) not null,
    data_segment varchar2(32 char) not null,
    matl_group varchar2(20 char) not null,
    ship_to_cust_code varchar2(10 char) not null,
    matl_code varchar2(18 char) not null,
    acct_assgnmnt_grp_code varchar2(10 char) not null,
    demand_plng_grp_code varchar2(10 char) not null,
    mfanz_icb_flag varchar2(10 char) not null,
    data_type varchar2(10 char) not null,
    cdy_ord_value number not null,
    cdy_inv_value number not null,
    ptd_inv_value number not null,
    ptw_inv_value number not null,
    ptg_fcst_value number not null,
    cpd_out_value number not null,
    cpd_ord_value number not null,
    cpd_inv_value number not null,
    cpd_op_value number not null,
    cpd_rob_value number not null,
    cpd_br_value number not null,
    cpd_brm1_value number not null,
    cpd_brm2_value number not null,
    cpd_fcst_value number not null,
    fpd_out_value number not null,
    fpd_ord_value number not null,
    fpd_inv_value number not null,
    lyr_cpd_inv_value number not null,
    lyr_ytp_inv_value number not null,
    lyr_yee_inv_value number not null,
    lyrm1_yee_inv_value number not null,
    lyrm2_yee_inv_value number not null,
    cyr_ytp_inv_value number not null,
    cyr_mat_inv_value number not null,
    cyr_ytg_rob_value number not null,
    cyr_ytg_br_value number not null,
    cyr_ytg_fcst_value number not null,
    cyr_yee_op_value number not null,
    cyr_yee_rob_value number not null,
    cyr_yee_br_value number not null,
    cyr_yee_brm1_value number not null,
    cyr_yee_brm2_value number not null,
    cyr_yee_fcst_value number not null,
    nyr_yee_br_value number not null,
    nyr_yee_brm1_value number not null,
    nyr_yee_brm2_value number not null,
    nyr_yee_fcst_value number not null,
    p01_lyr_value number not null,
    p02_lyr_value number not null,
    p03_lyr_value number not null,
    p04_lyr_value number not null,
    p05_lyr_value number not null,
    p06_lyr_value number not null,
    p07_lyr_value number not null,
    p08_lyr_value number not null,
    p09_lyr_value number not null,
    p10_lyr_value number not null,
    p11_lyr_value number not null,
    p12_lyr_value number not null,
    p13_lyr_value number not null,
    p01_op_value number not null,
    p02_op_value number not null,
    p03_op_value number not null,
    p04_op_value number not null,
    p05_op_value number not null,
    p06_op_value number not null,
    p07_op_value number not null,
    p08_op_value number not null,
    p09_op_value number not null,
    p10_op_value number not null,
    p11_op_value number not null,
    p12_op_value number not null,
    p13_op_value number not null,
    p01_rob_value number not null,
    p02_rob_value number not null,
    p03_rob_value number not null,
    p04_rob_value number not null,
    p05_rob_value number not null,
    p06_rob_value number not null,
    p07_rob_value number not null,
    p08_rob_value number not null,
    p09_rob_value number not null,
    p10_rob_value number not null,
    p11_rob_value number not null,
    p12_rob_value number not null,
    p13_rob_value number not null,
    p01_br_value number not null,
    p02_br_value number not null,
    p03_br_value number not null,
    p04_br_value number not null,
    p05_br_value number not null,
    p06_br_value number not null,
    p07_br_value number not null,
    p08_br_value number not null,
    p09_br_value number not null,
    p10_br_value number not null,
    p11_br_value number not null,
    p12_br_value number not null,
    p13_br_value number not null,
    p14_br_value number not null,
    p15_br_value number not null,
    p16_br_value number not null,
    p17_br_value number not null,
    p18_br_value number not null,
    p19_br_value number not null,
    p20_br_value number not null,
    p21_br_value number not null,
    p22_br_value number not null,
    p23_br_value number not null,
    p24_br_value number not null,
    p25_br_value number not null,
    p26_br_value number not null,
    p01_brm1_value number not null,
    p02_brm1_value number not null,
    p03_brm1_value number not null,
    p04_brm1_value number not null,
    p05_brm1_value number not null,
    p06_brm1_value number not null,
    p07_brm1_value number not null,
    p08_brm1_value number not null,
    p09_brm1_value number not null,
    p10_brm1_value number not null,
    p11_brm1_value number not null,
    p12_brm1_value number not null,
    p13_brm1_value number not null,
    p14_brm1_value number not null,
    p15_brm1_value number not null,
    p16_brm1_value number not null,
    p17_brm1_value number not null,
    p18_brm1_value number not null,
    p19_brm1_value number not null,
    p20_brm1_value number not null,
    p21_brm1_value number not null,
    p22_brm1_value number not null,
    p23_brm1_value number not null,
    p24_brm1_value number not null,
    p25_brm1_value number not null,
    p26_brm1_value number not null,
    p01_brm2_value number not null,
    p02_brm2_value number not null,
    p03_brm2_value number not null,
    p04_brm2_value number not null,
    p05_brm2_value number not null,
    p06_brm2_value number not null,
    p07_brm2_value number not null,
    p08_brm2_value number not null,
    p09_brm2_value number not null,
    p10_brm2_value number not null,
    p11_brm2_value number not null,
    p12_brm2_value number not null,
    p13_brm2_value number not null,
    p14_brm2_value number not null,
    p15_brm2_value number not null,
    p16_brm2_value number not null,
    p17_brm2_value number not null,
    p18_brm2_value number not null,
    p19_brm2_value number not null,
    p20_brm2_value number not null,
    p21_brm2_value number not null,
    p22_brm2_value number not null,
    p23_brm2_value number not null,
    p24_brm2_value number not null,
    p25_brm2_value number not null,
    p26_brm2_value number not null,
    p01_fcst_value number not null,
    p02_fcst_value number not null,
    p03_fcst_value number not null,
    p04_fcst_value number not null,
    p05_fcst_value number not null,
    p06_fcst_value number not null,
    p07_fcst_value number not null,
    p08_fcst_value number not null,
    p09_fcst_value number not null,
    p10_fcst_value number not null,
    p11_fcst_value number not null,
    p12_fcst_value number not null,
    p13_fcst_value number not null,
    p14_fcst_value number not null,
    p15_fcst_value number not null,
    p16_fcst_value number not null,
    p17_fcst_value number not null,
    p18_fcst_value number not null,
    p19_fcst_value number not null,
    p20_fcst_value number not null,
    p21_fcst_value number not null,
    p22_fcst_value number not null,
    p23_fcst_value number not null,
    p24_fcst_value number not null,
    p25_fcst_value number not null,
    p26_fcst_value number not null);

/**/
/* Comments
/**/
comment on table dw_mart_sales01_det is 'Mart Sales 01 Detail Table';
comment on column dw_mart_sales01_det.company_code is 'Company code';
comment on column dw_mart_sales01_det.data_segment is 'Data segment';
comment on column dw_mart_sales01_det.matl_group is 'Material group - *ALL or group code';
comment on column dw_mart_sales01_det.ship_to_cust_code is 'Ship to customer code';
comment on column dw_mart_sales01_det.matl_code is 'Material code';
comment on column dw_mart_sales01_det.acct_assgnmnt_grp_code is 'Account assignment group code';
comment on column dw_mart_sales01_det.demand_plng_grp_code is 'Demand planning group code';
comment on column dw_mart_sales01_det.mfanz_icb_flag is 'MFANZ ICB flag';
comment on column dw_mart_sales01_det.data_type is 'Data type - *QTY, *TON, *GSV';
comment on column dw_mart_sales01_det.cdy_ord_value is 'Current day - ordered value';
comment on column dw_mart_sales01_det.cdy_inv_value is 'Current day - invoiced value';
comment on column dw_mart_sales01_det.ptd_inv_value is 'Period to date - invoiced value';
comment on column dw_mart_sales01_det.ptw_inv_value is 'Period to week - invoiced value';
comment on column dw_mart_sales01_det.ptg_fcst_value is 'Period to go - forecast value';
comment on column dw_mart_sales01_det.cpd_out_value is 'Current period - outstanding value';
comment on column dw_mart_sales01_det.cpd_ord_value is 'Current period - order delivered value';
comment on column dw_mart_sales01_det.cpd_inv_value is 'Current period - invoiced value';
comment on column dw_mart_sales01_det.cpd_op_value is 'Current period - operating plan value';
comment on column dw_mart_sales01_det.cpd_rob_value is 'Current period - review of business value';
comment on column dw_mart_sales01_det.cpd_br_value is 'Current period - business review value';
comment on column dw_mart_sales01_det.cpd_brm1_value is 'Current period - business review minus 1 value';
comment on column dw_mart_sales01_det.cpd_brm2_value is 'Current period - business review minus 2 value';
comment on column dw_mart_sales01_det.cpd_fcst_value is 'Current period - forecast value';
comment on column dw_mart_sales01_det.fpd_out_value is 'Future periods - outstanding value';
comment on column dw_mart_sales01_det.fpd_ord_value is 'Future periods - order delivered value';
comment on column dw_mart_sales01_det.fpd_inv_value is 'Future periods - invoice delivered value';
comment on column dw_mart_sales01_det.lyr_cpd_inv_value is 'Last year - current period - invoiced value';
comment on column dw_mart_sales01_det.lyr_ytp_inv_value is 'Last year - year to period - invoiced value';
comment on column dw_mart_sales01_det.lyr_yee_inv_value is 'Last year - year end estimate - invoiced value';
comment on column dw_mart_sales01_det.lyrm1_yee_inv_value is 'Last year minus 1 - year end estimate - invoiced value';
comment on column dw_mart_sales01_det.lyrm2_yee_inv_value is 'Last year minus 2 - year end estimate - invoiced value';
comment on column dw_mart_sales01_det.cyr_ytp_inv_value is 'Current year - year to period - invoiced value';
comment on column dw_mart_sales01_det.cyr_mat_inv_value is 'Current year - moving annual total - invoiced value';
comment on column dw_mart_sales01_det.cyr_ytg_rob_value is 'Current year - year to go - review of business value';
comment on column dw_mart_sales01_det.cyr_ytg_br_value is 'Current year - year to go - business review value';
comment on column dw_mart_sales01_det.cyr_ytg_fcst_value is 'Current year - year to go - forecast value';
comment on column dw_mart_sales01_det.cyr_yee_op_value is 'Current year - year end estimate - operating plan';
comment on column dw_mart_sales01_det.cyr_yee_rob_value is 'Current year - year end estimate - review of business';
comment on column dw_mart_sales01_det.cyr_yee_br_value is 'Current year - year end estimate - business review value';
comment on column dw_mart_sales01_det.cyr_yee_brm1_value is 'Current year - year end estimate - business review minus 1 value';
comment on column dw_mart_sales01_det.cyr_yee_brm2_value is 'Current year - year end estimate - business review minus 2 value';
comment on column dw_mart_sales01_det.cyr_yee_fcst_value is 'Current year - year end estimate - forecast value';
comment on column dw_mart_sales01_det.nyr_yee_br_value is 'Next year - year end estimate - business review value';
comment on column dw_mart_sales01_det.nyr_yee_brm1_value is 'Next year - year end estimate - business review minus 1 value';
comment on column dw_mart_sales01_det.nyr_yee_brm2_value is 'Next year - year end estimate - business review minus 2 value';
comment on column dw_mart_sales01_det.nyr_yee_fcst_value is 'Next year - year end estimate - forecast value';
comment on column dw_mart_sales01_det.p01_lyr_value is 'P01 Last year value';
comment on column dw_mart_sales01_det.p02_lyr_value is 'P02 Last year value';
comment on column dw_mart_sales01_det.p03_lyr_value is 'P03 Last year value';
comment on column dw_mart_sales01_det.p04_lyr_value is 'P04 Last year value';
comment on column dw_mart_sales01_det.p05_lyr_value is 'P05 Last year value';
comment on column dw_mart_sales01_det.p06_lyr_value is 'P06 Last year value';
comment on column dw_mart_sales01_det.p07_lyr_value is 'P07 Last year value';
comment on column dw_mart_sales01_det.p08_lyr_value is 'P08 Last year value';
comment on column dw_mart_sales01_det.p09_lyr_value is 'P09 Last year value';
comment on column dw_mart_sales01_det.p10_lyr_value is 'P10 Last year value';
comment on column dw_mart_sales01_det.p11_lyr_value is 'P11 Last year value';
comment on column dw_mart_sales01_det.p12_lyr_value is 'P12 Last year value';
comment on column dw_mart_sales01_det.p13_lyr_value is 'P13 Last year value';
comment on column dw_mart_sales01_det.p01_op_value is 'P01 OP value';
comment on column dw_mart_sales01_det.p02_op_value is 'P02 OP value';
comment on column dw_mart_sales01_det.p03_op_value is 'P03 OP value';
comment on column dw_mart_sales01_det.p04_op_value is 'P04 OP value';
comment on column dw_mart_sales01_det.p05_op_value is 'P05 OP value';
comment on column dw_mart_sales01_det.p06_op_value is 'P06 OP value';
comment on column dw_mart_sales01_det.p07_op_value is 'P07 OP value';
comment on column dw_mart_sales01_det.p08_op_value is 'P08 OP value';
comment on column dw_mart_sales01_det.p09_op_value is 'P09 OP value';
comment on column dw_mart_sales01_det.p10_op_value is 'P10 OP value';
comment on column dw_mart_sales01_det.p11_op_value is 'P11 OP value';
comment on column dw_mart_sales01_det.p12_op_value is 'P12 OP value';
comment on column dw_mart_sales01_det.p13_op_value is 'P13 OP value';
comment on column dw_mart_sales01_det.p01_rob_value is 'P01 ACT/ROB value';
comment on column dw_mart_sales01_det.p02_rob_value is 'P02 ACT/ROB value';
comment on column dw_mart_sales01_det.p03_rob_value is 'P03 ACT/ROB value';
comment on column dw_mart_sales01_det.p04_rob_value is 'P04 ACT/ROB value';
comment on column dw_mart_sales01_det.p05_rob_value is 'P05 ACT/ROB value';
comment on column dw_mart_sales01_det.p06_rob_value is 'P06 ACT/ROB value';
comment on column dw_mart_sales01_det.p07_rob_value is 'P07 ACT/ROB value';
comment on column dw_mart_sales01_det.p08_rob_value is 'P08 ACT/ROB value';
comment on column dw_mart_sales01_det.p09_rob_value is 'P09 ACT/ROB value';
comment on column dw_mart_sales01_det.p10_rob_value is 'P10 ACT/ROB value';
comment on column dw_mart_sales01_det.p11_rob_value is 'P11 ACT/ROB value';
comment on column dw_mart_sales01_det.p12_rob_value is 'P12 ACT/ROB value';
comment on column dw_mart_sales01_det.p13_rob_value is 'P13 ACT/ROB value';
comment on column dw_mart_sales01_det.p01_br_value is 'P01 ACT/BR value';
comment on column dw_mart_sales01_det.p02_br_value is 'P02 ACT/BR value';
comment on column dw_mart_sales01_det.p03_br_value is 'P03 ACT/BR value';
comment on column dw_mart_sales01_det.p04_br_value is 'P04 ACT/BR value';
comment on column dw_mart_sales01_det.p05_br_value is 'P05 ACT/BR value';
comment on column dw_mart_sales01_det.p06_br_value is 'P06 ACT/BR value';
comment on column dw_mart_sales01_det.p07_br_value is 'P07 ACT/BR value';
comment on column dw_mart_sales01_det.p08_br_value is 'P08 ACT/BR value';
comment on column dw_mart_sales01_det.p09_br_value is 'P09 ACT/BR value';
comment on column dw_mart_sales01_det.p10_br_value is 'P10 ACT/BR value';
comment on column dw_mart_sales01_det.p11_br_value is 'P11 ACT/BR value';
comment on column dw_mart_sales01_det.p12_br_value is 'P12 ACT/BR value';
comment on column dw_mart_sales01_det.p13_br_value is 'P13 ACT/BR value';
comment on column dw_mart_sales01_det.p14_br_value is 'P14 ACT/BR value';
comment on column dw_mart_sales01_det.p15_br_value is 'P15 ACT/BR value';
comment on column dw_mart_sales01_det.p16_br_value is 'P16 ACT/BR value';
comment on column dw_mart_sales01_det.p17_br_value is 'P17 ACT/BR value';
comment on column dw_mart_sales01_det.p18_br_value is 'P18 ACT/BR value';
comment on column dw_mart_sales01_det.p19_br_value is 'P19 ACT/BR value';
comment on column dw_mart_sales01_det.p20_br_value is 'P20 ACT/BR value';
comment on column dw_mart_sales01_det.p21_br_value is 'P21 ACT/BR value';
comment on column dw_mart_sales01_det.p22_br_value is 'P22 ACT/BR value';
comment on column dw_mart_sales01_det.p23_br_value is 'P23 ACT/BR value';
comment on column dw_mart_sales01_det.p24_br_value is 'P24 ACT/BR value';
comment on column dw_mart_sales01_det.p25_br_value is 'P25 ACT/BR value';
comment on column dw_mart_sales01_det.p26_br_value is 'P26 ACT/BR value';
comment on column dw_mart_sales01_det.p01_brm1_value is 'P01 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p02_brm1_value is 'P02 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p03_brm1_value is 'P03 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p04_brm1_value is 'P04 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p05_brm1_value is 'P05 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p06_brm1_value is 'P06 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p07_brm1_value is 'P07 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p08_brm1_value is 'P08 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p09_brm1_value is 'P09 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p10_brm1_value is 'P10 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p11_brm1_value is 'P11 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p12_brm1_value is 'P12 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p13_brm1_value is 'P13 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p14_brm1_value is 'P14 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p15_brm1_value is 'P15 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p16_brm1_value is 'P16 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p17_brm1_value is 'P17 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p18_brm1_value is 'P18 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p19_brm1_value is 'P19 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p20_brm1_value is 'P20 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p21_brm1_value is 'P21 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p22_brm1_value is 'P22 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p23_brm1_value is 'P23 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p24_brm1_value is 'P24 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p25_brm1_value is 'P25 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p26_brm1_value is 'P26 ACT/BR minus 1 value';
comment on column dw_mart_sales01_det.p01_brm2_value is 'P01 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p02_brm2_value is 'P02 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p03_brm2_value is 'P03 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p04_brm2_value is 'P04 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p05_brm2_value is 'P05 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p06_brm2_value is 'P06 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p07_brm2_value is 'P07 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p08_brm2_value is 'P08 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p09_brm2_value is 'P09 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p10_brm2_value is 'P10 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p11_brm2_value is 'P11 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p12_brm2_value is 'P12 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p13_brm2_value is 'P13 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p14_brm2_value is 'P14 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p15_brm2_value is 'P15 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p16_brm2_value is 'P16 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p17_brm2_value is 'P17 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p18_brm2_value is 'P18 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p19_brm2_value is 'P19 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p20_brm2_value is 'P20 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p21_brm2_value is 'P21 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p22_brm2_value is 'P22 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p23_brm2_value is 'P23 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p24_brm2_value is 'P24 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p25_brm2_value is 'P25 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p26_brm2_value is 'P26 ACT/BR minus 2 value';
comment on column dw_mart_sales01_det.p01_fcst_value is 'P01 ACT/FCST value';
comment on column dw_mart_sales01_det.p02_fcst_value is 'P02 ACT/FCST value';
comment on column dw_mart_sales01_det.p03_fcst_value is 'P03 ACT/FCST value';
comment on column dw_mart_sales01_det.p04_fcst_value is 'P04 ACT/FCST value';
comment on column dw_mart_sales01_det.p05_fcst_value is 'P05 ACT/FCST value';
comment on column dw_mart_sales01_det.p06_fcst_value is 'P06 ACT/FCST value';
comment on column dw_mart_sales01_det.p07_fcst_value is 'P07 ACT/FCST value';
comment on column dw_mart_sales01_det.p08_fcst_value is 'P08 ACT/FCST value';
comment on column dw_mart_sales01_det.p09_fcst_value is 'P09 ACT/FCST value';
comment on column dw_mart_sales01_det.p10_fcst_value is 'P10 ACT/FCST value';
comment on column dw_mart_sales01_det.p11_fcst_value is 'P11 ACT/FCST value';
comment on column dw_mart_sales01_det.p12_fcst_value is 'P12 ACT/FCST value';
comment on column dw_mart_sales01_det.p13_fcst_value is 'P13 ACT/FCST value';
comment on column dw_mart_sales01_det.p14_fcst_value is 'P14 ACT/FCST value';
comment on column dw_mart_sales01_det.p15_fcst_value is 'P15 ACT/FCST value';
comment on column dw_mart_sales01_det.p16_fcst_value is 'P16 ACT/FCST value';
comment on column dw_mart_sales01_det.p17_fcst_value is 'P17 ACT/FCST value';
comment on column dw_mart_sales01_det.p18_fcst_value is 'P18 ACT/FCST value';
comment on column dw_mart_sales01_det.p19_fcst_value is 'P19 ACT/FCST value';
comment on column dw_mart_sales01_det.p20_fcst_value is 'P20 ACT/FCST value';
comment on column dw_mart_sales01_det.p21_fcst_value is 'P21 ACT/FCST value';
comment on column dw_mart_sales01_det.p22_fcst_value is 'P22 ACT/FCST value';
comment on column dw_mart_sales01_det.p23_fcst_value is 'P23 ACT/FCST value';
comment on column dw_mart_sales01_det.p24_fcst_value is 'P24 ACT/FCST value';
comment on column dw_mart_sales01_det.p25_fcst_value is 'P25 ACT/FCST value';
comment on column dw_mart_sales01_det.p26_fcst_value is 'P26 ACT/FCST value';

/**/
/* Primary Key Constraint
/**/
alter table dw_mart_sales01_det
   add constraint dw_mart_sales01_det_pk primary key (company_code, data_segment, matl_group, ship_to_cust_code, matl_code, acct_assgnmnt_grp_code, demand_plng_grp_code, mfanz_icb_flag, data_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on dw_mart_sales01_det to dw_app;
grant select on dw_mart_sales01_det to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_mart_sales01_det for dds.dw_mart_sales01_det;
