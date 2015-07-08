create or replace package body pxipmx14_extract as
/*******************************************************************************
  Package Constants
*******************************************************************************/
  -- Package Name
  pc_package_name          constant pxi_common.st_package_name := 'PXIPMX14_EXTRACT';
  pc_outbound_interface    constant pxi_common.st_interface_name := 'PXIPMX14';
  pc_baseline_history_days constant pxi_e2e_demand.st_days := 7*4*20;  -- 20 Periods ways.

/*******************************************************************************
  Package Variables
*******************************************************************************/

/*******************************************************************************
  NAME: PT_MARS_WEEK                                                      PUBLIC
*******************************************************************************/
  function pt_mars_weeks return tt_mars_weeks pipelined is
  begin
    for rv_row in (
      select
        mars_week,
        min(calendar_date)+1 as start_date,
        max(calendar_date)+1 as stop_date
      from mars_date
      group by mars_week
      having mars_week > (select mars_week from mars_date where calendar_date = trunc(sysdate) - (365 * 2)) -- 2 Years Prior Today
      order by mars_week
      )
      loop
        pipe row(rv_row);
      end loop;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_MARS_WEEKS');
  end pt_mars_weeks;

/*******************************************************************************
  NAME:      GET_MOE_CODE                                                PRIVATE
  PURPOSE:   This function will take the demand sequence code and return the
             moe code for it.  If it cannot find the value it will raise
             and exception.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  function get_moe_code(
    i_demand_seq in pxi_e2e_demand.st_sequence) return pxi_common.st_moe_code is
    v_moe_code pxi_common.st_moe_code;
  begin
    select moe_code into v_moe_code from pxi_demand_header where demand_seq = i_demand_seq;
    return v_moe_code;
  exception
    when others then
      pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Could not determine moe code for Demand Sequence [' || i_demand_seq || '].');
  end get_moe_code;

/*******************************************************************************
  NAME:      UPDATE_BASELINE                                              PUBLIC
*******************************************************************************/
  procedure update_baseline(
    i_demand_seq in pxi_e2e_demand.st_sequence) is
    -- Cursor for the demand header.
    cursor csr_header is select * from pxi_demand_header where demand_seq = i_demand_seq;
    rv_header csr_header%rowtype;
    -- Cursor for the moe attributes.
    cursor csr_moe_attributes is select * from pxi_moe_attributes where moe_code = rv_header.moe_code;
    rv_moe_attributes csr_moe_attributes%rowtype;
    -- Cursor for the demand forecast.
    cursor csr_detail is
      select
        zrep_code,
        demand_group,
        mars_week,
        sum(qty) as volume
      from
        pxi_demand_detail
      where
        demand_seq = i_demand_seq and
        type_code in (pxi_e2e_demand.fc_type_1_base, pxi_e2e_demand.fc_type_4_reconcile, pxi_e2e_demand.fc_type_6_override)
      group by
        zrep_code,
        demand_group,
        mars_week
      having
        sum(qty) >= 0;  -- Promax cannot handle any negatives.
    rv_detail csr_detail%rowtype;
    -- Query to use for cap checking.
    cursor csr_baseline is
      select
        *
      from pxi_baseline
      where
        moe_code = rv_header.moe_code
      order by
        account_code,
        zrep_code,
        mars_week;
    -- Variables for updating the baseline tables.
    rv_baseline pxi_baseline%rowtype;
    rv_previous pxi_baseline%rowtype;
    v_modify_date date;
  begin
    -- Initialise the Demand Header.
    rv_header := null;
    rv_moe_attributes := null;
    -- Now fetch the demand header information.
    open csr_header;
    fetch csr_header into rv_header;
    close csr_header;
    if rv_header.moe_code is null then
      pxi_common.raise_promax_error(pc_package_name,'UPDATE_BASELINE','Unable to fetch demand header information for Demand Sequence [' || i_demand_seq || '].');
    end if;
    -- Now fetch the moe attributes
    open csr_moe_attributes;
    fetch csr_moe_attributes into rv_moe_attributes;
    close csr_moe_attributes;
    if rv_header.moe_code is null then
      pxi_common.raise_promax_error(pc_package_name,'UPDATE_BASELINE','Unable to fetch moe attribute information for Moe Code [' || rv_header.moe_code || '].');
    end if;
    -- Delete Old Baseline Information
    delete from pxi_baseline where moe_code = rv_header.moe_code and
    mars_week < (select mars_week from mars_date where calendar_date = trunc(sysdate) - pc_baseline_history_days);
    -- Set the modification date.
    v_modify_date := sysdate;
    -- Perform initial assignments to the baseline table with common values.
    rv_baseline.moe_code := rv_header.moe_code;
    rv_baseline.px_company_code := rv_moe_attributes.px_company_code;
    rv_baseline.px_division_code := rv_moe_attributes.px_division_code;
    rv_baseline.demand_seq := i_demand_seq;
    rv_baseline.has_account_sku := null;
    rv_baseline.has_account := null;
    rv_baseline.has_sku := null;
    rv_baseline.created_date := v_modify_date;
    rv_baseline.modified_date := v_modify_date;
    -- Now take the forecast and apply it to the database.
    open csr_detail;
    loop
      fetch csr_detail into rv_detail;
      exit when csr_detail%notfound = true;
      -- Now process each detail record.
      rv_baseline.zrep_code := rv_detail.zrep_code;
      rv_baseline.demand_group := rv_detail.demand_group;
      rv_baseline.mars_week := rv_detail.mars_week;
      rv_baseline.volume := rv_detail.volume;
      -- Now lookup the account code
      rv_baseline.account_code := pxi_e2e_demand.short_account_code(pxi_e2e_demand.get_account_code(rv_baseline.moe_code,rv_baseline.demand_group));
      -- Now lookup the start and stop dates.
      rv_baseline.start_date := pxi_e2e_demand.get_week_date(rv_baseline.mars_week) + 1;  -- Monday.
      rv_baseline.stop_date := rv_baseline.start_date + 6; -- Sunday.
      -- Now perform an update and if no update then perform an insert if we have an account code.  Otherwise skip record.
      if rv_baseline.account_code is not null then
        update pxi_baseline
        set
          volume = rv_baseline.volume,
          demand_group = rv_baseline.demand_group,
          demand_seq = rv_baseline.demand_seq,
          modified_date = rv_baseline.modified_date
        where
          moe_code = rv_baseline.moe_code and
          account_code = rv_baseline.account_code and
          zrep_code = rv_baseline.zrep_code and
          mars_week = rv_baseline.mars_week;
        if sql%rowcount = 0 then
          insert into pxi_baseline values rv_baseline;
        end if;
      end if;
    end loop;
    close csr_detail;
    -- Now zero any records within the demand forecast range that weren't modified.
    update pxi_baseline set volume = 0, modified_date = v_modify_date, demand_seq = i_demand_seq
    where modified_date <> v_modify_date and
      mars_week between rv_header.min_mars_week and rv_header.max_mars_week and
      moe_code = rv_header.moe_code;
    -- Now insert any capping records that may be required.
    rv_previous := null;
    open csr_baseline;
    loop
      fetch csr_baseline into rv_baseline;
      exit when csr_baseline%notfound = true;
      -- Detect and add Zero Capping Record if Required.
      if (rv_previous.account_code <> rv_baseline.account_code or
          rv_previous.zrep_code <> rv_baseline.zrep_code or
          rv_previous.start_date + 7 <> rv_baseline.start_date) and
          rv_previous.volume <> 0 then
        -- Now Modify the Previous Record to Create the Capping Record.
        rv_previous.volume := 0;
        rv_previous.start_date := rv_previous.start_date + 7;
        rv_previous.stop_date := rv_previous.stop_date + 7;
        rv_previous.mars_week := pxi_e2e_demand.get_mars_week(rv_previous.start_date);
        insert into pxi_baseline values rv_previous;
      end if;
      rv_previous := rv_baseline;
    end loop;
    close csr_baseline;
  exception
    when pxi_common.ge_promax_exception then
      raise;
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'UPDATE_BASELINE');
  end update_baseline;

