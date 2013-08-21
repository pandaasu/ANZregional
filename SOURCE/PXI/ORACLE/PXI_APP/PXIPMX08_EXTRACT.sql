create or replace 
PACKAGE PXIPMX08_EXTRACT AS
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : LADS
  Package : PXIPMX08_EXTRACT
  Owner   : DDS_APP
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
  2013-08-21  Chris Horn            Cleaned Up Code

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
  type rt_inbound is record (
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

  type tt_inbound is table of rt_inbound;

  type tt_inbound_array is table of rt_inbound index by binary_integer;

  function get_inbound return tt_inbound pipelined;

END PXIPMX08_EXTRACT;