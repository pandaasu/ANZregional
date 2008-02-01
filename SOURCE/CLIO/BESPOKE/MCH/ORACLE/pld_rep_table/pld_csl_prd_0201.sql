/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_csl_prd_0201                                   */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_csl_prd_0201
   (sap_company_code varchar2(6 char) not null,
    sap_ship_to_cust_code varchar2(10 char) not null,
    sap_sales_org_code varchar2(4 char) not null,
    sap_distbn_chnl_code varchar2(2 char) not null,
    sap_division_code varchar2(2 char) not null,
    sap_material_code varchar2(18 char) not null,
    ord_qty number not null,
    del_qty number not null,
    pod_qty number not null);

/**/
/* Comment */
/**/
comment on table pld_csl_prd_0201 is 'Planning Customer Service Level 01 Period Case Fill Table - Invoice Date';
comment on column pld_csl_prd_0201.sap_company_code is 'SAP Company code';
comment on column pld_csl_prd_0201.sap_ship_to_cust_code is 'SAP Ship To Customer code';
comment on column pld_csl_prd_0201.sap_sales_org_code is 'SAP Sales organisation code';
comment on column pld_csl_prd_0201.sap_distbn_chnl_code is 'SAP Distribution channel code';
comment on column pld_csl_prd_0201.sap_division_code is 'SAP Division code';
comment on column pld_csl_prd_0201.sap_material_code is 'SAP Material code';
comment on column pld_csl_prd_0201.ord_qty is 'Order quantity';
comment on column pld_csl_prd_0201.del_qty is 'Delivered quantity';
comment on column pld_csl_prd_0201.pod_qty is 'POD quantity';

/**/
/* Primary Key Constraint */
/**/
alter table pld_csl_prd_0201
   add constraint pld_csl_prd_0201_pk primary key (sap_company_code,
                                                   sap_ship_to_cust_code,
                                                   sap_sales_org_code,
                                                   sap_distbn_chnl_code,
                                                   sap_division_code,
                                                   sap_material_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_csl_prd_0201 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_csl_prd_0201 for pld_rep.pld_csl_prd_0201;
