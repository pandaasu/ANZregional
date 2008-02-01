/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format1304                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : October 2005                                       */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format1304
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    billing_YYYYMM number(6,0) not null,
    ty_qty number(17,0) not null,
    ty_ton number(17,6) not null,
    ty_bps number(22,0) not null,
    ty_gsv number(22,0) not null,
    ly_qty number(17,0) not null,
    ly_ton number(17,6) not null,
    ly_bps number(22,0) not null,
    ly_gsv number(22,0) not null,
    op_qty number(17,0) not null,
    op_ton number(17,6) not null,
    op_bps number(22,0) not null,
    op_gsv number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format1304 is 'Planning Sales Format 13 Month Detail Table';
comment on column pld_sal_format1304.sap_company_code is 'SAP Company code';
comment on column pld_sal_format1304.sap_material_code is 'SAP Material code';
comment on column pld_sal_format1304.billing_YYYYMM is 'Billing month';
comment on column pld_sal_format1304.ty_qty is 'This year quantity';
comment on column pld_sal_format1304.ty_ton is 'This year tonnes';
comment on column pld_sal_format1304.ty_bps is 'This year base price sale';
comment on column pld_sal_format1304.ty_gsv is 'This year gross sales value';
comment on column pld_sal_format1304.ly_qty is 'Last year quantity';
comment on column pld_sal_format1304.ly_ton is 'Last year tonnes';
comment on column pld_sal_format1304.ly_bps is 'Last year base price sale';
comment on column pld_sal_format1304.ly_gsv is 'Last year gross sales value';
comment on column pld_sal_format1304.op_qty is 'Operating plan quantity';
comment on column pld_sal_format1304.op_ton is 'Operating plan tonnes';
comment on column pld_sal_format1304.op_bps is 'Operating plan base price sale';
comment on column pld_sal_format1304.op_gsv is 'Operating plan gross sales value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format1304
   add constraint pld_sal_format1304_pk primary key (sap_company_code, sap_material_code, billing_YYYYMM);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format1304 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format1304 for pld_rep.pld_sal_format1304;
