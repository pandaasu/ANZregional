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
 2013-07-23    Chris Horn            Created.
 2013-07-25    Mal Chambeyron        Formatted SQL Output
 2013-08-20    Chris Horn            Updated with revision.
 

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This function creates an extract of sales data for promax.
             It defaults to all available promax companies and divisions and
             for sales from yesterday.  If null is supplied as the creation data
             it will generate all sales history from the hard coded sales 
             history date.
             
             Note that if no date is supplied it will try and extract all 
             relevant data from 01/01/2012 to yesterday.  This may cause 
             issues and fail to run.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.

*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate-1);

end PXIPMX07_EXTRACT;