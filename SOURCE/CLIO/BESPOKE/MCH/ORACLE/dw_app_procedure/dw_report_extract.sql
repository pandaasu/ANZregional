/******************/
/* Package Header */
/******************/
create or replace package dw_report_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_report_extract
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Report Extract

    This package contains the procedures for the Sales and Management Reports. The package exposes
    one procedure EXECUTE that performs the extract based on the following parameters:

    1. PAR_COMPANY_CODE (MANDATORY)

       The company code to extract.

    **notes**
    1. A web log is produced under the search value DW_REPORT_EXTRACT where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/07   Steve Gregan   Created
    2006/08   Steve Gregan   Added Hermes data marts
    2007/04   Steve Gregan   Added multiple company functionality
    2008/04   Steve Gregan   Added CLIO company check

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company_code in varchar2);

end dw_report_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_report_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company_code in varchar2) is

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
      var_return varchar2(4000);
      var_sales boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Report Extract';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'REPORT_EXTRACT';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'REPORT_EXTRACT';
      con_dbp_code constant varchar2(32) := 'REGDBP_REGDBP01';
      con_dbp_alt_group constant varchar2(32) := 'LICS_TRIGGER_ALERT';
      con_dbp_ema_group constant varchar2(32) := 'LICS_TRIGGER_EMAIL_GROUP';
      con_dbp_tri_group constant varchar2(32) := 'LICS_TRIGGER_GROUP';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from table(lics_datastore.retrieve_value('CLIO','SALES','COMPANY')) t01
          where t01.dsv_value = par_company_code;
      rcd_company csr_company%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_REPORT_EXTRACT';
      var_log_search := 'DW_REPORT_EXTRACT';
      var_loc_string := 'DW_REPORT_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_company_code) is null then
         raise_application_error(-20000, 'Company code parameter must be supplied');
      end if;

      /*-*/
      /* Retrieve the CLIO sales company code
      /*-*/
      var_sales := false;
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%found then
         var_sales := true;
      end if;
      close csr_company;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Report Extract - Parameters(' || par_company_code || ')');

      /*-*/
      /* Request the lock on the report extracts
      /*-*/
      begin
         lics_locking.request(var_loc_string || '-' || par_company_code);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the extract procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the inventory extract procedures
         /* **note** ALWAYS REFRESHED (ie. no company sales test)
         /*-*/
         begin
            var_return := hk_inv_format02_extract.main(par_company_code);
            if var_return = '*OK' then
               lics_logging.write_log('Report Extract - inventory - hk_inv_format02_extract - successful');
            else
               lics_logging.write_log('Report Extract - inventory - hk_inv_format02_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Report Extract - inventory - hk_inv_format02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;

         /*-*/
         /* CLIO sales companies only
         /*-*/
         if var_sales = true then

            /*-*/
            /* Execute the inventory extract procedures
            /*-*/
            begin
               var_return := hk_inv_format01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - inventory - hk_inv_format01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - inventory - hk_inv_format01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - inventory - hk_inv_format01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;

            /*-*/
            /* Execute the sales extract procedures
            /*-*/
            begin
               var_return := hk_sal_format01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_format01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_format01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract  - sales- hk_sal_format01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_format11_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_format11_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_format11_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_format11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;

            /*-*/
            /* Execute the standard sales extract procedures
            /*-*/
            begin
               var_return := hk_sal_cus_mth_01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_mth_02_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_02_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_02_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_mth_03_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_03_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_03_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_03_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_mth_11_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_11_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_11_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_mth_12_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_12_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_12_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_12_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_mth_13_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_13_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_13_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_mth_13_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_prd_01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_prd_02_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_02_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_02_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_prd_03_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_03_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_03_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_03_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_prd_11_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_11_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_11_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_prd_12_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_12_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_12_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_12_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_cus_prd_13_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_13_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_13_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_cus_prd_13_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_mth_01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_mth_02_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_02_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_02_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_mth_03_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_03_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_03_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_03_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_mth_11_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_11_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_11_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_mth_12_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_12_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_12_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_12_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_mth_13_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_13_extract - successful');
            else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_13_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_mth_13_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_prd_01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_prd_02_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_02_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_02_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_prd_03_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_03_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_03_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_03_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_prd_11_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_11_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_11_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
            var_return := hk_sal_mat_prd_12_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_12_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_12_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_12_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_sal_mat_prd_13_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_13_extract - successful');
               else
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_13_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - sales - hk_sal_mat_prd_13_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;

            /*-*/
            /* Execute the customer service level extract procedures
            /*-*/
            begin
               var_return := hk_csl_prd_01_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_csl_prd_11_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_11_extract - successful');
               else
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_11_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_csl_prd_02_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_02_extract - successful');
               else
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_02_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;
            /*----*/
            begin
               var_return := hk_csl_prd_12_extract.main(par_company_code);
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_12_extract - successful');
               else
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_12_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - csl - hk_csl_prd_12_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;

            /*-*/
            /* Execute the hermes extract procedures
            /*-*/
            begin
               var_return := hermes_prd_01_extract.main;
               if var_return = '*OK' then
                  lics_logging.write_log('Report Extract - hermes - hermes_prd_01_extract - successful');
               else
                  lics_logging.write_log('Report Extract - hermes - hermes_prd_01_extract - **ERROR** - ' || var_return);
               end if;
            exception
               when others then
                  var_errors := true;
                  lics_logging.write_log('Report Extract - hermes - hermes_prd_01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
            end;

         end if;

         /*-*/
         /* Release the lock on the report extracts
         /*-*/
         lics_locking.release(var_loc_string || '-' || par_company_code);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Report Extract');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_REPORT_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the Report Extract execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      /*-*/
      /* Fire any required triggers
      /*-*/
      else

         /*-*/
         /* Trigger the Regional DBP Extract for CLIO sales companies only
         /*-*/
         if var_sales = true then
            lics_trigger_loader.execute('Regional DBP Extract',
                                        'dw_regional_dbp.execute(''' || par_company_code || ''')',
                                        lics_setting_configuration.retrieve_setting(con_dbp_alt_group, con_dbp_code),
                                        lics_setting_configuration.retrieve_setting(con_dbp_ema_group, con_dbp_code),
                                        lics_setting_configuration.retrieve_setting(con_dbp_tri_group, con_dbp_code));
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
         var_exception := substr(SQLERRM, 1, 1024);

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
         /* Release the lock on the report extracts
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string || '-' || par_company_code);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_REPORT_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_report_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_report_extract for dw_app.dw_report_extract;
grant execute on dw_report_extract to public;
