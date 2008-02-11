/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mars_date_period_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Mars Date Period Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.mars_date_period_dim_view as
select mars_period,
  t01.mars_yyyyqq_date,
  t01.period_num,
  t01.mars_year
from mars_date t01

union

select 999913 AS mars_period,
  999904 AS mars_yyyyqq_date,
  13 AS period_num,
  9999 AS mars_year
from dual;

/*-*/
/* Authority 
/*-*/
grant select on ods_app.mars_date_period_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym mars_date_period_dim_view for ods_app.mars_date_period_dim_view;