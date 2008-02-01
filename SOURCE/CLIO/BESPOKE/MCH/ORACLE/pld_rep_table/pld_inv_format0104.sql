/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Object  : pld_inv_format0104                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0104
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    billing_YYYYMM number(6,0) not null,
    br_qty number not null,
    rb_qty number not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0104 is 'Planning Inventory Format 03 Month Forecast Table';
comment on column pld_inv_format0104.sap_company_code is 'SAP Company code';
comment on column pld_inv_format0104.sap_material_code is 'SAP Material code';
comment on column pld_inv_format0104.billing_YYYYMM is 'Billing month';
comment on column pld_inv_format0104.br_qty is 'Month br quantity';
comment on column pld_inv_format0104.rb_qty is 'Month le quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_format0104
   add constraint pld_inv_format0104_pk primary key (sap_company_code, sap_material_code, billing_YYYYMM);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0104 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0104 for pld_rep.pld_inv_format0104;
