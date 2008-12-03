DROP PACKAGE PT_APP.TAGSYS_FCTRY_INTFC;

CREATE OR REPLACE PACKAGE PT_APP.Tagsys_Fctry_Intfc AS
 
 PROCEDURE Create_Pllt(
	   o_result                 IN OUT NUMBER,
	   o_result_msg             IN OUT VARCHAR2,
	
       i_XACTN_DATE			    IN DATE,
	   i_XACTN_TIME			    IN NUMBER,
	   i_PLANT_CODE			    IN VARCHAR2,
	   i_SENDER_NAME			IN VARCHAR2,
	   i_ZPPPI_BATCH			IN VARCHAR2,
	   i_PROC_ORDER			    IN NUMBER,
	   i_STOR_LOC_CODE		    IN NUMBER,
	   i_DISPN_CODE			    IN VARCHAR2,
	   i_USE_BY_DATE			IN DATE,
	   i_MATERIAL_CODE		    IN VARCHAR2,
	   i_UOM					IN VARCHAR2,
	   i_PLT_CODE				IN VARCHAR2,
	   i_QTY					IN NUMBER,
	   i_FULL_PLT_FLAG		    IN VARCHAR2,
	   i_USER_ID				IN VARCHAR2,
	   i_LAST_GR_FLAG			IN VARCHAR2
   );
   
  PROCEDURE Cancel_Pllt(
	   o_result                 IN OUT NUMBER,
	   o_result_msg             IN OUT VARCHAR2,
	
	   i_XACTN_DATE			    IN DATE,
	   i_XACTN_TIME			    IN NUMBER,
	   i_SENDER_NAME			IN VARCHAR2,
	   i_PLT_CODE				IN VARCHAR2,
	   i_USER_ID				IN VARCHAR2
   );  
   
   
   PROCEDURE Disposition(
       o_result                 IN OUT NUMBER,
	   o_result_msg             IN OUT VARCHAR2,
       i_plt_code               IN VARCHAR2,
       i_Sloc                   IN VARCHAR2,
       i_Sign                   IN VARCHAR2,
       i_Iss_Stock_Status       IN VARCHAR2,
       i_Rec_Stock_Status       IN VARCHAR2,
       i_dspstn_type            IN VARCHAR2
       );   
 
       /* Disposition procedure is called to change the disposition within Atlas.
       it is called 1 pallet at a time and an Idoc is only sent to Atlas if:
       .. the pallet has not had an STO raised
       .. or the Atlas disposition changes. ie Shift Log has 16 dispositions - Atlas has 3
       */
 
 
 END;
/


DROP PACKAGE BODY PT_APP.TAGSYS_FCTRY_INTFC;

CREATE OR REPLACE PACKAGE BODY PT_APP.Tagsys_Fctry_Intfc AS
 
   /**********************************************************************************/
   /* Create a Pallet Record and set up the Idoc structure to send to Atlas
   /**********************************************************************************/
   
   b_test_flag    BOOLEAN := FALSE;
   

PROCEDURE Create_Pllt(
    o_result                 IN OUT NUMBER,
    o_result_msg             IN OUT VARCHAR2,
 
    i_XACTN_DATE       IN DATE,
    i_XACTN_TIME       IN NUMBER,
    i_PLANT_CODE       IN VARCHAR2,
    i_SENDER_NAME   IN VARCHAR2,
    i_ZPPPI_BATCH   IN VARCHAR2,
    i_PROC_ORDER       IN NUMBER,
    i_STOR_LOC_CODE      IN NUMBER,
    i_DISPN_CODE       IN VARCHAR2,
    i_USE_BY_DATE   IN DATE,
    i_MATERIAL_CODE      IN VARCHAR2,
    i_UOM     IN VARCHAR2,
    i_PLT_CODE    IN VARCHAR2,
    i_QTY     IN NUMBER,
    i_FULL_PLT_FLAG      IN VARCHAR2,
    i_USER_ID    IN VARCHAR2,
    i_LAST_GR_FLAG   IN VARCHAR2
       )
       AS
    
    b_last_gr_flag   BOOLEAN := FALSE;
    v_count                  NUMBER := 0;
       v_transaction_type       VARCHAR2(10);
    e_process_exception      EXCEPTION;
    e_IDOC_EXCEPTION   EXCEPTION;
       v_result                 NUMBER;
       v_result_msg             VARCHAR2(2000);
       v_batch                  VARCHAR2(10);
       
       TRANS_TYPE               VARCHAR2(10) DEFAULT 'CREATE';
