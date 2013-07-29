create or replace 
package body          pxiatl01_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private definitions
   /*-*/
   con_group constant number := 900; -- Limit of 909 rows per IDOC when sending to ATLAS

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(i_datime in date default sysdate-7) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_data varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_input is
      
      SELECT RPAD(ref.belnr,35,' ') || 
             RPAD(ref.refnr,35,' ') || 
             RPAD(hdr.idoc_number,16,' ') || 
             TO_CHAR(hdr.lads_date,'yyyymmddhh24miss') 
              AS ladstr01
        FROM lads_sal_ord_hdr hdr, lads_sal_ord_ref ref
       WHERE hdr.belnr = ref.belnr
         AND UPPER(SUBSTR(ref.refnr,1,3)) = 'GAS'
         AND TRUNC(hdr.lads_date) >= TRUNC(i_datime)
       UNION SELECT '7580522177                         GAS-9000030040                     475223311       20121218102029' AS col1 from dual
       UNION SELECT '7580518038                         GAS-9000030022                     475235479       20121217163228' AS col1 from dual;

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
            var_instance := lics_outbound_loader.create_interface('LADSTR01');
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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

 

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   --function execute_old(par_int_id in number) return number is
   procedure execute_old(par_int_id in number) is

      /*-*/
      /* Local definitions
      /*-*/
      TYPE tbl_accrual IS TABLE OF VARCHAR2(220)
      INDEX BY BINARY_INTEGER;

      rcd_accrual_detail  tbl_accrual;
      rcd_reversal_detail tbl_accrual;
      
      var_exception varchar2(4000);
      var_history number;
      var_instance number(15,0);
      var_count integer;

      -- VARIABLE  DECLARATIONS
      v_instance             varchar2(8);
      var_result             number;
      v_data                 varchar2(4000);
      v_accrual_hdr          varchar2(4000);
      v_reversal_hdr         varchar2(4000);
      v_accrual_detail_summ  varchar2(4000);
      v_reversal_detail_summ varchar2(4000);
      v_accrual_tax          varchar2(4000);
      v_reversal_tax         varchar2(4000);
      v_item_count           binary_integer := 0;
      v_total_item_count     binary_integer := 0;
      v_start_item_count     binary_integer := 1;
      v_header_count         pls_integer := 0;
      v_total_accrl_amt      number(21,2) := 0;
      v_taxfree_base_amt     number(21,2) := 0;
      v_cmpny_code           varchar2(4);
      v_div_code             varchar2(4);
      v_cust_code            varchar2(10);
      v_acct_code            varchar2(20);
      v_currcy_code          varchar2(10);
      v_plant_code           varchar2(10);
      v_profit_ctr           varchar2(10);
      v_distbn_chnl_code     varchar2(10);
      v_previous_period_end  number(8);
      v_current_period_start number(8);
      v_item_processed       number := 0;

      -- EXCEPTION DECLARATIONS.
      e_processing_failure EXCEPTION;
      e_processing_error   EXCEPTION;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_accruals IS
        select 
            px_cmpny_code as cmpny_code,
            bus_sgmnt as div_code,
            allocation as cust_code,
            ' ' as cust_vndr_code,
            product_number as matl_zrep_code, 
            reference as prom_num,
            RPAD(NVL(LTRIM(int_claim_num),' '),18) as internal_claim_num,
            amount as accrl_amt,
            matl_tdu_code as matl_tdu_code,
            account as acct_code,
            plant_code as plant_code,
            profit_ctr_code as profit_ctr_code, 
            distbn_chnl_code as distbn_chnl_code,
            currency
        from 
            pmx_accrls t01 
        where 
            int_id = par_int_id
            and rec_type = 'D'
            and posting_key = 'DR';
        /*   
        WHERE
          cmpny_code = i_pmx_cmpny_code
          AND div_code = i_pmx_div_code
          AND valdtn_status = pc_valdtn_status_valid
          AND procg_status = pc_procg_status_processed;
         */
        
        rv_accruals csr_accruals%ROWTYPE;
      
      

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

   SELECT count(*) INTO v_total_item_count
    from 
        pmx_accrls t01 
    where 
        int_id = par_int_id
        and rec_type = 'D'
        and posting_key = 'DR';


  /*
  Retrieve the last day of the previous period.
  Note: The Interface is scheduled to run on the last day of the period (ie Saturday)
  just closed. The transaction date to be used for the Accrual is the same date (ie Last
  Saturday of the period just closed), irrespective of when the interface is actually run.
  This needs to be catered for in the interface. To allow for this we subtract 24 from
  the current (run) date. Provided it is run from the last Thursday of the Period up to
  23 days after the period end, it will always retrieve the dates of the period just closed.
  */
  SELECT MAX(yyyymmdd_date) INTO v_previous_period_end
  FROM mars_date
  WHERE mars_period = (SELECT MIN(mars_period)
                       FROM mars_date
                       WHERE calendar_date = trunc(SYSDATE - 24));
  /*
  Retrieve the first day of the current period.
  Note: The Interface is scheduled to run on the last day of the period (ie Saturday)
  just closed. The transaction date to be used for the Reversal is first day of the next
  period (ie First Sunday of the next period), irrespective of when the interface is
  actually run. This needs to be catered for in the interface. To allow for this we add
  4 to the current (run) date. Provided it is run from the lats Thursday of the Period
  up to 23 days after the period end, it will always retrieve the dates of the period
  following the period just closed.
  */
  SELECT TO_CHAR(MIN(yyyymmdd_date)) INTO v_current_period_start
  FROM mars_date
  WHERE mars_period = (SELECT mars_period
                       FROM mars_date
                       WHERE calendar_date = TRUNC(SYSDATE + 4));


  -- Read through each of the accrual records to be interfaced.
  OPEN csr_accruals;
  LOOP
  
    FETCH csr_accruals INTO rv_accruals;
    EXIT WHEN csr_accruals%NOTFOUND;

    v_item_count := v_item_count + 1;
    v_item_processed := v_item_processed + 1;

    v_total_accrl_amt := v_total_accrl_amt + rv_accruals.accrl_amt;
    v_taxfree_base_amt := v_taxfree_base_amt + rv_accruals.accrl_amt;

    
    v_acct_code := rv_accruals.acct_code;
    v_plant_code := rv_accruals.plant_code;
    v_profit_ctr := rv_accruals.profit_ctr_code;
    v_cmpny_code := rv_accruals.cmpny_code;
    v_currcy_code := rv_accruals.currency;
    
    -- Format Customer Code.
    var_result := pmx_common.format_cust_code (rv_accruals.cust_code,v_cust_code);
    
    -- Lookup the Distribution Channel Code.
    v_distbn_chnl_code := rv_accruals.distbn_chnl_code;
    IF v_distbn_chnl_code IS NULL THEN
      v_distbn_chnl_code := '10';
    END IF;

    
    
    -- Writing Accrual Detail records to array.
    rcd_accrual_detail(v_item_count) := 'G' ||
      LPAD(v_acct_code,10,0) ||
      TO_CHAR((rv_accruals.accrl_amt * 1),'9999999999999999999.99') ||
      -- GORDOSTE 20130320 - Add promo num and trim all leading zeroes in the text field
      RPAD( LTRIM(rv_accruals.matl_tdu_code, '0')  || ' ' ||
            LTRIM(v_cust_code, '0')                || ' ' ||
            LTRIM(rv_accruals.cust_vndr_code, '0') || ' ' ||
            LTRIM(rv_accruals.prom_num, '0'),
        50) ||
      rv_accruals.internal_claim_num ||
      'GL' ||
      RPAD(' ',10) || -- Cost Centre
      RPAD(' ',12) || -- Order Identification
      RPAD(' ',24) || -- WBS Element
      RPAD(' ',13) || -- Accrual Quantity
      RPAD(' ',3) || -- Accrual Quantity BUOM
      RPAD(NVL(rv_accruals.matl_tdu_code,' '),18) ||
      RPAD(v_plant_code,4) ||
      RPAD(v_cust_code,10) ||
      LPAD(v_profit_ctr,10,0) ||
      RPAD(v_cmpny_code,4) ||
      RPAD(v_distbn_chnl_code,2);

      
      
    -- Writing Accrual Reversal Detail records to array.
    rcd_reversal_detail(v_item_count) := 'G' ||
      LPAD(v_acct_code,10,0) ||
      TO_CHAR((rv_accruals.accrl_amt * -1),'9999999999999999999.99') ||
      -- GORDOSTE 20130320 - Add promo num and trim all leading zeroes in the text field
      RPAD( LTRIM(rv_accruals.matl_tdu_code, '0')  || ' ' ||
            LTRIM(v_cust_code, '0')                || ' ' ||
            LTRIM(rv_accruals.cust_vndr_code, '0') || ' ' ||
            LTRIM(rv_accruals.prom_num, '0'),
        50) ||
      rv_accruals.internal_claim_num ||
      'GL' ||
      RPAD(' ',10) || -- Cost Centre
      RPAD(' ',12) || -- Order Identification
      RPAD(' ',24) || -- WBS Element
      RPAD(' ',13) || -- Accrual Quantity
      RPAD(' ',3) || -- Accrual Quantity BUOM
      RPAD(NVL(rv_accruals.matl_tdu_code,' '),18) ||
      RPAD(v_plant_code,4) ||
      RPAD(v_cust_code,10) ||
      LPAD(v_profit_ctr,10,0) ||
      RPAD(v_cmpny_code,4) ||
      RPAD(v_distbn_chnl_code,2);
      
      
      
    /*
    If the record count has reached 900 or the total number of records to be processed
    has been reached then generate the creation of the extract file. Then continue
    processing records if there are more to be processed (i.e. greater than 900 records).

    Note: 909 (includes 9 SAP generated records) is the limitation of the number of
    records that can be contained within an IDOC loaded into Atlas.
    */
    IF (MOD(v_item_processed,900) = 0) OR v_item_processed = v_total_item_count THEN

      v_header_count := v_header_count + 1;

      -- Writing Accrual Header record.
      v_accrual_hdr := 'H' ||
        RPAD('IDOC',5) ||
        'PX' ||
        TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') ||
        LPAD(TO_CHAR(v_header_count),4,'0') ||
        'RFBU' ||
        RPAD('BATCHSCHE',12) ||
        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || rv_accruals.div_code ||