/*******************************************************************************
  NAME:      VALIDATE_PROMAX_ACCOUNT_SKUS                                 PUBLIC
*******************************************************************************/
  procedure validate_promax_account_skus(
    i_moe_code in pxi_common.st_moe_code) is
    v_system_code pxi_e2e_demand.st_lics_setting;
    -- Cursor to lookup the valid account sku information from promax.
    cursor csr_promax_data is
      select
        moe_code,
        account_code,
        zrep_code,
        mars_week,
        case when account_sku_details_x.as_row_id is null then pxi_e2e_demand.fc_no else pxi_e2e_demand.fc_yes end as has_account_sku,
        case when ac.ac_code is null then pxi_e2e_demand.fc_no else pxi_e2e_demand.fc_yes end as has_account,
        case when sku.sku_stock_code is null then pxi_e2e_demand.fc_no else pxi_e2e_demand.fc_yes end as has_sku
      from
        pxi_baseline t1,
        table(pxi_promax_connect.pt_account_sku_details_x(v_system_code)) account_sku_details_x,
        table(pxi_promax_connect.pt_account(v_system_code)) ac,
        table(pxi_promax_connect.pt_sku(v_system_code)) sku
      where
        t1.moe_code = i_moe_code and
        t1.account_code = account_sku_details_x.ac_code(+) and -- forecast > account_sku_details_x
        t1.zrep_code = account_sku_details_x.sku_stock_code(+) and
        t1.start_date >= account_sku_details_x.asd_start_date(+) and
        t1.stop_date <= account_sku_details_x.asd_stop_date(+) and
        t1.account_code = ac.ac_code(+) and -- forecast > account
        t1.zrep_code = sku.sku_stock_code(+); -- forecast > sku
     rv_promax_data csr_promax_data%rowtype;
  begin
    -- Lookup the system code for us in the queries.
    v_system_code := pxi_e2e_demand.get_system_code(i_moe_code);
    -- Update all the promax flags initially to no.
    open csr_promax_data;
    loop
      fetch csr_promax_data into rv_promax_data;
      exit when csr_promax_data%notfound = true;
      update pxi_baseline
      set
        has_account = rv_promax_data.has_account,
        has_sku = rv_promax_data.has_sku,
        has_account_sku = rv_promax_data.has_account_sku
      where
        moe_code = rv_promax_data.moe_code and
        account_code = rv_promax_data.account_code and
        zrep_code = rv_promax_data.zrep_code and
        mars_week = rv_promax_data.mars_week;
    end loop;
    close csr_promax_data;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'VALIDATE_PROMAX_ACCOUNT_SKUS');
  end validate_promax_account_skus;

