/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format0303                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format0303
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
    op_gsv number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format0303 is 'Planning Sales Format 03 Period Detail Table';
comment on column pld_sal_format0303.sap_company_code is 'SAP Company code';
comment on column pld_sal_format0303.sap_material_code is 'SAP Material code';
comment on column pld_sal_format0303.billing_YYYYPP is 'Billing period';
comment on column pld_sal_format0303.ty_qty is 'This year quantity';
comment on column pld_sal_format0303.ty_ton is 'This year tonnes';
comment on column pld_sal_format0303.ty_bps is 'This year base price sale';
comment on column pld_sal_format0303.ty_gsv is 'This year gross sales value';
comment on column pld_sal_format0303.ly_qty is 'Last year quantity';
comment on column pld_sal_format0303.ly_ton is 'Last year tonnes';
comment on column pld_sal_format0303.ly_bps is 'Last year base price sale';
comment on column pld_sal_format0303.ly_gsv is 'Last year gross sales value';
comment on column pld_sal_format0303.op_qty is 'Operating plan quantity';
comment on column pld_sal_format0303.op_ton is 'Operating plan tonnes';
comment on column pld_sal_format0303.op_bps is 'Operating plan base price sale';
comment on column pld_sal_format0303.op_gsv is 'Operating plan gross sales value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format0303
   add constraint pld_sal_format0303_pk primary key (sap_company_code, sap_material_code, billing_YYYYPP);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format0303 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format0303 for pld_rep.pld_sal_format0303;
