create or replace 
PACKAGE PXIPMX08_EXTRACT AS
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : LADS
  Package : PXIPMX08_EXTRACT
  Owner   : PXI_APP
  Author  : Chris Horn

  Description
  ------------------------------------------------------------------------------
  LADS (Outbound) -> Promax PX - AR Claims - 361DECUCT (New Zealand)

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
  2013-06-25  Chris Horn            Created Interface
  2013-07-28  Mal Chambeyron        Updated SQL Formatting
  2013-08-22  Chris Horn            Cleaned Up Code
  2013-08-28  Chris Horn            Made code generic for OZ.
  2013-10-07  Chris Horn            Updated to handle duplicates.
  2013-10-08  Chris Horn            Div Code and Tax Code Logic Added fixed Oz.
  2013-10-14  Chris Horn            Triggered email report of duplicates.
  2013-10-18  Chris Horn            Built html error reporting.
  2013-10-22  Chris Horn            Completed html error reporting.
  2013-10-24  Chris Horn            Added missing 42 reason code.  Changed NZ
                                    duplicate claim checking to not use
                                    div code.
  2013-10-25  Chris Horn            Fixed bugs with report not joining on line
                                    number correctly and joining on NZ duplicate
                                    claim references.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

/*******************************************************************************
  Record Inbound
*******************************************************************************/
  type rt_claim is record (
    idoc_type varchar2(30 char),
    idoc_no number(16,0),
    idoc_date date,
    company_code varchar2(3 char),
    div_code varchar2(3 char),
    cust_code varchar2(10 char),
    claim_amount number(15,4),
    claim_ref varchar2(12 char),
    assignment_no varchar2(18 char),
    tax_base number(15,4),
    posting_date date,
    fiscal_period number(2,0),
    reason_code varchar2(3 char),
    accounting_doc_no varchar2(10 char),
    fiscal_year number(4,0),
    line_item_no varchar2(3),
    bus_partner_ref varchar2(12 char),
    tax_code varchar2(2 char)
  );

  type tt_claims_piped is table of rt_claim;

  type tt_claims_array is table of rt_claim index by binary_integer;

/*******************************************************************************
  NAME:      GET_INBOUND                                                  PUBLIC
  PURPOSE:   This function returns the internal collection of data as a pipeline
             function table so that it can be used in the extract formatting 
             code within the internal execute function. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-10-07 Chris Horn           Renamed Function.

*******************************************************************************/
  function get_claims return tt_claims_piped pipelined;

/*******************************************************************************
  NAME:      GET_DUPLICATE_CLAIMS                                         PUBLIC
  PURPOSE:   This function returns the internal collection of data as a pipeline
             function table so that it can be used in the internal exception 
             reporting function.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-10-07 Chris Horn           Created.

*******************************************************************************/
  function get_duplicate_claims return tt_claims_piped pipelined;
  
/*******************************************************************************
  NAME:      TRIGGER_REPORT                                              PRIVATE
  PURPOSE:   Creates a lics triggered background job to perform the reporting
             in a seperate thread.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-10-07 Chris Horn           Created.
  1.2   2013-10-14 Chris Horn           Implemented.
  
*******************************************************************************/
  procedure trigger_report(i_xactn_seq in fflu_common.st_sequence);
  
/*******************************************************************************
  NAME:      REPORT_DUPLICATES                                            PUBLIC
  PURPOSE:   Looks at the duplicate claims and send an exception report
             to the specific destination email addresses by company code.
             
             Identical duplicates are reported as warnings, and different 
             duplicates are reported as errors. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-10-14 Chris Horn           Created.
  1.2   2013-10-17 Chris Horn           Implemented.

*******************************************************************************/
  procedure report_duplicates(i_xactn_seq in fflu_common.st_sequence, i_interface_suffix in fflu_common.st_interface);

END PXIPMX08_EXTRACT;