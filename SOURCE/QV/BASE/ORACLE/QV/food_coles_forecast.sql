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
  acf_moe_code       
);

/**/
/* Comments 
/**/
comment on table food_coles_forecast is 'Food Coles Forecasts';
comment on column food_coles_forecast.fcf_yyyypp is 'Food Coles Forecasts - forecast period';
comment on column food_coles_forecast.fcf_yyyyppw is 'Food Coles Forecasts - forecast week';
comment on column food_coles_forecast.fcf_warehouse is 'Food Coles Forecasts - Coles warehouse';
comment on column food_coles_forecast.fcf_rep_item is 'Food Coles Forecasts - ZREP code';
comment on column food_coles_forecast.fcf_forecast is 'Food Coles Forecasts - forecast value';
comment on column food_coles_forecast.fcf_load_yyyypp is 'Food Coles Forecasts - forecast load period';
comment on column food_coles_forecast.fcf_load_yyyyppw is 'Food Coles Forecasts - forecast load week';

/**/
/* Primary Key Constraint 
/**/
alter table food_coles_forecast 
   add constraint food_coles_forecast_pk primary key (fcf_yyyyppw, fcf_load_yyyyppw, fcf_warehouse, fcf_rep_item);

/**/
/* Index 
/**/
create index food_coles_forecast_ix01 on food_coles_forecast(fcf_load_yyyypp);

/**/
/* Authority 
/**/
grant select, insert, update, delete on food_coles_forecast to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym food_coles_forecast for qv.food_coles_forecast;