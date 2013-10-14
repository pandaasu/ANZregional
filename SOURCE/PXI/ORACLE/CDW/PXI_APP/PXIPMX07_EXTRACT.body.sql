create or replace 
PACKAGE BODY PXIPMX07_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX07_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX07';

/*******************************************************************************
  NAME:  EXECUTE                                                          PUBLIC
*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company default null,
     i_pmx_division in pxi_common.st_promax_division default null, 
     i_creation_date in date default sysdate-1) is
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
            dw_sales_base@db1270p_promax_testing t1,  --
            dw_order_base@db1270p_promax_testing t2,  -- @db1270p_promax_testing
            matl_dim@db1270p_promax_testing t3, -- @db1270p_promax_testing
            table(pxi_common.promax_config(i_pmx_company,i_pmx_division)) t4
          where
            -- Join to promax configuration table.
            t1.company_code = t4.promax_company 
            and ((t1.company_code = pxi_common.gc_australia and t1.hdr_division_code = t4.cust_division) or (t1.company_code = pxi_common.gc_new_zealand))
            -- Extract yesterdays data by default, otherwise extract a whole range of data. for history since 2012.
            and t1.company_code = t2.company_code (+)
            and t1.creatn_date between nvl(trunc(i_creation_date),to_date('01/01/2012','DD/MM/YYYY')) and nvl(trunc(i_creation_date),trunc(sysdate-1))
            and t1.order_doc_num = t2.order_doc_num (+)
            and t1.order_doc_line_num = t2.order_doc_line_num (+)
            -- Now join to the material zrep detail
            and t1.matl_code = t3.matl_code
            -- Not null check added to accommodate new restrictions on output format
            and t1.matl_entd is not null
        );

   begin
     -- Open cursor with the extract data.
     open csr_input;
     loop
       fetch csr_input into v_data;
       exit when csr_input%notfound;
      -- Create the new interface when required
      if lics_outbound_loader.is_created = false then
        v_instance := lics_outbound_loader.create_interface(pc_interface_name);
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

end PXIPMX07_EXTRACT; 