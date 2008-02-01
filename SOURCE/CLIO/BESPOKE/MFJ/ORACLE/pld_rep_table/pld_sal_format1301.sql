/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format1301                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format1301
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    tot_ty_qty number(17,0) not null,
    tot_ty_ton number(17,6) not null,
    tot_ty_bps number(22,0) not null,
    tot_ty_gsv number(22,0) not null,
    tot_ly_qty number(17,0) not null,
    tot_ly_ton number(17,6) not null,
    tot_ly_bps number(22,0) not null,
    tot_ly_gsv number(22,0) not null,
    tot_op_qty number(17,0) not null,
    tot_op_ton number(17,6) not null,
    tot_op_bps number(22,0) not null,
    tot_op_gsv number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format1301 is 'Planning Sales Format 13 Period Header Table';
comment on column pld_sal_format1301.sap_company_code is 'SAP Company code';
comment on column pld_sal_format1301.sap_material_code is 'SAP Material code';
comment on column pld_sal_format1301.tot_ty_qty is 'Total this year quantity';
comment on column pld_sal_format1301.tot_ty_ton is 'Total this year tonnes';
comment on column pld_sal_format1301.tot_ty_bps is 'Total this year base price sale';
comment on column pld_sal_format1301.tot_ty_gsv is 'Total this year gross sales value';
comment on column pld_sal_format1301.tot_ly_qty is 'Total last year quantity';
comment on column pld_sal_format1301.tot_ly_ton is 'Total last year tonnes';
comment on column pld_sal_format1301.tot_ly_bps is 'Total last year base price sale';
comment on column pld_sal_format1301.tot_ly_gsv is 'Total last year gross sales value';
comment on column pld_sal_format1301.tot_op_qty is 'Total operating plan quantity';
comment on column pld_sal_format1301.tot_op_ton is 'Total operating plan tonnes';
comment on column pld_sal_format1301.tot_op_bps is 'Total operating plan base price sale';
comment on column pld_sal_format1301.tot_op_gsv is 'Total operating plan gross sales value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format1301
   add constraint pld_sal_format1301_pk primary key (sap_company_code, sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format1301 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format1301 for pld_rep.pld_sal_format1301;
