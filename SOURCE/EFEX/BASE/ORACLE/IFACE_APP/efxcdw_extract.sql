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
      var_alert varchar2(256);
      var_email varchar2(256);
      var_timestamp varchar2(14);
      var_instance number(15,0);
      var_history number;
      var_return number;
      var_errors boolean;
      type rcd_cntl is record (intcde varchar2(32), intcnt integer);
      type typ_cntl is table of rcd_cntl index by binary_integer;
      tbl_cntl typ_cntl;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'Efex CDW Extract';
      con_alt_group constant varchar2(32) := 'EFEX_CDW_EXTRACT';
      con_alt_code constant varchar2(32) := 'ALERT_STRING';
      con_ema_group constant varchar2(32) := 'EFEX_CDW_EXTRACT';
      con_ema_code constant varchar2(32) := 'EMAIL_GROUP';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the variables
      /*-*/
      var_timestamp := to_char(sysdate,'yyyymmddhh24miss');
      var_log_prefix := 'EFEX CDW_EXTRACT';
      var_log_search := 'EFEX_CDW_EXTRACT' || '_' || var_timestamp;
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_instance := -1;
      tbl_cntl.delete;

      /*-*/
      /* Define number of days to extract
      /*-*/
      if par_history = 0 then
         var_history := 99999;
      else
         var_history := par_history;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - EFEX CDW Extract - Parameters - Market(' || to_char(par_market) || ') Timestamp(' || var_timestamp || ') History Days(' || to_char(par_history) || ')');

      /*-*/
      /* Execute the extract procedures
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw01_extract');
      begin
         var_return := efxcdw01_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw01_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW01';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw01_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw02_extract');
      begin
         var_return := efxcdw02_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw02_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW02';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw02_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw03_extract');
      begin
         var_return := efxcdw03_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw03_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW03';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw03_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw04_extract');
      begin
         var_return := efxcdw04_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw04_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW04';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw04_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw05_extract');
      begin
         var_return := efxcdw05_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw05_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW05';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw05_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw06_extract');
      begin
         var_return := efxcdw06_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw06_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW06';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw06_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw07_extract');
      begin
         var_return := efxcdw07_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw07_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW07';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw07_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw08_extract');
      begin
         var_return := efxcdw08_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw08_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW08';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw08_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw09_extract');
      begin
         var_return := efxcdw09_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw09_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW09';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw09_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw10_extract');
      begin
         var_return := efxcdw10_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw10_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW10';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw10_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw11_extract');
      begin
         var_return := efxcdw11_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw11_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW11';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw11_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw12_extract');
      begin
         var_return := efxcdw12_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw12_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW12';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw12_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw13_extract');
      begin
         var_return := efxcdw13_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw13_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW13';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw13_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw14_extract');
      begin
         var_return := efxcdw14_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw14_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW14';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw14_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw15_extract');
      begin
         var_return := efxcdw15_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw15_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW15';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw15_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw16_extract');
      begin
         var_return := efxcdw16_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw16_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW16';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw16_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw17_extract');
      begin
         var_return := efxcdw17_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw17_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW17';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw17_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw18_extract');
      begin
         var_return := efxcdw18_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw18_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW18';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw18_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw19_extract');
      begin
         var_return := efxcdw19_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw19_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW19';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw19_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw20_extract');
      begin
         var_return := efxcdw20_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw20_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW20';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw20_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw21_extract');
      begin
         var_return := efxcdw21_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw21_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW21';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw21_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw22_extract');
      begin
         var_return := efxcdw22_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw22_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW22';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw22_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw23_extract');
      begin
         var_return := efxcdw23_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw23_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW23';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw23_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw24_extract');
      begin
         var_return := efxcdw24_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw24_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW24';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw24_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw25_extract');
      begin
         var_return := efxcdw25_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw25_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW25';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw25_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw26_extract');
      begin
         var_return := efxcdw26_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw26_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW26';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw26_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw27_extract');
      begin
         var_return := efxcdw27_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw27_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW27';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw27_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw28_extract');
      begin
         var_return := efxcdw28_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw28_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW28';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw28_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw29_extract');
      begin
         var_return := efxcdw29_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw29_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW29';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw29_extract - '||substr(sqlerrm, 1, 1024));
      end;
      /*-*/
      lics_logging.write_log('  ==> Start efxcdw30_extract');
      begin
         var_return := efxcdw30_extract.execute(par_market, var_timestamp, var_history);
         lics_logging.write_log('  ==> End efxcdw30_extract - extract sent count('||to_char(var_return)||')');
         if var_return != 0 then
            tbl_cntl(tbl_cntl.count+1).intcde := 'EFXCDW30';
            tbl_cntl(tbl_cntl.count).intcnt := var_return;
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('  ==> **FAILED** - efxcdw30_extract - '||substr(sqlerrm, 1, 1024));
      end;

      /*-*/
      /* Interface data sent
      /*-*/
      if tbl_cntl.count != 0 then

         /*-*/
         /* Create outbound control interface
         /*-*/
         lics_logging.write_log('  ==> Create efxcdw00 control interface');
         var_instance := lics_outbound_loader.create_interface('EFXCDW00',null,'EFXCDW00.DAT');
         lics_outbound_loader.append_data('CTL'||'EFXCDW00'||rpad(' ',32-length('EFXCDW00'),' ')||nvl(par_market,'0')||rpad(' ',10-length(nvl(par_market,'0')),' ')||nvl(var_timestamp,' ')||rpad(' ',14-length(nvl(var_timestamp,' ')),' '));

         /*-*/
         /* Append data lines
         /*-*/
         for idx in 1..tbl_cntl.count loop
            lics_outbound_loader.append_data('DET' ||
                                             nvl(tbl_cntl(idx).intcde,' ')||rpad(' ',32-length(nvl(tbl_cntl(idx).intcde,' ')),' ') ||
                                             nvl(tbl_cntl(idx).intcnt,'0')||rpad(' ',10-length(nvl(tbl_cntl(idx).intcnt,'0')),' '));
         end loop;

         /*-*/
         /* Finalise Interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      /*-*/
      /* Interface data NOT sent
      /*-*/
      else

         /*-*/
         /* Append data lines
         /*-*/
         lics_logging.write_log('  ==> **NO INTERFACE DATA EXTRACTED** - efxcdw00 control interface not required');

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - EFEX CDW Extract');

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
            lics_notification.send_email(lics_parameter.system_code,
                                         lics_parameter.system_unit,
                                         lics_parameter.system_environment,
                                         con_function,
                                         'EFEX_CDW_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the Efex CDW extract execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Finalise the outbound loader when required
         /*-*/
         if var_instance != -1 then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

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
