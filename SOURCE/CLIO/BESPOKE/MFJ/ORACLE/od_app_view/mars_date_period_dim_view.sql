/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mars_date_period_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Mars Date Period Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.mars_date_period_dim_view
   (mars_period,
    mars_yyyyqq_date,
    period_num,
    mars_year) as
   select mars_period,
          max(t01.mars_yyyyqq_date),
          max(t01.period_num),
          max(t01.mars_year)
     from mars_date t01
    group by mars_period;

/*-*/
/* Authority
/*-*/
grant select on od_app.mars_date_period_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mars_date_period_dim_view for od_app.mars_date_period_dim_view;