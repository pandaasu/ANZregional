CREATE OR REPLACE PACKAGE MANU_APP.Re_Timing IS
/******************************************************************************
   NAME:       Re  timing tool functions
   PURPOSE:    This package will provide the interface between the windows application
	            Re-timming tool and Oracle
					All reference data for the re-timing toool display will be proviided
					plus the current view of all process orders and schedule.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        21/11/2005   Jeff Phillipson    1. Created this package.
   2.0		    22/11/2006   Jeff Phillipson	  Removed all RTT interfaces Just FRR procs now
   3.1        28-Aug-2008  Daniel Owen        Added DISTINCT to query in retrieve_recpe_waiver   			  			   					  
******************************************************************************/

 /***********************************************************/
  /* RETRIEVE_PROC_ORDER_CHAIN will retrieve  Proc Orders 
  /* based on Parenet Child to 3 levels.
  /* This query has to consider _
  /* Unasigned Proc Orders start after the start date of the input Proc Order
  /* Teco PO's will be ignored
  /* This data is used to provide a report within the FRR for suggesting 
  /* modified run start times of lower level process orders
  /***********************************************************/
  PROCEDURE RETRIEVE_PROC_ORDER_CHAIN(i_plant_code IN VARCHAR2,
  								  o_result OUT NUMBER, 
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_proc_order_chain OUT Re_Timing_Common.RETURN_REF_CURSOR);


  /******************************************************************/
  /* Removes proc_orders from rd_teco_pending onced they are TECO'd */
  /******************************************************************/
  FUNCTION CLEAN_RD_TECO_PENDING RETURN NUMBER;


  /***************************************************************************/
  /* Inserts a Proc_Order (leading zeros trimmed) into RD_TECO_PENDING table */
  /***************************************************************************/
  PROCEDURE INSERT_RD_TECO_PENDING(proc_order IN VARCHAR2);



  /***********************************************************/
  /* RETRIEVE_SHIFTS will retrieve the shift data for the specified plasnt code
  /***********************************************************/
  PROCEDURE RETRIEVE_SHIFTS(i_plant_code IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_shifts OUT Re_Timing_Common.RETURN_REF_CURSOR);


  /***********************************************************/
  /* User_Role will determine if the current user
  /* for the Factory Recipe Report
  /* has access - NO acess to this application - returns 0
  /*  general user access - PR_USER - return 1
  /*  R-D access PR_FDR_ISSR - return 2
  /*   ADMIN - PR_ADMIN - return 3
  /***********************************************************/
  FUNCTION User_Role(i_userid IN VARCHAR2)  RETURN NUMBER;

  /***********************************************************/
  /* User_Role_Demands will determine if the current user 
  /* for the Factory Recipe Report 
  /* has access - to print the process order demands
  /* Nn - returns 0 
  /* Yes - PR_PLNR - return 1
  /*  Yes - PR_ADMIN - return 1 
  /***********************************************************/
  FUNCTION USER_ROLE_DEMANDS(i_userid IN VARCHAR2)  RETURN NUMBER;
  
  /***********************************************************/
  /* retrieve all process orders demands ie parent child process orders 
  /***********************************************************/ 
  PROCEDURE RETRIEVE_PARENT_DEMANDS(i_plant_code IN VARCHAR2,
  							o_result OUT NUMBER, 
							o_result_msg OUT VARCHAR2,
							o_retrieve_parent_demands OUT Re_Timing_Common.RETURN_REF_CURSOR);
	
	

  /***********************************************************/
  /* Get the Plant description by passing in the plant code
  /***********************************************************/
  FUNCTION GET_PLANT_DESC(i_plant_code IN VARCHAR2)  RETURN VARCHAR2;



  /***********************************************************/
  /* retrieve all process orders in the active mode
  /* used for the Recipe report tool
  /***********************************************************/
  PROCEDURE RETRIEVE_FRR_PROC_ORDERS(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_procs OUT Re_Timing_Common.RETURN_REF_CURSOR);

  /***********************************************************/
  /* retrieve all process orders in the active mode
  /***********************************************************/
  PROCEDURE RETRIEVE_RD_PROC_ORDERS(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_procs OUT Re_Timing_Common.RETURN_REF_CURSOR);



  /***********************************************************/
  /* RECIPE REPORT
  /* the following procedures are used to retrieve recipe data
  /* from the data base
  /* they are used to get data for the Factory Recipe Report (FRR)
  /***********************************************************/



  /***********************************************************/
  /* retrieve the recipe header information for the recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_HDR(i_proc_order IN VARCHAR2,
  										i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR);


  /***********************************************************/
  /* retrieve the recipe detail information for the recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_DTL(i_proc_order IN VARCHAR2,
  									   i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR);


  /***********************************************************/
  /* retrieve the recipe footer information for the recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_FTR(i_proc_order  IN VARCHAR2,
  										i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR);


  /***********************************************************/
  /* retrieve any waivers that are active for the selected proic order material
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_WAIVER(i_proc_order IN VARCHAR2,
  									   i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR);


  /***********************************************************/
  /* RETRIEVE_Plants will retrieve the plants available in this database
  /* this is used in the factory recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_PLANTS(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_plants OUT Re_Timing_Common.RETURN_REF_CURSOR);


 


  /***********************************************************/
  /* RETRIEVE_Materials which can have a process order created
  /* this is used in the factory recipe report - R-D section
  /***********************************************************/
  PROCEDURE RETRIEVE_MATLS(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_matls OUT Re_Timing_Common.RETURN_REF_CURSOR);

  /***********************************************************/
  /* Insert or Delete a record from the R and D Schedule table
  /* - and send to Atlas
  /***********************************************************/
  FUNCTION INSERT_RD_SCHED(i_matl IN VARCHAR2,
								i_qty IN NUMBER,
								i_plant_code IN VARCHAR2,
								i_status VARCHAR2
								) RETURN NUMBER;

	/*-*/
	/*  i_status  -		I 			Insert a record in RD_SCHED table
	/*	 			  			D			Delete the record from the RD_SCHED table
	/*							S			Test used to send the Main Schedule into Atlas
   /*-*/


