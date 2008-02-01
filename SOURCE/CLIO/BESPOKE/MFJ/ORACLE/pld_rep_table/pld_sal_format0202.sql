/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format0202                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format0202
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    ytd_ty_qty number(17,0) not null,
    ytd_ty_ton number(17,6) not null,
    ytd_ty_bps number(22,0) not null,
    ytd_ty_gsv number(22,0) not null,
    ytd_ly_qty number(17,0) not null,
    ytd_ly_ton number(17,6) not null,
    ytd_ly_bps number(22,0) not null,
    ytd_ly_gsv number(22,0) not null,
    ytd_op_qty number(17,0) not null,
    ytd_op_ton number(17,6) not null,
    ytd_op_bps number(22,0) not null,
    ytd_op_gsv number(22,0) not null,
    ytd_br_qty number(17,0) not null,
    ytd_br_ton number(17,6) not null,
    ytd_br_bps number(22,0) not null,
    ytd_br_gsv number(22,0) not null,
    ytd_le_qty number(17,0) not null,
    ytd_le_ton number(17,6) not null,
    ytd_le_bps number(22,0) not null,
    ytd_le_gsv number(22,0) not null,
    ytg_ly_qty number(17,0) not null,
    ytg_ly_ton number(17,6) not null,
    ytg_ly_bps number(22,0) not null,
    ytg_ly_gsv number(22,0) not null,
    ytg_op_qty number(17,0) not null,
    ytg_op_ton number(17,6) not null,
    ytg_op_bps number(22,0) not null,
    ytg_op_gsv number(22,0) not null,
    ytg_br_qty number(17,0) not null,
    ytg_br_ton number(17,6) not null,
    ytg_br_bps number(22,0) not null,
    ytg_br_gsv number(22,0) not null,
    ytg_le_qty number(17,0) not null,
    ytg_le_ton number(17,6) not null,
    ytg_le_bps number(22,0) not null,
    ytg_le_gsv number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format0202 is 'Planning Sales Format 02 Month Header Table';
comment on column pld_sal_format0202.sap_company_code is 'SAP Company code';
comment on column pld_sal_format0202.sap_material_code is 'SAP Material code';
comment on column pld_sal_format0202.ytd_ty_qty is 'Year to date this year quantity';
comment on column pld_sal_format0202.ytd_ty_ton is 'Year to date this year tonnes';
comment on column pld_sal_format0202.ytd_ty_bps is 'Year to date this year base price sale';
comment on column pld_sal_format0202.ytd_ty_gsv is 'Year to date this year gross sales value';
comment on column pld_sal_format0202.ytd_ly_qty is 'Year to date last year quantity';
comment on column pld_sal_format0202.ytd_ly_ton is 'Year to date last year tonnes';
comment on column pld_sal_format0202.ytd_ly_bps is 'Year to date last year base price sale';
comment on column pld_sal_format0202.ytd_ly_gsv is 'Year to date last year gross sales value';
comment on column pld_sal_format0202.ytd_op_qty is 'Year to date operating plan quantity';
comment on column pld_sal_format0202.ytd_op_ton is 'Year to date operating plan tonnes';
comment on column pld_sal_format0202.ytd_op_bps is 'Year to date operating plan base price sale';
comment on column pld_sal_format0202.ytd_op_gsv is 'Year to date operating plan gross sales value';
comment on column pld_sal_format0202.ytd_br_qty is 'Year to date business review quantity';
comment on column pld_sal_format0202.ytd_br_ton is 'Year to date business review tonnes';
comment on column pld_sal_format0202.ytd_br_bps is 'Year to date business review base price sale';
comment on column pld_sal_format0202.ytd_br_gsv is 'Year to date business review gross sales value';
comment on column pld_sal_format0202.ytd_le_qty is 'Year to date latest estimate quantity';
comment on column pld_sal_format0202.ytd_le_ton is 'Year to date latest estimate tonnes';
comment on column pld_sal_format0202.ytd_le_bps is 'Year to date latest estimate base price sale';
comment on column pld_sal_format0202.ytd_le_gsv is 'Year to date latest estimate gross sales value';
comment on column pld_sal_format0202.ytg_ly_qty is 'Year to go last year quantity';
comment on column pld_sal_format0202.ytg_ly_ton is 'Year to go last year tonnes';
comment on column pld_sal_format0202.ytg_ly_bps is 'Year to go last year base price sale';
comment on column pld_sal_format0202.ytg_ly_gsv is 'Year to go last year gross sales value';
comment on column pld_sal_format0202.ytg_op_qty is 'Year to go operating plan quantity';
comment on column pld_sal_format0202.ytg_op_ton is 'Year to go operating plan tonnes';
comment on column pld_sal_format0202.ytg_op_bps is 'Year to go operating plan base price sale';
comment on column pld_sal_format0202.ytg_op_gsv is 'Year to go operating plan gross sales value';
comment on column pld_sal_format0202.ytg_br_qty is 'Year to go business review quantity';
comment on column pld_sal_format0202.ytg_br_ton is 'Year to go business review tonnes';
comment on column pld_sal_format0202.ytg_br_bps is 'Year to go business review base price sale';
comment on column pld_sal_format0202.ytg_br_gsv is 'Year to go business review gross sales value';
comment on column pld_sal_format0202.ytg_le_qty is 'Year to go latest estimate quantity';
comment on column pld_sal_format0202.ytg_le_ton is 'Year to go latest estimate tonnes';
comment on column pld_sal_format0202.ytg_le_bps is 'Year to go latest estimate base price sale';
comment on column pld_sal_format0202.ytg_le_gsv is 'Year to go latest estimate gross sales value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format0202
   add constraint pld_sal_format0202_pk primary key (sap_company_code, sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format0202 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format0202 for pld_rep.pld_sal_format0202;
