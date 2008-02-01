/******************/
/* Package Header */
/******************/
create or replace package edi_whslr_daily as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_whslr_daily
    Owner   : dw_app

    Description
    -----------
    Electronic Data Interchange - EDI Wholesaler Daily Invoicing

    This package contains the extract procedure for Wholesaler daily invoices. The
    package exposes one procedure EXECUTE that performs the extract based on the
    following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the EDI invoicing is to be performed.

    2. PAR_DATE (date in string format YYYYMMDD) (MANDATORY)

       The date for which the EDI invoicing is to be performed.

    **notes**
    1. A web log is produced under the search value EDI_WHOLESALER_DAILY_INVOICING where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2, par_date in varchar2);

end edi_whslr_daily;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_whslr_daily as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure create_invoices(par_company in varchar2, par_date in varchar2);
   procedure send_invoices(par_company in varchar2, par_date in varchar2);
   function overpunch_zoned(par_number in number, par_format in varchar2) return varchar2;

   /*-*/
   /* Private definitions
   /*-*/
   var_partner_code varchar2(128);
   var_partner_name varchar2(128);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company in varchar2, par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'EDI Wholesaler Daily Invoicing';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'EDI_INVOICING';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'EDI_INVOICING';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'EDI - WHOLESALER DAILY INVOICING';
      var_log_search := 'EDI_WHOLESALER_DAILY_INVOICING';
      var_loc_string := 'EDI_WHOLESALER_INVOICING' || '_' || par_company;
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_company) is null then
         raise_application_error(-20000, 'Company parameter must be supplied');
      end if;
      if upper(par_date) is null then
         raise_application_error(-20000, 'Date parameter must be supplied');
      end if;

      /*-*/
      /* Retrieve the Mars EDI partner name and code
      /*-*/
      var_partner_code := lics_setting_configuration.retrieve_setting('EDI_SYSTEM','PARTNER_CODE');
      var_partner_name := lics_setting_configuration.retrieve_setting('EDI_SYSTEM','PARTNER_NAME');
      if trim(var_partner_code) is null or trim(upper(var_partner_code)) = '*NONE' then
         raise_application_error(-20000, 'Mars EDI partner code not specified');
      end if;
      if trim(var_partner_name) is null or trim(upper(var_partner_name)) = '*NONE' then
         raise_application_error(-20000, 'Mars EDI partner name not specified');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - EDI Wholesaler Daily Invoicing - Parameters(' || par_company || ' + ' || par_date || ')');

      /*-*/
      /* Request the lock
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the wholesaler daily create procedure
         /*-*/
         begin
            create_invoices(par_company, par_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Execute the wholesaler daily send procedure when required
         /*-*/
         if var_errors = false then
            begin
               send_invoices(par_company, par_date);
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - EDI Wholesaler Daily Invoicing');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'EDI_INVOICING',
                                         var_email,
                                         'One or more errors occurred during the EDI Wholesaler Daily Invoicing execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;
      end if;

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EDI - WHOLESALER DAILY INVOICING - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*******************************************************/
   /* This procedure performs the create invoices routine */
   /*******************************************************/
   procedure create_invoices(par_company in varchar2, par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_invc_count number;
      var_qualf varchar2(30 char);
      var_parvw varchar2(30 char);
      var_langu varchar2(30 char);
      var_iddat varchar2(30 char);
      var_kschl varchar2(30 char);
      var_zcrp_count number;
      rcd_whslr_dly_inv_hdr whslr_dly_inv_hdr%rowtype;
      rcd_whslr_dly_inv_det whslr_dly_inv_det%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_inv_hdr is
         select t01.*
           from lads_inv_hdr t01,
                (select t01.belnr as belnr
                   from lads_inv_dat t01
                  where t01.iddat = '015'
                    and t01.datum = par_date
                  group by t01.belnr) T02,
                (select t01.belnr as belnr
                   from lads_inv_org t01
                  where t01.qualf = '003'
                    and t01.orgid = par_company
                  group by t01.belnr) t03
          where t01.belnr = t02.belnr
            and t01.belnr = t03.belnr
          order by t01.belnr asc;
      rcd_lads_inv_hdr csr_lads_inv_hdr%rowtype;

      cursor csr_lads_inv_org is
         select t01.*
           from lads_inv_org t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.qualf = var_qualf;
      rcd_lads_inv_org csr_lads_inv_org%rowtype;

      cursor csr_lads_inv_pnr is
         select t01.*
           from lads_inv_pnr t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.parvw = var_parvw;
      rcd_lads_inv_pnr csr_lads_inv_pnr%rowtype;

      cursor csr_lads_inv_adj is
         select t01.*
           from lads_inv_adj t01
          where t01.belnr = rcd_lads_inv_pnr.belnr
            and t01.pnrseq = rcd_lads_inv_pnr.pnrseq
            and t01.langu = var_langu;
      rcd_lads_inv_adj csr_lads_inv_adj%rowtype;

      cursor csr_lads_inv_ref is
         select t01.*
           from lads_inv_ref t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.qualf = var_qualf;
      rcd_lads_inv_ref csr_lads_inv_ref%rowtype;

      cursor csr_lads_inv_dat is
         select t01.*
           from lads_inv_dat t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.iddat = var_iddat;
      rcd_lads_inv_dat csr_lads_inv_dat%rowtype;

      cursor csr_lads_inv_con is
         select t01.*
           from lads_inv_con t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.kschl = var_kschl;
      rcd_lads_inv_con csr_lads_inv_con%rowtype;

      cursor csr_lads_inv_cus is
         select t01.*
           from lads_inv_cus t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.atnam = 'ZZ-JP_SHIPTO_TYPE'
            and t01.customer = rcd_whslr_dly_inv_hdr.sap_shpto_code;
      rcd_lads_inv_cus csr_lads_inv_cus%rowtype;

      cursor csr_lads_inv_gen is
         select t01.*
           from lads_inv_gen t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
          order by t01.genseq asc;
      rcd_lads_inv_gen csr_lads_inv_gen%rowtype;

      cursor csr_lads_inv_ipn is
         select t01.*
           from lads_inv_ipn t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.parvw = var_parvw;
      rcd_lads_inv_ipn csr_lads_inv_ipn%rowtype;

      cursor csr_lads_inv_iaj is
         select t01.*
           from lads_inv_iaj t01
          where t01.belnr = rcd_lads_inv_ipn.belnr
            and t01.genseq = rcd_lads_inv_ipn.genseq
            and t01.ipnseq = rcd_lads_inv_ipn.ipnseq
            and t01.langu = var_langu;
      rcd_lads_inv_iaj csr_lads_inv_iaj%rowtype;

      cursor csr_lads_inv_iob is
         select t01.*
           from lads_inv_iob t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.qualf = var_qualf;
      rcd_lads_inv_iob csr_lads_inv_iob%rowtype;

      cursor csr_lads_inv_mat is
         select t01.*
           from lads_inv_mat t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.langu = var_langu;
      rcd_lads_inv_mat csr_lads_inv_mat%rowtype;

      cursor csr_lads_inv_ias is
         select t01.*
           from lads_inv_ias t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.qualf = var_qualf;
      rcd_lads_inv_ias csr_lads_inv_ias%rowtype;

      cursor csr_lads_inv_icn is
         select t01.*
           from lads_inv_icn t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
          order by t01.icnseq;
      rcd_lads_inv_icn csr_lads_inv_icn%rowtype;

      cursor csr_lads_adr_hdr is
         select t02.sort1
           from lads_adr_hdr t01,
                lads_adr_det t02
          where t01.obj_type = t02.obj_type(+)
            and t01.obj_id = t02.obj_id(+)
            and t01.context = t02.context(+)
            and t01.obj_type = 'KNA1'
            and t01.context = 1
            and t02.addr_vers = 'K'
            and t01.obj_id = (select kunnr from lads_cus_pfr where substr(knref,5,7) = rcd_whslr_dly_inv_hdr.edi_brnch_code);
      rcd_lads_adr_hdr csr_lads_adr_hdr%rowtype;

      cursor csr_whslr is
         select t02.*
           from payer_link t01,
                whslr t02
          where t01.sap_payer_code = lads_trim_code(rcd_whslr_dly_inv_hdr.sap_payer_code)
            and upper(t01.edi_link_type) = '*WHSLR'
            and t01.edi_link_code = t02.edi_sndto_code;
      rcd_whslr csr_whslr%rowtype;

      cursor csr_whslr_transaction is
         select t01.*
           from whslr_transaction t01
          where (t01.sap_order_type = '*' or t01.sap_order_type = rcd_whslr_dly_inv_hdr.sap_order_type)
            and (t01.sap_invoice_type = '*' or t01.sap_invoice_type = rcd_whslr_dly_inv_hdr.sap_invoice_type)
            and (t01.edi_ship_to_type = '*' or t01.edi_ship_to_type = rcd_whslr_dly_inv_hdr.edi_ship_to_type)
          order by t01.sap_order_type desc,
                   t01.sap_invoice_type desc,
                   t01.edi_ship_to_type desc;
      rcd_whslr_transaction csr_whslr_transaction%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Wholesaler Create Daily Invoices');

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Deleting any existing wholesaler daily invoices for company and date');

      /*-*/
      /* Delete any existing invoice details for the company and date
      /*-*/
      delete from whslr_dly_inv_det
       where sap_company_code = par_company
         and sap_creatn_date = par_date;

      /*-*/
      /* Delete any existing invoice headers for the company and date
      /*-*/
      delete from whslr_dly_inv_hdr
       where sap_company_code = par_company
         and sap_creatn_date = par_date;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Creating wholesaler daily invoices for company and date');

      /*-*/
      /* Initialise the routine
      /*-*/
      var_invc_count := 0;

      /*-*/
      /* Retrieve the invoices for the parameter date and company
      /*-*/
      open csr_lads_inv_hdr;
      loop
         fetch csr_lads_inv_hdr into rcd_lads_inv_hdr;
         if csr_lads_inv_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the wholesaler invoice header
         /*-*/
         rcd_whslr_dly_inv_hdr.sap_company_code := par_company;
         rcd_whslr_dly_inv_hdr.sap_creatn_date := par_date;
         rcd_whslr_dly_inv_hdr.sap_invoice_number := rcd_lads_inv_hdr.belnr;
         rcd_whslr_dly_inv_hdr.sap_order_type := null;
         rcd_whslr_dly_inv_hdr.sap_invoice_type := null;
         rcd_whslr_dly_inv_hdr.sap_payer_code := null;
         rcd_whslr_dly_inv_hdr.sap_prmry_code := null;
         rcd_whslr_dly_inv_hdr.sap_scdry_code := null;
         rcd_whslr_dly_inv_hdr.sap_shpto_code := null;
         rcd_whslr_dly_inv_hdr.sap_refnr_number := null;
         rcd_whslr_dly_inv_hdr.edi_partn_code := var_partner_code;
         rcd_whslr_dly_inv_hdr.edi_partn_name := var_partner_name;
         rcd_whslr_dly_inv_hdr.edi_sndto_code := null;
         rcd_whslr_dly_inv_hdr.edi_whslr_code := null;
         rcd_whslr_dly_inv_hdr.edi_brnch_code := substr(rcd_lads_inv_hdr.expnr,5,8);
         rcd_whslr_dly_inv_hdr.edi_brnch_name := null;
         rcd_whslr_dly_inv_hdr.edi_sldto_code := null;
         rcd_whslr_dly_inv_hdr.edi_sldto_name := null;
         rcd_whslr_dly_inv_hdr.edi_shpto_code := null;
         rcd_whslr_dly_inv_hdr.edi_shpto_pcde := null;
         rcd_whslr_dly_inv_hdr.edi_shpto_name := null;
         rcd_whslr_dly_inv_hdr.edi_shpto_addr := null;
         rcd_whslr_dly_inv_hdr.edi_ordby_code := substr(rcd_lads_inv_hdr.expnr,5,8);
         rcd_whslr_dly_inv_hdr.edi_invoice_number := null;
         rcd_whslr_dly_inv_hdr.edi_invoice_date := null;
         rcd_whslr_dly_inv_hdr.edi_order_number := null;
         rcd_whslr_dly_inv_hdr.edi_order_date := null;
         rcd_whslr_dly_inv_hdr.edi_disc_code := null;
         rcd_whslr_dly_inv_hdr.edi_tran_code := null;
         rcd_whslr_dly_inv_hdr.edi_ship_to_type := null;
         rcd_whslr_dly_inv_hdr.edi_case_qty := 0;
         rcd_whslr_dly_inv_hdr.edi_amount := 0;
         rcd_whslr_dly_inv_hdr.edi_discount := 0;
         rcd_whslr_dly_inv_hdr.edi_balance := 0;
         rcd_whslr_dly_inv_hdr.edi_tax := 0;
         rcd_whslr_dly_inv_hdr.edi_value := 0;
         rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt := 0;
         rcd_whslr_dly_inv_hdr.edi_disc_volume_pct := 0;
         rcd_whslr_dly_inv_hdr.edi_disc_volume := 0;
         rcd_whslr_dly_inv_hdr.edi_disc_noreturn := 0;
         rcd_whslr_dly_inv_hdr.edi_disc_earlypay := 0;

         /*-*/
         /* Retrieve the invoice payer partner data (RG)
         /*-*/
         var_parvw := 'RG';
         open csr_lads_inv_pnr;
         fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
         if csr_lads_inv_pnr%found then
            rcd_whslr_dly_inv_hdr.sap_payer_code := rcd_lads_inv_pnr.partn;
         end if;
         close csr_lads_inv_pnr;

         /*-*/
         /* Only process wholesler invoices
         /* **notes** 1. The payer customer must exist in the payer link table (*WHSLR)
         /*-*/
         open csr_whslr;
         fetch csr_whslr into rcd_whslr;
         if csr_whslr%found then

            /*-*/
            /* Increment the invoice count
            /*-*/
            var_invc_count := var_invc_count + 1;

            /*-*/
            /* Set the wholesaler values
            /*-*/
            rcd_whslr_dly_inv_hdr.edi_sndto_code := rcd_whslr.edi_sndto_code;
            rcd_whslr_dly_inv_hdr.edi_whslr_code := rcd_whslr.edi_whslr_code;
            rcd_whslr_dly_inv_hdr.edi_disc_code := rcd_whslr.edi_disc_code;

            /*-*/
            /* Retrieve the invoice organisation data (012)
            /*-*/
            var_qualf := '012';
            open csr_lads_inv_org;
            fetch csr_lads_inv_org into rcd_lads_inv_org;
            if csr_lads_inv_org%found then
               rcd_whslr_dly_inv_hdr.sap_order_type := rcd_lads_inv_org.orgid;
            end if;
            close csr_lads_inv_org;

            /*-*/
            /* Retrieve the invoice organisation data (015)
            /*-*/
            var_qualf := '015';
            open csr_lads_inv_org;
            fetch csr_lads_inv_org into rcd_lads_inv_org;
            if csr_lads_inv_org%found then
               rcd_whslr_dly_inv_hdr.sap_invoice_type := rcd_lads_inv_org.orgid;
            end if;
            close csr_lads_inv_org;

            /*-*/
            /* Retrieve the invoice partner data (AG)
            /*-*/
            var_parvw := 'AG';
            open csr_lads_inv_pnr;
            fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
            if csr_lads_inv_pnr%found then

               /*-*/
               /* Set the values
               /*-*/
               rcd_whslr_dly_inv_hdr.sap_prmry_code := rcd_lads_inv_pnr.partn;

            end if;
            close csr_lads_inv_pnr;

            /*-*/
            /* Retrieve the invoice partner data (Z5)
            /*-*/
            var_parvw := 'Z5';
            open csr_lads_inv_pnr;
            fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
            if csr_lads_inv_pnr%found then

               /*-*/
               /* Set the values
               /*-*/
               rcd_whslr_dly_inv_hdr.sap_scdry_code := rcd_lads_inv_pnr.partn;
               rcd_whslr_dly_inv_hdr.edi_sldto_code := substr(rcd_lads_inv_pnr.knref,5,8);

               /*-*/
               /* Retrieve the invoice partner address data (Z5/Z3)
               /*-*/
               var_langu := 'Z3';
               open csr_lads_inv_adj;
               fetch csr_lads_inv_adj into rcd_lads_inv_adj;
               if csr_lads_inv_adj%found then
                  rcd_whslr_dly_inv_hdr.edi_sldto_name := substr(rcd_lads_inv_adj.name1,1,30);
               end if;
               close csr_lads_inv_adj;

            end if;
            close csr_lads_inv_pnr;

            /*-*/
            /* Retrieve data from the first invoice line
            /*-*/
            open csr_lads_inv_gen;
            fetch csr_lads_inv_gen into rcd_lads_inv_gen;
            if csr_lads_inv_gen%found then

               /*-*/
               /* Retrieve the invoice item partner data (WE)
               /*-*/
               var_parvw := 'WE';
               open csr_lads_inv_ipn;
               fetch csr_lads_inv_ipn into rcd_lads_inv_ipn;
               if csr_lads_inv_ipn%found then

                  /*-*/
                  /* Set the ship to data
                  /*-*/
                  rcd_whslr_dly_inv_hdr.sap_shpto_code := rcd_lads_inv_ipn.partn;
                  rcd_whslr_dly_inv_hdr.edi_shpto_code := substr(rcd_lads_inv_ipn.ilnnr,5,8);
                  rcd_whslr_dly_inv_hdr.edi_shpto_pcde := substr(rcd_lads_inv_ipn.pstlz,1,7);

                  /*-*/
                  /* Retrieve the invoice item partner address data (WE/Z3)
                  /*-*/
                  var_langu := 'Z3';
                  open csr_lads_inv_iaj;
                  fetch csr_lads_inv_iaj into rcd_lads_inv_iaj;
                  if csr_lads_inv_iaj%found then
                     rcd_whslr_dly_inv_hdr.edi_shpto_name := substr(rcd_lads_inv_iaj.name1,1,40);
                     rcd_whslr_dly_inv_hdr.edi_shpto_addr := substr(rcd_lads_inv_iaj.street||' '||rcd_lads_inv_iaj.city1,1,50);
                  end if;
                  close csr_lads_inv_iaj;

               end if;
               close csr_lads_inv_ipn;

            end if;
            close csr_lads_inv_gen;

            /*-*/
            /* Retrieve the invoice date data (024)
            /*-*/
            var_iddat := '024';
            open csr_lads_inv_dat;
            fetch csr_lads_inv_dat into rcd_lads_inv_dat;
            if csr_lads_inv_dat%found then
               rcd_whslr_dly_inv_hdr.edi_invoice_date := rcd_lads_inv_dat.datum;
            end if;
            close csr_lads_inv_dat;

            /*-*/
            /* Retrieve the invoice reference data (001)
            /*-*/
            var_qualf := '001';
            open csr_lads_inv_ref;
            fetch csr_lads_inv_ref into rcd_lads_inv_ref;
            if csr_lads_inv_ref%found then
               rcd_whslr_dly_inv_hdr.edi_order_number := rcd_lads_inv_ref.refnr;
               rcd_whslr_dly_inv_hdr.edi_order_date := rcd_lads_inv_ref.datum;
            end if;
            close csr_lads_inv_ref;

            /*-*/
            /* Retrieve the invoice reference data (012)
            /*-*/
            var_qualf := '012';
            open csr_lads_inv_ref;
            fetch csr_lads_inv_ref into rcd_lads_inv_ref;
            if csr_lads_inv_ref%found then
               rcd_whslr_dly_inv_hdr.sap_refnr_number := rcd_lads_inv_ref.refnr;
            end if;
            close csr_lads_inv_ref;

            /*-*/
            /* Retrieve the invoice condition data (MWST)
            /*-*/
            var_kschl := 'MWST';
            open csr_lads_inv_con;
            fetch csr_lads_inv_con into rcd_lads_inv_con;
            if csr_lads_inv_con%found then
               rcd_whslr_dly_inv_hdr.edi_tax := nvl(rcd_lads_inv_con.kwert,0) * 100;
            end if;
            close csr_lads_inv_con;

            /*-*/
            /* Retrieve the wholesaler branch name
            /*-*/
            open csr_lads_adr_hdr;
            fetch csr_lads_adr_hdr into rcd_lads_adr_hdr;
            if csr_lads_adr_hdr%found then
               rcd_whslr_dly_inv_hdr.edi_brnch_name := rcd_lads_adr_hdr.sort1;
            end if;
            close csr_lads_adr_hdr;

            /*-*/
            /* Retrieve the EDI delivery number
            /*-*/
            if rcd_whslr_dly_inv_hdr.sap_invoice_type = 'ZS1' or
               rcd_whslr_dly_inv_hdr.sap_invoice_type = 'ZS2' then
               rcd_whslr_dly_inv_hdr.edi_invoice_number := rcd_whslr_dly_inv_hdr.sap_invoice_number;
            elsif not(trim(rcd_whslr_dly_inv_hdr.sap_refnr_number) is null) then
               rcd_whslr_dly_inv_hdr.edi_invoice_number := rcd_whslr_dly_inv_hdr.sap_refnr_number;
            else
               rcd_whslr_dly_inv_hdr.edi_invoice_number := rcd_whslr_dly_inv_hdr.sap_invoice_number;
            end if;
            if substr(rcd_whslr_dly_inv_hdr.edi_invoice_number,1,2) = '70' then
               rcd_whslr_dly_inv_hdr.edi_invoice_number := substr(rcd_whslr_dly_inv_hdr.edi_invoice_number,3);
               rcd_whslr_dly_inv_hdr.edi_invoice_number := substr(rpad(' ',10,' ')||rcd_whslr_dly_inv_hdr.edi_invoice_number,length(rcd_whslr_dly_inv_hdr.edi_invoice_number)+1,10);
            end if;

            /*-*/
            /* Retrieve the EDI ship to type
            /*-*/
            if not(rcd_whslr_dly_inv_hdr.sap_scdry_code is null) and
               rcd_whslr_dly_inv_hdr.sap_scdry_code = rcd_whslr_dly_inv_hdr.sap_shpto_code then
               rcd_whslr_dly_inv_hdr.edi_ship_to_type := '2';
            else
               open csr_lads_inv_cus;
               fetch csr_lads_inv_cus into rcd_lads_inv_cus;
               if csr_lads_inv_cus%found then
                  rcd_whslr_dly_inv_hdr.edi_ship_to_type := rcd_lads_inv_cus.atwrt;
               end if;
               close csr_lads_inv_cus;
            end if;

            /*-*/
            /* Retrieve the EDI transaction code
            /*-*/
            open csr_whslr_transaction;
            fetch csr_whslr_transaction into rcd_whslr_transaction;
            if csr_whslr_transaction%found then
               rcd_whslr_dly_inv_hdr.edi_tran_code := rcd_whslr_transaction.edi_tran_code;
            end if;
            close csr_whslr_transaction;

            /*-*/
            /* Convert the EDI ship to type
            /*-*/
            if rcd_whslr_dly_inv_hdr.edi_ship_to_type = '1' then
               rcd_whslr_dly_inv_hdr.edi_ship_to_type := '1';
            elsif rcd_whslr_dly_inv_hdr.edi_ship_to_type = '2' then
               rcd_whslr_dly_inv_hdr.edi_ship_to_type := '3';
            elsif rcd_whslr_dly_inv_hdr.edi_ship_to_type = '3' then
               rcd_whslr_dly_inv_hdr.edi_ship_to_type := '2';
            end if;

            /*-*/
            /* Insert the wholesaler invoice header row
            /*-*/
            insert into whslr_dly_inv_hdr values rcd_whslr_dly_inv_hdr;

            /*-*/
            /* Retrieve the invoice line data
            /*-*/
            open csr_lads_inv_gen;
            loop
               fetch csr_lads_inv_gen into rcd_lads_inv_gen;
               if csr_lads_inv_gen%notfound then
                  exit;
               end if;

               /*-*/
               /* Only process non-zero lines
               /*-*/
               if nvl(lads_to_number(rcd_lads_inv_gen.menge),'0') != 0 then

                  /*-*/
                  /* Initialise the wholesaler invoice detail
                  /*-*/
                  rcd_whslr_dly_inv_det.sap_company_code := par_company;
                  rcd_whslr_dly_inv_det.sap_creatn_date := par_date;
                  rcd_whslr_dly_inv_det.sap_invoice_number := rcd_lads_inv_gen.belnr;
                  rcd_whslr_dly_inv_det.sap_invoice_line := rcd_lads_inv_gen.genseq;
                  rcd_whslr_dly_inv_det.sap_unit_price := 0;
                  rcd_whslr_dly_inv_det.sap_amount := 0;
                  rcd_whslr_dly_inv_det.sap_disc_volume_pct := 0;
                  rcd_whslr_dly_inv_det.sap_disc_volume := 0;
                  rcd_whslr_dly_inv_det.sap_disc_noreturn := 0;
                  rcd_whslr_dly_inv_det.sap_disc_earlypay := 0;
                  rcd_whslr_dly_inv_det.edi_material_code := null;
                  rcd_whslr_dly_inv_det.edi_material_name := null;
                  rcd_whslr_dly_inv_det.edi_rsu_per_tdu := nvl(lads_to_number(rcd_lads_inv_gen.rsu_per_tdu),'0');
                  rcd_whslr_dly_inv_det.edi_case_qty := 0;
                  rcd_whslr_dly_inv_det.edi_delivered_qty := 0;
                  rcd_whslr_dly_inv_det.edi_unit_price := 0;
                  rcd_whslr_dly_inv_det.edi_amount := 0;
                  if trim(rcd_lads_inv_gen.menee) = 'CS' then
                     rcd_whslr_dly_inv_det.edi_case_qty := nvl(lads_to_number(rcd_lads_inv_gen.menge),'0');
                     rcd_whslr_dly_inv_det.edi_delivered_qty := rcd_whslr_dly_inv_det.edi_rsu_per_tdu * rcd_whslr_dly_inv_det.edi_case_qty;
                  else
                     rcd_whslr_dly_inv_det.edi_delivered_qty := nvl(lads_to_number(rcd_lads_inv_gen.menge),'0');
                  end if;

                  /*-*/
                  /* Retrieve the invoice line object identification data (R01)
                  /*-*/
                  var_qualf := 'R01';
                  open csr_lads_inv_iob;
                  fetch csr_lads_inv_iob into rcd_lads_inv_iob;
                  if csr_lads_inv_iob%found then
                     rcd_whslr_dly_inv_det.edi_material_code := rcd_lads_inv_iob.idtnr;
                  end if;
                  close csr_lads_inv_iob;

                  /*-*/
                  /* Retrieve the invoice line object identification data (003) when required
                  /*-*/
                  if rcd_whslr_dly_inv_det.edi_material_code is null then
                     var_qualf := '003';
                     open csr_lads_inv_iob;
                     fetch csr_lads_inv_iob into rcd_lads_inv_iob;
                     if csr_lads_inv_iob%found then
                        rcd_whslr_dly_inv_det.edi_material_code := substr(rcd_lads_inv_iob.idtnr,1,35);
                     end if;
                     close csr_lads_inv_iob;
                  end if;

                  /*-*/
                  /* Retrieve the invoice line material data (JA)
                  /*-*/
                  var_langu := 'JA';
                  open csr_lads_inv_mat;
                  fetch csr_lads_inv_mat into rcd_lads_inv_mat;
                  if csr_lads_inv_mat%found then
                     rcd_whslr_dly_inv_det.edi_material_name := substr(rcd_lads_inv_mat.maktx,1,40);
                  end if;
                  close csr_lads_inv_mat;

                  /*-*/
                  /* Retrieve the invoice line item amount (901)
                  /*-*/
                  var_qualf := '901';
                  open csr_lads_inv_ias;
                  fetch csr_lads_inv_ias into rcd_lads_inv_ias;
                  if csr_lads_inv_ias%found then
                     rcd_whslr_dly_inv_det.sap_unit_price := nvl(lads_to_number(rcd_lads_inv_ias.krate),0);
                     rcd_whslr_dly_inv_det.sap_amount := nvl(lads_to_number(rcd_lads_inv_ias.betrg),0);
                  end if;
                  close csr_lads_inv_ias;

                  /*-*/
                  /* Retrieve the invoice item condition data
                  /*-*/
                  var_zcrp_count := 0;
                  open csr_lads_inv_icn;
                  loop
                     fetch csr_lads_inv_icn into rcd_lads_inv_icn;
                     if csr_lads_inv_icn%notfound then
                        exit;
                     end if;
                     if rcd_lads_inv_icn.kschl = 'ZCRP' then
                        var_zcrp_count := 1;
                        rcd_whslr_dly_inv_det.sap_disc_volume_pct := nvl(lads_to_number(rcd_lads_inv_icn.kperc),0);
                        rcd_whslr_dly_inv_det.sap_disc_volume := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0);
                     end if;
                     if rcd_lads_inv_icn.kschl = 'ZK25' then
                        rcd_whslr_dly_inv_det.sap_disc_noreturn := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0);
                     end if;
                     if rcd_lads_inv_icn.kschl = 'ZK60' then
                        rcd_whslr_dly_inv_det.sap_disc_earlypay := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0);
                     end if;
                  end loop;
                  close csr_lads_inv_icn;

                  /*-*/
                  /* Set the EDI values
                  /*-*/
                  if rcd_whslr_dly_inv_det.edi_rsu_per_tdu = 0 then
                     rcd_whslr_dly_inv_det.edi_unit_price := rcd_whslr_dly_inv_det.sap_unit_price * 100;
                  else
                     rcd_whslr_dly_inv_det.edi_unit_price := (rcd_whslr_dly_inv_det.sap_unit_price * 100) / rcd_whslr_dly_inv_det.edi_rsu_per_tdu;
                  end if;
                  if rcd_whslr_dly_inv_det.edi_case_qty = 0 then
                     rcd_whslr_dly_inv_det.edi_amount := rcd_whslr_dly_inv_det.sap_unit_price;
                  else
                     rcd_whslr_dly_inv_det.edi_amount := rcd_whslr_dly_inv_det.sap_unit_price * rcd_whslr_dly_inv_det.edi_case_qty;
                  end if;

                  /*-*/
                  /* Accumulate the EDI total values
                  /*-*/
                  rcd_whslr_dly_inv_hdr.edi_case_qty := rcd_whslr_dly_inv_hdr.edi_case_qty + rcd_whslr_dly_inv_det.edi_case_qty;
                  rcd_whslr_dly_inv_hdr.edi_amount := rcd_whslr_dly_inv_hdr.edi_amount + rcd_whslr_dly_inv_det.edi_amount;
                  rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt := rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt + var_zcrp_count;
                  rcd_whslr_dly_inv_hdr.edi_disc_volume_pct := rcd_whslr_dly_inv_hdr.edi_disc_volume_pct + abs(rcd_whslr_dly_inv_det.sap_disc_volume_pct);
                  rcd_whslr_dly_inv_hdr.edi_disc_volume := rcd_whslr_dly_inv_hdr.edi_disc_volume - rcd_whslr_dly_inv_det.sap_disc_volume;
                  if rcd_whslr_dly_inv_hdr.edi_disc_code = 'A' then
                     rcd_whslr_dly_inv_hdr.edi_disc_noreturn := rcd_whslr_dly_inv_hdr.edi_disc_noreturn - rcd_whslr_dly_inv_det.sap_disc_noreturn;
                     rcd_whslr_dly_inv_hdr.edi_disc_earlypay := rcd_whslr_dly_inv_hdr.edi_disc_earlypay - rcd_whslr_dly_inv_det.sap_disc_earlypay;
                  end if;

                  /*-*/
                  /* Insert the wholesaler invoice detail row
                  /*-*/
                  insert into whslr_dly_inv_det values rcd_whslr_dly_inv_det;

               end if;

            end loop;
            close csr_lads_inv_gen;

            /*-*/
            /* Update the wholesaler invoice header row
            /*-*/
            rcd_whslr_dly_inv_hdr.edi_discount := rcd_whslr_dly_inv_hdr.edi_disc_volume + rcd_whslr_dly_inv_hdr.edi_disc_earlypay + rcd_whslr_dly_inv_hdr.edi_disc_noreturn;
            rcd_whslr_dly_inv_hdr.edi_balance := rcd_whslr_dly_inv_hdr.edi_amount + rcd_whslr_dly_inv_hdr.edi_discount;
            rcd_whslr_dly_inv_hdr.edi_value := rcd_whslr_dly_inv_hdr.edi_balance + rcd_whslr_dly_inv_hdr.edi_tax;
            update whslr_dly_inv_hdr
               set edi_case_qty = rcd_whslr_dly_inv_hdr.edi_case_qty,
                   edi_amount = rcd_whslr_dly_inv_hdr.edi_amount,
                   edi_discount = rcd_whslr_dly_inv_hdr.edi_discount,
                   edi_balance = rcd_whslr_dly_inv_hdr.edi_balance,
                   edi_tax = rcd_whslr_dly_inv_hdr.edi_tax,
                   edi_value = rcd_whslr_dly_inv_hdr.edi_value,
                   edi_disc_volume_cnt = rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt,
                   edi_disc_volume_pct = rcd_whslr_dly_inv_hdr.edi_disc_volume_pct,
                   edi_disc_volume = rcd_whslr_dly_inv_hdr.edi_disc_volume,
                   edi_disc_noreturn = rcd_whslr_dly_inv_hdr.edi_disc_noreturn,
                   edi_disc_earlypay = rcd_whslr_dly_inv_hdr.edi_disc_earlypay
             where sap_invoice_number = rcd_whslr_dly_inv_hdr.sap_invoice_number;

         end if;
         close csr_whslr;

      end loop;
      close csr_lads_inv_hdr;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Created (' || to_char(var_invc_count,'fm999999990') || ') wholesaler daily invoices');

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Wholesaler Create Daily Invoices');

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - Wholesaler Create Daily Invoices - ' || var_exception);
            lics_logging.write_log('End - Wholesaler Create Daily Invoices');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_invoices;

   /*****************************************************/
   /* This procedure performs the send invoices routine */
   /*****************************************************/
   procedure send_invoices(par_company in varchar2, par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(4000);
      var_sndto_save varchar2(128);
      var_invc_count number;
      var_row_count number;
      var_data_type varchar2(2);
      var_maker_code varchar2(7);
      var_process_date varchar2(2);
      var_send_process_date varchar2(6);
      var_send_process_time varchar2(6);
      type typ_outbound is table of varchar2(4000) index by binary_integer;
      tbl_outbound typ_outbound;
      /*-*/
      var_fh_data_type varchar2(128 char);
      var_fh_maker_code varchar2(128 char);
      var_fh_process_date varchar2(128 char);
      var_fh_sequential_number varchar2(128 char);
      var_fh_record_type varchar2(128 char);
      var_fh_send_process_date varchar2(128 char);
      var_fh_send_process_time varchar2(128 char);
      var_fh_final_receiver varchar2(128 char);
      var_fh_relay_receiver varchar2(128 char);
      var_fh_relay_sender varchar2(128 char);
      var_fh_relay_send_date varchar2(128 char);
      var_fh_relay_send_time varchar2(128 char);
      var_fh_relay_send_data_1 varchar2(128 char);
      var_fh_relay_send_data_2 varchar2(128 char);
      var_fh_reserved_field_1 varchar2(128 char);
      var_fh_filler varchar2(128 char);
      var_fh_relay_send_initial varchar2(128 char);
      var_fh_reserved_field_2 varchar2(128 char);
      /*-*/
      var_h1_data_type varchar2(128 char);
      var_h1_maker_code varchar2(128 char);
      var_h1_process_date varchar2(128 char);
      var_h1_sequential_number varchar2(128 char);
      var_h1_record_type varchar2(128 char);
      var_h1_bill_to_party_code varchar2(128 char);
      var_h1_transaction_type varchar2(128 char);
      var_h1_purchase_order_no varchar2(128 char);
      var_h1_purchase_order_date varchar2(128 char);
      var_h1_classification_code varchar2(128 char);
      var_h1_document_type varchar2(128 char);
      var_h1_partner_code varchar2(128 char);
      var_h1_account_code varchar2(128 char);
      var_h1_invoice_date varchar2(128 char);
      var_h1_invoice_number varchar2(128 char);
      var_h1_billing_date varchar2(128 char);
      var_h1_partner_name varchar2(128 char);
      var_h1_ship_to_party_type varchar2(128 char);
      var_h1_adjustment varchar2(128 char);
      var_h1_order_party_code varchar2(128 char);
      var_h1_reserved_field varchar2(128 char);
      /*-*/
      var_h2_data_type varchar2(128 char);
      var_h2_maker_code varchar2(128 char);
      var_h2_process_date varchar2(128 char);
      var_h2_sequential_number varchar2(128 char);
      var_h2_record_type varchar2(128 char);
      var_h2_sold_to_party_code varchar2(128 char);
      var_h2_sold_to_party_name varchar2(128 char);
      var_h2_reserved_field varchar2(128 char);
      /*-*/
      var_h3_data_type varchar2(128 char);
      var_h3_maker_code varchar2(128 char);
      var_h3_process_date varchar2(128 char);
      var_h3_sequential_number varchar2(128 char);
      var_h3_record_type varchar2(128 char);
      var_h3_ship_to_party_code varchar2(128 char);
      var_h3_ship_to_party_name varchar2(128 char);
      var_h3_ship_to_party_post_code varchar2(128 char);
      var_h3_reserved_field_1 varchar2(128 char);
      var_h3_ship_to_party_addess varchar2(128 char);
      var_h3_reserved_field_2 varchar2(128 char);
      /*-*/
      var_l1_data_type varchar2(128 char);
      var_l1_maker_code varchar2(128 char);
      var_l1_process_date varchar2(128 char);
      var_l1_sequential_number varchar2(128 char);
      var_l1_record_type varchar2(128 char);
      var_l1_line_item_number varchar2(128 char);
      var_l1_material_code_type varchar2(128 char);
      var_l1_material_code varchar2(128 char);
      var_l1_material_name varchar2(128 char);
      var_l1_piece_qty varchar2(128 char);
      var_l1_case_qty varchar2(128 char);
      var_l1_order_qty varchar2(128 char);
      var_l1_paid_qty varchar2(128 char);
      var_l1_free_qty varchar2(128 char);
      var_l1_unit_price varchar2(128 char);
      var_l1_price_unit varchar2(128 char);
      var_l1_amount varchar2(128 char);
      var_l1_type_of_set_package varchar2(128 char);
      var_l1_number_of_combined_box varchar2(128 char);
      var_l1_reserved_field varchar2(128 char);
      /*-*/
      var_t1_data_type varchar2(128 char);
      var_t1_maker_code varchar2(128 char);
      var_t1_process_date varchar2(128 char);
      var_t1_sequential_number varchar2(128 char);
      var_t1_record_type varchar2(128 char);
      var_t1_total_case_qty varchar2(128 char);
      var_t1_total_amount varchar2(128 char);
      var_t1_total_discount_amount varchar2(128 char);
      var_t1_net_amount_after_disc varchar2(128 char);
      var_t1_remarks_a varchar2(128 char);
      var_t1_remarks_1_for_order_no varchar2(128 char);
      var_t1_remarks_1_for_comments varchar2(128 char);
      var_t1_discount_pc varchar2(128 char);
      var_t1_volume_discount varchar2(128 char);
      var_t1_early_pmt_disc varchar2(128 char);
      var_t1_no_return_disc varchar2(128 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_dly_inv_hdr is
         select t01.*
           from whslr_dly_inv_hdr t01
          where t01.sap_company_code = par_company
            and t01.sap_creatn_date = par_date
          order by t01.edi_sndto_code asc,
                   t01.sap_invoice_number asc;
      rcd_whslr_dly_inv_hdr csr_whslr_dly_inv_hdr%rowtype;

      cursor csr_whslr_dly_inv_det is
         select t01.*
           from whslr_dly_inv_det t01
          where t01.sap_invoice_number = rcd_whslr_dly_inv_hdr.sap_invoice_number
          order by t01.sap_invoice_line asc;
      rcd_whslr_dly_inv_det csr_whslr_dly_inv_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_data_type := 'K1';
      var_maker_code := '02397';
      var_process_date := to_char(sysdate,'dd');
      var_send_process_date := to_char(sysdate,'yymmdd');
      var_send_process_time := to_char(sysdate,'hhmiss');
      var_invc_count := 0;
      var_row_count := 0;
      tbl_outbound.delete;

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Wholesaler Send Daily Invoices');

      /*-*/
      /* Retrieve the wholesaler invoices for the parameter date and company
      /*-*/
      var_sndto_save := null;
      open csr_whslr_dly_inv_hdr;
      loop
         fetch csr_whslr_dly_inv_hdr into rcd_whslr_dly_inv_hdr;
         if csr_whslr_dly_inv_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Change in wholesaler
         /*-*/
         if var_sndto_save is null or
            var_sndto_save != rcd_whslr_dly_inv_hdr.edi_sndto_code then

            /*-*/
            /* Process the previous wholesaler when required
            /*-*/
            if not(var_sndto_save is null) then

               /*-*/
               /* Log the event
               /*-*/
               lics_logging.write_log('Sent (' || to_char(var_invc_count,'fm999999990') || ') daily invoices to Wholesaler (' || var_sndto_save || ')');

            end if;

            /*-*/
            /* Initialise the new wholesaler
            /*-*/
            var_sndto_save := rcd_whslr_dly_inv_hdr.edi_sndto_code;
            var_invc_count := 0;
            var_row_count := 0;

            /*-*/
            /* Set the FH record data
            /*-*/
            var_fh_data_type := lads_right_pad(var_data_type,2,' ');
            var_fh_maker_code := lads_right_pad(var_maker_code,7,' ');
            var_fh_process_date := lads_right_pad(var_process_date,2,' ');
            var_fh_sequential_number := to_char(var_row_count,'fm00000');
            var_fh_record_type := lads_right_pad('FH',2,' ');
            var_fh_send_process_date := lads_right_pad(var_send_process_date,6,' ');
            var_fh_send_process_time := lads_right_pad(var_send_process_time,6,' ');
            var_fh_final_receiver := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_sndto_code,1,8),8,' ');
            var_fh_relay_receiver := lads_right_pad(' ',8,' ');
            var_fh_relay_sender := lads_right_pad(' ',8,' ');
            var_fh_relay_send_date := lads_right_pad(' ',6,' ');
            var_fh_relay_send_time := lads_right_pad(' ',6,' ');
            var_fh_relay_send_data_1 := lads_right_pad(' ',6,' ');
            var_fh_relay_send_data_2 := lads_right_pad(' ',6,' ');
            var_fh_reserved_field_1 := lads_right_pad(' ',22,' ');
            var_fh_filler := lads_right_pad(' ',17,' ');
            var_fh_relay_send_initial := lads_right_pad(' ',8,' ');
            var_fh_reserved_field_2 := lads_right_pad(' ',3,' ');

            /*-*/
            /* Output the FH record data
            /*-*/
            var_output := var_fh_data_type;
            var_output := var_output || var_fh_maker_code;
            var_output := var_output || var_fh_process_date;
            var_output := var_output || var_fh_sequential_number;
            var_output := var_output || var_fh_record_type;
            var_output := var_output || var_fh_send_process_date;
            var_output := var_output || var_fh_send_process_time;
            var_output := var_output || var_fh_final_receiver;
            var_output := var_output || var_fh_relay_receiver;
            var_output := var_output || var_fh_relay_sender;
            var_output := var_output || var_fh_relay_send_date;
            var_output := var_output || var_fh_relay_send_time;
            var_output := var_output || var_fh_relay_send_data_1;
            var_output := var_output || var_fh_relay_send_data_2;
            var_output := var_output || var_fh_reserved_field_1;
            var_output := var_output || var_fh_filler;
            var_output := var_output || var_fh_relay_send_initial;
            var_output := var_output || var_fh_reserved_field_2;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end if;

         /*-*/
         /* Increment the invoice count
         /*-*/
         var_invc_count := var_invc_count + 1;

         /*-*/
         /* Increment the row count
         /*-*/
         var_row_count := var_row_count + 1;

         /*-*/
         /* Set the H1 record data
         /*-*/
         var_h1_data_type := lads_right_pad(var_data_type,2,' ');
         var_h1_maker_code := lads_right_pad(var_maker_code,7,' ');
         var_h1_process_date := lads_right_pad(var_process_date,2,' ');
         var_h1_sequential_number := to_char(var_row_count,'fm00000');
         var_h1_record_type := lads_right_pad('H1',2,' ');
         var_h1_bill_to_party_code := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_brnch_code,1,8),8,' ');
         var_h1_transaction_type := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_tran_code,1,2),2,' ');
         if length(rcd_whslr_dly_inv_hdr.edi_order_number) > 8 then
            var_h1_purchase_order_no := lads_left_pad(substr(lads_trim_code(rcd_whslr_dly_inv_hdr.edi_order_number),1,8),8,'0');
         else
            var_h1_purchase_order_no := lads_left_pad(substr(rcd_whslr_dly_inv_hdr.edi_order_number,1,8),8,'0');
         end if;
         var_h1_purchase_order_date := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_order_date,3,6),6,' ');
         var_h1_classification_code := lads_right_pad(' ',6,' ');
         var_h1_document_type := lads_right_pad(' ',2,' ');
         var_h1_partner_code := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_partn_code,1,7),7,' ');
         var_h1_account_code := lads_right_pad(' ',1,' ');
         var_h1_invoice_date := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_invoice_date,3,6),6,' ');
         var_h1_invoice_number := lads_left_pad(substr(rcd_whslr_dly_inv_hdr.edi_invoice_number,1,10),10,'0');
         var_h1_billing_date := lads_right_pad(' ',6,' ');
         var_h1_partner_name := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_partn_name,1,25),25,' ');
         var_h1_ship_to_party_type := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_ship_to_type,1,1),1,' ');
         var_h1_adjustment := lads_right_pad(' ',1,' ');
         var_h1_order_party_code := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_ordby_code,1,8),8,' ');
         var_h1_reserved_field := lads_right_pad(' ',13,' ');

         /*-*/
         /* Output the H1 record data
         /*-*/
         var_output := var_h1_data_type;
         var_output := var_output || var_h1_maker_code;
         var_output := var_output || var_h1_process_date;
         var_output := var_output || var_h1_sequential_number;
         var_output := var_output || var_h1_record_type;
         var_output := var_output || var_h1_bill_to_party_code;
         var_output := var_output || var_h1_transaction_type;
         var_output := var_output || var_h1_purchase_order_no;
         var_output := var_output || var_h1_purchase_order_date;
         var_output := var_output || var_h1_classification_code;
         var_output := var_output || var_h1_document_type;
         var_output := var_output || var_h1_partner_code;
         var_output := var_output || var_h1_account_code;
         var_output := var_output || var_h1_invoice_date;
         var_output := var_output || var_h1_invoice_number;
         var_output := var_output || var_h1_billing_date;
         var_output := var_output || var_h1_partner_name;
         var_output := var_output || var_h1_ship_to_party_type;
         var_output := var_output || var_h1_adjustment;
         var_output := var_output || var_h1_order_party_code;
         var_output := var_output || var_h1_reserved_field;
         tbl_outbound(tbl_outbound.count + 1) := var_output;

         /*-*/
         /* H2 record only required when Z5 partner exists
         /*-*/
         if not(rcd_whslr_dly_inv_hdr.sap_scdry_code is null) then

            /*-*/
            /* Increment the row count
            /*-*/
            var_row_count := var_row_count + 1;

            /*-*/
            /* Set the H2 record data
            /*-*/
            var_h2_data_type := lads_right_pad(var_data_type,2,' ');
            var_h2_maker_code := lads_right_pad(var_maker_code,7,' ');
            var_h2_process_date := lads_right_pad(var_process_date,2,' ');
            var_h2_sequential_number := to_char(var_row_count,'fm00000');
            var_h2_record_type := lads_right_pad('H2',2,' ');
            var_h2_sold_to_party_code := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_sldto_code,1,8),8,' ');
            var_h2_sold_to_party_name := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_sldto_name,1,30),30,' ');
            var_h2_reserved_field := lads_right_pad(' ',72,' ');

            /*-*/
            /* Output the H2 record data
            /*-*/
            var_output := var_h2_data_type;
            var_output := var_output || var_h2_maker_code;
            var_output := var_output || var_h2_process_date;
            var_output := var_output || var_h2_sequential_number;
            var_output := var_output || var_h2_record_type;
            var_output := var_output || var_h2_sold_to_party_code;
            var_output := var_output || var_h2_sold_to_party_name;
            var_output := var_output || var_h2_reserved_field;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end if;

         /*-*/
         /* H3 record only required when WE partner exists
         /*-*/
         if not(rcd_whslr_dly_inv_hdr.sap_shpto_code is null) then

            /*-*/
            /* Increment the row count
            /*-*/
            var_row_count := var_row_count + 1;

            /*-*/
            /* Set the H3 record data
            /*-*/
            var_h3_data_type := lads_right_pad(var_data_type,2,' ');
            var_h3_maker_code := lads_right_pad(var_maker_code,7,' ');
            var_h3_process_date := lads_right_pad(var_process_date,2,' ');
            var_h3_sequential_number := to_char(var_row_count,'fm00000');
            var_h3_record_type := lads_right_pad('H3',2,' ');
            var_h3_ship_to_party_code := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_shpto_code,1,8),8,' ');
            var_h3_ship_to_party_name := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_shpto_name,1,40),40,' ');
            var_h3_ship_to_party_post_code := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_shpto_pcde,1,7),7,' ');
            var_h3_reserved_field_1 := lads_right_pad(' ',1,' ');
            var_h3_ship_to_party_addess := lads_right_pad(substr(rcd_whslr_dly_inv_hdr.edi_shpto_addr,1,50),50,' ');
            var_h3_reserved_field_2 := lads_right_pad(' ',4,' ');

            /*-*/
            /* Output the H3 record data
            /*-*/
            var_output := var_h3_data_type;
            var_output := var_output || var_h3_maker_code;
            var_output := var_output || var_h3_process_date;
            var_output := var_output || var_h3_sequential_number;
            var_output := var_output || var_h3_record_type;
            var_output := var_output || var_h3_ship_to_party_code;
            var_output := var_output || var_h3_ship_to_party_name;
            var_output := var_output || var_h3_ship_to_party_post_code;
            var_output := var_output || var_h3_reserved_field_1;
            var_output := var_output || var_h3_ship_to_party_addess;
            var_output := var_output || var_h3_reserved_field_2;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end if;

         /*-*/
         /* Retrieve the wholesaler invoice details
         /*-*/
         open csr_whslr_dly_inv_det;
         loop
            fetch csr_whslr_dly_inv_det into rcd_whslr_dly_inv_det;
            if csr_whslr_dly_inv_det%notfound then
               exit;
            end if;

            /*-*/
            /* Increment the row count
            /*-*/
            var_row_count := var_row_count + 1;

            /*-*/
            /* Set the L1 record data
            /*-*/
            var_l1_data_type := lads_right_pad(var_data_type,2,' ');
            var_l1_maker_code := lads_right_pad(var_maker_code,7,' ');
            var_l1_process_date := lads_right_pad(var_process_date,2,' ');
            var_l1_sequential_number := to_char(var_row_count,'fm00000');
            var_l1_record_type := lads_right_pad('L1',2,' ');
            var_l1_line_item_number := substr(to_char(rcd_whslr_dly_inv_det.sap_invoice_line,'000000000000000'),17-2,2);
            var_l1_material_code_type := lads_right_pad('J',1,' ');
            var_l1_material_code := lads_right_pad(substr(rcd_whslr_dly_inv_det.edi_material_code,1,16),16,' ');
            var_l1_material_name := lads_right_pad(substr(rcd_whslr_dly_inv_det.edi_material_name,1,25),25,' ');
            var_l1_piece_qty := substr(to_char(nvl(rcd_whslr_dly_inv_det.edi_rsu_per_tdu,0),'000000000000000'),17-5,5);
            var_l1_case_qty := substr(overpunch_zoned(rcd_whslr_dly_inv_det.edi_case_qty,'000000000000000'),17-4,4);
            var_l1_order_qty := substr(overpunch_zoned(0,'000000000000000'),17-6,6);
            var_l1_paid_qty := substr(overpunch_zoned(rcd_whslr_dly_inv_det.edi_delivered_qty,'000000000000000'),17-6,6);
            var_l1_free_qty := substr(overpunch_zoned(0,'000000000000000'),17-4,4);
            var_l1_unit_price := substr(to_char(nvl(rcd_whslr_dly_inv_det.edi_unit_price,0),'0000000000000V00'),17-10,10);
            var_l1_price_unit := lads_right_pad(' ',1,' ');
            var_l1_amount := substr(overpunch_zoned(rcd_whslr_dly_inv_det.edi_amount,'000000000000000'),17-9,9);
            var_l1_type_of_set_package := lads_right_pad('0',1,' ');
            var_l1_number_of_combined_box := lads_right_pad('0',1,' ');
            var_l1_reserved_field := lads_right_pad(' ',19,' ');

            /*-*/
            /* Output the L1 record data
            /*-*/
            var_output := var_l1_data_type;
            var_output := var_output || var_l1_maker_code;
            var_output := var_output || var_l1_process_date;
            var_output := var_output || var_l1_sequential_number;
            var_output := var_output || var_l1_record_type;
            var_output := var_output || var_l1_line_item_number;
            var_output := var_output || var_l1_material_code_type;
            var_output := var_output || var_l1_material_code;
            var_output := var_output || var_l1_material_name;
            var_output := var_output || var_l1_piece_qty;
            var_output := var_output || var_l1_case_qty;
            var_output := var_output || var_l1_order_qty;
            var_output := var_output || var_l1_paid_qty;
            var_output := var_output || var_l1_free_qty;
            var_output := var_output || var_l1_unit_price;
            var_output := var_output || var_l1_price_unit;
            var_output := var_output || var_l1_amount;
            var_output := var_output || var_l1_type_of_set_package;
            var_output := var_output || var_l1_number_of_combined_box;
            var_output := var_output || var_l1_reserved_field;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end loop;
         close csr_whslr_dly_inv_det;

         /*-*/
         /* Increment the row count
         /*-*/
         var_row_count := var_row_count + 1;

         /*-*/
         /* Set the T1 record data
         /*-*/
         var_t1_data_type := lads_right_pad(var_data_type,2,' ');
         var_t1_maker_code := lads_right_pad(var_maker_code,7,' ');
         var_t1_process_date := lads_right_pad(var_process_date,2,' ');
         var_t1_sequential_number := to_char(var_row_count,'fm00000');
         var_t1_record_type := lads_right_pad('T1',2,' ');
         var_t1_total_case_qty := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_case_qty,'000000000000000'),17-4,4);
         var_t1_total_amount := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_amount,'000000000000000'),17-10,10);
         var_t1_total_discount_amount := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_discount,'000000000000000'),17-8,8);
         var_t1_net_amount_after_disc := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_balance,'000000000000000'),17-9,9);
         var_t1_remarks_a := lads_right_pad(' ',20,' ');
         var_t1_remarks_1_for_order_no := lads_right_pad(' ',8,' ');
         var_t1_remarks_1_for_comments := lads_right_pad(' ',28,' ');
         if rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt != 0 then
            var_t1_discount_pc := substr(to_char((rcd_whslr_dly_inv_hdr.edi_disc_volume_pct/rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt)*10,'000000000000000'),17-2,2);
         else
            var_t1_discount_pc := substr(to_char(0,'000000000000000'),17-2,2);
         end if;
         var_t1_volume_discount := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_disc_volume,'000000000000000'),17-7,7);
         var_t1_early_pmt_disc := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_disc_earlypay,'000000000000000'),17-7,7);
         var_t1_no_return_disc := substr(overpunch_zoned(rcd_whslr_dly_inv_hdr.edi_disc_noreturn,'000000000000000'),17-7,7);

         /*-*/
         /* Output the T1 record data
         /*-*/
         var_output := var_t1_data_type;
         var_output := var_output || var_t1_maker_code;
         var_output := var_output || var_t1_process_date;
         var_output := var_output || var_t1_sequential_number;
         var_output := var_output || var_t1_record_type;
         var_output := var_output || var_t1_total_case_qty;
         var_output := var_output || var_t1_total_amount;
         var_output := var_output || var_t1_total_discount_amount;
         var_output := var_output || var_t1_net_amount_after_disc;
         var_output := var_output || var_t1_remarks_a;
         var_output := var_output || var_t1_remarks_1_for_order_no;
         var_output := var_output || var_t1_remarks_1_for_comments;
         var_output := var_output || var_t1_discount_pc;
         var_output := var_output || var_t1_volume_discount;
         var_output := var_output || var_t1_early_pmt_disc;
         var_output := var_output || var_t1_no_return_disc;
         tbl_outbound(tbl_outbound.count + 1) := var_output;

      end loop;
      close csr_whslr_dly_inv_hdr;

      /*-*/
      /* Process the previous wholesaler when required
      /*-*/
      if not(var_sndto_save is null) then

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('Sent (' || to_char(var_invc_count,'fm999999990') || ') daily invoices to Wholesaler (' || var_sndto_save || ')');

      end if;

      /*-*/
      /* Create the invoice interface when required
      /*-*/
      if tbl_outbound.count != 0 then
         var_instance := lics_outbound_loader.create_interface('LADEDI02','LADEDI02_'||par_company||'_'||par_date,'LADEDI02_'||par_company||'_'||par_date||'.TXT');
         for idx in 1..tbl_outbound.count loop
            lics_outbound_loader.append_data(tbl_outbound(idx));
         end loop;
         lics_outbound_loader.finalise_interface;
      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Wholesaler Send Daily Invoices');

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - Wholesaler Send Daily Invoices - ' || var_exception);
            lics_logging.write_log('End - Wholesaler Send Daily Invoices');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_invoices;

   /***********************************************************************/
   /* This function performs the overpunch zoned number format conversion */
   /***********************************************************************/
   function overpunch_zoned(par_number in number, par_format in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(50);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Format and overpunch the number to a string
      /*-*/
      var_return := to_char(abs(nvl(par_number,0)),par_format);
      if par_number >= 0 then
         var_return := substr(var_return,1,length(var_return)-1) || translate(substr(var_return,length(var_return),1),'0123456789','{ABCDEFGHI');
      else
         var_return := substr(var_return,1,length(var_return)-1) || translate(substr(var_return,length(var_return),1),'0123456789','}JKLMNOPQR');
      end if;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end overpunch_zoned;

end edi_whslr_daily;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_whslr_daily for dw_app.edi_whslr_daily;
grant execute on edi_whslr_daily to public;
