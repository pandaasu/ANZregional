create or replace package master_schedule_send as
/******************************************************************************
   NAME:              MASTER_SCHEDULE_SEND
   PURPOSE:       		The MASTER_SCHEDULE_SEND package sends a copy of the medium term
                      schedule into SAP. The medium term schedule lies in a window of
                      time that starts from the end of the RTT frozen window, and ends 2
                      weeks after next sunday.
                     
                      The schedule can be sent :
                      1. Automatically. Each day the EXECUTE procedure is run as a 
                      scheduled Oracle job. The scheduling of the Oracle job is 
                      controlled by the NEXT_DATE standalone function which uses the 
                      timings entered in the WNDW_TIME and EXT_WNDW_TIME fields in 
                      the RTT_WNW_TIME table.
                      
                      2. Manually. The Bathurst scheduler can also send the schedule 
                      on demand, using the Bathurst Schedule on Demand application.
                      
                      In both instances, the send is triggered by the EXECUTE procedure,  
                      and will only send the schedule to SAP if the RTT frozen window is 
                      a maximum of 2 days in width.
                      
                      How the send works :
                      1. The items scheduled in the medium term schedule window are retrieved.
                         from the PS schema.
                      2. This data is exported using the remote file loader called MANU_REMOTE_LOADER.
                      3. A trigger file is generated. The trigger file is linked to the data file via
                         the var_serialise_code. The trigger file and data file must arrive in SAP
                         within 30 minutes of each other, otherwise SAP will not process the data.
                      4. The data and trigger files are then transferred via MQ, ICS, the HUB and onto
                         SAP.
  Additional Notes :
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
   1.0        14-Sep-05   Jeff Phillipson  Created this package.
   1.2		    05-Nov-08	  Chris Munn       Prevent Schedule from sending if window
                                  			   width is greater than 2.
   1.3        01-APR-09   Chris Munn       Added functionality to allow users to send
                                           the schedule to SAP on demand.                      
*******************************************************************************/
 
  procedure execute(i_plant_code in varchar2, i_demand_send in number default 0);
  procedure check_if_authorised(i_user_id in varchar2, o_constraint_met out number);
  procedure check_start_constraint(o_constraint_met out number);
  procedure check_end_constraint(o_constraint_met out number);
  procedure check_interval_constraint(o_constraint_met out number);
  procedure check_window_constraint(o_constraint_met out number);
  procedure get_constraint_details(o_window_time out varchar2, o_first_demand_send out varchar2, o_demand_master_offset out number, o_demand_send_interval out number, o_last_send out date);
  function get_last_demand_send_time return date;
  procedure notify_users(i_user_id in varchar2, i_site in varchar2, i_database in varchar2, i_system_type in varchar2);
end master_schedule_send;
/

