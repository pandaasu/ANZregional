create or replace package pt_app.tagsys_fctry_intfc_ics as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : pt_app 
 View    : tagsys_fctry_intfc_ics
 Owner   : pt_app 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - Production Interface

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created
 2008/12   Trevor Keon    Modified to use pt_cisatl17_gr_ics for sending interface

*******************************************************************************/
 
  procedure create_pllt(o_result  in out number,
                  o_result_msg    in out varchar2,    	
                  i_xactn_date		in date,
                  i_xactn_time		in number,
                  i_plant_code		in varchar2,
                  i_sender_name		in varchar2,
                  i_zpppi_batch		in varchar2,
                  i_proc_order		in number,
                  i_stor_loc_code	in number,
                  i_dispn_code		in varchar2,
                  i_use_by_date	  in date,
                  i_material_code	in varchar2,
                  i_uom					  in varchar2,
                  i_plt_code		  in varchar2,
                  i_qty					  in number,
                  i_full_plt_flag	in varchar2,
                  i_user_id				in varchar2,
                  i_last_gr_flag	in varchar2);
   
  procedure cancel_pllt(o_result  in out number,
                  o_result_msg    in out varchar2,	
                  i_xactn_date		in date,
                  i_xactn_time		in number,
                  i_sender_name		in varchar2,
                  i_plt_code			in varchar2,
                  i_user_id				in varchar2);    

  /* Disposition procedure is called to change the disposition within Atlas.
  it is called 1 pallet at a time and an Idoc is only sent to Atlas if:
  .. the pallet has not had an STO raised
  .. or the Atlas disposition changes. ie Shift Log has 16 dispositions - Atlas has 3
  */   
  procedure disposition(o_result      in out number,
                  o_result_msg        in out varchar2,
                  i_plt_code          in varchar2,
                  i_sloc              in varchar2,
                  i_sign              in varchar2,
                  i_iss_stock_status  in varchar2,
                  i_rec_stock_status  in varchar2,
                  i_dspstn_type       in varchar2);   
 
end;

