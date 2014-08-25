create or replace package body dfnapo01_extract as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name   constant common.st_package_name := 'DFNAPO01_EXTRACT';
  pc_interface_name constant common.st_oracle_name := 'DFNAPO01';

/*******************************************************************************
  NAME:  FORECAST_MOE                                                     PUBLIC
*******************************************************************************/
   function forecast_moe(
    i_fcst_id in common.st_id
   ) return common.st_code is
   v_moe_code pxi_common.st_moe_code;
   begin
    -- Get moe code for the supplied forecast id
    v_moe_code := null;
    begin
      select moe_code into v_moe_code from fcst where fcst_id = i_fcst_id;
    exception
      when no_data_found then
        null; -- Ignore
    end;
    return v_moe_code;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'FORECAST_MOE');
  end forecast_moe;

/*******************************************************************************
  NAME:  FIRST_DATE_MARS_WEEK                                             PUBLIC
*******************************************************************************/
   function first_date_mars_week(
    i_mars_week in common.st_count
   ) return date is
   v_date date;
   begin
    -- Get first date of casting week for forecast provided
    begin
      select min(calendar_date) into v_date
      from mars_date
      where mars_week = i_mars_week;
    exception
      when no_data_found then
        null; -- Ignore
    end;
    return v_date;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'FIRST_DATE_MARS_WEEK');
  end first_date_mars_week;

