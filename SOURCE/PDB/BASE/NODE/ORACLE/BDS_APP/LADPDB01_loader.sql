CREATE OR REPLACE PACKAGE BDS_APP.Ladpdb01_Loader
AS
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : Plant Database
 Package : ladpdb01_loader
 Owner   : BDS_APP
 Author  : Steve Gregan

 Description
 -----------
 Plant Database - Inbound Control Recipe Interface

 dd-mmm-yyyy   Author              Description
 -----------   ------              -----------
 01-Jun-2007   Steve Gregan        Created
 01-Jul-2007   Jeff Phillipson     Modified table definitions
 18-Oct-2007   JP                  Added delete of procedure order with the same cntl_rec_id
 27-Jul-2011   Steve Gregan        Commented out call to recipe conversion procedure - refer Ben Halicki
*******************************************************************************/

   /*-*/
   /* Public declarations
       /*-*/
   PROCEDURE on_start;

   PROCEDURE on_data (par_record IN VARCHAR2);

   PROCEDURE on_end;
END Ladpdb01_Loader;
/



CREATE OR REPLACE PACKAGE BODY BDS_APP.Ladpdb01_Loader AS

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   PROCEDURE complete_transaction;
   PROCEDURE process_record_hdr(par_record IN VARCHAR2);
   PROCEDURE process_record_bom(par_record IN VARCHAR2);
   PROCEDURE process_record_res(par_record IN VARCHAR2);
   PROCEDURE process_record_stx(par_record IN VARCHAR2);
   PROCEDURE process_record_st1(par_record IN VARCHAR2);
   PROCEDURE process_record_st2(par_record IN VARCHAR2);
   PROCEDURE process_record_svl(par_record IN VARCHAR2);
   PROCEDURE process_record_sv1(par_record IN VARCHAR2);
   PROCEDURE process_record_sv2(par_record IN VARCHAR2);
   
   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start  BOOLEAN;
   var_trn_ignore BOOLEAN;
   var_trn_error BOOLEAN;
   rcd_hdr bds_recipe_header%ROWTYPE;
   rcd_bom bds_recipe_bom%ROWTYPE;
   rcd_res bds_recipe_resource%ROWTYPE;
   rcd_stx bds_recipe_src_text%ROWTYPE;
   rcd_svl bds_recipe_src_value%ROWTYPE;
   var_proc_order rcd_hdr.proc_order%TYPE;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   PROCEDURE on_start IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_start := FALSE;
      var_trn_ignore := FALSE;
      var_trn_error := FALSE;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/ 
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','ID',3);
      lics_inbound_utility.set_definition('HDR','PROC_ORDER',12);
      lics_inbound_utility.set_definition('HDR','CNTL_REC_ID',18);
      lics_inbound_utility.set_definition('HDR','PLANT',4);
      lics_inbound_utility.set_definition('HDR','CNTL_REC_STATUS',5);
      lics_inbound_utility.set_definition('HDR','TEST_FLAG',1);
      lics_inbound_utility.set_definition('HDR','RECIPE_TEXT',40);
      lics_inbound_utility.set_definition('HDR','MATERIAL',18);
      lics_inbound_utility.set_definition('HDR','MATERIAL_TEXT',40);
      lics_inbound_utility.set_definition('HDR','QUANTITY',38);
      lics_inbound_utility.set_definition('HDR','INSPLOT',12);
      lics_inbound_utility.set_definition('HDR','UOM',4);
      lics_inbound_utility.set_definition('HDR','BATCH',10);
      lics_inbound_utility.set_definition('HDR','SCHED_START_DATIME',14);
      lics_inbound_utility.set_definition('HDR','RUN_START_DATIME',14);
      lics_inbound_utility.set_definition('HDR','RUN_END_DATIME',14);
      lics_inbound_utility.set_definition('HDR','VERSION',38);
      lics_inbound_utility.set_definition('HDR','UPD_DATIME',14);
      lics_inbound_utility.set_definition('HDR','CNTL_REC_XFER',1);
      lics_inbound_utility.set_definition('HDR','TECO_STATUS',4);
      lics_inbound_utility.set_definition('HDR','STORAGE_LOCN',4);
      lics_inbound_utility.set_definition('HDR','IDOC_TIMESTAMP',16);
      /*-*/
      lics_inbound_utility.set_definition('BOM','ID',3);
      lics_inbound_utility.set_definition('BOM','PROC_ORDER',12);
      lics_inbound_utility.set_definition('BOM','OPERATION',4);
      lics_inbound_utility.set_definition('BOM','PHASE',4);
      lics_inbound_utility.set_definition('BOM','SEQ',4);
      lics_inbound_utility.set_definition('BOM','MATERIAL_CODE',18);
      lics_inbound_utility.set_definition('BOM','MATERIAL_DESC',40);
      lics_inbound_utility.set_definition('BOM','MATERIAL_QTY',38);
      lics_inbound_utility.set_definition('BOM','MATERIAL_UOM',4);
      lics_inbound_utility.set_definition('BOM','MATERIAL_PRNT',18);
      lics_inbound_utility.set_definition('BOM','BF_ITEM',1);
      lics_inbound_utility.set_definition('BOM','RESERVATION',40);
      lics_inbound_utility.set_definition('BOM','PLANT',4);
      lics_inbound_utility.set_definition('BOM','PAN_SIZE',38);
      lics_inbound_utility.set_definition('BOM','LAST_PAN_SIZE',38);
      lics_inbound_utility.set_definition('BOM','PAN_SIZE_FLAG',1);
      lics_inbound_utility.set_definition('BOM','PAN_QTY',38);
      lics_inbound_utility.set_definition('BOM','PHANTOM',1);
      lics_inbound_utility.set_definition('BOM','OPERATION_FROM',4);
      /*-*/
      lics_inbound_utility.set_definition('RES','ID',3);
      lics_inbound_utility.set_definition('RES','PROC_ORDER',12);
      lics_inbound_utility.set_definition('RES','OPERATION',4);
      lics_inbound_utility.set_definition('RES','RESOURCE_CODE',9);
      lics_inbound_utility.set_definition('RES','BATCH_QTY',38);
      lics_inbound_utility.set_definition('RES','BATCH_UOM',4);
      lics_inbound_utility.set_definition('RES','PHANTOM',8);
      lics_inbound_utility.set_definition('RES','PHANTOM_DESC',40);
      lics_inbound_utility.set_definition('RES','PHANTOM_QTY',20);
      lics_inbound_utility.set_definition('RES','PHANTOM_UOM',10);
      lics_inbound_utility.set_definition('RES','PLANT',4);
      /*-*/
      lics_inbound_utility.set_definition('STX','ID',3);
      lics_inbound_utility.set_definition('STX','PROC_ORDER',12);
      lics_inbound_utility.set_definition('STX','OPERATION',4);
      lics_inbound_utility.set_definition('STX','PHASE',4);
      lics_inbound_utility.set_definition('STX','SEQ',4);
      lics_inbound_utility.set_definition('STX','SRC_TYPE',1);
      lics_inbound_utility.set_definition('STX','MACHINE_CODE',4);
      lics_inbound_utility.set_definition('STX','PLANT',4);
      /*-*/
      lics_inbound_utility.set_definition('ST1','ID',3);
      lics_inbound_utility.set_definition('ST1','PROC_ORDER',12);
      lics_inbound_utility.set_definition('ST1','OPERATION',4);
      lics_inbound_utility.set_definition('ST1','PHASE',4);
      lics_inbound_utility.set_definition('ST1','SEQ',4);
      lics_inbound_utility.set_definition('ST1','TEXT_DATA',500);
      /*-*/
      lics_inbound_utility.set_definition('ST2','ID',3);
      lics_inbound_utility.set_definition('ST2','PROC_ORDER',12);
      lics_inbound_utility.set_definition('ST2','OPERATION',4);
      lics_inbound_utility.set_definition('ST2','PHASE',4);
      lics_inbound_utility.set_definition('ST2','SEQ',4);
      lics_inbound_utility.set_definition('ST2','TEXT_DATA',500);
      /*-*/
      lics_inbound_utility.set_definition('SVL','ID',3);
      lics_inbound_utility.set_definition('SVL','PROC_ORDER',12);
      lics_inbound_utility.set_definition('SVL','OPERATION',4);
      lics_inbound_utility.set_definition('SVL','PHASE',4);
      lics_inbound_utility.set_definition('SVL','SEQ',4);
      lics_inbound_utility.set_definition('SVL','SRC_TAG',40);
      lics_inbound_utility.set_definition('SVL','SRC_VAL',30);
      lics_inbound_utility.set_definition('SVL','SRC_UOM',20);
      lics_inbound_utility.set_definition('SVL','MACHINE_CODE',4);
      lics_inbound_utility.set_definition('SVL','PLANT',4);
      /*-*/
      lics_inbound_utility.set_definition('SV1','ID',3);
      lics_inbound_utility.set_definition('SV1','PROC_ORDER',12);
      lics_inbound_utility.set_definition('SV1','OPERATION',4);
      lics_inbound_utility.set_definition('SV1','PHASE',4);
      lics_inbound_utility.set_definition('SV1','SEQ',4);
      lics_inbound_utility.set_definition('SV1','TEXT_DATA',500);
      /*-*/
      lics_inbound_utility.set_definition('SV2','ID',3);
      lics_inbound_utility.set_definition('SV2','PROC_ORDER',12);
      lics_inbound_utility.set_definition('SV2','OPERATION',4);
      lics_inbound_utility.set_definition('SV2','PHASE',4);
      lics_inbound_utility.set_definition('SV2','SEQ',4);
      lics_inbound_utility.set_definition('SV2','TEXT_DATA',500);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   PROCEDURE on_data(par_record IN VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_record_identifier VARCHAR2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := SUBSTR(par_record,1,3);
      CASE var_record_identifier
         WHEN 'HDR' THEN process_record_hdr(par_record);
         WHEN 'BOM' THEN process_record_bom(par_record);
         WHEN 'RES' THEN process_record_res(par_record);
         WHEN 'STX' THEN process_record_stx(par_record);
         WHEN 'ST1' THEN process_record_st1(par_record);
         WHEN 'ST2' THEN process_record_st2(par_record);
         WHEN 'SVL' THEN process_record_svl(par_record);
         WHEN 'SV1' THEN process_record_sv1(par_record);
         WHEN 'SV2' THEN process_record_sv2(par_record);
         ELSE lics_inbound_utility.add_exception('Record identifier (' || var_record_identifier || ') not recognised');
      END CASE;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   PROCEDURE on_end IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Complete the Transaction
      /*-*/
      complete_transaction;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END on_end;


   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   PROCEDURE complete_transaction IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* No data processed
      /*-*/
      IF var_trn_start = FALSE THEN
         ROLLBACK;
         RETURN;
      END IF;

      /*-*/
      /* Commit/rollback the transaction as required
      /*-*/
      IF var_trn_ignore = TRUE THEN

         /*-*/
         /* Rollback the transaction
         /* **note** - releases transaction lock
         /*-*/
         ROLLBACK;

      ELSIF var_trn_error = TRUE THEN

         /*-*/
         /* Rollback the transaction
         /* **note** - releases transaction lock
         /*-*/
         ROLLBACK;

      ELSE

         /*-*/
         /* Commit the transaction
         /* **note** - releases transaction lock
         /*-*/
         COMMIT;
      --   /*-*/
      --   /* call recipe conversion procedure
      --   /*-*/
      --   BEGIN
      --      Recipe_Conversion.EXECUTE(rcd_hdr.cntl_rec_id);
      --   EXCEPTION
      --      WHEN OTHERS THEN
      --         lics_inbound_utility.add_exception(SUBSTR(SQLERRM, 1, 512));
      --   END;

      END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END complete_transaction;


   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   PROCEDURE process_record_hdr(par_record IN VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_idoc_timestamp rcd_hdr.idoc_timestamp%TYPE;
      var_count NUMBER;
                         
   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Complete the previous transactions
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset transaction variables
      /*-*/
      var_trn_start := TRUE;
      var_trn_ignore := FALSE;
      var_trn_error := FALSE;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      /*-------------------------------*/
      /* check if this is a validation recipe
      /*-------------------------------*/
      IF SUBSTR(par_record,4,1) BETWEEN '0' AND '9' THEN
          var_proc_order := lics_inbound_utility.get_variable('PROC_ORDER');
      ELSE
          IF SUBSTR(par_record,34,4) IN ('NZ01') THEN 
           lics_inbound_utility.add_exception('Validation Proc Orders are not configured for NZ01 at present.');
           var_trn_error := TRUE;
       END IF;
       SELECT bds_recipe_seq.NEXTVAL INTO var_proc_order FROM dual; 
       var_proc_order := SUBSTR(par_record,4,1) || LPAD(TO_CHAR(var_proc_order),11,'0');
      END IF;
      
      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
      rcd_hdr.proc_order := var_proc_order;
      rcd_hdr.cntl_rec_id := lics_inbound_utility.get_variable('CNTL_REC_ID');
      rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT');
      rcd_hdr.cntl_rec_status := lics_inbound_utility.get_variable('CNTL_REC_STATUS');
      rcd_hdr.test_flag := lics_inbound_utility.get_variable('TEST_FLAG');
      rcd_hdr.recipe_text := lics_inbound_utility.get_variable('RECIPE_TEXT');
      rcd_hdr.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_hdr.material_text := lics_inbound_utility.get_variable('MATERIAL_TEXT');
      rcd_hdr.quantity := lics_inbound_utility.get_number('QUANTITY',NULL);
      rcd_hdr.insplot := lics_inbound_utility.get_variable('INSPLOT');
      rcd_hdr.uom := lics_inbound_utility.get_variable('UOM');
      rcd_hdr.batch := lics_inbound_utility.get_variable('BATCH');
      rcd_hdr.sched_start_datime := lics_inbound_utility.get_date('SCHED_START_DATIME','yyyymmddhh24miss');
      rcd_hdr.run_start_datime := lics_inbound_utility.get_date('RUN_START_DATIME','yyyymmddhh24miss');
      rcd_hdr.run_end_datime := lics_inbound_utility.get_date('RUN_END_DATIME','yyyymmddhh24miss');
      rcd_hdr.VERSION := lics_inbound_utility.get_number('VERSION',NULL);
      rcd_hdr.upd_datime := SYSDATE;
      rcd_hdr.cntl_rec_xfer := lics_inbound_utility.get_variable('CNTL_REC_XFER');
      rcd_hdr.teco_status := lics_inbound_utility.get_variable('TECO_STATUS');
      rcd_hdr.storage_locn := lics_inbound_utility.get_variable('STORAGE_LOCN');
      rcd_hdr.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_TIMESTAMP');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      IF rcd_hdr.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*----------------------------------------*/
      /* LOCK- Lock the interface transaction   */
      /*----------------------------------------*/

      /*-*/
      /* Lock the transaction
      /* **note** - attempt to lock the transaction header row (oracle default wait behaviour)
      /*              - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index
      /*              - update/update (exists) - logic goes to update and default wait behaviour
      /*          - validate the IDOC sequence when locking row exists
      /*          - lock and commit cycle encompasses transaction child procedure execution
      /*-*/
      BEGIN
         INSERT INTO bds_recipe_header
            (proc_order,
             cntl_rec_id,
             plant_code,
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
         VALUES
            (rcd_hdr.proc_order,
             rcd_hdr.cntl_rec_id,
             rcd_hdr.plant_code,
             rcd_hdr.cntl_rec_status,
             rcd_hdr.test_flag,
             rcd_hdr.recipe_text,
             rcd_hdr.material,
             rcd_hdr.material_text,
             rcd_hdr.quantity,
             rcd_hdr.insplot,
             rcd_hdr.uom,
             rcd_hdr.batch,
             rcd_hdr.sched_start_datime,
             rcd_hdr.run_start_datime,
             rcd_hdr.run_end_datime,
             rcd_hdr.VERSION,
             rcd_hdr.upd_datime,
             rcd_hdr.cntl_rec_xfer,
             rcd_hdr.teco_status,
             rcd_hdr.storage_locn,
             rcd_hdr.idoc_timestamp);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            /*-*/
            /* check if this is a duplicate proc_order or a duplicate cntl_rec_id
            /*-*/
            SELECT COUNT(*) INTO var_count
            FROM bds_recipe_header
            WHERE cntl_rec_id = rcd_hdr.cntl_rec_id;
            IF var_count = 0 THEN
                /*-*/
                /* duplicate proc order
                /*-*/ 
                UPDATE bds_recipe_header
                   SET upd_datime = SYSDATE
                 WHERE proc_order = rcd_hdr.proc_order
                 RETURNING idoc_timestamp INTO var_idoc_timestamp;
                IF SQL%FOUND AND var_idoc_timestamp <= rcd_hdr.idoc_timestamp THEN
                    DELETE FROM bds_recipe_bom WHERE proc_order = rcd_hdr.proc_order;
                    DELETE FROM bds_recipe_resource WHERE proc_order = rcd_hdr.proc_order;
                    DELETE FROM bds_recipe_src_text WHERE proc_order = rcd_hdr.proc_order;
                    DELETE FROM bds_recipe_src_value WHERE proc_order = rcd_hdr.proc_order;
               ELSE
                   var_trn_ignore := TRUE;
               END IF;
           ELSE
               /*-*/
               /* if duplicate cntl rec id - ignore
               /*-*/
               var_trn_ignore := TRUE;
           END IF;
      END;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      IF var_count = 0 THEN
          UPDATE bds_recipe_header SET
                 cntl_rec_id = rcd_hdr.cntl_rec_id,
                 plant_code = rcd_hdr.plant_code,
                 cntl_rec_status = rcd_hdr.cntl_rec_status,
                 test_flag = rcd_hdr.test_flag,
                 recipe_text = rcd_hdr.recipe_text,
                 material = rcd_hdr.material,
                 material_text = rcd_hdr.material_text,
                 quantity = rcd_hdr.quantity,
                 insplot = rcd_hdr.insplot,
                 uom = rcd_hdr.uom,
                 batch = rcd_hdr.batch,
                 sched_start_datime = rcd_hdr.sched_start_datime,
                 run_start_datime = rcd_hdr.run_start_datime,
                 run_end_datime = rcd_hdr.run_end_datime,
                 VERSION = VERSION + 1,
                 upd_datime = rcd_hdr.upd_datime,
                 cntl_rec_xfer = rcd_hdr.cntl_rec_xfer,
                 teco_status = rcd_hdr.teco_status,
                 storage_locn = rcd_hdr.storage_locn,
                 idoc_timestamp = rcd_hdr.idoc_timestamp
           WHERE proc_order = rcd_hdr.proc_order;
      ELSE
          UPDATE bds_recipe_header SET
                 proc_order = rcd_hdr.proc_order,
                 plant_code = rcd_hdr.plant_code,
                 cntl_rec_status = rcd_hdr.cntl_rec_status,
                 test_flag = rcd_hdr.test_flag,
                 recipe_text = rcd_hdr.recipe_text,
                 material = rcd_hdr.material,
                 material_text = rcd_hdr.material_text,
                 quantity = rcd_hdr.quantity,
                 insplot = rcd_hdr.insplot,
                 uom = rcd_hdr.uom,
                 batch = rcd_hdr.batch,
                 sched_start_datime = rcd_hdr.sched_start_datime,
                 run_start_datime = rcd_hdr.run_start_datime,
                 run_end_datime = rcd_hdr.run_end_datime,
                 VERSION = rcd_hdr.VERSION,
                 upd_datime = rcd_hdr.upd_datime,
                 cntl_rec_xfer = rcd_hdr.cntl_rec_xfer,
                 teco_status = rcd_hdr.teco_status,
                 storage_locn = rcd_hdr.storage_locn,
                 idoc_timestamp = rcd_hdr.idoc_timestamp
           WHERE cntl_rec_id = rcd_hdr.cntl_rec_id;
      END IF;  
   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_hdr;

   /**************************************************/
   /* This procedure performs the record BOM routine */
   /**************************************************/
   PROCEDURE process_record_bom(par_record IN VARCHAR2) IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('BOM', par_record);
     
      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
   SELECT recipe_bom_id_seq.NEXTVAL INTO rcd_bom.recipe_bom_id FROM dual;    
      rcd_bom.proc_order := rcd_hdr.proc_order;
      rcd_bom.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_bom.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_bom.seq := lics_inbound_utility.get_variable('SEQ');
      rcd_bom.material_code := lics_inbound_utility.get_variable('MATERIAL_CODE');
      rcd_bom.material_desc := lics_inbound_utility.get_variable('MATERIAL_DESC');
      rcd_bom.material_qty := lics_inbound_utility.get_number('MATERIAL_QTY',NULL);
      IF rcd_bom.material_qty = -1 THEN
          rcd_bom.material_qty := NULL;
      END IF;
      rcd_bom.material_uom := lics_inbound_utility.get_variable('MATERIAL_UOM');
      rcd_bom.material_prnt := lics_inbound_utility.get_variable('MATERIAL_PRNT');
      rcd_bom.bf_item := lics_inbound_utility.get_variable('BF_ITEM');
      rcd_bom.reservation := lics_inbound_utility.get_variable('RESERVATION');
      rcd_bom.plant_code := lics_inbound_utility.get_variable('PLANT');
      rcd_bom.pan_size := lics_inbound_utility.get_number('PAN_SIZE',NULL);
      IF rcd_bom.pan_size = -1 THEN
          rcd_bom.pan_size := NULL;
      END IF;
      rcd_bom.last_pan_size := lics_inbound_utility.get_number('LAST_PAN_SIZE',NULL);
      IF rcd_bom.last_pan_size = -1 THEN
          rcd_bom.last_pan_size := NULL;
      END IF;
      rcd_bom.pan_size_flag := lics_inbound_utility.get_variable('PAN_SIZE_FLAG');
      rcd_bom.pan_qty := lics_inbound_utility.get_number('PAN_QTY',NULL);
      IF rcd_bom.pan_qty = -1 THEN
          rcd_bom.pan_qty := NULL;
      END IF;
      rcd_bom.phantom := lics_inbound_utility.get_variable('PHANTOM');
      rcd_bom.operation_from := lics_inbound_utility.get_variable('OPERATION_FROM');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_bom.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - BOM.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
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
          plant_code,
          pan_size,
          last_pan_size,
          pan_size_flag,
          pan_qty,
          phantom,
          operation_from)
      VALUES
         (rcd_bom.recipe_bom_id,
    rcd_bom.proc_order,
          rcd_bom.operation,
          rcd_bom.phase,
          rcd_bom.seq,
          rcd_bom.material_code,
          rcd_bom.material_desc,
          rcd_bom.material_qty,
          rcd_bom.material_uom,
          rcd_bom.material_prnt,
          rcd_bom.bf_item,
          rcd_bom.reservation,
          rcd_bom.plant_code,
          rcd_bom.pan_size,
          rcd_bom.last_pan_size,
          rcd_bom.pan_size_flag,
          rcd_bom.pan_qty,
          rcd_bom.phantom,
          rcd_bom.operation_from);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_bom;

   /**************************************************/
   /* This procedure performs the record RES routine */
   /**************************************************/
   PROCEDURE process_record_res(par_record IN VARCHAR2) IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('RES', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
   SELECT recipe_resource_id_seq.NEXTVAL INTO rcd_res.recipe_resource_id FROM dual;
      rcd_res.proc_order := rcd_hdr.proc_order;
      rcd_res.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_res.resource_code := lics_inbound_utility.get_variable('RESOURCE_CODE');
      rcd_res.batch_qty := lics_inbound_utility.get_number('BATCH_QTY',NULL);
      IF rcd_res.batch_qty = -1 THEN
          rcd_res.batch_qty := NULL;
      END IF;
      rcd_res.batch_uom := lics_inbound_utility.get_variable('BATCH_UOM');
      rcd_res.phantom := lics_inbound_utility.get_variable('PHANTOM');
      rcd_res.phantom_desc := lics_inbound_utility.get_variable('PHANTOM_DESC');
      rcd_res.phantom_qty := lics_inbound_utility.get_variable('PHANTOM_QTY');
      rcd_res.phantom_uom := lics_inbound_utility.get_variable('PHANTOM_UOM');
      rcd_res.plant_code := lics_inbound_utility.get_variable('PLANT');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_res.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - RES.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      INSERT INTO bds_recipe_resource
         (recipe_resource_id,
    proc_order,
          operation,
          resource_code,
          batch_qty,
          batch_uom,
          phantom,
          phantom_desc,
          phantom_qty,
          phantom_uom,
          plant_code)
      VALUES
         (rcd_res.recipe_resource_id,
    rcd_res.proc_order,
          rcd_res.operation,
          rcd_res.resource_code,
          rcd_res.batch_qty,
          rcd_res.batch_uom,
          rcd_res.phantom,
          rcd_res.phantom_desc,
          rcd_res.phantom_qty,
          rcd_res.phantom_uom,
          rcd_res.plant_code);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_res;

   /**************************************************/
   /* This procedure performs the record STX routine */
   /**************************************************/
   PROCEDURE process_record_stx(par_record IN VARCHAR2) IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('STX', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
   SELECT recipe_src_text_id_seq.NEXTVAL INTO rcd_stx.recipe_src_text_id FROM dual;
      rcd_stx.proc_order := rcd_hdr.proc_order;
      rcd_stx.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_stx.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_stx.seq := lics_inbound_utility.get_variable('SEQ');
      rcd_stx.src_type := lics_inbound_utility.get_variable('SRC_TYPE');
      rcd_stx.machine_code := lics_inbound_utility.get_variable('MACHINE_CODE');
      rcd_stx.plant_code := lics_inbound_utility.get_variable('PLANT');
      rcd_stx.src_text := NULL;
      rcd_stx.detail_desc := NULL;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_stx.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - STX.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      INSERT INTO bds_recipe_src_text
         (recipe_src_text_id,
    proc_order,
          operation,
          phase,
          seq,
          src_type,
          machine_code,
          plant_code,
          src_text,
          detail_desc)
      VALUES
         (rcd_stx.recipe_src_text_id,
    rcd_stx.proc_order,
          rcd_stx.operation,
          rcd_stx.phase,
          rcd_stx.seq,
          rcd_stx.src_type,
          rcd_stx.machine_code,
          rcd_stx.plant_code,
          rcd_stx.src_text,
          rcd_stx.detail_desc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_stx;

   /**************************************************/
   /* This procedure performs the record ST1 routine */
   /**************************************************/
   PROCEDURE process_record_st1(par_record IN VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_text_data VARCHAR2(500 CHAR);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('ST1', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_stx.proc_order := rcd_hdr.proc_order;
      rcd_stx.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_stx.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_stx.seq := lics_inbound_utility.get_variable('SEQ');
      var_text_data := lics_inbound_utility.get_variable('TEXT_DATA');
      
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_stx.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - ST1.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      UPDATE bds_recipe_src_text
         SET src_text = REPLACE(REPLACE(src_text || var_text_data,'&.NEW_LINE',CHR(13)),'&.TAB',CHR(9))
       WHERE recipe_src_text_id = rcd_stx.recipe_src_text_id;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_st1;

   /**************************************************/
   /* This procedure performs the record ST2 routine */
   /**************************************************/
   PROCEDURE process_record_st2(par_record IN VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_text_data VARCHAR2(500 CHAR);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('ST2', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_stx.proc_order := rcd_hdr.proc_order;
      rcd_stx.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_stx.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_stx.seq := lics_inbound_utility.get_variable('SEQ');
      var_text_data := lics_inbound_utility.get_variable('TEXT_DATA');
      
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_stx.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - ST2.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      UPDATE bds_recipe_src_text
         SET detail_desc = REPLACE(REPLACE(detail_desc || var_text_data,'&.NEW_LINE',CHR(13)),'&.TAB',CHR(9))
       WHERE recipe_src_text_id = rcd_stx.recipe_src_text_id;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_st2;

   /**************************************************/
   /* This procedure performs the record SVL routine */
   /**************************************************/
   PROCEDURE process_record_svl(par_record IN VARCHAR2) IS

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('SVL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
   SELECT recipe_src_value_id_seq.NEXTVAL INTO rcd_svl.recipe_src_value_id FROM dual;
      rcd_svl.proc_order := rcd_hdr.proc_order;
      rcd_svl.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_svl.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_svl.seq := lics_inbound_utility.get_variable('SEQ');
      rcd_svl.src_tag := lics_inbound_utility.get_variable('SRC_TAG');
      rcd_svl.src_val := lics_inbound_utility.get_variable('SRC_VAL');
      rcd_svl.src_uom := lics_inbound_utility.get_variable('SRC_UOM');
      rcd_svl.machine_code := lics_inbound_utility.get_variable('MACHINE_CODE');
      rcd_svl.plant_code := lics_inbound_utility.get_variable('PLANT');
      rcd_svl.src_desc := NULL;
      rcd_svl.detail_desc := NULL;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_svl.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - SVL.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      INSERT INTO bds_recipe_src_value
         (recipe_src_value_id,
    proc_order,
          operation,
          phase,
          seq,
          src_tag,
          src_val,
          src_uom,
          machine_code,
          plant_code,
          src_desc,
          detail_desc)
      VALUES
         (rcd_svl.recipe_src_value_id,
    rcd_svl.proc_order,
          rcd_svl.operation,
          rcd_svl.phase,
          rcd_svl.seq,
          rcd_svl.src_tag,
          rcd_svl.src_val,
          rcd_svl.src_uom,
          rcd_svl.machine_code,
          rcd_svl.plant_code,
          rcd_svl.src_desc,
          rcd_svl.detail_desc);

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_svl;

   /**************************************************/
   /* This procedure performs the record SV1 routine */
   /**************************************************/
   PROCEDURE process_record_sv1(par_record IN VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_text_data VARCHAR2(500 CHAR);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('SV1', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_svl.proc_order := rcd_hdr.proc_order;
      rcd_svl.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_svl.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_svl.seq := lics_inbound_utility.get_variable('SEQ');
      var_text_data := lics_inbound_utility.get_variable('TEXT_DATA');
     
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_svl.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - SV1.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      UPDATE bds_recipe_src_value
         SET src_desc = REPLACE(REPLACE(src_desc || var_text_data,'&.NEW_LINE',CHR(13)),'&.TAB',CHR(9))
       WHERE recipe_src_value_id = rcd_svl.recipe_src_value_id;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_sv1;

   /**************************************************/
   /* This procedure performs the record SV2 routine */
   /**************************************************/
   PROCEDURE process_record_sv2(par_record IN VARCHAR2) IS

      /*-*/
      /* Local definitions
      /*-*/
      var_text_data VARCHAR2(500 CHAR);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      IF var_trn_ignore = TRUE THEN
         RETURN;
      END IF;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('SV2', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_svl.proc_order := rcd_hdr.proc_order;
      rcd_svl.operation := lics_inbound_utility.get_variable('OPERATION');
      rcd_svl.phase := lics_inbound_utility.get_variable('PHASE');
      rcd_svl.seq := lics_inbound_utility.get_variable('SEQ');
      var_text_data := lics_inbound_utility.get_variable('TEXT_DATA');
     
      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      IF lics_inbound_utility.has_errors = TRUE THEN
         var_trn_error := TRUE;
      END IF;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      IF rcd_svl.proc_order IS NULL THEN
         lics_inbound_utility.add_exception('Missing Primary Key - SV2.PROC_ORDER');
         var_trn_error := TRUE;
      END IF;

      /*-------------------------------------------*/
      /* ERROR - Ignore the data row when required */
      /*-------------------------------------------*/
      IF var_trn_error = TRUE THEN
         RETURN;
      END IF;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      UPDATE bds_recipe_src_value
         SET detail_desc = REPLACE(REPLACE(detail_desc || var_text_data,'&.NEW_LINE',CHR(13)),'&.TAB',CHR(9))
       WHERE recipe_src_value_id = rcd_svl.recipe_src_value_id;

   /*-------------*/
   /* End routine */
   /*-------------*/
   END process_record_sv2;

END Ladpdb01_Loader;
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb01_loader to appsupport;
grant execute on bds_app.ladpdb01_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb01_loader for bds_app.ladpdb01_loader;