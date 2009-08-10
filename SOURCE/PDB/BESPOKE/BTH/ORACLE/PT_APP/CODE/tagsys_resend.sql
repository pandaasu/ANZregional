create or replace package pt_app.tagsys_resend as
/******************************************************************************
  NAME:       TAGSYS_RESEND
  PURPOSE:    This set of procedures is used to re-create and resend 
             interface-files for HU's.  There is a separate procedure for
             each specific type of HU interface file. (ATLAS, TOLAS_FDS or
             TOLAS_LTDS).  
                 
             The list of HU's to send must be entered into the respective
             table shown below:
                 
             ResendAtlas sends HU's in RESEND_HU_ATLAS to Altas only
             ResendTolasFDS sends HU's in RESEND_HU_TOLAS_FDS to Tolas FDS only
             ResendTolasLTDS sends HU's in RESEND_HU_TOLAS_LTDS to Tolas LTDS only
                 
             The HU's listed in the tables above to resend must exist already
             in plt_hdr and plt_det (ie, they have already been created but
             the sending has failed for some reason)
                 
             The two Tolas procedures will use the seq number already recorded
             in plt_tolas if the HU is found in there - otherwise they will use
             the next seq value.

  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        30/05/2007  Daniel Owen      1. Created this package.
                                     this affecets creat and cancel plts
  1.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr
******************************************************************************/
 
  procedure resendatlas;
  procedure resendtolasltds;
  procedure resendtolasfds;
  
end tagsys_resend;
/

