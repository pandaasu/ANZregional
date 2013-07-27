create or replace 
PACKAGE          PXIPMX03_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX03_EXTRACT
 Owner   : DDS_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Customer Data - PX Interface 300 (New Zealand)
 
 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 26/07/2013    Mal Chambeyron        Formatted SQL Output         
 
*******************************************************************************/

   procedure execute;

end PXIPMX03_EXTRACT;
/