create or replace 
package body pxi_common is

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant st_package_name := 'PXI_COMMON';

/*******************************************************************************
  NAME:  RERAISE_PROMAX_EXCEPTION                                         PUBLIC
*******************************************************************************/
  procedure reraise_promax_exception(
    i_package_name in st_package_name,
    i_method in st_string
  ) is
  begin
    raise_application_error(gc_application_exception,substr(upper(i_package_name) || '.' || upper(i_method) || ' - ' || SQLERRM,1,4000));
  end reraise_promax_exception;
  
/*******************************************************************************
  NAME:  RAISE_PROMAX_EXCEPTION                                           PUBLIC
*******************************************************************************/
  procedure raise_promax_error(
    i_package_name in st_package_name,
    i_method in st_string, 
    i_message in st_string) is
  begin
    raise_application_error(gc_application_exception,substr(upper(i_package_name) || '.' || upper(i_method) || ' - ' || i_message,1,4000));
  end raise_promax_error;

/*******************************************************************************
  NAME:  FULL_MATL_CODE                                                   PUBLIC
*******************************************************************************/
  function full_matl_code (i_matl_code in st_material) return st_material is
    v_result st_material;
    v_firstchar st_material;
  begin
    -- Trim the inputted Material Code.
    v_result := ltrim(i_matl_code);
  
    -- Return zero if Material Code is null.
    if v_result is null then
      v_result := '0';
    end if;
  
    -- Check whether the first character is a number. If so, then left pad with zero's to
    -- eighteen characters. Otherwise right pad with white spaces to eighteen characters.
    v_firstchar := substr(v_result,1,1); 
    if v_firstchar >= '0' and v_firstchar <= '9' then
      v_result := lpad(v_result,18,'0');
    else
      v_result := rpad(v_result,18,' ');
    end if;
    return v_result;
  exception
    when others then 
      reraise_promax_exception(pc_package_name,'FULL_MATL_CODE');
  end full_matl_code;

/*******************************************************************************
  NAME:  SHORT_MATL_CODE                                                  PUBLIC
*******************************************************************************/
  function short_matl_code (i_matl_code in st_material) return st_material is
  begin
    return trim (ltrim (i_matl_code, '0') );
  exception 
    when others then 
      reraise_promax_exception(pc_package_name,'SHORT_MATL_CODE');
  end short_matl_code;

/*******************************************************************************
  NAME:  FULL_CUST_CODE                                                  PUBLIC
*******************************************************************************/
  function full_cust_code (i_cust_code in st_customer) return st_customer is
  begin
    return lpad(nvl(i_cust_code,'0'),10,'0');
  exception
    when others then 
      reraise_promax_exception(pc_package_name,'FULL_CUST_CODE');
  end full_cust_code;

/*******************************************************************************
  NAME:  FULL_VEND_CODE                                                   PUBLIC
*******************************************************************************/
  function full_vend_code (i_vendor_code in st_vendor) return st_vendor is
  begin
    return lpad(nvl(i_vendor_code,'0'),10,'0');
  exception
    when others then 
      reraise_promax_exception(pc_package_name,'FULL_VEND_CODE');
  end full_vend_code;

/*******************************************************************************
********************************************************************************
  CODE BELOW HERE STILL NEEDS TO BE REFORMATTED AND TIDIED UP.
********************************************************************************
*******************************************************************************/

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
      return rpad(' ', i_length,' '); -- return empty string of correct length
    else 
      raise_promax_error(pc_package_name,'char_format','Value CANNOT be NULL');
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
    raise_application_error(-20000, substr('['||pc_package_name||'.char_format] : '||SQLERRM, 1, 4000));
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
      return rpad(' ', length(i_format)); -- return empty string of correct length
    else
      raise_application_error(-20000, 'Value CANNOT be NULL');
    end if;
  elsif i_value < 0 and upper(substr(i_format,1,1)) != 'S' then
    raise_application_error(-20000, 'Value ['||i_value||'] CANNOT be Negative, without Format ['||i_format||'] Including S Prefix');
  end if;

  begin
    v_value := trim(to_char(i_value, i_format));
  exception
    when others then
      raise_application_error(-20000, substr('Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
  end;

  if instr(v_value, '#') > 0 then
      raise_application_error(-20000, 'Format ['||i_format||'] on Value ['||i_value||']');
  end if;

  if upper(substr(i_format,1,1)) = 'S' then
    v_value := replace(v_value, '+', ' ');
  end if;

  if length(v_value) > length(i_format) then
      raise_application_error(-20000, 'Format Length ['||i_format||']['||length(i_format)||'] < Value Length ['||i_value||']['||length(v_value)||']');
  end if;

  return lpad(v_value, length(i_format));

exception
  when others then
    raise_application_error(-20000, substr('['||pc_package_name||'.numb_format] : '||SQLERRM, 1, 4000));
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
      return rpad(' ',length(i_format)); -- return empty string of correct length
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
    raise_application_error(-20000, substr('['||pc_package_name||'.date_format] : '||SQLERRM, 1, 4000));

end date_format;


--------------------------------------------------------------------------------
end pxi_common;
/
