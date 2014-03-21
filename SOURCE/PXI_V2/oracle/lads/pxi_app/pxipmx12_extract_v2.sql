prompt :: Compile Package [pxipmx12_extract_v2] :::::::::::::::::::::::::::::::::::::::

create or replace package pxi_app.pxipmx12_extract_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : LADS
 Package : PXIPMX12_EXTRACT_V2
 Owner   : PXI_APP
 Author  : Jonathan Girling

 Description
 -----------
 LADS (Outbound) -> Promax PX - Redist, Ullage and Settlement - PX Interface 336

 Date        Author                Description
 ----------  --------------------  -----------
 2014-02-07  Jonathan Girling      Created.
 2014-03-12  Mal Chambeyron        Remove DEFAULTS,
                                   Replace [pxi_common.promax_config]
 2014-03-21  Mal Chambeyron        Ensure VARCHAR2 representation of date is in fact a DATE

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
  1.1   2014-02-07 Jonathan Girling     Created.

*******************************************************************************/
   procedure execute(
     i_pmx_company in pxi_common.st_company,
     i_pmx_division in pxi_common.st_promax_division,
     i_creation_date in date);

end pxipmx12_extract_v2;
/

create or replace package body pxi_app.pxipmx12_extract_v2 as
/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX12_EXTRACT_V2';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX12';

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

     -- The extract query.
     cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('record_type','336002', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- CONSTANT '336002' -> RecordType
          pxi_common.char_format('promax_company',promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format('promax_division',promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format('invoice_number',invoicenumber, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- invoicenumber -> InvoiceNumber
          pxi_common.char_format('invoice_line_number',invoicelinenumber, 6, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- invoicelinenumber -> InvoiceLineNumber
          pxi_common.char_format('customer_hierarchy',customerhierarchy, 8, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- customerhierarchy -> CustomerHierarchy
          pxi_common.char_format('material',material, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- material -> Material
          pxi_common.date_format('invoice_date',invoicedate, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- invoicedate -> InvoiceDate
          --pxi_common.numb_format(discountgiven, '9999990.00', pxi_common.fc_is_not_nullable) || -- discountgiven -> DiscountGiven
          pxi_common.numb_format('discount_given',discountgiven, 's999990.00', pxi_common.fc_is_not_nullable) || -- discountgiven -> DiscountGiven
          pxi_common.char_format('condition_type',conditiontype, 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- conditiontype -> ConditionType
          pxi_common.char_format('currency',currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) || -- currency -> Currency
          pxi_common.char_format('intentionally_blank',' ', 10, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) -- CONSTANT ' ' -> PromotionNumber
        -------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select
            t01.promax_company,
            t01.promax_division,
            t01.invoice_no as invoicenumber,
            t01.line_no as invoicelinenumber,
            t01.sold_to_cust_code as customerhierarchy,
            t01.zrep_matl_code as material,
            to_date(t01.billing_date, 'yyyymmdd') as invoicedate, -- Ensure VARCHAR2 representation of date is in fact a DATE
            round(case when t01.pricing_condition = 'SKTO' then t01.discount / 1.1 else t01.discount * 1 end, 2) as discountgiven,
            t01.pricing_condition as conditiontype,
            t01.currency as currency
          from (
            select
              t03.promax_company,
              t03.promax_division,
              a.belnr as invoice_no,
              c.posex as line_no,
              b.orgid as sales_org,
              k.orgid as cust_division,
              c.prod_spart as division,
              (select t0.partn
                 from lads_inv_pnr t0
                where t0.belnr = a.belnr and t0.parvw = '1I')
                 as level1_cust_hierarchy,
              (select t0.partn
                 from lads_inv_pnr t0
                where t0.belnr = a.belnr and t0.parvw = '1H')
                 as level2_cust_hierarchy,
              (select t0.partn
                 from lads_inv_pnr t0
                where t0.belnr = a.belnr and t0.parvw = '1G')
                 as level3_cust_hierarchy,
              (select t0.partn
                 from lads_inv_pnr t0
                where t0.belnr = a.belnr and t0.parvw = '1F')
                 as level4_cust_hierarchy,
              (select t0.partn
                 from lads_inv_pnr t0
                where t0.belnr = a.belnr and t0.parvw = '1E')
                 as level5_cust_hierarchy,
              d.partn as sold_to_cust_code,
              j.partn as ship_to_cust_code,
              --h.kosrt AS pmnum,
              f.idtnr as zrep_matl_code,
              substr (e.datum, 1, 4) as promyear,
              case
                 when m.orgid in
                         ('FAZ',
                          'LGS',
                          'LRS',
                          'S1',
                          'S3',
                          'SV',
                          'ZG2',
                          'ZG2R',
                          'ZLG',
                          'ZRE',
                          'ZRG',
                          'ZGI')
                 then
                    to_char (to_number (c.menge) * -1, 'FM9990.000')
                 else
                    c.menge
              end
                 as inv_qty,
              c.menee as inv_qty_uom,
              case
                 when ( (c.menee = 'CS') and (t2.mkt_sgmnt_code = '27'))
                 then
                    to_char (
                       (  c.menge
                        * (select cnvrsn_fctr_to_base_uom
                             from mfanz_matl_altrntv_uom
                            where matl_code = f.idtnr and altrntv_uom = 'CS')),
                       'FM9990.000')
                 else
                    c.menge
              end
                 as promo_qty,
              case
                 when ( (c.menee = 'CS') and (t2.mkt_sgmnt_code = '27'))
                 then
                    'EA'
                 else
                    c.menee
              end
                 as promo_qty_uom,
              case
                 when i.krate is null
                 then
                    null
                 else
                    to_char (
                         to_number (
                               decode (instr (i.krate, '-'),
                                       0, '',
                                       substr (i.krate, instr (i.krate, '-'), 1))
                            || rtrim (i.krate, '-'))
                       / to_number (nvl (i.uprbs, 1)),
                       'FM99990.00MI')
              end
                 as discount_rate,
              to_number (g.betrg) as gsv,
              i.kschl as pricing_condition,
              case
                 when m.orgid in
                         ('FAZ',
                          'LGS',
                          'LRS',
                          'S1',
                          'S3',
                          'SV',
                          'ZG2',
                          'ZG2R',
                          'ZLG',
                          'ZRE',
                          'ZRG',
                          'ZGI')
                 then
                    to_char (to_number (i.betrg) * -1, 'FM99990.00')
                 else
                    to_char (to_number (i.betrg), 'FM99990.00')
              end
                 as discount,
              e.datum as invoice_date,
              e.uzeit as invoice_time,
              a.lads_date,
              decode (l.datum,
                      null, '19000101',
                      '00000000', '19000101',
                      l.datum)
                 as billing_date,
              m.orgid as bllng_type,
              case b.orgid when '147' then 'AUD' when '149' then 'NZD' else null end as currency
            from
              lads_inv_hdr a,
              lads_inv_org b,
              lads_inv_org k,
              lads_inv_gen c,
              lads_inv_pnr d,
              lads_inv_ipn j,
              lads_inv_dat e,
              lads_inv_iob f,
              lads_inv_icn g,
              lads_inv_icn i,
              --lads_inv_icp h,
              lads_inv_dat l,
              lads_inv_org m,
              mfanz_fg_matl_clssfctn t2,
              (
                select distinct
                  promax_company,
                  promax_division
                from pxi.pmx_extract_criteria
                where promax_company = i_pmx_company
                and promax_division = i_pmx_division
              ) t03 -- repalce pxi_common:promax_config
            where
              -- Now make sure the correct data is being extracted.
              b.orgid = t03.promax_company and
              --  ((b.orgid = '147' and k.orgid = t03.cust_division) or (b.orgid = '149'))
              ((b.orgid = '147' and c.prod_spart = t03.promax_division) or (b.orgid = '149'))
              and a.lads_date > trunc(i_creation_date)
              -- remaining joins
              and
               a.lads_status = 1
              and a.belnr = b.belnr
              and b.qualf = '008'                            -- Sales Organisation
              and a.belnr = k.belnr
              and k.qualf = '006'                             -- Customer Division
              and a.belnr = c.belnr
              and c.belnr = d.belnr
              and d.parvw = 'AG'                               -- Sold To Customer
              and c.belnr = j.belnr
              and c.genseq = j.genseq
              and j.parvw = 'WE'                               -- Ship To Customer
              and a.belnr = e.belnr
              and e.iddat = 'Z03'                      -- Local Creation Date Time
              and c.belnr = f.belnr
              and c.genseq = f.genseq
              and f.qualf = '006'             -- Pricing Reference Material - ZREP
              and c.belnr = g.belnr
              and c.genseq = g.genseq
              and g.kschl is null
              and g.kotxt = 'GSV'
              and c.belnr = i.belnr
              and c.genseq = i.genseq
              --AND i.belnr = h.belnr
              --AND i.GENSEQ = h.genseq
              --AND i.ICNSEQ = h.icnseq
              and a.belnr = l.belnr
              and l.iddat = '026'                                  -- billing date
              and a.belnr = m.belnr
              and m.qualf = '015'                                  -- billing type
              and f.idtnr = t2.matl_code
              and i.kschl is not null             -- Must have Pricing Conditions
              and i.kschl in ('ZK33', 'ZK35', 'SKTO') -- Ullage, Redistribution, Settlement
          ) t01
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
        v_instance := lics_outbound_loader.create_interface(pc_interface_name||'.'||pxi_common.promax_interface_suffix(trim(substr(v_data,7,3)),trim(substr(v_data,10,3))));
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

end pxipmx12_extract_v2;
/

grant execute on pxi_app.pxipmx12_extract_v2 to lics_app, fflu_app, site_app;
