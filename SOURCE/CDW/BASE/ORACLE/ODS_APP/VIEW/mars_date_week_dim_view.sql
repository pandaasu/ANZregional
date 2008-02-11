/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mars_date_week_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Mars Date Week Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.mars_date_week_dim_view as
select mars_week,
  max(mars_yyyyqq_date) as mars_yyyyqq_date,
  max(period_num) as period_num,
  max(mars_year) as mars_year
from mars_date
group by mars_week;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.mars_date_week_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym mars_date_week_dim_view for ods_app.mars_date_week_dim_view;