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
 2012/12   Jeff Phillipson Added 2 extra columns acf_cast_yyyyppw and acf_unallocated_coles_code

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
  acf_moe_code       varchar2(8 char) not null,
  acf_cast_yyyyppw   number not null, 
  acf_unallocated_coles_code VARCHAR2(400 char)     
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
COMMENT ON COLUMN au_coles_forecast.acf_cast_yyyyppw IS 'Used to save Cast Week from cell A1 of spreadsheet';
COMMENT ON COLUMN au_coles_forecast.acf_unallocated_coles_code IS 'Contains the Coles code and desc when no Rep Item xref is available';

/**/
/* Primary Key Constraint 
/**/
alter table au_coles_forecast 
   add constraint au_coles_forecast_pk primary key (AU_COLES_FORECAST, acf_yyyyppw, acf_load_yyyyppw, acf_warehouse, acf_rep_item, acf_cast_yyyyppw);

/**/
/* Index 
/**/
create index au_coles_forecast_ix01 on au_coles_forecast(acf_load_yyyypp);
create index au_coles_forecast_idx02 on au_coles_forecast (acf_cast_yyyyppw asc) 

/**/
/* Authority 
/**/
grant select, insert, update, delete on au_coles_forecast to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym au_coles_forecast for qv.au_coles_forecast;