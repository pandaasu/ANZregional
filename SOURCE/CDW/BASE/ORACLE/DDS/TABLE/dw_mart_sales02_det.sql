/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Table   : dw_mart_sales02_det
 Owner   : dds
 Author  : Steve Gregan

 Description
 -----------
 Dimensional Data Store - Mart Sales 02 Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/06   Steve Gregan   Created
 2008/08   Steve Gregan   Added ICB_FLAG
 2008/08   Steve Gregan   Added ship to customer
 2008/10   Steve Gregan   Added PTW/PTG/LYRM1/LYRM2/P01-26FCST/P01-26BR

*******************************************************************************/

/**/
/* Table creation
/**/
create table dw_mart_sales02_det
   (company_code varchar2(6 char) not null,
    data_segment varchar2(32 char) not null,
    matl_group varchar2(20 char) not null,
    ship_to_cust_code varchar2(10 char) not null,
    matl_code varchar2(18 char) not null,
    acct_assgnmnt_grp_code varchar2(10 char) not null,
    demand_plng_grp_code varchar2(10 char) not null,
    mfanz_icb_flag varchar2(10 char) not null,
    data_type varchar2(10 char) not null,
    cur_day_ord_value number not null,
    cur_day_inv_value number not null,
    ptw_inv_value number not null,
    ptg_br_value number not null,
    ptg_fcst_value number not null,
    cur_prd_inv_value number not null,
    cur_prd_op_value number not null,
    cur_prd_rob_value number not null,
    cur_prd_br_value number not null,
    cur_prd_fcst_value number not null,
    cur_prd_out_value number not null,
    cur_prd_ord_value number not null,
    fut_prd_ord_value number not null,
    fut_prd_inv_value number not null,
    lyr_yte_inv_value number not null,
    lyrm1_yte_inv_value number not null,
    lyrm2_yte_inv_value number not null,
    cyr_ytd_inv_value number not null,
    cyr_mat_inv_value number not null,
    cyr_yte_op_value number not null,
    cyr_yte_rob_value number not null,
    cyr_ytg_br_value number not null,
    cyr_ytg_fcst_value number not null,
    nyr_yte_br_value number not null,
    nyr_yte_fcst_value number not null,
    cyr_yee_inv_fcst_value number not null,
    cyr_yee_inv_br_value number not null,
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
    p26_fcst_value number not null,
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
    p26_br_value number not null);

