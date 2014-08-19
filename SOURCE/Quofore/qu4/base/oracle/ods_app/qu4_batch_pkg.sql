
set define off;

create or replace package ods_app.qu4_batch as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu4
    Owner   : ods_app
    Package : qu4_batch
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    Interface Batch Processing Package

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-03-05  Mal Chambeyron        Add Check Batches
    2013-09-11  Mal Chambeyron        Updated with Lastest Entity List
    2013-09-24  Tom Docherty          Added Process Batch Log Entries
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Type

  type qu4_unprocessed_batches_rec is record (
    batch_id  number(10,0),
    expected_file_name varchar2(512 char),
    expected_row_count number(10,0),
    loaded_row_count number(10,0),
    load_status varchar2(16 char)
  );

  type qu4_unprocessed_batches_type is table of qu4_unprocessed_batches_rec;

  -- Public : Functions
  procedure process_batches;
  procedure process_batch(p_batch_id in number);
  procedure force_batches;
  procedure check_batches;
  function view_unprocessed_batches return qu4_unprocessed_batches_type pipelined;

end qu4_batch;
/

create or replace package body ods_app.qu4_batch as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu4_batch';

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
    l_log_search_text := 'QU4_PROCESS_BATCH';
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
          from qu4_interface_hdr a,
            qu4_digest_load b,
            qu4_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status = qu4_constants.status_loaded
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and qu4_constants.status_loaded = c.q4x_status(+)
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

    lics_logging.write_log('Process Digest'); qu4_qu4cdw00.process_batch(p_batch_id); -- Digest
    lics_logging.write_log('Process Hierarchy'); qu4_qu4cdw01.process_batch(p_batch_id); -- Hierarchy
    lics_logging.write_log('Process GeneralList'); qu4_qu4cdw02.process_batch(p_batch_id); -- GeneralList
    lics_logging.write_log('Process Role'); qu4_qu4cdw03.process_batch(p_batch_id); -- Role
    lics_logging.write_log('Process Position'); qu4_qu4cdw04.process_batch(p_batch_id); -- Position
    lics_logging.write_log('Process Rep'); qu4_qu4cdw05.process_batch(p_batch_id); -- Rep
    lics_logging.write_log('Process RepAddress'); qu4_qu4cdw06.process_batch(p_batch_id); -- RepAddress
    lics_logging.write_log('Process Product'); qu4_qu4cdw07.process_batch(p_batch_id); -- Product
    lics_logging.write_log('Process ProductBarcode'); qu4_qu4cdw08.process_batch(p_batch_id); -- ProductBarcode
    lics_logging.write_log('Process Customer'); qu4_qu4cdw09.process_batch(p_batch_id); -- Customer
    lics_logging.write_log('Process CustomerAddress'); qu4_qu4cdw10.process_batch(p_batch_id); -- CustomerAddress
    lics_logging.write_log('Process CustomerNote'); qu4_qu4cdw11.process_batch(p_batch_id); -- CustomerNote
    lics_logging.write_log('Process CustomerContact'); qu4_qu4cdw12.process_batch(p_batch_id); -- CustomerContact
    lics_logging.write_log('Process CustomerVisitorDay'); qu4_qu4cdw13.process_batch(p_batch_id); -- CustomerVisitorDay
    lics_logging.write_log('Process AssortmentDetail'); qu4_qu4cdw14.process_batch(p_batch_id); -- AssortmentDetail
    lics_logging.write_log('Process CustomerAssortmentDetail'); qu4_qu4cdw15.process_batch(p_batch_id); -- CustomerAssortmentDetail
    lics_logging.write_log('Process ProductAssortmentDetail'); qu4_qu4cdw16.process_batch(p_batch_id); -- ProductAssortmentDetail
    lics_logging.write_log('Process AuthorisedListProduct'); qu4_qu4cdw17.process_batch(p_batch_id); -- AuthorisedListProduct
    lics_logging.write_log('Process Appointment'); qu4_qu4cdw18.process_batch(p_batch_id); -- Appointment
    lics_logging.write_log('Process CallCard'); qu4_qu4cdw19.process_batch(p_batch_id); -- CallCard
    lics_logging.write_log('Process CallcardNote'); qu4_qu4cdw20.process_batch(p_batch_id); -- CallcardNote
    lics_logging.write_log('Process OrderHeader'); qu4_qu4cdw21.process_batch(p_batch_id); -- OrderHeader
    lics_logging.write_log('Process OrderDetail'); qu4_qu4cdw22.process_batch(p_batch_id); -- OrderDetail
    lics_logging.write_log('Process Territory'); qu4_qu4cdw23.process_batch(p_batch_id); -- Territory
    lics_logging.write_log('Process CustomerTerritory'); qu4_qu4cdw24.process_batch(p_batch_id); -- CustomerTerritory
    lics_logging.write_log('Process PositionTerritory'); qu4_qu4cdw25.process_batch(p_batch_id); -- PositionTerritory
    lics_logging.write_log('Process Survey'); qu4_qu4cdw26.process_batch(p_batch_id); -- Survey
    lics_logging.write_log('Process SurveyQuestion'); qu4_qu4cdw27.process_batch(p_batch_id); -- SurveyQuestion
    lics_logging.write_log('Process ResponseOption'); qu4_qu4cdw28.process_batch(p_batch_id); -- ResponseOption
    lics_logging.write_log('Process Task'); qu4_qu4cdw29.process_batch(p_batch_id); -- Task
    lics_logging.write_log('Process TaskAssignment'); qu4_qu4cdw30.process_batch(p_batch_id); -- TaskAssignment
    lics_logging.write_log('Process TaskCustomer'); qu4_qu4cdw31.process_batch(p_batch_id); -- TaskCustomer
    lics_logging.write_log('Process TaskProduct'); qu4_qu4cdw32.process_batch(p_batch_id); -- TaskProduct
    lics_logging.write_log('Process TaskSurvey'); qu4_qu4cdw33.process_batch(p_batch_id); -- TaskSurvey
    lics_logging.write_log('Process ActivityHeader'); qu4_qu4cdw34.process_batch(p_batch_id); -- ActivityHeader
    lics_logging.write_log('Process ActivityDetail_Distribution'); qu4_qu4cdw35.process_batch(p_batch_id); -- ActivityDetail_Distribution
    lics_logging.write_log('Process ActivityDetail_Permanency'); qu4_qu4cdw36.process_batch(p_batch_id); -- ActivityDetail_Permanency
    lics_logging.write_log('Process ActivityDetail_DisplayTradeStd'); qu4_qu4cdw37.process_batch(p_batch_id); -- ActivityDetail_DisplayTradeStd
    lics_logging.write_log('Process SurveyAnswer'); qu4_qu4cdw38.process_batch(p_batch_id); -- SurveyAnswer
    lics_logging.write_log('Process Graveyard'); qu4_qu4cdw39.process_batch(p_batch_id); -- Graveyard
    lics_logging.write_log('Process ActivityDetail_Planogram'); qu4_qu4cdw40.process_batch(p_batch_id); -- ActivityDetail_Planogram


    -- Update Interface Header
    qu4_interface.complete_batch(p_batch_id);

    -- Commit Processed Batch
    commit;

    -- Send Flag File ..
    begin
       l_outbound_instance := lics_outbound_loader.create_interface('CDWQVW01',null,'Quofore_Source_'||qu4_constants.source_id||'.txt');
       lics_outbound_loader.append_data('{ "source": '||qu4_constants.source_id||', "batch": '||p_batch_id||', "status": "ready" }'); -- Message Body JSON Encoded
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
    l_log_search_text := 'QU4_PROCESS_BATCH';
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
        from qu4_interface_hdr
        where q4x_status = qu4_constants.status_loaded
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
    l_log_search_text := 'QU4_CHECK_BATCH';
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
        from qu4_interface_hdr
        where q4x_status = qu4_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_create_time < sysdate-1
        and q4x_batch_id in (
          select max(q4x_batch_id) q4x_batch_id
          from qu4_interface_hdr
          where q4x_status = qu4_constants.status_processed
          and q4x_entity_name = 'DIGEST'
        )

        union all

        select 'Last Batch Processed was Empty - This is Possible on Weekends/Public Holidays' message,
          q4x_batch_id batch_id,
          q4x_create_time create_time
        from qu4_interface_hdr
        where q4x_status = qu4_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_row_count = 0
        and trim(to_char(sysdate,'Day')) not in ('Sunday','Monday') -- Ignore Empty Batches Over Weekend, Sun / Mon Mornings
        and q4x_batch_id in (
          select max(q4x_batch_id) q4x_batch_id
          from qu4_interface_hdr
          where q4x_status = qu4_constants.status_processed
          and q4x_entity_name = 'DIGEST'
          and q4x_create_time > sysdate-1
        )

        union all

        select 'Unprocessed Batch' message,
          q4x_batch_id batch_id,
          max(q4x_create_time) create_time
        from qu4_interface_hdr
        where q4x_status != qu4_constants.status_processed
        group by q4x_batch_id

        order by 1,2,3

      ) loop

        l_batch_errors := true;

        l_message := null;
        l_line := qu4_util.get_source_desc(qu4_constants.source_id);
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

        lics_logging.write_log('Errors Found .. Sending E-Mail ['||qu4_util.get_email_default||']');

        lics_mailer.send_short_email('Quofore_'||lics_parameter.system_environment||'_'||lics_parameter.system_code||'_'||lics_parameter.system_unit||'@'||lics_parameter.log_database, -- sender
          qu4_util.get_email_default, -- recipient
          'DAILY BATCH CHECK *ERROR* : Quofore '||lics_parameter.system_environment||' '||lics_parameter.system_code||' '||lics_parameter.system_unit, -- subject
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
  function view_unprocessed_batches return qu4_unprocessed_batches_type pipelined is

  begin

    for l_entity in (

          select a.q4x_batch_id batch_id,
            nvl(b.file_name,a.q4x_file_name) expected_file_name,
            b.row_count expected_row_count,
            c.q4x_row_count loaded_row_count,
            decode(b.row_count,nvl(c.q4x_row_count,-1),'PASS',decode(a.q4x_row_count,0,'PASS','FAIL')) load_status -- digest equals loaded, or digest is empty
          from qu4_interface_hdr a,
            qu4_digest_load b,
            qu4_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status != qu4_constants.status_processed
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and qu4_constants.status_processed != c.q4x_status(+)
          order by 1,2,3

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_unprocessed_batches] : '||SQLERRM, 1, 4000));

  end view_unprocessed_batches;

end qu4_batch;
/

-- Synonyms
create or replace public synonym qu4_batch for ods_app.qu4_batch;

-- Grants
grant execute on ods_app.qu4_batch to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
