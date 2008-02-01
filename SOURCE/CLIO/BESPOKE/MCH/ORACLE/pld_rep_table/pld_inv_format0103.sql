/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Object  : pld_inv_format0103                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0103
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    billing_YYYYPP number(6,0) not null,
    br_qty number not null,
    rb_qty number not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0103 is 'Planning Inventory Format 03 Period Forecast Table';
comment on column pld_inv_format0103.sap_company_code is 'SAP Company code';
comment on column pld_inv_format0103.sap_material_code is 'SAP Material code';
comment on column pld_inv_format0103.billing_YYYYPP is 'Billing period';
comment on column pld_inv_format0103.br_qty is 'Period br quantity';
comment on column pld_inv_format0103.rb_qty is 'Period rb quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_format0103
   add constraint pld_inv_format0103_pk primary key (sap_company_code, sap_material_code, billing_YYYYPP);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0103 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0103 for pld_rep.pld_inv_format0103;
