create or replace package body pxi_common is
--------------------------------------------------------------------------------
  -- Private : Application Exception
  pv_application_exception exception;
  pragma exception_init(pv_application_exception, -20000);
  
  -- Private : Constants
  pv_package_name constant varchar2(30 char) := 'pmi_common';
  
  --                               0        1         2         3         4         5         6         7         8         9         10          
  --                               1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
  pv_spaces varchar2(100 char) := '                                                                                                    ';
--------------------------------------------------------------------------------
function is_nullable return number is begin return 1; end;
function is_not_nullable return number is begin return 0; end;
--------------------------------------------------------------------------------
function format_type_none return number is begin return 0; end;
function format_type_trim return number is begin return 1; end;
function format_type_ltrim return number is begin return 2; end;
function format_type_rtrim return number is begin return 3; end;
function format_type_ltrim_zeros return number is begin return 4; end;
--------------------------------------------------------------------------------
function char_format(i_value in varchar2, i_length in number, i_format_type in number, i_value_is_nullable in number) return varchar2 is

  v_value varchar2(4000 char);

begin

  if i_length is null then
      raise_application_error(-20000, 'Length CANNOT be NULL');
  end if;
  
  if i_format_type is null then
      raise_application_error(-20000, 'Format Type CANNOT be NULL');
  end if;

  if i_value_is_nullable is null then
      raise_application_error(-20000, 'Value Is Nullable CANNOT be NULL');
  end if;
  
  if i_value is null then
    if i_value_is_nullable = pxi_common.is_nullable then
      return substr(pv_spaces, 1, i_length); -- return empty string of correct length
    else 
      raise_application_error(-20000, 'Value CANNOT be NULL');
    end if;
  end if;
  
  case i_format_type
    when format_type_none then
      v_value := i_value;
    when format_type_trim then
      v_value := trim(i_value);
    when format_type_ltrim then
      v_value := ltrim(i_value);
    when format_type_rtrim then
      v_value := rtrim(i_value);
    when format_type_ltrim_zeros then
      v_value := ltrim(i_value, '0');
    else
      raise_application_error(-20000, 'Invalid Format Type ['||i_format_type||']');
  end case;

  if length(v_value) > i_length then
      raise_application_error(-20000, 'Value ['||v_value||'] Length ['||length(v_value)||'] Greater Than Length Provided ['||i_length||']');
  else
    return rpad(v_value, i_length, ' ');
  end if;
  
exception
  when others then
    raise_application_error(-20000, substr('['||pv_package_name||'.char_format] : '||SQLERRM, 1, 4000));

end char_format;
--------------------------------------------------------------------------------
function numb_format(i_value in number, i_format in varchar2, i_value_is_nullable in number) return varchar2 is

  v_value varchar2(128 char);

begin

  if i_format is null then
      raise_application_error(-20000, 'Format CANNOT be NULL');
  end if;

  if i_value_is_nullable is null then
      raise_application_error(-20000, 'Value Is Nullable CANNOT be NULL');
  end if;
  
  if i_value is null then
    if i_value_is_nullable = pxi_common.is_nullable then
      return substr(pv_spaces, 1, length(i_format)); -- return empty string of correct length
    else 
      raise_application_error(-20000, 'Value CANNOT be NULL');
    end if;
  end if;

  begin
    v_value := to_char(i_value, i_format);
  exception
    when others then
      raise_application_error(-20000, substr('Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
  end;
  
  if instr(v_value, '#') > 0 then
      raise_application_error(-20000, substr('Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
  end if;
  
  return replace(v_value, '+', ' ');
  
exception
  when others then
    raise_application_error(-20000, substr('['||pv_package_name||'.numb_format] : '||SQLERRM, 1, 4000));

end numb_format;
--------------------------------------------------------------------------------
function date_format(i_value in date, i_format in varchar2, i_value_is_nullable in number) return varchar2 is

begin

  if i_format is null then
      raise_application_error(-20000, 'Format CANNOT be NULL');
  end if;
  
  if i_value_is_nullable is null then
      raise_application_error(-20000, 'Value Is Nullable CANNOT be NULL');
  end if;

  if i_value is null then
    if i_value_is_nullable = pxi_common.is_nullable then
      return substr(pv_spaces, 1, length(i_format)); -- return empty string of correct length
    else 
      raise_application_error(-20000, 'Value CANNOT be NULL');
    end if;
  end if;

  begin
    return to_char(i_value, i_format);
  exception
    when others then
      raise_application_error(-20000, substr('Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
  end;
  
exception
  when others then
    raise_application_error(-20000, substr('['||pv_package_name||'.date_format] : '||SQLERRM, 1, 4000));

end date_format;
--------------------------------------------------------------------------------
end pxi_common;
/
