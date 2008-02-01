/******************/
/* Package Header */
/******************/
create or replace package bds_atllad01_flatten as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : BDS (Business Data Store)
    Package : bds_atllad01_flatten
    Owner   : bds_app
    Author  : Steve Gregan

    Description
    -----------
    Business Data Store - ATLLAD01 - Control Recipe (ZOWMIVMX)

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
    2007/05   Jeff Phillipson Changed format of TO_NUMBER from 999G999D999 to FM999G999G999D999 (11 occurances)
    2007/06   Steve Gregan   Changed cursor definitions for performance
    2007/06   Steve Gregan   Added ZATLAS2 test
    2007/07   Steve Gregan   Included text truncation (max 2000/4000)
    2007/07   Steve Gregan   Included validation process order logic
    2007/08   Steve Gregan   Excluded AU10 and NZ01 from validation process order logic
    2008/01   Jeff Phillipson Allow AU10 validation process orders 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_cntl_rec_id in number);

end bds_atllad01_flatten;
/

create or replace package body bds_atllad01_flatten AS

   /*-*/
   /* VERSION
   /* Problem found when LAST_PAN_SIZE in ZPHBRQ1 has a numerical value with a shorter length than
   /* PAN_SIZE. The variable var_space was being used for the length of both fields
   /* when var_space1 should have been used for LAST_PAN_SIZE
   /* Added by JP 26 May 2006  - search on the text in the bracket to find the change {Added by JP 26 May 2006}
   /*-*/

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
   procedure lads_lock(par_cntl_rec_id in number);
   procedure bds_flatten(par_cntl_rec_id in number);
   procedure bds_refresh;
   procedure bds_rebuild;
   PROCEDURE process_zordine;
   PROCEDURE process_zatlas;
   PROCEDURE process_zatlasa;
   PROCEDURE process_zmessrc;
   PROCEDURE process_zphpan1;
   PROCEDURE process_zphbrq1;

   /*-*/
   /* Private definitions
   /*-*/
   var_action VARCHAR2(1);
   var_zordine BOOLEAN;
   rcd_lads_ctl_rec_hpi lads_ctl_rec_hpi%ROWTYPE;
   rcd_lads_ctl_rec_tpi lads_ctl_rec_tpi%ROWTYPE;
   rcd_bds_recipe_header bds_recipe_header%ROWTYPE;
   rcd_bds_recipe_bom bds_recipe_bom%ROWTYPE;
   rcd_bds_recipe_resource bds_recipe_resource%ROWTYPE;
   rcd_bds_recipe_src_value bds_recipe_src_value%ROWTYPE;
   rcd_bds_recipe_src_text bds_recipe_src_text%ROWTYPE;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_cntl_rec_id in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute BDS Flattening process
      /*-*/
      case upper(par_action)
        when '*DOCUMENT' then bds_flatten(par_cntl_rec_id);
        when '*DOCUMENT_OVERRIDE' then lads_lock(par_cntl_rec_id);
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
         raise_application_error(-20000, 'bds_atllad01_flatten - EXECUTE ' || par_action || ' - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***************************************************/
   /* This procedure perfroms the BDS Flatten routine */
   /***************************************************/
   procedure bds_flatten(par_cntl_rec_id in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_flattened varchar2(1);
      var_excluded boolean;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_hpi_01 IS
         SELECT t01.cntl_rec_id,
                t01.plant,
                t01.proc_order,
                t01.dest,
                t01.dest_address,
                t01.dest_type,
                t01.cntl_rec_status,
                t01.test_flag,
                t01.recipe_text,
                t01.material,
                t01.material_text,
                t01.insplot,
                t01.material_external,
                t01.material_guid,
                t01.material_version,
                t01.batch,
                t01.scheduled_start_date,
                t01.scheduled_start_time,
                t01.idoc_name,
                t01.idoc_number,
                t01.idoc_timestamp,
                t01.lads_date,
                t01.lads_status,
                t01.lads_flattened
           FROM lads_ctl_rec_hpi t01
          WHERE t01.cntl_rec_id = par_cntl_rec_id;

      CURSOR csr_lads_ctl_rec_tpi_01 IS
         SELECT t01.cntl_rec_id,
                t01.proc_instr_number,
                t01.proc_instr_type,
                t01.proc_instr_category,
                t01.proc_instr_line_no,
                t01.phase_number
           FROM lads_ctl_rec_tpi t01
          WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id
       ORDER BY t01.proc_instr_number ASC;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

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
      /* Retrieve the control recipe HPI from the LADS schema
      /*-*/
      OPEN csr_lads_ctl_rec_hpi_01;
      FETCH csr_lads_ctl_rec_hpi_01 INTO rcd_lads_ctl_rec_hpi;
      IF csr_lads_ctl_rec_hpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Execute - Control recipe id (' || TO_CHAR(par_cntl_rec_id) || ') does not exist');
      END IF;
      CLOSE csr_lads_ctl_rec_hpi_01;

      /*-*/
      /* Initialise the action and ZORDINE indicators
      /*-*/
      var_action := NULL;
      var_zordine := FALSE;

      /*-*/
      /* Retrieve the related control recipe TPI rows
      /*-*/
      OPEN csr_lads_ctl_rec_tpi_01;
      LOOP
         FETCH csr_lads_ctl_rec_tpi_01 INTO rcd_lads_ctl_rec_tpi;
         IF csr_lads_ctl_rec_tpi_01%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Process the related control recipe VPI rows based on intruction category
         /*-*/
         CASE rcd_lads_ctl_rec_tpi.proc_instr_category
            WHEN 'ZORDINE' THEN process_zordine;
            WHEN 'ZATLAS'  THEN process_zatlas;
            -- added next line JP - 11 Aug 2005 new comds in idoc
            WHEN 'ZBFBRQ1' THEN process_zatlas;
            WHEN 'ZATLASA' THEN process_zatlasa;
            -- added next line JP - 11 Aug 2005 new comds in idoc
            WHEN 'ZACBRQ1' THEN process_zatlasa;
            WHEN 'ZMESSRC' THEN process_zmessrc;
            -- added next 3 lines JP - 11 Aug 2005 new comds in idoc
            WHEN 'ZSRC'    THEN process_zmessrc;
            WHEN 'ZPHPAN1' THEN process_zphpan1;
            WHEN 'ZPHBRQ1' THEN process_zphbrq1;
            WHEN 'ZATLAS2' THEN null;
            ELSE RAISE_APPLICATION_ERROR(-20000, 'Execute - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_hpi.cntl_rec_id) || ') process instruction category (' || rcd_lads_ctl_rec_tpi.proc_instr_category || ') not recognised on LADS_CTL_REC_TPI');
         END CASE;

      END LOOP;
      CLOSE csr_lads_ctl_rec_tpi_01;

      /*-*/
      /* Control recipe must have one ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Execute - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_hpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      END IF;

      /*-*/
      /* Perform exclusion processing
      /*-*/
      if (var_excluded) then
         var_flattened := '2';
      end if;

      /*-*/
      /* Update LADS header record to reflect flattened status
      /*-*/
      update lads_ctl_rec_hpi
         set lads_flattened = var_flattened
         where cntl_rec_id = par_cntl_rec_id;

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
         raise_application_error(-20000, 'BDS_FLATTEN - ' || 'CNTL_REC_ID: ' || to_char(par_cntl_rec_id) || ' - ' || substr(SQLERRM, 1, 1024));

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
   procedure lads_lock(par_cntl_rec_id in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_available boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lock is
         select t01.*
           from lads_ctl_rec_hpi t01
          where t01.cntl_rec_id = par_cntl_rec_id
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
         bds_flatten(rcd_lock.cntl_rec_id);

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
         select t01.cntl_rec_id
           from lads_ctl_rec_hpi t01
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

         lads_lock(rcd_flatten.cntl_rec_id);

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
      bds_table.truncate('bds_recipe_resource');
      bds_table.truncate('bds_recipe_src_text');
      bds_table.truncate('bds_recipe_src_value');
      bds_table.truncate('bds_recipe_bom');
      bds_table.truncate('bds_recipe_header');

      /*-*/
      /* Set all source LADS documents to unflattened status
      /*-*/
      update lads_ctl_rec_hpi
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

   /*******************************************************/
   /* This procedure performs the process ZORDINE routine */
   /*******************************************************/
   PROCEDURE process_zordine IS

      /*-*/
      /* Local variables
      /*-*/
      var_process_order number;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01 IS
         SELECT t01.pppi_process_order,
                t01.pppi_order_quantity,
                t01.pppi_unit_of_measure,
                t01.pppi_storage_location,
                t01.zpppi_order_start_date,
                t01.zpppi_order_start_time,
                t01.zpppi_order_end_date,
                t01.zpppi_order_end_time,
                t01.z_teco_status
           FROM (SELECT t01.cntl_rec_id,
                        t01.proc_instr_number,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PROCESS_ORDER' THEN t01.char_value END) AS pppi_process_order,
                        MAX(CASE WHEN t01.name_char = 'PPPI_ORDER_QUANTITY' THEN t01.char_value END) AS pppi_order_quantity,
                        MAX(CASE WHEN t01.name_char = 'PPPI_UNIT_OF_MEASURE' THEN t01.char_value END) AS pppi_unit_of_measure,
                        MAX(CASE WHEN t01.name_char = 'PPPI_STORAGE_LOCATION' THEN t01.char_value END) AS pppi_storage_location,
                        MAX(CASE WHEN t01.name_char = 'ZPPPI_ORDER_START_DATE' THEN t01.char_value END) AS zpppi_order_start_date,
                        MAX(CASE WHEN t01.name_char = 'ZPPPI_ORDER_START_TIME' THEN t01.char_value END) AS zpppi_order_start_time,
                        MAX(CASE WHEN t01.name_char = 'ZPPPI_ORDER_END_DATE' THEN t01.char_value END) AS zpppi_order_end_date,
                        MAX(CASE WHEN t01.name_char = 'ZPPPI_ORDER_END_TIME' THEN t01.char_value END) AS zpppi_order_end_time,
                        MAX(CASE WHEN t01.name_char = 'Z_TECO_STATUS' THEN t01.char_value END) AS z_teco_status
                   FROM lads_ctl_rec_vpi t01
                  WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    AND t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               GROUP BY t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_bds_recipe_header_01 IS
         SELECT t01.cntl_rec_id,
                t01.idoc_timestamp
           FROM bds_recipe_header t01
          WHERE t01.proc_order = rcd_bds_recipe_header.proc_order;
      rcd_bds_recipe_header_01 csr_bds_recipe_header_01%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Control recipe can only have one ZORDINE process instruction
      /*-*/
      IF var_zordine = TRUE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') has multiple ZORDINE process instructions on LADS_CTL_REC_TPI');
      END IF;
      var_zordine := TRUE;

      /*-*/
      /* Retrieve the ZORDINE data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;
      FETCH csr_lads_ctl_rec_vpi_01 INTO rcd_lads_ctl_rec_vpi;
      IF csr_lads_ctl_rec_vpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || TO_CHAR(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      END IF;
      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_header row data
      /* **note** Process orders starting with a non-numeric character represent validation process orders
      /*-*/
      rcd_bds_recipe_header.proc_order := rcd_lads_ctl_rec_vpi.pppi_process_order;
      if not(rcd_bds_recipe_header.proc_order is null) then
         if substr(rcd_bds_recipe_header.proc_order,1,1) < '0' or substr(rcd_bds_recipe_header.proc_order,1,1) > '9' then
            if rcd_lads_ctl_rec_hpi.plant <> 'NZ01' then
               select bds_recipe_sequence.nextval into var_process_order from dual;
               rcd_bds_recipe_header.proc_order := substr(rcd_bds_recipe_header.proc_order,1,1) || to_char(var_process_order,'fm00000000000');
            else
               raise_application_error(-20000, 'Process ZORDINE - Field - Validation PROC_ORDER - cannot be sent for NZ01');
            end if;
         end if;
      else
         raise_application_error(-20000, 'Process ZORDINE - Field - PROC_ORDER - Must not be null');
      end if;

      rcd_bds_recipe_header.cntl_rec_id := rcd_lads_ctl_rec_hpi.cntl_rec_id;

      rcd_bds_recipe_header.plant := rcd_lads_ctl_rec_hpi.plant;
      IF rcd_bds_recipe_header.plant IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - PLANT - Must not be null');
      END IF;

      rcd_bds_recipe_header.cntl_rec_status := rcd_lads_ctl_rec_hpi.cntl_rec_status;

      rcd_bds_recipe_header.test_flag := rcd_lads_ctl_rec_hpi.test_flag;

      rcd_bds_recipe_header.recipe_text := rcd_lads_ctl_rec_hpi.recipe_text;

      rcd_bds_recipe_header.material := rcd_lads_ctl_rec_hpi.material;
      IF rcd_bds_recipe_header.material IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - MATERIAL - Must not be null');
      END IF;

      rcd_bds_recipe_header.material_text := rcd_lads_ctl_rec_hpi.material_text;

      rcd_bds_recipe_header.quantity := NULL;
      BEGIN
         rcd_bds_recipe_header.quantity := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_order_quantity);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - QUANTITY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_order_quantity || ') to a number');
      END;

      rcd_bds_recipe_header.insplot := rcd_lads_ctl_rec_hpi.insplot;

      rcd_bds_recipe_header.uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;

      rcd_bds_recipe_header.batch := rcd_lads_ctl_rec_hpi.batch;

      rcd_bds_recipe_header.sched_start_datime := NULL;
      BEGIN
         rcd_bds_recipe_header.sched_start_datime := TO_DATE(rcd_lads_ctl_rec_hpi.scheduled_start_date || rcd_lads_ctl_rec_hpi.scheduled_start_time,'YYYYMMDDHH24MISS');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - SCHED_START_DATIME - Unable to convert (' || rcd_lads_ctl_rec_hpi.scheduled_start_date || rcd_lads_ctl_rec_hpi.scheduled_start_time || ') to a date using format (YYYYMMDDHH24MISS)');
      END;

      rcd_bds_recipe_header.run_start_datime := NULL;
      BEGIN
         rcd_bds_recipe_header.run_start_datime := TO_DATE(rcd_lads_ctl_rec_vpi.zpppi_order_start_date || rcd_lads_ctl_rec_vpi.zpppi_order_start_time,'YYYYMMDDHH24MISS');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - RUN_START_DATIME - Unable to convert (' || rcd_lads_ctl_rec_vpi.zpppi_order_start_date || rcd_lads_ctl_rec_vpi.zpppi_order_start_time || ') to a date using format (YYYYMMDDHH24MISS)');
      END;
      IF rcd_bds_recipe_header.run_start_datime IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - RUN_START_DATIME - Must not be null');
      END IF;

      rcd_bds_recipe_header.run_end_datime := NULL;
      BEGIN
         rcd_bds_recipe_header.run_end_datime := TO_DATE(rcd_lads_ctl_rec_vpi.zpppi_order_end_date || rcd_lads_ctl_rec_vpi.zpppi_order_end_time,'YYYYMMDDHH24MISS');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - RUN_END_DATIME - Unable to convert (' || rcd_lads_ctl_rec_vpi.zpppi_order_end_date || rcd_lads_ctl_rec_vpi.zpppi_order_end_time || ') to a date using format (YYYYMMDDHH24MISS)');
      END;
      IF rcd_bds_recipe_header.run_end_datime IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000,' Process ZORDINE - Field - RUN_END_DATIME - Must not be null');
      END IF;

      rcd_bds_recipe_header.VERSION := 1;

      rcd_bds_recipe_header.upd_datime := SYSDATE;

      rcd_bds_recipe_header.cntl_rec_xfer := 'N';

      rcd_bds_recipe_header.teco_status := rcd_lads_ctl_rec_vpi.z_teco_status;

      rcd_bds_recipe_header.storage_locn := rcd_lads_ctl_rec_vpi.pppi_storage_location;

      rcd_bds_recipe_header.idoc_timestamp := rcd_lads_ctl_rec_hpi.idoc_timestamp;

      /*-*/
      /* Retrieve the bds_recipe_header data
      /*    - insert new process order when none found
      /*    - replace existing process order when control recipe identifier is greater
      /*-*/
      OPEN csr_bds_recipe_header_01;
      FETCH csr_bds_recipe_header_01 INTO rcd_bds_recipe_header_01;
      IF csr_bds_recipe_header_01%NOTFOUND THEN
         var_action := 'I';
      ELSE
         IF rcd_bds_recipe_header.idoc_timestamp > rcd_bds_recipe_header_01.idoc_timestamp THEN
            var_action := 'R';
         END IF;
      END IF;
      CLOSE csr_bds_recipe_header_01;

      /*-*/
      /* Replace an existing process order
      /*-*/
      IF var_action = 'R' THEN

         /*-*/
         /* Remove any existing child data
         /*-*/
         DELETE FROM bds_recipe_src_text WHERE proc_order = rcd_bds_recipe_header.proc_order;
         DELETE FROM bds_recipe_src_value WHERE proc_order = rcd_bds_recipe_header.proc_order;
         DELETE FROM bds_recipe_resource WHERE proc_order = rcd_bds_recipe_header.proc_order;
         DELETE FROM bds_recipe_bom WHERE proc_order = rcd_bds_recipe_header.proc_order;


         /*-*/
         /* Update the bds_recipe_header row
         /*-*/
         UPDATE bds_recipe_header
            SET cntl_rec_id = rcd_bds_recipe_header.cntl_rec_id,
                plant = rcd_bds_recipe_header.plant,
                cntl_rec_status = rcd_bds_recipe_header.cntl_rec_status,
                test_flag = rcd_bds_recipe_header.test_flag,
                recipe_text = rcd_bds_recipe_header.recipe_text,
                material = rcd_bds_recipe_header.material,
                material_text = rcd_bds_recipe_header.material_text,
                quantity = rcd_bds_recipe_header.quantity,
                insplot = rcd_bds_recipe_header.insplot,
                uom = rcd_bds_recipe_header.uom,
                batch = rcd_bds_recipe_header.batch,
                sched_start_datime = rcd_bds_recipe_header.sched_start_datime,
                run_start_datime = rcd_bds_recipe_header.run_start_datime,
                run_end_datime = rcd_bds_recipe_header.run_end_datime,
                VERSION = VERSION + 1,
                upd_datime = rcd_bds_recipe_header.upd_datime,
                cntl_rec_xfer = rcd_bds_recipe_header.cntl_rec_xfer,
                teco_status = rcd_bds_recipe_header.teco_status,
                storage_locn = rcd_bds_recipe_header.storage_locn,
                idoc_timestamp = rcd_bds_recipe_header.idoc_timestamp
          WHERE proc_order = rcd_bds_recipe_header.proc_order;

      END IF;

      /*-*/
      /* Insert a new process order
      /*-*/
      IF var_action = 'I' THEN

         /*-*/
         /* Insert the bds_recipe_header row
         /*-*/
         INSERT INTO bds_recipe_header
            (proc_order,
             cntl_rec_id,
             plant,
             cntl_rec_status,
             test_flag,
             recipe_text,
             material,
             material_text,
             quantity,
             insplot,
             uom,
             batch,
             sched_start_datime,
             run_start_datime,
             run_end_datime,
             VERSION,
             upd_datime,
             cntl_rec_xfer,
             teco_status,
             storage_locn,
             idoc_timestamp)
            VALUES(rcd_bds_recipe_header.proc_order,
                   rcd_bds_recipe_header.cntl_rec_id,
                   rcd_bds_recipe_header.plant,
                   rcd_bds_recipe_header.cntl_rec_status,
                   rcd_bds_recipe_header.test_flag,
                   rcd_bds_recipe_header.recipe_text,
                   rcd_bds_recipe_header.material,
                   rcd_bds_recipe_header.material_text,
                   rcd_bds_recipe_header.quantity,
                   rcd_bds_recipe_header.insplot,
                   rcd_bds_recipe_header.uom,
                   rcd_bds_recipe_header.batch,
                   rcd_bds_recipe_header.sched_start_datime,
                   rcd_bds_recipe_header.run_start_datime,
                   rcd_bds_recipe_header.run_end_datime,
                   rcd_bds_recipe_header.VERSION,
                   rcd_bds_recipe_header.upd_datime,
                   rcd_bds_recipe_header.cntl_rec_xfer,
                   rcd_bds_recipe_header.teco_status,
                   rcd_bds_recipe_header.storage_locn,
                   rcd_bds_recipe_header.idoc_timestamp);

      END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_zordine;

   /******************************************************/
   /* This procedure performs the process ZATLAS routine */
   /******************************************************/
   PROCEDURE process_zatlas IS

      /*-*/
      /* Local definitions
      /*-*/
      var_work VARCHAR2(1);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01 IS
         SELECT t01.pppi_material_item,
                t01.pppi_material,
                t01.pppi_material_quantity,
                t01.pppi_material_short_text,
                t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_unit_of_measure,
                -- added next 5 lines JP - 11 Aug 2005 new comds in idoc
                t01.pppi_phase_resource,
                t01.z_ps_first_pan_in_num,
                t01.z_ps_last_pan_in_num,
                t01.z_ps_pan_size_yn,
                t01.z_ps_no_of_pans
           FROM (SELECT t01.cntl_rec_id,
                        t01.proc_instr_number,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL_ITEM' THEN t01.char_value END) AS pppi_material_item,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL' THEN t01.char_value END) AS pppi_material,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL_QUANTITY' THEN t01.char_value END) AS pppi_material_quantity,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL_SHORT_TEXT' THEN t01.char_value END) AS pppi_material_short_text,
                        MAX(CASE WHEN t01.name_char = 'PPPI_OPERATION' THEN t01.char_value END) AS pppi_operation,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE' THEN t01.char_value END) AS pppi_phase,
                        MAX(CASE WHEN t01.name_char = 'PPPI_UNIT_OF_MEASURE' THEN t01.char_value END) AS pppi_unit_of_measure,
                        -- added next 5 lines JP - 11 Aug 2005 new comds in idoc
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE_RESOURCE' THEN t01.char_value END) AS pppi_phase_resource,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_FIRST_PAN_IN_NUM' THEN t01.char_value END) AS z_ps_first_pan_in_num,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_LAST_PAN_IN_NUM' THEN t01.char_value END) AS z_ps_last_pan_in_num,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_PAN_SIZE_YN' THEN t01.char_value END) AS z_ps_pan_size_yn,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_NO_OF_PANS' THEN t01.char_value END) AS z_ps_no_of_pans
                   FROM lads_ctl_rec_vpi t01
                  WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    AND t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               GROUP BY t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_bds_recipe_resource_01 IS
         SELECT 'x'
           FROM bds_recipe_resource t01
          WHERE t01.proc_order = rcd_bds_recipe_resource.proc_order
            AND t01.operation = rcd_bds_recipe_resource.operation;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      END IF;

      /*-*/
      /* Ignore when action is null
      /*-*/
      IF var_action IS NULL THEN
         RETURN;
      END IF;

      /*-*/
      /* Retrieve the ZATLAS data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;
      FETCH csr_lads_ctl_rec_vpi_01 INTO rcd_lads_ctl_rec_vpi;
      IF csr_lads_ctl_rec_vpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || TO_CHAR(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      END IF;
      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      SELECT recipe_bom_id_seq.NEXTVAL INTO rcd_bds_recipe_bom.recipe_bom_id FROM dual;

      rcd_bds_recipe_bom.proc_order := rcd_bds_recipe_header.proc_order;

      rcd_bds_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_bds_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_bds_recipe_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;

      rcd_bds_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;

      rcd_bds_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.pppi_material_short_text;

      rcd_bds_recipe_bom.material_qty := NULL;
      BEGIN
         rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process  ZBFBRQ1 (ZATLAS) - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_material_quantity || ') to a number');
      END;

      rcd_bds_recipe_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;

      rcd_bds_recipe_bom.material_prnt := NULL;

      rcd_bds_recipe_bom.bf_item := NULL;

      rcd_bds_recipe_bom.reservation := NULL;

      rcd_bds_recipe_bom.plant := rcd_bds_recipe_header.plant;

      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comands in idoc - Atlas 3.1
      /*-*/
      rcd_bds_recipe_bom.pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_bds_recipe_bom.pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_bds_recipe_bom.last_pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_bds_recipe_bom.last_pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_bds_recipe_bom.pan_size_flag := 'N';
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         rcd_bds_recipe_bom.pan_size_flag := 'Y';
      END IF;

      rcd_bds_recipe_bom.pan_qty := NULL;
      BEGIN
         rcd_bds_recipe_bom.pan_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans || ') to a number');
      END;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      IF rcd_bds_recipe_bom.material_qty IS NULL THEN
         IF rcd_bds_recipe_bom.pan_size_flag = 'N' THEN
            BEGIN
               rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
            END;
         ELSE
            BEGIN
               rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans -1) + TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || 'or' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num ||') to a number');
            END;
         END IF;
      END IF;

		/* add a resource record here if you can */

		rcd_bds_recipe_resource.proc_order := rcd_bds_recipe_header.proc_order;
		rcd_bds_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		rcd_bds_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
		rcd_bds_recipe_resource.batch_qty := NULL;
		rcd_bds_recipe_resource.batch_uom := NULL;
		rcd_bds_recipe_resource.plant := rcd_bds_recipe_header.plant;

		/*-*/
      /* Insert the bds_recipe_resource row when required
      /*-*/

		-- commented out until the Pan size is sorted ouit in Atlas
      OPEN csr_bds_recipe_resource_01;
         FETCH csr_bds_recipe_resource_01 INTO var_work;
         IF csr_bds_recipe_resource_01%NOTFOUND THEN
			    IF  rcd_bds_recipe_resource.operation  IS NOT NULL AND rcd_bds_recipe_resource.resource_code  IS NOT NULL THEN
                 SELECT recipe_resource_id_seq.NEXTVAL
                   INTO rcd_bds_recipe_resource.recipe_resource_id
                   FROM dual;
                 INSERT INTO bds_recipe_resource
                        (recipe_resource_id,
                   		proc_order,
                   		operation,
                   		resource_code,
                   		batch_qty,
                   		batch_uom,
                   		plant)
                 VALUES (rcd_bds_recipe_resource.recipe_resource_id,
                   		rcd_bds_recipe_resource.proc_order,
	                     rcd_bds_recipe_resource.operation,
                   		rcd_bds_recipe_resource.resource_code,
                   		rcd_bds_recipe_resource.batch_qty,
                   		rcd_bds_recipe_resource.batch_uom,
                   		rcd_bds_recipe_resource.plant);
			    END IF;
         END IF;
      CLOSE csr_bds_recipe_resource_01;

		/****************************************************/


      /*-*/
      /*- end of additions */
      /*-*/



      /*-*/
      /* Insert the bds_recipe_bom row
      /*-*/
      INSERT INTO bds_recipe_bom
         (recipe_bom_id,
          proc_order,
          operation,
          phase,
          seq,
          material_code,
          material_desc,
          material_qty,
          material_uom,
          material_prnt,
          bf_item,
          reservation,
          plant,
          -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
          pan_size,
          last_pan_size,
          pan_size_flag,
          pan_qty)
         VALUES(rcd_bds_recipe_bom.recipe_bom_id,
                rcd_bds_recipe_bom.proc_order,
                rcd_bds_recipe_bom.operation,
                rcd_bds_recipe_bom.phase,
                rcd_bds_recipe_bom.seq,
                rcd_bds_recipe_bom.material_code,
                rcd_bds_recipe_bom.material_desc,
                rcd_bds_recipe_bom.material_qty,
                rcd_bds_recipe_bom.material_uom,
                rcd_bds_recipe_bom.material_prnt,
                rcd_bds_recipe_bom.bf_item,
                rcd_bds_recipe_bom.reservation,
                rcd_bds_recipe_bom.plant,
                -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
                rcd_bds_recipe_bom.pan_size,
                rcd_bds_recipe_bom.last_pan_size,
                rcd_bds_recipe_bom.pan_size_flag,
                rcd_bds_recipe_bom.pan_qty);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_zatlas;

   /*******************************************************/
   /* This procedure performs the process ZATLASA routine */
   /*******************************************************/
   PROCEDURE process_zatlasa IS

      /*-*/
      /* Local definitions
      /*-*/
      var_work VARCHAR2(1);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01 IS
         SELECT t01.pppi_output_text,
                t01.pppi_material_item,
                t01.pppi_reservation,
                t01.pppi_material,
                t01.pppi_material_quantity,
                t01.pppi_material_short_text,
                t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_unit_of_measure,
                t01.pppi_phase_resource,
                -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
                t01.z_ps_first_pan_in_num,
                t01.z_ps_last_pan_in_num,
                t01.z_ps_pan_size_yn,
                t01.z_ps_no_of_pans
           FROM (SELECT t01.cntl_rec_id,
                        t01.proc_instr_number,
                        MAX(CASE WHEN t01.name_char = 'PPPI_OUTPUT_TEXT' THEN t01.char_value END) AS pppi_output_text,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL_ITEM' THEN t01.char_value END) AS pppi_material_item,
                        MAX(CASE WHEN t01.name_char = 'PPPI_RESERVATION' THEN t01.char_value END) AS pppi_reservation,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL' THEN t01.char_value END) AS pppi_material,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL_QUANTITY' THEN t01.char_value END) AS pppi_material_quantity,
                        MAX(CASE WHEN t01.name_char = 'PPPI_MATERIAL_SHORT_TEXT' THEN t01.char_value END) AS pppi_material_short_text,
                        MAX(CASE WHEN t01.name_char = 'PPPI_OPERATION' THEN t01.char_value END) AS pppi_operation,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE' THEN t01.char_value END) AS pppi_phase,
                        MAX(CASE WHEN t01.name_char = 'PPPI_UNIT_OF_MEASURE' THEN t01.char_value END) AS pppi_unit_of_measure,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE_RESOURCE' THEN t01.char_value END) AS pppi_phase_resource,
                        -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
                        MAX(CASE WHEN t01.name_char = 'Z_PS_FIRST_PAN_IN_NUM' THEN t01.char_value END) AS z_ps_first_pan_in_num,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_LAST_PAN_IN_NUM' THEN t01.char_value END) AS z_ps_last_pan_in_num,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_PAN_SIZE_YN' THEN t01.char_value END) AS z_ps_pan_size_yn,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_NO_OF_PANS' THEN t01.char_value END) AS z_ps_no_of_pans
                   FROM lads_ctl_rec_vpi t01
                  WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    AND t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               GROUP BY t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_bds_recipe_resource_01 IS
         SELECT 'x'
           FROM bds_recipe_resource t01
          WHERE t01.proc_order = rcd_bds_recipe_resource.proc_order
            AND t01.operation = rcd_bds_recipe_resource.operation;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      END IF;

      /*-*/
      /* Ignore when action is null
      /*-*/
      IF var_action IS NULL THEN
         RETURN;
      END IF;

      /*-*/
      /* Retrieve the ZATLASA data from the LADS schema
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;
      FETCH csr_lads_ctl_rec_vpi_01 INTO rcd_lads_ctl_rec_vpi;
      IF csr_lads_ctl_rec_vpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || TO_CHAR(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      END IF;
      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      SELECT recipe_bom_id_seq.NEXTVAL INTO rcd_bds_recipe_bom.recipe_bom_id FROM dual;

      rcd_bds_recipe_bom.proc_order := rcd_bds_recipe_header.proc_order;

      rcd_bds_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_bds_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_bds_recipe_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;

      rcd_bds_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;

      rcd_bds_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.pppi_material_short_text;

      rcd_bds_recipe_bom.material_qty := NULL;
      BEGIN
		   IF INSTR(rcd_lads_ctl_rec_vpi.pppi_material_quantity,'E') > 0 THEN
			    rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
			ELSE
             rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_material_quantity,'FM999G999G999D999');
         END IF;

		EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_material_quantity || ') to a number');
      END;


      rcd_bds_recipe_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;

      rcd_bds_recipe_bom.material_prnt := NULL;

      rcd_bds_recipe_bom.bf_item := 'Y';
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.pppi_output_text)) = 'NON BACKFLUSHED ITEMS' THEN
         rcd_bds_recipe_bom.bf_item := 'N';
      END IF;

      rcd_bds_recipe_bom.reservation := rcd_lads_ctl_rec_vpi.pppi_reservation;

      rcd_bds_recipe_bom.plant := rcd_bds_recipe_header.plant;

      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comds in idoc
      /*-*/
      rcd_bds_recipe_bom.pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_bds_recipe_bom.pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_bds_recipe_bom.last_pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_bds_recipe_bom.last_pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_bds_recipe_bom.pan_size_flag := 'N';
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         rcd_bds_recipe_bom.pan_size_flag := 'Y';
      END IF;

      rcd_bds_recipe_bom.pan_qty := NULL;
      BEGIN
         rcd_bds_recipe_bom.pan_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans || ') to a number');
      END;

      /* update quantity if pan size is N or Y
      /*-*/
      IF rcd_bds_recipe_bom.material_qty IS NULL THEN
         IF rcd_bds_recipe_bom.pan_size_flag = 'N' THEN
            BEGIN
               rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
            END;
         ELSE
            BEGIN
               rcd_bds_recipe_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans -1) + TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || 'or' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num ||') to a number');
            END;
         END IF;
      END IF;

		rcd_bds_recipe_resource.proc_order := rcd_bds_recipe_header.proc_order;
		rcd_bds_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		rcd_bds_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
		rcd_bds_recipe_resource.batch_qty := NULL;
		rcd_bds_recipe_resource.batch_uom := NULL;
		rcd_bds_recipe_resource.plant := rcd_bds_recipe_header.plant;

		/*-*/
      /* Insert the bds_recipe_resource row when required
      /*-*/

		-- commented out until pan size section of recipe idoc sorted out
      OPEN csr_bds_recipe_resource_01;
         FETCH csr_bds_recipe_resource_01 INTO var_work;
         IF csr_bds_recipe_resource_01%NOTFOUND THEN
			    IF  rcd_bds_recipe_resource.operation  IS NOT NULL AND rcd_bds_recipe_resource.resource_code  IS NOT NULL THEN
                 SELECT recipe_resource_id_seq.NEXTVAL
                   INTO rcd_bds_recipe_resource.recipe_resource_id
                   FROM dual;
                 INSERT INTO bds_recipe_resource
                        (recipe_resource_id,
                   		proc_order,
                   		operation,
                   		resource_code,
                   		batch_qty,
                   		batch_uom,
                   		plant)
                 VALUES (rcd_bds_recipe_resource.recipe_resource_id,
                        rcd_bds_recipe_resource.proc_order,
                    		rcd_bds_recipe_resource.operation,
                   		rcd_bds_recipe_resource.resource_code,
                   		rcd_bds_recipe_resource.batch_qty,
                   		rcd_bds_recipe_resource.batch_uom,
                   		rcd_bds_recipe_resource.plant);
             END IF;
			END IF;
      CLOSE csr_bds_recipe_resource_01;




      /*- end of additions */
      /*------------------------------------------------------------------*/

      /*-*/
      /* Insert the bds_recipe_bom row
      /*-*/
      INSERT INTO bds_recipe_bom
         (recipe_bom_id,
          proc_order,
          operation,
          phase,
          seq,
          material_code,
          material_desc,
          material_qty,
          material_uom,
          material_prnt,
          bf_item,
          reservation,
          plant,
          -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
          pan_size,
          last_pan_size,
          pan_size_flag,
          pan_qty)
         VALUES(rcd_bds_recipe_bom.recipe_bom_id,
                rcd_bds_recipe_bom.proc_order,
                rcd_bds_recipe_bom.operation,
                rcd_bds_recipe_bom.phase,
                rcd_bds_recipe_bom.seq,
                rcd_bds_recipe_bom.material_code,
                rcd_bds_recipe_bom.material_desc,
                rcd_bds_recipe_bom.material_qty,
                rcd_bds_recipe_bom.material_uom,
                rcd_bds_recipe_bom.material_prnt,
                rcd_bds_recipe_bom.bf_item,
                rcd_bds_recipe_bom.reservation,
                rcd_bds_recipe_bom.plant,
                -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
                rcd_bds_recipe_bom.pan_size,
                rcd_bds_recipe_bom.last_pan_size,
                rcd_bds_recipe_bom.pan_size_flag,
                rcd_bds_recipe_bom.pan_qty);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_zatlasa;

   /*******************************************************/
   /* This procedure performs the process ZMESSRC routine */
   /*******************************************************/
   PROCEDURE process_zmessrc IS

      /*-*/
      /* Local definitions
      /*-*/
      var_work VARCHAR2(1 char);
      var_char VARCHAR2(1 char);
      var_next VARCHAR2(1 char);
      var_tab BOOLEAN;
      var_wrk_text VARCHAR2(256 char);
      var_text01 VARCHAR2(32767 char);
      var_text02 VARCHAR2(32767 char);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01 IS
         SELECT t01.pppi_phase_resource,
                t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_export_data,
                t01.z_src_type,
                t01.z_src_id,
                t01.z_src_description,
                t01.x_src_description,
                t01.z_src_long_text,
                t01.x_src_long_text,
                t01.z_src_value,
                t01.z_src_uom,
                t01.z_src_machine_id
           FROM (SELECT t01.cntl_rec_id,
                        t01.proc_instr_number,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE_RESOURCE' THEN t01.char_value END) AS pppi_phase_resource,
                        MAX(CASE WHEN t01.name_char = 'PPPI_OPERATION' THEN t01.char_value END) AS pppi_operation,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE' THEN t01.char_value END) AS pppi_phase,
                        MAX(CASE WHEN t01.name_char = 'PPPI_EXPORT_DATA' THEN t01.char_value END) AS pppi_export_data,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_TYPE' OR t01.name_char = 'Z_TYPE_SRC' THEN t01.char_value END) AS z_src_type,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_ID' OR t01.name_char = 'Z_ID_SRC'THEN t01.char_value END) AS z_src_id,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_DESCRIPTION' OR t01.name_char = 'Z_DESCRIPTION_SRC'THEN t01.char_value END) AS z_src_description,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_DESCRIPTION' OR t01.name_char = 'Z_DESCRIPTION_SRC' THEN t01.char_line_number END) AS x_src_description,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_LONG_TEXT' OR t01.name_char = 'PPPI_NOTE' THEN t01.char_value END) AS z_src_long_text,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_LONG_TEXT' OR t01.name_char = 'PPPI_NOTE' THEN t01.char_line_number END) AS x_src_long_text,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_VALUE' OR t01.name_char = 'Z_VALUE_SRC' THEN t01.char_value END) AS z_src_value,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_UOM' OR t01.name_char = 'Z_UOM_SRC' THEN t01.char_value END) AS z_src_uom,
                        MAX(CASE WHEN t01.name_char = 'Z_SRC_MACHINE_ID' OR t01.name_char = 'Z_MACHINE_ID_SRC' THEN t01.char_value END) AS z_src_machine_id
                   FROM lads_ctl_rec_vpi t01
                  WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    AND t01.proc_instr_number = rcd_lads_ctl_rec_tpi.proc_instr_number
               GROUP BY t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_lads_ctl_rec_txt_01 IS
         SELECT t01.tdformat,
                t01.tdline
           FROM lads_ctl_rec_txt t01
          WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
            AND t01.proc_instr_number = rcd_lads_ctl_rec_tpi.proc_instr_number
            AND t01.char_line_number = rcd_lads_ctl_rec_vpi.x_src_description
       ORDER BY t01.arrival_sequence;
      rcd_lads_ctl_rec_txt_01 csr_lads_ctl_rec_txt_01%ROWTYPE;

      CURSOR csr_lads_ctl_rec_txt_02 IS
         SELECT t01.tdformat,
                t01.tdline
           FROM lads_ctl_rec_txt t01
          WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
            AND t01.proc_instr_number = rcd_lads_ctl_rec_tpi.proc_instr_number
            AND t01.char_line_number = rcd_lads_ctl_rec_vpi.x_src_long_text
       ORDER BY t01.arrival_sequence;
      rcd_lads_ctl_rec_txt_02 csr_lads_ctl_rec_txt_02%ROWTYPE;

      CURSOR csr_bds_recipe_resource_01 IS
         SELECT 'x'
           FROM bds_recipe_resource t01
          WHERE t01.proc_order = rcd_bds_recipe_resource.proc_order
            AND t01.operation = rcd_bds_recipe_resource.operation;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZMESSRC - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      END IF;

      /*-*/
      /* Ignore when action is null
      /*-*/
      IF var_action IS NULL THEN
         RETURN;
      END IF;

      /*-*/
      /* Retrieve the ZMESSRC data from the LADS schema
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;
      FETCH csr_lads_ctl_rec_vpi_01 INTO rcd_lads_ctl_rec_vpi;
      IF csr_lads_ctl_rec_vpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZMESSRC - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || TO_CHAR(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      END IF;
      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Retrieve and concatenate the related description text
      /*-*/
      var_text01 := NULL;
      OPEN csr_lads_ctl_rec_txt_01;
      LOOP
         FETCH csr_lads_ctl_rec_txt_01 INTO rcd_lads_ctl_rec_txt_01;
         IF csr_lads_ctl_rec_txt_01%NOTFOUND THEN
            EXIT;
         END IF;
         IF NOT(var_text01 IS NULL) THEN
            IF rcd_lads_ctl_rec_txt_01.tdformat = '*' THEN
               var_text01 := var_text01 || chr(13);
            ELSE
               var_text01 := var_text01 || ' ';
            END IF;
         END IF;
         IF NOT(rcd_lads_ctl_rec_txt_01.tdline IS NULL) THEN
            var_wrk_text := NULL;
            var_tab := FALSE;
            FOR idx_chr IN 1..LENGTH(rcd_lads_ctl_rec_txt_01.tdline) LOOP
               IF var_tab = FALSE THEN
                  var_char := SUBSTR(rcd_lads_ctl_rec_txt_01.tdline, idx_chr, 1);
                  var_next := SUBSTR(rcd_lads_ctl_rec_txt_01.tdline, idx_chr + 1, 1);
                  IF var_char = ',' AND var_next = ',' THEN
                     var_wrk_text := var_wrk_text || CHR(9);
                     var_tab := TRUE;
                  ELSE
                     var_wrk_text := var_wrk_text || var_char;
                  END IF;
               ELSE
                  var_tab := FALSE;
               END IF;
            END LOOP;
            var_text01 := var_text01 || var_wrk_text;
         END IF;
      END LOOP;
      CLOSE csr_lads_ctl_rec_txt_01;

      /*-*/
      /* Retrieve and concatenate the related long text
      /*-*/
      var_text02 := NULL;
      OPEN csr_lads_ctl_rec_txt_02;
      LOOP
         FETCH csr_lads_ctl_rec_txt_02 INTO rcd_lads_ctl_rec_txt_02;
         IF csr_lads_ctl_rec_txt_02%NOTFOUND THEN
            EXIT;
         END IF;
         IF NOT(var_text02 IS NULL) THEN
            IF rcd_lads_ctl_rec_txt_02.tdformat = '*' THEN
               var_text02 := var_text02 || chr(13);
            ELSE
               var_text02 := var_text02 || ' ';
            END IF;
         END IF;
         IF NOT(rcd_lads_ctl_rec_txt_02.tdline IS NULL) THEN
            var_wrk_text := NULL;
            var_tab := FALSE;
            FOR idx_chr IN 1..LENGTH(rcd_lads_ctl_rec_txt_02.tdline) LOOP
               IF var_tab = FALSE THEN
                  var_char := SUBSTR(rcd_lads_ctl_rec_txt_02.tdline, idx_chr, 1);
                  var_next := SUBSTR(rcd_lads_ctl_rec_txt_02.tdline, idx_chr + 1, 1);
                  IF var_char = ',' AND var_next = ',' THEN
                     var_wrk_text := var_wrk_text || CHR(9);
                     var_tab := TRUE;
                  ELSE
                     var_wrk_text := var_wrk_text || var_char;
                  END IF;
               ELSE
                  var_tab := FALSE;
               END IF;
            END LOOP;
            var_text02 := var_text02 || var_wrk_text;
         END IF;
      END LOOP;
      CLOSE csr_lads_ctl_rec_txt_02;

      /*-*/
      /* Set and validate the bds_recipe_resource row data
      /*-*/
      IF NOT(rcd_lads_ctl_rec_vpi.pppi_operation IS NULL) AND
         NOT(rcd_lads_ctl_rec_vpi.pppi_phase_resource IS NULL) THEN

         rcd_bds_recipe_resource.proc_order := rcd_bds_recipe_header.proc_order;

         rcd_bds_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

         rcd_bds_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;

         rcd_bds_recipe_resource.batch_qty := NULL;

         rcd_bds_recipe_resource.batch_uom := NULL;

         rcd_bds_recipe_resource.plant := rcd_bds_recipe_header.plant;

         /*-*/
         /* Insert the bds_recipe_resource row when required
         /*-*/
         OPEN csr_bds_recipe_resource_01;
         FETCH csr_bds_recipe_resource_01 INTO var_work;
         IF csr_bds_recipe_resource_01%NOTFOUND THEN
            SELECT recipe_resource_id_seq.NEXTVAL
              INTO rcd_bds_recipe_resource.recipe_resource_id
              FROM dual;
            INSERT INTO bds_recipe_resource
                   (recipe_resource_id,
                   proc_order,
                   operation,
                   resource_code,
                   batch_qty,
                   batch_uom,
                   plant)
            VALUES (rcd_bds_recipe_resource.recipe_resource_id,
                   rcd_bds_recipe_resource.proc_order,
                   rcd_bds_recipe_resource.operation,
                   rcd_bds_recipe_resource.resource_code,
                   rcd_bds_recipe_resource.batch_qty,
                   rcd_bds_recipe_resource.batch_uom,
                   rcd_bds_recipe_resource.plant);
         END IF;
         CLOSE csr_bds_recipe_resource_01;

      END IF;

      /*-*/
      /* The bds_recipe_src_text row data
      /*-*/
      IF rcd_lads_ctl_rec_vpi.z_src_type = 'H' OR
         rcd_lads_ctl_rec_vpi.z_src_type = 'I' OR
         rcd_lads_ctl_rec_vpi.z_src_type = 'N' THEN

         /*-*/
         /* Set and validate the bds_recipe_src_text row data
         /*-*/
         SELECT recipe_src_text_id_seq.NEXTVAL INTO rcd_bds_recipe_src_text.recipe_src_text_id FROM dual;

         rcd_bds_recipe_src_text.proc_order := rcd_bds_recipe_header.proc_order;

         rcd_bds_recipe_src_text.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

         rcd_bds_recipe_src_text.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

	     /********************************/
	     /* Jeff Phillipson - 28/10/2004 */

         rcd_bds_recipe_src_text.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

	     /********************************/

         rcd_bds_recipe_src_text.src_text := rcd_lads_ctl_rec_vpi.z_src_description;
         IF NOT(var_text01 IS NULL) THEN
            rcd_bds_recipe_src_text.src_text := substrb(var_text01,1,4000);
         END IF;

         rcd_bds_recipe_src_text.src_type := rcd_lads_ctl_rec_vpi.z_src_type;

         rcd_bds_recipe_src_text.machine_code := rcd_lads_ctl_rec_vpi.z_src_machine_id;

         rcd_bds_recipe_src_text.detail_desc := rcd_lads_ctl_rec_vpi.z_src_long_text;
         IF NOT(var_text02 IS NULL) THEN
            rcd_bds_recipe_src_text.detail_desc := substrb(var_text02,1,4000);
         END IF;

         rcd_bds_recipe_src_text.plant := rcd_bds_recipe_header.plant;

         /*-*/
         /* Insert the CNTL_MPI_TXT row
         /*-*/
         INSERT INTO bds_recipe_src_text
                (recipe_src_text_id,
                proc_order,
                operation,
                phase,
                seq,
                src_text,
                src_type,
                machine_code,
                detail_desc,
                plant)
         VALUES (rcd_bds_recipe_src_text.recipe_src_text_id,
                rcd_bds_recipe_src_text.proc_order,
                rcd_bds_recipe_src_text.operation,
                rcd_bds_recipe_src_text.phase,
                rcd_bds_recipe_src_text.seq,
                rcd_bds_recipe_src_text.src_text,
                rcd_bds_recipe_src_text.src_type,
                rcd_bds_recipe_src_text.machine_code,
                rcd_bds_recipe_src_text.detail_desc,
                rcd_bds_recipe_src_text.plant);

      /*-*/
      /* The bds_recipe_resource row data
      /*-*/
      ELSIF rcd_lads_ctl_rec_vpi.z_src_type = 'B' THEN

         /*-*/
         /* Set and validate the bds_recipe_resource row data
         /*-*/
         IF NOT(rcd_lads_ctl_rec_vpi.pppi_operation IS NULL) AND
            NOT(rcd_lads_ctl_rec_vpi.pppi_phase_resource IS NULL) THEN

            /*-*/
            /* Set the values
            /*-*/
            IF NOT(rcd_lads_ctl_rec_vpi.pppi_export_data IS NULL) THEN
               rcd_bds_recipe_resource.batch_qty := rcd_lads_ctl_rec_vpi.pppi_export_data;
            ELSE
               rcd_bds_recipe_resource.batch_qty := rcd_lads_ctl_rec_vpi.z_src_value;
            END IF;
            rcd_bds_recipe_resource.batch_uom := rcd_lads_ctl_rec_vpi.z_src_uom;

            /*-*/
            /* Update the bds_recipe_resource row
            /*-*/
            UPDATE bds_recipe_resource
               SET batch_qty = rcd_bds_recipe_resource.batch_qty,
                   batch_uom = rcd_bds_recipe_resource.batch_uom
             WHERE proc_order = rcd_bds_recipe_header.proc_order
               AND operation = rcd_lads_ctl_rec_vpi.pppi_operation;

         END IF;

      /*-*/
      /* The bds_recipe_src_value row data
      /*-*/
      ELSIF (rcd_lads_ctl_rec_vpi.z_src_type = 'V' OR rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1') THEN

         /*-*/
         /* Set and validate the bds_recipe_src_value row data
         /*-*/
         SELECT recipe_src_value_id_seq.NEXTVAL INTO rcd_bds_recipe_src_value.recipe_src_value_id FROM dual;

         rcd_bds_recipe_src_value.proc_order := rcd_bds_recipe_header.proc_order;

         rcd_bds_recipe_src_value.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

         rcd_bds_recipe_src_value.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

	    /********************************/
	    /* Jeff Phillipson - 28/10/2004 */

         rcd_bds_recipe_src_value.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

	    /********************************/

         rcd_bds_recipe_src_value.src_tag := rcd_lads_ctl_rec_vpi.z_src_id;

         rcd_bds_recipe_src_value.src_desc := rcd_lads_ctl_rec_vpi.z_src_description;
         IF NOT(var_text01 IS NULL) THEN
            rcd_bds_recipe_src_value.src_desc := substrb(var_text01,1,2000);
         END IF;

         IF NOT(rcd_lads_ctl_rec_vpi.pppi_export_data IS NULL) THEN
            rcd_bds_recipe_src_value.src_val := rcd_lads_ctl_rec_vpi.pppi_export_data;
         ELSE
            rcd_bds_recipe_src_value.src_val := rcd_lads_ctl_rec_vpi.z_src_value;
         END IF;

         rcd_bds_recipe_src_value.src_uom := rcd_lads_ctl_rec_vpi.z_src_uom;

         rcd_bds_recipe_src_value.machine_code := rcd_lads_ctl_rec_vpi.z_src_machine_id;

         rcd_bds_recipe_src_value.detail_desc := rcd_lads_ctl_rec_vpi.z_src_long_text;
         IF NOT(var_text02 IS NULL) THEN
            rcd_bds_recipe_src_value.detail_desc := substrb(var_text02,1,4000);
         END IF;

         rcd_bds_recipe_src_value.plant := rcd_bds_recipe_header.plant;

         /*-*/
         /* Modify values if src type TEXT1 is used
         /*-*/
         IF rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1' THEN
            if lengthb(rcd_bds_recipe_src_value.src_desc||' '||LOWER(rcd_bds_recipe_src_value.src_val)||' '||LOWER(rcd_bds_recipe_src_value.src_uom)) > 2000 then
               rcd_bds_recipe_src_value.src_desc := substrb(rcd_bds_recipe_src_value.src_desc,1,(2000 - lengthb(' '||LOWER(rcd_bds_recipe_src_value.src_val)||' '||LOWER(rcd_bds_recipe_src_value.src_uom))));
            end if;
            rcd_bds_recipe_src_value.src_desc := rcd_bds_recipe_src_value.src_desc || ' ' || LOWER(rcd_bds_recipe_src_value.src_val) || ' ' || LOWER(rcd_bds_recipe_src_value.src_uom);
            rcd_bds_recipe_src_value.src_val := '';
            rcd_bds_recipe_src_value.src_uom := '';
         END IF;

         /*-*/
         /* Insert the CNTL_MPI_VAL row
         /*-*/
         INSERT INTO bds_recipe_src_value
                (recipe_src_value_id,
                proc_order,
                operation,
                phase,
                seq,
                src_tag,
                src_desc,
                src_val,
                src_uom,
                machine_code,
                detail_desc,
                plant)
         VALUES (rcd_bds_recipe_src_value.recipe_src_value_id,
                rcd_bds_recipe_src_value.proc_order,
                rcd_bds_recipe_src_value.operation,
                rcd_bds_recipe_src_value.phase,
                rcd_bds_recipe_src_value.seq,
                rcd_bds_recipe_src_value.src_tag,
                rcd_bds_recipe_src_value.src_desc,
                rcd_bds_recipe_src_value.src_val,
                rcd_bds_recipe_src_value.src_uom,
                rcd_bds_recipe_src_value.machine_code,
                rcd_bds_recipe_src_value.detail_desc,
                rcd_bds_recipe_src_value.plant);

	  END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_zmessrc;


   /******************************************************/
   /* This procedure performs the process ZPHPAN1 routine */
   /******************************************************/
   PROCEDURE process_zphpan1 IS

      /*-*/
      /* Local definitions
      /*-*/
      var_work VARCHAR2(1);
      var_space NUMBER;
      var_space1 NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01 IS
         SELECT t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_phase_resource,
                t01.z_ps_first_pan_out_char,
                t01.z_ps_material,
                t01.z_ps_material_short_text,
                t01.z_ps_material_qty_char,
                t01.z_ps_no_of_pans,
                t01.z_ps_last_pan_out_char
           FROM (SELECT t01.cntl_rec_id,
                        t01.proc_instr_number,
                        MAX(CASE WHEN t01.name_char = 'PPPI_OPERATION' THEN t01.char_value END) AS pppi_operation,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE' THEN t01.char_value END) AS pppi_phase,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE_RESOURCE' THEN t01.char_value END) AS pppi_phase_resource,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_FIRST_PAN_OUT_CHAR' THEN t01.char_value END) AS z_ps_first_pan_out_char,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_MATERIAL' THEN t01.char_value END) AS z_ps_material,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_MATERIAL_SHORT_TEXT' THEN t01.char_value END) AS z_ps_material_short_text,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_MATERIAL_QTY_CHAR' THEN t01.char_value END) AS z_ps_material_qty_char,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_NO_OF_PANS' THEN t01.char_value END) AS z_ps_no_of_pans,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_LAST_PAN_OUT_CHAR' THEN t01.char_value END) AS z_ps_last_pan_out_char
                   FROM lads_ctl_rec_vpi t01
                  WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    AND t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               GROUP BY t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_bds_recipe_resource_01 IS
         SELECT 'x'
           FROM bds_recipe_resource t01
          WHERE t01.proc_order = rcd_bds_recipe_resource.proc_order
            AND t01.operation = rcd_bds_recipe_resource.operation;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      END IF;

      /*-*/
      /* Ignore when action is null
      /*-*/
      IF var_action IS NULL THEN
         RETURN;
      END IF;

      /*-*/
      /* Retrieve the ZATLAS data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;
      FETCH csr_lads_ctl_rec_vpi_01 INTO rcd_lads_ctl_rec_vpi;
      IF csr_lads_ctl_rec_vpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || TO_CHAR(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      END IF;
      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      SELECT recipe_bom_id_seq.NEXTVAL INTO rcd_bds_recipe_bom.recipe_bom_id FROM dual;

      rcd_bds_recipe_bom.proc_order := rcd_bds_recipe_header.proc_order;

      /*-*/
      /* copy phase into operation - its not sent in the latest Idoc
      /*-*/
		IF rcd_lads_ctl_rec_vpi.pppi_operation IS NULL THEN
			rcd_bds_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
		ELSE
      	 rcd_bds_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		END IF;
      rcd_bds_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_bds_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;

      rcd_bds_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.z_ps_material_short_text;

      rcd_bds_recipe_bom.phantom := 'M';  -- Phantom made location

      rcd_bds_recipe_bom.pan_qty :=  rcd_lads_ctl_rec_vpi.z_ps_no_of_pans;

      rcd_bds_recipe_bom.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

      rcd_bds_recipe_bom.material_uom := trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1));

      rcd_bds_recipe_bom.plant := rcd_bds_recipe_header.plant;

      /*-*/
      /* seperate out qty and uom values
      /*-*/
      rcd_bds_recipe_bom.material_qty := NULL;
      rcd_bds_recipe_bom.pan_size := NULL;
      rcd_bds_recipe_bom.last_pan_size := NULL;
      IF rcd_lads_ctl_rec_vpi.z_ps_no_of_pans = 0 THEN

         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,' ');
         BEGIN
            rcd_bds_recipe_bom.material_qty := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,1,var_space - 1)),'FM999G999G999D999');
            rcd_bds_recipe_bom.material_uom := UPPER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char || ') to a number');
         END;

      ELSE
         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char,' ');
         var_space1 := INSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,' ');
         BEGIN
            rcd_bds_recipe_bom.pan_size := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char, 1, var_space - 1)),'FM999G999G999D999');
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, ' Process ZPHPAN1 - Field - FIRST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char || ') to a number');
         END;

         BEGIN
            rcd_bds_recipe_bom.last_pan_size := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,1,var_space1 - 1)),'FM999G999G999D999');
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char || ') TO a NUMBER');
         END;

         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,' ');
         BEGIN
            rcd_bds_recipe_bom.material_qty := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,1,var_space - 1)) ,'FM999G999G999D999');
            rcd_bds_recipe_bom.material_uom := UPPER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Field - MATERIAL_QTY WITH Pan Qty - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char || ') to a number');
         END;

         rcd_bds_recipe_bom.pan_size_flag := 'Y';

      END IF;


      /*-*/
      /* now update the bds_recipe_header_RESOURECE table
      /*-*/
      rcd_bds_recipe_resource.proc_order := rcd_bds_recipe_header.proc_order;

      rcd_bds_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_bds_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;

      rcd_bds_recipe_resource.plant := rcd_bds_recipe_header.plant;

      /*-*/
      /* Insert the bds_recipe_resource row when required
      /*-*/
      OPEN csr_bds_recipe_resource_01;
      FETCH csr_bds_recipe_resource_01 INTO var_work;
      IF csr_bds_recipe_resource_01%NOTFOUND THEN
		   IF  rcd_bds_recipe_resource.operation  IS NOT NULL THEN
             SELECT recipe_resource_id_seq.NEXTVAL
               INTO rcd_bds_recipe_resource.recipe_resource_id
               FROM dual;
             INSERT INTO bds_recipe_resource
                    (recipe_resource_id,
                    proc_order,
                    operation,
                    resource_code,
                    plant)
             VALUES (rcd_bds_recipe_resource.recipe_resource_id,
                    rcd_bds_recipe_resource.proc_order,
                    rcd_bds_recipe_resource.operation,
                    rcd_bds_recipe_resource.resource_code,
                    rcd_bds_recipe_resource.plant);
			END IF;
      END IF;
      CLOSE csr_bds_recipe_resource_01;

      /*-*/
      /* Insert the bds_recipe_bom row
      /*-*/
      INSERT INTO bds_recipe_bom
             (recipe_bom_id,
             proc_order,
             operation,
             phase,
             seq,
             material_code,
             material_desc,
             material_qty,
             material_uom,
             material_prnt,
             bf_item,
             reservation,
             plant,
             pan_size,
             last_pan_size,
             pan_size_flag,
             pan_qty,
             phantom)
      VALUES (rcd_bds_recipe_bom.recipe_bom_id,
             rcd_bds_recipe_bom.proc_order,
             rcd_bds_recipe_bom.operation,
             rcd_bds_recipe_bom.phase,
             rcd_bds_recipe_bom.seq,
             rcd_bds_recipe_bom.material_code,
             rcd_bds_recipe_bom.material_desc,
             rcd_bds_recipe_bom.material_qty,
             rcd_bds_recipe_bom.material_uom,
             rcd_bds_recipe_bom.material_prnt,
             rcd_bds_recipe_bom.bf_item,
             rcd_bds_recipe_bom.reservation,
             rcd_bds_recipe_bom.plant,
             rcd_bds_recipe_bom.pan_size,
             rcd_bds_recipe_bom.last_pan_size,
             rcd_bds_recipe_bom.pan_size_flag,
             rcd_bds_recipe_bom.pan_qty,
             rcd_bds_recipe_bom.phantom);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_zphpan1;

   /******************************************************/
   /* This procedure performs the process ZPHBRQ1 routine */
   /******************************************************/
   PROCEDURE process_zphbrq1 IS

      /*-*/
      /* Local definitions
      /*-*/
      var_work VARCHAR2(1);
      var_space NUMBER;
      var_space1 NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_lads_ctl_rec_vpi_01 IS
         SELECT t01.pppi_operation,
                t01.pppi_phase,
                t01.pppi_phase_resource,
                t01.z_ps_predecessor,
                t01.z_ps_first_pan_in_char,
                t01.z_ps_material,
                t01.z_ps_material_short_text,
                t01.z_ps_last_pan_in_char,
                t01.z_ps_pan_size_yn
           FROM (SELECT t01.cntl_rec_id,
                        t01.proc_instr_number,
                        MAX(CASE WHEN t01.name_char = 'PPPI_OPERATION' THEN t01.char_value END) AS pppi_operation,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE' THEN t01.char_value END) AS pppi_phase,
                        MAX(CASE WHEN t01.name_char = 'PPPI_PHASE_RESOURCE' THEN t01.char_value END) AS pppi_phase_resource,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_PREDECESSOR' THEN t01.char_value END) AS z_ps_predecessor,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_FIRST_PAN_IN_CHAR' THEN t01.char_value END) AS z_ps_first_pan_in_char,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_MATERIAL' THEN t01.char_value END) AS z_ps_material,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_MATERIAL_SHORT_TEXT' THEN t01.char_value END) AS z_ps_material_short_text,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_LAST_PAN_IN_CHAR' THEN t01.char_value END) AS z_ps_last_pan_in_char,
                        MAX(CASE WHEN t01.name_char = 'Z_PS_PAN_SIZE_YN' THEN t01.char_value END) AS z_ps_pan_size_yn
                   FROM lads_ctl_rec_vpi t01
                  WHERE t01.cntl_rec_id = rcd_lads_ctl_rec_tpi.cntl_rec_id
                    AND t01.proc_instr_number =  rcd_lads_ctl_rec_tpi.proc_instr_number
               GROUP BY t01.cntl_rec_id,
                        t01.proc_instr_number) t01;
      rcd_lads_ctl_rec_vpi csr_lads_ctl_rec_vpi_01%ROWTYPE;

      CURSOR csr_bds_recipe_resource_01 IS
         SELECT 'x'
           FROM bds_recipe_resource t01
          WHERE t01.proc_order = rcd_bds_recipe_resource.proc_order
            AND t01.operation = rcd_bds_recipe_resource.operation;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Control recipe must have a ZORDINE process instruction
      /*-*/
      IF var_zordine = FALSE THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') does not have a ZORDINE process instruction on LADS_CTL_REC_TPI');
      END IF;

      /*-*/
      /* Ignore when action is null
      /*-*/
      IF var_action IS NULL THEN
         RETURN;
      END IF;

      /*-*/
      /* Retrieve the ZPHBRQ1 data (LADS schema)
      /*-*/
      OPEN csr_lads_ctl_rec_vpi_01;
      FETCH csr_lads_ctl_rec_vpi_01 INTO rcd_lads_ctl_rec_vpi;
      IF csr_lads_ctl_rec_vpi_01%NOTFOUND THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Control recipe id (' || TO_CHAR(rcd_lads_ctl_rec_tpi.cntl_rec_id) || ') process instruction number (' || TO_CHAR(rcd_lads_ctl_rec_tpi.proc_instr_number,'FM99999990') || ') has no associated rows on LADS_CTL_REC_VPI');
      END IF;
      CLOSE csr_lads_ctl_rec_vpi_01;

      /*-*/
      /* Set and validate the bds_recipe_bom row data
      /*-*/
      SELECT recipe_bom_id_seq.NEXTVAL INTO rcd_bds_recipe_bom.recipe_bom_id FROM dual;

      rcd_bds_recipe_bom.proc_order := rcd_bds_recipe_header.proc_order;

      /*-*/
      /* Idoc doesn't send operation so make the operation and phase the same
      /*-*/
		IF rcd_lads_ctl_rec_vpi.pppi_operation IS NULL THEN
		    rcd_bds_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
		ELSE
          rcd_bds_recipe_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		END IF;
      rcd_bds_recipe_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_bds_recipe_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;

      rcd_bds_recipe_bom.material_desc := rcd_lads_ctl_rec_vpi.z_ps_material_short_text;

      rcd_bds_recipe_bom.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

      rcd_bds_recipe_bom.plant := rcd_bds_recipe_header.plant;

      rcd_bds_recipe_bom.operation_from := rcd_lads_ctl_rec_vpi.z_ps_predecessor;

      rcd_bds_recipe_bom.phantom := 'U';  -- Phantom used location

      rcd_bds_recipe_bom.pan_size_flag := rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn;

      rcd_bds_recipe_bom.pan_qty := NULL;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      rcd_bds_recipe_bom.material_qty := NULL;
      rcd_bds_recipe_bom.pan_size := NULL;
      rcd_bds_recipe_bom.last_pan_size := NULL;

      IF rcd_bds_recipe_bom.pan_size_flag = 'N' OR rcd_bds_recipe_bom.pan_size_flag = 'E' THEN

         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,' ');

         BEGIN
		    IF var_space = 0 THEN
			    rcd_bds_recipe_bom.material_qty := TO_NUMBER(trim(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char),'FM999G999G999D999');
			ELSE
                rcd_bds_recipe_bom.material_qty := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1, var_space - 1)),'FM999G999G999D999');
         	END IF;
		 EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Field - material qty - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ') to a number');
         END;

      ELSE




         /*-*/
         /* get material qty using first and last pan qty
         /*-*/
         BEGIN
			    /*-*/
			    /* check on the type of number ie 1,0000 ot 1.098+E2 etc
			    /*-*/
			    IF INSTR(trim(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char),'E') > 0 THEN
				     rcd_bds_recipe_bom.material_qty := (TO_NUMBER(TRIM(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char)) + TO_NUMBER(trim(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char)));
				 ELSE
				     var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,' ');
         		  var_space1 := INSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,' ');
            	  rcd_bds_recipe_bom.material_qty := (TO_NUMBER(TRIM(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1,var_space -1)),'FM999G999G999D999') * 1) + TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,1,var_space1 -1)),'FM999G999G999D999');
             END IF;
			EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ' or ' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char ||') to a number');
         END;

         /*-*/
         /* get pan size
         /*-*/
         rcd_bds_recipe_bom.pan_size := NULL;
         BEGIN
            rcd_bds_recipe_bom.pan_size := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1,var_space - 1)),'FM999G999G999D999');
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1  - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ') to a number');
         END;

         /*-*/
         /* get last pan size
         /*-*/
         rcd_bds_recipe_bom.last_pan_size := NULL;
         BEGIN
		    /*-*/
		    /* Changed the variable name from var_space to var_space1
		    /* Added by JP 26 May 2006
		    /* For the first time a Proc Order was sent with a smaller numerical value length for last_pan_size
		    /*-*/
            rcd_bds_recipe_bom.last_pan_size := TO_NUMBER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,1,var_space1 - 1)),'FM999G999G999D999');
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char || ') to a number');
         END;
      END IF;

      IF var_space  = 0 THEN
	      rcd_bds_recipe_bom.material_uom := NULL;
	  ELSE
	     rcd_bds_recipe_bom.material_uom := UPPER(TRIM(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char, var_space + 1)));
      END IF;

      /*-*/
      /* now update the bds_recipe_header_RESOURECE table
      /*-*/
      rcd_bds_recipe_resource.proc_order := rcd_bds_recipe_header.proc_order;

      rcd_bds_recipe_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_bds_recipe_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;

      rcd_bds_recipe_resource.plant := rcd_bds_recipe_header.plant;

      /*-*/
      /* Insert the bds_recipe_resource row when required
      /*-*/
      OPEN csr_bds_recipe_resource_01;
      FETCH csr_bds_recipe_resource_01 INTO var_work;
      IF csr_bds_recipe_resource_01%NOTFOUND THEN
		    IF  rcd_bds_recipe_resource.operation  IS NOT NULL THEN
             SELECT recipe_resource_id_seq.NEXTVAL
               INTO rcd_bds_recipe_resource.recipe_resource_id
               FROM dual;
             INSERT INTO bds_recipe_resource
                    (recipe_resource_id,
                    proc_order,
                    operation,
                    resource_code,
                    plant)
             VALUES (rcd_bds_recipe_resource.recipe_resource_id,
                    rcd_bds_recipe_resource.proc_order,
                    rcd_bds_recipe_resource.operation,
                    rcd_bds_recipe_resource.resource_code,
                    rcd_bds_recipe_resource.plant);
		    END IF;
      END IF;
      CLOSE csr_bds_recipe_resource_01;

      /*-*/
      /* Insert the bds_recipe_bom row 
      /*-*/
      INSERT INTO bds_recipe_bom
             (recipe_bom_id,
             proc_order,
             operation,
             phase,
             seq,
             material_code,
             material_desc,
             material_qty,
             material_uom,
             material_prnt,
             bf_item,
             reservation,
             plant,
             pan_size,
             last_pan_size,
             pan_size_flag,
             pan_qty,
             phantom,
             operation_from)
      VALUES (rcd_bds_recipe_bom.recipe_bom_id,
             rcd_bds_recipe_bom.proc_order,
             rcd_bds_recipe_bom.operation,
             rcd_bds_recipe_bom.phase,
             rcd_bds_recipe_bom.seq,
             rcd_bds_recipe_bom.material_code,
             rcd_bds_recipe_bom.material_desc,
             rcd_bds_recipe_bom.material_qty,
             rcd_bds_recipe_bom.material_uom,
             rcd_bds_recipe_bom.material_prnt,
             rcd_bds_recipe_bom.bf_item,
             rcd_bds_recipe_bom.reservation,
             rcd_bds_recipe_bom.plant,
             rcd_bds_recipe_bom.pan_size,
             rcd_bds_recipe_bom.last_pan_size,
             rcd_bds_recipe_bom.pan_size_flag,
             rcd_bds_recipe_bom.pan_qty,
             rcd_bds_recipe_bom.phantom,
             rcd_bds_recipe_bom.operation_from);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_zphbrq1;

end bds_atllad01_flatten;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bds_atllad01_flatten for bds_app.bds_atllad01_flatten;
grant execute on bds_atllad01_flatten to lics_app;
grant execute on bds_atllad01_flatten to lads_app;