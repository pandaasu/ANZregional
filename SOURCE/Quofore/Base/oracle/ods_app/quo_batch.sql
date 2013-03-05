set define off;

create or replace package ods_app.quo_batch as

  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

   System  : quo
   Package : ods_app.quo_batch
   Owner   : ods_app
   Author  : Mal Chambeyron

   Description
   -----------------------------------------------------------------------------
   Quofore Interface Batch Processing Package ..

   YYYY-MM-DD   Author                 Description
   ----------   --------------------   -----------------------------------------
   2013-02-19   Mal Chambeyron         Created
   2013-03-05   Mal Chambeyron         Add Check Batches

  *****************************************************************************/

  -- Public : Functions
  procedure process_batches;
  procedure process_batch(p_source_id in number, p_batch_id in number);
  procedure force_batches;
  procedure check_batches;
   
end quo_batch;
/

create or replace package body ods_app.quo_batch as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);
  
  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.quo_batch';

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
    l_log_search_text := 'QUO_PROCESS_BATCH';
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
        select source_id,
          batch_id
        from (  
          select a.q4x_source_id source_id,
            a.q4x_batch_id batch_id,
            decode(b.row_count,nvl(c.q4x_row_count,-1),'PASS',decode(a.q4x_row_count,0,'PASS','FAIL')) load_status -- digest equals loaded, or digest is empty
          from quo_interface_hdr a,
            quo_digest_load b,
            quo_interface_hdr c
          -- interface header for digest > digest
          where a.q4x_status = quo_constants.status_loaded
          and a.q4x_entity_name = 'DIGEST'
          and a.q4x_source_id = b.q4x_source_id(+)
          and a.q4x_batch_id = b.q4x_batch_id(+)
          -- digest > interaface headers found in digest
          and b.q4x_source_id = c.q4x_source_id(+)
          and b.q4x_batch_id = c.q4x_batch_id(+)
          and b.file_name = c.q4x_file_name(+)
          and quo_constants.status_loaded = c.q4x_status(+) 
        )
        group by source_id,
          batch_id
        having min(load_status) = 'PASS'
        order by source_id,
          batch_id
      ) loop
      
        l_batch_processed := true;
        lics_logging.write_log('Process Source ['||batch.source_id||'] Batch ['||batch.batch_id||']');
        process_batch(batch.source_id, batch.batch_id);
        
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
  procedure process_batch(p_source_id in number, p_batch_id in number) as
  
    l_err_msg varchar2(4000 char);
    l_outbound_instance number(15);
  
  begin
  
    quo_quocdw00.process_batch(p_source_id, p_batch_id); -- Digest
    quo_quocdw01.process_batch(p_source_id, p_batch_id); -- Hierarchy
    quo_quocdw02.process_batch(p_source_id, p_batch_id); -- GeneralList
    quo_quocdw03.process_batch(p_source_id, p_batch_id); -- Position
    quo_quocdw04.process_batch(p_source_id, p_batch_id); -- Rep
    quo_quocdw05.process_batch(p_source_id, p_batch_id); -- RepAddress
    quo_quocdw06.process_batch(p_source_id, p_batch_id); -- Product
    quo_quocdw07.process_batch(p_source_id, p_batch_id); -- ProductBarcode
    quo_quocdw08.process_batch(p_source_id, p_batch_id); -- Customer
    quo_quocdw09.process_batch(p_source_id, p_batch_id); -- CustomerAddress
    quo_quocdw10.process_batch(p_source_id, p_batch_id); -- CustomerNote
    quo_quocdw11.process_batch(p_source_id, p_batch_id); -- CustomerContact
    quo_quocdw12.process_batch(p_source_id, p_batch_id); -- CustomerVisitorDay
    quo_quocdw13.process_batch(p_source_id, p_batch_id); -- AssortmentDetail
    quo_quocdw14.process_batch(p_source_id, p_batch_id); -- CustomerAssortmentDetail
    quo_quocdw15.process_batch(p_source_id, p_batch_id); -- ProductAssortmentDetail
    quo_quocdw16.process_batch(p_source_id, p_batch_id); -- AuthorisedListProduct
    quo_quocdw17.process_batch(p_source_id, p_batch_id); -- Appointment
    quo_quocdw18.process_batch(p_source_id, p_batch_id); -- CallCard
    quo_quocdw19.process_batch(p_source_id, p_batch_id); -- CallCardNote
    quo_quocdw20.process_batch(p_source_id, p_batch_id); -- OrderHeader
    quo_quocdw21.process_batch(p_source_id, p_batch_id); -- OrderDetail
    quo_quocdw22.process_batch(p_source_id, p_batch_id); -- Territory
    quo_quocdw23.process_batch(p_source_id, p_batch_id); -- CustomerTerritory
    quo_quocdw24.process_batch(p_source_id, p_batch_id); -- PositionTerritory
    quo_quocdw25.process_batch(p_source_id, p_batch_id); -- Survey
    quo_quocdw26.process_batch(p_source_id, p_batch_id); -- SurveyQuestion
    quo_quocdw27.process_batch(p_source_id, p_batch_id); -- ResponseOption
    quo_quocdw28.process_batch(p_source_id, p_batch_id); -- Task
    quo_quocdw29.process_batch(p_source_id, p_batch_id); -- TaskAssignment
    quo_quocdw30.process_batch(p_source_id, p_batch_id); -- TaskCustomer
    quo_quocdw31.process_batch(p_source_id, p_batch_id); -- TaskProduct
    quo_quocdw32.process_batch(p_source_id, p_batch_id); -- TaskSurvey
    quo_quocdw33.process_batch(p_source_id, p_batch_id); -- ActivityHeader
    quo_quocdw34.process_batch(p_source_id, p_batch_id); -- ActivityDetailDistCheck
    quo_quocdw35.process_batch(p_source_id, p_batch_id); -- ActivityDetailOOS
    quo_quocdw36.process_batch(p_source_id, p_batch_id); -- ActivityDetailSoSPSD
    quo_quocdw37.process_batch(p_source_id, p_batch_id); -- ActivityDetailSoSSPC
    quo_quocdw38.process_batch(p_source_id, p_batch_id); -- ActivityDetailSoCPSD
    quo_quocdw39.process_batch(p_source_id, p_batch_id); -- ActivityDetailSoCSPC
    quo_quocdw40.process_batch(p_source_id, p_batch_id); -- ActivityDetailTraining
    quo_quocdw41.process_batch(p_source_id, p_batch_id); -- SurveyAnswer
    quo_quocdw42.process_batch(p_source_id, p_batch_id); -- Graveyard
    quo_quocdw43.process_batch(p_source_id, p_batch_id); -- ActivityDetailOFF

    -- Update Interface Header 
    quo_interface.complete_batch(p_source_id, p_batch_id);
    
    -- Commit Processed Batch 
    commit;

    -- Send Flag File ..    
    begin 
       l_outbound_instance := lics_outbound_loader.create_interface('CDWQVW01',null,'Quofore_Source_'||p_source_id||'.txt'); 
       lics_outbound_loader.append_data('{ "source": '||p_source_id||', "batch": '||p_batch_id||', "status": "ready" }'); -- Message Body JSON Encoded  
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
    l_log_search_text := 'QUO_PROCESS_BATCH';
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
        select distinct q4x_source_id source_id,
          q4x_batch_id batch_id
        from quo_interface_hdr 
        where q4x_status = quo_constants.status_loaded                
        order by q4x_source_id,
          q4x_batch_id
      ) loop
      
        l_batch_processed := true;
        lics_logging.write_log('Process Source ['||batch.source_id||'] Batch ['||batch.batch_id||']');
        process_batch(batch.source_id, batch.batch_id);
        
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
    l_source_id number(4,0);
    l_message varchar2(4000 char);
    l_line varchar2(4000 char);
    l_body varchar2(4000 char);

  begin
  
    -- start logging
    l_log_header_text := 'Quofore Check Batches';
    l_log_search_text := 'QUO_CHECK_BATCH';
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
      l_source_id := -1;
      l_message := null;
      for batch in (
      
        select q4x_source_id source_id,
          'Last Batch Processed > 24 Hours' message,
          q4x_batch_id batch_id,
          q4x_create_time create_time
        from quo_interface_hdr
        where q4x_status = quo_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_create_time < sysdate-1
        and (q4x_source_id, q4x_batch_id) in ( 
          select q4x_source_id,
            max(q4x_batch_id) q4x_batch_id
          from quo_interface_hdr
          where q4x_status = quo_constants.status_processed
          and q4x_entity_name = 'DIGEST'
          group by q4x_source_id
        )
        
        union all
        
        select q4x_source_id source_id,
          'Last Batch Processed was Empty - This is Possible on Weekends/Public Holidays' message,
          q4x_batch_id batch_id,
          q4x_create_time create_time
        from quo_interface_hdr
        where q4x_status = quo_constants.status_processed
        and q4x_entity_name = 'DIGEST'
        and q4x_row_count = 0
        and trim(to_char(sysdate,'Day')) not in ('Sunday','Monday') -- Ignore Empty Batches Over Weekend, Sun / Mon Mornings        
        and (q4x_source_id, q4x_batch_id) in ( -- latest batch per source / 24 hours 
          select q4x_source_id,
            max(q4x_batch_id) q4x_batch_id
          from quo_interface_hdr
          where q4x_status = quo_constants.status_processed
          and q4x_entity_name = 'DIGEST'
          and q4x_create_time > sysdate-1
          group by q4x_source_id
        )          

        union all

        select q4x_source_id source_id,
          'Unprocessed Batch' message,
          q4x_batch_id batch_id,
          max(q4x_create_time) create_time
        from quo_interface_hdr
        where q4x_status != quo_constants.status_processed
        group by q4x_source_id,
          q4x_batch_id
        
        order by 1,2,3  

      ) loop
      
        l_batch_errors := true;
        
        if batch.source_id != nvl(l_source_id,-1) then
          l_source_id := batch.source_id;
          l_message := null;
          l_line := 'Source : ['||batch.source_id||'] '||quo_util.get_source_desc(batch.source_id);
          l_body := l_body||l_line||chr(10)||chr(13);
          lics_logging.write_log(l_line);
        end if;
        
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

        lics_logging.write_log('Errors Found .. Sending E-Mail ['||quo_util.get_email_default||']');

        lics_mailer.send_short_email('Quofore_'||lics_parameter.system_environment||'_'||lics_parameter.system_code||'_'||lics_parameter.system_unit||'@'||lics_parameter.log_database, -- sender
          quo_util.get_email_default, -- recipient
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
  
end quo_batch;
/

-- Synonyms
create or replace public synonym quo_batch for ods_app.quo_batch;

-- Grants
grant execute on ods_app.quo_batch to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/

