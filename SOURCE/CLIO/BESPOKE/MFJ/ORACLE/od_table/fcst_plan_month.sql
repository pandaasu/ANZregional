/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_plan_month
 Owner  : od

 Description
 -----------
 Data Warehouse - Forecast Planning Month Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_plan_month
   (sap_material_code               varchar2(18 char)  not null,
    sap_distbn_chnl_code            varchar2(2 char),
    sap_sales_org_code              varchar2(4 char)   not null,
    material_list_price_year_from   number(4),
    material_list_price_month_from  number(2),
    material_list_price_day_from    number(2),
    material_list_price_year_to     number(4),
    material_list_price_month_to    number(2),
    material_list_price_day_to      number(2),
    material_list_price             number(16,4),
    publish_date                    date               not null,
    casting_date                    date               not null,
    casting_yyyymm                  number(6)          not null,
    asof_date                       date               not null,
    asof_yyyymm                     number(6)          not null,
    fcst_date                       date               not null,
    fcst_yyyymm                     number(6)          not null,
    fcst_cases                      number(14,4)       not null,
    fcst_mth_lupdp                  varchar2(8 char)   not null,
    fcst_mth_lupdt                  date               not null);

/**/
/* Comments
/**/
comment on table od.fcst_plan_month is 'Forecast Planning Month Table';
comment on column od.fcst_plan_month.sap_material_code is 'SAP Material Code for the Item.';
comment on column od.fcst_plan_month.sap_distbn_chnl_code is 'SAP Distribution Channel Code for the Material.';
comment on column od.fcst_plan_month.sap_sales_org_code is 'SAP Sales Org Code for the Material.';
comment on column od.fcst_plan_month.material_list_price_year_from is 'Material List Price From Year';
comment on column od.fcst_plan_month.material_list_price_month_from is 'Material List Price From Month';
comment on column od.fcst_plan_month.material_list_price_day_from is 'Material List Price From Day';
comment on column od.fcst_plan_month.material_list_price_year_to is 'Material List Price To Year';
comment on column od.fcst_plan_month.material_list_price_month_to is 'Material List Price To Month';
comment on column od.fcst_plan_month.material_list_price_day_to is 'Material List Price To Day';
comment on column od.fcst_plan_month.material_list_price is 'Material List Price';
comment on column od.fcst_plan_month.publish_date is 'Date of the last forecast update';
comment on column od.fcst_plan_month.casting_date is 'Date of the last period end';
comment on column od.fcst_plan_month.casting_yyyymm is 'Date of the last period end in YYYYMM format';
comment on column od.fcst_plan_month.asof_date is 'Date the forecast begins';
comment on column od.fcst_plan_month.asof_yyyymm is 'Date the forecast begins in YYYYMM format';
comment on column od.fcst_plan_month.fcst_date is 'Forecast date';
comment on column od.fcst_plan_month.fcst_yyyymm is 'Forecast date in YYYYMM format';
comment on column od.fcst_plan_month.fcst_cases is 'Forecast cases';
comment on column od.fcst_plan_month.fcst_mth_lupdp is 'Last Updated Person';
comment on column od.fcst_plan_month.fcst_mth_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_plan_month
   add constraint fcst_plan_month_pk primary key (sap_material_code, casting_date, asof_date, fcst_date);

/**/
/* Authority
/**/
grant select on od.fcst_plan_month to bo_user with grant option;
grant select on od.fcst_plan_month to pld_rep_app;
grant select on od.fcst_plan_month to dw_app with grant option;
grant delete, insert, update on od.fcst_plan_month to dw_app;

/**/
/* Synonym
/**/
create or replace public synonym fcst_plan_month for od.fcst_plan_month;