/*******************************************************************************
  NAME:      PT_BASELINE                                                  PUBLIC
*******************************************************************************/
  -- Uplift Extract Pipelined Table Function
  function pt_baseline(
    i_moe_code in pxi_common.st_moe_code
    ) return tt_baseline pipelined is
    v_from_mars_week pxi_e2e_demand.st_mars_week;
    cursor csr_baseline is
      select
        *
      from pxi_baseline
      where
        moe_code = i_moe_code and
        has_account_sku = pxi_e2e_demand.fc_yes and
        has_account = pxi_e2e_demand.fc_yes and
        has_sku = pxi_e2e_demand.fc_yes and
        mars_week >= v_from_mars_week
      order by
        account_code,
        zrep_code,
        mars_week;
    rv_baseline csr_baseline%rowtype;
  begin
    -- Find the first week in P13 of the previous year.
    -- Changed P13 to P1. padma 18/03/2015.
    select min(mars_week) into v_from_mars_week from mars_date where mars_year = (
    select mars_year-1 from mars_date where calendar_date = trunc(sysdate)) and period_num = 1;
    -- Iterate over the baseline.
    open csr_baseline;
    loop
      fetch csr_baseline into rv_baseline;
      exit when csr_baseline%notfound = true;
      pipe row (rv_baseline);
    end loop;
    close csr_baseline;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_BASELINE');
  end pt_baseline;

