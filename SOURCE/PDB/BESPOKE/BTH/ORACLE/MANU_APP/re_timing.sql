CREATE OR REPLACE PACKAGE MANU_APP.Re_Timing
IS
/******************************************************************************
   NAME:       Re  timing tool functions
   PURPOSE:    This package will provide the interface between the windows application
               Re-timming tool and Oracle
               All reference data for the re-timing toool display will be proviided
               plus the current view of all process orders and schedule.

   REVISIONS:
   Ver        Date         Author             Description
   ---------  ----------   ---------------    ------------------------------------
   1.0        21/11/2005   Jeff Phillipson    1. Created this package.
   2.0        01/02/2008   Jeff Phillipson    Validation upgrade changes made
   3.0        27-May-2008  Jeff Phillipson    Obsolete BOM Report procedures added to end of package
   3.1        28-Aug-2008  Daniel Owen        Added DISTINCT to query in retrieve_recpe_waiver
******************************************************************************/

   /***********************************************************/
/* MRP_PERIOD will check if the current time is in the extended
/* time frame or before the extended time frame
/* Returns 0 for before the extended period ie before the time of
/*           18:50 starting from midnight
/*         1 for after the epriod ie 18:50 to midnight
/***********************************************************/
   FUNCTION mrp_period
      RETURN NUMBER;

/******************************************************************/
/* Removes proc_orders from rd_teco_pending onced they are TECO'd */
/******************************************************************/
   FUNCTION clean_rd_teco_pending
      RETURN NUMBER;

/***************************************************************************/
/* Inserts a Proc_Order (leading zeros trimmed) into RD_TECO_PENDING table */
/***************************************************************************/
   PROCEDURE insert_rd_teco_pending (proc_order IN VARCHAR2);

/***********************************************************/
/* RETRIEVE_DEMANDS will retrieve  parent Proc Orders
/* ibased on the Proc Order received.
/* This query has to consider _
/* Unasigned Proc Orders start after the start date of the input Proc Order
/* Teco PO's if they start after the start of the inputed PO.
/***********************************************************/
   PROCEDURE retrieve_demands (
      i_proc_order         IN       VARCHAR2,
      o_result             OUT      NUMBER,
      o_result_msg         OUT      VARCHAR2,
      o_retrieve_demands   OUT      Re_Timing_Common.return_ref_cursor
   );

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
	

