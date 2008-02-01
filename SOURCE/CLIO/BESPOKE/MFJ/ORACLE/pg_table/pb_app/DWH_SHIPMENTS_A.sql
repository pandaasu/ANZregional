/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : dwh_shipments_a
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
create or replace force view pb_app.dwh_shipments_a
   (ARRIVAL_DATE, PROD_CD, CHAIN_ID, SHIPED_QTY)
AS 
select to_number(to_char(t1.WHSE_ESTD_ARRIVAL_DATE,'YYYYMMDD')) ,
   t1.SAP_MATERIAL_CODE ,
   decode(t1.SAP_HANDLING_UNIT_STS_CODE,'3',t1.SAP_PLANT_CODE,
   (select distinct t4.CHAIN_ID from pb.Chain_ID_Xref t4 where t4.SAP_PLANT_CD=
   t1.SAP_PLANT_CODE and t4.SAP_STORAGE_LC_CD=t1.SAP_STORAGE_LOCN_CODE )) ,
   t1.SHIPD_QTY
   from dw_app.Period_Order_View@AP0093P t1
   where NVL(t1.sap_bus_sgmnt_code,'0')!='01' and
         NVL(t1.SAP_HANDLING_UNIT_STS_CODE,'0')!='4';

/*-*/
/* Synonym
/*-*/
create or replace public synonym dwh_shipments_a for pb_app.dwh_shipments_a;