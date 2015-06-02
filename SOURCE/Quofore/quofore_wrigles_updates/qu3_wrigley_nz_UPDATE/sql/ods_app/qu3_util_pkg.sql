
set define off;

create or replace package ods_app.qu3_util as
  /*****************************************************************************
  ** Package Definition
  ******************************************************************************

    System  : qu3
    Owner   : ods_app
    Package : qu3_util
    Author  : Mal Chambeyron

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    Utility Package

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-21  Mal Chambeyron        Created
    2013-07-10  Mal Chambeyron        Increase Entity Name from 32 > 64 char
    2014-05-15  Mal Chambeyron        Make into a Template
    2015-03-17  Mal Chambeyron        Remove
                                      - Get Source Desc
                                      - Get Interface Source Id
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

  -- Public : Procedures/Functions, Raise Exception - as Failure on Each is Fatal
  function get_next_load_seq return number;
  function get_email_default return varchar2;

  procedure validate_interface_name(p_entity_name in varchar2, p_interface_name in varchar2);
  function get_entity_interface_name(p_entity_name in varchar2) return varchar2;

  procedure validate_file_name(p_entity_name in varchar2, p_file_name in varchar2);
  function get_file_entity_name(p_file_name in varchar2) return varchar2;
  function get_file_timestamp(p_file_name in varchar2) return date;
  function get_file_batch_id(p_file_name in varchar2) return number;

  function get_end_of_day(p_date in date) return date;
  function get_last_date_for_yyyyppw(p_yyyyppw in number) return date;
  function get_last_date_for_yyyypp(p_yyyypp in number) return date;
  function get_last_date_for_myyyy(p_myyyy in number) return date;
  function get_yyyyppw(p_date in date) return number;

  -- Public : Functions, Set On Error - as Failure on Each is Non-Fatal
  function get_string(p_column_name in varchar2, p_size in number, p_is_nullable in boolean, p_on_error in out boolean) return varchar2;
  function get_number(p_column_name in varchar2, p_precision in number, p_scale in number, p_is_nullable in boolean, p_on_error in out boolean) return number;
  function get_boolean_as_number(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return number;
  function get_datetime(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return date;
  function get_date(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return date;
  function get_time(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return date;

end qu3_util;
/

create or replace package body ods_app.qu3_util as

  -- Private : Application Exception
  g_application_exception exception;
  pragma exception_init(g_application_exception, -20000);

  -- Private : Constants
  g_package_name constant varchar2(64 char) := 'ods_app.qu3_util';
  g_expected_file_format_desc constant varchar2(64 char) := '{Entity}_{Timestamp:YYYYMMDDHH24MISS}_{Batch Id:99999999}.csv';

  /*****************************************************************************
  ** PUBLIC Function : Get Next Load Sequence
  *****************************************************************************/
  function get_next_load_seq return number as

    l_next_seq number;

  begin

    -- Get Next Load Sequence
    select qu3_load_seq.nextval into l_next_seq from dual;
    return l_next_seq; -- Normal Return

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_next_load_seq] : Failed to Get Next Sequence [ods.qu3_load_seq.nextval] : '||SQLERRM, 1, 4000));

  end get_next_load_seq;

  /*****************************************************************************
  ** PUBLIC Function : Get Email Default
  *****************************************************************************/
  function get_email_default return varchar2 as

    l_set_group varchar2(30);
    l_set_code varchar2(30);
    l_set_value varchar2(256);

  begin

    -- Retrieve Email Default
    l_set_group := qu3_constants.setting_group;
    l_set_code := 'EMAIL:DEFAULT';
    l_set_value := trim(lics_setting_configuration.retrieve_setting(l_set_group,l_set_code));
    if l_set_value is null then
      raise_application_error(-20000, 'Email Default : Group ['||l_set_group||'] Code ['||l_set_code||'] : Not Configured in Table [lics.lics_setting]');
    end if;

    return l_set_value; -- Normal Return

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_email_default] : '||SQLERRM, 1, 4000));

  end get_email_default;

  /*****************************************************************************
  ** PUBLIC Function : Get Entity Interface Name
  *****************************************************************************/
  function get_entity_interface_name(p_entity_name in varchar2) return varchar2 as

    l_entity_interface_name varchar2(32);

  begin

    -- Retrieve Entity Interface Name
    begin
      select q4x_interface_name into l_entity_interface_name
      from qu3_interface_list
      where q4x_entity_name = upper(p_entity_name);
    exception
      when no_data_found then
        raise_application_error(-20000, 'Not Configured');
      when others then
        raise_application_error(-20000, substr('Failed : '||SQLERRM, 1, 4000));
    end;

    return l_entity_interface_name; -- Normal Return

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_entity_interface_name] : Entity ['||upper(p_entity_name)||'] : Table [ods.qu3_interface_list] : '||SQLERRM, 1, 4000));

  end get_entity_interface_name;

  /*****************************************************************************
  ** PUBLIC Procedure : Validate Interface Name
  *****************************************************************************/
  procedure validate_interface_name(p_entity_name in varchar2, p_interface_name in varchar2) as

    l_entity_interface_name varchar2(32 char);

  begin

    -- Retrieve Entity Interface Name
    l_entity_interface_name := get_entity_interface_name(p_entity_name);

    -- Return Error for Not Configured Entity
    if l_entity_interface_name is null then
      raise_application_error(-20000, 'Entity ['||upper(p_entity_name)||'] Interface Not Configured in Table [ods.qu3_interface_list]');
    end if;

    -- Return Error for Invalid Interace
    if upper(substr(p_interface_name,1,length(l_entity_interface_name))) != upper(l_entity_interface_name) then
      raise_application_error(-20000, 'Invalid Interface for Entity, Value ['||upper(p_interface_name)||'] : Expected ['||upper(l_entity_interface_name));
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.validate_interface_name] : '||SQLERRM, 1, 4000));

  end validate_interface_name;

  /*****************************************************************************
  ** PUBLIC Procedure : Is Valid File Name ?
  *****************************************************************************/
  procedure validate_file_name(p_entity_name in varchar2, p_file_name in varchar2) as

    l_expected_file_name_format varchar2(512 char);

  begin

    -- Validate File Name Format
    l_expected_file_name_format := '^'||p_entity_name||'_[[:digit:]]{14}_[[:digit:]]{8}.csv$';
    if regexp_instr(p_file_name,l_expected_file_name_format,1,1,0,'i') = 1 then -- Check file name, case insensitive
      -- Raise Exception on Invalid Entity
      if get_entity_interface_name(p_entity_name) is null then
        raise_application_error(-20000, 'Entity ['||upper(p_entity_name)||'] Interface Not Configured in Table [ods.qu3_interface_list] ');
      end if;
      -- Raise Exception on Invalid Timestamp
      if get_file_timestamp(p_file_name) is null then
        raise_application_error(-20000, 'Invalid File Timestamp ['||p_file_name||']');
      end if;
      -- Raise Exception on Invalid Batch Id
      if get_file_batch_id(p_file_name) is null then
        raise_application_error(-20000, 'Invalid File Batch Id ['||p_file_name||']');
      end if;
    else -- Raise Exception on Invalid File Name Format
      raise_application_error(-20000, 'Invalid File Name ['||p_file_name||'] : Expected Format ['||l_expected_file_name_format||']');
    end if;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.validate_file_name] : '||SQLERRM, 1, 4000));

  end validate_file_name;

  /*****************************************************************************
  ** PUBLIC Function : Get File Entity Name
  *****************************************************************************/
  function get_file_entity_name(p_file_name in varchar2) return varchar2 as

    l_entity_name varchar2(64 char);

  begin

    -- Extract File Entity
    l_entity_name := replace(regexp_substr(p_file_name,'[^_]+_'),'_',null);
    if l_entity_name is null then
      raise_application_error(-20000, 'Unable to Extract Entity ['||p_file_name||'] : Expected Format ['||g_expected_file_format_desc||']');
    end if;

    return l_entity_name;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_file_entity_name] : '||SQLERRM, 1, 4000));

  end get_file_entity_name;

  /*****************************************************************************
  ** PUBLIC Function : Get File Timestamp
  *****************************************************************************/
  function get_file_timestamp(p_file_name in varchar2) return date as

  begin

    -- Extract File Timestamp
    begin
      return to_date(replace(regexp_substr(p_file_name,'_\d{14}_',1),'_',null),'YYYYMMDDHH24MISS');
    exception
      when others then
        raise_application_error(-20000, 'Unable to Extract Timestamp ['||p_file_name||'] : Expected Format ['||g_expected_file_format_desc||']');
    end;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_file_timestamp] : '||SQLERRM, 1, 4000));

  end get_file_timestamp;

  /*****************************************************************************
  ** PUBLIC Function : Get File Batch Id
  *****************************************************************************/
  function get_file_batch_id(p_file_name in varchar2) return number as

  begin

    -- Extract File Batch Id
    begin
      return to_number(replace(replace(regexp_substr(p_file_name,'_\d{8}\.',1),'_',null),'.',null));
    exception
      when others then
        raise_application_error(-20000, 'Unable to Extract Batch Id ['||p_file_name||'] : Expected Format ['||g_expected_file_format_desc||']');
    end;

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_file_batch_id] : '||SQLERRM, 1, 4000));

  end get_file_batch_id;

  /*****************************************************************************
  ** PUBLIC Function : Get End of Day for a Given Date .. ie. YYYYMMDD 23:59:59
  *****************************************************************************/
  function get_end_of_day(p_date in date) return date as

  begin

    return trunc(p_date) + (1-1/24/60/60); -- Returns 23:59:59 for a given Date

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_end_of_day] : '||SQLERRM, 1, 4000));

  end get_end_of_day;

  /*****************************************************************************
  ** PUBLIC Function : Get Last Calendar Date for Mars Year/Period/Week
  *****************************************************************************/
  function get_last_date_for_yyyyppw(p_yyyyppw in number) return date as

    l_date date;

  begin

    select max(calendar_date) into l_date
    from mars_date
    where mars_week = p_yyyyppw;

    return get_end_of_day(l_date);

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_last_date_for_yyyyppw] : '||SQLERRM, 1, 4000));

  end get_last_date_for_yyyyppw;

  /*****************************************************************************
  ** PUBLIC Function : Get Last Calendar Date for Mars Year/Period
  *****************************************************************************/
  function get_last_date_for_yyyypp(p_yyyypp in number) return date as

    l_date date;

  begin

    select max(calendar_date) into l_date
    from mars_date
    where mars_period = p_yyyypp;

    return get_end_of_day(l_date);

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_last_date_for_yyyypp] : '||SQLERRM, 1, 4000));

  end get_last_date_for_yyyypp;

  /*****************************************************************************
  ** PUBLIC Function : Get Last Calendar Date for Mars Year
  *****************************************************************************/
  function get_last_date_for_myyyy(p_myyyy in number) return date as

    l_date date;

  begin

    select max(calendar_date) into l_date
    from mars_date
    where mars_year = p_myyyy;

    return get_end_of_day(l_date);

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_last_date_for_myyyy] : '||SQLERRM, 1, 4000));

  end get_last_date_for_myyyy;

  /*****************************************************************************
  ** PUBLIC Function : Get Mars Year/Period/Week
  *****************************************************************************/
  function get_yyyyppw(p_date in date) return number as

    l_date date;
    l_iso_year number(4);
    l_iso_week_of_year number(2);
    l_period number(2);
    l_week_of_period number(1);

  begin

    l_date := trunc(p_date) + 1;

    -- check limits
    if l_date < to_date('19940101', 'YYYYMMDD') then
      raise_application_error(-20000, '['||g_package_name||'.get_yyyyppw] : Date Cannot be Less Than 1994-01-01');
    end if;

    if l_date > to_date('90000101', 'YYYYMMDD') then
      raise_application_error(-20000, '['||g_package_name||'.get_yyyyppw] : Date Cannot be Greater Than 9000-01-01');
    end if ;

    -- calc mars date
    l_iso_year := to_number(to_char(l_date,'iyyy'));
    l_iso_week_of_year := to_number(to_char(l_date,'iw'));

    if l_iso_week_of_year = 53 then
      l_period := 13;
      l_week_of_period := 5;
    else
      l_period := ceil(l_iso_week_of_year/4);
      l_week_of_period := mod(l_iso_week_of_year,4);
      if l_week_of_period = 0 then
        l_week_of_period := 4;
      end if;
    end if;

    return l_iso_year * 1000 + l_period * 10 + l_week_of_period; -- normal return

  exception
    when others then
      raise_application_error(-20000, substr('['||g_package_name||'.get_yyyyppw] : '||SQLERRM, 1, 4000));

  end get_yyyyppw;

  /*****************************************************************************
  ** PUBLIC Function : Get Validated String
  *****************************************************************************/
  function get_string(p_column_name in varchar2, p_size in number, p_is_nullable in boolean, p_on_error in out boolean) return varchar2 as

    l_return_value varchar2(4000 char);
    l_message_prefix varchar2(4000 char);

  begin

    -- Set Message Prefix
    l_message_prefix := '['||g_package_name||'.get_string] Field ['||p_column_name||']';

    -- Get Value
    l_return_value := lics_inbound_utility.get_variable(p_column_name);

    -- Add Value to Message Prefix
    l_message_prefix := l_message_prefix||' Value ['||l_return_value||']';

    -- Not Nullable .. and Value is Null
    if l_return_value is null then
      if p_is_nullable = false then
        lics_inbound_utility.add_exception(l_message_prefix||' Cannot be NULL');
        p_on_error := true;
        return null; -- Error Return
      end if;
      return null; -- Null, No Need to Continue
    end if;

    -- Reconstitute LF Escaping .. '</n>' -> chr(10) .. MUST be Completed before Size Check
    l_return_value := replace(l_return_value,'<\n>',chr(10));

    -- Value Too Large
    if length(l_return_value) > p_size then
      lics_inbound_utility.add_exception(l_message_prefix||' Too Large : Expected Size ['||p_size||'] Actual Size ['||length(l_return_value)||']');
      p_on_error := true;
      return null; -- Error Return
    end if;
    return l_return_value; -- Normal Return

  exception
    when others then
      raise_application_error(-20000, substr(l_message_prefix||' : '||SQLERRM, 1, 4000));

  end get_string;

  /*****************************************************************************
  ** PUBLIC Function : Get Validated Number
  *****************************************************************************/
  function get_number(p_column_name in varchar2, p_precision in number, p_scale in number, p_is_nullable in boolean, p_on_error in out boolean) return number as

    l_value varchar2(4000 char);
    l_number_format varchar2(64);
    l_message_prefix varchar2(4000 char);

  begin

    -- Set Message Prefix
    l_message_prefix := '['||g_package_name||'.get_number] Field ['||p_column_name||']';

    -- Get Value as String
    l_value := get_string(p_column_name, 4000, p_is_nullable, p_on_error);

    -- Add Value to Message Prefix
    l_message_prefix := l_message_prefix||' Value ['||l_value||']';

    -- Return if Null
    if l_value is null then
      return null; -- Null, No Need to Continue
    end if;

    -- Create Number Format String
    -- 'Technically' NOT correct to precision / scale .. however meets our usage needs
    l_number_format := substr('9999999999999999999999999999999999999999',1,p_precision-p_scale);
    if p_scale > 0 then
      l_number_format := l_number_format||'.'||substr('0000000000000000000000000000000000000000',1,p_scale);
    elsif p_scale = 0 then
      null; -- Do nothing
    else -- Only allow positive scales
      raise_application_error(-20000, 'Negative Scale Invalid');
    end if;

    -- Convert Number
    begin
      return to_number(l_value,l_number_format); -- Normal Return
    exception
      when others then
        lics_inbound_utility.add_exception(l_message_prefix||' Invalid Number : Expected Format ['||l_number_format||']');
        p_on_error := true;
        return null; -- Error Return
    end;

  exception
    when others then
      raise_application_error(-20000, substr(l_message_prefix||' : '||SQLERRM, 1, 4000));

  end get_number;

  /*****************************************************************************
  ** PUBLIC Function : Get Validated Boolean .. Returns Number, 1=True | 0=False
  *****************************************************************************/
  function get_boolean_as_number(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return number as

    l_value varchar2(4000 char);
    l_message_prefix varchar2(4000 char);

  begin

    -- Set Message Prefix
    l_message_prefix := '['||g_package_name||'.get_boolean_as_number] Field ['||p_column_name||']';

    -- Get Value as String
    l_value := get_string(p_column_name, 5, p_is_nullable, p_on_error);

    -- Add Value to Message Prefix
    l_message_prefix := l_message_prefix||' Value ['||l_value||']';

    -- Return if Null
    if l_value is null then
      return null; -- Null, No Need to Continue
    end if;

    -- Convert Boolean .. True = 1, False = 0
    if upper(l_value) = 'TRUE' then
      return 1; -- Normal Return
    elsif upper(l_value) = 'FALSE' then
      return 0; -- Normal Return
    else
      lics_inbound_utility.add_exception(l_message_prefix||' Invalid Boolean : Expected Format [TRUE|FALSE]');
      p_on_error := true;
      return null; -- Error Return
    end if;

  exception
    when others then
      raise_application_error(-20000, substr(l_message_prefix||' : '||SQLERRM, 1, 4000));

  end get_boolean_as_number;

  /*****************************************************************************
  ** PUBLIC Function : Get Validated Date/Time
  *****************************************************************************/
  function get_datetime(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return date as

    l_value varchar2(4000 char);
    l_message_prefix varchar2(4000 char);

  begin

    -- Set Message Prefix
    l_message_prefix := '['||g_package_name||'.get_datetime] Field ['||p_column_name||']';

    -- Get Value as String
    l_value := get_string(p_column_name, 20, p_is_nullable, p_on_error);

    -- Add Value to Message Prefix
    l_message_prefix := l_message_prefix||' Value ['||l_value||']';

    -- Return if Null
    if l_value is null then
      return null; -- Null, No Need to Continue
    end if;

    -- Convert Datetime .. YYYY-MM-DDTHH24:MI:SSZ .. 2012-12-31T23:59:59Z
    begin
      return to_date(substr(l_value,1,10)||' '||substr(l_value,12,8),'YYYY-MM-DD HH24:MI:SS'); -- Normal Return
    exception
      when others then
        lics_inbound_utility.add_exception(l_message_prefix||' Invalid Datetime : Expected Format [YYYY-MM-DDTHH24:MI:SSZ]');
        p_on_error := true;
        return null; -- Error Return
    end;

  exception
    when others then
      raise_application_error(-20000, substr(l_message_prefix||' : '||SQLERRM, 1, 4000));

  end get_datetime;

  /*****************************************************************************
  ** PUBLIC Function : Get Validated Date
  *****************************************************************************/
  function get_date(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return date as

    l_value varchar2(4000 char);
    l_message_prefix varchar2(4000 char);

  begin

    -- Set Message Prefix
    l_message_prefix := '['||g_package_name||'.get_date] Field ['||p_column_name||']';

    -- Get Value as String
    l_value := get_string(p_column_name, 20, p_is_nullable, p_on_error);

    -- Add Value to Message Prefix
    l_message_prefix := l_message_prefix||' Value ['||l_value||']';

    -- Return if Null
    if l_value is null then
      return null; -- Null, No Need to Continue
    end if;

    -- Convert Datetime .. YYYY-MM-DDTHH24:MI:SSZ .. 2012-12-31T00:00:00Z
    -- if substr(l_value,12,8) != '00:00:00' and substr(l_value,12,8) != '23:00:00' then
    if substr(l_value,12,8) != '00:00:00' then
      lics_inbound_utility.add_exception(l_message_prefix||' Invalid Date : Expected [00:00:00] for Time Component');
      p_on_error := true;
      return null; -- Error Return
    end if;
    begin
      return trunc(to_date(substr(l_value,1,10)||' '||substr(l_value,12,8),'YYYY-MM-DD HH24:MI:SS')); -- Normal Return
    exception
      when others then
        lics_inbound_utility.add_exception(l_message_prefix||' Invalid Date : Expected Format [YYYY-MM-DDTHH00:00:00Z]');
        p_on_error := true;
        return null; -- Error Return
    end;

  exception
    when others then
      raise_application_error(-20000, substr(l_message_prefix||' : '||SQLERRM, 1, 4000));

  end get_date;

  /*****************************************************************************
  ** PUBLIC Function : Get Validated Time
  *****************************************************************************/
  function get_time(p_column_name in varchar2, p_is_nullable in boolean, p_on_error in out boolean) return date as

    l_value varchar2(4000 char);
    l_message_prefix varchar2(4000 char);

  begin

    -- Set Message Prefix
    l_message_prefix := '['||g_package_name||'.get_time] Field ['||p_column_name||']';

    -- Get Value as String
    l_value := get_string(p_column_name, 8, p_is_nullable, p_on_error);

    -- Add Value to Message Prefix
    l_message_prefix := l_message_prefix||' Value ['||l_value||']';

    -- Return if Null
    if l_value is null then
      return null; -- Null, No Need to Continue
    end if;

    -- Convert Datetime .. HH24:MI:SS .. 23:59:59 .. Default year to 0001 ..
    begin
      return to_date('0001-01-01 '||substr(l_value,1,8),'YYYY-MM-DD HH24:MI:SS'); -- Normal Return
    exception
      when others then
        lics_inbound_utility.add_exception(l_message_prefix||' Invalid Time : Expected Format [HH24:MI:SS]');
        p_on_error := true;
        return null; -- Error Return
    end;

  exception
    when others then
      raise_application_error(-20000, substr(l_message_prefix||' : '||SQLERRM, 1, 4000));

  end get_time;

end qu3_util;
/

-- Synonyms
create or replace public synonym qu3_util for ods_app.qu3_util;

-- Grants
grant execute on ods_app.qu3_util to lics_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
