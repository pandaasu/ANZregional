/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_sal_cus_mth_1301                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_cus_mth_1301
   (sap_company_code varchar2(6 char) not null,
    sap_ship_to_cust_code varchar2(10 char) not null,
    sap_sales_org_code varchar2(4 char) not null,
    sap_distbn_chnl_code varchar2(2 char) not null,
    sap_division_code varchar2(2 char) not null,
    sap_material_code varchar2(18 char) not null,
    tot_ty_qty number not null,
    tot_ty_ton number not null,
    tot_ty_gsv number not null,
    tot_ty_niv number not null,
    tot_ly_qty number not null,
    tot_ly_ton number not null,
    tot_ly_gsv number not null,
    tot_ly_niv number not null,
    tot_op_qty number not null,
    tot_op_ton number not null,
    tot_op_gsv number not null,
    tot_op_niv number not null);

/**/
/* Comment */
/**/
comment on table pld_sal_cus_mth_1301 is 'Planning Sales Customer 13 Month Header Table - Billing Date';
comment on column pld_sal_cus_mth_1301.sap_company_code is 'SAP Company code';
comment on column pld_sal_cus_mth_1301.sap_ship_to_cust_code is 'SAP Ship To Customer code';
comment on column pld_sal_cus_mth_1301.sap_sales_org_code is 'SAP Sales organisation code';
comment on column pld_sal_cus_mth_1301.sap_distbn_chnl_code is 'SAP Distribution channel code';
comment on column pld_sal_cus_mth_1301.sap_division_code is 'SAP Division code';
comment on column pld_sal_cus_mth_1301.sap_material_code is 'SAP Material code';
comment on column pld_sal_cus_mth_1301.tot_ty_ton is 'Total this year tonnes';
comment on column pld_sal_cus_mth_1301.tot_ty_gsv is 'Total this year gross sales value';
comment on column pld_sal_cus_mth_1301.tot_ty_niv is 'Total this year net invoice value';
comment on column pld_sal_cus_mth_1301.tot_ly_qty is 'Total last year quantity';
comment on column pld_sal_cus_mth_1301.tot_ly_ton is 'Total last year tonnes';
comment on column pld_sal_cus_mth_1301.tot_ly_gsv is 'Total last year gross sales value';
comment on column pld_sal_cus_mth_1301.tot_ly_niv is 'Total last year net invoice value';
comment on column pld_sal_cus_mth_1301.tot_op_qty is 'Total operating plan quantity';
comment on column pld_sal_cus_mth_1301.tot_op_ton is 'Total operating plan tonnes';
comment on column pld_sal_cus_mth_1301.tot_op_gsv is 'Total operating plan gross sales value';
comment on column pld_sal_cus_mth_1301.tot_op_niv is 'Total operating plan net invoice value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_cus_mth_1301
   add constraint pld_sal_cus_mth_1301_pk primary key (sap_company_code,
                                                       sap_ship_to_cust_code,
                                                       sap_sales_org_code,
                                                       sap_distbn_chnl_code,
                                                       sap_division_code,
                                                       sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_cus_mth_1301 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_cus_mth_1301 for pld_rep.pld_sal_cus_mth_1301;