/**/
/* Comments
/**/
comment on table dw_mart_sales02_det is 'Mart Sales 02 Detail Table';
comment on column dw_mart_sales02_det.company_code is 'Company code';
comment on column dw_mart_sales02_det.data_segment is 'Data segment';
comment on column dw_mart_sales02_det.matl_group is 'Material group - *ALL or group code';
comment on column dw_mart_sales02_det.ship_to_cust_code is 'Ship to customer code';
comment on column dw_mart_sales02_det.matl_code is 'Material code';
comment on column dw_mart_sales02_det.acct_assgnmnt_grp_code is 'Account assignment group code';
comment on column dw_mart_sales02_det.demand_plng_grp_code is 'Demand planning group code';
comment on column dw_mart_sales02_det.mfanz_icb_flag is 'MFANZ ICB flag';
comment on column dw_mart_sales02_det.data_type is 'Data type - *QTY, *TON, *GSV';
comment on column dw_mart_sales02_det.cur_day_ord_value is 'Current day ordered value';
comment on column dw_mart_sales02_det.cur_day_inv_value is 'Current day invoiced value';
comment on column dw_mart_sales02_det.ptw_inv_value is 'Period to week invoiced value';
comment on column dw_mart_sales02_det.ptg_br_value is 'Period to go business review value';
comment on column dw_mart_sales02_det.ptg_fcst_value is 'Period to go forecast value';
comment on column dw_mart_sales02_det.cur_prd_inv_value is 'Current period invoiced value';
comment on column dw_mart_sales02_det.cur_prd_op_value is 'Current period operating plan value';
comment on column dw_mart_sales02_det.cur_prd_rob_value is 'Current period review of business value';
comment on column dw_mart_sales02_det.cur_prd_br_value is 'Current period business review value';
comment on column dw_mart_sales02_det.cur_prd_fcst_value is 'Current period forecast value';
comment on column dw_mart_sales02_det.cur_prd_out_value is 'Current period outstanding value';
comment on column dw_mart_sales02_det.cur_prd_ord_value is 'Current period order delivered value';
comment on column dw_mart_sales02_det.fut_prd_ord_value is 'Future periods order delivered value';
comment on column dw_mart_sales02_det.fut_prd_inv_value is 'Future period invoice delivered value';
comment on column dw_mart_sales02_det.lyr_yte_inv_value is 'Last year to end invoiced value';
comment on column dw_mart_sales02_det.lyrm1_yte_inv_value is 'Last year minus 1 to end invoiced value';
comment on column dw_mart_sales02_det.lyrm2_yte_inv_value is 'Last year minus 2 to end invoiced value';
comment on column dw_mart_sales02_det.cyr_ytd_inv_value is 'Current year to date invoiced value';
comment on column dw_mart_sales02_det.cyr_mat_inv_value is 'Current moving annual total invoiced value';
comment on column dw_mart_sales02_det.cyr_yte_op_value is 'Current year to end operating plan';
comment on column dw_mart_sales02_det.cyr_yte_rob_value is 'Current year to end review of business';
comment on column dw_mart_sales02_det.cyr_ytg_br_value is 'Current year to go business review value';
comment on column dw_mart_sales02_det.cyr_ytg_fcst_value is 'Current year to go forecast value';
comment on column dw_mart_sales02_det.nyr_yte_br_value is 'Next year to end business review value';
comment on column dw_mart_sales02_det.nyr_yte_fcst_value is 'Next year to end forecast value';
comment on column dw_mart_sales02_det.cyr_yee_inv_fcst_value is 'Current year end estimate invoiced/forecast value';
comment on column dw_mart_sales02_det.cyr_yee_inv_br_value is 'Current year end estimate invoiced/business review value';
comment on column dw_mart_sales02_det.p01_fcst_value is 'P01 ACT/FCST value';
comment on column dw_mart_sales02_det.p02_fcst_value is 'P02 ACT/FCST value';
comment on column dw_mart_sales02_det.p03_fcst_value is 'P03 ACT/FCST value';
comment on column dw_mart_sales02_det.p04_fcst_value is 'P04 ACT/FCST value';
comment on column dw_mart_sales02_det.p05_fcst_value is 'P05 ACT/FCST value';
comment on column dw_mart_sales02_det.p06_fcst_value is 'P06 ACT/FCST value';
comment on column dw_mart_sales02_det.p07_fcst_value is 'P07 ACT/FCST value';
comment on column dw_mart_sales02_det.p08_fcst_value is 'P08 ACT/FCST value';
comment on column dw_mart_sales02_det.p09_fcst_value is 'P09 ACT/FCST value';
comment on column dw_mart_sales02_det.p10_fcst_value is 'P10 ACT/FCST value';
comment on column dw_mart_sales02_det.p11_fcst_value is 'P11 ACT/FCST value';
comment on column dw_mart_sales02_det.p12_fcst_value is 'P12 ACT/FCST value';
comment on column dw_mart_sales02_det.p13_fcst_value is 'P13 ACT/FCST value';
comment on column dw_mart_sales02_det.p14_fcst_value is 'P14 ACT/FCST value';
comment on column dw_mart_sales02_det.p15_fcst_value is 'P15 ACT/FCST value';
comment on column dw_mart_sales02_det.p16_fcst_value is 'P16 ACT/FCST value';
comment on column dw_mart_sales02_det.p17_fcst_value is 'P17 ACT/FCST value';
comment on column dw_mart_sales02_det.p18_fcst_value is 'P18 ACT/FCST value';
comment on column dw_mart_sales02_det.p19_fcst_value is 'P19 ACT/FCST value';
comment on column dw_mart_sales02_det.p20_fcst_value is 'P20 ACT/FCST value';
comment on column dw_mart_sales02_det.p21_fcst_value is 'P21 ACT/FCST value';
comment on column dw_mart_sales02_det.p22_fcst_value is 'P22 ACT/FCST value';
comment on column dw_mart_sales02_det.p23_fcst_value is 'P23 ACT/FCST value';
comment on column dw_mart_sales02_det.p24_fcst_value is 'P24 ACT/FCST value';
comment on column dw_mart_sales02_det.p25_fcst_value is 'P25 ACT/FCST value';
comment on column dw_mart_sales02_det.p26_fcst_value is 'P26 ACT/FCST value';
comment on column dw_mart_sales02_det.p01_br_value is 'P01 ACT/BR value';
comment on column dw_mart_sales02_det.p02_br_value is 'P02 ACT/BR value';
comment on column dw_mart_sales02_det.p03_br_value is 'P03 ACT/BR value';
comment on column dw_mart_sales02_det.p04_br_value is 'P04 ACT/BR value';
comment on column dw_mart_sales02_det.p05_br_value is 'P05 ACT/BR value';
comment on column dw_mart_sales02_det.p06_br_value is 'P06 ACT/BR value';
comment on column dw_mart_sales02_det.p07_br_value is 'P07 ACT/BR value';
comment on column dw_mart_sales02_det.p08_br_value is 'P08 ACT/BR value';
comment on column dw_mart_sales02_det.p09_br_value is 'P09 ACT/BR value';
comment on column dw_mart_sales02_det.p10_br_value is 'P10 ACT/BR value';
comment on column dw_mart_sales02_det.p11_br_value is 'P11 ACT/BR value';
comment on column dw_mart_sales02_det.p12_br_value is 'P12 ACT/BR value';
comment on column dw_mart_sales02_det.p13_br_value is 'P13 ACT/BR value';
comment on column dw_mart_sales02_det.p14_br_value is 'P14 ACT/BR value';
comment on column dw_mart_sales02_det.p15_br_value is 'P15 ACT/BR value';
comment on column dw_mart_sales02_det.p16_br_value is 'P16 ACT/BR value';
comment on column dw_mart_sales02_det.p17_br_value is 'P17 ACT/BR value';
comment on column dw_mart_sales02_det.p18_br_value is 'P18 ACT/BR value';
comment on column dw_mart_sales02_det.p19_br_value is 'P19 ACT/BR value';
comment on column dw_mart_sales02_det.p20_br_value is 'P20 ACT/BR value';
comment on column dw_mart_sales02_det.p21_br_value is 'P21 ACT/BR value';
comment on column dw_mart_sales02_det.p22_br_value is 'P22 ACT/BR value';
comment on column dw_mart_sales02_det.p23_br_value is 'P23 ACT/BR value';
comment on column dw_mart_sales02_det.p24_br_value is 'P24 ACT/BR value';
comment on column dw_mart_sales02_det.p25_br_value is 'P25 ACT/BR value';
comment on column dw_mart_sales02_det.p26_br_value is 'P26 ACT/BR value';

/**/
/* Primary Key Constraint
/**/
alter table dw_mart_sales02_det
   add constraint dw_mart_sales02_det_pk primary key (company_code, data_segment, matl_group, ship_to_cust_code, matl_code, acct_assgnmnt_grp_code, demand_plng_grp_code, mfanz_icb_flag, data_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on dw_mart_sales02_det to dw_app;
grant select on dw_mart_sales02_det to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_mart_sales02_det for dds.dw_mart_sales02_det;
