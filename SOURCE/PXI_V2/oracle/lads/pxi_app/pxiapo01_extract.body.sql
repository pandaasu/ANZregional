create or replace package body pxiapo01_extract as
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- Package Name
  pc_package_name       constant pxi_common.st_package_name := 'PXIAPO01_EXTRACT';
  pc_outbound_interface constant pxi_common.st_interface_name := 'PXIAPO01';
  
/*******************************************************************************
  NAME:      PT_UPLIFT_DETAIL                                             PUBLIC
*******************************************************************************/
  function pt_uplift_detail(
    i_demand_seq in pxi_e2e_demand.st_sequence,
    i_estimate_seq in pxi_e2e_demand.st_sequence,
    i_uplift_seq in pxi_e2e_demand.st_sequence
    ) return tt_uplift_detail pipelined is
    rv_row pxi_uplift_detail%rowtype;
    v_min_mars_week pxi_e2e_demand.st_mars_week;
    v_moe_code pxi_common.st_moe_code;
    -- Curosr with the estimate data that needs to be checked and sent.
    cursor csr_estimate_and_demand is 
      select 
        t10.demand_group, 
        t10.zrep_code, 
        t10.mars_week,
        sum(t10.estimate_qty) as estimate_qty,
        ( select sum(qty) 
          from pxi_demand_detail t0
          where 
            t0.demand_seq = i_demand_seq and 
            t0.demand_group = t10.demand_group and
            t0.zrep_code = t10.zrep_code and
            t0.mars_week = t10.mars_week and 
            t0.type_code in (pxi_e2e_demand.fc_type_1_base, pxi_e2e_demand.fc_type_4_reconcile, pxi_e2e_demand.fc_type_6_override)
        ) as demand_qty
      from 
        ( select 
            pxi_e2e_demand.get_demand_group(v_moe_code,t1.account_code) as demand_group,
            t1.stock_code as zrep_code,
            t1.mars_week,
            t1.est_estimated_volume as estimate_qty
          from
            pxi_estimate_detail t1
          where 
            t1.estimate_seq = i_estimate_seq and 
            t1.mars_week >= v_min_mars_week) t10
      group by 
        t10.demand_group,
        t10.zrep_code, 
        t10.mars_week;
    rv_estimate_and_demand csr_estimate_and_demand%rowtype;
    
    -- Now perform lookups to find the demand and uplift header information.
    procedure lookup_demand_uplift_headers is 
    begin
      select min_mars_week into v_min_mars_week from pxi_demand_header where demand_seq = i_demand_seq;
      select moe_code into v_moe_code from pxi_uplift_header where uplift_seq = i_uplift_seq;
    exception 
     when others then
       pxi_common.reraise_promax_exception(pc_package_name,'LOOKUP_DEMAND_UPLIFT_HEADERS');
    end lookup_demand_uplift_headers;
    
  begin
    -- Find the minimum mars week for the linked demand file and the moe code.
    lookup_demand_uplift_headers;
    
    -- Setup the Row Constants.
    rv_row.uplift_seq := i_uplift_seq;
    rv_row.row_seq := 0;
    rv_row.duration := 7*24*60; -- Minutes per week.
    rv_row.type_code := pxi_e2e_demand.gc_type_7_market; 
    rv_row.forecast_id := 'PROMAXPX';
    
    -- Increase the row Sequence.
    open csr_estimate_and_demand;
    loop
      fetch csr_estimate_and_demand into rv_estimate_and_demand;
      exit when csr_estimate_and_demand%notfound = true;
      rv_row.row_seq := rv_row.row_seq + 1; 
      -- Now perform the assignments
      rv_row.demand_group := rv_estimate_and_demand.demand_group;
      rv_row.demand_unit := rv_estimate_and_demand.zrep_code || '_' || v_moe_code;
      rv_row.mars_week := rv_estimate_and_demand.mars_week;
      rv_row.start_date := pxi_e2e_demand.get_week_date(rv_estimate_and_demand.mars_week);
      -- Now perform the various lookups.
      if rv_row.demand_group is not null then 
        -- Now subtract the current demand base quantities
        rv_row.qty := rv_estimate_and_demand.estimate_qty - nvl(rv_estimate_and_demand.demand_qty,0);
        -- Now pipe the row to the output.
        if rv_row.qty <> 0 then 
          pipe row (rv_row);
        end if;
      end if;
    end loop;
    close csr_estimate_and_demand;
   exception
     when others then
       pxi_common.reraise_promax_exception(pc_package_name,'PT_UPLIFT_DETAIL');
  end pt_uplift_detail;

