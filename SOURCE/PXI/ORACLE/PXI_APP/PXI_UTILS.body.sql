create or replace 
package body pxi_utils is

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXI_UTILS';

/*******************************************************************************
  NAME:  LOOKUP_TDU_FROM_ZREP                                             PUBLIC
*******************************************************************************/
  function lookup_tdu_from_zrep (
    i_sales_org in pxi_common.st_company,
    i_zrep_matl_code in pxi_common.st_material,
    i_buy_start_date in date,
    i_buy_end_date in date
    ) return pxi_common.st_material is
    -- Cursor to find the TDU. 
    cursor csr_zrep_tdu is
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
        and t01.sales_organisation = i_sales_org
        and t01.zrep_material_code = pxi_common.full_matl_code(i_zrep_matl_code)
        and not (i_buy_end_date < start_date or i_buy_start_date > end_date)
      order by start_date desc;
    rv_zrep_tdu csr_zrep_tdu%rowtype;
    v_result pxi_common.st_material;
  begin
    -- Set the initial result.
    v_result := null;
    -- Perform the material determination lookup
    open csr_zrep_tdu;
    fetch csr_zrep_tdu into rv_zrep_tdu;
    if csr_zrep_tdu%found = true then
      v_result  := rv_zrep_tdu.tdu_material_code;
    end if;
    close csr_zrep_tdu;
    -- Return the result. 
    return v_result;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'LOOKUP_TDU_FROM_ZREP');
  end lookup_tdu_from_zrep;

/*******************************************************************************
  NAME:  DETERMINE_BUS_SGMNT                                              PUBLIC
*******************************************************************************/
  function determine_bus_sgmnt (
    i_sales_org in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_zrep_matl_code in pxi_common.st_material) return pxi_common.st_bus_sgmnt is 
    c_method_name constant pxi_common.st_method_name := 'DETERMINE_BUS_SGMNT';
    cursor csr_bus_sgmnt is 
      select sap_bus_sgmnt_code 
      from bds_material_classfctn 
      where sap_material_code = pxi_common.full_matl_code(i_zrep_matl_code);
    v_result pxi_common.st_bus_sgmnt; 
  begin
    -- Initialise the result. 
    v_result := null;
    if i_sales_org = pxi_common.gc_new_zealand and i_promax_division = pxi_common.gc_new_zealand then
      -- Now lookup the business segment from the material. 
      open csr_bus_sgmnt;
      fetch csr_bus_sgmnt into v_result;
      close csr_bus_sgmnt;
    else
      if length(i_promax_division) > 2 then 
        pxi_common.raise_promax_error(pc_package_name,c_method_name,'Supplied Promax Division was meant to be less than 3 characters.  But was [' || i_promax_division || ']'); 
      else 
        v_result := i_promax_division;
      end if;
    end if;
    -- Now return the business segment.
    return v_result;
  exception
    when pxi_common.ge_promax_exception then
      raise; 
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,c_method_name); 
  end determine_bus_sgmnt;

/*******************************************************************************
  NAME:  determine_dstrbtn_chnnl                                              PUBLIC
*******************************************************************************/
  function determine_dstrbtn_chnnl (
    i_sales_org in pxi_common.st_company, 
    i_matl_code in pxi_common.st_material, 
    i_cust_code IN pxi_common.st_customer
    ) return pxi_common.st_dstrbtn_chnnl is
    
    CURSOR csr_distn_chnl IS
      SELECT
        a.DSTRBTN_CHANNEL
      from
        bds_material_dstrbtn_chain a,
        bds_cust_sales_area b
      where a.sap_material_code = pxi_common.full_matl_code(i_matl_code)
        and b.customer_code = pxi_common.full_cust_code(i_cust_code)
        and a.SALES_ORGANISATION = b.sales_org_code
        and a.SALES_ORGANISATION = i_sales_org 
        and a.DSTRBTN_CHANNEL = b.DISTBN_CHNL_CODE;
      rv_distn_chnl csr_distn_chnl%rowtype;
    
    v_result pxi_common.st_dstrbtn_chnnl;
  BEGIN
    -- Initialise Result Variable
    v_result := null;
    -- Open csr_distn_chnl cursor.
    OPEN csr_distn_chnl;
    LOOP
      FETCH csr_distn_chnl INTO rv_distn_chnl;
      EXIT WHEN csr_distn_chnl%NOTFOUND;
  
      -- There can be multiple records for a matl_code and cust_code, return 10 if
      -- it is a valid value for the matl_code and cust_code, otherwise return
      -- another of the matl_code and cust_code's valid values.
      if rv_distn_chnl.dstrbtn_channel = pxi_common.gc_distrbtn_channel_primary then
        v_result := pxi_common.gc_distrbtn_channel_primary;
      ELSIF rv_distn_chnl.DSTRBTN_CHANNEL != pxi_common.gc_distrbtn_channel_primary AND v_result is null THEN
        v_result := rv_distn_chnl.DSTRBTN_CHANNEL;
      END IF;
    END LOOP;
    close csr_distn_chnl;
    -- Now return the resulting distribution channel.
    return v_result;
  exception
      when others then 
        pxi_common.reraise_promax_exception(pc_package_name,'DETERMINE_DSTRBTN_CHNNL'); 
  END determine_dstrbtn_chnnl;


