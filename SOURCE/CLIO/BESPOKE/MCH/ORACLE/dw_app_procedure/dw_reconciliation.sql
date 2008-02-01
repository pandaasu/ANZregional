/******************/
/* Package Header */
/******************/
create or replace package dw_reconciliation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Object : dw_reconciliation
    Owner  : dw_app

    Description
    -----------
    Dimensional Data Store - Reconciliation

    This package contain the reconciliation functions/procedures for the invoice
    summary and invoice detail data. The package exposes the following methods:

    RECONCILE_SALES
    ---------------
    This function performs the sales reconciliation. The following parameters are
    required:

       PAR_FKDAT (Creation date string in format YYYYMMDD)

       The creation date (format YYYYMMDD) for which reconciliation is required.

       PAR_BUKRS (SAP company code)

       The SAP company code for which reconciliation is required.

       PAR_MESSAGE (Output message)

       Output parameter that will contain any message information.

       RETURN (Return status)

       The return value for the function. Values are:
          *OK - Reconciliation was successful.
          *VARIANCE - Reconciliation does not balance.
          *SUM_ONLY - Only sales summary was received
          *TRN_ONLY - Only sales transactions were received 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/01   Steve Gregan   Created
    2006/05   Steve Gregan   Added order aggregation for non_invoice days
    2007/01   Steve Gregan   Changed check_sales function to include warning
    2007/04   Steve Gregan   Included company code parameter

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function reconcile_sales(par_fkdat in varchar2, par_bukrs in varchar2, par_message out varchar2) return varchar2;
   function check_sales(par_message out varchar2, par_warning out varchar2, par_today out varchar2) return varchar2;
   procedure sales_status(par_company_code in varchar2, par_date out date, par_message out varchar2);
   procedure inventory_status(par_company_code in varchar2, par_date out date, par_message out varchar2);