/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : MANU_APP
 Package : OBS_BOM_REPORT  mpved into RE_TIMING package 
 Owner   : MANU_APP
 Author  : Raja X. Vaidyanathan

 Description
 -----------
    This package is for generating a report that lists all BOMs that are no longer used and that can be made obsolete
    without having to worry about the fact if it is used anywhere.
    The procedure walks the FG in question and identifies all its BOMs and then finds if any of them are used anywhere
    and if not, reports it in the output to enable user to take action on them.


 DD-MON-YYYY   Author                 Description
 ------------  --------------------  -----------
 06-May-2008   Raja Vaidyanathan      Created.   
 06-May-2008   Scott R. Harding       Minor corrections.
 16-May-2008   Raja Vaidyanathan      Changes made to the package body due to performance problem
**/
--Global Variables
  L_WHERE_MSG VARCHAR2(4000) := NULL;
  RET_SUCCESS NUMBER         := 0;
  RET_FAILURE NUMBER         := 1;
  APP_EXPN                   EXCEPTION;
  
--Reference Cursor
  TYPE RETURN_REF_CURSOR IS REF CURSOR;
  
--Procedures
  PROCEDURE PROCESS_OBS_BOMS(o_result     OUT NUMBER,
                             o_result_msg OUT VARCHAR2,
                             i_plant      IN  VARCHAR2,
                             i_bom        IN  VARCHAR2,  
                             i_first_time IN  VARCHAR2);
                             
  FUNCTION OBS_BOM_ITERATION(i_plant      IN  VARCHAR2) RETURN NUMBER;
  
--                             
  PROCEDURE OBS_BOM_RECORDS(o_result       OUT NUMBER,
                            o_result_msg   OUT VARCHAR2,
                            cur_OUT        IN OUT RETURN_REF_CURSOR);
                            
                            
END Re_Timing;
/

