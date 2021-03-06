CREATE OR REPLACE PACKAGE PXI_APP.pmxpxi03_loader_v2 as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI03_LOADER
  Author    : Jonathan Girling
  Interface : Promax PX Promotions to Atlas Interface

  Description
  ------------------------------------------------------------------------------
  This package is used for processing Promax Promotion information from Promax.
  It takes the information in the interface and determines if the information
  is for AR Claims or for AP Payments.

  Below is an example of the flow below.

  Promax PX Promotions 359 -> LADS (Inbound) -> Atlas PXIATL02 - Pricing Conditions

  * NOTE This Package should NOT be executed in parallel .. and WILL FAIL on
  * Duplicate XACTN_SEQ should it be executed in parallel.

  Functions
  ------------------------------------------------------------------------------
  + LICS Hooks
    - on_start                   Called on starting the interface.
    - on_data(i_row in varchar2) Called for each row of data in the interface.
    - on_end                     Called at the end of processing.
  + FFLU Hooks
    - on_get_file_type           Returns the type of file format expected.
    - on_get_csv_qualifier       Returns the CSV file format qualifier.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-08-02  Jonathan Girling      Created Interface
  2013-08-15  Mal Chambeyron        Added deletion / synchronization logic.
  2013-08-21  Chris Horn            Basic Clean Up.
  2013-08-26  Mal Chambeyron        Added Atlas document split logic ..
                                    on pxi_common.gc_max_idoc_rows
  2013-09-03  Mal Chambeyron        Add RAISE in APPEND_DATA
                                    Add Better On NULL Error Messages
  2013-10-09  Mal Chambeyron        Modify Logic to RE-WRITE the entire group
                                    (vakey, pricing condition) state
                                    intersecting with the current batch.
                                    Likewise, add handling for action code 'C',
                                    equivalent to 'D'.
  2013-11-05 Chris Horn             Rewrote create batch to create an in
                                    memory timeline of all changes and then
                                    write out the aggregated changes.  Storing
                                    a copy in pmx_price_condtions.
  2013-11-08 Chris Horn             Added exception handling to create batch
                                    functions.  Started creating pricing
                                    reconcilliation report.
  2013-11-29 Jonathan Girling       Changed selecting cust_div_code from
                                    pmx_prom_config table, to now use sales_org
                                    field from interface file.
  2014-02-19 Mal Chambeyron         Add LICS Interface Locking
  2014-02-19 Mal Chambeyron         Add Company / Division criteria to getting
                                    latest Promax Transaction Id
  2014-02-19 Mal Chambeyron         Add Interface Suffix Checking
  2014-02-19 Mal Chambeyron         Add Interface Outbound Suffix

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   Carries out the processing required based on the transaction
             sequence number.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Jonathan Girling     Created.
  1.2   2013-08-26 Chris Horn           Cleaned Up.

*******************************************************************************/
  procedure execute(i_batch_seq in number);

/*******************************************************************************
  NAME:      RECONCILE_PRICING_CONDITIONS                                 PUBLIC
  PURPOSE:   Looks at all the pricing condition records and checks that
             a corresponding record has been returned from SAP.  This should be
             run in the early hours of the morning after all the interfacing
             has synchronized.  Approx 2am each day.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-11-08 Chris Horn           Started Creating.

*******************************************************************************/
  procedure reconcile_pricing_conditions;

end pmxpxi03_loader_v2;
/