/******************/
/* Package Header */
/******************/
create or replace package edi_whslr_monthly as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : edi_whslr_monthly
    Owner   : dw_app

    Description
    -----------
    Electronic Data Interchange - EDI Wholesaler Monthly Invoicing

    This package contains the extract procedure for Wholesaler monthly invoices. The
    package exposes one procedure EXECUTE that performs the extract based on the
    following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the EDI invoicing is to be performed.

    2. PAR_DATE (date in string format YYYYMMDD) (MANDATORY)

       The date for which the EDI invoicing is to be performed.

    **notes**
    1. A web log is produced under the search value EDI_WHOLESALER_MONTHLY_INVOICING where all errors are logged.

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

end edi_whslr_monthly;
/

/****************/
/* Package Body */
/****************/
create or replace package body edi_whslr_monthly as

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
   procedure email_invoices(par_company in varchar2, par_date in varchar2);
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
      con_function constant varchar2(128) := 'EDI Wholesaler Monthly Invoicing';
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
      var_log_prefix := 'EDI - WHOLESALER MONTHLY INVOICING';
      var_log_search := 'EDI_WHOLESALER_MONTHLY_INVOICING';
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
      lics_logging.write_log('Begin - EDI Wholesaler Monthly Invoicing - Parameters(' || par_company || ' + ' || par_date || ')');

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
         /* Execute the wholesaler monthly create procedure
         /*-*/
         begin
            create_invoices(par_company, par_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Execute the wholesaler monthly send procedure when required
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
         /* Execute the wholesaler monthly email procedure when required
         /*-*/
         if var_errors = false then
            begin
               email_invoices(par_company, par_date);
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
      lics_logging.write_log('End - EDI Wholesaler Monthly Invoicing');

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
                                         'One or more errors occurred during the EDI Wholesaler Monthly Invoicing execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - EDI - WHOLESALER MONTHLY INVOICING - ' || var_exception);

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
          where t01.sap_company_code = par_company
            and t01.edi_sndto_code = rcd_whslr_mly_inv_hdr.edi_sndto_code
            and (t01.sap_creatn_date >= rcd_whslr_mly_inv_hdr.edi_bilto_str_date and
                 t01.sap_creatn_date <= rcd_whslr_mly_inv_hdr.edi_bilto_end_date)
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
      /* Retrieve the wholesalers with a billing date (YYYYMMDD) less than or equal to the parameter date
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
          where sap_company_code = par_company
            and edi_sndto_code = rcd_whslr.edi_sndto_code
            and edi_bilto_date = rcd_whslr.edi_bilto_date;

         /*-*/
         /* Delete any existing monthly invoice branch rows
         /*-*/
         delete from whslr_mly_inv_bch
          where sap_company_code = par_company
            and edi_sndto_code = rcd_whslr.edi_sndto_code
            and edi_bilto_date = rcd_whslr.edi_bilto_date;

         /*-*/
         /* Delete any existing monthly invoice header rows
         /*-*/
         delete from whslr_mly_inv_hdr
          where sap_company_code = par_company
            and edi_sndto_code = rcd_whslr.edi_sndto_code
            and edi_bilto_date = rcd_whslr.edi_bilto_date;

         /*-*/
         /* Log the event
         /*-*/
         lics_logging.write_log('Creating wholesaler monthly invoice data');

         /*-*/
         /* Initialise the wholesaler monthly invoice header
         /*-*/
         rcd_whslr_mly_inv_hdr.sap_company_code := par_company;
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
                   where sap_company_code = rcd_whslr_mly_inv_bch.sap_company_code
                     and edi_sndto_code = rcd_whslr_mly_inv_bch.edi_sndto_code
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
               rcd_whslr_mly_inv_bch.sap_company_code := rcd_whslr_mly_inv_hdr.sap_company_code;
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
            rcd_whslr_mly_inv_det.sap_company_code := rcd_whslr_mly_inv_hdr.sap_company_code;
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
             where sap_company_code = rcd_whslr_mly_inv_bch.sap_company_code
               and edi_sndto_code = rcd_whslr_mly_inv_bch.edi_sndto_code
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
          where sap_company_code = rcd_whslr_mly_inv_hdr.sap_company_code
            and edi_sndto_code = rcd_whslr_mly_inv_hdr.edi_sndto_code
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
          where t01.sap_company_code = par_company
            and t01.edi_sndon_date = par_date
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
      /* Retrieve the wholesaler invoices for the parameter date and company
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
         var_instance := lics_outbound_loader.create_interface('LADEDI03','LADEDI03_'||par_company||'_'||par_date,'LADEDI03_'||par_company||'_'||par_date||'.TXT');
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
   end send_invoices;

   /******************************************************/
   /* This procedure performs the email messages routine */
   /******************************************************/
   procedure email_invoices(par_company in varchar2, par_date in varchar2) is

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
            and t01.sap_company_code = par_company
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
      /* Retrieve the wholesaler invoices for the parameter date and company
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
   end email_invoices;

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

end edi_whslr_monthly;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym edi_whslr_monthly for dw_app.edi_whslr_monthly;
grant execute on edi_whslr_monthly to public;
