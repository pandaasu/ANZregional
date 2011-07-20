/* Formatted on 15-Jul-2011 11:30:04 AM (QP5 v5.139.911.3011) */
CREATE OR REPLACE FORCE VIEW MANU_APP.STOCK_BALANCE_VW
(
   COMPANY_CODE,
   PLANT_CODE,
   STORAGE_LOCATION_CODE,
   STOCK_BALANCE_DATE,
   STOCK_BALANCE_TIME,
   MATERIAL_CODE,
   MATERIAL_BATCH_NUMBER,
   INSPECTION_STOCK_FLAG,
   STOCK_QUANTITY,
   STOCK_UOM_CODE,
   STOCK_BEST_BEFORE_DATE,
   CONSIGNMENT_CUST_VEND,
   RCV_ISU_STORAGE_LOCATION_CODE,
   STOCK_TYPE_CODE
)
AS
   SELECT company_code,
          plant_code,
          storage_location_code,
          stock_balance_date,
          stock_balance_time,
          material_code,
          material_batch_number,
          inspection_stock_flag,
          stock_quantity,
          stock_uom_code,
          stock_best_before_date,
          consignment_cust_vend,
          rcv_isu_storage_location_code,
          stock_type_code
     FROM bds_stock_balance;

COMMENT ON TABLE MANU_APP.STOCK_BALANCE_VW IS 'Stock Balance';


CREATE PUBLIC SYNONYM STOCK_BALANCE_VW FOR MANU_APP.STOCK_BALANCE_VW;


GRANT SELECT ON MANU_APP.STOCK_BALANCE_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.STOCK_BALANCE_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.STOCK_BALANCE_VW TO MANU_USER;
