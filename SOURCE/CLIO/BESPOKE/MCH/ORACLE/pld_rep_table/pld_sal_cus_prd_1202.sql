/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_sal_cus_prd_1202                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_cus_prd_1202
   (sap_company_code varchar2(6 char) not null,
    sap_ship_to_cust_code varchar2(10 char) not null,
    sap_sales_org_code varchar2(4 char) not null,
    sap_distbn_chnl_code varchar2(2 char) not null,
    sap_division_code varchar2(2 char) not null,
    sap_material_code varchar2(18 char) not null,
    dta_type varchar2(3 char) not null,
    p01_qty number not null,
    p02_qty number not null,
    p03_qty number not null,
    p04_qty number not null,
    p05_qty number not null,
    p06_qty number not null,
    p07_qty number not null,
    p08_qty number not null,
    p09_qty number not null,
    p10_qty number not null,
    p11_qty number not null,
    p12_qty number not null,
    p13_qty number not null,
    p01_ton number not null,
    p02_ton number not null,
    p03_ton number not null,
    p04_ton number not null,
    p05_ton number not null,
    p06_ton number not null,
    p07_ton number not null,
    p08_ton number not null,
    p09_ton number not null,
    p10_ton number not null,
    p11_ton number not null,
    p12_ton number not null,
    p13_ton number not null,
    p01_gsv number not null,
    p02_gsv number not null,
    p03_gsv number not null,
    p04_gsv number not null,
    p05_gsv number not null,
    p06_gsv number not null,
    p07_gsv number not null,
    p08_gsv number not null,
    p09_gsv number not null,
    p10_gsv number not null,
    p11_gsv number not null,
    p12_gsv number not null,
    p13_gsv number not null,
    p01_niv number not null,
    p02_niv number not null,
    p03_niv number not null,
    p04_niv number not null,
    p05_niv number not null,
    p06_niv number not null,
    p07_niv number not null,
    p08_niv number not null,
    p09_niv number not null,
    p10_niv number not null,
    p11_niv number not null,
    p12_niv number not null,
    p13_niv number not null);