BEGIN

   o_result := Plt_Common.SUCCESS;
   o_result_msg := 'Pallet ' || i_plt_code || ' created';
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE
   /**********************************************************************************/

   /*
   IF (i_ZPPPI_BATCH IS NULL AND i_USE_BY_DATE IS NOT NULL) THEN
      o_result_msg := 'Transaction Failed: Batch Code required where Best Before Date is provided.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;   
   END IF;
   */
   -- Check if Pallet Code exists 
   SELECT COUNT(*) INTO v_count
   FROM PLT_HDR
   WHERE plt_code = i_plt_code;
   IF v_count > 0 THEN
      o_result_msg := 'Transaction Failed: Pallet code already exists. Please select a unique value.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception; 
   END IF;
   
   -- check validity of dates
   IF i_XACTN_DATE IS NULL THEN
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check plant code
   IF i_plant_code IS NULL THEN
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       SELECT COUNT(*) INTO v_count FROM manu.REF_PLANT
       WHERE plant_code = i_plant_code;
       IF v_count = 0 THEN
           o_result_msg := 'Plant Code is not correct.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
   END IF;
   
   -- check for valid proc order
   IF i_proc_order IS NULL THEN
      o_result_msg := 'Proc Order is not valid.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       IF SUBSTR(i_proc_order,1,2) <> '99' THEN
          SELECT COUNT(*) INTO v_count FROM manu.CNTL_REC
          WHERE proc_order = i_proc_order;
          IF v_count = 0 THEN
              o_result_msg := 'Proc Order is not valid.';
              o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
          END IF;
       END IF;
   END IF;
   
   -- check material code
   IF i_material_code IS NULL THEN
      o_result_msg := 'Material Code cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       SELECT COUNT(*) INTO v_count FROM material_vw
       WHERE material_code = i_material_code;
       /*IF v_count = 0 THEN
           o_result_msg := 'Material Code is not correct.';
           o_result := 1;
           RAISE e_process_exception;
       END IF;
       */
   END IF;
   
   -- check validity of qty
   IF i_Qty = 0 THEN
      o_result_msg := 'Quantity cannot be Null.';
      o_result :=Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check uom
   IF i_uom IS NULL THEN
      o_result_msg := 'UOM cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check disposition code 
   /***********************************************************************************
    DISPOSITION STATUS 
   ********************
   Blocked            = 'S'
   Un Restricted      = ' '
   Quality Inspect    = 'X'
   ************************************************************************************/
   
   IF i_DISPN_CODE IS NULL THEN
      o_result_msg := 'Disposition cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   ELSE
       IF i_DISPN_CODE <> ' ' AND i_DISPN_CODE <> 'S' AND i_DISPN_CODE <> 'X' THEN
           o_result_msg := 'Disposition is not a valid value - Blank, ''S'' or ''X''.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
   END IF;
   

   
      /**********************************************************************************/
      /* Save data in Pallet tables
      /**********************************************************************************/

      BEGIN
      
           /*
           IF LENGTH(i_MATERIAL_CODE) < 8 THEN
               -- semi finished product
               v_batch := ' ';
           ELSE
               -- FG
               v_batch := i_ZPPPI_BATCH;
           END IF;
           */
           IF i_ZPPPI_BATCH IS NULL THEN
               v_batch := ' ';
           ELSE
               -- FG
               v_batch := SUBSTR(i_ZPPPI_BATCH,1,30);
           END IF;
           
           /**********************************************************************************/
           /* Insert record into header table
           /**********************************************************************************/
       INSERT INTO PT.PLT_HDR (
      PLT_CODE,
                  MATL_CODE,
                  QTY,
                  STATUS,
      PLANT_CODE,
         ZPPPI_BATCH,
      PROC_ORDER,
      STOR_LOCN_CODE,
         DISPN_CODE,
      USE_BY_DATE,
         FULL_PLT_FLAG,
                  LAST_GR_FLAG,
      PLT_CREATE_DATIME,
                  UOM)
           VALUES(
          i_Plt_Code,
                  i_MATERIAL_CODE,
                  i_QTY,
                  TRANS_TYPE,
       i_PLANT_CODE,
       v_batch,
                  i_PROC_ORDER,
                  i_STOR_LOC_CODE,
         i_DISPN_CODE, 
       i_USE_BY_DATE,
                  i_FULL_PLT_FLAG,
                  i_LAST_GR_FLAG,
         SYSDATE,
       UPPER(i_UOM)   
      );
                    
          /**********************************************************************************/                 
          /* Insert detail record 
          /**********************************************************************************/
          INSERT INTO  PLT_DET (
                  PLT_CODE,
                  XACTN_TYPE,
                  USER_ID,
                  REASON,
                  XACTN_DATE,
                  XACTN_TIME,
                  SENDER_NAME
                  )
              VALUES (
                  i_PLT_CODE,
                  TRANS_TYPE,
                  UPPER(i_USER_ID),
                  TRANS_TYPE,
                  TO_CHAR(i_Xactn_Date,'dd-mon-yyyy'),
                  i_Xactn_Time,
                  UPPER(i_Sender_Name)
                  );         
              -- DBMS_OUTPUT.PUT_LINE(TRANS_TYPE); 
        EXCEPTION
          WHEN OTHERS THEN
            o_result_msg := 'INSERT (CREATE) INTO pt.plt_hdr and plt_det FAILED, RETURN ['
               ||SQLERRM(SQLCODE)||']';
            o_result := Plt_Common.FAILURE;
        END;

        
        
        /**********************************************************************************/
        /* Create Idoc package for Create
        /**********************************************************************************/

       
        
  BEGIN
    IF SUBSTR(i_proc_order,1,2) <> '99' THEN
     
    v_transaction_type := 'Z_PI1';
    --v2#transaction_type := 'Z_PI2';
    
    IF (i_LAST_GR_FLAG = 'Y') THEN
       b_last_gr_flag := TRUE;
    END IF;

                IF NOT Idoc_Hold THEN
                 
        -- Make call to create iDOC
        Create_Idoc(v_result,
                            v_result_msg,
                            v_transaction_type,
          i_PLANT_CODE,
          i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), --i_SENDER_NAME,
          b_TEST_FLAG,
          i_PROC_ORDER,
          i_XACTN_DATE,
          i_XACTN_TIME,
          i_MATERIAL_CODE,
          i_QTY,
          UPPER(i_UOM),
          i_STOR_LOC_CODE,
          i_DISPN_CODE,
          v_batch,
          b_LAST_GR_FLAG,
       TO_CHAR(i_USE_BY_DATE,'YYYYMMDD'));
                ELSE
                    v_result := 0;           
                END IF; 
                          
                IF v_result <> 0 THEN
                    -- error has occured 
                    -- insert record in log file
                    o_result_msg := v_result_msg;
                    o_result := v_result;
                    INSERT INTO PLT_IDOC_LOG
                        VALUES (i_PLT_CODE, TRANS_TYPE, 0, 'FAIL',o_result_msg, SYSDATE, 0);
                    o_result_msg := '';
                    o_result := Plt_Common.SUCCESS;
                    RAISE e_IDOC_EXCEPTION;
                END IF;
                COMMIT;
                 
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
      o_result_msg := 'Call to CREATE_IDOC Failed ['|| SQLCODE || ' ' || SUBSTR(SQLERRM,1,256) ||']';
            o_result := Plt_Common.FAILURE;
            ROLLBACK;
   RAISE   e_process_exception;
  END;
        
        
        
        
        /**********************************************************************************/
        /* Update Sent Flag if all OK
        /**********************************************************************************/
      
  BEGIN
    IF SUBSTR(i_proc_order,1,2) = '99' THEN
     UPDATE PT.PLT_DET
    SET SENT_FLAG = 'X'
    WHERE PLT_CODE = UPPER(i_PLT_CODE);
    ELSE
                 IF NOT Idoc_Hold THEN
          UPDATE PT.PLT_DET
         SET SENT_FLAG = 'Y'
         WHERE PLT_CODE = UPPER(i_PLT_CODE);
                 END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := '<TAGSYS_FCTRY_INTFC.Create_Pllt> Error updating sent flag on pts_intfc: ['||SQLERRM||']';
            o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
  END;


        
        

        COMMIT;

   EXCEPTION
     WHEN e_process_exception THEN
          o_result := Plt_Common.FAILURE;
        -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
  WHEN e_IDOC_EXCEPTION THEN
          COMMIT;
          o_result := Plt_Common.SUCCESS;
  -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
    WHEN OTHERS THEN
         o_result := Plt_Common.FAILURE;
         ROLLBACK;
         o_result_msg := 'ERROR OCCURED'||SQLCODE || '-' || SUBSTR(SQLERRM,1,256);
       --  RAISE_APPLICATION_ERROR(-20000, o_result_msg);
