DROP PACKAGE PT_APP.TAGSYS_WHSE_INTFC;

CREATE OR REPLACE PACKAGE PT_APP.Tagsys_Whse_Intfc AS
/******************************************************************************
   NAME:       TAGSYS_WHSE_INTFC
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005      Jeff Phillipson  1. Created this package.
******************************************************************************/

  PROCEDURE STO_Start(
       o_result            IN OUT NUMBER,
	   o_result_msg        IN OUT VARCHAR2,
       i_cnn               IN VARCHAR2,
       i_dest_plant        IN VARCHAR2,   	
       i_deliv_date        IN DATE,
       i_Deliv_Time        IN NUMBER,
       i_Msg_Status        IN VARCHAR2
       );
       
 /************************************************************
 Start pallet will create a header record to instigate the saving of pallet records
 ************************************************************/
 
 
 
  PROCEDURE STO_PLT(
       o_result            IN OUT NUMBER,
	   o_result_msg        IN OUT VARCHAR2,
       i_cnn               IN VARCHAR2,
       i_plt_code          IN VARCHAR2,
	   --i_line_num		   IN NUMBER, -- not required - this has to be done in this procedure
       --i_matl_code         IN VARCHAR2,
       i_qty               IN NUMBER,
       --i_uom               IN VARCHAR2,
	   i_stock_status	   IN VARCHAR2,
       --i_batch             IN VARCHAR2,
       i_Msg_Status        IN VARCHAR2
       );

 /************************************************************
  pallet will save detail records on a pallet basis 
 ************************************************************/
 
 
 
  PROCEDURE STO_Trigger(
       o_result            IN OUT NUMBER,
	   o_result_msg        IN OUT VARCHAR2,
       i_cnn               IN VARCHAR2
       );
 
  /************************************************************
 Trigger pallet will retrieve the pallet data agregate 
 quantities of the same material and batch
 ************************************************************/     
       
END Tagsys_Whse_Intfc;
/


DROP PACKAGE BODY PT_APP.TAGSYS_WHSE_INTFC;

