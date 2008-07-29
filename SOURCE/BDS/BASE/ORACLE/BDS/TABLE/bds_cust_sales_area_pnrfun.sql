/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area_pnrfun
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area Partner Function Roles

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area_pnrfun
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
    partner_funcn_code                 varchar2(5 char)         not null,
    partner_cust_code                  varchar2(10 char)        not null,
    default_partner_flag               varchar2(1 char)         null,
    partner_description                varchar2(30 char)        null,
    partner_counter                    number                   null,
    partner_text                       varchar2(20 char)        null,
    partner_name                       varchar2(80 char)        null,
    partner_last_name                  varchar2(40 char)        null,
    partner_first_name                 varchar2(40 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_sales_area_pnrfun is 'Business Data Store - Customer Sales Area Partner Function Roles';
comment on column bds_cust_sales_area_pnrfun.customer_code is 'Customer Number - lads_cus_pfr.kunnr';
comment on column bds_cust_sales_area_pnrfun.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area_pnrfun.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area_pnrfun.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area_pnrfun.partner_funcn_code is 'Partner function - lads_cus_pfr.parvw';
comment on column bds_cust_sales_area_pnrfun.partner_cust_code is 'Customer number of business partner - lads_cus_pfr.kunn2';
comment on column bds_cust_sales_area_pnrfun.default_partner_flag is 'Default partner - lads_cus_pfr.defpa';
comment on column bds_cust_sales_area_pnrfun.partner_description is '''Customer description of partner (plant, storage location)'' - lads_cus_pfr.knref';
comment on column bds_cust_sales_area_pnrfun.partner_counter is 'Partner counter - lads_cus_pfr.parza';
comment on column bds_cust_sales_area_pnrfun.partner_text is 'Description - lads_cus_pfr.zz_parvw_txt';
comment on column bds_cust_sales_area_pnrfun.partner_name is 'Complete Name - lads_cus_pfr.zz_partn_nam';
comment on column bds_cust_sales_area_pnrfun.partner_last_name is 'Last Name - lads_cus_pfr.zz_partn_nachn';
comment on column bds_cust_sales_area_pnrfun.partner_first_name is 'First Name - lads_cus_pfr.zz_partn_vorna';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area_pnrfun
   add constraint bds_cust_sales_area_pnrfun_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code, partner_funcn_code, partner_cust_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area_pnrfun to lics_app;
grant select, insert, update, delete on bds_cust_sales_area_pnrfun to lads_app;
grant select, insert, update, delete on bds_cust_sales_area_pnrfun to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area_pnrfun for bds.bds_cust_sales_area_pnrfun;