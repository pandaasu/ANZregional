/******************/
/* Package Header */
/******************/
create or replace package dw_order_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_order_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Order Aggregation

    This package contain the aggregation procedures for sales orders and deliveries. The package exposes
    one procedure EXECUTE that performs the aggregation based on the following parameters:

    1. PAR_DATE (date in string format YYYYMMDD) (MANDATORY)

       The date up until which the aggregation is to be performed.

    2. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_ORDER_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2006/03   Steve Gregan   Created
    2006/06   Steve Gregan   Modified delivery POD logic.
    2006/06   Steve Gregan   Modified delivery base UOM quantity from Atlas value to calculation.
    2006/06   Steve Gregan   Modified delivery line selection for (hipos/hievw) free goods issue.
    2006/06   Steve Gregan   Modified order line rejection logic to ignore reason ZA.
    2006/06   Steve Gregan   Modified delivery pod selection for (hipos/hievw) free goods issue.
    2006/08   Steve Gregan   Modified order line invoiced logic to include invoices with no billing date.
    2006/08   Steve Gregan   Modified order date test to last 14 days.
    2006/09   Steve Gregan   Modified order usage code source to the header for order type ZRE.
    2007/04   Steve Gregan   Modified report extract call to include company.
    2008/08   Trevor Keon    Added log level option
    2008/08   Steve Gregan   Added DW_EXPAND_CODE for performance

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_date in varchar2, par_company in varchar2);

