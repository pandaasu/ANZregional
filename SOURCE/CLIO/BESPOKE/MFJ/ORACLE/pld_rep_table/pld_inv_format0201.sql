/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_inv_format0201                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2003                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_inv_format0201
   (sap_company_code varchar2(6 char) not null,
    sap_material_code varchar2(18 char) not null,
    prd_op_qty number(22,0) not null,
    prd_br_qty number(22,0) not null,
    prd_le_qty number(22,0) not null,
    mth_op_qty number(22,0) not null,
    mth_br_qty number(22,0) not null,
    mth_le_qty number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_inv_format0201 is 'Planning Inventory Format 02 Forecast Table';
comment on column pld_inv_format0201.sap_company_code is 'SAP Company code';
comment on column pld_inv_format0201.sap_material_code is 'SAP Material code';
comment on column pld_inv_format0201.prd_op_qty is 'Period op quantity';
comment on column pld_inv_format0201.prd_br_qty is 'Period br quantity';
comment on column pld_inv_format0201.prd_le_qty is 'Period le quantity';
comment on column pld_inv_format0201.mth_op_qty is 'Month op quantity';
comment on column pld_inv_format0201.mth_br_qty is 'Month br quantity';
comment on column pld_inv_format0201.mth_le_qty is 'Month le quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_inv_format0201
   add constraint pld_inv_format0201_pk primary key (sap_company_code, sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_inv_format0201 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_inv_format0201 for pld_rep.pld_inv_format0201;