CREATE OR REPLACE PACKAGE BODY MANU_APP.Re_Timing IS
/******************************************************************************
   NAME:       Re  timing tool functions
   PURPOSE:    This package will provide the interface between the windows application
	            Re-timming tool and Oracle
					All reference data for the re-timing toool display will be proviided
					plus the current view of all process orders and schedule.

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        21/11/2005   Jeff Phillipson    1. Created this package.
   2.0		  22/11/2006   Jeff Phillipson	  Removed all RTT interfaces
   			  			   					  Just FRR procs now
   3.0        27-May-2008  Jeff Phillipson  Obsolete BOM Report procedures added to end of package 

******************************************************************************/

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   var_work		   NUMBER DEFAULT 0;
   var_start      NUMBER;

 /***********************************************************/
  /* RETRIEVE_PROC_ORDER_CHAIN will retrieve  Proc Orders 
  /* based on Parenet Child to 3 levels.
  /* This query has to consider _
  /* Unasigned Proc Orders start after the start date of the input Proc Order
  /* Teco PO's will be ignored
  /* This data is used to provide a report within the FRR for suggesting 
  /* modified run start times of lower level process orders
  /***********************************************************/
  PROCEDURE RETRIEVE_PROC_ORDER_CHAIN(i_plant_code IN VARCHAR2,
  									 o_result OUT NUMBER, 
								     o_result_msg OUT VARCHAR2,
								     o_retrieve_proc_order_chain OUT Re_Timing_Common.RETURN_REF_CURSOR)
  IS
  
       
  BEGIN
  	  o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';
		
	  OPEN o_retrieve_proc_order_chain FOR
	  SELECT   LTRIM (t01.proc_order, '0') child_proc_order,
         LTRIM (t01.material, '0') child_matl_code,
         t01.material_text child_matl_text,
         ROUND(t01.quantity, 2) || LOWER(t01.UOM) child_to_be_made,
         TO_CHAR (TRUNC (t01.run_start_datime)) child_start_date,
         TO_CHAR (t01.run_start_datime, 'hh24:mi') child_start_time,
         TO_CHAR (TRUNC (t07.suggested_date)) suggested_start_date,
         TO_CHAR (t07.suggested_date, 'hh24:mi') suggested_start_time,
         -- anything within 15 minutes doesnt need to be changed
         CASE
            WHEN ABS (t01.run_start_datime - t07.suggested_date) < 15 / 1440
               THEN 'No'
            ELSE 'Yes'
         END CHANGE,
         LTRIM (t03.proc_order, '0') prnt_proc_order,
         LTRIM (t04.material, '0') prnt_matl_code,
         t04.material_text prnt_matl_text,
         t04.quantity || LOWER(t04.UOM) prnt_qty,
         TO_CHAR (TRUNC (t04.run_start_datime)) prnt_start_date,
         TO_CHAR (t04.run_start_datime, 'hh24:mi') prnt_start_datime
      FROM cntl_rec t01,
         material t02,
         cntl_rec_bom t03,
         cntl_rec t04,
         (SELECT   t05.material_code,
                   MIN (run_start_datime) - 2 / 24 suggested_date
              FROM cntl_rec_bom t05, cntl_rec t06
             WHERE t05.proc_order = t06.proc_order
               -- AND LTRIM(t05.MATL_CODE,'0') = '1034648'
               AND teco_status = 'NO'
               AND t06.run_start_datime BETWEEN TRUNC (SYSDATE) - 1
                                            AND TRUNC (SYSDATE) + 2
          GROUP BY t05.material_code) t07
      WHERE LTRIM (t01.material, '0') = t02.material_code
        AND t01.material = t03.material_code
     	AND t03.proc_order = t04.proc_order
     	--AND t01.plant = t02.plant
     	--AND t01.plant = t03.plant_code
     	AND t01.material = t07.material_code
    	AND t01.run_start_datime BETWEEN TRUNC (SYSDATE) + 1 AND   TRUNC (SYSDATE) + 2
     	AND t01.plant = i_plant_code
     	AND t01.teco_status = 'NO'
     	AND t02.material_type = 'ROH'
     	AND t04.teco_status = 'NO'
     	AND t04.run_start_datime > TRUNC (SYSDATE)
     	AND t04.run_start_datime < TRUNC (SYSDATE) + 2
      ORDER BY t01.run_start_datime, t01.proc_order, t04.run_start_datime;

 EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_PROC_ORDER_CHAIN procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);		  
   
  
  END RETRIEVE_PROC_ORDER_CHAIN;	
  
  /******************************************************************/
  /* Removes TECO'd proc_orders from rd_teco_pending                */
  /******************************************************************/
  FUNCTION CLEAN_RD_TECO_PENDING RETURN NUMBER IS
  BEGIN
    DELETE FROM rd_teco_pending
    WHERE proc_order IN (SELECT t02.proc_order
    FROM cntl_rec t01, rd_teco_pending t02
    WHERE LTRIM(t01.proc_order, '0') = t02.proc_order
     AND t01.teco_status = 'YES');

    RETURN Re_Timing_Common.SUCCESS;

  EXCEPTION
   WHEN OTHERS THEN
    RETURN Re_Timing_Common.FAILURE;
  END CLEAN_RD_TECO_PENDING;


  /***************************************************************************/
  /* Inserts a Proc_Order (leading zeros trimmed) into RD_TECO_PENDING table */
  /***************************************************************************/
  PROCEDURE INSERT_RD_TECO_PENDING(proc_order IN VARCHAR2) IS
  BEGIN
    INSERT INTO rd_teco_pending (proc_order)
    VALUES (LTRIM(proc_order,'0'));
  EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
    /* Handle failed insertion quietly if proc_order is already in table */
    NULL;
   WHEN OTHERS THEN
    /* TODO: confirm if any other errors need handling */
    NULL;
  END INSERT_RD_TECO_PENDING;

  /***********************************************************/
  /* RETRIEVE_SHIFTS will retrieve the shift data for the specified plasnt code
  /***********************************************************/
  PROCEDURE RETRIEVE_SHIFTS(i_plant_code IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_shifts OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN

  		o_result  := Re_Timing_Common.SUCCESS;
		o_result_msg := '';

       /*OPEN o_retrieve_shifts FOR
	  SELECT MOD(TO_NUMBER(TO_CHAR(start_datime,'D')),7) ID,
		      INITCAP(DECODE(trim(UPPER(shift_type_name)),'AFTERNOON 8HR', 'AFTN 8hr', 'AFTERNOON','AFTN',trim(shift_type_name))) shift_type_name,
		      SUBSTR(shift_type_name,1,1) shift_type_short_name,
		      start_datime
       FROM prodn_shift pt, shift_type st
      WHERE trim(plant_code) = i_plant_code
        AND start_datime > TRUNC(SYSDATE) - 1
        AND start_datime < TRUNC(SYSDATE) + 9
        AND st.SHIFT_TYPE_CODE = pt.SHIFT_TYPE_CODE
      ORDER BY 4; */
      OPEN o_retrieve_shifts FOR 
        SELECT * FROM dual WHERE 1=0;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Shifts procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);

  END RETRIEVE_SHIFTS;





  /***********************************************************/
  /* User_Role will determine if the current user
  /* has access - NO acess to this application - returns 0
  /*  general user access - PR_USER - return 1
  /*  R-D access PR_FDR_ISSR - return 2
  /*   ADMIN - PR_ADMIN - return 3
  /***********************************************************/
  FUNCTION User_Role(i_userid IN VARCHAR2)  RETURN NUMBER IS

      var_return NUMBER;
		var_work VARCHAR2(20);

		CURSOR cur_role IS
      SELECT granted_role FROM DBA_ROLE_PRIVS
		 WHERE grantee = UPPER(i_userid)
         AND granted_role IN ('PR_USER','PR_FDR_ISSR')
		 ORDER BY 1 ASC;

  BEGIN

  		var_return := 0;  -- default

      OPEN cur_role;
      LOOP
         FETCH cur_role INTO var_work;
         EXIT WHEN cur_role%NOTFOUND;
			   var_work := trim(UPPER(var_work));
				IF var_work = 'PR_ADMIN' THEN
			      var_return := 3;
					EXIT;
			   END IF;
		      IF var_work = 'PR_FDR_ISSR' THEN
			      var_return := 2;
					EXIT;
			   END IF;
			   IF var_work = 'PR_USER' THEN
			      var_return := 1;
					EXIT;
			   END IF;
      END LOOP;
      CLOSE cur_role;
  RETURN var_return;

  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN 0;

  END;

    /***********************************************************/
  /* User_Role_Demands will determine if the current user 
  /* for the Factory Recipe Report 
  /* has access - to print the process order demands
  /* Nn - returns 0 
  /* Yes - PR_PLNR - return 1
  /*  Yes - PR_ADMIN - return 1 
  /***********************************************************/
  FUNCTION USER_ROLE_DEMANDS(i_userid IN VARCHAR2)  RETURN NUMBER IS
      var_return NUMBER;
	  
  BEGIN
      SELECT COUNT(*) INTO var_return
	    FROM DBA_ROLE_PRIVS
	   WHERE grantee = UPPER(i_userid)
         AND granted_role IN ('PR_PLNR','PR_ADMIN')
	   ORDER BY 1 ASC;
	   IF var_return = 2 THEN
	       var_return := 1;
	   END IF;
	   RETURN var_return;
	   
  END USER_ROLE_DEMANDS;
  
  /***********************************************************/
  /* retrieve all process orders demands ie parent child process orders 
  /***********************************************************/ 
  PROCEDURE RETRIEVE_PARENT_DEMANDS(i_plant_code IN VARCHAR2,
  							o_result OUT NUMBER, 
							o_result_msg OUT VARCHAR2,
							o_retrieve_parent_demands OUT Re_Timing_Common.RETURN_REF_CURSOR) IS 
  
  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';
		
      OPEN o_retrieve_parent_demands FOR 
	  /* Formatted on 2006/12/14 09:29 (Formatter Plus v4.8.7) */
      SELECT LTRIM (t01.proc_order, '0') prnt_proc_order,
          LTRIM (t01.material, '0') prnt_matl_code,
       	  t01.material_text prnt_matl_text, t01.quantity prnt_qty,
       	  TO_CHAR (ROUND (t01.run_start_datime, 'mi'),'Dy dd Mon hh24:mi') prnt_run_start_datime,
       	  --DECODE (t03.pan_size_flag,'N', t03.qty, NVL (t03.pan_qty, 1) * t03.pan_size) child_demand,
       	  t03.material_qty,
		  LTRIM (t05.proc_order, '0') child_proc_order,
       	  LTRIM (t03.material_code, '0') child_matl_code,
       	  t05.material_text child_matl_text, t05.quantity child_to_be_made,
       	  TO_CHAR (ROUND (t05.run_start_datime),'Dy dd Mon hh24:mi') child_start_datime,
       	  CASE
              WHEN TO_NUMBER (  ROUND (t01.run_start_datime, 'mi')- ROUND (t05.run_start_datime, 'mi')
                         	 ) > 120 / 1440 + 15 / 1440
             				 THEN TO_CHAR (t01.run_start_datime - 2 / 24, 'Dy dd Mon hh24:mi')
              WHEN TO_NUMBER (  ROUND (t01.run_start_datime, 'mi')- ROUND (t05.run_start_datime, 'mi')
                         	 ) < 120 / 1440 + 15 / 1440
             				 THEN TO_CHAR (t01.run_start_datime - 2 / 24, 'Dy dd Mon hh24:mi')
              ELSE 'No change'
          END suggested_start
  		  --, TO_NUMBER(ROUND(t01.run_start_datime,'mi') - ROUND(t05.RUN_START_datime,'mi')),120/1440, t01.RUN_START_datime
	 FROM cntl_rec t01, material t02, cntl_rec_bom t03, material t04, cntl_rec t05,
	      material_mrp t06
    WHERE LTRIM (t01.material, '0') = t02.material_code
      AND t01.proc_order = t03.proc_order(+)
     -- AND t01.plant = t02.plant                  -- plant code has to be the same
      AND LTRIM (t03.material_code, '0') = t04.material_code(+)
      -- added
	  AND t04.MATERIAL_CODE = t06.MATERIAL(+)
	  AND t06.MRP_CNTRLLR(+) = 116
	  --AND t04.prcrmnt_type = 'E'
      -- only child materials that can have a process order raised
      --AND t04.spcl_prcrmnt_type IS NULL
      -- only child materials that can have a process order raised
     AND t01.teco_status = 'NO'
   	 AND t02.tdu_code = 'X'
   	 AND TRUNC (t01.run_start_datime) = TRUNC (SYSDATE)
     -- all process orders have to be for today
     --AND LTRIM(t01.proc_order,'0') = '1071801'
     AND t03.material_code = t05.material
     AND t05.run_start_datime < SYSDATE + 1
   	 AND t05.teco_status = 'NO'
   	 AND t05.run_start_datime <= t01.run_start_datime
   	 AND t01.plant = i_plant_code  -- select by plant
   ORDER BY 5;                                 

	
  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - retrieve_parent_demands' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);	
  END RETRIEVE_PARENT_DEMANDS;
  
  /***********************************************************/
  /* Get the Plant description by passing in the plant code
  /***********************************************************/
  FUNCTION GET_PLANT_DESC(i_plant_code IN VARCHAR2)  RETURN VARCHAR2 IS

  var_work VARCHAR2(200);

  BEGIN
  		 SELECT plant_desc plant_name INTO var_work
		   FROM REF_PLANT
		  WHERE plant_code = i_plant_code;

		RETURN var_work;

  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN 'None found';
  END GET_PLANT_DESC;

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
	  SELECT LTRIM(proc_order,'0') AS proc_order,
             cntl_rec_id,
			 LTRIM(material,'0') AS matl_code,
			 material_text AS matl_desc,
			 quantity AS qty,
			 uom,
			 run_start_datime,
			 run_end_datime,
			 teco_status AS teco_stat
        FROM bds_recipe_header
	   WHERE plant_code = i_plant_code
		 AND teco_status = 'NO' 
		 AND run_start_datime > TRUNC(SYSDATE) - 5
		 AND run_start_datime < TRUNC(SYSDATE) + 20
         AND ASCII(SUBSTR(proc_order,1,1)) BETWEEN ASCII(0) AND ASCII(9)
	   ORDER BY run_start_datime;
									
   EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE FRR Proc Orders procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);		
  END RETRIEVE_FRR_PROC_ORDERS;


  /***********************************************************/
  /* retrieve all R and D process orders in the active mode 
  /***********************************************************/ 
  PROCEDURE RETRIEVE_RD_PROC_ORDERS(i_plant_code IN VARCHAR2,
  									o_result OUT NUMBER, 
								  	o_result_msg OUT VARCHAR2,
								  	o_retrieve_procs OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
									
      var_work VARCHAR2(100);
	  var_work1 NUMBER;
		
  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';
		
	  OPEN o_retrieve_procs FOR 
	  SELECT LTRIM(t01.proc_order,'0') AS proc_order,
	         cntl_rec_id,
			 LTRIM(t01.material,'0') AS matl_code,
	         material_text matl_desc,
		     quantity AS qty,
		     t01.uom,
		     t01.run_start_datime,
		     run_end_datime,
		     'Y',
		     '-1',
		     0,
		     0,
		     1
	    FROM bds_recipe_header t01
       WHERE t01.plant_code = i_plant_code
         AND SUBSTR(proc_order,1,1) NOT BETWEEN '0' AND '9'
         AND upd_datime > SYSDATE - 100
       ORDER BY 1 DESC, 3;
			 
  EXCEPTION
      WHEN OTHERS THEN
		  o_result  := Re_Timing_Common.FAILURE;
		  o_result_msg := 'RE_TIMING - RETRIEVE Proc RD Orders procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);		
  END RETRIEVE_RD_PROC_ORDERS;


  /***********************************************************/
  /***********************************************************/
  /* RECIPE REPORT
  /* the following procedures are used to retrieve recipe data
  /* from the data base
  /* they are used to get data for the Factory Recipe Report (FRR)
  /***********************************************************/
   /***********************************************************/


  /***********************************************************/
  /* retrieve the recipe header information for the recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_HDR(i_proc_order  IN VARCHAR2,
  										i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

      var_work NUMBER;
		var_work1 NUMBER;

  BEGIN
     o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	  /*-*/
	  /* check if a recipe exists for this proc order and control rec id
	  /*-*/
	   SELECT COUNT(*) INTO var_work
	    FROM RECPE_HDR t01, CNTL_REC t02
      WHERE LTRIM(t01.proc_order,'0') = LTRIM(t02.Proc_order,'0')
		  AND LTRIM(t01.proc_order,'0') = LTRIM(i_proc_order,'0');

	  IF var_work = 0 THEN
	      /*-*/
			/* get the cntl rec id
			/*-*/
	      SELECT cntl_rec_id INTO var_work1
			  FROM CNTL_REC
			 WHERE LTRIM(proc_order,'0') = i_proc_order;
			 /*-*/
			 /* load the recipe
			 /*-*/
	      Recipe_Conversion.EXECUTE(var_work1);
			COMMIT;
	  END IF;


	    OPEN o_retrieve_recipe FOR
		 SELECT cntl_rec_id,
		 		  proc_order,
				  c.matl_code,
				  matl_desc,
              	  run_start_datime,
				  run_end_datime,
		 		  DECODE(tun_code,NULL,'-1',tun_code) tun_code,
		 		  DECODE(old_matl_code,NULL,'-1',old_matl_code) old_matl_code,
		 		  qty,
		 		  c.uom,
				  units_per_case,
				  P.CRTNS_PER_PLLT,
				  '0'  zrep,
				  '' sales_text,
				  M.SHELF_LIFE,
				  M.DCLRD_WGHT net_wght,
				  M.GROSS_WGHT
		   FROM RECPE_HDR c, MATERIAL_PLLT P, material M
        WHERE c.MATL_CODE = P.MATL_CODE(+)
		  AND c.MATL_CODE = M.MATERIAL_CODE(+)
		  AND LTRIM(c.proc_order,'0') = LTRIM(i_proc_order,'0');

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_RECIPE_HDR procedure with ProcOrder ' || trim(i_proc_order) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
             OPEN o_retrieve_recipe FOR 
             SELECT * FROM dual WHERE 1=0;
  END RETRIEVE_RECIPE_HDR;


  /***********************************************************/
  /* retrieve the recipe detail information for the recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_DTL(i_proc_order IN VARCHAR2,
  										i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN
     o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	     OPEN o_retrieve_recipe FOR 
	   SELECT t01.cntl_rec_id, 
		 	  t01.opertn, 
			  t01.phase, 
			  t01.seq,
		 	  old_matl_code matl_code,
		 	  DECODE(t01.description, NULL, '-1',t01.description) matl_desc,
			  t01.DETAILTYPE detailtype,
		 	  DECODE(t01.uom, NULL, '-1','?','-1', t01.uom) uom,
		 	  DECODE(TO_CHAR(qty), NULL, '-1', '?','-1', t01.qty) bom_qty,
		 	  DECODE(t01.sub_total, NULL, '0', t01.sub_total) total,
			  sub_header --, DECODE(t02.VALUE, NULL,'N','Y') different
         FROM recpe_vw t01 --, recpe_diff t02
        WHERE /*t01.proc_order = t02.proc_order(+)
          AND t01.opertn = t02.opertn(+)
          AND t01.phase = t02.phase(+)
          AND t01.seq = t02.seq(+)
          AND */t01.proc_order = i_proc_order
	    ORDER BY t01.opertn, t01.phase, t01.seq;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_RECIPE_DTL procedure with ProcOrder' || trim(i_proc_order) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
            OPEN o_retrieve_recipe FOR 
            SELECT * FROM dual WHERE 1=0;
  END RETRIEVE_RECIPE_DTL;


  /***********************************************************/
  /* retrieve the recipe footer information for the recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_FTR(i_proc_order IN VARCHAR2,
  										i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

   BEGIN
     o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	    OPEN o_retrieve_recipe FOR
		 SELECT c.*
         FROM RECPE_DTL c, RECPE_HDR h
        WHERE h.CNTL_REC_ID = c.CNTL_REC_ID
		    AND h.proc_order = i_proc_order
		  ORDER BY opertn, phase, seq;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_RECIPE_FTR procedure with ProcOrder ' || trim(i_proc_order) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
             OPEN o_retrieve_recipe FOR 
             SELECT * FROM dual WHERE 1=0;
  END RETRIEVE_RECIPE_FTR;


  /***********************************************************/
  /* retrieve any waivers that are active for the selected proc order material
  /***********************************************************/
  PROCEDURE RETRIEVE_RECIPE_WAIVER(i_proc_order IN VARCHAR2,
  									   i_recipe_type IN NUMBER,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_recipe OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';
      OPEN o_retrieve_recipe FOR 
        SELECT * FROM dual WHERE 1=0;
        
	   /* ******************************************************************************
     This section of code is commented out as waivers is not installed in this database at this site.
     Since the tables do not exist, uncommenting would stop compilation.
     *********************************************************************************
     OPEN o_retrieve_recipe FOR
	   SELECT DISTINCT w.waiver_code
		 FROM WAIVER w, wm.WAIVER_CRTRIA c
		WHERE w.waiver_code = c.waiver_code
		  AND eff_start_datime <= SYSDATE
		  AND eff_end_datime >= SYSDATE
		  AND item_code = (SELECT LTRIM(material,'0')
			                FROM CNTL_REC
			      			 WHERE LTRIM(proc_order,'0') = LTRIM(i_proc_order,'0')); */

    EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_WAIVERS procedure with ProcOrder ' || trim(i_proc_order) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_RECIPE_WAIVER;


  /***********************************************************/
  /* RETRIEVE_Plants will retrieve the plants available in this database
  /* this is used in the factory recipe report
  /***********************************************************/
  PROCEDURE RETRIEVE_PLANTS(i_plant_code IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_plants OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

   BEGIN
     o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	    OPEN o_retrieve_plants FOR
		 SELECT trim(c.PLANT_code) plant,
		        trim(c.PLANT_desc) plant_name
         FROM ref_PLANT c
        WHERE trim(c.PLANT_CODE) = i_plant_code
		    AND trim(c.plant_code) IN (SELECT plant FROM CNTL_REC WHERE teco_status = 'NO')
		  ORDER BY 1;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_PLANTS procedure failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_PLANTS;


  /***********************************************************/
  /* RETRIEVE_Materials which can have a process order created
  /* this is used in the factory recipe report - R-D section
  /***********************************************************/
  PROCEDURE RETRIEVE_MATLS(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_matls OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	   o_result_msg := '';

	   OPEN o_retrieve_matls FOR
		   SELECT material_code matl_code, material_desc matl_desc, i_plant_code plant
			  FROM material
			 WHERE prcrmnt_type = 'E'
			  --  AND spcl_prcrmnt_type IS NULL no equiv in mfa yet
			   AND plant_sts = '20'
				AND (LTRIM(MATERIAL_CODE,'0')) NOT IN
				    (SELECT matl_code FROM rd_sched)
				ORDER BY  3,1;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_MATLS procedure failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END;


     /*-*/
	 /* internal functions
	 /*-*/
	 FUNCTION getElement (sList IN OUT VARCHAR2, sDelimiter IN VARCHAR2) RETURN VARCHAR2 IS
		/* This function is used to return the next element in a list of element stored in a string or
		 *  the leftmost portion of a string up to a particular delimiter.
		 *
		 * When called, the first element, up to and including sDelimiter is removed from sList and the
		 *  element returned by this function.
		 *
		 * If the list consists of only one element, or doesn't contain the delimiter at all, the whole
		 *  of sList is returned and sList set to the empty string. Calling this function with the
		 *	empty string, returns the empty string.
		 *
		 * The parameter sDelimiter is usually a "," but it can be any character or string of characters.
		 */
		iCharPos INTEGER;
		sTemp VARCHAR2(4000);
		BEGIN
		    -- find the end of the element by finding the sDelimiter or end of string
			iCharPos := INSTR(sList, sDelimiter);
			sTemp := sList;
			IF iCharPos = 0 THEN
			    sList := '';
				RETURN sTemp;
			ELSE
				sList := SUBSTR(sList, iCharPos + LENGTH(sDelimiter));
				RETURN SUBSTR(sTemp, 1, iCharPos - 1);
			END IF;
		END getElement;


  /***********************************************************/
  /* Insert or Delete a record from the R and D Schedule table
  /* - and send to Atlas
  /***********************************************************/
  FUNCTION INSERT_RD_SCHED(i_matl IN VARCHAR2,
								i_qty IN NUMBER,
								i_plant_code IN VARCHAR2,
								i_status VARCHAR2
								) RETURN NUMBER IS

	/*-*/
	/*  i_status  -		I 			Insert a record in RD_SCHED table
	/*	 			    D			Delete the record from the RD_SCHED table
	/*					S			Test used to send the Main Schedule into Atlas

	/* i_matl for Insert this value is the material code
	/*        for Delete it will be a list of Process Orders to delete
    /*-*/

      CURSOR csr_matl IS
		SELECT COUNT(*) FROM rd_sched
		 WHERE matl_code = i_matl
		   AND plant_code = i_plant_code;

		CURSOR csr_uom IS
	    SELECT DECODE(dclrd_uom,'KGM', 'KG', dclrd_uom) uom
		  FROM material
		 WHERE material_code = i_matl;

	    var_work        NUMBER;
		var_proc_orders VARCHAR2(2000);
		var_work1       VARCHAR2(100);
		var_uom         VARCHAR2(20);

  BEGIN

      var_proc_orders := i_matl;

      IF i_status = 'I' THEN -- Insert
	      var_uom := 'EA';

	      OPEN csr_uom;
		  FETCH csr_uom INTO var_uom;
		      IF csr_uom%NOTFOUND THEN
			      var_uom := 'EA'; -- default
			  END IF;
		  CLOSE csr_uom;

		     OPEN csr_matl ;
             FETCH csr_matl  INTO var_work;
				IF var_work = 0 THEN
				    INSERT INTO RD_SCHED
                           (matl_code,
                           plant_code,
                           qty,
                           uom,
                           start_datime,
                           end_datime)
			        VALUES (i_matl,
					        i_plant_code,
					        i_qty,
					        var_uom,
					        TO_DATE('28/12/2029 01:00:00','dd/mm/yyyy hh24:mi:ss'),
					        TO_DATE('28/12/2029 01:00:00','dd/mm/yyyy hh24:mi:ss'));
				  END IF;
           CLOSE csr_matl;

		   --COMMIT;

		   --Rd_Schedule_Send.EXECUTE(i_plant_code);

		ELSIF i_status = 'D' THEN -- delete

			  LOOP

              EXIT WHEN var_proc_orders IS NULL;

				  var_work1 := getElement(var_proc_orders,'|');

			     DELETE FROM RD_SCHED
			      WHERE matl_code = (SELECT LTRIM(matl_code,'0')
			                         FROM CNTL_REC
									WHERE LTRIM(proc_order,'0') = LTRIM(RTRIM(var_work1)));

				INSERT_RD_TECO_PENDING(LTRIM(RTRIM(var_work1)));

           END LOOP;

		END IF;

		COMMIT;

		--Rd_Schedule_Send.EXECUTE(i_plant_code);

		RETURN Re_Timing_Common.SUCCESS;

  EXCEPTION
      WHEN OTHERS THEN

			 RETURN  Re_Timing_Common.FAILURE;

  END INSERT_RD_SCHED;
  
  
  PROCEDURE PROCESS_OBS_BOMS(o_result     OUT NUMBER,
                            o_result_msg OUT VARCHAR2,
                            i_plant      IN  VARCHAR2,
                            i_bom        IN  VARCHAR2,  
                            i_first_time IN  VARCHAR2) 
  IS 
   
 
   
      /*-*/
      /* This cursor selects all BOMs belonging to the plant and inserts them into the table for later use.
      /*-*/
       CURSOR Matl 
       IS 
       SELECT ltrim(sap_material_code,'0') Material,
              bds_material_desc_en         Description,
              procurement_type             Proc_type,
              special_procurement_type     Sp_proc_type,
              plant_specific_status        Plant_status,
              (SELECT count(DISTINCT t1.BOM_ALTERNATIVE) Alt_count
                 FROM bds_bom_all t1
                WHERE t1.BOM_USAGE=1
                  AND t1.BOM_STATUS !='07'
                  AND t1.BOM_PLANT = t2.PLANT_CODE
                  AND t1.BOM_MATERIAL_CODE = LTRIM(t2.sap_material_code,' 0')
                  AND t2.PLANT_SPECIFIC_STATUS <>99) Alt_Count
         FROM bds_material_plant_mfanz t2
        WHERE plant_code     = I_PLANT
          AND procurement_type = 'E'
          AND nvl(special_procurement_type,'*') IN ('50','*')
        ORDER BY ltrim(sap_material_code,'0');
        
      /*-*/
      /*This cursor traverses the given FG to the bottom-most level possible and identifies the BOMs within the FG
      /*and updates the table accordingly. These are the only BOMs that we are interested in. 
      /*-*/
      CURSOR BOM 
      IS
      SELECT bom_material_code   matl_code,
             bom_alternative     Alt,
             item_material_code  sub_matl_code,
             lpad(' ',LEVEL,'>') Lvl 
        FROM bds_bom_all b
       WHERE bom_plant              = I_PLANT
       start WITH bom_material_code = I_BOM
     connect BY bom_material_code = PRIOR item_material_code;
      /*-*
      /* End of All declarations and procedure/function definitions
      /*-*/

  BEGIN

    /*-*/
    /*The Main Block starts from here...
    /*-*/
    l_where_msg := 'In Main PLSQL Block for  ' || I_BOM;
    O_RESULT    := RET_SUCCESS;
    O_RESULT_MSG := NULL;
    IF ( I_FIRST_TIME = 1 ) THEN
        BEGIN
            l_where_msg := 'Deleting from unique_bom_materials for this run';
            DELETE FROM unique_bom_materials;
        EXCEPTION
           WHEN OTHERS THEN
               l_where_msg := l_where_msg || ' Oracle error ' || SUBSTR(SQLERRM, 1, 512);
               RAISE APP_EXPN;
        END;
       
        FOR MatRec IN Matl
        LOOP
            BEGIN
                l_where_msg := 'Inserting into UNIQUE_BOM_MATERIALS for 1st Time';
                INSERT INTO unique_bom_materials(Material,Description,Proc_type,Sp_proc_type,Plant_status,Alt_count,Used_Flag)
                VALUES (MatRec.Material,
                       MatRec.Description,
                       MatRec.Proc_type,
                       MatRec.Sp_proc_type,
                       MatRec.Plant_status,
                       MatRec.Alt_Count,
                       '*');
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                     NULL;
                WHEN OTHERS THEN
                     l_where_msg := l_where_msg || ' Oracle error ' || SUBSTR(SQLERRM, 1, 512);
                     RAISE APP_EXPN;
                     EXIT;
            END;
        END LOOP;
        COMMIT;
    END IF;
    
    /*-*/
    /*This update is for the FG in question
    /*-*/
    l_where_msg := 'Updating UNIQUE_BOM_MATERIALS for ' || I_BOM;
    UPDATE UNIQUE_BOM_MATERIALS
       Set USED_FLAG = 'N'
     WHERE MATERIAL = I_BOM;
   
    /*-*/
    /* This update is for the sub boms within the FG in question
    /*-*/    
    FOR BomRec IN BOM
    LOOP
        BEGIN
            l_where_msg := 'Updating UNIQUE_BOM_MATERIALS for Child ' || BomRec.sub_matl_code || ' of Parent ' || I_BOM;
            UPDATE UNIQUE_BOM_MATERIALS
               Set USED_FLAG = 'N'
             WHERE MATERIAL = BomRec.sub_matl_code;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
            WHEN OTHERS THEN
                l_where_msg := l_where_msg || ' Oracle error ' || SUBSTR(SQLERRM, 1, 512);
                RAISE APP_EXPN;
                EXIT;
        END;
    END LOOP;
    COMMIT; 
    
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          l_where_msg  := ' BOM ' || I_BOM || ' not found for plant ' || I_PLANT;
          O_RESULT     :=  RET_FAILURE;
          O_RESULT_MSG := 'OBS_BOM_REPORT.PROCESS_OBS_BOMS failed ' || CHR(13) || l_where_msg;
          ROLLBACK;
      WHEN APP_EXPN THEN
          O_RESULT     :=  RET_FAILURE;
          O_RESULT_MSG := 'OBS_BOM_REPORT.PROCESS_OBS_BOMS failed ' || CHR(13) || l_where_msg;
          ROLLBACK;
      WHEN OTHERS THEN
          o_result  := RET_FAILURE;
          IF ( l_where_msg IS NULL ) THEN
              o_result_msg := 'OBS_BOM_REPORT.PROCESS_OBS_BOMS failed ' || CHR(13) || ' Oracle error ' || SUBSTR(SQLERRM, 1, 512);
          ELSE
              o_result_msg := 'OBS_BOM_REPORT.PROCESS_OBS_BOMS failed ' || CHR(13) || l_where_msg;
          END IF;
          ROLLBACK;
  END PROCESS_OBS_BOMS;


FUNCTION OBS_BOM_ITERATION(I_PLANT      IN  VARCHAR2) RETURN NUMBER                            
IS

    l_counter NUMBER := 0;
    CURSOR C1 IS 
    SELECT DISTINCT t1.ITEM_MATERIAL_CODE
      FROM bds_bom_all t1, 
           bds_material_plant_mfanz t2
     WHERE item_material_code IN (SELECT material 
                                    FROM unique_bom_materials c
                                   WHERE c.used_flag = 'N' )
       AND BOM_PLANT= I_PLANT
       AND BOM_USAGE=1
       AND BOM_STATUS='01'
       AND BOM_MATERIAL_CODE NOT IN (SELECT material 
                                       FROM unique_bom_materials d
                                      WHERE d.used_flag = 'N' )
       AND BOM_PLANT = t2.PLANT_CODE
       AND t1.BOM_MATERIAL_CODE = LTRIM(t2.sap_material_code,' 0')
       AND t2.PLANT_SPECIFIC_STATUS <>99;

BEGIN
  
    FOR C1Rec IN C1
    LOOP
       l_counter := nvl(l_counter,0) + 1;
       --
       --This update is to change the BOMs to reflect that they are needed(and cannot be made obsolete)
       --
       BEGIN
           UPDATE unique_bom_materials
              set used_flag = 'Y'
            WHERE  material = C1Rec.Item_Material_Code;
       EXCEPTION
           WHEN OTHERS THEN
               RAISE;
       END;
    END LOOP;
    IF ( nvl(l_counter,0) > 0 ) THEN
        COMMIT;
    END IF;
--  
    RETURN nvl(l_counter,0);
--  
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -1;
END OBS_BOM_ITERATION;


PROCEDURE OBS_BOM_RECORDS(o_result     OUT NUMBER, 
                          o_result_msg OUT VARCHAR2,
                          cur_OUT      IN OUT RETURN_REF_CURSOR) 
IS

BEGIN
    O_RESULT     := RET_SUCCESS;
    O_RESULT_MSG := NULL;
    l_where_msg  := 'Opening Cursor CUR_OUT for Selecting from UNIQUE_BOM_MATERIALS table...';
 
    OPEN CUR_OUT FOR
    SELECT * 
      FROM UNIQUE_BOM_MATERIALS
     WHERE  USED_FLAG IN ( 'N' , 'Y' )
     ORDER BY DECODE(USED_FLAG,'N',1,2);
     
EXCEPTION
    WHEN OTHERS THEN
        O_RESULT     :=  RET_FAILURE;
        O_RESULT_MSG := 'OBS_BOM_REPORT.OBS_BOM_RECORDS failed ' || CHR(13) || l_where_msg;
        ROLLBACK;
        /*-*/
        /* this creates a dummy cursor to prevent an oracle error occuring prior to sending the
        /* result variables back to the calling application
        /*-*/
        OPEN cur_OUT FOR 
        SELECT * FROM dual WHERE 1=0;
END OBS_BOM_RECORDS;



  END Re_Timing;
/

CREATE OR REPLACE PUBLIC SYNONYM RE_TIMING FOR MANU_APP.RE_TIMING;


GRANT EXECUTE ON MANU_APP.RE_TIMING TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RE_TIMING TO PUBLIC;

