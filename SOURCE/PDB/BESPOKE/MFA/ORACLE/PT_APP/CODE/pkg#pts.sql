DROP PACKAGE PT_APP.PKG#PTS;

CREATE OR REPLACE PACKAGE PT_APP.Pkg#PTS IS
----------------------------------------------------------------[PROCEDURES]
------------------------------------------------[pro#citec_delete_err_xactn]
   PROCEDURE pro#citec_delete_err_xactn(
      in#xactn_seq                  IN NUMBER);
---------------------------------------------[pro#citec_reprocess_err_xactn]
   PROCEDURE pro#citec_reprocess_err_xactn(
      in#xactn_seq                  IN NUMBER);
----------------------------------------------------[pro#delete_error_batch]
   PROCEDURE pro#delete_error_batch(
      in#batch_code                 IN NUMBER);
---------------------------------------------------------[pro#process_batch]
   PROCEDURE pro#process_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER);
-----------------------------------------------------------[pro#disposition]
   PROCEDURE pro#disposition(
      in#disposition_code           IN NUMBER);
-------------------------------------------------[pro#reprocess_error_batch]
   PROCEDURE pro#reprocess_error_batch(
      in#batch_code                 IN NUMBER);
-------------------------------------------------[pro#reprocess_batch_errors]
   PROCEDURE pro#reprocess_batch_errors;

-----------------------------------------------------------------[FUNCTIONS]
-----------------------------------------------------[fun#process_psh_batch]
   FUNCTION fun#process_psh_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER
      ,ov2#batch_status             OUT VARCHAR2
      ,on#batch_err_rec_num         OUT NUMBER
      ,ov2#batch_err_msg            OUT VARCHAR2)
      RETURN                        BOOLEAN;
------------------------------------------------------[fun#split_psh_record]
   FUNCTION fun#split_psh_record(
      iv2#batch_rec                 IN VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,ov2#material_code             OUT VARCHAR2
      ,ov2#plt_code                 OUT VARCHAR2
      ,ov2#shipto                    OUT VARCHAR2
      ,ov2#load_num                 OUT VARCHAR2
      ,ov2#order_num                OUT VARCHAR2
      ,od#desp_date                 OUT DATE
      ,on#qty                       OUT NUMBER
      ,od#use_by_date               OUT DATE
	  ,ov2#zpppi_batch				OUT VARCHAR2)
      RETURN                        BOOLEAN;
-----------------------------------------------------[fun#process_sto_batch]
   FUNCTION fun#process_sto_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER
      ,ov2#batch_status             OUT VARCHAR2
      ,on#batch_err_rec_num         OUT NUMBER
      ,ov2#batch_err_msg            OUT VARCHAR2)
      RETURN                        BOOLEAN;
------------------------------------------------------[fun#split_sto_record]
   FUNCTION fun#split_sto_record(
      iv2#batch_rec                 IN VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,ov2#plt_code                 OUT VARCHAR2
      ,ov2#material_code             OUT VARCHAR2
      ,ov2#sto_cnn_code                 OUT VARCHAR2
      ,ov2#driver_id                OUT VARCHAR2
      ,od#confirm_date              OUT DATE
	  ,on#confirm_time				OUT NUMBER
      ,ov2#trailer_id               OUT VARCHAR2
      ,on#qty                       OUT NUMBER
      ,ov2#dispn_code               OUT VARCHAR2
      ,ov2#loader_id                OUT VARCHAR2
      ,ov2#status                   OUT VARCHAR2
      ,ov2#zpppi_batch		    OUT VARCHAR2)
      RETURN                        BOOLEAN;
--------------------------------------------------------[pkg#plt.header.end]
END Pkg#PTS;
/


DROP PACKAGE BODY PT_APP.PKG#PTS;

CREATE OR REPLACE PACKAGE BODY PT_APP.Pkg#pts IS
-------------------------------------------------------------------[Globals]
   gbl#TRUE                      BOOLEAN DEFAULT TRUE;
   gbl#FALSE                     BOOLEAN DEFAULT FALSE;
   gbl#SUCCESS                   BOOLEAN DEFAULT TRUE;
   gbl#FAIL                      BOOLEAN DEFAULT FALSE;
   gv2#err_msg                   VARCHAR2(4000);
   gn#err_msg_len                NUMBER DEFAULT 4000;
   gv2#to_whse_code              VARCHAR2(5) DEFAULT '880';
----------------------------------------------------------------[Exceptions]
   ex#process_exception          EXCEPTION;
----------------------------------------------------------------[PROCEDURES]
------------------------------------------------[pro#citec_delete_err_xactn]
   PROCEDURE pro#citec_delete_err_xactn(
      in#xactn_seq                  IN NUMBER)
   IS
      CURSOR csr#pts_intfc_err(
         in#xactn_seq                  IN NUMBER)
      IS
      SELECT *
      FROM pts_intfc_err
      WHERE xactn_seq = in#xactn_seq;

      rec#pts_intfc_err             csr#pts_intfc_err%ROWTYPE;
   BEGIN
      OPEN csr#pts_intfc_err(in#xactn_seq);
      FETCH csr#pts_intfc_err INTO rec#pts_intfc_err;
      IF (csr#pts_intfc_err%NOTFOUND) THEN
         gv2#err_msg := 'Transaction Code Not Found ['||TO_CHAR(in#xactn_seq)
            ||']';
         CLOSE csr#pts_intfc_err;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#pts_intfc_err;

      -- Remove Transaction from Error
      DELETE FROM pts_intfc_err
      WHERE xactn_seq = rec#pts_intfc_err.xactn_seq;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Citec Delete Error Transaction'
            ||', Transaction Sequence ['||TO_CHAR(in#xactn_seq)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#citec_delete_err_xactn;

---------------------------------------------[pro#citec_reprocess_err_xactn]
   PROCEDURE pro#citec_reprocess_err_xactn(
      in#xactn_seq                  IN NUMBER)
   IS
      CURSOR csr#pts_intfc_err(
         in#xactn_seq                  IN NUMBER)
      IS
      SELECT *
      FROM pts_intfc_err
      WHERE xactn_seq = in#xactn_seq;

      rec#pts_intfc_err             csr#pts_intfc_err%ROWTYPE;
   BEGIN
      OPEN csr#pts_intfc_err(in#xactn_seq);
      FETCH csr#pts_intfc_err INTO rec#pts_intfc_err;
      IF (csr#pts_intfc_err%NOTFOUND) THEN
         gv2#err_msg := 'Transaction Code Not Found ['||TO_CHAR(in#xactn_seq)
            ||']';
         CLOSE csr#pts_intfc_err;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#pts_intfc_err;

      -- Reprocess Transaction (via Triggers)
      INSERT INTO pt.pts_intfc(
         xactn_type
         , xactn_date
      , XACTN_TIME
      , PLANT_CODE
      , SENDER_NAME
      , ZPPPI_BATCH
      , PROC_ORDER
      , STOR_LOC_CODE
      , DISPN_CODE
         , use_by_date
         , plt_code
         , material_code
         , uom
         , qty
         , full_plt_flag
         , whse_code
         , whse_locn_code
         , work_centre
         , user_id
         , rework_code
   , last_gr_flag)
      SELECT xactn_type
         , xactn_date
      , XACTN_TIME
      , PLANT_CODE
      , SENDER_NAME
      , ZPPPI_BATCH
      , PROC_ORDER
      , STOR_LOC_CODE
      , DISPN_CODE
         , use_by_date
         , plt_code
         , material_code
         , uom
         , qty
         , full_plt_flag
         , whse_code
         , whse_locn_code
         , work_centre
         , user_id
         , rework_code
   , last_gr_flag
      FROM pt.pts_intfc_err
      WHERE xactn_seq = in#xactn_seq;

      -- Remove Transaction from Error
      DELETE FROM pts_intfc_err
      WHERE xactn_seq = rec#pts_intfc_err.xactn_seq;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Citec Reprocess Error Transaction'
            ||', Transaction Sequence ['||TO_CHAR(in#xactn_seq)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#citec_reprocess_err_xactn;

----------------------------------------------------[pro#delete_error_batch]
   PROCEDURE pro#delete_error_batch(
      in#batch_code                 IN NUMBER)
   IS

      CURSOR csr#pts_batch_cntl(
         in#batch_code                 IN NUMBER)
      IS
      SELECT *
      FROM pts_batch_cntl
      WHERE batch_code = in#batch_code
      AND batch_seq_code IN (
         SELECT DISTINCT batch_seq_code
         FROM pts_batch_err
         WHERE batch_code = in#batch_code);

      rec#pts_batch_cntl                csr#pts_batch_cntl%ROWTYPE;
   BEGIN
      OPEN csr#pts_batch_cntl(in#batch_code);
      FETCH csr#pts_batch_cntl INTO rec#pts_batch_cntl;
      IF (csr#pts_batch_cntl%NOTFOUND) THEN
         gv2#err_msg := 'Batch Code Not Found ['||TO_CHAR(in#batch_code)
            ||']';
         CLOSE csr#pts_batch_cntl;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#pts_batch_cntl;

      IF (rec#pts_batch_cntl.batch_status <> 'ERROR') THEN
         gv2#err_msg := 'Invalid Batch Status ['||rec#pts_batch_cntl.batch_status
            ||']';
         RAISE ex#process_exception;
      END IF;

      -- Update Batch Control
      UPDATE pts_batch_cntl
      SET batch_status = 'DELETED'
         ,procg_strtd_date = SYSDATE
         ,procg_compld_date = SYSDATE
      WHERE batch_code = rec#pts_batch_cntl.batch_code
      AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

      -- Remove Batch from Error
      DELETE FROM pts_batch_err
      WHERE batch_code = rec#pts_batch_cntl.batch_code
      AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Delete Error Batch'
            ||', Batch Code ['||TO_CHAR(in#batch_code)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#delete_error_batch;

---------------------------------------------------------[pro#process_batch]
   PROCEDURE pro#process_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER)
   IS
      d#procg_strtd_date            DATE DEFAULT SYSDATE;
      v2#batch_status               VARCHAR2(20);
      n#batch_err_rec_num           NUMBER(10);
      v2#batch_err_msg              VARCHAR2(4000);

      CURSOR csr#pts_batch_cntl(
         in#batch_code                 IN NUMBER
         ,in#batch_seq_code            IN NUMBER)
      IS
      SELECT *
      FROM pts_batch_cntl
      WHERE batch_code = in#batch_code
      AND batch_seq_code = in#batch_seq_code;

      rec#pts_batch_cntl          csr#pts_batch_cntl%ROWTYPE;
   BEGIN
      -- Cleanup Batch Error Table
      --   Remove NON-ERRORS...
      DELETE FROM pts_batch_err
      WHERE err_msg LIKE 'Processed by another Batch [%';
      COMMIT;

      -- Query Batch Control
      OPEN csr#pts_batch_cntl(in#batch_code, in#batch_seq_code);
      FETCH csr#pts_batch_cntl INTO rec#pts_batch_cntl;
      IF (csr#pts_batch_cntl%NOTFOUND) THEN
         gv2#err_msg := 'Batch Not Found';
         CLOSE csr#pts_batch_cntl;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#pts_batch_cntl;

      IF (rec#pts_batch_cntl.batch_status NOT IN ('LOADED', 'RE-PROCESS')) THEN
         gv2#err_msg := 'Invalid Batch Status ['||rec#pts_batch_cntl.batch_status
            ||']';
         RAISE ex#process_exception;
      END IF;

      -- Identify and Process Batch, by Batch Type
      IF (rec#pts_batch_cntl.batch_type = 'STO') THEN
         -- Stock Transfer Order Batch
         IF (fun#process_sto_batch(
            in#batch_code
            ,in#batch_seq_code
            ,v2#batch_status
            ,n#batch_err_rec_num
            ,v2#batch_err_msg) = gbl#FAIL) THEN
            RAISE ex#process_exception;
         END IF;
      ELSIF (rec#pts_batch_cntl.batch_type = 'PSH') THEN
         -- Ship To Batch
         IF (fun#process_psh_batch(
            in#batch_code
            ,in#batch_seq_code
            ,v2#batch_status
            ,n#batch_err_rec_num
            ,v2#batch_err_msg) = gbl#FAIL) THEN
            RAISE ex#process_exception;
         END IF;
      ELSE
         -- Unknown Batch Type
         v2#batch_status := 'ERROR';
         n#batch_err_rec_num := 1;
         v2#batch_err_msg := 'Unknown Batch Type ['
            ||rec#pts_batch_cntl.batch_type||']';
      END IF;

      -- Update Batch Control
      UPDATE pts_batch_cntl
      SET procg_strtd_date = d#procg_strtd_date
         ,procg_compld_date = SYSDATE
         ,batch_status = v2#batch_status
      WHERE batch_code = rec#pts_batch_cntl.batch_code
      AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

      IF (rec#pts_batch_cntl.batch_type <> 'PSH') THEN
         IF (v2#batch_status = 'ERROR') THEN
            INSERT INTO pts_batch_err(
               batch_code
               ,batch_seq_code
               ,batch_rec_num
               ,batch_rec
               ,err_msg
               ,procg_code)
            SELECT batch_code
               ,batch_seq_code
               ,batch_rec_num
               ,batch_rec
               ,DECODE((n#batch_err_rec_num-batch_rec_num)
                  ,0 , v2#batch_err_msg
                  ,NULL)
               ,'ERROR'
            FROM pts_batch_data
            WHERE batch_code = in#batch_code
            AND batch_seq_code = in#batch_seq_code;
         END IF;

         DELETE FROM pts_batch_data
         WHERE batch_code = in#batch_code
         AND batch_seq_code = in#batch_seq_code;
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Process Batch'
            ||', Batch Code ['||TO_CHAR(in#batch_code)
            ||'], Batch Sequence Code ['||TO_CHAR(in#batch_seq_code)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#process_batch;

-----------------------------------------------------------[pro#disposition]
   PROCEDURE pro#disposition(in#disposition_code IN NUMBER)
   IS
      CURSOR csr#pts_disposition
      IS
      SELECT pts_trans.*
      FROM pts_plt ,pts_trans
      WHERE pts_plt.plt_trans_xactn_seq = pts_trans.xactn_seq
      AND pts_trans.sta_code IS NOT NULL
      AND pts_trans.sta_status = 'C'
      AND plt_cancel_intfc_xactn_seq IS NULL
      AND pts_trans.disposition_code IS NULL;

      rec#pts_disposition csr#pts_disposition%ROWTYPE;
   BEGIN
      -- Create Disposition Header
      INSERT INTO pts_disposition(disposition_code)
      VALUES(in#disposition_code);
   COMMIT;

      -- Create Disposition Transaction
      OPEN csr#pts_disposition;
         LOOP
         FETCH csr#pts_disposition INTO rec#pts_disposition;
         EXIT WHEN csr#pts_disposition%NOTFOUND;

         INSERT INTO pts_trans(
      xactn_type
            ,plt_code
            ,sta_code
            ,disposition_code
            ,disposition_by
            ,disposition_date)
         VALUES(
            'DSPOSITION'
            ,rec#pts_disposition.plt_code
            ,rec#pts_disposition.sta_code
            ,in#disposition_code
            ,USER
            ,SYSDATE
   );
         COMMIT;

      END LOOP;
      CLOSE csr#pts_disposition;
      COMMIT;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Disposition'
            ||', Disposition Code ['||TO_CHAR(in#disposition_code)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#disposition;

-------------------------------------------------[pro#reprocess_error_batch]
   PROCEDURE pro#reprocess_error_batch(
      in#batch_code                 IN NUMBER)
   IS

      CURSOR csr#pts_batch_cntl(
         in#batch_code                 IN NUMBER)
      IS
      SELECT *
      FROM pts_batch_cntl
      WHERE batch_code = in#batch_code
      AND batch_seq_code IN (
         SELECT DISTINCT batch_seq_code
         FROM pts_batch_err
         WHERE batch_code = in#batch_code);

      rec#pts_batch_cntl                csr#pts_batch_cntl%ROWTYPE;
   BEGIN
      OPEN csr#pts_batch_cntl(in#batch_code);
      FETCH csr#pts_batch_cntl INTO rec#pts_batch_cntl;
      IF (csr#pts_batch_cntl%NOTFOUND) THEN
         gv2#err_msg := 'Batch Code Not Found ['||TO_CHAR(in#batch_code)
            ||']';
         CLOSE csr#pts_batch_cntl;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#pts_batch_cntl;

      IF (rec#pts_batch_cntl.batch_status <> 'ERROR') THEN
         gv2#err_msg := 'Invalid Batch Status ['||rec#pts_batch_cntl.batch_status
            ||']';
         RAISE ex#process_exception;
      END IF;

      -- Create New Batch Control (New Sequence)
      INSERT INTO pts_batch_cntl(
         batch_code
         ,batch_seq_code
         ,batch_type
         ,batch_file_name
         ,procg_strtd_date
         ,procg_compld_date
         ,batch_rows
         ,batch_status
         ,replct_batch_code)
      SELECT batch_code
         ,(batch_seq_code+1)
         ,batch_type
         ,batch_file_name
         ,NULL
         ,NULL
         ,batch_rows
         ,'RE-PROCESS'
         ,replct_batch_code
      FROM pts_batch_cntl
      WHERE batch_code = rec#pts_batch_cntl.batch_code
      AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

      -- Move Batch from Error to Data
      INSERT INTO pts_batch_data(
         batch_code
         ,batch_seq_code
         ,batch_rec_num
         ,batch_rec)
      SELECT batch_code
         ,(batch_seq_code+1)
         ,batch_rec_num
         ,batch_rec
      FROM pts_batch_err
      WHERE batch_code = rec#pts_batch_cntl.batch_code
      AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

      -- Remove Batch from Error
      DELETE FROM pts_batch_err
      WHERE batch_code = rec#pts_batch_cntl.batch_code
      AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

      -- Reprocess Batch
      pro#process_batch(rec#pts_batch_cntl.batch_code
         ,rec#pts_batch_cntl.batch_seq_code+1);

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Reprocess Error Batch'
            ||', Batch Code ['||TO_CHAR(in#batch_code)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#reprocess_error_batch;

-------------------------------------------------[pro#reprocess_batch_errors]
   PROCEDURE pro#reprocess_batch_errors IS

   CURSOR csr#pts_batch_cntl IS
   SELECT *
   FROM   pts_batch_cntl
   WHERE  (batch_code, batch_seq_code) IN
    (SELECT batch_code, batch_seq_code FROM pts_batch_err);
   rec#pts_batch_cntl csr#pts_batch_cntl%ROWTYPE;

   BEGIN
      FOR rec#pts_batch_cntl in csr#pts_batch_cntl LOOP

         -- Create New Batch Control (New Sequence)
         INSERT INTO pts_batch_cntl(
             batch_code
            ,batch_seq_code
            ,batch_type
            ,batch_file_name
            ,procg_strtd_date
            ,procg_compld_date
            ,batch_rows
            ,batch_status
            ,replct_batch_code)
         VALUES (
       rec#pts_batch_cntl.batch_code
            ,rec#pts_batch_cntl.batch_seq_code + 1
            ,rec#pts_batch_cntl.batch_type
            ,rec#pts_batch_cntl.batch_file_name
            ,NULL
            ,NULL
            ,rec#pts_batch_cntl.batch_rows
            ,'RE-PROCESS'
            ,rec#pts_batch_cntl.replct_batch_code);

         -- Move Batch from Error to Data
         INSERT INTO pts_batch_data(
             batch_code
            ,batch_seq_code
            ,batch_rec_num
            ,batch_rec)
         SELECT batch_code
            ,(batch_seq_code+1)
            ,batch_rec_num
            ,batch_rec
         FROM pts_batch_err
         WHERE batch_code = rec#pts_batch_cntl.batch_code
         AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

         -- Remove Batch from Error
         DELETE FROM pts_batch_err
         WHERE batch_code = rec#pts_batch_cntl.batch_code
         AND batch_seq_code = rec#pts_batch_cntl.batch_seq_code;

         -- Reprocess Batch
         pro#process_batch(rec#pts_batch_cntl.batch_code, rec#pts_batch_cntl.batch_seq_code + 1);

         COMMIT;
      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Reprocessing Batch Errors. '
            ||' RETURN ['||SQLERRM(SQLCODE)||'] '
            ||': '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#reprocess_batch_errors;

-----------------------------------------------------------------[FUNCTIONS]
-----------------------------------------------------[fun#process_psh_batch]
   FUNCTION fun#process_psh_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER
      ,ov2#batch_status             OUT VARCHAR2
      ,on#batch_err_rec_num         OUT NUMBER
      ,ov2#batch_err_msg            OUT VARCHAR2)
      RETURN                        BOOLEAN
   IS
      -- Currenct SHP
      v2#rec_type                   VARCHAR2(3);
      v2#material_code             VARCHAR2(8);
      v2#plt_code                   VARCHAR2(20);
      v2#shipto                  VARCHAR2(10);
      v2#load_num                   VARCHAR2(9);
      v2#order_num                  VARCHAR2(10);
      d#desp_date                   DATE;
      n#qty                         NUMBER(6);
      d#use_by_date                 DATE;
   v2#zpppi_batch    VARCHAR2(10);
      -- Working
      bl#err_flg                    BOOLEAN;
      n#commit_counter              NUMBER;

      -- Batch Cursor
      CURSOR csr#pts_batch_data(
         in#batch_code                 IN NUMBER
         ,in#batch_seq_code            IN NUMBER)
      IS
      SELECT pts_batch_data.batch_rec_num
         ,pts_batch_data.batch_rec
         ,pts_batch_cntl.batch_rows
         ,pts_batch_cntl.ROWID pts_batch_cntl_ROWID
         ,pts_batch_data.ROWID pts_batch_data_ROWID
      FROM pts_batch_cntl
         ,pts_batch_data
      WHERE pts_batch_cntl.batch_code = pts_batch_data.batch_code
      AND pts_batch_cntl.batch_seq_code = pts_batch_data.batch_seq_code
      AND pts_batch_cntl.batch_code = in#batch_code
      AND pts_batch_cntl.batch_seq_code = in#batch_seq_code
      FOR UPDATE;

      rec#pts_batch_data                   csr#pts_batch_data%ROWTYPE;

      -- Ship To Cursor
      CURSOR csr#psh_shipto(
         iv2#plt_code                  IN VARCHAR2
         ,iv2#order_num                IN VARCHAR2)
      IS
      SELECT batch_code
        ,psh_shipto.ROWID psh_shipto_ROWID
      FROM pt.psh_shipto
      WHERE psh_shipto.plt_code = iv2#plt_code
      AND psh_shipto.order_num = iv2#order_num
      FOR UPDATE;

      rec#psh_shipto                   csr#psh_shipto%ROWTYPE;
   BEGIN
      ov2#batch_status := 'PROCESSED';
      on#batch_err_rec_num := NULL;
      ov2#batch_err_msg := NULL;

      -- Process Batch
      OPEN csr#pts_batch_data(in#batch_code, in#batch_seq_code);
      LOOP
         bl#err_flg := FALSE;

         FETCH csr#pts_batch_data INTO rec#pts_batch_data;
         EXIT WHEN csr#pts_batch_data%NOTFOUND;

         -- Split PSH Record
         IF (fun#split_psh_record(
            rec#pts_batch_data.batch_rec
            ,v2#rec_type
            ,v2#material_code
            ,v2#plt_code
            ,v2#shipto
            ,v2#load_num
            ,v2#order_num
            ,d#desp_date
            ,n#qty
            ,d#use_by_date
   ,v2#zpppi_batch) = gbl#FAIL) THEN

            bl#err_flg := TRUE;
            on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
            ov2#batch_err_msg := gv2#err_msg;
         ELSE
            -- Insert or Update as Required
            BEGIN
               ov2#batch_err_msg := 'CURSOR csr#psh_shipto(['
                  ||v2#plt_code||'], ['||v2#order_num||']);';

               rec#psh_shipto := NULL;
               OPEN csr#psh_shipto(v2#plt_code, v2#order_num);
               FETCH csr#psh_shipto INTO rec#psh_shipto;
               CLOSE csr#psh_shipto;

               IF (rec#psh_shipto.batch_code IS NULL) THEN
                  ov2#batch_err_msg := 'INSERT into Pallet Ship To Table Failed';
                  INSERT INTO pt.psh_shipto(
                     batch_code
                     ,rec_type
                     ,material_code
                     ,plt_code
                     ,shipto
                     ,load_num
                     ,order_num
                     ,desp_date
                     ,qty
                     ,use_by_date
                     ,line_cnt
      ,zpppi_batch)
                  VALUES(
                     in#batch_code
                     ,v2#rec_type
                     ,v2#material_code
                     ,v2#plt_code
                     ,v2#shipto
                     ,v2#load_num
                     ,v2#order_num
                     ,d#desp_date
                     ,n#qty
                     ,d#use_by_date
                     ,1
      ,v2#zpppi_batch);
               ELSE
                  IF (rec#psh_shipto.batch_code = in#batch_code) THEN
                     ov2#batch_err_msg := 'UPDATE of Pallet Ship To Table Failed';
                     UPDATE psh_shipto
                     SET qty              = qty+n#qty
                        ,line_cnt         = line_cnt+1
                     WHERE psh_shipto.ROWID = rec#psh_shipto.psh_shipto_ROWID;
                  ELSE
                     bl#err_flg := TRUE;
                     ov2#batch_err_msg := 'Processed by another Batch ['
                        ||rec#psh_shipto.batch_code||']';
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  bl#err_flg := TRUE;
                  on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
                  ov2#batch_err_msg := ov2#batch_err_msg
                     ||', Batch Code ['||TO_CHAR(in#batch_code)
                     ||'], Record Type ['||v2#rec_type
                     ||'], Material Code ['||v2#material_code
                     ||'], Pallet Code ['||v2#plt_code
                     ||'], SHIPTO Code ['||v2#shipto
                     ||'], Load Number ['||v2#load_num
                     ||'], Order Number ['||v2#order_num
                     ||'], Despatch Date ['||TO_CHAR(d#desp_date, 'YYYYMONDD')
                     ||'], Quantity ['||TO_CHAR(n#qty)
                     ||'], Use By Date ['||TO_CHAR(d#use_by_date, 'YYYYMONDD')
      ||'], ZPPPI_BATCH ['||v2#zpppi_batch
                     ||'], RETURN ['||SQLERRM(SQLCODE)||']';
            END;


         END IF;

         IF (bl#err_flg = TRUE) THEN
            ov2#batch_status := 'ERROR';
            INSERT INTO pts_batch_err(
               batch_code
               ,batch_seq_code
               ,batch_rec_num
               ,batch_rec
               ,err_msg
               ,procg_code)
            VALUES (
               in#batch_code
               ,in#batch_seq_code
               ,rec#pts_batch_data.batch_rec_num
               ,rec#pts_batch_data.batch_rec
               ,ov2#batch_err_msg
               ,'ERROR');
         END IF;

         DELETE FROM pts_batch_data WHERE ROWID = rec#pts_batch_data.pts_batch_data_ROWID;

         -- Commit at this point destroys the transactions autonomy,
         -- however transaction autonomy is not important for this process,
         -- and commit allows generic process to be used without alteration
         -- or extending rollback segment
         n#commit_counter := n#commit_counter + 1;
         IF (MOD(n#commit_counter, 1000) = 0) THEN
            COMMIT;
         END IF;

      END LOOP;
      CLOSE csr#pts_batch_data;

      RETURN gbl#SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         IF (csr#pts_batch_data%ISOPEN) THEN
            CLOSE csr#pts_batch_data;
         END IF;
         gv2#err_msg := SUBSTR('Process PSH Batch FAILED'
            ||', Batch Code ['||TO_CHAR(in#batch_code)
            ||'], Batch Sequence Code ['||TO_CHAR(in#batch_seq_code)
            ||'], RETURN ['||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#process_psh_batch;

------------------------------------------------------[fun#split_psh_record]

   FUNCTION fun#split_psh_record(
      iv2#batch_rec                 IN  VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,ov2#material_code            OUT VARCHAR2
      ,ov2#plt_code                 OUT VARCHAR2
      ,ov2#shipto                 OUT VARCHAR2
      ,ov2#load_num                 OUT VARCHAR2
      ,ov2#order_num                OUT VARCHAR2
      ,od#desp_date                 OUT DATE
      ,on#qty                       OUT NUMBER
      ,od#use_by_date               OUT DATE
   ,ov2#zpppi_batch    OUT VARCHAR2)
      RETURN                        BOOLEAN
   IS
      -- Working Variables
      v2#desp_date                  VARCHAR2(8);
      v2#qty                        VARCHAR2(6);
      v2#use_by_date                VARCHAR2(8);
      bl#return_value               BOOLEAN;
   BEGIN
      bl#return_value := gbl#SUCCESS;

      -- Split Record into VARCHAR2 Fields
      ov2#rec_type         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  1,   3)));
      ov2#material_code    := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  4,   8)));
      ov2#plt_code         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 12,  20)));
      ov2#shipto           := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 32,  10)));
      ov2#load_num         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 42,   9)));
      ov2#order_num        := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 51,  10)));
      v2#desp_date         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 61,   8)));
      v2#qty               := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 69,   6)));
      v2#use_by_date       := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 75,   8)));
   ov2#zpppi_batch      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 83,  10)));

      -- Initilise Required Data Type Fields
      od#use_by_date     := NULL;
      od#desp_date          := NULL;
      on#qty                := NULL;

      -- Check Record Type
      IF (ov2#rec_type = 'PSH') THEN

         -- Confirm Date
         BEGIN
            od#desp_date := TO_DATE(v2#desp_date, 'YYYYMMDD');
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Despatch Date Field ['
                  ||v2#desp_date||'] to a DATE, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

         -- Quantity
         BEGIN
            on#qty := TO_NUMBER(v2#qty);
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Quantity Field ['
                  ||v2#qty||'] to a NUMBER, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

         -- Use By Date
         BEGIN
            od#use_by_date := TO_DATE(v2#use_by_date, 'YYYYMMDD');
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Use By Date Field ['
                  ||v2#use_by_date||'] to a DATE, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;
      ELSE
         bl#return_value := gbl#FAIL;
         gv2#err_msg := SUBSTR('Invalid Record Type ['
            ||ov2#rec_type||'] : '
            ||gv2#err_msg, 1, gn#err_msg_len);
      END IF;

      RETURN bl#return_value;
   EXCEPTION
      WHEN OTHERS THEN
         gv2#err_msg := SUBSTR('Split PSH Record FAILED'
            ||', Batch Record ['   ||iv2#batch_rec
            ||'], Record Type ['   ||ov2#rec_type
            ||'], Material Code ['   ||ov2#material_code
            ||'], Pallet Code ['   ||ov2#plt_code
            ||'], SHIPTO Code ['   ||ov2#shipto
            ||'], Load Number ['   ||ov2#load_num
            ||'], Order Number ['   ||ov2#order_num
            ||'], Despatch Date ['   ||v2#desp_date
            ||'], Quantity ['    ||v2#qty
            ||'], Use By Date ['   ||v2#use_by_date
   ||'], ZPPPI BATCH ['   ||ov2#zpppi_batch
            ||'], RETURN ['       ||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#split_psh_record;

-----------------------------------------------------[fun#process_sto_batch]
   FUNCTION fun#process_sto_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER
      ,ov2#batch_status             OUT VARCHAR2
      ,on#batch_err_rec_num         OUT NUMBER
      ,ov2#batch_err_msg            OUT VARCHAR2)
      RETURN                        BOOLEAN
   IS
      -- Current STO Record Type
      v2#rec_type                   VARCHAR2(3);
      v2#plt_code                   VARCHAR2(20);
      v2#material_code               VARCHAR2(8);
      v2#sto_cnn_code                   VARCHAR2(12);
      v2#driver_id                  VARCHAR2(2);
      d#confirm_date                  DATE;
   n#confirm_time     NUMBER(6);
      v2#trailer_id                 VARCHAR2(12);
      n#qty                         NUMBER(6);
      v2#dispn_code                 VARCHAR2(2);
      v2#loader_id                  VARCHAR2(2);
      v2#status                     VARCHAR2(1);
      -- Previous STO Record Type
      v2#last_rec_type              VARCHAR2(3);
      v2#last_sto_cnn_code              VARCHAR2(12);
      v2#last_driver_id             VARCHAR2(2);
      v2#last_trailer_id            VARCHAR2(12);
      v2#last_loader_id             VARCHAR2(2);
      v2#last_status                VARCHAR2(1);
   v2#zpppi_batch    VARCHAR2(10);
      -- Working
      bl#first_rec_flg              BOOLEAN;

      -- Batch Cursor
      CURSOR csr#pts_batch_data(
         in#batch_code                 IN NUMBER
         ,in#batch_seq_code            IN NUMBER)
      IS
      SELECT pts_batch_data.batch_rec_num
         ,pts_batch_data.batch_rec
         ,pts_batch_cntl.batch_rows
         ,pts_batch_cntl.ROWID batch_cntl_ROWID
         ,pts_batch_data.ROWID batch_data_ROWID
      FROM pts_batch_cntl
         ,pts_batch_data
      WHERE pts_batch_cntl.batch_code = pts_batch_data.batch_code
      AND pts_batch_cntl.batch_seq_code = pts_batch_data.batch_seq_code
      AND pts_batch_cntl.batch_code = in#batch_code
      AND pts_batch_cntl.batch_seq_code = in#batch_seq_code;

      rec#pts_batch_data                   csr#pts_batch_data%ROWTYPE;
   BEGIN
      ov2#batch_status := 'PROCESSED';
      on#batch_err_rec_num := NULL;
      ov2#batch_err_msg := NULL;
      bl#first_rec_flg := TRUE;

      SAVEPOINT sto_batch;

      -- Process Batch
      OPEN csr#pts_batch_data(in#batch_code, in#batch_seq_code);
<<sto_batch_loop>>
      LOOP
         FETCH csr#pts_batch_data INTO rec#pts_batch_data;
         EXIT WHEN csr#pts_batch_data%NOTFOUND;

         -- Split STO Record
         IF (fun#split_sto_record(
            rec#pts_batch_data.batch_rec
            ,v2#rec_type
            ,v2#plt_code
            ,v2#material_code
            ,v2#sto_cnn_code
            ,v2#driver_id
            ,d#confirm_date
   ,n#confirm_time
            ,v2#trailer_id
            ,n#qty
            ,v2#dispn_code
            ,v2#loader_id
            ,v2#status
   ,v2#zpppi_batch) = gbl#FAIL) THEN

            ov2#batch_status := 'ERROR';
            on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
            ov2#batch_err_msg := gv2#err_msg;

            ROLLBACK TO SAVEPOINT sto_batch;
            EXIT sto_batch_loop;
         END IF;

         -- Insert STO on First Record, then Check for Match of
         -- Appropriate Fields.
         IF (bl#first_rec_flg = TRUE) THEN
            BEGIN
               INSERT INTO sto(
                  sto_cnn_code
                  ,batch_code
                  ,rec_type
                  ,loader_id
                  ,driver_id
                  ,trailer_id
                  ,status
      ,zpppi_batch)
               VALUES(
                  v2#sto_cnn_code
                  ,in#batch_code
                  ,v2#rec_type
                  ,v2#loader_id
                  ,v2#driver_id
                  ,v2#trailer_id
                  ,v2#status
      ,v2#zpppi_batch);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  ov2#batch_status := 'ERROR';
                  on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
                  ov2#batch_err_msg := 'CNN Already Exists';
                  ROLLBACK TO SAVEPOINT sto_batch;
                  EXIT sto_batch_loop;
               WHEN OTHERS THEN
                  ov2#batch_status := 'ERROR';
                  on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
                  ov2#batch_err_msg := '>>>'||SQLERRM(SQLCODE);
                  ROLLBACK TO SAVEPOINT sto_batch;
                  EXIT sto_batch_loop;
            END;

            bl#first_rec_flg := FALSE;

            v2#last_sto_cnn_code   := v2#sto_cnn_code;
            v2#last_rec_type   := v2#rec_type;
            v2#last_loader_id  := v2#loader_id;
            v2#last_driver_id  := v2#driver_id;
            v2#last_trailer_id := v2#trailer_id;
            v2#last_status     := v2#status;
         ELSE
            IF (v2#last_sto_cnn_code <> v2#sto_cnn_code) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := 'CNN Code Mismatch, OLD ['
                  ||v2#last_sto_cnn_code||'], NEW ['||v2#sto_cnn_code||']';
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
            END IF;
            IF (v2#last_rec_type <> v2#rec_type) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Record Type Mismatch, OLD ['
                  ||v2#last_rec_type||'], NEW ['||v2#rec_type||']';
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
            END IF;
            IF (v2#last_loader_id <> v2#loader_id) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Loader Id Mismatch, OLD ['
                  ||v2#last_loader_id||'], NEW ['||v2#loader_id||']';
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
            END IF;
            IF (v2#last_driver_id <> v2#driver_id) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Driver Id Mismatch, OLD ['
                  ||v2#last_driver_id||'], NEW ['||v2#driver_id||']';
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
            END IF;
            IF (v2#last_trailer_id <> v2#trailer_id) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Trailer Id Mismatch, OLD ['
                  ||v2#last_trailer_id||'], NEW ['||v2#trailer_id||']';
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
            END IF;
            IF (v2#last_status <> v2#status) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Status Mismatch, OLD ['
                  ||v2#last_status||'], NEW ['||v2#status||']';
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
            END IF;

            v2#last_sto_cnn_code   := v2#sto_cnn_code;
            v2#last_rec_type   := v2#rec_type;
            v2#last_loader_id  := v2#loader_id;
            v2#last_driver_id  := v2#driver_id;
            v2#last_trailer_id := v2#trailer_id;
            v2#last_status     := v2#status;
         END IF;

         -- Insert into STO Interface Table
         BEGIN
            INSERT INTO sto_intfc(
               batch_code
               ,rec_type
               ,plt_code
               ,material_code
               ,sto_cnn_code
               ,driver_id
               ,confirm_date
      ,confirm_time
               ,trailer_id
               ,qty
               ,dispn_code
               ,loader_id
               ,status
      ,zpppi_batch)
            VALUES(
               in#batch_code
               ,v2#rec_type
               ,v2#plt_code
               ,v2#material_code
               ,v2#sto_cnn_code
               ,v2#driver_id
               ,d#confirm_date
      ,n#confirm_time
               ,v2#trailer_id
               ,n#qty
               ,v2#dispn_code
               ,v2#loader_id
               ,v2#status
      ,v2#zpppi_batch);
         EXCEPTION
            WHEN OTHERS THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#pts_batch_data.batch_rec_num;
               ov2#batch_err_msg := SQLERRM(SQLCODE);
               ROLLBACK TO SAVEPOINT sto_batch;
               EXIT sto_batch_loop;
         END;

      END LOOP;
      CLOSE csr#pts_batch_data;

      RETURN gbl#SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         IF (csr#pts_batch_data%ISOPEN) THEN
            CLOSE csr#pts_batch_data;
         END IF;
         gv2#err_msg := SUBSTR('Process STO Batch FAILED'
            ||', Batch Code ['||TO_CHAR(in#batch_code)
            ||'], Batch Sequence Code ['||TO_CHAR(in#batch_seq_code)
            ||'], RETURN ['||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#process_sto_batch;

------------------------------------------------------[fun#split_sto_record]
   FUNCTION fun#split_sto_record(
      iv2#batch_rec                 IN VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,ov2#plt_code                 OUT VARCHAR2
      ,ov2#material_code             OUT VARCHAR2
      ,ov2#sto_cnn_code             OUT VARCHAR2
      ,ov2#driver_id                OUT VARCHAR2
      ,od#confirm_date              OUT DATE
   ,on#confirm_time    OUT NUMBER
      ,ov2#trailer_id               OUT VARCHAR2
      ,on#qty                       OUT NUMBER
      ,ov2#dispn_code               OUT VARCHAR2
      ,ov2#loader_id                OUT VARCHAR2
      ,ov2#status                   OUT VARCHAR2
      ,ov2#zpppi_batch      OUT VARCHAR2)
      RETURN                        BOOLEAN
   IS
      -- Working Variables
      v2#confirm_date               VARCHAR2(8);
      v2#confirm_time               VARCHAR2(8);
      v2#qty                        VARCHAR2(6);
      bl#return_value               BOOLEAN;
   BEGIN
      bl#return_value := gbl#SUCCESS;

      -- Split Record into VARCHAR2 Fields
      ov2#rec_type      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  1,   3)));
      ov2#plt_code      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  4,   20)));
      ov2#material_code := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 24,   8)));
      ov2#sto_cnn_code  := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 32,   12)));
      ov2#driver_id     := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 44,   2)));
      v2#confirm_date   := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 46,   8)));
      v2#confirm_time   := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 54,   8)));
      ov2#trailer_id    := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 62,  12)));
      v2#qty            := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 74,   6)));
      ov2#dispn_code    := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 80,   2)));
      ov2#loader_id     := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 82,   2)));
      ov2#status        := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 84,   1)));
      ov2#zpppi_batch   := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 85,   10)));

      -- Initilise Required Data Type Fields
      on#confirm_time := NULL;
      od#confirm_date   := NULL;
      on#qty            := NULL;

      -- Check Record Type
     IF (ov2#rec_type = 'REC') THEN

         -- Confirm Date
         BEGIN
            od#confirm_date := TO_DATE(v2#confirm_date||v2#confirm_time,'YYYYMMDDHH24:MI:SS');
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Confirm Date Field ['
                  ||v2#confirm_date||']['
                  ||v2#confirm_time||'] to a DATE, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

         -- Quantity
         BEGIN
            on#qty := TO_NUMBER(v2#qty);
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Quantity Field ['
                  ||v2#qty||'] to a NUMBER, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

         -- Confirm Time
         BEGIN
            on#confirm_time := TO_NUMBER(REPLACE(v2#confirm_time,':',''));
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Confirm Time Field ['
                  ||v2#confirm_time||'] to a NUMBER, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

      ELSE
         bl#return_value := gbl#FAIL;
         gv2#err_msg := SUBSTR('Invalid Record Type ['
            ||ov2#rec_type||'] : '
            ||gv2#err_msg, 1, gn#err_msg_len);
      END IF;

      RETURN bl#return_value;
   EXCEPTION
      WHEN OTHERS THEN
         gv2#err_msg := SUBSTR('Split STO Record FAILED'
            ||', Batch Record ['||iv2#batch_rec
            ||'], Record Type ['||ov2#rec_type
            ||'], Pallet Code ['||ov2#plt_code
            ||'], Material Code ['||ov2#material_code
            ||'], CNN Code ['||ov2#sto_cnn_code
            ||'], Driver Id ['||ov2#driver_id
            ||'], Confirm Date ['||v2#confirm_date
            ||'], Confirm Time ['||v2#confirm_time
            ||'], Trailer Id ['||ov2#trailer_id
            ||'], Quatity ['||v2#qty
            ||'], Disposition Code ['||ov2#dispn_code
            ||'], Loader Id ['||ov2#loader_id
            ||'], Status ['||ov2#status
     ||'], ZPPPI_BATCH ['||ov2#zpppi_batch
            ||'], RETURN ['||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#split_sto_record;
----------------------------------------------------------[pkg#pts.body.end]
END pkg#pts;
/


