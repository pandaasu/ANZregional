create or replace 
PACKAGE          PXIPMX07_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : VENUS
 Package : PXIPMX07_EXTRACT
 Owner   : DDS_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
    VENUS -> LADS (Pass Through) -> Promax PX - Sales Data - PX Interface 306

 This interface selects sales data for the specific creation date and company 
 149 and extracts that data and then onsends it to Lads for Pass through.

 Date          Author                Description
 ------------  --------------------  -----------
 23/07/2013    Chris Horn            Created.
 25/07/2013    Mal Chambeyron        Formatted SQL Output         
 
*******************************************************************************/

   procedure execute(i_creation_date in date default sysdate-1);

end PXIPMX07_EXTRACT;
/