end dw_reconciliation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_reconciliation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************/
   /* This function performs the reconcile sales routine */
   /******************************************************/
   function reconcile_sales(par_fkdat in varchar2,
                            par_bukrs in varchar2,
                            par_message out varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local constants
      /*-*/
      con_trn_count constant varchar2(32) := 'DW_SALES_TRAN_COUNT_VARIANCE';
      con_trn_value constant varchar2(32) := 'DW_SALES_TRAN_VALUE_VARIANCE';

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(32);
      var_summary boolean;
      var_detail boolean;
      var_trn_count number;
      var_trn_value number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_summary is
         select t2.znumiv as znumiv,
                t2.znumps as znumps,
                t2.netwr as netwr
           from lads_inv_sum_hdr t1,
                (select t21.fkdat as fkdat,
                        t21.bukrs as bukrs,
                        sum(t21.znumiv) as znumiv,
                        sum(t21.znumps) as znumps,
                        sum(t21.netwr) as netwr
                   from lads_inv_sum_det t21
                  where t21.fkdat = par_fkdat
                    and t21.bukrs = par_bukrs
                  group by t21.fkdat,
                           t21.bukrs) t2
          where t1.fkdat = t2.fkdat(+)
            and t1.bukrs = t2.bukrs(+)
            and t1.fkdat = par_fkdat
            and t1.bukrs = par_bukrs;
      rcd_summary csr_summary%rowtype;

      cursor csr_detail is
         select t1.trn_count as trn_count,
                t2.lin_count as lin_count,
                t3.trn_value as trn_value
           from (select t12.datum as datum,
                        t13.orgid as orgid,
                        count(*) as trn_count
                   from lads_inv_hdr t11,
                        lads_inv_dat t12,
                        lads_inv_org t13
                  where t11.belnr = t12.belnr
                    and t11.belnr = t13.belnr
                    and t12.iddat = '015'
                    and t12.datum = par_fkdat
                    and t13.qualf = '008'
                    and t13.orgid = par_bukrs
                  group by t12.datum,
                           t13.orgid) t1,
                (select t22.datum as datum,
                        t23.orgid as orgid,
                        count(*) as lin_count
                   from lads_inv_hdr t21,
                        lads_inv_dat t22,
                        lads_inv_org t23,
                        lads_inv_gen t24
                  where t21.belnr = t22.belnr
                    and t21.belnr = t23.belnr
                    and t21.belnr = t24.belnr
                    and t22.iddat = '015'
                    and t22.datum = par_fkdat
                    and t23.qualf = '008'
                    and t23.orgid = par_bukrs
                  group by t22.datum,
                           t23.orgid) t2,
                (select t32.datum as datum,
                        t33.orgid as orgid,
                        sum(decode(sign(instr(t34.summe,'-',1,1)),1,-1,1) * trim('-' from t34.summe)) as trn_value
                   from lads_inv_hdr t31,
                        lads_inv_dat t32,
                        lads_inv_org t33,
                        lads_inv_smy t34
                  where t31.belnr = t32.belnr
                    and t31.belnr = t33.belnr
                    and t31.belnr = t34.belnr
                    and t32.iddat = '015'
                    and t32.datum = par_fkdat
                    and t33.qualf = '008'
                    and t33.orgid = par_bukrs
                    and t34.sumid = '010'
                  group by t32.datum,
                           t33.orgid) t3
          where t1.datum = t2.datum(+)
            and t1.orgid = t2.orgid(+)
            and t1.datum = t3.datum(+)
            and t1.orgid = t3.orgid(+);
      rcd_detail csr_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return variables
      /*-*/
      var_return := '*OK';

      /*-*/
      /* Retrieve the variance count
      /*-*/
      begin
         var_trn_count := to_number(nvl(lics_setting_configuration.retrieve_setting(con_trn_count, par_bukrs),'0'));
      exception
         when others then
            var_trn_count := 0;
      end;

      /*-*/
      /* Retrieve the variance value
      /*-*/
      begin
         var_trn_value := to_number(nvl(lics_setting_configuration.retrieve_setting(con_trn_value, par_bukrs),'0'));
      exception
         when others then
            var_trn_value := 0;
      end;

      /*-*/
      /* Retrieve the sales reconciliation summary
      /*-*/
      var_summary := false;
      open csr_summary;
      fetch csr_summary into rcd_summary;
      if csr_summary%found then
         var_summary := true;
      end if;
      close csr_summary;

      /*-*/
      /* Retrieve the sales reconciliation detail
      /*-*/
      var_detail := false;
      open csr_detail;
      fetch csr_detail into rcd_detail;
      if csr_detail%found then
         var_detail := true;
      end if;
      close csr_detail;

      /*-*/
      /* Summary but NO detail
      /*-*/
      if var_summary = true and
         var_detail = false then
         var_return := '*SUM_ONLY';
         par_message := 'Invoice summary (YES) Invoices (NO) for Date(' || par_fkdat || ') Company(' || par_bukrs || ')' ||
                        ' Summary(headers=' || to_char(rcd_summary.znumiv) || ',lines=' || to_char(rcd_summary.znumps) || ',value=' || to_char(rcd_summary.netwr) || ')';
      end if;

      /*-*/
      /* Detail but NO summary
      /*-*/
      if var_detail = true and
         var_summary = false then
         var_return := '*TRN_ONLY';
         par_message := 'Invoice summary (NO) Invoices (YES) for Date(' || par_fkdat || ') Company(' || par_bukrs || ')' ||
                        ' Invoice(headers=' || to_char(rcd_detail.trn_count) || ',lines=' || to_char(rcd_detail.lin_count) || ',value=' || to_char(rcd_detail.trn_value) || ')';
      end if;

      /*-*/
      /* Variance between the summary and the detail
      /*-*/
      if var_summary = true and
         var_detail = true then
         if rcd_summary.znumiv != rcd_detail.trn_count or
            rcd_summary.znumps != rcd_detail.lin_count or
            rcd_summary.netwr != rcd_detail.trn_value then
            if abs(rcd_summary.znumiv - rcd_detail.trn_count) <= var_trn_count and
               abs(rcd_summary.netwr - rcd_detail.trn_value) <= var_trn_value then
               var_return := '*VAR_ACCEPT';
               par_message := 'Acceptable Variance - Invoice summary does not balance for Date(' || par_fkdat || ') Company(' || par_bukrs || ') -' ||
                              ' Summary(headers=' || to_char(rcd_summary.znumiv) || ',lines=' || to_char(rcd_summary.znumps) || ',value=' || to_char(rcd_summary.netwr) || ')' ||
                              ' Invoice(headers=' || to_char(rcd_detail.trn_count) || ',lines=' || to_char(rcd_detail.lin_count) || ',value=' || to_char(rcd_detail.trn_value) || ')';
            else
               var_return := '*VAR_FATAL';
               par_message := 'Fatal Variance - Invoice summary does not balance for Date(' || par_fkdat || ') Company(' || par_bukrs || ') -' ||
                              ' Summary(headers=' || to_char(rcd_summary.znumiv) || ',lines=' || to_char(rcd_summary.znumps) || ',value=' || to_char(rcd_summary.netwr) || ')' ||
                              ' Invoice(headers=' || to_char(rcd_detail.trn_count) || ',lines=' || to_char(rcd_detail.lin_count) || ',value=' || to_char(rcd_detail.trn_value) || ')';
            end if;
         end if;
      end if;

      /*-*/
      /* Return the result
      /*-*/
      return var_return;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_RECONCILIATION - RECONCILE_SALES - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end reconcile_sales;

   /**************************************************/
   /* This function performs the check sales routine */
   /**************************************************/
   function check_sales(par_message out varchar2, par_warning out varchar2, par_today out varchar2) return varchar2 is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(32);
      var_message varchar2(2000);
      var_warning varchar2(2000);
      var_summary boolean;
      var_detail boolean;
      var_day number;
      var_check varchar2(256);

      /*-*/
      /* Local constants
      /*-*/
      con_chk_group constant varchar2(32) := 'DAILY_SALES_CHECKER';
      con_ord_alt_group constant varchar2(32) := 'DW_ALERT';
      con_ord_alt_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_ord_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ord_ema_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_ord_tri_group constant varchar2(32) := 'DW_JOB_GROUP';
      con_ord_tri_code constant varchar2(32) := 'ORDER_AGGREGATION';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select sap_company_code as sap_company_code
           from company t1;
      rcd_company csr_company%rowtype;

      cursor csr_summary is
         select 'x' as sum_found
           from lads_inv_sum_hdr t1
          where t1.fkdat = to_char(sysdate-1,'yyyymmdd')
            and t1.bukrs = rcd_company.sap_company_code;
      rcd_summary csr_summary%rowtype;

      cursor csr_detail is
         select max('x') as det_found
           from lads_inv_hdr t21,
                lads_inv_dat t22,
                lads_inv_org t23
          where t21.belnr = t22.belnr
            and t21.belnr = t23.belnr
            and t22.iddat = '015'
            and t22.datum = to_char(sysdate-1,'yyyymmdd')
            and t23.qualf = '008'
            and t23.orgid = rcd_company.sap_company_code;
      rcd_detail csr_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the return variables
      /*-*/
      var_return := '*NR';
      var_message := null;
      var_warning := null;
      par_today := '*NR';

      /*-*/
      /* Retrieve the previous day number
      /* **note** Day 1 = Sunday
      /*-*/
      var_day := to_char(to_number(to_char(sysdate-1,'d')),'FM0');
      if var_day = 1 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_SUNDAY');
      elsif var_day = 2 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_MONDAY');
      elsif var_day = 3 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_TUESDAY');
      elsif var_day = 4 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_WEDNESDAY');
      elsif var_day = 5 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_THURSDAY');
      elsif var_day = 6 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_FRIDAY');
      elsif var_day = 7 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_SATURDAY');
      end if;
      if upper(trim(var_check)) = 'Y' then

         /*-*/
         /* Set the return variable
         /*-*/
         var_return := '*OK';

         /*-*/
         /* Retrieve the company data
         /*-*/
         open csr_company;
         loop
            fetch csr_company into rcd_company;
            if csr_company%notfound then
               exit;
            end if;

            /*-*/
            /* Check for sales summary
            /*-*/
            var_summary := false;
            open csr_summary;
            fetch csr_summary into rcd_summary;
            if csr_summary%found and
               rcd_summary.sum_found = 'x' then
               var_summary := true;
            end if;
            close csr_summary;

            /*-*/
            /* Check for sales detail (invoice)
            /*-*/
            var_detail := false;
            open csr_detail;
            fetch csr_detail into rcd_detail;
            if csr_detail%found and
               rcd_detail.det_found = 'x' then
               var_detail := true;
            end if;
            close csr_detail;

            /*-*/
            /* Summary (NO) and Detail (YES)
            /* **notes** Summary has not arrived but detail has arrived
            /*-*/
            if var_summary = false and
               var_detail = true then
               var_return := '*ERROR';
               if not(var_message is null) then
                  var_message := var_message || ',';
               end if;
               var_message := var_message || rcd_company.sap_company_code;
            end if;

            /*-*/
            /* Summary (NO) and Detail (NO)
            /* **notes** Summary and detail has not arrived
            /*-*/
            if var_summary = false and
               var_detail = false then
               var_return := '*ERROR';
               if not(var_warning is null) then
                  var_warning := var_warning || ',';
               end if;
               var_warning := var_warning || rcd_company.sap_company_code;
            end if;

         end loop;
         close csr_company;

         /*-*/
         /* Set the return parameter
         /*-*/
         if var_return != '*OK' then
            if not(var_message is null) then
               par_message := 'Invoice summary has not arrived for Date(' || to_char(sysdate-1,'yyyy/mm/dd') || ') Companies(' || var_message || ')';
            end if;
            if not(var_warning is null) then
               par_warning := 'Invoice summary and detail have not arrived for Date(' || to_char(sysdate-1,'yyyy/mm/dd') || ') Companies(' || var_warning || ')';
            end if;
         end if;

      else

         /*-*/
         /* Retrieve the company data
         /*-*/
         open csr_company;
         loop
            fetch csr_company into rcd_company;
            if csr_company%notfound then
               exit;
            end if;

            /*-*/
            /* Trigger the order aggregation for each company
            /*-*/
            lics_trigger_loader.execute('DW Order Aggregation',
                                        'dw_order_aggregation.execute(''' || to_char(sysdate-1,'yyyymmdd') || ''',''' || rcd_company.sap_company_code || ''')',
                                        lics_setting_configuration.retrieve_setting(con_ord_alt_group, con_ord_alt_code),
                                        lics_setting_configuration.retrieve_setting(con_ord_ema_group, con_ord_ema_code),
                                        lics_setting_configuration.retrieve_setting(con_ord_tri_group, con_ord_tri_code));

         end loop;
         close csr_company;

      end if;

      /*-*/
      /* Retrieve the current day number
      /* **note** Day 1 = Sunday
      /*-*/
      var_day := to_char(to_number(to_char(sysdate,'d')),'FM0');
      if var_day = 1 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_SUNDAY');
      elsif var_day = 2 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_MONDAY');
      elsif var_day = 3 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_TUESDAY');
      elsif var_day = 4 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_WEDNESDAY');
      elsif var_day = 5 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_THURSDAY');
      elsif var_day = 6 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_FRIDAY');
      elsif var_day = 7 then
         var_check := lics_setting_configuration.retrieve_setting(con_chk_group, 'CHECK_SATURDAY');
      end if;
      if upper(trim(var_check)) = 'Y' then
         par_today := '*OK';
      end if;

      /*-*/
      /* Return the result
      /*-*/
      return var_return;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_RECONCILIATION - CHECK_SALES - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end check_sales;

   /****************************************************/
   /* This procedure performs the sales status routine */
   /****************************************************/
   procedure sales_status(par_company_code in varchar2, par_date out date, par_message out varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_date is
         select t1.fkdat as fkdat
           from lads_inv_sum_hdr t1
          where t1.bukrs = par_company_code
          order by t1.fkdat desc;
      rcd_date csr_date%rowtype;

      cursor csr_company is
         select t1.*
           from lads_inv_sum_hdr t1
          where t1.bukrs = par_company_code
            and t1.fkdat = rcd_date.fkdat
            and t1.lads_status = '2';
      rcd_company csr_company%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_message := null;

      /*-*/
      /* Retrieve the latest sales date
      /*-*/
      var_found := false;
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%found and
         not(rcd_date.fkdat is null) then

         /*-*/
         /* Set the found indicator
         /*-*/
         var_found := true;

         /*-*/
         /* Retrieve the variance company
         /*-*/
         open csr_company;
         fetch csr_company into rcd_company;
         if csr_company%found then
            var_message := rcd_company.bukrs;
         end if;
         close csr_company;

      end if;
      close csr_date;

      /*-*/
      /* Set the return parameter
      /*-*/
      if var_found = false then
         par_date := sysdate;
         par_message := 'Sales Status: NO SALES EXIST';
      else
         par_date := to_date(rcd_date.fkdat,'yyyymmdd');
         if var_message is null then
            par_message := 'Sales Date: ' || to_char(to_date(rcd_date.fkdat,'yyyymmdd'),'yyyy/mm/dd') || ' Status: OK';
         else
            par_message := 'Sales Date: ' || to_char(to_date(rcd_date.fkdat,'yyyymmdd'),'yyyy/mm/dd') || ' Status: ERRORS - Company(' || var_message || ')';
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_RECONCILIATION - SALES_STATUS - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_status;

   /********************************************************/
   /* This procedure performs the inventory status routine */
   /********************************************************/
   procedure inventory_status(par_company_code in varchar2, par_date out date, par_message out varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

      /*-*/
      /* Local definitions
      /*-*/
      var_date date;
      var_message varchar2(4000);
      var_found boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_date is
         select t1.budat as budat
           from lads_stk_bal_hdr t1
          where t1.bukrs = par_company_code
          order by t1.budat desc;
      rcd_date csr_date%rowtype;

      cursor csr_plant is
         select t1.werks as werks
           from lads_stk_bal_hdr t1
          where t1.bukrs = par_company_code
            and t1.budat = rcd_date.budat
            and t1.lads_status = '2'
          order by t1.werks;
      rcd_plant csr_plant%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message
      /*-*/
      var_message := null;

      /*-*/
      /* Retrieve the latest inventory date
      /*-*/
      var_found := false;
      open csr_date;
      fetch csr_date into rcd_date;
      if csr_date%found and
         not(rcd_date.budat is null) then

         /*-*/
         /* Set the found indicator
         /*-*/
         var_found := true;

         /*-*/
         /* Retrieve the plant data
         /*-*/
         open csr_plant;
         loop
            fetch csr_plant into rcd_plant;
            if csr_plant%notfound then
               exit;
            end if;
            if not(var_message is null) then
               var_message := var_message || ',';
            end if;
            var_message := var_message || rcd_plant.werks;
         end loop;
         close csr_plant;

      end if;
      close csr_date;

      /*-*/
      /* Set the return parameter
      /*-*/
      if var_found = false then
         par_date := sysdate;
         par_message := 'Inventory Status: NO INVENTORY EXISTS';
      else
         par_date := to_date(rcd_date.budat,'yyyymmdd');
         if var_message is null then
            par_message := 'Inventory Date: ' || to_char(to_date(rcd_date.budat,'yyyymmdd'),'yyyy/mm/dd') || ' Status: OK';
         else
            par_message := 'Inventory Date: ' || to_char(to_date(rcd_date.budat,'yyyymmdd'),'yyyy/mm/dd') || ' Status: ERRORS - Plants(' || var_message || ')';
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_RECONCILIATION - INVENTORY_STATUS - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end inventory_status;

end dw_reconciliation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_reconciliation for dw_app.dw_reconciliation;
grant execute on dw_reconciliation to public;
