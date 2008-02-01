/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mars_date_month_dim_view
 Owner  : od_app

 DESCRIPTION
 -----------
 Operational Data Store - Mars Date Month Dimension View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view od_app.mars_date_month_dim_view
   (yyyymm_date,
    yyyyqq_date,
    month_num,
    year_num) as
   select to_number(substr(t01.yyyymmdd_date,1,6)) yyyymm_date,
          max(t01.yyyyqq_date),
          max(t01.month_num),
          max(t01.year_num)
     from mars_date t01
    group by to_number(substr(t01.yyyymmdd_date,1,6));

/*-*/
/* Authority
/*-*/
grant select on od_app.mars_date_month_dim_view to dw_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mars_date_month_dim_view for od_app.mars_date_month_dim_view;
