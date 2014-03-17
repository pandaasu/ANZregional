prompt :: Compile Package [pmxpxi03_loader_v2] ::::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pmxpxi03_loader_v2 as

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

create or replace package body pxi_app.pmxpxi03_loader_v2 as

  -- Package Constants
  pc_package_name constant pxi_common.st_package_name := 'PMXPXI03_LOADER_V2';
  pc_outbound_interface constant varchar2(30) := 'PXIATL02';

  -- Package Variables
  prv_inbound pmx_359_promotions%rowtype;
  pv_previous_xactn_seq number(15,0);
  pv_previous_px_xactn_id number(10,0);
  pv_outbound_interface_instance number(15,0);
  pv_outbound_record_count number(3,0);
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
    -- fflu_data.add_date_field_txt(pc_buy_stop_date,59,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
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

    -- Reset Outbound Record Count
    pv_outbound_record_count := 0;

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
  procedure raise_outbound_exception(p_exception_msg in varchar2) is
  begin
    fflu_data.log_interface_exception(p_exception_msg);
    lics_outbound_loader.add_exception(p_exception_msg);
    pxi_common.raise_promax_error(pc_package_name,'RAISE_OUTBOUND_EXCEPTION',p_exception_msg);
  end raise_outbound_exception;

  ------------------------------------------------------------------------------
  procedure append_record(pr_record in pmx_price_conditions%rowtype) is
  begin

    pv_outbound_record_count := pv_outbound_record_count + 1;

    -- Create outbound interface when required
    if not lics_outbound_loader.is_created then
      pv_outbound_interface_instance := lics_outbound_loader.create_interface(pc_outbound_interface||'.'||pv_interface_suffix);
    end if;

    -- If greater than max idoc rows, finalise and create new interface
    if pv_outbound_record_count > pxi_common.gc_max_idoc_rows then
      pv_outbound_record_count := 1;
      lics_outbound_loader.finalise_interface;
      pv_outbound_interface_instance := lics_outbound_loader.create_interface(pc_outbound_interface||'.'||pv_interface_suffix);
    end if;

    lics_outbound_loader.append_data(
      pxi_common.char_format('A', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'A' -> UsageConditionCode
      pxi_common.char_format(pr_record.condition_table, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- condition_table_ref -> CondTable
      pxi_common.char_format('V', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'V' -> Application
      pxi_common.char_format(pr_record.vakey, 50, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- VAKEY -> VAKEY
      pxi_common.char_format(pr_record.company_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- px_company_code -> CompanyCode
      pxi_common.char_format(pr_record.cust_div_code, 2, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- cust_div_code -> Division
      pxi_common.char_format(pr_record.cust_hierarchy_code, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- customer_hierarchy -> Customer
      pxi_common.char_format(pr_record.matl_code, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- material -> Material
      pxi_common.date_format(pr_record.buy_start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- buy_start_date -> ValidFrom
      pxi_common.date_format(pr_record.buy_stop_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- buy_stop_date -> ValidTo
      pxi_common.char_format(pr_record.pricing_condition_code, 4, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- pricing_cndtn_code -> Condition
      pxi_common.char_format(pr_record.condition_type_code, 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- condition_type_code -> ConditionType
      pxi_common.numb_format(pr_record.rate, 'S9999990.00', pxi_common.fc_is_not_nullable) || -- rate -> Rate
      pxi_common.char_format(pr_record.rate_unit, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- rate_unit -> RateUnit
      pxi_common.char_format('EA', 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'EA' -> UOM
      pxi_common.char_format(pr_record.sales_deal, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- sales_deal -> PromoNum
      pxi_common.char_format(pr_record.rate_multiplier, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- rate_multiplier -> PriceUnit
      pxi_common.char_format(pr_record.order_type_code, 4, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- order_type_code -> OrderType
    );

  exception
    when others then
      fflu_data.log_interface_exception('APPEND_RECORD');
      raise;
  end append_record;

/*******************************************************************************
  NAME:      CHECK_BATCH                                                 PRIVATE
*******************************************************************************/
  procedure check_batch(i_batch_seq in number) is

    -- Local definitions
    v_key_message varchar2(4000 char);

    v_previous_state_found boolean;
    v_prev_state_found_in_current boolean;

    v_clash_count number(15,0);

    vr_previous_state pmx_359_promotions%rowtype;
    -- vr_first_state pmx_359_promotions%rowtype;

    v_current_action_desc varchar2(16 char);
    v_previous_action_desc varchar2(16 char);
  begin

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

      -- Populate current action code description, to provide meaninful error messages
      case vr_current.action_code
        when 'A' then v_current_action_desc := 'ADD';
        when 'C' then v_current_action_desc := 'CANCEL';
        when 'D' then v_current_action_desc := 'DELETE';
        when 'M' then v_current_action_desc := 'MODIFY';
        else raise_outbound_exception('Invalid Current Action Code ['||vr_current.action_code||'] MUST be one of [''A'',''C'',''D'',''M''], '||v_key_message);
      end case;

      if v_previous_state_found then -- Previous State FOUND
        -- Populate previous action code description, to provide meaninful error messages
        case vr_previous_state.action_code
          when 'A' then v_previous_action_desc := 'ADD';
          when 'C' then v_previous_action_desc := 'CANCEL';
          when 'D' then v_previous_action_desc := 'DELETE';
          when 'M' then v_previous_action_desc := 'MODIFY';
          else raise_outbound_exception('Invalid Previous Action Code ['||vr_previous_state.action_code||'] MUST be one of [''A'',''C'',''D'',''M''], '||v_key_message);
        end case;

        if vr_current.action_code = 'A' then
            raise_outbound_exception('Previous Transaction State FOUND for '||v_current_action_desc||', '||v_key_message);
        elsif vr_current.action_code in ('C','D') and vr_previous_state.action_code in ('C','D') then
            raise_outbound_exception('Previous Transaction State Already '||v_previous_action_desc||' for '||v_current_action_desc||', '||v_key_message);
        end if;

      else -- Previous State NOT FOUND
        if vr_current.action_code in ('C','D','M') then
            raise_outbound_exception('Previous Transaction State NOT FOUND for '||v_current_action_desc||', '||v_key_message);
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
            raise_outbound_exception('Clash Count SQL Raised Exception : '||SQLERRM);
        end;

        if v_clash_count > 0 then
          raise_outbound_exception('Transaction Would Clash with Existing Transaction, '||v_key_message);
        end if;

      end if;

    end loop;

  exception

      when others then
         fflu_data.log_interface_exception('CHECK_BATCH');
         rollback;
         raise;

 end check_batch;

/*******************************************************************************
  NAME:      CREATE_BATCH                                                PRIVATE
*******************************************************************************/
  procedure create_batch(i_batch_seq in number) is

    -- This query determins the vakeys and pricing conditions that we will be
    -- dealing with for this batch, and the minimum and maximum dates involved
    -- in the whole process across all available time.
    cursor csr_batch_keys is
       select
         t1.vakey,
         t1.pricing_condition_code,
         (select min(buy_start_date) from pmx_359_promotions t0 where t0.vakey = t1.vakey and t0.pricing_condition_code = t1.pricing_condition_code and t0.batch_seq <= i_batch_seq) as min_buy_start_date,
         (select max(buy_stop_date) from pmx_359_promotions t0 where t0.vakey = t1.vakey and t0.pricing_condition_code = t1.pricing_condition_code and t0.batch_seq <= i_batch_seq) as max_buy_stop_date
       from pmx_359_promotions t1
       where t1.batch_seq = i_batch_seq
       group by
         t1.vakey,
         t1.pricing_condition_code;
    rv_batch_key csr_batch_keys%rowtype;

   -- Define the in memory data structure to store a timeline of all pricing information.
   type tt_timeline is table of pmx_359_promotions%rowtype index by pls_integer;
   tv_timeline tt_timeline;

   -- Define a cursor with the instructions to be applied up to and including
   -- this batch.
   cursor csr_instructions is
     select *
     from pmx_359_promotions t1
     where
       t1.vakey = rv_batch_key.vakey and
       t1.pricing_condition_code = rv_batch_key.pricing_condition_code and
       t1.batch_seq <= i_batch_seq
    order by
      t1.xactn_seq;
   rv_instruction csr_instructions%rowtype;

   -- This procedure applys the current instruction to the in memory timeline.
   procedure apply_instruction is
     -- Function to calculate the time line position based on a given date.
     function calculate_timeline_position(i_date in date) return pls_integer is
       v_position pls_integer;
     begin
       v_position := i_date - rv_batch_key.min_buy_start_date + 1;
       return v_position;
     exception
       when others then
          fflu_data.log_interface_exception('APPLY_INSTRUCTION');
           raise;
     end calculate_timeline_position;

     -- Function applys the current instruction to the ranage specified.
     procedure set_range(i_from in pls_integer, i_to in pls_integer) is
       v_counter pls_integer;
     begin
       v_counter := i_from;
       loop
         tv_timeline(v_counter) := rv_instruction;
         v_counter := v_counter + 1;
         exit when v_counter > i_to;
       end loop;
      exception
        when others then
           fflu_data.log_interface_exception('SET_RANGE');
           raise;
     end set_range;

     -- Function to brute force zero all records that contain this sales deal.
     procedure zero_sales_deal is
       v_counter pls_integer;
       v_count pls_integer;
     begin
       v_counter := 1;
       v_count := 0;
       loop
         exit when v_count = tv_timeline.count;
         if tv_timeline.exists(v_counter) = true then
           v_count := v_count + 1;
           if tv_timeline(v_counter).sales_deal = rv_instruction.sales_deal then
             tv_timeline(v_counter).new_rate := 0;
           end if;
         end if;
         v_counter := v_counter + 1;
       end loop;
      exception
        when others then
           fflu_data.log_interface_exception('ZERO_SALES_DEAL');
           raise;
     end zero_sales_deal;

   begin
     case rv_instruction.action_code
       when 'A' then
         set_range(
           calculate_timeline_position(rv_instruction.buy_start_date),
           calculate_timeline_position(rv_instruction.buy_stop_date));
       when 'D' then
         rv_instruction.new_rate := 0;
         set_range(
           calculate_timeline_position(rv_instruction.buy_start_date),
           calculate_timeline_position(rv_instruction.buy_stop_date));
       when 'C' then
         rv_instruction.new_rate := 0;
         set_range(
           calculate_timeline_position(rv_instruction.buy_start_date),
           calculate_timeline_position(rv_instruction.buy_stop_date));
       when 'M' then
         -- Zero any entries with the same sales deal, brute force search.
         zero_sales_deal;
         -- Then set this sales deal.
         set_range(
           calculate_timeline_position(rv_instruction.buy_start_date),
           calculate_timeline_position(rv_instruction.buy_stop_date));
      end case;
    exception
      when others then
         fflu_data.log_interface_exception('APPLY_INSTRUCTION');
         raise;
   end apply_instruction;

    -- Now save out the timeline to the pmx_price_conditions table and to the outbound interface.
    procedure save_timeline is
      rv_condition pmx_price_conditions%rowtype;
      v_counter pls_integer;
      v_count pls_integer;
      v_have_condition boolean;

      procedure write_condition is
      begin
        if v_have_condition = true then
          rv_condition.buy_stop_date := rv_batch_key.min_buy_start_date + v_counter - 2;
          insert into pmx_price_conditions values rv_condition;
          append_record(rv_condition);
          v_have_condition := false;
        end if;
      exception
        when others then
           fflu_data.log_interface_exception('WRITE_CONDITION');
           raise;
      end write_condition;
      -- Checks if there are any differences between the last record and the current record.
      function check_for_change return boolean is
        -- Varchar2 Comparator
        function is_different(i_val1 in varchar2, i_val2 in varchar2) return boolean is
        begin
          return not (i_val1 is not null and i_val2 is not null and i_val1 = i_val2 or (i_val1 is null and i_val2 is null));
        end is_different;
        -- Number Comparator
        function is_different(i_val1 in number, i_val2 in number) return boolean is
        begin
          return not (i_val1 is not null and i_val2 is not null and i_val1 = i_val2 or (i_val1 is null and i_val2 is null));
        end is_different;
      begin
        return
          -- Only things that should / could change between records.
          is_different(rv_condition.rate, tv_timeline(v_counter).new_rate) or
          is_different(rv_condition.sales_deal, tv_timeline(v_counter).sales_deal) or
          -- Other things that we should check for changes on regardless.
          is_different(rv_condition.condition_table, tv_timeline(v_counter).condition_table_ref) or
          is_different(rv_condition.company_code, tv_timeline(v_counter).px_company_code) or
          is_different(rv_condition.cust_div_code, tv_timeline(v_counter).cust_div_code) or
          is_different(rv_condition.cust_hierarchy_code, tv_timeline(v_counter).new_customer_hierarchy) or
          is_different(rv_condition.matl_code, tv_timeline(v_counter).new_material) or
          is_different(rv_condition.condition_type_code, tv_timeline(v_counter).condition_type_code) or
          is_different(rv_condition.rate_unit, tv_timeline(v_counter).new_rate_unit) or
          is_different(rv_condition.rate_multiplier, tv_timeline(v_counter).new_rate_multiplier) or
          is_different(rv_condition.order_type_code, tv_timeline(v_counter).order_type_code);
      exception
        when others then
           fflu_data.log_interface_exception('CHECK_FOR_CHANGE');
           raise;
      end check_for_change;
      -- Now take the first pricing condition of this type that we have seen and assign the details to this current record.
      procedure assign_condition is
      begin
        v_have_condition := true;
        rv_condition.vakey := rv_batch_key.vakey;
        rv_condition.pricing_condition_code := rv_batch_key.pricing_condition_code;
        rv_condition.rate := tv_timeline(v_counter).new_rate;
        rv_condition.sales_deal := tv_timeline(v_counter).sales_deal;
        rv_condition.condition_table := tv_timeline(v_counter).condition_table_ref;
        rv_condition.company_code := tv_timeline(v_counter).px_company_code;
        rv_condition.cust_div_code := tv_timeline(v_counter).cust_div_code;
        rv_condition.cust_hierarchy_code := tv_timeline(v_counter).new_customer_hierarchy;
        rv_condition.matl_code := tv_timeline(v_counter).new_material;
        rv_condition.condition_type_code := tv_timeline(v_counter).condition_type_code;
        rv_condition.rate_unit := tv_timeline(v_counter).new_rate_unit;
        rv_condition.rate_multiplier := tv_timeline(v_counter).new_rate_multiplier;
        rv_condition.order_type_code := tv_timeline(v_counter).order_type_code;
        rv_condition.buy_start_date := rv_batch_key.min_buy_start_date + v_counter - 1;
      exception
        when others then
           fflu_data.log_interface_exception('ASSIGN_CONDITION');
           raise;
      end assign_condition;
    begin
      -- Clear any previous records.
      delete from pmx_price_conditions where vakey = rv_batch_key.vakey and pricing_condition_code = rv_batch_key.pricing_condition_code;
      -- Now generate an insert the rest of the records based on the past history.
      v_counter := 1;
      v_count := 0;
      v_have_condition := false;
      loop
        exit when v_count = tv_timeline.count;
        if tv_timeline.exists(v_counter) = true then
          v_count := v_count + 1;
          if v_have_condition = false then
            assign_condition;
          else
            if check_for_change = true then
              write_condition;
              assign_condition;
            end if;
          end if;
        else
          write_condition;
        end if;
        v_counter := v_counter + 1;
      end loop;
      write_condition;
    exception
      when others then
         fflu_data.log_interface_exception('SAVE_TIMELINE');
         raise;
    end save_timeline;

  begin
    -- Now fetch all the unique vakeys pricing condition entries that we need to process for this batch.
    open csr_batch_keys;
    loop
      fetch csr_batch_keys into rv_batch_key;
      exit when csr_batch_keys%notfound;
      -- Now process this specific vakey combination.
      tv_timeline.delete;
      -- Now fetch each of the instructions to build the timeline.
      open csr_instructions;
      loop
        fetch csr_instructions into rv_instruction;
        exit when csr_instructions%notfound;
        apply_instruction;
      end loop;
      close csr_instructions;
      -- Now save the timeline to the table.
      save_timeline;
    end loop;
    close csr_batch_keys;

    -- Finalise the interface when required
    if lics_outbound_loader.is_created then
       lics_outbound_loader.finalise_interface;
    end if;

    -- Commit any changes made at this point.
    commit;
   exception
      when others then
         fflu_data.log_interface_exception('CREATE_BATCH');
         rollback;
         if lics_outbound_loader.is_created then
           lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
           lics_outbound_loader.finalise_interface;
         end if;
         raise;
   end create_batch;

/*******************************************************************************
  NAME:      CHECK_BATCH                                                  PUBLIC
*******************************************************************************/
  procedure execute(i_batch_seq in number) is
  begin
    check_batch(i_batch_seq);
    create_batch(i_batch_seq);
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
      -- execute(pv_previous_xactn_seq); -- outbound processing
      execute(prv_inbound.batch_seq);
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

grant execute on pxi_app.pmxpxi03_loader_v2 to lics_app, fflu_app, site_app;
