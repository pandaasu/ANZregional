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
--------------------------------------------------------------------------------
end pxi_utils;
/
