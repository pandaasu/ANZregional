/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_sal_cus_mth_0101                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_cus_mth_0101
   (sap_company_code varchar2(6 char) not null,
    sap_ship_to_cust_code varchar2(10 char) not null,
    sap_sales_org_code varchar2(4 char) not null,
    sap_distbn_chnl_code varchar2(2 char) not null,
    sap_division_code varchar2(2 char) not null,
    sap_material_code varchar2(18 char) not null,
    ord_uc_qty number not null,
    ord_uc_ton number not null,
    ord_uc_gsv number not null,
    ord_uc_niv number not null,
    ord_cn_qty number not null,
    ord_cn_ton number not null,
    ord_cn_gsv number not null,
    ord_cn_niv number not null,
    cur_dy_qty number not null,
    cur_dy_ton number not null,
    cur_dy_gsv number not null,
    cur_dy_niv number not null,
    cur_ty_qty number not null,
    cur_ty_ton number not null,
    cur_ty_gsv number not null,
    cur_ty_niv number not null,
    cur_ly_qty number not null,
    cur_ly_ton number not null,
    cur_ly_gsv number not null,
    cur_ly_niv number not null,
    cur_op_qty number not null,
    cur_op_ton number not null,
    cur_op_gsv number not null,
    cur_op_niv number not null,
    cur_br_qty number not null,
    cur_br_ton number not null,
    cur_br_gsv number not null,
    cur_br_niv number not null,
    cur_rb_qty number not null,
    cur_rb_ton number not null,
    cur_rb_gsv number not null,
    cur_rb_niv number not null);

/**/
/* Comment */
/**/
comment on table pld_sal_cus_mth_0101 is 'Planning Sales Customer 01 Month Header Table - Invoice Date';
comment on column pld_sal_cus_mth_0101.sap_company_code is 'SAP Company code';
comment on column pld_sal_cus_mth_0101.sap_ship_to_cust_code is 'SAP Ship To Customer code';
comment on column pld_sal_cus_mth_0101.sap_sales_org_code is 'SAP Sales organisation code';
comment on column pld_sal_cus_mth_0101.sap_distbn_chnl_code is 'SAP Distribution channel code';
comment on column pld_sal_cus_mth_0101.sap_division_code is 'SAP Division code';
comment on column pld_sal_cus_mth_0101.sap_material_code is 'SAP Material code';
comment on column pld_sal_cus_mth_0101.ord_uc_qty is 'Order unconfirmed quantity';
comment on column pld_sal_cus_mth_0101.ord_uc_ton is 'Order unconfirmed tonnes';
comment on column pld_sal_cus_mth_0101.ord_uc_gsv is 'Order unconfirmed gross sales value';
comment on column pld_sal_cus_mth_0101.ord_uc_niv is 'Order unconfirmed net invoice value';
comment on column pld_sal_cus_mth_0101.ord_cn_qty is 'Order confirmed quantity';
comment on column pld_sal_cus_mth_0101.ord_cn_ton is 'Order confirmed tonnes';
comment on column pld_sal_cus_mth_0101.ord_cn_gsv is 'Order confirmed gross sales value';
comment on column pld_sal_cus_mth_0101.ord_cn_niv is 'Order confirmed net invoice value';
comment on column pld_sal_cus_mth_0101.cur_dy_qty is 'Current day quantity';
comment on column pld_sal_cus_mth_0101.cur_dy_ton is 'Current day tonnes';
comment on column pld_sal_cus_mth_0101.cur_dy_gsv is 'Current day gross sales value';
comment on column pld_sal_cus_mth_0101.cur_dy_niv is 'Current day net invoice value';
comment on column pld_sal_cus_mth_0101.cur_ty_qty is 'Current period this year quantity';
comment on column pld_sal_cus_mth_0101.cur_ty_ton is 'Current period this year tonnes';
comment on column pld_sal_cus_mth_0101.cur_ty_gsv is 'Current period this year gross sales value';
comment on column pld_sal_cus_mth_0101.cur_ty_niv is 'Current period this year net invoice value';
comment on column pld_sal_cus_mth_0101.cur_ly_qty is 'Current period last year quantity';
comment on column pld_sal_cus_mth_0101.cur_ly_ton is 'Current period last year tonnes';
comment on column pld_sal_cus_mth_0101.cur_ly_gsv is 'Current period last year gross sales value';
comment on column pld_sal_cus_mth_0101.cur_ly_niv is 'Current period last year net invoice value';
comment on column pld_sal_cus_mth_0101.cur_op_qty is 'Current period operating plan quantity';
comment on column pld_sal_cus_mth_0101.cur_op_ton is 'Current period operating plan tonnes';
comment on column pld_sal_cus_mth_0101.cur_op_gsv is 'Current period operating plan gross sales value';
comment on column pld_sal_cus_mth_0101.cur_op_niv is 'Current period operating plan net invoice value';
comment on column pld_sal_cus_mth_0101.cur_br_qty is 'Current period business review quantity';
comment on column pld_sal_cus_mth_0101.cur_br_ton is 'Current period business review tonnes';
comment on column pld_sal_cus_mth_0101.cur_br_gsv is 'Current period business review gross sales value';
comment on column pld_sal_cus_mth_0101.cur_br_niv is 'Current period business review net invoice value';
comment on column pld_sal_cus_mth_0101.cur_rb_qty is 'Current period review of business quantity';
comment on column pld_sal_cus_mth_0101.cur_rb_ton is 'Current period review of business tonnes';
comment on column pld_sal_cus_mth_0101.cur_rb_gsv is 'Current period review of business gross sales value';
comment on column pld_sal_cus_mth_0101.cur_rb_niv is 'Current period review of business net invoice value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_cus_mth_0101
   add constraint pld_sal_cus_mth_0101_pk primary key (sap_company_code,
                                                       sap_ship_to_cust_code,
                                                       sap_sales_org_code,
                                                       sap_distbn_chnl_code,
                                                       sap_division_code,
                                                       sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_cus_mth_0101 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_cus_mth_0101 for pld_rep.pld_sal_cus_mth_0101;
