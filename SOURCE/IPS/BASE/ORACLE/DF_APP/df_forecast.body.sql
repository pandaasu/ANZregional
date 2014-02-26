create or replace  package body        df_forecast as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_demand_file(par_action in varchar2, par_file_id in number,par_append in varchar2);
   procedure process_supply_file(par_action in varchar2, par_file_id in number);

   /***********************************************/
   /* This procedure performs the process routine */
   /***********************************************/
   procedure process(par_action in varchar2, par_file_id in number, par_append in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_result_msg varchar2(3900);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DF Forecast Process';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_load_file is
         select t01.*
           from load_file t01
          where t01.file_id = par_file_id;
      rcd_load_file csr_load_file%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the procedure
      /*-*/
      var_log_prefix := 'DF - FORECAST_PROCESS';
      var_log_search := 'DF_FORECAST_PROCESS' || '_' || to_char(par_file_id) || '_' || lics_stream_processor.callback_parameter('MOE');
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream lock not returned - must be executed from the ICS Stream Processor');
      end if;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*DEMAND_FINAL' and
         upper(par_action) != '*DEMAND_DRAFT' and
         upper(par_action) != '*SUPPLY_FINAL' and
         upper(par_action) != '*SUPPLY_DRAFT' then
         raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *DEMAND_FINAL, *DEMAND_DRAFT, *SUPPLY_FINAL or *SUPPLY_DRAFT');
      end if;
      if par_file_id is null then
         raise_application_error(-20000, 'File identifier must be supplied');
      end if;
      if par_append is not null and par_append != 'TRUE' and par_append != 'FALSE' then 
        raise_application_error(-20000, 'Append instruction must be null, TRUE or FALSE.');
      end if;
      /*-*/
      open csr_load_file;
      fetch csr_load_file into rcd_load_file;
      if csr_load_file%notfound then
         raise_application_error(-20000, 'File id ' || to_char(par_file_id) || ' not found on the load file table');
      end if;
      close csr_load_file;

      /*-*/
      /* Required for invoked demand financials functions
      /* **notes** 1. NEW_LOG required because ICS job processes multiple requests
      /*           2. Should be removed as existing functions replaced
      /*-*/
      logit.new_log;
      logit.enter_method('DF_FORECAST', 'PROCESS');
      logit.log('**ICS_START**');

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Demand Financials Forecast Process - Parameters(' || upper(par_action) || ' + ' || to_char(par_file_id) || ' + ' || rcd_load_file.moe_code || ' + ' || par_append || ')');

      /*-*/
      /* Request the lock on the processing
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Process when lock secured
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the requested procedure
         /*-*/
         begin
            if upper(par_action) = '*DEMAND_FINAL' then
               process_demand_file(par_action,par_file_id,par_append);
            elsif upper(par_action) = '*DEMAND_DRAFT' then
               process_demand_file(par_action,par_file_id,par_append);
            elsif upper(par_action) = '*SUPPLY_FINAL' then
               process_supply_file(par_action,par_file_id);
            elsif upper(par_action) = '*SUPPLY_DRAFT' then
               process_supply_file(par_action,par_file_id);
            end if;
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Release the lock on the processing
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Demand Financials Forecast Process');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Required for invoked demand financials functions
      /* **notes** 1. Should be removed as existing functions replaced
      /*-*/
      logit.log('**ICS_END**');
      logit.leave_method;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(df_parameter.system_code,
                                         df_parameter.system_unit,
                                         df_parameter.system_environment,
                                         con_function,
                                         'DF_FORECAST_PROCESS',
                                         var_email,
                                         'One or more errors occurred during the Demand Financials Forecast Process execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Required for invoked functions
         /*-*/
         logit.leave_method;

         /*-*/
         /* Release the lock when required
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DF_FORECAST - PROCESS - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process;

   /***********************************************************/
   /* This procedure performs the process demand file routine */
   /***********************************************************/
   procedure process_demand_file(par_action in varchar2, par_file_id in number, par_append in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_fcst_id common.st_id;
      var_fcst_valid boolean;
      var_source_type fcst_source.source_type%type;
      var_casting_week load_dmnd.casting_mars_week%type;
      var_found boolean;
      v_item_valid boolean;
      v_invalid_reason common.st_message_string;
      v_calendar_day varchar2(8);
      v_tdu varchar2(18);
      v_price common.st_value;
      v_message_out common.st_message_string;
      v_pricing_condition common.st_message_string;
      v_forecast_type common.st_code;
      v_dmnd_type common.st_code;
      v_ovrd_tdu_flag common.st_status;
      v_matl_dtrmntn_offset common.st_counter;
      v_matl_dtrmntn_type common.st_code;
      var_tot_qty number;
      type rcd_sku is record(tdu varchar2(32),
                             zrep_qty number,
                             tdu_qty number,
                             alloc_factor number,
                             conv_factor number);
      type typ_sku is table of rcd_sku index by binary_integer;
      tbl_sku typ_sku;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_load_file is
         select t01.*
           from load_file t01
          where t01.file_id = par_file_id;
      rcd_load_file csr_load_file%rowtype;

      cursor csr_moe_setting is
         select t01.*
           from moe_setting t01
          where t01.moe_code = rcd_load_file.moe_code;
      rcd_moe_setting csr_moe_setting%rowtype;

      cursor csr_fcst_source is
         select t01.*
           from fcst_source t01
          where t01.fcst_id = var_fcst_id
            and t01.source_type = var_source_type;
      rcd_fcst_source csr_fcst_source%rowtype;

      cursor csr_casting_weeks is
         select distinct t01.casting_mars_week
           from load_dmnd t01
          where t01.file_id = rcd_load_file.file_id;
      type typ_cast is table of csr_casting_weeks%rowtype index by binary_integer;
      tbl_cast typ_cast;

      cursor csr_load_data is
         select t01.*
           from load_dmnd t01
          where t01.file_id = rcd_load_file.file_id
            and t01.casting_mars_week = var_casting_week
            and t01.status = common.gc_loaded;
      type rcd_load_data is table of csr_load_data%rowtype index by binary_integer;
      tab_load_data rcd_load_data;

      cursor csr_matl(i_matl_code in varchar2) is
         select t01.*,
                t02.bus_sgmnt_code
           from matl t01,
                matl_fg_clssfctn t02
          where t01.matl_code = t02.matl_code(+)
            and t01.matl_code = reference_functions.full_matl_code(i_matl_code)
            and t01.matl_type = 'ZREP'
            and t01.trdd_unit = 'X';
      rcd_matl csr_matl%rowtype;

      cursor csr_demand_group_org(i_dmdgroup in varchar2, i_business_segment in varchar2, i_source_code in varchar2) is
         select dgo.dmnd_grp_org_id,
                dgo.currcy_code,
                dgo.invc_prty,
                dgo.distbn_chnl,
                dgo.pricing_formula,
                dgo.sales_org,
                dgo.bill_to_code,
                dgo.ship_to_code,
                dgo.mltplr_value,
                dgo.cust_hrrchy_code,
                dg.sply_whse_lst
           from dmnd_grp dg,
                dmnd_grp_type dt,
                dmnd_grp_org dgo
          where dg.dmnd_grp_type_id = dt.dmnd_grp_type_id
            and dg.dmnd_grp_id = dgo.dmnd_grp_id
            and dt.dmnd_grp_type_code = demand_forecast.gc_demand_group_code_demand
            and dg.dmnd_grp_code = i_dmdgroup
            and dgo.source_code = i_source_code
            and dgo.bus_sgmnt_code = i_business_segment;
      rcd_demand_group_org csr_demand_group_org%rowtype;

      cursor csr_sku_mapping(i_dmdunit in varchar2, i_dmdgroup in varchar2, i_loc in varchar2, i_startdate in varchar2) is
         select t01.item,
                t01.alloc_factor,
                t01.conv_factor
           from dmnd_sku_mapping t01
          where t01.dmd_unit = i_dmdunit
            and t01.dmd_group = i_dmdgroup
            and t01.dfu_locn = i_loc
            and t01.str_date <= i_startdate
            and t01.end_date >= i_startdate
          order by t01.item asc;
      rcd_sku_mapping csr_sku_mapping%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the event start
      /*-*/
      lics_logging.write_log('Begin - Demand file processing');

      /*-*/
      /* Retrieve the requested load file
      /*-*/
      rcd_load_file.file_id := null;
      open csr_load_file;
      fetch csr_load_file into rcd_load_file;
      if csr_load_file%notfound then
         raise_application_error(-20000, 'File id (' || par_file_id || ') not found');
      end if;
      close csr_load_file;

      /*-*/
      /* Retrieve the moe settings
      /*-*/
      v_matl_dtrmntn_offset := 0;
      v_matl_dtrmntn_type := '*TDU';
      open csr_moe_setting;
      fetch csr_moe_setting into rcd_moe_setting;
      if csr_moe_setting%found then
         if not(rcd_moe_setting.matl_dtrmntn_offset is null) then
            v_matl_dtrmntn_offset := rcd_moe_setting.matl_dtrmntn_offset;
            v_matl_dtrmntn_type := rcd_moe_setting.matl_dtrmntn_type;
         end if;
      else
         raise_application_error(-20000, 'Moe settings not found for MOE code (' || rcd_load_file.moe_code || ')');
      end if;
      close csr_moe_setting;
      lics_logging.write_log('Material Determination type: '||v_matl_dtrmntn_type); 
      /*-*/
      /* Update the load data status
      /*-*/
      lics_logging.write_log('--> Updating all load data status to loaded');
      update load_dmnd
         set status = common.gc_loaded
       where file_id = rcd_load_file.file_id;
      commit;

      /*-*/
      /* Retrieve the file casting weeks
      /*-*/
      lics_logging.write_log('--> Retrieving the casting weeks');
      tbl_cast.delete;
      open csr_casting_weeks;
      fetch csr_casting_weeks bulk collect into tbl_cast;
      close csr_casting_weeks;

      /*-*/
      /* Process each forecast (casting week)
      /*-*/
      for icx in 1..tbl_cast.count loop

         /*-*/
         /* Set the casting week
         /*-*/
         lics_logging.write_log('--> Start processing casting week ('||to_char(tbl_cast(icx).casting_mars_week)||')');
         var_casting_week := tbl_cast(icx).casting_mars_week;

         /*-*/
         /* Create/retrieve the forecast
         /*-*/
         if upper(par_action) = '*DEMAND_FINAL' then
            v_forecast_type := demand_forecast.gc_ft_fcst;
         else
            v_forecast_type := demand_forecast.gc_ft_draft;
         end if;
         if demand_forecast.create_forecast(v_forecast_type,
                                            var_casting_week,
                                            demand_forecast.gc_fs_invalid,
                                            rcd_load_file.moe_code,
                                            var_fcst_id,
                                            v_message_out) != common.gc_success then
            raise_application_error(-20000, 'Forecast id invalid or null');
         end if;
         lics_logging.write_log('--> Created/updated forecast ('||to_char(var_fcst_id)||')');

         /*-*/
         /* Clear the temporary forecast table
         /*-*/
         delete from dmnd_temp;
         commit;

         /*-*/
         /* Process the related load data
         /*-*/
         lics_logging.write_log('--> Processing load data for forecast ('||to_char(var_fcst_id)||')');
         loop

            /*-*/
            /* Retrieve the load data in 10000 row chunks
            /* **note** 1. the cursor is opened and closed on each loop to avoid rollback segment issues
            /*          2. the cursor only retrieves load data with a loaded status so only unprocessed rows are used
            /*-*/
            open csr_load_data;
            fetch csr_load_data bulk collect into tab_load_data limit 10000;
            close csr_load_data;
            if tab_load_data.count = 0 then
               exit;
            end if;

            /*-*/
            /* Process the retrieved rows from the array
            /*-*/
            for idx in 1..tab_load_data.count loop

               /*-*/
               /* Validate the item
               /*-*/
               v_item_valid := true;
               v_invalid_reason := null;
               open csr_matl(tab_load_data(idx).zrep_code);
               fetch csr_matl into rcd_matl;
               if csr_matl%notfound then
                  v_item_valid := false;
                  v_invalid_reason := 'ZREP Lookup Error.';
               else
                  if rcd_matl.bus_sgmnt_code is null then
                     raise_application_error(-20000, 'Business segment invalid - ZREP code(' || tab_load_data(idx).zrep_code || ')');
                  end if;
               end if;
               close csr_matl;
               if tab_load_data(idx).source_code is null then
                  raise_application_error(-20000, 'Make source invalid - ZREP code(' || tab_load_data(idx).zrep_code || ')');
               end if;

               /*-*/
               /* Process the load data row - valid item
               /*-*/
               if v_item_valid = true then

                  /*-*/
                  /* Process the demand group data
                  /*-*/
                  var_found := false;
                  open csr_demand_group_org(tab_load_data(idx).dmdgroup, rcd_matl.bus_sgmnt_code, tab_load_data(idx).source_code);
                  loop
                     fetch csr_demand_group_org into rcd_demand_group_org;
                     if csr_demand_group_org%notfound then
                        exit;
                     end if;

                     /*-*/
                     /* Initialise the demand group
                     /*-*/
                     var_found := true;
                     v_calendar_day := to_char(tab_load_data(idx).startdate, 'YYYYMMDD');
                     v_tdu := null;
                     v_ovrd_tdu_flag := common.gc_no;

                     /*-*/
                     /* Process based on material determination type
                     /* **notes** 1. *TDU uses material determination tables
                     /*              1.1. Check for a TDU override in the demand load data
                     /*              1.1. Retrieve the TDU from the material determination data when no override
                     /*-*/
                     if v_matl_dtrmntn_type = '*TDU' then

                        if tab_load_data(idx).fcst_text is not null then
                           if demand_forecast.get_ovrd_tdu(tab_load_data(idx).zrep_code,
                                                           rcd_demand_group_org.distbn_chnl,
                                                           rcd_demand_group_org.sales_org,
                                                           tab_load_data(idx).fcst_text,
                                                           v_tdu,
                                                           v_ovrd_tdu_flag,
                                                           v_invalid_reason,
                                                           v_message_out) != common.gc_success then
                              v_invalid_reason := v_invalid_reason || 'Using standard material determination. ';
                           end if;
                        end if;

                        if v_tdu is null then
                           if demand_forecast.get_tdu(tab_load_data(idx).zrep_code,
                                                      rcd_demand_group_org.distbn_chnl,
                                                      rcd_demand_group_org.sales_org,
                                                      rcd_demand_group_org.bill_to_code,
                                                      rcd_demand_group_org.ship_to_code,
                                                      rcd_demand_group_org.cust_hrrchy_code,
                                                      to_char((to_date(v_calendar_day, 'yyyymmdd') + v_matl_dtrmntn_offset),'yyyymmdd'),
                                                      v_tdu,
                                                      v_message_out) != common.gc_success then
                              v_invalid_reason := v_invalid_reason || 'TDU Material Determination Lookup Failure. ';
                           end if;
                        end if;

                        if demand_forecast.get_price(tab_load_data(idx).zrep_code,
                                                     v_tdu,
                                                     rcd_demand_group_org.distbn_chnl,
                                                     rcd_demand_group_org.bill_to_code,
                                                     rcd_demand_group_org.sales_org,
                                                     rcd_demand_group_org.invc_prty,
                                                     rcd_demand_group_org.sply_whse_lst,
                                                     v_calendar_day,
                                                     rcd_demand_group_org.pricing_formula,
                                                     rcd_demand_group_org.currcy_code,
                                                     v_pricing_condition,
                                                     v_price,
                                                     v_message_out) != common.gc_success then
                           v_invalid_reason := v_invalid_reason || 'Price Lookup Failure. ';
                        end if;

                        v_dmnd_type := null;
                        if tab_load_data(idx).type = 1 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_1;
                        elsif tab_load_data(idx).type = 2 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_2;
                        elsif tab_load_data(idx).type = 3 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_3;
                        elsif tab_load_data(idx).type = 4 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_4;
                        elsif tab_load_data(idx).type = 5 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_5;
                        elsif tab_load_data(idx).type = 6 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_6;
                        elsif tab_load_data(idx).type = 7 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_7;
                        elsif tab_load_data(idx).type = 8 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_8;
                        elsif tab_load_data(idx).type = 9 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_9;
                        elsif tab_load_data(idx).type = 10 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_b;
                        elsif tab_load_data(idx).type = 11 then
                           v_dmnd_type := demand_forecast.gc_dmnd_type_u;
                        end if;

                        insert into dmnd_temp
                           (fcst_id,
                            dmnd_grp_org_id,
                            zrep,
                            qty_in_base_uom,
                            gsv,
                            price,
                            mars_week,
                            price_condition,
                            tdu,
                            type,
                            tdu_ovrd_flag)
                           values(var_fcst_id,
                                  rcd_demand_group_org.dmnd_grp_org_id,
                                  substr(tab_load_data(idx).zrep_code, length(tab_load_data(idx).zrep_code) - 5, 6),
                                  tab_load_data(idx).qty * rcd_demand_group_org.mltplr_value,
                                  (tab_load_data(idx).qty * rcd_demand_group_org.mltplr_value) * v_price,
                                  v_price,
                                  tab_load_data(idx).mars_week,
                                  v_pricing_condition,
                                  v_tdu,
                                  v_dmnd_type,
                                  v_ovrd_tdu_flag);

                     /*-*/
                     /* Process based on material determination type
                     /* **notes** 1. *SKU uses demand SKU mapping table
                     /*              1.1. Retrieve the TDU from the demand SKU mapping data when no override
                     /*              1.1. Adjust the last TDU to reach the total
										 /*						2. The *SKU mapping applies a conversion factor (CONV_FACTOR) to the ZREP quantities.
										 /*								This should be 1, but sometimes for unusual reasons the users will make it 2.
										 /*								Unfortunately this means the sales quantities for ZREPs with not equal those for TDUs
										 /*									as they should.
                     /*-*/
                     elsif v_matl_dtrmntn_type = '*SKU' then

                        /*-*/
                        /* Retrieve and allocate the SKU mapping data
                        /*-*/
                        tbl_sku.delete;
                        var_tot_qty := 0;
                        open csr_sku_mapping(tab_load_data(idx).dmdunit, tab_load_data(idx).dmdgroup, tab_load_data(idx).loc, tab_load_data(idx).startdate);
                        loop
                           fetch csr_sku_mapping into rcd_sku_mapping;
                           if csr_sku_mapping%notfound then
                              exit;
                           end if;
                           tbl_sku(tbl_sku.count+1).tdu := reference_functions.short_matl_code(rcd_sku_mapping.item);
                           tbl_sku(tbl_sku.count).zrep_qty := round(tab_load_data(idx).qty * rcd_sku_mapping.alloc_factor, 10);
													 -- See Note 2 above on this conversion factor
                           tbl_sku(tbl_sku.count).tdu_qty := tbl_sku(tbl_sku.count).zrep_qty * rcd_sku_mapping.conv_factor;
                           tbl_sku(tbl_sku.count).alloc_factor := rcd_sku_mapping.alloc_factor;
                           tbl_sku(tbl_sku.count).conv_factor := rcd_sku_mapping.conv_factor;
                           var_tot_qty := var_tot_qty + tbl_sku(tbl_sku.count).zrep_qty;
                        end loop;
                        close csr_sku_mapping;
                        if tbl_sku.count != 0 then
													/*-*/
													/* Check that ZREP total quantity matches Dmnd_Unit total quanity - otherwise adjust the final quantity
													/*-*/
                           if var_tot_qty != tab_load_data(idx).qty then
                              tbl_sku(tbl_sku.count).zrep_qty := tbl_sku(tbl_sku.count).zrep_qty + (tab_load_data(idx).qty - var_tot_qty);
	 													  -- See Note 2 above on this conversion factor
                              tbl_sku(tbl_sku.count).tdu_qty := tbl_sku(tbl_sku.count).zrep_qty * tbl_sku(tbl_sku.count).conv_factor;
                           end if;
                        end if;

                        /*-*/
                        /* SKU mapping not found
                        /*-*/
                        if tbl_sku.count = 0 then

                           v_invalid_reason := v_invalid_reason || 'SKU Mapping Lookup Failure. ';

                           if demand_forecast.get_price(tab_load_data(idx).zrep_code,
                                                        v_tdu,
                                                        rcd_demand_group_org.distbn_chnl,
                                                        rcd_demand_group_org.bill_to_code,
                                                        rcd_demand_group_org.sales_org,
                                                        rcd_demand_group_org.invc_prty,
                                                        rcd_demand_group_org.sply_whse_lst,
                                                        v_calendar_day,
                                                        rcd_demand_group_org.pricing_formula,
                                                        rcd_demand_group_org.currcy_code,
                                                        v_pricing_condition,
                                                        v_price,
                                                        v_message_out) != common.gc_success then
                              v_invalid_reason := v_invalid_reason || 'Price Lookup Failure. ';
                           end if;

                           v_dmnd_type := null;
                           if tab_load_data(idx).type = 1 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_1;
                           elsif tab_load_data(idx).type = 2 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_2;
                           elsif tab_load_data(idx).type = 3 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_3;
                           elsif tab_load_data(idx).type = 4 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_4;
                           elsif tab_load_data(idx).type = 5 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_5;
                           elsif tab_load_data(idx).type = 6 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_6;
                           elsif tab_load_data(idx).type = 7 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_7;
                           elsif tab_load_data(idx).type = 8 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_8;
                           elsif tab_load_data(idx).type = 9 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_9;
                           elsif tab_load_data(idx).type = 10 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_b;
                           elsif tab_load_data(idx).type = 11 then
                              v_dmnd_type := demand_forecast.gc_dmnd_type_u;
                           end if;

                           insert into dmnd_temp
                              (fcst_id,
                               dmnd_grp_org_id,
                               zrep,
                               qty_in_base_uom,
                               gsv,
                               price,
                               mars_week,
                               price_condition,
                               tdu,
                               type,
                               tdu_ovrd_flag)
                              values(var_fcst_id,
                                     rcd_demand_group_org.dmnd_grp_org_id,
                                     substr(tab_load_data(idx).zrep_code, length(tab_load_data(idx).zrep_code) - 5, 6),
                                     tab_load_data(idx).qty * rcd_demand_group_org.mltplr_value,
                                     (tab_load_data(idx).qty * rcd_demand_group_org.mltplr_value) * v_price,
                                     v_price,
                                     tab_load_data(idx).mars_week,
                                     v_pricing_condition,
                                     v_tdu,
                                     v_dmnd_type,
                                     v_ovrd_tdu_flag);

                        /*-*/
                        /* SKU mapping found
                        /*-*/
                        else

                           /*-*/
                           /* Process the SKU mapping data
                           /*-*/
                           for ids in 1..tbl_sku.count loop

                              if demand_forecast.get_price(tab_load_data(idx).zrep_code,
                                                           tbl_sku(ids).tdu,
                                                           rcd_demand_group_org.distbn_chnl,
                                                           rcd_demand_group_org.bill_to_code,
                                                           rcd_demand_group_org.sales_org,
                                                           rcd_demand_group_org.invc_prty,
                                                           rcd_demand_group_org.sply_whse_lst,
                                                           v_calendar_day,
                                                           rcd_demand_group_org.pricing_formula,
                                                           rcd_demand_group_org.currcy_code,
                                                           v_pricing_condition,
                                                           v_price,
                                                           v_message_out) != common.gc_success then
                                 v_invalid_reason := v_invalid_reason || 'Price Lookup Failure. ';
                              end if;

                              v_dmnd_type := null;
                              if tab_load_data(idx).type = 1 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_1;
                              elsif tab_load_data(idx).type = 2 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_2;
                              elsif tab_load_data(idx).type = 3 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_3;
                              elsif tab_load_data(idx).type = 4 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_4;
                              elsif tab_load_data(idx).type = 5 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_5;
                              elsif tab_load_data(idx).type = 6 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_6;
                              elsif tab_load_data(idx).type = 7 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_7;
                              elsif tab_load_data(idx).type = 8 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_8;
                              elsif tab_load_data(idx).type = 9 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_9;
                              elsif tab_load_data(idx).type = 10 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_b;
                              elsif tab_load_data(idx).type = 11 then
                                 v_dmnd_type := demand_forecast.gc_dmnd_type_u;
                              end if;

                              insert into dmnd_temp
                                 (fcst_id,
                                  dmnd_grp_org_id,
                                  zrep,
                                  qty_in_base_uom,
                                  gsv,
                                  price,
                                  mars_week,
                                  price_condition,
                                  tdu,
                                  type,
                                  tdu_ovrd_flag)
                                 values(var_fcst_id,
                                        rcd_demand_group_org.dmnd_grp_org_id,
                                        substr(tab_load_data(idx).zrep_code, length(tab_load_data(idx).zrep_code) - 5, 6),
                                        tbl_sku(ids).tdu_qty * rcd_demand_group_org.mltplr_value,
                                        (tbl_sku(ids).tdu_qty * rcd_demand_group_org.mltplr_value) * v_price,
                                        v_price,
                                        tab_load_data(idx).mars_week,
                                        v_pricing_condition,
                                        tbl_sku(ids).tdu,
                                        v_dmnd_type,
                                        v_ovrd_tdu_flag);

                           end loop;

                        end if;

                     end if;

                  end loop;
                  close csr_demand_group_org;

                  /*-*/
                  /* No demand groups found
                  /*-*/
                  if var_found = false then
                     raise_application_error(-20000, 'Demand group org lookup failure - Demand group(' || tab_load_data(idx).dmdgroup || '), Business segment(' || rcd_matl.bus_sgmnt_code || '), Source code(' || tab_load_data(idx).source_code || ')');
                  end if;

               end if;

               /*-*/
               /* Update the load data row
               /*-*/
               if v_item_valid = false then
                  update load_dmnd
                     set status = common.gc_errored,
                         error_msg = v_invalid_reason
                   where file_id = tab_load_data(idx).file_id
                     and file_line = tab_load_data(idx).file_line;
               else
                  update load_dmnd
                     set status = decode(v_invalid_reason, null, common.gc_processed, common.gc_failed),
                         error_msg = v_invalid_reason
                   where file_id = tab_load_data(idx).file_id
                     and file_line = tab_load_data(idx).file_line;
               end if;

            end loop;

            /*-*/
            /* Commit the temporary data
            /*-*/
            commit;

         end loop;

         /*-*/
         /* Load the new forecast data within the one commit cycle
         /* to preserve the integrity of the forecast
         /* **notes**
         /* 1. Delete the existing forecast demand data - complete replacement
         /* 2. Insert the new forecast data from the temporary table
         /*-*/
         if par_append = 'FALSE' or par_append is null then 
           lics_logging.write_log('--> Removing existing demand DMND_DATA for forecast ('||to_char(var_fcst_id)||')');
           delete from dmnd_data
            where fcst_id = var_fcst_id
              and dmnd_grp_org_id in (select distinct dgo.dmnd_grp_org_id
                                        from dmnd_grp dg,
                                             dmnd_grp_org dgo,
                                             dmnd_grp_type dt
                                       where dg.dmnd_grp_type_id = dt.dmnd_grp_type_id
                                         and dg.dmnd_grp_id = dgo.dmnd_grp_id
                                         and dt.dmnd_grp_type_code = demand_forecast.gc_demand_group_code_demand);
           commit;
         else 
           lics_logging.write_log('--> Retaining existing demand DMND_DATA for forecast ('|| to_char(var_fcst_id) || '), going to append new data.');
         end if;

         lics_logging.write_log('--> Inserting new demand DMND_DATA for forecast ('||to_char(var_fcst_id)||')');
         insert into dmnd_data select * from dmnd_temp;
         commit;

         /** Perform the promax demand adjustment on any appended promax data. */         
         if par_append = 'TRUE' then 
           lics_logging.write_log('--> Perform Promax Type Adjustment fore forecast ('||to_char(var_fcst_id)||')');
           demand_forecast.perform_promax_adjustment(var_fcst_id);
         end if;

         /*-*/
         /* Clear the temporary forecast table
         /*-*/
         lics_logging.write_log('--> Deleting temporary data for forecast ('||to_char(var_fcst_id)||')');
         delete from dmnd_temp;
         commit;

         /*-*/
         /* Insert/update the forecast source
         /*-*/
         lics_logging.write_log('--> Insert/update demand data received for forecast ('||to_char(var_fcst_id)||')');
         begin
            insert into fcst_source
               (fcst_id,
                source_type,
                source_date)
               values(var_fcst_id,
                      '*DEMAND',
                      sysdate);
         exception
            when dup_val_on_index then
               update fcst_source
                  set source_date = sysdate
                where fcst_id = var_fcst_id
                  and source_type = '*DEMAND';
         end;

         /*-*/
         /* Check/mark the forecast for completion
         /*-*/
         lics_logging.write_log('--> Checking forecast ('||to_char(var_fcst_id)||') for completion');
         var_fcst_valid := true;
         if rcd_moe_setting.dmnd_file = common.gc_yes then
            var_source_type := '*DEMAND';
            open csr_fcst_source;
            fetch csr_fcst_source into rcd_fcst_source;
            if csr_fcst_source%notfound then
               var_fcst_valid := false;
            end if;
            close csr_fcst_source;
         end if;
         if rcd_moe_setting.sply_file = common.gc_yes then
            var_source_type := '*SUPPLY';
            open csr_fcst_source;
            fetch csr_fcst_source into rcd_fcst_source;
            if csr_fcst_source%notfound then
               var_fcst_valid := false;
            end if;
           close csr_fcst_source;
         end if;
         if var_fcst_valid = true then
            lics_logging.write_log('--> Updating forecast ('||to_char(var_fcst_id)||') to complete');
            update fcst
               set status = demand_forecast.gc_fs_valid
             where fcst_id = var_fcst_id;
         end if;

         /*-*/
         /* Commit the forecast
         /*-*/
         commit;

         /*-*/
         /* Stream the forecast dependants when required
         /*-*/
         if upper(par_action) = '*DEMAND_FINAL' then
            if var_fcst_valid = true then
               lics_logging.write_log('--> Triggering final stream for forecast ('||to_char(var_fcst_id)||')');
               lics_stream_loader.clear_parameters;
               lics_stream_loader.set_parameter('FCST_ID',to_char(var_fcst_id));
               lics_stream_loader.execute('DF_FCST_FINAL',null);
            end if;
         else
            if var_fcst_valid = true then
               lics_logging.write_log('--> Triggering draft stream for forecast ('||to_char(var_fcst_id)||')');
               lics_stream_loader.clear_parameters;
               lics_stream_loader.set_parameter('FCST_ID',to_char(var_fcst_id));
               lics_stream_loader.execute('DF_FCST_DRAFT',null);
            end if;
         end if;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('--> End processing casting week ('||to_char(tbl_cast(icx).casting_mars_week)||')');

      end loop;

      /*-*/
      /* Update the load file status to processed
      /*-*/
      update load_file
         set status = common.gc_processed
       where file_id = rcd_load_file.file_id;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event end
      /*-*/
      lics_logging.write_log('End - Demand file processing');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Update the load file when required
         /*-*/
         if not(rcd_load_file.file_id is null) then
            update load_file
               set status = common.gc_errored
             where file_id = rcd_load_file.file_id;
            commit;
         end if;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Demand file processing - ' || var_exception);
            lics_logging.write_log('End - Demand file processing');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   end process_demand_file;

   /***********************************************************/
   /* This procedure performs the process supply file routine */
   /***********************************************************/
   procedure process_supply_file(par_action in varchar2, par_file_id in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_fcst_id common.st_id;
      var_fcst_valid boolean;
      var_source_type fcst_source.source_type%type;
      var_casting_week load_dmnd.casting_mars_week%type;
      var_found boolean;
      v_price_condition common.st_message_string;
      v_item_valid boolean;
      v_invalid_reason common.st_message_string;
      v_calendar_day varchar2(8);
      v_zrep common.st_code;
      v_price common.st_value;
      v_message_out common.st_message_string;
      v_material_code common.st_code;
      v_dest common.st_code;
      v_source_code common.st_code;
      v_forecast_type common.st_code;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_load_file is
         select t01.*
           from load_file t01
          where t01.file_id = par_file_id;
      rcd_load_file csr_load_file%rowtype;

      cursor csr_moe_setting is
         select t01.*
           from moe_setting t01
          where t01.moe_code = rcd_load_file.moe_code;
      rcd_moe_setting csr_moe_setting%rowtype;

      cursor csr_fcst_source is
         select t01.*
           from fcst_source t01
          where t01.fcst_id = var_fcst_id
            and t01.source_type = var_source_type;
      rcd_fcst_source csr_fcst_source%rowtype;

      cursor csr_casting_weeks is
         select distinct t01.casting_mars_week
           from load_sply t01
          where t01.file_id = rcd_load_file.file_id;
      type typ_cast is table of csr_casting_weeks%rowtype index by binary_integer;
      tbl_cast typ_cast;

      cursor csr_load_data is
         select t01.*
           from load_sply t01
          where t01.file_id = rcd_load_file.file_id
            and t01.casting_mars_week = var_casting_week
            and t01.status = common.gc_loaded;
      type rcd_load_data is table of csr_load_data%rowtype index by binary_integer;
      tab_load_data rcd_load_data;

      cursor csr_matl(i_matl_code in varchar2) is
         select t01.*,
                t02.bus_sgmnt_code
           from matl t01,
                matl_fg_clssfctn t02
          where t01.matl_code = t02.matl_code(+)
            and t01.matl_code = i_matl_code
            and t01.matl_type = 'FERT'
            and t01.trdd_unit = 'X';
      rcd_matl csr_matl%rowtype;

      cursor csr_demand_group_org (i_warehouse_code in varchar2, i_source_code in varchar2, i_business_segment_code in varchar2) is
         select dgo.dmnd_grp_org_id,
                dgo.currcy_code,
                dgo.invc_prty,
                dgo.distbn_chnl,
                dgo.pricing_formula,
                dgo.bill_to_code,
                dgo.ship_to_code,
                dgo.sales_org,
                dgo.cust_hrrchy_code,
                dgo.mltplr_value,
                dg.sply_whse_lst
           from dmnd_grp dg,
                dmnd_grp_type dt,
                dmnd_grp_org dgo
          where dg.dmnd_grp_type_id = dt.dmnd_grp_type_id
            and dg.dmnd_grp_id = dgo.dmnd_grp_id
            and dt.dmnd_grp_type_code = demand_forecast.gc_demand_group_code_supply
            and dgo.source_code = i_source_code
            and dg.sply_whse_lst like '%' || i_warehouse_code || '%'
            and dgo.bus_sgmnt_code = i_business_segment_code;
      rcd_demand_group_org csr_demand_group_org%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the event start
      /*-*/
      lics_logging.write_log('Begin - Supply file processing');

      /*-*/
      /* Retrieve the requested load file
      /*-*/
      rcd_load_file.file_id := null;
      open csr_load_file;
      fetch csr_load_file into rcd_load_file;
      if csr_load_file%notfound then
         raise_application_error(-20000, 'File id (' || par_file_id || ') not found');
      end if;
      close csr_load_file;

      /*-*/
      /* Retrieve the moe settings
      /*-*/
      open csr_moe_setting;
      fetch csr_moe_setting into rcd_moe_setting;
      if csr_moe_setting%notfound then
         raise_application_error(-20000, 'Moe settings not found for MOE (' || rcd_load_file.moe_code || ')');
      end if;
      close csr_moe_setting;

      /*-*/
      /* Update the load data status
      /*-*/
      lics_logging.write_log('--> Updating all load data status to loaded');
      update load_sply
         set status = common.gc_loaded
       where file_id = rcd_load_file.file_id;
      commit;

      /*-*/
      /* Retrieve the file casting weeks
      /*-*/
      lics_logging.write_log('--> Retrieving the casting weeks');
      tbl_cast.delete;
      open csr_casting_weeks;
      fetch csr_casting_weeks bulk collect into tbl_cast;
      close csr_casting_weeks;

      /*-*/
      /* Process each forecast (casting week)
      /*-*/
      for icx in 1..tbl_cast.count loop

         /*-*/
         /* Set the casting week
         /*-*/
         lics_logging.write_log('--> Start processing casting week ('||to_char(tbl_cast(icx).casting_mars_week)||')');
         var_casting_week := tbl_cast(icx).casting_mars_week;

         /*-*/
         /* Create/retrieve the forecast
         /*-*/
         if upper(par_action) = '*SUPPLY_FINAL' then
            v_forecast_type := demand_forecast.gc_ft_fcst;
         else
            v_forecast_type := demand_forecast.gc_ft_draft;
         end if;
         if demand_forecast.create_forecast(v_forecast_type,
                                            var_casting_week,
                                            demand_forecast.gc_fs_invalid,
                                            rcd_load_file.moe_code,
                                            var_fcst_id,
                                            v_message_out) != common.gc_success then
            raise_application_error(-20000, 'Forecast id invalid or null');
         end if;
         lics_logging.write_log('--> Created/updated forecast ('||to_char(var_fcst_id)||')');

         /*-*/
         /* Clear the temporary forecast table
         /*-*/
         delete from dmnd_temp;
         commit;

         /*-*/
         /* Process the related load data
         /*-*/
         lics_logging.write_log('--> Processing load data for forecast ('||to_char(var_fcst_id)||')');
         loop

            /*-*/
            /* Retrieve the load data in 10000 row chunks
            /* **note** 1. the cursor is opened and closed on each loop to avoid rollback segment issues
            /*          2. the cursor only retrieves load data with a loaded status so only unprocessed rows are used
            /*-*/
            open csr_load_data;
            fetch csr_load_data bulk collect into tab_load_data limit 10000;
            close csr_load_data;
            if tab_load_data.count = 0 then
               exit;
            end if;

            /*-*/
            /* Process the retrieved rows from the array
            /*-*/
            for idx in 1..tab_load_data.count loop

               /*-*/
               /* Validate the item
               /*-*/
               v_item_valid := true;
               v_invalid_reason := null;
               v_dest := tab_load_data(idx).dest;
               v_calendar_day := to_char(tab_load_data(idx).schedshipdate,'YYYYMMDD');
               v_material_code := reference_functions.full_matl_code(tab_load_data(idx).item);
               v_source_code := demand_forecast.get_source_code(v_material_code);
               if length(trim(v_dest)) != 4 and length(trim(v_dest)) != 5 then
                  v_item_valid := false;
                  v_invalid_reason := v_invalid_reason || 'Unknown Destination Error. ';
               end if;
               open csr_matl(v_material_code);
               fetch csr_matl into rcd_matl;
               if csr_matl%notfound then
                  v_item_valid := false;
                  v_invalid_reason := v_invalid_reason || 'FERT Lookup Error ';
               else
                  if rcd_matl.bus_sgmnt_code is null then
                     raise_application_error(-20000, 'Business segment invalid - TDU code (' || v_material_code || ')');
                  end if;
               end if;
               close csr_matl;
               if demand_forecast.get_zrep_for_tdu(tab_load_data(idx).item, v_zrep, v_message_out) != common.gc_success then
                  v_item_valid := false;
                  v_invalid_reason := v_invalid_reason || 'ZREP Lookup Error. ';
               end if;

               /*-*/
               /* Process the load data row - valid item
               /*-*/
               if v_item_valid = true then

                  var_found := false;
                  open csr_demand_group_org(tab_load_data(idx).dest, v_source_code, rcd_matl.bus_sgmnt_code);
                  loop
                     fetch csr_demand_group_org into rcd_demand_group_org;
                     if csr_demand_group_org%notfound then
                        exit;
                     end if;

                     var_found := true;

                     if demand_forecast.get_price(v_zrep,
                                                  tab_load_data(idx).item,
                                                  rcd_demand_group_org.distbn_chnl,
                                                  rcd_demand_group_org.bill_to_code,
                                                  rcd_demand_group_org.sales_org,
                                                  rcd_demand_group_org.invc_prty,
                                                  rcd_demand_group_org.sply_whse_lst,
                                                  v_calendar_day,
                                                  rcd_demand_group_org.pricing_formula,
                                                  rcd_demand_group_org.currcy_code,
                                                  v_price_condition,
                                                  v_price,
                                                  v_message_out) != common.gc_success then
                        v_invalid_reason := 'Price Lookup Failure.';
                     end if;

                     insert into dmnd_temp
                        (fcst_id,
                         dmnd_grp_org_id,
                         tdu,
                         zrep,
                         qty_in_base_uom,
                         gsv,
                         mars_week,
                         price_condition,
                         price,
                         type)
                        values(var_fcst_id,
                               rcd_demand_group_org.dmnd_grp_org_id,
                               tab_load_data(idx).item,
                               ltrim(v_zrep, '0'),
                               tab_load_data(idx).qty * rcd_demand_group_org.mltplr_value,
                               (tab_load_data(idx).qty * rcd_demand_group_org.mltplr_value) * v_price,
                               tab_load_data(idx).mars_week,
                               v_price_condition,
                               v_price,
                               null);

                  end loop;
                  close csr_demand_group_org;

                  /*-*/
                  /* No demand groups found
                  /*-*/
                  if var_found = false then
                     raise_application_error(-20000, 'Demand group org lookup failure - Destination(' || tab_load_data(idx).dest || '), Source code(' || v_source_code || '), Business segment(' || rcd_matl.bus_sgmnt_code || ')');
                  end if;

               end if;

               /*-*/
               /* Update the load data row
               /*-*/
               if v_item_valid = false then
                  update load_sply
                     set status = common.gc_errored,
                         processed_date = sysdate,
                         error_msg = v_invalid_reason
                   where file_id = tab_load_data(idx).file_id
                     and file_line = tab_load_data(idx).file_line;
               else
                  update load_sply
                     set status = decode(v_invalid_reason, null, common.gc_processed, common.gc_failed),
                         processed_date = sysdate,
                         error_msg = v_invalid_reason
                   where file_id = tab_load_data(idx).file_id
                     and file_line = tab_load_data(idx).file_line;
               end if;

            end loop;

            /*-*/
            /* Commit the temporary data
            /*-*/
            commit;

         end loop;

         /*-*/
         /* Load the new forecast data within the one commit cycle
         /* to preserve the integrity of the forecast
         /* **notes**
         /* 1. Delete the existing forecast supply data - complete replacement
         /* 2. Insert the new forecast data from the temporary table
         /*-*/
         lics_logging.write_log('--> Removing existing supply DMND_DATA for forecast ('||to_char(var_fcst_id)||')');
         delete from dmnd_data
          where fcst_id = var_fcst_id
            and dmnd_grp_org_id in (select distinct dgo.dmnd_grp_org_id
                                      from dmnd_grp dg,
                                           dmnd_grp_org dgo,
                                           dmnd_grp_type dt
                                     where dg.dmnd_grp_type_id = dt.dmnd_grp_type_id
                                       and dg.dmnd_grp_id = dgo.dmnd_grp_id
                                       and dt.dmnd_grp_type_code = demand_forecast.gc_demand_group_code_supply);
         commit;

         lics_logging.write_log('--> Inserting new supply DMND_DATA for forecast ('||to_char(var_fcst_id)||')');
         insert into dmnd_data select * from dmnd_temp;
         commit;

         /*-*/
         /* Clear the temporary forecast table
         /*-*/
         lics_logging.write_log('--> Deleting temporary data for forecast ('||to_char(var_fcst_id)||')');
         delete from dmnd_temp;
         commit;

         /*-*/
         /* Insert/update the forecast source
         /*-*/
         lics_logging.write_log('--> Insert/update supply data received for forecast ('||to_char(var_fcst_id)||')');
         begin
            insert into fcst_source
               (fcst_id,
                source_type,
                source_date)
               values(var_fcst_id,
                      '*SUPPLY',
                      sysdate);
         exception
            when dup_val_on_index then
               update fcst_source
                  set source_date = sysdate
                where fcst_id = var_fcst_id
                  and source_type = '*SUPPLY';
         end;

         /*-*/
         /* Check/mark the forecast for completion
         /*-*/
         lics_logging.write_log('--> Checking forecast ('||to_char(var_fcst_id)||') for completion');
         var_fcst_valid := true;
         if rcd_moe_setting.dmnd_file = common.gc_yes then
            var_source_type := '*DEMAND';
            open csr_fcst_source;
            fetch csr_fcst_source into rcd_fcst_source;
            if csr_fcst_source%notfound then
               var_fcst_valid := false;
            end if;
            close csr_fcst_source;
         end if;
         if rcd_moe_setting.sply_file = common.gc_yes then
            var_source_type := '*SUPPLY';
            open csr_fcst_source;
            fetch csr_fcst_source into rcd_fcst_source;
            if csr_fcst_source%notfound then
               var_fcst_valid := false;
            end if;
            close csr_fcst_source;
         end if;
         if var_fcst_valid = true then
            lics_logging.write_log('--> Updating forecast ('||to_char(var_fcst_id)||') to complete');
            update fcst
               set status = demand_forecast.gc_fs_valid
             where fcst_id = var_fcst_id;
         end if;

         /*-*/
         /* Commit the forecast
         /*-*/
         commit;

         /*-*/
         /* Stream the forecast dependants when required
         /*-*/
         if upper(par_action) = '*SUPPLY_FINAL' then
            if var_fcst_valid = true then
               lics_logging.write_log('--> Triggering final stream for forecast ('||to_char(var_fcst_id)||')');
               lics_stream_loader.clear_parameters;
               lics_stream_loader.set_parameter('FCST_ID',to_char(var_fcst_id));
               lics_stream_loader.execute('DF_FCST_FINAL',null);
            end if;
         else
            if var_fcst_valid = true then
               lics_logging.write_log('--> Triggering draft stream for forecast ('||to_char(var_fcst_id)||')');
               lics_stream_loader.clear_parameters;
               lics_stream_loader.set_parameter('FCST_ID',to_char(var_fcst_id));
               lics_stream_loader.execute('DF_FCST_DRAFT',null);
            end if;
         end if;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('--> End processing casting week ('||to_char(tbl_cast(icx).casting_mars_week)||')');

      end loop;

      /*-*/
      /* Update the load file status to processed
      /*-*/
      update load_file
         set status = common.gc_processed
       where file_id = rcd_load_file.file_id;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event end
      /*-*/
      lics_logging.write_log('End - Supply file processing');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Update the load file when required
         /*-*/
         if not(rcd_load_file.file_id is null) then
            update load_file
               set status = common.gc_errored
             where file_id = rcd_load_file.file_id;
            commit;
         end if;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Supply file processing - ' || var_exception);
            lics_logging.write_log('End - Supply file processing');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   end process_supply_file;

end df_forecast;