CREATE OR REPLACE PACKAGE BODY PT_APP.Tagsys_Whse_Intfc AS
/******************************************************************************
   NAME:       TAGSYS_WHSE_INTFC
   PURPOSE:    This package forms the interface between Atlas and Shift Log in NZ
               or other system that may want to initiate STO's or Dispositions to Atlas
               
               STO_Confirm will provide error checking for data integrity
                           Save the STO data in local tables and initiate the appropriate IDOC
                           package for sending to Atlas
               
               InputS:     The data required to send to Atlas
               Output:     o_result - Success or Failure
                           o_result_mesg - any Error message if the above is set to > 0 
                           
               Disposition will save the data received from Shift Log and
                           initiate the appropriate interface to send the data to Atlas.
                           
               InputS:     The data required to send to Atlas
               Output:     o_result - Success or Failure
                           o_result_mesg - any Error message if the above is set to > 0 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005      Jeff Phillipson  1. Created this package body.
******************************************************************************/

    b_test_flag    BOOLEAN := FALSE;
    v_count                 NUMBER;

    PROCEDURE STO_Start(
        o_result            IN OUT NUMBER,
     o_result_msg        IN OUT VARCHAR2,
        i_cnn               IN VARCHAR2,
        i_dest_plant        IN VARCHAR2,    
        i_deliv_date        IN DATE,
        i_Deliv_Time        IN NUMBER,
        i_Msg_Status        IN VARCHAR2
        )
        AS
       
        e_process_exception  EXCEPTION;
     IDOC_EXCEPTION  EXCEPTION;
       
        
        v_seq                NUMBER;
       
     BEGIN
     
         o_result := Plt_Common.SUCCESS;
         o_result_msg := 'Start record for cnn ' || i_cnn;
         
         SELECT COUNT(*) INTO v_count
         FROM STO_HDR
         WHERE mesg_status = 'S';
         IF v_count > 0 THEN
             -- remove the previous entry
             DELETE FROM STO_DET
             WHERE cnn = (SELECT cnn FROM STO_HDR WHERE mesg_status = 'S');
             DELETE FROM STO_HDR
             WHERE  mesg_status = 'S';
         END IF;
         
         
         
       
         -- check validity of dates
         IF i_deliv_date IS NULL THEN
             o_result_msg := 'Delivery Date cannot be Null.';
             o_result := Plt_Common.FAILURE;
            RAISE e_process_exception;
         END IF;
   
         -- check a destination plant code
         IF i_dest_plant IS NULL THEN
             o_result_msg := 'Destination Plant Code cannot be Null.';
             o_result := Plt_Common.FAILURE;
             RAISE e_process_exception;
         END IF;
       
       
         -- check if the current cnn value exists
         -- need to send multiple 
         SELECT COUNT(*) INTO v_count
         FROM STO_HDR
         WHERE cnn = i_cnn;
         IF v_count > 0 THEN
            UPDATE sto_hdr
            SET deliv_date =  TO_CHAR(i_deliv_date,'dd-mon-yyyy'),
            deliv_time = i_deliv_time,
            dest_plant = i_dest_plant,
            sent_flag = '',
            create_datime = SYSDATE,
            Mesg_Status = i_Msg_Status
            WHERE cnn = i_cnn;
            
            
         ELSE
         
             -- if not insert record 
             -- insert a record in STO tables 
             --SELECT STO_HDR_CODE_SEQ.NEXTVAL INTO v_seq FROM dual;
       
             INSERT INTO STO_HDR 
                 VALUES (
                     i_cnn,
                     Plt_Common.CMPNY_CODE,
                     Plt_Common.PURCH_ORG,
                     Plt_Common.VENDOR,
                     Plt_Common.SOURCE_PLANT,
                     Plt_Common.CURRENCY,
                     Plt_Common.PURCH_GRP,
                     '',
                     SYSDATE,
                     '',
                     i_dest_plant,    
                     TO_CHAR(i_deliv_date,'dd-mon-yyyy'),
                     i_deliv_time,
                     i_Msg_Status,
                     Plt_Common.STOR_LOCN);
                       
         END IF;
      
     EXCEPTION
         WHEN e_process_exception THEN
             o_result := Plt_Common.FAILURE;
             
      WHEN IDOC_EXCEPTION THEN
             o_result := Plt_Common.FAILURE;
       
         WHEN OTHERS THEN
             o_result := Plt_Common.FAILURE;
             ROLLBACK;
             o_result_msg := 'ERROR OCCURED in STO_START procedure' || CHR(13) ||SUBSTR(SQLERRM,1,256);
     END;
       
    
    
    
    
    
    
    PROCEDURE STO_PLT(
       o_result            IN OUT NUMBER,
    o_result_msg        IN OUT VARCHAR2,
       i_cnn               IN VARCHAR2,
       i_plt_code          IN VARCHAR2,
    --i_line_num     IN NUMBER,
       --i_matl_code         IN VARCHAR2,
       i_qty               IN NUMBER,
       --i_uom               IN VARCHAR2,
    i_stock_status    IN VARCHAR2,
       --i_batch             IN VARCHAR2,
       i_Msg_Status        IN VARCHAR2
       )
       AS

  
       
       e_process_exception  EXCEPTION;
    IDOC_EXCEPTION  EXCEPTION;
       
       v_matl               VARCHAR2(8);
       v_qty                NUMBER;
       v_uom                VARCHAR2(3);
       v_dispn              VARCHAR2(10);
       v_batch              VARCHAR2(10);
       
         
  BEGIN
  
       o_result := Plt_Common.SUCCESS;
       o_result_msg := 'STO for pallet ' || i_plt_code;
       
       
       
       
       
       
      /**********************************************************************************/
      /* Save data in STO tables
      /**********************************************************************************/
       -- check if a header record exists
       SELECT COUNT(*) INTO v_count
       FROM STO_HDR
       WHERE cnn = i_cnn
       AND MESG_STATUS = 'S';
       IF v_count = 1 THEN
       
          /* do field checks now   */
          
          -- check if this record line number is the same 
    /*      SELECT COUNT(*) INTO v_count
          FROM STO_HDR h, STO_DET d
          WHERE h.cnn = i_cnn
          AND d.cnn = h.cnn
          AND  line_num = i_line_num;
          IF v_count > 0 THEN
              o_result_msg := 'Cannot add an entry, duplicate Line Number.';
              o_result := Plt_Common.FAILURE;
              RAISE e_process_exception;
          END IF;
       */
       -- ensure a plt exists and is a create type ie not been cancelled
          SELECT COUNT(*) INTO v_count
          FROM PLT_HDR
          WHERE plt_code = i_plt_code
          AND STATUS = 'CREATE';
          IF v_count <> 1 THEN
              o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
              o_result := Plt_Common.FAILURE;
              RAISE e_process_exception;
          END IF;
          
          -- get pallet data 
          SELECT matl_code,  uom, DISPN_CODE, ZPPPI_BATCH 
          INTO v_matl,  v_uom, v_dispn, v_batch
          FROM PLT_HDR
          WHERE plt_code = i_plt_code;
       
          -- check disposition is the same as shiftlog believes
          IF i_stock_status <> v_dispn THEN
              o_result_msg := 'Transaction Failed: The Pallet Disposition is not the same as Atlas';
              o_result := Plt_Common.FAILURE;
              RAISE e_process_exception;
          END IF;
          
          -- check the proc order is not begining with 99 since this is a local
          -- generation only and will not go to Atlas
          SELECT COUNT(*) INTO v_count
          FROM PLT_HDR
          WHERE plt_code = i_plt_code
          AND STATUS = 'CREATE'
          AND SUBSTR(proc_order,1,2) = '99';
     --     IF v_count > 0 THEN
     --         o_result_msg := 'Transaction Failed: A Pallet record has a PROC ORDER begining ''99''.';
     --         o_result := Plt_Common.FAILURE;
     --         RAISE e_process_exception;
     --     END IF;
          
           
           INSERT INTO STO_DET
               VALUES (i_cnn,
                   i_plt_code,
                   v_matl,
                   UPPER(v_uom),
                   i_qty,
                   UPPER(v_dispn),
                   UPPER(v_batch)
                   );
           COMMIT;
       ELSE
           o_result_msg := 'No Header record found. Use PLT_START first.';
           o_result := Plt_Common.FAILURE;
           RAISE e_process_exception;
       END IF;
       
     EXCEPTION
         WHEN e_process_exception THEN
             o_result := Plt_Common.FAILURE;
             
      WHEN IDOC_EXCEPTION THEN
             o_result := Plt_Common.FAILURE;
       
         WHEN OTHERS THEN
             o_result := Plt_Common.FAILURE;
             ROLLBACK;
             o_result_msg := 'ERROR OCCURED in STO_START procedure' || CHR(13) ||SUBSTR(SQLERRM,1,256);
     END;     
           
     
     
  
  
   PROCEDURE STO_Trigger(
       o_result            IN OUT NUMBER,
    o_result_msg        IN OUT VARCHAR2,
       i_cnn               IN VARCHAR2
       )
       AS
    
       e_process_exception  EXCEPTION;
    IDOC_EXCEPTION  EXCEPTION;
       v_line               NUMBER;
       
       
       CURSOR c_sto IS
       SELECT d.cnn,  matl_code, uom, SUM(qty) qty, stock_status, batch,
              DEST_PLANT, DELIV_DATE, DECODE(MAX(deliv_time), NULL, 0, MAX(deliv_time)) DELIV_TIME
       FROM STO_DET d, STO_HDR h
       WHERE h.cnn = d.cnn
       AND h.cnn = i_cnn
       GROUP BY d.cnn, matl_code, uom, stock_status, batch, 
                DEST_PLANT, DELIV_DATE
       ORDER BY batch;
       
          
       rcd c_sto%ROWTYPE; 
       
       v_intfc_rtn      NUMBER(15,0);
    v_interface_type     VARCHAR2(10) := 'CISATL04.1'; 
       v_success            BOOLEAN;
    v_TEST_FLAG      VARCHAR2(1)  := '';
       v_out                VARCHAR2(2000);
       v_stock_status       VARCHAR2(1);
       
   BEGIN
   
       o_result := Plt_Common.SUCCESS;
       o_result_msg := 'STO sent for pallets using cnn code ' || i_cnn;
       
       
       SELECT COUNT(*) INTO v_count
       FROM STO_HDR
       WHERE cnn = i_cnn
       AND MESG_STATUS = 'S';
       
       
       
       -- set up Idoc generation if last record detail record saved.         
       IF v_count = 1 THEN
       
          BEGIN 
          
              -- update STO_HDR table with end flag
              UPDATE STO_HDR SET mesg_status = 'E'
              WHERE cnn = i_cnn;
              
          EXCEPTION
              WHEN OTHERS THEN
                  o_result := Plt_Common.FAILURE;
                  o_result_msg := 'ERROR OCCURED ' || CHR(13) ||SUBSTR(SQLERRM,1,256);
                  RAISE e_process_exception; 
          END;
          
          IF NOT Idoc_Hold THEN
          BEGIN
                
              --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
              v_intfc_rtn := outbound_loader.create_interface(v_interface_type);

              --CREATE DATA LINES FOR MESSAGE

              -- HEADER: Header Record
              -- Including 'X' at the end of the header record will cause Atlas
              -- to treat the message as a test, meaning no further processing
              -- will be completed once it reaches Atlas.
              outbound_loader.append_data('HDRZUB '
                  ||LPAD(Plt_Common.CMPNY_CODE,4,' ')
                  ||RPAD(Plt_Common.PURCH_ORG,4,' ')
                  ||RPAD(Plt_Common.PURCH_GRP,3,' ')
                  ||RPAD(Plt_Common.VENDOR,8,' ')
                  ||RPAD(TRIM(Plt_Common.source_PLANT),4,' ')
                  ||RPAD(Plt_Common.CURRENCY,5,' ')
                  ||RPAD(' ',12,' '));
            
                        
              v_line := 10;
              
              OPEN c_sto;
              LOOP
                  FETCH c_sto INTO rcd;
                  EXIT WHEN c_sto%NOTFOUND;
                  
                  
                  
                  --SELECT DISPN_CODE INTO v_stock_status
                  --FROM plt_hdr 
                  --WHERE plt_code = rcd.plt_code;
                  v_stock_status := rcd.stock_status;
                  
                  -- DET: PROCESS ORDER 
                  outbound_loader.append_data('DET'
                       ||LPAD(TO_CHAR(v_line),5,'0')
                       ||RPAD(TRIM(rcd.MATL_code),8,' ')
                       ||RPAD(TRIM(rcd.dest_plant),4,' ')
                       ||RPAD(TRIM(Plt_Common.STOR_LOCN),4,' ')
                       ||RPAD(UPPER(rcd.uom),3,' ')
                       ||LTRIM(TO_CHAR(rcd.qty,'000000000.000'))
                       ||RPAD(v_stock_status,1,' ')
                       ||TO_CHAR(rcd.deliv_date,'YYYYMMDD')
                       ||LPAD(TO_CHAR(rcd.Deliv_Time),6,'0')
                       ||RPAD(rcd.Batch,10,' '));
                       
                  v_line := v_line + 10;
                                           
              END LOOP;
              CLOSE c_sto;
          
              --Close PASSTHROUGH INTERFACE
              outbound_loader.finalise_interface();
          
          EXCEPTION              
              WHEN OTHERS THEN
              IF (outbound_loader.is_created()) THEN
                  outbound_loader.finalise_interface();
              END IF;
              
                 -- error has occured 
                 -- insert record in log file
                 o_result_msg := 'ERROR OCCURED'|| '-' || SUBSTR(SQLERRM,1,256);
                 o_result := SQLCODE;
                 INSERT INTO STO_IDOC_LOG
                     VALUES (i_cnn,  0, SUBSTR(o_result,1,10), o_result_msg,SYSDATE );
                 o_result := Plt_Common.FAILURE;
              o_result_msg:= 'Creation of STO iDOC failed' || CHR(13) || ' ['||LTRIM(SQLERRM,255)||']';   
                 
                 RAISE IDOC_EXCEPTION;
                 
          END;      
          END IF;
          
          
          -- set sent flag if all ok 
              
          /**********************************************************************************/
          /* Update Sent Flag if all OK
          /**********************************************************************************/
    BEGIN 
              IF NOT Idoc_Hold 
              THEN  
            UPDATE PT.STO_HDR
               SET SENT_FLAG = 'Y'
                   WHERE cnn = i_cnn;
              END IF;
          EXCEPTION
              WHEN OTHERS THEN
                  o_result := Plt_Common.FAILURE;
                  o_result_msg := 'ERROR OCCURED ' || CHR(13) ||SUBSTR(SQLERRM,1,256);
                  RAISE e_process_exception; 
          END;
          
    ELSE
           o_result := Plt_Common.FAILURE;
           o_result_msg := 'No valid STO start record' ;
           RAISE e_process_exception;     
       END IF;
       
         
   EXCEPTION
      WHEN e_process_exception THEN
          o_result := Plt_Common.FAILURE;
          -- RAISE_APPLICATION_ERROR(-20001, o_result_msg);
   WHEN IDOC_EXCEPTION THEN
          o_result := Plt_Common.FAILURE;
    -- RAISE_APPLICATION_ERROR(-20000, o_result_msg);
      WHEN OTHERS THEN
          o_result := Plt_Common.FAILURE;
          ROLLBACK;
          o_result_msg := 'ERROR OCCURED ' || CHR(13) ||SUBSTR(SQLERRM,1,256);
          --  RAISE_APPLICATION_ERROR(-20000, o_result_msg);
   END;



   
 
 
END Tagsys_Whse_Intfc;
/


GRANT EXECUTE ON PT_APP.TAGSYS_WHSE_INTFC TO SHIFTLOG;

GRANT EXECUTE ON PT_APP.TAGSYS_WHSE_INTFC TO SHIFTLOG_APP;