/*******************************************************************************
  NAME:  DETERMINE_MATL_PLANT_CODE                                        PUBLIC
*******************************************************************************/
  function determine_matl_plant_code (
    i_company_code IN pxi_common.st_company,
    i_matl_code in pxi_common.st_material)
    return pxi_common.st_plant_code is 
    c_method_name constant pxi_common.st_method_name := 'DETERMINE_MATL_PLANT_CODE';

    v_cmpny_prefix pxi_common.st_company;
  
    -- CURSOR DECLARATIONS
    CURSOR csr_matl_plant IS
      select
        t1.plant_code
      from
        bds_material_plant_hdr t1
      where
        t1.sap_material_code = pxi_common.full_matl_code(i_matl_code)
        and substr(t1.plant_code, 1, 2) = v_cmpny_prefix
        and t1.plant_code != 'AU10' -- Note: No sales occur from this plant.
      order by t1.plant_code; 
      v_result pxi_common.st_plant_code;
  begin
    -- Initialise the result.
    v_result := null;
    -- Set the plant prefix based on Company Code.
    IF i_company_code = pxi_common.gc_australia THEN
      v_cmpny_prefix :='AU';
    ELSIF i_company_code = pxi_common.gc_new_zealand THEN
      v_cmpny_prefix :='NZ';
    else
      pxi_common.raise_promax_error(pc_package_name,c_method_name,'Invalid Company Code. Valid Company Code values include ''147'' and ''149''.');
    END IF;
  
    -- Fetch the plant code.
    OPEN csr_matl_plant;
    FETCH csr_matl_plant INTO v_result;
    close csr_matl_plant;

    -- Now Return the plant code.
    return v_result;
  exception
    when pxi_common.ge_promax_exception then 
      raise;
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,c_method_name); 
  END determine_matl_plant_code;

/*******************************************************************************
  NAME:  DETERMINE_TAX_CODE_FROM_REASON                                   PUBLIC
*******************************************************************************/
  function determine_tax_code_from_reason(i_reason_code in pxi_common.st_reason_code) 
    return pxi_common.st_tax_code is
    v_result pxi_common.st_tax_code; 
  begin
    case i_reason_code
      when '40' then 
        v_result := 'S3'; 
      when '41' then 
        v_result := 'S1'; 
      when '42' then 
        v_result := 'S3'; 
      when '43' then 
        v_result := 'S1';
      when '44' then 
        v_result := 'S3';
      when '45' then 
        v_result := 'S1'; 
      when '51' then 
        v_result := 'S2'; 
      when '53' then 
        v_result := 'S2'; 
      when '55' then 
        v_result := 'S2';
      else 
        v_result := null;
    end case;
    return v_result;
  exception
     when others then 
       pxi_common.reraise_promax_exception(pc_package_name,'DETERMINE_TAX_CODE_FROM_REASON'); 
  end determine_tax_code_from_reason;

/*******************************************************************************
********************************************************************************
  CODE BELOW HERE STILL NEEDS TO BE REFORMATTED AND TIDIED UP.
********************************************************************************
*******************************************************************************/


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
end pxi_utils;
/
