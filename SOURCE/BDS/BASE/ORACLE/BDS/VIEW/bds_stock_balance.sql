/******************************************************************************/
/* View Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 View   : bds_stock_balance
 Owner   : bds 
 Author  : Steve Gregan 

 Description 
 ----------- 
 Business Data Store - bds_addr_customer_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2007/04   Steve Gregan   Created 
 2008/10   Trevor Keon    Changed to use LADS tables to resolve issues with
                            primary key being invalid in BDS tables

*******************************************************************************/

create or replace force view bds.bds_stock_balance as
  select t01.bukrs as company_code,
    t01.werks as plant_code, 
    t01.lgort as storage_location_code,
    decode(t03.budat, null, '19000101', t03.budat) as stock_balance_date,
    decode(t03.timlo, null, '120000', t03.timlo) as stock_balance_time,
    t03.matnr as material_code,
    t03.charg as material_batch_number,
    t03.sobkz as inspection_stock_flag,
    to_number(t03.menga) as stock_quantity, 
    t03.altme as stock_uom_code,
    t03.vfdat as stock_best_before_date, 
    t03.kunnr as consignment_cust_vend,
    t03.umlgo as rcv_isu_storage_location_code,
    t03.insmk as stock_type_code
  from 
    (
      select t11.bukrs, 
        t11.werks, 
        t11.lgort, 
        t11.budat, 
        max(t11.timlo) as max_timlo
      from lads_stk_bal_hdr t11
      where t11.bukrs in ('147', '149') 
        and t11.lgort <> 'INTR'
      group by t11.bukrs, 
        t11.werks, 
        t11.lgort, 
        t11.budat
    ) t01,
    (
      select t12.bukrs, 
        t12.werks, 
        max(t12.budat) as max_budat
      from lads_stk_bal_hdr t12
      where bukrs in ('147', '149')
      group by t12.bukrs, 
        t12.werks
    ) t02,
    lads_stk_bal_det t03
  where t01.bukrs = t02.bukrs
    and t01.werks = t02.werks
    and t01.budat = t02.max_budat
    and t01.bukrs = t03.bukrs
    and t01.werks = t03.werks
    and t01.lgort = t03.lgort
    and t01.budat = t03.budat
    and t01.max_timlo = t03.timlo
  union all
  select t02.burks as company_code,
    t01.werks as plant_code, 
    'INTR' as storage_location_code,
    nvl(substr(t01.idoc_timestamp, 1, 8), '19000101') as stock_balance_date,
    nvl(substr(t01.idoc_timestamp, 9, 6), '120000') as stock_balance_time,
    t02.matnr as material_code,
    t02.charg as material_batch_number,
    null as inspection_stock_flag,
    to_number(nvl(t02.lfimg, 0)) as stock_quantity, 
    t02.meins as stock_uom_code,
    t02.atwrt as stock_best_before_date, 
    null as consignment_cust_vend,
    null as rcv_isu_storage_location_code, 
    '1' as stock_type_code
  from lads_int_stk_hdr t01, 
    lads_int_stk_det t02
  where t01.werks = t02.werks
    and t02.burks in ('147', '149');

/*-*/
/* Authority
/*-*/
grant select on bds.bds_stock_balance to ics_app;
grant select on bds.bds_stock_balance to bds_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym bds_stock_balance for bds.bds_stock_balance;