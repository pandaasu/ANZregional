create or replace 
package body pxi_common is

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant st_package_name := 'PXI_COMMON';
  pc_promax_exception pls_integer := -20000;

/*******************************************************************************
  NAME:  HELPER FUNCTIONS - Functions to Return Package Constants         PUBLIC
*******************************************************************************/

  -- Company Constants / Sales Org Constants
  function fc_new_zealand return st_company is begin return gc_new_zealand; end fc_new_zealand;
  function fc_australia return st_company is begin return gc_australia; end fc_australia;

  -- Business Segment / Material Division Constants
  function fc_bus_sgmnt_snack return st_bus_sgmnt is begin return gc_bus_sgmnt_snack; end fc_bus_sgmnt_snack;
  function fc_bus_sgmnt_food return st_bus_sgmnt is begin return gc_bus_sgmnt_food; end fc_bus_sgmnt_food;
  function fc_bus_sgmnt_petcare return st_bus_sgmnt is begin return gc_bus_sgmnt_petcare; end fc_bus_sgmnt_petcare;

  -- Customer Divivision Constants
  function fc_cust_division_non_specific return st_cust_division is begin return gc_cust_division_non_specific; end fc_cust_division_non_specific;
  function fc_cust_division_food return st_cust_division is begin return gc_cust_division_food; end fc_cust_division_food;
  function fc_cust_division_snack return st_cust_division is begin return gc_cust_division_snack; end fc_cust_division_snack;
  function fc_cust_division_petcare return st_cust_division is begin return gc_cust_division_petcare; end fc_cust_division_petcare;

  -- Segment MOE Codes
  function fc_moe_nz return st_moe_code is begin return gc_moe_nz; end fc_moe_nz;
  function fc_moe_pet return st_moe_code is begin return gc_moe_pet; end fc_moe_pet;
  function fc_moe_food return st_moe_code is begin return gc_moe_food; end fc_moe_food;
  function fc_moe_snack return st_moe_code is begin return gc_moe_snack; end fc_moe_snack;

  -- Interface Sufix's
  function fc_interface_snack return fflu_common.st_interface is begin return gc_interface_snack; end fc_interface_snack;
  function fc_interface_food return fflu_common.st_interface is begin return gc_interface_food; end fc_interface_food;
  function fc_interface_pet return fflu_common.st_interface is begin return gc_interface_pet; end fc_interface_pet;
  function fc_interface_nz return fflu_common.st_interface is begin return gc_interface_nz; end fc_interface_nz;

  -- Distribution Channel
  function fc_distrbtn_channel_primary return st_dstrbtn_chnnl is begin return gc_distrbtn_channel_primary; end fc_distrbtn_channel_primary;

  -- Tax Codes
  function fc_tax_code_gl return st_tax_code is begin return gc_tax_code_gl; end fc_tax_code_gl;
  function fc_tax_code_s1 return st_tax_code is begin return gc_tax_code_s1; end fc_tax_code_s1;
  function fc_tax_code_s2 return st_tax_code is begin return gc_tax_code_s2; end fc_tax_code_s2;
  function fc_tax_code_s3 return st_tax_code is begin return gc_tax_code_s3; end fc_tax_code_s3;
  function fc_tax_code_se return st_tax_code is begin return gc_tax_code_se; end fc_tax_code_se;

  -- Maximum rows per idoc output.
  function fc_max_idoc_rows return pls_integer is begin return gc_max_idoc_rows; end fc_max_idoc_rows;

  -- Constants used in formatting functions

  -- Null / Not Null
  function fc_is_nullable return number is begin return gc_is_nullable; end;
  function fc_is_not_nullable return number is begin return gc_is_not_nullable; end;

  -- Format Type
  function fc_format_type_none return number is begin return gc_format_type_none; end;
  function fc_format_type_trim return number is begin return gc_format_type_trim; end;
  function fc_format_type_ltrim return number is begin return gc_format_type_ltrim; end;
  function fc_format_type_rtrim return number is begin return gc_format_type_rtrim; end;
  function fc_format_type_ltrim_zeros return number is begin return gc_format_type_ltrim_zeros; end;

/*******************************************************************************
  NAME:  RERAISE_PROMAX_EXCEPTION                                         PUBLIC
*******************************************************************************/
  procedure reraise_promax_exception(
    i_package_name in st_package_name,
    i_method in st_method_name
  ) is
  begin
    raise_application_error(pc_promax_exception,substr(upper(i_package_name) || '.' || upper(i_method) || ' - ' || SQLERRM,1,4000));
  end reraise_promax_exception;

/*******************************************************************************
  NAME:  RAISE_PROMAX_EXCEPTION                                           PUBLIC
*******************************************************************************/
  procedure raise_promax_error(
    i_package_name in st_package_name,
    i_method in st_method_name,
    i_message in st_string) is
  begin
    raise_application_error(pc_promax_exception,substr(upper(i_package_name) || '.' || upper(i_method) || ' - ' || i_message,1,4000));
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
  NAME:  CHAR_FORMAT                                                      PUBLIC
