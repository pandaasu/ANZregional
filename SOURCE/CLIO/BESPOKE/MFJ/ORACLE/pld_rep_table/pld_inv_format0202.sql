/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_inv_format0202                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0202
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    sap_plant_code varchar2(4 char) not null,
    inv_exp_date date not null,
    inv_unr_qty number(22,0) not null,
    inv_unr_val number(22,0) not null,
    inv_res_qty number(22,0) not null,
    inv_res_val number(22,0) not null,
    inv_class01 varchar2(3 char) not null,
    inv_class02 varchar2(3 char) not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0202 is 'Planning Inventory Format 02 Inventory Table';
comment on column pld_inv_format0202.sap_company_code is 'SAP Company code';
comment on column pld_inv_format0202.sap_material_code is 'SAP Material code';
comment on column pld_inv_format0202.sap_plant_code is 'SAP plant code';
comment on column pld_inv_format0202.inv_exp_date is 'Expiry date - 01011900=blank, 02011900=01019999';
comment on column pld_inv_format0202.inv_unr_qty is 'Unrestricted inventory quantity';
comment on column pld_inv_format0202.inv_unr_val is 'Unrestricted inventory value';
comment on column pld_inv_format0202.inv_res_qty is 'Restricted inventory quantity';
comment on column pld_inv_format0202.inv_res_val is 'Restricted inventory value';
comment on column pld_inv_format0202.inv_class01 is 'Inventory classification 01 - C01=Available, C02=Warning, C03=Ageing';
comment on column pld_inv_format0202.inv_class02 is 'Inventory classification 02 - C01=Available/Warning, C02=Ageing';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_format0202
   add constraint pld_inv_format0202_pk primary key (sap_company_code, sap_material_code, sap_plant_code, inv_exp_date);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0202 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0202 for pld_rep.pld_inv_format0202;
