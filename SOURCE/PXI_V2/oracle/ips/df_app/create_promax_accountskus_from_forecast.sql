/*

  Script  : create_promax_accountskus_from_forecast.sql
  Purpose : Generate MS SQL Script to CREATE or RESET Promax PX Ranging 
            (ACCOUNTSKUS) for a Given Forecast.
            NOTE : This script should only be executed on Promax PX database 
                   setup/reset ***NOT*** for normal ranging maintenance
  Author  : Mal Chambeyron
  Date    : 20140212
  
*/

set arraysize 5000
set define '^'
set echo off
set feedback off
set heading off
set linesize 512
set pagesize 0
set serveroutput on size 100000

-- Generate MS SQL Script to CREATE or RESET Promax PX Ranging (ACCOUNTSKUS) for a Given Forecast
spool create_promax_accountskus_from_forecast_GENERATED.sql

select 'use PETCARE_TEST' from dual;
select ' ' from dual;
select 'delete from accountskuexternalvolume' from dual;

-- UPDATES ONLY
select ' ' from dual;
select 'insert into accountskus (as_accountrowid,as_accountpubid,as_skurowid,as_skupubid,as_clientforecastmodel,as_salesstddevavgvolume,as_externalbasescan) values ('||ac_row_id||',''headoffice'','||sku_row_id||',''headoffice'',0,0,1)' as sql_row
from (
    select 
      ac.ac_row_id,
      sku.sku_row_id
    from (
        select distinct 
          px_dmnd_plng_node,
          zrep_matl_code
        from table(dfnpxi01_extract.pt_forecast_split(4256))
      ) ac_sku,
      table(px_promax_connect.pt_account) ac,
      table(px_promax_connect.pt_sku) sku
    where ac_sku.px_dmnd_plng_node = ac.ac_code
    and ac_sku.zrep_matl_code = sku.sku_stock_code
  ) new_range,
  table(px_promax_connect.pt_account_skus) current_range
where new_range.ac_row_id = current_range.as_account_row_id(+) 
and new_range.sku_row_id = current_range.as_sku_row_id(+)
and current_range.as_account_row_id is null
;
/*
-- REPLACE ALL
select 'delete from accountskudetails' from dual;
select 'delete from accountskus' from dual;
select ' ' from dual;
select 'insert into accountskus (as_accountrowid,as_accountpubid,as_skurowid,as_skupubid,as_clientforecastmodel,as_salesstddevavgvolume,as_externalbasescan) values ('||ac.ac_row_id||',''headoffice'','||sku.sku_row_id||',''headoffice'',0,0,1)' as sql_row
from (
    select distinct 
      px_dmnd_plng_node,
      zrep_matl_code
    from table(dfnpxi01_extract.pt_forecast_split(4189))
  ) ac_sku,
  table(px_promax_connect.pt_account) ac,
  table(px_promax_connect.pt_sku) sku
where ac_sku.px_dmnd_plng_node = ac.ac_code
and ac_sku.zrep_matl_code = sku.sku_stock_code
;
*/
select ' ' from dual;
select 'insert into accountskudetails (asd_normalqtymethod,asd_normalqty,asd_startdate,asd_accountskurowid,asd_accountskupubid,asd_clientforecastmodel) (select 3,0,''2013-01-01'',as_rowid,''headoffice'',0 from accountskus where as_rowid not in (select asd_accountskurowid from accountskudetails))' from dual;
select ' ' from dual;

spool off;

