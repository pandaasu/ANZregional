/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cad_sales_force_geo_hier
 Owner  : CAD

 Description
 -----------
 China Application Data - Sales Force Geography Hierarchy Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created

*******************************************************************************/


drop table cad_sales_force_geo_hier;

/**/
/* Table creation
/**/
create table cad.cad_sales_force_geo_hier
   (sap_hier_cust_code              varchar2(10 char)  not null,
    sap_sales_org_code              varchar2(4 char)   not null,
    sap_distbn_chnl_code            varchar2(2 char)   not null,
    sap_division_code               varchar2(2 char)   not null,
    sap_cust_code_level_1           varchar2(10 char)  not null,
    cust_name_en_level_1            varchar2(40 char)  null,
    sap_sales_org_code_level_1      varchar2(4 char)   not null,
    sap_distbn_chnl_code_level_1    varchar2(2 char)   not null,
    sap_division_code_level_1       varchar2(2 char)   not null,
    cust_hier_sort_level_1          varchar2(10 char)  null,
    sap_cust_code_level_2           varchar2(10 char)  null,
    cust_name_en_level_2            varchar2(40 char)  null,
    sap_sales_org_code_level_2      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_2    varchar2(2 char)   null,
    sap_division_code_level_2       varchar2(2 char)   null,
    cust_hier_sort_level_2          varchar2(10 char)  null,
    sap_cust_code_level_3           varchar2(10 char)  null,
    cust_name_en_level_3            varchar2(40 char)  null,
    sap_sales_org_code_level_3      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_3    varchar2(2 char)   null,
    sap_division_code_level_3       varchar2(2 char)   null,
    cust_hier_sort_level_3          varchar2(10 char)  null,
    sap_cust_code_level_4           varchar2(10 char)  null,
    cust_name_en_level_4            varchar2(40 char)  null,
    sap_sales_org_code_level_4      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_4    varchar2(2 char)   null,
    sap_division_code_level_4       varchar2(2 char)   null,
    cust_hier_sort_level_4          varchar2(10 char)  null,
    sap_cust_code_level_5           varchar2(10 char)  null,
    cust_name_en_level_5            varchar2(40 char)  null,
    sap_sales_org_code_level_5      varchar2(4 char)   null, 
    sap_distbn_chnl_code_level_5    varchar2(2 char)   null,
    sap_division_code_level_5       varchar2(2 char)   null,
    cust_hier_sort_level_5          varchar2(10 char)  null,
    sap_cust_code_level_6           varchar2(10 char)  null,
    cust_name_en_level_6            varchar2(40 char)  null,
    sap_sales_org_code_level_6      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_6    varchar2(2 char)   null,
    sap_division_code_level_6       varchar2(2 char)   null,
    cust_hier_sort_level_6          varchar2(10 char)  null,
    sap_cust_code_level_7           varchar2(10 char)  null,
    cust_name_en_level_7            varchar2(40 char)  null,
    sap_sales_org_code_level_7      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_7    varchar2(2 char)   null,
    sap_division_code_level_7       varchar2(2 char)   null,
    cust_hier_sort_level_7          varchar2(10 char)  null,
    sap_cust_code_level_8           varchar2(10 char)  null,
    cust_name_en_level_8            varchar2(40 char)  null,
    sap_sales_org_code_level_8      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_8    varchar2(2 char)   null,
    sap_division_code_level_8       varchar2(2 char)   null,
    cust_hier_sort_level_8          varchar2(10 char)  null,
    sap_cust_code_level_9           varchar2(10 char)  null,
    cust_name_en_level_9            varchar2(40 char)  null,
    sap_sales_org_code_level_9      varchar2(4 char)   null,
    sap_distbn_chnl_code_level_9    varchar2(2 char)   null,
    sap_division_code_level_9       varchar2(2 char)   null,
    cust_hier_sort_level_9          varchar2(10 char)  null,
    sap_cust_code_level_10          varchar2(10 char)  null,
    cust_name_en_level_10           varchar2(40 char)  null,
    sap_sales_org_code_level_10     varchar2(4 char)   null,
    sap_distbn_chnl_code_level_10   varchar2(2 char)   null,
    sap_division_code_level_10      varchar2(2 char)   null,
    cust_hier_sort_level_10         varchar2(10 char)  null,
    cad_load_date                   date               not null);

