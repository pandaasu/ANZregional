/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : period_as_of_days_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view period_as_of_days_view
   (ASOFDAYS) AS 
   select 'Current Year/Period: ' || ltrim(to_char(mars_year, '9999')) || '/' ||  ltrim(to_char(period_num, '99')) || 
          '     Working Day ' || daynum || ' of ' || numdays || 
          ' Working Days (' || ltrim(to_char(daynum / numdays * 100, '990.0')) || '%)' AS AsOfDays 
     from (select count(*) as daynum 
             from mars_date
            where mars_period = (select mars_period from mars_date where to_char(calendar_date,'yyyymmdd') = to_char(sysdate-1,'yyyymmdd'))
              and to_char(calendar_date,'yyyymmdd') <= to_char(sysdate-1,'yyyymmdd')
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6)) t1,
          (select count(*) as numdays
            from mars_date
            where mars_period = (select mars_period from mars_date where to_char(calendar_date,'yyyymmdd') = to_char(sysdate-1,'yyyymmdd'))
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6)) t2,
          (select * 
             from mars_date 
            where to_char(calendar_date,'yyyymmdd') = to_char(sysdate-1,'yyyymmdd')) t3;

/*-*/
/* Authority
/*-*/
grant select on dw_app.period_as_of_days_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym period_as_of_days_view for dw_app.period_as_of_days_view;