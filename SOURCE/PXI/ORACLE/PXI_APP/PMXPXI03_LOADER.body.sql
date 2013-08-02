create or replace 
package body pmxpxi03_loader as

/*******************************************************************************
  Package Variables
*******************************************************************************/
  prv_inbound rt_inbound;
  pv_inbound_array tt_inbound_array;
  
/*******************************************************************************
  Package Definitions
*******************************************************************************/
  -- Subtypes: Pricing Condition 
  subtype st_condition_unit is varchar2(1 char);
  subtype st_condition_flag is varchar2(1 char);
  subtype st_pricing_condition is varchar2(5 char);

  -- Package Constants: Pricing Condition Unit/Flags
  pc_condition_unit_dollar      constant st_condition_unit := '1';
  pc_condition_flag_percentage  constant st_condition_flag := 'T';
  pc_condition_flag_dollar      constant st_condition_flag := 'F';

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/
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


/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/
  procedure on_start is
  begin
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_csv_header,fflu_data.gc_allow_missing);

    -- Detail Record - Fields
    fflu_data.add_char_field_txt(pc_ic_record_type,1,6,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
	fflu_data.add_char_field_txt(pc_px_company_code,7,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
	fflu_data.add_char_field_txt(pc_px_division_code,10,3,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
	fflu_data.add_char_field_txt(pc_customer_hierarchy,13,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
	fflu_data.add_char_field_txt(pc_sales_deal,23,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
	fflu_data.add_char_field_txt(pc_material,33,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
	fflu_data.add_date_field_txt(pc_buy_start_date,51,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
	fflu_data.add_date_field_txt(pc_buy_stop_date,59,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
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

    -- Empty Inbound Array
    pv_inbound_array.delete;

  exception
    when others then
      fflu_utils.log_interface_exception('On Start');
  end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/
  procedure on_data(p_row in varchar2) is
    /*-*
	/*  Local Definitions
	/*-*/
	v_ok boolean;
      
    /*-*/
    /* Lookup Pricing Conditions
    /*-*/   
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

		--
		prv_inbound.ic_record_type := fflu_data.get_char_field(pc_ic_record_type);
		prv_inbound.px_company_code := fflu_data.get_char_field(pc_px_company_code);
		prv_inbound.px_division_code := fflu_data.get_char_field(pc_px_division_code);
		prv_inbound.customer_hierarchy := pxi_common.full_cust_code(fflu_data.get_char_field(pc_customer_hierarchy));
		prv_inbound.sales_deal := fflu_data.get_char_field(pc_sales_deal);
		prv_inbound.material := pxi_common.full_matl_code(fflu_data.get_char_field(pc_material));
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
		--
		
		prv_inbound.business_segment := pxi_common.determine_bus_sgmnt(fflu_data.get_char_field(pc_px_company_code),fflu_data.get_char_field(pc_px_division_code), prv_inbound.material);
		
		if fflu_data.get_char_field(pc_condition_pricing_unit) = pc_condition_unit_dollar then
          prv_inbound.condition_flag :=  pc_condition_flag_dollar;
	    else
		  prv_inbound.condition_flag :=  pc_condition_flag_percentage;
	    end if;   
		

        /******************************************************************/
        /* Ignore any Records that do not have a Customer Hierarchy fields. 
        /* These records are header records and not required.
        /******************************************************************/
        if trim(fflu_data.get_char_field(pc_customer_hierarchy)) is not null then

          /*-*/
          /* Lookup Pricing Condition Information from PXI_PROM_CONFIG to send to ATLAS.
          /*-*/
            
          open csr_prom_config(prv_inbound.px_company_code, prv_inbound.condition_flag, prv_inbound.user_1, prv_inbound.business_segment);
          fetch csr_prom_config into rcd_prom_config;
            if csr_prom_config%notfound then
              fflu_data.log_field_error(pc_user_1,'Unable to determine Pricing Condition information [Company:' || prv_inbound.px_company_code || 'Div:' || prv_inbound.business_segment || 'Pricing Condition:' || prv_inbound.user_1 || 'Condition Flag:' || prv_inbound.condition_flag || '].');
            else
              prv_inbound.rate_multiplier := rcd_prom_config.rate_multiplier;
              prv_inbound.condition_type_code := rcd_prom_config.cndtn_type_code;
              prv_inbound.pricing_condition_code := rcd_prom_config.pricing_cndtn_code;
              prv_inbound.condition_table_ref := rcd_prom_config.cndtn_table_ref;
              prv_inbound.cust_div_code := rcd_prom_config.cust_div_code;
              prv_inbound.order_type_code := rcd_prom_config.order_type_code;
            end if;
          close csr_prom_config;	
          
		  pv_inbound_array(pv_inbound_array.count+1) := prv_inbound;
          
		end if;

    end if;
  exception
    when others then
      fflu_utils.log_interface_exception('On Data');
  end on_data;

/*******************************************************************************
  NAME:      EXECUTE (*MUST* be loacated before ON_END, as is Private)   PRIVATE
*******************************************************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('A', 1, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT 'A' -> UsageConditionCode
		  pxi_common.char_format(condition_table_ref, 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- condition_table_ref -> CondTable
		  pxi_common.char_format('V', 1, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT 'V' -> Application
		  pxi_common.char_format(VAKEY, 50, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- VAKEY -> VAKEY
		  pxi_common.char_format(px_company_code, 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- px_company_code -> CompanyCode
		  pxi_common.char_format(cust_div_code, 2, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- cust_div_code -> Division
		  pxi_common.char_format(customer_hierarchy, 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- customer_hierarchy -> Customer
		  pxi_common.char_format(material, 18, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- material -> Material
		  pxi_common.date_format(buy_start_date, 'yyyymmdd', pxi_common.is_not_nullable) || -- buy_start_date -> ValidFrom
		  pxi_common.date_format(buy_stop_date, 'yyyymmdd', pxi_common.is_not_nullable) || -- buy_stop_date -> ValidTo
		  pxi_common.char_format(pricing_condition_code, 4, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- pricing_cndtn_code -> Condition
		  pxi_common.char_format(condition_type_code, 1, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- condition_type_code -> ConditionType
		  pxi_common.numb_format(rate, 's9999990.00', pxi_common.is_not_nullable) || -- rate -> Rate
		  pxi_common.char_format(rate_unit, 5, pxi_common.format_type_none, pxi_common.is_nullable) || -- rate_unit -> RateUnit
		  pxi_common.char_format('EA', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- CONSTANT 'EA' -> UOM
		  pxi_common.char_format(sales_deal, 10, pxi_common.format_type_none, pxi_common.is_not_nullable) || -- sales_deal -> PromoNum
		  pxi_common.char_format(rate_multiplier, 5, pxi_common.format_type_none, pxi_common.is_nullable) || -- rate_multiplier -> PriceUnit
		  pxi_common.char_format(order_type_code, 4, pxi_common.format_type_none, pxi_common.is_nullable) -- order_type_code -> OrderType
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
		  select 
			t1.condition_table_ref,
			case when t1.order_type_code = 'ZORB' then
			RPAD (
					rpad(t1.px_company_code, 3)
				 || ' '
				 || t1.cust_div_code
				 || t1.order_type_code
				 || t1.customer_hierarchy
				 || t1.material,
				 50,
				 ' ')
			else
				RPAD (
						rpad(t1.px_company_code, 3)
					 || ' '
					 || t1.cust_div_code
					 || t1.customer_hierarchy
					 || t1.material,
					 50,
					 ' ')
			end as VAKEY,
			t1.px_company_code,
			t1.cust_div_code,
			t1.customer_hierarchy,
			t1.material,
			t1.buy_start_date,
			t1.buy_stop_date,
			t1.pricing_condition_code,
			t1.condition_type_code,
			case when t1.condition_flag = 'T' then
				-t1.rate
			else
				case when t1.rate_multiplier is null then 
					-t1.rate
				else
					(-t1.rate * t1.rate_multiplier)
				end
			end as rate,
			case when t1.condition_flag = 'T' then 
				null 
			else 
				t1.currency 
			end as rate_unit,
			t1.sales_deal,
			decode (nvl(t1.rate_multiplier, 0), 0, rpad(' ', 5, ' '), trim(to_char(t1.rate_multiplier, '09999'))) as rate_multiplier,
			t1.order_type_code
		  FROM table(get_inbound) t1
        ------------------------------------------------------------------------
        );
        --======================================================================

   BEGIN

      /*-*/
      /* Retrieve the rows
      /*-*/
      open csr_input;
      loop
         fetch csr_input into var_data;
         if csr_input%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new interface when required
         /*-*/
         if lics_outbound_loader.is_created = false then
            var_instance := lics_outbound_loader.create_interface('PXIATL02');
         end if;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

      end loop;
      close csr_input;

      /*-*/
      /* Finalise the interface when required
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   exception

      when others then
         fflu_utils.log_interface_exception('Execute - Outbound Processing');
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;
         raise;

   end execute;

/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/
  procedure on_end is
  begin
    -- Only perform a commit if there were no errors at all.
    if fflu_data.was_errors = true then
      rollback;
    else
      execute; -- outbound processing
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception
    when others then
      fflu_utils.log_interface_exception('On End');
  end on_end;

/*******************************************************************************
  NAME:      GET_INBOUND                                                  PUBLIC
*******************************************************************************/
  function get_inbound return tt_inbound pipelined is

    v_counter pls_integer;

  begin

     v_counter := 0;
     loop
       v_counter := v_counter + 1;
       exit when v_counter > pv_inbound_array.count;
       pipe row(pv_inbound_array(v_counter));
     end loop;

  end get_inbound;

/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/
  function on_get_file_type return varchar2 is
  begin
    return fflu_common.gc_file_type_fixed_width;
  end on_get_file_type;

/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFER                                          PUBLIC
*******************************************************************************/
  function on_get_csv_qualifier return varchar2 is
  begin
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;


  
end pmxpxi03_loader;
/
