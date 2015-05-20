
set define off;

create or replace package ods_app.qu5_batch as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu5
    Owner   : ods_app
    Package : qu5_batch
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
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
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Type

  type qu5_unprocessed_batches_rec is record (
    batch_id  number(10,0),
    expected_file_name varchar2(512 char),
    expected_row_count number(10,0),
    loaded_row_count number(10,0),
    load_status varchar2(16 char)
  );

  type qu5_unprocessed_batches_type is table of qu5_unprocessed_batches_rec;

  -- Public : Functions
  procedure process_batches;
  procedure process_batch(p_batch_id in number);
  procedure force_batches;
  procedure check_batches;
  function view_unprocessed_batches return qu5_unprocessed_batches_type pipelined;

end qu5_batch;
/

create or replace package body ods_app.qu5_batch as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu5_batch';

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
    l_log_search_text := qu5_constants.setting_group||'_PROCESS_BATCH';
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
          from qu5_interface_hdr a,
            qu5_digest_load b,
            qu5_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status = qu5_constants.status_loaded
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and qu5_constants.status_loaded = c.q4x_status(+)
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

    lics_logging.write_log('Process Digest'); qu5_qu5cdw00.process_batch(p_batch_id); -- Digest
    lics_logging.write_log('Process Hierarchy'); qu5_qu5cdw01.process_batch(p_batch_id); -- Hierarchy
    lics_logging.write_log('Process GeneralList'); qu5_qu5cdw02.process_batch(p_batch_id); -- GeneralList
    lics_logging.write_log('Process Role'); qu5_qu5cdw03.process_batch(p_batch_id); -- Role
    lics_logging.write_log('Process Position'); qu5_qu5cdw04.process_batch(p_batch_id); -- Position
    lics_logging.write_log('Process Rep'); qu5_qu5cdw05.process_batch(p_batch_id); -- Rep
    lics_logging.write_log('Process RepAddress'); qu5_qu5cdw06.process_batch(p_batch_id); -- RepAddress
    lics_logging.write_log('Process Product'); qu5_qu5cdw07.process_batch(p_batch_id); -- Product
    lics_logging.write_log('Process ProductBarcode'); qu5_qu5cdw08.process_batch(p_batch_id); -- ProductBarcode
    lics_logging.write_log('Process Customer'); qu5_qu5cdw09.process_batch(p_batch_id); -- Customer
    lics_logging.write_log('Process CustomerAddress'); qu5_qu5cdw10.process_batch(p_batch_id); -- CustomerAddress
    lics_logging.write_log('Process CustomerNote'); qu5_qu5cdw11.process_batch(p_batch_id); -- CustomerNote
    lics_logging.write_log('Process CustomerContact'); qu5_qu5cdw12.process_batch(p_batch_id); -- CustomerContact
    lics_logging.write_log('Process CustomerVisitorDay'); qu5_qu5cdw13.process_batch(p_batch_id); -- CustomerVisitorDay
    lics_logging.write_log('Process CustomerContactTraining'); qu5_qu5cdw14.process_batch(p_batch_id); -- CustomerContactTraining
    lics_logging.write_log('Process AssortmentDetail'); qu5_qu5cdw15.process_batch(p_batch_id); -- AssortmentDetail
    lics_logging.write_log('Process CustomerAssortmentDetail'); qu5_qu5cdw16.process_batch(p_batch_id); -- CustomerAssortmentDetail
    lics_logging.write_log('Process ProductAssortmentDetail'); qu5_qu5cdw17.process_batch(p_batch_id); -- ProductAssortmentDetail
    lics_logging.write_log('Process AuthorisedListProduct'); qu5_qu5cdw18.process_batch(p_batch_id); -- AuthorisedListProduct
    lics_logging.write_log('Process Appointment'); qu5_qu5cdw19.process_batch(p_batch_id); -- Appointment
    lics_logging.write_log('Process CallCard'); qu5_qu5cdw20.process_batch(p_batch_id); -- CallCard
    lics_logging.write_log('Process CallCardNote'); qu5_qu5cdw21.process_batch(p_batch_id); -- CallCardNote
    lics_logging.write_log('Process OrderHeader'); qu5_qu5cdw22.process_batch(p_batch_id); -- OrderHeader
    lics_logging.write_log('Process OrderDetail'); qu5_qu5cdw23.process_batch(p_batch_id); -- OrderDetail
    lics_logging.write_log('Process Territory'); qu5_qu5cdw24.process_batch(p_batch_id); -- Territory
    lics_logging.write_log('Process CustomerTerritory'); qu5_qu5cdw25.process_batch(p_batch_id); -- CustomerTerritory
    lics_logging.write_log('Process PositionTerritory'); qu5_qu5cdw26.process_batch(p_batch_id); -- PositionTerritory
    lics_logging.write_log('Process Survey'); qu5_qu5cdw27.process_batch(p_batch_id); -- Survey
    lics_logging.write_log('Process SurveyQuestion'); qu5_qu5cdw28.process_batch(p_batch_id); -- SurveyQuestion
    lics_logging.write_log('Process ResponseOption'); qu5_qu5cdw29.process_batch(p_batch_id); -- ResponseOption
    lics_logging.write_log('Process Task'); qu5_qu5cdw30.process_batch(p_batch_id); -- Task
    lics_logging.write_log('Process TaskAssignment'); qu5_qu5cdw31.process_batch(p_batch_id); -- TaskAssignment
    lics_logging.write_log('Process TaskCustomer'); qu5_qu5cdw32.process_batch(p_batch_id); -- TaskCustomer
    lics_logging.write_log('Process TaskProduct'); qu5_qu5cdw33.process_batch(p_batch_id); -- TaskProduct
    lics_logging.write_log('Process TaskSurvey'); qu5_qu5cdw34.process_batch(p_batch_id); -- TaskSurvey
    lics_logging.write_log('Process ActivityHeader'); qu5_qu5cdw35.process_batch(p_batch_id); -- ActivityHeader
    lics_logging.write_log('Process SurveyAnswer'); qu5_qu5cdw36.process_batch(p_batch_id); -- SurveyAnswer
    lics_logging.write_log('Process Graveyard'); qu5_qu5cdw37.process_batch(p_batch_id); -- Graveyard
    lics_logging.write_log('Process CustomerWholesaler'); qu5_qu5cdw38.process_batch(p_batch_id); -- CustomerWholesaler
    lics_logging.write_log('Process ActivityDetail_DistCheck1'); qu5_qu5cdw39.process_batch(p_batch_id); -- ActivityDetail_DistCheck1
    lics_logging.write_log('Process ActivityDetail_DistCheck2'); qu5_qu5cdw40.process_batch(p_batch_id); -- ActivityDetail_DistCheck2
    lics_logging.write_log('Process ActivityDetail_RelayHours'); qu5_qu5cdw41.process_batch(p_batch_id); -- ActivityDetail_RelayHours
    lics_logging.write_log('Process ActivityDetail_SecondSite'); qu5_qu5cdw42.process_batch(p_batch_id); -- ActivityDetail_SecondSite
    lics_logging.write_log('Process ActivityDetail_PtOfInterupt'); qu5_qu5cdw43.process_batch(p_batch_id); -- ActivityDetail_PtOfInterupt
    lics_logging.write_log('Process ActivityDetail_Hardware'); qu5_qu5cdw44.process_batch(p_batch_id); -- ActivityDetail_Hardware
    lics_logging.write_log('Process ActivityDetail_Upgrades'); qu5_qu5cdw45.process_batch(p_batch_id); -- ActivityDetail_Upgrades
    lics_logging.write_log('Process ActivityDetail_Training'); qu5_qu5cdw46.process_batch(p_batch_id); -- ActivityDetail_Training
    lics_logging.write_log('Process ActivityDetail_ShareOfShelf'); qu5_qu5cdw47.process_batch(p_batch_id); -- ActivityDetail_ShareOfShelf
    lics_logging.write_log('Process ActivityDetail_PromoCompliance'); qu5_qu5cdw48.process_batch(p_batch_id); -- ActivityDetail_PromoCompliance
    lics_logging.write_log('Process ActivityDetail_NewProdDev'); qu5_qu5cdw49.process_batch(p_batch_id); -- ActivityDetail_NewProdDev


    -- Update Interface Header
    qu5_interface.complete_batch(p_batch_id);

    -- Commit Processed Batch
    commit;

    -- Send Flag File ..
    begin
       l_outbound_instance := lics_outbound_loader.create_interface('CDWQVW01',null,'Quofore_Source_5.txt');
       lics_outbound_loader.append_data('{ "source": 5, "batch": '||p_batch_id||', "status": "ready" }'); -- Message Body JSON Encoded
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
    l_log_search_text := qu5_constants.setting_group||'_PROCESS_BATCH';
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
        from qu5_interface_hdr
        where q4x_status = qu5_constants.status_loaded
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
    l_log_search_text := qu5_constants.setting_group||'_CHECK_BATCH';
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
        from qu5_interface_hdr
        where q4x_status = qu5_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_create_time < sysdate-1
        and q4x_batch_id in (
          select max(q4x_batch_id) q4x_batch_id
          from qu5_interface_hdr
          where q4x_status = qu5_constants.status_processed
          and q4x_entity_name = 'DIGEST'
        )

        union all

        select 'Last Batch Processed was Empty - This is Possible on Weekends/Public Holidays' message,
          q4x_batch_id batch_id,
          q4x_create_time create_time
        from qu5_interface_hdr
        where q4x_status = qu5_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_row_count = 0
        and trim(to_char(sysdate,'Day')) not in ('Sunday','Monday') -- Ignore Empty Batches Over Weekend, Sun / Mon Mornings
        and q4x_batch_id in (
          select max(q4x_batch_id) q4x_batch_id
          from qu5_interface_hdr
          where q4x_status = qu5_constants.status_processed
          and q4x_entity_name = 'DIGEST'
          and q4x_create_time > sysdate-1
        )

        union all

        select 'Unprocessed Batch' message,
          q4x_batch_id batch_id,
          max(q4x_create_time) create_time
        from qu5_interface_hdr
        where q4x_status != qu5_constants.status_processed
        group by q4x_batch_id

        order by 1,2,3

      ) loop

        l_batch_errors := true;

        l_message := null;
        l_line := qu5_constants.app_instance_name;
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

        lics_logging.write_log('Errors Found .. Sending E-Mail ['||qu5_util.get_email_default||']');

        lics_mailer.send_short_email('Quofore_'||qu5_constants.setting_group||'_'||lics_parameter.system_environment||'_'||lics_parameter.system_code||'_'||lics_parameter.system_unit||'@'||lics_parameter.log_database, -- sender
          qu5_util.get_email_default, -- recipient
          'DAILY BATCH CHECK *ERROR* : Quofore '||qu5_constants.setting_group||' '||lics_parameter.system_environment||' '||lics_parameter.system_code||' '||lics_parameter.system_unit, -- subject
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
  function view_unprocessed_batches return qu5_unprocessed_batches_type pipelined is

  begin

    for l_entity in (

          select a.q4x_batch_id batch_id,
            nvl(b.file_name,a.q4x_file_name) expected_file_name,
            b.row_count expected_row_count,
            c.q4x_row_count loaded_row_count,
            decode(b.row_count,nvl(c.q4x_row_count,-1),'PASS',decode(a.q4x_row_count,0,'PASS','FAIL')) load_status -- digest equals loaded, or digest is empty
          from qu5_interface_hdr a,
            qu5_digest_load b,
            qu5_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status != qu5_constants.status_processed
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and qu5_constants.status_processed != c.q4x_status(+)
          order by 1,2,3

    )
    loop
      pipe row(l_entity);
    end loop;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.view_unprocessed_batches] : '||SQLERRM, 1, 4000));

  end view_unprocessed_batches;

end qu5_batch;
/

-- Synonyms
create or replace public synonym qu5_batch for ods_app.qu5_batch;

-- Grants
grant execute on ods_app.qu5_batch to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
