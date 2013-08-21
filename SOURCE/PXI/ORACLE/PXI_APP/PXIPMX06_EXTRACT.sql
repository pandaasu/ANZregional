create or replace 
PACKAGE          PXIPMX06_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX06_EXTRACT
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Price Data - PX Interface 330 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 27/07/2013    Mal Chambeyron        Formatted SQL Output
 21/08/2013    Chris Horn            Cleaned Up Code.

*******************************************************************************/
   procedure execute;

end PXIPMX06_EXTRACT;