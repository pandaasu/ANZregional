DROP PACKAGE MANU_APP.RD_SCHEDULE_SEND;

CREATE OR REPLACE PACKAGE MANU_APP.Rd_Schedule_Send AS
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
 

END Rd_Schedule_Send;
/


DROP PACKAGE BODY MANU_APP.RD_SCHEDULE_SEND;

CREATE OR REPLACE PACKAGE BODY MANU_APP.Rd_Schedule_Send AS
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
******************************************************************************/
   
	/*-*/
	/* Constants used 
	/*-*/
	
   /*-*/
	/* this value defines the interface sand server directory 
	/*-*/
	cst_fil_path	CONSTANT	VARCHAR2(60) := 'MANU_OUTBOUND';
	cst_fil_name	CONSTANT	VARCHAR2(20) := 'CISATL11_';  -- the .1 will be added with the time stamp 
	cst_trig_name  CONSTANT VARCHAR2(20) := 'CISATL09_';  -- the .1 will be added with the time stamp 
	
	/*-*/
	/* Unix command to send the file over MQ series  
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
	
		/*-*/
		/* start time based on 7am start and end 
		/* get ALL active Proc Orders over the time scale required 
		/*-*/
	   CURSOR csr_po IS
		    SELECT matl_code, 
			       plant_code plant,
		  	  	   qty, 
		  	  	   uom, 
		  	  	   start_datime, 
		  	  	   end_datime
	          FROM RD_SCHED;
				 
			
        rcd_po csr_po%ROWTYPE;
   
   	
   	    var_prodn_version  VARCHAR2(4)  := '0001';
		var_count          NUMBER DEFAULT 0;
		var_count1          NUMBER DEFAULT 0;
		var_serialise_code DATE;
		var_timestamp      VARCHAR2(20);
		var_plant_atlas_address VARCHAR2(3);
		
		CURSOR csr_atlas_code
		IS
		SELECT MAX(t01.RD_ATLAS_CODE) atlas_code
 		  FROM RD_ATLAS_CODE t01
		 WHERE t01.plant_code = i_plant_code
 		   AND t01.EFF_DATIME < SYSDATE;
     
   BEGIN

	    var_serialise_code := SYSDATE;
		var_timestamp := TO_CHAR(SYSDATE,'yyyymmddhh24miss') || '.1';
		
		
	
		BEGIN
		
		   /*-*/
		   /*  specify path and file name for remote transfer  
		   /*-*/
		   Manu_Remote_Loader.create_interface (cst_fil_path, cst_fil_name || var_timestamp);
 
 		   /* Each plant has a unique Atlas "Address code" */
		   OPEN csr_atlas_code;
               FETCH csr_atlas_code INTO var_plant_atlas_address;
           CLOSE csr_atlas_code;
		   
		   OPEN csr_po;
    	   LOOP
       	   FETCH csr_po INTO  rcd_po;
       	   EXIT WHEN csr_po%NOTFOUND;
		   						
				/*-*/
		      /*  append records 
				/*-*/			   
	         Manu_Remote_Loader.append_data('CTL' || var_plant_atlas_address  
	                       				 || TO_CHAR(TRUNC(var_serialise_code),'YYYYMMDD')
	              			  			 || TO_CHAR(var_serialise_code,'HH24MISS')
								  		 );				   
				 
	         Manu_Remote_Loader.append_data('HDR' 
	  		                 			 || LPAD(TRIM(rcd_po.matl_code),18,'0')
				 		        		 || RPAD(TRIM(rcd_po.plant),4,' ')
				 		        		 || RPAD(TRIM(rcd_po.plant),10,' ')
				 				  		 || LPAD(TRIM(rcd_po.qty),15,'0')
				 				  		 || RPAD(TRIM(rcd_po.uom),3,' ')
				 				  		 || RPAD(trim(var_prodn_version),4)
								  		 );
														 
				
			   run_start_datime := rcd_po.start_datime;	
				run_end_datime := rcd_po.end_datime;
				
								   
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
         Manu_Remote_Loader.finalise_interface(cst_prc_script  || var_timestamp);
		
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
							 			|| RPAD(var_plant_atlas_address,64,' ') -- address value for Cannery Schedule 
							 			|| RPAD(' ',20,' ')
							 			|| RPAD(TO_CHAR(var_serialise_code,'YYYYMMDDHH24MISS'),20,' ')
							 			|| var_plant_atlas_address -- address value for Cannery Schedule 
							 			|| '64'  -- Atlas status 
							 			|| LPAD(TO_CHAR(var_count),6,'0') -- number of schedule records 
							 			|| RPAD('ZIN_MAPP',30,' ') -- idoc type 
							 			|| RPAD('COUNT', 20,' ')
							 			|| '05'
							 			|| '0060' -- delay in seconds 
										);
							 
         Manu_Remote_Loader.finalise_interface(cst_prc_script1 || var_timestamp);
			
			/*-*/
			/* update the status table 
			/*-*/
			UPDATE RE_TIME_STAT  
			   SET atlas_sent_flag = 'Y',
			       atlas_sent_datime = SYSDATE
			 WHERE re_time_start_datime = (SELECT MAX(re_time_start_datime) 
			 		 							 	FROM RE_TIME_STAT
			   								   WHERE  re_time_stat_flag = 'E'
												   AND atlas_sent_flag IS NULL);
		
			COMMIT;
	  
	  EXCEPTION
	     WHEN OTHERS THEN
           IF ( Manu_Remote_Loader.is_created()) THEN
	   	     Manu_Remote_Loader.finalise_interface(cst_prc_script1); -- use a dummy command 
	        END IF;
			  RAISE;
			 -- RAISE_APPLICATION_ERROR(-20000, 'Send Schedule - Trigger command failed  - ' || CHR(13)
			     --   || SUBSTR(SQLERRM, 1, 512) || CHR(13));
	  END;
	  
  
	EXCEPTION
	   WHEN OTHERS THEN
		  RAISE;
	  
   END EXECUTE; 
	
END Rd_Schedule_Send;
/


DROP PUBLIC SYNONYM RD_SCHEDULE_SEND;

CREATE PUBLIC SYNONYM RD_SCHEDULE_SEND FOR MANU_APP.RD_SCHEDULE_SEND;


GRANT EXECUTE ON MANU_APP.RD_SCHEDULE_SEND TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RD_SCHEDULE_SEND TO BTHSUPPORT;

