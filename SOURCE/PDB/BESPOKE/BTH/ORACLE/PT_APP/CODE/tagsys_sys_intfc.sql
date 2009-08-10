create or replace package pt_app.tagsys_sys_intfc as
  /******************************************************************************
  NAME:       TAGSYS_SYS_INTFC
  PURPOSE:		This set of procedures will check for any unsent records 
    and will re process the messages to Atlas 

  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this package.
  2.0		     07/03/2006  Jeff Phillipson	1. Update for HaU (handling units) adedd 
                                             this affecets creat and cancel plts
  2.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr
  ******************************************************************************/

  procedure checksendsplt; 
  procedure checksendsconsumption;
  
end tagsys_sys_intfc;
/

create or replace package body pt_app.tagsys_sys_intfc as
  /******************************************************************************
  NAME:       TAGSYS_SYS_INTFC
  PURPOSE:		This set of procedures will check for any unsent records 
    and will re process the messages to Atlas 

  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this package.
  2.0		     07/03/2006  Jeff Phillipson	1. Update for HaU (handling units) adedd 
                                             this affecets creat and cancel plts
  2.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr                                             
  ******************************************************************************/

  resend_max   constant number  := 5;
  			
  /*-*/
  /* this value defines the interface sand server directory 
  /*-*/
  cst_fil_path	constant	varchar2(60) := 'MANU_OUTBOUND';

  /*********************************************
  raise email notification of error
  **********************************************/
  procedure raisenotification(message in varchar2) is
       
    var_message varchar2(4000);
           
  begin
    var_message := message;
    mailout(var_message);
  exception
    when others then
      var_message := message;
  end;
     
       
  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send a GR Pallet data 
  			
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.    
  2.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr   
  ******************************************************************************/        
  function sendgr (i_plt_code in varchar2) return number is
			 
    v_success      number;
    o_result         number;
    o_result_msg     varchar2(2000);                   
                                                                               
    cursor c_p is
      select h.*, 
        reason, 
        xactn_date, 
        xactn_time,
        sender_name, 
        user_id
      from plt_hdr h, 
        plt_det d
      where h.plt_code = d.plt_code
        and d.plt_code = i_plt_code
        and d.reason = 'CREATE';                   
    rcd c_p%rowtype;
                
  begin
                   
    open c_p;
    loop
      fetch c_p into rcd;
      exit when c_p%notfound;
      
      pt_cisatl17_gr.execute
      (
        o_result, 
        o_result_msg,
        'Z_PI1', 
        rcd.plant_code,
        rcd.sender_name || ':' || substr(rcd.plt_code,1,18), --rcd.sender_name, 
        false,
        to_number(rcd.proc_order),
        rcd.xactn_date,
        rcd.xactn_time, 
        rcd.matl_code,
        rcd.qty, 
        rcd.uom,
        to_number(rcd.stor_locn_code), 
        rcd.dispn_code,
        rcd.zpppi_batch, 
        false,
        to_char(rcd.use_by_date,'YYYYMMDD'),
        rcd.plt_code,
        rcd.plt_type,
        'CHEP',
        trunc(rcd.start_prodn_datime),
        to_number(to_char(rcd.start_prodn_datime, 'hh24miss')),
        trunc(rcd.end_prodn_datime),
        to_number(to_char(rcd.end_prodn_datime, 'hh24miss'))
      );
				  
      exit;   
    end loop;
    close c_p;
                       
    return o_result;
                       
  exception
    when no_data_found then
      null;
    when others then
      -- consider logging the error and then re-raise
      raise;
  end sendgr;

  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send a GR Pallet data 
  				
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.    
  2.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr   				
  ******************************************************************************/
  function sendrgr (i_plt_code in varchar2) return number is

    v_success      number;
    v_type			varchar2(10);
    o_result         number;
    o_result_msg     varchar2(2000);
                                                                           
    cursor c_p is
      select h.*, 
        reason, 
        xactn_date, 
        xactn_time,
        sender_name, 
        user_id
      from plt_hdr h, 
        plt_det d
      where h.plt_code = d.plt_code
        and d.plt_code = i_plt_code
        and d.reason = 'CANCEL';                   
    rcd c_p%rowtype;
                   
  begin
                   
    o_result  := 0;
                    
    if length(rcd.plt_code) > 12 then
      /*-*/
      /* set type as pallet if the pallet code is a full 18 chars long 
      /*-*/
      v_type := 'Z_PI6';
    else
      /*-*/
      /* otherwise this is a process record 
      /*-*/
      v_type := 'Z_PI2';
    end if;
    					 
    open c_p;
    loop
      fetch c_p into rcd;
      exit when c_p%notfound;
      
      pt_cisatl17_gr.execute
      (
        o_result, 
        o_result_msg,
        v_type, 
        rcd.plant_code,
        rcd.sender_name || ':' || substr(rcd.plt_code,1,18), --rcd.sender_name, 
        false,
        to_number(rcd.proc_order),rcd.xactn_date,
        rcd.xactn_time, rcd.matl_code,
        rcd.qty, rcd.uom,
        to_number(rcd.stor_locn_code), rcd.dispn_code,
        rcd.zpppi_batch, false,
        to_char(rcd.use_by_date,'YYYYMMDD'),
        rcd.plt_code,
        rcd.plt_type,
        'CHEP',
        trunc(rcd.start_prodn_datime),
        to_number(to_char(rcd.start_prodn_datime, 'hh24miss')),
        trunc(rcd.end_prodn_datime),
        to_number(to_char(rcd.end_prodn_datime, 'hh24miss'))
      );
                                             
      exit;   
    end loop;
    close c_p;
      
    return o_result;
  exception
    when no_data_found then
      o_result := 1;    				      
    when others then
      -- consider logging the error and then re-raise 
      o_result := 1;
      raise;
  end sendrgr;
 
  /*-*/
  /* this procedure will check for any palet records not sent to atlas and will forward them 
  /*-*/  
  procedure checksendsplt is

  v_count    number;
  v_success  number;
        
  cursor csr_chk is
    select d.*, 
      h.matl_code, 
      h.qty qty , 
      zpppi_batch batch 
    from plt_det d, 
      plt_hdr h
    where sent_flag is null
      and h.plt_code = d.plt_code
    order by 1,2,3 desc;      
  rcd_chk csr_chk%rowtype;
    
  begin
        
    /*-*/
    /* only resend data if there is more than 1 plt waiting
    /* temp fix for the issue of one being sent -by the normal process but not finished
    /*-*/
    select count(*) 
    into v_count
    from plt_det 
    where sent_flag is null;
  	  
    /*-*/
    /* check any create and cancel pallets for a send error 
    /*first check if the sending of idocs has been disabled
    /*-*/
    if not idoc_hold and v_count > 1 then
          
      open csr_chk;
      loop
        fetch csr_chk into rcd_chk;
        exit when csr_chk%notfound;                     
                    
        if rcd_chk.reason = 'CREATE' then
          v_success := sendgr(rcd_chk.plt_code);
        else
          /*-*/
          /* otherwise cancel pallet 
          /*-*/
          v_success := sendrgr(rcd_chk.plt_code);
        end if;                   
                        
        if v_success = 0 then
        				  
          update plt_det 
          set sent_flag = 'Y'
          where plt_code = rcd_chk.plt_code
            and reason = rcd_chk.reason;
          						  
          update plt_idoc_log 
          set status = 'Sent'
          where plt_code = rcd_chk.plt_code
            and xactn_type = rcd_chk.reason;
          						  
          dbms_output.put_line (rcd_chk.plt_code || 'OK');
          					  
        else
          				  
          select count(*) 
          into v_count
          from plt_idoc_log
          where plt_code = rcd_chk.plt_code
            and xactn_type = rcd_chk.reason;
                                 
          if v_count = 1 then
            select resend_count 
            into v_count
            from plt_idoc_log
            where plt_code = rcd_chk.plt_code
              and xactn_type = rcd_chk.reason;
            								
            update plt_idoc_log 
            set resend_count = v_count + 1
            where plt_code = rcd_chk.plt_code 
              and xactn_type = rcd_chk.reason;
          else
            v_count := 0;
          end if;           
        						  
          if v_count >= 5 then
            -- send email notification
            raisenotification(v_count + 1 || ' attempts to send a pallet via the interface Idoc have failed. Plt code = ' || rcd_chk.plt_code);
          end if;
        end if;
        				  
      end loop;
      			 
      close csr_chk;
      			 
      commit;
    end if;  
            
  exception
    when others then
      rollback;
      raisenotification('ERROR OCCURED - <Tagsys_Sys_Intfc.CheckSendsPlt> ' || chr(13) ||sqlerrm);    
  end;
		
  /*-*/
  /* this procedure will check for any consumption records not sent to atlas 
  /* and will forward them grouped by proc order, material and trans type
  /*-*/     
  procedure checksendsconsumption is

    v_count    				 number default 0;
    v_success  				 number default 0;
    v_result_msg  			 varchar2(2000);
    v_transaction_type 		 varchar2(100);
    v_ids					 varchar2(4000) default '''';
    v_qty					 number default 0;
    v_counter				 number default 0;
    v_string_count			 number default 0;  
   	
    /*-*/
    /* retrieve the cursor of grouped material, proc orders and trans type
    /* this will minimise the sending of descrete materials to atlas
    /* this will reduce the number of transmissions to atlas
    /* and will be run on a scheduled job every 30mis.
    /*-*/
    cursor csr_chk is
      select  t01.*, 
        rownum as id
      from plt_cnsmptn t01
      where sent_flag is  null 
        and substr(proc_order,1,2) <> '99'
      order by 2,3, trans_type;    	  	 
    rcd_chk csr_chk%rowtype;       -- used to store current record
    rcd_chk_last csr_chk%rowtype;  -- used to store last record
 
  begin
    	   
    /*-*/
    /* check any create and cancel pallets for a send error 
    /*-*/ 
    open csr_chk;
    loop
      fetch csr_chk into rcd_chk;
      exit when csr_chk%notfound;
      
      v_counter := v_counter + 1;
      
      if v_counter = 1 then
        rcd_chk_last := rcd_chk;
      end if;
    		   
      begin
      					
        if rcd_chk_last.proc_order <> rcd_chk.proc_order
          or rcd_chk_last.matl_code <> rcd_chk.matl_code
          or rcd_chk_last.trans_type <> rcd_chk.trans_type then
        				   
          /*-*/
          /* get trans type 
          /*-*/
          if rcd_chk_last.trans_type = 'CREATE' then
            v_transaction_type := 'ZPI_CONS';
          else
            v_transaction_type := 'Z_PI4';
          end if;
    					 
          /*-*/
          /* make call to create idoc 
          /*-*/
          if v_qty > 0 then          
            pt_cisatl17_gr.execute
            (
              v_success,
              v_result_msg,
              v_transaction_type,
              rcd_chk_last.plant_code,
              '',
              false,
              rcd_chk_last.proc_order,
              trunc(sysdate),
              to_number(to_char(sysdate,'HH24') || to_char(sysdate,'MI') || '00') ,
              rcd_chk_last.matl_code,
              v_qty,
              upper(rcd_chk_last.uom),
              rcd_chk_last.store_locn,
              '',
              '',
              false,
              0,
              '',
              '',
              '',
              trunc(sysdate), -- dummy entry 
              0, -- dummy entry 
              trunc(sysdate), -- dummy entry 
              0 -- dummy entry 
            );    								
          end if;
    					
          if v_success = 0 then
    					    
            v_ids := substr(v_ids, 0, length(v_ids)-2); -- remove the trailing comma
            			            
            /*-*/
            /* insert the sent flag into the table entries for the selected group of records
            /*-*/
            execute immediate 'UPDATE PLT_CNSMPTN ' || ' SET sent_flag = ''Y'' ' || ' WHERE TO_CHAR(trim(PLT_CNSMPTN_id)) IN (' || v_ids || ')';
          				      	
          end if;
          
          /*-*/
          /* reset the values to blank
          /*-*/
          v_ids := '''';
          v_qty := 0;
          v_string_count := 0;
        end if;
        
        /*-*/
        /* commit the 1 record
        /*-*/
        commit;
    				
      exception
        when others then
          rollback;
      end;
    			
      if length(v_ids) < 3900 and v_string_count < 300 then
        v_string_count := v_string_count + 1;	
        v_ids := v_ids || to_char(rcd_chk.plt_cnsmptn_id) || ''',''';  
        v_qty := v_qty + rcd_chk.qty;  
      end if;
    			
      /*-*/
      /* make the last record = the ciurrent record
      /*-*/
      rcd_chk_last := rcd_chk;    			
    end loop;
    
    /*-*/
    /* send the last record here
    /*-*/
    if v_counter > 0 then
      /*-*/
      /* get trans type 
      /*-*/
      if rcd_chk_last.trans_type = 'CREATE' then
        v_transaction_type := 'ZPI_CONS';
      else
        v_transaction_type := 'Z_PI4';
      end if;
      
      /*-*/
      /* make call to create idoc 
      /*-*/
      if v_qty > 0 then
        pt_cisatl17_gr.execute
        (
          v_success,
          v_result_msg,
          v_transaction_type,
          rcd_chk_last.plant_code,
          '',
          false,
          rcd_chk_last.proc_order,
          trunc(sysdate),
          to_number(to_char(sysdate,'HH24') || to_char(sysdate,'MI') || '00') ,
          rcd_chk_last.matl_code,
          v_qty,
          upper(rcd_chk_last.uom),
          rcd_chk_last.store_locn,
          '',
          '',
          false,
          0,
          '',
          '',
          '',
          trunc(sysdate), -- dummy entry 
          0, -- dummy entry 
          trunc(sysdate), -- dummy entry 
          0 -- dummy entry 
        );      								
      end if;
      								
      if v_success = 0 then
      			    
        v_ids := substr(v_ids, 0, length(v_ids)-2); -- remove the trailing comma
        		           
        /*-*/
        /* insert the sent flag into the table entries for the selected group of records
        /*-*/
        execute immediate 'UPDATE PLT_CNSMPTN ' 
        || ' SET sent_flag = ''Y'' ' 
        || ' WHERE TO_CHAR(trim(PLT_CNSMPTN_id)) IN (' || v_ids || ')';
      				      	
      end if;
            
    end if;
    close csr_chk;
    			 
    commit;		    
    		 
  exception
    when others then
      raisenotification('CreateSendsConsumption failed. Proc order = ' || rcd_chk_last.proc_order
        || chr(13) || ' Matl Code = ' || rcd_chk_last.matl_code
        || chr(13) || 'Oracle error end ' || substr(sqlerrm, 1, 512));
      rollback;
  end;
end tagsys_sys_intfc;
/

grant execute on pt_app.tagsys_sys_intfc to appsupport;
grant execute on pt_app.tagsys_sys_intfc to bthsupport;

create or replace public synonym tagsys_sys_intfc for pt_app.tagsys_sys_intfc;