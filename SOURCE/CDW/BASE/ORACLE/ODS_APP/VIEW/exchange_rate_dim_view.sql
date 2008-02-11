/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : exchange_rate_dim_view 
 Owner  : ods_app 

 DESCRIPTION 
 -----------
 Operational Data Store - Exchange Rate Dimension View 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/10   Trevor Keon    Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
create or replace force view ods_app.exchange_rate_dim_view as
select t01.rate_type,
  t01.from_curr,
  t02.currcy_code,
  t01.valid_from,
  round(ods_app.currcy_conv(1, t01.from_curr, t02.currcy_code, to_date(t01.valid_from, 'YYYYMMDD'), t01.rate_type), 5) as exch_rate
from sap_xch_rat_det t01,
  currcy t02
where t01.to_currncy = 'USD'
  and t01.from_curr <> t02.currcy_code
  and ods_app.currcy_conv(1, t01.from_curr, t02.currcy_code, to_date(t01.valid_from, 'YYYYMMDD'), t01.rate_type) <> 0

union all

select 'USDX',
  t01.currcy_code,
  t01.currcy_code,
  '20000101',
  1
from currcy t01

/*-*/
/* Authority 
/*-*/
grant select on ods_app.exchange_rate_dim_view to dw_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym exchange_rate_dim_view for ods_app.exchange_rate_dim_view;