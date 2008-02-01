/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format0203                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format0203
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    billing_YYYYPP number(6,0) not null,
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
    op_gsv number(22,0) not null,
    br_qty number(17,0) not null,
    br_ton number(17,6) not null,
    br_bps number(22,0) not null,
    br_gsv number(22,0) not null,
    le_qty number(17,0) not null,
    le_ton number(17,6) not null,
    le_bps number(22,0) not null,
    le_gsv number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format0203 is 'Planning Sales Format 02 Period Detail Table';
comment on column pld_sal_format0203.sap_company_code is 'SAP Company code';
comment on column pld_sal_format0203.sap_material_code is 'SAP Material code';
comment on column pld_sal_format0203.billing_YYYYPP is 'Billing period';
comment on column pld_sal_format0203.ty_qty is 'This year quantity';
comment on column pld_sal_format0203.ty_ton is 'This year tonnes';
comment on column pld_sal_format0203.ty_bps is 'This year base price sale';
comment on column pld_sal_format0203.ty_gsv is 'This year gross sales value';
comment on column pld_sal_format0203.ly_qty is 'Last year quantity';
comment on column pld_sal_format0203.ly_ton is 'Last year tonnes';
comment on column pld_sal_format0203.ly_bps is 'Last year base price sale';
comment on column pld_sal_format0203.ly_gsv is 'Last year gross sales value';
comment on column pld_sal_format0203.op_qty is 'Operating plan quantity';
comment on column pld_sal_format0203.op_ton is 'Operating plan tonnes';
comment on column pld_sal_format0203.op_bps is 'Operating plan base price sale';
comment on column pld_sal_format0203.op_gsv is 'Operating plan gross sales value';
comment on column pld_sal_format0203.br_qty is 'Business review quantity';
comment on column pld_sal_format0203.br_ton is 'Business review tonnes';
comment on column pld_sal_format0203.br_bps is 'Business review base price sale';
comment on column pld_sal_format0203.br_gsv is 'Business review gross sales value';
comment on column pld_sal_format0203.le_qty is 'Latest estimate quantity';
comment on column pld_sal_format0203.le_ton is 'Latest estimate tonnes';
comment on column pld_sal_format0203.le_bps is 'Latest estimate base price sale';
comment on column pld_sal_format0203.le_gsv is 'Latest estimate gross sales value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format0203
   add constraint pld_sal_format0203_pk primary key (sap_company_code, sap_material_code, billing_YYYYPP);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format0203 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format0203 for pld_rep.pld_sal_format0203;
