
set define off;

create or replace package ods_app.qu5_interface as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu5
    Owner   : ods_app
    Package : qu5_interface
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    Interface Control Package .. Maintains the [qu5_interface_hdr] table

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2013-03-05  Mal Chambeyron        Add Check Batches
    2014-05-15  Mal Chambeyron        Cleanup Source Id from tables / calls
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-03-30  Mal Chambeyron        Include Source Id for Original Instance (required for Partition Key)
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Functions
  function start_load(p_batch_id in number, p_entity_name in varchar2, p_interface_name in varchar2, p_file_name in varchar2, p_timestamp in date) return number;
  procedure complete_load(p_load_seq in number, p_batch_id in number, p_entity_name in varchar2, p_row_count in number);
  procedure complete_batch(p_batch_id in number);

end qu5_interface;
/

create or replace package body ods_app.qu5_interface as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu5_interface';
  g_package_desc constant varchar2(64 char) := 'Interface Header [ods.qu5_interface_hdr]';

  /*****************************************************************************
  ** PUBLIC Function : Start Interface Load .. Returning Load Sequence
  *****************************************************************************/
  function start_load(p_batch_id in number, p_entity_name in varchar2, p_interface_name in varchar2, p_file_name in varchar2, p_timestamp in date) return number as

    l_row_count number;
    l_load_seq number;
    l_key_desc varchar2(1024 char);

  begin
    -- Set Key Description
    l_key_desc := 'Batch/Entity ['||p_batch_id||']['||upper(p_entity_name)||']';

    -- Check if Batch / Entity already exists ..
    begin
      select count(1) into l_row_count
      from qu5_interface_hdr
      where q4x_batch_id = p_batch_id
      and q4x_entity_name = upper(p_entity_name);
    exception
      when others then
        raise_application_error(-20000, substr(g_package_desc||' Check for '||l_key_desc||' Failed : '||SQLERRM, 1, 4000));
    end;

    if l_row_count > 0 then
      raise_application_error(-20000, g_package_desc||' for '||l_key_desc||' Already Exists');
    end if;

    -- Get Next Load Sequence
    l_load_seq := qu5_util.get_next_load_seq;

    -- Create Interface Header
    begin

      insert into qu5_interface_hdr (
        q4x_load_seq,
        q4x_create_user,
        q4x_create_time,
        q4x_modify_user,
        q4x_modify_time,
        q4x_status,
        q4x_interface_name,
        q4x_batch_id,
        q4x_entity_name,
        q4x_file_name,
        q4x_timestamp,
        q4x_row_count
      ) values (
        l_load_seq, -- q4x_load_seq
        user, -- q4x_create_user
        sysdate, -- q4x_create_time
        user, -- q4x_modify_user
        sysdate, -- q4x_modify_time
        qu5_constants.status_started, -- q4x_status
        upper(p_interface_name), -- q4x_interface_name
        p_batch_id, -- q4x_batch_id
        upper(p_entity_name), -- q4x_entity_name
        p_file_name, -- q4x_file_name
        p_timestamp, -- q4x_timestamp
        0 -- q4x_row_count
      );

    exception
      when others then
        raise_application_error(-20000, substr(g_package_desc||' Insert Load ['||l_load_seq||'] for '||l_key_desc||' Failed : '||SQLERRM, 1, 4000));
    end;

    -- Return Load Sequence
    return l_load_seq;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.start_load] : '||SQLERRM, 1, 4000));

  end start_load;

  /*****************************************************************************
  ** PUBLIC Procedure : Complete Interface Load
  *****************************************************************************/
  procedure complete_load(p_load_seq in number, p_batch_id in number, p_entity_name in varchar2, p_row_count in number) as

    l_status varchar2(32 char);
    l_key_desc varchar2(1024 char);

  begin
    -- Set Key Description
    l_key_desc := 'Load/Batch/Entity ['||p_load_seq||']['||p_batch_id||']['||upper(p_entity_name)||']';

    -- Check if Load / Batch / Entity already exists ..
    begin

      select q4x_status into l_status
      from qu5_interface_hdr
      where q4x_load_seq = p_load_seq
      and q4x_batch_id = p_batch_id
      and q4x_entity_name = upper(p_entity_name);

    exception
      when no_data_found then
        raise_application_error(-20000, g_package_desc||' Not Started for '||l_key_desc);
      when others then
        raise_application_error(-20000, substr(g_package_desc||' Check for '||l_key_desc||' Failed : '||SQLERRM, 1, 4000));
    end;

    if l_status <> qu5_constants.status_started then
        raise_application_error(-20000, g_package_desc||' for '||l_key_desc||' Invalid Status ['||l_status||'] Expected ['||qu5_constants.status_started||']');
    end if;

    -- Update Interface Header
    begin

      update qu5_interface_hdr
      set
        q4x_modify_user = user,
        q4x_modify_time = sysdate,
        q4x_status = qu5_constants.status_loaded,
        q4x_row_count = p_row_count
      where q4x_load_seq = p_load_seq
      and q4x_batch_id = p_batch_id
      and q4x_entity_name = upper(p_entity_name);

      if sql%notfound then -- Check for Unsuccessful Update
        raise_application_error(-20000, g_package_desc||' Updated Row Not Found for '||l_key_desc);
      end if;

    exception
      when others then
        raise_application_error(-20000, substr(g_package_desc||' Update for '||l_key_desc||' Failed : '||SQLERRM, 1, 4000));
    end;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.complete_load] : '||SQLERRM, 1, 4000));

  end complete_load;

  /*****************************************************************************
  ** PUBLIC Procedure : Complete Batch
  *****************************************************************************/
  procedure complete_batch(p_batch_id in number) as

    l_status varchar2(32 char);
    l_key_desc varchar2(1024 char);

  begin
    -- Set Key Description
    l_key_desc := 'Batch ['||p_batch_id||']';

    -- Update Interface Header
    begin

      update qu5_interface_hdr
      set
        q4x_modify_user = user,
        q4x_modify_time = sysdate,
        q4x_status = qu5_constants.status_processed
      where q4x_batch_id = p_batch_id;

      if sql%notfound then -- Check for Unsuccessful Update
        raise_application_error(-20000, g_package_desc||' Updated Row Not Found for '||l_key_desc);
      end if;

    exception
      when others then
        raise_application_error(-20000, substr(g_package_desc||' Update for '||l_key_desc||' Failed : '||SQLERRM, 1, 4000));
    end;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.complete_load] : '||SQLERRM, 1, 4000));

  end complete_batch;

end qu5_interface;
/

-- Synonyms
create or replace public synonym qu5_interface for ods_app.qu5_interface;

-- Grants
grant execute on ods_app.qu5_interface to lics_app;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
