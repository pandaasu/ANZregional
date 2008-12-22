DROP PROCEDURE PT_APP.CREATE_IDOC;

CREATE OR REPLACE PROCEDURE PT_APP./******************************************************************************
   NAME:       BatchDate
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        05/03/2008  Beau Frericks    1. Changed lics_outbound_loader to point
                                              to outbound_loader.

******************************************************************************/

Create_Idoc(
    o_result            IN OUT NUMBER,
 o_result_msg        IN OUT VARCHAR2,
 iv2#MESSAGE_TYPE IN VARCHAR2, -- Z_PI1 Create or Z_PI2 Reverse
 iv2#PLANT_CODE  IN VARCHAR2,
 iv2#SENDER_NAME  IN VARCHAR2,
 ib#TEST_FLAG  IN BOOLEAN,  -- IF TRUE, THEN CREATE TEST ATLAS MESSAGE
 IN#PROC_ORDER  IN NUMBER,
 ID#XACTN_DATE  IN DATE,
 IN#XACTN_TIME  IN NUMBER,
 iv2#MATERIAL_CODE IN VARCHAR2,
 IN#QTY    IN NUMBER,     -- Material Produced
 iv2#UOM    IN VARCHAR2,
 IN#STOR_LOC_CODE IN NUMBER,
 iv2#DISPN_CODE  IN VARCHAR2, -- Stock Type
 iv2#ZPPPI_BATCH  IN VARCHAR2, -- ATLAS BATCH CODE
 ib#LAST_GR_FLAG  IN BOOLEAN,  -- IF TRUE, THEN LAST MESSAGE
 IN#BB_DATE   IN NUMBER)  -- Best Before Date
AS
 
 v2#intfc_rtn  NUMBER(15,0);
 v2#interface_type VARCHAR2(10) := 'CISATL17';
 v2#TEST_FLAG  VARCHAR2(1)  := '';
    ex#process_exception EXCEPTION;
 
BEGIN

    o_result := 0;
    o_result_msg := 'OK';
    
 IF (ib#TEST_FLAG = TRUE) THEN
    v2#TEST_FLAG := 'X';
 END IF;


      --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
      v2#intfc_rtn := outbound_loader.create_interface(v2#interface_type);

      --CREATE DATA LINES FOR MESSAGE

      -- HEADER: Header Record
      -- Including 'X' at the end of the header record will cause Atlas
      -- to treat the message as a test, meaning no further processing
      -- will be completed once it reaches Atlas.
      outbound_loader.append_data('HDR000000000000000001'
                                           ||RPAD(TRIM(iv2#PLANT_CODE),4,' ')
                                           ||RPAD(iv2#MESSAGE_TYPE,8,' ')
                                           ||RPAD(TRIM(iv2#SENDER_NAME),32,' ')
             ||TRIM(v2#TEST_FLAG));

      --DET: PROCESS ORDER
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_PROCESS_ORDER',30,' ')
                                           ||RPAD(LPAD(TRIM(TO_CHAR(IN#PROC_ORDER)),12,0),30,' ')
                                           ||'CHAR');

      --DET: EVENT DATE
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_EVENT_DATE',30,' ')
                                           ||RPAD(TO_CHAR(ID#XACTN_DATE,'YYYYMMDD'),30,' ')
                                           ||'DATE');

      --DET: EVENT TIME
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_EVENT_TIME',30,' ')
                                           ||RPAD(TRIM(TO_CHAR(IN#XACTN_TIME)),30,' ')
                                           ||'TIME');

      IF ASCII(RTRIM(LTRIM(SUBSTR(iv2#MATERIAL_CODE,1,1)))) >= 48 AND  ASCII(RTRIM(LTRIM(SUBSTR(iv2#MATERIAL_CODE,1,1)))) <= 57 THEN
          --DET: MATERIAL CODE
          outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_MATERIAL',30,' ')
                                           ||RPAD(LPAD(TRIM(iv2#MATERIAL_CODE),18,'0'),30,' ')
                                           ||'CHAR');
      ELSE
          outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_MATERIAL',30,' ')
                                           ||RPAD(trim(iv2#MATERIAL_CODE),30,' ')
                                           ||'CHAR');
      END IF;

      --DET: MATERIAL PRODUCED (QTY)
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_MATERIAL_PRODUCED',30,' ')
                                           ||RPAD(TRIM(TO_CHAR(IN#QTY)),30,' ')
                                           ||'NUM');

      --DET: UNIT OF MEASURE (UOM)
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_UNIT_OF_MEASURE',30,' ')
                                           ||RPAD(TRIM(iv2#UOM),30,' ')
                                           ||'CHAR');

      --DET: STORAGE LOCATION
   IF (IN#STOR_LOC_CODE IS NOT NULL) THEN
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_STORAGE_LOCATION',30,' ')
                                           ||RPAD(LPAD(TRIM(TO_CHAR(IN#STOR_LOC_CODE)),4,0),30,' ')
                                           ||'CHAR');
   END IF;

      --DET: STOCK TYPE (DISPN)
   IF (iv2#DISPN_CODE IS NOT NULL) THEN
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('Z_PPPI_STOCK_TYPE',30,' ')
                                           ||RPAD(iv2#DISPN_CODE,30,' ')
                                           ||'CHAR');
   END IF;

   --DET: ZPPPI BATCH CODE
   IF (iv2#ZPPPI_BATCH IS NOT NULL) THEN
          IF iv2#MESSAGE_TYPE  = 'Z_PI2' THEN
             outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_BATCH',30,' ')
                                           ||RPAD(iv2#ZPPPI_BATCH,30,' ')
                                           ||'CHAR');
          ELSE
              outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_BATCH',30,' ')
                                           ||RPAD(iv2#ZPPPI_BATCH,30,' ')
                                           ||'CHAR');
          END IF;
   END IF;

   --DET: DELIVER COMPLETE (LAST GR/RGR) 
   IF (ib#LAST_GR_FLAG = TRUE) THEN
      outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('PPPI_DELIVERY_COMPLETE',30,' ')
                                           ||RPAD(TRIM('X'),30,' ')
                                           ||'CHAR');
   END IF;
             
   --DET: BEST BEFORE DATE (SHELF LIFE EXPIRATION DATE = SLED) 
   IF (IN#BB_DATE IS NOT NULL) THEN
          IF iv2#MESSAGE_TYPE  = 'Z_PI1' THEN
              
          
              outbound_loader.append_data('DET000000000000000001'
                                           ||RPAD('ZPPPI_SLED',30,' ')
                                           ||RPAD(TRIM(IN#BB_DATE),30,' ')
                                           ||'DATE');
          END IF;
   END IF;

      --Close PASSTHROUGH INTERFACE
      outbound_loader.finalise_interface();


   EXCEPTION
     WHEN OTHERS THEN
    IF (outbound_loader.is_created()) THEN
       outbound_loader.finalise_interface();
    END IF;
       o_result := 1;
    o_result_msg := 'Creation of iDOC failed ['||SQLERRM||']';
       --RAISE_APPLICATION_ERROR(-20001, v2#err_msg);
END;
/


