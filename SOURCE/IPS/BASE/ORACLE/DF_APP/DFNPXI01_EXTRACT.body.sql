create or replace 
PACKAGE BODY          DFNPXI01_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'DFNPXI01_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'DFNPXI01';
  
/*******************************************************************************
  Package Types
*******************************************************************************/
  type rt_mars_week is record (
    start_date date,
    end_date date);
  type tt_mars_week is table of rt_mars_week index by common.st_code;
/*******************************************************************************
  Package Variables
*******************************************************************************/
  ptv_mars_weeks tt_mars_week;

/*******************************************************************************
  NAME:  GET_MARS_WEEK_DATES                                             PRIVATE
  PURPOSE:   This function will cache the mars week start and end date 
             information.  This is done mostly because there is no
             index on mars date table, and because these lookups need to be
             very quick.
             
             Note we add 1 to the dates to go monday to sunday as the weeks.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-12-02 Chris Horn           Created.
  
*******************************************************************************/
  procedure get_mars_week_dates(
    i_mars_week in common.st_code,
    io_start_date in out date,
    io_end_date in out date) is
    
    -- Initial cache population function.
    cursor csr_mars_weeks is 
      select 
        mars_week, 
        min(calendar_date)+1 as start_date,
        max(calendar_date)+1 as end_date
      from 
        mars_date
      where
        mars_week between 
          (select mars_week from mars_date where calendar_date = trunc(sysdate)) and 
          (select mars_week from mars_date where calendar_date = trunc(sysdate+365*3))
      group by mars_week;
    rv_mars_weeks csr_mars_weeks%rowtype;
    
    -- Cursor to fetch a specific week in case we missed during the initial population.      
    cursor csr_mars_week is
      select 
        min(calendar_date)+1 as start_date,
        max(calendar_date)+1 as end_date
      from 
        mars_date
      where
        mars_week = i_mars_week;
    rv_mars_week csr_mars_week%rowtype;

  begin
    -- Get if we should perform a prepopulation of the array, three years from today's date.
    if ptv_mars_weeks.count = 0 then 
      open csr_mars_weeks;
      loop
        fetch csr_mars_weeks into rv_mars_weeks;
        exit when csr_mars_weeks%notfound;
        ptv_mars_weeks(rv_mars_weeks.mars_week).start_date := rv_mars_weeks.start_date;
        ptv_mars_weeks(rv_mars_weeks.mars_week).end_date := rv_mars_weeks.end_date;
      end loop;
      close csr_mars_weeks;
    end if;
    -- Now check if the data exists for the request mars week.
    if ptv_mars_weeks.exists(i_mars_week) = false then 
      open csr_mars_week;
      fetch csr_mars_week into rv_mars_week;
      if csr_mars_week%found then 
        ptv_mars_weeks(i_mars_week).start_date := rv_mars_week.start_date;
        ptv_mars_weeks(i_mars_week).end_date := rv_mars_week.end_date;
      end if;
      close csr_mars_week;
    end if;
    -- Now fetch and assign the data.
    if ptv_mars_weeks.exists(i_mars_week) = true then 
      io_start_date := ptv_mars_weeks(i_mars_week).start_date;
      io_end_date := ptv_mars_weeks(i_mars_week).end_date;
    else
      pxi_common.raise_promax_error(pc_package_name,'GET_MARS_WEEK_DATES','Could not find mars week data for mars week [' || i_mars_week || ']');
    end if;
  exception 
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_MARS_WEEK_DATES');
  end get_mars_week_dates;


