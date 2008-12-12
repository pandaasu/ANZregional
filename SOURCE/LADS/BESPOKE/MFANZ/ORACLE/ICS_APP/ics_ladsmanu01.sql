CREATE OR REPLACE PACKAGE ICS_APP.ics_ladsmanu01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_cntl_rec_id in number);

end ics_ladsmanu01;
/


CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_ladsmanu01 AS

	/*-*/
	/*	 VERSION
	/*	 Problem found when LAST_PAN_SIZE in ZPHBRQ1 has a numerical value with a shorter length than
	/*   PAN_SIZE. The variable var_space was being used for the length of both fields
	/*   when var_space1 should have been used for LAST_PAN_SIZE
	/*   Added by JP 26 May 2006  - search on the text in the bracket to find the change {Added by JP 26 May 2006}
	/*   Jeff Phillipson Changed format of TO_NUMBER from 999G999D999 to FM999G999G999D999 (11 occurances)
	/*   Added by SG 25 May 2007  - modified cursors for performance
	/*   Added by SG 07 Jun 2007  - included ZATLAS2 test
	/*   Added by SG 19 Jun 2007  - included text truncation (max 2000/4000)
	/*   Added by SG 27 Jul 2007  - included validation process order logic
	/*   Added by SG 22 Aug 2007  - excluded AU10 and NZ01 from validation process order logic
  /*   Added by TK 17 Mar 2008  - removed AU10 from validation process order exclusions
  /*   Added by TK 10 Dec 2008  - added check for missing ',' when doing to_number with FM999G999G999D999 
  /*                              format using convert_to_number.
	/*-*/

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   PROCEDURE process_zordine;
   PROCEDURE process_zatlas;
   PROCEDURE process_zatlasa;
   PROCEDURE process_zmessrc;
   PROCEDURE process_zphpan1;
   PROCEDURE process_zphbrq1;
   FUNCTION convert_to_number(par_value varchar2) return number;

   /*-*/
   /* Private definitions
   /*-*/
   var_action VARCHAR2(1);
   var_zordine BOOLEAN;
   rcd_lads_ctl_rec_hpi lads_ctl_rec_hpi%ROWTYPE;
   rcd_lads_ctl_rec_tpi lads_ctl_rec_tpi%ROWTYPE;
   rcd_cntl_rec CNTL_REC%ROWTYPE;
   rcd_cntl_rec_bom CNTL_REC_BOM%ROWTYPE;
   rcd_cntl_rec_resource CNTL_REC_RESOURCE%ROWTYPE;
   rcd_cntl_rec_mpi_val CNTL_REC_MPI_VAL%ROWTYPE;
   rcd_cntl_rec_mpi_txt CNTL_REC_MPI_TXT%ROWTYPE;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   PROCEDURE EXECUTE(par_cntl_rec_id IN NUMBER) IS

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
      /* Commit the database
      /*-*/
      COMMIT;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Rollback the database
         /*-*/
         ROLLBACK;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'ICS_LADSMANU01 - in ' || rcd_lads_ctl_rec_tpi.proc_instr_category || ' - ' || SUBSTR(SQLERRM, 1, 512));
		 /*-*/
		 /*  raise tivoli alert
		 /*-*/
		-- LICS_NOTIFICATION.SEND_ALERT( '[PROC ORDER ALERT] ' || rcd_lads_ctl_rec_tpi.proc_instr_category || ' ' || SUBSTR(SQLERRM, 1, 200) );


   /*-------------*/
   /* End routine */
   /*-------------*/
   END EXECUTE;

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

      CURSOR csr_cntl_rec_01 IS
         SELECT t01.cntl_rec_id,
                t01.idoc_timestamp
           FROM CNTL_REC t01
          WHERE t01.proc_order = rcd_cntl_rec.proc_order;
      rcd_cntl_rec_01 csr_cntl_rec_01%ROWTYPE;

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
      /* Set and validate the CNTL_REC row data (MANU schema)
      /* **note** Process orders starting with a non-numeric character represent validation process orders
      /*-*/
      rcd_cntl_rec.proc_order := rcd_lads_ctl_rec_vpi.pppi_process_order;
      if not(rcd_cntl_rec.proc_order is null) then
         if substr(rcd_cntl_rec.proc_order,1,1) < '0' or substr(rcd_cntl_rec.proc_order,1,1) > '9' then
            if rcd_lads_ctl_rec_hpi.plant != 'NZ01' then
               select manu_recipe_sequence.nextval into var_process_order from dual;
               rcd_cntl_rec.proc_order := substr(rcd_cntl_rec.proc_order,1,1) || to_char(var_process_order,'fm00000000000');
            else
               raise_application_error(-20000, 'Process ZORDINE - Field - Validation PROC_ORDER - cannot be sent for NZ01');
            end if;
         end if;
      else
         raise_application_error(-20000, 'Process ZORDINE - Field - PROC_ORDER - Must not be null');
      end if;

      rcd_cntl_rec.cntl_rec_id := rcd_lads_ctl_rec_hpi.cntl_rec_id;

      rcd_cntl_rec.plant := rcd_lads_ctl_rec_hpi.plant;
      IF rcd_cntl_rec.plant IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - PLANT - Must not be null');
      END IF;

      rcd_cntl_rec.cntl_rec_status := rcd_lads_ctl_rec_hpi.cntl_rec_status;

      rcd_cntl_rec.test_flag := rcd_lads_ctl_rec_hpi.test_flag;

      rcd_cntl_rec.recipe_text := rcd_lads_ctl_rec_hpi.recipe_text;

      rcd_cntl_rec.material := rcd_lads_ctl_rec_hpi.material;
      IF rcd_cntl_rec.material IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - MATERIAL - Must not be null');
      END IF;

      rcd_cntl_rec.material_text := rcd_lads_ctl_rec_hpi.material_text;

      rcd_cntl_rec.quantity := NULL;
      BEGIN
         rcd_cntl_rec.quantity := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_order_quantity);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - QUANTITY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_order_quantity || ') to a number');
      END;

      rcd_cntl_rec.insplot := rcd_lads_ctl_rec_hpi.insplot;

      rcd_cntl_rec.uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;

      rcd_cntl_rec.batch := rcd_lads_ctl_rec_hpi.batch;

      rcd_cntl_rec.sched_start_datime := NULL;
      BEGIN
         rcd_cntl_rec.sched_start_datime := TO_DATE(rcd_lads_ctl_rec_hpi.scheduled_start_date || rcd_lads_ctl_rec_hpi.scheduled_start_time,'YYYYMMDDHH24MISS');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - SCHED_START_DATIME - Unable to convert (' || rcd_lads_ctl_rec_hpi.scheduled_start_date || rcd_lads_ctl_rec_hpi.scheduled_start_time || ') to a date using format (YYYYMMDDHH24MISS)');
      END;

      rcd_cntl_rec.run_start_datime := NULL;
      BEGIN
         rcd_cntl_rec.run_start_datime := TO_DATE(rcd_lads_ctl_rec_vpi.zpppi_order_start_date || rcd_lads_ctl_rec_vpi.zpppi_order_start_time,'YYYYMMDDHH24MISS');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - RUN_START_DATIME - Unable to convert (' || rcd_lads_ctl_rec_vpi.zpppi_order_start_date || rcd_lads_ctl_rec_vpi.zpppi_order_start_time || ') to a date using format (YYYYMMDDHH24MISS)');
      END;
      IF rcd_cntl_rec.run_start_datime IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - RUN_START_DATIME - Must not be null');
      END IF;

      rcd_cntl_rec.run_end_datime := NULL;
      BEGIN
         rcd_cntl_rec.run_end_datime := TO_DATE(rcd_lads_ctl_rec_vpi.zpppi_order_end_date || rcd_lads_ctl_rec_vpi.zpppi_order_end_time,'YYYYMMDDHH24MISS');
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZORDINE - Field - RUN_END_DATIME - Unable to convert (' || rcd_lads_ctl_rec_vpi.zpppi_order_end_date || rcd_lads_ctl_rec_vpi.zpppi_order_end_time || ') to a date using format (YYYYMMDDHH24MISS)');
      END;
      IF rcd_cntl_rec.run_end_datime IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000,' Process ZORDINE - Field - RUN_END_DATIME - Must not be null');
      END IF;

      rcd_cntl_rec.VERSION := 1;

      rcd_cntl_rec.upd_datime := SYSDATE;

      rcd_cntl_rec.cntl_rec_xfer := 'N';

      rcd_cntl_rec.teco_status := rcd_lads_ctl_rec_vpi.z_teco_status;

      rcd_cntl_rec.storage_locn := rcd_lads_ctl_rec_vpi.pppi_storage_location;

      rcd_cntl_rec.idoc_timestamp := rcd_lads_ctl_rec_hpi.idoc_timestamp;

      /*-*/
      /* Retrieve the CNTL_REC data (MANU schema)
      /*    - insert new process order when none found
      /*    - replace existing process order when control recipe identifier is greater
      /*-*/
      OPEN csr_cntl_rec_01;
      FETCH csr_cntl_rec_01 INTO rcd_cntl_rec_01;
      IF csr_cntl_rec_01%NOTFOUND THEN
         var_action := 'I';
      ELSE
         IF rcd_cntl_rec.idoc_timestamp > rcd_cntl_rec_01.idoc_timestamp THEN
            var_action := 'R';
         END IF;
      END IF;
      CLOSE csr_cntl_rec_01;

      /*-*/
      /* Replace an existing process order
      /*-*/
      IF var_action = 'R' THEN

         /*-*/
         /* Remove any existing child data from the MANU schema
         /*-*/
         DELETE FROM CNTL_REC_MPI_TXT WHERE proc_order = rcd_cntl_rec.proc_order;
         DELETE FROM CNTL_REC_MPI_VAL WHERE proc_order = rcd_cntl_rec.proc_order;
         DELETE FROM CNTL_REC_RESOURCE WHERE proc_order = rcd_cntl_rec.proc_order;
         DELETE FROM CNTL_REC_BOM WHERE proc_order = rcd_cntl_rec.proc_order;


         /*-*/
         /* Update the CNTL_REC row (MANU schema)
         /*-*/
         UPDATE CNTL_REC
            SET cntl_rec_id = rcd_cntl_rec.cntl_rec_id,
                plant = rcd_cntl_rec.plant,
                cntl_rec_status = rcd_cntl_rec.cntl_rec_status,
                test_flag = rcd_cntl_rec.test_flag,
                recipe_text = rcd_cntl_rec.recipe_text,
                material = rcd_cntl_rec.material,
                material_text = rcd_cntl_rec.material_text,
                quantity = rcd_cntl_rec.quantity,
                insplot = rcd_cntl_rec.insplot,
                uom = rcd_cntl_rec.uom,
                batch = rcd_cntl_rec.batch,
                sched_start_datime = rcd_cntl_rec.sched_start_datime,
                run_start_datime = rcd_cntl_rec.run_start_datime,
                run_end_datime = rcd_cntl_rec.run_end_datime,
                VERSION = VERSION + 1,
                upd_datime = rcd_cntl_rec.upd_datime,
                cntl_rec_xfer = rcd_cntl_rec.cntl_rec_xfer,
                teco_status = rcd_cntl_rec.teco_status,
                storage_locn = rcd_cntl_rec.storage_locn,
                idoc_timestamp = rcd_cntl_rec.idoc_timestamp
          WHERE proc_order = rcd_cntl_rec.proc_order;

      END IF;

      /*-*/
      /* Insert a new process order
      /*-*/
      IF var_action = 'I' THEN

         /*-*/
         /* Insert the CNTL_REC row (MANU schema)
         /*-*/
         INSERT INTO CNTL_REC
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
            VALUES(rcd_cntl_rec.proc_order,
                   rcd_cntl_rec.cntl_rec_id,
                   rcd_cntl_rec.plant,
                   rcd_cntl_rec.cntl_rec_status,
                   rcd_cntl_rec.test_flag,
                   rcd_cntl_rec.recipe_text,
                   rcd_cntl_rec.material,
                   rcd_cntl_rec.material_text,
                   rcd_cntl_rec.quantity,
                   rcd_cntl_rec.insplot,
                   rcd_cntl_rec.uom,
                   rcd_cntl_rec.batch,
                   rcd_cntl_rec.sched_start_datime,
                   rcd_cntl_rec.run_start_datime,
                   rcd_cntl_rec.run_end_datime,
                   rcd_cntl_rec.VERSION,
                   rcd_cntl_rec.upd_datime,
                   rcd_cntl_rec.cntl_rec_xfer,
                   rcd_cntl_rec.teco_status,
                   rcd_cntl_rec.storage_locn,
                   rcd_cntl_rec.idoc_timestamp);

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

      CURSOR csr_cntl_rec_resource_01 IS
         SELECT 'x'
           FROM CNTL_REC_RESOURCE t01
          WHERE t01.proc_order = rcd_cntl_rec_resource.proc_order
            AND t01.operation = rcd_cntl_rec_resource.operation;


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
      /* Set and validate the CNTL_REC_BOM row data (MANU schema)
      /*-*/
      SELECT cntl_rec_bom_id_seq.NEXTVAL INTO rcd_cntl_rec_bom.cntl_rec_bom_id FROM dual;

      rcd_cntl_rec_bom.proc_order := rcd_cntl_rec.proc_order;

      rcd_cntl_rec_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_cntl_rec_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_cntl_rec_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;

      rcd_cntl_rec_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;

      rcd_cntl_rec_bom.material_desc := rcd_lads_ctl_rec_vpi.pppi_material_short_text;

      rcd_cntl_rec_bom.material_qty := NULL;
      BEGIN
         rcd_cntl_rec_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process  ZBFBRQ1 (ZATLAS) - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_material_quantity || ') to a number');
      END;

      rcd_cntl_rec_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;

      rcd_cntl_rec_bom.material_prnt := NULL;

      rcd_cntl_rec_bom.bf_item := NULL;

      rcd_cntl_rec_bom.reservation := NULL;

      rcd_cntl_rec_bom.plant := rcd_cntl_rec.plant;

      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comands in idoc - Atlas 3.1
      /*-*/
      rcd_cntl_rec_bom.pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_cntl_rec_bom.pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_cntl_rec_bom.last_pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_cntl_rec_bom.last_pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_cntl_rec_bom.pan_size_flag := 'N';
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         rcd_cntl_rec_bom.pan_size_flag := 'Y';
      END IF;

      rcd_cntl_rec_bom.pan_qty := NULL;
      BEGIN
         rcd_cntl_rec_bom.pan_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans || ') to a number');
      END;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      IF rcd_cntl_rec_bom.material_qty IS NULL THEN
         IF rcd_cntl_rec_bom.pan_size_flag = 'N' THEN
            BEGIN
               rcd_cntl_rec_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
            END;
         ELSE
            BEGIN
               rcd_cntl_rec_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans -1) + TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZBFBRQ1 (ZATLAS) - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || 'or' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num ||') to a number');
            END;
         END IF;
      END IF;

		/* add a resource record here if you can */

		rcd_cntl_rec_resource.proc_order := rcd_cntl_rec.proc_order;
		rcd_cntl_rec_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		rcd_cntl_rec_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
		rcd_cntl_rec_resource.batch_qty := NULL;
		rcd_cntl_rec_resource.batch_uom := NULL;
		rcd_cntl_rec_resource.plant := rcd_cntl_rec.plant;

		/*-*/
      /* Insert the CNTL_REC_RESOURCE row (MANU schema) when required
      /*-*/

		-- commented out until the Pan size is sorted ouit in Atlas
      OPEN csr_cntl_rec_resource_01;
         FETCH csr_cntl_rec_resource_01 INTO var_work;
         IF csr_cntl_rec_resource_01%NOTFOUND THEN
			    IF  rcd_cntl_rec_resource.operation  IS NOT NULL AND rcd_cntl_rec_resource.resource_code  IS NOT NULL THEN
                 SELECT cntl_rec_resource_id_seq.NEXTVAL
                   INTO rcd_cntl_rec_resource.cntl_rec_resource_id
                   FROM dual;
                 INSERT INTO CNTL_REC_RESOURCE
                        (cntl_rec_resource_id,
                   		proc_order,
                   		operation,
                   		resource_code,
                   		batch_qty,
                   		batch_uom,
                   		plant)
                 VALUES (rcd_cntl_rec_resource.cntl_rec_resource_id,
                   		rcd_cntl_rec_resource.proc_order,
	                     rcd_cntl_rec_resource.operation,
                   		rcd_cntl_rec_resource.resource_code,
                   		rcd_cntl_rec_resource.batch_qty,
                   		rcd_cntl_rec_resource.batch_uom,
                   		rcd_cntl_rec_resource.plant);
			    END IF;
         END IF;
      CLOSE csr_cntl_rec_resource_01;

		/****************************************************/


      /*-*/
      /*- end of additions */
      /*-*/



      /*-*/
      /* Insert the CNTL_REC_BOM row (MANU schema)
      /*-*/
      INSERT INTO CNTL_REC_BOM
         (cntl_rec_bom_id,
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
         VALUES(rcd_cntl_rec_bom.cntl_rec_bom_id,
                rcd_cntl_rec_bom.proc_order,
                rcd_cntl_rec_bom.operation,
                rcd_cntl_rec_bom.phase,
                rcd_cntl_rec_bom.seq,
                rcd_cntl_rec_bom.material_code,
                rcd_cntl_rec_bom.material_desc,
                rcd_cntl_rec_bom.material_qty,
                rcd_cntl_rec_bom.material_uom,
                rcd_cntl_rec_bom.material_prnt,
                rcd_cntl_rec_bom.bf_item,
                rcd_cntl_rec_bom.reservation,
                rcd_cntl_rec_bom.plant,
                -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
                rcd_cntl_rec_bom.pan_size,
                rcd_cntl_rec_bom.last_pan_size,
                rcd_cntl_rec_bom.pan_size_flag,
                rcd_cntl_rec_bom.pan_qty);

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

      CURSOR csr_cntl_rec_resource_01 IS
         SELECT 'x'
           FROM CNTL_REC_RESOURCE t01
          WHERE t01.proc_order = rcd_cntl_rec_resource.proc_order
            AND t01.operation = rcd_cntl_rec_resource.operation;

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
      /* Set and validate the CNTL_REC_BOM row data (MANU schema)
      /*-*/
      SELECT cntl_rec_bom_id_seq.NEXTVAL INTO rcd_cntl_rec_bom.cntl_rec_bom_id FROM dual;

      rcd_cntl_rec_bom.proc_order := rcd_cntl_rec.proc_order;

      rcd_cntl_rec_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_cntl_rec_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_cntl_rec_bom.seq := rcd_lads_ctl_rec_vpi.pppi_material_item;

      rcd_cntl_rec_bom.material_code := rcd_lads_ctl_rec_vpi.pppi_material;

      rcd_cntl_rec_bom.material_desc := rcd_lads_ctl_rec_vpi.pppi_material_short_text;

      rcd_cntl_rec_bom.material_qty := NULL;
      BEGIN
		   IF INSTR(rcd_lads_ctl_rec_vpi.pppi_material_quantity,'E') > 0 THEN
			    rcd_cntl_rec_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
			ELSE
             rcd_cntl_rec_bom.material_qty := convert_to_number(rcd_lads_ctl_rec_vpi.pppi_material_quantity);
         END IF;

		EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.pppi_material_quantity || ') to a number');
      END;


      rcd_cntl_rec_bom.material_uom := rcd_lads_ctl_rec_vpi.pppi_unit_of_measure;

      rcd_cntl_rec_bom.material_prnt := NULL;

      rcd_cntl_rec_bom.bf_item := 'Y';
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.pppi_output_text)) = 'NON BACKFLUSHED ITEMS' THEN
         rcd_cntl_rec_bom.bf_item := 'N';
      END IF;

      rcd_cntl_rec_bom.reservation := rcd_lads_ctl_rec_vpi.pppi_reservation;

      rcd_cntl_rec_bom.plant := rcd_cntl_rec.plant;

      /*-*/
      /* added next series of checks JP - 11 Aug 2005 new comds in idoc
      /*-*/
      rcd_cntl_rec_bom.pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_cntl_rec_bom.pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_cntl_rec_bom.last_pan_size := NULL;
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         BEGIN
            rcd_cntl_rec_bom.last_pan_size := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num || ') to a number');
         END;
      END IF;

      rcd_cntl_rec_bom.pan_size_flag := 'N';
      IF UPPER(trim(rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn)) = 'Y' THEN
         rcd_cntl_rec_bom.pan_size_flag := 'Y';
      END IF;

      rcd_cntl_rec_bom.pan_qty := NULL;
      BEGIN
         rcd_cntl_rec_bom.pan_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_no_of_pans);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_no_of_pans || ') to a number');
      END;

      /* update quantity if pan size is N or Y
      /*-*/
      IF rcd_cntl_rec_bom.material_qty IS NULL THEN
         IF rcd_cntl_rec_bom.pan_size_flag = 'N' THEN
            BEGIN
               rcd_cntl_rec_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || ') to a number');
            END;
         ELSE
            BEGIN
               rcd_cntl_rec_bom.material_qty := TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num * rcd_lads_ctl_rec_vpi.z_ps_no_of_pans -1) + TO_NUMBER(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num);
            EXCEPTION
               WHEN OTHERS THEN
                  RAISE_APPLICATION_ERROR(-20000, 'Process ZACBRQ1 (ZATLASA) - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_num || 'or' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_num ||') to a number');
            END;
         END IF;
      END IF;

		rcd_cntl_rec_resource.proc_order := rcd_cntl_rec.proc_order;
		rcd_cntl_rec_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		rcd_cntl_rec_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;
		rcd_cntl_rec_resource.batch_qty := NULL;
		rcd_cntl_rec_resource.batch_uom := NULL;
		rcd_cntl_rec_resource.plant := rcd_cntl_rec.plant;

		/*-*/
      /* Insert the CNTL_REC_RESOURCE row (MANU schema) when required
      /*-*/

		-- commented out until pan size section of recipe idoc sorted out
      OPEN csr_cntl_rec_resource_01;
         FETCH csr_cntl_rec_resource_01 INTO var_work;
         IF csr_cntl_rec_resource_01%NOTFOUND THEN
			    IF  rcd_cntl_rec_resource.operation  IS NOT NULL AND rcd_cntl_rec_resource.resource_code  IS NOT NULL THEN
                 SELECT cntl_rec_resource_id_seq.NEXTVAL
                   INTO rcd_cntl_rec_resource.cntl_rec_resource_id
                   FROM dual;
                 INSERT INTO CNTL_REC_RESOURCE
                        (cntl_rec_resource_id,
                   		proc_order,
                   		operation,
                   		resource_code,
                   		batch_qty,
                   		batch_uom,
                   		plant)
                 VALUES (rcd_cntl_rec_resource.cntl_rec_resource_id,
                        rcd_cntl_rec_resource.proc_order,
                    		rcd_cntl_rec_resource.operation,
                   		rcd_cntl_rec_resource.resource_code,
                   		rcd_cntl_rec_resource.batch_qty,
                   		rcd_cntl_rec_resource.batch_uom,
                   		rcd_cntl_rec_resource.plant);
             END IF;
			END IF;
      CLOSE csr_cntl_rec_resource_01;




      /*- end of additions */
      /*------------------------------------------------------------------*/

      /*-*/
      /* Insert the CNTL_REC_BOM row (MANU schema)
      /*-*/
      INSERT INTO CNTL_REC_BOM
         (cntl_rec_bom_id,
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
         VALUES(rcd_cntl_rec_bom.cntl_rec_bom_id,
                rcd_cntl_rec_bom.proc_order,
                rcd_cntl_rec_bom.operation,
                rcd_cntl_rec_bom.phase,
                rcd_cntl_rec_bom.seq,
                rcd_cntl_rec_bom.material_code,
                rcd_cntl_rec_bom.material_desc,
                rcd_cntl_rec_bom.material_qty,
                rcd_cntl_rec_bom.material_uom,
                rcd_cntl_rec_bom.material_prnt,
                rcd_cntl_rec_bom.bf_item,
                rcd_cntl_rec_bom.reservation,
                rcd_cntl_rec_bom.plant,
                -- added next 4 lines JP - 11 Aug 2005 new comds in idoc
                rcd_cntl_rec_bom.pan_size,
                rcd_cntl_rec_bom.last_pan_size,
                rcd_cntl_rec_bom.pan_size_flag,
                rcd_cntl_rec_bom.pan_qty);

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

      CURSOR csr_cntl_rec_resource_01 IS
         SELECT 'x'
           FROM CNTL_REC_RESOURCE t01
          WHERE t01.proc_order = rcd_cntl_rec_resource.proc_order
            AND t01.operation = rcd_cntl_rec_resource.operation;

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
      /* Set and validate the CNTL_REC_RESOURCE row data (MANU schema)
      /*-*/
      IF NOT(rcd_lads_ctl_rec_vpi.pppi_operation IS NULL) AND
         NOT(rcd_lads_ctl_rec_vpi.pppi_phase_resource IS NULL) THEN

         rcd_cntl_rec_resource.proc_order := rcd_cntl_rec.proc_order;

         rcd_cntl_rec_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

         rcd_cntl_rec_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;

         rcd_cntl_rec_resource.batch_qty := NULL;

         rcd_cntl_rec_resource.batch_uom := NULL;

         rcd_cntl_rec_resource.plant := rcd_cntl_rec.plant;

         /*-*/
         /* Insert the CNTL_REC_RESOURCE row (MANU schema) when required
         /*-*/
         OPEN csr_cntl_rec_resource_01;
         FETCH csr_cntl_rec_resource_01 INTO var_work;
         IF csr_cntl_rec_resource_01%NOTFOUND THEN
            SELECT cntl_rec_resource_id_seq.NEXTVAL
              INTO rcd_cntl_rec_resource.cntl_rec_resource_id
              FROM dual;
            INSERT INTO CNTL_REC_RESOURCE
                   (cntl_rec_resource_id,
                   proc_order,
                   operation,
                   resource_code,
                   batch_qty,
                   batch_uom,
                   plant)
            VALUES (rcd_cntl_rec_resource.cntl_rec_resource_id,
                   rcd_cntl_rec_resource.proc_order,
                   rcd_cntl_rec_resource.operation,
                   rcd_cntl_rec_resource.resource_code,
                   rcd_cntl_rec_resource.batch_qty,
                   rcd_cntl_rec_resource.batch_uom,
                   rcd_cntl_rec_resource.plant);
         END IF;
         CLOSE csr_cntl_rec_resource_01;

      END IF;

      /*-*/
      /* The CNTL_REC_MPI_TXT row data (MANU schema)
      /*-*/
      IF rcd_lads_ctl_rec_vpi.z_src_type = 'H' OR
         rcd_lads_ctl_rec_vpi.z_src_type = 'I' OR
         rcd_lads_ctl_rec_vpi.z_src_type = 'N' THEN

         /*-*/
         /* Set and validate the CNTL_REC_MPI_TXT row data (MANU schema)
         /*-*/
         SELECT cntl_rec_mpi_txt_id_seq.NEXTVAL INTO rcd_cntl_rec_mpi_txt.cntl_rec_mpi_txt_id FROM dual;

         rcd_cntl_rec_mpi_txt.proc_order := rcd_cntl_rec.proc_order;

         rcd_cntl_rec_mpi_txt.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

         rcd_cntl_rec_mpi_txt.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

	     /********************************/
	     /* Jeff Phillipson - 28/10/2004 */

         rcd_cntl_rec_mpi_txt.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

	     /********************************/

         rcd_cntl_rec_mpi_txt.mpi_text := rcd_lads_ctl_rec_vpi.z_src_description;
         IF NOT(var_text01 IS NULL) THEN
            rcd_cntl_rec_mpi_txt.mpi_text := substrb(var_text01,1,4000);
         END IF;

         rcd_cntl_rec_mpi_txt.mpi_type := rcd_lads_ctl_rec_vpi.z_src_type;

         rcd_cntl_rec_mpi_txt.machine_code := rcd_lads_ctl_rec_vpi.z_src_machine_id;

         rcd_cntl_rec_mpi_txt.detail_desc := rcd_lads_ctl_rec_vpi.z_src_long_text;
         IF NOT(var_text02 IS NULL) THEN
            rcd_cntl_rec_mpi_txt.detail_desc := substrb(var_text02,1,4000);
         END IF;

         rcd_cntl_rec_mpi_txt.plant := rcd_cntl_rec.plant;

         /*-*/
         /* Insert the CNTL_MPI_TXT row (MANU schema)
         /*-*/
         INSERT INTO CNTL_REC_MPI_TXT
                (cntl_rec_mpi_txt_id,
                proc_order,
                operation,
                phase,
                seq,
                mpi_text,
                mpi_type,
                machine_code,
                detail_desc,
                plant)
         VALUES (rcd_cntl_rec_mpi_txt.cntl_rec_mpi_txt_id,
                rcd_cntl_rec_mpi_txt.proc_order,
                rcd_cntl_rec_mpi_txt.operation,
                rcd_cntl_rec_mpi_txt.phase,
                rcd_cntl_rec_mpi_txt.seq,
                rcd_cntl_rec_mpi_txt.mpi_text,
                rcd_cntl_rec_mpi_txt.mpi_type,
                rcd_cntl_rec_mpi_txt.machine_code,
                rcd_cntl_rec_mpi_txt.detail_desc,
                rcd_cntl_rec_mpi_txt.plant);

      /*-*/
      /* The CNTL_REC_RESOURCE row data (MANU schema)
      /*-*/
      ELSIF rcd_lads_ctl_rec_vpi.z_src_type = 'B' THEN

         /*-*/
         /* Set and validate the CNTL_REC_RESOURCE row data (MANU schema)
         /*-*/
         IF NOT(rcd_lads_ctl_rec_vpi.pppi_operation IS NULL) AND
            NOT(rcd_lads_ctl_rec_vpi.pppi_phase_resource IS NULL) THEN

            /*-*/
            /* Set the values
            /*-*/
            IF NOT(rcd_lads_ctl_rec_vpi.pppi_export_data IS NULL) THEN
               rcd_cntl_rec_resource.batch_qty := rcd_lads_ctl_rec_vpi.pppi_export_data;
            ELSE
               rcd_cntl_rec_resource.batch_qty := rcd_lads_ctl_rec_vpi.z_src_value;
            END IF;
            rcd_cntl_rec_resource.batch_uom := rcd_lads_ctl_rec_vpi.z_src_uom;

            /*-*/
            /* Update the CNTL_REC_RESOURCE row (MANU schema)
            /*-*/
            UPDATE CNTL_REC_RESOURCE
               SET batch_qty = rcd_cntl_rec_resource.batch_qty,
                   batch_uom = rcd_cntl_rec_resource.batch_uom
             WHERE proc_order = rcd_cntl_rec.proc_order
               AND operation = rcd_lads_ctl_rec_vpi.pppi_operation;

         END IF;

      /*-*/
      /* The CNTL_REC_MPI_VAL row data (MANU schema)
      /*-*/
      ELSIF (rcd_lads_ctl_rec_vpi.z_src_type = 'V' OR rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1') THEN

         /*-*/
         /* Set and validate the CNTL_REC_MPI_VAL row data (MANU schema)
         /*-*/
         SELECT cntl_rec_mpi_val_id_seq.NEXTVAL INTO rcd_cntl_rec_mpi_val.cntl_rec_mpi_val_id FROM dual;

         rcd_cntl_rec_mpi_val.proc_order := rcd_cntl_rec.proc_order;

         rcd_cntl_rec_mpi_val.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

         rcd_cntl_rec_mpi_val.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

	    /********************************/
	    /* Jeff Phillipson - 28/10/2004 */

         rcd_cntl_rec_mpi_val.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

	    /********************************/

         rcd_cntl_rec_mpi_val.mpi_tag := rcd_lads_ctl_rec_vpi.z_src_id;

         rcd_cntl_rec_mpi_val.mpi_desc := rcd_lads_ctl_rec_vpi.z_src_description;
         IF NOT(var_text01 IS NULL) THEN
            rcd_cntl_rec_mpi_val.mpi_desc := substrb(var_text01,1,2000);
         END IF;

         IF NOT(rcd_lads_ctl_rec_vpi.pppi_export_data IS NULL) THEN
            rcd_cntl_rec_mpi_val.mpi_val := rcd_lads_ctl_rec_vpi.pppi_export_data;
         ELSE
            rcd_cntl_rec_mpi_val.mpi_val := rcd_lads_ctl_rec_vpi.z_src_value;
         END IF;

         rcd_cntl_rec_mpi_val.mpi_uom := rcd_lads_ctl_rec_vpi.z_src_uom;

         rcd_cntl_rec_mpi_val.machine_code := rcd_lads_ctl_rec_vpi.z_src_machine_id;

         rcd_cntl_rec_mpi_val.detail_desc := rcd_lads_ctl_rec_vpi.z_src_long_text;
         IF NOT(var_text02 IS NULL) THEN
            rcd_cntl_rec_mpi_val.detail_desc := substrb(var_text02,1,4000);
         END IF;

         rcd_cntl_rec_mpi_val.plant := rcd_cntl_rec.plant;

         /*-*/
         /* Modify values if src type TEXT1 is used
         /*-*/
         IF rcd_lads_ctl_rec_vpi.z_src_type = 'TEXT1' THEN
            if lengthb(rcd_cntl_rec_mpi_val.mpi_desc||' '||LOWER(rcd_cntl_rec_mpi_val.mpi_val)||' '||LOWER(rcd_cntl_rec_mpi_val.mpi_uom)) > 2000 then
               rcd_cntl_rec_mpi_val.mpi_desc := substrb(rcd_cntl_rec_mpi_val.mpi_desc,1,(2000 - lengthb(' '||LOWER(rcd_cntl_rec_mpi_val.mpi_val)||' '||LOWER(rcd_cntl_rec_mpi_val.mpi_uom))));
            end if;
            rcd_cntl_rec_mpi_val.mpi_desc := rcd_cntl_rec_mpi_val.mpi_desc || ' ' || LOWER(rcd_cntl_rec_mpi_val.mpi_val) || ' ' || LOWER(rcd_cntl_rec_mpi_val.mpi_uom);
            rcd_cntl_rec_mpi_val.mpi_val := '';
            rcd_cntl_rec_mpi_val.mpi_uom := '';
         END IF;

         /*-*/
         /* Insert the CNTL_MPI_VAL row (MANU schema)
         /*-*/
         INSERT INTO CNTL_REC_MPI_VAL
                (cntl_rec_mpi_val_id,
                proc_order,
                operation,
                phase,
                seq,
                mpi_tag,
                mpi_desc,
                mpi_val,
                mpi_uom,
                machine_code,
                detail_desc,
                plant)
         VALUES (rcd_cntl_rec_mpi_val.cntl_rec_mpi_val_id,
                rcd_cntl_rec_mpi_val.proc_order,
                rcd_cntl_rec_mpi_val.operation,
                rcd_cntl_rec_mpi_val.phase,
                rcd_cntl_rec_mpi_val.seq,
                rcd_cntl_rec_mpi_val.mpi_tag,
                rcd_cntl_rec_mpi_val.mpi_desc,
                rcd_cntl_rec_mpi_val.mpi_val,
                rcd_cntl_rec_mpi_val.mpi_uom,
                rcd_cntl_rec_mpi_val.machine_code,
                rcd_cntl_rec_mpi_val.detail_desc,
                rcd_cntl_rec_mpi_val.plant);

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

      CURSOR csr_cntl_rec_resource_01 IS
         SELECT 'x'
           FROM CNTL_REC_RESOURCE t01
          WHERE t01.proc_order = rcd_cntl_rec_resource.proc_order
            AND t01.operation = rcd_cntl_rec_resource.operation;


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
      /* Set and validate the CNTL_REC_BOM row data (MANU schema)
      /*-*/
      SELECT cntl_rec_bom_id_seq.NEXTVAL INTO rcd_cntl_rec_bom.cntl_rec_bom_id FROM dual;

      rcd_cntl_rec_bom.proc_order := rcd_cntl_rec.proc_order;

      /*-*/
      /* copy phase into operation - its not sent in the latest Idoc
      /*-*/
		IF rcd_lads_ctl_rec_vpi.pppi_operation IS NULL THEN
			rcd_cntl_rec_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
		ELSE
      	 rcd_cntl_rec_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		END IF;
      rcd_cntl_rec_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_cntl_rec_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;

      rcd_cntl_rec_bom.material_desc := rcd_lads_ctl_rec_vpi.z_ps_material_short_text;

      rcd_cntl_rec_bom.phantom := 'M';  -- Phantom made location

      rcd_cntl_rec_bom.pan_qty :=  rcd_lads_ctl_rec_vpi.z_ps_no_of_pans;

      rcd_cntl_rec_bom.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

      rcd_cntl_rec_bom.material_uom := trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1));

      rcd_cntl_rec_bom.plant := rcd_cntl_rec.plant;

      /*-*/
      /* seperate out qty and uom values
      /*-*/
      rcd_cntl_rec_bom.material_qty := NULL;
      rcd_cntl_rec_bom.pan_size := NULL;
      rcd_cntl_rec_bom.last_pan_size := NULL;
      IF rcd_lads_ctl_rec_vpi.z_ps_no_of_pans = 0 THEN

         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,' ');
         BEGIN
            rcd_cntl_rec_bom.material_qty := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,1,var_space - 1)));
            rcd_cntl_rec_bom.material_uom := UPPER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Field - MATERIAL_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char || ') to a number');
         END;

      ELSE
         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char,' ');
         var_space1 := INSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,' ');
         BEGIN
            rcd_cntl_rec_bom.pan_size := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char, 1, var_space - 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, ' Process ZPHPAN1 - Field - FIRST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_out_char || ') to a number');
         END;

         BEGIN
            rcd_cntl_rec_bom.last_pan_size := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char,1,var_space1 - 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_out_char || ') TO a NUMBER');
         END;

         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,' ');
         BEGIN
            rcd_cntl_rec_bom.material_qty := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,1,var_space - 1)));
            rcd_cntl_rec_bom.material_uom := UPPER(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_material_qty_char,var_space + 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHPAN1 - Field - MATERIAL_QTY WITH Pan Qty - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_material_qty_char || ') to a number');
         END;

         rcd_cntl_rec_bom.pan_size_flag := 'Y';

      END IF;


      /*-*/
      /* now update the CNTL_REC_RESOURECE table
      /*-*/
      rcd_cntl_rec_resource.proc_order := rcd_cntl_rec.proc_order;

      rcd_cntl_rec_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_cntl_rec_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;

      rcd_cntl_rec_resource.plant := rcd_cntl_rec.plant;

      /*-*/
      /* Insert the CNTL_REC_RESOURCE row (MANU schema) when required
      /*-*/
      OPEN csr_cntl_rec_resource_01;
      FETCH csr_cntl_rec_resource_01 INTO var_work;
      IF csr_cntl_rec_resource_01%NOTFOUND THEN
		   IF  rcd_cntl_rec_resource.operation  IS NOT NULL THEN
             SELECT cntl_rec_resource_id_seq.NEXTVAL
               INTO rcd_cntl_rec_resource.cntl_rec_resource_id
               FROM dual;
             INSERT INTO CNTL_REC_RESOURCE
                    (cntl_rec_resource_id,
                    proc_order,
                    operation,
                    resource_code,
                    plant)
             VALUES (rcd_cntl_rec_resource.cntl_rec_resource_id,
                    rcd_cntl_rec_resource.proc_order,
                    rcd_cntl_rec_resource.operation,
                    rcd_cntl_rec_resource.resource_code,
                    rcd_cntl_rec_resource.plant);
			END IF;
      END IF;
      CLOSE csr_cntl_rec_resource_01;

      /*-*/
      /* Insert the CNTL_REC_BOM row (MANU schema)
      /*-*/
      INSERT INTO CNTL_REC_BOM
             (cntl_rec_bom_id,
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
      VALUES (rcd_cntl_rec_bom.cntl_rec_bom_id,
             rcd_cntl_rec_bom.proc_order,
             rcd_cntl_rec_bom.operation,
             rcd_cntl_rec_bom.phase,
             rcd_cntl_rec_bom.seq,
             rcd_cntl_rec_bom.material_code,
             rcd_cntl_rec_bom.material_desc,
             rcd_cntl_rec_bom.material_qty,
             rcd_cntl_rec_bom.material_uom,
             rcd_cntl_rec_bom.material_prnt,
             rcd_cntl_rec_bom.bf_item,
             rcd_cntl_rec_bom.reservation,
             rcd_cntl_rec_bom.plant,
             rcd_cntl_rec_bom.pan_size,
             rcd_cntl_rec_bom.last_pan_size,
             rcd_cntl_rec_bom.pan_size_flag,
             rcd_cntl_rec_bom.pan_qty,
             rcd_cntl_rec_bom.phantom);

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

      CURSOR csr_cntl_rec_resource_01 IS
         SELECT 'x'
           FROM CNTL_REC_RESOURCE t01
          WHERE t01.proc_order = rcd_cntl_rec_resource.proc_order
            AND t01.operation = rcd_cntl_rec_resource.operation;


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
      /* Set and validate the CNTL_REC_BOM row data (MANU schema)
      /*-*/
      SELECT cntl_rec_bom_id_seq.NEXTVAL INTO rcd_cntl_rec_bom.cntl_rec_bom_id FROM dual;

      rcd_cntl_rec_bom.proc_order := rcd_cntl_rec.proc_order;

      /*-*/
      /* Idoc doesn't send operation so make the operation and phase the same
      /*-*/
		IF rcd_lads_ctl_rec_vpi.pppi_operation IS NULL THEN
		    rcd_cntl_rec_bom.operation := rcd_lads_ctl_rec_vpi.pppi_phase;
		ELSE
          rcd_cntl_rec_bom.operation := rcd_lads_ctl_rec_vpi.pppi_operation;
		END IF;
      rcd_cntl_rec_bom.phase := rcd_lads_ctl_rec_vpi.pppi_phase;

      rcd_cntl_rec_bom.material_code := rcd_lads_ctl_rec_vpi.z_ps_material;

      rcd_cntl_rec_bom.material_desc := rcd_lads_ctl_rec_vpi.z_ps_material_short_text;

      rcd_cntl_rec_bom.seq := SUBSTR(rcd_lads_ctl_rec_tpi.proc_instr_number,1,4);

      rcd_cntl_rec_bom.plant := rcd_cntl_rec.plant;

      rcd_cntl_rec_bom.operation_from := rcd_lads_ctl_rec_vpi.z_ps_predecessor;

      rcd_cntl_rec_bom.phantom := 'U';  -- Phantom used location

      rcd_cntl_rec_bom.pan_size_flag := rcd_lads_ctl_rec_vpi.z_ps_pan_size_yn;

      rcd_cntl_rec_bom.pan_qty := NULL;

      /*-*/
      /* update quantity if pan size is N or Y
      /*-*/
      rcd_cntl_rec_bom.material_qty := NULL;
      rcd_cntl_rec_bom.pan_size := NULL;
      rcd_cntl_rec_bom.last_pan_size := NULL;

      IF rcd_cntl_rec_bom.pan_size_flag = 'N' OR rcd_cntl_rec_bom.pan_size_flag = 'E' THEN

         var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,' ');

         BEGIN
		    IF var_space = 0 THEN
			    rcd_cntl_rec_bom.material_qty := convert_to_number(trim(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char));
			ELSE
                rcd_cntl_rec_bom.material_qty := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1, var_space - 1)));
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
				     rcd_cntl_rec_bom.material_qty := (TO_NUMBER(TRIM(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char)) + TO_NUMBER(trim(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char)));
				 ELSE
				     var_space := INSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,' ');
         		  var_space1 := INSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,' ');
            	  rcd_cntl_rec_bom.material_qty := (convert_to_number(TRIM(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1,var_space -1))) * 1) + convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,1,var_space1 -1)));
             END IF;
			EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Field - PAN_SIZE * PAN_QTY - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ' or ' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char ||') to a number');
         END;

         /*-*/
         /* get pan size
         /*-*/
         rcd_cntl_rec_bom.pan_size := NULL;
         BEGIN
            rcd_cntl_rec_bom.pan_size := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char,1,var_space - 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1  - Field - PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char || ') to a number');
         END;

         /*-*/
         /* get last pan size
         /*-*/
         rcd_cntl_rec_bom.last_pan_size := NULL;
         BEGIN
		    /*-*/
		    /* Changed the variable name from var_space to var_space1
		    /* Added by JP 26 May 2006
		    /* For the first time a Proc Order was sent with a smaller numerical value length for last_pan_size
		    /*-*/
            rcd_cntl_rec_bom.last_pan_size := convert_to_number(trim(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char,1,var_space1 - 1)));
         EXCEPTION
            WHEN OTHERS THEN
               RAISE_APPLICATION_ERROR(-20000, 'Process ZPHBRQ1 - Field - LAST_PAN_SIZE - Unable to convert (' || rcd_lads_ctl_rec_vpi.z_ps_last_pan_in_char || ') to a number');
         END;
      END IF;

      IF var_space  = 0 THEN
	      rcd_cntl_rec_bom.material_uom := NULL;
	  ELSE
	     rcd_cntl_rec_bom.material_uom := UPPER(TRIM(SUBSTR(rcd_lads_ctl_rec_vpi.z_ps_first_pan_in_char, var_space + 1)));
      END IF;

      /*-*/
      /* now update the CNTL_REC_RESOURECE table
      /*-*/
      rcd_cntl_rec_resource.proc_order := rcd_cntl_rec.proc_order;

      rcd_cntl_rec_resource.operation := rcd_lads_ctl_rec_vpi.pppi_operation;

      rcd_cntl_rec_resource.resource_code := rcd_lads_ctl_rec_vpi.pppi_phase_resource;

      rcd_cntl_rec_resource.plant := rcd_cntl_rec.plant;

      /*-*/
      /* Insert the CNTL_REC_RESOURCE row (MANU schema) when required
      /*-*/
      OPEN csr_cntl_rec_resource_01;
      FETCH csr_cntl_rec_resource_01 INTO var_work;
      IF csr_cntl_rec_resource_01%NOTFOUND THEN
		    IF  rcd_cntl_rec_resource.operation  IS NOT NULL THEN
             SELECT cntl_rec_resource_id_seq.NEXTVAL
               INTO rcd_cntl_rec_resource.cntl_rec_resource_id
               FROM dual;
             INSERT INTO CNTL_REC_RESOURCE
                    (cntl_rec_resource_id,
                    proc_order,
                    operation,
                    resource_code,
                    plant)
             VALUES (rcd_cntl_rec_resource.cntl_rec_resource_id,
                    rcd_cntl_rec_resource.proc_order,
                    rcd_cntl_rec_resource.operation,
                    rcd_cntl_rec_resource.resource_code,
                    rcd_cntl_rec_resource.plant);
		    END IF;
      END IF;
      CLOSE csr_cntl_rec_resource_01;

      /*-*/
      /* Insert the CNTL_REC_BOM row (MANU schema)
      /*-*/
      INSERT INTO CNTL_REC_BOM
             (cntl_rec_bom_id,
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
      VALUES (rcd_cntl_rec_bom.cntl_rec_bom_id,
             rcd_cntl_rec_bom.proc_order,
             rcd_cntl_rec_bom.operation,
             rcd_cntl_rec_bom.phase,
             rcd_cntl_rec_bom.seq,
             rcd_cntl_rec_bom.material_code,
             rcd_cntl_rec_bom.material_desc,
             rcd_cntl_rec_bom.material_qty,
             rcd_cntl_rec_bom.material_uom,
             rcd_cntl_rec_bom.material_prnt,
             rcd_cntl_rec_bom.bf_item,
             rcd_cntl_rec_bom.reservation,
             rcd_cntl_rec_bom.plant,
             rcd_cntl_rec_bom.pan_size,
             rcd_cntl_rec_bom.last_pan_size,
             rcd_cntl_rec_bom.pan_size_flag,
             rcd_cntl_rec_bom.pan_qty,
             rcd_cntl_rec_bom.phantom,
             rcd_cntl_rec_bom.operation_from);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_zphbrq1;

  FUNCTION convert_to_number(par_value varchar2) return number is

    var_result number;

  BEGIN
  
    if ( instr(par_value, ',') = 0 ) then    
      var_result := to_number(par_value);    
    else
      var_result := to_number(par_value, 'FM999G999G999D999');    
    end if;    
  
    return var_result;

  END convert_to_number;

END ics_ladsmanu01;
/


CREATE OR REPLACE PUBLIC SYNONYM ICS_LADSMANU01 FOR ICS_APP.ICS_LADSMANU01;


GRANT EXECUTE ON  ICS_APP.ICS_LADSMANU01 TO PUBLIC;