create or replace package body pt_app.tagsys_fctry_intfc_ics as
 
  /**********************************************************************************/
  /* Create a Pallet Record and set up the Idoc structure to send to Atlas
  /**********************************************************************************/
    
  var_test_flag    boolean := false;
   

  procedure create_pllt(o_result      in out number,
                      o_result_msg    in out varchar2,                       
                      i_xactn_date    in date,
                      i_xactn_time    in number,
                      i_plant_code    in varchar2,
                      i_sender_name   in varchar2,
                      i_zpppi_batch   in varchar2,
                      i_proc_order    in number,
                      i_stor_loc_code in number,
                      i_dispn_code    in varchar2,
                      i_use_by_date   in date,
                      i_material_code in varchar2,
                      i_uom           in varchar2,
                      i_plt_code      in varchar2,
                      i_qty           in number,
                      i_full_plt_flag in varchar2,
                      i_user_id       in varchar2,
                      i_last_gr_flag  in varchar2) as
    /*-*/
    /* Variables
    /*-*/      
    var_last_gr_flag        boolean := false;
    
    var_count               number := 0;
    var_result              number;
    
    var_transaction_type    varchar2(10);
    var_result_msg          varchar2(2000);
    var_batch               varchar2(10);           
    var_trans_type          varchar2(10) default 'CREATE';
    
    process_exception       exception;
    idoc_exception          exception;    
  begin

    o_result := plt_common.success;
    o_result_msg := 'Pallet ' || i_plt_code || ' created';
       
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving IN TABLE
    /**********************************************************************************/

    -- Check if Pallet Code exists 
    select count(*) 
    into var_count
    from plt_hdr
    where plt_code = i_plt_code;
    
    if ( var_count > 0 ) then
      o_result_msg := 'Transaction Failed: Pallet code already exists. Please select a unique value.';
      o_result := plt_common.failure;
      raise process_exception; 
    end if;
   
    -- check validity of dates
    if ( i_xactn_date is null ) then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
       
    -- check plant code
    if ( i_plant_code is null ) then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    else
      select count(*) 
      into var_count 
      from manu.ref_plant
      where plant_code = i_plant_code;
             
      if ( var_count = 0 ) then
        o_result_msg := 'Plant Code is not correct.';
        o_result := plt_common.failure;
        raise process_exception;
      end if;
    end if;
   
    -- check for valid proc order
    if ( i_proc_order is null ) then
      o_result_msg := 'Proc Order is not valid.';
      o_result := plt_common.failure;
      raise process_exception;
    else
      if ( substr(i_proc_order,1,2) <> '99' ) then
        select count(*) 
        into var_count 
        from manu.cntl_rec_vw
        where proc_order = i_proc_order;
        
        if ( var_count = 0 ) then
          o_result_msg := 'Proc Order is not valid.';
          o_result := plt_common.failure;
          raise process_exception;
        end if;
      end if;
    end if;
   
    -- check material code
    if ( i_material_code is null ) then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    else
      select count(*) 
      into var_count 
      from material_vw
      where material_code = i_material_code;
    end if;
   
    -- check validity of qty
    if ( i_qty = 0 ) then
      o_result_msg := 'Quantity cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
       
    -- check uom
    if ( i_uom is null ) then
      o_result_msg := 'UOM cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
   
    -- check disposition code 
    /***********************************************************************************
    DISPOSITION STATUS 
    ********************
    Blocked            = 'S'
    Un Restricted      = ' '
    Quality Inspect    = 'X'
    ************************************************************************************/
   
    if ( i_dispn_code is null ) then
      o_result_msg := 'Disposition cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    else
      if ( i_dispn_code <> ' ' and i_dispn_code <> 'S' and i_dispn_code <> 'X' ) then
        o_result_msg := 'Disposition is not a valid value - Blank, ''S'' or ''X''.';
        o_result := plt_common.failure;
        raise process_exception;
      end if;
    end if;
       
    /**********************************************************************************/
    /* Save data in Pallet tables
    /**********************************************************************************/
    begin
          
      if ( i_zpppi_batch is null ) then
        var_batch := ' ';
      else
        -- fg
        var_batch := substr(i_zpppi_batch,1,30);
      end if;
               
      /**********************************************************************************/
      /* insert record into header table
      /**********************************************************************************/
      insert into pt.plt_hdr 
      (
        plt_code,
        matl_code,
        qty,
        status,
        plant_code,
        zpppi_batch,
        proc_order,
        stor_locn_code,
        dispn_code,
        use_by_date,
        full_plt_flag,
        last_gr_flag,
        plt_create_datime,
        uom
      )
      values
      (
        i_plt_code,
        i_material_code,
        i_qty,
        var_trans_type,
        i_plant_code,
        var_batch,
        i_proc_order,
        i_stor_loc_code,
        i_dispn_code, 
        i_use_by_date,
        i_full_plt_flag,
        i_last_gr_flag,
        sysdate,
        upper(i_uom)   
      );
                        
      /**********************************************************************************/                 
      /* insert detail record 
      /**********************************************************************************/
      insert into plt_det 
      (
        plt_code,
        xactn_type,
        user_id,
        reason,
        xactn_date,
        xactn_time,
        sender_name
      )
      values 
      (
        i_plt_code,
        var_trans_type,
        upper(i_user_id),
        var_trans_type,
        to_char(i_xactn_date,'dd-mon-yyyy'),
        i_xactn_time,
        upper(i_sender_name)
      );
    exception
      when others then
        o_result_msg := 'INSERT (CREATE) INTO pt.plt_hdr and plt_det FAILED, RETURN [' || sqlerrm(sqlcode) || ']';
        o_result := plt_common.failure;
    end;       
        
    /**********************************************************************************/
    /* Create Idoc package for Create
    /**********************************************************************************/       
    begin
      if ( substr(i_proc_order,1,2) <> '99' ) then
           
        var_transaction_type := 'Z_PI1';
          
        if ( i_last_gr_flag = 'Y' ) then
          var_last_gr_flag := true;
        end if;

        if ( not idoc_hold ) then
                       
          pt_cisatl17_gr_ics.execute
          (
            var_result,
            var_result_msg,
            var_transaction_type,
            i_plant_code,
            i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
            var_test_flag,
            i_proc_order,
            i_xactn_date,
            i_xactn_time,
            i_material_code,
            i_qty,
            upper(i_uom),
            i_stor_loc_code,
            i_dispn_code,
            var_batch,
            var_last_gr_flag,
            to_char(i_use_by_date,'YYYYMMDD'),
            null,
            null,
            null,
            null,
            null,
            null,
            null
          );
        else
          var_result := 0;           
        end if; 
                                
        if ( var_result <> 0 ) then
          -- error has occured 
          -- insert record in log file
          o_result_msg := var_result_msg;
          o_result := var_result;
          
          insert into plt_idoc_log
          values (i_plt_code, var_trans_type, 0, 'FAIL',o_result_msg, sysdate, 0);
          
          o_result_msg := '';
          o_result := plt_common.success;
          raise idoc_exception;
        end if;
        
        commit;
                       
      end if;

    exception
      when others then
        o_result_msg := 'Call to CREATE_IDOC Failed [' || sqlcode || ' ' || substr(sqlerrm,1,256) || ']';
        o_result := plt_common.failure;
        rollback;
        raise process_exception;
    end;
       
    /**********************************************************************************/
    /* Update Sent Flag if all OK
    /**********************************************************************************/
    begin
    
      if ( substr(i_proc_order,1,2) = '99' ) then
        update pt.plt_det
        set sent_flag = 'X'
        where plt_code = upper(i_plt_code);
      else
        if ( not idoc_hold ) then
          update pt.plt_det
          set sent_flag = 'Y'
          where plt_code = upper(i_plt_code);
        end if;
      end if;

    exception
      when others then
        o_result_msg := '<TAGSYS_FCTRY_INTFC.Create_Pllt> Error updating sent flag on pts_intfc: [' || sqlerrm || ']';
        o_result := plt_common.failure;
        raise process_exception;
    end;

    commit;

  exception
    when process_exception then
      o_result := plt_common.failure;
      -- raise_application_error(-20001, o_result_msg);
    when idoc_exception then
      commit;
      o_result := plt_common.success;
      -- raise_application_error(-20000, o_result_msg);
    when others then
      o_result := plt_common.failure;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlcode || '-' || substr(sqlerrm,1,256);
      --  raise_application_error(-20000, o_result_msg);
  end create_pllt;

  /**********************************************************************************/
  /* Cancel Pallet record -
  /* - the pallet record has to exist and it should be CREATE status
  /**********************************************************************************/
  procedure cancel_pllt(o_result    in out number,
                      o_result_msg  in out varchar2,                 
                      i_xactn_date  in date,
                      i_xactn_time  in number,
                      i_sender_name in varchar2,
                      i_plt_code    in varchar2,
                      i_user_id     in varchar2) as
    /*-*/
    /* Variables
    /*-*/ 
    var_last_gr_flag      boolean := false;
    
    var_count             number;
    var_result            number;
    
    var_transaction_type  varchar2(10);
    var_result_msg        varchar2(2000);
    var_proc_order        varchar2(12);
    var_trans_type        varchar2(10) default 'CANCEL';
    
    process_exception     exception;
    idoc_exception        exception;           
           
    cursor c_get_plt is
      select h.*, 
        sent_flag
      from plt_hdr h, 
        plt_det d
      where h.plt_code = i_plt_code
        and h.plt_code = d.plt_code
        and d.xactn_type = 'CREATE';           
    r_plt  c_get_plt%rowtype;      
       
  begin

    o_result := Plt_Common.SUCCESS;
    o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';  
         
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving IN TABLE
    /**********************************************************************************/   
    select count(*) 
    into var_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    
    if ( var_count <> 1 ) then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
        
    select count(*) 
    into var_count
    from plt_hdr
    where plt_code = i_plt_code
    and status = 'CANCEL';
    
    if ( var_count > 0 ) then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
         
    -- check validity of dates
    if ( i_xactn_date is null ) then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
         
    -- check sender name
    if ( i_sender_name is null ) then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;

   -- get rest of pallet data 
    open c_get_plt;
    fetch c_get_plt into r_plt;
    
    if ( c_get_plt%found ) then   
      /**********************************************************************************/
      /* Save data in Pallet tables
      /**********************************************************************************/

      begin
        update pt.plt_hdr 
        set status = var_trans_type
        where plt_code = r_plt.plt_code;               
             
        /**********************************************************************************/                 
        /* Insert detail record 
        /**********************************************************************************/
        insert into  plt_det 
        (
          plt_code,
          xactn_type,
          user_id,
          reason,
          xactn_date,
          xactn_time,
          sender_name
        )
        values 
        (
          i_plt_code,
          var_trans_type,
          upper(i_user_id),
          var_trans_type,
          to_char(i_xactn_date,'dd-mon-yyyy'),
          i_xactn_time,
          upper(i_sender_name)
        );              
      exception
        when others then
          o_result := plt_common.failure;
          o_result_msg := 'UPDATE (CANCEL) INTO pt.plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
      end;

      /**********************************************************************************/
      /* Create Idoc package for Cancel
      /**********************************************************************************/

      if ( not idoc_hold ) then
        begin
                  
          select proc_order 
          into var_proc_order
          from plt_hdr
          where plt_code = i_plt_code;
                         
          if ( substr(var_proc_order,1,2) <> '99' ) then
                 
            var_transaction_type := 'Z_PI2';
              
            if ( r_plt.last_gr_flag = 'Y' ) then
              var_last_gr_flag := true;
            else
              var_last_gr_flag := false;
            end if;
              
            pt_cisatl17_gr_ics.execute
            (
              var_result,
              var_result_msg,
              var_transaction_type,
              trim(r_plt.plant_code),
              i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
              var_test_flag,
              to_number(r_plt.proc_order),
              i_xactn_date,
              i_xactn_time,
              r_plt.matl_code,
              r_plt.qty,
              r_plt.uom,
              to_number(r_plt.stor_locn_code),
              r_plt.dispn_code,
              r_plt.zpppi_batch,
              var_last_gr_flag,
              to_char(r_plt.use_by_date,'YYYYMMDD'),
              null,
              null,
              null,
              null,
              null,
              null,
              null
            );           
                               
            if ( var_result <> 0 ) then
              -- error has occured 
              -- insert record in log file
              o_result_msg := var_result_msg;
              o_result := var_result;
                
              insert into plt_idoc_log
              values (i_plt_code, var_trans_type, 0, 'FAIL', o_result_msg, sysdate, o_result);
                
              o_result_msg := '';
              o_result := plt_common.success;
              raise idoc_exception;
            end if;
                             
          end if;
           
        exception
          when others then
            o_result_msg := 'Call to CREATE_IDOC Failed [' || sqlerrm || ']';
            o_result := plt_common.failure;
            raise process_exception;
        end;
      end if;
          
      begin
      
        if ( substr(var_proc_order,1,2) = '99' ) then
          update pt.plt_det
          set sent_flag = 'X'
          where plt_code = upper(i_plt_code);
        else
          if ( not idoc_hold ) then
            update pt.plt_det
            set sent_flag = 'Y'
            where plt_code = upper(i_plt_code);
          end if;
        end if;

      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_Pllt> Error updating sent flag on pts_intfc: [' || sqlerrm || ']';
          o_result := plt_common.failure;
          raise process_exception;
      end;
    
    end if;        
    close c_get_plt;        
       
    commit;

  exception
    when process_exception then
      o_result := plt_common.failure;
      -- raise_application_error(-20001, o_result_msg);
    when idoc_exception then
      commit;
      o_result := plt_common.success;
      -- raise_application_error(-20000, o_result_msg);
    when others then
      o_result := plt_common.failure;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      -- raise_application_error(-20000, o_result_msg);
  end;

  /**********************************************************************************/
  /* Disposition Pallet record -
  /* - the pallet record has to exist and in a CREATE status before
  /* - a disposition can be raised
  /* Disposition procedure is called to change the disposition within Atlas.
  /* it is called 1 pallet at a time and an Idoc is only sent to Atlas if:
  /*.. the pallet has not had an STO raised
  /*.. or the Atlas disposition changes. ie Shift Log has 16 dispositions - Atlas has 3
  /**********************************************************************************/

  procedure disposition(o_result          in out number,
                      o_result_msg        in out varchar2,
                      i_plt_code          in varchar2,
                      i_sloc              in varchar2,
                      i_sign              in varchar2,
                      i_iss_stock_status  in varchar2,
                      i_rec_stock_status  in varchar2,
                      i_dspstn_type       in varchar2) as
    /*-*/
    /* Variables
    /*-*/       
    process_exception     exception;
    escape_exception      exception;
    idoc_exception        exception;
           
    var_interface_type    varchar2(10) := 'CISATL05.1'; 
    var_batch             varchar2(20);
    var_test_flag         varchar2(1)  := '';
    var_dsp               varchar2(1);
    var_last_dspstn       varchar2(10);
    var_sign              varchar2(1);
    var_rec_stock_status  varchar2(1);
    
    var_count             number;
    var_intfc_rtn         number(15,0);
    var_seq               number;
    var_whse              number;
    var_qty               number;
           
    cursor c_disp is
      select matl_code, 
        qty, 
        zpppi_batch as batch,
        proc_order, 
        stor_locn_code as sloc1, 
        uom
      from plt_hdr h, 
        plt_det d
      where h.plt_code = d.plt_code
        and reason = 'CREATE'
        and h.plt_code = i_plt_code;               
    rcd c_disp%rowtype;
           
    cursor c_last is
      select iss_stock_status 
      from plt_dspstn
      where plt_code = i_plt_code
      order by create_datime desc;
       
  begin
       
    o_result := plt_common.success;
    o_result_msg := 'Disposition changed for pallet ' || i_plt_code;
             
    -- ensure a pallet exists 
    select count(*) 
    into var_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    
    if ( var_count = 0 ) then
      o_result_msg := 'Pallet does not exist or may have been cancelled.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
                          
    -- disposition can only be sent if an sto has not been raised ? 
    select count(*) 
    into var_count
    from sto_det d, sto_hdr h
    where d.cnn = h.cnn
      and d.plt_code = i_plt_code;
      
    if ( var_count > 0 ) then
      o_result_msg := 'STO has been sent for this Pallet - no Dispositions can be made.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
       
    /***********************************************************************
    -- check fields are valid for the type of transfer 
    ***********************************************************************/
    if ( i_dspstn_type = 'STCH' ) then
      -- check for a iss stock status 
      if ( i_rec_stock_status is null ) then
        o_result_msg := 'Issue Stock Status Code cannot be Null for STCH record.';
        raise process_exception;
      end if;
    end if;

    if ( i_dspstn_type <> 'STCH' and i_dspstn_type <> 'SADJ' ) then
      o_result_msg := 'Not a valid transaction type - STCH, SAADJ only';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
              
    -- check for a iss stock status 
    if ( i_iss_stock_status is null ) then
      o_result_msg := 'Issue Stock Status Code cannot be Null.';
      raise process_exception;
    end if;

    -- values can only be X - Quality Inspect
    --                    S - Blocked
    --                    space - Unrestricted
    -- change the shift log status to an atlas status 
    if ( i_iss_stock_status not in (' ','R','S','X') ) then
      o_result_msg := 'Incorrect Issuing disposition status.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;
             
    -- values can only be X - Quality Inspect
    --                    S - Blocked
    --                    space - Unrestricted
    -- change the shift log status to an atlas rec status 
    if ( i_rec_stock_status not in (' ','R','S','X') ) then
      o_result_msg := 'Incorrect Receive disposition status.';
      o_result := plt_common.failure;
      raise process_exception;
    end if;  
                  
    /**********************************************************************
    End of field checking 
    **********************************************************************/      
            
    -- get pallet infomation
    begin
      select max(zpppi_batch) batch 
      into var_batch
      from plt_hdr
      where plt_code = i_plt_code;
                         
    exception
      when too_many_rows then
        o_result_msg := 'ERROR OCCURED in Disposition procedure - more than one pallet' || chr(13) || substr(sqlerrm,1,256);
        o_result := plt_common.failure;
        raise process_exception;
      when no_data_found then
        o_result_msg := 'ERROR OCCURED in Disposition procedure - no pallet' || chr(13) || substr(sqlerrm,1,256);
        o_result := plt_common.failure;
        raise process_exception;
      when others then
        o_result_msg := 'ERROR OCCURED in Disposition procedure - get pallet' || chr(13) || substr(sqlerrm,1,256);
        o_result := plt_common.failure;
        raise process_exception;
    end;
         
    /* DISPOSITION tests
    only save data if the disposition is different from tha last Atlas disposition         
    get last atlas disposition 
    if it is the same as this one do not send       */
    select dispn_code, qty 
    into var_dsp, var_qty
    from plt_hdr
    where plt_code = i_plt_code;
    
    if ( var_dsp <> i_iss_stock_status ) then
      o_result_msg := 'The current Pallet disposition is different to the Iss_Stock_Status.';                
      raise process_exception;
    end if;
    if ( i_iss_stock_status = i_rec_stock_status ) then
      o_result_msg := 'Issue and Receive Dispositions are the same. They have to be different.';                
      raise process_exception;
    end if;
             
    -- insert a record in dspstn table
    select plt_dspstn_code_seq.nextval into var_seq from dual;
    
    -- get a seq code for whse_code filed 
    select plt_dspstn_whse_seq.nextval into var_whse from dual;
         
             
    begin
             
      /*****************************************
      update pallet record with by adding new qty
      *****************************************/
      --   IF i_sign  IS NULL THEN
      -- add qty 
      --      var_qty := var_qty + i_qty;
      --   ELSE
      -- subttract qty
      --       var_qty := var_qty - i_qty;
      --   END IF;
      --   UPDATE plt_hdr
      --   SET qty = var_qty
      --   WHERE plt_code = i_plt_code;
      /*****************************************/
               
      insert into plt_dspstn
      values 
      (
        var_seq,
        rtrim(ltrim(i_plt_code)),
        trunc(sysdate),
        to_char(sysdate,'hh24miss'),
        '',
        '', --i_qty,
        to_char(var_whse),
        plt_common.source_plant, -- source plant
        i_sloc, -- source sloc
        '', -- dest plant 
        '', -- dest sloc
        i_sign, -- qty sign
        rtrim(ltrim(i_iss_stock_status)),
        rtrim(ltrim(i_rec_stock_status)),
        var_batch,
        '',
        '',
        '',
        '',
        '',
        sysdate,
        i_dspstn_type
      );
                       
      update plt_hdr 
      set dispn_code = i_rec_stock_status
      where plt_code = i_plt_code;
                      
      commit;
                      
    exception
      when others then
        o_result := plt_common.failure;
        dbms_output.put ('Plt Code =' || i_plt_code || '-');
        o_result_msg := 'ERROR OCCURED in Disposition procedure Inserting record' || chr(13) || substr(sqlerrm,1,256);
        raise process_exception;
    end;
          
          
    if not idoc_hold then
             
      --CREATE DATA LINES FOR MESSAGE
      open c_disp;
      fetch c_disp into rcd;
      
      if ( c_disp%found ) then
                         
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
            || lpad(var_whse,16,'0'));
                 
                     
          -- DBMS_OUTPUT.PUT_LINE(TO_CHAR(rcd.qty,'000000000.000'));
          --DET: PROCESS ORDER
          if ( i_sign is null ) then
            var_sign := ' ';
          else
            var_sign := i_sign;
          end if; 
           
          if ( i_rec_stock_status is null ) then
            var_rec_stock_status := ' ';
          else
            var_rec_stock_status := i_rec_stock_status;
          end if;
          
          if ( i_dspstn_type <> 'STCH' ) then  
            var_rec_stock_status := ' ';
          end if;                   
                                             
          outbound_loader.append_data('DET'
            || rpad(plt_common.source_plant,4)
            || lpad(rcd.sloc1,4,'0')
            || rpad(' ', 4,' ')
            || rpad(' ', 4,' ')
            || rpad(rcd.matl_code,8,' ')
            || rpad(i_dspstn_type,4,' ')
            || var_sign
            || ltrim(to_char(0,'000000000.000'))
            || rpad(trim(rcd.uom),3,' ')
            || rpad(i_iss_stock_status,1,' ')
            || rpad(i_rec_stock_status,1,' ')
            || rpad(rcd.batch,10,' ')
            || rpad(' ',8,' ')
            || rpad(' ',1,' ')
            || rpad(' ',8,' ')
            || rpad(' ',8,' '));                                           
                                               
          --Close PASSTHROUGH INTERFACE
          outbound_loader.finalise_interface();                         
          dbms_output.put ('Sent Idoc');
                     
        exception
          when others then
            if ( outbound_loader.is_created() ) then
              outbound_loader.finalise_interface();
            end if;
                              
            -- error has occured 
            -- insert record in log file
            o_result_msg := 'ERROR OCCURED'|| '-' || substr(sqlerrm,1,256);
            o_result := sqlcode;
            
            insert into dspstn_idoc_log
            values (i_plt_code, 0, o_result_msg, sysdate, 0);
            
            -- raise error 
            o_result_msg := '';
            o_result := plt_common.success;
            raise idoc_exception;
        end;                     
                     
        update pt.plt_dspstn 
        set sent_flag = 'Y'
        where plt_code = upper(i_plt_code);
                 
      end if;
      close c_disp;     
       
    end if;
                                            
    commit;
            
  exception
  when escape_exception then
    -- this is an error within the operation and so its not really an error 
    o_result := plt_common.success;                    
  when process_exception then
    o_result := plt_common.failure;                   
  when idoc_exception then
    o_result := plt_common.success;            
  when others then
    o_result := plt_common.failure;
    rollback;
    o_result_msg := 'ERROR OCCURED in Disposition Procedure ' || chr(13) ||substr(sqlerrm,1,256);
  end;

end tagsys_fctry_intfc_ics;
/

grant execute on pt_app.tagsys_fctry_intfc_ics to shiftlog;
grant execute on pt_app.tagsys_fctry_intfc_ics to shiftlog_app;

create or replace public synonym tagsys_fctry_intfc_ics for pt_app.tagsys_fctry_intfc_ics;