end dw_order_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_order_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure order_fact_load(par_date in date, par_company in varchar2, par_log_level in varchar2);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_date in varchar2, par_company in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_log_level varchar2(128);
      var_locked boolean;
      var_errors boolean;
      var_date date;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Order Aggregation';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_rpt_alt_group constant varchar2(32) := 'DW_ALERT';
      con_rpt_alt_code constant varchar2(32) := 'DW_REPORT_EXTRACT';
      con_rpt_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_rpt_ema_code constant varchar2(32) := 'DW_REPORT_EXTRACT';
      con_rpt_tri_group constant varchar2(32) := 'DW_JOB_GROUP';
      con_rpt_tri_code constant varchar2(32) := 'DW_REPORT_EXTRACT';
      con_log_lvl_code constant varchar2(32) := 'DW_LOG_LEVEL';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_ORDER_AGGREGATION';
      var_log_search := 'DW_ORDER_AGGREGATION';
      var_loc_string := 'DW_ORDER_AGGREGATION';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_log_level := lics_setting_configuration.retrieve_setting(con_alt_group, con_log_lvl_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_date is null then
         raise_application_error(-20000, 'Date parameter must be supplied');
      else
         begin
            var_date := to_date(par_date,'yyyymmdd');
         exception
            when others then
               raise_application_error(-20000, 'Date parameter (' || par_date || ') - unable to convert to date format YYYYMMDD');
         end;
      end if;
      if upper(par_company) is null then
         raise_application_error(-20000, 'Company parameter must be supplied');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Order Aggregation - Parameters(' || nvl(par_date,'NULL') || ' + ' || par_company || ')');

      /*-*/
      /* Request the lock on the order aggregation
      /*-*/
      begin
         lics_locking.request(var_loc_string || '-' || par_company);
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
         /* ORDER_FACT load
         /*-*/
         begin
            order_fact_load(var_date, par_company, var_log_level);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Release the lock on the order extract
         /*-*/
         lics_locking.release(var_loc_string || '-' || par_company);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Order Aggregation');

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
                                         'DW_ORDER_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Order Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      /*-*/
      /* Set processing trace when required
      /*-*/
      else

         /*-*/
         /* Set the order aggregation trace for the current company
         /*-*/
         lics_processing.set_trace('ORDER_AGGREGATION_' || par_company, par_date);

         /*-*/
         /* Trigger the report extracts
         /*-*/
         lics_trigger_loader.execute('DW Report Extract',
                                     'dw_report_extract.execute(''' || par_company || ''')',
                                     lics_setting_configuration.retrieve_setting(con_rpt_alt_group, con_rpt_alt_code),
                                     lics_setting_configuration.retrieve_setting(con_rpt_ema_group, con_rpt_ema_code),
                                     lics_setting_configuration.retrieve_setting(con_rpt_tri_group, con_rpt_tri_code));

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Release the lock on the order aggregation
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string || '-' || par_company);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_ORDER_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*******************************************************/
   /* This procedure performs the order fact load routine */
   /*******************************************************/
   procedure order_fact_load(par_date in date, par_company in varchar2, par_log_level in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_order_type_sign order_type.order_type_sign%type;
      var_order_type_gsv order_type.order_type_gsv%type;
      var_matnr lads_mat_uom.matnr%type;
      var_meinh lads_mat_uom.meinh%type;
      var_order_type_factor number;
      var_price_record_factor number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_order_fact is
         select t01.*
           from order_fact t01
          where t01.sap_company_code = par_company
            and t01.ord_lin_status = '*UPD'
          order by t01.ord_doc_num asc, t01.ord_doc_line_num asc;
      rcd_order_fact csr_order_fact%rowtype;

      cursor csr_lads_sal_ord_gen is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.posex as posex,
                t01.menee as menee,
                t01.werks as werks,
                t01.lgort as lgort,
                t01.abrvw as abrvw,
                t01.abgru as abgru,
                nvl(lads_to_number(t01.menge),0) as menge,
                t02.curcy as curcy,
                nvl(lads_to_number(t02.wkurs),1) as wkurs,
                t02.abrvw as hdr_abrvw,
                t02.augru as augru,
                t02.lads_date as lads_date
           from lads_sal_ord_gen t01,
                lads_sal_ord_hdr t02
          where t01.belnr = t02.belnr(+)
            and t01.belnr = rcd_order_fact.ord_doc_num
            and t01.posex = rcd_order_fact.ord_doc_line_num;
      rcd_lads_sal_ord_gen csr_lads_sal_ord_gen%rowtype;

      cursor csr_lads_sal_ord_dat is
         select t01.belnr as belnr,
                t01.iddat as iddat,
                lads_to_date(t01.datum,'yyyymmdd') as datum,
                t02.mars_yyyyppdd as mars_yyyyppdd,
                t02.mars_week as mars_yyyyppw,
                t02.mars_period as mars_yyyypp,
                (t02.year_num * 100) + t02.month_num as mars_yyyymm
           from lads_sal_ord_dat t01,
                mars_date t02
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.iddat in ('002','025')
            and lads_to_date(t01.datum,'yyyymmdd') = t02.calendar_date(+);
      rcd_lads_sal_ord_dat csr_lads_sal_ord_dat%rowtype;

      cursor csr_lads_sal_ord_org is
         select t01.belnr as belnr,
                t01.qualf as qualf,
                t01.orgid as orgid
           from lads_sal_ord_org t01
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.qualf in ('006','007','008','012');
      rcd_lads_sal_ord_org csr_lads_sal_ord_org%rowtype;

      cursor csr_lads_sal_ord_pnr is
         select t01.belnr as belnr,
                t01.parvw as parvw,
                lads_trim_code(t01.partn) as partn
           from lads_sal_ord_pnr t01
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.parvw in ('AG','RE','RG','WE');
      rcd_lads_sal_ord_pnr csr_lads_sal_ord_pnr%rowtype;

      cursor csr_lads_sal_ord_ref is
         select t01.qualf as qualf,
                t01.refnr as refnr
           from lads_sal_ord_ref t01
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.qualf in ('001');
      rcd_lads_sal_ord_ref csr_lads_sal_ord_ref%rowtype;

      cursor csr_lads_sal_ord_iid is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.qualf as qualf,
                t01.idtnr as idtnr
           from lads_sal_ord_iid t01
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.genseq = rcd_lads_sal_ord_gen.genseq
            and t01.qualf in ('002','Z01');
      rcd_lads_sal_ord_iid csr_lads_sal_ord_iid%rowtype;

      cursor csr_lads_sal_ord_isc is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.iscseq as iscseq,
                nvl(lads_to_number(t01.wmeng),0) as wmeng,
                lads_to_date(t01.edatu,'yyyymmdd') as edatu,
                t02.mars_yyyyppdd as mars_yyyyppdd,
                t02.mars_week as mars_yyyyppw,
                t02.mars_period as mars_yyyypp,
                (t02.year_num * 100) + t02.month_num as mars_yyyymm
           from lads_sal_ord_isc t01,
                mars_date t02
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.genseq = rcd_lads_sal_ord_gen.genseq
            and lads_to_date(t01.edatu,'yyyymmdd') = t02.calendar_date(+)
          order by t01.iscseq desc;
      rcd_lads_sal_ord_isc csr_lads_sal_ord_isc%rowtype;

      cursor csr_lads_sal_ord_ipn is
         select t01.parvw as parvw,
                lads_trim_code(t01.partn) as partn
           from lads_sal_ord_ipn t01
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.genseq = rcd_lads_sal_ord_gen.genseq
            and t01.parvw in ('AG','RE','RG','WE')
            and not(t01.partn is null);
      rcd_lads_sal_ord_ipn csr_lads_sal_ord_ipn%rowtype;

      cursor csr_lads_sal_ord_ico is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.alckz as alckz,
                t01.kschl as kschl,
                t01.kotxt as kotxt,
                nvl(lads_to_number(t01.betrg),0) as betrg
           from lads_sal_ord_ico t01
          where t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.genseq = rcd_lads_sal_ord_gen.genseq;
      rcd_lads_sal_ord_ico csr_lads_sal_ord_ico%rowtype;

      cursor csr_lads_mat_uom is
         select t01.meins as meins,
                t01.gewei as gewei,
                nvl(t01.ntgew,0) as ntgew,
                nvl(t02.umren,1) as sal_umren,
                nvl(t02.umrez,1) as sal_umrez,
                nvl(t03.umren,1) as pce_umren,
                nvl(t03.umrez,1) as pce_umrez
           from lads_mat_hdr t01,
                (select t21.matnr,
                        t21.umren,
                        t21.umrez
                   from lads_mat_uom t21
                  where t21.matnr = var_matnr
                    and t21.meinh = var_meinh) t02,
                (select t31.matnr,
                        t31.umren,
                        t31.umrez
                   from lads_mat_uom t31
                  where t31.matnr = var_matnr
                    and t31.meinh = 'PCE') t03
          where t01.matnr = t02.matnr(+)
            and t01.matnr = t03.matnr(+)
            and t01.matnr = var_matnr;
      rcd_lads_mat_uom csr_lads_mat_uom%rowtype;

      cursor csr_order_type is
         select t01.order_type_sign as order_type_sign,
                t01.order_type_gsv as order_type_gsv
           from order_type t01
          where t01.sap_order_type_code = rcd_order_fact.sap_order_type_code;
      rcd_order_type csr_order_type%rowtype;

      cursor csr_lads_del_irf is
         select t01.irfseq as irfseq,
                t02.vbeln as vbeln,
                t02.posnr as posnr,
                t02.matnr as matnr,
                t02.vrkme as vrkme,
                t02.lfimg as lfimg,
                t02.meins as meins,
                t02.lgmng as lgmng,
                t03.del_idoc_number as del_idoc_number,
                t03.pod_idoc_number as pod_idoc_number,
                t03.del_lads_date as del_lads_date,
                t03.pod_lads_date as pod_lads_date,
                lads_to_date(ltrim(t04.isdd,'0'),'yyyymmdd') as del_isdd,
                t06.mars_yyyyppdd as del_mars_yyyyppdd,
                t06.mars_week as del_mars_yyyyppw,
                t06.mars_period as del_mars_yyyypp,
                (t06.year_num * 100) + t06.month_num as del_mars_yyyymm,
                lads_to_date(nvl(ltrim(t05.isdd,'0'),ltrim(t05.ntanf,'0')),'yyyymmdd') as pod_isdd,
                t07.mars_yyyyppdd as pod_mars_yyyyppdd,
                t07.mars_week as pod_mars_yyyyppw,
                t07.mars_period as pod_mars_yyyypp,
                (t07.year_num * 100) + t07.month_num as pod_mars_yyyymm
           from lads_del_irf t01,
                lads_del_det t02,
                lads_del_hdr t03,
                lads_del_tim t04,
                lads_del_tim t05,
                mars_date t06,
                mars_date t07
          where t01.vbeln = t02.vbeln(+)
            and t01.detseq = t02.detseq(+)
            and t02.vbeln = t03.vbeln(+)
            and t03.vbeln = t04.vbeln(+)
            and '006' = t04.qualf(+)
            and t03.vbeln = t05.vbeln(+)
            and 'Z02' = t05.qualf(+)
            and lads_to_date(ltrim(t04.isdd,'0'),'yyyymmdd') = t06.calendar_date(+)
            and lads_to_date(nvl(ltrim(t05.isdd,'0'),ltrim(t05.ntanf,'0')),'yyyymmdd') = t07.calendar_date(+)
            and t01.belnr = rcd_lads_sal_ord_gen.belnr
            and t01.posnr = rcd_lads_sal_ord_gen.posex
            and t01.qualf in ('C','H','I','K','L')
            and not(t01.datum is null)
            and (t02.hievw is null or t02.hievw = '5')
            and t03.lads_status = '1'
            and not(t03.del_idoc_number is null)
          order by t01.irfseq asc;
      rcd_lads_del_irf csr_lads_del_irf%rowtype;

      cursor csr_lads_del_pod is
         select t01.vbeln as vbeln,
                decode(t01.hipos,null,t01.posnr,decode(t01.hievw,'5',t01.posnr,t01.hipos)) as posnr,
                max(t01.grund) as grund,
                max(nvl(t01.podmg,0)) as podmg
           from lads_del_pod t01
          where t01.vbeln = rcd_lads_del_irf.vbeln
            and (t01.posnr = rcd_lads_del_irf.posnr or
                 t01.hipos = rcd_lads_del_irf.posnr)
          group by t01.vbeln,
                   decode(t01.hipos,null,t01.posnr,decode(t01.hievw,'5',t01.posnr,t01.hipos));
      rcd_lads_del_pod csr_lads_del_pod%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - ORDER_FACT Load - Parameters(' || to_char(par_date,'yyyy/mm/dd') || ' + ' || par_company || ')');
      
      if ( par_log_level = '1' ) then
        lics_logging.write_log('Begin - Delete order fact rows for orders updated up to ' || to_char(par_date,'yyyy/mm/dd'));
      end if;

      /*-*/
      /* STEP #1
      /*
      /* Delete the order fact rows for orders updated up until the parameter date
      /* **notes** 1. ORDER_FACT rows are deleted for order line status '*UPD'
      /*           2. ORDER_FACT rows are deleted for only LADS status not valid
      /*              (eg. order line could have been be valid in ORDER_FACT but order line now deleted/rejected in LADS)
      /*-*/
      delete from order_fact
       where ord_lin_status = '*UPD'
         and sap_company_code = par_company;
         
      delete from order_fact
       where (ord_doc_num, ord_doc_line_num)
             in (select t13.ord_doc_num,
                        t13.ord_doc_line_num
                   from lads_sal_ord_hdr t11,
                        lads_sal_ord_gen t12,
                        order_fact t13
                  where t11.belnr = t12.belnr
                    and t12.belnr = t13.ord_doc_num
                    and t12.posex = t13.ord_doc_line_num
                    and t13.sap_company_code = par_company
                    and trunc(t11.lads_date) <= trunc(par_date)
                    and (t11.lads_status != '1' or
                         (not(t12.abgru is null) and t12.abgru != 'ZA') or
                         ((t12.abgru is null or t12.abgru = 'ZA') and t12.menge is null and t12.menee is null)));
      commit;

      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Delete order fact rows');
        lics_logging.write_log('Begin - Update order fact rows for orders updated up to ' || to_char(par_date,'yyyy/mm/dd'));
      end if;

      /*-*/
      /* STEP #2
      /*
      /* Update order fact rows for orders updated up until the parameter date
      /* **notes** 1. ORDER_FACT rows are updated for only LADS status valid
      /*-*/
      update order_fact
         set ord_lin_status = '*UPD'
       where (ord_doc_num, ord_doc_line_num)
             in (select t12.ord_doc_num,
                        t12.ord_doc_line_num
                   from lads_sal_ord_hdr t11,
                        order_fact t12
                  where t11.belnr = t12.ord_doc_num
                    and trunc(t11.lads_date) <= trunc(par_date)
                    and t11.lads_status = '1'
                    and t11.lads_date != t12.ord_trn_date
                    and t12.sap_company_code = par_company);
      commit;
      
      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Update order fact rows for orders');
        lics_logging.write_log('Begin - Update order fact rows for deliveries updated up to ' || to_char(par_date,'yyyy/mm/dd'));
      end if;      

      /*-*/
      /* STEP #3
      /*
      /* Update order fact rows for all deliveries updated up until the parameter date
      /* **notes** 1. ORDER_FACT rows are updated for all LADS status
      /*           2. delivery inserted/updated in lads
      /*           3. delivery could have been be valid in ORDER_FACT but delivery now deleted in LADS
      /*-*/
      update order_fact
         set ord_lin_status = '*UPD'
       where (ord_doc_num, ord_doc_line_num)
             in (select t14.ord_doc_num,
                        t14.ord_doc_line_num
                   from lads_del_hdr t11,
                        lads_del_det t12,
                        lads_del_irf t13,
                        order_fact t14
                  where t11.vbeln = t12.vbeln
                    and t12.vbeln = t13.vbeln
                    and t12.detseq = t13.detseq
                    and t13.belnr = t14.ord_doc_num
                    and t13.posnr = t14.ord_doc_line_num
                    and ((not(t11.del_lads_date is null) and trunc(t11.del_lads_date) <= trunc(par_date) and (t14.del_trn_date is null or t11.del_lads_date != t14.del_trn_date)) or
                         (not(t11.pod_lads_date is null) and trunc(t11.pod_lads_date) <= trunc(par_date) and (t14.pod_trn_date is null or t11.pod_lads_date != t14.pod_trn_date)))
                    and not(t11.del_idoc_number is null)
                    and (t12.hievw is null or t12.hievw = '5')
                    and t13.qualf in ('C','H','I','K','L')
                    and not(t13.datum is null)
                    and t14.sap_company_code = par_company);
      commit;
      
      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Update order fact rows for deliveries');
        lics_logging.write_log('Begin - Insert order fact rows for orders updated up to ' || to_char(par_date,'yyyy/mm/dd'));
      end if;        

      /*-*/
      /* STEP #4
      /*
      /* Insert order fact rows for orders updated up until the parameter date
      /* **notes** 1. ORDER_FACT rows are inserted for only LADS status valid
      /*              (ie. new valid orders in LADS)
      /*           2. The order must be valid and the order line must not be rejected
      /*           3. The order line must have a material code
      /*           4. The minus test excludes the company as it is not part of the primary key
      /*-*/
      insert into order_fact
         (ord_doc_num,
          ord_doc_line_num,
          ord_lin_status,
          sap_company_code)
         (select t01.ord_doc_num,
                 t01.ord_doc_line_num,
                 '*UPD',
                 par_company
            from (select t12.belnr as ord_doc_num,
                         t12.posex as ord_doc_line_num
                    from lads_sal_ord_hdr t11,
                         lads_sal_ord_gen t12,
                         lads_sal_ord_iid t13,
                         (select t41.belnr as belnr
                            from lads_sal_ord_org t41
                           where t41.qualf = '008'
                             and t41.orgid = par_company) t14
                   where t11.belnr = t12.belnr
                     and t12.belnr = t13.belnr
                     and t12.genseq = t13.genseq
                     and t12.belnr = t14.belnr
                     and t11.lads_date >= (select nvl(max(ord_trn_date)-14,to_date('19000101','yyyymmdd')) from order_fact)
                     and trunc(t11.lads_date) <= trunc(par_date)
                     and t11.lads_status = '1'
                     and (t12.abgru is null or t12.abgru = 'ZA')
                     and (not(t12.menge is null) or not(t12.menee is null))
                     and t13.qualf = '002'
                     and not(t13.idtnr is null)
                   minus
                  select t21.ord_doc_num as ord_doc_num,
                         t21.ord_doc_line_num as ord_doc_line_num
                    from order_fact t21) t01);
      commit;

      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Insert order fact rows for orders');
        lics_logging.write_log('Begin - Retrieve the order fact rows with an update status');
      end if; 

      /*-*/
      /* STEP #5
      /*
      /* Retrieve the order fact rows with an update status
      /*-*/
      open csr_order_fact;
      loop
         fetch csr_order_fact into rcd_order_fact;
         if csr_order_fact%notfound then
            exit;
         end if;

         /*-*/
         /* Reset the order fact values
         /*-*/
         rcd_order_fact.del_doc_num := null;
         rcd_order_fact.del_doc_line_num := null;
         rcd_order_fact.ord_trn_date := null;
         rcd_order_fact.del_trn_date := null;
         rcd_order_fact.pod_trn_date := null;
         rcd_order_fact.creation_date := null;
         rcd_order_fact.creation_yyyyppdd := null;
         rcd_order_fact.creation_yyyyppw := null;
         rcd_order_fact.creation_yyyypp := null;
         rcd_order_fact.creation_yyyymm := null;
         rcd_order_fact.agr_date := null;
         rcd_order_fact.agr_yyyyppdd := null;
         rcd_order_fact.agr_yyyyppw := null;
         rcd_order_fact.agr_yyyypp := null;
         rcd_order_fact.agr_yyyymm := null;
         rcd_order_fact.sch_date := null;
         rcd_order_fact.sch_yyyyppdd := null;
         rcd_order_fact.sch_yyyyppw := null;
         rcd_order_fact.sch_yyyypp := null;
         rcd_order_fact.sch_yyyymm := null;
         rcd_order_fact.del_date := null;
         rcd_order_fact.del_yyyyppdd := null;
         rcd_order_fact.del_yyyyppw := null;
         rcd_order_fact.del_yyyypp := null;
         rcd_order_fact.del_yyyymm := null;
         rcd_order_fact.pod_date := null;
         rcd_order_fact.pod_yyyyppdd := null;
         rcd_order_fact.pod_yyyyppw := null;
         rcd_order_fact.pod_yyyypp := null;
         rcd_order_fact.pod_yyyymm := null;
         rcd_order_fact.pod_refusal := null;
         rcd_order_fact.sap_order_type_code := null;
         rcd_order_fact.sap_order_reasn_code := null;
         rcd_order_fact.sap_order_usage_code := null;
         rcd_order_fact.sap_doc_currcy_code := null;
         rcd_order_fact.sap_sold_to_cust_code := null;
         rcd_order_fact.sap_bill_to_cust_code := null;
         rcd_order_fact.sap_payer_cust_code := null;
         rcd_order_fact.sap_ship_to_cust_code := null;
         rcd_order_fact.sap_sales_hdr_sales_org_code := null;
         rcd_order_fact.sap_sales_hdr_distbn_chnl_code := null;
         rcd_order_fact.sap_sales_hdr_division_code := null;
         rcd_order_fact.sap_plant_code := null;
         rcd_order_fact.sap_storage_locn_code := null;
         rcd_order_fact.sap_ord_qty_uom_code := null;
         rcd_order_fact.sap_ord_qty_base_uom_code := null;
         rcd_order_fact.sap_del_qty_uom_code := null;
         rcd_order_fact.sap_del_qty_base_uom_code := null;
         rcd_order_fact.sap_ord_material := null;
         rcd_order_fact.sap_del_material := null;
         rcd_order_fact.sap_material_code := null;
         rcd_order_fact.material_entd := null;
         rcd_order_fact.purch_order_num := null;
         rcd_order_fact.exch_rate := 0;
         rcd_order_fact.ord_qty := 0;
         rcd_order_fact.ord_base_uom_qty := 0;
         rcd_order_fact.ord_pieces_qty := 0;
         rcd_order_fact.ord_tonnes_qty := 0;
         rcd_order_fact.ord_gsv := 0;
         rcd_order_fact.ord_niv := 0;
         rcd_order_fact.sch_qty := 0;
         rcd_order_fact.sch_base_uom_qty := 0;
         rcd_order_fact.sch_pieces_qty := 0;
         rcd_order_fact.sch_tonnes_qty := 0;
         rcd_order_fact.sch_gsv := 0;
         rcd_order_fact.sch_niv := 0;
         rcd_order_fact.del_qty := 0;
         rcd_order_fact.del_base_uom_qty := 0;
         rcd_order_fact.del_pieces_qty := 0;
         rcd_order_fact.del_tonnes_qty := 0;
         rcd_order_fact.del_gsv := 0;
         rcd_order_fact.del_niv := 0;
         rcd_order_fact.pod_qty := 0;
         rcd_order_fact.pod_base_uom_qty := 0;
         rcd_order_fact.pod_pieces_qty := 0;
         rcd_order_fact.pod_tonnes_qty := 0;
         rcd_order_fact.pod_gsv := 0;
         rcd_order_fact.pod_niv := 0;

         /*-*/
         /* Retrieve the related sales order line
         /*-*/
         open csr_lads_sal_ord_gen;
         fetch csr_lads_sal_ord_gen into rcd_lads_sal_ord_gen;
         if csr_lads_sal_ord_gen%found then

            /*-*/
            /* Set the sales fact header values
            /*-*/
            rcd_order_fact.sap_doc_currcy_code := rcd_lads_sal_ord_gen.curcy;
            rcd_order_fact.exch_rate := rcd_lads_sal_ord_gen.wkurs;
            rcd_order_fact.sap_order_reasn_code := rcd_lads_sal_ord_gen.augru;

            /*-*/
            /* Retrieve the order date data
            /*-*/
            open csr_lads_sal_ord_dat;
            loop
               fetch csr_lads_sal_ord_dat into rcd_lads_sal_ord_dat;
               if csr_lads_sal_ord_dat%notfound then
                  exit;
               end if;
               if rcd_lads_sal_ord_dat.iddat = '002' then
                  rcd_order_fact.agr_date := rcd_lads_sal_ord_dat.datum;
                  rcd_order_fact.agr_yyyyppdd := rcd_lads_sal_ord_dat.mars_yyyyppdd;
                  rcd_order_fact.agr_yyyyppw := rcd_lads_sal_ord_dat.mars_yyyyppw;
                  rcd_order_fact.agr_yyyypp := rcd_lads_sal_ord_dat.mars_yyyypp;
                  rcd_order_fact.agr_yyyymm := rcd_lads_sal_ord_dat.mars_yyyymm;
               elsif rcd_lads_sal_ord_dat.iddat = '025' then
                  rcd_order_fact.creation_date := rcd_lads_sal_ord_dat.datum;
                  rcd_order_fact.creation_yyyyppdd := rcd_lads_sal_ord_dat.mars_yyyyppdd;
                  rcd_order_fact.creation_yyyyppw := rcd_lads_sal_ord_dat.mars_yyyyppw;
                  rcd_order_fact.creation_yyyypp := rcd_lads_sal_ord_dat.mars_yyyypp;
                  rcd_order_fact.creation_yyyymm := rcd_lads_sal_ord_dat.mars_yyyymm;
               end if;
            end loop;
            close csr_lads_sal_ord_dat;

            /*-*/
            /* Retrieve the order organisation data
            /*-*/
            open csr_lads_sal_ord_org;
            loop
               fetch csr_lads_sal_ord_org into rcd_lads_sal_ord_org;
               if csr_lads_sal_ord_org%notfound then
                  exit;
               end if;
               case rcd_lads_sal_ord_org.qualf
                  when '006' then rcd_order_fact.sap_sales_hdr_division_code := rcd_lads_sal_ord_org.orgid;
                  when '007' then rcd_order_fact.sap_sales_hdr_distbn_chnl_code := rcd_lads_sal_ord_org.orgid;
                  when '008' then rcd_order_fact.sap_sales_hdr_sales_org_code := rcd_lads_sal_ord_org.orgid;
                  when '012' then rcd_order_fact.sap_order_type_code := rcd_lads_sal_ord_org.orgid;
                  else null;
               end case;
            end loop;
            close csr_lads_sal_ord_org;

            /*-*/
            /* Retrieve the order partner data
            /*-*/
            open csr_lads_sal_ord_pnr;
            loop
               fetch csr_lads_sal_ord_pnr into rcd_lads_sal_ord_pnr;
               if csr_lads_sal_ord_pnr%notfound then
                  exit;
               end if;
               case rcd_lads_sal_ord_pnr.parvw
                  when 'AG' then rcd_order_fact.sap_sold_to_cust_code := rcd_lads_sal_ord_pnr.partn;
                  when 'RE' then rcd_order_fact.sap_bill_to_cust_code := rcd_lads_sal_ord_pnr.partn;
                  when 'RG' then rcd_order_fact.sap_payer_cust_code := rcd_lads_sal_ord_pnr.partn;
                  when 'WE' then rcd_order_fact.sap_ship_to_cust_code := rcd_lads_sal_ord_pnr.partn;
                  else null;
               end case;
            end loop;
            close csr_lads_sal_ord_pnr;

            /*-*/
            /* Set the order reference data
            /*-*/
            open csr_lads_sal_ord_ref;
            loop
               fetch csr_lads_sal_ord_ref into rcd_lads_sal_ord_ref;
               if csr_lads_sal_ord_ref%notfound then
                  exit;
               end if;
               if rcd_lads_sal_ord_ref.qualf = '001' then
                  rcd_order_fact.purch_order_num := rcd_lads_sal_ord_ref.refnr;
               end if;
            end loop;
            close csr_lads_sal_ord_ref;

            /*-*/
            /* Retrieve the order type data
            /*-*/
            var_order_type_sign := null;
            var_order_type_gsv := '0';
            open csr_order_type;
            fetch csr_order_type into rcd_order_type;
            if csr_order_type%found then
               var_order_type_sign := rcd_order_type.order_type_sign;
               var_order_type_gsv := rcd_order_type.order_type_gsv;
            end if;
            close csr_order_type;
            var_order_type_factor := 1;
	    if var_order_type_sign = '-' then
	       var_order_type_factor := -1;
            end if;

            /*-*/
            /* Retrieve the order object identification data
            /*-*/
            open csr_lads_sal_ord_iid;
            loop
               fetch csr_lads_sal_ord_iid into rcd_lads_sal_ord_iid;
               if csr_lads_sal_ord_iid%notfound then
                  exit;
               end if;
               case rcd_lads_sal_ord_iid.qualf
                  when '002' then rcd_order_fact.sap_material_code := rcd_lads_sal_ord_iid.idtnr;
                  when 'Z01' then rcd_order_fact.material_entd := lads_trim_code(rcd_lads_sal_ord_iid.idtnr);
                  else null;
               end case;
            end loop;
            close csr_lads_sal_ord_iid;
            rcd_order_fact.sap_ord_material := dw_expand_code(rcd_order_fact.sap_material_code);
            rcd_order_fact.sap_material_code := lads_trim_code(rcd_order_fact.sap_material_code);

            /*-*/
            /* Set the order line data
            /*-*/
            rcd_order_fact.ord_lin_status := '*ORD';
            if var_order_type_gsv != '1' then
               rcd_order_fact.ord_lin_status := '*NVL';
            end if;
            rcd_order_fact.ord_trn_date := rcd_lads_sal_ord_gen.lads_date;
            rcd_order_fact.sap_ord_qty_uom_code := rcd_lads_sal_ord_gen.menee;
            rcd_order_fact.sap_plant_code := rcd_lads_sal_ord_gen.werks;
            rcd_order_fact.sap_storage_locn_code := rcd_lads_sal_ord_gen.lgort;
            rcd_order_fact.sap_order_usage_code := rcd_lads_sal_ord_gen.abrvw;
            if rcd_order_fact.sap_order_type_code = 'ZRE' then
               rcd_order_fact.sap_order_usage_code := rcd_lads_sal_ord_gen.hdr_abrvw;
            end if;

            /*-*/
            /* Retrieve the order line scheduled data
            /* **note** the relationship allows for many scheduled rows for each order line
            /*          so only the last row is used (ie, the highest iscseq number)
            /*-*/
            rcd_lads_sal_ord_isc.wmeng := 0;
            open csr_lads_sal_ord_isc;
            fetch csr_lads_sal_ord_isc into rcd_lads_sal_ord_isc;
            if csr_lads_sal_ord_isc%found then
               rcd_order_fact.sch_date := rcd_lads_sal_ord_isc.edatu;
               rcd_order_fact.sch_yyyyppdd := rcd_lads_sal_ord_isc.mars_yyyyppdd;
               rcd_order_fact.sch_yyyyppw := rcd_lads_sal_ord_isc.mars_yyyyppw;
               rcd_order_fact.sch_yyyypp := rcd_lads_sal_ord_isc.mars_yyyypp;
               rcd_order_fact.sch_yyyymm := rcd_lads_sal_ord_isc.mars_yyyymm;
            end if;
            close csr_lads_sal_ord_isc;

            /*-*/
            /* Retrieve the order item partner data
            /*-*/
            open csr_lads_sal_ord_ipn;
            loop
               fetch csr_lads_sal_ord_ipn into rcd_lads_sal_ord_ipn;
               if csr_lads_sal_ord_ipn%notfound then
                  exit;
               end if;
               case rcd_lads_sal_ord_ipn.parvw
                  when 'AG' then rcd_order_fact.sap_sold_to_cust_code := rcd_lads_sal_ord_ipn.partn;
                  when 'RE' then rcd_order_fact.sap_bill_to_cust_code := rcd_lads_sal_ord_ipn.partn;
                  when 'RG' then rcd_order_fact.sap_payer_cust_code := rcd_lads_sal_ord_ipn.partn;
                  when 'WE' then rcd_order_fact.sap_ship_to_cust_code := rcd_lads_sal_ord_ipn.partn;
                  else null;
               end case;
            end loop;
            close csr_lads_sal_ord_ipn;

            /*-*/
            /* Calculate the order quantity columns
            /*-*/
            rcd_order_fact.ord_qty := rcd_lads_sal_ord_gen.menge * var_order_type_factor;
            rcd_order_fact.ord_base_uom_qty := rcd_order_fact.ord_qty;
            rcd_order_fact.ord_pieces_qty := rcd_order_fact.ord_qty;
            rcd_order_fact.ord_tonnes_qty := 0;
            var_matnr := rcd_order_fact.sap_ord_material;
            var_meinh := rcd_order_fact.sap_ord_qty_uom_code;
            open csr_lads_mat_uom;
            fetch csr_lads_mat_uom into rcd_lads_mat_uom;
            if csr_lads_mat_uom%found then
               rcd_order_fact.sap_ord_qty_base_uom_code := rcd_lads_mat_uom.meins;
               rcd_order_fact.ord_base_uom_qty := (rcd_order_fact.ord_qty * rcd_lads_mat_uom.sal_umrez) / rcd_lads_mat_uom.sal_umren;
               if rcd_order_fact.sap_ord_qty_uom_code != 'PCE' then
                  rcd_order_fact.ord_pieces_qty := (rcd_order_fact.ord_base_uom_qty / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;
               end if;
               case rcd_lads_mat_uom.gewei
                  when 'G' then rcd_order_fact.ord_tonnes_qty := rcd_order_fact.ord_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                  when 'GRM' then rcd_order_fact.ord_tonnes_qty := rcd_order_fact.ord_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                  when 'KG' then rcd_order_fact.ord_tonnes_qty := rcd_order_fact.ord_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                  when 'KGM' then rcd_order_fact.ord_tonnes_qty := rcd_order_fact.ord_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                  when 'TO' then rcd_order_fact.ord_tonnes_qty := rcd_order_fact.ord_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                  when 'TON' then rcd_order_fact.ord_tonnes_qty := rcd_order_fact.ord_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                  else rcd_order_fact.ord_tonnes_qty := 0;
               end case;
            end if;
            close csr_lads_mat_uom;

            /*-*/
            /* Calculate the order value columns
            /*-*/
            open csr_lads_sal_ord_ico;
            loop
               fetch csr_lads_sal_ord_ico into rcd_lads_sal_ord_ico;
               if csr_lads_sal_ord_ico%notfound then
                  exit;
               end if;
               var_price_record_factor := 1;
               if rcd_lads_sal_ord_ico.alckz = '-' then
                  var_price_record_factor := -1;
               end if;
               rcd_lads_sal_ord_ico.betrg := rcd_lads_sal_ord_ico.betrg * var_order_type_factor * var_price_record_factor;
               case upper(rcd_lads_sal_ord_ico.kotxt)
                  when 'GSV' then rcd_order_fact.ord_gsv := round(rcd_lads_sal_ord_ico.betrg*rcd_order_fact.exch_rate,2);
                  when 'INVOICE VALUE' then rcd_order_fact.ord_niv := round(rcd_lads_sal_ord_ico.betrg*rcd_order_fact.exch_rate,2);
                  else null;
               end case;
            end loop;
            close csr_lads_sal_ord_ico;

            /*-*/
            /* Calculate the scheduled quantity and value columns
            /*-*/
            rcd_order_fact.sch_qty := rcd_lads_sal_ord_isc.wmeng * var_order_type_factor;
            rcd_order_fact.sch_base_uom_qty := rcd_order_fact.sch_qty;
            rcd_order_fact.sch_pieces_qty := rcd_order_fact.sch_qty;
            rcd_order_fact.sch_tonnes_qty := 0;
            if not(rcd_order_fact.sap_ord_qty_base_uom_code is null) then
               rcd_order_fact.sch_base_uom_qty := (rcd_order_fact.sch_qty * rcd_lads_mat_uom.sal_umrez) / rcd_lads_mat_uom.sal_umren;
               if rcd_order_fact.sap_ord_qty_uom_code != 'PCE' then
                  rcd_order_fact.sch_pieces_qty := (rcd_order_fact.sch_base_uom_qty / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;
               end if;
               case rcd_lads_mat_uom.gewei
                  when 'G' then rcd_order_fact.sch_tonnes_qty := rcd_order_fact.sch_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                  when 'GRM' then rcd_order_fact.sch_tonnes_qty := rcd_order_fact.sch_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                  when 'KG' then rcd_order_fact.sch_tonnes_qty := rcd_order_fact.sch_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                  when 'KGM' then rcd_order_fact.sch_tonnes_qty := rcd_order_fact.sch_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                  when 'TO' then rcd_order_fact.sch_tonnes_qty := rcd_order_fact.sch_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                  when 'TON' then rcd_order_fact.sch_tonnes_qty := rcd_order_fact.sch_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                  else rcd_order_fact.sch_tonnes_qty := 0;
               end case;
            end if;
            if rcd_order_fact.ord_qty = 0 then
               rcd_order_fact.sch_gsv := rcd_order_fact.ord_gsv;
               rcd_order_fact.sch_niv := rcd_order_fact.ord_niv;
            else
               rcd_order_fact.sch_gsv := (rcd_order_fact.ord_gsv / rcd_order_fact.ord_qty) * rcd_order_fact.sch_qty;
               rcd_order_fact.sch_niv := (rcd_order_fact.ord_niv / rcd_order_fact.ord_qty) * rcd_order_fact.sch_qty;
            end if;
  
            /*-*/
            /* Check for a related picked or podded delivery line
            /* **note** 1. the status is set to either *DEL or *POD depending on the state of the delivery
            /*          2. one to one relationship is assumed (first irfseq used)
            /*-*/
            open csr_lads_del_irf;
            fetch csr_lads_del_irf into rcd_lads_del_irf;
            if csr_lads_del_irf%found then

               /*-*/
               /* Only process picked (goods issued) delivery lines for *DEL data
               /*-*/
               if not(rcd_lads_del_irf.del_isdd is null) then

                  /*-*/
                  /* Set the DEL status and data when goods issued date is present
                  /* **note** 1. message function PCK cannot be used as will be overriden by POD
                  /*          2. only picked (goods issued) delivery lines progess status to *DEL
                  /*-*/
                  if rcd_order_fact.ord_lin_status = '*ORD' then
                     rcd_order_fact.ord_lin_status := '*DEL';
                  end if;
                  rcd_order_fact.del_trn_date := rcd_lads_del_irf.del_lads_date;
                  rcd_order_fact.pod_trn_date := rcd_lads_del_irf.pod_lads_date;
                  rcd_order_fact.sap_del_material := rcd_lads_del_irf.matnr;
                  rcd_order_fact.sap_material_code := lads_trim_code(rcd_order_fact.sap_del_material);
                  rcd_order_fact.sap_del_qty_uom_code := rcd_lads_del_irf.vrkme;
                  rcd_order_fact.sap_del_qty_base_uom_code := rcd_lads_del_irf.meins;
                  rcd_order_fact.del_doc_num := rcd_lads_del_irf.vbeln;
                  rcd_order_fact.del_doc_line_num := rcd_lads_del_irf.posnr;
                  rcd_order_fact.del_date := rcd_lads_del_irf.del_isdd;
                  rcd_order_fact.del_yyyyppdd := rcd_lads_del_irf.del_mars_yyyyppdd;
                  rcd_order_fact.del_yyyyppw := rcd_lads_del_irf.del_mars_yyyyppw;
                  rcd_order_fact.del_yyyypp := rcd_lads_del_irf.del_mars_yyyypp;
                  rcd_order_fact.del_yyyymm := rcd_lads_del_irf.del_mars_yyyymm;

                  /*-*/
                  /* Set the delivery quantities
                  /*-*/
                  rcd_order_fact.del_qty := rcd_lads_del_irf.lfimg * var_order_type_factor;
                  rcd_order_fact.del_base_uom_qty := rcd_order_fact.del_qty;
                  rcd_order_fact.del_pieces_qty := rcd_order_fact.del_qty;
                  rcd_order_fact.del_tonnes_qty := 0;
                  var_matnr := rcd_order_fact.sap_del_material;
                  var_meinh := rcd_order_fact.sap_del_qty_uom_code;
                  open csr_lads_mat_uom;
                  fetch csr_lads_mat_uom into rcd_lads_mat_uom;
                  if csr_lads_mat_uom%found then
                     rcd_order_fact.sap_del_qty_base_uom_code := rcd_lads_mat_uom.meins;
                     rcd_order_fact.del_base_uom_qty := (rcd_order_fact.del_qty * rcd_lads_mat_uom.sal_umrez) / rcd_lads_mat_uom.sal_umren;
                     if rcd_order_fact.sap_del_qty_uom_code != 'PCE' then
                        rcd_order_fact.del_pieces_qty := (rcd_order_fact.del_base_uom_qty / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;
                     end if;
                     case rcd_lads_mat_uom.gewei
                        when 'G' then rcd_order_fact.del_tonnes_qty := rcd_order_fact.del_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                        when 'GRM' then rcd_order_fact.del_tonnes_qty := rcd_order_fact.del_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                        when 'KG' then rcd_order_fact.del_tonnes_qty := rcd_order_fact.del_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                        when 'KGM' then rcd_order_fact.del_tonnes_qty := rcd_order_fact.del_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                        when 'TO' then rcd_order_fact.del_tonnes_qty := rcd_order_fact.del_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                        when 'TON' then rcd_order_fact.del_tonnes_qty := rcd_order_fact.del_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                        else rcd_order_fact.del_tonnes_qty := 0;
                     end case;
                  end if;
                  close csr_lads_mat_uom;

                  /*-*/
                  /* Calculate the delivery values
                  /*-*/
                  if rcd_order_fact.ord_qty = 0 then
                     rcd_order_fact.del_gsv := rcd_order_fact.ord_gsv;
                     rcd_order_fact.del_niv := rcd_order_fact.ord_niv;
                  else
                     rcd_order_fact.del_gsv := (rcd_order_fact.ord_gsv / rcd_order_fact.ord_qty) * rcd_order_fact.del_qty;
                     rcd_order_fact.del_niv := (rcd_order_fact.ord_niv / rcd_order_fact.ord_qty) * rcd_order_fact.del_qty;
                  end if;

                  /*-*/
                  /* Set the POD status and data when POD message and date is present
                  /* **note** 1. message function PCK cannot be used as will be overriden by POD
                  /*          2. only podded delivery lines with a POD message progess status to *POD
                  /*-*/
                  if not(rcd_lads_del_irf.pod_idoc_number is null) and not(rcd_lads_del_irf.pod_isdd is null) then

                     /*-*/
                     /* Set the POD status and time dimensions
                     /*-*/
                     if rcd_order_fact.ord_lin_status = '*DEL' then
                        rcd_order_fact.ord_lin_status := '*POD';
                     end if;
                     rcd_order_fact.pod_date := rcd_lads_del_irf.pod_isdd;
                     rcd_order_fact.pod_yyyyppdd := rcd_lads_del_irf.pod_mars_yyyyppdd;
                     rcd_order_fact.pod_yyyyppw := rcd_lads_del_irf.pod_mars_yyyyppw;
                     rcd_order_fact.pod_yyyypp := rcd_lads_del_irf.pod_mars_yyyypp;
                     rcd_order_fact.pod_yyyymm := rcd_lads_del_irf.pod_mars_yyyymm;

                     /*-*/
                     /* Retrieve related delivery line POD data
                     /* **note** 1. the retrieval is based on delivery line number
                     /*          2. No POD data equals fully delivered line
                     /*-*/
                     open csr_lads_del_pod;
                     fetch csr_lads_del_pod into rcd_lads_del_pod;
                     if csr_lads_del_pod%found then
                        rcd_order_fact.pod_refusal := rcd_lads_del_pod.grund;
                        rcd_order_fact.pod_qty := rcd_lads_del_pod.podmg * var_order_type_factor;
                        rcd_order_fact.pod_base_uom_qty := rcd_order_fact.pod_qty;
                        rcd_order_fact.pod_pieces_qty := rcd_order_fact.pod_qty;
                        rcd_order_fact.pod_tonnes_qty := 0;
                        if not(rcd_order_fact.sap_del_qty_base_uom_code is null) then
                           rcd_order_fact.pod_base_uom_qty := (rcd_order_fact.pod_qty * rcd_lads_mat_uom.sal_umrez) / rcd_lads_mat_uom.sal_umren;
                           if rcd_order_fact.sap_del_qty_uom_code != 'PCE' then
                              rcd_order_fact.pod_pieces_qty := (rcd_order_fact.pod_base_uom_qty / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;
                           end if;
                           case rcd_lads_mat_uom.gewei
                              when 'G' then rcd_order_fact.pod_tonnes_qty := rcd_order_fact.pod_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                              when 'GRM' then rcd_order_fact.pod_tonnes_qty := rcd_order_fact.pod_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                              when 'KG' then rcd_order_fact.pod_tonnes_qty := rcd_order_fact.pod_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                              when 'KGM' then rcd_order_fact.pod_tonnes_qty := rcd_order_fact.pod_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1000);
                              when 'TO' then rcd_order_fact.pod_tonnes_qty := rcd_order_fact.pod_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                              when 'TON' then rcd_order_fact.pod_tonnes_qty := rcd_order_fact.pod_base_uom_qty * (rcd_lads_mat_uom.ntgew / 1);
                              else rcd_order_fact.pod_tonnes_qty := 0;
                           end case;
                        end if;
                        if rcd_order_fact.ord_qty = 0 then
                           rcd_order_fact.pod_gsv := rcd_order_fact.ord_gsv;
                           rcd_order_fact.pod_niv := rcd_order_fact.ord_niv;
                        else
                           rcd_order_fact.pod_gsv := (rcd_order_fact.ord_gsv / rcd_order_fact.ord_qty) * rcd_order_fact.pod_qty;
                           rcd_order_fact.pod_niv := (rcd_order_fact.ord_niv / rcd_order_fact.ord_qty) * rcd_order_fact.pod_qty;
                        end if;
                     else
                        rcd_order_fact.pod_refusal := null;
                        rcd_order_fact.pod_qty := rcd_order_fact.del_qty;
                        rcd_order_fact.pod_base_uom_qty := rcd_order_fact.del_base_uom_qty;
                        rcd_order_fact.pod_pieces_qty := rcd_order_fact.del_pieces_qty;
                        rcd_order_fact.pod_tonnes_qty := rcd_order_fact.del_tonnes_qty;
                        rcd_order_fact.pod_gsv := rcd_order_fact.del_gsv;
                        rcd_order_fact.pod_niv := rcd_order_fact.del_niv;
                     end if;
                     close csr_lads_del_pod;

                  end if;

               end if;

            end if;
            close csr_lads_del_irf;

            /*-*/
            /* Update the order fact row
            /*-*/
            update order_fact
               set ord_lin_status = rcd_order_fact.ord_lin_status,
                   del_doc_num = rcd_order_fact.del_doc_num,
                   del_doc_line_num = rcd_order_fact.del_doc_line_num,
                   ord_trn_date = rcd_order_fact.ord_trn_date,
                   del_trn_date = rcd_order_fact.del_trn_date,
                   pod_trn_date = rcd_order_fact.pod_trn_date,
                   creation_date = rcd_order_fact.creation_date,
                   creation_yyyyppdd = rcd_order_fact.creation_yyyyppdd,
                   creation_yyyyppw = rcd_order_fact.creation_yyyyppw,
                   creation_yyyypp = rcd_order_fact.creation_yyyypp,
                   creation_yyyymm = rcd_order_fact.creation_yyyymm,
                   agr_date = rcd_order_fact.agr_date,
                   agr_yyyyppdd = rcd_order_fact.agr_yyyyppdd,
                   agr_yyyyppw = rcd_order_fact.agr_yyyyppw,
                   agr_yyyypp = rcd_order_fact.agr_yyyypp,
                   agr_yyyymm = rcd_order_fact.agr_yyyymm,
                   sch_date = rcd_order_fact.sch_date,
                   sch_yyyyppdd = rcd_order_fact.sch_yyyyppdd,
                   sch_yyyyppw = rcd_order_fact.sch_yyyyppw,
                   sch_yyyypp = rcd_order_fact.sch_yyyypp,
                   sch_yyyymm = rcd_order_fact.sch_yyyymm,
                   del_date = rcd_order_fact.del_date,
                   del_yyyyppdd = rcd_order_fact.del_yyyyppdd,
                   del_yyyyppw = rcd_order_fact.del_yyyyppw,
                   del_yyyypp = rcd_order_fact.del_yyyypp,
                   del_yyyymm = rcd_order_fact.del_yyyymm,
                   pod_date = rcd_order_fact.pod_date,
                   pod_yyyyppdd = rcd_order_fact.pod_yyyyppdd,
                   pod_yyyyppw = rcd_order_fact.pod_yyyyppw,
                   pod_yyyypp = rcd_order_fact.pod_yyyypp,
                   pod_yyyymm = rcd_order_fact.pod_yyyymm,
                   pod_refusal = rcd_order_fact.pod_refusal,
                   sap_company_code = rcd_order_fact.sap_company_code,
                   sap_order_type_code = rcd_order_fact.sap_order_type_code,
                   sap_order_reasn_code = rcd_order_fact.sap_order_reasn_code,
                   sap_order_usage_code = rcd_order_fact.sap_order_usage_code,
                   sap_doc_currcy_code = rcd_order_fact.sap_doc_currcy_code,
                   sap_sold_to_cust_code = rcd_order_fact.sap_sold_to_cust_code,
                   sap_bill_to_cust_code = rcd_order_fact.sap_bill_to_cust_code,
                   sap_payer_cust_code = rcd_order_fact.sap_payer_cust_code,
                   sap_ship_to_cust_code = rcd_order_fact.sap_ship_to_cust_code,
                   sap_sales_hdr_sales_org_code = rcd_order_fact.sap_sales_hdr_sales_org_code,
                   sap_sales_hdr_distbn_chnl_code = rcd_order_fact.sap_sales_hdr_distbn_chnl_code,
                   sap_sales_hdr_division_code = rcd_order_fact.sap_sales_hdr_division_code,
                   sap_plant_code = rcd_order_fact.sap_plant_code,
                   sap_storage_locn_code = rcd_order_fact.sap_storage_locn_code,
                   sap_ord_qty_uom_code = rcd_order_fact.sap_ord_qty_uom_code,
                   sap_ord_qty_base_uom_code = rcd_order_fact.sap_ord_qty_base_uom_code,
                   sap_del_qty_uom_code = rcd_order_fact.sap_del_qty_uom_code,
                   sap_del_qty_base_uom_code = rcd_order_fact.sap_del_qty_base_uom_code,
                   sap_ord_material = rcd_order_fact.sap_ord_material,
                   sap_del_material =  rcd_order_fact.sap_del_material,
                   sap_material_code = rcd_order_fact.sap_material_code,
                   material_entd = rcd_order_fact.material_entd,
                   purch_order_num = rcd_order_fact.purch_order_num,
                   exch_rate = rcd_order_fact.exch_rate,
                   ord_qty = rcd_order_fact.ord_qty,
                   ord_base_uom_qty = rcd_order_fact.ord_base_uom_qty,
                   ord_pieces_qty = rcd_order_fact.ord_pieces_qty,
                   ord_tonnes_qty = rcd_order_fact.ord_tonnes_qty,
                   ord_gsv = rcd_order_fact.ord_gsv,
                   ord_niv = rcd_order_fact.ord_niv,
                   sch_qty = rcd_order_fact.sch_qty,
                   sch_base_uom_qty = rcd_order_fact.sch_base_uom_qty,
                   sch_pieces_qty = rcd_order_fact.sch_pieces_qty,
                   sch_tonnes_qty = rcd_order_fact.sch_tonnes_qty,
                   sch_gsv = rcd_order_fact.sch_gsv,
                   sch_niv = rcd_order_fact.sch_niv,
                   del_qty = rcd_order_fact.del_qty,
                   del_base_uom_qty = rcd_order_fact.del_base_uom_qty,
                   del_pieces_qty = rcd_order_fact.del_pieces_qty,
                   del_tonnes_qty = rcd_order_fact.del_tonnes_qty,
                   del_gsv = rcd_order_fact.del_gsv,
                   del_niv = rcd_order_fact.del_niv,
                   pod_qty = rcd_order_fact.pod_qty,
                   pod_base_uom_qty = rcd_order_fact.pod_base_uom_qty,
                   pod_pieces_qty = rcd_order_fact.pod_pieces_qty,
                   pod_tonnes_qty = rcd_order_fact.pod_tonnes_qty,
                   pod_gsv = rcd_order_fact.pod_gsv,
                   pod_niv = rcd_order_fact.pod_niv
             where ord_doc_num = rcd_order_fact.ord_doc_num
               and ord_doc_line_num = rcd_order_fact.ord_doc_line_num;

         end if;
         close csr_lads_sal_ord_gen;

      end loop;
      close csr_order_fact;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Retrieve the order fact rows with an update status');
        lics_logging.write_log('Begin - Update order fact rows with the *INV status - invoice with billing date');
      end if; 

      /*-*/
      /* STEP #6
      /*
      /* Update order fact rows with the *INV status - invoice with billing date
      /* **notes** 1. ORDER_FACT rows are always set to *INV where a corresponding sales_fact rows exists
      /*              (ie. sales must not be counted twice)
      /*-*/
      update order_fact
         set ord_lin_status = '*INV'
       where sap_company_code = par_company
         and ord_lin_status in ('*ORD','*DEL','*POD')
         and (ord_doc_num, ord_doc_line_num) in (select t01.sales_doc_num,
                                                        t01.sales_doc_line_num
                                                   from sales_fact t01);
      commit;
      
      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Update order fact rows with the *INV status');
        lics_logging.write_log('Begin - Update order fact rows with the *INV status - invoice without billing date');
      end if;       

      /*-*/
      /* STEP #7
      /*
      /* Update order fact rows with the *INV status - invoice without billing date
      /* **notes** 1. ORDER_FACT rows must be set to *INV where a corresponding zero value invoice exists
      /*              (ie. unposted orders must be finalised)
      /*-*/
      update order_fact
         set ord_lin_status = '*INV'
       where sap_company_code = par_company
         and ord_lin_status in ('*ORD','*DEL','*POD')
         and (ord_doc_num, ord_doc_line_num) in (select t01.refnr as sales_doc_num,
                                                        t01.zeile as sales_doc_line_num
                                                   from lads_inv_irf t01,
                                                        (select t21.belnr as belnr
                                                           from lads_inv_org t21
                                                          where t21.qualf = '003'
                                                            and t21.orgid = par_company) t02
                                                  where t01.belnr = t02.belnr
                                                    and t01.qualf = '002'
                                                    and t01.belnr not in (select t01.belnr as belnr
                                                                            from lads_inv_dat t01
                                                                           where t01.iddat = '015'));
      commit;
      
      if ( par_log_level = '1' ) then
        lics_logging.write_log('End - Update order fact rows with the *INV status');
      end if;       

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - ORDER_FACT Load');

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
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - ORDER_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - ORDER_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end order_fact_load;

end dw_order_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_order_aggregation for dw_app.dw_order_aggregation;
grant execute on dw_order_aggregation to public;
