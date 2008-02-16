/******************/
/* Package Header */
/******************/
create or replace package edi_agency_daily as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_agency_daily
    Owner   : dw_app

    Description
    -----------
    Electronic Data Interchange - EDI Agency Daily Invoicing

    This package contains the extract procedure for Collection Agency daily invoices. The
    package exposes one procedure EXECUTE that performs the extract based on the
    following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the EDI invoicing is to be performed.

    2. PAR_DATE (date in string format YYYYMMDD) (MANDATORY)

       The date for which the EDI invoicing is to be performed.

    **notes**
    1. A web log is produced under the search value EDI_COLLECTION_AGENCY_DAILY_INVOICING where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/12   Steve Gregan   Created
    2008/02   Steve Gregan   Added sold to selection to EDI link logic

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2, par_date in varchar2);

end edi_agency_daily;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_agency_daily as

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
      con_function constant varchar2(128) := 'EDI Collection Agency Daily Invoicing';
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
      var_log_prefix := 'EDI - COLLECTION AGENCY DAILY INVOICING';
      var_log_search := 'EDI_COLLECTION_AGENCY_DAILY_INVOICING';
      var_loc_string := 'EDI_AGENCY_INVOICING' || '_' || par_company;
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
      lics_logging.write_log('Begin - EDI Collection Agency Daily Invoicing - Parameters(' || par_company || ' + ' || par_date || ')');

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
         /* Execute the collection agency daily create procedure
         /*-*/
         begin
            create_invoices(par_company, par_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Execute the collection agency daily send procedure when required
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
      lics_logging.write_log('End - EDI Collection Agency Daily Invoicing');

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
                                         'One or more errors occurred during the EDI Collection Agency Daily Invoicing execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - EDI - COLLECTION AGENCY DAILY INVOICING - ' || var_exception);

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
      var_agency_code varchar2(30);
      var_link_type varchar2(30);
      var_cust_type varchar2(30);
      var_cust_code varchar2(30);
      var_invc_count number;
      var_qualf varchar2(30);
      var_parvw varchar2(30);
      var_langu varchar2(30);
      var_iddat varchar2(30);
      var_snackfood boolean;
      var_petcare boolean;
      var_dlvry_flag boolean;
      var_refnr_flag boolean;
      var_dlvry_number varchar2(128);
      var_refnr_number varchar2(128);
      rcd_agency_dly_inv_hdr agency_dly_inv_hdr%rowtype;
      rcd_agency_dly_inv_det agency_dly_inv_det%rowtype;

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

      cursor csr_lads_inv_cus is
         select t01.*
           from lads_inv_cus t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.atnam = 'ZZ-JP_SHIPTO_TYPE'
            and t01.customer = rcd_agency_dly_inv_hdr.ipn_we_partn;
      rcd_lads_inv_cus csr_lads_inv_cus%rowtype;

      cursor csr_lads_inv_txt is
         select t02.*
           from lads_inv_txt t01,
                lads_inv_txi t02
          where t01.belnr = t02.belnr
            and t01.txtseq = t02.txtseq
            and t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.tdid = '0004'
            and t01.tsspras_iso = 'JA'
          order by t02.txtseq asc, t02.txiseq asc;
      rcd_lads_inv_txt csr_lads_inv_txt%rowtype;

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

      cursor csr_edi_link is
         select t01.*
           from edi_link t01
          where upper(t01.sap_cust_type) = var_cust_type
            and t01.sap_cust_code = var_cust_code;
      rcd_edi_link csr_edi_link%rowtype;

      cursor csr_agency is
         select t01.*
           from agency t01
          where t01.edi_agency_code = var_agency_code;
      rcd_agency csr_agency%rowtype;

      cursor csr_agency_interface is
         select t01.*
           from agency_interface t01
          where t01.edi_agency_code = rcd_agency_dly_inv_hdr.edi_agency_code
            and t01.sap_sales_org_code = rcd_agency_dly_inv_hdr.org_008_orgid
            and t01.sap_distbn_chnl_code = rcd_agency_dly_inv_hdr.org_007_orgid
            and t01.sap_division_code = rcd_agency_dly_inv_hdr.org_006_orgid;
      rcd_agency_interface csr_agency_interface%rowtype;

      cursor csr_agency_transaction is
         select t01.*
           from agency_transaction t01
          where t01.sap_invoice_type = rcd_agency_dly_inv_hdr.org_015_orgid
            and t01.sap_order_type = rcd_agency_dly_inv_hdr.org_012_orgid;
      rcd_agency_transaction csr_agency_transaction%rowtype;

      cursor csr_agency_discount is
         select t01.*
           from agency_discount t01
          where t01.edi_disc_code = rcd_agency_dly_inv_hdr.edi_disc_code;
      rcd_agency_discount csr_agency_discount%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Collection Agency Create Daily Invoices');

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Deleting any existing collection agency daily invoices for company');

      /*-*/
      /* Delete any existing invoice details for the company
      /*-*/
      delete from agency_dly_inv_det
       where company_code = par_company;

      /*-*/
      /* Delete any existing invoice headers for the company
      /*-*/
      delete from agency_dly_inv_hdr
       where company_code = par_company;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Creating collection agency daily invoices for company and date');

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
         /* Initialise the collection agency invoice header
         /*-*/
         rcd_agency_dly_inv_hdr.company_code := par_company;
         rcd_agency_dly_inv_hdr.creatn_date := par_date;
         rcd_agency_dly_inv_hdr.hdr_belnr := rcd_lads_inv_hdr.belnr;
         rcd_agency_dly_inv_hdr.hdr_expnr := rcd_lads_inv_hdr.expnr;
         rcd_agency_dly_inv_hdr.hdr_crpc_version := rcd_lads_inv_hdr.crpc_version;
         rcd_agency_dly_inv_hdr.org_006_orgid := '*';
         rcd_agency_dly_inv_hdr.org_007_orgid := '*';
         rcd_agency_dly_inv_hdr.org_008_orgid := '*';
         rcd_agency_dly_inv_hdr.org_012_orgid := '*';
         rcd_agency_dly_inv_hdr.org_015_orgid := '*';
         rcd_agency_dly_inv_hdr.pnr_rg_partn := null;
         rcd_agency_dly_inv_hdr.pnr_ag_partn := null;
         rcd_agency_dly_inv_hdr.adj_ag_z3_name1 := null;
         rcd_agency_dly_inv_hdr.adj_ag_z3_street := null;
         rcd_agency_dly_inv_hdr.adj_ag_z3_city1 := null;
         rcd_agency_dly_inv_hdr.pnr_z5_partn := null;
         rcd_agency_dly_inv_hdr.pnr_z5_knref := null;
         rcd_agency_dly_inv_hdr.adj_z5_z3_name1 := null;
         rcd_agency_dly_inv_hdr.adj_z5_z3_street := null;
         rcd_agency_dly_inv_hdr.adj_z5_z3_city1 := null;
         rcd_agency_dly_inv_hdr.ipn_we_partn := null;
         rcd_agency_dly_inv_hdr.iaj_we_z3_name1 := null;
         rcd_agency_dly_inv_hdr.iaj_we_z3_street := null;
         rcd_agency_dly_inv_hdr.iaj_we_z3_city1 := null;
         rcd_agency_dly_inv_hdr.gen_vsart := null;
         rcd_agency_dly_inv_hdr.gen_werks := null;
         rcd_agency_dly_inv_hdr.gen_knref := null;
         rcd_agency_dly_inv_hdr.gen_org_dlvnr := null;
         rcd_agency_dly_inv_hdr.gen_org_dlvdt := null;
         rcd_agency_dly_inv_hdr.gen_zztarif := null;
         rcd_agency_dly_inv_hdr.dat_024_datum := null;
         rcd_agency_dly_inv_hdr.ref_001_refnr := null;
         rcd_agency_dly_inv_hdr.ref_012_refnr := null;
         rcd_agency_dly_inv_hdr.txt_ja_tdline := null;
         rcd_agency_dly_inv_hdr.edi_partn_code := var_partner_code;
         rcd_agency_dly_inv_hdr.edi_partn_name := var_partner_name;
         rcd_agency_dly_inv_hdr.edi_agency_code := null;
         rcd_agency_dly_inv_hdr.edi_interface := null;
         rcd_agency_dly_inv_hdr.edi_tran_code := null;
         rcd_agency_dly_inv_hdr.edi_disc_code := null;
         rcd_agency_dly_inv_hdr.edi_disc_name := null;
         rcd_agency_dly_inv_hdr.edi_ship_to_type := null;
         rcd_agency_dly_inv_hdr.edi_denpyo_number := null;
         rcd_agency_dly_inv_hdr.edi_sub_denpyo_number := null;
         rcd_agency_dly_inv_hdr.edi_sub_denpyo_date := null;

         /*-*/
         /* Retrieve the invoice payer partner data (RG)
         /*-*/
         var_parvw := 'RG';
         open csr_lads_inv_pnr;
         fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
         if csr_lads_inv_pnr%found then
            rcd_agency_dly_inv_hdr.pnr_rg_partn := rcd_lads_inv_pnr.partn;
         end if;
         close csr_lads_inv_pnr;

         /*-*/
         /* Retrieve the invoice sold to partner data (AG)
         /*-*/
         var_parvw := 'AG';
         open csr_lads_inv_pnr;
         fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
         if csr_lads_inv_pnr%found then
            rcd_agency_dly_inv_hdr.pnr_ag_partn := rcd_lads_inv_pnr.partn;
         end if;
         close csr_lads_inv_pnr;

         /*-*/
         /* Retrieve the collection agency code
         /* **notes** 1. The sold to or payer customer must exist in the EDI link table (*AGENCY)
         /*           2. Sold to code overrides payer code
         /*-*/
         var_agency_code := null;
         var_link_type := null;
         var_cust_type := '*SOLDTO';
         var_cust_code := lads_trim_code(rcd_agency_dly_inv_hdr.pnr_ag_partn);
         open csr_edi_link;
         fetch csr_edi_link into rcd_edi_link;
         if csr_edi_link%found then
            var_link_type := rcd_edi_link.edi_link_type;
            if upper(rcd_edi_link.edi_link_type) = '*AGENCY' then
               var_agency_code := rcd_edi_link.edi_link_code;
            end if;
         end if;
         if var_link_type is null then
            var_cust_type := '*PAYER';
            var_cust_code := lads_trim_code(rcd_agency_dly_inv_hdr.pnr_rg_partn);
            open csr_edi_link;
            fetch csr_edi_link into rcd_edi_link;
            if csr_edi_link%found then
               if upper(rcd_edi_link.edi_link_type) = '*AGENCY' then
                  var_agency_code := rcd_edi_link.edi_link_code;
               end if;
            end if;
         end if;

         /*-*/
         /* Only process collection agency invoices
         /*-*/
         if not(var_agency_code is null) then

            /*-*/
            /* Retrieve the collection agency data
            /*-*/
            open csr_agency;
            fetch csr_agency into rcd_agency;
            if csr_agency%found then
         
               /*-*/
               /* Set the agency values
               /*-*/
               rcd_agency_dly_inv_hdr.edi_agency_code := rcd_agency.edi_agency_code;

               /*-*/
               /* Retrieve the invoice organisation data (006)
               /*-*/
               var_qualf := '006';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_agency_dly_inv_hdr.org_006_orgid := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

               /*-*/
               /* Retrieve the invoice organisation data (007)
               /*-*/
               var_qualf := '007';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_agency_dly_inv_hdr.org_007_orgid := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

               /*-*/
               /* Retrieve the invoice organisation data (008)
               /*-*/
               var_qualf := '008';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_agency_dly_inv_hdr.org_008_orgid := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

               /*-*/
               /* Retrieve the invoice organisation data (012)
               /*-*/
               var_qualf := '012';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_agency_dly_inv_hdr.org_012_orgid := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

               /*-*/
               /* Retrieve the invoice organisation data (015)
               /*-*/
               var_qualf := '015';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_agency_dly_inv_hdr.org_015_orgid := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

               /*-*/
               /* Retrieve the agency interface
               /*-*/
               open csr_agency_interface;
               fetch csr_agency_interface into rcd_agency_interface;
               if csr_agency_interface%found then
                  rcd_agency_dly_inv_hdr.edi_interface := rcd_agency_interface.edi_interface;
               end if;
               close csr_agency_interface;

               /*-*/
               /* Only process when agency interface found
               /*-*/
               if not(rcd_agency_dly_inv_hdr.edi_interface is null) then

                  /*-*/
                  /* Increment the invoice count
                  /*-*/
                  var_invc_count := var_invc_count + 1;

                  /*-*/
                  /* Determine the Mars division
                  /*-*/
                  var_snackfood := false;
                  var_petcare := false;
                  if rcd_agency_dly_inv_hdr.org_008_orgid = '131' and
                     rcd_agency_dly_inv_hdr.org_006_orgid = '51' then
                     if rcd_agency_dly_inv_hdr.org_007_orgid = '10' then
                        var_snackfood := true;
                     end if;
                     if rcd_agency_dly_inv_hdr.org_007_orgid = '11' or
                        rcd_agency_dly_inv_hdr.org_007_orgid = '20' then
                        var_petcare := true;
                     end if;
                  end if;

                  /*-*/
                  /* Retrieve the invoice partner address data (AG/Z3)
                  /*-*/
                  if not(rcd_agency_dly_inv_hdr.pnr_ag_partn is null) then
                     var_langu := 'Z3';
                     open csr_lads_inv_adj;
                     fetch csr_lads_inv_adj into rcd_lads_inv_adj;
                     if csr_lads_inv_adj%found then
                        rcd_agency_dly_inv_hdr.adj_ag_z3_name1 := rcd_lads_inv_adj.name1;
                        rcd_agency_dly_inv_hdr.adj_ag_z3_street := rcd_lads_inv_adj.street;
                        rcd_agency_dly_inv_hdr.adj_ag_z3_city1 := rcd_lads_inv_adj.city1;
                     end if;
                     close csr_lads_inv_adj;
                  end if;

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
                     rcd_agency_dly_inv_hdr.pnr_z5_partn := rcd_lads_inv_pnr.partn;
                     rcd_agency_dly_inv_hdr.pnr_z5_knref := rcd_lads_inv_pnr.knref;

                     /*-*/
                     /* Retrieve the invoice partner address data (Z5/Z3)
                     /*-*/
                     var_langu := 'Z3';
                     open csr_lads_inv_adj;
                     fetch csr_lads_inv_adj into rcd_lads_inv_adj;
                     if csr_lads_inv_adj%found then
                        rcd_agency_dly_inv_hdr.adj_z5_z3_name1 := rcd_lads_inv_adj.name1;
                        rcd_agency_dly_inv_hdr.adj_z5_z3_street := rcd_lads_inv_adj.street;
                        rcd_agency_dly_inv_hdr.adj_z5_z3_city1 := rcd_lads_inv_adj.city1;
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
                     /* Set the header data from the first invoice line
                     /*-*/
                     rcd_agency_dly_inv_hdr.gen_vsart := rcd_lads_inv_gen.vsart;
                     rcd_agency_dly_inv_hdr.gen_werks := rcd_lads_inv_gen.werks;
                     rcd_agency_dly_inv_hdr.gen_knref := rcd_lads_inv_gen.knref;
                     rcd_agency_dly_inv_hdr.gen_org_dlvnr := rcd_lads_inv_gen.org_dlvnr;
                     rcd_agency_dly_inv_hdr.gen_org_dlvdt := rcd_lads_inv_gen.org_dlvdt;
                     rcd_agency_dly_inv_hdr.gen_zztarif := rcd_lads_inv_gen.zztarif;

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
                        rcd_agency_dly_inv_hdr.ipn_we_partn := rcd_lads_inv_ipn.partn;

                        /*-*/
                        /* Retrieve the invoice item partner address data (WE/Z3)
                        /*-*/
                        var_langu := 'Z3';
                        open csr_lads_inv_iaj;
                        fetch csr_lads_inv_iaj into rcd_lads_inv_iaj;
                        if csr_lads_inv_iaj%found then
                           rcd_agency_dly_inv_hdr.iaj_we_z3_name1 := rcd_lads_inv_iaj.name1;
                           rcd_agency_dly_inv_hdr.iaj_we_z3_street := rcd_lads_inv_iaj.street;
                           rcd_agency_dly_inv_hdr.iaj_we_z3_city1 := rcd_lads_inv_iaj.city1;
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
                     rcd_agency_dly_inv_hdr.dat_024_datum := rcd_lads_inv_dat.datum;
                  end if;
                  close csr_lads_inv_dat;

                  /*-*/
                  /* Retrieve the invoice reference data (001)
                  /*-*/
                  var_qualf := '001';
                  open csr_lads_inv_ref;
                  fetch csr_lads_inv_ref into rcd_lads_inv_ref;
                  if csr_lads_inv_ref%found then
                     rcd_agency_dly_inv_hdr.ref_001_refnr := rcd_lads_inv_ref.refnr;
                  end if;
                  close csr_lads_inv_ref;

                  /*-*/
                  /* Retrieve the invoice reference data (012)
                  /*-*/
                  var_qualf := '012';
                  open csr_lads_inv_ref;
                  fetch csr_lads_inv_ref into rcd_lads_inv_ref;
                  if csr_lads_inv_ref%found then
                     rcd_agency_dly_inv_hdr.ref_012_refnr := rcd_lads_inv_ref.refnr;
                  end if;
                  close csr_lads_inv_ref;

                  /*-*/
                  /* Retrieve the invoice text data
                  /*-*/
                  open csr_lads_inv_txt;
                  fetch csr_lads_inv_txt into rcd_lads_inv_txt;
                  if csr_lads_inv_txt%found then
                     rcd_agency_dly_inv_hdr.txt_ja_tdline := rcd_lads_inv_txt.tdline;
                  end if;
                  close csr_lads_inv_txt;

                  /*-*/
                  /* Retrieve the EDI denpyo/sub denpyo data
                  /*-*/
                  var_dlvry_flag := false;
                  var_refnr_flag := false;
                  var_dlvry_number := rcd_agency_dly_inv_hdr.hdr_belnr;
                  var_refnr_number := null;
                  if rcd_agency_dly_inv_hdr.org_015_orgid = 'ZS1' or
                     rcd_agency_dly_inv_hdr.org_015_orgid = 'ZS2' then
                     var_dlvry_flag := true;
                  end if;
                  if not(rcd_agency_dly_inv_hdr.ref_012_refnr is null) then
                     var_dlvry_number := rcd_agency_dly_inv_hdr.ref_012_refnr;
                     var_refnr_number := rcd_agency_dly_inv_hdr.ref_012_refnr;
                     var_refnr_flag := true;
                  end if;
                  rcd_agency_dly_inv_hdr.edi_denpyo_number := substr(var_dlvry_number,3,35);
                  if var_dlvry_flag = true then
                     rcd_agency_dly_inv_hdr.edi_sub_denpyo_number := substr(var_refnr_number,3,35);
                     if var_refnr_flag = true then
                        rcd_agency_dly_inv_hdr.edi_sub_denpyo_date := substr(rcd_agency_dly_inv_hdr.dat_024_datum,3,6);
                     end if;
                  else
                     if rcd_agency_dly_inv_hdr.gen_org_dlvnr = var_dlvry_number then
                        rcd_agency_dly_inv_hdr.edi_sub_denpyo_number := null;
                        rcd_agency_dly_inv_hdr.edi_sub_denpyo_date := null;
                     else
                        rcd_agency_dly_inv_hdr.edi_sub_denpyo_number := substr(rcd_agency_dly_inv_hdr.gen_org_dlvnr,3,35);
                        if not(rcd_agency_dly_inv_hdr.gen_org_dlvdt is null) then
                           rcd_agency_dly_inv_hdr.edi_sub_denpyo_date := substr(rcd_agency_dly_inv_hdr.gen_org_dlvdt,3,6);
                        end if;
                     end if;
                  end if;

                  /*-*/
                  /* Retrieve the EDI ship to type
                  /*-*/
                  if not(rcd_agency_dly_inv_hdr.pnr_z5_partn is null) and
                     rcd_agency_dly_inv_hdr.pnr_z5_partn = rcd_agency_dly_inv_hdr.ipn_we_partn then
                     rcd_agency_dly_inv_hdr.edi_ship_to_type := '2';
                  else
                     open csr_lads_inv_cus;
                     fetch csr_lads_inv_cus into rcd_lads_inv_cus;
                     if csr_lads_inv_cus%found then
                        rcd_agency_dly_inv_hdr.edi_ship_to_type := rcd_lads_inv_cus.atwrt;
                     end if;
                     close csr_lads_inv_cus;
                  end if;

                  /*-*/
                  /* Retrieve the EDI transaction code
                  /*-*/
                  open csr_agency_transaction;
                  fetch csr_agency_transaction into rcd_agency_transaction;
                  if csr_agency_transaction%found then
                     rcd_agency_dly_inv_hdr.edi_tran_code := rcd_agency_transaction.edi_tran_code;
                  end if;
                  close csr_agency_transaction;

                  /*-*/
                  /* Retrieve the EDI discount code and name when required
                  /*-*/
                  if var_petcare = true then
                     if not(rcd_agency_dly_inv_hdr.hdr_crpc_version is null) and
                        not(rcd_agency_dly_inv_hdr.gen_zztarif is null) then
                        rcd_agency_dly_inv_hdr.edi_disc_code := rcd_agency_dly_inv_hdr.hdr_crpc_version || rcd_agency_dly_inv_hdr.gen_zztarif;
                     else
                        if not(rcd_agency_dly_inv_hdr.hdr_crpc_version is null) then
                           rcd_agency_dly_inv_hdr.edi_disc_code := rcd_agency_dly_inv_hdr.hdr_crpc_version;
                        end if;
                        if not(rcd_agency_dly_inv_hdr.gen_zztarif is null) then
                           rcd_agency_dly_inv_hdr.edi_disc_code := rcd_agency_dly_inv_hdr.gen_zztarif;
                        end if;
                     end if;
                     open csr_agency_discount;
                     fetch csr_agency_discount into rcd_agency_discount;
                     if csr_agency_discount%found then
                        rcd_agency_dly_inv_hdr.edi_disc_name := rcd_agency_discount.edi_disc_name;
                     end if;
                     close csr_agency_discount;
                  end if;

                  /*-*/
                  /* Insert the collection agency invoice header row
                  /*-*/
                  insert into agency_dly_inv_hdr values rcd_agency_dly_inv_hdr;

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
                        /* Initialise the collection agency invoice detail
                        /*-*/
                        rcd_agency_dly_inv_det.company_code := par_company;
                        rcd_agency_dly_inv_det.gen_belnr := rcd_lads_inv_gen.belnr;
                        rcd_agency_dly_inv_det.gen_genseq := rcd_lads_inv_gen.genseq;
                        rcd_agency_dly_inv_det.gen_mat_legacy := rcd_lads_inv_gen.mat_legacy;
                        rcd_agency_dly_inv_det.gen_rsu_per_tdu := nvl(lads_to_number(rcd_lads_inv_gen.rsu_per_tdu),'1');
                        rcd_agency_dly_inv_det.gen_rsu_per_mcu := nvl(lads_to_number(rcd_lads_inv_gen.rsu_per_mcu),'1');
                        rcd_agency_dly_inv_det.gen_mcu_per_tdu := nvl(lads_to_number(rcd_lads_inv_gen.mcu_per_tdu),'1');
                        rcd_agency_dly_inv_det.gen_menge := nvl(lads_to_number(rcd_lads_inv_gen.menge),'0');
                        rcd_agency_dly_inv_det.gen_menee := rcd_lads_inv_gen.menee;
                        rcd_agency_dly_inv_det.gen_pstyv := rcd_lads_inv_gen.pstyv;
                        rcd_agency_dly_inv_det.gen_prod_spart := rcd_lads_inv_gen.prod_spart;
                        rcd_agency_dly_inv_det.iob_002_idtnr := null;
                        rcd_agency_dly_inv_det.iob_r01_idtnr := null;
                        rcd_agency_dly_inv_det.mat_z3_maktx := null;
                        rcd_agency_dly_inv_det.ias_901_krate := null;
                        rcd_agency_dly_inv_det.ias_901_betrg := null;
                        rcd_agency_dly_inv_det.icn_zrsp_krate := null;
                        rcd_agency_dly_inv_det.icn_pr00_krate := null;
                        rcd_agency_dly_inv_det.icn_zcrp_kperc := null;
                        rcd_agency_dly_inv_det.icn_zcrp_betrg := null;
                        rcd_agency_dly_inv_det.icn_zk25_betrg := null;
                        rcd_agency_dly_inv_det.icn_zk60_betrg := null;

                        /*-*/
                        /* Retrieve the invoice line object identification data (002)
                        /*-*/
                        var_qualf := '002';
                        open csr_lads_inv_iob;
                        fetch csr_lads_inv_iob into rcd_lads_inv_iob;
                        if csr_lads_inv_iob%found then
                           rcd_agency_dly_inv_det.iob_002_idtnr := rcd_lads_inv_iob.idtnr;
                        end if;
                        close csr_lads_inv_iob;

                        /*-*/
                        /* Retrieve the invoice line object identification data (R01)
                        /*-*/
                        var_qualf := 'R01';
                        open csr_lads_inv_iob;
                        fetch csr_lads_inv_iob into rcd_lads_inv_iob;
                        if csr_lads_inv_iob%found then
                           rcd_agency_dly_inv_det.iob_r01_idtnr := rcd_lads_inv_iob.idtnr;
                        end if;
                        close csr_lads_inv_iob;

                        /*-*/
                        /* Retrieve the invoice line object identification data (003) when required
                        /*-*/
                        if rcd_agency_dly_inv_det.iob_r01_idtnr is null then
                           var_qualf := '003';
                           open csr_lads_inv_iob;
                           fetch csr_lads_inv_iob into rcd_lads_inv_iob;
                           if csr_lads_inv_iob%found then
                              rcd_agency_dly_inv_det.iob_r01_idtnr := rcd_lads_inv_iob.idtnr;
                           end if;
                           close csr_lads_inv_iob;
                        end if;

                        /*-*/
                        /* Retrieve the invoice line material data (Z3)
                        /*-*/
                        var_langu := 'Z3';
                        open csr_lads_inv_mat;
                        fetch csr_lads_inv_mat into rcd_lads_inv_mat;
                        if csr_lads_inv_mat%found then
                           rcd_agency_dly_inv_det.mat_z3_maktx := rcd_lads_inv_mat.maktx;
                        end if;
                        close csr_lads_inv_mat;

                        /*-*/
                        /* Retrieve the invoice line item amount (901)
                        /*-*/
                        var_qualf := '901';
                        open csr_lads_inv_ias;
                        fetch csr_lads_inv_ias into rcd_lads_inv_ias;
                        if csr_lads_inv_ias%found then
                           rcd_agency_dly_inv_det.ias_901_krate := nvl(lads_to_number(rcd_lads_inv_ias.krate),0);
                           rcd_agency_dly_inv_det.ias_901_betrg := nvl(lads_to_number(rcd_lads_inv_ias.betrg),0);
                        end if;
                        close csr_lads_inv_ias;

                        /*-*/
                        /* Retrieve the invoice item condition data
                        /*-*/
                        open csr_lads_inv_icn;
                        loop
                           fetch csr_lads_inv_icn into rcd_lads_inv_icn;
                           if csr_lads_inv_icn%notfound then
                              exit;
                           end if;
                           if rcd_lads_inv_icn.kschl = 'ZRSP' then
                              rcd_agency_dly_inv_det.icn_zrsp_krate := nvl(lads_to_number(rcd_lads_inv_icn.krate),0);
                           end if;
                           if rcd_lads_inv_icn.kschl = 'PR00' then
                              rcd_agency_dly_inv_det.icn_pr00_krate := nvl(lads_to_number(rcd_lads_inv_icn.krate),0);
                           end if;
                           if rcd_lads_inv_icn.kschl = 'ZCRP' then
                              rcd_agency_dly_inv_det.icn_zcrp_kperc := nvl(lads_to_number(rcd_lads_inv_icn.kperc),0);
                              rcd_agency_dly_inv_det.icn_zcrp_betrg := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0);
                           end if;
                           if rcd_lads_inv_icn.kschl = 'ZK25' then
                              rcd_agency_dly_inv_det.icn_zk25_betrg := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0);
                           end if;
                           if rcd_lads_inv_icn.kschl = 'ZK60' then
                              rcd_agency_dly_inv_det.icn_zk60_betrg := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0);
                           end if;
                        end loop;
                        close csr_lads_inv_icn;

                        /*-*/
                        /* Insert the wholesaler invoice detail row
                        /*-*/
                        insert into agency_dly_inv_det values rcd_agency_dly_inv_det;

                     end if;

                  end loop;
                  close csr_lads_inv_gen;

               end if;

            end if;
            close csr_agency;

         end if;

      end loop;
      close csr_lads_inv_hdr;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Created (' || to_char(var_invc_count,'fm999999990') || ') collection agency daily invoices');

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Collection Agency Create Daily Invoices');

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
            lics_logging.write_log('**ERROR** - Collection Agency Create Daily Invoices - ' || var_exception);
            lics_logging.write_log('End - Collection Agency Create Daily Invoices');
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
      var_snackfood boolean;
      var_petcare boolean;
      var_product_code varchar2(128);
      var_product_name varchar2(128);
      var_interface_save varchar2(128);
      var_invc_count number;
      var_line_count number;
      type typ_outbound is table of varchar2(4000) index by binary_integer;
      tbl_outbound typ_outbound;
      /*-*/
      v02_record_classification varchar2(128 char);
      v02_delivery_data_kind varchar2(128 char);
      v02_despatched_date varchar2(128 char);
      v02_shipment_date varchar2(128 char);
      v02_delivery_number varchar2(128 char);
      v02_sub_denpyo_number varchar2(128 char);
      v02_primary_w_s_code varchar2(128 char);
      v02_secondary_w_s_code varchar2(128 char);
      v02_third_w_s_code varchar2(128 char);
      v02_fourth_w_s_code varchar2(128 char);
      v02_fifth_w_s_code varchar2(128 char);
      v02_customer_code_class_no8 varchar2(128 char);
      v02_customer_code_class_no9 varchar2(128 char);
      v02_customer_code_class_no10 varchar2(128 char);
      v02_customer_code_class_no11 varchar2(128 char);
      v02_customer_code_class_no12 varchar2(128 char);
      v02_bill_type_information varchar2(128 char);
      v02_delivery_type varchar2(128 char);
      v02_distribution_type varchar2(128 char);
      v02_shipment_type varchar2(128 char);
      v02_disp_delivery_date_ind varchar2(128 char);
      v02_ap_reconciliation varchar2(128 char);
      v02_summary_detail_type varchar2(128 char);
      v02_root_sales varchar2(128 char);
      v02_direct_deliver_fee_type varchar2(128 char);
      v02_delivered_from_warehouse varchar2(128 char);
      v02_division_code varchar2(128 char);
      v02_class_product_or_pack varchar2(128 char);
      v02_sub_denpyo_date varchar2(128 char);
      v02_denpyo_type_format varchar2(128 char);
      v02_delivery_type_2 varchar2(128 char);
      v02_spare varchar2(128 char);
      /*-*/
      v32_record_classification varchar2(128 char);
      v32_denpyo_header_reference varchar2(128 char);
      v32_customer_name varchar2(128 char);
      v32_customer_address varchar2(128 char);
      v32_reference_code_customer varchar2(128 char);
      v32_japanese_desc_type varchar2(128 char);
      v32_edi_code_data varchar2(128 char);
      /*-*/
      v33_record_classification varchar2(128 char);
      v33_denpyo_header_reference varchar2(128 char);
      v33_customer_name varchar2(128 char);
      v33_customer_address varchar2(128 char);
      v33_reference_code_customer varchar2(128 char);
      v33_japanese_desc_type varchar2(128 char);
      v33_edi_code_data varchar2(128 char);
      /*-*/
      v35_record_classification varchar2(128 char);
      v35_denpyo_header_reference varchar2(128 char);
      v35_customer_name varchar2(128 char);
      v35_customer_address varchar2(128 char);
      v35_reference_code_customer varchar2(128 char);
      v35_japanese_desc_type varchar2(128 char);
      v35_edi_code_data varchar2(128 char);
      /*-*/
      v04_record_classification varchar2(128 char);
      v04_message varchar2(128 char);
      v04_japanese_desc_type varchar2(128 char);
      v04_discount_code varchar2(128 char);
      v04_discount_name varchar2(128 char);
      v04_spare varchar2(128 char);
      /*-*/
      v05_record_classification varchar2(128 char);
      v05_denpyo_line_no varchar2(128 char);
      v05_product_code varchar2(128 char);
      v05_product_name varchar2(128 char);
      v05_retail_units_per_case varchar2(128 char);
      v05_quantity varchar2(128 char);
      v05_unit varchar2(128 char);
      v05_applied_retail_unit_price varchar2(128 char);
      v05_amount varchar2(128 char);
      v05_retail_price_type varchar2(128 char);
      v05_retail_price_usage_type varchar2(128 char);
      v05_retail_unit_price varchar2(128 char);
      v05_invoice_closing_date varchar2(128 char);
      v05_bank_account varchar2(128 char);
      v05_tenpu_classification varchar2(128 char);
      v05_special_code varchar2(128 char);
      v05_tenpu_qty varchar2(128 char);
      v05_order_no varchar2(128 char);
      v05_product_code_usage varchar2(128 char);
      v05_consumption_tax_type varchar2(128 char);
      v05_piece_per_ball varchar2(128 char);
      v05_spare varchar2(128 char);
      /*-*/
      v07_record_classification varchar2(128 char);
      v07_denpyo_line_no varchar2(128 char);
      v07_rounding_type varchar2(128 char);
      v07_discount_type_1 varchar2(128 char);
      v07_discount_method_1 varchar2(128 char);
      v07_amount_1 varchar2(128 char);
      v07_spare_1 varchar2(128 char);
      v07_discount_type_2 varchar2(128 char);
      v07_discount_method_2 varchar2(128 char);
      v07_amount_2 varchar2(128 char);
      v07_spare_2 varchar2(128 char);
      v07_discount_type_3 varchar2(128 char);
      v07_discount_method_3 varchar2(128 char);
      v07_amount_3 varchar2(128 char);
      v07_spare_3 varchar2(128 char);
      v07_discount_type_4 varchar2(128 char);
      v07_discount_method_4 varchar2(128 char);
      v07_amount_4 varchar2(128 char);
      v07_spare_4 varchar2(128 char);
      v07_discount_type_5 varchar2(128 char);
      v07_discount_method_5 varchar2(128 char);
      v07_amount_5 varchar2(128 char);
      v07_spare_5 varchar2(128 char);
      v07_remarks varchar2(128 char);
      v07_free_uses varchar2(128 char);
      v07_product_edi_jan_code varchar2(128 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_agency_dly_inv_hdr is
         select t01.*
           from agency_dly_inv_hdr t01
          where t01.company_code = par_company
          order by t01.edi_interface asc,
                   t01.hdr_belnr asc;
      rcd_agency_dly_inv_hdr csr_agency_dly_inv_hdr%rowtype;

      cursor csr_agency_dly_inv_det is
         select t01.*
           from agency_dly_inv_det t01
          where t01.gen_belnr = rcd_agency_dly_inv_hdr.hdr_belnr
          order by t01.gen_genseq asc;
      rcd_agency_dly_inv_det csr_agency_dly_inv_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      tbl_outbound.delete;

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Collection Agency Send Daily Invoices');

      /*-*/
      /* Retrieve the collection agency invoices for the company
      /*-*/
      var_interface_save := null;
      open csr_agency_dly_inv_hdr;
      loop
         fetch csr_agency_dly_inv_hdr into rcd_agency_dly_inv_hdr;
         if csr_agency_dly_inv_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Change in interface
         /*-*/
         if var_interface_save is null or
            var_interface_save != rcd_agency_dly_inv_hdr.edi_interface then

            /*-*/
            /* Process the previous interface when required
            /*-*/
            if not(var_interface_save is null) then

               /*-*/
               /* Create the invoice interface when required
               /*-*/
               if tbl_outbound.count != 0 then
                  var_instance := lics_outbound_loader.create_interface(var_interface_save,var_interface_save||'_'||par_company||'_'||par_date||'.TXT',var_interface_save||'_'||par_company||'_'||par_date||'.TXT');
                  for idx in 1..tbl_outbound.count loop
                     lics_outbound_loader.append_data(tbl_outbound(idx));
                  end loop;
                  lics_outbound_loader.finalise_interface;
               end if;

               /*-*/
               /* Log the event
               /*-*/
               lics_logging.write_log('Sent (' || to_char(var_invc_count,'fm999999990') || ') daily invoices to collection agency (' || var_interface_save || ')');

            end if;

            /*-*/
            /* Initialise the new sales area
            /*-*/
            var_interface_save := rcd_agency_dly_inv_hdr.edi_interface;
            tbl_outbound.delete;
            var_invc_count := 0;
            var_line_count := 1;

         end if;

         /*-*/
         /* Increment the invoice count
         /*-*/
         var_invc_count := var_invc_count + 1;

         /*-*/
         /* Determine the Mars division
         /*-*/
         var_snackfood := false;
         var_petcare := false;
         if rcd_agency_dly_inv_hdr.org_008_orgid = '131' and
            rcd_agency_dly_inv_hdr.org_006_orgid = '51' then
            if rcd_agency_dly_inv_hdr.org_007_orgid = '10' then
               var_snackfood := true;
            end if;
            if rcd_agency_dly_inv_hdr.org_007_orgid = '11' or
               rcd_agency_dly_inv_hdr.org_007_orgid = '20' then
               var_petcare := true;
            end if;
         end if;

         /*-*/
         /* Set the classification 2 data
         /*-*/
         v02_record_classification := lads_right_pad('2',1,' ');
         v02_delivery_data_kind := lads_right_pad(substr(rcd_agency_dly_inv_hdr.edi_tran_code,1,2),2,' ');
         v02_despatched_date := lads_right_pad(substr(rcd_agency_dly_inv_hdr.dat_024_datum,3,6),6,' ');
         v02_shipment_date := lads_right_pad(substr(rcd_agency_dly_inv_hdr.dat_024_datum,3,6),6,' ');
         v02_delivery_number := lads_right_pad(substr(rcd_agency_dly_inv_hdr.edi_denpyo_number,1,8),8,' ');
         v02_sub_denpyo_number := lads_right_pad(substr(rcd_agency_dly_inv_hdr.edi_sub_denpyo_number,1,8),8,' ');
         v02_sub_denpyo_date := lads_right_pad(substr(rcd_agency_dly_inv_hdr.edi_sub_denpyo_date,1,6),6,' ');
         v02_primary_w_s_code := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.pnr_rg_partn),1,12),12,' ');
         v02_secondary_w_s_code := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.pnr_ag_partn),1,12),12,' ');
         v02_third_w_s_code := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.pnr_z5_partn),1,12),12,' ');
         v02_fourth_w_s_code := lads_right_pad(' ',12,' ');
         v02_fifth_w_s_code := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.ipn_we_partn),1,12),12,' ');
         v02_customer_code_class_no8 := lads_right_pad('1',1,' ');
         v02_customer_code_class_no9 := lads_right_pad('1',1,' ');
         v02_customer_code_class_no10 := lads_right_pad('1',1,' ');
         v02_customer_code_class_no11 := lads_right_pad(' ',1,' ');
         v02_customer_code_class_no12 := lads_right_pad('1',1,' ');
         v02_bill_type_information := lads_right_pad(' ',1,' ');
         if rcd_agency_dly_inv_hdr.edi_ship_to_type = '1' then
            v02_delivery_type_2 := lads_right_pad(' ',1,' ');
            if rcd_agency_dly_inv_hdr.gen_vsart = 'B0' then
               v02_delivery_type := lads_right_pad('3',1,' ');
            else
               v02_delivery_type := lads_right_pad('1',1,' ');
            end if;
         else
            v02_delivery_type_2 := lads_right_pad('1',1,' ');
            if rcd_agency_dly_inv_hdr.gen_vsart = 'B0' then
               v02_delivery_type := lads_right_pad('4',1,' ');
            else
               v02_delivery_type := lads_right_pad('2',1,' ');
            end if;
         end if;
         v02_distribution_type := lads_right_pad(' ',1,' ');
         v02_shipment_type := lads_right_pad(' ',1,' ');
         v02_disp_delivery_date_ind := lads_right_pad(' ',1,' ');
         v02_ap_reconciliation := lads_right_pad('1',1,' ');
         v02_summary_detail_type := lads_right_pad(' ',1,' ');
         v02_root_sales := lads_right_pad(' ',1,' ');
         v02_direct_deliver_fee_type := lads_right_pad(' ',1,' ');
         v02_delivered_from_warehouse := lads_right_pad(substr(rcd_agency_dly_inv_hdr.gen_werks,3,2),2,' ');
         v02_division_code := lads_right_pad(substr(rcd_agency_dly_inv_hdr.org_007_orgid,1,2),2,' ');
         v02_class_product_or_pack := lads_right_pad('0',1,' ');
         if var_snackfood = true then
            v02_denpyo_type_format := lads_right_pad('0',1,' ');
         else
            v02_denpyo_type_format := lads_right_pad(' ',1,' ');
         end if;
         v02_spare := lads_right_pad(' ',3,' ');

         /*-*/
         /* Output the classification 2 data
         /*-*/
         var_line_count := var_line_count + 1;
         var_output := v02_record_classification;
         var_output := var_output || to_char(var_line_count,'fm0000000');
         var_output := var_output || v02_delivery_data_kind;
         var_output := var_output || v02_despatched_date;
         var_output := var_output || v02_shipment_date;
         var_output := var_output || v02_delivery_number;
         var_output := var_output || v02_sub_denpyo_number;
         var_output := var_output || v02_primary_w_s_code;
         var_output := var_output || v02_secondary_w_s_code;
         var_output := var_output || v02_third_w_s_code;
         var_output := var_output || v02_fourth_w_s_code;
         var_output := var_output || v02_fifth_w_s_code;
         var_output := var_output || v02_customer_code_class_no8;
         var_output := var_output || v02_customer_code_class_no9;
         var_output := var_output || v02_customer_code_class_no10;
         var_output := var_output || v02_customer_code_class_no11;
         var_output := var_output || v02_customer_code_class_no12;
         var_output := var_output || v02_bill_type_information;
         var_output := var_output || v02_delivery_type;
         var_output := var_output || v02_distribution_type;
         var_output := var_output || v02_shipment_type;
         var_output := var_output || v02_disp_delivery_date_ind;
         var_output := var_output || v02_ap_reconciliation;
         var_output := var_output || v02_summary_detail_type;
         var_output := var_output || v02_root_sales;
         var_output := var_output || v02_direct_deliver_fee_type;
         var_output := var_output || v02_delivered_from_warehouse;
         var_output := var_output || v02_division_code;
         var_output := var_output || v02_class_product_or_pack;
         var_output := var_output || v02_sub_denpyo_date;
         var_output := var_output || v02_denpyo_type_format;
         var_output := var_output || v02_delivery_type_2;
         var_output := var_output || v02_spare;
         tbl_outbound(tbl_outbound.count + 1) := var_output;

         /*-*/
         /* Record classification 3/2 when required
         /*-*/
         if not(rcd_agency_dly_inv_hdr.pnr_ag_partn is null) then

            /*-*/
            /* Set the classification 3/2 data
            /*-*/
            v32_record_classification := lads_right_pad('3',1,' ');
            v32_denpyo_header_reference := lads_right_pad('2',1,' ');
            v32_customer_name := lads_right_pad(substr(rcd_agency_dly_inv_hdr.adj_ag_z3_name1,1,40),40,' ');
            v32_customer_address := lads_right_pad(substr(rcd_agency_dly_inv_hdr.adj_ag_z3_street||rcd_agency_dly_inv_hdr.adj_ag_z3_city1,1,56),56,' ');
            v32_reference_code_customer := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.pnr_ag_partn),1,12),12,' ');
            v32_japanese_desc_type := lads_right_pad(' ',1,' ');
            v32_edi_code_data := lads_right_pad(substr(rcd_agency_dly_inv_hdr.hdr_expnr,5,10),10,' ');

            /*-*/
            /* Output the classification 3/2 data
            /*-*/
            var_line_count := var_line_count + 1;
            var_output := v32_record_classification;
            var_output := var_output || to_char(var_line_count,'fm0000000');
            var_output := var_output || v32_denpyo_header_reference;
            var_output := var_output || v32_customer_name;
            var_output := var_output || v32_customer_address;
            var_output := var_output || v32_reference_code_customer;
            var_output := var_output || v32_japanese_desc_type;
            var_output := var_output || v32_edi_code_data;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end if;

         /*-*/
         /* Record classification 3/3 when required
         /*-*/
         if not(rcd_agency_dly_inv_hdr.pnr_z5_partn is null) then

            /*-*/
            /* Set the classification 3/3 data
            /*-*/
            v33_record_classification := lads_right_pad('3',1,' ');
            v33_denpyo_header_reference := lads_right_pad('3',1,' ');
            v33_customer_name := lads_right_pad(substr(rcd_agency_dly_inv_hdr.adj_z5_z3_name1,1,40),40,' ');
            v33_customer_address := lads_right_pad(substr(rcd_agency_dly_inv_hdr.adj_z5_z3_street||rcd_agency_dly_inv_hdr.adj_z5_z3_city1,1,56),56,' ');
            v33_reference_code_customer := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.pnr_z5_partn),1,12),12,' ');
            v33_japanese_desc_type := lads_right_pad(' ',1,' ');
            v33_edi_code_data := lads_right_pad(substr(rcd_agency_dly_inv_hdr.pnr_z5_knref,5,10),10,' ');

            /*-*/
            /* Output the classification 3/3 data
            /*-*/
            var_line_count := var_line_count + 1;
            var_output := v33_record_classification;
            var_output := var_output || to_char(var_line_count,'fm0000000');
            var_output := var_output || v33_denpyo_header_reference;
            var_output := var_output || v33_customer_name;
            var_output := var_output || v33_customer_address;
            var_output := var_output || v33_reference_code_customer;
            var_output := var_output || v33_japanese_desc_type;
            var_output := var_output || v33_edi_code_data;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end if;

         /*-*/
         /* Record classification 3/5 when required
         /*-*/
         if not(rcd_agency_dly_inv_hdr.ipn_we_partn is null) then

            /*-*/
            /* Set the classification 3/5 data
            /*-*/
            v35_record_classification := lads_right_pad('3',1,' ');
            v35_denpyo_header_reference := lads_right_pad('5',1,' ');
            v35_customer_name := lads_right_pad(substr(rcd_agency_dly_inv_hdr.iaj_we_z3_name1,1,40),40,' ');
            v35_customer_address := lads_right_pad(substr(rcd_agency_dly_inv_hdr.iaj_we_z3_street||rcd_agency_dly_inv_hdr.iaj_we_z3_city1,1,56),56,' ');
            v35_reference_code_customer := lads_right_pad(substr(lads_trim_code(rcd_agency_dly_inv_hdr.ipn_we_partn),1,12),12,' ');
            v35_japanese_desc_type := lads_right_pad(' ',1,' ');
            v35_edi_code_data := lads_right_pad(substr(rcd_agency_dly_inv_hdr.gen_knref,5,10),10,' ');

            /*-*/
            /* Output the classification 3/5 data
            /*-*/
            var_line_count := var_line_count + 1;
            var_output := v35_record_classification;
            var_output := var_output || to_char(var_line_count,'fm0000000');
            var_output := var_output || v35_denpyo_header_reference;
            var_output := var_output || v35_customer_name;
            var_output := var_output || v35_customer_address;
            var_output := var_output || v35_reference_code_customer;
            var_output := var_output || v35_japanese_desc_type;
            var_output := var_output || v35_edi_code_data;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end if;

         /*-*/
         /* Set the classification 4 data
         /*-*/
         v04_record_classification := lads_right_pad('4',1,' ');
         v04_message := lads_right_pad(substr(rcd_agency_dly_inv_hdr.txt_ja_tdline,1,90),90,' ');
         v04_japanese_desc_type := lads_right_pad(' ',1,' ');
         v04_discount_code := lads_right_pad(substr(rcd_agency_dly_inv_hdr.edi_disc_code,1,5),5,' ');
         v04_discount_name := lads_right_pad(substr(rcd_agency_dly_inv_hdr.edi_disc_name,1,16),16,' ');
         v04_spare := lads_right_pad(' ',8,' ');

         /*-*/
         /* Output the classification 4 data
         /*-*/
         var_line_count := var_line_count + 1;
         var_output := v04_record_classification;
         var_output := var_output || to_char(var_line_count,'fm0000000');
         var_output := var_output || v04_message;
         var_output := var_output || v04_japanese_desc_type;
         var_output := var_output || v04_discount_code;
         var_output := var_output || v04_discount_name;
         var_output := var_output || v04_spare;
         tbl_outbound(tbl_outbound.count + 1) := var_output;

         /*-*/
         /* Retrieve the collection agency invoice details
         /*-*/
         open csr_agency_dly_inv_det;
         loop
            fetch csr_agency_dly_inv_det into rcd_agency_dly_inv_det;
            if csr_agency_dly_inv_det%notfound then
               exit;
            end if;

            /*-*/
            /* Set the classification 5 data
            /*-*/
            v05_record_classification := lads_right_pad('5',1,' ');
            v05_denpyo_line_no := substr(to_char(rcd_agency_dly_inv_det.gen_genseq,'000000000000000'),17-2,2);
            var_product_code := lads_trim_code(rcd_agency_dly_inv_det.iob_002_idtnr);
            if var_snackfood = true and not(rcd_agency_dly_inv_det.gen_mat_legacy is null) then
               var_product_code := substr(lads_right_pad(var_product_code,8,' '),1,8) || rcd_agency_dly_inv_det.gen_mat_legacy;
            end if;
            v05_product_code := lads_right_pad(substr(var_product_code,1,16),16,' ');
            var_product_name := rcd_agency_dly_inv_det.mat_z3_maktx;
            if var_snackfood = true then
               if not(rcd_agency_dly_inv_det.icn_zrsp_krate is null) then
                  var_product_name := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_zrsp_krate,0),'000000000000000'),17-5,5) || var_product_name;
               else
                  var_product_name := lads_right_pad(' ',5,' ') || var_product_name;
               end if;
            end if;
            v05_product_name := lads_right_pad(substr(var_product_name,1,26),26,' ');
            v05_retail_units_per_case := substr(to_char(nvl(rcd_agency_dly_inv_det.gen_rsu_per_tdu,0),'000000000000000'),17-4,4);
            v05_quantity := substr(to_char(nvl(rcd_agency_dly_inv_det.gen_menge,0),'000000000000000'),17-5,5);
            if rcd_agency_dly_inv_det.gen_menee = 'CS' then
               v05_unit := lads_right_pad('1',1,' ');
            else
               v05_unit := lads_right_pad('3',1,' ');
            end if;
            if var_snackfood = true then
               v05_applied_retail_unit_price := substr(to_char(nvl(rcd_agency_dly_inv_det.ias_901_krate,0),'000000000000000'),17-9,9);
            else
               v05_applied_retail_unit_price := substr(to_char(nvl(rcd_agency_dly_inv_det.ias_901_krate,0)*100,'000000000000000'),17-9,9);
            end if;
            v05_amount := substr(to_char(nvl(rcd_agency_dly_inv_det.ias_901_betrg,0),'000000000000000'),17-10,10);
            if var_snackfood = true then
               v05_retail_price_type := lads_right_pad('A',1,' ');
               v05_retail_price_usage_type := lads_right_pad(' ',1,' ');
            else
               v05_retail_price_type := lads_right_pad(' ',1,' ');
               v05_retail_price_usage_type := lads_right_pad('2',1,' ');
            end if;
            v05_retail_unit_price := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_pr00_krate,0),'000000000000000'),17-9,9);
            if var_snackfood = false then
               v05_retail_unit_price := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_pr00_krate,0)*100,'000000000000000'),17-9,9);
            end if;
            v05_invoice_closing_date := lads_right_pad(' ',4,' ');
            v05_bank_account := lads_right_pad(' ',4,' ');
            v05_tenpu_classification := lads_right_pad(' ',1,' ');
            if rcd_agency_dly_inv_det.gen_pstyv = 'ZTNN' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZTIN' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZTPS' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZMAF' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZFAM' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZRNN' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZRIN' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZZRE' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZZRF' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZZCR' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZICR' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZZDR' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZIDR' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZKLN' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZRFS' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZNRN' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZORF' or
               rcd_agency_dly_inv_det.gen_pstyv = 'ZORM' then
               v05_tenpu_classification := lads_right_pad('3',1,' ');
            end if;
            if rcd_agency_dly_inv_det.gen_prod_spart = '01' then
               v05_special_code := lads_right_pad('3',1,' ');
            else
               v05_special_code := lads_right_pad('2',1,' ');
            end if;
            v05_tenpu_qty := to_char(0,'fm00');
            v05_order_no := lads_right_pad(substr(rcd_agency_dly_inv_hdr.ref_001_refnr,1,11),11,' ');
            v05_product_code_usage := lads_right_pad('1',1,' ');
            v05_consumption_tax_type := lads_right_pad(' ',1,' ');
            v05_piece_per_ball := substr(to_char(nvl(rcd_agency_dly_inv_det.gen_rsu_per_mcu,0),'000000000000000'),17-6,6);
            v05_spare := substr(to_char(nvl(rcd_agency_dly_inv_det.gen_mcu_per_tdu,0),'000000000000000'),17-5,5);

            /*-*/
            /* Output the classification 5 data
            /*-*/
            var_line_count := var_line_count + 1;
            var_output := v05_record_classification;
            var_output := var_output || to_char(var_line_count,'fm0000000');
            var_output := var_output || v05_denpyo_line_no;
            var_output := var_output || v05_product_code;
            var_output := var_output || v05_product_name;
            var_output := var_output || v05_retail_units_per_case;
            var_output := var_output || v05_quantity;
            var_output := var_output || v05_unit;
            var_output := var_output || v05_applied_retail_unit_price;
            var_output := var_output || v05_amount;
            var_output := var_output || v05_retail_price_type;
            var_output := var_output || v05_retail_price_usage_type;
            var_output := var_output || v05_retail_unit_price;
            var_output := var_output || v05_invoice_closing_date;
            var_output := var_output || v05_bank_account;
            var_output := var_output || v05_tenpu_classification;
            var_output := var_output || v05_special_code;
            var_output := var_output || v05_tenpu_qty;
            var_output := var_output || v05_order_no;
            var_output := var_output || v05_product_code_usage;
            var_output := var_output || v05_consumption_tax_type;
            var_output := var_output || v05_piece_per_ball;
            var_output := var_output || v05_spare;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

            /*-*/
            /* Record classification 7 when required
            /*-*/
            if not(rcd_agency_dly_inv_det.icn_zcrp_betrg is null) or
               not(rcd_agency_dly_inv_det.icn_zk25_betrg is null) or
               not(rcd_agency_dly_inv_det.icn_zk60_betrg is null) or
               not(rcd_agency_dly_inv_det.iob_r01_idtnr is null) then

               /*-*/
               /* Set the classification 7 data
               /*-*/
               v07_record_classification := lads_right_pad('7',1,' ');
               v07_denpyo_line_no := substr(to_char(rcd_agency_dly_inv_det.gen_genseq,'000000000000000'),17-2,2);
               v07_rounding_type := lads_right_pad(' ',1,' ');
               v07_discount_type_1 := lads_right_pad(' ',1,' ');
               v07_discount_method_1 := lads_right_pad(' ',1,' ');
               v07_amount_1 := '000000000';
               v07_spare_1 := lads_right_pad(' ',5,' ');
               v07_discount_type_2 := lads_right_pad(' ',1,' ');
               v07_discount_method_2 := lads_right_pad(' ',1,' ');
               v07_amount_2 := '000000000';
               v07_spare_2 := lads_right_pad(' ',5,' ');
               v07_discount_type_3 := lads_right_pad(' ',1,' ');
               v07_discount_method_3 := lads_right_pad(' ',1,' ');
               v07_amount_3 := '000000000';
               v07_spare_3 := lads_right_pad(' ',5,' ');
               v07_discount_type_4 := lads_right_pad(' ',1,' ');
               v07_discount_method_4 := lads_right_pad(' ',1,' ');
               v07_amount_4 := '000000000';
               v07_spare_4 := lads_right_pad(' ',5,' ');
               v07_discount_type_5 := lads_right_pad(' ',1,' ');
               v07_discount_method_5 := lads_right_pad(' ',1,' ');
               v07_amount_5 := '000000000';
               v07_spare_5 := lads_right_pad(' ',5,' ');
               v07_remarks := lads_right_pad(' ',17,' ');
               v07_free_uses := '0000000';
               v07_product_edi_jan_code := lads_right_pad(' ',13,' ');
               if not(rcd_agency_dly_inv_det.icn_zcrp_betrg is null) then
                  v07_discount_type_1 := lads_right_pad('1',1,' ');
                  v07_discount_method_1 := lads_right_pad('1',1,' ');
                  v07_amount_1 := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_zcrp_betrg,0),'000000000000000'),17-9,9);
                  v07_spare_1 := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_zcrp_kperc,0)*1000,'000000000000000'),17-5,5);
               end if;
               if not(rcd_agency_dly_inv_det.icn_zk60_betrg is null) then
                  v07_discount_type_2 := lads_right_pad('2',1,' ');
                  v07_discount_method_2 := lads_right_pad('1',1,' ');
                  v07_amount_2 := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_zk60_betrg,0),'000000000000000'),17-9,9);
                  v07_spare_2 := lads_right_pad(' ',5,' ');
               end if;
               if not(rcd_agency_dly_inv_det.icn_zk25_betrg is null) then
                  v07_discount_type_3 := lads_right_pad('3',1,' ');
                  v07_discount_method_3 := lads_right_pad('1',1,' ');
                  v07_amount_3 := substr(to_char(nvl(rcd_agency_dly_inv_det.icn_zk25_betrg,0),'000000000000000'),17-9,9);
                  v07_spare_3 := lads_right_pad(' ',5,' ');
               end if;
               if not(rcd_agency_dly_inv_det.iob_r01_idtnr is null) then
                  v07_product_edi_jan_code := lads_right_pad(substr(rcd_agency_dly_inv_det.iob_r01_idtnr,1,13),13,' ');
               end if;

               /*-*/
               /* Output the classification 7 data
               /*-*/
               var_line_count := var_line_count + 1;
               var_output := v07_record_classification;
               var_output := var_output || to_char(var_line_count,'fm0000000');
               var_output := var_output || v07_denpyo_line_no;
               var_output := var_output || v07_rounding_type;
               var_output := var_output || v07_discount_type_1;
               var_output := var_output || v07_discount_method_1;
               var_output := var_output || v07_amount_1;
               var_output := var_output || v07_spare_1;
               var_output := var_output || v07_discount_type_2;
               var_output := var_output || v07_discount_method_2;
               var_output := var_output || v07_amount_2;
               var_output := var_output || v07_spare_2;
               var_output := var_output || v07_discount_type_3;
               var_output := var_output || v07_discount_method_3;
               var_output := var_output || v07_amount_3;
               var_output := var_output || v07_spare_3;
               var_output := var_output || v07_discount_type_4;
               var_output := var_output || v07_discount_method_4;
               var_output := var_output || v07_amount_4;
               var_output := var_output || v07_spare_4;
               var_output := var_output || v07_discount_type_5;
               var_output := var_output || v07_discount_method_5;
               var_output := var_output || v07_amount_5;
               var_output := var_output || v07_spare_5;
               var_output := var_output || v07_remarks;
               var_output := var_output || v07_free_uses;
               var_output := var_output || v07_product_edi_jan_code;
               tbl_outbound(tbl_outbound.count + 1) := var_output;

            end if;

         end loop;
         close csr_agency_dly_inv_det;

      end loop;
      close csr_agency_dly_inv_hdr;

      /*-*/
      /* Process the previous interface when required
      /*-*/
      if not(var_interface_save is null) then

         /*-*/
         /* Create the invoice interface when required
         /*-*/
         if tbl_outbound.count != 0 then
            var_instance := lics_outbound_loader.create_interface(var_interface_save,var_interface_save||'_'||par_company||'_'||par_date||'.TXT',var_interface_save||'_'||par_company||'_'||par_date||'.TXT');
            for idx in 1..tbl_outbound.count loop
               lics_outbound_loader.append_data(tbl_outbound(idx));
            end loop;
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('Sent (' || to_char(var_invc_count,'fm999999990') || ') daily invoices to Collection Agency (' || var_interface_save || ')');

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Collection Agency Send Daily Invoices');

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
            lics_logging.write_log('**ERROR** - Collection Agency Send Daily Invoices - ' || var_exception);
            lics_logging.write_log('End - Collection Agency Send Daily Invoices');
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

end edi_agency_daily;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_agency_daily for dw_app.edi_agency_daily;
grant execute on edi_agency_daily to public;
