/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_sal_mat_mth_0201                               */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_mat_mth_0201
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
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
    cur_rb_niv number not null,
    ytd_ty_qty number not null,
    ytd_ty_ton number not null,
    ytd_ty_gsv number not null,
    ytd_ty_niv number not null,
    ytd_ly_qty number not null,
    ytd_ly_ton number not null,
    ytd_ly_gsv number not null,
    ytd_ly_niv number not null,
    ytd_op_qty number not null,
    ytd_op_ton number not null,
    ytd_op_gsv number not null,
    ytd_op_niv number not null,
    ytg_ly_qty number not null,
    ytg_ly_ton number not null,
    ytg_ly_gsv number not null,
    ytg_ly_niv number not null,
    ytg_op_qty number not null,
    ytg_op_ton number not null,
    ytg_op_gsv number not null,
    ytg_op_niv number not null,
    ytg_br_qty number not null,
    ytg_br_ton number not null,
    ytg_br_gsv number not null,
    ytg_br_niv number not null,
    ytg_rb_qty number not null,
    ytg_rb_ton number not null,
    ytg_rb_gsv number not null,
    ytg_rb_niv number not null);

/**/
/* Comment */
/**/
comment on table pld_sal_mat_mth_0201 is 'Planning Sales Material 02 Month Header Table - Invoice Date';
comment on column pld_sal_mat_mth_0201.sap_company_code is 'SAP Company code';
comment on column pld_sal_mat_mth_0201.sap_material_code is 'SAP Material code';
comment on column pld_sal_mat_mth_0201.cur_ty_qty is 'Current period this year quantity';
comment on column pld_sal_mat_mth_0201.cur_ty_ton is 'Current period this year tonnes';
comment on column pld_sal_mat_mth_0201.cur_ty_gsv is 'Current period this year gross sales value';
comment on column pld_sal_mat_mth_0201.cur_ty_niv is 'Current period this year net invoice value';
comment on column pld_sal_mat_mth_0201.cur_ly_qty is 'Current period last year quantity';
comment on column pld_sal_mat_mth_0201.cur_ly_ton is 'Current period last year tonnes';
comment on column pld_sal_mat_mth_0201.cur_ly_gsv is 'Current period last year gross sales value';
comment on column pld_sal_mat_mth_0201.cur_ly_niv is 'Current period last year net invoice value';
comment on column pld_sal_mat_mth_0201.cur_op_qty is 'Current period operating plan quantity';
comment on column pld_sal_mat_mth_0201.cur_op_ton is 'Current period operating plan tonnes';
comment on column pld_sal_mat_mth_0201.cur_op_gsv is 'Current period operating plan gross sales value';
comment on column pld_sal_mat_mth_0201.cur_op_niv is 'Current period operating plan net invoice value';
comment on column pld_sal_mat_mth_0201.cur_br_qty is 'Current period business review quantity';
comment on column pld_sal_mat_mth_0201.cur_br_ton is 'Current period business review tonnes';
comment on column pld_sal_mat_mth_0201.cur_br_gsv is 'Current period business review gross sales value';
comment on column pld_sal_mat_mth_0201.cur_br_niv is 'Current period business review net invoice value';
comment on column pld_sal_mat_mth_0201.cur_rb_qty is 'Current period review of business quantity';
comment on column pld_sal_mat_mth_0201.cur_rb_ton is 'Current period review of business tonnes';
comment on column pld_sal_mat_mth_0201.cur_rb_gsv is 'Current period review of business gross sales value';
comment on column pld_sal_mat_mth_0201.cur_rb_niv is 'Current period review of business net invoice value';
comment on column pld_sal_mat_mth_0201.ytd_ty_qty is 'Year to date this year quantity';
comment on column pld_sal_mat_mth_0201.ytd_ty_ton is 'Year to date this year tonnes';
comment on column pld_sal_mat_mth_0201.ytd_ty_gsv is 'Year to date this year gross sales value';
comment on column pld_sal_mat_mth_0201.ytd_ty_niv is 'Year to date this year net invoice value';
comment on column pld_sal_mat_mth_0201.ytd_ly_qty is 'Year to date last year quantity';
comment on column pld_sal_mat_mth_0201.ytd_ly_ton is 'Year to date last year tonnes';
comment on column pld_sal_mat_mth_0201.ytd_ly_gsv is 'Year to date last year gross sales value';
comment on column pld_sal_mat_mth_0201.ytd_ly_niv is 'Year to date last year net invoice value';
comment on column pld_sal_mat_mth_0201.ytd_op_qty is 'Year to date operating plan quantity';
comment on column pld_sal_mat_mth_0201.ytd_op_ton is 'Year to date operating plan tonnes';
comment on column pld_sal_mat_mth_0201.ytd_op_gsv is 'Year to date operating plan gross sales value';
comment on column pld_sal_mat_mth_0201.ytd_op_niv is 'Year to date operating plan net invoice value';
comment on column pld_sal_mat_mth_0201.ytg_ly_qty is 'Year to go last year quantity';
comment on column pld_sal_mat_mth_0201.ytg_ly_ton is 'Year to go last year tonnes';
comment on column pld_sal_mat_mth_0201.ytg_ly_gsv is 'Year to go last year gross sales value';
comment on column pld_sal_mat_mth_0201.ytg_ly_niv is 'Year to go last year net invoice value';
comment on column pld_sal_mat_mth_0201.ytg_op_qty is 'Year to go operating plan quantity';
comment on column pld_sal_mat_mth_0201.ytg_op_ton is 'Year to go operating plan tonnes';
comment on column pld_sal_mat_mth_0201.ytg_op_gsv is 'Year to go operating plan gross sales value';
comment on column pld_sal_mat_mth_0201.ytg_op_niv is 'Year to go operating plan net invoice value';
comment on column pld_sal_mat_mth_0201.ytg_br_qty is 'Year to go business review quantity';
comment on column pld_sal_mat_mth_0201.ytg_br_ton is 'Year to go business review tonnes';
comment on column pld_sal_mat_mth_0201.ytg_br_gsv is 'Year to go business review gross sales value';
comment on column pld_sal_mat_mth_0201.ytg_br_niv is 'Year to go business review net invoice value';
comment on column pld_sal_mat_mth_0201.ytg_rb_qty is 'Year to go review of business quantity';
comment on column pld_sal_mat_mth_0201.ytg_rb_ton is 'Year to go review of business tonnes';
comment on column pld_sal_mat_mth_0201.ytg_rb_gsv is 'Year to go review of business gross sales value';
comment on column pld_sal_mat_mth_0201.ytg_rb_niv is 'Year to go review of business net invoice value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_mat_mth_0201
   add constraint pld_sal_mat_mth_0201_pk primary key (sap_company_code,
                                                       sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_mat_mth_0201 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_mat_mth_0201 for pld_rep.pld_sal_mat_mth_0201;
