/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sales_force_geo_hier
 Owner  : dd

 Description
 -----------
 Data Warehouse - Sales Force Geography Hierarchy Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.sales_force_geo_hier
   (sap_hier_cust_code              varchar2(10 char)  not null,
    sap_sales_org_code              varchar2(4 char)   not null,
    sap_distbn_chnl_code            varchar2(2 char)   not null,
    sap_division_code               varchar2(2 char)   not null,
    sap_cust_code_level_1           varchar2(10 char)  not null,
    cust_name_en_level_1            varchar2(40 char),
    cust_name_ja_level_1            varchar2(40 char),
    sap_sales_org_code_level_1      varchar2(4 char)   not null,
    sap_distbn_chnl_code_level_1    varchar2(2 char)   not null,
    sap_division_code_level_1       varchar2(2 char)   not null,
    cust_hier_sort_level_1          varchar2(10 char),
    sap_cust_code_level_2           varchar2(10 char),
    cust_name_en_level_2            varchar2(40 char),
    cust_name_ja_level_2            varchar2(40 char),
    sap_sales_org_code_level_2      varchar2(4 char),
    sap_distbn_chnl_code_level_2    varchar2(2 char),
    sap_division_code_level_2       varchar2(2 char),
    cust_hier_sort_level_2          varchar2(10 char),
    sap_cust_code_level_3           varchar2(10 char),
    cust_name_en_level_3            varchar2(40 char),
    cust_name_ja_level_3            varchar2(40 char),
    sap_sales_org_code_level_3      varchar2(4 char),
    sap_distbn_chnl_code_level_3    varchar2(2 char),
    sap_division_code_level_3       varchar2(2 char),
    cust_hier_sort_level_3          varchar2(10 char),
    sap_cust_code_level_4           varchar2(10 char),
    cust_name_en_level_4            varchar2(40 char),
    cust_name_ja_level_4            varchar2(40 char),
    sap_sales_org_code_level_4      varchar2(4 char),
    sap_distbn_chnl_code_level_4    varchar2(2 char),
    sap_division_code_level_4       varchar2(2 char),
    cust_hier_sort_level_4          varchar2(10 char),
    sap_cust_code_level_5           varchar2(10 char),
    cust_name_en_level_5            varchar2(40 char),
    cust_name_ja_level_5            varchar2(40 char),
    sap_sales_org_code_level_5      varchar2(4 char), 
    sap_distbn_chnl_code_level_5    varchar2(2 char),
    sap_division_code_level_5       varchar2(2 char),
    cust_hier_sort_level_5          varchar2(10 char),
    sap_cust_code_level_6           varchar2(10 char),
    cust_name_en_level_6            varchar2(40 char),
    cust_name_ja_level_6            varchar2(40 char),
    sap_sales_org_code_level_6      varchar2(4 char),
    sap_distbn_chnl_code_level_6    varchar2(2 char),
    sap_division_code_level_6       varchar2(2 char),
    cust_hier_sort_level_6          varchar2(10 char),
    sap_cust_code_level_7           varchar2(10 char),
    cust_name_en_level_7            varchar2(40 char),
    cust_name_ja_level_7            varchar2(40 char),
    sap_sales_org_code_level_7      varchar2(4 char),
    sap_distbn_chnl_code_level_7    varchar2(2 char),
    sap_division_code_level_7       varchar2(2 char),
    cust_hier_sort_level_7          varchar2(10 char),
    sap_cust_code_level_8           varchar2(10 char),
    cust_name_en_level_8            varchar2(40 char),
    cust_name_ja_level_8            varchar2(40 char),
    sap_sales_org_code_level_8      varchar2(4 char),
    sap_distbn_chnl_code_level_8    varchar2(2 char),
    sap_division_code_level_8       varchar2(2 char),
    cust_hier_sort_level_8          varchar2(10 char),
    sap_cust_code_level_9           varchar2(10 char),
    cust_name_en_level_9            varchar2(40 char),
    cust_name_ja_level_9            varchar2(40 char),
    sap_sales_org_code_level_9      varchar2(4 char),
    sap_distbn_chnl_code_level_9    varchar2(2 char),
    sap_division_code_level_9       varchar2(2 char),
    cust_hier_sort_level_9          varchar2(10 char),
    sap_cust_code_level_10          varchar2(10 char),
    cust_name_en_level_10           varchar2(40 char),
    cust_name_ja_level_10           varchar2(40 char),
    sap_sales_org_code_level_10     varchar2(4 char),
    sap_distbn_chnl_code_level_10   varchar2(2 char),
    sap_division_code_level_10      varchar2(2 char),
    cust_hier_sort_level_10         varchar2(10 char));

