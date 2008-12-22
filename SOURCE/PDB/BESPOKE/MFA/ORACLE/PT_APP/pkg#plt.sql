DROP PACKAGE PT_APP.PKG#PLT;

CREATE OR REPLACE PACKAGE PT_APP.Pkg#plt IS
----------------------------------------------------------------[PROCEDURES]
-------------------------------------------------------------[pro#backflush]
   PROCEDURE pro#backflush(
      in#backflush_code             IN NUMBER);
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
---------------------------------------------------------------[pro#receipt]
   PROCEDURE pro#receipt(
      in#receipt_code               IN NUMBER);
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
      ,on#stock_unit_code           OUT NUMBER
      ,ov2#plt_code                 OUT VARCHAR2
      ,on#delto_code                OUT NUMBER
      ,ov2#load_num                 OUT VARCHAR2
      ,ov2#order_num                OUT VARCHAR2
      ,od#desp_date                 OUT DATE
      ,on#qty                       OUT NUMBER
      ,od#use_by_date               OUT DATE)
      RETURN                        BOOLEAN;
-----------------------------------------------------[fun#process_sta_batch]
   FUNCTION fun#process_sta_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER
      ,ov2#batch_status             OUT VARCHAR2
      ,on#batch_err_rec_num         OUT NUMBER
      ,ov2#batch_err_msg            OUT VARCHAR2)
      RETURN                        BOOLEAN;
------------------------------------------------------[fun#split_sta_record]
   FUNCTION fun#split_sta_record(
      iv2#batch_rec                 IN VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,ov2#plt_code                 OUT VARCHAR2
      ,on#item_code                 OUT NUMBER
      ,ov2#sta_code                 OUT VARCHAR2
      ,ov2#driver_id                OUT VARCHAR2
      ,od#confirm_date              OUT DATE
      ,ov2#trailer_id               OUT VARCHAR2
      ,on#qty                       OUT NUMBER
      ,ov2#dispn_code               OUT VARCHAR2
      ,ov2#loader_id                OUT VARCHAR2
      ,ov2#status                   OUT VARCHAR2)
      RETURN                        BOOLEAN;
--------------------------------------------------------[pkg#plt.header.end]
END Pkg#plt;
/


DROP PACKAGE BODY PT_APP.PKG#PLT;

CREATE OR REPLACE PACKAGE BODY PT_APP."PKG#PLT" IS
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
-------------------------------------------------------------[pro#backflush]
   PROCEDURE pro#backflush( 
      in#backflush_code             IN NUMBER)
   IS
      CURSOR csr#backflush
      IS
      SELECT plt_trans.*
      FROM plt
         ,plt_trans
      WHERE plt.plt_trans_xactn_seq = plt_trans.xactn_seq
      AND plt_trans.rework_code IS NULL
      AND (
            (plt_trans.backflush_code IS NULL
            AND plt_trans.plt_cancel_intfc_xactn_seq IS NULL)
          OR
            (plt_trans.backflush_code IS NOT NULL
            AND plt_trans.rev_backflush_code IS NULL
            AND plt_trans.plt_cancel_intfc_xactn_seq IS NOT NULL)
          );

      rec#backflush                 csr#backflush%ROWTYPE;
   BEGIN
      LOCK TABLE plt_trans IN EXCLUSIVE MODE;

      -- Create Backflush Header
      INSERT INTO backflush(
         backflush_code)
      VALUES(
         in#backflush_code);
      COMMIT;

      -- Create Backflush Transactions
      OPEN csr#backflush;
         LOOP
         FETCH csr#backflush INTO rec#backflush;
         EXIT WHEN csr#backflush%NOTFOUND;

         IF (rec#backflush.backflush_code IS NULL) THEN
            INSERT INTO plt_trans(
               xactn_type
               ,plt_code
               ,backflush_code)
            VALUES(
               'BACKFLUSH'
               ,rec#backflush.plt_code
               ,in#backflush_code);
         ELSE
            INSERT INTO plt_trans(
               xactn_type
               ,plt_code
               ,rev_backflush_code)
            VALUES(
               '-BACKFLUSH'
               ,rec#backflush.plt_code
               ,in#backflush_code);
         END IF;

      END LOOP;
      CLOSE csr#backflush;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Backflush'
            ||', Backflush Code ['||TO_CHAR(in#backflush_code)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#backflush;
------------------------------------------------[pro#citec_delete_err_xactn]
   PROCEDURE pro#citec_delete_err_xactn(
      in#xactn_seq                  IN NUMBER)
   IS
      CURSOR csr#plt_intfc_err(
         in#xactn_seq                  IN NUMBER)
      IS
      SELECT *
      FROM plt_intfc_err
      WHERE xactn_seq = in#xactn_seq;

      rec#plt_intfc_err             csr#plt_intfc_err%ROWTYPE;
   BEGIN
      OPEN csr#plt_intfc_err(in#xactn_seq);
      FETCH csr#plt_intfc_err INTO rec#plt_intfc_err;
      IF (csr#plt_intfc_err%NOTFOUND) THEN
         gv2#err_msg := 'Transaction Code Not Found ['||TO_CHAR(in#xactn_seq)
            ||']';
         CLOSE csr#plt_intfc_err;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#plt_intfc_err;

      -- Remove Transaction from Error
      DELETE FROM plt_intfc_err
      WHERE xactn_seq = rec#plt_intfc_err.xactn_seq;

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
      CURSOR csr#plt_intfc_err(
         in#xactn_seq                  IN NUMBER)
      IS
      SELECT *
      FROM plt_intfc_err
      WHERE xactn_seq = in#xactn_seq;

      rec#plt_intfc_err             csr#plt_intfc_err%ROWTYPE;
   BEGIN
      OPEN csr#plt_intfc_err(in#xactn_seq);
      FETCH csr#plt_intfc_err INTO rec#plt_intfc_err;
      IF (csr#plt_intfc_err%NOTFOUND) THEN
         gv2#err_msg := 'Transaction Code Not Found ['||TO_CHAR(in#xactn_seq)
            ||']';
         CLOSE csr#plt_intfc_err;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#plt_intfc_err;

      -- Reprocess Transaction (via Triggers)
      INSERT INTO pt_app.plt_intfc(
         xactn_type
         , xactn_date
         , use_by_date
         , plt_code
         , item_code
         , uom
         , qty
         , full_plt_flag
         , whse_code
         , whse_locn_code
         , work_centre
         , user_id
         , rework_code)
      SELECT xactn_type
         , xactn_date
         , use_by_date
         , plt_code
         , item_code
         , uom
         , qty
         , full_plt_flag
         , whse_code
         , whse_locn_code
         , work_centre
         , user_id
         , rework_code
      FROM pt.plt_intfc_err
      WHERE xactn_seq = in#xactn_seq;

      -- Remove Transaction from Error
      DELETE FROM plt_intfc_err
      WHERE xactn_seq = rec#plt_intfc_err.xactn_seq;

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

      CURSOR csr#batch_cntl(
         in#batch_code                 IN NUMBER)
      IS
      SELECT *
      FROM batch_cntl
      WHERE batch_code = in#batch_code
      AND batch_seq_code IN (
         SELECT DISTINCT batch_seq_code
         FROM batch_err
         WHERE batch_code = in#batch_code);

      rec#batch_cntl                csr#batch_cntl%ROWTYPE;
   BEGIN
      OPEN csr#batch_cntl(in#batch_code);
      FETCH csr#batch_cntl INTO rec#batch_cntl;
      IF (csr#batch_cntl%NOTFOUND) THEN
         gv2#err_msg := 'Batch Code Not Found ['||TO_CHAR(in#batch_code)
            ||']';
         CLOSE csr#batch_cntl;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#batch_cntl;

      IF (rec#batch_cntl.batch_status <> 'ERROR') THEN
         gv2#err_msg := 'Invalid Batch Status ['||rec#batch_cntl.batch_status
            ||']';
         RAISE ex#process_exception;
      END IF;

      -- Update Batch Control
      UPDATE batch_cntl
      SET batch_status = 'DELETED'
         ,procg_strtd_date = SYSDATE
         ,procg_compld_date = SYSDATE
      WHERE batch_code = rec#batch_cntl.batch_code
      AND batch_seq_code = rec#batch_cntl.batch_seq_code;

      -- Remove Batch from Error
      DELETE FROM batch_err
      WHERE batch_code = rec#batch_cntl.batch_code
      AND batch_seq_code = rec#batch_cntl.batch_seq_code;

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

      CURSOR csr#batch_cntl(
         in#batch_code                 IN NUMBER
         ,in#batch_seq_code            IN NUMBER)
      IS
      SELECT *
      FROM batch_cntl
      WHERE batch_code = in#batch_code
      AND batch_seq_code = in#batch_seq_code;

      rec#batch_cntl          csr#batch_cntl%ROWTYPE;
   BEGIN
      -- Cleanup Batch Error Table
      --   Remove NON-ERRORS...
      DELETE FROM batch_err
      WHERE err_msg LIKE 'Processed by another Batch [%';
      COMMIT;

      -- Query Batch Control
      OPEN csr#batch_cntl(in#batch_code, in#batch_seq_code);
      FETCH csr#batch_cntl INTO rec#batch_cntl;
      IF (csr#batch_cntl%NOTFOUND) THEN
         gv2#err_msg := 'Batch Not Found';
         CLOSE csr#batch_cntl;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#batch_cntl;

      IF (rec#batch_cntl.batch_status NOT IN ('LOADED', 'RE-PROCESS')) THEN
         gv2#err_msg := 'Invalid Batch Status ['||rec#batch_cntl.batch_status
            ||']';
         RAISE ex#process_exception;
      END IF;

      -- Identify and Process Batch, by Batch Type
      IF (rec#batch_cntl.batch_type = 'STA') THEN
         -- Stock Transfer Authority Batch
         IF (fun#process_sta_batch(
            in#batch_code
            ,in#batch_seq_code
            ,v2#batch_status
            ,n#batch_err_rec_num
            ,v2#batch_err_msg) = gbl#FAIL) THEN
            RAISE ex#process_exception;
         END IF;
      ELSIF (rec#batch_cntl.batch_type = 'PSH') THEN
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
            ||rec#batch_cntl.batch_type||']';
      END IF;

      -- Update Batch Control
      UPDATE batch_cntl
      SET procg_strtd_date = d#procg_strtd_date
         ,procg_compld_date = SYSDATE
         ,batch_status = v2#batch_status
      WHERE batch_code = rec#batch_cntl.batch_code
      AND batch_seq_code = rec#batch_cntl.batch_seq_code;

      IF (rec#batch_cntl.batch_type <> 'PSH') THEN
         IF (v2#batch_status = 'ERROR') THEN
            INSERT INTO batch_err(
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
            FROM batch_data
            WHERE batch_code = in#batch_code
            AND batch_seq_code = in#batch_seq_code;
         END IF;

         DELETE FROM batch_data
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
---------------------------------------------------------------[pro#receipt]
   PROCEDURE pro#receipt(
      in#receipt_code               IN NUMBER)
   IS
      CURSOR csr#receipt
      IS
      SELECT plt_trans.*
      FROM plt
         ,plt_trans
      WHERE plt.plt_trans_xactn_seq = plt_trans.xactn_seq
      AND plt_trans.receipt_code IS NULL
      AND plt_trans.sta_code IS NOT NULL
      AND plt_trans.sta_status = 'C'
      AND plt_cancel_intfc_xactn_seq IS NULL;

      rec#receipt csr#receipt%ROWTYPE;
   BEGIN
      -- Create Receipt Header
      INSERT INTO receipt(
         receipt_code)
      VALUES(
         in#receipt_code);

      -- Create Receipt Transaction
      OPEN csr#receipt;
         LOOP
         FETCH csr#receipt INTO rec#receipt;
         EXIT WHEN csr#receipt%NOTFOUND;

         INSERT INTO plt_trans(
            xactn_type
            ,plt_code
            ,sta_code
            ,receipt_code
            ,receipt_by
            ,receipt_date)
         VALUES(
            'RECEIPT'
            ,rec#receipt.plt_code
            ,rec#receipt.sta_code
            ,in#receipt_code
            ,USER
            ,SYSDATE);

      END LOOP;
      CLOSE csr#receipt;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         gv2#err_msg := SUBSTR('FATAL ERROR Receipt'
            ||', Receipt Code ['||TO_CHAR(in#receipt_code)
            ||'], RETURN ['||SQLERRM(SQLCODE)
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RAISE_APPLICATION_ERROR(-20000, gv2#err_msg);
   END pro#receipt;
-----------------------------------------------------------[pro#disposition]
   PROCEDURE pro#disposition(in#disposition_code IN NUMBER)
   IS
      CURSOR csr#disposition
      IS
      SELECT plt_trans.*
      FROM plt ,plt_trans
      WHERE plt.plt_trans_xactn_seq = plt_trans.xactn_seq
      AND plt_trans.sta_code IS NOT NULL
      AND plt_trans.sta_status = 'C'
      AND plt_cancel_intfc_xactn_seq IS NULL
      AND plt_trans.disposition_code IS NULL;
	  
      rec#disposition csr#disposition%ROWTYPE;
   BEGIN
      -- Create Disposition Header
      INSERT INTO disposition(disposition_code)
      VALUES(in#disposition_code);
	  COMMIT;

      -- Create Disposition Transaction
      OPEN csr#disposition;
         LOOP
         FETCH csr#disposition INTO rec#disposition;
         EXIT WHEN csr#disposition%NOTFOUND;

         INSERT INTO plt_trans(
	     xactn_type
            ,plt_code
            ,sta_code
            ,disposition_code
            ,disposition_by
            ,disposition_date)
         VALUES(
            'DSPOSITION'
            ,rec#disposition.plt_code
            ,rec#disposition.sta_code
            ,in#disposition_code
            ,USER
            ,SYSDATE);
         COMMIT;

      END LOOP;
      CLOSE csr#disposition;
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

      CURSOR csr#batch_cntl(
         in#batch_code                 IN NUMBER)
      IS
      SELECT *
      FROM batch_cntl
      WHERE batch_code = in#batch_code
      AND batch_seq_code IN (
         SELECT DISTINCT batch_seq_code
         FROM batch_err
         WHERE batch_code = in#batch_code);

      rec#batch_cntl                csr#batch_cntl%ROWTYPE;
   BEGIN
      OPEN csr#batch_cntl(in#batch_code);
      FETCH csr#batch_cntl INTO rec#batch_cntl;
      IF (csr#batch_cntl%NOTFOUND) THEN
         gv2#err_msg := 'Batch Code Not Found ['||TO_CHAR(in#batch_code)
            ||']';
         CLOSE csr#batch_cntl;
         RAISE ex#process_exception;
      END IF;
      CLOSE csr#batch_cntl;

      IF (rec#batch_cntl.batch_status <> 'ERROR') THEN
         gv2#err_msg := 'Invalid Batch Status ['||rec#batch_cntl.batch_status
            ||']';
         RAISE ex#process_exception;
      END IF;

      -- Create New Batch Control (New Sequence)
      INSERT INTO batch_cntl(
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
      FROM batch_cntl
      WHERE batch_code = rec#batch_cntl.batch_code
      AND batch_seq_code = rec#batch_cntl.batch_seq_code;

      -- Move Batch from Error to Data
      INSERT INTO batch_data(
         batch_code
         ,batch_seq_code
         ,batch_rec_num
         ,batch_rec)
      SELECT batch_code
         ,(batch_seq_code+1)
         ,batch_rec_num
         ,batch_rec
      FROM batch_err
      WHERE batch_code = rec#batch_cntl.batch_code
      AND batch_seq_code = rec#batch_cntl.batch_seq_code;

      -- Remove Batch from Error
      DELETE FROM batch_err
      WHERE batch_code = rec#batch_cntl.batch_code
      AND batch_seq_code = rec#batch_cntl.batch_seq_code;

      -- Reprocess Batch
      pro#process_batch(rec#batch_cntl.batch_code
         ,rec#batch_cntl.batch_seq_code+1);

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

   CURSOR csr#batch_cntl IS
   SELECT *
   FROM   batch_cntl
   WHERE  (batch_code, batch_seq_code) IN 
    (SELECT batch_code, batch_seq_code FROM batch_err);
   rec#batch_cntl csr#batch_cntl%ROWTYPE;
	  
   BEGIN
      FOR rec#batch_cntl in csr#batch_cntl LOOP

         -- Create New Batch Control (New Sequence)
         INSERT INTO batch_cntl(
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
		     rec#batch_cntl.batch_code
            ,rec#batch_cntl.batch_seq_code + 1
            ,rec#batch_cntl.batch_type
            ,rec#batch_cntl.batch_file_name
            ,NULL
            ,NULL
            ,rec#batch_cntl.batch_rows
            ,'RE-PROCESS'
            ,rec#batch_cntl.replct_batch_code);

         -- Move Batch from Error to Data
         INSERT INTO batch_data(
             batch_code
            ,batch_seq_code
            ,batch_rec_num
            ,batch_rec)
         SELECT batch_code
            ,(batch_seq_code+1)
            ,batch_rec_num
            ,batch_rec
         FROM batch_err
         WHERE batch_code = rec#batch_cntl.batch_code
         AND batch_seq_code = rec#batch_cntl.batch_seq_code;

         -- Remove Batch from Error
         DELETE FROM batch_err
         WHERE batch_code = rec#batch_cntl.batch_code
         AND batch_seq_code = rec#batch_cntl.batch_seq_code;

         -- Reprocess Batch
         pro#process_batch(rec#batch_cntl.batch_code, rec#batch_cntl.batch_seq_code + 1);

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
      n#stock_unit_code             NUMBER(6);
      v2#plt_code                   VARCHAR2(8);
      n#delto_code                  NUMBER(7);
      v2#load_num                   VARCHAR2(9);
      v2#order_num                  VARCHAR2(9);
      d#desp_date                   DATE;
      n#qty                         NUMBER(6);
      d#use_by_date                 DATE;
      -- Working
      bl#err_flg                    BOOLEAN;
      n#commit_counter              NUMBER;

      -- Batch Cursor
      CURSOR csr#batch_data(
         in#batch_code                 IN NUMBER
         ,in#batch_seq_code            IN NUMBER)
      IS
      SELECT batch_data.batch_rec_num
         ,batch_data.batch_rec
         ,batch_cntl.batch_rows
         ,batch_cntl.ROWID batch_cntl_ROWID
         ,batch_data.ROWID batch_data_ROWID
      FROM batch_cntl
         ,batch_data
      WHERE batch_cntl.batch_code = batch_data.batch_code
      AND batch_cntl.batch_seq_code = batch_data.batch_seq_code
      AND batch_cntl.batch_code = in#batch_code
      AND batch_cntl.batch_seq_code = in#batch_seq_code
      FOR UPDATE;

      rec#batch_data                   csr#batch_data%ROWTYPE;

      -- Ship To Cursor
      CURSOR csr#plt_shipto(
         iv2#plt_code                  IN VARCHAR2
         ,iv2#order_num                IN VARCHAR2)
      IS
      SELECT batch_code
        ,plt_shipto.ROWID plt_shipto_ROWID
      FROM plt_shipto
      WHERE plt_shipto.plt_code = iv2#plt_code
      AND plt_shipto.order_num = iv2#order_num
      FOR UPDATE;

      rec#plt_shipto                   csr#plt_shipto%ROWTYPE;
   BEGIN
      ov2#batch_status := 'PROCESSED';
      on#batch_err_rec_num := NULL;
      ov2#batch_err_msg := NULL;

      -- Process Batch
      OPEN csr#batch_data(in#batch_code, in#batch_seq_code);
      LOOP
         bl#err_flg := FALSE;

         FETCH csr#batch_data INTO rec#batch_data;
         EXIT WHEN csr#batch_data%NOTFOUND;

         -- Split PSH Record
         IF (fun#split_psh_record(
            rec#batch_data.batch_rec
            ,v2#rec_type
            ,n#stock_unit_code
            ,v2#plt_code
            ,n#delto_code
            ,v2#load_num
            ,v2#order_num
            ,d#desp_date
            ,n#qty
            ,d#use_by_date) = gbl#FAIL) THEN

            bl#err_flg := TRUE;
            on#batch_err_rec_num := rec#batch_data.batch_rec_num;
            ov2#batch_err_msg := gv2#err_msg;
         ELSE
            -- Insert or Update as Required
            BEGIN
               ov2#batch_err_msg := 'CURSOR csr#plt_shipto(['
                  ||v2#plt_code||'], ['||v2#order_num||']);';

               rec#plt_shipto := NULL;
               OPEN csr#plt_shipto(v2#plt_code, v2#order_num);
               FETCH csr#plt_shipto INTO rec#plt_shipto;
               CLOSE csr#plt_shipto;

               IF (rec#plt_shipto.batch_code IS NULL) THEN
                  ov2#batch_err_msg := 'INSERT into Pallet Ship To Table Failed';
                  INSERT INTO plt_shipto(
                     batch_code
                     ,rec_type
                     ,stock_unit_code
                     ,plt_code
                     ,delto_code
                     ,load_num
                     ,order_num
                     ,desp_date
                     ,qty
                     ,use_by_date
                     ,line_cnt)
                  VALUES(
                     in#batch_code
                     ,v2#rec_type
                     ,n#stock_unit_code
                     ,v2#plt_code
                     ,n#delto_code
                     ,v2#load_num
                     ,v2#order_num
                     ,d#desp_date
                     ,n#qty
                     ,d#use_by_date
                     ,1);
               ELSE
                  IF (rec#plt_shipto.batch_code = in#batch_code) THEN
                     ov2#batch_err_msg := 'UPDATE of Pallet Ship To Table Failed';
                     UPDATE plt_shipto
                     SET qty              = qty+n#qty
                        ,line_cnt         = line_cnt+1
                     WHERE plt_shipto.ROWID = rec#plt_shipto.plt_shipto_ROWID;
                  ELSE
                     bl#err_flg := TRUE;
                     ov2#batch_err_msg := 'Processed by another Batch ['
                        ||rec#plt_shipto.batch_code||']';
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  bl#err_flg := TRUE;
                  on#batch_err_rec_num := rec#batch_data.batch_rec_num;
                  ov2#batch_err_msg := ov2#batch_err_msg
                     ||', Batch Code ['||TO_CHAR(in#batch_code)
                     ||'], Record Type ['||v2#rec_type
                     ||'], Stock Unit Code ['||TO_CHAR(n#stock_unit_code)
                     ||'], Pallet Code ['||v2#plt_code
                     ||'], Deliver To Code ['||TO_CHAR(n#delto_code)
                     ||'], Load Number ['||v2#load_num
                     ||'], Order Number ['||v2#order_num
                     ||'], Despatch Date ['||TO_CHAR(d#desp_date, 'YYYYMONDD')
                     ||'], Quantity ['||TO_CHAR(n#qty)
                     ||'], Use By Date ['||TO_CHAR(d#use_by_date, 'YYYYMONDD')
                     ||'], RETURN ['||SQLERRM(SQLCODE)||']';
            END;


         END IF;

         IF (bl#err_flg = TRUE) THEN
            ov2#batch_status := 'ERROR';
            INSERT INTO batch_err(
               batch_code
               ,batch_seq_code
               ,batch_rec_num
               ,batch_rec
               ,err_msg
               ,procg_code)
            VALUES (
               in#batch_code
               ,in#batch_seq_code
               ,rec#batch_data.batch_rec_num
               ,rec#batch_data.batch_rec
               ,ov2#batch_err_msg
               ,'ERROR');
         END IF;

         DELETE FROM batch_data WHERE ROWID = rec#batch_data.batch_data_ROWID;

         -- Commit at this point destroys the transactions autonomy,
         -- however transaction autonomy is not important for this process,
         -- and commit allows generic process to be used without alteration
         -- or extending rollback segment
         n#commit_counter := n#commit_counter + 1;
         IF (MOD(n#commit_counter, 1000) = 0) THEN
            COMMIT;
         END IF;

      END LOOP;
      CLOSE csr#batch_data;

      RETURN gbl#SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         IF (csr#batch_data%ISOPEN) THEN
            CLOSE csr#batch_data;
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
      iv2#batch_rec                 IN VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,on#stock_unit_code           OUT NUMBER
      ,ov2#plt_code                 OUT VARCHAR2
      ,on#delto_code                OUT NUMBER
      ,ov2#load_num                 OUT VARCHAR2
      ,ov2#order_num                OUT VARCHAR2
      ,od#desp_date                 OUT DATE
      ,on#qty                       OUT NUMBER
      ,od#use_by_date               OUT DATE)
      RETURN                        BOOLEAN
   IS
      -- Working Variables
      v2#stock_unit_code            VARCHAR2(6);
      v2#delto_code                 VARCHAR2(10);
      v2#desp_date                  VARCHAR2(8);
      v2#qty                        VARCHAR2(6);
      v2#use_by_date                VARCHAR2(8);
      bl#return_value               BOOLEAN;
   BEGIN
      bl#return_value := gbl#SUCCESS;

      -- Split Record into VARCHAR2 Fields
      ov2#rec_type         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  1,   3)));
      v2#stock_unit_code   := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  4,   6)));
      ov2#plt_code         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 10,   8)));
      v2#delto_code        := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 18,  10)));
      ov2#load_num         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 28,   9)));
      ov2#order_num        := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 37,   9)));
      v2#desp_date         := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 46,   8)));
      v2#qty               := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 54,   6)));
      v2#use_by_date       := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 60,   8)));

      -- Initilise Required Data Type Fields
      on#stock_unit_code   := NULL;
      on#delto_code        := NULL;
      od#desp_date         := NULL;
      on#qty               := NULL;

      -- Check Record Type
      IF (ov2#rec_type = 'PSH') THEN

         -- Stock Unit Code
         BEGIN
            on#stock_unit_code := TO_NUMBER(v2#stock_unit_code);
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Stock Unit Code Field ['
                  ||v2#stock_unit_code||'] to a NUMBER, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

         -- Deliver To Code
         BEGIN
            on#delto_code := TO_NUMBER(v2#delto_code);
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Deliver To Field ['
                  ||v2#delto_code||'] to a NUMBER, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

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
            ||', Batch Record ['||iv2#batch_rec
            ||'], Record Type ['||ov2#rec_type
            ||'], Stock Unit Code ['||v2#stock_unit_code
            ||'], Pallet Code ['||ov2#plt_code
            ||'], Deliver To Code ['||v2#delto_code
            ||'], Load Number ['||ov2#load_num
            ||'], Order Number ['||ov2#order_num
            ||'], Despatch Date ['||v2#desp_date
            ||'], Quantity ['||v2#qty
            ||'], Use By Date ['||v2#use_by_date
            ||'], RETURN ['||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#split_psh_record;
-----------------------------------------------------[fun#process_sta_batch]
   FUNCTION fun#process_sta_batch(
      in#batch_code                 IN NUMBER
      ,in#batch_seq_code            IN NUMBER
      ,ov2#batch_status             OUT VARCHAR2
      ,on#batch_err_rec_num         OUT NUMBER
      ,ov2#batch_err_msg            OUT VARCHAR2)
      RETURN                        BOOLEAN
   IS
      -- Current STA Record Type
      v2#rec_type                   VARCHAR2(3);
      v2#plt_code                   VARCHAR2(8);
      n#item_code                   NUMBER(6);
      v2#sta_code                   VARCHAR2(8);
      v2#driver_id                  VARCHAR2(2);
      d#xactn_date                  DATE;
      v2#trailer_id                 VARCHAR2(12);
      n#qty                         NUMBER(6);
      v2#dispn_code                 VARCHAR2(2);
      v2#loader_id                  VARCHAR2(2);
      v2#status                     VARCHAR2(1);
      -- Previous STA Record Type
      v2#last_rec_type              VARCHAR2(3);
      v2#last_sta_code              VARCHAR2(8);
      v2#last_driver_id             VARCHAR2(2);
      v2#last_trailer_id            VARCHAR2(12);
      v2#last_loader_id             VARCHAR2(2);
      v2#last_status                VARCHAR2(1);
      -- Working
      bl#first_rec_flg              BOOLEAN;

      -- Batch Cursor
      CURSOR csr#batch_data(
         in#batch_code                 IN NUMBER
         ,in#batch_seq_code            IN NUMBER)
      IS
      SELECT batch_data.batch_rec_num
         ,batch_data.batch_rec
         ,batch_cntl.batch_rows
         ,batch_cntl.ROWID batch_cntl_ROWID
         ,batch_data.ROWID batch_data_ROWID
      FROM batch_cntl
         ,batch_data
      WHERE batch_cntl.batch_code = batch_data.batch_code
      AND batch_cntl.batch_seq_code = batch_data.batch_seq_code
      AND batch_cntl.batch_code = in#batch_code
      AND batch_cntl.batch_seq_code = in#batch_seq_code;

      rec#batch_data                   csr#batch_data%ROWTYPE;
   BEGIN
      ov2#batch_status := 'PROCESSED';
      on#batch_err_rec_num := NULL;
      ov2#batch_err_msg := NULL;
      bl#first_rec_flg := TRUE;

      SAVEPOINT sta_batch;

      -- Process Batch
      OPEN csr#batch_data(in#batch_code, in#batch_seq_code);
<<sta_batch_loop>>
      LOOP
         FETCH csr#batch_data INTO rec#batch_data;
         EXIT WHEN csr#batch_data%NOTFOUND;

         -- Split STA Record
         IF (fun#split_sta_record(
            rec#batch_data.batch_rec
            ,v2#rec_type
            ,v2#plt_code
            ,n#item_code
            ,v2#sta_code
            ,v2#driver_id
            ,d#xactn_date
            ,v2#trailer_id
            ,n#qty
            ,v2#dispn_code
            ,v2#loader_id
            ,v2#status) = gbl#FAIL) THEN

            ov2#batch_status := 'ERROR';
            on#batch_err_rec_num := rec#batch_data.batch_rec_num;
            ov2#batch_err_msg := gv2#err_msg;

            ROLLBACK TO SAVEPOINT sta_batch;
            EXIT sta_batch_loop;
         END IF;

         -- Insert STA on First Record, then Check for Match of
         -- Appropriate Fields.
         IF (bl#first_rec_flg = TRUE) THEN
            BEGIN
               INSERT INTO sta(
                  sta_code
                  ,batch_code
                  ,rec_type
                  ,loader_id
                  ,driver_id
                  ,trailer_id
                  ,status)
               VALUES(
                  v2#sta_code
                  ,in#batch_code
                  ,v2#rec_type
                  ,v2#loader_id
                  ,v2#driver_id
                  ,v2#trailer_id
                  ,v2#status);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  ov2#batch_status := 'ERROR';
                  on#batch_err_rec_num := rec#batch_data.batch_rec_num;
                  ov2#batch_err_msg := 'STA Already Exists';
                  ROLLBACK TO SAVEPOINT sta_batch;
                  EXIT sta_batch_loop;
               WHEN OTHERS THEN
                  ov2#batch_status := 'ERROR';
                  on#batch_err_rec_num := rec#batch_data.batch_rec_num;
                  ov2#batch_err_msg := '>>>'||SQLERRM(SQLCODE);
                  ROLLBACK TO SAVEPOINT sta_batch;
                  EXIT sta_batch_loop;
            END;

            bl#first_rec_flg := FALSE;

            v2#last_sta_code   := v2#sta_code;
            v2#last_rec_type   := v2#rec_type;
            v2#last_loader_id  := v2#loader_id;
            v2#last_driver_id  := v2#driver_id;
            v2#last_trailer_id := v2#trailer_id;
            v2#last_status     := v2#status;
         ELSE
            IF (v2#last_sta_code <> v2#sta_code) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := 'STA Code Mismatch, OLD ['
                  ||v2#last_sta_code||'], NEW ['||v2#sta_code||']';
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
            END IF;
            IF (v2#last_rec_type <> v2#rec_type) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Record Type Mismatch, OLD ['
                  ||v2#last_rec_type||'], NEW ['||v2#rec_type||']';
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
            END IF;
            IF (v2#last_loader_id <> v2#loader_id) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Loader Id Mismatch, OLD ['
                  ||v2#last_loader_id||'], NEW ['||v2#loader_id||']';
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
            END IF;
            IF (v2#last_driver_id <> v2#driver_id) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Driver Id Mismatch, OLD ['
                  ||v2#last_driver_id||'], NEW ['||v2#driver_id||']';
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
            END IF;
            IF (v2#last_trailer_id <> v2#trailer_id) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Trailer Id Mismatch, OLD ['
                  ||v2#last_trailer_id||'], NEW ['||v2#trailer_id||']';
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
            END IF;
            IF (v2#last_status <> v2#status) THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := 'Status Mismatch, OLD ['
                  ||v2#last_status||'], NEW ['||v2#status||']';
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
            END IF;

            v2#last_sta_code   := v2#sta_code;
            v2#last_rec_type   := v2#rec_type;
            v2#last_loader_id  := v2#loader_id;
            v2#last_driver_id  := v2#driver_id;
            v2#last_trailer_id := v2#trailer_id;
            v2#last_status     := v2#status;
         END IF;

         -- Insert into STA Interface Table
         BEGIN
            INSERT INTO sta_intfc(
               batch_code
               ,rec_type
               ,plt_code
               ,item_code
               ,sta_code
               ,driver_id
               ,xactn_date
               ,trailer_id
               ,qty
               ,dispn_code
               ,loader_id
               ,status)
            VALUES(
               in#batch_code
               ,v2#rec_type
               ,v2#plt_code
               ,n#item_code
               ,v2#sta_code
               ,v2#driver_id
               ,d#xactn_date
               ,v2#trailer_id
               ,n#qty
               ,v2#dispn_code
               ,v2#loader_id
               ,v2#status);
         EXCEPTION
            WHEN OTHERS THEN
               ov2#batch_status := 'ERROR';
               on#batch_err_rec_num := rec#batch_data.batch_rec_num;
               ov2#batch_err_msg := SQLERRM(SQLCODE);
               ROLLBACK TO SAVEPOINT sta_batch;
               EXIT sta_batch_loop;
         END;

      END LOOP;
      CLOSE csr#batch_data;

      RETURN gbl#SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         IF (csr#batch_data%ISOPEN) THEN
            CLOSE csr#batch_data;
         END IF;
         gv2#err_msg := SUBSTR('Process STA Batch FAILED'
            ||', Batch Code ['||TO_CHAR(in#batch_code)
            ||'], Batch Sequence Code ['||TO_CHAR(in#batch_seq_code)
            ||'], RETURN ['||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#process_sta_batch;
------------------------------------------------------[fun#split_sta_record]
   FUNCTION fun#split_sta_record(
      iv2#batch_rec                 IN VARCHAR2
      ,ov2#rec_type                 OUT VARCHAR2
      ,ov2#plt_code                 OUT VARCHAR2
      ,on#item_code                 OUT NUMBER
      ,ov2#sta_code                 OUT VARCHAR2
      ,ov2#driver_id                OUT VARCHAR2
      ,od#confirm_date              OUT DATE
      ,ov2#trailer_id               OUT VARCHAR2
      ,on#qty                       OUT NUMBER
      ,ov2#dispn_code               OUT VARCHAR2
      ,ov2#loader_id                OUT VARCHAR2
      ,ov2#status                   OUT VARCHAR2)
      RETURN                        BOOLEAN
   IS
      -- Working Variables
      v2#item_code                  VARCHAR2(6);
      v2#confirm_date               VARCHAR2(8);
      v2#confirm_time               VARCHAR2(8);
      v2#qty                        VARCHAR2(6);
      bl#return_value               BOOLEAN;
   BEGIN
      bl#return_value := gbl#SUCCESS;

      -- Split Record into VARCHAR2 Fields
      ov2#rec_type      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  1,   3)));
      ov2#plt_code      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec,  4,   8)));
      v2#item_code      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 12,   6)));
      ov2#sta_code      := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 18,   7)));
      ov2#driver_id     := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 25,   2)));
      v2#confirm_date   := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 27,   8)));
      v2#confirm_time   := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 35,   8)));
      ov2#trailer_id    := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 43,  12)));
      v2#qty            := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 55,   6)));
      ov2#dispn_code    := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 61,   2)));
      ov2#loader_id     := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 63,   2)));
      ov2#status        := LTRIM(RTRIM(SUBSTR(iv2#batch_rec, 65,   1)));

      -- Initilise Required Data Type Fields
      on#item_code      := NULL;
      od#confirm_date   := NULL;
      on#qty            := NULL;

      -- Check Record Type
      IF (ov2#rec_type = 'REC') THEN

         -- Item Code
         BEGIN
            on#item_code := TO_NUMBER(v2#item_code);
         EXCEPTION
            WHEN OTHERS THEN
               bl#return_value := gbl#FAIL;
               gv2#err_msg := SUBSTR('Converting Item Code Field ['
                  ||v2#item_code||'] to a NUMBER, FAILED : '
                  ||gv2#err_msg, 1, gn#err_msg_len);
         END;

         -- Confirm Date
         BEGIN
            od#confirm_date := TO_DATE(v2#confirm_date||v2#confirm_time
               ,'YYYYMMDDHH24:MI:SS');
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

      ELSE
         bl#return_value := gbl#FAIL;
         gv2#err_msg := SUBSTR('Invalid Record Type ['
            ||ov2#rec_type||'] : '
            ||gv2#err_msg, 1, gn#err_msg_len);
      END IF;

      RETURN bl#return_value;
   EXCEPTION
      WHEN OTHERS THEN
         gv2#err_msg := SUBSTR('Split STA Record FAILED'
            ||', Batch Record ['||iv2#batch_rec
            ||'], Record Type ['||ov2#rec_type
            ||'], Pallet Code ['||ov2#plt_code
            ||'], Item Code ['||v2#item_code
            ||'], STA Code ['||ov2#sta_code
            ||'], Driver Id ['||ov2#driver_id
            ||'], Confirm Date ['||v2#confirm_date
            ||'], Confirm Time ['||v2#confirm_time
            ||'], Trailer Id ['||ov2#trailer_id
            ||'], Quatity ['||v2#qty
            ||'], Disposition Code ['||ov2#dispn_code
            ||'], Loader Id ['||ov2#loader_id
            ||'], Status ['||ov2#status
            ||'], RETURN ['||LTRIM(RTRIM(SQLERRM(SQLCODE)))
            ||'] : '||gv2#err_msg, 1, gn#err_msg_len);
         RETURN gbl#FAIL;
   END fun#split_sta_record;
----------------------------------------------------------[pkg#plt.body.end]
END pkg#plt;
/


DROP PUBLIC SYNONYM PKG#PLT;

CREATE PUBLIC SYNONYM PKG#PLT FOR PT_APP.PKG#PLT;