END;




/**********************************************************************************/
/* Cancel Pallet record -
/* - the pallet record has to exist and it should be CREATE status
/**********************************************************************************/
      
      
PROCEDURE Cancel_Pllt(
    o_result                 IN OUT NUMBER,
    o_result_msg             IN OUT VARCHAR2,
 
    i_XACTN_DATE       IN DATE,
    i_XACTN_TIME       IN NUMBER,
    i_SENDER_NAME   IN VARCHAR2,
    i_PLT_CODE    IN VARCHAR2,
    i_USER_ID    IN VARCHAR2
       )
       AS
       
    
   
    b_last_gr_flag   BOOLEAN := FALSE;
       v_count                  NUMBER;
    v_transaction_type       VARCHAR2(10);
       v_result                 NUMBER;
       v_result_msg             VARCHAR2(2000);
       v_proc_order             VARCHAR2(12);
    e_process_exception      EXCEPTION;
    e_IDOC_EXCEPTION   EXCEPTION;
       
       TRANS_TYPE               VARCHAR2(10) DEFAULT 'CANCEL';
       
       CURSOR c_get_plt IS
       SELECT h.*, sent_flag
       FROM PLT_HDR h, PLT_DET d
       WHERE h.plt_code = i_plt_code
       AND h.PLT_CODE = d.PLT_CODE
       AND d.xactn_type = 'CREATE';
       
       r_plt  c_get_plt%ROWTYPE;
       
       
