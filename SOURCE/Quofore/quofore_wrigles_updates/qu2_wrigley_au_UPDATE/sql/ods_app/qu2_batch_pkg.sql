
set define off;

create or replace package ods_app.qu2_batch as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu2
    Owner   : ods_app
    Package : qu2_batch
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    Interface Batch Processing Package

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-03-05  Mal Chambeyron        Add Check Batches
    2013-09-11  Mal Chambeyron        Updated with Lastest Entity List
    2013-09-24  Tom Docherty          Added Process Batch Log Entries
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-03-18  Mal Chambeyron        Update LICS Logging ..to include Setting Group
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Type

  type qu2_unprocessed_batches_rec is record (
    batch_id  number(10,0),
    expected_file_name varchar2(512 char),
    expected_row_count number(10,0),
    loaded_row_count number(10,0),
    load_status varchar2(16 char)
  );

  type qu2_unprocessed_batches_type is table of qu2_unprocessed_batches_rec;

  -- Public : Functions
  procedure process_batches;
  procedure process_batch(p_batch_id in number);
  procedure force_batches;
  procedure check_batches;
  function view_unprocessed_batches return qu2_unprocessed_batches_type pipelined;

end qu2_batch;
/

create or replace package body ods_app.qu2_batch as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu2_batch';

  /*****************************************************************************
  ** PUBLIC Procedure : Process (Eligible) Batches .. Must be run from LICS_APP
  *****************************************************************************/
  procedure process_batches as

    l_log_header_text varchar2(4000 char);
    l_log_search_text varchar2(4000 char);

    l_lock_text varchar2(10);
    l_locked boolean;
    l_batch_processed boolean;

  begin

    -- start logging
    l_log_header_text := 'Quofore Process (Eligible) Batches';
    l_log_search_text := qu2_constants.setting_group||'_PROCESS_BATCH';
    lics_logging.start_log(l_log_header_text,l_log_search_text);

    -- request lock (on search text)
    l_locked := false;
    begin
      lics_locking.request(l_log_search_text);
      l_locked := true;
    exception
      when others then
        lics_logging.write_log(substr('Failed requesting lock ['||l_log_search_text||'] : '||SQLERRM, 1, 4000));
    end;

    -- if received lock
    if l_locked then

      -- Process (Eligible) Batches
      l_batch_processed := false;
      for batch in (
        select batch_id
        from (
          select a.q4x_batch_id batch_id,
            decode(b.row_count,nvl(c.q4x_row_count,-1),'PASS',decode(a.q4x_row_count,0,'PASS','FAIL')) load_status -- digest equals loaded, or digest is empty
          from qu2_interface_hdr a,
            qu2_digest_load b,
            qu2_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status = qu2_constants.status_loaded
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and qu2_constants.status_loaded = c.q4x_status(+)
        )
        group by batch_id
        having min(load_status) = 'PASS'
        order by batch_id
      ) loop

        l_batch_processed := true;
        lics_logging.write_log('Process Batch ['||batch.batch_id||']');
        process_batch(batch.batch_id);

      end loop;

      -- release lock
      lics_locking.release(l_log_search_text);

      -- log nothing to do
      if not l_batch_processed then
        lics_logging.write_log('No Eligible Batches to Process');
      end if;

    else
      -- log already locked
      lics_logging.write_log('Lock already held on ['||l_log_search_text||']');
    end if;

    -- end logging
    lics_logging.end_log;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.process_batches] : '||SQLERRM, 1, 4000));

  end process_batches;

  /*****************************************************************************
  ** PUBLIC Procedure : Process Batch
  *****************************************************************************/
  procedure process_batch(p_batch_id in number) as

    l_err_msg varchar2(4000 char);
    l_outbound_instance number(15);

  begin

    lics_logging.write_log('Process Digest'); qu2_qu2cdw00.process_batch(p_batch_id); -- Digest
    lics_logging.write_log('Process Hierarchy'); qu2_qu2cdw01.process_batch(p_batch_id); -- Hierarchy
    lics_logging.write_log('Process GeneralList'); qu2_qu2cdw02.process_batch(p_batch_id); -- GeneralList
    lics_logging.write_log('Process Role'); qu2_qu2cdw03.process_batch(p_batch_id); -- Role
    lics_logging.write_log('Process Position'); qu2_qu2cdw04.process_batch(p_batch_id); -- Position
    lics_logging.write_log('Process Rep'); qu2_qu2cdw05.process_batch(p_batch_id); -- Rep
    lics_logging.write_log('Process RepAddress'); qu2_qu2cdw06.process_batch(p_batch_id); -- RepAddress
    lics_logging.write_log('Process Product'); qu2_qu2cdw07.process_batch(p_batch_id); -- Product
    lics_logging.write_log('Process ProductBarcode'); qu2_qu2cdw08.process_batch(p_batch_id); -- ProductBarcode
    lics_logging.write_log('Process Customer'); qu2_qu2cdw09.process_batch(p_batch_id); -- Customer
    lics_logging.write_log('Process CustomerAddress'); qu2_qu2cdw10.process_batch(p_batch_id); -- CustomerAddress
    lics_logging.write_log('Process CustomerNote'); qu2_qu2cdw11.process_batch(p_batch_id); -- CustomerNote
    lics_logging.write_log('Process CustomerContact'); qu2_qu2cdw12.process_batch(p_batch_id); -- CustomerContact
    lics_logging.write_log('Process CustomerVisitorDay'); qu2_qu2cdw13.process_batch(p_batch_id); -- CustomerVisitorDay
    lics_logging.write_log('Process AssortmentDetail'); qu2_qu2cdw14.process_batch(p_batch_id); -- AssortmentDetail
    lics_logging.write_log('Process CustomerAssortmentDetail'); qu2_qu2cdw15.process_batch(p_batch_id); -- CustomerAssortmentDetail
    lics_logging.write_log('Process ProductAssortmentDetail'); qu2_qu2cdw16.process_batch(p_batch_id); -- ProductAssortmentDetail
    lics_logging.write_log('Process AuthorisedListProduct'); qu2_qu2cdw17.process_batch(p_batch_id); -- AuthorisedListProduct
    lics_logging.write_log('Process Appointment'); qu2_qu2cdw18.process_batch(p_batch_id); -- Appointment
    lics_logging.write_log('Process CallCard'); qu2_qu2cdw19.process_batch(p_batch_id); -- CallCard
    lics_logging.write_log('Process CallcardNote'); qu2_qu2cdw20.process_batch(p_batch_id); -- CallcardNote
    lics_logging.write_log('Process OrderHeader'); qu2_qu2cdw21.process_batch(p_batch_id); -- OrderHeader
    lics_logging.write_log('Process OrderDetail'); qu2_qu2cdw22.process_batch(p_batch_id); -- OrderDetail
    lics_logging.write_log('Process Territory'); qu2_qu2cdw23.process_batch(p_batch_id); -- Territory
    lics_logging.write_log('Process CustomerTerritory'); qu2_qu2cdw24.process_batch(p_batch_id); -- CustomerTerritory
    lics_logging.write_log('Process PositionTerritory'); qu2_qu2cdw25.process_batch(p_batch_id); -- PositionTerritory
    lics_logging.write_log('Process Survey'); qu2_qu2cdw26.process_batch(p_batch_id); -- Survey
    lics_logging.write_log('Process SurveyQuestion'); qu2_qu2cdw27.process_batch(p_batch_id); -- SurveyQuestion
    lics_logging.write_log('Process ResponseOption'); qu2_qu2cdw28.process_batch(p_batch_id); -- ResponseOption
    lics_logging.write_log('Process Task'); qu2_qu2cdw29.process_batch(p_batch_id); -- Task
    lics_logging.write_log('Process TaskAssignment'); qu2_qu2cdw30.process_batch(p_batch_id); -- TaskAssignment
    lics_logging.write_log('Process TaskCustomer'); qu2_qu2cdw31.process_batch(p_batch_id); -- TaskCustomer
    lics_logging.write_log('Process TaskProduct'); qu2_qu2cdw32.process_batch(p_batch_id); -- TaskProduct
    lics_logging.write_log('Process TaskSurvey'); qu2_qu2cdw33.process_batch(p_batch_id); -- TaskSurvey
    lics_logging.write_log('Process ActivityHeader'); qu2_qu2cdw34.process_batch(p_batch_id); -- ActivityHeader
    lics_logging.write_log('Process ActivityDetail_ALoc'); qu2_qu2cdw35.process_batch(p_batch_id); -- ActivityDetail_ALoc
    lics_logging.write_log('Process ActivityDetail_Sell_In'); qu2_qu2cdw38.process_batch(p_batch_id); -- ActivityDetail_Sell_In
    lics_logging.write_log('Process ActivityDetail_OffLocation'); qu2_qu2cdw39.process_batch(p_batch_id); -- ActivityDetail_OffLocation
    lics_logging.write_log('Process ActivityDetail_Facing'); qu2_qu2cdw40.process_batch(p_batch_id); -- ActivityDetail_Facing
    lics_logging.write_log('Process ActivityDetail_Checkout_Std'); qu2_qu2cdw41.process_batch(p_batch_id); -- ActivityDetail_Checkout_Std
    lics_logging.write_log('Process ActivityDetail_Checkout_ExpressQZ'); qu2_qu2cdw42.process_batch(p_batch_id); -- ActivityDetail_Checkout_ExpressQZ
    lics_logging.write_log('Process ActivityDetail_Checkout_Express'); qu2_qu2cdw43.process_batch(p_batch_id); -- ActivityDetail_Checkout_Express
    lics_logging.write_log('Process ActivityDetail_Checkout_SelfscanQZ'); qu2_qu2cdw44.process_batch(p_batch_id); -- ActivityDetail_Checkout_SelfscanQZ
    lics_logging.write_log('Process ActivityDetail_Checkout_Selfscan'); qu2_qu2cdw45.process_batch(p_batch_id); -- ActivityDetail_Checkout_Selfscan
    lics_logging.write_log('Process ActivityDetail_LocOOS'); qu2_qu2cdw46.process_batch(p_batch_id); -- ActivityDetail_LocOOS
    lics_logging.write_log('Process ActivityDetail_PermDisplay'); qu2_qu2cdw47.process_batch(p_batch_id); -- ActivityDetail_PermDisplay
    lics_logging.write_log('Process SurveyAnswer'); qu2_qu2cdw48.process_batch(p_batch_id); -- SurveyAnswer
    lics_logging.write_log('Process Graveyard'); qu2_qu2cdw49.process_batch(p_batch_id); -- Graveyard
    lics_logging.write_log('Process ActivityDetail_FacingAisle'); qu2_qu2cdw50.process_batch(p_batch_id); -- ActivityDetail_FacingAisle
    lics_logging.write_log('Process ActivityDetail_FacingExpress'); qu2_qu2cdw51.process_batch(p_batch_id); -- ActivityDetail_FacingExpress
    lics_logging.write_log('Process ActivityDetail_FacingSelfScan'); qu2_qu2cdw52.process_batch(p_batch_id); -- ActivityDetail_FacingSelfScan
    lics_logging.write_log('Process ActivityDetail_FacingStandard'); qu2_qu2cdw53.process_batch(p_batch_id); -- ActivityDetail_FacingStandard
    lics_logging.write_log('Process ActivityDetail_CompetitionAct'); qu2_qu2cdw54.process_batch(p_batch_id); -- ActivityDetail_CompetitionAct
    lics_logging.write_log('Process ActivityDetail_CompetitionFacings'); qu2_qu2cdw55.process_batch(p_batch_id); -- ActivityDetail_CompetitionFacings
    lics_logging.write_log('Process ActivityDetail_ExecCompliance'); qu2_qu2cdw56.process_batch(p_batch_id); -- ActivityDetail_ExecCompliance


    -- Update Interface Header
    qu2_interface.complete_batch(p_batch_id);

    -- Commit Processed Batch
    commit;

    -- Send Flag File ..
    begin
       l_outbound_instance := lics_outbound_loader.create_interface('CDWQVW01',null,'Quofore_Source_2.txt');
       lics_outbound_loader.append_data('{ "source": 2, "batch": '||p_batch_id||', "status": "ready" }'); -- Message Body JSON Encoded
       lics_outbound_loader.finalise_interface;
    exception
       when others then
          l_err_msg := substr('['||g_package_name||'.process_batch] Send Flag File [CDWQVW01] : '||SQLERRM, 1, 4000);
          lics_logging.write_log(l_err_msg);
          if lics_outbound_loader.is_created = true then
             lics_outbound_loader.add_exception(l_err_msg);
             lics_outbound_loader.finalise_interface;
          end if;
    end;

  exception
    when others then
      rollback;
      raise_application_error(-20000, substr('['||g_package_name||'.process_batch] : '||SQLERRM, 1, 4000));

  end process_batch;

  /*****************************************************************************
  ** PUBLIC Procedure : Process (*FORCE*) Batches - for TESTING ONLY .. Must be run from LICS_APP
  *****************************************************************************/
  procedure force_batches as

    l_log_header_text varchar2(4000 char);
    l_log_search_text varchar2(4000 char);

    l_lock_text varchar2(10);
    l_locked boolean;
    l_batch_processed boolean;

  begin

    -- start logging
    l_log_header_text := 'Quofore Process (*FORCE*) Batches';
    l_log_search_text := qu2_constants.setting_group||'_PROCESS_BATCH';
    lics_logging.start_log(l_log_header_text,l_log_search_text);

    -- request lock (on search text)
    l_locked := false;
    begin
      lics_locking.request(l_log_search_text);
      l_locked := true;
    exception
      when others then
        lics_logging.write_log(substr('Failed requesting lock ['||l_log_search_text||'] : '||SQLERRM, 1, 4000));
    end;

    -- if received lock
    if l_locked then

      -- FORCE Process Loaded Batches
      l_batch_processed := false;
      for batch in (
        select distinct q4x_batch_id batch_id
        from qu2_interface_hdr
        where q4x_status = qu2_constants.status_loaded
        order by q4x_batch_id
      ) loop

        l_batch_processed := true;
        lics_logging.write_log('Process Batch ['||batch.batch_id||']');
        process_batch(batch.batch_id);

      end loop;

      -- release lock
      lics_locking.release(l_log_search_text);

      -- log nothing to do
      if not l_batch_processed then
        lics_logging.write_log('No Eligible Batches to Process');
      end if;

    else
      -- log already locked
      lics_logging.write_log('Lock already held on ['||l_log_search_text||']');
    end if;

    -- end logging
    lics_logging.end_log;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.process_batches] : '||SQLERRM, 1, 4000));

  end force_batches;

  /*****************************************************************************
  ** PUBLIC Procedure : Check Batches .. Mail on Error
  *****************************************************************************/
  procedure check_batches as

    l_log_header_text varchar2(4000 char);
    l_log_search_text varchar2(4000 char);

    l_lock_text varchar2(10);
    l_locked boolean;
    l_batch_errors boolean;
    l_message varchar2(4000 char);
    l_line varchar2(4000 char);
    l_body varchar2(4000 char);

  begin

    -- start logging
    l_log_header_text := 'Quofore Check Batches';
    l_log_search_text := qu2_constants.setting_group||'_CHECK_BATCH';
    lics_logging.start_log(l_log_header_text,l_log_search_text);

    -- request lock (on search text)
    l_locked := false;
    begin
      lics_locking.request(l_log_search_text);
      l_locked := true;
    exception
      when others then
        lics_logging.write_log(substr('Failed requesting lock ['||l_log_search_text||'] : '||SQLERRM, 1, 4000));
    end;

    -- if received lock
    if l_locked then

      -- Check Batches ..
      l_batch_errors := false;
      l_message := null;
      for batch in (

        select 'Last Batch Processed > 24 Hours' message,
          q4x_batch_id batch_id,
          q4x_create_time create_time
        from qu2_interface_hdr
        where q4x_status = qu2_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_create_time < sysdate-1
        and q4x_batch_id in (
          select max(q4x_batch_id) q4x_batch_id
          from qu2_interface_hdr
          where q4x_status = qu2_constants.status_processed
          and q4x_entity_name = 'DIGEST'
        )

        union all

        select 'Last Batch Processed was Empty - This is Possible on Weekends/Public Holidays' message,
          q4x_batch_id batch_id,
          q4x_create_time create_time
        from qu2_interface_hdr
        where q4x_status = qu2_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_row_count = 0
        and trim(to_char(sysdate,'Day')) not in ('Sunday','Monday') -- Ignore Empty Batches Over Weekend, Sun / Mon Mornings
        and q4x_batch_id in (
          select max(q4x_batch_id) q4x_batch_id
          from qu2_interface_hdr
          where q4x_status = qu2_constants.status_processed
          and q4x_entity_name = 'DIGEST'
          and q4x_create_time > sysdate-1
        )

        union all

        select 'Unprocessed Batch' message,
          q4x_batch_id batch_id,
          max(q4x_create_time) create_time
        from qu2_interface_hdr
        where q4x_status != qu2_constants.status_processed
        group by q4x_batch_id

        order by 1,2,3

      ) loop

        l_batch_errors := true;

        l_message := null;
        l_line := qu2_constants.app_instance_name;
        l_body := l_body||l_line||chr(10)||chr(13);
        lics_logging.write_log(l_line);

        if batch.message != nvl(l_message,'*NULL') then
          l_message := batch.message;
          l_line := '--> Message : '||batch.message;
          l_body := l_body||l_line||chr(10)||chr(13);
          lics_logging.write_log(l_line);
        end if;

        if batch.batch_id > 0 then
          l_line := '----> Batch : ['||batch.batch_id||'] '||to_char(batch.create_time,'YYYY-MM-DD HH24:MI:SS');
          l_body := l_body||l_line||chr(10)||chr(13);
          lics_logging.write_log(l_line);
        end if;

      end loop;

      if l_batch_errors then

        lics_logging.write_log('Errors Found .. Sending E-Mail ['||qu2_util.get_email_default||']');

        lics_mailer.send_short_email('Quofore_'||qu2_constants.setting_group||'_'||lics_parameter.system_environment||'_'||lics_parameter.system_code||'_'||lics_parameter.system_unit||'@'||lics_parameter.log_database, -- sender
          qu2_util.get_email_default, -- recipient
          'DAILY BATCH CHECK *ERROR* : Quofore '||qu2_constants.setting_group||' '||lics_parameter.system_environment||' '||lics_parameter.system_code||' '||lics_parameter.system_unit, -- subject
           l_body, -- body
           lics_parameter.email_smtp_host, -- smtp host
           lics_parameter.email_smtp_port); --  smtp port

      else
        lics_logging.write_log('No Errors Found');
      end if;

      -- release lock
      lics_locking.release(l_log_search_text);

    else
      -- log already locked
      lics_logging.write_log('Lock already held on ['||l_log_search_text||']');
    end if;

    -- end logging
    lics_logging.end_log;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.check_batches] : '||SQLERRM, 1, 4000));

  end check_batches;

  /*****************************************************************************
  ** Function : View Unprocessed Batches
  *****************************************************************************/
  function view_unprocessed_batches return qu2_unprocessed_batches_type pipelined is

  begin

    for l_entity in (

          select a.q4x_batch_id batch_id,
            nvl(b.file_name,a.q4x_file_name) expected_file_name,
            b.row_count expected_row_count,
            c.q4x_row_count loaded_row_count,
            decode(b.row_count,nvl(c.q4x_row_count,-1),'PASS',decode(a.q4x_row_count,0,'PASS','FAIL')) load_status -- digest equals loaded, or digest is empty
          from qu2_interface_hdr a,
            qu2_digest_load b,
            qu2_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status != qu2_constants.status_processed
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and qu2_constants.status_processed != c.q4x_status(+)
          order by 1,2,3

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_unprocessed_batches] : '||SQLERRM, 1, 4000));

  end view_unprocessed_batches;

end qu2_batch;
/

-- Synonyms
create or replace public synonym qu2_batch for ods_app.qu2_batch;

-- Grants
grant execute on ods_app.qu2_batch to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
