create or replace 
PACKAGE          PXIPMX05_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX05_EXTRACT
 Owner   : DDS_APP
 Author  : Chris Horn & Mal Chambeyron

 Description
 -----------
    LADS (Outbound) -> Promax PX - Vendor Data - PX Interface 347

 This interface selects Vendor Data for New Zealand.

 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 
*******************************************************************************/

   procedure execute();

end PXIPMX05_EXTRACT;