*******************************************************************************/
  function char_format(
    i_value in varchar2,
    i_length in number,
    i_format_type in number,
    i_value_is_nullable in number) return varchar2 is
    c_method_name constant st_method_name := 'CHAR_FORMAT';
    v_value st_data;
  begin
    if i_length is null then
      raise_promax_error(pc_package_name,c_method_name,'Length CANNOT be NULL');
    end if;

    if i_format_type is null then
      raise_promax_error(pc_package_name,c_method_name,'Format Type CANNOT be NULL');
    end if;

    if i_value_is_nullable is null then
      raise_promax_error(pc_package_name,c_method_name,'Value Is Nullable CANNOT be NULL');
    end if;

    if i_value is null then
      if i_value_is_nullable = fc_is_nullable then
        return rpad(' ', i_length,' '); -- return empty string of correct length
      else
        raise_promax_error(pc_package_name,c_method_name,'Value CANNOT be NULL');
      end if;
    end if;

    case i_format_type
      when fc_format_type_none then
        v_value := i_value;
      when fc_format_type_trim then
        v_value := trim(i_value);
      when fc_format_type_ltrim then
        v_value := ltrim(i_value);
      when fc_format_type_rtrim then
        v_value := rtrim(i_value);
      when fc_format_type_ltrim_zeros then
        v_value := ltrim(i_value, '0');
      else
        raise_promax_error(pc_package_name,c_method_name,'Invalid Format Type ['||i_format_type||']');
    end case;

    -- Substitute "?" for non-single-btye-characters
    if length(v_value) != lengthb(v_value) then
      for v_position in 1..length(v_value)
      loop
        if length(substr(v_value, v_position, 1)) != lengthb(substr(v_value, v_position, 1)) then
          v_value := replace(v_value, substr(v_value, v_position, 1), '?');
        end if;
      end loop;
    end if;

    if length(v_value) > i_length then
      raise_promax_error(pc_package_name,c_method_name,'Value ['||v_value||'] Length ['||length(v_value)||'] Greater Than Length Provided ['||i_length||']');
    else
      return rpad(v_value, i_length, ' ');
    end if;

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end char_format;

