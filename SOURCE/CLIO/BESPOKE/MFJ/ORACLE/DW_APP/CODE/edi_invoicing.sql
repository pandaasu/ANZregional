/******************/
/* Package Header */
/******************/
create or replace package edi_invoicing as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_invoicing
    Owner   : dw_app

    Description
    -----------
    Electronic Data Interchange - EDI Invoicing

    This package contains the EDI invcoing control process. The package exposes
    one procedure EXECUTE that performs the extract based on the following
    parameters:

    1. PAR_ACTION (*ALL, *AGENCY) (MANDATORY)

       The EDI invoicing to be performed.

       *ALL = All invoicing
       *AGENCY_DAILY = Collection agency daily invoicing
       *WHSLR_DAILY = Wholesaler daily invoicing
       *WHSLR_MONTHLY = Wholesaler monthly invoicing

    2. PAR_DATE (date) (MANDATORY)

       The date for which the EDI invoicing is to be performed.

    **notes**
    1. A web log is produced under the search value EDI_INVOICING where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created
    2008/02   Steve Gregan   Changed wholesaler monthly date selection to the requested delivery date
    2008/02   Steve Gregan   Modified the wholesaler daily quantity and value logic to store naturaly signed numbers
    2008/02   Steve Gregan   Added sold to selection to EDI link logic

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_date in date);