/**/
/* Comments
/**/
comment on table cad.cad_sales_force_geo_hier is 'Sales Force Geography Hierarchy Table';
comment on column cad.cad_sales_force_geo_hier.sap_hier_cust_code is 'SAP Sales Force Geography Hierarchy Customer Code';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code is 'SAP Sales Organisation Code';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code is 'SAP Distribution Channel Code';
comment on column cad.cad_sales_force_geo_hier.sap_division_code is 'SAP Division Code';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_1 is 'SAP Customer Code Level 1';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_1 is 'Customer Name EN Level 1';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_1 is 'SAP Sales Organisation Code Level 1';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_1 is 'SAP Distribution Channel Code Level 1';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_1 is 'SAP Division Code Level 1';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_1 is 'Customer Hierarchy Sort Level 1';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_2 is 'SAP Customer Code Level 2';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_2 is 'Customer Name Level 2 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_2 is 'SAP Sales Organisation Code Level 2';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_2 is 'SAP Distribution Channel Code Level 2';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_2 is 'SAP Division Code Level 2';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_2 is 'Customer Hierarchy Sort Level 2';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_3 is 'SAP Customer Code Level 3';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_3 is 'Customer Name Level 3 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_3 is 'SAP Sales Organisation Code Level 3';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_3 is 'SAP Distribution Channel Code Level 3';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_3 is 'SAP Division Code Level 3';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_3 is 'Customer Hierarchy Sort Level 3';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_4 is 'SAP Customer Code Level 4';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_4 is 'Customer Name Level 4 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_4 is 'SAP Sales Organisation Code Level 4';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_4 is 'SAP Distribution Channel Code Level 4';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_4 is 'SAP Division Code Level 4';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_4 is 'Customer Hierarchy Sort Level 4';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_5 is 'SAP Customer Code Level 5';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_5 is 'Customer Name Level 5 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_5 is 'SAP Sales Organisation Code Level 5';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_5 is 'SAP Distribution Channel Code Level 5';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_5 is 'SAP Division Code Level 5';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_5 is 'Customer Hierarchy Sort Level 5';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_6 is 'SAP Customer Code Level 6';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_6 is 'Customer Name Level 6 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_6 is 'SAP Sales Organisation Code Level 6';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_6 is 'SAP Distribution Channel Code Level 6';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_6 is 'SAP Division Code Level 6';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_6 is 'Customer Hierarchy Sort Level 6';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_7 is 'SAP Customer Code Level 7';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_7 is 'Customer Name Level 7 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_7 is 'SAP Sales Organisation Code Level 7';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_7 is 'SAP Distribution Channel Code Level 7';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_7 is 'SAP Division Code Level 7';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_7 is 'Customer Hierarchy Sort Level 7';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_8 is 'SAP Customer Code Level 8';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_8 is 'Customer Name Level 8 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_8 is 'SAP Sales Organisation Code Level 8';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_8 is 'SAP Distribution Channel Code Level 8';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_8 is 'SAP Division Code Level 8';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_8 is 'Customer Hierarchy Sort Level 8';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_9 is 'SAP Customer Code Level 9';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_9 is 'Customer Name Level 9 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_9 is 'SAP Sales Organisation Code Level 9';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_9 is 'SAP Distribution Channel Code Level 9';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_9 is 'SAP Division Code Level 9';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_9 is 'Customer Hierarchy Sort Level 9';
comment on column cad.cad_sales_force_geo_hier.sap_cust_code_level_10 is 'SAP Customer Code Level 10';
comment on column cad.cad_sales_force_geo_hier.cust_name_en_level_10 is 'Customer Name Level 10 EN';
comment on column cad.cad_sales_force_geo_hier.sap_sales_org_code_level_10 is 'SAP Sales Organisation Code Level 10';
comment on column cad.cad_sales_force_geo_hier.sap_distbn_chnl_code_level_10 is 'SAP Distribution Channel Code Level 10';
comment on column cad.cad_sales_force_geo_hier.sap_division_code_level_10 is 'SAP Division Code Level 10';
comment on column cad.cad_sales_force_geo_hier.cust_hier_sort_level_10 is 'Customer Hierarchy Sort Level 10';

/**/
/* Primary Key Constraint
/**/
alter table cad.cad_sales_force_geo_hier
   add constraint cad_sales_force_geo_hier_pk primary key (sap_hier_cust_code, sap_sales_org_code, sap_distbn_chnl_code, sap_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on cad.cad_sales_force_geo_hier to lics_app;
grant select, insert, update, delete on cad.cad_sales_force_geo_hier to cad_app;
grant select on cad.cad_sales_force_geo_hier to public;

/**/
/* Synonym
/**/
create or replace public synonym cad_sales_force_geo_hier for cad.cad_sales_force_geo_hier;