/*******************************************************************************
  NAME:  ALLOCATE_DEMAND_DATA                                             PUBLIC
*******************************************************************************/
  -- The pipelined table function to return the product hierarchy nodes.
  function allocate_demand_data(
    i_dmnd_grp_code in common.st_code,
    i_bus_sgmnt_code in common.st_code,
    i_zrep in common.st_code,
    i_mars_week in common.st_code,
    i_qty in common.st_value
    ) return tt_demand_data pipelined is
    -- Variables
    v_qty_to_allocate common.st_value;
    v_qty_allocated common.st_value;
    v_total_percent common.st_value;
    v_found boolean;
    rv_demand_data rt_demand_data;
    -- Cursor to collect the rows to output data to.
    cursor csr_dmnd_lookup is 
      select ltrim(dmnd_plng_node,'0') as dmnd_plng_node, split_percent 
      from px_dmnd_lookup 
      where
        dmnd_grp_code = i_dmnd_grp_code and 
        bus_sgmnt_code = i_bus_sgmnt_code
      order by
        split_percent, dmnd_grp_desc;
    rv_dmnd_lookup csr_dmnd_lookup%rowtype;
  begin
    -- Initialise Variables.
    v_total_percent := 0;
    v_qty_allocated := 0;
    v_qty_to_allocate := 0;
    v_found := false;
    -- Now calculate the actual amount to allocate.
    v_qty_to_allocate := round(i_qty,0);
    if v_qty_to_allocate < 0 then 
      v_qty_to_allocate := 0;
    end if;
    -- Now assign the zrep material constant.
    rv_demand_data.zrep_matl_code := i_zrep;
    -- Now perform the mars date lookup + 1 for the given mars week as promax week is Monday to Sunday.
    get_mars_week_dates(i_mars_week, rv_demand_data.forecast_start_date, rv_demand_data.forecast_end_date);
    -- Now look for lookup / allocation data.
    open csr_dmnd_lookup;
    loop
      fetch csr_dmnd_lookup into rv_dmnd_lookup;
      exit when csr_dmnd_lookup%notfound;
      -- Update the found flag for error reporting.
      if v_found = false then 
        v_found := true;
      end if;
      -- Now update the percentages
      if rv_dmnd_lookup.split_percent is null then 
        rv_dmnd_lookup.split_percent := 100;
      end if;
      v_total_percent := v_total_percent + rv_dmnd_lookup.split_percent;
      -- Now create the output record.
      rv_demand_data.forecast_customer := rv_dmnd_lookup.dmnd_plng_node;
      rv_demand_data.base_sales_volume := round(rv_dmnd_lookup.split_percent * v_qty_to_allocate / 100,0);
      -- Now check if we are overallocated at this point.
      if v_qty_allocated + rv_demand_data.base_sales_volume > v_qty_to_allocate then 
        rv_demand_data.base_sales_volume := v_qty_to_allocate - v_qty_allocated;
      end if;
      v_qty_allocated := v_qty_allocated + rv_demand_data.base_sales_volume;
      -- Now if the percentage allocation todate is now at 100 then adjust this last record for rounding.
      if v_total_percent = 100 then
        rv_demand_data.base_sales_volume := rv_demand_data.base_sales_volume + v_qty_to_allocate - v_qty_allocated;
      end if;
      if rv_demand_data.base_sales_volume < 0 then  -- This should mathematically not be possible.  But have left in as a safty check. 
        pxi_common.raise_promax_error(pc_package_name,'ALLOCATE_DEMAND_DATA','PX Demand Lookup for Demand Group [' || i_dmnd_grp_code || '], Business Segment [' || i_bus_sgmnt_code || '], Mars Week [' || i_mars_week || '], Zrep [' || i_zrep || '], Qty [' || i_qty || '], tried to balance allocation to highest remaining split but generated a negative number instead [' || rv_demand_data.base_sales_volume || '].  Investigation required.');
      end if;
      -- Now pipe the output of this record.
      pipe row (rv_demand_data);
    end loop;
    close csr_dmnd_lookup;
    -- Now exception out if no records where found.
    if v_found = false then 
      pxi_common.raise_promax_error(pc_package_name,'ALLOCATE_DEMAND_DATA','PX Demand Lookup for Demand Group [' || i_dmnd_grp_code || '] and Business Segment [' || i_bus_sgmnt_code || '], no records could be found.');
    end if;
    -- Perform Checks that everything was correct.
    if v_total_percent is not null and v_total_percent not in (0,100) then 
      pxi_common.raise_promax_error(pc_package_name,'ALLOCATE_DEMAND_DATA','PX Demand Lookup Percentage Split of [' || v_total_percent || '] for Demand Group [' || i_dmnd_grp_code || '] and Business Segment [' || i_bus_sgmnt_code || '] was not 0 or 100%');
    end if;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'ALLOCATE_DEMAND_DATA');
  end allocate_demand_data;

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
  procedure execute(i_fcst_id in common.st_id) is 
    -- Variables     
    v_instance number(15,0);
    v_data pxi_common.st_data;
    v_found boolean;
    v_interface_name pxi_common.st_interface_name;
    v_promax_company common.st_code;
    v_promax_division common.st_code;

    -- Cursor to fetch the forecast header information.
    cursor csr_forecast is
      select * from fcst where fcst_id = i_fcst_id;
    rv_forecast csr_forecast%rowtype;
 
    -- This cursor returns for us the raw data that we need to then extract.
    cursor csr_dmnd_data is 
      select 
        t2.SALES_ORG,
        t2.BUS_SGMNT_CODE,
        t3.dmnd_grp_code,
        t1.zrep,
        t1.mars_week,
        sum(qty_in_base_uom) as qty
      from 
        dmnd_data t1,
        dmnd_grp_org t2,
        dmnd_grp t3,
        dmnd_acct_assign t4
      where 
        t1.fcst_id = i_fcst_id and
        t2.dmnd_grp_org_id = t1.dmnd_grp_org_id and
        t3.dmnd_grp_id = t2.dmnd_grp_id and 
        t4.acct_assign_id = t2.acct_assign_id and 
        t4.acct_assign_code = demand_forecast.gc_acct_assgnmnt_domestic and -- Domestic 
        t1.type in (
          demand_forecast.gc_dmnd_type_1,demand_forecast.gc_dmnd_type_2,demand_forecast.gc_dmnd_type_3,demand_forecast.gc_dmnd_type_4,
          demand_forecast.gc_dmnd_type_5,demand_forecast.gc_dmnd_type_6,demand_forecast.gc_dmnd_type_7,demand_forecast.gc_dmnd_type_8,
          demand_forecast.gc_dmnd_type_9)
      group by
        t2.SALES_ORG,
        t2.BUS_SGMNT_CODE,
        t3.dmnd_grp_code,
        t1.zrep,
        t1.mars_week;
    rv_dmnd_data csr_dmnd_data%rowtype;

    -- The extract to fetch the apollo base forecast information.
    cursor csr_outbound is
      select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
        pxi_common.char_format('355001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '355001' -> Record Type
        pxi_common.char_format(v_promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- company_code -> Company Code
        pxi_common.char_format(v_promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- division_code -> Division Code
        pxi_common.char_format(forecast_customer, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- forecast_customer -> Forecast Customer
        pxi_common.char_format(zrep_matl_code, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- zrep_matl_code -> ZREP product
        pxi_common.date_format(forecast_start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- forecast_start_date -> Forecast Start Date
        pxi_common.date_format(forecast_end_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- forecast_end_date -> Forecast End Date
        pxi_common.numb_format(base_sales_volume, '9999999999', pxi_common.fc_is_not_nullable) -- base_sales_volume -> Base Sales Volume
        ------------------------------------------------------------------------
      from table(allocate_demand_data(rv_dmnd_data.dmnd_grp_code, rv_dmnd_data.bus_sgmnt_code, rv_dmnd_data.zrep, rv_dmnd_data.mars_week,rv_dmnd_data.qty));

  begin
    -- Get the forecast information for the supplied forecast id. 
    v_found := false;
    open csr_forecast;
    fetch csr_forecast into rv_forecast;
    if csr_forecast%found then 
      v_found := true;
    end if;
    close csr_forecast;
    -- Firstly work out what the interface sufix should be based on the moe 
    -- code of the forecast that we are processing.
    if v_found = false then 
      pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unable to find the forecast for the supplied id [' || i_fcst_id || '].');
    else
      v_interface_name := null;
      -- Now determine the interface name to use for this file.
      case rv_forecast.moe_code 
        when pxi_common.gc_moe_nz then 
          v_interface_name := null;  --  v_interface_name := pc_interface_name || '.' || gc_interface_nz;
        when pxi_common.gc_moe_pet then 
          v_interface_name := pc_interface_name || '.' || pxi_common.gc_interface_pet;
        when pxi_common.gc_moe_food then 
          v_interface_name := null;  -- v_interface_name := pc_interface_name || '.' || pxi_common.gc_interface_food;
        when pxi_common.gc_moe_snack then 
          v_interface_name := null;  -- v_interface_name := pc_interface_name || '.' || pxi_common.gc_interface_snack;
        else 
          pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unknown moe code [' || rv_forecast.moe_code || '] for forecast id [' || i_fcst_id || '].');
      end case;
    end if;
    -- Open cursor with the extract data.
    if v_found = true and v_interface_name is not null then 
      v_promax_company := null;
      v_promax_division := null;
      -- Now fetch the actual demand data.
      open csr_dmnd_data;
      loop 
        fetch csr_dmnd_data into rv_dmnd_data;
        exit when csr_dmnd_data%notfound;
        -- Now determine the promax company and division.
        if v_promax_company is null and v_promax_division is null then 
          v_promax_company := rv_dmnd_data.sales_org;
          v_promax_division := rv_dmnd_data.bus_sgmnt_code;
          if v_promax_company = pxi_common.gc_new_zealand then 
            v_promax_division := pxi_common.gc_new_zealand;
          end if;
        end if;
        -- Now lets pass that information into the allocation / output query.
        -- Now fetch the rows of data assocaited with this data allocation.
        open csr_outbound;
        loop
          fetch csr_outbound into v_data;
          exit when csr_outbound%notfound;
          -- Create the new interface when required
          if lics_outbound_loader.is_created = false then
            v_instance := lics_outbound_loader.create_interface(v_interface_name);
          end if;
          -- Append the interface data
          lics_outbound_loader.append_data(v_data);
        end loop;
        close csr_outbound;
      end loop;
      close csr_dmnd_data;
      
      -- Finalise the interface when required
      if lics_outbound_loader.is_created = true then
        lics_outbound_loader.finalise_interface;
      end if;
    end if;
    -- Clear the Mars Weeks Cache.
    ptv_mars_weeks.delete;
  exception
     when others then
       rollback;
       -- Check if there is an interface in progress.       
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       -- Clear the Mars Weeks Cache.
       ptv_mars_weeks.delete;
       -- Reraise the exception.
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end DFNPXI01_EXTRACT;