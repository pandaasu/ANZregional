prompt :: Compile Package [pxipmx03_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx03_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX03_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Customer Data - PX Interface 300 (New Zealand)

 Date          Author                Description
 ------------  --------------------  -----------
 2013-07-24    Chris Horn            Created.
 2013-07-26    Mal Chambeyron        Formatted SQL Output
 2013-07-30    Chris Horn            Added an additional order block check.
 2013-08-21    Chris Horn            Cleaned Up Code.
 2014-02-26    Mal Chambeyron        Pipeline, Simplify, Tune and
                                     REMOVE Customers NOT in Customer Hierarchy
 2014-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix
 2014-03-25    Mal Chambeyron        Add Hierarchy Nodes to Extract, reference [pxipmx04_extract_v2]
                                     Change Sales Org to [division_code] 
 2014-03-25    Mal Chambeyron        Added Division [promax_division] and Shipping Type [1] to Record   
                                     to address "Shipping type cannot be modified on an existing account." condition
                                     
*******************************************************************************/

  procedure execute(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  );

  ------------------------------------------------------------------------------
  -- pt_cust_list : Customer

  type rt_cust_list is record (
    promax_company varchar2(3 char),
    promax_division varchar2(3 char),
    sales_org_code varchar2(5 char),
    division_code varchar2(5 char),
    distbn_chnl_code varchar2(5 char),
    cust_code varchar2(10 char),
    cust_name varchar2(40 char),
    payer_cust_code varchar2(10 char),
    tax_classification_code varchar2(1 char),
    cust_header_order_block_flag varchar2(2 char),
    cust_header_deletion_flag varchar2(2 char),
    sales_area_order_block_flag varchar2(2 char),
    sales_area_deletion_flag varchar2(2 char),
    last_billing_yyyypp varchar2(6 char),
    in_cust_hier number(1,0),
    priority number(2,0)
  );

  type tt_cust_list is table of rt_cust_list;

  function pt_cust_list (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_list pipelined;

  ------------------------------------------------------------------------------
  -- pt_output : Customer

  type rt_output is record (
    output_record varchar2(4000 char),
    promax_company varchar2(3 char),
    promax_division varchar2(3 char),
    sales_org_code varchar2(5 char),
    division_code varchar2(5 char),
    distbn_chnl_code varchar2(5 char),
    cust_code varchar2(10 char),
    cust_name varchar2(40 char),
    payer_cust_code varchar2(10 char),
    tax_classification_code varchar2(1 char),
    cust_header_order_block_flag varchar2(2 char),
    cust_header_deletion_flag varchar2(2 char),
    sales_area_order_block_flag varchar2(2 char),
    sales_area_deletion_flag varchar2(2 char),
    last_billing_yyyypp varchar2(6 char),
    in_cust_hier number(1,0),
    priority number(2,0)
  );

  type tt_output is table of rt_output;

  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined;

end pxipmx03_extract_v2;
/

create or replace package body pxi_app.pxipmx03_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX03_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX03';

/*******************************************************************************
  NAME: PT_CUST_LIST                                                      PUBLIC
*******************************************************************************/
  function pt_cust_list (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_cust_list pipelined is

    v_cust_code varchar2(10 char);

  begin

    v_cust_code := '*NULL'; -- Initalise to impossible value

    for rv_row in (

      select
        extract_criteria.promax_company,
        extract_criteria.promax_division,
        sales_area.sales_org_code,
        sales_area.division_code,
        sales_area.distbn_chnl_code,
        cust_header.customer_code as cust_code,
        cust_address.name as cust_name,
        cust_payer.partner_cust_code as payer_cust_code,
        cust_tax.tax_classification_code,
        cust_header.order_block_flag as cust_header_order_block_flag,
        cust_header.deletion_flag as cust_header_deletion_flag,
        sales_area.order_block_flag as sales_area_order_block_flag,
        sales_area.deletion_flag as sales_area_deletion_flag,
        cust_last_sold_to.last_billing_yyyypp,
        case when cust_hier.cust_code is not null then 1 else 0 end as in_cust_hier,
        extract_criteria.priority
      from bds_cust_header cust_header,
        bds_cust_sales_area sales_area,
        pxi.pmx_extract_criteria extract_criteria,
        bds_addr_customer cust_address,
        (
          select
            sales_org_code,
            division_code,
            distbn_chnl_code,
            customer_code,
            partner_cust_code,
            partner_counter
          from bds_cust_sales_area_pnrfun
          where sales_org_code = i_promax_company
          and partner_text = 'Payer'
          and customer_code not like '004%' -- Exclude Customer Hierarch Nodes
          and (sales_org_code, division_code, distbn_chnl_code, customer_code, partner_counter) in (
            select
              sales_org_code,
              division_code,
              distbn_chnl_code,
              customer_code,
              max(partner_counter) as max_partner_counter
            from bds_cust_sales_area_pnrfun
            where sales_org_code = i_promax_company
            and partner_text = 'Payer'
            and customer_code not like '004%' -- Exclude Customer Hierarch Nodes
            group by
              sales_org_code,
              division_code,
              distbn_chnl_code,
              customer_code
          )
        ) cust_payer,
        bds_cust_sales_area_taxind cust_tax,
        (
          select
            sales.sold_to_cust_code,
            max(sales.billing_yyyypp) as last_billing_yyyypp
          from sale_cdw_gsv sales,
            pxi.pmx_extract_criteria extract_criteria
          -- Join : sales > extract_criteria
          where sales.sales_org_code = extract_criteria.promax_company
          and sales.division_code = extract_criteria.customer_division
          and sales.distbn_chnl_code = extract_criteria.distribution_channel
          -- Filter : sales
          and sales.sales_org_code = i_promax_company
          and sales.sold_to_cust_code not like '004%' -- Exclude Customer Hierarch Nodes
          -- Filter : extract_criteria
          and extract_criteria.promax_company = i_promax_company
          and extract_criteria.promax_division = i_promax_division
          and extract_criteria.required_for_cust = 'YES'
          group by
            sales.sold_to_cust_code
        ) cust_last_sold_to,
        (
          select distinct cust_code
          from table(pxipmx04_extract_v2.pt_cust_hier_flat(i_promax_company,i_promax_division,i_eff_date))
          where cust_code not like '004%' -- Exclude Customer Hierarch Nodes
        ) cust_hier
      -- Join : cust_header > sales_area
      where cust_header.customer_code = sales_area.customer_code
      -- Join : sales_area > extract_criteria
      and sales_area.sales_org_code = extract_criteria.promax_company
      and sales_area.division_code = extract_criteria.customer_division
      and sales_area.distbn_chnl_code = extract_criteria.distribution_channel
      -- Join : cust_header > cust_address
      and cust_header.customer_code = cust_address.customer_code(+)
      -- Join : sales_area > cust_payer
      and sales_area.sales_org_code = cust_payer.sales_org_code(+)
      and sales_area.division_code = cust_payer.division_code(+)
      and sales_area.distbn_chnl_code = cust_payer.distbn_chnl_code(+)
      and sales_area.customer_code = cust_payer.customer_code(+)
      -- Join : sales_area > cust_tax
      and sales_area.sales_org_code = cust_tax.sales_org_code(+)
      and sales_area.division_code = cust_tax.division_code(+)
      and sales_area.distbn_chnl_code = cust_tax.distbn_chnl_code(+)
      and sales_area.customer_code = cust_tax.customer_code(+)
      -- Join : cust_header > cust_last_sold_to
      and cust_header.customer_code = cust_last_sold_to.sold_to_cust_code(+)
      -- Join : cust_header > cust_hier
      and cust_header.customer_code = cust_hier.cust_code(+)
      -- Filter : cust_header
      and cust_header.customer_code not like '004%' -- Exclude Customer Hierarch Nodes
      -- and cust_header.order_block_flag is null -- Not blocked
      -- and cust_header.deletion_flag is null -- Not deleted
      -- Filter : sales_area
      and sales_area.customer_code not like '004%' -- Exclude Customer Hierarch Nodes
      -- and sales_area.order_block_flag is null -- Not blocked
      -- and sales_area.deletion_flag is null -- Not deleted
      -- Filter : extract_criteria
      and extract_criteria.promax_company = i_promax_company
      and extract_criteria.promax_division = i_promax_division
      and extract_criteria.required_for_cust = 'YES'
      -- Filter : cust_address
      and cust_address.customer_code not like '004%' -- Exclude Customer Hierarch Nodes
      and cust_address.address_version = '*NONE'
      and i_eff_date between cust_address.valid_from_date and cust_address.valid_to_date
      -- Filter : cust_tax
      and cust_tax.sales_org_code = i_promax_company
      and cust_tax.tax_category_code = 'MWST'
      and cust_tax.customer_code not like '004%' -- Exclude Customer Hierarch Nodes
      -- Filter : Customer is NOT Blocked or Deleted .. or has been Billed within the last Year
      and (
          (
            cust_header.order_block_flag is null
            and cust_header.deletion_flag is null
            and sales_area.order_block_flag is null
            and sales_area.deletion_flag is null
          ) or nvl(last_billing_yyyypp, '000000') > to_char(extract(year from i_eff_date)-1)||'00' -- last year
        )
      order by
        cust_header.customer_code,
        extract_criteria.priority

    )
    loop

      if v_cust_code != rv_row.cust_code then
        v_cust_code := rv_row.cust_code;
        pipe row(rv_row);
      end if;

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_CUST_LIST');

  end pt_cust_list;

/*******************************************************************************
  NAME: PT_OUTPUT                                                         PUBLIC
*******************************************************************************/
  function pt_output (
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) return tt_output pipelined is

  begin

    for rv_row in (

      select
        pxi_common.char_format('300001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '300001' -> RecordType
        pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
        pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
        pxi_common.char_format(cust_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- customer_code -> CustomerNumber
        pxi_common.char_format(cust_name, 40, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- customer_name -> Longname
        pxi_common.char_format('Y', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT 'Y' -> PACSCustomer
        pxi_common.char_format(payer_cust_code, 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_nullable) || -- payer_customer_code -> PayerCode
        pxi_common.char_format(case tax_classification_code when '0' then 'Y' else 'N' end, 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- tax_exempt -> TaxExempt
        pxi_common.char_format(case sales_org_code when pxi_common.fc_australia then 'AUD' when pxi_common.fc_new_zealand then 'NZD' else null end, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- currency -> DefaultCurrenty
        -- pxi_common.char_format(sales_org_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- sales_org_code -> SalesOrg
        pxi_common.char_format(division_code, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- division_code -> SalesOrg
        pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- promax_division -> Division
        pxi_common.char_format('1', 1, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- CONSTANT '1' -> ShippingType
        as output_record,
        promax_company,
        promax_division,
        sales_org_code,
        division_code,
        distbn_chnl_code,
        cust_code,
        cust_name,
        payer_cust_code,
        tax_classification_code,
        cust_header_order_block_flag,
        cust_header_deletion_flag,
        sales_area_order_block_flag,
        sales_area_deletion_flag,
        last_billing_yyyypp,
        in_cust_hier,
        priority
      from (
      
        select        
          promax_company,
          promax_division,
          sales_org_code,
          division_code,
          distbn_chnl_code,
          cust_code,
          cust_name,
          payer_cust_code,
          tax_classification_code,
          cust_header_order_block_flag,
          cust_header_deletion_flag,
          sales_area_order_block_flag,
          sales_area_deletion_flag,
          last_billing_yyyypp,
          in_cust_hier,
          priority
        from table(pxipmx03_extract_v2.pt_cust_list(i_promax_company,i_promax_division,i_eff_date))
        where in_cust_hier = 1
        
        union all
        
        select        
          i_promax_company as promax_company,
          i_promax_division as promax_division,
          i_promax_company as sales_org_code,
          division_code,
          null as distbn_chnl_code,
          cust_code,
          cust_name,
          null as payer_cust_code,
          null as tax_classification_code,
          null as cust_header_order_block_flag,
          null as cust_header_deletion_flag,
          null as sales_area_order_block_flag,
          null as sales_area_deletion_flag,
          null as last_billing_yyyypp,
          1 as in_cust_hier,
          null as priority
        from table(pxipmx04_extract_v2.pt_output(i_promax_company,i_promax_division,i_eff_date))
        where cust_code like '004%'
      )
      order by 
        cust_code

    )
    loop

        pipe row(rv_row);

    end loop;

  exception
    when others then
      pxi_common.reraise_promax_exception(pc_package_name,'PT_OUTPUT');

  end pt_output;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(
    i_promax_company in pxi_common.st_company,
    i_promax_division in pxi_common.st_promax_division,
    i_eff_date in date
  ) is

    v_interface_name_with_suffix varchar2(64 char);
    v_instance number(15,0);

  begin

    -- Set interface name (including Suffix)
    v_interface_name_with_suffix := pc_interface_name || '.' || pxi_common.promax_interface_suffix(i_promax_company,i_promax_division);

    -- request lock (on interface)
    begin
      lics_locking.request(v_interface_name_with_suffix);
    exception
      when others then
        pxi_common.raise_promax_error(pc_package_name,'EXECUTE',substr('Unable to obtain interface lock ['||v_interface_name_with_suffix||'] - '||sqlerrm, 1, 4000));
    end;

    for rv_row in (

      select output_record
      from table(pt_output(i_promax_company,i_promax_division,i_eff_date))

    )
    loop

      -- Create interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(v_interface_name_with_suffix);
      end if;

      -- Append Data
      lics_outbound_loader.append_data(rv_row.output_record);

    end loop;

    -- Finalise interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

    -- Release lock (on interface)
    lics_locking.release(v_interface_name_with_suffix);

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(sqlerrm, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end pxipmx03_extract_v2;
/

grant execute on pxi_app.pxipmx03_extract_v2 to lics_app, fflu_app, site_app;
