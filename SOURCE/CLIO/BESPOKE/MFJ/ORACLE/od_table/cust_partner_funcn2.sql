/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_partner_funcn2
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Partner Function 2 Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_partner_funcn2
   (sap_ship_to_cust_code           varchar2(10 char)    not null,
    sap_sold_to_cust_code           varchar2(10 char)    not null,
    sap_distbn_chnl_code            varchar2(2 char)     not null,
    sap_division_code               varchar2(2 char)     not null,
    sap_sales_org_code              varchar2(4 char)     not null,
    sap_hier_cust_code              varchar2(10 char)    not null);

/**/
/* Comments
/**/
comment on table od.cust_partner_funcn2 is 'Customer Partner Function 2 Table';
comment on column od.cust_partner_funcn2.sap_ship_to_cust_code is 'SAP Ship To Customer Code';
comment on column od.cust_partner_funcn2.sap_sold_to_cust_code is 'SAP Sold To Customer Code';
comment on column od.cust_partner_funcn2.sap_distbn_chnl_code is 'SAP Distribution Channel Code';
comment on column od.cust_partner_funcn2.sap_division_code is 'SAP Division Code';
comment on column od.cust_partner_funcn2.sap_sales_org_code is 'SAP Sales Org Code';
comment on column od.cust_partner_funcn2.sap_hier_cust_code is 'SAP Sales Force Hierarchy Customer Code';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_partner_funcn2
   add constraint cust_partner_funcn2_pk primary key (sap_ship_to_cust_code, sap_sold_to_cust_code, sap_distbn_chnl_code, sap_division_code, sap_sales_org_code);

/**/
/* Indexes
/**/
create index od.cust_partner_funcn2_ix01 on od.cust_partner_funcn2 (sap_hier_cust_code, sap_distbn_chnl_code, sap_division_code, sap_sales_org_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_partner_funcn2 to dw_app;
grant select on od.cust_partner_funcn2 to od_app with grant option;
grant select on od.cust_partner_funcn2 to od_user;
grant select on od.cust_partner_funcn2 to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_partner_funcn2 for od.cust_partner_funcn2;