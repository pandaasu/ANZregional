/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : nz_kam_forecast
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - nz_kam_forecast 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2012/01   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table nz_kam_forecast
(
  nkf_yyyypp          number not null,
  nkf_yyyyppw         number not null,
  nkf_regroup_dpg     varchar2(100) not null,
  nkf_value           number not null
);

/**/
/* Comments 
/**/
comment on table nz_kam_forecast is 'KAM Forecasts';
comment on column nz_kam_forecast.nkf_yyyypp is 'KAM Forecasts - forecast period';
comment on column nz_kam_forecast.nkf_yyyyppw is 'KAM Forecasts - forecast week';
comment on column nz_kam_forecast.nkf_regroup_dpg is 'KAM Forecasts - NZ regroup';
comment on column nz_kam_forecast.nkf_value is 'KAM Forecasts - forecast value';

/**/
/* Primary Key Constraint 
/**/
alter table nz_kam_forecast
   add constraint nz_kam_forecast_pk primary key (nkf_yyyyppw, nkf_regroup_dpg);

/**/
/* Index 
/**/
create index nz_kam_forecast_ix01 on nz_kam_forecast(nkf_yyyypp);
create index nz_kam_forecast_ix02 on nz_kam_forecast(nkf_yyyyppw);

/**/
/* Authority 
/**/
grant select, insert, update, delete on nz_kam_forecast to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym nz_kam_forecast for qv.nz_kam_forecast;