create or replace package pt_app.tagsys_fctry_intfc_ics as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : tagsys_fctry_intfc
  Owner   : pt_app 

  Description 
  ----------- 
  This package is used for PETCARE - Bathurst and Wodonga only 

  create_pllt - will perform a Goods receipt of either a pallet or process 
  cancel_pllt - will reverse a process qty 
  cancel_hu_pllt - will reverse a pallet from atlas ie cancel 
  create_consumption - will record consumption of any material used within a 
    valid process order
  cancel_consumption - will cancel process only data in PT schema and send on 
    to Atlas
  
  NOTE: This Package is not the same as the one used in Wanganui or Food 
  it has been modified to handle the new HANDLING UNITS (pallet codes)
  and the package now uses the REMOTE_LOADER for transfer of data
  from Oracle to a file location on the Plant Database Server.
  this is then transferred via MQ Series Light to the LADS server 
  where is is sent again via MQ Series to Atlas via the HUB   

  YYYY/MM   Author          Description 
  -------   ------          ----------- 
  2006/01   Jeff Phillipson Created 
  2008/10   Trevor Keon     Updated layout and create_pllt to use matl instead
                            of matl_vw for performance reasons

*******************************************************************************/

  /*-*/
  /* Create_Pllt will record data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /*-*/
  procedure create_pllt
  (
    o_result            in out number,
    o_result_msg        in out varchar2,
    i_xactn_date		    in date,
    i_plant_code		    in varchar2,
    i_sender_name	      in varchar2,
    i_zpppi_batch	      in varchar2,
    i_proc_order		    in number,
    i_dispn_code		    in varchar2,
    i_use_by_date	      in date,
    i_material_code	    in varchar2,
    i_plt_code		      in varchar2,
    i_qty			          in number,
    i_full_plt_flag	    in varchar2,
    i_user_id		        in varchar2,
    i_last_gr_flag	    in varchar2,
    i_plt_type			    in varchar2,
    i_start_prodn_date  in date,
    i_end_prodn_date  	in date
  );
   
  /*-*/
  /* Cancel_Pllt will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /*-*/
  procedure cancel_pllt
  (
    o_result      in out number,
    o_result_msg  in out varchar2,
    i_xactn_date	in date,
    i_sender_name	in varchar2,
    i_plt_code		in varchar2,
    i_user_id			in varchar2
  );  
   
  /*-*/
  /* Cancel_HU_Pllt will cancel pallets only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /*-*/
  procedure cancel_hu_pllt
  (
    o_result      in out number,
    o_result_msg  in out varchar2,
    i_xactn_date	in date,
    i_sender_name	in varchar2,
    i_plt_code		in varchar2,
    i_user_id			in varchar2
  );  
		
  /*-*/
  /* Create_Consumption will record data in PT schema and send on to Atlas 
  /* this will record consumption of any material used within a 
  /* valid process order 
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /*-*/
  procedure create_consumption
  (
    o_result        in out number,
    o_result_msg    in out varchar2,
    i_trans_id			in number, --  uniquie id 
    i_xactn_date		in date,
    i_plant_code		in varchar2,
    i_proc_order		in varchar2,
    i_material_code	in varchar2,
    i_qty					  in number
  );
	
 
  /*-*/
  /* Cancel_Consumption will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /*-*/
  procedure cancel_consumption
  (
    o_result        in out number,
    o_result_msg    in out varchar2,
    i_trans_id		  in number, --  uniquie id 
    i_xactn_date		in date,
    i_plant_code		in varchar2,
    i_proc_order		in varchar2,
    i_material_code	in varchar2,
    i_qty			      in number
  );  
	
end;
/

