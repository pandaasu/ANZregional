/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_comp_whtax
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Company Withholding Tax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_comp_whtax
   (customer_code                      varchar2(10 char)        not null,
    company_code                       varchar2(6 char)         not null,
    withhold_tax_type                  varchar2(5 char)         not null,
    withhold_tax_code                  varchar2(5 char)         not null,
    withhold_tax_from_date             date                     not null,
    withhold_tax_to_date               date                     not null,
    withhold_tax_agent                 varchar2(1 char)         null,
    withhold_tax_identification        varchar2(16 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_comp_whtax is 'Business Data Store - Customer Company Withholding Tax';
comment on column bds_cust_comp_whtax.customer_code is 'Customer Number - lads_cus_ctx.kunnr';
comment on column bds_cust_comp_whtax.company_code is 'Company Code - lads_cus_cud.bukrs';
comment on column bds_cust_comp_whtax.withhold_tax_type is 'Indicator for withholding tax type - lads_cus_ctx.witht';
comment on column bds_cust_comp_whtax.withhold_tax_code is 'Withholding tax code - lads_cus_ctx.wt_withcd';
comment on column bds_cust_comp_whtax.withhold_tax_agent is 'Indicator: Withholding tax agent? - lads_cus_ctx.wt_agent';
comment on column bds_cust_comp_whtax.withhold_tax_from_date is 'Obligated to withhold tax from - lads_cus_ctx.wt_agtdf';
comment on column bds_cust_comp_whtax.withhold_tax_to_date is 'Obligated to withhold tax until - lads_cus_ctx.wt_agtdt';
comment on column bds_cust_comp_whtax.withhold_tax_identification is 'Withholding tax identification number - lads_cus_ctx.wt_wtstcd';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_comp_whtax
   add constraint bds_cust_comp_whtax_pk primary key (customer_code, company_code, withhold_tax_type, withhold_tax_code, withhold_tax_from_date, withhold_tax_to_date);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_comp_whtax to lics_app;
grant select, insert, update, delete on bds_cust_comp_whtax to lads_app;
grant select, insert, update, delete on bds_cust_comp_whtax to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_comp_whtax for bds.bds_cust_comp_whtax;