end edi_invoicing;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_invoicing as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure create_agency_daily(par_date in varchar2);
   procedure send_agency_daily(par_date in varchar2);
   procedure create_whslr_daily(par_date in varchar2);
   procedure send_whslr_daily(par_date in varchar2);
   procedure create_whslr_monthly(par_date in varchar2);
   procedure send_whslr_monthly(par_date in varchar2);
   procedure email_whslr_monthly(par_date in varchar2);
   function overpunch_zoned(par_number in number, par_format in varchar2) return varchar2;

   /*-*/
   /* Private definitions
   /*-*/
   var_partner_code varchar2(128);
   var_partner_name varchar2(128);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_date in date) is

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
      var_date varchar2(8 char);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'EDI Invoicing';
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
      var_log_prefix := 'EDI - INVOICING';
      var_log_search := 'EDI_INVOICING';
      var_loc_string := 'EDI_INVOICING';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*ALL' and
         upper(par_action) != '*AGENCY_DAILY' and
         upper(par_action) != '*WHSLR_DAILY' and
         upper(par_action) != '*WHSLR_MONTHLY' then
         raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *AGENCY_DAILY, *WHSLR_DAILY or *WHSLR_MONTHLY');
      end if;
      if par_date is null then
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
      /* Format the character date
      /*-*/
      var_date := to_char(par_date,'yyyymmdd');

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - EDI Invoicing - Parameters(' || upper(par_action) || ' + '  || to_char(par_date,'yyyy/mm/dd') || ')');

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
         /* Execute the collection agency daily invoices
         /*-*/
         if upper(par_action) = '*ALL' or
            upper(par_action) = '*AGENCY_DAILY' then

            /*-*/
            /* Execute the collection agency daily procedures
            /*-*/
            begin
               create_agency_daily(var_date);
               send_agency_daily(var_date);
            exception
               when others then
                  var_errors := true;
            end;

         end if;

         /*-*/
         /* Execute the wholesaler daily invoices
         /*-*/
         if upper(par_action) = '*ALL' or
            upper(par_action) = '*WHSLR_DAILY' then

            /*-*/
            /* Execute the wholesaler daily procedures
            /*-*/
            begin
               create_whslr_daily(var_date);
               send_whslr_daily(var_date);
            exception
               when others then
                  var_errors := true;
            end;

         end if;

         /*-*/
         /* Execute the wholesaler monthly invoices
         /*-*/
         if upper(par_action) = '*ALL' or
            upper(par_action) = '*WHSLR_MONTHLY' then

            /*-*/
            /* Execute the wholesaler monthly procedures
            /*-*/
            begin
               create_whslr_monthly(var_date);
               send_whslr_monthly(var_date);
               email_whslr_monthly(var_date);
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
      lics_logging.write_log('End - EDI Invoicing');

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
                                         'One or more errors occurred during the EDI Invoicing execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - EDI - INVOICING - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*******************************************************************************/
   /* This procedure performs the create collection agency daily invoices routine */
   /*******************************************************************************/
   procedure create_agency_daily(par_date in varchar2) is

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
                  group by t01.belnr) T02
          where t01.belnr = t02.belnr
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
      lics_logging.write_log('Deleting any existing collection agency daily invoices for date');

      /*-*/
      /* Delete any existing invoice details for the date
      /*-*/
      delete from agency_dly_inv_det
       where creatn_date = par_date;

      /*-*/
      /* Delete any existing invoice headers for the date
      /*-*/
      delete from agency_dly_inv_hdr
       where creatn_date = par_date;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Creating collection agency daily invoices for date');

      /*-*/
      /* Initialise the routine
      /*-*/
      var_invc_count := 0;

      /*-*/
      /* Retrieve the invoices for the parameter date
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
         rcd_agency_dly_inv_hdr.company_code := null;
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
         close csr_edi_link;
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
            close csr_edi_link;
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
               /* Retrieve the invoice organisation data (003)
               /*-*/
               var_qualf := '003';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_agency_dly_inv_hdr.company_code := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

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
                        rcd_agency_dly_inv_det.company_code := rcd_agency_dly_inv_hdr.company_code;
                        rcd_agency_dly_inv_det.creatn_date := rcd_agency_dly_inv_hdr.creatn_date;
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
   end create_agency_daily;

   /*****************************************************************************/
   /* This procedure performs the send collection agency daily invoices routine */
   /*****************************************************************************/
   procedure send_agency_daily(par_date in varchar2) is

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
          where t01.creatn_date = par_date
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
      /* Retrieve the collection agency invoices for the date
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
                  var_instance := lics_outbound_loader.create_interface(var_interface_save,var_interface_save||'_'||par_date||'.TXT',var_interface_save||'_'||par_date||'.TXT');
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
            var_instance := lics_outbound_loader.create_interface(var_interface_save,var_interface_save||'_'||par_date||'.TXT',var_interface_save||'_'||par_date||'.TXT');
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
   end send_agency_daily;

   /************************************************************************/
   /* This procedure performs the create wholesaler daily invoices routine */
   /************************************************************************/
   procedure create_whslr_daily(par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_sndto_code varchar2(30);
      var_link_type varchar2(30);
      var_cust_type varchar2(30);
      var_cust_code varchar2(30);
      var_invc_count number;
      var_qualf varchar2(30 char);
      var_parvw varchar2(30 char);
      var_langu varchar2(30 char);
      var_iddat varchar2(30 char);
      var_kschl varchar2(30 char);
      var_zcrp_count number;
      var_invoice_type_factor number;
      var_price_record_factor number;
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
                  group by t01.belnr) T02
          where t01.belnr = t02.belnr
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

      cursor csr_invc_type is
         select t01.invc_type_sign as invc_type_sign
           from invc_type t01
          where t01.sap_invc_type_code = rcd_whslr_dly_inv_hdr.sap_invoice_type;
      rcd_invc_type csr_invc_type%rowtype;

      cursor csr_edi_link is
         select t01.*
           from edi_link t01
          where upper(t01.sap_cust_type) = var_cust_type
            and t01.sap_cust_code = var_cust_code;
      rcd_edi_link csr_edi_link%rowtype;

      cursor csr_whslr is
         select t01.*
           from whslr t01
          where t01.edi_sndto_code = var_sndto_code;
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
      lics_logging.write_log('Deleting any existing wholesaler daily invoices for date');

      /*-*/
      /* Delete any existing invoice details for the date
      /*-*/
      delete from whslr_dly_inv_det
       where sap_creatn_date = par_date;

      /*-*/
      /* Delete any existing invoice headers for the date
      /*-*/
      delete from whslr_dly_inv_hdr
       where sap_creatn_date = par_date;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('Creating wholesaler daily invoices for date');

      /*-*/
      /* Initialise the routine
      /*-*/
      var_invc_count := 0;

      /*-*/
      /* Retrieve the invoices for the parameter date
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
         rcd_whslr_dly_inv_hdr.sap_company_code := null;
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
         /* Retrieve the invoice sold to partner data (AG)
         /*-*/
         var_parvw := 'AG';
         open csr_lads_inv_pnr;
         fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
         if csr_lads_inv_pnr%found then
            rcd_whslr_dly_inv_hdr.sap_prmry_code := rcd_lads_inv_pnr.partn;
         end if;
         close csr_lads_inv_pnr;

         /*-*/
         /* Retrieve the wholesaler send to code
         /* **notes** 1. The sold to or payer customer must exist in the EDI link table (*WHSLR)
         /*           2. Sold to code overrides payer code
         /*-*/
         var_sndto_code := null;
         var_link_type := null;
         var_cust_type := '*SOLDTO';
         var_cust_code := lads_trim_code(rcd_whslr_dly_inv_hdr.sap_prmry_code);
         open csr_edi_link;
         fetch csr_edi_link into rcd_edi_link;
         if csr_edi_link%found then
            var_link_type := rcd_edi_link.edi_link_type;
            if upper(rcd_edi_link.edi_link_type) = '*WHSLR' then
               var_sndto_code := rcd_edi_link.edi_link_code;
            end if;
         end if;
         close csr_edi_link;
         if var_link_type is null then
            var_cust_type := '*PAYER';
            var_cust_code := lads_trim_code(rcd_whslr_dly_inv_hdr.sap_payer_code);
            open csr_edi_link;
            fetch csr_edi_link into rcd_edi_link;
            if csr_edi_link%found then
               if upper(rcd_edi_link.edi_link_type) = '*WHSLR' then
                  var_sndto_code := rcd_edi_link.edi_link_code;
               end if;
            end if;
            close csr_edi_link;
         end if;

         /*-*/
         /* Only process wholesaler invoices
         /*-*/
         if not(var_sndto_code is null) then

            /*-*/
            /* Retrieve the wholesaler data
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
               /* Retrieve the invoice organisation data (003)
               /*-*/
               var_qualf := '003';
               open csr_lads_inv_org;
               fetch csr_lads_inv_org into rcd_lads_inv_org;
               if csr_lads_inv_org%found then
                  rcd_whslr_dly_inv_hdr.sap_company_code := rcd_lads_inv_org.orgid;
               end if;
               close csr_lads_inv_org;

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
               /* Retrieve the invoice type sign and factor
               /*-*/
               open csr_invc_type;
               fetch csr_invc_type into rcd_invc_type;
               if csr_invc_type%notfound then
                  rcd_invc_type.invc_type_sign := '+';
               end if;
               close csr_invc_type;
               var_invoice_type_factor := 1;
	       if rcd_invc_type.invc_type_sign = '-' then
	          var_invoice_type_factor := -1;
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
                     rcd_whslr_dly_inv_det.sap_company_code := rcd_whslr_dly_inv_hdr.sap_company_code;
                     rcd_whslr_dly_inv_det.sap_creatn_date := rcd_whslr_dly_inv_hdr.sap_creatn_date;
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
                        rcd_whslr_dly_inv_det.edi_case_qty := nvl(lads_to_number(rcd_lads_inv_gen.menge),'0') * var_invoice_type_factor;
                        rcd_whslr_dly_inv_det.edi_delivered_qty := rcd_whslr_dly_inv_det.edi_rsu_per_tdu * rcd_whslr_dly_inv_det.edi_case_qty;
                     else
                        rcd_whslr_dly_inv_det.edi_delivered_qty := nvl(lads_to_number(rcd_lads_inv_gen.menge),'0') * var_invoice_type_factor;
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
                        rcd_whslr_dly_inv_det.sap_amount := nvl(lads_to_number(rcd_lads_inv_ias.betrg),0) * var_invoice_type_factor;
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
                        var_price_record_factor := 1;
                        if rcd_lads_inv_icn.alckz = '-' then
                           var_price_record_factor := -1;
                        end if;
                        if rcd_lads_inv_icn.kschl = 'ZCRP' then
                           var_zcrp_count := 1;
                           rcd_whslr_dly_inv_det.sap_disc_volume_pct := nvl(lads_to_number(rcd_lads_inv_icn.kperc),0);
                           rcd_whslr_dly_inv_det.sap_disc_volume := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0) * var_invoice_type_factor * var_price_record_factor;
                        end if;
                        if rcd_lads_inv_icn.kschl = 'ZK25' then
                           rcd_whslr_dly_inv_det.sap_disc_noreturn := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0) * var_invoice_type_factor * var_price_record_factor;
                        end if;
                        if rcd_lads_inv_icn.kschl = 'ZK60' then
                           rcd_whslr_dly_inv_det.sap_disc_earlypay := nvl(lads_to_number(rcd_lads_inv_icn.betrg),0) * var_invoice_type_factor * var_price_record_factor;
                        end if;
                     end loop;
                     close csr_lads_inv_icn;

                     /*-*/
                     /* Set the EDI values
                     /*-*/
                     if rcd_whslr_dly_inv_det.edi_rsu_per_tdu = 0 then
                        rcd_whslr_dly_inv_det.edi_unit_price := trunc(rcd_whslr_dly_inv_det.sap_unit_price*100,0);
                     else
                        rcd_whslr_dly_inv_det.edi_unit_price := trunc((rcd_whslr_dly_inv_det.sap_unit_price*100)/rcd_whslr_dly_inv_det.edi_rsu_per_tdu,0);
                     end if;
                     rcd_whslr_dly_inv_det.edi_amount := (rcd_whslr_dly_inv_det.edi_unit_price * rcd_whslr_dly_inv_det.edi_delivered_qty) / 100;

                     /*-*/
                     /* Accumulate the EDI total values
                     /*-*/
                     rcd_whslr_dly_inv_hdr.edi_case_qty := rcd_whslr_dly_inv_hdr.edi_case_qty + rcd_whslr_dly_inv_det.edi_case_qty;
                     rcd_whslr_dly_inv_hdr.edi_amount := rcd_whslr_dly_inv_hdr.edi_amount + rcd_whslr_dly_inv_det.edi_amount;
                     rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt := rcd_whslr_dly_inv_hdr.edi_disc_volume_cnt + var_zcrp_count;
                     rcd_whslr_dly_inv_hdr.edi_disc_volume_pct := rcd_whslr_dly_inv_hdr.edi_disc_volume_pct + abs(rcd_whslr_dly_inv_det.sap_disc_volume_pct);
                     rcd_whslr_dly_inv_hdr.edi_disc_volume := rcd_whslr_dly_inv_hdr.edi_disc_volume + rcd_whslr_dly_inv_det.sap_disc_volume;
                     if rcd_whslr_dly_inv_hdr.edi_disc_code = 'A' then
                        rcd_whslr_dly_inv_hdr.edi_disc_noreturn := rcd_whslr_dly_inv_hdr.edi_disc_noreturn + rcd_whslr_dly_inv_det.sap_disc_noreturn;
                        rcd_whslr_dly_inv_hdr.edi_disc_earlypay := rcd_whslr_dly_inv_hdr.edi_disc_earlypay + rcd_whslr_dly_inv_det.sap_disc_earlypay;
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
   end create_whslr_daily;

   /**********************************************************************/
   /* This procedure performs the send wholesaler daily invoices routine */
   /**********************************************************************/
   procedure send_whslr_daily(par_date in varchar2) is

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
          where t01.sap_creatn_date = par_date
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
      /* Retrieve the wholesaler invoices for the parameter date
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
            var_l1_unit_price := substr(to_char(nvl(rcd_whslr_dly_inv_det.edi_unit_price,0),'000000000000000'),17-10,10);
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
         var_instance := lics_outbound_loader.create_interface('LADEDI02','LADEDI02_'||par_date,'LADEDI02_'||par_date||'.TXT');
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
   end send_whslr_daily;

   /**************************************************************************/
   /* This procedure performs the create wholesaler monthly invoices routine */
   /**************************************************************************/
   procedure create_whslr_monthly(par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_brnch_save varchar2(128);
      rcd_whslr_mly_inv_hdr whslr_mly_inv_hdr%rowtype;
      rcd_whslr_mly_inv_bch whslr_mly_inv_bch%rowtype;
      rcd_whslr_mly_inv_det whslr_mly_inv_det%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr is
         select t01.edi_sndto_code,
                t01.edi_whslr_code,
                t01.edi_whslr_name,
                t01.edi_disc_code,
                t01.edi_email_group,
                t02.edi_bilto_date,
                t02.edi_bilto_str_date,
                t02.edi_bilto_end_date,
                t02.edi_sndon_date 
           from whslr t01,
                whslr_billing t02
          where t01.edi_sndto_code = t02.edi_sndto_code
            and t02.edi_sndon_date = par_date
          order by t01.edi_sndto_code asc;
      rcd_whslr csr_whslr%rowtype;

      cursor csr_whslr_dly_inv_hdr is
         select t01.*
           from whslr_dly_inv_hdr t01
          where t01.edi_sndto_code = rcd_whslr_mly_inv_hdr.edi_sndto_code
            and (t01.edi_invoice_date >= rcd_whslr_mly_inv_hdr.edi_bilto_str_date and
                 t01.edi_invoice_date <= rcd_whslr_mly_inv_hdr.edi_bilto_end_date)
          order by t01.edi_brnch_code asc,
                   t01.sap_invoice_number asc;
      rcd_whslr_dly_inv_hdr csr_whslr_dly_inv_hdr%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Wholesaler Create Monthly Invoices');

      /*-*/
      /* Retrieve the wholesalers with a send on date (YYYYMMDD) equal to the parameter date
      /*-*/
      open csr_whslr;
      loop
         fetch csr_whslr into rcd_whslr;
         if csr_whslr%notfound then
            exit;
         end if;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('Processing wholesaler (' || rcd_whslr.edi_sndto_code || ') for date (' || rcd_whslr.edi_sndon_date || ')');

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('Deleting existing wholesaler monthly invoice data');

         /*-*/
         /* Delete any existing monthly invoice detail rows
         /*-*/
         delete from whslr_mly_inv_det
          where edi_sndto_code = rcd_whslr.edi_sndto_code
            and edi_bilto_date = rcd_whslr.edi_bilto_date;

         /*-*/
         /* Delete any existing monthly invoice branch rows
         /*-*/
         delete from whslr_mly_inv_bch
          where edi_sndto_code = rcd_whslr.edi_sndto_code
            and edi_bilto_date = rcd_whslr.edi_bilto_date;

         /*-*/
         /* Delete any existing monthly invoice header rows
         /*-*/
         delete from whslr_mly_inv_hdr
          where edi_sndto_code = rcd_whslr.edi_sndto_code
            and edi_bilto_date = rcd_whslr.edi_bilto_date;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('Creating wholesaler monthly invoice data');

         /*-*/
         /* Initialise the wholesaler monthly invoice header
         /*-*/
         rcd_whslr_mly_inv_hdr.edi_sndto_code := rcd_whslr.edi_sndto_code;
         rcd_whslr_mly_inv_hdr.edi_bilto_date := rcd_whslr.edi_bilto_date;
         rcd_whslr_mly_inv_hdr.edi_bilto_str_date := rcd_whslr.edi_bilto_str_date;
         rcd_whslr_mly_inv_hdr.edi_bilto_end_date := rcd_whslr.edi_bilto_end_date;
         rcd_whslr_mly_inv_hdr.edi_sndon_date := rcd_whslr.edi_sndon_date;
         rcd_whslr_mly_inv_hdr.edi_snton_date := to_char(sysdate,'yyyymmdd');
         rcd_whslr_mly_inv_hdr.edi_whslr_code := rcd_whslr.edi_whslr_code;
         rcd_whslr_mly_inv_hdr.edi_partn_code := var_partner_code;
         rcd_whslr_mly_inv_hdr.edi_partn_name := var_partner_name;
         rcd_whslr_mly_inv_hdr.edi_count := 0;
         rcd_whslr_mly_inv_hdr.edi_amount := 0;
         rcd_whslr_mly_inv_hdr.edi_discount := 0;
         rcd_whslr_mly_inv_hdr.edi_balance := 0;
         rcd_whslr_mly_inv_hdr.edi_tax := 0;
         rcd_whslr_mly_inv_hdr.edi_value := 0;
         rcd_whslr_mly_inv_hdr.edi_disc_volume := 0;
         rcd_whslr_mly_inv_hdr.edi_disc_noreturn := 0;
         rcd_whslr_mly_inv_hdr.edi_disc_earlypay := 0;

         /*-*/
         /* Insert the wholesaler monthly invoice header row
         /*-*/
         insert into whslr_mly_inv_hdr values rcd_whslr_mly_inv_hdr;

         /*-*/
         /* Retrieve the daily invoices for the wholesaler
         /* **notes** 1. Sort by branch code
         /*-*/
         var_brnch_save := null;
         open csr_whslr_dly_inv_hdr;
         loop
            fetch csr_whslr_dly_inv_hdr into rcd_whslr_dly_inv_hdr;
            if csr_whslr_dly_inv_hdr%notfound then
               exit;
            end if;

            /*-*/
            /* Change in wholesaler branch
            /*-*/
            if var_brnch_save is null or
               var_brnch_save != rcd_whslr_dly_inv_hdr.edi_brnch_code then

               /*-*/
               /* Process the previous wholesaler branch when required
               /*-*/
               if not(var_brnch_save is null) then

                  /*-*/
                  /* Update the wholesaler monthly invoice branch row
                  /*-*/
                  update whslr_mly_inv_bch
                     set edi_count = rcd_whslr_mly_inv_bch.edi_count,
                         edi_amount = rcd_whslr_mly_inv_bch.edi_amount,
                         edi_discount = rcd_whslr_mly_inv_bch.edi_discount,
                         edi_balance = rcd_whslr_mly_inv_bch.edi_balance,
                         edi_tax = rcd_whslr_mly_inv_bch.edi_tax,
                         edi_value = rcd_whslr_mly_inv_bch.edi_value,
                         edi_disc_volume = rcd_whslr_mly_inv_bch.edi_disc_volume,
                         edi_disc_noreturn = rcd_whslr_mly_inv_bch.edi_disc_noreturn,
                         edi_disc_earlypay = rcd_whslr_mly_inv_bch.edi_disc_earlypay
                   where edi_sndto_code = rcd_whslr_mly_inv_bch.edi_sndto_code
                     and edi_bilto_date = rcd_whslr_mly_inv_bch.edi_bilto_date
                     and edi_brnch_code = rcd_whslr_mly_inv_bch.edi_brnch_code;

               end if;

               /*-*/
               /* Initialise the new wholesaler branch
               /*-*/
               var_brnch_save := rcd_whslr_dly_inv_hdr.edi_brnch_code;

               /*-*/
               /* Initialise the wholesaler monthly invoice branch row
               /*-*/
               rcd_whslr_mly_inv_bch.edi_sndto_code := rcd_whslr_mly_inv_hdr.edi_sndto_code;
               rcd_whslr_mly_inv_bch.edi_bilto_date := rcd_whslr_mly_inv_hdr.edi_bilto_date;
               rcd_whslr_mly_inv_bch.edi_brnch_code := rcd_whslr_dly_inv_hdr.edi_brnch_code;
               rcd_whslr_mly_inv_bch.edi_brnch_name := rcd_whslr_dly_inv_hdr.edi_brnch_name;
               rcd_whslr_mly_inv_bch.edi_count := 0;
               rcd_whslr_mly_inv_bch.edi_amount := 0;
               rcd_whslr_mly_inv_bch.edi_discount := 0;
               rcd_whslr_mly_inv_bch.edi_balance := 0;
               rcd_whslr_mly_inv_bch.edi_tax := 0;
               rcd_whslr_mly_inv_bch.edi_value := 0;
               rcd_whslr_mly_inv_bch.edi_disc_volume := 0;
               rcd_whslr_mly_inv_bch.edi_disc_noreturn := 0;
               rcd_whslr_mly_inv_bch.edi_disc_earlypay := 0;

               /*-*/
               /* Insert the wholesaler monthly invoice branch row
               /*-*/
               insert into whslr_mly_inv_bch values rcd_whslr_mly_inv_bch;

            end if;

            /*-*/
            /* Initialise the wholesaler monthly invoice detail
            /*-*/
            rcd_whslr_mly_inv_det.edi_sndto_code := rcd_whslr_mly_inv_hdr.edi_sndto_code;
            rcd_whslr_mly_inv_det.edi_bilto_date := rcd_whslr_mly_inv_hdr.edi_bilto_date;
            rcd_whslr_mly_inv_det.edi_brnch_code := rcd_whslr_mly_inv_bch.edi_brnch_code;
            rcd_whslr_mly_inv_det.edi_invoice_number := rcd_whslr_dly_inv_hdr.edi_invoice_number;
            rcd_whslr_mly_inv_det.edi_invoice_date := rcd_whslr_dly_inv_hdr.edi_invoice_date;
            rcd_whslr_mly_inv_det.edi_sldto_code := rcd_whslr_dly_inv_hdr.edi_sldto_code;
            rcd_whslr_mly_inv_det.edi_tran_code := rcd_whslr_dly_inv_hdr.edi_tran_code;
            rcd_whslr_mly_inv_det.edi_ship_to_type := rcd_whslr_dly_inv_hdr.edi_ship_to_type;
            rcd_whslr_mly_inv_det.edi_order_number := rcd_whslr_dly_inv_hdr.edi_order_number;
            rcd_whslr_mly_inv_det.edi_order_date := rcd_whslr_dly_inv_hdr.edi_order_date;
            rcd_whslr_mly_inv_det.edi_amount := rcd_whslr_dly_inv_hdr.edi_amount;
            rcd_whslr_mly_inv_det.edi_discount := rcd_whslr_dly_inv_hdr.edi_discount;
            rcd_whslr_mly_inv_det.edi_balance := rcd_whslr_dly_inv_hdr.edi_balance;
            rcd_whslr_mly_inv_det.edi_tax := rcd_whslr_dly_inv_hdr.edi_tax;
            rcd_whslr_mly_inv_det.edi_value := rcd_whslr_dly_inv_hdr.edi_value;
            rcd_whslr_mly_inv_det.edi_disc_volume := rcd_whslr_dly_inv_hdr.edi_disc_volume;
            rcd_whslr_mly_inv_det.edi_disc_noreturn := rcd_whslr_dly_inv_hdr.edi_disc_noreturn;
            rcd_whslr_mly_inv_det.edi_disc_earlypay := rcd_whslr_dly_inv_hdr.edi_disc_earlypay;

            /*-*/
            /* Insert the wholesaler monthly invoice detail row
            /*-*/
            insert into whslr_mly_inv_det values rcd_whslr_mly_inv_det;

            /*-*/
            /* Accumulate the wholesaler monthly invoice branch values
            /*-*/
            rcd_whslr_mly_inv_bch.edi_count := rcd_whslr_mly_inv_bch.edi_count + 1;
            rcd_whslr_mly_inv_bch.edi_amount := rcd_whslr_mly_inv_bch.edi_amount + rcd_whslr_mly_inv_det.edi_amount;
            rcd_whslr_mly_inv_bch.edi_discount := rcd_whslr_mly_inv_bch.edi_discount + rcd_whslr_mly_inv_det.edi_discount;
            rcd_whslr_mly_inv_bch.edi_balance := rcd_whslr_mly_inv_bch.edi_balance + rcd_whslr_mly_inv_det.edi_balance;
            rcd_whslr_mly_inv_bch.edi_tax := rcd_whslr_mly_inv_bch.edi_tax + rcd_whslr_mly_inv_det.edi_tax;
            rcd_whslr_mly_inv_bch.edi_value := rcd_whslr_mly_inv_bch.edi_value + rcd_whslr_mly_inv_det.edi_value;
            rcd_whslr_mly_inv_bch.edi_disc_volume := rcd_whslr_mly_inv_bch.edi_disc_volume + rcd_whslr_mly_inv_det.edi_disc_volume;
            rcd_whslr_mly_inv_bch.edi_disc_noreturn := rcd_whslr_mly_inv_bch.edi_disc_noreturn + rcd_whslr_mly_inv_det.edi_disc_noreturn;
            rcd_whslr_mly_inv_bch.edi_disc_earlypay := rcd_whslr_mly_inv_bch.edi_disc_earlypay + rcd_whslr_mly_inv_det.edi_disc_earlypay;

            /*-*/
            /* Accumulate the wholesaler monthly invoice header values
            /*-*/
            rcd_whslr_mly_inv_hdr.edi_count := rcd_whslr_mly_inv_hdr.edi_count + 1;
            rcd_whslr_mly_inv_hdr.edi_amount := rcd_whslr_mly_inv_hdr.edi_amount + rcd_whslr_mly_inv_det.edi_amount;
            rcd_whslr_mly_inv_hdr.edi_discount := rcd_whslr_mly_inv_hdr.edi_discount + rcd_whslr_mly_inv_det.edi_discount;
            rcd_whslr_mly_inv_hdr.edi_balance := rcd_whslr_mly_inv_hdr.edi_balance + rcd_whslr_mly_inv_det.edi_balance;
            rcd_whslr_mly_inv_hdr.edi_tax := rcd_whslr_mly_inv_hdr.edi_tax + rcd_whslr_mly_inv_det.edi_tax;
            rcd_whslr_mly_inv_hdr.edi_value := rcd_whslr_mly_inv_hdr.edi_value + rcd_whslr_mly_inv_det.edi_value;
            rcd_whslr_mly_inv_hdr.edi_disc_volume := rcd_whslr_mly_inv_hdr.edi_disc_volume + rcd_whslr_mly_inv_det.edi_disc_volume;
            rcd_whslr_mly_inv_hdr.edi_disc_noreturn := rcd_whslr_mly_inv_hdr.edi_disc_noreturn + rcd_whslr_mly_inv_det.edi_disc_noreturn;
            rcd_whslr_mly_inv_hdr.edi_disc_earlypay := rcd_whslr_mly_inv_hdr.edi_disc_earlypay + rcd_whslr_mly_inv_det.edi_disc_earlypay;

         end loop;
         close csr_whslr_dly_inv_hdr;

         /*-*/
         /* Process the previous wholesaler branch when required
         /*-*/
         if not(var_brnch_save is null) then

            /*-*/
            /* Update the wholesaler monthly invoice branch row
            /*-*/
            update whslr_mly_inv_bch
               set edi_count = rcd_whslr_mly_inv_bch.edi_count,
                   edi_amount = rcd_whslr_mly_inv_bch.edi_amount,
                   edi_discount = rcd_whslr_mly_inv_bch.edi_discount,
                   edi_balance = rcd_whslr_mly_inv_bch.edi_balance,
                   edi_tax = rcd_whslr_mly_inv_bch.edi_tax,
                   edi_value = rcd_whslr_mly_inv_bch.edi_value,
                   edi_disc_volume = rcd_whslr_mly_inv_bch.edi_disc_volume,
                   edi_disc_noreturn = rcd_whslr_mly_inv_bch.edi_disc_noreturn,
                   edi_disc_earlypay = rcd_whslr_mly_inv_bch.edi_disc_earlypay
             where edi_sndto_code = rcd_whslr_mly_inv_bch.edi_sndto_code
               and edi_bilto_date = rcd_whslr_mly_inv_bch.edi_bilto_date
               and edi_brnch_code = rcd_whslr_mly_inv_bch.edi_brnch_code;

         end if;

         /*-*/
         /* Update the wholesaler monthly invoice header row
         /*-*/
         update whslr_mly_inv_hdr
            set edi_count = rcd_whslr_mly_inv_hdr.edi_count,
                edi_amount = rcd_whslr_mly_inv_hdr.edi_amount,
                edi_discount = rcd_whslr_mly_inv_hdr.edi_discount,
                edi_balance = rcd_whslr_mly_inv_hdr.edi_balance,
                edi_tax = rcd_whslr_mly_inv_hdr.edi_tax,
                edi_value = rcd_whslr_mly_inv_hdr.edi_value,
                edi_disc_volume = rcd_whslr_mly_inv_hdr.edi_disc_volume,
                edi_disc_noreturn = rcd_whslr_mly_inv_hdr.edi_disc_noreturn,
                edi_disc_earlypay = rcd_whslr_mly_inv_hdr.edi_disc_earlypay
          where edi_sndto_code = rcd_whslr_mly_inv_hdr.edi_sndto_code
            and edi_bilto_date = rcd_whslr_mly_inv_hdr.edi_bilto_date;

      end loop;
      close csr_whslr;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Wholesaler Create Monthly Invoices');

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
            lics_logging.write_log('**ERROR** - Wholesaler Create Monthly Invoices - ' || var_exception);
            lics_logging.write_log('End - Wholesaler Create Monthly Invoices');
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
   end create_whslr_monthly;

   /************************************************************************/
   /* This procedure performs the send wholesaler monthly invoices routine */
   /************************************************************************/
   procedure send_whslr_monthly(par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(4000);
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
      var_h1_payment_type varchar2(128 char);
      var_h1_partner_code varchar2(128 char);
      var_h1_partner_name varchar2(128 char);
      var_h1_account_code varchar2(128 char);
      var_h1_account_name varchar2(128 char);
      var_h1_billing_date varchar2(128 char);
      var_h1_billing_start varchar2(128 char);
      var_h1_billing_end varchar2(128 char);
      var_h1_bill_whslr_code varchar2(128 char);
      var_h1_bill_branch_code varchar2(128 char);
      var_h1_bill_branch_name varchar2(128 char);
      var_h1_reserved_field varchar2(128 char);
      /*-*/
      var_l1_data_type varchar2(128 char);
      var_l1_maker_code varchar2(128 char);
      var_l1_process_date varchar2(128 char);
      var_l1_sequential_number varchar2(128 char);
      var_l1_record_type  varchar2(128 char);
      var_l1_bill_branch_code varchar2(128 char);
      var_l1_sold_to_party_code varchar2(128 char);
      var_l1_deal_type varchar2(128 char);
      var_l1_order_date varchar2(128 char);
      var_l1_ship_to_type varchar2(128 char);
      var_l1_order_number varchar2(128 char);
      var_l1_classification_code varchar2(128 char);
      var_l1_correction_type varchar2(128 char);
      var_l1_invoice_date varchar2(128 char);
      var_l1_invoice_number varchar2(128 char);
      var_l1_payment_date varchar2(128 char);
      var_l1_payment_type varchar2(128 char);
      var_l1_amount varchar2(128 char);
      var_l1_discount varchar2(128 char);
      var_l1_balance varchar2(128 char);
      var_l1_consumption_type varchar2(128 char);
      var_l1_consumption_tax varchar2(128 char);
      var_l1_comment1 varchar2(128 char);
      var_l1_comment2 varchar2(128 char);
      var_l1_comment3 varchar2(128 char);
      var_l1_comment4 varchar2(128 char);
      var_l1_page_number varchar2(128 char);
      var_l1_row_number varchar2(128 char);
      /*-*/
      var_t1_data_type varchar2(128 char);
      var_t1_maker_code varchar2(128 char);
      var_t1_process_date varchar2(128 char);
      var_t1_sequential_number varchar2(128 char);
      var_t1_record_type varchar2(128 char);
      var_t1_wholesaler varchar2(128 char);
      var_t1_branch varchar2(128 char);
      var_t1_count varchar2(128 char);
      var_t1_amount varchar2(128 char);
      var_t1_discount varchar2(128 char);
      var_t1_balance varchar2(128 char);
      var_t1_consumption_tax varchar2(128 char);
      var_t1_value varchar2(128 char);
      var_t1_ddct1_invoice varchar2(128 char);
      var_t1_ddct1_summary varchar2(128 char);
      var_t1_ddct1_consumption_tax varchar2(128 char);
      var_t1_ddct2_record varchar2(128 char);
      var_t1_ddct2_summary varchar2(128 char);
      var_t1_ddct2_consumption_tax varchar2(128 char);
      var_t1_reserved_field varchar2(128 char);
      /*-*/
      var_t2_data_type varchar2(128 char);
      var_t2_maker_code varchar2(128 char);
      var_t2_process_date varchar2(128 char);
      var_t2_sequential_number varchar2(128 char);
      var_t2_record_type varchar2(128 char);
      var_t2_wholesaler varchar2(128 char);
      var_t2_reserved_field1 varchar2(128 char);
      var_t2_count varchar2(128 char);
      var_t2_amount varchar2(128 char);
      var_t2_discount varchar2(128 char);
      var_t2_balance varchar2(128 char);
      var_t2_consumption_tax varchar2(128 char);
      var_t2_value varchar2(128 char);
      var_t2_ddct1_invoice varchar2(128 char);
      var_t2_ddct1_summary varchar2(128 char);
      var_t2_ddct1_consumption_tax varchar2(128 char);
      var_t2_ddct2_record varchar2(128 char);
      var_t2_ddct2_summary varchar2(128 char);
      var_t2_ddct2_consumption_tax varchar2(128 char);
      var_t2_reserved_field2 varchar2(128 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_mly_inv_hdr is
         select t01.*
           from whslr_mly_inv_hdr t01
          where t01.edi_sndon_date = par_date
            and t01.edi_count != 0
          order by t01.edi_sndto_code asc;
      rcd_whslr_mly_inv_hdr csr_whslr_mly_inv_hdr%rowtype;

      cursor csr_whslr_mly_inv_bch is
         select t01.*
           from whslr_mly_inv_bch t01
          where t01.edi_sndto_code = rcd_whslr_mly_inv_hdr.edi_sndto_code
            and t01.edi_bilto_date = rcd_whslr_mly_inv_hdr.edi_bilto_date
          order by t01.edi_brnch_code asc;
      rcd_whslr_mly_inv_bch csr_whslr_mly_inv_bch%rowtype;

      cursor csr_whslr_mly_inv_det is
         select t01.*
           from whslr_mly_inv_det t01
          where t01.edi_sndto_code = rcd_whslr_mly_inv_bch.edi_sndto_code
            and t01.edi_bilto_date = rcd_whslr_mly_inv_bch.edi_bilto_date
            and t01.edi_brnch_code = rcd_whslr_mly_inv_bch.edi_brnch_code
          order by t01.edi_invoice_number asc;
      rcd_whslr_mly_inv_det csr_whslr_mly_inv_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the routine
      /*-*/
      var_data_type := 'K2';
      var_maker_code := '02397';
      var_process_date := to_char(sysdate,'dd');
      var_send_process_date := to_char(sysdate,'yymmdd');
      var_send_process_time := to_char(sysdate,'hhmiss');
      var_row_count := 0;
      tbl_outbound.delete;

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Wholesaler Send Monthly Invoices');

      /*-*/
      /* Retrieve the wholesaler invoices for the parameter date
      /*-*/
      open csr_whslr_mly_inv_hdr;
      loop
         fetch csr_whslr_mly_inv_hdr into rcd_whslr_mly_inv_hdr;
         if csr_whslr_mly_inv_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the wholesaler
         /*-*/
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
         var_fh_final_receiver := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_sndto_code,1,8),8,' ');
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

         /*-*/
         /* Retrieve the wholesaler monthly branch data
         /*-*/
         open csr_whslr_mly_inv_bch;
         loop
            fetch csr_whslr_mly_inv_bch into rcd_whslr_mly_inv_bch;
            if csr_whslr_mly_inv_bch%notfound then
               exit;
            end if;

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
            var_h1_payment_type := lads_right_pad('11',2,' ');
            var_h1_partner_code := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_partn_code,1,7),7,' ');
            var_h1_partner_name := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_partn_name,1,25),25,' ');
            var_h1_account_code := lads_right_pad(' ',1,' ');
            var_h1_account_name := lads_right_pad(' ',15,' ');
            var_h1_billing_date := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_bilto_date,3,6),6,' ');
            var_h1_billing_start := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_bilto_str_date,3,6),6,' ');
            var_h1_billing_end := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_bilto_end_date,3,6),6,' ');
            var_h1_bill_whslr_code := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_whslr_code,1,8),8,' ');
            var_h1_bill_branch_code := lads_right_pad(substr(rcd_whslr_mly_inv_bch.edi_brnch_code,1,8),8,' ');
            var_h1_bill_branch_name := lads_right_pad(substr(rcd_whslr_mly_inv_bch.edi_brnch_name,1,25),25,' ');
            var_h1_reserved_field := lads_right_pad(' ',1,' ');

            /*-*/
            /* Output the H1 record data
            /*-*/
            var_output := var_h1_data_type;
            var_output := var_output || var_h1_maker_code;
            var_output := var_output || var_h1_process_date;
            var_output := var_output || var_h1_sequential_number;
            var_output := var_output || var_h1_record_type;
            var_output := var_output || var_h1_payment_type;
            var_output := var_output || var_h1_partner_code;
            var_output := var_output || var_h1_partner_name;
            var_output := var_output || var_h1_account_code;
            var_output := var_output || var_h1_account_name;
            var_output := var_output || var_h1_billing_date;
            var_output := var_output || var_h1_billing_start;
            var_output := var_output || var_h1_billing_end;
            var_output := var_output || var_h1_bill_whslr_code;
            var_output := var_output || var_h1_bill_branch_code;
            var_output := var_output || var_h1_bill_branch_name;
            var_output := var_output || var_h1_reserved_field;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

            /*-*/
            /* Retrieve the wholesaler monthly detail data
            /*-*/
            open csr_whslr_mly_inv_det;
            loop
               fetch csr_whslr_mly_inv_det into rcd_whslr_mly_inv_det;
               if csr_whslr_mly_inv_det%notfound then
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
               var_l1_bill_branch_code := lads_right_pad(substr(rcd_whslr_mly_inv_bch.edi_brnch_code,1,8),8,' ');
               var_l1_sold_to_party_code := lads_right_pad(substr(rcd_whslr_mly_inv_det.edi_sldto_code,1,8),8,' ');
               var_l1_deal_type := lads_right_pad(substr(rcd_whslr_mly_inv_det.edi_tran_code,1,2),2,' ');
               var_l1_order_date := lads_right_pad(substr(rcd_whslr_mly_inv_det.edi_order_date,3,6),6,' ');
               var_l1_ship_to_type := lads_right_pad(substr(rcd_whslr_mly_inv_det.edi_ship_to_type,1,1),1,' ');
               var_l1_order_number := lads_right_pad(substr(rcd_whslr_mly_inv_det.edi_order_number,1,8),8,' ');
               var_l1_classification_code := lads_right_pad(' ',6,' ');
               var_l1_correction_type := lads_right_pad(' ',1,' ');
               var_l1_invoice_date := lads_right_pad(substr(rcd_whslr_mly_inv_det.edi_invoice_date,3,6),6,' ');
               var_l1_invoice_number := lads_left_pad(substr(rcd_whslr_mly_inv_det.edi_invoice_number,1,10),10,'0');
               var_l1_payment_date := lads_right_pad(' ',6,' ');
               var_l1_payment_type := lads_right_pad(' ',2,' ');
               var_l1_amount := substr(overpunch_zoned(rcd_whslr_mly_inv_det.edi_amount,'000000000000000'),17-10,10);
               var_l1_discount := substr(overpunch_zoned(rcd_whslr_mly_inv_det.edi_discount,'000000000000000'),17-8,8);
               var_l1_balance := substr(overpunch_zoned(rcd_whslr_mly_inv_det.edi_balance,'000000000000000'),17-9,9);
               var_l1_consumption_type := lads_right_pad('1',1,' ');
               var_l1_consumption_tax := substr(overpunch_zoned(rcd_whslr_mly_inv_det.edi_tax,'000000000000000'),17-7,7);
               var_l1_comment1 := lads_right_pad(' ',1,' ');
               var_l1_comment2 := lads_right_pad(' ',2,' ');
               var_l1_comment3 := lads_right_pad(' ',1,' ');
               var_l1_comment4 := lads_right_pad(' ',1,' ');
               var_l1_page_number := lads_right_pad(' ',4,' ');
               var_l1_row_number := lads_right_pad(' ',2,' ');

               /*-*/
               /* Output the L1 record data
               /*-*/
               var_output := var_l1_data_type;
               var_output := var_output || var_l1_maker_code;
               var_output := var_output || var_l1_process_date;
               var_output := var_output || var_l1_sequential_number;
               var_output := var_output || var_l1_record_type;
               var_output := var_output || var_l1_bill_branch_code;
               var_output := var_output || var_l1_sold_to_party_code;
               var_output := var_output || var_l1_deal_type;
               var_output := var_output || var_l1_order_date;
               var_output := var_output || var_l1_ship_to_type;
               var_output := var_output || var_l1_order_number;
               var_output := var_output || var_l1_classification_code;
               var_output := var_output || var_l1_correction_type;
               var_output := var_output || var_l1_invoice_date;
               var_output := var_output || var_l1_invoice_number;
               var_output := var_output || var_l1_payment_date;
               var_output := var_output || var_l1_payment_type;
               var_output := var_output || var_l1_amount;
               var_output := var_output || var_l1_discount;
               var_output := var_output || var_l1_balance;
               var_output := var_output || var_l1_consumption_type;
               var_output := var_output || var_l1_consumption_tax;
               var_output := var_output || var_l1_comment1;
               var_output := var_output || var_l1_comment2;
               var_output := var_output || var_l1_comment3;
               var_output := var_output || var_l1_comment4;
               var_output := var_output || var_l1_page_number;
               var_output := var_output || var_l1_row_number;
               tbl_outbound(tbl_outbound.count + 1) := var_output;

            end loop;
            close csr_whslr_mly_inv_det;

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
            var_t1_wholesaler := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_whslr_code,1,8),8,' ');
            var_t1_branch := lads_right_pad(substr(rcd_whslr_mly_inv_bch.edi_brnch_code,1,8),8,' ');
            var_t1_count := substr(to_char(nvl(rcd_whslr_mly_inv_bch.edi_count,0),'000000000000000'),17-6,6);
            var_t1_amount := substr(overpunch_zoned(rcd_whslr_mly_inv_bch.edi_amount,'000000000000000'),17-11,11);
            var_t1_discount := substr(overpunch_zoned(rcd_whslr_mly_inv_bch.edi_discount,'000000000000000'),17-8,8);
            var_t1_balance := substr(overpunch_zoned(rcd_whslr_mly_inv_bch.edi_balance,'000000000000000'),17-11,11);
            var_t1_consumption_tax := substr(overpunch_zoned(rcd_whslr_mly_inv_bch.edi_tax,'000000000000000'),17-8,8);
            var_t1_value := substr(overpunch_zoned(rcd_whslr_mly_inv_bch.edi_value,'000000000000000'),17-11,11);
            var_t1_ddct1_invoice := lads_right_pad(' ',2,' ');
            var_t1_ddct1_summary := lads_right_pad(' ',8,' ');
            var_t1_ddct1_consumption_tax := lads_right_pad(' ',8,' ');
            var_t1_ddct2_record := lads_right_pad(' ',2,' ');
            var_t1_ddct2_summary := lads_right_pad(' ',8,' ');
            var_t1_ddct2_consumption_tax := lads_right_pad(' ',8,' ');
            var_t1_reserved_field := lads_right_pad(' ',3,' ');

            /*-*/
            /* Output the T1 record data
            /*-*/
            var_output := var_t1_data_type;
            var_output := var_output || var_t1_maker_code;
            var_output := var_output || var_t1_process_date;
            var_output := var_output || var_t1_sequential_number;
            var_output := var_output || var_t1_record_type;
            var_output := var_output || var_t1_wholesaler;
            var_output := var_output || var_t1_branch;
            var_output := var_output || var_t1_count;
            var_output := var_output || var_t1_amount;
            var_output := var_output || var_t1_discount;
            var_output := var_output || var_t1_balance;
            var_output := var_output || var_t1_consumption_tax;
            var_output := var_output || var_t1_value;
            var_output := var_output || var_t1_ddct1_invoice;
            var_output := var_output || var_t1_ddct1_summary;
            var_output := var_output || var_t1_ddct1_consumption_tax;
            var_output := var_output || var_t1_ddct2_record;
            var_output := var_output || var_t1_ddct2_summary;
            var_output := var_output || var_t1_ddct2_consumption_tax;
            var_output := var_output || var_t1_reserved_field;
            tbl_outbound(tbl_outbound.count + 1) := var_output;

         end loop;
         close csr_whslr_mly_inv_bch;

         /*-*/
         /* Increment the row count
         /*-*/
         var_row_count := var_row_count + 1;

         /*-*/
         /* Set the T2 record data
         /*-*/
         var_t2_data_type := lads_right_pad(var_data_type,2,' ');
         var_t2_maker_code := lads_right_pad(var_maker_code,7,' ');
         var_t2_process_date := lads_right_pad(var_process_date,2,' ');
         var_t2_sequential_number := to_char(var_row_count,'fm00000');
         var_t2_record_type := lads_right_pad('T2',2,' ');
         var_t2_wholesaler := lads_right_pad(substr(rcd_whslr_mly_inv_hdr.edi_whslr_code,1,8),8,' ');
         var_t2_reserved_field1 := lads_right_pad(' ',8,' ');
         var_t2_count := substr(to_char(nvl(rcd_whslr_mly_inv_hdr.edi_count,0),'000000000000000'),17-6,6);
         var_t2_amount := substr(overpunch_zoned(rcd_whslr_mly_inv_hdr.edi_amount,'000000000000000'),17-11,11);
         var_t2_discount := substr(overpunch_zoned(rcd_whslr_mly_inv_hdr.edi_discount,'000000000000000'),17-8,8);
         var_t2_balance := substr(overpunch_zoned(rcd_whslr_mly_inv_hdr.edi_balance,'000000000000000'),17-11,11);
         var_t2_consumption_tax := substr(overpunch_zoned(rcd_whslr_mly_inv_hdr.edi_tax,'000000000000000'),17-8,8);
         var_t2_value := substr(overpunch_zoned(rcd_whslr_mly_inv_hdr.edi_value,'000000000000000'),17-11,11);
         var_t2_ddct1_invoice := lads_right_pad(' ',2,' ');
         var_t2_ddct1_summary := lads_right_pad(' ',8,' ');
         var_t2_ddct1_consumption_tax := lads_right_pad(' ',8,' ');
         var_t2_ddct2_record := lads_right_pad(' ',2,' ');
         var_t2_ddct2_summary := lads_right_pad(' ',8,' ');
         var_t2_ddct2_consumption_tax := lads_right_pad(' ',8,' ');
         var_t2_reserved_field2 := lads_right_pad(' ',3,' ');


         /*-*/
         /* Output the T2 record data
         /*-*/
         var_output := var_t2_data_type;
         var_output := var_output || var_t2_maker_code;
         var_output := var_output || var_t2_process_date;
         var_output := var_output || var_t2_sequential_number;
         var_output := var_output || var_t2_record_type;
         var_output := var_output || var_t2_wholesaler;
         var_output := var_output || var_t2_reserved_field1;
         var_output := var_output || var_t2_count;
         var_output := var_output || var_t2_amount;
         var_output := var_output || var_t2_discount;
         var_output := var_output || var_t2_balance;
         var_output := var_output || var_t2_consumption_tax;
         var_output := var_output || var_t2_value;
         var_output := var_output || var_t2_ddct1_invoice;
         var_output := var_output || var_t2_ddct1_summary;
         var_output := var_output || var_t2_ddct1_consumption_tax;
         var_output := var_output || var_t2_ddct2_record;
         var_output := var_output || var_t2_ddct2_summary;
         var_output := var_output || var_t2_ddct2_consumption_tax;
         var_output := var_output || var_t2_reserved_field2;
         tbl_outbound(tbl_outbound.count + 1) := var_output;

      end loop;
      close csr_whslr_mly_inv_hdr;

      /*-*/
      /* Create the invoice interface when required
      /*-*/
      if tbl_outbound.count != 0 then
         var_instance := lics_outbound_loader.create_interface('LADEDI03','LADEDI03_'||par_date,'LADEDI03_'||par_date||'.TXT');
         for idx in 1..tbl_outbound.count loop
            lics_outbound_loader.append_data(tbl_outbound(idx));
         end loop;
         lics_outbound_loader.finalise_interface;
      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Wholesaler Send Monthly Invoices');

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
            lics_logging.write_log('**ERROR** - Wholesaler Send Monthly Invoices - ' || var_exception);
            lics_logging.write_log('End - Wholesaler Send Monthly Invoices');
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
   end send_whslr_monthly;

   /*************************************************************************/
   /* This procedure performs the email wholesaler monthly messages routine */
   /*************************************************************************/
   procedure email_whslr_monthly(par_date in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_whslr_mly_inv_hdr is
         select t01.*,
                t02.edi_whslr_name,
                t02.edi_disc_code,
                t02.edi_email_group
           from whslr_mly_inv_hdr t01,
                whslr t02
          where t01.edi_sndto_code = t02.edi_sndto_code(+)
            and t01.edi_sndon_date = par_date
          order by t01.edi_sndto_code asc;
      rcd_whslr_mly_inv_hdr csr_whslr_mly_inv_hdr%rowtype;

      cursor csr_whslr_mly_inv_bch is
         select t01.*
           from whslr_mly_inv_bch t01
          where t01.edi_sndto_code = rcd_whslr_mly_inv_hdr.edi_sndto_code
            and t01.edi_bilto_date = rcd_whslr_mly_inv_hdr.edi_bilto_date
          order by t01.edi_brnch_code asc;
      rcd_whslr_mly_inv_bch csr_whslr_mly_inv_bch%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Wholesaler Email Monthly Invoices');

      /*-*/
      /* Retrieve the wholesaler invoices for the parameter date
      /*-*/
      open csr_whslr_mly_inv_hdr;
      loop
         fetch csr_whslr_mly_inv_hdr into rcd_whslr_mly_inv_hdr;
         if csr_whslr_mly_inv_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Create the new email and create the email text header part
         /*-*/
         lics_mailer.create_email('EDI_' || lads_parameter.system_unit || '_' || lads_parameter.system_environment,
                                  rcd_whslr_mly_inv_hdr.edi_email_group,
                                  'Monthly Invoice Data / '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_str_date,'yyyymmdd'),'yyyy.mm.dd')||' - '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_end_date,'yyyymmdd'),'yyyy.mm.dd')||' / '||rcd_whslr_mly_inv_hdr.edi_whslr_name,
                                  null,
                                  null);
         lics_mailer.create_part(null);
         lics_mailer.append_data('Monthly Invoice Data / '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_str_date,'yyyymmdd'),'yyyy.mm.dd')||' - '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_end_date,'yyyymmdd'),'yyyy.mm.dd')||' / '||rcd_whslr_mly_inv_hdr.edi_whslr_name);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);

         /*-*/
         /* Create the email file and output the header data
         /*-*/
         lics_mailer.create_part('Monthly_Invoice_Data_'||rcd_whslr_mly_inv_hdr.edi_whslr_code||'.xls');
         lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
         lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td align=center colspan=9 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Monthly Invoice Data / '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_str_date,'yyyymmdd'),'yyyy.mm.dd')||' - '||to_char(to_date(rcd_whslr_mly_inv_hdr.edi_bilto_end_date,'yyyymmdd'),'yyyy.mm.dd')||' / '||rcd_whslr_mly_inv_hdr.edi_whslr_name||'</td>');
         lics_mailer.append_data('</tr>');

         /*-*/
         /* Output the wholesaler header
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('</tr>');
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">売上</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ﾉｰﾘﾀｰﾝﾃﾞｨｽｶｳﾝﾄ</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ﾎﾞﾘｭｰﾑﾃﾞｨｽｶｳﾝﾄ</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ｷｬｯｼｭﾃﾞｨｽｶｳﾝﾄ</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ﾃﾞｨｽｶｳﾝﾄ合計</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">差引請求額</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">消費税</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">合計請求額</td>');
         lics_mailer.append_data('</tr>');

         /*-*/
         /* Output the wholesaler data
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_amount,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_disc_noreturn,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_disc_volume,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_disc_earlypay,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_discount,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_balance,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_tax,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_hdr.edi_value,'fm999g999g999g999g999')||'</td>');
         lics_mailer.append_data('</tr>');

         /*-*/
         /* Output the branch header
         /*-*/
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('<td></td>');
         lics_mailer.append_data('</tr>');
         lics_mailer.append_data('<tr>');
         lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">特約店</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">売上</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ﾉｰﾘﾀｰﾝﾃﾞｨｽｶｳﾝﾄ</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ﾎﾞﾘｭｰﾑﾃﾞｨｽｶｳﾝﾄ</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ｷｬｯｼｭﾃﾞｨｽｶｳﾝﾄ</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">ﾃﾞｨｽｶｳﾝﾄ合計</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">差引請求額</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">消費税</td>');
         lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">合計請求額</td>');
         lics_mailer.append_data('</tr>');

         /*-*/
         /* Retrieve the wholesaler monthly branch data
         /*-*/
         open csr_whslr_mly_inv_bch;
         loop
            fetch csr_whslr_mly_inv_bch into rcd_whslr_mly_inv_bch;
            if csr_whslr_mly_inv_bch%notfound then
               exit;
            end if;

            /*-*/
            /* Output the branch data
            /*-*/
            lics_mailer.append_data('<tr>');
            lics_mailer.append_data('<td align=left>'||rcd_whslr_mly_inv_bch.edi_brnch_code||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_amount,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_disc_noreturn,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_disc_volume,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_disc_earlypay,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_discount,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_balance,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_tax,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('<td align=right>'||to_char(rcd_whslr_mly_inv_bch.edi_value,'fm999g999g999g999g999')||'</td>');
            lics_mailer.append_data('</tr>');

         end loop;
         close csr_whslr_mly_inv_bch;

         /*-*/
         /* Output the email file part trailer data
         /*-*/
         lics_mailer.append_data('</table>');
         lics_mailer.create_part(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data(null);
         lics_mailer.append_data('** Email End **');
         lics_mailer.finalise_email('utf-8');

      end loop;
      close csr_whslr_mly_inv_hdr;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Wholesaler Email Monthly Invoices');

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
            lics_logging.write_log('**ERROR** - Wholesaler Email Monthly Invoices - ' || var_exception);
            lics_logging.write_log('End - Wholesaler Email Monthly Invoices');
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
   end email_whslr_monthly;

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

end edi_invoicing;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_invoicing for dw_app.edi_invoicing;
grant execute on edi_invoicing to public;