BEGIN

   o_result := Plt_Common.SUCCESS;
   o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';
   
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE
   /**********************************************************************************/

   
   SELECT COUNT(*) INTO v_count
   FROM PLT_HDR
   WHERE plt_code = i_plt_code
   AND STATUS = 'CREATE';
   IF v_count <> 1 THEN
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
  
   SELECT COUNT(*) INTO v_count
   FROM PLT_HDR
   WHERE plt_code = i_plt_code
   AND STATUS = 'CANCEL';
   IF v_count > 0 THEN
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check validity of dates
   IF i_XACTN_DATE IS NULL THEN
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   -- check SEnder name
   IF i_Sender_name IS NULL THEN
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := Plt_Common.FAILURE;
      RAISE e_process_exception;
   END IF;
   
   
   
   
   -- get rest of pallet data 
   OPEN c_get_plt;
   FETCH c_get_plt INTO r_plt;
   LOOP
       EXIT WHEN c_get_plt%NOTFOUND;
   
       -- check Sif Sent Flag is set - if not warn shiftlog to get it fixed before Cancelling Pallet
       /*
       IF r_plt.Sent_flag IS NULL THEN
           o_result_msg := 'Warning the Pallet ingformation has not been sent to Atlas.' || CHR(13) 
                            || ' Please consult your Support team.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
       */
   
   
   
       /**********************************************************************************/
       /* Save data in Pallet tables
       /**********************************************************************************/

       BEGIN
       UPDATE PT.PLT_HDR 
               SET STATUS = TRANS_TYPE
               WHERE plt_code = r_plt.Plt_Code;
       
   
         /**********************************************************************************/                 
         /* Insert detail record 
         /**********************************************************************************/
         INSERT INTO  PLT_DET (
                  PLT_CODE,
                  XACTN_TYPE,
                  USER_ID,
                  REASON,
                  XACTN_DATE,
                  XACTN_TIME,
                  SENDER_NAME
                  )
              VALUES (
                  i_PLT_CODE,
                  TRANS_TYPE,
                  UPPER(i_USER_ID),
                  TRANS_TYPE,
                  TO_CHAR(i_Xactn_Date,'dd-mon-yyyy'),
                  i_Xactn_Time,
                  UPPER(i_Sender_Name)
                  ); 
                  
                      
            
      EXCEPTION
         WHEN OTHERS THEN
            o_result := Plt_Common.FAILURE;
            o_result_msg := 'UPDATE (CANCEL) INTO pt.plt_hdr and plt_det FAILED, RETURN ['
               ||SUBSTR(SQLERRM,1,255) ||']';
      END;

      /**********************************************************************************/
      /* Create Idoc package for Cancel
      /**********************************************************************************/

      IF NOT Idoc_Hold THEN
  BEGIN
        
             SELECT proc_order INTO v_proc_order
             FROM PLT_HDR
             WHERE plt_code = i_plt_code;
             
    IF SUBSTR(v_proc_order,1,2) <> '99'  THEN
     
    --v2#transaction_type := 'Z_PI1';
    v_transaction_type := 'Z_PI2';
    IF r_plt.LAST_GR_FLAG = 'Y' THEN
                    b_last_gr_flag := TRUE;
                ELSE
                    b_last_gr_flag := FALSE;
                END IF;

                
                
        -- Make call to create iDOC
        Create_Idoc(v_result,
                         v_result_msg,
                            v_transaction_type,
          trim(r_plt.PLANT_CODE),
          i_SENDER_NAME || ':' || SUBSTR(i_PLT_CODE,1,18), --i_SENDER_NAME,
          b_TEST_FLAG,
          TO_NUMBER(r_plt.PROC_ORDER),
          i_XACTN_DATE,
          i_XACTN_TIME,
          r_plt.MATL_CODE,
          r_plt.QTY,
          r_plt.UOM,
          TO_NUMBER(r_plt.STOR_LOCN_CODE),
          r_plt.DISPN_CODE,
          r_plt.ZPPPI_BATCH,
          b_last_gr_flag,
       TO_CHAR(r_plt.USE_BY_DATE,'YYYYMMDD'));
                
                 
                IF v_result <> 0 THEN
                    -- error has occured 
                    -- insert record in log file
                    o_result_msg := v_result_msg;
                    o_result := v_result;
                    INSERT INTO PLT_IDOC_LOG
                        VALUES (i_PLT_CODE, TRANS_TYPE, 0, 'FAIL',o_result_msg, SYSDATE, o_result);
                    o_result_msg := '';
                    o_result := Plt_Common.SUCCESS;
                    RAISE e_IDOC_EXCEPTION;
                END IF;
                 
    END IF;
 
  EXCEPTION
      WHEN OTHERS THEN
          o_result_msg := 'Call to CREATE_IDOC Failed ['||SQLERRM||']';
                o_result := Plt_Common.FAILURE;
       RAISE e_process_exception;
  END;
      END IF;
        
  BEGIN
      IF SUBSTR(v_proc_order,1,2) = '99' THEN
       UPDATE PT.PLT_DET
    SET SENT_FLAG = 'X'
    WHERE PLT_CODE = UPPER(i_PLT_CODE);
   ELSE
                IF NOT Idoc_Hold THEN
           UPDATE PT.PLT_DET
        SET SENT_FLAG = 'Y'
        WHERE PLT_CODE = UPPER(i_PLT_CODE);
                END IF;
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
         o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_Pllt> Error updating sent flag on pts_intfc: ['||SQLERRM||']';
               o_result := Plt_Common.FAILURE;
         RAISE e_process_exception;
  END;
        
        EXIT;
        
   END LOOP;
   CLOSE c_get_plt;
       
   
   COMMIT;

