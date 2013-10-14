create or replace 
PACKAGE BODY PXIPMX10_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX10_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX10';

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate) is
     -- Variables     
     v_instance number(15,0);
     
     -- Extract Cursor.
     cursor csr_input is
        select
          pxi_common.char_format('336003', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '336003' -> RecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format(invoicenumber, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- invoicenumber -> InvoiceNumber
          pxi_common.char_format(invoicelinenumber, 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- invoicelinenumber -> InvoiceLineNumber
          pxi_common.char_format(customerhierarchy, 8, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- customerhierarchy -> CustomerHierarchy
          pxi_common.char_format(material, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- material -> Material
          pxi_common.date_format(orderdate, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- orderdate -> OrderDate
          pxi_common.numb_format(qty * cost, 'S999990.00', pxi_common.fc_is_nullable) || -- discountgiven -> DiscountGiven
          pxi_common.char_format('500', 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '500' -> ConditionType
          pxi_common.char_format(currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- currency -> Currency
          pxi_common.char_format(' ', 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) as data, -- CONSTANT ' ' -> PromotionNumber
          -- Bring out the other fields required for validating the interface.
          promax_company,
          promax_division,
          material,
          billing_eff_date,
          cost
        from (
           select
            t4.promax_company,
            t4.promax_division,
            t1.billing_doc_num as invoicenumber,
            decode(substr(t1.billing_doc_line_num,7,4),'_ADD','1'||substr(t1.billing_doc_line_num,2,5),'_REM','2'||substr(t1.billing_doc_line_num,2,5),t1.billing_doc_line_num) as invoicelinenumber,
            t1.sold_to_cust_code as customerhierarchy,
            t3.rep_item as material,
            nvl(decode(to_char(t2.order_eff_date,'DY'),'SUN',t2.order_eff_date +1,t2.order_eff_date),decode(to_char(t1.billing_eff_date,'DY'),'SUN',t1.billing_eff_date +1,t1.billing_eff_date)) as orderdate,
            t1.billing_eff_date,
            t1.billed_qty_base_uom as qty,
            t1.doc_currcy_code as currency,
            (select t0.cost from pxi.pmx_cogs t0 where t0.cmpny_code = t4.promax_company and t0.div_code = t4.promax_division and t0.zrep_matl_code = pxi_common.full_matl_code(t3.rep_item) and 
             t0.mars_period = (select t00.mars_period from mars_date@db1270p_promax_testing t00 where t00.calendar_date = t1.billing_eff_date)) as cost
          from
            dw_sales_base@db1270p_promax_testing t1,  -- @db1270p_promax_testing
            dw_order_base@db1270p_promax_testing t2,  -- @db1270p_promax_testing
            matl_dim@db1270p_promax_testing t3, -- @db1270p_promax_testing
            table(pxi_common.promax_config(i_pmx_company,i_pmx_division)) t4
          where
            -- Join to promax configuration table.
            t1.company_code = t4.promax_company 
            and ((t1.company_code = pxi_common.gc_australia and t1.hdr_division_code = t4.cust_division) or (t1.company_code = pxi_common.gc_new_zealand))
            -- Extract yesterdays data by default, otherwise extract a whole range of data. for history since 2012.
            and t1.company_code = t2.company_code (+)
            and t1.creatn_date between trunc(i_creation_date-7-to_char(sysdate,'D')) and trunc(sysdate-7+ (6-to_char(sysdate,'D')))
            and t1.order_doc_num = t2.order_doc_num (+)
            and t1.order_doc_line_num = t2.order_doc_line_num (+)
            -- Now join to the material zrep detail
            and t1.matl_code = t3.matl_code
            -- Not null check added to accommodate new restrictions on output format
            and t1.matl_entd is not null
        );
        rv_data csr_input%rowtype;

   begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into rv_data;
       exit when csr_input%notfound;
       -- Check if cost was in error.
       if rv_data.cost is null then 
         pxi_common.raise_promax_error(pc_package_name,'EXECUTE','Missing COGS Data for [' || rv_data.promax_company || ',' || rv_data.promax_division || '], billing date : ' || to_char(rv_data.billing_eff_date,'DD/MM/YYYY') || ', zrep material : ' || rv_data.material || '.');
       end if;
       -- Create the new interface when required
       if lics_outbound_loader.is_created = false then
         v_instance := lics_outbound_loader.create_interface(pc_interface_name);
       end if;
       -- Append the interface data
       lics_outbound_loader.append_data(rv_data.data);
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

end PXIPMX10_EXTRACT; 