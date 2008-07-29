/******************/
/* Package Header */
/******************/
create or replace package bds_atllad23_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad23_flatten
    Owner   : bds_app
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD23 - Stock Intransit (CTLZOU_INTRANSIT_MFANZ)

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
   procedure execute(par_action in varchar2, par_werks in varchar2);

end bds_atllad23_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad23_flatten as

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
   procedure lads_lock(par_werks in varchar2);
   procedure bds_flatten(par_werks in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_werks in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_werks);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_werks);
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
         raise_application_error(-20000, 'bds_atllad23_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_werks in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* BDS record definitions
      /*-*/
      rcd_bds_intransit_header bds_intransit_header%rowtype;
      rcd_bds_intransit_detail bds_intransit_detail%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_int_stk_hdr is
         select t01.werks as werks,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.berid as berid
           from lads_int_stk_hdr t01
          where t01.werks = par_werks;
      rcd_lads_int_stk_hdr csr_lads_int_stk_hdr%rowtype;

      cursor csr_lads_int_stk_det is
         select t01.werks as werks,
                t01.detseq as detseq,
                t01.burks as burks,
                t01.clf01 as clf01,
                t01.lifex as lifex,
                t01.vgbel as vgbel,
                t01.vend as vend,
                t01.tknum as tknum,
                t01.vbeln as vbeln,
                t01.werks1 as werks1,
                t01.logort1 as logort1,
                t01.werks2 as werks2,
                t01.lgort as lgort,
                t01.werks3 as werks3,
                t01.aedat as aedat,
                t01.zardte as zardte,
                t01.verab as verab,
                t01.charg as charg,
                t01.atwrt as atwrt,
                t01.vsbed as vsbed,
                t01.tdlnr as tdlnr,
                t01.trail as trail,
                t01.matnr as matnr,
                t01.lfimg as lfimg,
                t01.meins as meins,
                t01.insmk as insmk,
                t01.bsart as bsart,
                t01.exidv2 as exidv2,
                t01.inhalt as inhalt,
                t01.exti1 as exti1,
                t01.signi as signi,
                t01.record_nb as record_nb,
                t01.record_cnt as record_cnt,
                t01.time as time
           from lads_int_stk_det t01
          where t01.werks = rcd_lads_int_stk_hdr.werks;
      rcd_lads_int_stk_det csr_lads_int_stk_det%rowtype;

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
      delete from bds_intransit_detail where plant_code = par_werks;

      /*-*/
      /* Retrieve the LADS header
      /*-*/
      open csr_lads_int_stk_hdr;
      fetch csr_lads_int_stk_hdr into rcd_lads_int_stk_hdr;
      if csr_lads_int_stk_hdr%notfound then
         raise_application_error(-20000, 'LADS Header row not found');
      end if;
      close csr_lads_int_stk_hdr;

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_intransit_header.plant_code := rcd_lads_int_stk_hdr.werks;
      rcd_bds_intransit_header.sap_idoc_name := rcd_lads_int_stk_hdr.idoc_name;
      rcd_bds_intransit_header.sap_idoc_number := rcd_lads_int_stk_hdr.idoc_number;
      rcd_bds_intransit_header.sap_idoc_timestamp := rcd_lads_int_stk_hdr.idoc_timestamp;
      rcd_bds_intransit_header.bds_lads_date := rcd_lads_int_stk_hdr.lads_date;
      rcd_bds_intransit_header.bds_lads_status := rcd_lads_int_stk_hdr.lads_status;
      rcd_bds_intransit_header.target_planning_area := rcd_lads_int_stk_hdr.berid;

      /*-*/
      /* Update the BDS header
      /*-*/
      update bds_intransit_header
         set sap_idoc_name = rcd_bds_intransit_header.sap_idoc_name,
             sap_idoc_number = rcd_bds_intransit_header.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_intransit_header.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_intransit_header.bds_lads_date,
             bds_lads_status = rcd_bds_intransit_header.bds_lads_status,
             target_planning_area = rcd_bds_intransit_header.target_planning_area
         where plant_code = rcd_bds_intransit_header.plant_code;
      if sql%notfound then
         insert into bds_intransit_header
            (plant_code,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             target_planning_area)
             values(rcd_bds_intransit_header.plant_code,
                    rcd_bds_intransit_header.sap_idoc_name,
                    rcd_bds_intransit_header.sap_idoc_number,
                    rcd_bds_intransit_header.sap_idoc_timestamp,
                    rcd_bds_intransit_header.bds_lads_date,
                    rcd_bds_intransit_header.bds_lads_status,
                    rcd_bds_intransit_header.target_planning_area);
      end if;

      /*-*/
      /* Process the LADS child
      /*-*/
      open csr_lads_int_stk_det;
      loop
         fetch csr_lads_int_stk_det into rcd_lads_int_stk_det;
         if csr_lads_int_stk_det%notfound then
            exit;
         end if;

         /*-*/
         /* Set the BDS child values
         /*-*/
         rcd_bds_intransit_detail.plant_code := rcd_lads_int_stk_det.werks;
         rcd_bds_intransit_detail.detseq := rcd_lads_int_stk_det.detseq;
         rcd_bds_intransit_detail.company_code := rcd_lads_int_stk_det.burks;
         rcd_bds_intransit_detail.business_segment_code := rcd_lads_int_stk_det.clf01;
         rcd_bds_intransit_detail.cnn_number := rcd_lads_int_stk_det.lifex;
         rcd_bds_intransit_detail.purch_order_number := rcd_lads_int_stk_det.vgbel;
         rcd_bds_intransit_detail.vendor_code := rcd_lads_int_stk_det.vend;
         rcd_bds_intransit_detail.shipment_number := rcd_lads_int_stk_det.tknum;
         rcd_bds_intransit_detail.inbound_delivery_number := rcd_lads_int_stk_det.vbeln;
         rcd_bds_intransit_detail.source_plant_code := rcd_lads_int_stk_det.werks1;
         rcd_bds_intransit_detail.source_storage_location_code := rcd_lads_int_stk_det.logort1;
         rcd_bds_intransit_detail.shipping_plant_code := rcd_lads_int_stk_det.werks2;
         rcd_bds_intransit_detail.target_storage_location_code := rcd_lads_int_stk_det.lgort;
         rcd_bds_intransit_detail.target_mrp_plant_code := rcd_lads_int_stk_det.werks3;
         rcd_bds_intransit_detail.shipping_date := rcd_lads_int_stk_det.aedat;
         rcd_bds_intransit_detail.arrival_date := rcd_lads_int_stk_det.zardte;
         rcd_bds_intransit_detail.maturation_date := rcd_lads_int_stk_det.verab;
         rcd_bds_intransit_detail.batch_number := rcd_lads_int_stk_det.charg;
         rcd_bds_intransit_detail.best_before_date := rcd_lads_int_stk_det.atwrt;
         rcd_bds_intransit_detail.transportation_model_code := rcd_lads_int_stk_det.vsbed;
         rcd_bds_intransit_detail.forward_agent_code := rcd_lads_int_stk_det.tdlnr;
         rcd_bds_intransit_detail.forward_agent_trailer_number := rcd_lads_int_stk_det.trail;
         rcd_bds_intransit_detail.material_code := rcd_lads_int_stk_det.matnr;
         rcd_bds_intransit_detail.quantity := rcd_lads_int_stk_det.lfimg;
         rcd_bds_intransit_detail.uom_code := rcd_lads_int_stk_det.meins;
         rcd_bds_intransit_detail.stock_type_code := rcd_lads_int_stk_det.insmk;
         rcd_bds_intransit_detail.order_type_code := rcd_lads_int_stk_det.bsart;
         rcd_bds_intransit_detail.container_number := rcd_lads_int_stk_det.exidv2;
         rcd_bds_intransit_detail.seal_number := rcd_lads_int_stk_det.inhalt;
         rcd_bds_intransit_detail.vessel_name := rcd_lads_int_stk_det.exti1;
         rcd_bds_intransit_detail.voyage := rcd_lads_int_stk_det.signi;
         rcd_bds_intransit_detail.record_sequence := rcd_lads_int_stk_det.record_nb;
         rcd_bds_intransit_detail.record_count := rcd_lads_int_stk_det.record_cnt;
         rcd_bds_intransit_detail.record_timestamp := rcd_lads_int_stk_det.time;

         /*-*/
         /* Insert the child row
         /*-*/
         insert into bds_intransit_detail
            (plant_code,
             detseq,
             company_code,
             business_segment_code,
             cnn_number,
             purch_order_number,
             vendor_code,
             shipment_number,
             inbound_delivery_number,
             source_plant_code,
             source_storage_location_code,
             shipping_plant_code,
             target_storage_location_code,
             target_mrp_plant_code,
             shipping_date,
             arrival_date,
             maturation_date,
             batch_number,
             best_before_date,
             transportation_model_code,
             forward_agent_code,
             forward_agent_trailer_number,
             material_code,
             quantity,
             uom_code,
             stock_type_code,
             order_type_code,
             container_number,
             seal_number,
             vessel_name,
             voyage,
             record_sequence,
             record_count,
             record_timestamp)
             values(rcd_bds_intransit_detail.plant_code,
                    rcd_bds_intransit_detail.detseq,
                    rcd_bds_intransit_detail.company_code,
                    rcd_bds_intransit_detail.business_segment_code,
                    rcd_bds_intransit_detail.cnn_number,
                    rcd_bds_intransit_detail.purch_order_number,
                    rcd_bds_intransit_detail.vendor_code,
                    rcd_bds_intransit_detail.shipment_number,
                    rcd_bds_intransit_detail.inbound_delivery_number,
                    rcd_bds_intransit_detail.source_plant_code,
                    rcd_bds_intransit_detail.source_storage_location_code,
                    rcd_bds_intransit_detail.shipping_plant_code,
                    rcd_bds_intransit_detail.target_storage_location_code,
                    rcd_bds_intransit_detail.target_mrp_plant_code,
                    rcd_bds_intransit_detail.shipping_date,
                    rcd_bds_intransit_detail.arrival_date,
                    rcd_bds_intransit_detail.maturation_date,
                    rcd_bds_intransit_detail.batch_number,
                    rcd_bds_intransit_detail.best_before_date,
                    rcd_bds_intransit_detail.transportation_model_code,
                    rcd_bds_intransit_detail.forward_agent_code,
                    rcd_bds_intransit_detail.forward_agent_trailer_number,
                    rcd_bds_intransit_detail.material_code,
                    rcd_bds_intransit_detail.quantity,
                    rcd_bds_intransit_detail.uom_code,
                    rcd_bds_intransit_detail.stock_type_code,
                    rcd_bds_intransit_detail.order_type_code,
                    rcd_bds_intransit_detail.container_number,
                    rcd_bds_intransit_detail.seal_number,
                    rcd_bds_intransit_detail.vessel_name,
                    rcd_bds_intransit_detail.voyage,
                    rcd_bds_intransit_detail.record_sequence,
                    rcd_bds_intransit_detail.record_count,
                    rcd_bds_intransit_detail.record_timestamp);

      end loop;
      close csr_lads_int_stk_det;

      /*-*/
      /* Perform exclusion processing
      /*-*/
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/
      update lads_int_stk_hdr
         set lads_flattened = var_flattened
         where werks = par_werks;

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
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'WERKS: ' || par_werks || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_werks in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_int_stk_hdr t01
          where t01.werks = par_werks
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
         bds_flatten(rcd_lock.werks);

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
         select t01.werks
           from lads_int_stk_hdr t01
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

         lads_lock(rcd_flatten.werks);

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
      bds_table.truncate('bds_intransit_detail');
      bds_table.truncate('bds_intransit_header');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_int_stk_hdr
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

end bds_atllad23_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad23_flatten for bds_app.bds_atllad23_flatten;
grant execute on bds_atllad23_flatten to lics_app;
grant execute on bds_atllad23_flatten to lads_app;