/**/
/* Comments
/**/
comment on table dd.sales_force_geo_hier is 'Sales Force Geography Hierarchy Table';
comment on column dd.sales_force_geo_hier.sap_hier_cust_code is 'SAP Sales Force Geography Hierarchy Customer Code';
comment on column dd.sales_force_geo_hier.sap_sales_org_code is 'SAP Sales Organisation Code';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code is 'SAP Distribution Channel Code';
comment on column dd.sales_force_geo_hier.sap_division_code is 'SAP Division Code';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_1 is 'SAP Customer Code Level 1';
comment on column dd.sales_force_geo_hier.cust_name_en_level_1 is 'Customer Name EN Level 1';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_1 is 'Customer Name JA Level 1';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_1 is 'SAP Sales Organisation Code Level 1';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_1 is 'SAP Distribution Channel Code Level 1';
comment on column dd.sales_force_geo_hier.sap_division_code_level_1 is 'SAP Division Code Level 1';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_1 is 'Customer Hierarchy Sort Level 1';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_2 is 'SAP Customer Code Level 2';
comment on column dd.sales_force_geo_hier.cust_name_en_level_2 is 'Customer Name Level 2 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_2 is 'Customer Name Level 2 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_2 is 'SAP Sales Organisation Code Level 2';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_2 is 'SAP Distribution Channel Code Level 2';
comment on column dd.sales_force_geo_hier.sap_division_code_level_2 is 'SAP Division Code Level 2';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_2 is 'Customer Hierarchy Sort Level 2';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_3 is 'SAP Customer Code Level 3';
comment on column dd.sales_force_geo_hier.cust_name_en_level_3 is 'Customer Name Level 3 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_3 is 'Customer Name Level 3 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_3 is 'SAP Sales Organisation Code Level 3';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_3 is 'SAP Distribution Channel Code Level 3';
comment on column dd.sales_force_geo_hier.sap_division_code_level_3 is 'SAP Division Code Level 3';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_3 is 'Customer Hierarchy Sort Level 3';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_4 is 'SAP Customer Code Level 4';
comment on column dd.sales_force_geo_hier.cust_name_en_level_4 is 'Customer Name Level 4 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_4 is 'Customer Name Level 4 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_4 is 'SAP Sales Organisation Code Level 4';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_4 is 'SAP Distribution Channel Code Level 4';
comment on column dd.sales_force_geo_hier.sap_division_code_level_4 is 'SAP Division Code Level 4';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_4 is 'Customer Hierarchy Sort Level 4';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_5 is 'SAP Customer Code Level 5';
comment on column dd.sales_force_geo_hier.cust_name_en_level_5 is 'Customer Name Level 5 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_5 is 'Customer Name Level 5 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_5 is 'SAP Sales Organisation Code Level 5';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_5 is 'SAP Distribution Channel Code Level 5';
comment on column dd.sales_force_geo_hier.sap_division_code_level_5 is 'SAP Division Code Level 5';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_5 is 'Customer Hierarchy Sort Level 5';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_6 is 'SAP Customer Code Level 6';
comment on column dd.sales_force_geo_hier.cust_name_en_level_6 is 'Customer Name Level 6 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_6 is 'Customer Name Level 6 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_6 is 'SAP Sales Organisation Code Level 6';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_6 is 'SAP Distribution Channel Code Level 6';
comment on column dd.sales_force_geo_hier.sap_division_code_level_6 is 'SAP Division Code Level 6';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_6 is 'Customer Hierarchy Sort Level 6';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_7 is 'SAP Customer Code Level 7';
comment on column dd.sales_force_geo_hier.cust_name_en_level_7 is 'Customer Name Level 7 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_7 is 'Customer Name Level 7 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_7 is 'SAP Sales Organisation Code Level 7';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_7 is 'SAP Distribution Channel Code Level 7';
comment on column dd.sales_force_geo_hier.sap_division_code_level_7 is 'SAP Division Code Level 7';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_7 is 'Customer Hierarchy Sort Level 7';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_8 is 'SAP Customer Code Level 8';
comment on column dd.sales_force_geo_hier.cust_name_en_level_8 is 'Customer Name Level 8 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_8 is 'Customer Name Level 8 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_8 is 'SAP Sales Organisation Code Level 8';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_8 is 'SAP Distribution Channel Code Level 8';
comment on column dd.sales_force_geo_hier.sap_division_code_level_8 is 'SAP Division Code Level 8';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_8 is 'Customer Hierarchy Sort Level 8';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_9 is 'SAP Customer Code Level 9';
comment on column dd.sales_force_geo_hier.cust_name_en_level_9 is 'Customer Name Level 9 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_9 is 'Customer Name Level 9 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_9 is 'SAP Sales Organisation Code Level 9';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_9 is 'SAP Distribution Channel Code Level 9';
comment on column dd.sales_force_geo_hier.sap_division_code_level_9 is 'SAP Division Code Level 9';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_9 is 'Customer Hierarchy Sort Level 9';
comment on column dd.sales_force_geo_hier.sap_cust_code_level_10 is 'SAP Customer Code Level 10';
comment on column dd.sales_force_geo_hier.cust_name_en_level_10 is 'Customer Name Level 10 EN';
comment on column dd.sales_force_geo_hier.cust_name_ja_level_10 is 'Customer Name Level 10 JA';
comment on column dd.sales_force_geo_hier.sap_sales_org_code_level_10 is 'SAP Sales Organisation Code Level 10';
comment on column dd.sales_force_geo_hier.sap_distbn_chnl_code_level_10 is 'SAP Distribution Channel Code Level 10';
comment on column dd.sales_force_geo_hier.sap_division_code_level_10 is 'SAP Division Code Level 10';
comment on column dd.sales_force_geo_hier.cust_hier_sort_level_10 is 'Customer Hierarchy Sort Level 10';

/**/
/* Primary Key Constraint
/**/
alter table dd.sales_force_geo_hier
   add constraint sales_force_geo_hier_pk primary key (sap_hier_cust_code, sap_sales_org_code, sap_distbn_chnl_code, sap_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.sales_force_geo_hier to dw_app;
grant select on dd.sales_force_geo_hier to pld_rep_app;
grant select on dd.sales_force_geo_hier to dd_app with grant option;

/**/
/* Synonym
/**/
create or replace public synonym sales_force_geo_hier for dd.sales_force_geo_hier;
