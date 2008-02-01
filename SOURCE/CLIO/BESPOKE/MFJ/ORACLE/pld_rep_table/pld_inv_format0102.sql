/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_inv_format0102                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0102
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    sap_plant_code varchar2(4 char) not null,
    inv_sal_qty number(22,3) not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0102 is 'Planning Inventory Format 02 Warehouse Table';
comment on column pld_inv_format0102.sap_company_code is 'SAP Company code';
comment on column pld_inv_format0102.sap_material_code is 'SAP Material code';
comment on column pld_inv_format0102.sap_plant_code is 'SAP plant code';
comment on column pld_inv_format0102.inv_sal_qty is 'Saleable inventory quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_format0102
   add constraint pld_inv_format0102_pk primary key (sap_company_code, sap_material_code, sap_plant_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0102 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0102 for pld_rep.pld_inv_format0102;
