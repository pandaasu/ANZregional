prompt :: Compile Package [pmxpxi03_loader_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pmxpxi03_loader_v2 as

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
  2014-10-01 Mal Chambeyron         Update [execute], [check_batch] and [create_batch]
                                    - Restrict transaction effects to future
                                      (tomorrow forward), do not modify history.
                                    - Report (email) on Cancels and Deletes of either 
                                      non-existing, or previously Cancelled or 
                                      Deleted conditions, without raising an 
                                      exception.
                                    - Remove "in-memory" logic .. replacing with 
                                      Pipeline .. to improve supportability 
                                      (visability) and performance.
                                    - Correct exception reporting, to only add 
                                      outbound execptions, only once an outbound 
                                      interface placeholder has been created.
                                    * Note
                                      Interface Suffix : Function Constant : Business                                  
                                      '1' > fc_interface_snack > 'SNACK' 
                                      '2' > fc_interface_food > 'FOOD'
                                      '3' > fc_interface_pet > 'PET'
                                      '4' > fc_interface_nz > 'NZ'
                                      
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
  procedure execute(i_batch_seq in number, i_eff_date in date, i_interface_suffix in varchar2);

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

  ------------------------------------------------------------------------------
  type rt_promotions_time_slice is record (
    xactn_type number,
    vakey pmx_359_promotions.vakey%type,
    pricing_condition_code pmx_359_promotions.pricing_condition_code%type,
    condition_table_ref pmx_359_promotions.condition_table_ref%type,
    px_company_code pmx_359_promotions.px_company_code%type,
    cust_div_code pmx_359_promotions.cust_div_code%type,
    new_customer_hierarchy pmx_359_promotions.new_customer_hierarchy%type,
    new_material pmx_359_promotions.new_material%type,
    condition_type_code pmx_359_promotions.condition_type_code%type,
    new_rate_unit pmx_359_promotions.new_rate_unit%type, 
    sales_deal pmx_359_promotions.sales_deal%type,
    new_rate pmx_359_promotions.new_rate%type,
    new_rate_multiplier pmx_359_promotions.new_rate_multiplier%type,
    order_type_code pmx_359_promotions.order_type_code%type,
    buy_start_date pmx_359_promotions.buy_start_date%type,
    buy_stop_date pmx_359_promotions.buy_stop_date%type
  );

  type tt_promotions_time_slice is table of rt_promotions_time_slice;

  function pt_promotions_time_slice(
    i_batch_seq in number, 
    i_eff_date in date, 
    i_batch_time_slice in varchar2
  ) return tt_promotions_time_slice pipelined;
  
  ------------------------------------------------------------------------------
  function pt_promotions_delta(
    i_batch_seq in number, 
    i_eff_date in date 
  ) return tt_promotions_time_slice pipelined;

  ------------------------------------------------------------------------------
    
end pmxpxi03_loader_v2;
/

create or replace package body pmxpxi03_loader_v2 as

  -- Package Constants
  pc_package_name constant pxi_common.st_package_name := 'PMXPXI03_LOADER_V2';
  pc_outbound_interface constant varchar2(30) := 'PXIATL02';

  -- Package Variables
  prv_inbound pmx_359_promotions%rowtype;
  pv_previous_xactn_seq number(15,0);
  pv_previous_px_xactn_id number(10,0) := 0;
  pv_interface_suffix varchar2(64 char);

  -- Subtypes: Pricing Condition
  subtype st_condition_unit is varchar2(1 char);
  subtype st_condition_flag is varchar2(1 char);
  subtype st_pricing_condition is varchar2(5 char);

  -- Package Constants: Pricing Condition Unit/Flags
  pc_condition_unit_dollar      constant st_condition_unit := '1';
  pc_condition_flag_percentage  constant st_condition_flag := 'T';
  pc_condition_flag_dollar      constant st_condition_flag := 'F';

  -- Interface Field Definitions
  pc_ic_record_type constant fflu_common.st_name := 'IC Record Type';
  pc_px_company_code constant fflu_common.st_name := 'PX Company Code';
  pc_px_division_code constant fflu_common.st_name := 'PX Division Code';
  pc_customer_hierarchy constant fflu_common.st_name := 'Customer Hierarchy';
  pc_sales_deal constant fflu_common.st_name := 'Sales Deal';
  pc_material constant fflu_common.st_name := 'Material';
  pc_buy_start_date constant fflu_common.st_name := 'Buy Start Date';
  pc_buy_stop_date constant fflu_common.st_name := 'Buy Stop Date';
  pc_transaction_code constant fflu_common.st_name := 'Transaction Code';
  pc_description constant fflu_common.st_name := 'Description';
  pc_sales_org constant fflu_common.st_name := 'Sales Org';
  pc_rate constant fflu_common.st_name := 'Rate';
  pc_user_1 constant fflu_common.st_name := 'User 1';
  pc_user_2 constant fflu_common.st_name := 'User 2';
  pc_action_code constant fflu_common.st_name := 'Action Code';
  pc_bonus_stock_description constant fflu_common.st_name := 'Bonus Stock Description';
  pc_bonus_stock_hurdle constant fflu_common.st_name := 'Bonus Stock Hurdle';
  pc_bonus_stock_receive constant fflu_common.st_name := 'Bonus Stock Receive';
  pc_bonus_stock_sku_code constant fflu_common.st_name := 'Bonus Stock SKU Code';
  pc_rate_unit constant fflu_common.st_name := 'Rate Unit';
  pc_condition_pricing_unit constant fflu_common.st_name := 'Condition Pricing Unit';
  pc_condition_uom constant fflu_common.st_name := 'Condition UOM';
  pc_sap_promo_number constant fflu_common.st_name := 'SAP Promo Number';
  pc_currency constant fflu_common.st_name := 'Currency';
  pc_uom_str_unit constant fflu_common.st_name := 'UOM Str Unit';
  pc_uom_str_saleable constant fflu_common.st_name := 'UOM Str Saleable';
  pc_promo_price_saleable constant fflu_common.st_name := 'Promo Price Saleable';
  pc_promo_price_unit constant fflu_common.st_name := 'Promo Price Unit';
  pc_transaction_amount constant fflu_common.st_name := 'Transaction Amount';
  pc_payer_code constant fflu_common.st_name := 'Payer Code';
  --
  pc_condition_flag constant fflu_common.st_name := 'Condition Flag';
  pc_business_segment constant fflu_common.st_name := 'Business Segment';
  pc_rate_multiplier constant fflu_common.st_name := 'Rate Multiplier';
  pc_condition_type_code constant fflu_common.st_name := 'Condition Type Code';
  pc_pricing_condition_code constant fflu_common.st_name := 'Pricing Condition Code';
  pc_condition_table_ref constant fflu_common.st_name := 'Condition Table Ref';
  pc_cust_div_code constant fflu_common.st_name := 'Cust Div Code';
  pc_order_type_code constant fflu_common.st_name := 'Order Type Code';

  ------------------------------------------------------------------------------
  procedure on_start is
  begin
  
    --BK 20140624 - clear memory
    pv_previous_px_xactn_id := 0;
  
    -- Get interface suffix
    pv_interface_suffix := fflu_app.fflu_utils.get_interface_suffix;
    if pv_interface_suffix not in (pxi_common.fc_interface_snack,pxi_common.fc_interface_food,pxi_common.fc_interface_pet,pxi_common.fc_interface_nz) then
      pxi_common.raise_promax_error(pc_package_name,'ON_START','Unknown Suffix ['||pv_interface_suffix||'], Expected ['||
        pxi_common.fc_interface_snack||','||
        pxi_common.fc_interface_food||','||
        pxi_common.fc_interface_pet||','||
        pxi_common.fc_interface_nz||']');
    end if;

    -- Request lock (on interface)
    begin
      lics_locking.request(pc_outbound_interface);
    exception
      when others then
        pxi_common.raise_promax_error(pc_package_name,'ON_START',substr('Unable to obtain interface lock ['||pc_outbound_interface||'] - '||sqlerrm, 1, 4000));
    end;

    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_file_header,fflu_data.gc_allow_missing);

    -- Detail Record - Fields
    fflu_data.add_char_field_txt(pc_ic_record_type,1,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_company_code,7,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_px_division_code,10,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_customer_hierarchy,13,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sales_deal,23,10,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_material,33,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_buy_start_date,51,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_txt(pc_buy_stop_date,59,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_transaction_code,67,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_description,71,40,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sales_org,111,4,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_rate,115,12,'999999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_user_1,127,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_user_2,137,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_action_code,147,1,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_bonus_stock_description,148,100,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_bonus_stock_hurdle,248,9,'999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_txt(pc_bonus_stock_receive,257,9,'999999.99',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_txt(pc_bonus_stock_sku_code,266,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_rate_unit,284,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_condition_pricing_unit,289,5,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_condition_uom,294,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_sap_promo_number,297,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_currency,307,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_uom_str_unit,310,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_uom_str_saleable,313,3,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_price_saleable,316,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_promo_price_unit,326,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_transaction_amount,336,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_payer_code,346,20,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);

    -- Get Previous Transaction Seq *** UNIQUIE ACROSS ALL RECORDS
    select nvl(max(xactn_seq),0) into pv_previous_xactn_seq -- pv_previous_xactn_seq MUST not be modified after setting here
    from pmx_359_promotions;

    -- Preset Transaction Seq
    prv_inbound.xactn_seq := pv_previous_xactn_seq;

    -- Get Next Batch Seq
    prv_inbound.batch_seq := pmx_359_promotions_seq.nextval;

    -- Reset Batch Rec Seq
    prv_inbound.batch_rec_seq := 0;

  exception
    when others then
      fflu_data.log_interface_exception('ON_START');
  end on_start;

  ------------------------------------------------------------------------------
  procedure on_data(p_row in varchar2) is
    -- Variables
    v_ok boolean;

    -- Lookup Pricing Conditions
    cursor csr_prom_config(i_company_code in pxi_common.st_company, i_condition_flag in st_condition_flag, i_pricing_condition in st_pricing_condition, i_bus_sgmnt in pxi_common.st_bus_sgmnt) is
    select
      t01.cmpny_code as cmpny_code,
      t01.div_code as div_code,
      t01.cndtn_flag as cndtn_flag,
      t01.rate_unit as rate_unit,
      t01.rate_multiplier as rate_multiplier,
      t01.cndtn_type_code as cndtn_type_code,
      t01.pricing_cndtn_code as pricing_cndtn_code,
      t01.cndtn_table_ref as cndtn_table_ref,
      t01.cust_div_code as cust_div_code,
      t01.order_type_code as order_type_code
    from
      pmx_prom_config t01
    where
      t01.cmpny_code = i_company_code
      and t01.cndtn_flag = i_condition_flag
      and t01.pricing_cndtn_code = i_pricing_condition
      and div_code = i_bus_sgmnt;

    rcd_prom_config csr_prom_config%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then

      prv_inbound.ic_record_type := fflu_data.get_char_field(pc_ic_record_type);
      prv_inbound.px_company_code := fflu_data.get_char_field(pc_px_company_code);
      prv_inbound.px_division_code := fflu_data.get_char_field(pc_px_division_code);
      prv_inbound.customer_hierarchy := fflu_data.get_char_field(pc_customer_hierarchy);
      prv_inbound.sales_deal := fflu_data.get_char_field(pc_sales_deal);
      prv_inbound.material := fflu_data.get_char_field(pc_material);
      prv_inbound.buy_start_date := fflu_data.get_date_field(pc_buy_start_date);
      prv_inbound.buy_stop_date := fflu_data.get_date_field(pc_buy_stop_date);
      prv_inbound.transaction_code := fflu_data.get_char_field(pc_transaction_code);
      prv_inbound.description := fflu_data.get_char_field(pc_description);
      prv_inbound.sales_org := fflu_data.get_char_field(pc_sales_org);
      prv_inbound.rate := fflu_data.get_number_field(pc_rate);
      prv_inbound.user_1 := fflu_data.get_char_field(pc_user_1);
      prv_inbound.user_2 := fflu_data.get_char_field(pc_user_2);
      prv_inbound.action_code := fflu_data.get_char_field(pc_action_code);
      prv_inbound.bonus_stock_description := fflu_data.get_char_field(pc_bonus_stock_description);
      prv_inbound.bonus_stock_hurdle := fflu_data.get_number_field(pc_bonus_stock_hurdle);
      prv_inbound.bonus_stock_receive := fflu_data.get_number_field(pc_bonus_stock_receive);
      prv_inbound.bonus_stock_sku_code := fflu_data.get_char_field(pc_bonus_stock_sku_code);
      prv_inbound.rate_unit := fflu_data.get_char_field(pc_rate_unit);
      prv_inbound.condition_pricing_unit := fflu_data.get_char_field(pc_condition_pricing_unit);
      prv_inbound.condition_uom := fflu_data.get_char_field(pc_condition_uom);
      prv_inbound.sap_promo_number := fflu_data.get_char_field(pc_sap_promo_number);
      prv_inbound.currency := fflu_data.get_char_field(pc_currency);
      prv_inbound.uom_str_unit := fflu_data.get_char_field(pc_uom_str_unit);
      prv_inbound.uom_str_saleable := fflu_data.get_char_field(pc_uom_str_saleable);
      prv_inbound.promo_price_saleable := fflu_data.get_char_field(pc_promo_price_saleable);
      prv_inbound.promo_price_unit := fflu_data.get_char_field(pc_promo_price_unit);
      prv_inbound.transaction_amount := fflu_data.get_char_field(pc_transaction_amount);
      prv_inbound.payer_code := fflu_data.get_char_field(pc_payer_code);

      -- Ignore any Records that do not have a Customer Hierarchy fields.
      -- * These records are header records and not required.
      if trim(fflu_data.get_char_field(pc_customer_hierarchy)) is not null then

        -- Check Action Code
        if nvl(prv_inbound.action_code, 'X') not in ('A','C','D','M') then
          fflu_data.log_field_error(pc_action_code,'Action Code ['||prv_inbound.action_code||'] MUST be one of [''A'',''C'',''D'',''M'']');
        end if;

        -- If NOT Set, Get Last Promax Transaction Id
        if nvl(pv_previous_px_xactn_id, 0) < 1 then
          select nvl(max(px_xactn_id),0) into pv_previous_px_xactn_id
          from pmx_359_promotions
          where px_company_code = prv_inbound.px_company_code
          and px_division_code = prv_inbound.px_division_code;
        end if;

        -- Extract and Check Transaction Id
        prv_inbound.px_xactn_id := to_number(substr(prv_inbound.description, instr(prv_inbound.description, ':')+1),'9999999990');
        if prv_inbound.px_xactn_id < pv_previous_px_xactn_id then
          fflu_data.log_field_error(pc_description,'PX Transaction Id ['||prv_inbound.px_xactn_id||'] is Less Than Previous PX Transaction Id ['||pv_previous_px_xactn_id||'] - Unrecoverable, Must be Resolved Manually');
        end if;
        pv_previous_px_xactn_id := prv_inbound.px_xactn_id;

        -- Check Suffix against Expected Promax Company / Division
        case pv_interface_suffix
          when pxi_common.fc_interface_snack then
            if not (prv_inbound.px_company_code = pxi_common.fc_australia and prv_inbound.px_division_code = pxi_common.fc_bus_sgmnt_snack) then
              fflu_data.log_field_error(pc_px_company_code,'Wrong Promax Company / Division ['||prv_inbound.px_company_code||' / '||prv_inbound.px_division_code||
                '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_australia||' / '||pxi_common.fc_bus_sgmnt_snack||']');
            end if;
          when pxi_common.fc_interface_food then
            if not (prv_inbound.px_company_code = pxi_common.fc_australia and prv_inbound.px_division_code = pxi_common.fc_bus_sgmnt_food) then
              fflu_data.log_field_error(pc_px_company_code,'Wrong Promax Company / Division ['||prv_inbound.px_company_code||' / '||prv_inbound.px_division_code||
                '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_australia||' / '||pxi_common.fc_bus_sgmnt_food||']');
            end if;
          when pxi_common.fc_interface_pet then
            if not (prv_inbound.px_company_code = pxi_common.fc_australia and prv_inbound.px_division_code = pxi_common.fc_bus_sgmnt_petcare) then
              fflu_data.log_field_error(pc_px_company_code,'Wrong Promax Company / Division ['||prv_inbound.px_company_code||' / '||prv_inbound.px_division_code||
                '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_australia||' / '||pxi_common.fc_bus_sgmnt_petcare||']');
            end if;
          when pxi_common.fc_interface_nz then
            if not (prv_inbound.px_company_code = pxi_common.fc_new_zealand and prv_inbound.px_division_code = pxi_common.fc_new_zealand) then
              fflu_data.log_field_error(pc_px_company_code,'Wrong Promax Company / Division ['||prv_inbound.px_company_code||' / '||prv_inbound.px_division_code||
                '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_new_zealand||' / '||pxi_common.fc_new_zealand||']');
            end if;
          else
            fflu_data.log_field_error(pc_px_company_code,'Unknown Suffix ['||pv_interface_suffix||'], Expected ['||
              pxi_common.fc_interface_snack||','||
              pxi_common.fc_interface_food||','||
              pxi_common.fc_interface_pet||','||
              pxi_common.fc_interface_nz||']');
        end case;

        -- Format Customer Hierarchy
        prv_inbound.new_customer_hierarchy := pxi_common.full_cust_code(fflu_data.get_char_field(pc_customer_hierarchy));
        if prv_inbound.new_customer_hierarchy is null then
          fflu_data.log_field_error(pc_customer_hierarchy,'Full Customer Code Lookup (pxi_common.full_cust_code) - Cannot be Null');
        end if;

        -- Format Material
        prv_inbound.new_material := pxi_common.full_matl_code(fflu_data.get_char_field(pc_material));
        if prv_inbound.new_material is null then
          fflu_data.log_field_error(pc_material,'Full Material Code Lookup (pxi_common.full_matl_code) - Cannot be Null');
        end if;

        -- Determine Business Segment
        prv_inbound.business_segment := pxi_utils.determine_bus_sgmnt(fflu_data.get_char_field(pc_px_company_code),fflu_data.get_char_field(pc_px_division_code), prv_inbound.new_material);

        -- Set Condition Flag
        if fflu_data.get_char_field(pc_condition_pricing_unit) = pc_condition_unit_dollar then
          prv_inbound.condition_flag := pc_condition_flag_dollar;
        else
          prv_inbound.condition_flag := pc_condition_flag_percentage;
        end if;

        -- Lookup Pricing Condition Information from PXI_PROM_CONFIG to send to ATLAS.
        open csr_prom_config(prv_inbound.px_company_code, prv_inbound.condition_flag, prv_inbound.user_1, prv_inbound.business_segment);
        fetch csr_prom_config into rcd_prom_config;
          if csr_prom_config%notfound then
            fflu_data.log_field_error(pc_description,'Pricing Condition, Not Found - Company [' || prv_inbound.px_company_code || '] Business Segment [' || prv_inbound.business_segment || '] User 1 [' || prv_inbound.user_1 || '] Condition Flag [' || prv_inbound.condition_flag || ']');
          else
            --
            prv_inbound.rate_multiplier := rcd_prom_config.rate_multiplier;
            --
            prv_inbound.condition_type_code := rcd_prom_config.cndtn_type_code;
            if prv_inbound.condition_type_code is null then
              fflu_data.log_field_error(pc_description,'Condition Type Code, Cannot be Null - Pricing Condition - Company [' || prv_inbound.px_company_code || '] Business Segment [' || prv_inbound.business_segment || '] User 1 [' || prv_inbound.user_1 || '] Condition Flag [' || prv_inbound.condition_flag || ']');
            end if;
            --
            prv_inbound.pricing_condition_code := rcd_prom_config.pricing_cndtn_code;
            if prv_inbound.pricing_condition_code is null then
              fflu_data.log_field_error(pc_description,'Pricing Condition Code, Cannot be Null - Pricing Condition - Company [' || prv_inbound.px_company_code || '] Business Segment [' || prv_inbound.business_segment || '] User 1 [' || prv_inbound.user_1 || '] Condition Flag [' || prv_inbound.condition_flag || ']');
            end if;
            --
            prv_inbound.condition_table_ref := rcd_prom_config.cndtn_table_ref;
            if prv_inbound.condition_table_ref is null then
              fflu_data.log_field_error(pc_description,'Condition Table Reference, Cannot be Null - Pricing Condition - Company [' || prv_inbound.px_company_code || '] Business Segment [' || prv_inbound.business_segment || '] User 1 [' || prv_inbound.user_1 || '] Condition Flag [' || prv_inbound.condition_flag || ']');
            end if;
            -- Check if Sales org is populated, if it is it will contain the customer division code to use, else lookup from the condition configuration table.
            if prv_inbound.sales_org is null then
              prv_inbound.cust_div_code := rcd_prom_config.cust_div_code;
              if prv_inbound.cust_div_code is null then
                fflu_data.log_field_error(pc_description,'Customer Division Code, Cannot be Null - Pricing Condition - Company [' || prv_inbound.px_company_code || '] Business Segment [' || prv_inbound.business_segment || '] User 1 [' || prv_inbound.user_1 || '] Condition Flag [' || prv_inbound.condition_flag || ']');
              end if;
            else
              prv_inbound.cust_div_code := prv_inbound.sales_org;
            end if;
            --
            prv_inbound.order_type_code := rcd_prom_config.order_type_code;
          end if;
        close csr_prom_config;

        -- Create VAKEY
        if nvl(prv_inbound.order_type_code, ' ') = 'ZORB' then
          prv_inbound.vakey := rpad(
             rpad(prv_inbound.px_company_code, 3)
             || ' '
             || prv_inbound.cust_div_code
             || prv_inbound.order_type_code
             || prv_inbound.new_customer_hierarchy
             || prv_inbound.new_material,
             50
          );
        else
          prv_inbound.vakey := rpad(
            rpad(prv_inbound.px_company_code, 3)
            || ' '
            || prv_inbound.cust_div_code
            || prv_inbound.new_customer_hierarchy
            || prv_inbound.new_material,
            50
          );
        end if;

        -- Calculate New Rate
        if nvl(prv_inbound.condition_flag, ' ') = pc_condition_flag_dollar and prv_inbound.rate_multiplier is not null then -- Dollar = F
          prv_inbound.new_rate := (-1 * nvl(prv_inbound.rate, 0) * prv_inbound.rate_multiplier);
        else
          prv_inbound.new_rate := (-1 * nvl(prv_inbound.rate, 0));
        end if;

        -- Calculate New Rate Unit
        if nvl(prv_inbound.condition_flag, ' ') = pc_condition_flag_percentage then -- Percentage = T
          prv_inbound.new_rate_unit := null;
        else
          prv_inbound.new_rate_unit := prv_inbound.currency;
        end if;

        -- Format New Rate Multiplier (Number to Text)
        if nvl(prv_inbound.rate_multiplier,0) > 0 then
          prv_inbound.new_rate_multiplier := trim(to_char(prv_inbound.rate_multiplier, '00000'));
        else
          prv_inbound.new_rate_multiplier := rpad(' ', 5);
        end if;

        -- Increment Transaction Seq
        prv_inbound.xactn_seq := prv_inbound.xactn_seq + 1;

        -- Increment Batch Rec Seq
        prv_inbound.batch_rec_seq := prv_inbound.batch_rec_seq + 1;

        insert into pmx_359_promotions values prv_inbound;

      end if;

    end if;
  exception
    when others then
      fflu_data.log_interface_exception('ON_DATA');
  end on_data;

  ------------------------------------------------------------------------------
  procedure check_batch(
    i_batch_seq in number,
    i_eff_date in date,
    i_interface_suffix in number
  ) is
      
    v_key_message varchar2(4000 char);
    v_message varchar2(4000 char);

    v_previous_state_found boolean;
    v_prev_state_found_in_current boolean;

    v_clash_count number(15,0);

    vr_previous_state pmx_359_promotions%rowtype;

    v_current_action_desc varchar2(16 char);
    v_previous_action_desc varchar2(16 char);

    v_business varchar2(8 char);    
    v_subject varchar2(256 char);
    v_email varchar2(256 char);
    v_warning_flag boolean;
    v_error_flag boolean;
    
    -- log warning, and set warning flag
    procedure log_warning(p_msg in varchar2) is
    begin
      check_batch.v_warning_flag := true;
      lics_mailer.append_data('WARNING: '||p_msg);
    end log_warning;

    -- log error, and set warning and error flags
    procedure log_error(p_msg in varchar2) is
    begin
      check_batch.v_warning_flag := true;
      check_batch.v_error_flag := true;
      lics_mailer.append_data('ERROR: '||p_msg);
      fflu_data.log_interface_error('Method', 'CHECK_BATCH', p_msg);
    end log_error;
    
    -- log error, and raise exception
    procedure raise_exception(p_msg in varchar2) is
    begin
      check_batch.v_warning_flag := true;
      check_batch.v_error_flag := true;
      fflu_data.log_interface_exception(p_msg);
      pxi_common.raise_promax_error(pc_package_name,'CHECK_BATCH',p_msg);
    end raise_exception;
    
  begin

    -- Initialise flags
    v_warning_flag := false;
    v_error_flag := false;
  
    -- Set Setting Suffix from Interface Suffix
    case i_interface_suffix
      when pxi_common.fc_interface_snack then v_business := 'SNACK';
      when pxi_common.fc_interface_food then v_business := 'FOOD';
      when pxi_common.fc_interface_pet then v_business := 'PET';
      when pxi_common.fc_interface_nz then v_business := 'NZ';
      else
        raise_exception('Unknown Suffix ['||i_interface_suffix||'], Expected ['||
          pxi_common.fc_interface_snack||','||
          pxi_common.fc_interface_food||','||
          pxi_common.fc_interface_pet||','||
          pxi_common.fc_interface_nz||']');
    end case;

    -- Set subject
    v_subject := 'Promax PX - ' || v_business || ' - Batch ['||i_batch_seq||'] Effective Date ['||to_char(i_eff_date, 'YYYYMMDD')||'] - WARNINGS';

    -- Retrieve email group
    v_email := lics_setting_configuration.retrieve_setting('PROMAX_PX', 'EMAIL.WARNING.'||v_business);
    if v_email is null then
      raise_exception('['||pc_package_name||'][CHECK_BATCH] - [PROMAX_PX][EMAIL.WARNING.'||v_business||'] Not Found in [LICS_SETTING]');
    end if;

    -- Create email
    lics_mailer.create_email(
      'Promax_PX.Pricing_Conditions@effem.com',
      v_email,
      v_subject,
      lics_parameter.email_smtp_host,
      lics_parameter.email_smtp_port
    );

    -- Create email part
    lics_mailer.create_part('Batch_Check_Report_' || to_char(sysdate, 'YYYYMMDD_HH24MISS') || '.log');

    -- Loop Over Current Transactions
    for vr_current in (
      select *
      from ( -- to get around the fact you can't order a implicit cursor
        select *
        from pmx_359_promotions
        where xactn_seq in (
          select max(xactn_seq)
          from pmx_359_promotions
          where batch_seq = i_batch_seq
          group by vakey,
            pricing_condition_code,
            sales_deal
        )
        and buy_stop_date >= i_eff_date -- transactions effective before [i_eff_date] will not be applied, so are irrelevant
        order by xactn_seq
      )
    )
    loop
      -- Set Key Message for Use in Log Messages
      v_key_message := 'VAKEY ['||vr_current.vakey||'] Pricing Condition ['||vr_current.pricing_condition_code||'] Sales Deal ['||vr_current.sales_deal||'] Action Code ['||vr_current.action_code||']';

      -- Check Previous State, before Current Transaction (Batch)
      v_previous_state_found := false;
      v_prev_state_found_in_current := false;
      vr_previous_state.xactn_seq := null;
      begin
        select * into vr_previous_state
        from pmx_359_promotions
        where xactn_seq in (
          select max(xactn_seq)
          from pmx_359_promotions
          where batch_seq < i_batch_seq -- before Current Transaction (Batch)
          and vakey = vr_current.vakey
          and pricing_condition_code = vr_current.pricing_condition_code
          and sales_deal = vr_current.sales_deal
          group by vakey,
            pricing_condition_code,
            sales_deal
        );
        v_previous_state_found := true;
      exception
        when no_data_found then
          -- Check Previous State, *WITHIN* Current Transaction (Batch)
          begin
            select * into vr_previous_state
            from pmx_359_promotions
            where xactn_seq in (
              select max(xactn_seq)
              from pmx_359_promotions
              where batch_seq = i_batch_seq -- *WITHIN* Current Transaction (Batch)
              and xactn_seq < vr_current.xactn_seq -- and Earlier than Current Transcation
              and vakey = vr_current.vakey
              and pricing_condition_code = vr_current.pricing_condition_code
              and sales_deal = vr_current.sales_deal
              group by vakey,
                pricing_condition_code,
                sales_deal
            );
            v_previous_state_found := true;
            v_prev_state_found_in_current := true;
          exception
            when no_data_found then
                null; -- Error handled below ..
          end;
      end;

      -- Error Conditions ------------------------------------------------------

      -- Check Suffix against Expected Promax Company / Division
      case i_interface_suffix
        when pxi_common.fc_interface_snack then
          if not (vr_current.px_company_code = pxi_common.fc_australia and vr_current.px_division_code = pxi_common.fc_bus_sgmnt_snack) then
            v_message := 'Wrong Promax Company / Division ['||vr_current.px_company_code||' / '||vr_current.px_division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_australia||' / '||pxi_common.fc_bus_sgmnt_snack||'] - '||v_key_message;
            log_error(v_message);
          end if;
        when pxi_common.fc_interface_food then
          if not (vr_current.px_company_code = pxi_common.fc_australia and vr_current.px_division_code = pxi_common.fc_bus_sgmnt_food) then
            v_message := 'Wrong Promax Company / Division ['||vr_current.px_company_code||' / '||vr_current.px_division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_australia||' / '||pxi_common.fc_bus_sgmnt_food||'] - '||v_key_message;
            log_error(v_message);
          end if;
        when pxi_common.fc_interface_pet then
          if not (vr_current.px_company_code = pxi_common.fc_australia and vr_current.px_division_code = pxi_common.fc_bus_sgmnt_petcare) then
            v_message := 'Wrong Promax Company / Division ['||vr_current.px_company_code||' / '||vr_current.px_division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_australia||' / '||pxi_common.fc_bus_sgmnt_petcare||'] - '||v_key_message;
            log_error(v_message);
          end if;
        when pxi_common.fc_interface_nz then
          if not (vr_current.px_company_code = pxi_common.fc_new_zealand and vr_current.px_division_code = pxi_common.fc_new_zealand) then
            v_message := 'Wrong Promax Company / Division ['||vr_current.px_company_code||' / '||vr_current.px_division_code||
              '] for Suffix ['||pv_interface_suffix||'], Expected ['||pxi_common.fc_new_zealand||' / '||pxi_common.fc_new_zealand||'] - '||v_key_message;
            log_error(v_message);
          end if;
        else
          v_message := 'Unknown Suffix ['||pv_interface_suffix||'], Expected ['||
            pxi_common.fc_interface_snack||','||
            pxi_common.fc_interface_food||','||
            pxi_common.fc_interface_pet||','||
            pxi_common.fc_interface_nz||'] - '||v_key_message;
          log_error(v_message);
      end case;
      
      -- Populate current action code description, to provide meaninful error messages
      case vr_current.action_code
        when 'A' then v_current_action_desc := 'ADD';
        when 'C' then v_current_action_desc := 'CANCEL';
        when 'D' then v_current_action_desc := 'DELETE';
        when 'M' then v_current_action_desc := 'MODIFY';
        else 
          v_message := 'Invalid Current Action Code ['||vr_current.action_code||'] MUST be one of [''A'',''C'',''D'',''M''], '||v_key_message;
          log_error(v_message);
      end case;

      if v_previous_state_found then -- Previous State FOUND
        -- Populate previous action code description, to provide meaninful error messages
        case vr_previous_state.action_code
          when 'A' then v_previous_action_desc := 'ADD';
          when 'C' then v_previous_action_desc := 'CANCEL';
          when 'D' then v_previous_action_desc := 'DELETE';
          when 'M' then v_previous_action_desc := 'MODIFY';
          else 
            v_message := 'Invalid Previous Action Code ['||vr_previous_state.action_code||'] MUST be one of [''A'',''C'',''D'',''M''], '||v_key_message;
            log_error(v_message);
        end case;

        if vr_current.action_code = 'A' then
          v_message := 'Previous Transaction State FOUND for '||v_current_action_desc||', '||v_key_message;
          log_error(v_message);
        elsif vr_current.action_code in ('C','D') and vr_previous_state.action_code in ('C','D') then
          v_message := 'Previous Transaction State Already '||v_previous_action_desc||' for '||v_current_action_desc||', '||v_key_message;
          log_warning(v_message); -- Doesn't raise exception
        end if;

      else -- Previous State NOT FOUND
        if vr_current.action_code = 'M' then
          v_message := 'Previous Transaction State NOT FOUND for '||v_current_action_desc||', '||v_key_message;
          log_error(v_message);
        elsif vr_current.action_code in ('C','D') then
          v_message := 'Previous Transaction State NOT FOUND for '||v_current_action_desc||', '||v_key_message;
          log_warning(v_message); -- Doesn't raise exception
        end if;
      end if;

      -- Check If the Promax (3 Key) Will Clash with an Atlas (2 Key) --------
      --   Promax 3 Key .. VAKEY, Pricing Condition Code, Sales Deal
      --   Atlas 2 Key .. VAKEY, Pricing Condition Code

      if vr_current.action_code not in ('C','D') then

        begin

          select count(1) into v_clash_count
          from pmx_359_promotions
          where action_code not in ('C','D')
          and xactn_seq in (
            select max(xactn_seq)
            from pmx_359_promotions
            where xactn_seq < vr_current.xactn_seq -- and Earlier than Current Transcation
            and vakey = vr_current.vakey
            and pricing_condition_code = vr_current.pricing_condition_code
            group by vakey,
              pricing_condition_code,
              sales_deal
          )
          and sales_deal <> vr_current.sales_deal
          and (
            buy_start_date between vr_current.buy_start_date and vr_current.buy_stop_date
            or buy_stop_date between vr_current.buy_start_date and vr_current.buy_stop_date
          );

        exception
          when others then
            v_message := 'Clash Count SQL Raised Exception : '||SQLERRM;
            log_error(v_message);
        end;

        if v_clash_count > 0 then
          v_message := 'Transaction Would Clash with Existing Transaction, '||v_key_message;
          log_error(v_message);
        end if;

      end if;

    end loop;
    
    -- Finalise on Warning or Error
    if v_warning_flag or v_error_flag then -- only send email if warning produced
      lics_mailer.finalise_email;
      
      if v_error_flag then -- Raise Exception on Error
        raise_exception('Error Encountered, Cannot Continue.');
      end if;
    end if;
    
  exception
    when others then
      fflu_data.log_interface_exception('CHECK_BATCH');
      rollback;
      pxi_common.reraise_promax_exception(pc_package_name,'CHECK_BATCH');

  end check_batch;

  ------------------------------------------------------------------------------
  function pt_promotions_time_slice(
    i_batch_seq in number, 
    i_eff_date in date, 
    i_batch_time_slice in varchar2
  ) return tt_promotions_time_slice pipelined is
  
    v_first_row boolean;
    
    v_prev_buy_stop_date date;
    v_max_buy_stop_date date;
    
    rv_zero rt_promotions_time_slice;
  
  begin
  
    v_first_row := true;

    for rv_row in (

      -- xactn_type 0, transaction group header, providing the group range / boundaries
      select
        0 as xactn_type, -- used to sequence within transaction group (vakey, pricing_condition_code, xactn_type)
        vakey, 
        pricing_condition_code,
        max(condition_table_ref) as condition_table_ref,
        max(px_company_code) as px_company_code,
        max(cust_div_code) as cust_div_code,
        max(new_customer_hierarchy) as new_customer_hierarchy,
        max(new_material) as new_material,
        max(condition_type_code) as condition_type_code,
        max(new_rate_unit) as new_rate_unit, -- nullable
        '00000000' as sales_deal,
        0.0 as new_rate,
        max(new_rate_multiplier) as new_rate_multiplier, -- nullable
        max(order_type_code) as order_type_code, -- nullable
        min(buy_start_date) as buy_start_date,
        max(buy_stop_date) as buy_stop_date
      from pmx_359_promotions
      where 
        (
          (i_batch_time_slice = 'current' and batch_seq <= i_batch_seq) -- current view of transaction set effected by current batch
          or
          (i_batch_time_slice = 'previous' and batch_seq < i_batch_seq) -- previous view of transaction set effected by current batch
        )
      and (vakey, pricing_condition_code) in
        (
          select 
            vakey,
            pricing_condition_code
          from pmx_359_promotions
          where batch_seq = i_batch_seq
          group by 
            vakey,
            pricing_condition_code
        ) -- transaction set effected by current batch
      group by vakey,
        pricing_condition_code
      having max(buy_stop_date) >= i_eff_date
      
      union all
      
      -- xactn_type 1, transactions
      select
        1 as xactn_type, -- used to sequence within transaction group (vakey, pricing_condition_code, xactn_type)
        vakey, 
        pricing_condition_code,
        condition_table_ref,
        px_company_code,
        cust_div_code,
        new_customer_hierarchy,
        new_material,
        condition_type_code,
        new_rate_unit, 
        sales_deal,
        new_rate,
        new_rate_multiplier,
        order_type_code, 
        buy_start_date,
        buy_stop_date
      from pmx_359_promotions
      where xactn_seq in 
        (
          select max(xactn_seq)
          from pmx_359_promotions
          where 
            (
              (i_batch_time_slice = 'current' and batch_seq <= i_batch_seq) -- current view of transaction set effected by current batch
              or
              (i_batch_time_slice = 'previous' and batch_seq < i_batch_seq) -- previous view of transaction set effected by current batch
            )
          and (vakey, pricing_condition_code) in
            (
              select 
                vakey,
                pricing_condition_code
              from pmx_359_promotions
              where batch_seq = i_batch_seq
              group by 
                vakey,
                pricing_condition_code
            ) -- transaction set effected by current batch
          group by vakey,
            pricing_condition_code,
            sales_deal
        )
      and buy_stop_date(+) >= i_eff_date
      and action_code(+) not in ('C', 'D')
        
      union all
      
      -- xactn_type 2, dummy end of transactions marker record
      select
        2 as xactn_type, -- used to sequence within transaction group (vakey, pricing_condition_code, xactn_type)
        '999' as vakey, 
        '9999' as pricing_condition_code,
        null as condition_table_ref,
        null as px_company_code,
        null as cust_div_code,
        null as new_customer_hierarchy,
        null as new_material,
        null as condition_type_code,
        null as new_rate_unit, 
        null as sales_deal,
        null as new_rate,
        null as new_rate_multiplier, 
        null as order_type_code, 
        null as buy_start_date,
        null as buy_stop_date
      from dual
      
      order by vakey, pricing_condition_code, xactn_type, buy_start_date

    )
    loop
    
      -- raise all [buy_start_date]s to [i_eff_date]
      if rv_row.buy_start_date < i_eff_date then
        rv_row.buy_start_date := i_eff_date;
      end if;
      
      if rv_row.xactn_type in (0,2) then

        -- closing zero fill, as necessary
        if not v_first_row and v_prev_buy_stop_date < v_max_buy_stop_date then
          rv_zero.buy_start_date := v_prev_buy_stop_date+1;
          rv_zero.buy_stop_date := v_max_buy_stop_date;
          pipe row(rv_zero);       
        end if;
      
        -- initialise new group
        if rv_row.xactn_type = 0 then
          rv_zero.xactn_type := rv_row.xactn_type;
          rv_zero.vakey := rv_row.vakey;
          rv_zero.pricing_condition_code := rv_row.pricing_condition_code;
          rv_zero.condition_table_ref := rv_row.condition_table_ref;
          rv_zero.px_company_code := rv_row.px_company_code;
          rv_zero.cust_div_code := rv_row.cust_div_code;
          rv_zero.new_customer_hierarchy := rv_row.new_customer_hierarchy;
          rv_zero.new_material := rv_row.new_material;
          rv_zero.condition_type_code := rv_row.condition_type_code;
          rv_zero.new_rate_unit := rv_row.new_rate_unit;
          rv_zero.sales_deal := rv_row.sales_deal;
          rv_zero.new_rate := rv_row.new_rate;
          rv_zero.new_rate_multiplier  := rv_row.new_rate_multiplier ;
          rv_zero.order_type_code := rv_row.order_type_code;
          rv_zero.buy_start_date := rv_row.buy_start_date;
          rv_zero.buy_stop_date := rv_row.buy_stop_date;
          --
          v_max_buy_stop_date := rv_row.buy_stop_date;
          v_prev_buy_stop_date := rv_row.buy_start_date-1;
        end if;
        
      else
      
        -- zero fill before current record, as necessary
        if rv_row.buy_start_date > v_prev_buy_stop_date+1 then
          rv_zero.buy_start_date := v_prev_buy_stop_date+1;
          rv_zero.buy_stop_date := rv_row.buy_start_date-1;
          pipe row(rv_zero);       
        end if;
        
        -- write out current record
        pipe row(rv_row);       
        
        -- update [v_prev_buy_stop_date] 
        v_prev_buy_stop_date := rv_row.buy_stop_date;
        
      end if;
      
      v_first_row := false;

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_PROMOTIONS_TIME_SLICE');
  end pt_promotions_time_slice;

  ------------------------------------------------------------------------------
  function pt_promotions_delta(
    i_batch_seq in number, 
    i_eff_date in date 
  ) return tt_promotions_time_slice pipelined is
  
  begin
  
    for rv_row in (

      select curr.*
      from 
        table(pmxpxi03_loader_v2.pt_promotions_time_slice(i_batch_seq, i_eff_date, 'current')) curr
        left outer join 
        table(pmxpxi03_loader_v2.pt_promotions_time_slice(i_batch_seq, i_eff_date, 'previous')) prev
        on 
          curr.vakey = prev.vakey
          and curr.pricing_condition_code = prev.pricing_condition_code
          and curr.buy_start_date = prev.buy_start_date
      where
        (
          nvl(curr.vakey, '::null::') <> nvl(prev.vakey, '::null::')
          or nvl(curr.pricing_condition_code, '::null::') <> nvl(prev.pricing_condition_code, '::null::')
          or nvl(curr.condition_table_ref, '::null::') <> nvl(prev.condition_table_ref, '::null::')
          or nvl(curr.px_company_code, '::null::') <> nvl(prev.px_company_code, '::null::')
          or nvl(curr.cust_div_code, '::null::') <> nvl(prev.cust_div_code, '::null::')
          or nvl(curr.new_customer_hierarchy, '::null::') <> nvl(prev.new_customer_hierarchy, '::null::')
          or nvl(curr.new_material, '::null::') <> nvl(prev.new_material, '::null::')
          or nvl(curr.condition_type_code, '::null::') <> nvl(prev.condition_type_code, '::null::')
          or nvl(curr.new_rate_unit, '::null::') <> nvl(prev.new_rate_unit, '::null::')
          or nvl(curr.sales_deal, '::null::') <> nvl(prev.sales_deal, '::null::')
          or nvl(to_char(curr.new_rate), '::null::') <> nvl(to_char(prev.new_rate), '::null::')
          or nvl(curr.new_rate_multiplier, '::null::') <> nvl(prev.new_rate_multiplier, '::null::')
          or nvl(curr.order_type_code, '::null::') <> nvl(prev.order_type_code, '::null::')
          or nvl(to_char(curr.buy_start_date, 'yyyymmdd'), '::null::') <> nvl(to_char(prev.buy_start_date, 'yyyymmdd'), '::null::')
          or nvl(to_char(curr.buy_stop_date, 'yyyymmdd'), '::null::') <> nvl(to_char(prev.buy_stop_date, 'yyyymmdd'), '::null::')
        )

    )
    loop
      pipe row(rv_row);       
    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_PROMOTIONS_DELTA');
  end pt_promotions_delta;

  ------------------------------------------------------------------------------
  procedure create_batch(
    i_batch_seq in number,
    i_eff_date in date,
    i_interface_suffix in number
  ) is

    v_outbound_record_count number(3, 0);
    v_outbound_interface_instance number(15,0);

  begin

    v_outbound_record_count := 0;
    
    for rv_row in (

      select
        pxi_common.char_format('A', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'A' -> UsageConditionCode
        pxi_common.char_format(condition_table_ref, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- condition_table_ref -> CondTable
        pxi_common.char_format('V', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'V' -> Application
        pxi_common.char_format(vakey, 50, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- VAKEY -> VAKEY
        pxi_common.char_format(px_company_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- px_company_code -> CompanyCode
        pxi_common.char_format(cust_div_code, 2, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- cust_div_code -> Division
        pxi_common.char_format(new_customer_hierarchy, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- new_customer_hierarchy -> Customer
        pxi_common.char_format(new_material, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- material -> Material
        pxi_common.date_format(buy_start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- buy_start_date -> ValidFrom
        pxi_common.date_format(buy_stop_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- buy_stop_date -> ValidTo
        pxi_common.char_format(pricing_condition_code, 4, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- pricing_cndtn_code -> Condition
        pxi_common.char_format(condition_type_code, 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- condition_type_code -> ConditionType
        pxi_common.numb_format(new_rate, 'S9999990.00', pxi_common.fc_is_not_nullable) || -- new_rate -> Rate
        pxi_common.char_format(new_rate_unit, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- new_rate_unit -> RateUnit
        pxi_common.char_format('EA', 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'EA' -> UOM
        pxi_common.char_format(sales_deal, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- sales_deal -> PromoNum
        pxi_common.char_format(new_rate_multiplier, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- new_rate_multiplier -> PriceUnit
        pxi_common.char_format(order_type_code, 4, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- order_type_code -> OrderType
        as output_line
      from table(pmxpxi03_loader_v2.pt_promotions_delta(i_batch_seq, i_eff_date))    
    
    )
    loop

      v_outbound_record_count := v_outbound_record_count + 1;
  
      -- Create outbound interface when required
      if not lics_outbound_loader.is_created then
        v_outbound_interface_instance := lics_outbound_loader.create_interface(pc_outbound_interface||'.'||i_interface_suffix);
      end if;
  
      -- If greater than max idoc rows, finalise and create new interface
      if v_outbound_record_count > pxi_common.gc_max_idoc_rows then
        v_outbound_record_count := 1;
        lics_outbound_loader.finalise_interface;
        v_outbound_interface_instance := lics_outbound_loader.create_interface(pc_outbound_interface||'.'||i_interface_suffix);
      end if;

      lics_outbound_loader.append_data(rv_row.output_line);
    
    end loop;
    
    if v_outbound_record_count > 0 then
      lics_outbound_loader.finalise_interface;
    end if;
    
  exception

    when others then
      fflu_data.log_interface_exception('CREATE_BATCH');
      lics_outbound_loader.add_exception('CREATE_BATCH');
      rollback;
      pxi_common.reraise_promax_exception(pc_package_name,'CREATE_BATCH');

  end create_batch;
 
 
/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(i_batch_seq in number, i_eff_date in date, i_interface_suffix in varchar2) is
  begin
  
    if i_interface_suffix not in (pxi_common.fc_interface_snack,pxi_common.fc_interface_food,pxi_common.fc_interface_pet,pxi_common.fc_interface_nz) then
      pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unknown Suffix ['||i_interface_suffix||'], Expected ['||
        pxi_common.fc_interface_snack||','||
        pxi_common.fc_interface_food||','||
        pxi_common.fc_interface_pet||','||
        pxi_common.fc_interface_nz||']');
    end if;
  
    check_batch(i_batch_seq, i_eff_date, i_interface_suffix);
    create_batch(i_batch_seq, i_eff_date, i_interface_suffix);
    
  exception
    when others then
     fflu_data.log_interface_exception('EXECUTE');
  end execute;

/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/
  procedure on_end is
  begin
    -- Only perform a commit if there were no errors at all.
    if fflu_data.was_errors then
      rollback;
    else
      execute(prv_inbound.batch_seq, trunc(sysdate)+1, pv_interface_suffix); -- outbound processing
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;

    -- Release lock (on interface)
    lics_locking.release(pc_outbound_interface);
  exception
    when others then
      fflu_data.log_interface_exception('ON_END');
  end on_end;

/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/
  function on_get_file_type return varchar2 is
  begin
    return fflu_common.gc_file_type_fixed_width;
  end on_get_file_type;

/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFIER                                         PUBLIC
*******************************************************************************/
  function on_get_csv_qualifier return varchar2 is
  begin
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

/*******************************************************************************
  NAME:      RECONCILE_PRICING_CONDITIONS                                 PUBLIC
*******************************************************************************/
  procedure reconcile_pricing_conditions is
    -- TODO : Add a wrapping select around this to select where record missing from
    -- t2 and or t3 rate rate multiplier or sales deal do not match email report
    -- accordinly.
    cursor csr_reconcilliation_issues is
      select
        t1.*,
        t2.*,
        t3.*
      from
        pmx_price_conditions t1,
        lads_prc_lst_hdr t2,
        lads_prc_lst_det t3
      where t2.vakey (+) = trim(t1.vakey) and
        t2.vkorg (+) = t1.company_code and
        t2.kschl (+) = t1.pricing_condition_code and
        t2.datab (+) = to_char(t1.buy_start_date,'YYYYMMDD') and
        t2.datbi (+) = to_char(t1.buy_stop_date,'YYYYMMDD') and
        t2.kotabnr (+) = t1.condition_table and
        t3.vakey (+) = t2.vakey and
        t3.kschl (+) = t2.kschl and
        t3.knumh (+) = t2.knumh and
        t3.datab (+) = t2.datab and
        t3.detseq(+) = 1;
  begin
    null;
  end reconcile_pricing_conditions;
  
end pmxpxi03_loader_v2;
/

grant execute on pxi_app.pxipmx01_extract_v2 to lics_app, fflu_app, site_app;

