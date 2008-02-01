/******************************************************************************/
/*  NAME: BDS_STOCK_BALANCE                                                   */
/*                                                                            */
/*  REVISIONS:                                                                */
/*  Ver    Date        Author           Description                           */
/*  -----  ----------  ---------------  ------------------------------------  */
/*  1.0    11-04-2007  Steve Gregan     Created view                          */
/******************************************************************************/

create or replace force view bds.bds_stock_balance
   (company_code,
    plant_code,
    storage_location_code,
    stock_balance_date,
    stock_balance_time,
    material_code,
    inspection_stock_flag,
    stock_quantity,
    stock_uom_code,
    stock_best_before_date,
    consignment_cust_vend,
    rcv_isu_storage_location_code,
    stock_type_code) as
   select t02.company_code,
          t02.plant_code,
          t02.storage_location_code,
          t02.stock_balance_date,
          t02.stock_balance_time,
          t02.material_code,
          t02.inspection_stock_flag,
          t02.stock_quantity,
          t02.stock_uom_code,
          t02.stock_best_before_date,
          t02.consignment_cust_vend,
          t02.rcv_isu_storage_location_code,
          t02.stock_type_code
     from (select company_code,
                  max(stock_balance_date) as stock_balance_date
             from bds_stock_header
            where storage_location_code != 'INTR'
            group by company_code) t01,
          bds_stock_detail t02
    where t01.company_code = t02.company_code
      and t01.stock_balance_date = t02.stock_balance_date
    union all
   select t02.company_code,
          t02.plant_code,
          'INTR',
          substr(t01.sap_idoc_timestamp,1,8),
          substr(t01.sap_idoc_timestamp,9,6),
          t02.material_code,
          null,
          nvl(t02.quantity, 0),
          t02.uom_code,
          t02.best_before_date,
          null,
          null,
          '1'
     from bds_intransit_header t01,
          bds_intransit_detail t02
    where t01.plant_code = t02.plant_code;

/*-*/
/* Authority
/*-*/

/*-*/
/* Synonym
/*-*/
create or replace public synonym bds_bds_stock_balance for bds.bds_bds_stock_balance;