/***********************************************************/
/* RETRIEVE_LINES will retrieve the data for the right hand Level Tabs
/* in the re timing tool plus all Production Lines associated with the level
/***********************************************************/
   PROCEDURE retrieve_lines (
      i_plant_code       IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_result_msg       OUT      VARCHAR2,
      o_retrieve_lines   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* RETRIEVE_SHIFTS will retrieve the shift data for the specified plasnt code
/***********************************************************/
   PROCEDURE retrieve_shifts (
      i_plant_code        IN       VARCHAR2,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_shifts   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* IN Sync will determine if the Local Data is in sync
/* with the Atlas data
/* if YES - 0 is returned
/* if Different - 1 is returned
/* RULES -
/* 1     Only Proc Orders that have a Line assigned will be compared
/* 2     Check if Cntl Rec Id is different
/*       - if they are the same they are not in sync
/* 3     Run_Start_Datime will be identical if in sync
/* 4     Run_End_Datime will be identical if in sync
/* 5     Qty will be identical if in sync
/***********************************************************/
   FUNCTION in_sync (i_plant_code IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION check_sync (i_proc_order IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* User_Privs will determine if the current user
/* for the RE-TIMING TOOL
/* has access - NO acess to this application - returns 0
/*  read only access - return 1
/*  Update access - return 2
/***********************************************************/
   FUNCTION User_Privs (i_userid IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/*  Close_Edit will remove the Client variable from the Session Table
/* for the RE-TIMING TOOL
/*  0 for Success
/*  1 for failure
/***********************************************************/
   FUNCTION pulse (i_userid IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* User_Role will determine if the current user
/* for the Factory Recipe Report
/* has access - NO acess to this application - returns 0
/*  general user access - PR_USER - return 1
/*  R&D access PR_FDR_ISSR - return 2
/*   ADMIN - PR_ADMIN - return 3
/***********************************************************/
   FUNCTION User_Role (i_userid IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* User_Role_Demands will determine if the current user
/* for the Factory Recipe Report
/* has access - to print the process order demands
/* Nn - returns 0
/* Yes - PR_PLNR - return 1
/*  Yes - PR_ADMIN - return 1
/***********************************************************/
   FUNCTION user_role_demands (i_userid IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* retrieve all process orders demands ie parent child process orders
/***********************************************************/
   PROCEDURE retrieve_parent_demands (
      i_plant_code                IN       VARCHAR2,
      o_result                    OUT      NUMBER,
      o_result_msg                OUT      VARCHAR2,
      o_retrieve_parent_demands   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
 /* get user will return the current user id of the Assoc
 /* who is currently on a session with edit rights
 /* this will identify the Recipe Utility/SSC who is managing
 /* the Re-Timing tool updates
/***********************************************************/
   FUNCTION get_user
      RETURN VARCHAR2;

/***********************************************************/
/* Get the Plant description by passing in the plant code
/***********************************************************/
   FUNCTION get_plant_desc (i_plant_code IN VARCHAR2)
      RETURN VARCHAR2;

/***********************************************************/
/* retrieve all process orders in the active mode
/***********************************************************/
   PROCEDURE retrieve_proc_orders (
      i_plant_code       IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_result_msg       OUT      VARCHAR2,
      o_retrieve_procs   OUT      Re_Timing_Common.return_ref_cursor
   );

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

/***********************************************************/
/* retrieve all process orders in the active mode
/***********************************************************/
   PROCEDURE retrieve_rd_proc_orders (
      i_plant_code       IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_result_msg       OUT      VARCHAR2,
      o_retrieve_procs   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* Insert a record into the local copy of the cntl_rec table
/* - goes into cntl_rec_lcl
/***********************************************************/
   FUNCTION insert_proc_order (
      i_proc_order     IN   VARCHAR2,
      i_cntl_rec_id    IN   NUMBER,
      i_qty            IN   NUMBER,
      i_start_datime   IN   DATE,
      i_end_datime     IN   DATE,
      i_line_code      IN   NUMBER,
      i_actual         IN   NUMBER,
      i_level_code          NUMBER,
      i_matl_code           VARCHAR2,
      i_replan_rate         NUMBER,
      i_merge               VARCHAR2
   )
      RETURN NUMBER;

/***********************************************************/
/* retrieve all resource - work centre links in the active mode
/***********************************************************/
   PROCEDURE retrieve_resources (
      i_plant_code        IN       VARCHAR2,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_resrce   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* retrieve all resource - work centre links in the active mode
/***********************************************************/
   PROCEDURE retrieve_alloc_resources (
      i_plant_code        IN       VARCHAR2,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_resrce   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* Insert a record into the local copy of the resource table
/* - goes into cntl_rec_resrce_lcl
/***********************************************************/
   FUNCTION insert_resource (
      i_proc_order    IN   VARCHAR2,
      i_resrce_code   IN   VARCHAR2,
      i_work_ctr      IN   VARCHAR2,
      i_opertn        IN   VARCHAR2
   )
      RETURN NUMBER;

/***********************************************************/
/* retrieve schedule
/***********************************************************/
   PROCEDURE retrieve_sched (
      i_plant_code       IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_result_msg       OUT      VARCHAR2,
      o_retrieve_sched   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* get bthe actuals value from the Pallet Tagging app for
/* a specified proc_order
/***********************************************************/
   FUNCTION get_actual (i_proc_order IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* get the FIRM end date from oracle
/***********************************************************/
   FUNCTION get_firm (i_plant_code IN VARCHAR2)
      RETURN VARCHAR2;

/***********************************************************/
/* get the FIRM start date from oracle
/***********************************************************/
   FUNCTION get_firm_start (i_plant_code IN VARCHAR2)
      RETURN VARCHAR2;

/***********************************************************/
/* RECIPE REPORT
/* the following procedures are used to retrieve recipe data
/* from the data base
/* they are used to get data for the Factory Recipe Report (FRR)
/***********************************************************/

   /***********************************************************/
/* retrieve the recipe header information for the recipe report
/***********************************************************/
   PROCEDURE retrieve_recipe_hdr (
      i_proc_order        IN       VARCHAR2,
      i_recipe_type       IN       NUMBER,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_recipe   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* retrieve the recipe detail information for the recipe report
/***********************************************************/
   PROCEDURE retrieve_recipe_dtl (
      i_proc_order        IN       VARCHAR2,
      i_recipe_type       IN       NUMBER,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_recipe   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* retrieve the recipe footer information for the recipe report
/***********************************************************/
   PROCEDURE retrieve_recipe_ftr (
      i_proc_order        IN       VARCHAR2,
      i_recipe_type       IN       NUMBER,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_recipe   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* retrieve any waivers that are active for the selected proic order material
/***********************************************************/
   PROCEDURE retrieve_recipe_waiver (
      i_proc_order        IN       VARCHAR2,
      i_recipe_type       IN       NUMBER,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_recipe   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* RETRIEVE_Plants will retrieve the plants available in this database
/* this is used in the factory recipe report
/***********************************************************/
   PROCEDURE retrieve_plants (
      i_plant_code        IN       VARCHAR2,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_plants   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* RETRIEVE_Actuals will retrieve the actuals available in this database
/* this is used in the RTT
/***********************************************************/
   PROCEDURE retrieve_actuals (
      i_plant_code         IN       VARCHAR2,
      o_result             OUT      NUMBER,
      o_result_msg         OUT      VARCHAR2,
      o_retrieve_actuals   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* RETRIEVE_Status will retrieve the status of all available process orders
/* in the database
/* this is used in the RTT
/* Return values
/* 0      Local data is in sync with Atlas
/* 1      Data saved in the local databse
/* 2      Local data sent to Atlas
/* 3      Time limit exceeded since data was sent to Atlas (not implimented yet
/*        - needs 2 extra data fields
/*        in CNTL_REC_LCL table containing date saved and date sent to atlas
/***********************************************************/
   PROCEDURE retrieve_status (
      i_plant_code        IN       VARCHAR2,
      o_result            OUT      NUMBER,
      o_result_msg        OUT      VARCHAR2,
      o_retrieve_status   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* RETRIEVE_Packing material specific data from
/* matl_plt views
/* this is used in the factory recipe report and the production report
/***********************************************************/
   PROCEDURE retrieve_pack_info (
      i_plant_code      IN       VARCHAR2,
      o_result          OUT      NUMBER,
      o_result_msg      OUT      VARCHAR2,
      o_retrieve_pack   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* Start of update of process orders and resources
/***********************************************************/
   FUNCTION start_update (i_plant_code IN VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* End of update of process orders and resources
/* send to Atlas = 1
/* send = 0 do not send
/***********************************************************/
   FUNCTION end_update (i_plant_code IN VARCHAR2, i_send IN NUMBER)
      RETURN NUMBER;

/***********************************************************/
/* Set by retiming Tool to indicate Atlas is on or off
/***********************************************************/
   FUNCTION atlas_on (i_status IN NUMBER)
      RETURN NUMBER;

/***********************************************************/
 /* Get by retiming Tool if Atlas is on or off
 /***********************************************************/
   FUNCTION is_atlas_on (i_plant_code VARCHAR2)
      RETURN NUMBER;

/***********************************************************/
/* RETRIEVE_Materials which can have a process order created
/* this is used in the factory recipe report - R&D section
/***********************************************************/
   PROCEDURE retrieve_matls (
      i_plant_code       IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_result_msg       OUT      VARCHAR2,
      o_retrieve_matls   OUT      Re_Timing_Common.return_ref_cursor
   );

/***********************************************************/
/* Insert or Delete a record from the R and D Schedule table
/* - and send to Atlas
/***********************************************************/
   FUNCTION insert_rd_sched (
      i_matl         IN   VARCHAR2,
      i_qty          IN   NUMBER,
      i_plant_code   IN   VARCHAR2,
      i_status            VARCHAR2
   )
      RETURN NUMBER;
/*-*/
/*  i_status  -      I        Insert a record in RD_SCHED table
/*                   D        Delete the record from the RD_SCHED table
/*                   S        Test used to send the Main Schedule into Atlas
/*-*/


/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : MANU_APP
 Package : OBS_BOM_REPORT  moved into RE_TIMING package 
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
   Ver        Date         Author            Description
   ---------  ----------   ---------------   ------------------------------------
   1.0        21/11/2005   Jeff Phillipson   1. Created this package.
   3.0        27-May-2008  Jeff Phillipson   Obsolete BOM Report procedures added to end of package 
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
  /* MRP_PERIOD will check if the current time is in the extended
  /* time frame or before the extended time frame
  /* Returns 0 for before the extended period ie before the time of
  /*           18:50 starting from midnight
  /*         1 for after the epriod ie 18:50 to midnight
  /***********************************************************/
  FUNCTION MRP_PERIOD RETURN NUMBER
  IS

  	  var_mrp NUMBER;

  BEGIN
      /*-*/
	  /* the cursor will return data from the last record
	  /* entered into the table - RTT_WNDW_TIME
	  /* RESULT 0 BEFORE mrp WINDOW
	  /* 		1 AFTER MRP WINDOW
	  /*-*/
      SELECT CASE WHEN TO_DATE(TO_CHAR(TRUNC(SYSDATE),'dd-mon-yyyy') || ' ' || decode(to_char(sysdate,'DY'),'FRI', fri_wndw_time,wndw_time),'dd-Mon-yyyy HH24:MI') + mrp_offset/1440 - SYSDATE  > 0 THEN 0
             ELSE 1 END mrp_stat
	         /* 0 is before MRP window  */
	         /* 1 is after MRP window   */
	    INTO var_mrp
        FROM RTT_Wndw_time WHERE Wndw_Date IN
             (SELECT MAX(wndw_date) FROM RTT_Wndw_time WHERE Wndw_date <= SYSDATE);

      RETURN var_mrp;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
       RETURN 0;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
	   RETURN 0;
  END;

  /******************************************************************/
  /* Removes TECO'd proc_orders from rd_teco_pending                */
  /******************************************************************/
  FUNCTION CLEAN_RD_TECO_PENDING RETURN NUMBER IS
  BEGIN
    DELETE FROM rd_teco_pending
    WHERE proc_order IN (SELECT t02.proc_order
    FROM cntl_rec t01, rd_teco_pending t02
    WHERE LTRIM(t01.proc_order, '0') = t02.proc_order
     AND t01.teco_stat = 'YES');
    
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
    INSERT INTO rd_teco_pending
	       (proc_order)
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
  /* RETRIEVE_DEMANDS will retrieve  parent Proc Orders
  /* ibased on the Proc Order received.
  /* This query has to consider _
  /* Unasigned Proc Orders start after the start date of the input Proc Order
  /* Teco PO's if they start after the start of the inputed PO.
  /***********************************************************/
  PROCEDURE RETRIEVE_DEMANDS(i_proc_order IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_demands OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
  BEGIN

	  o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	  OPEN o_retrieve_demands FOR

		/*-*/
       /*  get all which start after the select proc order start date
		/* teco'd POs are also sent
		/* nothing is sent if the start date is outside the Firm datime
		/*-*/

		SELECT LTRIM(t01.proc_order,'0') proc_order,
		             po_qty,
					 SUM(DECODE(pan_size_flag, 'Y', pan_size * (DECODE(pan_qty, NULL, 2, pan_qty) -1) + (last_pan_size), t02.QTY)) demand_qty,
				 	 teco_stat,
				 	 ROUND(RUN_START,'mi') run_start_datime,
		 	 	 	 ROUND(RUN_end,'mi') run_end_datime,
                 	 DECODE(t01.LINE_CODE, NULL, '-1', t01.Line_code) line_code,
				 	 LTRIM(t01.matl_code,'0') matl_code,
		 	 	 	 t01.matl_desc,
				 	 t03.start_datime,
					-- t04.net_wght,
					 po_qty * t04.net_wght po_qty_in_kg
          FROM (SELECT LTRIM(t21.proc_order,'0') proc_order,
			 		               DECODE(t22.qty_lcl,NULL,t21.qty,t22.qty_lcl) po_qty,
								   teco_stat,
								   DECODE(run_start_datime_lcl, NULL, run_start_datime, run_start_datime_lcl) run_start,
								   DECODE(run_end_datime_lcl, NULL, run_end_datime, run_end_datime_lcl) run_end,
								   DECODE(t22.LINE_CODE, NULL, '-1',t22.Line_code) line_code,
								   LTRIM(t21.matl_code,'0') matl_code,
		 	 	    			   t21.matl_text matl_desc, plant
		                FROM cntl_rec t21, cntl_rec_lcl t22
		              WHERE LTRIM(t21.PROC_ORDER,'0')  = t22.PROC_ORDER(+)   ) t01,
		             cntl_rec_bom t02,
				    (SELECT LTRIM(t11.matl_code,'0') matl_code,
				                  DECODE(run_start_datime_lcl, NULL, run_start_datime,run_start_datime_lcl) start_datime
		               FROM cntl_rec t11, cntl_rec_lcl t12
		             WHERE LTRIM(t11.PROC_ORDER,'0') = t12.PROC_ORDER(+)
				          AND LTRIM(t11.proc_order,'0') =LTRIM( i_proc_order,'0')  ) t03,
					matl t04
		WHERE t01.PROC_ORDER = LTRIM(t02.proc_order,'0')
		     AND LTRIM(t02.matl_code,'0') = t03.matl_code
			 AND LTRIM(t01.matl_code,'0') = t04.matl_code(+)
			 AND t01.plant = t04.plant(+)
			 AND t01.run_start BETWEEN t03.start_datime AND TO_DATE(Re_Timing.GET_FIRM(t01.plant),'dd/mm/yyyy hh24:mi')
		GROUP BY t01.proc_order, po_qty,
				    teco_stat,
				 	RUN_START,
		 	 	 	RUN_end,
                 	DECODE(t01.LINE_CODE, NULL, '-1', t01.Line_code),
				 	t01.matl_code,
		 	 	 	t01.matl_desc,
				 	t03.start_datime,
				    t04.net_wght
	   ORDER BY 5;

  END;

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
         LTRIM (t01.matl_code, '0') child_matl_code,
         t01.matl_text child_matl_text,
         ROUND(t01.qty, 2) || LOWER(t01.UOM) child_to_be_made,
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
         LTRIM (t04.matl_code, '0') prnt_matl_code,
         t04.matl_text prnt_matl_text,
         t04.qty || LOWER(t04.UOM) prnt_qty,
         TO_CHAR (TRUNC (t04.run_start_datime)) prnt_start_date,
         TO_CHAR (t04.run_start_datime, 'hh24:mi') prnt_start_datime
      FROM cntl_rec_vw t01,
         matl t02,
         cntl_rec_bom t03,
         cntl_rec_vw t04,
         (SELECT   t05.matl_code,
                   MIN (run_start_datime) - 2 / 24 suggested_date
              FROM cntl_rec_bom t05, cntl_rec_vw t06
             WHERE t05.proc_order = t06.proc_order
               -- AND LTRIM(t05.MATL_CODE,'0') = '1034648'
               AND teco_stat = 'NO'
               AND t06.run_start_datime BETWEEN TRUNC (SYSDATE) - 1
                                            AND TRUNC (SYSDATE) + 2
          GROUP BY t05.matl_code) t07
      WHERE LTRIM (t01.matl_code, '0') = t02.matl_code
        AND t01.matl_code = t03.matl_code
     	AND t03.proc_order = t04.proc_order
     	AND t01.plant = t02.plant
     	AND t01.plant = t03.plant
     	AND t01.matl_code = t07.matl_code
    	AND t01.run_start_datime BETWEEN TRUNC (SYSDATE) + 1 AND   TRUNC (SYSDATE) + 2
     	AND t01.plant = i_plant_code
     	AND t01.teco_stat = 'NO'
     	AND t02.matl_type = 'ROH'
     	AND t04.teco_stat = 'NO'
     	AND t04.run_start_datime > TRUNC (SYSDATE)
     	AND t04.run_start_datime < TRUNC (SYSDATE) + 2
      ORDER BY t01.run_start_datime, t01.proc_order, t04.run_start_datime;

 EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_PROC_ORDER_CHAIN procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);		  
   
  
  END RETRIEVE_PROC_ORDER_CHAIN;	
  

  /***********************************************************/
  /* RETRIEVE_LINES will retrieve the data for the right hand Level Tabs
  /* in the re timing tool plus all Production Lines associated with the level
  /***********************************************************/
  PROCEDURE RETRIEVE_LINES(i_plant_code IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_lines OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN

      o_result  := Re_Timing_Common.SUCCESS;
		o_result_msg := '';

		  OPEN o_retrieve_lines FOR
      SELECT rl.LEVEL_CODE,
		       rl.LEVEL_DESC,
		 		 rf.LINE_CODE,
       		 rf.LINE_DESC,
				 DECODE(prnt_line_code,NULL,'-1',prnt_line_code) prnt_line_code
  	     FROM REF_LINE rf, REF_LEVEL rl
       WHERE rf.LEVEL_CODE(+) = rl.LEVEL_CODE
         AND rl.PLANT_CODE = UPPER(trim(i_plant_code))
			ORDER BY 1,3;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE LINES procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);


  END RETRIEVE_LINES;



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

       OPEN o_retrieve_shifts FOR
	  SELECT MOD(TO_NUMBER(TO_CHAR(start_datime,'D')),7) ID,
		      INITCAP(DECODE(trim(UPPER(shift_type_name)),'AFTERNOON 8HR', 'AFTN 8hr', 'AFTERNOON','AFTN',trim(shift_type_name))) shift_type_name,
		      SUBSTR(shift_type_name,1,1) shift_type_short_name,
		      start_datime
       FROM prodn_shift pt, shift_type st
      WHERE trim(plant_code) = i_plant_code
        AND start_datime > TRUNC(SYSDATE) - 1
        AND start_datime < TRUNC(SYSDATE) + 9
        AND st.SHIFT_TYPE_CODE = pt.SHIFT_TYPE_CODE
		AND st.SHIFT_TYPE_CODE NOT IN ('200015','200016','200017')
      ORDER BY 4;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Shifts procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);

  END RETRIEVE_SHIFTS;


  /***********************************************************/
  /* Check Sync will determine if the Local Data is in sync
  /* with the Atlas data
  /* if YES - 0 is returned
  /* if Different - 1 is returned
  /* RULES -
  /* 1	  Only Proc Orders that have a Line assigned will be compared
  /* 2	  Check if Cntl Rec Id is different
  /* 		  - if they are the same they are not in sync
  /* 3	  Run_Start_Datime will be identical if in sync
  /* 4	  Run_End_Datime will be identical if in sync
  /* 5	  Qty will be identical if in sync
  /***********************************************************/

   FUNCTION CHECK_SYNC(i_proc_order IN VARCHAR2) RETURN NUMBER IS

	   var_work NUMBER;

		CURSOR cur_sync IS
		SELECT run_start_datime,
		       run_start_datime_lcl,
				 run_end_datime,
				 run_end_datime_lcl,
				 ROUND(qty) qty,
				 ROUND(qty_lcl) qty_lcl,
				 merge_flag
		  FROM CNTL_REC t01, CNTL_REC_LCL t02
		 WHERE LTRIM(T01.PROC_ORDER,'0') = LTRIM(T02.PROC_ORDER(+),'0')
		 AND LTRIM(T02.proc_order,'0') = i_proc_order;

		rcd_sync cur_sync%ROWTYPE;

  BEGIN

     SELECT COUNT(*) INTO var_work
		 FROM CNTL_REC_LCL
		WHERE PROC_ORDER = LTRIM(i_proc_order,'0');

	  IF var_work > 0 THEN

		   OPEN cur_sync;
         FETCH cur_sync INTO rcd_sync;
             IF NOT cur_sync%NOTFOUND THEN
		           IF ((rcd_sync.merge_flag IS NULL OR rcd_sync.merge_flag <> 'M') OR (rcd_sync.merge_flag = 'M' AND rcd_sync.qty = rcd_sync.qty_lcl))
			           AND ABS(rcd_sync.run_start_datime - rcd_sync.run_start_datime_lcl) <= 2/1440
						  AND ABS(rcd_sync.run_end_datime - rcd_sync.run_end_datime_lcl) <= 2/1440 THEN
			 	        var_work := Re_Timing_Common.ISTRUE;

			        ELSE
			           var_work := Re_Timing_Common.isfalse;

			        END IF;
				  END IF;
         CLOSE cur_sync;

		   RETURN var_work;
	  ELSE

	      RETURN Re_Timing_Common.ISTRUE;
	  END IF;


  EXCEPTION
      WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('failed');
 			    RETURN Re_Timing_Common.ISTRUE;
  END CHECK_SYNC;



  /***********************************************************/
  /* IN Sync will determine if the Local Data is in sync
  /* with the Atlas data
  /* if YES - 0 is returned
  /* if Different - 1 is returned
  /* RULES -
  /* 1	  Only Proc Orders that have a Line assigned will be compared
  /* 2	  Check if Cntl Rec Id is different
  /* 		  - if they are the same they are not in sync
  /* 3	  Run_Start_Datime will be identical if in sync
  /* 4	  Run_End_Datime will be identical if in sync
  /* 5	  Qty will be identical if in sync
  /***********************************************************/
  FUNCTION IN_SYNC(i_plant_code IN VARCHAR2) RETURN NUMBER IS

     var_work VARCHAR2(20);
	  var_result NUMBER DEFAULT Re_Timing_Common.ISTRUE;

	  /*-*/
	  /* Cursor definitions
	  /*-*/
	  CURSOR cur_proc_order IS
	  SELECT *
	    FROM CNTL_REC
	   WHERE teco_stat = 'NO';

	  rcd_proc_order cur_proc_order%ROWTYPE;

  BEGIN

	  -- do all valid proc orders
	  OPEN cur_proc_order;
         LOOP
            FETCH cur_proc_order INTO rcd_proc_order;
            EXIT WHEN cur_proc_order%NOTFOUND;
		      var_result := CHECK_SYNC(trim(rcd_proc_order.proc_order));
		      IF var_result = 1 THEN
		          EXIT; -- get out now because it is out of sync
		      END IF;
         END LOOP;
     CLOSE cur_proc_order;

  	  -- 1 = false
	  -- 0 = true
  	  RETURN var_result;

  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN Re_Timing_Common.ISFALSE;
  END IN_SYNC;


  /***********************************************************/
  /* User_Privs will determine if the current user
  /*  has access NO to this application - return 0
  /*  read only access - return 1
  /*  Update access - return 2
  /***********************************************************/
  FUNCTION User_Privs(i_userid IN VARCHAR2) RETURN NUMBER IS

  var_work VARCHAR2(32);
  var_return NUMBER;
  var_userid VARCHAR2(20) DEFAULT '';

  CURSOR cur_role IS
      SELECT trim(UPPER(granted_role)) FROM DBA_ROLE_PRIVS
		 WHERE grantee = UPPER(i_userid)
         AND granted_role IN ('PR_ADMIN','PR_USER')
			ORDER BY 1;

  BEGIN
      var_return := Re_Timing_Common.NOACCESS;
		OPEN cur_role;
      LOOP
         FETCH cur_role INTO var_work;
         EXIT WHEN cur_role%NOTFOUND;
			   var_work := trim(UPPER(var_work));
				IF var_work = 'PR_USER' THEN
			      var_return := Re_Timing_Common.READONLY;
					EXIT;
			   END IF;

		      IF var_work = 'PR_ADMIN' THEN
			      var_return := Re_Timing_Common.EDIT;

					IF Get_Edit_Status = FALSE THEN
					    var_return := Re_Timing_Common.READONLY;
					END IF;

			  	   EXIT;
			   END IF;

      END LOOP;
      CLOSE cur_role;

		RETURN var_return;

  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN Re_Timing_Common.NOACCESS;
  END User_Privs;


  /***********************************************************/
  /*  Pulse will update the Client_Info field from the Session Table
  /* for the RE-TIMING TOOL
  /* This procedure calls the PULSE_STATUS function to nachieve this.
  /*  return 0 for Success
  /*  1 for failure
  /***********************************************************/
  FUNCTION PULSE(i_userid IN VARCHAR2)  RETURN NUMBER IS

  BEGIN


		RETURN Pulse_Status(i_userid);


  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN Re_Timing_Common.FAILURE;
  END  PULSE;



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
          LTRIM (t01.matl_code, '0') prnt_matl_code,
       	  t01.matl_text prnt_matl_text, t01.qty prnt_qty,
       	  TO_CHAR (ROUND (t01.run_start_datime, 'mi'),'Dy dd Mon hh24:mi') prnt_run_start_datime,
       	  DECODE (t03.pan_size_flag,'N', t03.qty, NVL (t03.pan_qty, 1) * t03.pan_size) child_demand,
       	  LTRIM (t05.proc_order, '0') child_proc_order,
       	  LTRIM (t03.matl_code, '0') child_matl_code,
       	  t05.matl_text child_matl_text, t05.qty child_to_be_made,
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
	 FROM cntl_rec_vw t01, matl t02, cntl_rec_bom t03, matl t04, cntl_rec_vw t05
    WHERE LTRIM (t01.matl_code, '0') = t02.matl_code
      AND t01.proc_order = t03.proc_order(+)
      AND t01.plant = t02.plant                  -- plant code has to be the same
      AND LTRIM (t03.matl_code, '0') = t04.matl_code(+)
      AND t04.prcrmnt_type = 'E'
      -- only child materials that can have a process order raised
      AND t04.spcl_prcrmnt_type IS NULL
      -- only child materials that can have a process order raised
     AND t01.teco_stat = 'NO'
   	 AND t02.trdd_unit = 'X'
   	 AND TRUNC (t01.run_start_datime) = TRUNC (SYSDATE)
     -- all process orders have to be for today
     --AND LTRIM(t01.proc_order,'0') = '1071801'
     AND t03.matl_code = t05.matl_code
     AND t05.run_start_datime < SYSDATE + 1
   	 AND t05.teco_stat = 'NO'
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
  /* User_Role will determine if the current user
  /* has access - NO acess to this application - returns 0
  /*  general user access - PR_USER - return 1
  /*  R&D access PR_FDR_ISSR - return 2
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
  /* get user will return the current user id of the Assoc
  /* who is currently on a session with edit rights
  /* this will identify the Recipe Utility/SSC who is managing
  /* the Re-Timing tool updates
  /***********************************************************/
  FUNCTION GET_USER RETURN VARCHAR2 IS

  BEGIN

  		 RETURN Get_Edit_User;

  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN 'None found';

  END GET_USER;






  /***********************************************************/
  /* Get the Plant description by passing in the plant code
  /***********************************************************/
  FUNCTION GET_PLANT_DESC(i_plant_code IN VARCHAR2)  RETURN VARCHAR2 IS

  var_work VARCHAR2(200);

  BEGIN
  		 SELECT plant_name INTO var_work
		   FROM manu.REF_PLANT
		  WHERE plant = i_plant_code;

		RETURN var_work;

  EXCEPTION
      WHEN OTHERS THEN
  			 RETURN 'None found';
  END GET_PLANT_DESC;


  /***********************************************************/
  /* RETRIEVE_Plants will retrieve the actuals against all valid
  /*  process orders
  /***********************************************************/
  PROCEDURE RETRIEVE_ACTUALS(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_actuals OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

	   var_work VARCHAR2(100);
		var_work1 NUMBER;


  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

      OPEN o_retrieve_actuals FOR
		SELECT t01.proc_order,
             SUM(t01.qty) actual
        FROM pt.plt_hdr t01,
             cntl_rec_lcl t02,
			 cntl_rec_vw t03
       WHERE t01.PROC_ORDER = LTRIM(t02.PROC_ORDER,'0')
	     AND t02.PROC_ORDER = LTRIM(t03.PROC_ORDER,'0')
		 AND plant_code = i_plant_code
		 AND status = 'CREATE'
		 AND teco_stat = 'NO'
		 AND run_start_datime < TRUNC(SYSDATE) + 100
       GROUP BY t01.proc_order;

	EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Actuals' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_ACTUALS;


  /***********************************************************/
  /* RETRIEVE_Status will retrieve the status of all available process orders
  /* in the database
  /* this is used in the RTT
  /* Return values
  /* 0		Local data is in sync with Atlas
  /* 1		Data saved in the local databse
  /* 2		Local data sent to Atlas
  /* 3		Time limit exceeded since data was sent to Atlas (not implimented yet
  /*        - needs 2 extra data fields
  /*        in CNTL_REC_LCL table containing date saved and date sent to atlas
  /***********************************************************/
  PROCEDURE RETRIEVE_STATUS(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_status OUT Re_Timing_Common.RETURN_REF_CURSOR) IS


	  var_proc_order			  VARCHAR2(10);
	  var_sync					  NUMBER;

	  /*-*/
	  /* this cursor is used to check if process orders are now in sync
	  /* if they are the changed flag is set to null
	  /*-*/
	  CURSOR csr_sync
	  IS
	  SELECT t01.proc_order
	    FROM cntl_rec_lcl t01, cntl_rec_vw t02
       WHERE t01.proc_order = LTRIM(t02.proc_order,'0')
         AND t02.TECO_STAT = 'NO'
		 AND t02.PLANT = i_plant_code
		 AND changed IS NOT NULL  -- only get records that are still out of sync
		 AND (t02.RUN_START_DATIME > TRUNC(SYSDATE) - 4 OR t01.RUN_START_DATIME_LCL > TRUNC(SYSDATE) - 4)
         AND (t02.RUN_START_DATIME < TRUNC(SYSDATE) + 100 OR t01.RUN_START_DATIME_LCL < TRUNC(SYSDATE) + 100)
	   ORDER BY 1;


  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	  /*-*/
	  /* go through all process orders and check for sync status
	  /*-*/

	  OPEN csr_sync;
      LOOP
          FETCH csr_sync INTO var_proc_order;
          EXIT WHEN csr_sync%NOTFOUND;
		      var_sync := Re_Timing.check_sync(var_proc_order);
			  IF var_sync = 1 THEN
			      UPDATE cntl_rec_lcl SET changed = '', upd_datime = SYSDATE
				  WHERE proc_order = var_proc_order;
			  END IF;
      END LOOP;
      CLOSE csr_sync;
      COMMIT;

      OPEN o_retrieve_status FOR
	  SELECT t01.proc_order,
	         --DECODE(RE_TIMING.check_sync(t01.proc_order),0,DECODE(changed,'S',2,1),1,0) status
			 CASE WHEN SYSDATE - t01.upd_datime > 1/24 AND changed = 'S' THEN 3
                  WHEN changed = 'S' THEN 2
		          WHEN changed = 'Y' THEN 1
		          WHEN changed = '' OR changed IS NULL THEN 0 END status
	    FROM cntl_rec_lcl t01, cntl_rec_vw t02
       WHERE t01.proc_order = LTRIM(t02.proc_order,'0')
         AND t02.TECO_STAT = 'NO'
		 AND t02.PLANT = i_plant_code
		 AND (t02.RUN_START_DATIME > TRUNC(SYSDATE) - 4 OR t01.RUN_START_DATIME_LCL > TRUNC(SYSDATE) - 4)
         AND (t02.RUN_START_DATIME < TRUNC(SYSDATE) + 100 OR t01.RUN_START_DATIME_LCL < TRUNC(SYSDATE) + 100)
	   ORDER BY 1;


  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Status' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_STATUS;



  /***********************************************************/
  /* RETRIEVE_Packing material specific data from
  /* matl_plt views
  /* this is used in the factory recipe report and the production report
  /***********************************************************/
  PROCEDURE RETRIEVE_PACK_INFO(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_pack OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

		var_work VARCHAR2(100);
		var_work1 NUMBER;


  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
		o_result_msg := '';

      OPEN o_retrieve_pack FOR
		  SELECT LTRIM(proc_order,'0') proc_order,
               units_per_case,
		         100 mixes
          FROM cntl_rec_vw t01,
               matl_plt t02
         WHERE teco_stat = 'NO'
           AND LTRIM(t01.MATL_CODE,'0') = t02.MATL_CODE
           AND run_start_datime >= SYSDATE - 1
          -- AND run_start_datime <= TO_DATE(RE_TIMING.GET_FIRM('AU30'),'dd/mm/yyyy hh24:mi:ss')
			  AND t01.plant = i_plant_code
			ORDER BY 1;

	EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE package Info' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_PACK_INFO;


  /***********************************************************/
  /* retrieve all process orders in the active mode
  /***********************************************************/
  PROCEDURE RETRIEVE_PROC_ORDERS(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_procs OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

      var_work VARCHAR2(100);
		var_work1 NUMBER;


  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
		o_result_msg := '';

      OPEN o_retrieve_procs FOR
		/*-*/
  		/* get all records that are unplanned from the cntl_rec table
  		/*-*/
	  SELECT LTRIM(t01.proc_order,'0') proc_order,
  		      t01.cntl_rec_id,
		  		LTRIM(t01.matl_code,'0') matl_code,
		  		t01.matl_text matl_desc,
		  		t01.QTY,
		  		t01.UOM,
		  		ROUND(t01.RUN_START_DATIME,'MI') RUN_START_DATIME,
		  		ROUND(t01.RUN_END_DATIME,'MI') RUN_END_DATIME,
		  		'Y' sync,
		  		'-1' line,
		  		TO_CHAR(TO_NUMBER(DECODE(t05.brand_color,NULL,'00c040',t05.brand_color), 'xxxxxx')) Brand_color,
		  		CASE WHEN LENGTH(LTRIM(t01.matl_code,'0')) = 7 AND LENGTH(t07.level_code) > 2 THEN t07.level_code
				  	  WHEN LENGTH(LTRIM(t01.matl_code,'0')) = 7 AND t07.level_code IS NULL AND LENGTH(t08.level_code) > 2 THEN t08.level_code
		 			  WHEN LENGTH(LTRIM(t01.matl_code,'0')) = 7 AND t07.level_code IS NULL AND t08.level_code IS NULL THEN 5000
					  WHEN LENGTH(LTRIM(t01.matl_code,'0')) = 8 AND LENGTH(t06.level_code) > 2 THEN t06.level_code
				  	  WHEN LENGTH(LTRIM(t01.matl_code,'0')) = 8 AND t06.level_code IS NULL AND LENGTH(t08.level_code) > 2 THEN t08.level_code
		 			  WHEN LENGTH(LTRIM(t01.matl_code,'0')) = 8 AND t06.level_code IS NULL AND t08.level_code IS NULL THEN 5000
				END	 lvl,
				ROUND(qty / (DECODE((run_end_datime - run_start_datime) * 24 * 60,0,1,(run_end_datime - run_start_datime) * 24 * 60)),6) replan_rate
		 FROM cntl_rec_vw t01,
	         (SELECT sched_vrsn,
		              TO_CHAR(trad_unit_code) matl_code,
				        ROUND(start_datime,'mi') start_datime,
				        UPPER(trim(prodn_line_code)) prodn_line_code
		         FROM PPS_PLND_PRDN_DETL
	           WHERE sched_vrsn = (SELECT MAX(sched_vrsn) FROM  PPS_PLND_PRDN_DETL WHERE plant_code = i_plant_code)
				) t02,
		  		matl_brand_xref t04,
		  		REF_BRAND_COLOR t05,
		  		ref_line t06,
		  		ref_line t07,
		  		ref_level_matl_xref t08
      WHERE LTRIM(t01.matl_code,'0')   = t02.matl_code(+)
	     AND LTRIM(t01.matl_code,'0')   = t04.MATL_CODE(+)
	 	  AND t04.brand_flag_code        = t05.brand_flag_code(+)
	 	  AND t02.prodn_line_code        = UPPER(t06.sched_xref(+))
	 	  AND TO_NUMBER(t06.alt_xref)    = t07.line_code(+)
	 	  AND LTRIM(t01.matl_code,'0')   = t08.matl_code(+)
    	  AND t01.teco_stat = 'NO'
	 	  AND t01.run_start_datime > SYSDATE - 1
    	  AND t01.run_start_datime < SYSDATE + 6
	 	 -- AND ABS(t01.RUN_START_DATIME - t02.START_DATIME(+)) <= 2/1440
		  --AND ABS(t01.RUN_START_DATIME - t01.run_end_DATIME) >= 2/1440
	 	  AND t01.PLANT = i_plant_code
	 	  AND INSTR(UPPER(t01.matl_text),'BLEND')  = 0
	 	  AND LTRIM(t01.PROC_ORDER,'0') NOT IN (SELECT proc_order FROM cntl_rec_lcl)
  UNION ALL
  /*-*/
  /* get all records that are active from the local Proc Order table
  /*-*/
 SELECT t01.proc_order,
        t02.cntl_rec_id,
		  LTRIM(t02.MATL_CODE,'0') matl_code,
		  t02.MATL_TEXT,
		  DECODE(merge_flag,'M',t01.QTY_lcl, t02.qty) qty,
		  t02.UOM,
		  t01.RUN_START_DATIME_lcl,
		  t01.RUN_END_DATIME_lcl,
		  DECODE(sync,0,'N','Y') sync,
		  TO_CHAR(t01.LINE_CODE) line,
		  TO_CHAR(TO_NUMBER(DECODE(t05.brand_color,NULL,'00c040',t05.brand_color), 'xxxxxx')) Brand_color,
  		  DECODE(t01.line_code,'-1',t01.level_code,t06.LEVEL_CODE) level_code,
		  DECODE(replan_rate,NULL,0,replan_rate) replan_rate
   FROM cntl_rec_lcl t01,
        cntl_rec_vw t02,
		  (SELECT proc_order, Re_Timing.CHECK_SYNC(LTRIM(proc_order,'0')) sync FROM cntl_rec_vw) t03,
		  matl_brand_xref t04,
		  REF_BRAND_COLOR t05,
		  ref_line t06
  WHERE t01.proc_order = LTRIM(t02.proc_order,'0')
    AND t02.proc_order = t03.proc_order
	 AND LTRIM(t02.matl_code,'0') = t04.MATL_CODE(+)
	 AND t04.brand_flag_code = t05.brand_flag_code(+)
	 AND t01.LINE_CODE = t06.LINE_CODE(+)
	 AND t01.run_end_datime_lcl >= SYSDATE - 1
	-- AND ABS(t01.RUN_START_DATIME_LCL - t01.RUN_END_DATIME_LCL) >= 2/1440
    AND t01.run_start_datime_lcl < SYSDATE + 6
	 AND teco_stat = 'NO'
	 AND t02.PLANT = i_plant_code
  ORDER BY 7, 1;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Proc Orders procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_PROC_ORDERS;


  /***********************************************************/
  /* retrieve all process orders in the active mode
  /* used for the Recipe report tool
  /***********************************************************/
  PROCEDURE RETRIEVE_FRR_PROC_ORDERS(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_procs OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

	  /*-*/
	  /* contants used for the query - days back and days forward
	  /*-*/
	  LOOK_BACK NUMBER DEFAULT 4;
	  LOOK_FORWARD NUMBER DEFAULT 100;


  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

      OPEN o_retrieve_procs FOR
		SELECT LTRIM(t01.proc_order,'0') proc_order,
       		   cntl_rec_id,
	   		   LTRIM(matl_code,'0') matl_code,
			   matl_text matl_desc,
			   qty,
			   uom,
			   run_start_datime,
			   run_end_datime,
			   teco_stat
          FROM cntl_rec_lcl t01, cntl_rec_vw t02
  		 WHERE t01.proc_order = LTRIM(t02.proc_order,'0')
    	   AND plant = i_plant_code
		   AND teco_stat = 'NO'
		   AND run_start_datime_lcl > TRUNC(SYSDATE) - LOOK_BACK
		   AND run_start_datime_lcl < TRUNC(SYSDATE) + LOOK_FORWARD
		 UNION
		SELECT LTRIM(proc_order,'0') proc_order,
               cntl_rec_id,
			   LTRIM(matl_code,'0') matl_code,
			   matl_text matl_desc,
			   qty,
			   uom,
			   run_start_datime,
			   run_end_datime,
			   teco_stat
          FROM cntl_rec_vw
  		 WHERE plant = i_plant_code
		   AND teco_stat = 'NO'
		   AND run_start_datime > TRUNC(SYSDATE) - LOOK_BACK + 2
		   AND run_start_datime < TRUNC(SYSDATE) + LOOK_FORWARD
		   AND LTRIM(proc_order,'0')  NOT IN (SELECT proc_order FROM cntl_rec_lcl WHERE run_start_datime_lcl > TRUNC(SYSDATE) - 1
		                                      AND run_start_datime_lcl < TRUNC(SYSDATE) + 100)
         ORDER BY 7;

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
               LTRIM(t01.matl_code,'0') AS matl_code,
               matl_text AS matl_desc,
               qty,
               t01.uom,
               t01.run_start_datime,
               run_end_datime,
               'Y',
               '-1',
               0,
               0,
               1
          FROM cntl_rec t01
         WHERE t01.plant = i_plant_code
           AND SUBSTR(proc_order,1,1) NOT BETWEEN '0' AND '9'
           AND upd_datime > SYSDATE - 20
         ORDER BY 7 DESC, 3;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Proc RD Orders procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_RD_PROC_ORDERS;


  /***********************************************************/
  /* Insert a record into the local copy of the cntl_rec table
  /* - goes into cntl_rec_lcl
  /***********************************************************/
  FUNCTION INSERT_PROC_ORDER(i_proc_order IN VARCHAR2,
								  i_cntl_rec_id IN NUMBER,
								  i_qty IN NUMBER,
								  i_start_datime IN DATE,
								  i_end_datime IN DATE,
								  i_line_code IN NUMBER,
								  i_actual IN NUMBER,
								  i_level_code NUMBER,
								  i_matl_code VARCHAR2,
								  i_replan_rate NUMBER,
								  i_merge VARCHAR2
								  ) RETURN NUMBER IS

		var_merge VARCHAR2(4);
		var_count NUMBER;

  BEGIN

		SELECT COUNT(*) INTO var_count
		 FROM CNTL_REC_LCL
		WHERE proc_order = 	i_proc_order
		  AND merge_flag = 'M';

		IF var_count = 0 THEN
		    var_merge := SUBSTR(i_merge,0,1);
		ELSE
		    var_merge := 'M';
		END IF;

		/*-*/
		/* delete all resource records
		/*-*/
		DELETE FROM CNTL_REC_LCL_RESRCE
		 WHERE proc_order = i_proc_order;

		/*-*/
		/* delete all the local copy of the records
		/*-*/
		DELETE FROM CNTL_REC_LCL
		WHERE proc_order = i_proc_order;

	   /*-*/
		/* insert the local record
		/*-*/
		INSERT INTO CNTL_REC_LCL
		VALUES (i_proc_order,
		       i_cntl_rec_id,
				 TO_DATE(TO_CHAR(i_start_datime,'dd-mon-yyyy HH24:mi'),'dd-mon-yyyy HH24:mi'),
				 TO_DATE(TO_CHAR(i_end_datime ,'dd-mon-yyyy HH24:mi'),'dd-mon-yyyy HH24:mi'),
				 i_qty,
				 'Y', -- changed flag set to Y
				 i_line_code,
				 DECODE(i_actual,0,'N','Y'),
				 i_level_code,
				 i_replan_rate,
				 var_merge,
				 SYSDATE  -- save date the changed flag was set to Y
				 );


		/*-*/
		/* insert a value in the xref table if not exists
		/*-*/
		DELETE FROM REF_LEVEL_MATL_XREF
		 WHERE matl_code = i_matl_code;

		INSERT INTO ref_level_matl_xref
		VALUES (i_matl_code,
				 i_level_code);


		RETURN Re_Timing_Common.SUCCESS;

  EXCEPTION
      WHEN OTHERS THEN

			 --o_result_msg := 'RE_TIMING - Insert_Proc_Order  function with proc_order ' || trim(i_proc_order) || ' failed' || CHR(13)
          --                       || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
			 RETURN  Re_Timing_Common.FAILURE;

  END INSERT_PROC_ORDER;


  /***********************************************************/
  /* retrieve all resource - work centre links in the active mode
  /***********************************************************/
  PROCEDURE RETRIEVE_RESOURCES(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_resrce OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
  BEGIN
     o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	    OPEN o_retrieve_resrce FOR
		  SELECT prnt_line_code,
		         t04.RESRCE_CODE,
				 t05.RESRCE_DESC,
       			 trim(t02.work_ctr_code) work_ctr_code,
		 		 NLS_INITCAP(trim(work_ctr_name)) work_ctr_desc,
				 DECODE(SUBSTR(UPPER(trim(work_ctr_name)),0,4),'PALL','Y','MEAT','Y','LIQU', 'Y', 'CERE', 'Y','PACK','Y', 'DBON','Y','SCHM','Y', 'N')  SHARED
			FROM ref_line t01,
		 	     REF_LINE_WC_XREF t02,
		 	     work_ctr t03,
		 		 REF_RESRCE_WC_XREF t04,
		 		 ref_resrce t05
         WHERE t01.prnt_line_code = t02.LINE_CODE
           AND trim(t02.work_ctr_code) = trim(t03.work_ctr_code)
			  AND trim(t02.work_ctr_code) = trim(t04.work_ctr_code)
			  AND t04.RESRCE_CODE = t05.RESRCE_CODE
			  AND t05.PLANT = i_plant_code
         GROUP BY prnt_line_code, t04.RESRCE_CODE, t02.work_ctr_code, SPLIT, work_ctr_name, t05.RESRCE_DESC
         ORDER BY 1,2,5;



  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Resources procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END retrieve_resources;


  /***********************************************************/
  /* retrieve all resource - work centre links in the active mode
  /***********************************************************/
  PROCEDURE RETRIEVE_ALLOC_RESOURCES(i_plant_code IN VARCHAR2,
  										o_result OUT NUMBER,
								  		o_result_msg OUT VARCHAR2,
								  		o_retrieve_resrce OUT Re_Timing_Common.RETURN_REF_CURSOR) IS
  BEGIN
     o_result  := Re_Timing_Common.SUCCESS;
	  o_result_msg := '';

	    OPEN o_retrieve_resrce FOR

			SELECT LTRIM(t05.proc_order,'0') proc_order,
				   t05.resrce_code,
				   --DECODE(t06.WORK_CTR_CODE,NULL,'-1',t06.WORK_CTR_CODE) work_ctr_code,
				   DECODE(t06.WORK_CTR_CODE,NULL,'-1','-1','-1',DECODE(SUBSTR(t05.resrce_code,0,5),'CEREL','200025', t06.WORK_CTR_CODE)) work_ctr_code,
				   MIN(t05.OPERTN) opertn ,
				   --t08.SPLIT,
				   DECODE(t07.matl_made, NULL,'-1',t07.matl_made) matl_code,
				   DECODE(t07.matl_made_desc,NULL,'-1',t07.matl_made_desc) matl_desc
			  FROM CNTL_REC_RESRCE t05,
				   CNTL_REC_LCL_RESRCE t06,
				   REF_LINE_WC_XREF t08,
				   (SELECT proc_order, opertn, matl_made, matl_made_desc
					  FROM recpe_hdr t01, recpe_resrce t02
					 WHERE t01.CNTL_REC_ID = t02.CNTL_REC_ID) t07,
				   (SELECT proc_order, opertn FROM cntl_rec_bom WHERE matl_code NOT IN (SELECT matl_code FROM recpe_phantom)) t09
			 WHERE LTRIM(t05.PROC_ORDER,'0') = t06.PROC_ORDER(+)
				AND t05.RESRCE_CODE = t06.RESRCE_CODE(+)
				AND t06.WORK_CTR_CODE = t08.WORK_CTR_CODE(+)
				AND LTRIM(t05.PROC_ORDER,'0') = t07.PROC_ORDER(+)
				AND t05.PROC_ORDER = t09.proc_order
				AND t05.opertn = t09.opertn
				AND t05.OPERTN = t07.opertn(+)
				AND LTRIM(t05.proc_order,'0') NOT IN
							   (
				           		SELECT LTRIM(t01.Proc_order,'0')
				       			  FROM CNTL_REC t01, CNTL_REC_LCL t02
						 		 WHERE LTRIM(t01.proc_order,'0') = t02.proc_order(+)
								   AND ((t01.run_end_datime < SYSDATE - 2 OR t02.RUN_end_DATIME_LCL < SYSDATE  -2)
			 						OR t01.run_start_datime >= SYSDATE + 4
									OR teco_stat = 'YES'
									OR t01.RUN_START_DATIME = t01.RUN_END_DATIME)
								   AND plant = i_plant_code
								)
				AND t05.opertn IS NOT NULL
				AND (t08.SPLIT = 'Y' OR t08.SPLIT IS NULL)
				AND t05.resrce_code NOT LIKE 'USEBN%'
                AND substr(t05.proc_order,1,1) <> '%'
			  GROUP BY t05.proc_order,
			        t05.resrce_code,
					t06.work_ctr_code, SPLIT,
					t07.matl_made,
					t07.matl_made_desc
			UNION
			SELECT LTRIM(t05.proc_order,'0') proc_order,
				   t05.resrce_code,
				   --DECODE(t06.WORK_CTR_CODE,NULL,'-1',t06.WORK_CTR_CODE) work_ctr_code,
				   DECODE(t06.WORK_CTR_CODE,NULL,'-1','-1','-1',DECODE(SUBSTR(t05.resrce_code,0,5),'CEREL','200025', t06.WORK_CTR_CODE)) work_ctr_code,
				   MIN(t05.OPERTN) opertn ,
				   -- t08.SPLIT,
				   DECODE(t07.matl_made, NULL,'-1',t07.matl_made) matl_code,
				   DECODE(t07.matl_made_desc,NULL,'-1',t07.matl_made_desc) matl_desc
		      FROM CNTL_REC_RESRCE t05,
				   CNTL_REC_LCL_RESRCE t06,
				   REF_LINE_WC_XREF t08,
				   (SELECT proc_order, opertn, matl_made, matl_made_desc
					 FROM recpe_hdr t01, recpe_resrce t02
					WHERE t01.CNTL_REC_ID = t02.CNTL_REC_ID) t07,
				   (SELECT proc_order, opertn FROM cntl_rec_bom WHERE matl_code NOT IN (SELECT matl_code FROM recpe_phantom)) t09
			  WHERE LTRIM(t05.PROC_ORDER,'0') = t06.PROC_ORDER(+)
				AND t05.RESRCE_CODE = t06.RESRCE_CODE(+)
				AND t06.WORK_CTR_CODE = t08.WORK_CTR_CODE(+)
				AND LTRIM(t05.PROC_ORDER,'0') = t07.PROC_ORDER(+)
				AND t05.PROC_ORDER = t09.proc_order
				AND t05.opertn = t09.opertn
				AND t05.OPERTN = t07.opertn(+)
				AND LTRIM(t05.proc_order,'0') NOT IN
				 				   (
				             		SELECT LTRIM(t01.Proc_order,'0')
				      				  FROM CNTL_REC t01, CNTL_REC_LCL t02
						 			 WHERE LTRIM(t01.proc_order,'0') = t02.proc_order(+)
									   AND ((t01.run_end_datime < SYSDATE - 2 OR t02.RUN_end_DATIME_LCL < SYSDATE  -2)
			 							OR t01.run_start_datime >= SYSDATE + 4
										OR teco_stat = 'YES'
										OR t01.RUN_START_DATIME = t01.RUN_END_DATIME)
									   AND plant = i_plant_code
									)
				AND t05.opertn IS NOT NULL
				AND t08.SPLIT = 'N'
				AND t05.resrce_code NOT LIKE 'USEBN%'
                AND substr(t05.proc_order,1,1) <> '%'
			  GROUP BY t05.proc_order,
			        t05.resrce_code,
					t06.work_ctr_code,
					SPLIT,
					t07.matl_made,
					t07.matl_made_desc
			  ORDER BY 1,4;



  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE Allocated Resources procedure with Plant ' || trim(i_plant_code) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END retrieve_alloc_resources;





  /***********************************************************/
  /* Insert a record into the local copy of the cntl_rec_resrce table
  /* - goes into cntl_rec_lcl_resrce
  /***********************************************************/
  FUNCTION INSERT_RESOURCE(i_proc_order IN VARCHAR2,
								  i_resrce_code IN VARCHAR2,
								  i_work_ctr IN VARCHAR2,
								  i_opertn IN VARCHAR2) RETURN NUMBER IS

	  CURSOR cur_proc_order IS
	  SELECT COUNT(*)
	    FROM CNTL_REC_LCL
	   WHERE proc_order = i_proc_order;

	  var_work NUMBER;
	  var_seq  NUMBER;
	  var_opertn VARCHAR2(4);

  BEGIN

  		/*-*/
		/* delete the record if it exists
		/*-*/
  		DELETE FROM CNTL_REC_LCL_RESRCE
		 WHERE proc_order = trim(i_proc_order)
		   AND opertn = trim(i_opertn)
		   AND resrce_code = trim(i_resrce_code)
		   AND work_ctr_code = trim(i_work_ctr);

	    IF i_resrce_CODE LIKE 'EXTRU%' THEN
			 DELETE FROM CNTL_REC_LCL_RESRCE
		     WHERE proc_order = trim(i_proc_order)
		       AND opertn = trim(i_opertn)
		       AND resrce_code = 'CEREL' || SUBSTR(i_resrce_code,6,3)
		       AND work_ctr_code = trim(i_work_ctr);
		END IF;

		/*-*/
		/* If the resource is Cerel then dont do this section
		/*-*/
		IF NOT (i_resrce_CODE LIKE 'CEREL%') THEN
		    /*-*/
			/*  only insert if a record exists in the cntl_rec_lcl table
			/*-*/
			OPEN cur_proc_order;
        	LOOP
                FETCH cur_proc_order INTO var_work;
		    	/*-*/
			 	/* insert a record in the resource - work ctr table
			 	/*-*/
			 	IF var_work > 0 THEN
				    SELECT CNTL_REC_LCL_RESRCE_id_seq.NEXTVAL INTO var_seq FROM dual;

					 INSERT INTO CNTL_REC_LCL_RESRCE
		   		     VALUES (var_seq,
					        trim(i_proc_order),
			                trim(i_opertn),
			    			trim(i_resrce_code),
				 			trim(i_work_ctr));

					/*-*/
					/* Check if this is an extruder
					/*-*/
					IF i_resrce_code LIKE 'EXTRU%' THEN

						 SELECT opertn INTO var_opertn
						  FROM cntl_rec_resrce
						  WHERE LTRIM(proc_order,'0') = i_proc_order
						  AND resrce_code = 'CEREL' || SUBSTR(i_resrce_code,6,3);


						 SELECT CNTL_REC_LCL_RESRCE_id_seq.NEXTVAL INTO var_seq FROM dual;

						 INSERT INTO CNTL_REC_LCL_RESRCE
		   		         VALUES (var_seq,
					            trim(i_proc_order),
			                    trim(var_opertn),
			    			    'CEREL' || SUBSTR(i_resrce_code,6,3),
				 			    trim(i_work_ctr));
					END IF;

			 	END IF;
		        EXIT;
		    END LOOP;
            CLOSE cur_proc_order;

		END IF;

      RETURN Re_Timing_Common.SUCCESS;

  EXCEPTION
      WHEN TOO_MANY_ROWS THEN
	      RETURN  Re_Timing_Common.FAILURE;
	  WHEN NO_DATA_FOUND THEN
	      RETURN  Re_Timing_Common.success;
      WHEN OTHERS THEN
			 RETURN  Re_Timing_Common.FAILURE;

  END INSERT_RESOURCE;


  /***********************************************************/
  /* retrieve schedule
  /***********************************************************/
  PROCEDURE RETRIEVE_SCHED(i_plant_code IN VARCHAR2,
  									o_result OUT NUMBER,
								  	o_result_msg OUT VARCHAR2,
								  	o_retrieve_sched OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN

      OPEN o_retrieve_sched FOR
  SELECT  CASE
		    WHEN LENGTH(TO_CHAR(t01.TRAD_UNIT_CODE)) = 7 AND t02.ALT_XREF IS NOT NULL THEN t02.ALT_XREF
			ELSE TO_CHAR(t02.Line_code) END line_code,
		 t01.TRAD_UNIT_CODE matl_code,
		 DECODE(matl_desc,NULL,'None', matl_desc) matl_desc,
		 sched_qty qty,
   	     'EA' uom,
		 ROUND(start_datime,'mi') start_datime,
		 ROUND(end_datime,'mi') end_datime,
		 TO_CHAR(TO_NUMBER(DECODE(t05.brand_color,NULL,'00c040',t05.brand_color), 'xxxxxx')) Brand_color,
		 t01.sched_vrsn vrsn,
		 t06.CREATN_DATIME vsrn_datime
    FROM PPS_PLND_PRDN_DETL t01,
		 PPS_PLND_PRDN_vrsn t06,
		 REF_LINE t02,
		 MATL t03,
		 matl_brand_xref t04,
		 REF_BRAND_COLOR t05
   WHERE TO_CHAR(t01.TRAD_UNIT_CODE) = t04.MATL_CODE(+)
	 AND t04.BRAND_FLAG_CODE = t05.BRAND_FLAG_CODE(+)
	 AND TO_CHAR(t01.TRAD_UNIT_CODE) = t03.MATL_CODE(+)
	 AND trim(t01.PRODN_LINE_CODE) = trim(t02.SCHED_XREF)
	 AND t01.SCHED_VRSN = t06.SCHED_VRSN
	 AND start_datime >= SYSDATE - 7
	 AND start_datime < SYSDATE + Re_Timing_Common.SCHEDULE_DAYS
	 AND trim(t01.plant_code) = i_plant_code
	 /*-*/
	 /* filter out any record where Line number is not selected
	 /*-*/
	 AND NOT (LENGTH(t02.Line_code) = 0 AND LENGTH(t02.ALT_XREF) = 0)
	 AND t01.sched_vrsn = (SELECT MAX(sched_vrsn) FROM PPS_PLND_PRDN_DETL WHERE trim(plant_code) = i_plant_code)
  ORDER BY 1,6,3;

    o_result := 0;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	      o_result := 2;
		  o_result_msg := 'Retrieve_Sched found NO records';
      WHEN OTHERS THEN
		  o_result := 1;
		  o_result_msg := 'Retrieve_Sched - ' || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_SCHED;


  /***********************************************************/
  /* get bthe actuals value from the Pallet Tagging app for
  /* a specified proc_order
  /***********************************************************/
  FUNCTION GET_ACTUAL(i_proc_order IN VARCHAR2)  RETURN NUMBER IS

      var_work NUMBER;

  BEGIN
  	SELECT SUM(qty) INTO var_work
	  FROM (
	  	 	SELECT  DECODE(SUM(qty), NULL,0,SUM(qty)) qty
		      FROM plt_hdr
		     WHERE proc_order = LTRIM(i_proc_order,'0')
		       AND status = 'CREATE'
		     UNION ALL
		    SELECT - DECODE(SUM(qty), NULL,0,SUM(qty)) qty
		      FROM plt_hdr
		     WHERE proc_order = LTRIM(i_proc_order,'0')
		       AND status = 'CANCEL'
		   );

		 RETURN var_work;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	      RETURN 0;
      WHEN OTHERS THEN
		   RETURN 0;

  END GET_ACTUAL;


  /***********************************************************/
  /* get the FIRM date from oracle
  /***********************************************************/
  FUNCTION GET_FIRM(i_plant_code IN VARCHAR2)  RETURN VARCHAR2 IS

      var_work VARCHAR2(20);


  BEGIN

	   --IF SYSDATE >= TRUNC(SYSDATE) + RE_TIMING_COMMON.SCHEDULE_CHANGE THEN
	   /*IF mrp_period = 1 THEN
	       IF TO_CHAR(SYSDATE,'DY') = 'FRI' THEN
                   var_work := TO_CHAR(TRUNC(SYSDATE) + 4,'dd/mm/yyyy hh24:mi');
               ELSE
                   var_work := TO_CHAR(TRUNC(SYSDATE) + 3,'dd/mm/yyyy hh24:mi');
               END IF;
	   ELSE
               IF TO_CHAR(SYSDATE,'DY') = 'SAT' THEN
                   var_work := TO_CHAR(TRUNC(SYSDATE) + 3,'dd/mm/yyyy hh24:mi');
               ELSE
                   var_work := TO_CHAR(TRUNC(SYSDATE) + 2,'dd/mm/yyyy hh24:mi');
               END IF;

	   END IF;*/
           
      /* Basic pattern for RTT window sizes is 2/3 for most days except on Fridays (2/4) and Saturdays (3/3) */
      CASE TO_CHAR(SYSDATE,'DY')
      WHEN 'FRI' THEN
          --FRIDAY
          IF mrp_period = 0 THEN
                  var_work := TO_CHAR(TRUNC(SYSDATE) + 2,'dd/mm/yyyy hh24:mi');
          ELSE
                  var_work := TO_CHAR(TRUNC(SYSDATE) + 4,'dd/mm/yyyy hh24:mi');
          END IF;
          
      WHEN 'SAT' THEN
          --SATURDAY
          IF mrp_period = 0 THEN
                  var_work := TO_CHAR(TRUNC(SYSDATE) + 3,'dd/mm/yyyy hh24:mi');
          ELSE
                  var_work := TO_CHAR(TRUNC(SYSDATE) + 3,'dd/mm/yyyy hh24:mi');
          END IF;
          
      ELSE
          --OTHER DAYS
          IF mrp_period = 0 THEN
                  var_work := TO_CHAR(TRUNC(SYSDATE) + 2,'dd/mm/yyyy hh24:mi');
          ELSE
                  var_work := TO_CHAR(TRUNC(SYSDATE) + 3,'dd/mm/yyyy hh24:mi');
          END IF;       
      END CASE;

      RETURN var_work;

  EXCEPTION
      WHEN OTHERS THEN
		   RETURN TO_CHAR(TRUNC(SYSDATE) + 2,'dd/mm/yyyy hh24:mi');

  END GET_FIRM;


  /***********************************************************/
  /* get the FIRM start date from oracle
  /***********************************************************/
  FUNCTION GET_FIRM_START(i_plant_code IN VARCHAR2)  RETURN VARCHAR2 IS

	   var_work VARCHAR2(20);
		var_work1 DATE;

		CURSOR csr_date IS
		SELECT start_datime FROM prodn_shift t01
       WHERE trim(plant_code) = i_plant_code
         AND end_datime > SYSDATE
         AND start_datime <= SYSDATE;

  BEGIN
  	  /*-*/
	  /* start of the current shift is sent back
	  /*-*/
      OPEN csr_date;
      LOOP
          FETCH csr_date INTO var_work1;
          EXIT WHEN csr_date%NOTFOUND;
			     var_work := TO_CHAR(var_work1, 'dd/mm/yyyy hh24:mi');
				  EXIT;
      END LOOP;
      CLOSE csr_date;

      RETURN var_work;

  EXCEPTION
      WHEN OTHERS THEN
		   RETURN TO_CHAR(SYSDATE+2, 'dd/mm/yyyy hh24:mi');

  END GET_FIRM_START;


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
		  AND LTRIM(t01.proc_order,'0') = LTRIM(i_proc_order,'0')
		  AND t01.cntl_rec_id = t02.cntl_rec_id;

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
				  c.matl_desc,
				  run_start_datime,
				  run_end_datime,
		 		  DECODE(tun_code,NULL,'-1',tun_code) tun_code,
		 		  DECODE(old_matl_code,NULL,'-1',old_matl_code) old_matl_code,
		 		  qty,
		 		  uom,
				  units_per_case,
				  P.CRTNS_PER_PLLT,
				  ''  zrep,
				  ''  sales_text,
				  M.SHELF_LIFE,
				  M.NET_WGHT,
				  M.GROSS_WGHT
		   FROM RECPE_HDR c, MATL_PLT P, matl_vw M
          WHERE c.MATL_CODE = P.MATL_CODE(+)
		    AND c.MATL_CODE = M.MATL_CODE(+)
		    AND LTRIM(c.proc_order,'0') = LTRIM(i_proc_order,'0');

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_RECIPE_HDR procedure with ProcOrder ' || trim(i_proc_order) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
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
		 SELECT cntl_rec_id,
		 		  opertn,
				  phase,
				  seq,
		 		  old_matl_code matl_code,
		 		  DECODE(description, NULL, '-1',description) matl_desc,
				  c.DETAILTYPE detailtype,

		 		  DECODE(uom, NULL, '-1','?','-1', uom) uom,
		 		  DECODE(TO_CHAR(qty), NULL, '-1', '?','-1', qty) bom_qty,
		 		  DECODE(sub_total, NULL, '0', sub_total) total,
				  sub_header
         FROM recpe_vw c
        WHERE c.proc_order = i_proc_order
		  ORDER BY opertn, phase, seq;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_RECIPE_DTL procedure with ProcOrder' || trim(i_proc_order) || ' failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
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
  END RETRIEVE_RECIPE_FTR;


    /***********************************************************/
  /* retrieve any waivers that are active for the selected proic order material
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
		  SELECT DISTINCT w.waiver_code
		    FROM WAIVER w, WAIVER_CRTRIA c
		WHERE w.waiver_code = c.waiver_code
		  AND eff_start_datime <= SYSDATE
		  AND eff_end_datime >= SYSDATE
		  AND  item_code = (SELECT LTRIM(matl_code,'0')
			                FROM CNTL_REC
			      			 WHERE LTRIM(proc_order,'0') = LTRIM(i_proc_order,'0'));

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
		 SELECT trim(c.PLANT) plant,
		        trim(c.PLANT_NAME) plant_name
         FROM manu.REF_PLANT c
        WHERE c.PLANT IN ('AU30')
		    AND c.plant IN (SELECT plant FROM CNTL_REC WHERE teco_stat = 'NO')
		  ORDER BY 1;

  EXCEPTION
      WHEN OTHERS THEN
			 o_result  := Re_Timing_Common.FAILURE;
			 o_result_msg := 'RE_TIMING - RETRIEVE_PLANTS procedure failed' || CHR(13)
                                 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512);
  END RETRIEVE_PLANTS;

  /***********************************************************/
  /* Start of update of process orders and resources
  /***********************************************************/
  FUNCTION START_UPDATE(i_plant_code IN VARCHAR2)  RETURN NUMBER IS

		var_seq NUMBER;

  BEGIN

		/*-*/
      /* Set a start record
      /*-*/
      SELECT RE_TIME_STAT_id_seq.NEXTVAL INTO var_seq FROM dual;
      INSERT INTO RE_TIME_STAT
		VALUES (var_seq, SYSDATE,'S','','','','','','');

		var_start := var_seq; -- save the seq number for the end flag

  		RETURN 0;

  EXCEPTION
      WHEN OTHERS THEN
		   RETURN 1;
  END;


  /***********************************************************/
  /* End of update of process orders and resources
  /* send to Atlas = 1
  /* send = 0 do not send
  /***********************************************************/
  FUNCTION END_UPDATE(i_plant_code IN VARCHAR2, i_send IN NUMBER)  RETURN NUMBER IS

      var_work NUMBER DEFAULT 0;

  BEGIN

      UPDATE RE_TIME_STAT
		   SET re_time_stat_flag ='E'
		 WHERE re_time_stat_id = var_start;


		SELECT COUNT(*) INTO var_work
		  FROM ATLAS_STAT t01
		 WHERE t01.ATLAS_DOWN_DATIME = (SELECT MAX(ATLAS_DOWN_DATIME) FROM ATLAS_STAT)
		   AND ATLAS_STAT = 'ON';

		/*-*/
		/* only send the sre-timing schedule to Atlas if the Atlas
		/* stat is on and the i_send flag is set to 1
		/*-*/
		IF var_work > 0 AND i_send = 1 THEN
		    Re_Timing_Schedule_Send.EXECUTE(i_plant_code);
		END IF;

		COMMIT;

  		RETURN 0;

  EXCEPTION
      WHEN OTHERS THEN
		   ROLLBACK;
		   RETURN 1;
  END;

    /***********************************************************/
  /* Set by retiming Tool to indicate Atlas is on or off
  /***********************************************************/
  FUNCTION ATLAS_ON(i_status IN NUMBER) RETURN NUMBER IS

      var_seq NUMBER;
	  var_mrp  VARCHAR2(4) DEFAULT 'R';
	  var_count NUMBER;
	  var_work VARCHAR2(10);

  BEGIN

  		 IF (i_status = 1) THEN
		     var_work := 'ON';

			 --IF RE_TIMING_COMMON.SCHEDULE_TIME + RE_TIMING_COMMON.SCHEDULE_TIME_DELAY - TO_NUMBER(SYSDATE - TRUNC(SYSDATE)) < 0 THEN
			 IF mrp_period = 1 THEN
		 	     SELECT COUNT(*) INTO var_count
				   FROM atlas_stat
				  WHERE atlas_down_datime BETWEEN TRUNC(SYSDATE) AND SYSDATE
			        AND atlas_stat_type = 'MRP';

				 IF var_count = 0 THEN
				     var_mrp := 'MRP';
				 END IF;
			 END IF;
		 ELSE
		     var_work := 'OFF';
		 END IF;

		 /*-*/
		 /* insert a record representing the status just passed in by RTT
		 /*-*/
  		 SELECT RE_TIME_STAT_id_seq.NEXTVAL INTO var_seq FROM dual;
  		 INSERT INTO ATLAS_STAT
		 VALUES (var_seq,
		 		 var_work,
				 SYSDATE,
				 var_mrp -- Retiming
		 		 );

		COMMIT;

		RETURN 0;

  EXCEPTION
      WHEN OTHERS THEN
	      RETURN 0;

  END;


   /***********************************************************/
  /* Get by retiming Tool if Atlas is on or off
  /* return 1 for On
  /* return 0 for Off
  /* return 2 mrp mode
  /***********************************************************/
  FUNCTION IS_ATLAS_ON (i_plant_code VARCHAR2) RETURN NUMBER IS


     var_return NUMBER;
	var_count  NUMBER;
	var_seq    NUMBER;
	var_date   DATE;
	var_rcd_count NUMBER DEFAULT 0;

   CURSOR csr_atlas
   IS
   SELECT atlas_stat, atlas_stat_type FROM ATLAS_STAT
    WHERE TRUNC(atlas_down_datime) = var_date
    ORDER BY atlas_stat_id DESC;

	rcd_atlas csr_atlas%ROWTYPE;

   CURSOR csr_atlas_old
   IS
   SELECT atlas_stat, atlas_stat_type FROM ATLAS_STAT
   -- WHERE TRUNC(atlas_down_datime) = var_date
    ORDER BY atlas_stat_id DESC;

	rcd_atlas_old csr_atlas_old%ROWTYPE;

    BEGIN

	    var_return :=  1;
        var_date := TRUNC(SYSDATE);

		/*-*/
		/* this is before the extended MRP section so run as normal
		/*-*/
        OPEN csr_atlas;
        LOOP
        FETCH csr_atlas INTO rcd_atlas;
            EXIT WHEN csr_atlas%NOTFOUND;

			var_rcd_count := 1;

			/*-*/
		    /* Check if the stystem is in MRP window mode ie the frim date is extended for 1 day
		    /*-*/
		    --IF RE_TIMING_COMMON.SCHEDULE_TIME + RE_TIMING_COMMON.SCHEDULE_TIME_DELAY - TO_NUMBER(SYSDATE - TRUNC(SYSDATE)) < 0 AND rcd_atlas.atlas_stat = 'ON' THEN
		    IF mrp_period = 1 THEN
			    /*-*/
			    /* find if there has already been an MRP set
				/* for this 24 hour period
			    /*-*/
			    SELECT COUNT(*) INTO var_count
			      FROM ATLAS_STAT
			     WHERE atlas_down_datime BETWEEN TRUNC(SYSDATE) AND SYSDATE
			       AND atlas_stat_type = 'MRP';

			    IF var_count = 0 THEN
				    /*-*/
					/* insert another record with MRP set - since it has not been recorded yet
					/*-*/
			        SELECT RE_TIME_STAT_id_seq.NEXTVAL INTO var_seq FROM dual;
			        INSERT INTO atlas_stat VALUES (var_seq, rcd_atlas.atlas_stat, SYSDATE, 'MRP');
				    -- mrp mode so send value of 2
			        var_return := 2;
				ELSE
				    /*-*/
					/* check if the latest record is still set to MRP of not
					/*-*/
					IF rcd_atlas.atlas_stat_type = 'MRP' THEN
					    /*-*/
					    /* if still MRP set as the last record then
					    /*-*/
					    var_return := 2;
					ELSE
					    /*-*/
						/* otherwise set based on stat flag
						/*-*/
						IF rcd_atlas.atlas_stat = 'ON' THEN
						    var_return :=  1;
						ELSE
						    var_return :=  0;
						END IF;
					END IF;
				END IF;
			ELSE
			    IF rcd_atlas.atlas_stat = 'ON' THEN
				    var_return :=  1;
				ELSE
				    var_return :=  0;
				END IF;
			END IF;

		    EXIT;
        END LOOP;
        CLOSE csr_atlas;

		--DBMS_OUTPUT.PUT_LINE('here we are' );

	    /*-*/
		/* must be the first time past midnight
		/*-*/
		/*-*/
		IF var_rcd_count = 0 THEN
			/*-*/
			/* no records found so use last record from the last day day
			/*-*/
			OPEN csr_atlas_old;
            LOOP
            FETCH csr_atlas_old INTO rcd_atlas_old;
                EXIT WHEN csr_atlas_old%NOTFOUND;
				/*-*/
		    	/* Check if the stystem is in MRP window mode ie the frim date is extended for 1 day
		    	/*-*/
		    	--IF RE_TIMING_COMMON.SCHEDULE_TIME + RE_TIMING_COMMON.SCHEDULE_TIME_DELAY - TO_NUMBER(SYSDATE - TRUNC(SYSDATE)) < 0 AND rcd_atlas_old.atlas_stat = 'ON' THEN
		    	IF mrp_period = 1 THEN
				    /*-*/
					/* insert another record with MRP set - since it has not been recorded yet
					/*-*/
			        SELECT RE_TIME_STAT_id_seq.NEXTVAL INTO var_seq FROM dual;
			        INSERT INTO atlas_stat VALUES (var_seq, rcd_atlas_old.atlas_stat, SYSDATE, 'MRP');
				    -- mrp mode so send value of 2
			        var_return := 2;
				ELSE

				    IF rcd_atlas_old.atlas_stat = 'ON' THEN
				        var_return :=  1;
				    ELSE
				        var_return :=  0;
				    END IF;
				END IF;
				EXIT;
            END LOOP;
            CLOSE csr_atlas_old;
		END IF;

		COMMIT;

		RETURN var_return;


  EXCEPTION
      WHEN OTHERS THEN
	      RETURN 9;
  END;


  /***********************************************************/
  /* RETRIEVE_Materials which can have a process order created
  /* this is used in the factory recipe report - R&D section
  /***********************************************************/
  PROCEDURE RETRIEVE_MATLS(i_plant_code  IN VARCHAR2,
  								  o_result OUT NUMBER,
								  o_result_msg OUT VARCHAR2,
								  o_retrieve_matls OUT Re_Timing_Common.RETURN_REF_CURSOR) IS

  BEGIN
      o_result  := Re_Timing_Common.SUCCESS;
	   o_result_msg := '';

	   OPEN o_retrieve_matls FOR
		   SELECT matl_code, matl_desc, plant
			  FROM matl
			 WHERE prcrmnt_type = 'E'
			   AND spcl_prcrmnt_type IS NULL
			   AND plant_sts = '20'
				AND (LTRIM(MATL_CODE,'0'), plant) NOT IN
				    (SELECT matl_code, plant_code FROM rd_sched)
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
	    SELECT DECODE(base_uom,'KGM', 'KG', base_uom) uom
		  FROM matl
		 WHERE plant = i_plant_code
		   AND matl_code = i_matl;

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
					       (matl_code, plant_code, qty, uom, start_datime, end_datime)
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

		Rd_Schedule_Send.EXECUTE(i_plant_code);

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

GRANT EXECUTE ON MANU_APP.RE_TIMING TO APPSUPPORT;
GRANT EXECUTE ON MANU_APP.RE_TIMING TO BTHSUPPORT;
GRANT EXECUTE ON MANU_APP.RE_TIMING TO PR_ADMIN;
GRANT EXECUTE ON MANU_APP.RE_TIMING TO PR_APP WITH GRANT OPTION;
GRANT EXECUTE ON MANU_APP.RE_TIMING TO PR_USER;

CREATE OR REPLACE PUBLIC SYNONYM RE_TIMING FOR MANU_APP.RE_TIMING;