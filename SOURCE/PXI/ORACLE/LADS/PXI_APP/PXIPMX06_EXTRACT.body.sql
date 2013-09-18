create or replace 
PACKAGE BODY          PXIPMX06_EXTRACT as

/*******************************************************************************
  Package Cosntants
*******************************************************************************/
  pc_package_name constant pxi_common.st_package_name := 'PXIPMX06_EXTRACT';
  pc_interface_name constant pxi_common.st_interface_name := 'PXIPMX06';

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
 
     -- The extract query.
     cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('330002', 6, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- CONSTANT '330002' -> RecordType
          pxi_common.char_format(promax_company, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- promax_company -> PXCompanyCode
          pxi_common.char_format(promax_division, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_nullable) || -- promax_division -> PXDivisionCode
          pxi_common.char_format('DIV_1', 10, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- CONSTANT 'DIV_1' -> CustomerCode
          pxi_common.char_format(prodcode, 18, pxi_common.fc_format_type_ltrim_zeros, pxi_common.fc_is_not_nullable) || -- prodcode -> MaterialCode
          pxi_common.date_format(startdate, 'yyyymmdd', pxi_common.fc_is_not_nullable) || -- startdate -> StartDate
          pxi_common.date_format(enddate, 'yyyymmdd', pxi_common.fc_is_nullable) || -- enddate -> EndDate
          pxi_common.numb_format(listprice, '999999990.00', pxi_common.fc_is_nullable) || -- listprice -> ListPrice
          pxi_common.char_format(currency, 3, pxi_common.fc_format_type_none, pxi_common.fc_is_not_nullable) -- currency -> Currency
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select
            t20.promax_company,
            t20.promax_division,
            t10.custcode,
            t10.prodcode,
            t10.startdate,
            t10.enddate,
            t10.price1 as listprice,
            case t10.cocode when  pxi_common.gc_australia then 'AUD' when pxi_common.gc_new_zealand then 'NZD' else null end as currency
          FROM (SELECT t01.*,
                        RANK ()
                        OVER (
                           PARTITION BY t01.cocode,
                                        t01.divcode,
                                        t01.channel,
                                        t01.custcode,
                                        t01.prodcode,
                                        t01.currency
                           ORDER BY t01.startdate ASC)
                           AS rnkseq
                   --FROM (SELECT LTRIM (a.vkorg, 1) AS cocode,
                   FROM (SELECT a.vkorg AS cocode,
                                f.dvsn AS divcode,
                                DECODE (a.vkorg,
                                        '147', h.dstrbtn_chnl,
                                        '149', '11')
                                   AS channel,
                                a.kunnr as custcode,
                                ltrim (a.matnr, 0) as prodcode,
                                to_date(a.datab,'YYYYMMDD') as startdate,
                                to_date(a.datbi,'YYYYMMDD') AS enddate,
                                c.konwa as currency,
                                DECODE (
                                   a.vkorg,
                                   '147', CASE
                                             WHEN     h.dstrbtn_chnl = '12'
                                                  AND g.trade_sctr_code = '01'
                                             THEN
                                                c.kbetr * 1.03
                                             ELSE
                                                c.kbetr
                                          END,
                                   '149', c.kbetr)
                                   AS price1,
                                0 AS mnfcost,
                                0 AS rrp
                           FROM lads_prc_lst_hdr a, -- @ap0064p_promax_testing
                                lads_prc_lst_det c, -- @ap0064p_promax_testing
                                mfanz_matl f,-- @ap0064p_promax_testing
                                mfanz_fg_matl_clssfctn g, -- @ap0064p_promax_testing
                                mfanz_matl_by_sales_area h -- @ap0064p_promax_testing
                          WHERE     a.vakey = c.vakey
                                AND a.datab = c.datab
                                AND a.kschl = c.kschl
                                AND a.matnr IS NOT NULL
                                AND a.kotabnr = 812 -- 812 refers to the Access Sequence Sales Organisation / Material
                                AND a.matnr = g.matl_code
                                AND a.matnr = h.matl_code
                                AND a.matnr = f.matl_code
                                AND f.matl_type = 'ZREP'
                                AND f.trdd_unit = 'X'
                                AND a.vkorg = h.sales_org
                                AND (a.vkorg, h.dstrbtn_chnl) IN
                                       ( ('147', '11'),
                                        ('147', '12'),
                                        ('149', '10')) -- AUS Distribution Channels set up are 11 and 12, NZ is 10
                                AND c.kbetr IS NOT NULL
                                AND c.knumh = a.knumh
                                AND c.kschl IN ('ZR05', 'ZN00')
                                AND c.kmein = 'EA'
                                and c.loevm_ko is null -- If this is marked 'X' it means the condition is no longer active
                                and a.datbi >= to_char (sysdate, 'yyyymmdd')) t01) t10, 
            table(pxi_common.promax_config(i_pmx_company,i_pmx_division)) t20  -- Promax Configuration table
          where 
            t10.rnkseq <= 3 and 
            -- Now join to current information
            t10.cocode = t20.promax_company and 
            ((t10.cocode = pxi_common.gc_australia and t10.divcode = t20.promax_division) or (t10.cocode = pxi_common.gc_new_zealand))
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

end PXIPMX06_EXTRACT; 