/*******************************************************************************
  NAME:  NUMB_FORMAT                                                      PUBLIC
*******************************************************************************/
  function numb_format(
    i_value in number,
    i_format in varchar2,
    i_value_is_nullable in number) return varchar2 is
    c_method_name constant st_method_name := 'NUMB_FORMAT';
    v_value varchar2(128 char);
  begin
    if i_format is null then
      raise_promax_error(pc_package_name,c_method_name,'Format CANNOT be NULL');
    end if;

    if i_value_is_nullable is null then
      raise_promax_error(pc_package_name,c_method_name,'Value Is Nullable CANNOT be NULL');
    end if;

    if i_value is null then
      if i_value_is_nullable = fc_is_nullable then
        return rpad(' ', length(i_format)); -- return empty string of correct length
      else
        raise_promax_error(pc_package_name,c_method_name,'Value CANNOT be NULL');
      end if;
    elsif i_value < 0 and upper(substr(i_format,1,1)) != 'S' then
      raise_promax_error(pc_package_name,c_method_name,'Value ['||i_value||'] CANNOT be Negative, without Format ['||i_format||'] Including S Prefix');
    end if;

    begin
      v_value := trim(to_char(i_value, i_format));
    exception
      when others then
        raise_promax_error(pc_package_name,c_method_name,substr('Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
    end;

    if instr(v_value, '#') > 0 then
      raise_promax_error(pc_package_name,c_method_name,'Format ['||i_format||'] on Value ['||i_value||']');
    end if;

    if upper(substr(i_format,1,1)) = 'S' then
      v_value := replace(v_value, '+', ' ');
    end if;

    if length(v_value) > length(i_format) then
      raise_promax_error(pc_package_name,c_method_name,'Format Length ['||i_format||']['||length(i_format)||'] < Value Length ['||i_value||']['||length(v_value)||']');
    end if;

    return lpad(v_value, length(i_format));

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end numb_format;

/*******************************************************************************
  NAME:  DATE_FORMAT                                                      PUBLIC
*******************************************************************************/
  function date_format(
    i_value in date,
    i_format in varchar2,
    i_value_is_nullable in number) return varchar2 is
    c_method_name constant st_method_name := 'DATE_FORMAT';
  begin

    if i_format is null then
      raise_promax_error(pc_package_name,c_method_name,'Format CANNOT be NULL');
    end if;

    if i_value_is_nullable is null then
        raise_promax_error(pc_package_name,c_method_name,'Value Is Nullable CANNOT be NULL');
    end if;

    if i_value is null then
      if i_value_is_nullable = fc_is_nullable then
        return rpad(' ',length(i_format)); -- return empty string of correct length
      else
        raise_promax_error(pc_package_name,c_method_name,'Value CANNOT be NULL');
      end if;
    end if;

    begin
      return to_char(i_value, i_format);
    exception
      when others then
        raise_promax_error(pc_package_name,c_method_name,substr('Format ['||i_format||'] on Value ['||i_value||'] Failed : '||SQLERRM, 1, 4000));
    end;

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end date_format;

/*******************************************************************************
  NAME:  PROMAX_CONFIG                                                    PUBLIC
*******************************************************************************/
  function promax_config(
    i_promax_company in st_company default null,
    i_promax_division in st_promax_division default null
    ) return tt_promax_config pipelined is
    c_method_name constant st_method_name := 'PROMAX_CONFIG';
    c_live constant boolean := true;
    c_not_live constant boolean := false;
    rv_row rt_promax_config;

    function add_row(i_live in boolean) return boolean is
      v_result boolean;
    begin
      v_result := false;
      -- Check if both records have been supplied in which case return then even if not yet live.
      if i_promax_company is not null and i_promax_division is not null then
        if rv_row.promax_company = i_promax_company and rv_row.promax_division = i_promax_division then
          v_result := true;
        end if;
      else
        -- Only include rows that are live from this point onwards.
        if i_live = true then
          if i_promax_company is null and i_promax_division is null then
            v_result := true;
          else
            if i_promax_company is null and rv_row.promax_division = i_promax_division then
              v_result := true;
            end if;
            if i_promax_division is null and rv_row.promax_company = i_promax_company then
              v_result := true;
            end if;
          end if;
        end if;
      end if;
      return v_result;
    end add_row;

  begin
    -- Now add new zealand data as necessary.
    rv_row.promax_company := gc_new_zealand;
    rv_row.promax_division := gc_new_zealand;
    rv_row.cust_division := gc_cust_division_non_specific;
    rv_row.interface_suffix := gc_interface_nz;
    if add_row(c_live) = true then
      pipe row(rv_row);
    end if;

    -- Add Australia Petcare Configuration
    rv_row.promax_company := gc_australia;
    rv_row.promax_division := gc_bus_sgmnt_petcare;
    rv_row.cust_division := gc_cust_division_petcare;
    rv_row.interface_suffix := gc_interface_pet;
    if add_row(c_live) = true then
      pipe row(rv_row);
    end if;

    -- Add Australia Food Configuration
    rv_row.promax_company := gc_australia;
    rv_row.promax_division := gc_bus_sgmnt_food;
    rv_row.cust_division := gc_cust_division_food;
    rv_row.interface_suffix := gc_interface_food;
    if add_row(c_not_live) = true then
      pipe row(rv_row);
    end if;

    -- Add Australia Snackfood Configuration
    rv_row.promax_company := gc_australia;
    rv_row.promax_division := gc_bus_sgmnt_snack;
    rv_row.cust_division := gc_cust_division_snack;
    rv_row.interface_suffix := gc_interface_snack;
    if add_row(c_not_live) = true then
      pipe row(rv_row);
    end if;

  exception
    -- Where the calling function has found all the rows it needs this exception may be raised.  Ignore at this point.
    when no_data_needed then 
      null;
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end promax_config;

/*******************************************************************************
  NAME:  PROMAX_INTERFACE_SUFFIX                                          PUBLIC
*******************************************************************************/
  function promax_interface_suffix(
    i_promax_company in st_company,
    i_promax_division in st_promax_division -- ~ Material Business Segment
    ) return fflu_common.st_interface is
    c_method_name constant st_method_name := 'PROMAX_INTERFACE_SUFFIX';
  begin

    case i_promax_company
      when gc_australia then
        case i_promax_division
          when gc_bus_sgmnt_snack then return gc_interface_snack;
          when gc_bus_sgmnt_food then return gc_interface_food;
          when gc_bus_sgmnt_petcare then return gc_interface_pet;
          else raise_promax_error(pc_package_name,c_method_name,'Unknown Promax [Company:Division] Combination ['||i_promax_company||':'||i_promax_division||'].');
        end case;
      when gc_new_zealand then
        case i_promax_division
          when gc_new_zealand then return gc_interface_nz;
          else raise_promax_error(pc_package_name,c_method_name,'Unknown Promax [Company:Division] Combination ['||i_promax_company||':'||i_promax_division||'].');
        end case;
      else raise_promax_error(pc_package_name,c_method_name,'Unknown Promax [Company:Division] Combination ['||i_promax_company||':'||i_promax_division||'].');
    end case;

  exception
    when ge_promax_exception then
      raise;
    when others then
      reraise_promax_exception(pc_package_name,c_method_name);
  end promax_interface_suffix;

end pxi_common;