create or replace package body pt_app.tagsys_fctry_intfc_ics as
   
  b_test_flag boolean := false; 
   
  /******************************************************/
  /* Create_Pllt will record data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*          - 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_pllt
  (
    o_result            in out number,
    o_result_msg        in out varchar2,
    i_xactn_date        in date,
    i_plant_code        in varchar2,
    i_sender_name       in varchar2,
    i_zpppi_batch       in varchar2,
    i_proc_order        in number,
    i_dispn_code        in varchar2,
    i_use_by_date       in date,
    i_material_code     in varchar2,
    i_plt_code          in varchar2,
    i_qty               in number,
    i_full_plt_flag     in varchar2,
    i_user_id           in varchar2,
    i_last_gr_flag      in varchar2,
    i_plt_type          in varchar2,
    i_start_prodn_date  in date,
    i_end_prodn_date    in date
  ) as
             
    /*-*/
    /* Variables 
    /*-*/
    b_last_gr_flag      boolean := false;
    v_count             number := 0;
    v_transaction_type  varchar2(10);
    v_result            number default 0;
    v_result_msg        varchar2(2000);
    v_batch             varchar2(10);
    v_start_prodn_date  varchar2(20);
    v_end_prodn_date    varchar2(20);
    v_work              number;
    v_work1             varchar2(10);       
    v_seq               number;
             
    trans_type          varchar2(10) default 'CREATE';
          
    e_process_exception exception;
    e_idoc_exception    exception;
          
    cursor csr_matl is
      select issue_strg_locn, 
        decode(base_uom,'KGM','KG', base_uom) as uom 
      from matl_ics
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;    
    
  begin

    o_result := plt_common.success;
    o_result_msg := 'Pallet ' || i_plt_code || ' created';
  
    /*-*/
    /* Set prodn times to 6 char strings 
    /*-*/
    v_start_prodn_date := i_start_prodn_date;
    v_end_prodn_date := i_end_prodn_date;
  
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving in TABLE 
    /**********************************************************************************/
      
    /*-*/
    /*  Check if Pallet Code exists in the pallet tables
    /*-*/
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = to_char(i_plt_code);
    
    if ( v_count > 0 ) then
      o_result_msg := 'Transaction Failed: Pallet code already exists. Please select a unique value.';
      o_result := plt_common.failure;
      raise e_process_exception; 
    end if;
   
    /*-*/
    /*  check validity of date - transaction date cannot be null
    /*-*/
    if ( i_xactn_date is null ) then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    /*-*/
    /* check plant code is valid and not null
    /*-*/
    if ( i_plant_code is null ) then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from manu.ref_plant
      where plant = i_plant_code;
      
      if ( v_count = 0 ) then
        o_result_msg := 'Plant Code is not correct.';
        o_result := plt_common.failure;
        raise e_process_exception;
      end if;
    end if;
       
    /*-*/
    /* check for valid proc order
    /*-*/
    if ( i_proc_order is null ) then
      o_result_msg := 'Proc Order is not valid.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      if ( substr(i_proc_order,1,2) <> '99' ) then
        select count(*) 
        into v_count 
        from manu.cntl_rec 
        where ltrim(proc_order,'0') = ltrim(to_char(i_proc_order),'0');
        
        if ( v_count = 0 ) then
          o_result_msg := 'Proc Order is not valid.';
          o_result := plt_common.failure;
          raise e_process_exception;
        end if;
      end if;
    end if;
       
    /*-*/
    /* check for a valid material code 
    /*-*/
    if ( i_material_code is null ) then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from matl_ics
      where matl_code = i_material_code;
      
      if ( v_count = 0 ) then
        o_result_msg := 'Material Code is not correct.';
        o_result := 1;
        raise e_process_exception;
      end if;
    end if;
       
    /*-*/
    /* check validity of qty 
    /*-*/
    if ( i_qty = 0 ) then
      o_result_msg := 'Quantity cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
             
    /*-*/
    /* check validity of best before date
    /*-*/
    if ( length(i_plt_code) > 12 ) then
      if ( i_use_by_date is null ) then
        o_result_msg := 'Best before date cannot be Null.';
        o_result := plt_common.failure;
        raise e_process_exception;
      end if;
    end if;
   
    /*-*/
    /* check disposition code 
    /*-*/
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
      raise e_process_exception;
    else
      if ( i_dispn_code <> ' ' and i_dispn_code <> 'S' and i_dispn_code <> 'X' ) then
        o_result_msg := 'Disposition is not a valid value - Blank, ''S'' or ''X''.';
        o_result := plt_common.failure;
        raise e_process_exception;
      end if;
    end if;
   

    /*-*/                                                       
    /* get storage location, uom  
    /*-*/
    begin
      open csr_matl;
      loop
        fetch csr_matl into v_work, v_work1;
        exit when csr_matl%notfound;
      end loop;
      close csr_matl;
    exception
      when others then
        o_result_msg := 'Failed to get the MATL data from the view RETURN [' || sqlcode || '-' || substr(sqlerrm,1,255) ||']';
        o_result := plt_common.failure;
        raise e_process_exception;
    end;
   
   
    /**********************************************************************************/
    /* Save data in Pallet tables
    /**********************************************************************************/
    begin
          
      if i_zpppi_batch is null then
        v_batch := ' ';
      else
        -- FG 
        v_batch := substr(i_zpppi_batch,1,30);
      end if;
                  
      /**********************************************************************************/
      /* Insert record into header table
      /**********************************************************************************/
      insert into plt_hdr
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
        uom,
        plt_type,
        start_prodn_datime,
        end_prodn_datime
      )
      values 
      (
        i_plt_code,
        i_material_code,
        i_qty,
        trans_type,
        i_plant_code,
        v_batch,
        to_char(i_proc_order),
        v_work,
        i_dispn_code, 
        i_use_by_date,
        i_full_plt_flag,
        i_last_gr_flag,
        sysdate,
        v_work1,
        i_plt_type,
        i_start_prodn_date,
        i_end_prodn_date
      );
                       
      /**********************************************************************************/                 
      /* Insert detail record 
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
        trans_type,
        upper(i_user_id),
        trans_type,
        trunc(i_xactn_date),
        to_number(to_char(i_xactn_date,'hh24miss')),
        upper(i_sender_name)
      ); 
              
      commit;
             
    exception
      when others then
        o_result_msg := 'Insert (CREATE) into plt_hdr and plt_det FAILED, RETURN [' || sqlcode || '-' || substr(sqlerrm,1,255) ||']';      
        o_result := plt_common.failure;
        rollback;
        raise e_process_exception;
    end; 
      
    /*-*/
    /* only send if the pallet code is areal Atlas code
    /* anything begining with 99 is a dummy - local code
    /* This will still allow FG Pallet Codes and Process to be sent
    /* Process will use an auto generated id for plt codes this will be less than 
    /* 10 digits long
    /*-*/
    if ( substr(i_proc_order,1,2) <> '99' ) then
             
      v_transaction_type := 'Z_PI1';
              
      if ( i_last_gr_flag = 'Y' ) then
        b_last_gr_flag := true;
      end if;
        
      /*-*/
      /* if the hold flag is not set then send the files to Atlas and Tolas
      /*-*/
      if not idoc_hold then
              
      /**********************************************************************************/
      /* Create Idoc package for Create
      /**********************************************************************************/  
        
        begin
                
          /*-*/
          /* Make call to create iDOC 
          /*-*/
          goods_recipte_send
          (
            v_result,
            v_result_msg,
            v_transaction_type,
            i_plant_code,
            i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
            b_test_flag,
            i_proc_order,
            trunc(i_xactn_date),
            to_number(to_char(i_xactn_date,'hh24miss')),
            i_material_code,
            i_qty,
            v_work1,
            v_work,
            i_dispn_code,
            v_batch,
            b_last_gr_flag,
            to_char(i_use_by_date,'yyyymmdd'),
            i_plt_code,
            i_plt_type,
            'CHEP',
            trunc(i_start_prodn_date),
            to_number(to_char(i_start_prodn_date,'hh24miss')),
            trunc(i_end_prodn_date),
            to_number(to_char(i_end_prodn_date,'hh24miss'))
          );
                    
          commit;
                    
        exception
          when others then
            o_result_msg := 'Call to Goods_Recipte_Send (create) Failed [' || sqlcode || ' ' || substr(sqlerrm,1,255) || ']';
            o_result := plt_common.failure;
            rollback;
            raise e_process_exception;
        end;
          
        
        begin
                
          if v_result = 0 then
            update plt_det
            set sent_flag = 'Y'
            where plt_code = upper(i_plt_code);  
          else
            /*-*/
            /*  error has occured 
            /*  insert RECORD in LOG FILE 
            /* and a retry will be made latter
            /*-*/
            o_result_msg := v_result_msg;
            o_result := v_result;
                             
            insert into plt_idoc_log
            values (i_plt_code, trans_type, 0, 'FAIL', substr(o_result_msg,0,500), sysdate, 1);
                   
          end if;
                  
        exception
          when others then
            o_result_msg := 'Insert SEND flag (create) Failed [' || sqlcode || ' ' || substr(sqlerrm,1,255) || ']';
            o_result := plt_common.failure;
            raise e_process_exception;
        end;
            
      end if; -- on not on Hold section complete       
    
      /*-*/
      /* only send Tolas files if the Pallet Code is for a Finished Good
      /*-*/
      if length(i_plt_code) > 10 and length(ltrim(i_material_code,'0')) = 8 then
                
        /*-*
        /* get a sequence number for the Tolas interface
        /*-*/
        begin
          select plt_tolas_seq.nextval into v_seq from dual;
          insert into plt_tolas values (i_plt_code, v_seq);
        end;
                   
        begin
          /*-*/
          /* only for Plant codes Cannery and Bathurst 
          /*-*/
          if i_plant_code = 'AU20'  OR  i_plant_code = 'AU30' then
            /*-*/
            /* send the FDS file to Tolas
            /* this file is based on plant and will be assigned to a different queue for the 2 Plant Codes
            /* defined in the If statement
            /*-*/
            tolas_fds_send
            (
              v_result,
              v_result_msg,
              v_transaction_type,
              i_plant_code,
              i_sender_name || ':' || substr(i_plt_code,1,18), 
              b_test_flag,
              i_proc_order,
              trunc(i_xactn_date),
              to_number(to_char(i_xactn_date,'hh24miss')),
              i_material_code,
              i_qty,
              v_work1,
              v_work,
              i_dispn_code,
              v_batch,
              to_char(i_use_by_date,'yyyymmdd'),
              i_plt_code,
              i_plt_type,
              'CHEP',
              trunc(i_start_prodn_date),
              to_number(to_char(i_start_prodn_date,'hh24miss')),
              trunc(i_end_prodn_date),
              to_number(to_char(i_end_prodn_date,'hh24miss')),
              to_char(lpad(v_seq,8,'0'))
            );
          end if;
                                 
                    
          /*-*/
          /* the LDTS file is sent to the same queue for all plants
          /* for Petcare
          /*-*/
          tolas_ltds_send
          (
            v_result,
            v_result_msg,
            v_transaction_type,
            i_plant_code,
            i_material_code,
            i_qty,
            i_dispn_code,
            v_batch,
            to_char(i_use_by_date,'yyyymmdd'),
            i_plt_code,
            to_char(lpad(v_seq,8,'0'))
          );
          
          commit;
                    
        exception
          when others then
            o_result_msg := 'Call to Tolas_Send (create) Failed [' || sqlcode || ' ' || substr(sqlerrm,1,255) || ']';
            o_result := plt_common.failure;
            rollback;
            raise e_process_exception;
        end;
      end if;  -- end of send if pallet code is a real code 
                  
    else
      update plt_det
      set sent_flag = 'X'
      where plt_code = upper(i_plt_code);        
                          
    end if; -- end of Temp pallet or FG/Process pallet
          
  exception
    when e_process_exception then
      o_result := plt_common.failure;
      rollback;
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
    when others then
      o_result := plt_common.failure;
      o_result_msg := 'ERROR OCCURED' || sqlcode || '-' || substr(sqlerrm,1,255);
      rollback;
  end create_pllt;
  
  /**********************************************************************************/
  /* Cancel Pallet record - special for Handling Units 
  /* - the pallet record has to exist and it should be CREATE status
  /**********************************************************************************/     
  procedure cancel_pllt
  (
    o_result      in out number,
    o_result_msg  in out varchar2,
    i_xactn_date  in date,
    i_sender_name in varchar2,
    i_plt_code    in varchar2,
    i_user_id     in varchar2
  ) as
  
    b_last_gr_flag      boolean := false;
    v_count             number;
    v_transaction_type  varchar2(10);
    v_result            number;
    v_result_msg        varchar2(2000);
    v_proc_order        varchar2(12);
    e_process_exception exception;
    e_idoc_exception    exception;
           
    trans_type          varchar2(10) default 'CANCEL';
           
    cursor c_get_plt is
      select h.*, 
        sent_flag
      from plt_hdr h, 
        plt_det d
      where h.plt_code = i_plt_code
        and h.plt_code = d.plt_code
        and d.xactn_type = 'CREATE';         
    r_plt c_get_plt%rowtype;
              
  begin

    o_result := plt_common.success;
    o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';   
   
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving in TABLE
    /**********************************************************************************/   
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    
    if ( v_count <> 1 ) then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
      
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CANCEL';
        
    if ( v_count > 0 ) then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check validity of dates
    if ( i_xactn_date is null ) then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check SEnder name
    if ( i_sender_name is null ) then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;   
   
    v_transaction_type := 'Z_PI2'; -- set atlas type code 
   
    -- get rest of pallet data 
    open c_get_plt;
    fetch c_get_plt into r_plt;
    loop
      exit when c_get_plt%notfound;
       
      /**********************************************************************************/
      /* Save data in Pallet tables
      /**********************************************************************************/
      begin
        update plt_hdr 
        set status = trans_type
        where plt_code = r_plt.plt_code;
                            
        /**********************************************************************************/                 
        /* Insert detail record 
        /**********************************************************************************/
        insert into plt_det 
        (
          plt_code,
          xactn_type,
          user_id,
          reason,
          xactn_date,
          xactn_time,
          sender_name,
          atlas_type
        )
        values 
        (
          i_plt_code,
          trans_type,
          upper(i_user_id),
          trans_type,
          trunc(i_xactn_date),
          to_number(to_char(i_xactn_date,'hh24miss')),
          upper(i_sender_name),
          v_transaction_type
        );  
                             
      exception
        when others then
          o_result := plt_common.failure;
          o_result_msg := 'Update (CANCEL) into plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
      end;

      /**********************************************************************************/
      /* Create Idoc package for Cancel 
      /**********************************************************************************/

      if ( not idoc_hold ) then
        begin
                
          select proc_order into v_proc_order
          from plt_hdr
          where plt_code = i_plt_code;
                     
          if substr(v_proc_order,1,2) <> '99'  then                   
                  
            if r_plt.last_gr_flag = 'Y' then
              b_last_gr_flag := true;
            else
              b_last_gr_flag := false;
            end if;
                  
            -- make call to create idoc
            goods_recipte_send
            (
              v_result,
              v_result_msg,
              v_transaction_type,
              trim(r_plt.plant_code),
              i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
              b_test_flag,
              to_number(r_plt.proc_order),
              trunc(i_xactn_date),
              to_number(to_char(i_xactn_date,'hh24miss')),
              r_plt.matl_code,
              r_plt.qty,
              r_plt.uom,
              to_number(r_plt.stor_locn_code),
              r_plt.dispn_code,
              r_plt.zpppi_batch,
              b_last_gr_flag,
              to_char(r_plt.use_by_date,'yyyymmdd'),
              i_plt_code,
              r_plt.plt_type,
              '1095',
              trunc(sysdate), -- dummy entry 
              0,           -- dummy entry 
              trunc(sysdate), -- dummy entry 
              0           -- dummy entry 
            );                        
                           
            if ( v_result <> 0 ) then
              -- error has occured 
              -- insert record in log file
              o_result_msg := v_result_msg;
              o_result := v_result;
              
              insert into plt_idoc_log
              values (i_plt_code, trans_type, 0, 'FAIL',o_result_msg, sysdate, o_result);
              
              o_result_msg := '';
              o_result := plt_common.success;
              raise e_idoc_exception;
            end if;
                         
          end if;
         
        exception
          when others then
            o_result_msg := 'Call to Goods_Recipte_Send Failed [' || sqlerrm || ']';
            o_result := plt_common.failure;
            raise e_process_exception;
        end;
      end if;
        
      begin
        if substr(v_proc_order,1,2) = '99' then
          update plt_det
          set sent_flag = 'X'
          where plt_code = upper(i_plt_code);
        else
          if not idoc_hold then
            update plt_det
            set sent_flag = 'Y'
            where plt_code = upper(i_plt_code);
          end if;
        end if;

      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_Pllt> Error updating sent flag on pts_intfc: [' || sqlerrm || ']';
          o_result := plt_common.failure;
          raise e_process_exception;
      end;
          
      exit;
          
    end loop;
    close c_get_plt;    
     
    commit;

  exception
    when e_process_exception then
      o_result := plt_common.failure;
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
    when others then
      o_result := plt_common.failure;
      o_result_msg := 'ERROR OCCURED'||sqlerrm(sqlcode);
      rollback;
  end cancel_pllt;

  /**********************************************************************************/
  /* Cancel Pallet record - special for Handling Units 
  /* - the pallet record has to exist and it should be CREATE status
  /**********************************************************************************/  
  procedure cancel_hu_pllt  
  (
    o_result      in out number,
    o_result_msg  in out varchar2,
    i_xactn_date  in date,
    i_sender_name in varchar2,
    i_plt_code    in varchar2,
    i_user_id     in varchar2
  ) as     
      
    b_last_gr_flag      boolean := false;
    v_count             number;
    v_transaction_type  varchar2(10);
    v_result            number;
    v_result_msg        varchar2(2000);
    v_proc_order        varchar2(12);
    v_seq               number;
         
    e_process_exception exception;
    e_idoc_exception    exception;
           
    trans_type          varchar2(10) default 'CANCEL';
           
    cursor c_get_plt is
      select h.*, 
        sent_flag
      from plt_hdr h, 
        plt_det d
      where h.plt_code = i_plt_code
        and h.plt_code = d.plt_code
        and d.xactn_type = 'CREATE';           
    r_plt c_get_plt%rowtype;      
       
  begin

    o_result := plt_common.success;
    o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';
      
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving in TABLE
    /**********************************************************************************/       
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
        
    if ( v_count <> 1 ) then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
      
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and STATUS = 'CANCEL';
        
    if ( v_count > 0 ) then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check validity of dates
    if ( i_xactn_date is null ) then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check SEnder name
    if ( i_sender_name is null ) then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    v_transaction_type := 'Z_PI6'; -- set atlas type code 
   
    -- get rest of pallet data 
    open c_get_plt;
    fetch c_get_plt into r_plt;
    loop
      exit when c_get_plt%notfound;

      /**********************************************************************************/
      /* Save data in Pallet tables
      /**********************************************************************************/
      begin
        update plt_hdr
        set status = trans_type
        where plt_code = r_plt.plt_code;
           
        /**********************************************************************************/                 
        /* Insert detail record 
        /**********************************************************************************/
        insert into plt_det 
        (
          plt_code,
          xactn_type,
          user_id,
          reason,
          xactn_date,
          xactn_time,
          sender_name,
          atlas_type
        )
        values 
        (
          i_plt_code,
          trans_type,
          upper(i_user_id),
          trans_type,
          trunc(i_xactn_date),
          to_number(to_char(i_xactn_date,'hh24miss')),
          upper(i_sender_name),
          v_transaction_type 
        );                     
                    
      exception
        when others then
          o_result := plt_common.failure;
          o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> update into plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
      end;

      /**********************************************************************************/
      /* Create Idoc package for Cancel 
      /**********************************************************************************/
      /*-*/
      /* first get the process order number
      /*-*/
      select proc_order 
      into v_proc_order
      from plt_hdr
      where plt_code = i_plt_code;       
      
      begin
        /*-*/
        /* only send cancel to Atlas and Tolas if the pallet code is a valid value
        /*-*/
        if substr(v_proc_order,1,2) <> '99'  then 
                      
          if r_plt.last_gr_flag = 'Y' then
            b_last_gr_flag := true;
          else
            b_last_gr_flag := false;
          end if;

          if not idoc_hold then
            /*-*/
            /* Make call to create iDOC
            /*-*/
            goods_recipte_send
            (
              v_result,
              v_result_msg,
              v_transaction_type,
              trim(r_plt.plant_code),
              i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
              b_test_flag,
              to_number(r_plt.proc_order),
              trunc(i_xactn_date),
              to_number(to_char(i_xactn_date,'hh24miss')),
              r_plt.matl_code,
              r_plt.qty,
              r_plt.uom,
              to_number(r_plt.stor_locn_code),
              r_plt.dispn_code,
              r_plt.zpppi_batch,
              b_last_gr_flag,
              to_char(r_plt.use_by_date,'yyyymmdd'),
              i_plt_code,
              r_plt.plt_type,
              '',
              trunc(sysdate), -- dummy entry 
              0,         -- dummy entry 
              trunc(sysdate), -- dummy entry 
              0         -- dummy entry 
            );
                            
            /*-*/
            /* set sent flag if no errors found
            /*-*/
            if v_result <> 0 then
              -- error has occured 
              -- insert record in log file
              o_result_msg := v_result_msg;
              o_result := v_result;
              
              insert into plt_idoc_log
              values (i_plt_code, trans_type, 0, 'FAIL', substr(o_result_msg,0,500), sysdate, o_result);
              
              o_result_msg := '';
              o_result := plt_common.success;
              raise e_idoc_exception;
            end if;                      
          end if;
        end if;
       
      exception
        when others then
          o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error: Call to Goods_Recipte_Send Failed [' || substr(sqlerrm,0,255) || ']';
          o_result := plt_common.failure;
          raise e_process_exception;
      end;     
      
      /*-*/
      /* insert the sent flag if everything ok
      /*-*/  
      begin
        if substr(v_proc_order,1,2) = '99' then
          update plt_det
          set sent_flag = 'X'
          where plt_code = upper(i_plt_code);
        else
          if not idoc_hold then
            update plt_det
            set sent_flag = 'Y'
            where plt_code = upper(i_plt_code);
          end if;
        end if;

      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error updating sent flag on pts_intfc: [' || sqlerrm || ']';
          o_result := plt_common.failure;
          raise e_process_exception;
      end;
      /*-*/
      /* Cancel sent to atlas
      /*-*/
        
      /*-*/
      /* now send Tolas Files if required
      /*-*/
      begin
        /*-*/
        /* only for Plant codes Cannery and Bathurst 
        /*-*/
        if r_plt.plant_code = 'AU20'  OR  r_plt.plant_code = 'AU30' then
              
          /*-*/
          /* get a sequence number for the Tolas interface
          /*-*/
          begin
            select plt_tolas_seq.nextval into v_seq from dual;
            insert into plt_tolas
            values (i_plt_code, v_seq);
          end;
                                    
          /*-*/
          /* send the FDS file to Tolas
          /* this file is based on plant and will be assigned to a different queue for the 2 Plant Codes
          /* defined in the If statement
          /*-*/
          tolas_fds_send
          (
            v_result,
            v_result_msg,
            v_transaction_type,
            r_plt.plant_code,
            i_sender_name || ':' || substr(i_plt_code,1,18), 
            b_test_flag,
            v_proc_order,
            trunc(i_xactn_date),
            to_number(to_char(i_xactn_date,'hh24miss')),
            r_plt.matl_code,
            r_plt.qty,
            r_plt.uom,
            r_plt.stor_locn_code,
            r_plt.dispn_code,
            r_plt.zpppi_batch,
            to_char(r_plt.use_by_date,'yyyymmdd'),
            i_plt_code,
            r_plt.plt_type,
            'CHEP',
            trunc(sysdate), -- dummy entry 
            0,           -- dummy entry 
            trunc(sysdate), -- dummy entry 
            0,           -- dummy entry 
            to_char(lpad(v_seq,8,'0'))
          );
          
        end if;     
      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error sending Tolas files: [' || substr(sqlerrm,0,255) || ']';
          o_result := plt_common.failure;
          raise e_process_exception;
      end;
      /*-*/
      /* Tolas files sent
      /*-*/
        
      exit;
              
    end loop;
    close c_get_plt;             
         
    commit;

  exception
    when e_process_exception then
      o_result := plt_common.failure;
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
    when others then
      o_result := plt_common.failure;
      o_result_msg := 'ERROR OCCURED'||sqlerrm(sqlcode);
      rollback;
  end cancel_hu_pllt;


   /******************************************************/
  /* Create_Consumption will send on to Atlas
  /* this will record consumption of any material used within a 
  /* valid process order 
  /* o_result - 0 for successfull
  /*          - 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_consumption
  (
    o_result        in out number,
    o_result_msg    in out varchar2,
    i_trans_id      in number, --  uniquie id 
    i_xactn_date    in date,
    i_plant_code    in varchar2,
    i_proc_order    in varchar2,
    i_material_code in varchar2,
    i_qty           in number
  ) as
      
    e_process_exception exception;
    e_idoc_exception    exception;
    v_result            number default 0;
    v_result_msg        varchar2(2000);
    v_count             number;
    v_transaction_type  varchar2(10);
    v_work              number;
    v_work1             varchar2(10);
    v_seq               number;     
      
    cursor csr_matl is
      select issue_strg_locn, 
        decode(base_uom,'KGM','KG', base_uom) as uom 
      from matl_ics
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;
    
  begin
    
    o_result := plt_common.success;
    o_result_msg := '';
       
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving in TABLE 
    /**********************************************************************************/

    -- check plant code 
    if ( i_plant_code is null ) then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from manu.ref_plant
      where plant = i_plant_code;
      
      if ( v_count = 0 ) then
        o_result_msg := 'Plant Code is not correct.';
        o_result := plt_common.failure;
        raise e_process_exception;
      end if;
    end if;
       
    -- check for valid proc order
    if ( i_proc_order is null ) then
      o_result_msg := 'Proc Order is not valid.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      if ( substr(i_proc_order,1,2) <> '99' ) then
        select count(*) 
        into v_count 
        from manu.cntl_rec
        where ltrim(proc_order,'0') = ltrim(i_proc_order,'0');
        
        if ( v_count = 0 ) then
          o_result_msg := 'Proc Order is not valid.';
          o_result := plt_common.failure;
          raise e_process_exception;
        end if;
      end if;
    end if;
       
    -- check material code 
    -- material can be a substitution so it doesnt have to be in the process order bom 
    if i_material_code is null then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check validity of qty 
    if i_qty = 0 then
      o_result_msg := 'Quantity cannot be Null.';
      o_result :=plt_common.failure;
      raise e_process_exception;
    end if; 

    /**********************************************************************************/
    /* Create Idoc package for Create
    /**********************************************************************************/
    /*-*/																											 
    /* get storage location   
    /*-*/
    open csr_matl;
    loop
      fetch csr_matl into v_work, v_work1;
      exit when csr_matl%notfound;
    end loop;
    close csr_matl;
     
    /*-*/
    /* save data to table 
    /*-*/
    begin
    	 
      select plt_cnsmptn_id_seq.nextval into v_seq from dual;
      
      insert into plt_cnsmptn
      values 
      (
        v_seq,
        i_proc_order,
        i_material_code,
        i_qty,
        v_work1,
        i_plant_code,
        '',
        v_work,
        i_xactn_date,
        i_trans_id,
        'CREATE'
      );
      
      commit;
    		 
    exception
      when others then
        o_result := plt_common.failure;
        o_result_msg := 'ERROR OCCURED'|| substr(sqlerrm(sqlcode),0,255);
        rollback;
    end;		
				       
  exception
    when e_process_exception then
      o_result := plt_common.failure;
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
    when others then
      o_result := plt_common.failure;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      rollback;
  								
  end create_consumption;
	
  /******************************************************/
  /* Cancel_Consumption will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_consumption
  (
    o_result        in out number,
    o_result_msg    in out varchar2,
    i_trans_id		  in number, --  uniquie id 
    i_xactn_date		in date,
    i_plant_code		in varchar2,
    i_proc_order		in varchar2,
    i_material_code in varchar2,
    i_qty			      in number
  ) as
  	 
    e_process_exception exception;
    e_idoc_exception		exception;
    	 
    v_work						  number;
    v_work1					    varchar2(10);
    v_result            number default 0;
    v_result_msg        varchar2(2000);
    v_transaction_type  varchar2(10);
    v_seq					      varchar2(10);    	 
    	 
    /*-*/
    /* get storage location and uom from matl table
    /*-*/
    cursor csr_matl is
    select issue_strg_locn, 
      decode(base_uom,'KGM','KG', base_uom) uom 
    from matl_ics
    where ltrim(matl_code,'0') = i_material_code
      and plant = i_plant_code;		
	
  begin
  	 
    /*-*/
    /* get storage location and uom
    /*-*/
    open csr_matl;
    loop
      fetch csr_matl into v_work, v_work1;
      exit when csr_matl%notfound;
    end loop;
    close csr_matl;    		  
    		  
    /*-*/
    /* save data to table 
    /*-*/
    begin
    	 
      select plt_cnsmptn_id_seq.nextval into v_seq from dual;
      
      insert into plt_cnsmptn
      values 
      (
        v_seq,
        i_proc_order,
        i_material_code,
        i_qty,
        v_work1,
        i_plant_code,
        '',
        v_work,
        i_xactn_date,
        i_trans_id,
        'CANCEL'
      ); 
      
      commit;
      
    exception
      when others then
        o_result := plt_common.failure;
        o_result_msg := 'ERROR OCCURED' || substr(sqlerrm(sqlcode),0,255);
        rollback;
    end;
  		  
  exception
    when e_process_exception then
      o_result := plt_common.failure;
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
    when others then
      o_result := plt_common.failure;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      rollback;
  	 
  end cancel_consumption;

end tagsys_fctry_intfc_ics;
/

/**/
/* Authority 
/**/
grant execute on pt_app.tagsys_fctry_intfc_ics to appsupport;
grant execute on pt_app.tagsys_fctry_intfc_ics to citsrv1 with grant option;
grant execute on pt_app.tagsys_fctry_intfc_ics to pt_maint;
grant execute on pt_app.tagsys_fctry_intfc_ics to pt_user;
grant execute on pt_app.tagsys_fctry_intfc_ics to public;
grant execute on pt_app.tagsys_fctry_intfc_ics to shiftlog;

/**/
/* Synonym 
/**/
create or replace public synonym tagsys_fctry_intfc_ics for pt_app.tagsys_fctry_intfc_ics;