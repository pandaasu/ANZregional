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



FUNCTION format_cust_code (
  i_cust_code IN VARCHAR2,
  o_cust_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS.
  v_cust_code  VARCHAR2(10);
  v_first_char VARCHAR2(1);

BEGIN
  -- Trim the inputted Customer Code.
  v_cust_code := RTRIM(i_cust_code);

  -- Return zero's if Customer Code is null.
  IF v_cust_code IS NULL THEN
    -- Return the value.
    o_cust_code := '0000000000';
  END IF;

  -- Check whether the first character is a number.  If so, then left pad with zero's to
  -- ten characters.  Otherwise right pad with spaces to ten characters.
  v_first_char := SUBSTR(v_cust_code,1,1);
  IF v_first_char >= '0' AND v_first_char <= '9' THEN
    o_cust_code := LPAD(v_cust_code,10,'0');
  ELSE
    o_cust_code := RPAD(v_cust_code,10,' ');
  END IF;

  -- Now return a successful status.
 RETURN 0; --constants.success;

/*EXCEPTION
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_error_msg('PDS_COMMON.FORMAT_CUST_CODE:',
        'Unable to perform function.') ||
      utils.create_params_str('Customer Code',i_cust_code) ||
      utils.create_sql_err_msg();
    RETURN constants.error;*/
END format_cust_code;


FUNCTION format_pmx_cust_code (
  i_cust_code IN VARCHAR2,
  o_pmx_cust_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS.
  v_pmx_cust_code  VARCHAR2(10);
  v_first_char VARCHAR2(1);

BEGIN
  -- Trim the inputted Customer Code.
  v_pmx_cust_code := LTRIM(TRIM(i_cust_code),'0');

  -- Return zero's if Customer Code is null.
  IF v_pmx_cust_code IS NULL THEN
    -- Return the value.
    o_pmx_cust_code := NULL;
  END IF;

  -- Right trim any spaces from the end of the Pmx Customer Code.
  o_pmx_cust_code := RTRIM(v_pmx_cust_code,' ');

  -- Now return a successful status.
  RETURN 0; --constants.success;
/*
EXCEPTION
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_error_msg('PDS_COMMON.FORMAT_PMX_CUST_CODE:',
        'Unable to perform function.') ||
      utils.create_params_str('Customer Code',i_cust_code) ||
      utils.create_sql_err_msg();
    RETURN constants.error;*/
END format_pmx_cust_code;


FUNCTION format_matl_code (
  i_matl_code IN VARCHAR2,
  o_matl_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS.
  v_matl_code VARCHAR2(18);
  v_firstchar CHAR(1);

BEGIN
  -- Trim the inputted Material Code.
  v_matl_code := LTRIM(i_matl_code);

  -- Return zeros if Material Code is null.
  IF v_matl_code IS NULL THEN
    v_matl_code := '000000000000000000';
  END IF;

  -- Check whether the first character is a number. If so, then left pad with zero's to
  -- eighteen characters. Otherwise right pad with white spaces to eighteen characters.
  v_firstchar := SUBSTR(v_matl_code,1,1);
  IF v_firstchar >= '0' AND v_firstchar <= '9' THEN
    o_matl_code := LPAD(v_matl_code,18,'0');
  ELSE
    o_matl_code := RPAD(v_matl_code,18,' ');
  END IF;

  -- Now return a successful status.
  RETURN 0; --constants.success;
/*
EXCEPTION
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_error_msg('PDS_COMMON.FORMAT_MATL_CODE:',
        'Unable to perform function.') ||
      utils.create_params_str('Material Code',i_matl_code) ||
      utils.create_sql_err_msg();
    RETURN constants.error;*/
END format_matl_code;


FUNCTION format_pmx_matl_code (
  i_matl_code IN VARCHAR2,
  o_matl_code OUT VARCHAR2
  --i_log_level IN NUMBER,
  --o_result_msg OUT VARCHAR2
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS.
  v_matl_code VARCHAR2(18);
  v_firstchar CHAR(1);

BEGIN
  -- Trim the inputted Material Code.
  v_matl_code := LTRIM(TRIM(i_matl_code), '0');
  o_matl_code := v_matl_code;

  -- Now return a successful status.
  RETURN constants.success;
/*
EXCEPTION
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_error_msg('PDS_COMMON.FORMAT_PMX_MATL_CODE:',
        'Unable to perform function.') ||
      utils.create_params_str('Material Code',i_matl_code) ||
      utils.create_sql_err_msg();
    RETURN constants.error;*/
END format_pmx_matl_code;



function lookup_matl_tdu_num (
    i_matl_zrep_code    in  varchar2,
    o_matl_tdu_code     out varchar2,
    i_buy_start_date    in  date,
    i_buy_end_date      in  date
  ) return number is

    -- VARIABLE DECLARATIONS.
    v_result          number;
    v_matl_zrep_code  varchar2(18);
    v_matl_tdu_code   varchar2(18);
      
      
    /*-*/ 
    /* Lookup Current User
    /*-*/   
    cursor csr_matl_tdu is
        select 
            sales_organisation,
            dstrbtn_channel,
            sold_to_code,
            zrep_material_code,
            start_date,
            end_date,
            tdu_material_code
        from
            bds_refrnc_material_zrep t01,
            bds_refrnc_material_tdu t02
        where 
            t01.condition_record_no = t02.condition_record_no
            and t01.material_dtrmntn_type = 'Z001'
            and t01.sales_organisation = '149'
            and t01.zrep_material_code = v_matl_zrep_code 
            and not (i_buy_end_date < start_date or i_buy_start_date > end_date)
            order by start_date desc;
    rcd_matl_tdu csr_matl_tdu%rowtype;

BEGIN
  
    -- Format the ZREP Code  
    v_result := format_matl_code(i_matl_zrep_code, v_matl_zrep_code);

    /*-*/
    /* Obtain the TDU number
    /*-*/
    open csr_matl_tdu;
    fetch csr_matl_tdu into rcd_matl_tdu;
    if csr_matl_tdu%notfound then
       -- No result
       o_matl_tdu_code := 0;
    else
       o_matl_tdu_code := rcd_matl_tdu.tdu_material_code;
    end if;
    close csr_matl_tdu;


  -- Now return a successful status.
  return 0; 

end lookup_matl_tdu_num;


function lookup_distbn_chnl_code (
    i_cust_code         in  varchar2,
    o_distbn_chnl_code     out varchar2
  ) return number is

    -- VARIABLE DECLARATIONS.
    v_result     number;
    v_cust_code  varchar2(18);
      
      
    /*-*/ 
    /* Lookup Current User
    /*-*/   
    cursor csr_distbn_chnl is
        select 
            customer_code, 
            distbn_chnl_code
        from 
            bds_cust_sales_area t01
        where 
            t01.customer_code = i_cust_code;
    rcd_distbn_chnl csr_distbn_chnl%rowtype;

BEGIN
  
    -- Format the ZREP Code  
    v_result := format_cust_code(i_cust_code, v_cust_code);

    /*-*/
    /* Obtain the TDU number
    /*-*/
    open csr_distbn_chnl;
    fetch csr_distbn_chnl into rcd_distbn_chnl;
    if csr_distbn_chnl%notfound then
       -- No result
       o_distbn_chnl_code := 10;
    else
       o_distbn_chnl_code := rcd_distbn_chnl.distbn_chnl_code;
    end if;
    close csr_distbn_chnl;


  -- Now return a successful status.
  return 0; 

end lookup_distbn_chnl_code;


function lookup_division_code (
    i_matl_tdu_code     in  varchar2,
    o_division_code     out varchar2
  ) return number is

    -- VARIABLE DECLARATIONS.
    v_result          number;
    v_matl_tdu_code  varchar2(18);
      
      
    /*-*/ 
    /* Lookup Current User
    /*-*/   
    cursor csr_matl_division is
        select 
            sap_material_code,
            material_division
        from
            bds_material_hdr t01
        where
            t01.sap_material_code = v_matl_tdu_code;
    rcd_matl_division csr_matl_division%rowtype;

BEGIN
  
    -- Format the TDU Code  
    v_result := format_matl_code(i_matl_tdu_code, v_matl_tdu_code);

    /*-*/
    /* Obtain the Division number
    /*-*/
    open csr_matl_division;
    fetch csr_matl_division into rcd_matl_division;
    if csr_matl_division%notfound then
       -- No result
       o_division_code := 0;
    else
       o_division_code := rcd_matl_division.material_division;
    end if;
    close csr_matl_division;


  -- Now return a successful status.
  return 0; 

end lookup_division_code;


function lookup_plant_code (
    i_matl_tdu_code     in  varchar2,
    o_plant_code        out varchar2
  ) return number is

    -- VARIABLE DECLARATIONS.
    v_result          number;
    v_matl_tdu_code  varchar2(18);
      
      
    /*-*/ 
    /* Lookup Current User
    /*-*/   
    cursor csr_matl_plant is
        select 
            sap_material_code,
            plant_code 
        from
            bds_material_plant_hdr t01
        where
            t01.sap_material_code = v_matl_tdu_code
            AND t01.plant_code != 'AU10' -- Note: No sales occur from this plant.
            AND SUBSTR(t01.plant_code, 1, 2) = 'NZ'
        order by 
            t01.plant_specific_status_valid desc;
    rcd_matl_plant csr_matl_plant%rowtype;

BEGIN
  
    -- Format the TDU Code  
    v_result := format_matl_code(i_matl_tdu_code, v_matl_tdu_code);

    /*-*/
    /* Obtain the Division number
    /*-*/
    open csr_matl_plant;
    fetch csr_matl_plant into rcd_matl_plant;
    if csr_matl_plant%notfound then
       -- No result
       o_plant_code := 'NZ01';
    else
       o_plant_code := rcd_matl_plant.plant_code;
    end if;
    close csr_matl_plant;


  -- Now return a successful status.
  return 0; 

end lookup_plant_code;

--------------------------------------------------------------------------------
end pxi_common;
/
