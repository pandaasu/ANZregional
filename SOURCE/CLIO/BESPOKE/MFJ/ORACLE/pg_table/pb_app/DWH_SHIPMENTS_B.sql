/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : dwh_shipments_b
 Owner  : pb_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view pb_app.dwh_shipments_b
   (ARRIVAL_DATE, PROD_CD, CHAIN_ID, SHIPED_QTY)
AS 
select to_number(to_char(t1.WHSE_ESTD_ARRIVAL_DATE,'YYYYMMDD')) , t1.SAP_MATERIAL_CODE ,
   '250TL' , t1.SHIPD_QTY
   from dw_app.Period_Order_View@AP0093P t1
   where t1.sap_bus_sgmnt_code='01';

/*-*/
/* Synonym
/*-*/
create or replace public synonym dwh_shipments_b for pb_app.dwh_shipments_b;