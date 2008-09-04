DROP PACKAGE MANU_APP.MASTER_SCHEDULE_SEND;

CREATE OR REPLACE PACKAGE MANU_APP.Master_Schedule_Send AS
/******************************************************************************
   NAME:       Send_Schedule
   PURPOSE:		This will send a mini schedule of say 2 days. 
					starting at 7 am on the day the request is made 
					ending at 7am 
					
					The cursor selects all active Proc Orders between the days of interest
					and is sent via the Remote Loader package to a directory /tmp on the server 
					

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14-Sep-05   Jeff Phillipson  Created this package.
******************************************************************************/

 
  PROCEDURE EXECUTE(i_plant_code IN VARCHAR2);
 

END Master_Schedule_Send;
/


DROP PACKAGE BODY MANU_APP.MASTER_SCHEDULE_SEND;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Master_Schedule_Send AS
/******************************************************************************
   NAME:       Send_Schedule 
   PURPOSE:		This package is called from Execute which return a query based on a standard 
					time slot of x days - standard schedule starting at 7am 
					The updated data from all proc orders will be sent back to Atlas for 
					updating with the relavent date changes 
					
					This package users the remote file loader called MANU_REMPOTE_LOADER 
					as used in the LADS database - this is the original with no modifications 
					
					After the Schedule data has been sent a trigger Idoc has to be created 
					that will fire a batch job in Atlas to update the proc orders. 
					Not sure on the timing between these 2 Idocs 
					
					
					The var_serialise_code uses the sysdate as a refence number for both the
					Schedule file and the trigger file. The value has to be identical 
					so that Atlas can process the schedule file when the trigger is fired 
					
					Modifications 15 Sep 2006 - Added cursor csr_count which will check if there 
					are any material codes in the schedule - located in the PPS table - that
					are not valid. 
					
					The rule on validation is - they are not in the MATL materialised view from Atlas
					However any code that starts with 99 will not be considered invalid since
					it may be used for special assignment such as cleaning time.
					
					If any material codes are found a Mailout is made to the Notes Sheduler group

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        21-Sep-05   Jeff Phillipson  Created this package body.
   1.1		  15 Sep 2006 Jeff Phillipson  Added Invalid matl code checking and mailout
******************************************************************************/
   
	/*-*/
	/* Constants used 
	/*-*/
	
   /*-*/
	/* this value defines the schedule window in days 
	/*-*/
	--cst_Offset     CONSTANT NUMBER(2)    := 2;
	cst_fil_path	CONSTANT	VARCHAR2(60) := 'MANU_OUTBOUND';
	cst_fil_name	CONSTANT	VARCHAR2(20) := 'CISATL11_';  -- the .1 will be added with the time stamp 
	cst_trig_name  CONSTANT VARCHAR2(20) := 'CISATL09_';  -- the .1 will be added with the time stamp 
	
	/*-*/
	/* Unix command to send the file over MQ series - not workinyg yet 
	/*-*/
    cst_prc_script	 CONSTANT	VARCHAR2(100):= '/manu/prod/bin/send_file.sh -f ' || cst_fil_name;
	cst_prc_script1 CONSTANT	VARCHAR2(100):= '/manu/prod/bin/send_file.sh -f ' || cst_trig_name;
	
	/*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);
		
		run_start_datime DATE;
		run_end_datime DATE;
				
	/*-*/
	/* Start of process
	/*-*/
   PROCEDURE EXECUTE(i_plant_code IN VARCHAR2)
	AS
	
	    var_prodn_version    VARCHAR2(4)  := '0001';
		var_count            NUMBER DEFAULT 0;
		var_serialise_code   DATE;
		var_timestamp        VARCHAR2(20);
		var_matl 			 VARCHAR2(32);
		var_seq				 NUMBER;
		var_sched_days       NUMBER DEFAULT Re_Timing_Common.SCHEDULE_DAYS;
        var_start_date       DATE DEFAULT TO_DATE(Re_Timing.GET_FIRM('AU30'),'dd/mm/yyyy hh24:mi');
        var_end_date         DATE;
	    var_offset           NUMBER;
		var_non_grd			 VARCHAR2(4000) DEFAULT '';
	 
		/*-*/
		/* start time based on 7am start and end 
		/* get ALL active materials over the time scale required 
		/*-*/
   	    CURSOR csr_po IS
	  SELECT t01.TRAD_UNIT_CODE matl_code, 
		  	 trim(t01.plant_code) plant,
		  	 sched_qty qty, 
   	  		 'EA' uom, 
		  	 ROUND(start_datime,'mi') run_start_datime, 
		  	 ROUND(end_datime,'mi') run_end_datime
        FROM PPS_PLND_PRDN_DETL t01,
		     PPS_PLND_PRDN_vrsn t06,
			 matl t02
       WHERE t01.SCHED_VRSN = t06.SCHED_VRSN
	     AND TO_CHAR(t01.trad_unit_code) = t02.matl_code
		 AND end_datime  - start_datime > 0
	     AND start_datime >= TO_DATE(var_start_date) 
	     -- end date will be based on the last day of the week 
		 AND start_datime < TO_DATE(var_end_date)
	     AND trim(t01.plant_code) = i_plant_code
	     AND t01.sched_vrsn = (SELECT MAX(sched_vrsn) FROM PPS_PLND_PRDN_DETL WHERE trim(plant_code) = i_plant_code)
	   GROUP BY t01.TRAD_UNIT_CODE, 
			      t01.plant_code,
				  sched_qty,
	 		      start_datime,
			      end_datime
      ORDER BY 5; 
			
        /*-*/
		/* do a count against grd materials over the same time frame 
		/* to see if there are any materials that have no GRD equivalent
		/* but ignore any material code that starts with 99....
		/*-*/
   	    CURSOR csr_count IS
	    SELECT t01.trad_unit_code matl_code
          FROM PPS_PLND_PRDN_DETL t01, matl t02
         WHERE TO_CHAR(t01.trad_unit_code) = t02.matl_code(+)
	       AND trim(t01.plant_code) = i_plant_code
		   AND t02.matl_code IS NULL
		   AND SUBSTR(TO_CHAR(t01.trad_unit_code),0,2) <> '99' -- don't bother with materials starting 99 since they are special
		   AND t01.start_datime > TRUNC(SYSDATE) 
	       AND t01.sched_vrsn = (SELECT MAX(sched_vrsn) FROM PPS_PLND_PRDN_vrsn 
								 WHERE trim(plant_code) = trim(t01.plant_code));
								 
								 
      rcd_po csr_po%ROWTYPE;
 	  rcd_count csr_count%ROWTYPE;  
   
   	
  
     
   BEGIN
   		
	    /*-*/
		/* get the schedule end date
		/*-*/
		var_end_date := TO_DATE(NEXT_DAY(TRUNC(SYSDATE),'Sunday') + var_sched_days - 7,'dd/mm/yyyy hh24:mi:ss');
		/*
		var_end_date := var_start_date + var_sched_days;
		
		var_offset := TO_NUMBER(TO_CHAR(var_end_date,'d'));
		IF var_offset = 7 THEN
		    var_offset := 0;
		END IF;
   		var_end_date := TO_DATE(TRUNC(var_end_date) - var_offset,'dd/mm/yyyy hh24:mi');
		*/
		
		/*-*/
		/* set up the common code for trigger and data file
		/*-*/
	    var_serialise_code := SYSDATE;
		/*-*/
		/* setup file suffix and extension
		/*-*/
		var_timestamp := TO_CHAR(SYSDATE,'yyyymmddhh24miss') || '.1';
	
		BEGIN
		
		   /*-*/
		   /*  specify path and file name for remote transfer  
		   /*-*/
		   Manu_Remote_Loader.create_interface (cst_fil_path, cst_fil_name || var_timestamp);

		   OPEN csr_po;
    	   LOOP
       	   FETCH csr_po INTO  rcd_po;
       	   EXIT WHEN csr_po%NOTFOUND;
								
			  /*-*/
		      /*  append records 
			  /*-*/			   
	          Manu_Remote_Loader.append_data('CTL'  || LPAD(Re_Timing_Common.SCHEDULE_CODE,3,'0') 
	                       					|| TO_CHAR(TRUNC(var_serialise_code),'YYYYMMDD')
	              			  				|| TO_CHAR(var_serialise_code,'HH24MISS')
								  			);				   
				
				IF ASCII(RTRIM(LTRIM(SUBSTR(rcd_po.matl_code,1,1)))) >= 48 AND  ASCII(RTRIM(LTRIM(SUBSTR(rcd_po.matl_code,1,1)))) <= 57 THEN
	             -- Alpha start character to material code 
					 var_matl := LPAD(TRIM(rcd_po.matl_code),18,'0');
				ELSE
				    -- numeric value so carry on as normal 
				    var_matl := RPAD(trim(rcd_po.matl_code),18,' ');
				END IF;
				
				Manu_Remote_Loader.append_data('HDR' 
	  		                 					--|| LPAD(TRIM(rcd_po.matl_code),18,'0')
												|| var_matl
				 		        				|| RPAD(TRIM(rcd_po.plant),4,' ')
				 		        				|| RPAD(TRIM(rcd_po.plant),10,' ')
				 				  				|| LPAD(TRIM(rcd_po.qty),15,'0')
				 				  				|| RPAD(TRIM(rcd_po.uom),3,' ')
				 				  				|| RPAD(trim(var_prodn_version),4)
								  				);
														 
				
			   run_start_datime := rcd_po.run_start_datime;	
				run_end_datime := rcd_po.run_end_datime;
				
								   
	         Manu_Remote_Loader.append_data('DET'
	  			 	           				|| '0010' -- operation number 
				 				  			|| '0020' -- superior numbner 
											/*-*/
											/* existing or modified start and end dates for run 
				 				  			/*-*/
											|| TO_CHAR(TRUNC(run_end_datime),'YYYYMMDD')
				 				  			|| TO_CHAR(run_end_datime,'HH24MISS')
				 				  			|| TO_CHAR(TRUNC(run_start_datime),'YYYYMMDD')
				 				  			|| TO_CHAR(run_start_datime,'HH24MISS')
											);
								
				var_count := var_count + 1;
					   
         END LOOP;
         CLOSE csr_po;
	 
	 	  /*-*/
	      /* Close remote loader transfer 
	      /*-*/
         Manu_Remote_Loader.finalise_interface(cst_prc_script || var_timestamp);
		
      EXCEPTION
         WHEN OTHERS THEN
	         IF ( Manu_Remote_Loader.is_created()) THEN
	   	      Manu_Remote_Loader.finalise_interface(cst_prc_script); -- use a dummy command 
	         END IF;
	         RAISE_APPLICATION_ERROR(-20000, 'Send Schedule - Schedule file construction failed - ' || SUBSTR(SQLERRM, 1, 512));
	   END EXECUTE;
		
		BEGIN
		
	      /*-*/
			/* Send the trigger Idoc - this will start a 
			/* batch job within Atlas to update the changes 
			/* Create interface - append data - and close task 
			/*-*/
		   Manu_Remote_Loader.create_interface (cst_fil_path, cst_trig_name || var_timestamp);
		   --DBMS_OUTPUT.PUT_LINE(cst_fil_path || ' - ' || cst_trig_name || var_timestamp);
		   Manu_Remote_Loader.append_data('HDR'
		                				 || RPAD('Z_PRODUCTION_SCHEDULE',32,' ')
							 			 || RPAD(Re_Timing_Common.SCHEDULE_CODE,64,' ') -- address value for Cannery Schedule 
							 			 || RPAD(' ',20,' ')
							 			 || RPAD(TO_CHAR(var_serialise_code,'YYYYMMDDHH24MISS'),20,' ')
							 			 || Re_Timing_Common.SCHEDULE_CODE -- address value for Cannery Schedule 
							 			 || '64'  -- Atlas status 
							 			 || LPAD(TO_CHAR(var_count),6,'0') -- number of schedule records 
							 			 || RPAD('ZIN_MAPP',30,' ') -- idoc type 
							 			 || RPAD('COUNT', 20,' ')
							 			 || '05'
							 			 || '0300' -- delay in seconds 
										 );
							 
         Manu_Remote_Loader.finalise_interface(cst_prc_script1 || var_timestamp);
	  
	  
	  EXCEPTION
	     WHEN OTHERS THEN
           IF ( Manu_Remote_Loader.is_created()) THEN
	   	     Manu_Remote_Loader.finalise_interface(cst_prc_script1); -- use a dummy command 
	        END IF;
			  RAISE;
			-- RAISE_APPLICATION_ERROR(-20000, 'Send Schedule - Trigger command failed  - ' || CHR(13)
			     --  || SUBSTR(SQLERRM, 1, 512) || CHR(13));
	  END;
	  
	  
	  --DBMS_OUTPUT.PUT_LINE('Finished');
	  
	  /*-*/
	  /* update the log table with the serialisation code
	  /*-*/
	  BEGIN
	  
	      /*-*/
			/* insert into the status table 
			/*-*/
			SELECT RE_TIME_STAT_id_seq.NEXTVAL INTO var_seq FROM dual;
			INSERT INTO RE_TIME_STAT  
			VALUES (var_seq,
				 SYSDATE, 
				 'M',
				 'Y',
				 SYSDATE,
				 TO_CHAR(var_serialise_code,'YYYYMMDDHH24MISS'),
				 '',
				 '',
				 '');
					 			
			 COMMIT;
	  
	  EXCEPTION
	      WHEN OTHERS THEN
			    RAISE_APPLICATION_ERROR(-20000, 'Send Schedule - Update RE_TIME_STAT failed - ' || CHR(13)  
		             || SUBSTR(SQLERRM, 1, 512) || CHR(13));
	  END;
	 
	  /*-*/
	  /* now check if any material code loaded into pps tables are not a valid GRD code
	  /*-*/
	  OPEN csr_count;
          LOOP
             FETCH csr_count INTO rcd_count;
             EXIT WHEN csr_count%NOTFOUND;
			     IF LENGTH(var_non_grd) < 200 OR var_non_grd IS NULL THEN
			         var_non_grd := var_non_grd || rcd_count.matl_code || ',';
				 ELSE
				     EXIT;
				 END IF;
          END LOOP;
      CLOSE csr_count;
	 
	  IF var_non_grd IS NOT NULL THEN
	      var_non_grd := SUBSTR(var_non_grd,0,LENGTH(var_non_grd) - 1);
	      Mailout('Scheduled material not found in Plant Database list of active GRD codes.' || CHR(13) 
		           || 'Material code(s) = ' || var_non_grd || CHR(13),
				   '"BTH Schedule Change Control"@esosn1',
				   'Schedule_Send_to_ATLAS',
				   'Invalid material code found in Schedule');
				   
	  END IF;
	  
	EXCEPTION
	   WHEN OTHERS THEN
		  RAISE;
	  
   END EXECUTE; 
	
END Master_Schedule_Send;
/


DROP PUBLIC SYNONYM MASTER_SCHEDULE_SEND;

CREATE PUBLIC SYNONYM MASTER_SCHEDULE_SEND FOR MANU_APP.MASTER_SCHEDULE_SEND;


GRANT EXECUTE ON MANU_APP.MASTER_SCHEDULE_SEND TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.MASTER_SCHEDULE_SEND TO BTHSUPPORT;

