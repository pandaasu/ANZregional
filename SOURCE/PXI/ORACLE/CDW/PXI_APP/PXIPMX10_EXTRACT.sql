create or replace 
PACKAGE          PXIPMX10_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : VENUS
 Package : PXIPMX07_EXTRACT
 Owner   : PXI_APP
 Author  : Chris Horn

 Description
 -----------
    VENUS -> LADS (Pass Through) -> Promax PX - Cogs - PX Interface 336

 This interface selects sales data for the previous week and multiples the 
 quanties by the cogs data for the given period.  If the cogs data is missing
 the interface will fail.

 Date          Author                Description
 ------------  --------------------  -----------
 2013-09-16    Chris Horn            Created.
 2013-09-18    Chris Horn            Reduced the column width by of the discount 
                                     given field.
 2013-10-14    Chris Horn            Fixed bug with 147 division selection.                                     

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This function creates an extract of sales data for promax and 
             multiplies it by the cogs data.

             It defaults to all available promax companies and divisions and
             for sales from last week.  ie.  The weel prior to the supplied \
             date.
             

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-09-16 Chris Horn           Created.

*******************************************************************************/
   procedure execute (
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate);

end PXIPMX10_EXTRACT;