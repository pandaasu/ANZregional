create or replace package bds_atllad17_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad17_flatten
    Owner   : BDS_APP
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD17 - Bill Of Material

    PARAMETERS
      1. PAR_ACTION [MANDATORY]
         *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
         *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
         *REFRESH             - process all unflattened LADS records
         *REBUILD             - process all LADS records - truncates BDS table(s) first
                              - RECOMMEND stopping ICS jobs prior to execution

      2. PAR_STLNR [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
         Field from LADS document in LADS_MAT_BOM_HDR.STLNR

      3. PAR_STLAL [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
         Field from LADS document in LADS_MAT_BOM_HDR.STLAL

    NOTES 
      1. This package must raise an exception on failure to exclude database activity from parent commit

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/03   Steve Gregan   Created
    2007/04   Steve Gregan   Added redundant header column to detail row

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_stlal in varchar2, par_matnr in varchar2, par_werks in varchar2);

end bds_atllad17_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad17_flatten as

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
   procedure lads_lock(par_stlal in varchar2, par_matnr in varchar2, par_werks in varchar2);
   procedure bds_flatten(par_stlal in varchar2, par_matnr in varchar2, par_werks in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_stlal in varchar2, par_matnr in varchar2, par_werks in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/   
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_stlal, par_matnr, par_werks);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_stlal, par_matnr, par_werks);
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
         raise_application_error(-20000, 'BDS_ATLLAD17_FLATTEN - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_stlal in varchar2, par_matnr in varchar2, par_werks in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;
      var_det_found boolean;

      /*-*/
      /* BOM record variables
      /*-*/
      rcd_bds_bom_hdr bds_bom_hdr%rowtype;
      rcd_bds_bom_det bds_bom_det%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_bom_hdr is
         select t01.matnr as matnr,
                t01.stlal as stlal,
                t01.werks as werks,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.stlnr as stlnr,
                t01.msgfn as msgfn,
                t01.stlan as stlan,
                bds_date.bds_to_date('*START_DATE',t01.datuv) as datuv,
                bds_date.bds_to_date('*END_DATE',t01.datub) as datub,
                t01.bmeng as bmeng,
                t01.bmein as bmein,
                t01.stlst as stlst
         from lads_bom_hdr t01
         where t01.stlal = par_stlal
           and t01.matnr = par_matnr
           and t01.werks = par_werks;
      rcd_lads_bom_hdr csr_lads_bom_hdr%rowtype;

      cursor csr_lads_bom_det is
         select t01.detseq as detseq,
                t01.msgfn as msgfn,
                t01.idnrk as idnrk,
                t01.posnr as posnr,
                t01.postp as postp,
                t01.menge as menge,
                t01.meins as meins,
                bds_date.bds_to_date('*START_DATE',t01.datuv) as datuv,
                bds_date.bds_to_date('*END_DATE',t01.datub) as datub
         from lads_bom_det t01
         where t01.stlal = rcd_lads_bom_hdr.stlal
           and t01.matnr = rcd_lads_bom_hdr.matnr
           and t01.werks = rcd_lads_bom_hdr.werks;
      rcd_lads_bom_det csr_lads_bom_det%rowtype;

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
      /* Delete the existing BDS BOM data
      /*-*/
      delete bds_bom_det where bom_material_code = par_matnr
                           and bom_alternative = par_stlal
                           and bom_plant = par_werks;

      /*-*/
      /* Process LADS BOM header
      /*-*/
      open csr_lads_bom_hdr;
      fetch csr_lads_bom_hdr into rcd_lads_bom_hdr;
      if (csr_lads_bom_hdr%notfound) then
         raise_application_error(-20000, 'BOM Header cursor not found');
      end if;
      close csr_lads_bom_hdr;

      /*-*/
      /* Initialise the BDS BOM row
      /*-*/
      rcd_bds_bom_hdr.bom_material_code := rcd_lads_bom_hdr.matnr;
      rcd_bds_bom_hdr.bom_alternative := rcd_lads_bom_hdr.stlal;
      rcd_bds_bom_hdr.bom_plant := rcd_lads_bom_hdr.werks;
      rcd_bds_bom_hdr.sap_idoc_name := rcd_lads_bom_hdr.idoc_name;
      rcd_bds_bom_hdr.sap_idoc_number := rcd_lads_bom_hdr.idoc_number;
      rcd_bds_bom_hdr.sap_idoc_timestamp := rcd_lads_bom_hdr.idoc_timestamp;
      rcd_bds_bom_hdr.bds_lads_date := rcd_lads_bom_hdr.lads_date;
      rcd_bds_bom_hdr.bds_lads_status := rcd_lads_bom_hdr.lads_status;
      rcd_bds_bom_hdr.bom_number := rcd_lads_bom_hdr.stlnr;
      rcd_bds_bom_hdr.bom_msg_function := rcd_lads_bom_hdr.msgfn;
      rcd_bds_bom_hdr.bom_usage := rcd_lads_bom_hdr.stlan;
      rcd_bds_bom_hdr.bom_eff_from_date := rcd_lads_bom_hdr.datuv;
      rcd_bds_bom_hdr.bom_eff_to_date := rcd_lads_bom_hdr.datub;
      rcd_bds_bom_hdr.bom_base_qty := rcd_lads_bom_hdr.bmeng;
      rcd_bds_bom_hdr.bom_base_uom := rcd_lads_bom_hdr.bmein;
      rcd_bds_bom_hdr.bom_status := rcd_lads_bom_hdr.stlst;

      /*-*/
      /* Update/Insert the BDS BOM header row
      /*-*/
      update bds_bom_hdr
         set sap_idoc_name = rcd_bds_bom_hdr.sap_idoc_name,
             sap_idoc_number = rcd_bds_bom_hdr.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_bom_hdr.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_bom_hdr.bds_lads_date,
             bds_lads_status = rcd_bds_bom_hdr.bds_lads_status,
             bom_number = rcd_bds_bom_hdr.bom_number,
             bom_msg_function = rcd_bds_bom_hdr.bom_msg_function,
             bom_usage = rcd_bds_bom_hdr.bom_usage,
             bom_eff_from_date = rcd_bds_bom_hdr.bom_eff_from_date,
             bom_eff_to_date = rcd_bds_bom_hdr.bom_eff_to_date,
             bom_base_qty = rcd_bds_bom_hdr.bom_base_qty,
             bom_base_uom = rcd_bds_bom_hdr.bom_base_uom,
             bom_status = rcd_bds_bom_hdr.bom_status
      where bom_material_code = rcd_bds_bom_hdr.bom_material_code
        and bom_alternative = rcd_bds_bom_hdr.bom_alternative
        and bom_plant = rcd_bds_bom_hdr.bom_plant;
      if (sql%notfound) then
         insert into bds_bom_hdr
            (bom_material_code,
             bom_alternative,
             bom_plant,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             bom_number,
             bom_msg_function,
             bom_usage,
             bom_eff_from_date,
             bom_eff_to_date,
             bom_base_qty,
             bom_base_uom,
             bom_status)
          values 
            (rcd_bds_bom_hdr.bom_material_code,
             rcd_bds_bom_hdr.bom_alternative,
             rcd_bds_bom_hdr.bom_plant,
             rcd_bds_bom_hdr.sap_idoc_name,
             rcd_bds_bom_hdr.sap_idoc_number,
             rcd_bds_bom_hdr.sap_idoc_timestamp,
             rcd_bds_bom_hdr.bds_lads_date,
             rcd_bds_bom_hdr.bds_lads_status,
             rcd_bds_bom_hdr.bom_number,
             rcd_bds_bom_hdr.bom_msg_function,
             rcd_bds_bom_hdr.bom_usage,
             rcd_bds_bom_hdr.bom_eff_from_date,
             rcd_bds_bom_hdr.bom_eff_to_date,
             rcd_bds_bom_hdr.bom_base_qty,
             rcd_bds_bom_hdr.bom_base_uom,
             rcd_bds_bom_hdr.bom_status);
      end if;

      /*-*/
      /* Process LADS BOM detail
      /*-*/
      var_det_found := false;
      open csr_lads_bom_det;
      loop
         fetch csr_lads_bom_det into rcd_lads_bom_det;
         if (csr_lads_bom_det%notfound) then
            exit;
         end if;

         /*-*/
         /* Set the BDS BOM detail columns
         /*-*/
         var_det_found := true;
         rcd_bds_bom_det.bom_material_code := rcd_bds_bom_hdr.bom_material_code;
         rcd_bds_bom_det.bom_alternative := rcd_bds_bom_hdr.bom_alternative;
         rcd_bds_bom_det.bom_plant := rcd_bds_bom_hdr.bom_plant;
         rcd_bds_bom_det.item_sequence := rcd_lads_bom_det.detseq;
         rcd_bds_bom_det.item_number := rcd_lads_bom_det.posnr;
         rcd_bds_bom_det.item_msg_function := rcd_lads_bom_det.msgfn;
         rcd_bds_bom_det.item_material_code := rcd_lads_bom_det.idnrk;
         rcd_bds_bom_det.item_category := rcd_lads_bom_det.postp;
         rcd_bds_bom_det.item_base_qty := rcd_lads_bom_det.menge;
         rcd_bds_bom_det.item_base_uom := rcd_lads_bom_det.meins;
         rcd_bds_bom_det.item_eff_from_date := rcd_lads_bom_det.datuv;
         rcd_bds_bom_det.item_eff_to_date := rcd_lads_bom_det.datub;

         /*-*/
         /* Insert the BDS BOM detail row
         /*-*/
         insert into bds_bom_det
            (bom_material_code,
             bom_alternative,
             bom_plant,
             item_sequence,
             item_number,
             item_msg_function,
             item_material_code,
             item_category,
             item_base_qty,
             item_base_uom,
             item_eff_from_date,
             item_eff_to_date,
             bds_lads_date,
             bds_lads_status,
             bom_number,
             bom_msg_function,
             bom_usage,
             bom_eff_from_date,
             bom_eff_to_date,
             bom_base_qty,
             bom_base_uom,
             bom_status)
          values 
            (rcd_bds_bom_det.bom_material_code,
             rcd_bds_bom_det.bom_alternative,
             rcd_bds_bom_det.bom_plant,
             rcd_bds_bom_det.item_sequence,
             rcd_bds_bom_det.item_number,
             rcd_bds_bom_det.item_msg_function,
             rcd_bds_bom_det.item_material_code,
             rcd_bds_bom_det.item_category,
             rcd_bds_bom_det.item_base_qty,
             rcd_bds_bom_det.item_base_uom,
             rcd_bds_bom_det.item_eff_from_date,
             rcd_bds_bom_det.item_eff_to_date,
             rcd_bds_bom_hdr.bds_lads_date,
             rcd_bds_bom_hdr.bds_lads_status,
             rcd_bds_bom_hdr.bom_number,
             rcd_bds_bom_hdr.bom_msg_function,
             rcd_bds_bom_hdr.bom_usage,
             rcd_bds_bom_hdr.bom_eff_from_date,
             rcd_bds_bom_hdr.bom_eff_to_date,
             rcd_bds_bom_hdr.bom_base_qty,
             rcd_bds_bom_hdr.bom_base_uom,
             rcd_bds_bom_hdr.bom_status);

      end loop;
      close csr_lads_bom_det;

      /*-*/
      /* Insert LADS BOM detail for header only
      /*-*/
      if var_det_found = false then

         /*-*/
         /* Set the BDS BOM detail columns
         /*-*/
         rcd_bds_bom_det.bom_material_code := rcd_bds_bom_hdr.bom_material_code;
         rcd_bds_bom_det.bom_alternative := rcd_bds_bom_hdr.bom_alternative;
         rcd_bds_bom_det.bom_plant := rcd_bds_bom_hdr.bom_plant;
         rcd_bds_bom_det.item_sequence := 0;
         rcd_bds_bom_det.item_number := null;
         rcd_bds_bom_det.item_msg_function := null;
         rcd_bds_bom_det.item_material_code := null;
         rcd_bds_bom_det.item_category := null;
         rcd_bds_bom_det.item_base_qty := null;
         rcd_bds_bom_det.item_base_uom := null;
         rcd_bds_bom_det.item_eff_from_date := null;
         rcd_bds_bom_det.item_eff_to_date := null;

         /*-*/
         /* Insert the BDS BOM detail row
         /*-*/
         insert into bds_bom_det
            (bom_material_code,
             bom_alternative,
             bom_plant,
             item_sequence,
             item_number,
             item_msg_function,
             item_material_code,
             item_category,
             item_base_qty,
             item_base_uom,
             item_eff_from_date,
             item_eff_to_date,
             bds_lads_date,
             bds_lads_status,
             bom_number,
             bom_msg_function,
             bom_usage,
             bom_eff_from_date,
             bom_eff_to_date,
             bom_base_qty,
             bom_base_uom,
             bom_status)
          values 
            (rcd_bds_bom_det.bom_material_code,
             rcd_bds_bom_det.bom_alternative,
             rcd_bds_bom_det.bom_plant,
             rcd_bds_bom_det.item_sequence,
             rcd_bds_bom_det.item_number,
             rcd_bds_bom_det.item_msg_function,
             rcd_bds_bom_det.item_material_code,
             rcd_bds_bom_det.item_category,
             rcd_bds_bom_det.item_base_qty,
             rcd_bds_bom_det.item_base_uom,
             rcd_bds_bom_det.item_eff_from_date,
             rcd_bds_bom_det.item_eff_to_date,
             rcd_bds_bom_hdr.bds_lads_date,
             rcd_bds_bom_hdr.bds_lads_status,
             rcd_bds_bom_hdr.bom_number,
             rcd_bds_bom_hdr.bom_msg_function,
             rcd_bds_bom_hdr.bom_usage,
             rcd_bds_bom_hdr.bom_eff_from_date,
             rcd_bds_bom_hdr.bom_eff_to_date,
             rcd_bds_bom_hdr.bom_base_qty,
             rcd_bds_bom_hdr.bom_base_uom,
             rcd_bds_bom_hdr.bom_status);

      end if;

      /*-*/
      /* Perform exclusion processing
      /*-*/   
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/         
      update lads_bom_hdr
         set lads_flattened = var_flattened
      where stlal = par_stlal
        and matnr = par_matnr
        and werks = par_werks;

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
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'STLAL: ' || par_stlal || ' MATNR: ' || par_matnr || ' WERK: ' || par_werks || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_stlal in varchar2, par_matnr in varchar2, par_werks in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select *
         from lads_bom_hdr t01
         where t01.stlal = par_stlal
           and t01.matnr = par_matnr
           and t01.werks = par_werks
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
         bds_flatten(par_stlal, par_matnr, par_werks);

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
         select t01.stlal,
                t01.matnr,
                t01.werks
         from lads_bom_hdr t01
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

         lads_lock(rcd_flatten.stlal, rcd_flatten.matnr, rcd_flatten.werks);

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
      bds_table.truncate('bds_bom_det');
      bds_table.truncate('bds_bom_hdr');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_bom_hdr
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

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad17_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad17_flatten for bds_app.bds_atllad17_flatten;
grant execute on bds_atllad17_flatten to lics_app;
grant execute on bds_atllad17_flatten to lads_app;