EXCEPTION
     WHEN e_process_exception THEN
         o_result := Plt_Common.FAILURE;
         -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
  WHEN e_IDOC_EXCEPTION THEN
         COMMIT;
         o_result := Plt_Common.SUCCESS;
   -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
     WHEN OTHERS THEN
         o_result := Plt_Common.FAILURE;
         ROLLBACK;
         o_result_msg := 'ERROR OCCURED'||SQLERRM(SQLCODE);
         -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
END;


/**********************************************************************************/
/* Disposition Pallet record -
/* - the pallet record has to exist and in a CREATE status before
/* - a disposition can be raised
/**********************************************************************************/

PROCEDURE Disposition(
       o_result            IN OUT NUMBER,
    o_result_msg        IN OUT VARCHAR2,
       i_plt_code          IN VARCHAR2,
       i_Sloc              IN VARCHAR2,
       i_Sign              IN VARCHAR2,
       i_Iss_Stock_Status  IN VARCHAR2,
       i_Rec_Stock_Status  IN VARCHAR2,
       i_dspstn_type       IN VARCHAR2
       ) AS
       
       
       /* Disposition procedure is called to change the disposition within Atlas.
       it is called 1 pallet at a time and an Idoc is only sent to Atlas if:
       .. the pallet has not had an STO raised
       .. or the Atlas disposition changes. ie Shift Log has 16 dispositions - Atlas has 3
       */
       
       
       e_process_exception      EXCEPTION;
       e_escape_exception       EXCEPTION;
    e_IDOC_EXCEPTION   EXCEPTION;
       
       v_count                  NUMBER;
       v_intfc_rtn          NUMBER(15,0);
    v_interface_type         VARCHAR2(10) := 'CISATL05.1'; 
       v_batch                  VARCHAR2(20);
    v_TEST_FLAG          VARCHAR2(1)  := '';
       --v_status                 VARCHAR2(1);  -- used for issuing disposition
       --v_status_rec             VARCHAR2(1);  -- used for receiving disposition
       v_seq                    NUMBER;
       v_last_dspstn            VARCHAR2(10);
       v_sign                   VARCHAR2(1);
       v_rec_stock_status       VARCHAR2(1);
       v_whse                   NUMBER;
       v_dsp                    VARCHAR2(1);
       v_qty                    NUMBER;
       
       CURSOR c_disp IS
       SELECT  matl_code, qty, zpppi_batch batch,
           proc_order, stor_locn_code sloc1, uom
           FROM PLT_HDR h, PLT_DET d
           WHERE h.PLT_CODE = d.PLT_CODE
           AND reason = 'CREATE'
           AND h.plt_code = i_plt_code;
           
       rcd c_disp%ROWTYPE;
       
       CURSOR c_last IS
       SELECT iss_stock_status 
             FROM PLT_DSPSTN
             WHERE plt_code = i_plt_code
             ORDER BY create_datime DESC;
       
     BEGIN
     
         o_result := Plt_Common.SUCCESS;
         o_result_msg := 'Disposition changed for pallet ' || i_plt_code;
         
         -- ensure a Pallet exists 
         SELECT COUNT(*) INTO v_count
         FROM PLT_HDR
         WHERE PLT_CODE = i_plt_code
         AND STATUS = 'CREATE';
         IF v_count = 0 THEN
             o_result_msg := 'Pallet does not exist or may have been cancelled.';
             o_result := Plt_Common.FAILURE;
             RAISE e_process_exception;
         END IF;
         
         
         -- disposition can only be sent if an STO has not been raised ? 
         SELECT COUNT(*) INTO v_count
         FROM STO_DET d, STO_HDR h
         WHERE d.cnn = h.cnn
         AND d.PLT_CODE = i_plt_code;
         IF v_count > 0 THEN
             o_result_msg := 'STO has been sent for this Pallet - no Dispositions can be made.';
             o_result := Plt_Common.FAILURE;
             RAISE e_process_exception;
         END IF;
         
         
         
         
         /***********************************************************************
         -- check fields are valid for the type of transfer 
         ***********************************************************************/
         IF i_dspstn_type = 'STCH' THEN
             -- check for a iss stock status 
             IF i_rec_stock_status IS NULL THEN
                 o_result_msg := 'Issue Stock Status Code cannot be Null for STCH record.';
                 RAISE e_process_exception;
             END IF;
         END IF;
         --IF i_dspstn_type = 'SADJ' THEN
             --check if a qty has been supplied
            -- IF i_qty IS NULL OR i_qty = 0 THEN
            --    o_result_msg := 'Stock Adjustment needs a valid Quantity';
            --    o_result := Plt_Common.FAILURE;
            --    RAISE e_process_exception;
            -- END IF;
         --END IF;

         IF i_dspstn_type <> 'STCH' AND i_dspstn_type <> 'SADJ'  THEN
             o_result_msg := 'Not a valid transaction type - STCH, SAADJ only';
             o_result := Plt_Common.FAILURE;
             RAISE e_process_exception;
         END IF;
          
         -- check for a iss stock status 
         IF i_iss_stock_status IS NULL THEN
             o_result_msg := 'Issue Stock Status Code cannot be Null.';
             RAISE e_process_exception;
         END IF;
        

         
         
         
         
         -- values can only be X - Quality Inspect
         --                    S - Blocked
         --                    space - Unrestricted
         -- change the shift log status to an atlas status 
         IF i_iss_stock_status NOT IN (' ','R','S','X')  THEN
             o_result_msg := 'Incorrect Issuing disposition status.';
             o_result := Plt_Common.FAILURE;
             RAISE e_process_exception;
         END IF;
         
         -- values can only be X - Quality Inspect
         --                    S - Blocked
         --                    space - Unrestricted
         -- change the shift log status to an atlas rec status 
         IF i_rec_stock_status NOT IN (' ','R','S','X')  THEN
             o_result_msg := 'Incorrect Receive disposition status.';
             o_result := Plt_Common.FAILURE;
             RAISE e_process_exception;
         END IF;
         
         
                  
         /**********************************************************************
         End of field checking 
         **********************************************************************/
         
            
                 
         -- get pallet infomation
         BEGIN
             SELECT MAX(zpppi_batch) batch INTO v_batch
             FROM PLT_HDR
             WHERE plt_code = i_plt_code;
                     
         EXCEPTION
             WHEN TOO_MANY_ROWS THEN
                         o_result_msg := 'ERROR OCCURED in Disposition procedure - more than one pallet' || CHR(13) ||SUBSTR(SQLERRM,1,256);
                         o_result := Plt_Common.FAILURE;
                         RAISE e_process_exception;
             WHEN NO_DATA_FOUND THEN
                         o_result_msg := 'ERROR OCCURED in Disposition procedure - no pallet' || CHR(13) ||SUBSTR(SQLERRM,1,256);
                         o_result := Plt_Common.FAILURE;
                         RAISE e_process_exception;
             WHEN OTHERS THEN
                         o_result_msg := 'ERROR OCCURED in Disposition procedure - get pallet' || CHR(13) ||SUBSTR(SQLERRM,1,256);
                         o_result := Plt_Common.FAILURE;
                         RAISE e_process_exception;
         END;
         
         /* DISPOSITION tests
          only save data if the disposition is different from tha last Atlas disposition         
          get last atlas disposition 
          if it is the same as this one do not send       */
         SELECT DISPN_CODE, qty INTO v_dsp, v_qty
         FROM plt_hdr
         WHERE plt_code = i_plt_code;
         IF v_dsp <> i_iss_stock_status THEN
            o_result_msg := 'The current Pallet disposition is different to the Iss_Stock_Status.';
            
            RAISE e_process_exception;
         END IF;
         IF i_iss_stock_status = i_rec_stock_status THEN
            o_result_msg := 'Issue and Receive Dispositions are the same. They have to be different.' ;
            
            RAISE e_process_exception;
         END IF;
         
         -- insert a record in dspstn table
         SELECT PLT_DSPSTN_CODE_SEQ.NEXTVAL INTO v_seq FROM dual;
         -- get a seq code for WHSE_CODE filed 
         SELECT PLT_DSPSTN_WHSE_SEQ.NEXTVAL INTO v_whse FROM dual;
         
             
         BEGIN
         
         /*****************************************
         update pallet record with by adding new qty
         *****************************************/
      --   IF i_sign  IS NULL THEN
            -- add qty 
      --      v_qty := v_qty + i_qty;
      --   ELSE
             -- subttract qty
      --       v_qty := v_qty - i_qty;
      --   END IF;
      --   UPDATE plt_hdr
      --   SET qty = v_qty
      --   WHERE plt_code = i_plt_code;
         /*****************************************/
         
         INSERT INTO PLT_DSPSTN
             VALUES (v_seq,
                 RTRIM(LTRIM(i_plt_code)),
                 TRUNC(SYSDATE),
                 TO_CHAR(SYSDATE,'hh24miss'),
                 '',
                 '', --i_qty,
                 TO_CHAR(v_whse),
                 Plt_Common.SOURCE_PLANT, -- source plant
                 i_sloc, -- source sloc
                 '', -- dest plant 
                 '', -- dest sloc
                 i_sign, -- qty sign
                 RTRIM(LTRIM(i_iss_stock_status)),
                 RTRIM(LTRIM(i_rec_stock_status)),
                 v_batch,
                 '',
                 '',
                 '',
                 '',
                 '',
                 SYSDATE,
                 i_dspstn_type);
                 
             UPDATE PLT_HDR SET dispn_code = i_rec_stock_status
             WHERE plt_code = i_plt_code;
                
             COMMIT;
                  
         EXCEPTION
   WHEN OTHERS THEN
                o_result := Plt_Common.FAILURE;
                dbms_output.put ('Plt Code =' || i_plt_code || '-');
                o_result_msg := 'ERROR OCCURED in Disposition procedure Inserting record' || CHR(13) ||SUBSTR(SQLERRM,1,256);
                RAISE e_process_exception;
         END;
          
          
         IF NOT Idoc_Hold THEN
         
         --CREATE DATA LINES FOR MESSAGE
         OPEN c_disp;
             LOOP
                 FETCH c_disp INTO rcd;
                 EXIT WHEN c_disp%NOTFOUND;
                 
                     BEGIN
                 
                     --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
                     v_intfc_rtn := outbound_loader.create_interface(v_interface_type);

                 

                     -- HEADER: Header Record
                     -- Including 'X' at the end of the header record will cause Atlas
                     -- to treat the message as a test, meaning no further processing
                     -- will be completed once it reaches Atlas.
                     outbound_loader.append_data('HDR'
                         ||TO_CHAR(SYSDATE,'yyyymmdd')
                         ||TO_CHAR(SYSDATE,'hh24miss')
                         ||RPAD(' ',16,' ')
                         ||RPAD(' ',25,' ')
                         ||LPAD(v_whse,16,'0')
          --||TRIM(v_TEST_FLAG)
                         );
             
                 
                     -- DBMS_OUTPUT.PUT_LINE(TO_CHAR(rcd.qty,'000000000.000'));
                     --DET: PROCESS ORDER
                     IF i_sign IS NULL THEN
                         v_sign := ' ';
                     ELSE
                         v_sign := i_sign;
                     END IF;  
                     IF i_rec_stock_status IS NULL THEN
                         v_rec_stock_status := ' ';
                     ELSE
                         V_rec_stock_status := i_rec_stock_status;
                     END IF;
                     IF i_dspstn_type <> 'STCH' THEN  
                         v_rec_stock_status := ' ';
                     END IF;                   
                                         
                     outbound_loader.append_data('DET'
                                           ||RPAD(Plt_Common.SOURCE_PLANT,4)
                                           ||LPAD(rcd.sloc1,4,'0')
                                           ||RPAD(' ', 4,' ')
                                           ||RPAD(' ', 4,' ')
                                           ||RPAD(rcd.matl_code,8,' ')
                                           ||RPAD(i_dspstn_type,4,' ')
                                           ||v_sign
                                           ||LTRIM(TO_CHAR(0,'000000000.000'))
                                           ||RPAD(TRIM(rcd.uom),3,' ')
                                           ||RPAD(i_iss_stock_status,1,' ')
                                           ||RPAD(i_rec_stock_status,1,' ')
                                           ||RPAD(rcd.Batch,10,' ')
                                           ||RPAD(' ',8,' ')
                                           ||RPAD(' ',1,' ')
                                           ||RPAD(' ',8,' ')
                                           ||RPAD(' ',8,' '));
                                           
                                           
                     --Close PASSTHROUGH INTERFACE
                     outbound_loader.finalise_interface();                         
                     dbms_output.put ('Sent Idoc');
                 
                     EXCEPTION
                         WHEN OTHERS THEN
                          IF (outbound_loader.is_created()) THEN
                              outbound_loader.finalise_interface();
                          END IF;
                      
                             -- error has occured 
                             -- insert record in log file
                             o_result_msg := 'ERROR OCCURED'|| '-' || SUBSTR(SQLERRM,1,256);
                             o_result := SQLCODE;
                             INSERT INTO DSPSTN_IDOC_LOG
                                 VALUES (i_PLT_CODE, 0,o_result_msg, SYSDATE, 0);
                             -- raise error 
                             o_result_msg := '';
                             o_result := Plt_Common.SUCCESS;
                             RAISE e_IDOC_EXCEPTION;
                     END;
                 
                 
                     UPDATE PT.PLT_DSPSTN SET SENT_FLAG = 'Y'
            WHERE PLT_CODE = UPPER(i_PLT_CODE);
             
             
                 EXIT;
             END LOOP;
         CLOSE c_disp;     
   
         END IF;
                                        
         COMMIT;
          
     EXCEPTION
         WHEN e_escape_exception THEN
              -- this is an error within the operation and so its not really an error 
              o_result := Plt_Common.SUCCESS;
              
         WHEN e_process_exception THEN
             o_result := Plt_Common.FAILURE;
             
      WHEN e_IDOC_EXCEPTION THEN
             o_result := Plt_Common.SUCCESS;
      
         WHEN OTHERS THEN
             o_result := Plt_Common.FAILURE;
             ROLLBACK;
             o_result_msg := 'ERROR OCCURED in Disposition Procedure ' || CHR(13) ||SUBSTR(SQLERRM,1,256);
            
       
     END;
 
 
 
     
     
 
   

END Tagsys_Fctry_Intfc;
/


GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO SHIFTLOG;

GRANT EXECUTE ON PT_APP.TAGSYS_FCTRY_INTFC TO SHIFTLOG_APP;

