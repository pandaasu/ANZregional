create or replace 
PACKAGE          PXIPMX10_EXTRACT as
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
    VENUS -> LADS (Pass Through) -> Promax PX - Cogs - PX Interface 336

 This interface selects sales data for the previous week and multiples the 
 quanties by the cogs data for the given period.  If the cogs data is missing
 the interface will fail.

 Date          Author                Description
 ------------  --------------------  -----------
 2013-09-15    Chris Horn            Created.

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
  1.1   2013-09-15 Chris Horn           Created.

*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate);


/*******************************************************************************
  NAME:      COST_CALCULATION                                             PUBLIC
  PURPOSE:   This function performs the cost calculation and ra
             

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-09-15 Chris Horn           Created.

*******************************************************************************/
  function cost_calculation(i_billing_date in date, i_zrep_matl, i_qty in number, i_cost in number) return number;

end PXIPMX10_EXTRACT;