create or replace package pt_app.re_process_tolas as
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
  2.1        11/06/2009  Trevor Keon      1. Formatted Code                                       
  ******************************************************************************/
  
  procedure checksendsplt;

end re_process_tolas;
/

create or replace package body pt_app.re_process_tolas as
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
  2.1        11/06/2009  Trevor Keon      1. Formatted Code                                       
  ******************************************************************************/
  
  resend_max   constant number  := 5;
  			
  /*-*/
  /* this value defines the interface sand server directory 
  /*-*/
  cst_fil_path	constant	varchar2(60) := 'MANU_OUTBOUND';
			

  /*********************************************
  Raise email notification of error
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
  ******************************************************************************/             
  function sendgr (i_plt_code in varchar2) return number is
				 
    v_success      number;
    o_result         number;
    o_result_msg     varchar2(2000);
    v_seq          number;
    				                                                                                  
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
      if length(i_plt_code) > 10 and length(ltrim(rcd.matl_code,'0')) = 8 then
        /*-*
        /* get a sequence number for the tolas interface
        /*-*/
        select plt_tolas_seq.nextval 
        into v_seq 
        from dual;  							     
  									
        /*-*/
        /* only for plant codes cannery and bathurst 
        /*-*/
        if rcd.plant_code = 'AU20'  or  rcd.plant_code = 'AU30' then		       
					 
          tolas_fds_send
          (
            o_result,
            o_result_msg,
            'Z_PI1',
            rcd.plant_code,
            rcd.sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
            false,
            rcd.proc_order,
            trunc(rcd.xactn_date),
            to_number(to_char(rcd.xactn_date,'HH24MISS')),
            rcd.matl_code,
            rcd.qty,
            upper(rcd.uom),
            to_number(rcd.stor_locn_code),
            rcd.dispn_code,
            rcd.zpppi_batch, 
            to_char(rcd.use_by_date,'YYYYMMDD'),
            rcd.plt_code,
            rcd.plt_type,
            'CHEP',
            trunc(rcd.start_prodn_datime),
            to_number(to_char(rcd.start_prodn_datime, 'hh24miss')),
            trunc(rcd.end_prodn_datime),
            to_number(to_char(rcd.end_prodn_datime, 'hh24miss')),
            v_seq
          );
        end if;
								
        tolas_ltds_send
        (
          o_result,
          o_result_msg,
          'Z_PI1',
          rcd.plant_code,
          rcd.matl_code,
          rcd.qty,
          rcd.dispn_code,
          rcd.zpppi_batch,
          to_char(rcd.use_by_date,'YYYYMMDD'),
          rcd.plt_code,
          v_seq
        );
								  
        insert into plt_tolas
        values 
        (
          i_plt_code, 
          v_seq
        );
								   
        dbms_output.put_line('Seq code =' || v_seq);
      								
      end if;					       
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
  				
  ******************************************************************************/
  function sendrgr (i_plt_code in varchar2) return number is
			
    v_success      number;
    v_type		   varchar2(10);
    v_seq		   number;
    o_result       number;
    o_result_msg   varchar2(2000);                 
                                                                             
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
      
      if length(i_plt_code) > 10 and length(ltrim(rcd.matl_code,'0')) = 8 then
        						   
        								
        /*-*/
        /* only for plant codes cannery and bathurst 
        /*-*/
        if rcd.plant_code = 'AU20'  or  rcd.plant_code = 'AU30' then
          /*-*
          /* get a sequence number for the tolas interface
          /*-*/
          select plt_tolas_seq.nextval 
          into v_seq 
          from dual;
          					   	   		
          												
          /*-*/
          /* send the fds file to tolas
          /* this file is based on plant and will be assigned to a different queue for the 2 plant codes
          /* defined in the if statement
          /*-*/
          tolas_fds_send
          (
            o_result,
            o_result_msg,
            v_type,
            rcd.plant_code,
            rcd.sender_name || ':' || substr(i_plt_code,1,18), 
            false,
            rcd.proc_order,
            trunc(rcd.xactn_date),
            to_number(to_char(rcd.xactn_date,'HH24MISS')),
            rcd.matl_code,
            rcd.qty,
            rcd.uom,
            rcd.stor_locn_code,
            rcd.dispn_code,
            rcd.zpppi_batch,
            to_char(rcd.use_by_date,'YYYYMMDD'),
            i_plt_code,
            rcd.plt_type,
            'CHEP',
            trunc(sysdate), -- dummy entry 
            0, 			    -- dummy entry 
            trunc(sysdate), -- dummy entry 
            0, 			    -- dummy entry 
            to_char(lpad(v_seq,8,'0'))
          );
                                      
          insert into plt_tolas
          values 
          (
            i_plt_code, 
            v_seq
          );
        								
        end if;
      end if;                
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
  /* this procedure will check for any palet records not sent  to Tolas and will forward them 
  /*-*/  
  procedure checksendsplt is

    v_count    number;
    v_success  number;
    
    cursor csr_chk is
      select
        h.*, 
        dt.reason
      from plt_tolas d, 
        plt_hdr h, 
        plt_det dt
      where length(matl_code) = 8
        and dt.plt_code = h.plt_code
        and length(h.plt_code) > 12
        and h.plt_code = d.plt_code(+)
        and substr(proc_order,1,2) <> '99'
        and d.plt_code is null 
      order by 1,2,3 desc;        
    rcd_chk csr_chk%rowtype;
     
  begin      
    /*-*/
    /* check any create and cancel pallets for a send error 
    /*-*/          
    open csr_chk;
    loop
      fetch csr_chk into rcd_chk;
      exit when csr_chk%notfound;
      dbms_output.put_line ('plt code=' || rcd_chk.plt_code);
                  
      if upper(rcd_chk.reason) = 'CREATE' then
        v_success := sendgr(rcd_chk.plt_code);
      else
        /*-*/
        /* otherwise cancel pallet 
        /*-*/
        v_success := sendrgr(rcd_chk.plt_code);
      end if;			  
    end loop;    			 
    close csr_chk;    			 
    commit;  
           
  exception
    when others then
      rollback;
      raisenotification('ERROR OCCURED - <Re_Process_Tolas.CheckSendsPlt> ' || chr(13) ||substr(sqlerrm,0,255));    
  end;
		 
end re_process_tolas;
/

create or replace public synonym re_process_tolas for pt_app.re_process_tolas;