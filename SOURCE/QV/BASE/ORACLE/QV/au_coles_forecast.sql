/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : au_coles_forecast
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - au_coles_forecast 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2012/07   Trevor Keon    Created 
 2012/07   Trevor Keon    Updated to include load YYYYPP 
 2012/08   Trevor Keon    Updated to support all AU sites

*******************************************************************************/

/**/
/* Table creation
/**/
create table au_coles_forecast
(
  acf_yyyypp         number not null,
  acf_yyyyppw        number not null,
  acf_warehouse      varchar2(200 char) not null,
  acf_rep_item       varchar2(18 char) not null,
  acf_forecast       number not null,
  acf_load_yyyypp    number not null,
  acf_load_yyyyppw   number not null,
  acf_moe_code       varchar2(8 char) not null       
);

/**/
/* Comments 
/**/
comment on table au_coles_forecast is 'AU Coles Forecasts';
comment on column au_coles_forecast.acf_yyyypp is 'AU Coles Forecasts - forecast period';
comment on column au_coles_forecast.acf_yyyyppw is 'AU Coles Forecasts - forecast week';
comment on column au_coles_forecast.acf_warehouse is 'AU Coles Forecasts - Coles warehouse';
comment on column au_coles_forecast.acf_rep_item is 'AU Coles Forecasts - ZREP code';
comment on column au_coles_forecast.acf_forecast is 'AU Coles Forecasts - forecast value';
comment on column au_coles_forecast.acf_load_yyyypp is 'AU Coles Forecasts - forecast load period';
comment on column au_coles_forecast.acf_load_yyyyppw is 'AU Coles Forecasts - forecast load week';
comment on column au_coles_forecast.acf_moe_code is 'AU Coles Forecasts - MOE code';

/**/
/* Primary Key Constraint 
/**/
alter table au_coles_forecast 
   add constraint au_coles_forecast_pk primary key (acf_yyyyppw, acf_load_yyyyppw, acf_warehouse, acf_rep_item);

/**/
/* Index 
/**/
create index au_coles_forecast_ix01 on au_coles_forecast(acf_load_yyyypp);

/**/
/* Authority 
/**/
grant select, insert, update, delete on au_coles_forecast to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym au_coles_forecast for qv.au_coles_forecast;