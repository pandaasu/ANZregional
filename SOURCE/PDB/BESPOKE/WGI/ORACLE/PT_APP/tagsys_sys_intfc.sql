create or replace package pt_app.tagsys_sys_intfc_ics As
/******************************************************************************
   NAME:       tagsys_sys_intfc_ics
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson  1. Created this package.
   1.1        03/12/2008  Trevor Keon      2. Modified to use pt_cisatl17_gr_ics 
                                            for sending interface
******************************************************************************/

  procedure checksendsplt;
  procedure checksendssto;
  procedure checksendsdisposition;  
  
end tagsys_sys_intfc_ics;

create or replace package body pt_app.tagsys_sys_intfc_ics as

  resend_max   constant number  := 5;

  /*********************************************
  RAISE email notification OF error
  **********************************************/
  procedure raisenotification(message in varchar2) is
    /*-*/
    /* Variables
    /*-*/        
    var_message varchar2(4000);
           
  begin
    var_message := message;
    mailout(var_message);
  exception
    when others then
      var_message := message;
  end;
     
             
  function sendgr ( i_plt_code in varchar2) return number is
  /******************************************************************************
  NAME:       SendGR
  PURPOSE:    This function will send a GR Pallet data 
      
  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
  ******************************************************************************/
    /*-*/
    /* Variables
    /*-*/      
    var_result          number;
    var_result_msg      varchar2(2000);                   
                                                                               
    cursor c_p is
      select h.*, 
        reason, 
        xactn_date, 
        xactn_time,
        sender_name, 
        user_id
      from plt_hdr h, plt_det d
      where h.plt_code = d.plt_code
        and d.plt_code = i_plt_code
        and d.reason = 'CREATE';                     
    rcd c_p%rowtype;               
              
  begin
                 
    open c_p;   
    fetch c_p into rcd;
    
    if ( c_p%found ) then
      pt_cisatl17_gr_ics.execute
      (
        var_result,
        var_result_msg,
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
        null,
        null,
        null,
        null,
        null,
        null,
        null
      );                                         
    end if;
    
    close c_p;                       
    return var_result;
                   
  exception
    when no_data_found then
      null;
    when others then
      -- consider logging the error and then re-raise
      raise;
  end sendgr;
  
  function sendrgr ( i_plt_code in varchar2) return number is 
  /******************************************************************************
   NAME:       SendGR
   PURPOSE:    This function will send a GR Pallet data 
      
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/01/2005  Jeff Phillipson  1. Created this function.     
      
  ******************************************************************************/
    /*-*/
    /* Variables
    /*-*/   
    var_result          number;
    var_result_msg      varchar2(2000);
                                                                                                      
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
                   
    var_result  := 0;
                     
    open c_p;                        
    fetch c_p into rcd;
    
    if ( c_p%found ) then
    
      dbms_output.put_line ('Z44');
      
      pt_cisatl17_gr_ics.execute
      (
        var_result, 
        var_result_msg,
        'Z_PI2', 
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
        null,
        null,
        null,
        null,
        null,
        null,
        null
      );                                           
    end if;
    
    close c_p;
    return var_result;
    
  exception
    when no_data_found then
      null;
    when others then
      -- consider logging the error and then re-raise
      raise;
  end sendrgr;

  procedure checksendsplt is      
    /*-*/
    /* Variables
    /*-*/ 
    var_count    number;
    var_success  number;
      
    cursor c_chk is
      select d.*, 
        h.matl_code, 
        h.qty qty, 
        zpppi_batch as batch 
      from plt_det d, 
        plt_hdr h
      where sent_flag is null
        and h.plt_code = d.plt_code
      order by 1,2,3 desc;        
    r_chk c_chk%rowtype;
    
  begin
    /* check any Create and Cancel Pallets for a send error 
    || first CHECK IF the sending OF Idocs has been disabled
    */
    if ( not idoc_hold ) then
          
      open c_chk;
      loop
        fetch c_chk into r_chk;
        exit when c_chk%notfound;                 
                
        if ( r_chk.reason = 'CREATE' ) then
          var_success := sendgr(r_chk.plt_code);
        else
          var_success := sendrgr(r_chk.plt_code);
        end if;
                                     
        -- send email notification
        raisenotification('Found A pallet not sent via the Idoc.' || r_chk.plt_code);
                              
        if ( var_success = 0 ) then
          update plt_det set sent_flag = 'Y'
          where plt_code = r_chk.plt_code
            and reason = r_chk.reason;
        else
          select count(*) 
          into var_count
          from plt_idoc_log
          where plt_code = r_chk.plt_code
            and xactn_type = r_chk.reason;
                               
          if ( var_count = 1 ) then
            select resend_count 
            into var_count
            from plt_idoc_log
            where plt_code = r_chk.plt_code
              and xactn_type = r_chk.reason;
          else
            var_count := 0;
          end if;
                         
          update plt_idoc_log 
          set resend_count = var_count + 1
          where plt_code = r_chk.plt_code 
            and xactn_type = r_chk.reason;
        end if;
      end loop;
      
    close c_chk;
    commit;
    
    end if;  
        
  exception
    when others then
      rollback;
      raisenotification('ERROR OCCURED - <tagsys_sys_intfc_ics.CheckSendsPlt> ' || chr(13) || sqlerrm);    
  end;
  
  procedure checksendssto  is 
  /******************************************************************************
   NAME:       CheckSendsSTO
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/02/2005   Jeff Phillipson 1. Created this procedure.
  ******************************************************************************/
    /*-*/
    /* Variables
    /*-*/ 
    var_interface_type    varchar2(10) := 'CISATL04.1'; 
    var_stock_status      varchar2(1);
    var_result_msg        varchar2(2000);
    
    var_intfc_rtn         number(15,0);
    var_line              number;
    var_count             number;
    var_success           number;        
    var_result            number;
        
    process_exception exception;
    idoc_exception exception;

    cursor c_chk is
      select h.*
      from sto_det d, 
        sto_hdr h
      where sent_flag is null 
        and mesg_status = 'E'
        and h.cnn = d.cnn
      order by 1,2,3 desc;        
    r_chk c_chk%rowtype;      
        
    cursor c_sto is
      select d.cnn,
        matl_code, 
        uom, 
        sum(qty) as qty, 
        stock_status, 
        batch,
        dest_plant, 
        deliv_date, 
        decode(deliv_time, null, 0, deliv_time) as deliv_time,
        d.plt_code
      from sto_det d, 
        sto_hdr h
      where h.cnn = d.cnn
        and h.cnn = r_chk.cnn
      group by d.cnn, 
        matl_code, 
        uom, 
        stock_status, 
        batch, 
        dest_plant, 
        deliv_date, 
        decode(deliv_time, null, 0, deliv_time), 
        d.plt_code
      order by batch;              
    rcd c_sto%rowtype;

  begin
      
    if not idoc_hold then

      -- check any create and cancel pallets for a send error 
      var_result := 0; 
       
      open c_chk;
      loop
        fetch c_chk into r_chk;
        exit when c_chk%notfound;
                    
                     
        begin
                
          --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
          var_intfc_rtn := outbound_loader.create_interface(var_interface_type);

          --CREATE DATA LINES FOR MESSAGE

          -- HEADER: Header Record
          -- Including 'X' at the end of the header record will cause Atlas
          -- to treat the message as a test, meaning no further processing
          -- will be completed once it reaches Atlas.
          outbound_loader.append_data('HDRZUB '
            || lpad(plt_common.cmpny_code,4,' ')
            || rpad(plt_common.purch_org,4,' ')
            || rpad(plt_common.purch_grp,3,' ')
            || rpad(plt_common.vendor,8,' ')
            || rpad(trim(plt_common.source_plant),4,' ')
            || rpad(plt_common.currency,5,' ')
            || rpad(' ',12,' '));            
                          
          var_line := 10;
                
          open c_sto;
          loop
            fetch c_sto into rcd;
            exit when c_sto%notfound;
                      
            select dispn_code 
            into var_stock_status
            from plt_hdr 
            where plt_code = rcd.plt_code;                    
                      
            -- det: process order 
            outbound_loader.append_data('DET'
              || lpad(to_char(var_line),5,'0')
              || rpad(trim(rcd.matl_code),8,' ')
              || rpad(trim(rcd.dest_plant),4,' ')
              || rpad(trim(plt_common.stor_locn),4,' ')
              || rpad(upper(rcd.uom),3,' ')
              || ltrim(to_char(rcd.qty,'000000000.000'))
              || rpad(var_stock_status,1,' ')
              || to_char(rcd.deliv_date,'YYYYMMDD')
              || lpad(to_char(rcd.deliv_time),6,'0')
              || rpad(rcd.batch,10,' '));
                           
            var_line := var_line + 10;
                                             
          end loop;
          close c_sto;
          
          --Close PASSTHROUGH INTERFACE
          outbound_loader.finalise_interface();
          
          var_success := 0;
              
        exception              
          when others then
            if ( outbound_loader.is_created() ) then
              outbound_loader.finalise_interface();
            end if;                          
            -- error has occured   
            var_success := 1;                         
        end;      
         
        -- send email notification
        raisenotification('Found A STO not sent via the Idoc.' || r_chk.cnn);       
                        
        if ( var_success = 0 ) then
          update sto_hdr 
          set sent_flag = 'Y'
          where cnn = r_chk.cnn;
                               
          dbms_output.put_line (r_chk.cnn || 'OK');
        else
          select count(*) 
          into var_count
          from sto_idoc_log
          where cnn = r_chk.cnn;
          
          if ( var_count = 1 ) then
            select resend_count
            into var_count
            from sto_idoc_log
            where cnn = r_chk.cnn;
                          
            update sto_idoc_log 
            set resend_count = var_count + 1
            where cnn = r_chk.cnn;
                       
          else
            var_count := 0;
          end if;
                     
        end if;
                 
      end loop;
      close c_chk;
    end if;
    commit;
                
  exception
    when others then
      rollback;
      raisenotification('ERROR OCCURED - <tagsys_sys_intfc_ics.CheckSendsPlt> ' || chr(13) || sqlerrm);    
  end;

  procedure checksendsdisposition is
  /******************************************************************************
  NAME:       CheckSendsDisposition
  PURPOSE:    

  REVISIONS:
  Ver        Date        Author           Description
  ---------  ----------  ---------------  ------------------------------------
  1.0        17/02/2005   Jeff Phillipson 1. Created this procedure.    
  ******************************************************************************/
    /*-*/
    /* Variables
    /*-*/     
    var_interface_type      varchar2(10) := 'CISATL05.1';
    var_sign                varchar2(1);
    var_rec_stock_status    varchar2(1);
    var_plt_code            varchar2(12);
    var_result_msg          varchar2(2000);
    
    var_count               number;
    var_intfc_rtn           number(15,0);
    var_result              number;
        
    process_exception       exception;
    e_escape_exception      exception;
    idoc_exception          exception;
    
    cursor c_dsp is
      select d.*, 
        matl_code, 
        qty, uom 
      from plt_dspstn d, 
        plt_hdr h
      where sent_flag is null
        and h.plt_code = d.plt_code;        
    rcd c_dsp%rowtype;   
                                                                              
  begin
  /* check any Create and Cancel Pallets for a send error 
  || first CHECK IF the sending OF Idocs has been disabled
  */
  if ( not idoc_hold ) then     
    var_result := 0;
           
    open c_dsp;
    loop
      fetch c_dsp into rcd;
      exit when c_dsp%notfound;
               
      begin
                             
        --Create PASSTHROUGH interface on ICS for GR or RGR message to Atlas
        var_intfc_rtn := outbound_loader.create_interface(var_interface_type);                 

        -- HEADER: Header Record
        -- Including 'X' at the end of the header record will cause Atlas
        -- to treat the message as a test, meaning no further processing
        -- will be completed once it reaches Atlas.
        outbound_loader.append_data('HDR'
          || to_char(sysdate,'yyyymmdd')
          || to_char(sysdate,'hh24miss')
          || rpad(' ',16,' ')
          || rpad(' ',25,' ')
          || rpad(ltrim(rcd.whse_ref),16,' '));
                                     
        -- DBMS_OUTPUT.PUT_LINE(TO_CHAR(rcd.qty,'000000000.000'));
        --DET: PROCESS ORDER
        if ( rcd.sign is null ) then
          var_sign := ' ';
        else
          var_sign := rcd.sign;
        end if;
                     
        if ( rcd.rec_stock_status is null ) then
          var_rec_stock_status := ' ';
        else
          var_rec_stock_status := rcd.rec_stock_status;
        end if;
                   
        if ( rcd.dspstn_type <> 'STCH' ) then  
          var_rec_stock_status := ' ';
        end if;                   
                                                
        outbound_loader.append_data('DET'
          || rpad(plt_common.source_plant,4)
          || lpad(rcd.sloc_1,4,'0')
          || rpad(' ', 4,' ')
          || rpad(' ', 4,' ')
          || rpad(rcd.matl_code,8,' ')
          || rpad(rcd.dspstn_type,4,' ')
          || var_sign
          || ltrim(to_char(rcd.qty,'000000000.000'))
          || rpad(trim(rcd.uom),3,' ')
          || rpad(rcd.iss_stock_status,1,' ')
          || rpad(rcd.rec_stock_status,1,' ')
          || rpad(rcd.batch,10,' ')
          || rpad(' ',8,' ')
          || rpad(' ',1,' ')
          || rpad(' ',8,' ')
          || rpad(' ',8,' '));                                           
                                                   
        --Close PASSTHROUGH INTERFACE
        outbound_loader.finalise_interface();                         
        dbms_output.put ('Sent Idoc');
                                       
        var_result := plt_common.success;
                                 
      exception
        when others then
          if ( outbound_loader.is_created() ) then
            outbound_loader.finalise_interface();
          end if;
                                                         
        var_result_msg := 'Disposition Idoc create Failed [' || var_result_msg || ']';
        var_result := plt_common.failure;
      end;      
            
      if ( var_result = plt_common.success ) then
        update pt.plt_dspstn 
        set sent_flag = 'Y'
        where plt_code = upper(rcd.plt_code);
                           
        dbms_output.put_line (rcd.plt_code || 'OK');
      else
        select count(*) 
        into var_count
        from dspstn_idoc_log
        where plt_code = rcd.plt_code;
        
        if ( var_count = 1 ) then
          select resend_count 
          into var_count
          from dspstn_idoc_log
          where  plt_code = rcd.plt_code;
                         
          update dspstn_idoc_log 
          set resend_count = var_count + 1
          where plt_code = rcd.plt_code;
        else
          var_count := 0;
        end if;     
      end if;
             
      -- send email notification
      raisenotification('Found A Disposition not sent via the Idoc.' || rcd.plt_code); 

    end loop;
    close c_dsp;    
  end if;
end checksendsdisposition;
   
end tagsys_sys_intfc_ics;
/

grant execute on pt_app.tagsys_sys_intfc_ics to shiftlog;
grant execute on pt_app.tagsys_sys_intfc_ics to shiftlog_app;

create or replace public synonym tagsys_sys_intfc_ics for pt_app.tagsys_sys_intfc_ics;