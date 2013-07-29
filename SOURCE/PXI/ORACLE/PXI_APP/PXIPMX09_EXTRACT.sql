create or replace 
PACKAGE          PXIPMX09_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX09_EXTRACT
 Owner   : DDS_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Pricing Conditions Actuals - PX Interface 336 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 27/07/2013    Mal Chambeyron        Formatted SQL Output         
 
*******************************************************************************/

   procedure execute;

end PXIPMX09_EXTRACT;
/