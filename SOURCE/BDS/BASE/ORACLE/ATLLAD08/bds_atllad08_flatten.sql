create or replace package bds_atllad08_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad08_flatten
    Owner   : BDS_APP
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD08 - Material BOM (BOMMAT)

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
    2006/12   Steve Gregan   Created
    2007/04   Steve Gregan   Added redundant header column to detail row

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_stlnr in varchar2, par_stlal in varchar2);

end bds_atllad08_flatten;
/

/****************/
/* Package Body */
/****************/
create or replace package body bds_atllad08_flatten as

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
   procedure lads_lock(par_stlnr in varchar2, par_stlal in varchar2);
   procedure bds_flatten(par_stlnr in varchar2, par_stlal in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_stlnr in varchar2, par_stlal in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/   
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_stlnr, par_stlal);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_stlnr, par_stlal);
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
         raise_application_error(-20000, 'BDS_ATLLAD08_FLATTEN - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_stlnr in varchar2, par_stlal in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* Material BOM rows
      /*-*/
      rcd_bds_material_bom_hdr bds_material_bom_hdr%rowtype;
      rcd_bds_material_bom_det bds_material_bom_det%rowtype;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_mat_bom_hdr is
         select t01.stlnr as stlnr,
                t01.stlal as stlal,
                t01.idoc_name as idoc_name,
                t01.idoc_number as idoc_number,
                t01.idoc_timestamp as idoc_timestamp,
                t01.lads_date as lads_date,
                t01.lads_status as lads_status,
                t01.matnr as matnr,
                nvl(t01.werks,'*NONE') as werks,
                t01.stlan as stlan,
                bds_date.bds_to_date('*START_DATE',t01.datuv) as datuv,
                nvl(t01.stlst,7) as stlst,
                t01.bmeng_c as bmeng_c,
                t01.bmein as bmein
         from lads_mat_bom_hdr t01
         where t01.stlnr = par_stlnr
           and t01.stlal = par_stlal
           and not(t01.matnr is null);
      rcd_lads_mat_bom_hdr csr_lads_mat_bom_hdr%rowtype;

      cursor csr_lads_mat_bom_det is
         select t01.idnrk as idnrk,
                max(t01.postp) as postp,
                max(t01.menge_c) as menge_c,
                max(t01.meins) as meins
         from lads_mat_bom_det t01
         where t01.stlnr = rcd_lads_mat_bom_hdr.stlnr
           and t01.stlal = rcd_lads_mat_bom_hdr.stlal
           and not(t01.idnrk is null)
         group by t01.idnrk;
      rcd_lads_mat_bom_det csr_lads_mat_bom_det%rowtype;

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
      /* Delete the existing BDS material BOM data
      /*-*/
      delete bds_material_bom_det where sap_bom = par_stlnr
                                    and sap_bom_alternative = par_stlal;

      /*-*/
      /* Process LADS material BOM header
      /*-*/
      open csr_lads_mat_bom_hdr;
      fetch csr_lads_mat_bom_hdr into rcd_lads_mat_bom_hdr;
      if (csr_lads_mat_bom_hdr%notfound) then
         raise_application_error(-20000, 'Material BOM Header cursor not found');
      end if;
      close csr_lads_mat_bom_hdr;

      /*-*/
      /* Initialise the BDS material BOM row
      /*-*/
      rcd_bds_material_bom_hdr.sap_bom := rcd_lads_mat_bom_hdr.stlnr;
      rcd_bds_material_bom_hdr.sap_bom_alternative := rcd_lads_mat_bom_hdr.stlal;
      rcd_bds_material_bom_hdr.sap_idoc_name := rcd_lads_mat_bom_hdr.idoc_name;
      rcd_bds_material_bom_hdr.sap_idoc_number := rcd_lads_mat_bom_hdr.idoc_number;
      rcd_bds_material_bom_hdr.sap_idoc_timestamp := rcd_lads_mat_bom_hdr.idoc_timestamp;
      rcd_bds_material_bom_hdr.bds_lads_date := rcd_lads_mat_bom_hdr.lads_date;
      rcd_bds_material_bom_hdr.bds_lads_status := rcd_lads_mat_bom_hdr.lads_status;
      rcd_bds_material_bom_hdr.bom_plant := rcd_lads_mat_bom_hdr.werks;
      rcd_bds_material_bom_hdr.bom_usage := rcd_lads_mat_bom_hdr.stlan;
      rcd_bds_material_bom_hdr.bom_eff_date := rcd_lads_mat_bom_hdr.datuv;
      rcd_bds_material_bom_hdr.bom_status := rcd_lads_mat_bom_hdr.stlst;
      rcd_bds_material_bom_hdr.parent_material_code := rcd_lads_mat_bom_hdr.matnr;
      rcd_bds_material_bom_hdr.parent_base_qty := rcd_lads_mat_bom_hdr.bmeng_c;
      rcd_bds_material_bom_hdr.parent_base_uom := rcd_lads_mat_bom_hdr.bmein;

      /*-*/
      /* Update/Insert the BDS material BOM header row
      /*-*/
      update bds_material_bom_hdr
         set sap_idoc_name = rcd_bds_material_bom_hdr.sap_idoc_name,
             sap_idoc_number = rcd_bds_material_bom_hdr.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_material_bom_hdr.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_material_bom_hdr.bds_lads_date,
             bds_lads_status = rcd_bds_material_bom_hdr.bds_lads_status,
             bom_plant = rcd_bds_material_bom_hdr.bom_plant,
             bom_usage = rcd_bds_material_bom_hdr.bom_usage,
             bom_eff_date = rcd_bds_material_bom_hdr.bom_eff_date,
             bom_status = rcd_bds_material_bom_hdr.bom_status,
             parent_material_code = rcd_bds_material_bom_hdr.parent_material_code,
             parent_base_qty = rcd_bds_material_bom_hdr.parent_base_qty,
             parent_base_uom = rcd_bds_material_bom_hdr.parent_base_uom
      where sap_bom = rcd_bds_material_bom_hdr.sap_bom
        and sap_bom_alternative = rcd_bds_material_bom_hdr.sap_bom_alternative;
      if (sql%notfound) then
         insert into bds_material_bom_hdr
            (sap_bom,
             sap_bom_alternative,
             sap_idoc_name,
             sap_idoc_number,
             sap_idoc_timestamp,
             bds_lads_date,
             bds_lads_status,
             bom_plant,
             bom_usage,
             bom_eff_date,
             bom_status,
             parent_material_code,
             parent_base_qty,
             parent_base_uom)
          values 
            (rcd_bds_material_bom_hdr.sap_bom,
             rcd_bds_material_bom_hdr.sap_bom_alternative,
             rcd_bds_material_bom_hdr.sap_idoc_name,
             rcd_bds_material_bom_hdr.sap_idoc_number,
             rcd_bds_material_bom_hdr.sap_idoc_timestamp,
             rcd_bds_material_bom_hdr.bds_lads_date,
             rcd_bds_material_bom_hdr.bds_lads_status,
             rcd_bds_material_bom_hdr.bom_plant,
             rcd_bds_material_bom_hdr.bom_usage,
             rcd_bds_material_bom_hdr.bom_eff_date,
             rcd_bds_material_bom_hdr.bom_status,
             rcd_bds_material_bom_hdr.parent_material_code,
             rcd_bds_material_bom_hdr.parent_base_qty,
             rcd_bds_material_bom_hdr.parent_base_uom);
      end if;

      /*-*/
      /* Process LADS material BOM detail
      /*-*/
      open csr_lads_mat_bom_det;
      loop
         fetch csr_lads_mat_bom_det into rcd_lads_mat_bom_det;
         if (csr_lads_mat_bom_det%notfound) then
            exit;
         end if;

         /*-*/
         /* Set the BDS material BOM detail columns
         /*-*/
         rcd_bds_material_bom_det.sap_bom := rcd_bds_material_bom_hdr.sap_bom;
         rcd_bds_material_bom_det.sap_bom_alternative := rcd_bds_material_bom_hdr.sap_bom_alternative;
         rcd_bds_material_bom_det.child_material_code := rcd_lads_mat_bom_det.idnrk;
         rcd_bds_material_bom_det.child_item_category := rcd_lads_mat_bom_det.postp;
         rcd_bds_material_bom_det.child_base_qty := rcd_lads_mat_bom_det.menge_c;
         rcd_bds_material_bom_det.child_base_uom := rcd_lads_mat_bom_det.meins;

         /*-*/
         /* Insert the BDS material BOM detail row
         /*-*/
         insert into bds_material_bom_det
            (sap_bom,
             sap_bom_alternative,
             child_material_code,
             child_item_category,
             child_base_qty,
             child_base_uom,
             bds_lads_date,
             bds_lads_status,
             bom_plant,
             bom_usage,
             bom_eff_date,
             bom_status,
             parent_material_code,
             parent_base_qty,
             parent_base_uom)
          values 
            (rcd_bds_material_bom_det.sap_bom,
             rcd_bds_material_bom_det.sap_bom_alternative,
             rcd_bds_material_bom_det.child_material_code,
             rcd_bds_material_bom_det.child_item_category,
             rcd_bds_material_bom_det.child_base_qty,
             rcd_bds_material_bom_det.child_base_uom,
             rcd_bds_material_bom_hdr.bds_lads_date,
             rcd_bds_material_bom_hdr.bds_lads_status,
             rcd_bds_material_bom_hdr.bom_plant,
             rcd_bds_material_bom_hdr.bom_usage,
             rcd_bds_material_bom_hdr.bom_eff_date,
             rcd_bds_material_bom_hdr.bom_status,
             rcd_bds_material_bom_hdr.parent_material_code,
             rcd_bds_material_bom_hdr.parent_base_qty,
             rcd_bds_material_bom_hdr.parent_base_uom);

      end loop;
      close csr_lads_mat_bom_det;

      /*-*/
      /* Perform exclusion processing
      /*-*/   
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/         
      update lads_mat_bom_hdr
         set lads_flattened = var_flattened
      where stlnr = par_stlnr
        and stlal = par_stlal;

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
         raise_application_error(-20000, 'BDS_FLATTEN -  ' || 'STLNR: ' || par_stlnr || 'STLAL: ' || par_stlal || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_stlnr in varchar2, par_stlal in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select *
         from lads_mat_bom_hdr t01
         where t01.stlnr = par_stlnr
           and t01.stlal = par_stlal
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
         bds_flatten(par_stlnr, par_stlal);

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
         select t01.stlnr,
                t01.stlal
         from lads_mat_bom_hdr t01
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

         lads_lock(rcd_flatten.stlnr, rcd_flatten.stlal);

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
      bds_table.truncate('bds_material_bom_det');
      bds_table.truncate('bds_material_bom_hdr');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_mat_bom_hdr
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
         raise_application_error(-20000, ' - BDS_REBUILD - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bds_rebuild;

end bds_atllad08_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad08_flatten for bds_app.bds_atllad08_flatten;
grant execute on bds_atllad08_flatten to lics_app;
grant execute on bds_atllad08_flatten to lads_app;
