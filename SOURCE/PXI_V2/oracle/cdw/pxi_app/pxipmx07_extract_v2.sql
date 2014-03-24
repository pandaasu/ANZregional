prompt :: Compile Package [pxipmx07_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx07_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : VENUS
 Package : PXIPMX07_EXTRACT_V2
 Owner   : DDS_APP
 Author  : Chris Horn and Mal Chambeyron

 Description
 -----------
    VENUS -> LADS (Pass Through) -> Promax PX - Sales Data - PX Interface 306

 This interface selects sales data for the specific creation date and company
 149 and extracts that data and then onsends it to Lads for Pass through.

 Date          Author                Description
 ------------  --------------------  -----------
 2013-07-23    Chris Horn            Created.
 2013-07-25    Mal Chambeyron        Formatted SQL Output
 2013-08-20    Chris Horn            Updated with revision.
 2013-08-29    Chris Horn            Updated the a revised sales query.
 2013-03-12    Mal Chambeyron        Remove DEFAULTS,
                                     Replace [pxi_common.promax_config]
                                     Use Suffix
 2013-03-21    Mal Chambeyron        Modify Sales Data Filter ..
                                     - [creatn_date] >= trunc([i_creation_date]-28) 
                                     - [billing_eff_date] <= end of [i_creation_date] Mars Week 
 2013-03-24    Mal Chambeyron        Updated [billing_eff_date] <= end of [i_creation_date] Mars Week
                                     to correct inconsistient behavour dependant on client (NLS)
            
*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This function creates an extract of sales data for promax.
             It defaults to all available promax companies and divisions and
             for sales from yesterday.  If null is supplied as the creation data
             it will generate all sales history from the hard coded sales
             history date.

             Note that if no date is supplied it will try and extract all
             relevant data from 01/01/2012 to yesterday.  This may cause
             issues and fail to run.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-07-30 Chris Horn           Created.
  1.2   2013-08-29 Chris Horn           Updated sales query.

*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company,
     i_pmx_division in pxi_common.st_promax_division,
     i_creation_date in date);

end pxipmx07_extract_v2;
/

create or replace package body pxi_app.pxipmx07_extract_v2 as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX07_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX07';

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company,
     i_pmx_division in pxi_common.st_promax_division,
     i_creation_date in date) is
     -- Variables
     v_instance number(15,0);
     v_data pxi_common.st_data;

     -- Extract Cursor.
     cursor csr_input is
        select
          pxi_common.char_format('306001', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '306001' -> ICRecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- hdr_division_code -> PXDivisionCode
          pxi_common.char_format(sold_to_cust_code, 20, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- sold_to_cust_code -> CustomerNumber
          pxi_common.char_format(billing_doc_num, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- billing_doc_num -> InvoiceNumber
          pxi_common.char_format(billing_doc_line_num, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- billing_doc_line_num -> InvoiceLineNumber
          pxi_common.char_format(rep_item, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- matl_entd -> Material
          pxi_common.date_format(order_eff_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- order_eff_date -> OrderDate
          pxi_common.date_format(billing_eff_date, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- billing_eff_date -> InvoiceDate
          pxi_common.numb_format(billed_qty_base_uom, 'S9999999999990.00', pxi_common.fc_is_not_nullable) || -- billed_qty_base_uom -> QuantityInvoiced
          pxi_common.numb_format(billed_gsv, 'S999999990.00', pxi_common.fc_is_not_nullable) || -- billed_gsv -> GrossAmount
          pxi_common.char_format(doc_currcy_code, 5, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) -- doc_currcy_code -> Currency
        from (
          select
            t4.promax_company,
            t4.promax_division,
            t1.sold_to_cust_code,
            t1.billing_doc_num,
            decode(substr(t1.billing_doc_line_num,7,4),'_ADD','1'||substr(t1.billing_doc_line_num,2,5),'_REM','2'||substr(t1.billing_doc_line_num,2,5),t1.billing_doc_line_num) as billing_doc_line_num,
            t3.rep_item,
            nvl(decode(to_char(t2.order_eff_date,'DY'),'SUN',t2.order_eff_date +1,t2.order_eff_date),decode(to_char(t1.billing_eff_date,'DY'),'SUN',t1.billing_eff_date +1,t1.billing_eff_date)) as order_eff_date,
            decode(to_char(t1.billing_eff_date,'DY'),'SUN',t1.billing_eff_date +1,t1.billing_eff_date) as billing_eff_date,
            t1.billed_qty_base_uom,
            t1.billed_gsv,
            t1.doc_currcy_code
          from
            dw_sales_base t1,  --
            dw_order_base t2,  -- 
            matl_dim t3, -- 
            (
              select distinct
                promax_company,
                promax_division,
                customer_division,
                distribution_channel
              from pxi.pmx_extract_criteria
              where promax_company = i_pmx_company
              and promax_division = i_pmx_division
              and required_for_sales = 'YES'
            ) t4 -- replaced pxi_common:promax_config
          where
            -- Join to promax configuration table.
                t1.hdr_distbn_chnl_code = t4.distribution_channel
            and t1.hdr_division_code = t4.customer_division
            and t1.company_code = t2.company_code (+)
            and t1.order_doc_num = t2.order_doc_num (+)
            and t1.order_doc_line_num = t2.order_doc_line_num (+)
           -- Now join to the material zrep detail
            and t1.matl_code = t3.matl_code
            and t1.creatn_date >= trunc(i_creation_date-28) -- Include creation date > 28 days previous
            -- Not null check added to accommodate new restrictions on output format
            and t1.matl_entd is not null
            -- Limit [billing_eff_date] <= end of [i_creation_date] Mars Week
            and t1.billing_eff_date <= trunc(i_creation_date) + 
              case to_char(i_creation_date, 'DY')
                when 'SUN' then 6
                when 'MON' then 5
                when 'TUE' then 4
                when 'WED' then 3
                when 'THU' then 2
                when 'FRI' then 1
                when 'SAT' then 0
              end
          );
        
   begin
   
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(i_pmx_company,i_pmx_division));
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

end pxipmx07_extract_v2;
/

grant execute on pxi_app.pxipmx07_extract_v2 to lics_app, fflu_app;
