create or replace package manu_app.rd_schedule_send as
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
   1.1        15-Jun-09   Trevor Keon      Configured to send via ICS
******************************************************************************/
 
  procedure execute(i_plant_code in varchar2);

end rd_schedule_send;
/

create or replace package body manu_app.rd_schedule_send as
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
   1.1        15-Jun-09   Trevor Keon      Configured to send via ICS
******************************************************************************/
   
  /*-*/
  /* Variables for ICS interface creation
  /*-*/    
  var_site              varchar2(4);
  var_db_value          varchar2(4);
  var_extension         varchar2(2);
  var_interface         varchar2(100);
  var_msg_name          varchar2(100);
  var_interface_id      number;

  var_vir_table lics_datastore_table := lics_datastore_table();  
  	
  /*-*/
  /* This value defines the interface to send
  /*-*/
  cst_file_name	      constant varchar2(20) := 'CISATL11';
  cst_file_interface  constant varchar2(20) := 'PDBICS11';
  
  cst_trig_name	      constant varchar2(20) := 'CISATL09';
  cst_trig_interface  constant varchar2(20) := 'PDBICS09'; 
  	
  /*-*/
  /* private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
  		
  run_start_datime date;
  run_end_datime date;
  				
  /*-*/
  /* start of process
  /*-*/
  procedure execute(i_plant_code in varchar2) as
  	
    /*-*/
    /* start time based on 7am start and end 
    /* get all active proc orders over the time scale required 
    /*-*/
    cursor csr_po is
      select matl_code, 
        plant_code plant,
        qty, 
        uom, 
        start_datime, 
        end_datime
      from rd_sched;   			
    rcd_po csr_po%rowtype;
              	
    var_prodn_version  varchar2(4)  := '0001';
    var_count          number default 0;
    var_count1         number default 0;
    var_serialise_code date;
    var_timestamp      varchar2(20);
    var_plant_atlas_address varchar2(3);
    var_int_success    boolean;
    		
    cursor csr_atlas_code is
      select max(t01.rd_atlas_code) atlas_code
      from rd_atlas_code t01
      where t01.plant_code = i_plant_code
        and t01.eff_datime < sysdate;
       
  begin

    var_serialise_code := sysdate;
    var_timestamp := to_char(sysdate,'yyyymmddhh24miss') || '.1';
  	
    begin
        		
      /*-*/
      /* Get site specific settings
      /*-*/     
      var_site := lics_app.lics_setting_configuration.retrieve_setting('pdb','site_code');
      
      var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'GR');
      var_db_value := var_vir_table(1).dsv_value;      
      var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'BU');
      var_extension := var_vir_table(1).dsv_value;         
      
      var_interface := cst_file_interface || '.' || var_db_value;
      var_msg_name := cst_file_name || '.' || var_extension;
      var_int_success := false;    
         
      /* each plant has a unique atlas "address code" */
      open csr_atlas_code;
       fetch csr_atlas_code into var_plant_atlas_address;
      close csr_atlas_code;
        		   
      open csr_po;
      loop
        fetch csr_po into  rcd_po;
        exit when csr_po%notfound;
        
        if ( lics_outbound_loader.is_created = false ) then
          var_interface_id := lics_outbound_loader.create_interface(var_interface, null, var_msg_name);
        end if;
          		   						
        /*-*/
        /*  append records 
        /*-*/			   
        lics_outbound_loader.append_data('CTL' || var_plant_atlas_address  
          || to_char(trunc(var_serialise_code),'YYYYMMDD')
          || to_char(var_serialise_code,'HH24MISS'));				   
          				 
        lics_outbound_loader.append_data('HDR' 
          || lpad(trim(rcd_po.matl_code),18,'0')
          || rpad(trim(rcd_po.plant),4,' ')
          || rpad(trim(rcd_po.plant),10,' ')
          || lpad(trim(rcd_po.qty),15,'0')
          || rpad(trim(rcd_po.uom),3,' ')
          || rpad(trim(var_prodn_version),4));          														 
          				
        run_start_datime := rcd_po.start_datime;	
        run_end_datime := rcd_po.end_datime;          				
          								   
        lics_outbound_loader.append_data('DET'
          || '0010' -- operation number 
          || '0020' -- superior numbner 
          || to_char(trunc(run_end_datime),'YYYYMMDD')
          || to_char(run_end_datime,'HH24MISS')
          || to_char(trunc(run_start_datime),'YYYYMMDD')
          || to_char(run_start_datime,'HH24MISS'));
          								
        var_count := var_count + 1;
        					   
      end loop;
      close csr_po;
        	 
      if ( lics_outbound_loader.is_created ) then      
        lics_outbound_loader.finalise_interface;
        var_int_success := true;
      end if;
        		
    exception
      when others then
        if ( lics_outbound_loader.is_created ) then
          lics_outbound_loader.finalise_interface;
        end if;
        raise_application_error(-20000, 'Send Schedule - Schedule file construction failed - ' || substr(sqlerrm, 1, 512));
    end;
  		
    begin
    		
      if ( var_int_success = true ) then        
        var_interface := cst_trig_interface || '.' || var_db_value;
        var_msg_name := cst_trig_name || '.' || var_extension;
        
        /*-*/
        /* send the trigger idoc - this will start a 
        /* batch job within atlas to update the changes 
        /* create interface - append data - and close task 
        /*-*/
        var_interface_id := lics_outbound_loader.create_interface(var_interface, null, var_msg_name);
        		
        lics_outbound_loader.append_data('HDR'
          || rpad('Z_PRODUCTION_SCHEDULE',32,' ')
          || rpad(var_plant_atlas_address,64,' ') -- address value for cannery schedule 
          || rpad(' ',20,' ')
          || rpad(to_char(var_serialise_code,'YYYYMMDDHH24MISS'),20,' ')
          || var_plant_atlas_address -- address value for cannery schedule 
          || '64'  -- atlas status 
          || lpad(to_char(var_count),6,'0') -- number of schedule records 
          || rpad('ZIN_MAPP',30,' ') -- idoc type 
          || rpad('COUNT', 20,' ')
          || '05'
          || '0060'); -- delay in seconds           
        							 
        lics_outbound_loader.finalise_interface;
        			
        /*-*/
        /* update the status table 
        /*-*/
        update re_time_stat  
        set atlas_sent_flag = 'Y',
          atlas_sent_datime = sysdate
        where re_time_start_datime = 
          (
            select max(re_time_start_datime) 
            from re_time_stat
            where  re_time_stat_flag = 'E'
              and atlas_sent_flag is null
          );
        		
        commit;
      
      end if;
      	  
    exception
      when others then
        if ( lics_outbound_loader.is_created ) then
          lics_outbound_loader.finalise_interface; 
        end if;
        raise;
      -- raise_application_error(-20000, 'send schedule - trigger command failed  - ' || chr(13)
      --   || substr(sqlerrm, 1, 512) || chr(13));
    end;    	  
      
  exception
    when others then
      raise;  	  
  end execute; 
  	
end rd_schedule_send;
/

grant execute on manu_app.rd_schedule_send to appsupport;
grant execute on manu_app.rd_schedule_send to bthsupport;

create or replace public synonym rd_schedule_send for manu_app.rd_schedule_send;