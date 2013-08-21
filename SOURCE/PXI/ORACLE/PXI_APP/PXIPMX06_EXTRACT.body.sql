create or replace 
PACKAGE BODY          PXIPMX06_EXTRACT as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
        --======================================================================
        select
        ------------------------------------------------------------------------
        -- FORMAT OUTPUT
        ------------------------------------------------------------------------
          pxi_common.char_format('330002', 6, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '330002' -> RecordType
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '149' -> PXCompanyCode
          pxi_common.char_format('149', 3, pxi_common.format_type_none, pxi_common.is_nullable) || -- CONSTANT '149' -> PXDivisionCode
          pxi_common.char_format('DIV_1', 10, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- CONSTANT 'DIV_1' -> CustomerCode
          pxi_common.char_format(prodcode, 18, pxi_common.format_type_ltrim_zeros, pxi_common.is_not_nullable) || -- prodcode -> MaterialCode
          pxi_common.date_format(startdate, 'yyyymmdd', pxi_common.is_not_nullable) || -- startdate -> StartDate
          pxi_common.date_format(enddate, 'yyyymmdd', pxi_common.is_nullable) || -- enddate -> EndDate
          pxi_common.numb_format(listprice, '999999990.00', pxi_common.is_nullable) || -- listprice -> ListPrice
          pxi_common.char_format('NZD', 3, pxi_common.format_type_none, pxi_common.is_not_nullable) -- CONSTANT 'NZD' -> Currency
        ------------------------------------------------------------------------
        from (
        ------------------------------------------------------------------------
        -- SQL
        ------------------------------------------------------------------------
          select
              custcode,
              prodcode,
              startdate,
              enddate,
              PRICE1 as listprice
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
                           FROM lads_prc_lst_hdr/*@ap0064p_promax_testing*/ a,
                                lads_prc_lst_det/*@ap0064p_promax_testing*/ c,
                                mfanz_matl/*@ap0064p_promax_testing*/ f,
                                mfanz_fg_matl_clssfctn/*@ap0064p_promax_testing*/ g,
                                mfanz_matl_by_sales_area/*@ap0064p_promax_testing*/ h
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
                                AND c.loevm_ko IS NULL -- If this is marked 'X' it means the condition is no longer active
                                AND a.datbi >= TO_CHAR (SYSDATE, 'yyyymmdd')) t01) t01
          WHERE t01.rnkseq <= 3
          and cocode = '149'
        ------------------------------------------------------------------------
        );
        --======================================================================

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Retrieve the rows
      /*-*/
      open csr_input;
      loop
         fetch csr_input into var_data;
         if csr_input%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new interface when required
         /*-*/
         if lics_outbound_loader.is_created = false then
            var_instance := lics_outbound_loader.create_interface('PXIPMX06');
         end if;

         /*-*/
         /* Append the interface data
         /*-*/
         lics_outbound_loader.append_data(var_data);

      end loop;
      close csr_input;

      /*-*/
      /* Finalise the interface when required
      /*-*/
      if lics_outbound_loader.is_created = true then
         lics_outbound_loader.finalise_interface;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then
         rollback;
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end PXIPMX06_EXTRACT; 