/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_sal_mat_mth_0202                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_mat_mth_0202
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    dta_type varchar2(3 char) not null,
    m01_qty number not null,
    m02_qty number not null,
    m03_qty number not null,
    m04_qty number not null,
    m05_qty number not null,
    m06_qty number not null,
    m07_qty number not null,
    m08_qty number not null,
    m09_qty number not null,
    m10_qty number not null,
    m11_qty number not null,
    m12_qty number not null,
    m01_ton number not null,
    m02_ton number not null,
    m03_ton number not null,
    m04_ton number not null,
    m05_ton number not null,
    m06_ton number not null,
    m07_ton number not null,
    m08_ton number not null,
    m09_ton number not null,
    m10_ton number not null,
    m11_ton number not null,
    m12_ton number not null,
    m01_gsv number not null,
    m02_gsv number not null,
    m03_gsv number not null,
    m04_gsv number not null,
    m05_gsv number not null,
    m06_gsv number not null,
    m07_gsv number not null,
    m08_gsv number not null,
    m09_gsv number not null,
    m10_gsv number not null,
    m11_gsv number not null,
    m12_gsv number not null,
    m01_niv number not null,
    m02_niv number not null,
    m03_niv number not null,
    m04_niv number not null,
    m05_niv number not null,
    m06_niv number not null,
    m07_niv number not null,
    m08_niv number not null,
    m09_niv number not null,
    m10_niv number not null,
    m11_niv number not null,
    m12_niv number not null);

/**/
/* Comment */
/**/
comment on table pld_sal_mat_mth_0202 is 'Planning Sales Material 02 Month Detail Table - Invoice Date';
comment on column pld_sal_mat_mth_0202.sap_company_code is 'SAP Company code';
comment on column pld_sal_mat_mth_0202.sap_material_code is 'SAP Material code';
comment on column pld_sal_mat_mth_0202.dta_type is 'Data type - AOP, ABR, ARB, LYR, TOP';
comment on column pld_sal_mat_mth_0202.m01_qty is 'M01 quantity';
comment on column pld_sal_mat_mth_0202.m02_qty is 'M02 quantity';
comment on column pld_sal_mat_mth_0202.m03_qty is 'M03 quantity';
comment on column pld_sal_mat_mth_0202.m04_qty is 'M04 quantity';
comment on column pld_sal_mat_mth_0202.m05_qty is 'M05 quantity';
comment on column pld_sal_mat_mth_0202.m06_qty is 'M06 quantity';
comment on column pld_sal_mat_mth_0202.m07_qty is 'M07 quantity';
comment on column pld_sal_mat_mth_0202.m08_qty is 'M08 quantity';
comment on column pld_sal_mat_mth_0202.m09_qty is 'M09 quantity';
comment on column pld_sal_mat_mth_0202.m10_qty is 'M10 quantity';
comment on column pld_sal_mat_mth_0202.m11_qty is 'M11 quantity';
comment on column pld_sal_mat_mth_0202.m12_qty is 'M12 quantity';
comment on column pld_sal_mat_mth_0202.m01_ton is 'M01 tonnes';
comment on column pld_sal_mat_mth_0202.m02_ton is 'M02 tonnes';
comment on column pld_sal_mat_mth_0202.m03_ton is 'M03 tonnes';
comment on column pld_sal_mat_mth_0202.m04_ton is 'M04 tonnes';
comment on column pld_sal_mat_mth_0202.m05_ton is 'M05 tonnes';
comment on column pld_sal_mat_mth_0202.m06_ton is 'M06 tonnes';
comment on column pld_sal_mat_mth_0202.m07_ton is 'M07 tonnes';
comment on column pld_sal_mat_mth_0202.m08_ton is 'M08 tonnes';
comment on column pld_sal_mat_mth_0202.m09_ton is 'M09 tonnes';
comment on column pld_sal_mat_mth_0202.m10_ton is 'M10 tonnes';
comment on column pld_sal_mat_mth_0202.m11_ton is 'M11 tonnes';
comment on column pld_sal_mat_mth_0202.m12_ton is 'M12 tonnes';
comment on column pld_sal_mat_mth_0202.m01_gsv is 'M01 gross sales value';
comment on column pld_sal_mat_mth_0202.m02_gsv is 'M02 gross sales value';
comment on column pld_sal_mat_mth_0202.m03_gsv is 'M03 gross sales value';
comment on column pld_sal_mat_mth_0202.m04_gsv is 'M04 gross sales value';
comment on column pld_sal_mat_mth_0202.m05_gsv is 'M05 gross sales value';
comment on column pld_sal_mat_mth_0202.m06_gsv is 'M06 gross sales value';
comment on column pld_sal_mat_mth_0202.m07_gsv is 'M07 gross sales value';
comment on column pld_sal_mat_mth_0202.m08_gsv is 'M08 gross sales value';
comment on column pld_sal_mat_mth_0202.m09_gsv is 'M09 gross sales value';
comment on column pld_sal_mat_mth_0202.m10_gsv is 'M10 gross sales value';
comment on column pld_sal_mat_mth_0202.m11_gsv is 'M11 gross sales value';
comment on column pld_sal_mat_mth_0202.m12_gsv is 'M12 gross sales value';
comment on column pld_sal_mat_mth_0202.m01_niv is 'M01 net invoice value';
comment on column pld_sal_mat_mth_0202.m02_niv is 'M02 net invoice value';
comment on column pld_sal_mat_mth_0202.m03_niv is 'M03 net invoice value';
comment on column pld_sal_mat_mth_0202.m04_niv is 'M04 net invoice value';
comment on column pld_sal_mat_mth_0202.m05_niv is 'M05 net invoice value';
comment on column pld_sal_mat_mth_0202.m06_niv is 'M06 net invoice value';
comment on column pld_sal_mat_mth_0202.m07_niv is 'M07 net invoice value';
comment on column pld_sal_mat_mth_0202.m08_niv is 'M08 net invoice value';
comment on column pld_sal_mat_mth_0202.m09_niv is 'M09 net invoice value';
comment on column pld_sal_mat_mth_0202.m10_niv is 'M10 net invoice value';
comment on column pld_sal_mat_mth_0202.m11_niv is 'M11 net invoice value';
comment on column pld_sal_mat_mth_0202.m12_niv is 'M12 net invoice value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_mat_mth_0202
   add constraint pld_sal_mat_mth_0202_pk primary key (sap_company_code,
                                                       sap_material_code,
                                                       dta_type);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_mat_mth_0202 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_mat_mth_0202 for pld_rep.pld_sal_mat_mth_0202;