/**/
/* Comment */
/**/
comment on table pld_sal_cus_prd_1202 is 'Planning Sales Customer 12 Period Detail Table - Billing Date';
comment on column pld_sal_cus_prd_1202.sap_company_code is 'SAP Company code';
comment on column pld_sal_cus_prd_1202.sap_ship_to_cust_code is 'SAP Ship To Customer code';
comment on column pld_sal_cus_prd_1202.sap_sales_org_code is 'SAP Sales organisation code';
comment on column pld_sal_cus_prd_1202.sap_distbn_chnl_code is 'SAP Distribution channel code';
comment on column pld_sal_cus_prd_1202.sap_division_code is 'SAP Division code';
comment on column pld_sal_cus_prd_1202.sap_material_code is 'SAP Material code';
comment on column pld_sal_cus_prd_1202.dta_type is 'Data type - AOP, ABR, ARB, LYR, TOP';
comment on column pld_sal_cus_prd_1202.p01_qty is 'P01 quantity';
comment on column pld_sal_cus_prd_1202.p02_qty is 'P02 quantity';
comment on column pld_sal_cus_prd_1202.p03_qty is 'P03 quantity';
comment on column pld_sal_cus_prd_1202.p04_qty is 'P04 quantity';
comment on column pld_sal_cus_prd_1202.p05_qty is 'P05 quantity';
comment on column pld_sal_cus_prd_1202.p06_qty is 'P06 quantity';
comment on column pld_sal_cus_prd_1202.p07_qty is 'P07 quantity';
comment on column pld_sal_cus_prd_1202.p08_qty is 'P08 quantity';
comment on column pld_sal_cus_prd_1202.p09_qty is 'P09 quantity';
comment on column pld_sal_cus_prd_1202.p10_qty is 'P10 quantity';
comment on column pld_sal_cus_prd_1202.p11_qty is 'P11 quantity';
comment on column pld_sal_cus_prd_1202.p12_qty is 'P12 quantity';
comment on column pld_sal_cus_prd_1202.p13_qty is 'P13 quantity';
comment on column pld_sal_cus_prd_1202.p01_ton is 'P01 tonnes';
comment on column pld_sal_cus_prd_1202.p02_ton is 'P02 tonnes';
comment on column pld_sal_cus_prd_1202.p03_ton is 'P03 tonnes';
comment on column pld_sal_cus_prd_1202.p04_ton is 'P04 tonnes';
comment on column pld_sal_cus_prd_1202.p05_ton is 'P05 tonnes';
comment on column pld_sal_cus_prd_1202.p06_ton is 'P06 tonnes';
comment on column pld_sal_cus_prd_1202.p07_ton is 'P07 tonnes';
comment on column pld_sal_cus_prd_1202.p08_ton is 'P08 tonnes';
comment on column pld_sal_cus_prd_1202.p09_ton is 'P09 tonnes';
comment on column pld_sal_cus_prd_1202.p10_ton is 'P10 tonnes';
comment on column pld_sal_cus_prd_1202.p11_ton is 'P11 tonnes';
comment on column pld_sal_cus_prd_1202.p12_ton is 'P12 tonnes';
comment on column pld_sal_cus_prd_1202.p13_ton is 'P13 tonnes';
comment on column pld_sal_cus_prd_1202.p01_gsv is 'P01 gross sales value';
comment on column pld_sal_cus_prd_1202.p02_gsv is 'P02 gross sales value';
comment on column pld_sal_cus_prd_1202.p03_gsv is 'P03 gross sales value';
comment on column pld_sal_cus_prd_1202.p04_gsv is 'P04 gross sales value';
comment on column pld_sal_cus_prd_1202.p05_gsv is 'P05 gross sales value';
comment on column pld_sal_cus_prd_1202.p06_gsv is 'P06 gross sales value';
comment on column pld_sal_cus_prd_1202.p07_gsv is 'P07 gross sales value';
comment on column pld_sal_cus_prd_1202.p08_gsv is 'P08 gross sales value';
comment on column pld_sal_cus_prd_1202.p09_gsv is 'P09 gross sales value';
comment on column pld_sal_cus_prd_1202.p10_gsv is 'P10 gross sales value';
comment on column pld_sal_cus_prd_1202.p11_gsv is 'P11 gross sales value';
comment on column pld_sal_cus_prd_1202.p12_gsv is 'P12 gross sales value';
comment on column pld_sal_cus_prd_1202.p13_gsv is 'P13 gross sales value';
comment on column pld_sal_cus_prd_1202.p01_niv is 'P01 net invoice value';
comment on column pld_sal_cus_prd_1202.p02_niv is 'P02 net invoice value';
comment on column pld_sal_cus_prd_1202.p03_niv is 'P03 net invoice value';
comment on column pld_sal_cus_prd_1202.p04_niv is 'P04 net invoice value';
comment on column pld_sal_cus_prd_1202.p05_niv is 'P05 net invoice value';
comment on column pld_sal_cus_prd_1202.p06_niv is 'P06 net invoice value';
comment on column pld_sal_cus_prd_1202.p07_niv is 'P07 net invoice value';
comment on column pld_sal_cus_prd_1202.p08_niv is 'P08 net invoice value';
comment on column pld_sal_cus_prd_1202.p09_niv is 'P09 net invoice value';
comment on column pld_sal_cus_prd_1202.p10_niv is 'P10 net invoice value';
comment on column pld_sal_cus_prd_1202.p11_niv is 'P11 net invoice value';
comment on column pld_sal_cus_prd_1202.p12_niv is 'P12 net invoice value';
comment on column pld_sal_cus_prd_1202.p13_niv is 'P13 net invoice value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_cus_prd_1202
   add constraint pld_sal_cus_prd_1202_pk primary key (sap_company_code,
                                                       sap_ship_to_cust_code,
                                                       sap_sales_org_code,
                                                       sap_distbn_chnl_code,
                                                       sap_division_code,
                                                       sap_material_code,
                                                       dta_type);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_cus_prd_1202 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_cus_prd_1202 for pld_rep.pld_sal_cus_prd_1202;
