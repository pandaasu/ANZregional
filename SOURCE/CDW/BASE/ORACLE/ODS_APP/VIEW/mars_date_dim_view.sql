/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mars_date_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Mars Date Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.mars_date_dim_view as
select calendar_date,
  year_num,
  month_num,
  period_num,
  month_day_num,
  period_day_num,
  julian_date,
  mars_period,
  yyyymmdd_date,
  yyyyqq_date,
  mars_yyyyqq_date,
  mars_week,
  mars_yyyyppdd,
  mars_year,
  mwc_date,
  period_bus_day_num,
  0 as day_of_week,
  0 as week_of_month,
  0 as mars_day_of_week,
  0 as mars_week_of_period,
  0 as mars_week_of_year,
  0 as mars_prd_seq_num,
  0 as month_seq_num
from mars_date;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.mars_date_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym mars_date_dim_view for ods_app.mars_date_dim_view;