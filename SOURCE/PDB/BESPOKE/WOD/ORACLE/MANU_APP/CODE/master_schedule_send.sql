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
   1.1        25-Feb-09   Daniel Owen      Updated to support schedule resending
******************************************************************************/

 
  PROCEDURE EXECUTE(i_plant_code IN VARCHAR2, i_resend IN NUMBER DEFAULT 0);
 

END Master_Schedule_Send;
/


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
					

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        21-Sep-05   Jeff Phillipson  Created this package body.
   1.1        25-Feb-09   Daniel Owen      Updated to support schedule resending
******************************************************************************/
   
	/*-*/
	/* Constants used 
	/*-*/
	
    /*-*/
	/* this value defines the schedule window in days 
	/*-*/
	
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
   
    PROCEDURE EXECUTE(i_plant_code IN VARCHAR2, i_resend IN NUMBER DEFAULT 0)
	AS
	
		var_prodn_version    VARCHAR2(4)  := '0001';
		var_count            NUMBER DEFAULT 0;
		var_serialise_code   DATE;
		var_timestamp        VARCHAR2(20);
		var_matl 			 VARCHAR2(32);
		var_seq				 NUMBER;
		var_sched_days       NUMBER DEFAULT Re_Timing_Common.SCHEDULE_DAYS;
    var_start_date       DATE DEFAULT TO_DATE(Re_Timing.GET_FIRM('AU20'),'dd/mm/yyyy hh24:mi');
    var_end_date         DATE;
    MESSAGE_CODE VARCHAR(3);	 
	 
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
		     PPS_PLND_PRDN_vrsn t06
       WHERE t01.SCHED_VRSN = t06.SCHED_VRSN
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
			
      rcd_po csr_po%ROWTYPE;
     
   BEGIN

	    /*-*/
		/* get the schedule end date
		/*-*/
		var_end_date := TO_DATE(NEXT_DAY(TRUNC(SYSDATE),'Sunday') + var_sched_days - 7,'dd/mm/yyyy hh24:mi:ss');
			
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
       
        /* Message codes and start date are different between normal sends and resends */
        /* The type of send is determined by the value of the i_resend (optional) parameter */
        /* i_resend defaults to 0 if not supplied */
        IF i_resend = 0 THEN -- First Send (Use "normal message codes")
           MESSAGE_CODE := CASE i_plant_code
              WHEN 'AU20' THEN Re_Timing_Common.SCHEDULE_CODE_AU20
              WHEN 'AU21' THEN Re_Timing_Common.SCHEDULE_CODE_AU21
              WHEN 'AU22' THEN Re_Timing_Common.SCHEDULE_CODE_AU22
              WHEN 'AU25' THEN Re_Timing_Common.SCHEDULE_CODE_AU25
           END;
        ELSE -- Resend. (Use alternate message codes and modify startdate)
           MESSAGE_CODE := CASE i_plant_code
              WHEN 'AU20' THEN Re_Timing_Common.SCHEDULE_RESEND_CODE_AU20
              WHEN 'AU21' THEN Re_Timing_Common.SCHEDULE_RESEND_CODE_AU21
              WHEN 'AU22' THEN Re_Timing_Common.SCHEDULE_RESEND_CODE_AU22
              WHEN 'AU25' THEN Re_Timing_Common.SCHEDULE_RESEND_CODE_AU25
           END;
            -- Schedule resends must skip an extra day (compared to first schedule send) to avoid newly converted process orders 
            var_start_date := var_start_date + 1;
        END IF;
 
		   OPEN csr_po;
    	   LOOP
       	   FETCH csr_po INTO  rcd_po;
       	   EXIT WHEN csr_po%NOTFOUND;
								
			 /*-*/
		     /*  append records 
			 /*-*/
      
	            Manu_Remote_Loader.append_data('CTL' || LPAD(MESSAGE_CODE,3,'0') 
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
       
              Manu_Remote_Loader.append_data('HDR'
		                				 || RPAD('Z_PRODUCTION_SCHEDULE',32,' ')
							 			 || RPAD(MESSAGE_CODE,64,' ') -- address value for Cannery Schedule 
							 			|| RPAD(' ',20,' ')
							 			|| RPAD(TO_CHAR(var_serialise_code,'YYYYMMDDHH24MISS'),20,' ')
							 			|| RPAD(MESSAGE_CODE,3,' ')
										/* address value for Cannery Schedule */
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
	   
	  
	EXCEPTION
	   WHEN OTHERS THEN
		  RAISE;
	  
   END EXECUTE; 
	
END Master_Schedule_Send;
/

create or replace public synonym master_schedule_send for manu_app.master_schedule_send;
grant execute on manu_app.master_schedule_send to appsupport;