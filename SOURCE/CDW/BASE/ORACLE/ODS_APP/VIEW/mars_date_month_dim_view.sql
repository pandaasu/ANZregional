/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mars_date_month_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Mars Date Month Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.mars_date_month_dim_view as
select to_number(substr(t01.yyyymmdd_date,1,6)) as yyyymm_date,
  max(t01.yyyyqq_date) as yyyyqq_date,
  max(t01.month_num) as month_num,
  max(t01.year_num) as year_num
from mars_date t01
group by to_number(substr(t01.yyyymmdd_date,1,6));

/*-*/
/* Authority 
/*-*/
grant select on ods_app.mars_date_month_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym mars_date_month_dim_view for ods_app.mars_date_month_dim_view;