create or replace package body master_schedule_send as
/******************************************************************************
   NAME:              MASTER_SCHEDULE_SEND
   PURPOSE:       		The MASTER_SCHEDULE_SEND package sends a copy of the medium term
                      schedule into SAP. The medium term schedule lies in a window of
                      time that starts from the end of the RTT frozen window, and ends 2
                      weeks after next sunday.
                     
                      The schedule can be sent :
                      1. Automatically. Each day the EXECUTE procedure is run as a 
                      scheduled Oracle job. The scheduling of the Oracle job is 
                      controlled by the NEXT_DATE standalone function which uses the 
                      timings entered in the WNDW_TIME and EXT_WNDW_TIME fields in 
                      the RTT_WNW_TIME table.
                      
                      2. Manually. The Bathurst scheduler can also send the schedule 
                      on demand, using the Bathurst Schedule on Demand application.
                      
                      In both instances, the send is triggered by the EXECUTE procedure,  
                      and will only send the schedule to SAP if the RTT frozen window is 
                      a maximum of 2 days in width.
                      
                      How the send works :
                      1. The items scheduled in the medium term schedule window are retrieved.
                         from the PS schema.
                      2. This data is exported using the remote file loader called MANU_REMOTE_LOADER.
                      3. A trigger file is generated. The trigger file is linked to the data file via
                         the var_serialise_code. The trigger file and data file must arrive in SAP
                         within 30 minutes of each other, otherwise SAP will not process the data.
                      4. The data and trigger files are then transferred via MQ, ICS, the HUB and onto
                         SAP.
  Additional Notes :
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
   1.0        14-Sep-05   Jeff Phillipson  Created this package.
   1.2		    05-Nov-08	  Chris Munn       Prevent Schedule from sending if window
                                  			   width is greater than 2.
   1.3        01-APR-09   Chris Munn       Added functionality to allow users to send
                                           the schedule to SAP on demand.                      
*******************************************************************************/
   
	/*-*/
	/* Constants used 
	/*-*/
	
   /*-*/
	/* this value defines the schedule window in days 
	/*-*/
	--cst_Offset      CONSTANT NUMBER(2)    := 2;
	cst_fil_path	    constant	varchar2(60) := 'MANU_OUTBOUND';
	cst_fil_name	    constant	varchar2(20) := 'CISATL11_';  -- the .1 will be added with the time stamp 
	cst_trig_name     constant  varchar2(20) := 'CISATL09_';  -- the .1 will be added with the time stamp
  cst_sched_group   constant  varchar2(32) := 'MASTER_SCHED_SEND';   
	
	/*-*/
	/* unix command to send the file over mq series - not workinyg yet 
	/*-*/
  cst_prc_script	  constant	varchar2(100):= '/manu/prod/bin/send_file.sh -f ' || cst_fil_name;
	cst_prc_script1   constant	varchar2(100):= '/manu/prod/bin/send_file.sh -f ' || cst_trig_name;
	
	/*-*/
  /* private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
		
	run_start_datime date;
	run_end_datime date;
				
	/*-*/
	/* Start of process
	/*-*/
  procedure execute(i_plant_code in varchar2, i_demand_send in number default 0) as
  	
    var_prodn_version    varchar2(4)  := '0001';
    var_count            number default 0;
    var_serialise_code   date;
    var_timestamp        varchar2(20);
    var_matl 			       varchar2(32);
    var_seq				       number;
    var_sched_days       number default re_timing_common.schedule_days;
    var_start_date       date default to_date(re_timing.get_firm('AU30'),'dd/mm/yyyy hh24:mi');
    var_end_date         date;
    var_offset           number;
    var_non_grd			     varchar2(4000) default '';
    var_message_code     varchar(3);
    var_send_type_flag   char;
    	 
    /*-*/
    /* start time based on 7am start and end 
    /* get all active materials over the time scale required 
    /*-*/
    cursor csr_po is
      select t01.trad_unit_code matl_code, 
        trim(t01.plant_code) plant,
        sched_qty qty, 
        'EA' uom, 
        round(start_datime,'mi') run_start_datime, 
        round(end_datime,'mi') run_end_datime
      from pps_plnd_prdn_detl t01,
        pps_plnd_prdn_vrsn t06,
        matl t02
      where t01.sched_vrsn = t06.sched_vrsn
        and to_char(t01.trad_unit_code) = t02.matl_code
        and end_datime  - start_datime > 0
        and start_datime >= to_date(var_start_date) 
        -- end date will be based on the last day of the week 
        and start_datime < to_date(var_end_date)
        and trim(t01.plant_code) = i_plant_code
        and t01.sched_vrsn = (select max(sched_vrsn) from pps_plnd_prdn_detl where trim(plant_code) = i_plant_code)
      group by t01.trad_unit_code, 
        t01.plant_code,
        sched_qty,
        start_datime,
        end_datime
      order by 5; 
    					
    /*-*/
    /* do a count against grd materials over the same time frame 
    /* to see if there are any materials that have no grd equivalent
    /* but ignore any material code that starts with 99....
    /*-*/
    cursor csr_count is
      select t01.trad_unit_code matl_code
      from pps_plnd_prdn_detl t01, matl t02
      where to_char(t01.trad_unit_code) = t02.matl_code(+)
        and trim(t01.plant_code) = i_plant_code
        and t02.matl_code is null
        and substr(to_char(t01.trad_unit_code),0,2) <> '99' -- don't bother with materials starting 99 since they are special
        and t01.start_datime > trunc(sysdate) 
        and t01.sched_vrsn = (select max(sched_vrsn) from pps_plnd_prdn_vrsn where trim(plant_code) = trim(t01.plant_code));
    								 
    								 
    rcd_po csr_po%rowtype;
    rcd_count csr_count%rowtype;  
  begin
    -- only send the schedule if the length of the frozen window is 2 days or less.
    if var_start_date - trunc(sysdate) <= 2 then
      /*-*/
      /* get the schedule end date
      /*-*/
      var_end_date := to_date(next_day(trunc(sysdate),'Sunday') + var_sched_days - 7,'dd/mm/yyyy hh24:mi:ss');
      /*
      var_end_date := var_start_date + var_sched_days;
                  
      var_offset := to_number(to_char(var_end_date,'d'));
      if var_offset = 7 then
      var_offset := 0;
      end if;
      var_end_date := to_date(trunc(var_end_date) - var_offset,'dd/mm/yyyy hh24:mi');
      */
                  
      /*-*/
      /* set up the common code for trigger and data file
      /*-*/
      var_serialise_code := sysdate;
      /*-*/
      /* setup file suffix and extension
      /*-*/
      var_timestamp := to_char(sysdate,'yyyymmddhh24miss') || '.1';
                
      --added by chris munn 26-03-2009
      --if a schedule on demand send has been initiated
      if (i_demand_send = 1) then
        --use the message code associated with a schedule on demand send.
        var_message_code := re_timing_common.on_demand_schedule_code;
        --use the flag associated with the schedule on demand send.
        var_send_type_flag := 'D';
        --otherwise a regular send has been initiated.
      else
        --use the message code associated with a regular schedule send.
        var_message_code := re_timing_common.schedule_code;
        --use the flag associated with the regular send.
        var_send_type_flag := 'M';
      end if;
                  
      begin
        /*-*/
        /*  specify path and file name for remote transfer  
        /*-*/
        manu_remote_loader.create_interface (cst_fil_path, cst_fil_name || var_timestamp);
                       
        open csr_po;
        loop
          fetch csr_po into  rcd_po;
          exit when csr_po%notfound;
                                  
          /*-*/
          /*  append records 
          /*-*/			   
          manu_remote_loader.append_data('CTL'  || lpad(var_message_code,3,'0') 
                                  || to_char(trunc(var_serialise_code),'YYYYMMDD')
                                  || to_char(var_serialise_code,'HH24MISS')
                                );				   
                                  
          if ascii(rtrim(ltrim(substr(rcd_po.matl_code,1,1)))) >= 48 and  ascii(rtrim(ltrim(substr(rcd_po.matl_code,1,1)))) <= 57 then
            -- alpha start character to material code 
            var_matl := lpad(trim(rcd_po.matl_code),18,'0');
          else
            -- numeric value so carry on as normal 
            var_matl := rpad(trim(rcd_po.matl_code),18,' ');
          end if;
                                      
          manu_remote_loader.append_data('HDR' 
                                      --|| lpad(trim(rcd_po.matl_code),18,'0')
                           || var_matl
                           || rpad(trim(rcd_po.plant),4,' ')
                           || rpad(trim(rcd_po.plant),10,' ')
                           || lpad(trim(rcd_po.qty),15,'0')
                           || rpad(trim(rcd_po.uom),3,' ')
                           || rpad(trim(var_prodn_version),4)
                         );
                                                           
           run_start_datime := rcd_po.run_start_datime;	
           run_end_datime := rcd_po.run_end_datime;
                                                   
           manu_remote_loader.append_data('DET'
                           || '0010' -- operation number 
                           || '0020' -- superior numbner 
                           /*-*/
                           /* existing or modified start and end dates for run 
                             /*-*/
                           || to_char(trunc(run_end_datime),'YYYYMMDD')
                           || to_char(run_end_datime,'HH24MISS')
                           || to_char(trunc(run_start_datime),'YYYYMMDD')
                           || to_char(run_start_datime,'HH24MISS')
                          );
                                              
           var_count := var_count + 1;
                               
        end loop;
        close csr_po;
                     
        /*-*/
        /* close remote loader transfer 
        /*-*/
        manu_remote_loader.finalise_interface(cst_prc_script || var_timestamp);
                      
      exception
        when others then
          if ( manu_remote_loader.is_created()) then
            manu_remote_loader.finalise_interface(cst_prc_script); -- use a dummy command 
          end if;
          raise_application_error(-20000, 'Send Schedule - Schedule file construction failed - ' || substr(sqlerrm, 1, 512));
      end execute;
                    
      begin
                    
        /*-*/
        /* send the trigger idoc - this will start a 
        /* batch job within atlas to update the changes 
        /* create interface - append data - and close task 
        /*-*/
        manu_remote_loader.create_interface (cst_fil_path, cst_trig_name || var_timestamp);
        --dbms_output.put_line(cst_fil_path || ' - ' || cst_trig_name || var_timestamp);
        manu_remote_loader.append_data('HDR'
                                || rpad('Z_PRODUCTION_SCHEDULE',32,' ')
                                || rpad(var_message_code,64,' ') -- address value for cannery schedule 
                                || rpad(' ',20,' ')
                                || rpad(to_char(var_serialise_code,'YYYYMMDDHH24MISS'),20,' ')
                                || var_message_code -- address value for cannery schedule 
                                || '64'  -- atlas status 
                                || lpad(to_char(var_count),6,'0') -- number of schedule records 
                                || rpad('ZIN_MAPP',30,' ') -- idoc type 
                                || rpad('COUNT', 20,' ')
                                || '05'
                                || '0300' -- delay in seconds 
                              );
                                 
        manu_remote_loader.finalise_interface(cst_prc_script1 || var_timestamp);
                      
                      
      exception
        when others then
          if ( manu_remote_loader.is_created()) then
              manu_remote_loader.finalise_interface(cst_prc_script1); -- use a dummy command 
          end if;
          raise;
            -- raise_application_error(-20000, 'send schedule - trigger command failed  - ' || chr(13)
              --  || substr(sqlerrm, 1, 512) || chr(13));
      end;
                    
                    
      --dbms_output.put_line('finished');
                    
      /*-*/
      /* update the log table with the serialisation code
      /*-*/
      begin
        /*-*/
        /* insert into the status table 
        /*-*/
        select re_time_stat_id_seq.nextval into var_seq from dual;        
        insert into re_time_stat  
        values 
        (
          var_seq,
          sysdate, 
          var_send_type_flag,
          'Y',
          sysdate,
          to_char(var_serialise_code,'YYYYMMDDHH24MISS'),
          '',
          '',
          ''
        );
                                
        commit;
                    
      exception
        when others then
          raise_application_error(-20000, 'Send Schedule - Update RE_TIME_STAT failed - ' || chr(13)  
            || substr(sqlerrm, 1, 512) || chr(13));
      end;
                   
      /*-*/
      /* now check if any material code loaded into pps tables are not a valid grd code
      /*-*/
      open csr_count;
      loop
        fetch csr_count into rcd_count;
        exit when csr_count%notfound;
          if length(var_non_grd) < 200 or var_non_grd is null then
            var_non_grd := var_non_grd || rcd_count.matl_code || ',';
          else
            exit;
          end if;
      end loop;
      close csr_count;
                   
      if var_non_grd is not null then
        var_non_grd := substr(var_non_grd,0,length(var_non_grd) - 1);
        mailout('Scheduled material not found in Plant Database list of active GRD codes.' || chr(13) 
            || 'Material code(s) = ' || var_non_grd || chr(13),
            '"BTH Schedule Change Control"@esosn1',
            'Schedule_Send_to_ATLAS',
            'Invalid material code found in Schedule');                           
      end if;      		  
    end if;    		  
  exception
    when others then
      raise;
  		  
  end execute; 

  /*******************************************************************************************
    The CHECK_START_CONSTRAINT procedure determines if the current system time is before  
    after the time specified in the FIRST_DEMAND_SEND field in the RTT_WNDW_TIME table. 
    Ad-hoc sends before this time are not permitted. If the current system time is earlier 
    than the time specified in the FIRST_DEMAND_SEND field, a 1 is returned indicating that the
    constraint has not been met. If the system time is later than this time a 0 is returned indicating
    that the constraing has been met.
  ********************************************************************************************/
    
  procedure check_start_constraint(o_constraint_met out number) as
  begin
    
    -- retrieve the time specified in the first_demand_send field in the rtt_wndw_time table, and subtract the current
    -- system date and time from this value. if the result is greater than 0, then it is before the specified time. if the result
    -- is less than 0 it is after the specified time.
        
    select 
      case 
        when to_date(to_char(trunc(sysdate),'dd-mon-yyyy') || first_demand_send,'dd-Mon-yyyy HH24:MI') - sysdate > 0 then 1
        else 0 
      end into o_constraint_met
    from rtt_wndw_time 
    where wndw_date in 
      -- make sure that the most recent valid entry is retrieved from rtt_wndw_time
      (
        select max(wndw_date) 
        from rtt_wndw_time 
        where wndw_date <= sysdate
      );
              
  exception
    when others then
      -- return an error if the constraint could not be determined.
      raise_application_error(-20000, 'There was a problem determining the start constraint.');
      o_constraint_met := 1;

  end check_start_constraint;
  
    /*******************************************************************************************
    The CHECK_END_CONSTRAINT procedure ensures that the schedule when sent on demand, is not sent
    at a time too close to the time that the master schedule send will be sent to Atlas. The
    RTT_WNDW_TIME table contains a field called DEMAND_MASTER_OFFSET. This is the amount of
    time (in minutes) that must separate the master and demand schedule sends.
    ********************************************************************************************/
  
  procedure check_end_constraint(o_constraint_met out number) as
    var_sqlstmt varchar2(1000);
  begin
    --  build the sql to determine if the current time is before or after the last permitted time for an demand schedule send
    var_sqlstmt := 'SELECT CASE WHEN TO_DATE(TO_CHAR(TRUNC(SYSDATE),''dd-mon-yyyy'') || ';
          
    -- if today is not a day off and tomorrow is the start of a block of days off
    if (re_timing.is_day_off(sysdate) = false) and (re_timing.get_off_block_length(sysdate) >= 2) then
      -- retrieve the extended time at which the master scheduled send is run.
      var_sqlstmt := var_sqlstmt || 'ext_wndw_time';
    else
      -- otherwise retrieve the regular time at which the master schedule send is run
      var_sqlstmt := var_sqlstmt || 'wndw_time';
    end if;
     
    -- determine if the demand_master_offset threshold has been reached (the time at which the master schedule will run 
    -- minus the value (in minutes) in the demand_master_offset field). if this constraint has been met, return 0 otherwise
    -- return 1.
    var_sqlstmt := var_sqlstmt || ',''dd-Mon-yyyy HH24:MI'') - demand_master_offset/1440 - SYSDATE  > 0 THEN 0';
    var_sqlstmt := var_sqlstmt || ' ELSE 1 END';
    var_sqlstmt := var_sqlstmt || ' FROM RTT_Wndw_time WHERE Wndw_Date IN';
    var_sqlstmt := var_sqlstmt || ' (SELECT MAX(wndw_date) FROM RTT_Wndw_time WHERE Wndw_date <= SYSDATE)';
          
    execute immediate var_sqlstmt
    into o_constraint_met;
            
  exception
    when others then
      -- return an error if the constraint could not be determined.
      raise_application_error(-20000, 'There was a problem determining the end constraint.');
      o_constraint_met := 1;

  end check_end_constraint;

  /*******************************************************************************************
    The CHECK_END_CONSTRAINT procedure ensures that the demand schedule sends cannot be sent
    too frequently. The RTT_WNDW_TIME table contains a DEMAND_SEND_INTERVAL field that stipulates
    the number of minutes that mast pass between demand sends.
  ********************************************************************************************/
    
  procedure check_interval_constraint(o_constraint_met out number) as
    var_demand_send_interval number;
  begin
      
    --determine the time and date that the schedule was last sent on demand.
    select demand_send_interval into var_demand_send_interval
    from rtt_wndw_time
    --only retrieve the most recent valid entry from rtt_wndw_time
    where wndw_date in
      (
        select max(wndw_date) 
        from rtt_wndw_time 
        where wndw_date <= sysdate
      );
          
    --determine if the amount of time in minutes, contained in the var_demand_send_interval variable have
    --passed since the last time the schedule was sent on demand has passed. if sufficient time has passed
    --constraint_met will be set to 0 indicating that the constraint has been met. if enough time has not passed 
    --1 will be assigned to constraint_met indicating that the required amount of time has not passed since the last
    --time the schedule was sent on demand.
    select 
      case 
        when max(re_time_start_datime) + var_demand_send_interval / 1440 - sysdate > 0 then 1
        else 0 
      end into o_constraint_met
    from re_time_stat
    where re_time_stat_flag = 'D';
          
    exception
      when others then
        -- return an error if the constraint could not be determined.
        raise_application_error(-20000, 'There was a problem determining the interval constraint.');
        o_constraint_met := 1;
        
  end check_interval_constraint;
  
  /*******************************************************************************************
    The CHECK_WINDOW_CONSTRAINT procedure ensures that the demand schedule sends will only
    be sent when the Frozen Window has a width of two days. o_constraint_met is set to 0 if 
    the window is currently 2 days or less in width. o_constraint_met is set to 1 if the window
    is currently more than 2 days wide.
  ********************************************************************************************/
  
  procedure check_window_constraint(o_constraint_met out number) as
    var_start_date  date default to_date(re_timing.get_firm('AU30'),'dd/mm/yyyy hh24:mi');
  begin
    
    if var_start_date - trunc(sysdate) <= 2 then
      o_constraint_met := 0;
    else
      o_constraint_met := 1;
    end if;
        
  end check_window_constraint;
    
   /*******************************************************************************************
    The CHECK_IF_AUTHORISED procedure verifies that a user belongs to the 'BTH_SCHEDULER' db role. 
    If they do they are permitted to send the schedule, and the application will launch. If they are
    not permitted to send the schedule, the application will not load. A 0 will be returned
    if a user is not authorsed.
    ********************************************************************************************/
     
  procedure check_if_authorised(i_user_id in varchar2, o_constraint_met out number) as
    var_user_found number;
  begin
    
    --find any entries where the user in i_user_id has been granted the pr_admin role.
    select count(*) into var_user_found
    from dba_role_privs
    where lower(grantee) = lower(i_user_id)
      and granted_role = 'BTH_SCHEDULER';
          
    --if a an entry for the given user was found with the required role. they are authorsied and the constraint
    --has been met. return 0. 
    if var_user_found > 0 then
      o_constraint_met := 0;
    else
      --otherwise the user is not authorised. and the constraint has not been met. return 1.
      o_constraint_met := 1;
    end if;
          
    exception
      --always indicate a failed constraint if there was a problem retrieving user data.
      when others then
        o_constraint_met := 1;
     
  end check_if_authorised;
  
  /**********************************************************************************
    The GET_CONSTRAINT_DETAILS procedure retrieves the constraints that have been
    entered into the RTT_WNDW_TIME table to control when and how often the 
    schedule can be sent on demand.
  ***********************************************************************************/
  procedure get_constraint_details(o_window_time out varchar2, o_first_demand_send out varchar2, o_demand_master_offset out number, o_demand_send_interval out number, o_last_send out date) as
    var_sqlstmt varchar2(1000);
  begin

    -- build the sql to to retrieve the 
    -- 1. current window time
    -- 2. the earliest time the schedule is allowed to be sent within a day.
    -- 3. the latest time in the day the schedule is allowed to be sent.
    -- 4. the interval in minutes that must elaps between each send.

    -- build the sql to retrieve the current send on demand constraints
    var_sqlstmt := 'SELECT ';
          
    -- if today is not a day off and tomorrow is the start of a block of days off
    if (re_timing.is_day_off(sysdate) = false) and (re_timing.get_off_block_length(sysdate) >= 2) then
      -- retrieve the extended time at which the master scheduled send is run.
      var_sqlstmt := var_sqlstmt || 'ext_wndw_time';
    else
      -- otherwise retrieve the regular time at which the master schedule send is run
      var_sqlstmt := var_sqlstmt || 'wndw_time';
    end if;
     
    -- retrieve the first time within a day the schedule can be sent to sap, the number of minutes before the 
    -- master schedule send that the scedule can be sent, and thefrequencey at which the schedule can be sent to sap.
    var_sqlstmt := var_sqlstmt || ', first_demand_send, demand_master_offset, demand_send_interval';
    var_sqlstmt := var_sqlstmt || ' FROM RTT_Wndw_time';
    var_sqlstmt := var_sqlstmt || ' WHERE first_demand_send IS NOT NULL';
    var_sqlstmt := var_sqlstmt || ' AND demand_master_offset IS NOT NULL';
    var_sqlstmt := var_sqlstmt || ' AND demand_send_interval IS NOT NULL';
    var_sqlstmt := var_sqlstmt || ' AND wndw_date IN';
    var_sqlstmt := var_sqlstmt || ' (SELECT MAX(wndw_date) FROM RTT_Wndw_time WHERE Wndw_date <= SYSDATE)';
          
    -- execute the dynamic sql statement.
    execute immediate var_sqlstmt into o_window_time, o_first_demand_send, o_demand_master_offset, o_demand_send_interval;
          
    -- retrieve the last time that the schedule was sent.    
    o_last_send := get_last_demand_send_time;

  exception
    when others then
      -- return an error if the constraint could not be determined.
      raise_application_error(-20000, 'There was a problem retrieving constraint details.');
  end get_constraint_details;
   
  /*****************************************************************
    The GET_LAST_DEMAND_SEND_TIME function retrieves the last time
    the schedule was sent on demand.
  ******************************************************************/
  
  function get_last_demand_send_time return date as
    var_last_send date;
  begin
    select max(re_time_start_datime) into var_last_send
    from re_time_stat
    where re_time_stat_flag = 'D';
            
    return var_last_send;
          
  exception
    when others then
      -- return an error if the constraint could not be determined.
      raise_application_error(-20000, 'There was a problem with last send details');
  end get_last_demand_send_time;
 
  /*****************************************************************
    The NOTIFY_USERS procedure sends an email to a group of key users
    who need to be aware that the schedule has been sent on 
    demand.
    ***************************************************************/

  procedure notify_users(i_user_id in varchar2, i_site in varchar2, i_database in varchar2, i_system_type in varchar2) as
    var_source_email varchar2(200);
    var_target_email varchar2(200);  
  begin
  
    var_source_email := lics_setting_configuration.retrieve_setting(cst_sched_group, 'SOURCE_EMAIL');
    var_target_email := lics_setting_configuration.retrieve_setting(cst_sched_group, 'TARGET_EMAIL');
      
    lics_mailer.create_email(var_source_email,var_target_email, i_system_type  || ' Send from ' || i_site || ' ' || i_database || ' : Schedule Sent on Demand at ' || 
            to_char(sysdate, 'HH24:MI') || ' on ' || to_char(sysdate, 'DD/MON/YYYY'),null,null);
    lics_mailer.create_part(null);
    lics_mailer.append_data('**' || i_system_type  || ' SEND** Please be advised that the ' || i_site || ' schedule was sent on demand from the ' || 
            i_system_type || ' plant database (' || i_database || ') to SAP ' || i_system_type || ' at ' || to_char(sysdate, 'HH24:MI') ||
            ' on ' || to_char(sysdate, 'DD/MON/YYYY') || ' by user ' || i_user_id);
    lics_mailer.append_data(' ');
    lics_mailer.append_data('Please be aware this will impact the MRP and orders for the ' || i_site || ' site.');
    lics_mailer.append_data(' ');
    lics_mailer.append_data('Please do not reply to this email.');
    lics_mailer.finalise_email;

  exception
    when others then
      -- return an error if the email could not be sent.
      raise_application_error(-20000, 'A notification email could not be sent.');                                     
  end notify_users;   
  	
end master_schedule_send;

grant execute on manu_app.master_schedule_send to appsupport;
grant execute on manu_app.master_schedule_send to bthsupport;
grant execute on manu_app.master_schedule_send to bth_scheduler;

create or replace public synonym master_schedule_send for manu_app.master_schedule_send;