create or replace package body pt_app.tagsys_resend as

  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send a GR Pallet data 
  			
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.    
  1.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr
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
  1.1        11/06/2009  Trevor Keon      1. Changed to use pt_cisatl17_gr  				
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

  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send an LTDS-GR Pallet data 
  				
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.
  2.0        31/01/2007  Daniel Owen      2. Modified for sending LTDS only for existing HU's
  ******************************************************************************/
  function sendltdsgr(i_plt_code in varchar2) return number is
			 
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
        begin        
          select tolas_seq 
          into v_seq 
          from plt_tolas 
          where plt_code = i_plt_code;
        exception
          when others then
            select plt_tolas_seq.nextval 
            into v_seq 
            from dual;
            
            insert into plt_tolas
            values 
            (
              i_plt_code, 
              v_seq
            );
        end;
								
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
  end sendltdsgr;

  function sendltdsrgr(i_plt_code in varchar2) return number is
  begin
    /* at time of writing, this type of file not sent */
    return 1;
  end sendltdsrgr;

  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send a FDS GR Pallet data 
  				
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
  2.0        31/01/2007  Daniel Owen      2. Modified for sending FDS only for existing HU's
  ******************************************************************************/
  function sendfdsgr(i_plt_code in varchar2) return number is

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
        begin        
          select tolas_seq 
          into v_seq 
          from plt_tolas 
          where plt_code = i_plt_code;
        exception
          when others then
            select plt_tolas_seq.nextval 
            into v_seq 
            from dual;
            
            insert into plt_tolas
            values 
            (
              i_plt_code, 
              v_seq
            );
        end;
								
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
  end sendfdsgr;
  
  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send a GR Pallet data 
  			
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
  				
  ******************************************************************************/  
  function sendfdsrgr(i_plt_code in varchar2) return number is

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
          begin        
            select tolas_seq 
            into v_seq 
            from plt_tolas 
            where plt_code = i_plt_code;
          exception
            when others then
              select plt_tolas_seq.nextval 
              into v_seq 
              from dual;
              
              insert into plt_tolas
              values 
              (
                i_plt_code, 
                v_seq
              );
          end;	   	   		
        												
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
  end sendfdsrgr;

  procedure resendatlas as
  
    v_success  number;
    v_create   number;
    v_cancel   number;
    
    cursor csr_resend is
      select d.*, 
        h.matl_code, 
        h.qty qty , 
        zpppi_batch as batch 
      from plt_det d, 
        plt_hdr h
      where h.plt_code in (select plt_code from resend_hu_atlas) 
        and h.plt_code = d.plt_code
      order by 1,2,3 desc;          
    rcd_resend csr_resend%rowtype;

  begin
    v_create := 0;
    v_cancel := 0;
          
    /*first check if the sending of idocs has been disabled
    /*-*/
    if not idoc_hold then
      open csr_resend;
      loop
        fetch csr_resend into rcd_resend;
        exit when csr_resend%notfound;
                  
        if rcd_resend.reason = 'CREATE' then
          v_success := sendgr(rcd_resend.plt_code);
          dbms_output.put('ATLAS_GR: ');
          v_create := v_create + 1;
        else
          /* otherwise cancel pallet */
          v_success := sendrgr(rcd_resend.plt_code);
          dbms_output.put('ATLAS_RGR: ');
          v_cancel := v_cancel + 1;
        end if;
                  
        if v_success = 0 then
          dbms_output.put_line (rcd_resend.plt_code || ' OK');
        else
          dbms_output.put_line (rcd_resend.plt_code || ' FAILED');
        end if;
                
      end loop;
      close csr_resend;
    end if; --not idoc_hold
          
    dbms_output.put_line('CREATES: ' || v_create);
    dbms_output.put_line('CANCELS: ' || v_cancel);
  end resendatlas;

  procedure resendtolasltds as

  v_success  number;
  v_create   number;
  v_cancel   number;
    
  cursor csr_resend is
    select d.*, 
      h.matl_code, 
      h.qty qty , 
      zpppi_batch as batch 
    from plt_det d, 
      plt_hdr h
    where h.plt_code in (select plt_code from resend_hu_tolas_ltds) 
      and h.plt_code = d.plt_code
    order by 1,2,3 desc;        
  rcd_resend csr_resend%rowtype;
  
  begin
    v_create := 0;
    v_cancel := 0;
          
    /*first check if the sending of idocs has been disabled
    /*-*/
    if not idoc_hold then
      open csr_resend;
      loop
        fetch csr_resend into rcd_resend;
        exit when csr_resend%notfound;
                  
        if rcd_resend.reason = 'CREATE' then
          v_success := sendltdsgr(rcd_resend.plt_code);
          dbms_output.put('LTDS_GR: ');
          v_create := v_create + 1;
        else
          /* otherwise cancel pallet */
          v_success := sendltdsrgr(rcd_resend.plt_code);
          dbms_output.put('LTDS_RGR: ');
          v_cancel := v_cancel + 1;
        end if;
                  
        if v_success = 0 then
          dbms_output.put_line (rcd_resend.plt_code || ' OK');
        else
          dbms_output.put_line (rcd_resend.plt_code || ' FAILED');
        end if;
                
      end loop;
      close csr_resend;
    end if;
    dbms_output.put_line('CREATES: ' || v_create);
    dbms_output.put_line('CANCELS: ' || v_cancel);
  end resendtolasltds;

  procedure resendtolasfds as
  
  v_success  number;
  v_create   number;
  v_cancel   number;
    
  cursor csr_resend is
    select d.*, 
      h.matl_code, 
      h.qty qty , 
      zpppi_batch as batch 
    from plt_det d, 
      plt_hdr h
    where h.plt_code in (select plt_code from resend_hu_tolas_fds) 
      and h.plt_code = d.plt_code
    order by 1,2,3 desc;        
  rcd_resend csr_resend%rowtype;

  begin
    v_create := 0;
    v_cancel := 0;
          
    /*first check if the sending of idocs has been disabled
    /*-*/
    if not idoc_hold then
      open csr_resend;
      loop
        fetch csr_resend into rcd_resend;
        exit when csr_resend%notfound;
                  
        if rcd_resend.reason = 'CREATE' then
          v_success := sendfdsgr(rcd_resend.plt_code);
          dbms_output.put('FDS_GR: ');
          v_create := v_create + 1;
        else
          /* otherwise cancel pallet */
          v_success := sendfdsrgr(rcd_resend.plt_code);
          dbms_output.put('FDS_RGR: ');
          v_cancel := v_cancel + 1;
        end if;
                  
        if v_success = 0 then
          dbms_output.put_line (rcd_resend.plt_code || ' OK');
        else
          dbms_output.put_line (rcd_resend.plt_code || ' FAILED');
        end if;
                  
      end loop;
      close csr_resend;
    end if;
          
    dbms_output.put_line('CREATES: ' || v_create);
    dbms_output.put_line('CANCELS: ' || v_cancel);
  end resendtolasfds;
    
  end tagsys_resend;
/