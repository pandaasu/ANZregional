create or replace 
package body pmxpxi03_loader as

  -- Package Constants
  pc_package_name constant pxi_common.st_package_name := 'PMXPXI03_LOADER';
  pc_outbound_interface constant varchar2(30) := 'PXIATL02';
  
  -- Package Variables
  prv_inbound pmx_359_promotions%rowtype;
  pv_previous_xactn_seq number(15,0);
  pv_previous_px_xactn_id number(10,0);
  pv_outbound_interface_instance number(15,0);
  pv_outbound_record_count number(3,0);

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

    -- Get Last Promax Transaction Id
    select nvl(max(px_xactn_id),0) into pv_previous_px_xactn_id
    from pmx_359_promotions;

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

        -- Extract and Check Transaction Id
        prv_inbound.px_xactn_id := to_number(substr(prv_inbound.description, instr(prv_inbound.description, ':')+1),'9999999990');
        if prv_inbound.px_xactn_id < pv_previous_px_xactn_id then
          fflu_data.log_field_error(pc_description,'PX Transaction Id ['||prv_inbound.px_xactn_id||'] is Less Than Previous PX Transaction Id ['||pv_previous_px_xactn_id||'] - Unrecoverable, Must be Resolved Manually');
        end if;
        pv_previous_px_xactn_id := prv_inbound.px_xactn_id;

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
            --
            prv_inbound.cust_div_code := rcd_prom_config.cust_div_code;
            if prv_inbound.cust_div_code is null then
              fflu_data.log_field_error(pc_description,'Customer Division Code, Cannot be Null - Pricing Condition - Company [' || prv_inbound.px_company_code || '] Business Segment [' || prv_inbound.business_segment || '] User 1 [' || prv_inbound.user_1 || '] Condition Flag [' || prv_inbound.condition_flag || ']');          
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
  procedure append_record(pr_record in pmx_359_promotions%rowtype) is
  begin
  
    pv_outbound_record_count := pv_outbound_record_count + 1;
    
    -- Create outbound interface when required
    if not lics_outbound_loader.is_created then
      pv_outbound_interface_instance := lics_outbound_loader.create_interface(pc_outbound_interface);
    end if;
          
    -- If greater than max idoc rows, finalise and create new interface
    if pv_outbound_record_count > pxi_common.gc_max_idoc_rows then 
      pv_outbound_record_count := 1;
      lics_outbound_loader.finalise_interface;
      pv_outbound_interface_instance := lics_outbound_loader.create_interface(pc_outbound_interface);
    end if;

    lics_outbound_loader.append_data(  
      pxi_common.char_format('A', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'A' -> UsageConditionCode
      pxi_common.char_format(pr_record.condition_table_ref, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- condition_table_ref -> CondTable
      pxi_common.char_format('V', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'V' -> Application
      pxi_common.char_format(pr_record.vakey, 50, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- VAKEY -> VAKEY
      pxi_common.char_format(pr_record.px_company_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- px_company_code -> CompanyCode
      pxi_common.char_format(pr_record.cust_div_code, 2, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- cust_div_code -> Division
      pxi_common.char_format(pr_record.new_customer_hierarchy, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- customer_hierarchy -> Customer
      pxi_common.char_format(pr_record.new_material, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- material -> Material
      pxi_common.date_format(pr_record.buy_start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- buy_start_date -> ValidFrom
      pxi_common.date_format(pr_record.buy_stop_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- buy_stop_date -> ValidTo
      pxi_common.char_format(pr_record.pricing_condition_code, 4, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- pricing_cndtn_code -> Condition
      pxi_common.char_format(pr_record.condition_type_code, 1, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- condition_type_code -> ConditionType
      pxi_common.numb_format(pr_record.new_rate, 'S9999990.00', pxi_common.fc_is_not_nullable) || -- rate -> Rate
      pxi_common.char_format(pr_record.new_rate_unit, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- rate_unit -> RateUnit
      pxi_common.char_format('EA', 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT 'EA' -> UOM
      pxi_common.char_format(pr_record.sales_deal, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- sales_deal -> PromoNum
      pxi_common.char_format(pr_record.new_rate_multiplier, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- rate_multiplier -> PriceUnit
      pxi_common.char_format(pr_record.order_type_code, 4, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- order_type_code -> OrderType
    );
      
  exception
    when others then
      fflu_data.log_interface_exception('APPEND_RECORD');
      raise;
  end append_record;

  ------------------------------------------------------------------------------
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
  
  ------------------------------------------------------------------------------
  procedure create_batch(i_batch_seq in number) is

    -- Local definitions
    type rt_xactn_group is record (
      vakey pmx_359_promotions.vakey%type,
      pricing_condition_code pmx_359_promotions.pricing_condition_code%type,
      buy_start_date pmx_359_promotions.buy_start_date%type,
      buy_stop_date pmx_359_promotions.buy_stop_date%type
    );
    vr_current_group rt_xactn_group;
    vr_previous_group rt_xactn_group;

    vr_previous pmx_359_promotions%rowtype;
    vr_delete pmx_359_promotions%rowtype;
    vr_debug pmx_359_promotions%rowtype;
    
    v_key_message varchar2(4000 char);

  begin

    -- Loop current state of *ALL* transactions (VAKEY, Pricing Condition) intersecting with current batch
    for vr_current in (
    
      select *
      from ( -- to get around the fact you can't order a implicit cursor
        select *
        from pmx_359_promotions
        where action_code not in ('C','D')
        and xactn_seq in (
          select max(xactn_seq)
          from pmx_359_promotions
          where batch_seq <= i_batch_seq
          and (vakey, pricing_condition_code) in (
            select vakey,
              pricing_condition_code
            from pmx_359_promotions
            where batch_seq = i_batch_seq
            group by vakey, 
              pricing_condition_code
          )
          group by vakey, 
            pricing_condition_code,
            sales_deal  
        )
        order by vakey, 
          pricing_condition_code,
          buy_start_date
      )
    
    )
    loop
      -- Set key message for use in log messages
      v_key_message := 'VAKEY ['||vr_current.vakey||'] Pricing Condition ['||vr_current.pricing_condition_code||'] Sales Deal ['||vr_current.sales_deal||'] Action Code ['||vr_current.action_code||']';

      -- On transaction group (vakey, pricing_condition_code) change
      if vr_current_group.vakey is null 
        or vr_current_group.vakey != vr_current.vakey
        or vr_current_group.pricing_condition_code != vr_current.pricing_condition_code then

        -- Create closing date range delete if necessary
        if vr_previous_group.vakey is not null  
          and vr_previous_group.buy_stop_date > vr_previous.buy_stop_date then
          vr_delete := vr_previous;
          vr_delete.new_rate := 0;
          vr_delete.buy_start_date := vr_previous_group.buy_start_date;
          vr_delete.buy_stop_date := vr_previous_group.buy_stop_date;
          append_record(vr_delete);
        end if;
        
        begin
          select vakey,
            pricing_condition_code,
            min(buy_start_date),
            max(buy_stop_date)
          into vr_current_group
          from pmx_359_promotions
          where batch_seq <= i_batch_seq
          and vakey = vr_current.vakey
          and pricing_condition_code = vr_current.pricing_condition_code
          group by vakey,
            pricing_condition_code;        
        exception
          when no_data_found then
            raise;
              raise_outbound_exception('Date Range NOT FOUND, '||v_key_message); -- should not be possible
        end;                

      end if;
            
      -- Create filler date range delete if necessary
      if vr_current_group.buy_start_date < vr_current.buy_start_date then
          vr_delete := vr_current;
          vr_delete.new_rate := 0;
          vr_delete.buy_start_date := vr_current_group.buy_start_date;
          vr_delete.buy_stop_date := vr_current.buy_start_date - 1;
          append_record(vr_delete);
      end if;
      vr_current_group.buy_start_date := vr_current.buy_stop_date + 1; -- reset group date range start to end of current
      
      -- Zero rate for delete transaction 
      if vr_current.action_code in ('C','D') then
        vr_current.new_rate := 0;
      end if;
      
      -- Create transaction record
      append_record(vr_current);
    
      -- Take copy of current group/record
      vr_previous_group := vr_current_group;
      vr_previous := vr_current;

    end loop;

    -- Create closing date range delete if necessary
    if vr_previous_group.buy_stop_date > vr_previous.buy_stop_date then
      vr_delete := vr_previous;
      vr_delete.new_rate := 0;
      vr_delete.buy_start_date := vr_previous_group.buy_start_date;
      vr_delete.buy_stop_date := vr_previous_group.buy_stop_date;
      append_record(vr_delete);
    end if;
    
    -- Finalise the interface when required
    if lics_outbound_loader.is_created then
       lics_outbound_loader.finalise_interface;
    end if;

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

  ------------------------------------------------------------------------------
  procedure execute(i_batch_seq in number) is

  begin
  
    check_batch(i_batch_seq);
    create_batch(i_batch_seq);
    
  exception

    when others then
       fflu_data.log_interface_exception('EXECUTE');
       rollback;
       if lics_outbound_loader.is_created then
          lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
          lics_outbound_loader.finalise_interface;
       end if;
       raise;
  
  end execute;
   
  ------------------------------------------------------------------------------
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
  exception
    when others then
      fflu_data.log_interface_exception('ON_END');
  end on_end;

  ------------------------------------------------------------------------------
  function on_get_file_type return varchar2 is
  begin
    return fflu_common.gc_file_type_fixed_width;
  end on_get_file_type;

  ------------------------------------------------------------------------------
  function on_get_csv_qualifier return varchar2 is
  begin
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

end pmxpxi03_loader;