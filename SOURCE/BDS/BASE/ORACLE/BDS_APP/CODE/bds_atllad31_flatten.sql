--
-- BDS_ATLLAD31_FLATTEN  (Package) 
--
CREATE OR REPLACE PACKAGE BDS_APP.bds_atllad31_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad31_flatten
    Owner   : BDS_APP
    Author  : Ben Halicki

    Description
    -----------
    Business Data Store - ATLLAD31 - Plant Maintenance Equipment Master

    PARAMETERS
      1. PAR_ACTION [MANDATORY]
         *DOCUMENT            - ONLY to be called from LADS load package, assumes locking/commits in parent
         *DOCUMENT_OVERRIDE   - manual flattening execution, implements locks/commits internally
         *REFRESH             - process all unflattened LADS records
         *REBUILD             - process all LADS records - truncates BDS table(s) first
                              - RECOMMEND stopping ICS jobs prior to execution

      2. PAR_MATNR [MANDATORY on *DOCUMENT and *DOCUMENT_OVERRIDE]
         Field from LADS document in LADS_MAT_HDR.MATNR

    NOTES
      1. This package must raise an exception on failure to exclude database activity from parent commit

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Ben Halicki    Created this package
    
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_equnr in varchar2);
    
end bds_atllad31_flatten;
/


GRANT EXECUTE ON BDS_APP.BDS_ATLLAD31_FLATTEN TO LADS_APP;


--
-- BDS_ATLLAD31_FLATTEN  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY BDS_APP.bds_atllad31_flatten as

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
   procedure lads_lock(par_equnr in varchar2);
   procedure bds_flatten(par_equnr in varchar2);
   procedure bds_refresh;
   procedure bds_rebuild;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_equnr in varchar2) is
    
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_equnr);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_equnr);
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
         raise_application_error(-20000, 'bds_atllad31_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_equnr in varchar2) is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* BDS record definitions
      /*-*/
      rcd_bds_equipment_plant_hdr bds_equipment_plant_hdr%rowtype;
      
      /*-*/
      /* local cursors
      /*-*/
        cursor csr_lads_equ_hdr is
           select t01.equnr as equnr,
                  t01.shtxt as shtxt, 
                  t01.tplnr as tplnr,
                  t01.eqfnr as eqfnr,
                  t01.swerk as swerk,
                  t01.idoc_name as idoc_name,
                  t01.idoc_number as idoc_number,
                  t01.idoc_timestamp as idoc_timestamp,
                  t01.lads_date as lads_date,
                  t01.lads_status as lads_status
             from lads_equ_hdr t01
            where t01.equnr = par_equnr;
              
        rcd_lads_equ_hdr csr_lads_equ_hdr%rowtype;

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
      delete from bds_equipment_plant_hdr where sap_equipment_code = par_equnr;
                                            
      /*-*/
      /* Retrieve the LADS stock balance header
      /*-*/
      open csr_lads_equ_hdr;
      fetch csr_lads_equ_hdr into rcd_lads_equ_hdr;
      
      if csr_lads_equ_hdr%notfound then
         raise_application_error(-20000, 'LADS Header row not found');
      end if;
      close csr_lads_equ_hdr;

      /*-*/
      /* Set the BDS header values
      /*-*/
      rcd_bds_equipment_plant_hdr.sap_equipment_code := rcd_lads_equ_hdr.equnr;
      rcd_bds_equipment_plant_hdr.plant_code := rcd_lads_equ_hdr.swerk;
      rcd_bds_equipment_plant_hdr.equipment_desc := rcd_lads_equ_hdr.shtxt;
      rcd_bds_equipment_plant_hdr.functnl_locn_code := rcd_lads_equ_hdr.tplnr;
      rcd_bds_equipment_plant_hdr.sort_field := rcd_lads_equ_hdr.eqfnr;
      rcd_bds_equipment_plant_hdr.sap_idoc_name := rcd_lads_equ_hdr.idoc_name;
      rcd_bds_equipment_plant_hdr.sap_idoc_number := rcd_lads_equ_hdr.idoc_number;
      rcd_bds_equipment_plant_hdr.sap_idoc_timestamp := rcd_lads_equ_hdr.idoc_timestamp;
      rcd_bds_equipment_plant_hdr.bds_lads_date := rcd_lads_equ_hdr.lads_date;
      rcd_bds_equipment_plant_hdr.bds_lads_status := rcd_lads_equ_hdr.lads_status;
        
      /*-*/
      /* Update the BDS header
      /*-*/
      update bds_equipment_plant_hdr
         set equipment_desc = rcd_bds_equipment_plant_hdr.equipment_desc,
             functnl_locn_code = rcd_bds_equipment_plant_hdr.functnl_locn_code,
             sort_field = rcd_bds_equipment_plant_hdr.sort_field,
             sap_idoc_name = rcd_bds_equipment_plant_hdr.sap_idoc_name,
             sap_idoc_number = rcd_bds_equipment_plant_hdr.sap_idoc_number,
             sap_idoc_timestamp = rcd_bds_equipment_plant_hdr.sap_idoc_timestamp,
             bds_lads_date = rcd_bds_equipment_plant_hdr.bds_lads_date,
             bds_lads_status = rcd_bds_equipment_plant_hdr.bds_lads_status
       where sap_equipment_code = rcd_bds_equipment_plant_hdr.sap_equipment_code;
       
       if sql%notfound then
          insert into bds_equipment_plant_hdr
          (
            sap_equipment_code,
            plant_code,
            equipment_desc,
            functnl_locn_code,
            sort_field,
            sap_idoc_name,
            sap_idoc_number,
            sap_idoc_timestamp,
            bds_lads_date,
            bds_lads_status
         )
         values(rcd_bds_equipment_plant_hdr.sap_equipment_code,
                rcd_bds_equipment_plant_hdr.plant_code,
                rcd_bds_equipment_plant_hdr.equipment_desc,
                rcd_bds_equipment_plant_hdr.functnl_locn_code,
                rcd_bds_equipment_plant_hdr.sort_field,
                rcd_bds_equipment_plant_hdr.sap_idoc_name,
                rcd_bds_equipment_plant_hdr.sap_idoc_number,
                rcd_bds_equipment_plant_hdr.sap_idoc_timestamp,
                rcd_bds_equipment_plant_hdr.bds_lads_date,
                rcd_bds_equipment_plant_hdr.bds_lads_status);
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
      update lads_equ_hdr
         set lads_flattened = var_flattened
       where equnr = par_equnr;
          
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
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'EQUNR: ' || par_equnr || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_equnr in varchar2) is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_equ_hdr t01
          where t01.equnr = par_equnr
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
         bds_flatten(rcd_lock.equnr);
         
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
        select t01.equnr 
          from lads_equ_hdr t01      
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

         lads_lock(rcd_flatten.equnr);
         
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
      bds_table.truncate('bds_equipment_plant_hdr');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_equ_hdr
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

end bds_atllad31_flatten;
/


GRANT EXECUTE ON BDS_APP.BDS_ATLLAD31_FLATTEN TO LADS_APP;