/*******************************************************************************
  NAME:      PT_UPLIFT_EXTRACT                                            PUBLIC
*******************************************************************************/
  -- Uplift Extract Pipelined Table Function 
  function pt_uplift_extract(
    i_uplift_seq in pxi_e2e_demand.st_sequence
    ) return tt_uplift_extract pipelined is
    -- Cursor to create the output record.
    cursor csr_uplift_extract is 
      select 
        '"' || t2.demand_unit || '",'  || -- Demand Unit
        '"' || substr(t2.demand_group, 1, instr(t2.demand_group, '_') - 1) || '",' || -- Demand Group
        '"' || t1.location_code || '",' || -- Location Code
        '"' || to_char(start_date, 'yyyymmdd hh24:mi:ss') || '",' || -- Start Date
        t2.duration || ',' || -- Duration
        t2.type_code || ',' ||  -- Type Code - Market Activity 
        '"' || t2.forecast_id || '",' || -- Forecast ID
        trim(to_char(qty, '999999990.000000')) || ',' || -- Quantity
        '"' || t1.moe_code || '",' || -- Moe Code
        '"PROMAXPX",' || -- Source 
        '"' || to_char(sysdate, 'yyyymmdd hh24:mi:ss') || '"' -- Extract Timestamp
        as extract_data 
      from 
        pxi_uplift_header t1,
        pxi_uplift_detail t2
      where
        t1.uplift_seq = i_uplift_seq and 
        t2.uplift_seq = t1.uplift_seq;
    rv_row rt_uplift_extract;
  begin
    open csr_uplift_extract;
    loop
      fetch csr_uplift_extract into rv_row;
      exit when csr_uplift_extract%notfound = true;
      pipe row (rv_row);
    end loop;
    close csr_uplift_extract;
   exception
     when others then
       pxi_common.reraise_promax_exception(pc_package_name,'PT_UPLIFT_EXTRACT');
  end pt_uplift_extract;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(
    i_estimate_seq in pxi_e2e_demand.st_sequence) is
    v_instance pxi_e2e_demand.st_sequence;
    v_suffix pxi_common.st_interface_name;
    -- Create the header record.
    rv_header pxi_uplift_header%rowtype;
    
    -- Creates a new uplift header record after checking for estimate and demand files.
    procedure create_uplift_header is
      -- Cursor to get the estimate header.
      cursor csr_estimate_header is 
        select * from pxi_estimate_header 
        where estimate_seq = i_estimate_seq;
      rv_estimate_header csr_estimate_header%rowtype;
      -- Cursor to get the demand header.
      cursor csr_demand_header is
        select * from pxi_demand_header
        where moe_code = rv_header.moe_code and 
        demand_seq = (select max(demand_seq) from pxi_demand_header where moe_code = rv_header.moe_code);
      rv_demand_header csr_demand_header%rowtype;
    begin
      -- Now fetch the estimate header file and perform checks.
      open csr_estimate_header;
      fetch csr_estimate_header into rv_estimate_header;
      if csr_estimate_header%found = true then
        rv_header.estimate_seq := rv_estimate_header.estimate_seq;
        rv_header.moe_code := rv_estimate_header.moe_code;
      end if;
      close csr_estimate_header;
      -- Now check that the estimate header was allocated.
      if rv_header.moe_code is null then 
        pxi_common.raise_promax_error(pc_package_name,'CREATE_UPLIFT_HEADER','Unable to determine Moe from estimate sequence [' || i_estimate_seq || '].');
      end if;
      -- Now check we could find the latest demand file for the comparison.
      open csr_demand_header;
      fetch csr_demand_header into rv_demand_header;
      if csr_demand_header%found = true then 
        rv_header.demand_seq := rv_demand_header.demand_seq;
      end if;
      close csr_demand_header;
      -- Now update the location code.
      rv_header.location_code := pxi_e2e_demand.get_location_code(rv_header.moe_code);
      -- Now check that the demand header was allocated.
      if rv_header.demand_seq is null then 
        pxi_common.raise_promax_error(pc_package_name,'CREATE_UPLIFT_HEADER','Could not find a demand file for comparision. For estimate sequence [' || i_estimate_seq || '] and MOE [' || rv_header.moe_code || '.');
      end if;
      -- If this interface was running via inbound processor, get the interface user.
      rv_header.modify_user := fflu_utils.get_interface_user;
      rv_header.modify_date := sysdate;
      -- Now create the actual uplift header record.
      select pxi_uplift_seq.nextval into rv_header.uplift_seq from dual;
      insert into pxi_uplift_header values rv_header;
    exception
      when pxi_common.ge_promax_exception then 
        raise;
      when others then 
       pxi_common.reraise_promax_exception(pc_package_name,'CREATE_UPLIFT_HEADER');
    end create_uplift_header;
    
    -- Creates the uplift data and insert it into the uplift detail table.
    procedure create_uplift_detail is
    begin
      -- Now generate the data and insert it into the uplift detail table.
      insert into pxi_uplift_detail 
        select * from table(
          pxiapo01_extract.pt_uplift_detail(
            rv_header.demand_seq,
            rv_header.estimate_seq,
            rv_header.uplift_seq));
    exception
      when others then 
       -- Re Raise the exception.
       pxi_common.reraise_promax_exception(pc_package_name,'CREATE_UPLIFT_DETAIL');
    end create_uplift_detail;
    
    -- Updates the uplift header with the latest modified date time at the end of the extract generation.
    procedure update_uplift_header is
    begin
      update pxi_uplift_header set modify_date = sysdate where uplift_seq = rv_header.uplift_seq;
    exception
      when others then 
       -- Re Raise the exception.
       pxi_common.reraise_promax_exception(pc_package_name,'UPDATE_UPLIFT_HEADER');
    end update_uplift_header;
    
    -- Now create the actual extract.
    procedure create_uplift_extract is 
      cursor csr_uplift_extract is 
        select extract_data from table (pxiapo01_extract.pt_uplift_extract(rv_header.uplift_seq));
      rv_output csr_uplift_extract%rowtype;
    begin
      v_suffix := pxi_e2e_demand.get_suffix_from_moe(rv_header.moe_code);
      v_instance := lics_outbound_loader.create_interface(pc_outbound_interface || '.' || v_suffix);
      open csr_uplift_extract;
      loop
        fetch csr_uplift_extract into rv_output;
        exit when csr_uplift_extract%notfound;
        lics_outbound_loader.append_data(rv_output.extract_data);
      end loop;
      close csr_uplift_extract;
      lics_outbound_loader.finalise_interface;
    exception
      when others then 
       if lics_outbound_loader.is_created = true then
          lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
          lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'CREATE_EXTRACT');
    end create_uplift_extract;
    
    -- This creates and email if there are any missing account codes within the estimate file.
    procedure email_config_error_report is
      cursor csr_missing_accounts is
        select 
          t10.account_code
        from
          ( select distinct t1.account_code 
            from pxi_estimate_detail t1 
            where t1.estimate_seq = rv_header.estimate_seq) t10
        where
          pxi_e2e_demand.get_demand_group(rv_header.moe_code,t10.account_code) is null;
      rv_missing_account csr_missing_accounts%rowtype;
    begin
      -- Now search for any missing accounts.
      open csr_missing_accounts;
      loop
        fetch csr_missing_accounts into rv_missing_account;
        exit when csr_missing_accounts%notfound = true;
        if lics_mailer.is_created = false then 
          lics_mailer.create_email(pxi_e2e_demand.gc_email_sender,pxi_e2e_demand.get_config_err_email_group(pxi_e2e_demand.get_system_code(rv_header.moe_code)),'Promax PX End to End Demand Missing Configuration Report',null,null);
          lics_mailer.create_part(null);
          lics_mailer.append_data('');
          lics_mailer.append_data('Please see the below the list of account codes that need to be configured');
          lics_mailer.append_data('within the Promax PX Demand Group to Account mapping table for MOE [' || rv_header.moe_code || '].');
          lics_mailer.append_data('');
        end if;
       lics_mailer.append_data(rv_missing_account.account_code);
      end loop;
      close csr_missing_accounts;
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
    
  begin
    -- Createe a new uplift header and allocate sequence.
    create_uplift_header;
    -- Create the actual extract data to be sent to Apollo
    create_uplift_detail;
    -- Update the header.
    update_uplift_header;
    -- Commit the changes to this E2E Database at this point.
    commit;
    -- Now create the extract file.
    create_uplift_extract;
    -- Email Missing Account Code Configuration
    email_config_error_report;
   exception
     when others then
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
  end execute;

end pxiapo01_extract;
/