/*******************************************************************************
  NAME:      PT_BASELINE_EXTRACT                                          PUBLIC
*******************************************************************************/
  -- Uplift Extract Pipelined Table Function
  function pt_baseline_extract(
    i_moe_code in pxi_common.st_moe_code
    ) return tt_baseline_extract pipelined is
  begin
    -- Loop around the rows.
    for rv_row in (
      select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
        pxi_common.char_format('Record Type', '355001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '355001' -> Record Type
        pxi_common.char_format('Company Code', px_company_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- sales_org -> Company Code
        pxi_common.char_format('Division Code', px_division_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- division_code -> Division Code
        pxi_common.char_format('Forecast Customer', account_code, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- px_dmnd_plng_node -> Forecast Customer
        pxi_common.char_format('ZREP Product', zrep_code, 18, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- zrep_matl_code -> ZREP Product
        pxi_common.date_format('Forecast Start Date', start_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- start_date -> Forecast Start Date
        pxi_common.date_format('Forecast End Date', stop_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- end_date -> Forecast End Date
        pxi_common.numb_format('Base Sales Volume', volume, '9999999999', pxi_common.fc_is_not_nullable) -- split_qty -> Base Sales Volume
        as extract_data
        -----------------------------------------------------------------------
      from table(pxipmx14_extract.pt_baseline(i_moe_code))
    )
    loop
      pipe row(rv_row);
    end loop;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_BASELINE_EXTRACT');
  end pt_baseline_extract;

/*******************************************************************************
  NAME: PT_ERROR_REPORT                                                   PUBLIC
*******************************************************************************/
  function pt_baseline_error_report (
    i_moe_code in pxi_common.st_moe_code
  ) return tt_baseline_error_report pipelined is
  begin
    for rv_row in (
      select
        sort_seq,
        error_desc,
        account_code,
        demand_group,
        zrep_code,
        zrep_desc,
        start_date,
        end_date,
        record_count,
        volume
      from (
          -- Collect the Missing Accounts in Promax.
          select
            1 as sort_seq,
            'Missing Account in Promax PX' as error_desc,
            account_code,
            demand_group,
            null as zrep_code,
            null as zrep_desc,
            min(start_date) as start_date,
            max(stop_date) as end_date,
            count(*) as record_count,
            sum(volume) as volume
          from
            pxi_baseline
          where
            moe_code = i_moe_code and
            has_account = pxi_e2e_demand.fc_no
          group by
            account_code,
            demand_group
          having max(stop_date) > trunc(sysdate)
          -- Collect the missing SKU in promax.
          union all
          select
            2 as sort_seq,
            'Missing SKU in Promax PX' as error_desc,
            null as account_code,
            null as demand_group,
            zrep_code,
            (select t0.bds_material_desc_en from bds_material_hdr t0 where t0.sap_material_code = pxi_common.full_matl_code(zrep_code)) as zrep_desc,
            min(start_date) as start_date,
            max(stop_date) as end_date,
            count(*) as record_count,
            sum(volume) as volume
          from
            pxi_baseline
          where
            moe_code = i_moe_code and
            has_sku = pxi_e2e_demand.fc_no
          group by
            zrep_code
          having max(stop_date) > trunc(sysdate)
          -- Get the missing account sku range information.
          union all
          select
            3 as sort_seq,
            'Missing Account / SKU (Range) in Promax PX' as error_desc,
            account_code,
            demand_group,
            zrep_code,
            (select t0.bds_material_desc_en from bds_material_hdr t0 where t0.sap_material_code = pxi_common.full_matl_code(zrep_code)) as zrep_desc,
            min(start_date) as start_date,
            max(stop_date) as end_date,
            count(*) as record_count,
            sum(volume) as volume
          from
            pxi_baseline
          where
            moe_code = i_moe_code and
            has_account_sku = pxi_e2e_demand.fc_no
          group by
            account_code,
            demand_group,
            zrep_code
          having max(stop_date) > trunc(sysdate)
        ) error_report
      order by
        error_report.sort_seq,
        error_report.account_code,
        error_report.zrep_code
    )
    loop
      pipe row(rv_row);
    end loop;
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_BASELINE_ERROR_REPORT');
  end pt_baseline_error_report;

/*******************************************************************************
  NAME: EMAIL_ERROR_REPORT                                                PUBLIC
*******************************************************************************/
  procedure email_baseline_error_report (
    i_moe_code in pxi_common.st_moe_code
  ) is
    -- Cursor to select and format the error result.
    cursor csr_baseline_errors is
      select
        trim(replace(error_desc, ',', ' ')) || ',' ||
        trim(replace(account_code, ',', ' ')) || ',' ||
        trim(replace(demand_group, ',', ' ')) || ',' ||
        trim(replace(zrep_code, ',', ' ')) || ',' ||
        trim(replace(zrep_desc, ',', ' ')) || ',' ||
        to_char(start_date, 'YYYY-MM-DD') || ',' ||
        to_char(stop_date, 'YYYY-MM-DD') || ',' ||
        record_count || ',' ||
        volume as output_record
      from table(pxipmx14_extract.pt_baseline_error_report(i_moe_code));
    rv_baseline_error csr_baseline_errors%rowtype;
  begin
    -- Now search for any demand account mappings.
    open csr_baseline_errors;
      loop
        fetch csr_baseline_errors into rv_baseline_error;
        exit when csr_baseline_errors%notfound = true;
        if lics_mailer.is_created = false then
          lics_mailer.create_email(pxi_e2e_demand.gc_email_sender,pxi_e2e_demand.get_config_err_email_group(pxi_e2e_demand.get_system_code(i_moe_code)),'Promax PX End to End Demand Missing Promax Accounts and SKUs Report',null,null);
          lics_mailer.create_part(null);
          lics_mailer.append_data('');
          lics_mailer.append_data('Please see the attached file for the list accounts and skus that need to be configured in Promax System [' || pxi_e2e_demand.get_system_code(i_moe_code) ||'].');
          lics_mailer.append_data('');
          lics_mailer.create_part('Error_Report_' || to_char(sysdate, 'YYYYMMDD') || '.csv');
          lics_mailer.append_data('Error Desc,Account Code,Demand Group,ZREP Code,ZREP Desc,Start Date,Stop Date,Record Count,Volume');
        end if;
       lics_mailer.append_data(rv_baseline_error.output_record);
      end loop;
      close csr_baseline_errors;
      if lics_mailer.is_created = true then
        lics_mailer.finalise_email;
      end if;
   exception
     when others then
       if lics_mailer.is_created = true then
         lics_mailer.append_data('** FATAL ERROR DURING PROCESSING ** : ' || SQLERRM);
         lics_mailer.finalise_email;
       end if;
      pxi_common.reraise_promax_exception(pc_package_name,'EMAIL_BASELINE_ERROR_REPORT');
  end email_baseline_error_report;

/*******************************************************************************
  NAME: EMAIL_ERROR_REPORT                                                PUBLIC
*******************************************************************************/
  procedure email_config_error_report(
    i_demand_seq in pxi_e2e_demand.st_sequence) is
    v_moe_code pxi_common.st_moe_code;
    cursor csr_missing_demand is
      select
          t10.demand_group
        from
          ( select distinct t1.demand_group
            from pxi_demand_detail t1
            where t1.demand_seq = i_demand_seq) t10
        where
          pxi_e2e_demand.get_account_code(v_moe_code,t10.demand_group) is null;
      rv_missing_demand csr_missing_demand%rowtype;
  begin
    -- Now lookup the moe_code for this demand sequence.
    v_moe_code := get_moe_code(i_demand_seq);
    -- Now search for any demand account mappings.
    open csr_missing_demand;
    loop
      fetch csr_missing_demand into rv_missing_demand;
      exit when csr_missing_demand%notfound = true;
      if lics_mailer.is_created = false then
        lics_mailer.create_email(pxi_e2e_demand.gc_email_sender,pxi_e2e_demand.get_config_err_email_group(pxi_e2e_demand.get_system_code(v_moe_code)),'Promax PX End to End Demand Missing Configuration Report',null,null);
        lics_mailer.create_part(null);
        lics_mailer.append_data('');
        lics_mailer.append_data('Please see the below the list of demand group codes that need to be configured');
        lics_mailer.append_data('within the Promax PX Demand Group to Account mapping table for MOE [' || v_moe_code || '].');
        lics_mailer.append_data('');
      end if;
     lics_mailer.append_data(rv_missing_demand.demand_group);
    end loop;
    close csr_missing_demand;
    if lics_mailer.is_created = true then
      lics_mailer.finalise_email;
    end if;
  exception
    when others then
      if lics_mailer.is_created = true then
        lics_mailer.append_data('** FATAL ERROR DURING PROCESSING ** : ' || SQLERRM);
        lics_mailer.finalise_email;
      end if;
      pxi_common.reraise_promax_exception(pc_package_name,'EMAIL_CONFIG_ERROR_REPORT');
  end email_config_error_report;

/*******************************************************************************
  NAME:      CREATE_EXTRACT                                               PUBLIC
*******************************************************************************/
  procedure create_extract(
    i_moe_code in pxi_common.st_moe_code) is
    cursor csr_baseline_extract is
      select * from table (pxipmx14_extract.pt_baseline_extract(i_moe_code));
    rv_baseline_extract csr_baseline_extract%rowtype;
    v_instance pxi_e2e_demand.st_sequence;
    v_suffix pxi_common.st_interface_name;
  begin
    -- Add the data to the extract.
    open csr_baseline_extract;
    loop
      fetch csr_baseline_extract into rv_baseline_extract;
      exit when csr_baseline_extract%notfound;
      if lics_outbound_loader.is_created = false then
        -- Create the interface.
        v_suffix := pxi_e2e_demand.get_suffix_from_moe(i_moe_code);
        v_instance := lics_outbound_loader.create_interface(pc_outbound_interface || '.' || v_suffix);
      end if;
      lics_outbound_loader.append_data(rv_baseline_extract.extract_data);
    end loop;
    close csr_baseline_extract;
    -- Finalise the interface.
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;
  exception
    when pxi_common.ge_promax_exception then
      raise;
    when others then
     if lics_outbound_loader.is_created = true then
        lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
        lics_outbound_loader.finalise_interface;
     end if;
     pxi_common.reraise_promax_exception(pc_package_name,'CREATE_EXTRACT');
  end create_extract;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(
    i_demand_seq in pxi_e2e_demand.st_sequence) is
    v_moe_code pxi_common.st_moe_code;
  begin
    -- Now fetch the moe code
    v_moe_code := get_moe_code(i_demand_seq);
    --  Update the baseline table.
    update_baseline(i_demand_seq);
    -- Validate Promax Account and Sku Information.
    validate_promax_account_skus(v_moe_code);
    -- Now commit the changes made to this point.
    commit;
    -- Create an extract to Promax.
    create_extract(v_moe_code);
    -- Create a configuration email report that
    email_config_error_report(i_demand_seq);
    -- Create a baseline email report
    email_baseline_error_report(v_moe_code);
  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
  end execute;

end pxipmx14_extract;