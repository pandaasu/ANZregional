create or replace 
package pmxpxi03_loader_chambma1 as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI03_LOADER_CHAMBMA1
  Author    : Jonathan Girling
  Interface : Promax PX Promotions to Atlas Interface

  Description
  ------------------------------------------------------------------------------
  This package is used for processing Promax Promotion information from Promax.
  It takes the information in the interface and determines if the information 
  is for AR Claims or for AP Payments.  
  
  Below is an example of the flow below. 

  Promax PX Promotions 359 -> LADS (Inbound) -> Atlas PXIATL02 - Pricing Conditions

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

/*

  type rt_inbound is record (
    ic_record_type varchar2(6 char),
    px_company_code varchar2(3 char),
    px_division_code varchar2(3 char),
    customer_hierarchy varchar2(10 char),
    sales_deal varchar2(10 char),
    material varchar2(18 char),
    buy_start_date date,
    buy_stop_date date,
    transaction_code varchar2(4 char),
    description varchar2(40 char),
    sales_org varchar2(4 char),
    rate number(12,2),
    user_1 varchar2(10 char),
    user_2 varchar2(10 char),
    action_code varchar2(1 char),
    bonus_stock_description varchar2(100 char),
    bonus_stock_hurdle number(9,2),
    bonus_stock_receive number(9,2),
    bonus_stock_sku_code varchar2(18 char),
    rate_unit varchar2(5 char),
    condition_pricing_unit varchar2(5 char),
    condition_uom varchar2(3 char),
    sap_promo_number varchar2(10 char),
    currency varchar2(3 char),
    uom_str_unit varchar2(3 char),
    uom_str_saleable varchar2(3 char),
    promo_price_saleable varchar2(10 char),
    promo_price_unit varchar2(10 char),
    transaction_amount varchar2(10 char),
    payer_code varchar2(20 char),
    --
    condition_flag varchar2(1 char),
    business_segment varchar2(2 char),
    rate_multiplier number(4),
    condition_type_code varchar2(1 char),
    pricing_condition_code varchar2(4 char),
    condition_table_ref varchar2(5 char),
    cust_div_code varchar2(2 char),
    order_type_code varchar2(4 char)
  );

  type tt_inbound is table of rt_inbound;

  type tt_inbound_array is table of rt_inbound index by binary_integer;

  function get_inbound return tt_inbound pipelined;
*/
  
end pmxpxi03_loader_chambma1;
/