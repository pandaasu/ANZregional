/******************/
/* Package Header */
/******************/
create or replace package bds_atllad02_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad02_flatten
    Owner   : bds_app
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD02 - Stock Balance (ZOWMIVMX)

    PARAMETERS
      1. PAR_ACTION [MANDATORY]
         *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
         *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
         *REFRESH             - process all unflattened LADS records
         *REBUILD             - process all LADS records - truncates BDS table(s) first
                              - RECOMMEND stopping ICS jobs prior to execution

    NOTES
      1. This package must raise an exception on failure to exclude database activity from parent commit

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_bukrs in varchar2, par_werks in varchar2, par_lgort in varchar2, par_budat in varchar2, par_timlo in varchar2);

end bds_atllad02_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad02_flatten as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   snapshot_exception exception;
   pragma exception_init(application_exception, -20000);
   pragma exception_init(snapshot_exception, -1555);

   /*-*/
   /* Private declarations
   /*-*/
   procedure lads_lock(par_bukrs in varchar2, par_werks in varchar2, par_lgort in varchar2, par_budat in varchar2, par_timlo in varchar2);
   procedure bds_flatten(par_bukrs in varchar2, par_werks in varchar2, par_lgort in varchar2, par_budat in varchar2, par_timlo in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_bukrs in varchar2, par_werks in varchar2, par_lgort in varchar2, par_budat in varchar2, par_timlo in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_bukrs, par_werks, par_lgort, par_budat, par_timlo);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_bukrs, par_werks, par_lgort, par_budat, par_timlo);
        when '*REFRESH' then bds_refresh;
        when '*REBUILD' then bds_rebuild;
        else raise_application_error(-20000, 'Action parameter must be *DOCUMENT, *DOCUMENT_OVERRIDE, *REFRESH or *REBUILD');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'bds_atllad02_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_bukrs in varchar2, par_werks in varchar2, par_lgort in varchar2, par_budat in varchar2, par_timlo in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* BDS record definitions
      /*-*/
      rcd_bds_stock_header bds_stock_header%rowtype;
      rcd_bds_stock_detail bds_stock_detail%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_stk_bal_hdr is
         select t01.bukrs as bukrs,
                t01.werks as werks,
                t01.lgort as lgort,
                t01.budat as budat,
                t01.timlo as timlo,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.credat as credat,
                t01.cretim as cretim,
                t01.vbund as vbund,
                t01.mblnr as mblnr
           from lads_stk_bal_hdr t01
          where t01.bukrs = par_bukrs
            and t01.werks = par_werks
            and t01.lgort = par_lgort
            and t01.budat = par_budat
            and t01.timlo = par_timlo;
      rcd_lads_stk_bal_hdr csr_lads_stk_bal_hdr%rowtype;

      cursor csr_lads_stk_bal_det is
         select * from (
            select t01.bukrs as bukrs,
                   t01.werks as werks,
                   t01.lgort as lgort,
                   t01.budat as budat,
                   t01.timlo as timlo,
                   t01.detseq as detseq,
                   nvl(t01.matnr,'*NONE') as matnr,
                   t01.charg as charg,
                   t01.sobkz as sobkz,
                   t01.menga as menga,
                   t01.altme as altme,
                   t01.vfdat as vfdat,
                   t01.kunnr as kunnr,
                   t01.umlgo as umlgo,
                   t01.insmk as insmk,
                   rank() over (partition by nvl(t01.matnr,'*NONE')
                                    order by t01.detseq) as rnkseq
              from lads_stk_bal_det t01
             where t01.bukrs = rcd_lads_stk_bal_hdr.bukrs
               and t01.werks = rcd_lads_stk_bal_hdr.werks
               and t01.lgort = rcd_lads_stk_bal_hdr.lgort
               and t01.budat = rcd_lads_stk_bal_hdr.budat
               and t01.timlo = rcd_lads_stk_bal_hdr.timlo)
         where rnkseq = 1;
      rcd_lads_stk_bal_det csr_lads_stk_bal_det%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_excluded := false;
      var_flattened := '1';

      /*-*/
      /* Perform BDS Flattening Logic
      /* **note** - assumes that a lock is held in a parent procedure
      /*          - assumes commit/rollback will be issued in a parent procedure
      /*-*/

      /*-*/
      /* Delete the BDS table child data
      /*-*/
      delete from bds_stock_detail where company_code = par_bukrs
                                     and plant_code = par_werks
                                     and storage_location_code = par_lgort
                                     and stock_balance_date = par_budat
                                     and stock_balance_time = par_timlo;

      /*-*/
      /* Retrieve the LADS stock balance header
      /*-*/
      open csr_lads_stk_bal_hdr;
      fetch csr_lads_stk_bal_hdr into rcd_lads_stk_bal_hdr;
      if csr_lads_stk_bal_hdr%notfound then
         raise_application_error(-20000, 'LADS Header row not found');
      end if;
      close csr_lads_stk_bal_hdr;

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_stock_header.company_code := rcd_lads_stk_bal_hdr.bukrs;
      rcd_bds_stock_header.plant_code := rcd_lads_stk_bal_hdr.werks;
      rcd_bds_stock_header.storage_location_code := rcd_lads_stk_bal_hdr.lgort;
      rcd_bds_stock_header.stock_balance_date := rcd_lads_stk_bal_hdr.budat;
      rcd_bds_stock_header.stock_balance_time := rcd_lads_stk_bal_hdr.timlo;
      rcd_bds_stock_header.sap_idoc_name := rcd_lads_stk_bal_hdr.idoc_name;
      rcd_bds_stock_header.sap_idoc_number := rcd_lads_stk_bal_hdr.idoc_number;
      rcd_bds_stock_header.sap_idoc_timestamp := rcd_lads_stk_bal_hdr.idoc_timestamp;
      rcd_bds_stock_header.bds_lads_date := rcd_lads_stk_bal_hdr.lads_date;
      rcd_bds_stock_header.bds_lads_status := rcd_lads_stk_bal_hdr.lads_status;
      rcd_bds_stock_header.create_date := rcd_lads_stk_bal_hdr.credat;
      rcd_bds_stock_header.create_time := rcd_lads_stk_bal_hdr.cretim;
      rcd_bds_stock_header.company_identifier := rcd_lads_stk_bal_hdr.vbund;
      rcd_bds_stock_header.inventory_document := rcd_lads_stk_bal_hdr.mblnr;

      /*-*/
      /* Update the BDS header
      /*-*/
      update bds_stock_header
         set sap_idoc_name = rcd_bds_stock_header.sap_idoc_name,
             sap_idoc_number = rcd_bds_stock_header.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_stock_header.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_stock_header.bds_lads_date,
             bds_lads_status = rcd_bds_stock_header.bds_lads_status,
             create_date = rcd_bds_stock_header.create_date,
             create_time = rcd_bds_stock_header.create_time,
             company_identifier = rcd_bds_stock_header.company_identifier,
             inventory_document = rcd_bds_stock_header.inventory_document
         where company_code = rcd_bds_stock_header.company_code
           and plant_code = rcd_bds_stock_header.plant_code
           and storage_location_code = rcd_bds_stock_header.storage_location_code
           and stock_balance_date = rcd_bds_stock_header.stock_balance_date
           and stock_balance_time = rcd_bds_stock_header.stock_balance_time;
      if sql%notfound then
         insert into bds_stock_header
            (company_code,
             plant_code,
             storage_location_code,
             stock_balance_date,
             stock_balance_time,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             create_date,
             create_time,
             company_identifier,
             inventory_document)
             values(rcd_bds_stock_header.company_code,
                    rcd_bds_stock_header.plant_code,
                    rcd_bds_stock_header.storage_location_code,
                    rcd_bds_stock_header.stock_balance_date,
                    rcd_bds_stock_header.stock_balance_time,
                    rcd_bds_stock_header.sap_idoc_name,
                    rcd_bds_stock_header.sap_idoc_number,
                    rcd_bds_stock_header.sap_idoc_timestamp,
                    rcd_bds_stock_header.bds_lads_date,
                    rcd_bds_stock_header.bds_lads_status,
                    rcd_bds_stock_header.create_date,
                    rcd_bds_stock_header.create_time,
                    rcd_bds_stock_header.company_identifier,
                    rcd_bds_stock_header.inventory_document);
      end if;

      /*-*/
      /* Process the LADS stock balance detail
      /*-*/
      open csr_lads_stk_bal_det;
      loop
         fetch csr_lads_stk_bal_det into rcd_lads_stk_bal_det;
         if csr_lads_stk_bal_det%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_stock_detail.company_code := rcd_lads_stk_bal_det.bukrs;
         rcd_bds_stock_detail.plant_code := rcd_lads_stk_bal_det.werks;
         rcd_bds_stock_detail.storage_location_code := rcd_lads_stk_bal_det.lgort;
         rcd_bds_stock_detail.stock_balance_date := rcd_lads_stk_bal_det.budat;
         rcd_bds_stock_detail.stock_balance_time := rcd_lads_stk_bal_det.timlo;
         rcd_bds_stock_detail.material_code := rcd_lads_stk_bal_det.matnr;
         rcd_bds_stock_detail.material_batch_number := rcd_lads_stk_bal_det.charg;
         rcd_bds_stock_detail.inspection_stock_flag := rcd_lads_stk_bal_det.sobkz;
         rcd_bds_stock_detail.stock_quantity := rcd_lads_stk_bal_det.menga;
         rcd_bds_stock_detail.stock_uom_code := rcd_lads_stk_bal_det.altme;
         rcd_bds_stock_detail.stock_best_before_date := rcd_lads_stk_bal_det.vfdat;
         rcd_bds_stock_detail.consignment_cust_vend := rcd_lads_stk_bal_det.kunnr;
         rcd_bds_stock_detail.rcv_isu_storage_location_code := rcd_lads_stk_bal_det.umlgo;
         rcd_bds_stock_detail.stock_type_code := rcd_lads_stk_bal_det.insmk;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_stock_detail
            (company_code,
             plant_code,
             storage_location_code,
             stock_balance_date,
             stock_balance_time,
             material_code,
             material_batch_number,
             inspection_stock_flag,
             stock_quantity,
             stock_uom_code,
             stock_best_before_date,
             consignment_cust_vend,
             rcv_isu_storage_location_code,
             stock_type_code)
             values(rcd_bds_stock_detail.company_code,
                    rcd_bds_stock_detail.plant_code,
                    rcd_bds_stock_detail.storage_location_code,
                    rcd_bds_stock_detail.stock_balance_date,
                    rcd_bds_stock_detail.stock_balance_time,
                    rcd_bds_stock_detail.material_code,
                    rcd_bds_stock_detail.material_batch_number,
                    rcd_bds_stock_detail.inspection_stock_flag,
                    rcd_bds_stock_detail.stock_quantity,
                    rcd_bds_stock_detail.stock_uom_code,
                    rcd_bds_stock_detail.stock_best_before_date,
                    rcd_bds_stock_detail.consignment_cust_vend,
                    rcd_bds_stock_detail.rcv_isu_storage_location_code,
                    rcd_bds_stock_detail.stock_type_code);

      end loop;
      close csr_lads_stk_bal_det;

      /*-*/
      /* Perform exclusion processing
      /*-*/
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/
      update lads_stk_bal_hdr
         set lads_flattened = var_flattened
         where bukrs = par_bukrs
           and werks = par_werks
           and lgort = par_lgort
           and budat = par_budat
           and timlo = par_timlo;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'BUKRS: ' || par_bukrs || ' WERKS: ' || par_werks || ' LGORT: ' || par_lgort || ' BUDAT: ' || par_budat || ' TIMLO: ' || par_timlo || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_flatten;

   /*******************************************************************************/
   /* This procedure performs the lock routine                                    */
   /*   notes - acquires a lock on the LADS header record                         */
   /*         - uses NOWAIT, assumes if locked, LADS load will re-call flattening */
   /*         - issues commit to release lock                                     */
   /*         - used when manually executing flattening                           */
   /*******************************************************************************/
   procedure lads_lock(par_bukrs in varchar2, par_werks in varchar2, par_lgort in varchar2, par_budat in varchar2, par_timlo in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_stk_bal_hdr t01
          where t01.bukrs = par_bukrs
            and t01.werks = par_werks
            and t01.lgort = par_lgort
            and t01.budat = par_budat
            and t01.timlo = par_timlo
            for update nowait;
      rcd_lock csr_lock%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Attempt to lock the header row
      /* notes - must still exist
      /*         must not be locked
      /*-*/
      var_available := true;
      begin
         open csr_lock;
         fetch csr_lock into rcd_lock;
         if csr_lock%notfound then
            var_available := false;
         end if;
      exception
         when others then
            var_available := false;
      end;
      /*-*/
      if csr_lock%isopen then
         close csr_lock;
      end if;
      /*-*/
      if (var_available) then

         /*-*/
         /* Flatten
         /*-*/
         bds_flatten(rcd_lock.bukrs, rcd_lock.werks, rcd_lock.lgort, rcd_lock.budat, rcd_lock.timlo);

         /*-*/
         /* Commit
         /*-*/
         commit;

      else
         rollback;
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
         /* Rollback database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lads_lock;

   /******************************************************************************************/
   /* This procedure performs the refresh routine                                            */
   /*   notes - processes all LADS records with unflattened status                           */
   /******************************************************************************************/
   procedure bds_refresh is

      /*-*/
      /* Local definitions
      /*-*/
      var_open boolean;
      var_exit boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_flatten is
         select t01.bukrs,
                t01.werks,
                t01.lgort,
                t01.budat,
                t01.timlo
           from lads_stk_bal_hdr t01
          where nvl(t01.lads_flattened,'0') = '0';
      rcd_flatten csr_flatten%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve document header with lads_flattened status = 0
      /* notes - cursor is reopened when snapshot to old
      /*-*/
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next document to process
         /*-*/
         loop
            if var_open = true then
               if csr_flatten%isopen then
                  close csr_flatten;
               end if;
               open csr_flatten;
               var_open := false;
            end if;
            begin
               fetch csr_flatten into rcd_flatten;
               if csr_flatten%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         /*-*/
         if var_exit = true then
            exit;
         end if;

         lads_lock(rcd_flatten.bukrs, rcd_flatten.werks, rcd_flatten.lgort, rcd_flatten.budat, rcd_flatten.timlo);

      end loop;
      close csr_flatten;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_refresh;

   /******************************************************************************************/
   /* This procedure performs the rebuild routine                                            */
   /*   notes - RECOMMEND stopping ICS jobs prior to execution                               */
   /*         - performs a truncate on the target BDS table                                  */
   /*         - updates all LADS records to unflattened status                               */
   /*         - calls bds_refresh procedure to drive processing                              */
   /******************************************************************************************/
   procedure bds_rebuild is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Truncate target BDS table(s)
      /*-*/
      bds_table.truncate('bds_stock_detail');
      bds_table.truncate('bds_stock_header');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_stk_bal_hdr
         set lads_flattened = '0';

      /*-*/
      /* Commit
      /*-*/
      commit;

      /*-*/
      /* Execute BDS_REFRESH to repopulate BDS target tables
      /*-*/
      bds_refresh;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad02_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad02_flatten for bds_app.bds_atllad02_flatten;
grant execute on bds_atllad02_flatten to lics_app;
grant execute on bds_atllad02_flatten to lads_app;