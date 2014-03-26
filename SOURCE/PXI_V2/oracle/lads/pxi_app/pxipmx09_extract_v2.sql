prompt :: Compile Package [pxipmx09_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx09_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX09_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
 LADS (Outbound) -> Promax PX - Pricing Conditions Actuals - PX Interface 336 

 Date          Author                Description
 ------------  --------------------  -----------
 24/07/2013    Chris Horn            Created.
 27/07/2013    Mal Chambeyron        Formatted SQL Output
 21/08/2013    Chris Horn            Cleaned Up Code
 28/08/2013    Chris Horn            Made code generic for OZ.
 2013-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix
 2014-03-25    Mal Chambeyron        Updated filter criteria  
                                     - Creation Date > 28 days prior to [i_creation_date]
                                     - Billing Effective Date within the Mars Week for [i_creation_date] 
 2014-03-25    Mal Chambeyron        Changes to support PC Actual Extract Criteria ..
                                     [required_for_price] > [required_for_pcact]
                                     t01.division = t03.promax_division

*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of pricing condition actual
             data.

             It defaults to all available live promax companies and divisions
             and just current data as of yesterday.  If null is supplied as
             the creation date then historial information will be supplied
             as defined by the business logic.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-21 Chris Horn           Cleaned Up.
  1.3   2013-08-28 Chris Horn           Made Code Generic for Oz.
  1.4   2013-11-01 Jonathan Girling     Added additional join on condition type
                                        Changed discountgiven to allow negatives

*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_creation_date in date);

end pxipmx09_extract_v2;
/

create or replace package body pxi_app.pxipmx09_extract_v2 as
/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX09_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX09';

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_promax_company in pxi_common.st_company,
     i_promax_division in pxi_common.st_promax_division,
     i_creation_date in date) is
     -- Variables
     v_instance number(15,0);
     v_data pxi_common.st_data;

     -- The extract query.
     cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('336002', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '336002' -> RecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(invoicenumber, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- invoicenumber -> InvoiceNumber
          pxi_common.char_format(invoicelinenumber, 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- invoicelinenumber -> InvoiceLineNumber
          pxi_common.char_format(customerhierarchy, 8, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- customerhierarchy -> CustomerHierarchy
          pxi_common.char_format(material, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- material -> Material
          pxi_common.date_format(invoicedate, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- invoicedate -> InvoiceDate
          pxi_common.numb_format(discountgiven, 's999990.00', pxi_common.fc_is_not_nullable) || -- discountgiven -> DiscountGiven
          pxi_common.char_format(conditiontype, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- conditiontype -> ConditionType
          pxi_common.char_format(currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- currency -> Currency
          pxi_common.char_format(promotion_number, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) -- promotion_number -> PromotionNumber
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select
              t03.promax_company,
              t03.promax_division,
              t01.invoice_no as invoicenumber,
              t01.line_no as invoiceLineNumber,
              t02.kunnr as customerhierarchy,
              t01.zrep_matl_code as material,
              to_date(t01.invoice_date, 'yyyymmdd') as invoicedate,
              t01.discount as discountGiven,
              rpad(t01.pricing_condition,6) as conditionType,       -- TBC with the business. In issues log.
              t01.pmnum as promotion_number,
              case t01.sales_org when pxi_common.fc_australia then 'AUD' when pxi_common.fc_new_zealand then 'NZD' else null end as currency
          from
              promax_prom_inv_ext_view t01,
              lads_prc_lst_hdr t02,
              (
                select distinct
                  promax_company,
                  promax_division,
                  customer_division
                from pxi.pmx_extract_criteria
                where promax_company = i_promax_company
                and promax_division = i_promax_division
                and required_for_pcact = 'YES'
              ) t03
          where
              t01.pmnum = t02.kosrt and
              t01.sales_org = t02.vkorg and
              t01.cust_division = t02.spart and
              t01.zrep_matl_code = t02.matnr and
              t01.pricing_condition = t02.kschl and
              t01.invoice_date between t02.datab and t02.datbi and -- Include Pricing Condition Effectivity date filter on invoice_date
              -- Now make sure the correct data is being extracted.
              t01.sales_org = t03.promax_company and
              ((t01.sales_org = pxi_common.fc_australia and t01.division = t03.promax_division) or (t01.sales_org = pxi_common.fc_new_zealand))
              --------------------------------------------------------------------
              and t01.lads_date >= trunc(i_creation_date-28) -- Creation Date > 28 days prior to [i_creation_date]
              and to_date(t01.invoice_date, 'YYYYMMDD') -- Billing Effective Date within the Mars Week for [i_creation_date] 
                between
                trunc(i_creation_date) +
                case to_char(i_creation_date, 'DY')
                  when 'SUN' then 0
                  when 'MON' then -1
                  when 'TUE' then -2
                  when 'WED' then -3
                  when 'THU' then -4
                  when 'FRI' then -5
                  when 'SAT' then -6
                end -- Mars Week Start Date
                and trunc(i_creation_date) +
                case to_char(i_creation_date, 'DY')
                  when 'SUN' then 6
                  when 'MON' then 5
                  when 'TUE' then 4
                  when 'WED' then 3
                  when 'THU' then 2
                  when 'FRI' then 1
                  when 'SAT' then 0
                end -- Mars Week End Date
              --------------------------------------------------------------------
        ------------------------------------------------------------------------
        );
        --======================================================================

   begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(i_promax_company,i_promax_division));
      end if;
      -- Append the interface data
      lics_outbound_loader.append_data(v_data);
    end loop;
    close csr_input;

    -- Finalise the interface when required
    if lics_outbound_loader.is_created = true then
      lics_outbound_loader.finalise_interface;
    end if;

  exception
     when others then
       rollback;
       if lics_outbound_loader.is_created = true then
         lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
         lics_outbound_loader.finalise_interface;
       end if;
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
   end execute;

end pxipmx09_extract_v2;
/

grant execute on pxi_app.pxipmx09_extract_v2 to lics_app, fflu_app, site_app;
