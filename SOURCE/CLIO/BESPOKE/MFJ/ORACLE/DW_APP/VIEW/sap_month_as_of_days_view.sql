/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : sap_month_as_of_days_view
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
create or replace force view sap_month_as_of_days_view
   (ASOFDAYS) AS 
   select 'Current Year/Month: ' || to_char(year_num, 'fm9999') || '/' || to_char(month_num, 'fm99') || 
          '     Working Day ' || daynum || ' of ' ||  numdays || 
          ' Working Days (' ||  to_char(daynum / numdays * 100, 'fm990.0') || '%)' as AsOfDays 
     from (select count(*) daynum
             from mars_date
            where to_char(calendar_date,'yyyymm') = to_char(sysdate-1,'yyyymm')
              and to_char(calendar_date,'yyyymmdd') <= to_char(sysdate-1,'yyyymmdd')
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6,7)) t1,
          (select count(*) as numdays
             from mars_date
            where to_char(calendar_date,'yyyymm') = to_char(sysdate-1,'yyyymm')
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6,7)) t2,
          (select * 
             from mars_date 
            where to_char(calendar_date,'yyyymmdd') = to_char(sysdate-1,'yyyymmdd')) t3;

/*-*/
/* Authority
/*-*/
grant select on dw_app.sap_month_as_of_days_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sap_month_as_of_days_view for dw_app.sap_month_as_of_days_view;




