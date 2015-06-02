
set define off;

create or replace package ods_app.qu3_qu3cdw34 as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System   : qu3
    Owner    : ods_app
    Package  : qu3_qu3cdw34
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    Loader Package, Interface [qu3cdw34] Entity [ActivityHeader] Table [qu3_act_hdr][_load/_hist]

    Package provides the standard LICS on_start, on_data, on_end callbacks,
    plus a process_batch callback which moves records from _load to _hist table
    on completion of batch

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2014-05-27  Mal Chambeyron        Use column name (30 char) instead of attribute name
                                      for lics_inbound_utility.set_csv_definition
                                      to avoid 32 char lics restriction
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Procedures
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  procedure process_batch(p_batch_id in number);

end qu3_qu3cdw34;
/

create or replace package body ods_app.qu3_qu3cdw34 as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Procedures
  procedure perform_preprocessing;
  procedure process_header_row(p_row in varchar2);
  procedure process_data_row(p_row in varchar2);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu3_qu3cdw34';
  g_entity_name constant varchar2(64 char) := 'ActivityHeader';
  g_delimiter constant varchar2(1)  := ',';
  g_text_qualifier constant varchar2(1) := '"';

  -- Private : Flags
  g_abort_processing_flag boolean;
  g_source_file_error_flag boolean;

  g_first_row_flag boolean;
  g_valid_header_row_found_flag boolean;
  g_footer_row_found_flag boolean;

  -- Private : Counters
  g_row_count number(10);
  g_data_row_count number(10);

  -- Private : Variables
  g_load_seq number;
  g_interface_name varchar2(32 char);
  g_prefixed_file_name varchar2(512 char);
  g_original_file_name varchar2(512 char);
  g_batch_id number(15);
  g_timestamp date;

  /*****************************************************************************
  ** Procedure : On Start - Call Back for LICS Framework
  **             Called by the LICS Framework BEFORE Processing the Record Set
  *****************************************************************************/
  procedure on_start is

  begin
    -- Initialise : Transaction flags
    g_abort_processing_flag := false;
    g_source_file_error_flag := false;

    g_first_row_flag := true;
    g_valid_header_row_found_flag := false;
    g_footer_row_found_flag := false;

    -- Initialise : Counters
    g_row_count := 0;
    g_data_row_count := 0;

    -- Initialise : Layout definitions
    lics_inbound_utility.clear_definition;
    lics_inbound_utility.set_csv_definition('id',1);
    lics_inbound_utility.set_csv_definition('task_id',2);
    lics_inbound_utility.set_csv_definition('rep_id',3);
    lics_inbound_utility.set_csv_definition('start_date',4);
    lics_inbound_utility.set_csv_definition('is_complete',5);
    lics_inbound_utility.set_csv_definition('end_date',6);
    lics_inbound_utility.set_csv_definition('callcard_id',7);
    lics_inbound_utility.set_csv_definition('incomplete_reason_id',8);
    lics_inbound_utility.set_csv_definition('incomplete_reason_id_desc',9);
    lics_inbound_utility.set_csv_definition('note',10);
    lics_inbound_utility.set_csv_definition('due_date',11);
    lics_inbound_utility.set_csv_definition('full_name',12);
    lics_inbound_utility.set_csv_definition('task_id_desc',13);
    lics_inbound_utility.set_csv_definition('no_incr_display',14);
    lics_inbound_utility.set_csv_definition('incr_duration',15);
    lics_inbound_utility.set_csv_definition('coop_spent',16);
    lics_inbound_utility.set_csv_definition('sell_in_note',17);
    lics_inbound_utility.set_csv_definition('min_coverage_express',18);
    lics_inbound_utility.set_csv_definition('min_coverage_std',19);
    lics_inbound_utility.set_csv_definition('planogram_ad_here_',20);
    lics_inbound_utility.set_csv_definition('min_gm_sku_aisle',21);
    lics_inbound_utility.set_csv_definition('min_confec_aisle',22);
    lics_inbound_utility.set_csv_definition('gm_off_loc_old',23);
    lics_inbound_utility.set_csv_definition('confec_old',24);
    lics_inbound_utility.set_csv_definition('payment_status_compliant',25);
    lics_inbound_utility.set_csv_definition('titanium_created_date',26);
    lics_inbound_utility.set_csv_definition('contact_name',27);
    lics_inbound_utility.set_csv_definition('titanium_status',28);
    lics_inbound_utility.set_csv_definition('admin_meeting',29);
    lics_inbound_utility.set_csv_definition('leave_public_holiday',30);
    lics_inbound_utility.set_csv_definition('sick_leave',31);
    lics_inbound_utility.set_csv_definition('travel',32);
    lics_inbound_utility.set_csv_definition('time_in_shed',33);
    lics_inbound_utility.set_csv_definition('it_down_time',34);
    lics_inbound_utility.set_csv_definition('over_logged_time',35);
    lics_inbound_utility.set_csv_definition('agree_reclaim_a_locs',36);
    lics_inbound_utility.set_csv_definition('entry_nestle_stands_a_loc',37);
    lics_inbound_utility.set_csv_definition('entry_nestle_standsin_store',38);
    lics_inbound_utility.set_csv_definition('no_a_locs_reclaimed',39);
    lics_inbound_utility.set_csv_definition('no_nestle_stands_prev_wwy',40);
    lics_inbound_utility.set_csv_definition('nonewalocations_wwy',41);
    lics_inbound_utility.set_csv_definition('nestle_moved_wwy_stand',42);
    lics_inbound_utility.set_csv_definition('retailer_signed_premium_offer',43);
    lics_inbound_utility.set_csv_definition('comments',44);

  end on_start;

  /*****************************************************************************
  ** Procedure : On Data - Call Back for LICS Framework
  **             Called by the LICS Framework FOR EACH Record of the Record Set
  *****************************************************************************/
  procedure on_data(p_row in varchar2) is

    l_row varchar2(4000 char);

  begin
    -- Return if Abort Processing Flag set / Stops Unnecessary Processing
    if g_abort_processing_flag = true then
      return;
    end if ;

    -- Remove leading and trailing whitespace (including cr/lf/tab/etc..)
    l_row := trim(regexp_replace(p_row,'[[:space:]]*$',null));
    if l_row is null then
      return; -- Return on EMPTY Line
    end if;

    -- Process CSV ..
    -- HEADER Row
    if g_first_row_flag = true then
      g_first_row_flag := false;
      perform_preprocessing; -- Raises Exception on Failure
      process_header_row(l_row);
    else
      -- FOOTER row .. Starts with FTR followed by any APLHA, NUMERIC, [_] and [.] .. Note, NO Comma [,]
      if regexp_instr(l_row,'^FTR[A-Z0-9._]*$',1,1,0,'i') = 1 then -- Simple Check to Distinguish from DATA row
        g_footer_row_found_flag := true;
        if upper(l_row) != upper('FTR'||g_original_file_name) then -- Invalid FOOTER row / More Specific Check
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] Invalid Footer Row .. Expected [FTR'||g_original_file_name||']');
          g_source_file_error_flag := true;
          return; -- Invalid Footer
        end if;
      -- DATA row
      else
        if g_footer_row_found_flag then -- cannot have DATA row after FOOTER row
          lics_inbound_utility.add_exception('['||g_package_name||'.on_data] DATA Row Found After FOOTER Row');
          g_source_file_error_flag := true;
        end if;
        process_data_row(l_row);
      end if;
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_data] : '||SQLERRM, 1, 4000));

  end on_data;

  /*****************************************************************************
  ** Procedure : Perform Preprocessing
  *****************************************************************************/
  procedure perform_preprocessing as

  begin
    -- Set Interface and Source File Names ..
    g_prefixed_file_name := lics_inbound_processor.callback_file_name;
    g_original_file_name := substr(g_prefixed_file_name, 5); -- remove prefix 'qu#_'
    g_interface_name := upper(lics_inbound_processor.callback_interface); -- delibrate upper

    -- Each of the remaining Procedures / Functions Raise Exception on Failure

    -- Valid Interface Name
    qu3_util.validate_interface_name(g_entity_name, g_interface_name);

    -- Valid File Name
    qu3_util.validate_file_name(g_entity_name, g_original_file_name);

    -- File Name, Extract .. Timestamp, Batch Id
    g_timestamp := qu3_util.get_file_timestamp(g_original_file_name);
    g_batch_id := qu3_util.get_file_batch_id(g_original_file_name);

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.perform_preprocessing] : '||SQLERRM, 1, 4000));

  end perform_preprocessing;

  /*****************************************************************************
  ** Procedure : On End - Call Back for LICS Framework
  **             Called by the LICS Framework AFTER Processing the Record Set
  *****************************************************************************/
  procedure on_end is

  begin

    -- Commit/Rollback as necessary ..
    if g_abort_processing_flag = false and g_source_file_error_flag = false and g_valid_header_row_found_flag = true and g_footer_row_found_flag = true then
      qu3_interface.complete_load(g_load_seq, g_batch_id, g_entity_name, g_data_row_count);
      commit;
    else
      rollback;
      if g_valid_header_row_found_flag = true and g_footer_row_found_flag = false then
        raise_application_error(-20000, 'FOOTER NOT FOUND .. Expected [FTR'||g_original_file_name||']');
      end if;
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.on_end] : '||SQLERRM, 1, 4000));

  end on_end;

  /*****************************************************************************
  ** Procedure : Process HEADER Row
  *****************************************************************************/
  procedure process_header_row(p_row in varchar2) is

    l_expected_row varchar2(4000 char) := 'ID,Task_ID,Rep_ID,StartDate,IsComplete,EndDate,Callcard_ID,IncompleteReasonID,IncompleteReasonID_Description,Notes,DueDate,FullName,Task_ID_Description,NumIncrDisplay,IncrDuration,CoopSpent,SellInNote,MinCoverageExpress,MinCoverageStd,PlanogramAdhered,MinGMSKUAisle,MinConfecAisle,GMOffLocationOLD,ConfecOLD,PmtStsCompliant,TitaniumCreatedDate,ContactName,TitaniumStatus,AdminMeeting,LeavePublicHoliday,SickLeave,Travel,TimeInShed,ITDownTime,OverLoggedTime,AgreeReclaimALocations,EntryNestleStandsALocation,EntryNestleStandsInStore,NoALocationsReclaimed,NoNestleStandsPrevWrigley,NoNewALocationsWrigley,NestleMovedWrigleyStand,RetailerSignedPremiumOffer,Comments';

  begin

    if upper(p_row) = upper(l_expected_row) then -- Valid HEADER Row
      g_valid_header_row_found_flag := true;
      -- Start Interface Loader .. Raised Exception on Failure
      g_load_seq := qu3_interface.start_load(g_batch_id, g_entity_name, g_interface_name, g_original_file_name, g_timestamp);
    else
      lics_inbound_utility.add_exception('['||g_package_name||'.process_header_row] Invalid Header Row .. Expected ['||l_expected_row||']');
      g_abort_processing_flag := true;
      g_source_file_error_flag := true;
    end if;

  exception
    when others then
      g_abort_processing_flag := true;
      raise_application_error(-20000, substr('['||g_package_name||'.process_header_row] : '||SQLERRM, 1, 4000));

  end process_header_row;

  /*****************************************************************************
  ** Procedure : Process DATA Row
  *****************************************************************************/
  procedure process_data_row(p_row in varchar2) is

    l_entity_load_row ods.qu3_act_hdr_load%rowtype;
    l_raw_column_value varchar2(4000 char);

  begin
    -- Should NEVER reach this point .. Return if Abort Processing Flag set / Stops Unnecessary Processing
    if g_abort_processing_flag = true then
      return;
    end if ;

    -- Increment data row count
    g_data_row_count := g_data_row_count + 1;

    -- Parse DATA Row
    lics_inbound_utility.parse_csv_record(p_row, g_delimiter, g_text_qualifier);

    -- Populate DATA Row - CONTROL Columns
    l_entity_load_row.q4x_load_seq := g_load_seq;
    l_entity_load_row.q4x_load_data_seq := g_data_row_count;
    l_entity_load_row.q4x_create_user := user;
    l_entity_load_row.q4x_create_time := sysdate;
    l_entity_load_row.q4x_modify_user := user;
    l_entity_load_row.q4x_modify_time := sysdate;
    l_entity_load_row.q4x_batch_id := g_batch_id;
    l_entity_load_row.q4x_timestamp := g_timestamp; -- Interface File Timestamp used as Default Transaction Timestamp, as Quofore Advised that Create Date was not Reliable
    -- Populate DATA Row - DATA Columns
    begin
      l_entity_load_row.id := qu3_util.get_number('id',10,0,false,g_source_file_error_flag);
      l_entity_load_row.task_id := qu3_util.get_number('task_id',10,0,true,g_source_file_error_flag);
      l_entity_load_row.rep_id := qu3_util.get_number('rep_id',10,0,true,g_source_file_error_flag);
      l_entity_load_row.start_date := qu3_util.get_datetime('start_date',true,g_source_file_error_flag);
      l_entity_load_row.is_complete := qu3_util.get_boolean_as_number('is_complete',true,g_source_file_error_flag);
      l_entity_load_row.end_date := qu3_util.get_datetime('end_date',true,g_source_file_error_flag);
      l_entity_load_row.callcard_id := qu3_util.get_number('callcard_id',10,0,true,g_source_file_error_flag);
      l_entity_load_row.incomplete_reason_id := qu3_util.get_number('incomplete_reason_id',10,0,true,g_source_file_error_flag);
      l_entity_load_row.incomplete_reason_id_desc := qu3_util.get_string('incomplete_reason_id_desc',50,true,g_source_file_error_flag);
      l_entity_load_row.note := qu3_util.get_string('note',200,true,g_source_file_error_flag);
      l_entity_load_row.due_date := qu3_util.get_datetime('due_date',true,g_source_file_error_flag);
      l_entity_load_row.full_name := qu3_util.get_string('full_name',101,true,g_source_file_error_flag);
      l_entity_load_row.task_id_desc := qu3_util.get_string('task_id_desc',200,true,g_source_file_error_flag);
      l_entity_load_row.no_incr_display := qu3_util.get_number('no_incr_display',10,0,true,g_source_file_error_flag);
      l_entity_load_row.incr_duration := qu3_util.get_number('incr_duration',10,0,true,g_source_file_error_flag);
      l_entity_load_row.coop_spent := qu3_util.get_number('coop_spent',18,4,true,g_source_file_error_flag);
      l_entity_load_row.sell_in_note := qu3_util.get_string('sell_in_note',50,true,g_source_file_error_flag);
      l_entity_load_row.min_coverage_express := qu3_util.get_number('min_coverage_express',10,0,true,g_source_file_error_flag);
      l_entity_load_row.min_coverage_std := qu3_util.get_number('min_coverage_std',10,0,true,g_source_file_error_flag);
      l_entity_load_row.planogram_ad_here_ := qu3_util.get_number('planogram_ad_here_',10,0,true,g_source_file_error_flag);
      l_entity_load_row.min_gm_sku_aisle := qu3_util.get_number('min_gm_sku_aisle',10,0,true,g_source_file_error_flag);
      l_entity_load_row.min_confec_aisle := qu3_util.get_number('min_confec_aisle',10,0,true,g_source_file_error_flag);
      l_entity_load_row.gm_off_loc_old := qu3_util.get_number('gm_off_loc_old',10,0,true,g_source_file_error_flag);
      l_entity_load_row.confec_old := qu3_util.get_number('confec_old',10,0,true,g_source_file_error_flag);
      l_entity_load_row.payment_status_compliant := qu3_util.get_number('payment_status_compliant',10,0,true,g_source_file_error_flag);
      l_entity_load_row.titanium_created_date := qu3_util.get_datetime('titanium_created_date',true,g_source_file_error_flag);
      l_entity_load_row.contact_name := qu3_util.get_string('contact_name',101,true,g_source_file_error_flag);
      l_entity_load_row.titanium_status := qu3_util.get_number('titanium_status',10,0,true,g_source_file_error_flag);
      l_entity_load_row.admin_meeting := qu3_util.get_string('admin_meeting',50,true,g_source_file_error_flag);
      l_entity_load_row.leave_public_holiday := qu3_util.get_string('leave_public_holiday',50,true,g_source_file_error_flag);
      l_entity_load_row.sick_leave := qu3_util.get_string('sick_leave',50,true,g_source_file_error_flag);
      l_entity_load_row.travel := qu3_util.get_string('travel',50,true,g_source_file_error_flag);
      l_entity_load_row.time_in_shed := qu3_util.get_number('time_in_shed',10,0,true,g_source_file_error_flag);
      l_entity_load_row.it_down_time := qu3_util.get_number('it_down_time',10,0,true,g_source_file_error_flag);
      l_entity_load_row.over_logged_time := qu3_util.get_number('over_logged_time',10,0,true,g_source_file_error_flag);
      l_entity_load_row.agree_reclaim_a_locs := qu3_util.get_number('agree_reclaim_a_locs',10,0,true,g_source_file_error_flag);
      l_entity_load_row.entry_nestle_stands_a_loc := qu3_util.get_number('entry_nestle_stands_a_loc',10,0,true,g_source_file_error_flag);
      l_entity_load_row.entry_nestle_standsin_store := qu3_util.get_number('entry_nestle_standsin_store',10,0,true,g_source_file_error_flag);
      l_entity_load_row.no_a_locs_reclaimed := qu3_util.get_number('no_a_locs_reclaimed',10,0,true,g_source_file_error_flag);
      l_entity_load_row.no_nestle_stands_prev_wwy := qu3_util.get_number('no_nestle_stands_prev_wwy',10,0,true,g_source_file_error_flag);
      l_entity_load_row.nonewalocations_wwy := qu3_util.get_number('nonewalocations_wwy',10,0,true,g_source_file_error_flag);
      l_entity_load_row.nestle_moved_wwy_stand := qu3_util.get_number('nestle_moved_wwy_stand',10,0,true,g_source_file_error_flag);
      l_entity_load_row.retailer_signed_premium_offer := qu3_util.get_number('retailer_signed_premium_offer',10,0,true,g_source_file_error_flag);
      l_entity_load_row.comments := qu3_util.get_string('comments',100,true,g_source_file_error_flag);
      exception
      when others then
         lics_inbound_utility.add_exception(substr('['||g_package_name||'.process_data_row] Unexpected Parsing Error : '||SQLERRM, 1, 4000));
         g_source_file_error_flag := true;
    end;

    -- Retrieve exceptions raised
    if lics_inbound_utility.has_errors = true then
       g_source_file_error_flag := true;
    end if;

    -- Error, bypass insert once an error is found
    if g_source_file_error_flag = true then
       return;
    end if;

    -- Insert row
    begin
      insert into ods.qu3_act_hdr_load values l_entity_load_row;
    exception
      when others then
         lics_inbound_utility.add_exception(substr('['||g_package_name||'.process_data_row] Insert Failed [ods.qu3_act_hdr_load] : '||SQLERRM, 1, 4000));
         g_source_file_error_flag := true;
    end;

  end process_data_row;

  /*****************************************************************************
  ** Procedure : Process Batch .. Called from Batch / Digest Process
  **             DO NOT COMMIT/ROLLBACK .. This is Performed by Calling Function
  *****************************************************************************/
  procedure process_batch(p_batch_id in number) is

    l_batch_row_count number;

  begin

    -- Check if Anything to Process
    select count(1) into l_batch_row_count
    from ods.qu3_act_hdr_load
    where q4x_batch_id = p_batch_id;

    -- Return is Nothing to Process
    if l_batch_row_count = 0 then
      return;
    end if;

    -- Update Modified User/Time
    update ods.qu3_act_hdr_load
    set q4x_modify_user = user,
      q4x_modify_time = sysdate
    where q4x_batch_id = p_batch_id;

    -- Insert ALL of Load Batch into History
    insert into ods.qu3_act_hdr_hist
    select *
    from ods.qu3_act_hdr_load
    where q4x_batch_id = p_batch_id;

    -- Delete Load Batch
    delete from ods.qu3_act_hdr_load
    where q4x_batch_id = p_batch_id;

  exception
    when others then
      g_abort_processing_flag := true;
      raise_application_error(-20000, substr('['||g_package_name||'.process_batch] Failed [ods.qu3_act_hdr/_load/_hist] : '||SQLERRM, 1, 4000));

  end process_batch;

end qu3_qu3cdw34;
/

-- Synonyms
create or replace public synonym qu3_qu3cdw34 for ods_app.qu3_qu3cdw34;

-- Grants
grant execute on ods_app.qu3_qu3cdw34 to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