/*******************************************************************************
  NAME: GET_FORECAST                                                      PUBLIC
*******************************************************************************/
  function get_forecast (
    i_fcst_id in common.st_id
  ) return tt_forecast pipelined is
  begin
    -- Fetch each row of the defined query back out as a pipelined table function.
    for rv_row in (
      select
        t10.fcst_id,
        t10.moe_code,
        t10.dmnd_grp_code,
        t10.mars_week,
        -- Output Fields
        t10.tdu_matl_code,
        ( select 
            t0.plant_code 
          from 
            plng_srce_plant_xref t0
          where 
            t0.plng_srce_code = 
              ( select 
                  t00.plng_srce_code 
                from 
                  matl_fg_clssfctn t00 
                where 
                  t00.matl_code = reference_functions.full_matl_code(t10.tdu_matl_code)
              )
        ) as plant_code,
        first_date_mars_week(t10.mars_week) as start_date,
        t10.qty
      from
        (select
          t1.fcst_id,
          t1.moe_code,
          t4.dmnd_grp_code,
          t2.mars_week,
          -- Output Fields
          t2.tdu as tdu_matl_code,
          sum(t2.qty_in_base_uom) as qty
        from
          fcst t1,
          dmnd_data t2,
          dmnd_grp_org t3,
          dmnd_grp t4
        where 
          -- Base Joines
          t1.fcst_id = t2.fcst_id 
          and t2.dmnd_grp_org_id = t3.dmnd_grp_org_id
          and t3.dmnd_grp_id = t4.dmnd_grp_id 
          -- Filter Predicates
          and t1.fcst_id = i_fcst_id -- Limit to fcst_id
          and t3.acct_assign_id in (
            select acct_assign_id
            from dmnd_acct_assign
            where acct_assign_code = demand_forecast.gc_acct_assgnmnt_domestic
          )
        group by
          t1.fcst_id,
          t1.moe_code,
          t4.dmnd_grp_code,
          t2.mars_week,
          t2.tdu
      ) t10
    )
    loop
      pipe row(rv_row);
    end loop;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'GET_FORECAST');
  end get_forecast;

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
    i_fcst_id in common.st_id
   ) is
    v_moe_code pxi_common.st_moe_code;
    v_interface_name_with_suffix pxi_common.st_interface_name;
    v_instance number(15,0);
    v_promax_rows_loaded number(20,0);
    v_forecast_count number(1,0);
  begin
    -- Start Logging ..
    lics_logging.start_log('DF to Apolllo Supply','DF_TO_APOLLO_SUPPLY_'||i_fcst_id);
    -- Check for Forecast
    select count(1) into v_forecast_count
    from df.fcst
    where fcst_id = i_fcst_id
    and forecast_type in ('FCST');
    if v_forecast_count = 0 then
      lics_logging.write_log('NOTHING TO DO : Forecast ['||i_fcst_id||'] Either NOT FOUND : Forecast Type [FCST].');
      lics_logging.end_log;
      return;
    end if;
    
    -- Do NOTHING for MOE's Other than Petcare [0196], for Execute
    v_moe_code := forecast_moe(i_fcst_id); -- assign so we don't need to lookup twice
    if v_moe_code != pxi_common.fc_moe_pet then
      lics_logging.write_log('NOTHING TO DO : Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'] : Processing Limited to MOE ['||pxi_common.fc_moe_pet||'].');
      lics_logging.end_log;
      return;
    end if;

    -- Check If Forecase Already has Promax PX Estimates Loaded
    select count(1) into v_promax_rows_loaded
    from df.dmnd_data
    where fcst_id = i_fcst_id
    and type in ('B','U','P');
    -- No Need to Continue If Forecast Already has Promax PX Estimates Loaded
    if v_promax_rows_loaded = 0 then
      lics_logging.write_log('NOTHING TO DO : Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'] : Does not yet have any Promax PX Estimates Loaded, Types [B|U|P].');
      lics_logging.end_log;
      return;
    end if;

    -- request lock (on interface)
    lics_logging.write_log('INFO : Request Interface Lock ['||pc_interface_name||'] for Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'].');
    begin
      lics_locking.request(pc_interface_name);
    exception
      when others then
        lics_logging.write_log('ERROR : Unable to Obtain Interface Lock ['||pc_interface_name||'] for Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'].');
        lics_logging.end_log;
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE',substr('Unable to obtain interface lock ['||pc_interface_name||'] - '||sqlerrm, 1, 4000));
    end;

    -- Now determine the interface name to use for this file.
    v_interface_name_with_suffix := null;
    case v_moe_code
      when pxi_common.fc_moe_nz then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_nz;
      when pxi_common.fc_moe_pet then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_pet;
      when pxi_common.fc_moe_food then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_food;
      when pxi_common.fc_moe_snack then
        v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.fc_interface_snack;
      else
        lics_logging.write_log('ERROR : Unknown MOE [' || v_moe_code || '] for Forecast [' || i_fcst_id || '].');
        lics_logging.end_log;
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Unknown MOE [' || v_moe_code || '] for Forecast [' || i_fcst_id || '].');
    end case;

    -- Now commence extracting the data.
    lics_logging.write_log('INFO : Now extracting forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'].');

    for rv_row in (
      select
        tdu_matl_code || ',' ||
        plant_code || ',' ||
        ',' ||
        to_char(start_date,'DD/MM/YYYY') || ',' ||
        '7D' || ',' ||
        qty as output_record
      from table(dfnapo01_extract.get_forecast(i_fcst_id))
      order by
        tdu_matl_code,
        mars_week
    )
    loop
      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        lics_logging.write_log('INFO : Create Outbound Interface ['||v_interface_name_with_suffix||'] for Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'].');
        v_instance := lics_outbound_loader.create_interface(v_interface_name_with_suffix);
      end if;
      -- Now put this record onto the forecast extract.
      lics_outbound_loader.append_data(rv_row.output_record);
    end loop;

    -- Finalise interface when required
    if lics_outbound_loader.is_created = true then
      lics_logging.write_log('INFO : Finalise Outbound Interface ['||v_interface_name_with_suffix||'] for Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'].');
      lics_outbound_loader.finalise_interface;
    end if;

    -- Commit changes to product history extract table
    lics_logging.write_log('INFO : Extract completed for Forecast ['||i_fcst_id||'] MOE ['||v_moe_code||'].');
    commit;

    -- End Logging
    lics_logging.end_log;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       lics_logging.end_log;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end dfnapo01_extract; 