create or replace 
PACKAGE          PXIPMX01_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX01_EXTRACT
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Product Data - PX Interface 302 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 27/07/2013    Mal Chambeyron        Formatted SQL Output.
 21/08/2013    Chris Horn            Cleaned Up Code.
 27/08/2013    Chris Horn            Updated logic. 

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of product data.
  
             It defaults to all available live promax companies and divisions 
             and just current data as of yesterday.  If null is supplied as 
             the creation date then historial information will be supplied 
             as defined by the business logic.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-21 Chris Horn           Cleaned Up.
  1.3   2013-08-27 Chris Horn           Implemented New Product Logic.

*******************************************************************************/
  procedure execute(
    i_pmx_company in pxi_common.st_company default null,
    i_pmx_division in pxi_common.st_promax_division default null, 
    i_creation_date in date default sysdate-1);

end PXIPMX01_EXTRACT;