--        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || v_div_code ||
        TO_CHAR(SYSDATE,'YYYYMMDD'),25) ||
        RPAD(v_cmpny_code,4) ||
        RPAD(v_currcy_code,5) ||
        v_previous_period_end ||
        v_previous_period_end ||
        v_previous_period_end ||
        'ZA' ||
        RPAD(' ',16)  || -- Reference Document Number
        RPAD('PROMAX',10);

      -- Writing Accrual Reversal Header record.
      v_reversal_hdr := 'H' ||
        RPAD('IDOC',5) ||
        'PX' ||
        TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') ||
        LPAD(TO_CHAR(v_header_count),4,'0') ||
        'RFBU' ||
        RPAD('BATCHSCHE',12) ||
        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || rv_accruals.div_code ||
--        RPAD('Pmx Accr' || ' ' || LTRIM(RPAD(v_cmpny_code,4)) || v_div_code ||
        TO_CHAR(SYSDATE,'YYYYMMDD'),25) ||
        RPAD(v_cmpny_code,4) ||
        RPAD(v_currcy_code,5) ||
        v_current_period_start ||
        v_current_period_start ||
        v_current_period_start ||
        'ZB' ||
        RPAD(' ',16)  || -- Reference Document Number
        RPAD('PROMAX',10);

      -- Writing Accrual Detail Summary record.
      -- The Taxfree Base Amount is negative to offset the positive detail amounts in the
      -- Accrual Balance Sheet account.
      v_accrual_detail_summ := 'G0000955136' ||
        TO_CHAR((-(v_taxfree_base_amt)),'9999999999999999999.99') ||
        RPAD(' ',50) || -- Item Text
        RPAD(' ',18) || -- Allocation Number
        'GL' ||
        RPAD(' ',10) || -- Cost Centre
        RPAD(' ',12) || -- Order Identification
        RPAD(' ',24) || -- WBS Element
        RPAD(' ',13) || -- Accrual Quantity
        RPAD(' ',3) || -- Accrual Quantity BUOM
        RPAD(' ',18) || -- Material Code (Blank)
        RPAD(' ',4) || -- Plant Code (Blank)
        RPAD(' ',10) || -- Customer Code (Blank)
        LPAD(v_profit_ctr,10,0) ||
        RPAD(' ',4) || -- Company Code (Blank)
        RPAD(' ',2); -- Distribution Channel (Blank)

      -- Writing Reversal Detail Summary record.
      -- The Taxfree Base Amount is positive  to offset the negative detail amounts in the
      -- Accrual Balance Sheet account.
      v_reversal_detail_summ := 'G0000955136' ||
        TO_CHAR(((v_taxfree_base_amt)),'9999999999999999999.99') ||
        RPAD(' ',50) || -- Item Text
        RPAD(' ',18) || -- Allocation Number
        'GL' ||
        RPAD(' ',10) || -- Cost Centre
        RPAD(' ',12) || -- Order Identification
        RPAD(' ',24) || -- WBS Element
        RPAD(' ',13) || -- Accrual Quantity
        RPAD(' ',3) || -- Accrual Quantity BUOM
        RPAD(' ',18) || -- Material Code (Blank)
        RPAD(' ',4) || -- Plant Code (Blank)
        RPAD(' ',10) || -- Customer Code (Blank)
        LPAD(v_profit_ctr,10,0) ||
        RPAD(' ',4) || -- Company Code (Blank)
        RPAD(' ',2); -- Distribution Channel (Blank)

      -- Writing Accrual Tax record.
      v_accrual_tax := 'T' ||
        'GL' ||
        RPAD( ' ',20) ||
        '000' ||
        RPAD( ' ',16) ||
        '000' ||
        RPAD( ' ',8);

      -- Writing Reversal Tax record.
      v_reversal_tax := 'T' ||
        'GL' ||
        RPAD( ' ',20) ||
        '000' ||
        RPAD( ' ',16) ||
        '000' ||
        RPAD( ' ',8);

        
      -- Create the Accrual file.
      v_instance := lics_outbound_loader.create_interface('PXIATL01');
      
      -- Write Accrual records to the file.
      lics_outbound_loader.append_data(v_accrual_hdr);

      FOR i IN v_start_item_count..v_item_count LOOP
        lics_outbound_loader.append_data(rcd_accrual_detail(i));
      END LOOP;

      lics_outbound_loader.append_data(v_accrual_detail_summ);
      lics_outbound_loader.append_data(v_accrual_tax);

      -- Finalise the Accrual interface.
      lics_outbound_loader.finalise_interface;
      
      
      
     
      -- Create the Accrual Reversal file.
      v_instance := lics_outbound_loader.create_interface('PXIATL01');

      -- Write Accrual Reversal records to the file.
      lics_outbound_loader.append_data(v_reversal_hdr);

      FOR i IN v_start_item_count..v_item_count LOOP
        lics_outbound_loader.append_data(rcd_reversal_detail(i));
      END LOOP;

      lics_outbound_loader.append_data(v_reversal_detail_summ);
      lics_outbound_loader.append_data(v_reversal_tax);

      -- Finalise the Accrual Reversal interface.
      lics_outbound_loader.finalise_interface;
      
      
      
      /*
      dbms_output.put_line('Accrual Output');
      dbms_output.put_line(v_accrual_hdr);
      
      FOR i IN v_start_item_count..v_item_count LOOP
        dbms_output.put_line(rcd_accrual_detail(i));
      END LOOP;
      
      dbms_output.put_line(v_accrual_detail_summ);
      dbms_output.put_line(v_accrual_tax);
      dbms_output.put_line('Accrual End Out');
      
      
      dbms_output.put_line('Reversal Output');
      dbms_output.put_line(v_reversal_hdr);
      
      FOR i IN v_start_item_count..v_item_count LOOP
        dbms_output.put_line(rcd_reversal_detail(i));
      END LOOP;
      
      dbms_output.put_line(v_reversal_detail_summ);
      dbms_output.put_line(v_reversal_tax);
      dbms_output.put_line('Reversal End Out');
      */
      
      
      -- Reset variables.
      v_taxfree_base_amt := 0;
      v_item_count := 0;
      rcd_accrual_detail.DELETE;
      rcd_reversal_detail.DELETE;

    END IF;

  END LOOP;
  CLOSE csr_accruals;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if var_instance != -1 then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - PXIATL01 EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_old;

end pxiatl01_extract;