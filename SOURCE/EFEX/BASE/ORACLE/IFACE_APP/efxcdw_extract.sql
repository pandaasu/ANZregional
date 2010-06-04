/******************/
/* Package Header */
/******************/
create or replace package iface_app.efxcdw_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw_extract
    Owner   : iface_app

    Description
    -----------
    EFEX to CDW - Extract Control

    This package extracts the EFEX information been modified within the last
    history number of days and invokes the individual interface extracts that
    send the extract files to the CDW environment.

    1. PAR_MARKET (MANDATORY)

       ## - Market id for the extract

    2. PAR_HISTORY (OPTIONAL)

       ## - Number of days changes to extract
       0 - Full extract (default)

    **notes**
    1. A web log is produced under the search value EFEX_CDW_EXTRACT where all errors are logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number, par_history in number default 0);

end efxcdw_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body iface_app.efxcdw_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_market in number, par_history in number default 0) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'EFEX CDW_EXTRACT';
      var_log_search := 'EFEX_CDW_EXTRACT' || '_' || to_char(sysdate,'yyyymmddhh24miss');

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - EFEX CDW Extract - Parameters - Market(' || to_char(par_market) || ') History(' || to_char(par_history) || ')');

      /*-*/
      /* Execute the extract procedures
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw01_extract');
      efxcdw01_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw02_extract');
      efxcdw02_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw03_extract');
      efxcdw03_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw04_extract');
      efxcdw04_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw05_extract');
      efxcdw05_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw06_extract');
      efxcdw06_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw07_extract');
      efxcdw07_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw08_extract');
      efxcdw08_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw09_extract');
      efxcdw09_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw10_extract');
      efxcdw10_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw11_extract');
      efxcdw11_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw12_extract');
      efxcdw12_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw13_extract');
      efxcdw13_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw14_extract');
      efxcdw14_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw15_extract');
      efxcdw15_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw16_extract');
      efxcdw16_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw17_extract');
      efxcdw17_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw18_extract');
      efxcdw18_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw19_extract');
      efxcdw19_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw20_extract');
      efxcdw20_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw21_extract');
      efxcdw21_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw22_extract');
      efxcdw22_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw23_extract');
      efxcdw23_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw24_extract');
      efxcdw24_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw25_extract');
      efxcdw25_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw26_extract');
      efxcdw26_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw27_extract');
      efxcdw27_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw28_extract');
      efxcdw28_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw29_extract');
      efxcdw29_extract.execute(par_market, par_history);
      /*-*/
      lics_logging.write_log('  ==> Perform efxcdw30_extract');
      efxcdw30_extract.execute(par_market, par_history);

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - EFEX CDW Extract');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW_EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw_extract for iface_app.efxcdw_extract;
grant execute on efxcdw_extract to public;
