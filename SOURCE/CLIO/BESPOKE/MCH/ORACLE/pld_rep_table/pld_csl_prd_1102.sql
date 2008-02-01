/****************************************************************/
/* Table Definition                                             */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Object  : pld_csl_prd_1102                                   */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep                                            */
/* Date    : March 2006                                         */
/****************************************************************/

/**/
/* Table creation */
/**/
create table pld_csl_prd_1102
   (sap_company_code varchar2(6 char) not null,
    sap_ship_to_cust_code varchar2(10 char) not null,
    sap_sales_org_code varchar2(4 char) not null,
    sap_distbn_chnl_code varchar2(2 char) not null,
    sap_division_code varchar2(2 char) not null,
    ord_tot number not null,
    ord_fil number not null,
    ord_tim number not null,
    ord_prm_tot number not null,
    ord_prm_fil number not null,
    ord_prm_tim number not null);

/**/
/* Comment */
/**/
comment on table pld_csl_prd_1102 is 'Planning Customer Service Level 01 Period Order Fill Table - Billing Date';
comment on column pld_csl_prd_1102.sap_company_code is 'SAP Company code';
comment on column pld_csl_prd_1102.sap_ship_to_cust_code is 'SAP Ship To Customer code';
comment on column pld_csl_prd_1102.sap_sales_org_code is 'SAP Sales organisation code';
comment on column pld_csl_prd_1102.sap_distbn_chnl_code is 'SAP Distribution channel code';
comment on column pld_csl_prd_1102.sap_division_code is 'SAP Division code';
comment on column pld_csl_prd_1102.ord_tot is 'Order total';
comment on column pld_csl_prd_1102.ord_fil is 'Order filled';
comment on column pld_csl_prd_1102.ord_tim is 'Order on-time';
comment on column pld_csl_prd_1102.ord_prm_tot is 'Order promotional total';
comment on column pld_csl_prd_1102.ord_prm_fil is 'Order promotional filled';
comment on column pld_csl_prd_1102.ord_prm_tim is 'Order promotional on-time';

/**/
/* Primary Key Constraint */
/**/
alter table pld_csl_prd_1102
   add constraint pld_csl_prd_1102_pk primary key (sap_company_code,
                                                   sap_ship_to_cust_code,
                                                   sap_sales_org_code,
                                                   sap_distbn_chnl_code,
                                                   sap_division_code);

/**/
/* Authority */
/**/
grant select, insert, update, delete on pld_csl_prd_1102 to pld_rep_app;

/**/
/* Synonym */
/**/
create or replace public synonym pld_csl_prd_1102 for pld_rep.pld_csl_prd_1102;
