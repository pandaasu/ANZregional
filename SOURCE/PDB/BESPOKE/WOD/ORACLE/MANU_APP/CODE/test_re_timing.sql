DROP PACKAGE MANU_APP.TEST_RE_TIMING;

CREATE OR REPLACE PACKAGE MANU_APP.TEST_RE_TIMING AS

/***********************************************************/
/* retrieve all process orders in the active mode
/* used for the Recipe report tool
/***********************************************************/
   PROCEDURE retrieve_frr_proc_orders (
      i_plant_code       IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_result_msg       OUT      VARCHAR2,
      o_retrieve_procs   OUT      Re_Timing_Common.return_ref_cursor
   );

END TEST_RE_TIMING;
/


DROP PACKAGE BODY MANU_APP.TEST_RE_TIMING;

CREATE OR REPLACE PACKAGE BODY MANU_APP.TEST_RE_TIMING AS

/***********************************************************/
  /* retrieve all process orders in the active mode 
  /* used for the Recipe report tool 
  /***********************************************************/ 
  PROCEDURE RETRIEVE_FRR_PROC_ORDERS(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER, 
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_procs OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
	  
	  var_work VARCHAR2(100);
	  var_work1 NUMBER;
		
		
  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
		o_result_msg := '';
		
      OPEN o_retrieve_procs FOR 
		SELECT LTRIM(proc_order,'0') proc_order,
             cntl_rec_id,
		 		 LTRIM(matl_code,'0') matl_code,
		 		 matl_text matl_desc,
		 		 qty,
		 		 uom,
		 		 run_start_datime,
		 		 run_end_datime,
		 		 teco_stat
        FROM cntl_rec
		  WHERE plant = i_plant_code
		    AND (teco_stat = 'NO' OR LTRIM(proc_order,'0') = '1096433')
			 AND run_start_datime > TRUNC(SYSDATE) - 4
			 AND run_start_datime < TRUNC(SYSDATE) + 10
		 ORDER BY run_start_datime;
									
   EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE FRR Proc Orders procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);		
  END RETRIEVE_FRR_PROC_ORDERS;

END TEST_RE_TIMING;
/


GRANT EXECUTE ON MANU_APP.TEST_RE_TIMING TO OWENDAN;

GRANT EXECUTE ON MANU_APP.TEST_RE_TIMING TO PR_USER;

