/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Object  : pld_sal_format0401                                 */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : June 2004                                          */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_sal_format0401
   (sap_company_code varchar2(6 char) not null,
    sap_hier_cust_code varchar2(10 char) not null,
    sap_sales_org_code varchar2(4 char) not null,
    sap_distbn_chnl_code varchar2(2 char) not null,
    sap_division_code varchar2(2 char) not null,
    sap_material_code varchar2(18 char) not null,
    cur_billed_qty number(17,0) not null,
    cur_billed_bps number(22,0) not null,
    cur_op_qty number(17,0) not null,
    cur_br_qty number(17,0) not null,
    cur_le_qty number(17,0) not null,
    cur_op_bps number(22,0) not null,
    cur_br_bps number(22,0) not null,
    cur_le_bps number(22,0) not null,
    ytd_billed_qty number(17,0) not null,
    ytd_billed_bps number(22,0) not null,
    ytd_op_qty number(17,0) not null,
    ytd_br_qty number(17,0) not null,
    ytd_le_qty number(17,0) not null,
    ytd_op_bps number(22,0) not null,
    ytd_br_bps number(22,0) not null,
    ytd_le_bps number(22,0) not null,
    ytg_op_qty number(17,0) not null,
    ytg_br_qty number(17,0) not null,
    ytg_le_qty number(17,0) not null,
    ytg_op_bps number(22,0) not null,
    ytg_br_bps number(22,0) not null,
    ytg_le_bps number(22,0) not null);

/**/
/* Comment */
/**/
comment on table pld_sal_format0401 is 'Planning Sales Format 04 Period Header Table';
comment on column pld_sal_format0401.sap_company_code is 'SAP Company code';
comment on column pld_sal_format0401.sap_hier_cust_code is 'SAP Hierarchy Customer code';
comment on column pld_sal_format0401.sap_sales_org_code is 'SAP Sales organisation code';
comment on column pld_sal_format0401.sap_distbn_chnl_code is 'SAP Distribution channel code';
comment on column pld_sal_format0401.sap_division_code is 'SAP Division code';
comment on column pld_sal_format0401.sap_material_code is 'SAP Material code';
comment on column pld_sal_format0401.cur_billed_qty is 'Current period billed quantity';
comment on column pld_sal_format0401.cur_billed_bps is 'Current period billed base price value';
comment on column pld_sal_format0401.cur_op_qty is 'Current period operating plan quantity';
comment on column pld_sal_format0401.cur_br_qty is 'Current period business review quantity';
comment on column pld_sal_format0401.cur_le_qty is 'Current period latest estimate quantity';
comment on column pld_sal_format0401.cur_op_bps is 'Current period operating plan base price value';
comment on column pld_sal_format0401.cur_br_bps is 'Current period business review base price value';
comment on column pld_sal_format0401.cur_le_bps is 'Current period latest estimate base price value';
comment on column pld_sal_format0401.ytd_billed_qty is 'Year to date billed quantity';
comment on column pld_sal_format0401.ytd_billed_bps is 'Year to date billed base price value';
comment on column pld_sal_format0401.ytd_op_qty is 'Year to date operating plan quantity';
comment on column pld_sal_format0401.ytd_br_qty is 'Year to date business review quantity';
comment on column pld_sal_format0401.ytd_le_qty is 'Year to date latest estimate quantity';
comment on column pld_sal_format0401.ytd_op_bps is 'Year to date operating plan base price value';
comment on column pld_sal_format0401.ytd_br_bps is 'Year to date business review base price value';
comment on column pld_sal_format0401.ytd_le_bps is 'Year to date latest estimate base price value';
comment on column pld_sal_format0401.ytg_op_qty is 'Year to go operating plan quantity';
comment on column pld_sal_format0401.ytg_br_qty is 'Year to go business review quantity';
comment on column pld_sal_format0401.ytg_le_qty is 'Year to go latest estimate quantity';
comment on column pld_sal_format0401.ytg_op_bps is 'Year to go operating plan base price value';
comment on column pld_sal_format0401.ytg_br_bps is 'Year to go business review base price value';
comment on column pld_sal_format0401.ytg_le_bps is 'Year to go latest estimate base price value';

/**/
/* Primary Key Constraint */
/**/
alter table pld_sal_format0401
   add constraint pld_sal_format0401_pk primary key (sap_company_code, sap_hier_cust_code, sap_sales_org_code, sap_distbn_chnl_code, sap_division_code, sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_sal_format0401 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_sal_format0401 for pld_rep.pld_sal_format0401;
