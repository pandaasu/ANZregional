create or replace package pt_app.tagsys_fctry_intfc as
  /* SNACK version only  */
  /*************************************************************************/
  /* this package contains 4 fprocedures 
  /*
  /*  This package is used for SNACK Ballarat and Scoresby only 
  /*  It has some small differences to the procedure used for Petcare
  /* Creat_Pllt - will perform a Goods receipt of either a pallet or process 
  /* Cancel_Pllt - will reverse a process qty 
  /* Cancel_HU_Pllt - will reverse a pallet from atlas ie cancel 
  /*************************************************************************/
   
   
  /*************************************************************************/
  /* NOTE: This Package is not the same as the one used in Wanganui or Food 
  /* it has been modified to handle the new HANDLING UNITS (pallet codes)
  /* and the package now uses the REMOTE_LOADER for transfer of data
  /* from Oracle to a file location on the Plant Database Server.
  /* this is then transferred via MQ Series Light to the LADS server 
  /* where is is sent again via MQ Series to Atlas via the HUB 
   
  /* Developer 	 Jeff Phillipson 
  /* Date			 13 Jan 2006 
  /* 19 Jul 2007      Jeff Phillipson     Changes to FG selection based on Batch code
  /* 15-Oct-2007      Jeff Phillipson     Added Reclaim feature to procedure
  /* 09-Jun-2009      Trevor Keon         Added logging on exceptions.
  /*************************************************************************/
 
  /*************************************************************************/
  /* Create_Pllt will record data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /*************************************************************************/
  procedure create_pllt(o_result        in out number,
                        o_result_msg     in out varchar2,
                        i_xactn_date	 in date,
                        i_plant_code	 in varchar2,
                        i_sender_name	 in varchar2,
                        i_zpppi_batch	 in varchar2,
                        i_proc_order	 in number,
                        i_dispn_code	 in varchar2,
                        i_use_by_date	 in date,
                        i_material_code	 in varchar2,
                        i_plt_code		 in varchar2,
                        i_qty			 in number,
                        i_full_plt_flag	 in varchar2,
                        i_user_id		 in varchar2,
                        i_last_gr_flag	 in varchar2,
                        i_plt_type		 in varchar2,
                        i_start_prodn_date in date,
                        i_end_prodn_date  in date);
     
  /******************************************************/
  /* Cancel_Pllt will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_pllt(o_result       in out number,
                        o_result_msg    in out varchar2,
                        i_xactn_date	in date,
                        i_sender_name	in varchar2,
                        i_plt_code		in varchar2,
                        i_user_id		in varchar2);  
     
  /******************************************************/
  /* Cancel_HU_Pllt will cancel pallets only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_hu_pllt(o_result        in out number,
                           o_result_msg     in out varchar2,
                           i_xactn_date		in date,
                           i_sender_name	in varchar2,
                           i_plt_code		in varchar2,
                           i_user_id		in varchar2);  
  	
  	
  /******************************************************/
  /* Create_Consumption will record data in PT schema and send on to Atlas 
  /* this will record consumption of any material used within a 
  /* valid process order 
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_consumption(o_result        in out number,
                               o_result_msg     in out varchar2,
                               i_trans_id		in number, --  uniquie id 
                               i_xactn_date		in date,
                               i_plant_code		in varchar2,
                               i_proc_order		in varchar2,
                               i_material_code	in varchar2,
                               i_qty			in number);
  	
   
  /******************************************************/
  /* Cancel_Consumption will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_consumption(o_result         in out number,
                               o_result_msg      in out varchar2,
                               i_trans_id		 in number, --  uniquie id 
                               i_xactn_date		 in date,
                               i_plant_code		 in varchar2,
                               i_proc_order		 in varchar2,
                               i_material_code	 in varchar2,
                               i_qty			 in number);  
	
 end tagsys_fctry_intfc;
/
create or replace package body pt_app.tagsys_fctry_intfc as
  /* SNACK version only  */
 
  procedure set_lock;
  procedure set_unlock;
  procedure log_exception(i_header in varchar2, i_search in varchar2, i_msg in varchar2, i_process_order in number default 0);
     
  b_test_flag				boolean := false; 
  /*-*/
  /* constants
  /*-*/
  reclaim_proc_order       constant varchar2(12) := '1';
   
  /******************************************************/
  /* Create_Pllt will record data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_pllt(o_result in out number,
                        o_result_msg             in out varchar2,
                        i_xactn_date			    in date,
                        i_plant_code			    in varchar2,
                        i_sender_name			in varchar2,
                        i_zpppi_batch			in varchar2,
                        i_proc_order			    in number,
                        i_dispn_code			    in varchar2,
                        i_use_by_date			in date,
                        i_material_code		    in varchar2,
                        i_plt_code				in varchar2,
                        i_qty					in number,
                        i_full_plt_flag		    in varchar2,
                        i_user_id				in varchar2,
                        i_last_gr_flag			in varchar2,
                        i_plt_type				in varchar2,
                        i_start_prodn_date 		in date,
                        i_end_prodn_date  		in date) as  	   
  		
    /*-*/
    /* Variables 
    /*-*/
    b_last_gr_flag			 boolean := false;
    v_count                  number := 0;
    v_transaction_type       varchar2(10);
    v_result                 number default 0;
    v_result_msg             varchar2(2000);
    v_batch                  varchar2(10);
    v_start_prodn_date		 varchar2(20);
    v_end_prodn_date		 varchar2(20);
    v_work					 number;
    v_work1					 varchar2(10);		
    v_seq					 number;
           
    trans_type               varchar2(10) default 'CREATE';
    		
    e_process_exception      exception;
    e_idoc_exception		 exception;
            
    /*-*/
    /* Cursor
    /*-*/
    cursor csr_matl is
      select issue_strg_locn, 
        decode(base_uom,'KGM','KG', base_uom) as uom 
      from matl_vw
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;		
		
  begin

    o_result := 0;
    o_result_msg := 'Pallet ' || i_plt_code || ' created';
    	
    /*-*/
    /* set prodn times to 6 char strings 
    /*-*/
    v_start_prodn_date := i_start_prodn_date;
    v_end_prodn_date := i_end_prodn_date;
	
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving IN TABLE 
    /**********************************************************************************/
    	
    /*-*/
    /*  Check if Pallet Code exists in the pallet tables only if a valid procedure order
    /*-*/
    if i_proc_order <> reclaim_proc_order then
      select count(*) 
      into v_count
      from plt_hdr
      where plt_code = to_char(i_plt_code);
      
      if v_count > 0 then
        o_result_msg := 'Transaction Failed: Pallet code already exists. Please select a unique value.';
        o_result := 1;
        raise e_process_exception; 
      end if;
    end if;
    
    /*-*/
    /*  check validity of date - transaction date cannot be null
    /*-*/
    if i_xactn_date is null then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    end if;
   
    /*-*/
    /* check plant code is valid and not null
    /*-*/
    if i_plant_code is null then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from ref_plant 
      where plant = i_plant_code;
      
      if v_count = 0 then
        o_result_msg := 'Plant Code is not correct.';
        o_result := 1;
        raise e_process_exception;
      end if;
    end if;
   
    /*-*/
    /* check for valid proc order
    /*-*/
    if i_proc_order is null then
      o_result_msg := 'Proc Order is not valid.';
      o_result := 1;
      raise e_process_exception;
    else
      if substr(i_proc_order,1,2) <> '99' and i_proc_order <> reclaim_proc_order then
        select count(*) 
        into v_count 
        from cntl_rec 
        where ltrim(proc_order,'0') = ltrim(to_char(i_proc_order),'0');
        
        if v_count = 0 then
          o_result_msg := 'Proc Order is not valid.';
          o_result := 1;
          raise e_process_exception;
        end if;
        
        /*-*/
        /* check for correct plant code
        /*-*/
        select count(*) 
        into v_count 
        from cntl_rec 
        where ltrim(proc_order,'0') = ltrim(to_char(i_proc_order),'0')
          and plant = i_plant_code;
          
        if v_count = 0 then
          o_result_msg := 'Plant code:' || i_plant_code || ' is incorrect for this proc order.' || i_proc_order;
          o_result := 1;
          raise e_process_exception;
        end if;
      end if;
    end if;
   
    /*-*/
    /* check for a valid material code 
    /*-*/
    if i_material_code is null then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from matl_vw 
      where matl_code = i_material_code;
      
      if v_count = 0 then
        o_result_msg := 'Material Code is not correct.';
        o_result := 1;
        raise e_process_exception;
      end if;
    end if;
   
    /*-*/
    /* check validity of qty 
    /*-*/
    if i_qty = 0 then
      o_result_msg := 'Quantity cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    end if;
  
    /*-*/
    /* check validity of best before date
    /*-*/
    if length(i_plt_code) = 18 and length(i_material_code) = 8 then
      if i_use_by_date is null then
        o_result_msg := 'Best before date cannot be Null.';
        o_result := 1;
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
    if i_dispn_code is null then
      o_result_msg := 'Disposition cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    else
      if i_dispn_code <> ' ' and i_dispn_code <> 'S' and i_dispn_code <> 'X' then
        o_result_msg := 'Disposition is not a valid value - Blank, ''S'' or ''X''.';
        o_result := 1;
        raise e_process_exception;
      end if;
    end if;
   
    /*-*/																											 
    /* get storage location, uom  
    /*-*/
    begin
      open csr_matl;
      fetch csr_matl into v_work, v_work1;
      
      if csr_matl%notfound then
        v_work1 := 'KG';
        v_work := '0020';
      end if;
      
      close csr_matl;
    exception
      when others then
        o_result_msg := 'Failed to get the MATL data from the view RETURN [' || sqlcode || '-' || substr(sqlerrm,1,255) ||']';
        o_result := 1;
        raise e_process_exception;
    end;
          
    if i_zpppi_batch is null then
      v_batch := ' ';
    else
      -- fg 
      v_batch := substr(i_zpppi_batch,1,30);
    end if;
    
    v_transaction_type := 'Z_PI1';
           
    if i_proc_order = reclaim_proc_order then
      select plt_tolas_seq.nextval 
      into v_seq 
      from dual;
      
      /*-*/
      /* just send tolas ltds file
      /*-*/
      pt_pdbtol02_ltds.execute
      (
        v_result,
        v_result_msg,
        v_transaction_type,
        i_plant_code,
        i_material_code,
        i_qty,
        i_dispn_code,
        v_batch,
        to_char(i_use_by_date,'YYYYMMDD'),
        i_plt_code,
        to_char(lpad(v_seq,8,'0'))
      );
      
      /*-*/
      /* and save
      /*-*/
      insert into plt_reclaim
      (
        reclaim_ltds_id,
        plt_code,
        material_code,
        qty,
        plant_code,
        proc_order,
        dispn_code,
        batch_code,
        use_by_date,
        transaction_type,
        last_upd_by,
        last_upd_datime
      )
      values 
      (
        v_seq,
        i_plt_code,
        i_material_code,
        i_qty,
        i_plant_code,
        i_proc_order,
        i_dispn_code,
        v_batch,
        i_use_by_date,
        v_transaction_type,
        'PT_APP',
        sysdate
      );
                                    
      lics_logging.start_log('Goods Recipt: Reclaim', 'Pallet code: ');
      lics_logging.write_log(i_plt_code);
      lics_logging.end_log;
    else
           
      set_lock();
   
      /**********************************************************************************/
      /* Save data in pallet tables
      /**********************************************************************************/
      begin
                    
        /**********************************************************************************/
        /* Insert record into header table
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
          upper(substr(i_user_id,1,8)),
          trans_type,
          trunc(i_xactn_date),
          to_number(to_char(i_xactn_date,'HH24MISS')),
          upper(i_sender_name)
        );   
              
        commit;
        			   
      exception
        when others then
          o_result_msg := 'INSERT (CREATE) INTO pt.plt_hdr and plt_det FAILED, RETURN [' || sqlcode || '-' || substr(sqlerrm,1,255) ||']';
          rollback;
          o_result := 1;
          raise e_process_exception;
      end;

      set_unlock();	
    
      /*-*/
      /* only send if the pallet code is areal Atlas code
      /* anything begining with 99 is a dummy - local code
      /* This will still allow FG Pallet Codes and Process to be sent
      /* Process will use an auto generated id for plt codes this will be less than 
      /* 10 digits long
      /*-*/
      if substr(i_proc_order,1,2) <> '99' then
        				
        if (i_last_gr_flag = 'Y') then
          b_last_gr_flag := true;
        end if;
				
        /**********************************************************************************/
        /* Create idoc package for create
        /**********************************************************************************/  
        begin
          /*-*/
          /* Make call to create idoc 
          /*-*/
          pt_cisatl17_gr.execute
          (
            v_result,
            v_result_msg,
            v_transaction_type,
            i_plant_code,
            i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
            b_test_flag,
            i_proc_order,
            trunc(i_xactn_date),
            to_number(to_char(i_xactn_date,'HH24MISS')),
            i_material_code,
            i_qty,
            v_work1,
            v_work,
            i_dispn_code,
            v_batch,
            b_last_gr_flag,
            to_char(i_use_by_date,'YYYYMMDD'),
            i_plt_code,
            i_plt_type,
            'CHEP',
            trunc(i_start_prodn_date),
            to_number(to_char(i_start_prodn_date,'HH24MISS')),
            trunc(i_end_prodn_date),
            to_number(to_char(i_end_prodn_date,'HH24MISS'))
          );
          
          commit;
          
        exception
          when others then
            o_result_msg := 'Call to Goods_Recipte_Send (create) Failed ['|| sqlcode || ' ' || substr(sqlerrm,1,255) ||']';
            o_result := 1;
            rollback;
            raise e_process_exception;
        end;        				
        			
        begin
          if v_result = 0 then
            update plt_det
            set sent_flag = 'Y'
            where plt_code = upper(i_plt_code);        
          end if;
          					
        exception
          when others then
            o_result_msg := 'Insert SEND flag (create) Failed ['|| sqlcode || ' ' || substr(sqlerrm,1,255) ||']';
            o_result := 1;
            raise e_process_exception;
        end;
				    
        /*-*/
        /* only send Tolas files if the Pallet Code is for a Finished Good
        /*-*/
        if length(i_plt_code) = 18 and length(ltrim(i_material_code,'0')) = 8 then
        				
          /*-*
          /* get a sequence number for the tolas interface
          /*-*/
          begin
            select plt_tolas_seq.nextval 
            into v_seq from dual;
            
            insert into plt_tolas
            values (i_plt_code, v_seq);
          end;
        					 
          begin						 
            /*-*/
            /* the ldts file is sent to the same queue for all plants
            /* for petcare
            /*-*/
            pt_pdbtol02_ltds.execute
            (
              v_result,
              v_result_msg,
              v_transaction_type,
              i_plant_code,
              i_material_code,
              i_qty,
              i_dispn_code,
              v_batch,
              to_char(i_use_by_date,'YYYYMMDD'),
              i_plt_code,
              to_char(lpad(v_seq,8,'0'))
            );
            
            commit;
            					
          exception
            when others then
              o_result_msg := 'Call to Tolas_Send (create) Failed ['|| sqlcode || ' ' || substr(sqlerrm,1,255) ||']';
              o_result := 1;
              rollback;
              raise e_process_exception;
          end;
        end if;  -- end of send if pallet code is a real code 
								
      else
        update pt.plt_det
        set sent_flag = 'X'
        where plt_code = upper(i_plt_code);  
      end if; -- end of Temp pallet or FG/Process pallet
            
    end if;  
    		
  exception
    when e_process_exception then
      o_result := 1;
      log_exception('Create Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, i_proc_order);
      rollback;
    when e_idoc_exception then
      commit;
      o_result := 0;
      log_exception('Create Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, i_proc_order);
    when others then
      o_result := 1;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlcode || '-' || substr(sqlerrm,1,255);
      log_exception('Create Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, i_proc_order);
  end;

  /**********************************************************************************/
  /* Cancel Pallet record - special for Handling Units 
  /* - the pallet record has to exist and it should be CREATE status
  /**********************************************************************************/     
  procedure cancel_pllt(o_result in out number,
                        o_result_msg   in out varchar2,
                        i_xactn_date	in date,
                        i_sender_name	in varchar2,
                        i_plt_code		in varchar2,
                        i_user_id		in varchar2) as

    b_last_gr_flag		boolean := false;
    v_count              number;
    v_transaction_type   varchar2(10);
    v_result             number;
    v_result_msg         varchar2(2000);
    v_proc_order         varchar2(12);
    e_process_exception  exception;
    e_idoc_exception		exception;
           
    trans_type           varchar2(10) default 'CANCEL';
           
    cursor c_get_plt is
      select h.*, sent_flag
      from plt_hdr h, plt_det d
      where h.plt_code = i_plt_code
        and h.plt_code = d.plt_code
        and d.xactn_type = 'CREATE';         
    r_plt  c_get_plt%rowtype;
       
       
  begin

    o_result := 0;
    o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';
    
    /**********************************************************************************/
    /* VALIDATE data BEFORE saving IN TABLE
    /**********************************************************************************/
    select count(*) into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    	  
    if v_count <> 1 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := 1;
      raise e_process_exception;
    end if;
      
    select count(*) into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CANCEL';
    		
    if v_count > 0 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    -- check validity of dates
    if i_xactn_date is null then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    -- check sender name
    if i_sender_name is null then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    v_transaction_type := 'Z_PI2'; -- set atlas type code 
   
   -- get rest of pallet data 
    open c_get_plt;
    loop    
      fetch c_get_plt into r_plt;
      exit when c_get_plt%notfound;
   
       -- check Sif Sent Flag is set - if not warn shiftlog to get it fixed before Cancelling Pallet
       /*
       IF r_plt.Sent_flag IS NULL THEN
           o_result_msg := 'Warning the Pallet ingformation has not been sent to Atlas.' || CHR(13) 
                            || ' Please consult your Support team.';
           o_result := 1;
           RAISE e_process_exception;
       END IF;
       */
       /**********************************************************************************/
       /* Save data in Pallet tables
       /**********************************************************************************/

      begin
        update pt.plt_hdr 
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
          to_number(to_char(i_xactn_date,'HH24MISS')),
          upper(i_sender_name),
          v_transaction_type
        );            
      exception
        when others then
          o_result := 1;
          o_result_msg := 'UPDATE (CANCEL) INTO pt.plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
      end;

      /**********************************************************************************/
      /* Create Idoc package for Cancel 
      /**********************************************************************************/
      begin
              
        select proc_order 
        into v_proc_order
        from plt_hdr
        where plt_code = i_plt_code;
                   
        if substr(v_proc_order,1,2) <> '99'  then 	
        				
          if r_plt.last_gr_flag = 'Y' then
            b_last_gr_flag := true;
          else
            b_last_gr_flag := false;
          end if;

          -- make call to create idoc
          pt_cisatl17_gr.execute
          (
            v_result,
            v_result_msg,
            v_transaction_type,
            trim(r_plt.plant_code),
            i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
            b_test_flag,
            to_number(r_plt.proc_order),
            trunc(i_xactn_date),
            to_number(to_char(i_xactn_date,'HH24MISS')),
            r_plt.matl_code,
            r_plt.qty,
            r_plt.uom,
            to_number(r_plt.stor_locn_code),
            r_plt.dispn_code,
            r_plt.zpppi_batch,
            b_last_gr_flag,
            to_char(r_plt.use_by_date,'YYYYMMDD'),
            i_plt_code,
            r_plt.plt_type,
            '1095',
            trunc(sysdate), -- dummy entry 
            0, 				  -- dummy entry 
            trunc(sysdate), -- dummy entry 
            0 				  -- dummy entry 
          );                      
                       
          if v_result <> 0 then
            -- error has occured 
            o_result_msg := v_result_msg;
            o_result := v_result;
            raise e_idoc_exception;
          end if;                       
        end if;
       
      exception
        when others then
          o_result_msg := 'Call to Goods_Recipte_Send Failed ['||sqlerrm||']';
          o_result := 1;
          raise e_process_exception;
      end;
        
      begin
        if substr(v_proc_order,1,2) = '99' then
          update pt.plt_det
          set sent_flag = 'X'
          where plt_code = upper(i_plt_code);
        else
          update pt.plt_det
          set sent_flag = 'Y'
          where plt_code = upper(i_plt_code);
        end if;

      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_Pllt> Error updating sent flag on pts_intfc: ['||sqlerrm||']';
          o_result := 1;
          raise e_process_exception;
      end;
            
    exit;
            
    end loop;
    close c_get_plt;          
       
    commit;

  exception
    when e_process_exception then
      o_result := 1;
      log_exception('Cancel Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when e_idoc_exception then
      commit;
      o_result := 0;
      log_exception('Cancel Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when others then
      o_result := 1;
      rollback;
      o_result_msg := 'ERROR OCCURED'||sqlerrm(sqlcode);
      log_exception('Cancel Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
  end;

  /**********************************************************************************/
  /* Cancel Pallet record - special for Handling Units 
  /* - the pallet record has to exist and it should be CREATE status
  /**********************************************************************************/  
  procedure cancel_hu_pllt(o_result      in out number,
                           o_result_msg  in out varchar2,
                           i_xactn_date	in date,
                           i_sender_name	in varchar2,
                           i_plt_code		in varchar2,
                           i_user_id		in varchar2) as   	   
  	   
  	  
      b_last_gr_flag		boolean := false;
      v_count              number;
      v_transaction_type   varchar2(10);
      v_result             number;
      v_result_msg         varchar2(2000);
      v_proc_order         varchar2(12);
      v_seq				number;
      	   
      e_process_exception  exception;
      e_idoc_exception		exception;
             
      trans_type           varchar2(10) default 'CANCEL';
             
      cursor c_get_plt is
        select h.*, sent_flag
        from plt_hdr h, plt_det d
        where h.plt_code = i_plt_code
          and h.plt_code = d.plt_code
          and d.xactn_type = 'CREATE';               
      r_plt  c_get_plt%rowtype;    
  begin

    o_result := 0;
    o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';

    /**********************************************************************************/
    /* validate data before saving in table
    /**********************************************************************************/
    select count(*) into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    	  
    if v_count <> 1 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := 1;
      raise e_process_exception;
    end if;
      
    select count(*) into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CANCEL';
    		
    if v_count > 0 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    -- check validity of dates
    if i_xactn_date is null then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    -- check sender name
    if i_sender_name is null then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    v_transaction_type := 'Z_PI6'; -- set atlas type code 
  
    -- get rest of pallet data 
    open c_get_plt;
    loop
      fetch c_get_plt into r_plt;
      exit when c_get_plt%notfound;

      /**********************************************************************************/
      /* save data in pallet tables
      /**********************************************************************************/
      begin
        update pt.plt_hdr 
        set status = trans_type
        where plt_code = r_plt.plt_code;
  	  	   
        /**********************************************************************************/                 
        /* insert detail record 
        /**********************************************************************************/
        insert into  plt_det 
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
          to_number(to_char(i_xactn_date,'HH24MISS')),
          upper(i_sender_name),
          v_transaction_type
        ); 
              
      exception
        when others then
          o_result := 1;
          o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> UPDATE INTO pt.plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
          raise e_process_exception;
      end;

      /**********************************************************************************/
      /* create idoc package for cancel 
      /**********************************************************************************/
      /*-*/
      /* first get the process order number
      /*-*/
      select proc_order into v_proc_order
      from plt_hdr
      where plt_code = i_plt_code;
        
      begin
        /*-*/
        /* only send cancel to atlas and tolas if the pallet code is a valid value
        /*-*/
        if substr(v_proc_order,1,2) <> '99'  then
          if r_plt.last_gr_flag = 'Y' then
            b_last_gr_flag := true;
          else
            b_last_gr_flag := false;
          end if;
          
          /*-*/
          /* make call to create idoc
          /*-*/
          pt_cisatl17_gr.execute
          (
            v_result,
            v_result_msg,
            v_transaction_type,
            trim(r_plt.plant_code),
            i_sender_name || ':' || substr(i_plt_code,1,18), --i_sender_name,
            b_test_flag,
            to_number(r_plt.proc_order),
            trunc(i_xactn_date),
            to_number(to_char(i_xactn_date,'HH24MISS')),
            r_plt.matl_code,
            r_plt.qty,
            r_plt.uom,
            to_number(r_plt.stor_locn_code),
            r_plt.dispn_code,
            r_plt.zpppi_batch,
            b_last_gr_flag,
            to_char(r_plt.use_by_date,'YYYYMMDD'),
            i_plt_code,
            r_plt.plt_type,
            '',
            trunc(sysdate), -- dummy entry 
            0, 			  -- dummy entry 
            trunc(sysdate), -- dummy entry 
            0 			  -- dummy entry 
          );
                      
          /*-*/
          /* set sent flag if no errors found
          /*-*/
          if v_result <> 0 then
            -- error has occured 
            o_result_msg := v_result_msg;
            o_result := v_result;
            raise e_idoc_exception;
          end if;
        end if;
       
      exception
        when others then
          o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error: Call to Goods_Recipte_Send Failed [' || substr(sqlerrm,0,255) || ']';
          o_result := 1;
          raise e_process_exception;
      end;
       
        
      /*-*/
      /* insert the sent flag if everything ok
      /*-*/  
      begin
        if substr(v_proc_order,1,2) = '99' then
          update pt.plt_det
          set sent_flag = 'X'
          where plt_code = upper(i_plt_code);
        else
          update pt.plt_det
          set sent_flag = 'Y'
          where plt_code = upper(i_plt_code);
        end if;
      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error updating sent flag on pts_intfc: [' || sqlerrm || ']';
          o_result := 1;
          raise e_process_exception;
      end;
      		
      exit;
              
    end loop;
    
    close c_get_plt;   
    commit;

  exception
    when e_process_exception then
      o_result := 1;
      log_exception('Cancel HU Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when e_idoc_exception then
      commit;
      o_result := 0;
      log_exception('Cancel HU Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when others then
      o_result := 1;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      log_exception('Cancel HU Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
  end;

  /******************************************************/
	/* Create_Consumption will send on to Atlas
	/* this will record consumption of any material used within a 
	/* valid process order 
	/* o_result - 0 for successfull
	/*      		- 1 for a failure 
	/* o_result_msg - if o_result is 1 then this will contain the error message 
	/******************************************************/
  procedure create_consumption(o_result          in out number,
                               o_result_msg      in out varchar2,
                               i_trans_id		 in number, --  uniquie id 
                               i_xactn_date		 in date,
                               i_plant_code		 in varchar2,
                               i_proc_order		 in varchar2,
                               i_material_code	 in varchar2,
                               i_qty			 in number) as
  		
    e_process_exception      exception;
    e_idoc_exception			exception;
    v_result                 number default 0;
    v_result_msg             varchar2(2000);
    v_count 					number;
    v_transaction_type       varchar2(10);
    v_work   				number;
    v_work1					varchar2(10);
    v_seq					number;  		
  		
    cursor csr_matl is
      select issue_strg_locn, 
        decode(base_uom,'KGM','KG', base_uom) as uom 
      from matl_vw
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;
  		
  begin
  	
    o_result := 0;
    o_result_msg := '';
       
    /**********************************************************************************/
    /* validate data before saving in table 
    /**********************************************************************************/

    -- check plant code 
    if i_plant_code is null then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from manu.ref_plant 
      where plant = i_plant_code;
      
      if v_count = 0 then
        o_result_msg := 'Plant Code is not correct.';
        o_result := 1;
        raise e_process_exception;
      end if;
    end if;
       
    -- check for valid proc order
    if i_proc_order is null then
      o_result_msg := 'Proc Order is not valid.';
      o_result := 1;
      raise e_process_exception;
    else
      if substr(i_proc_order,1,2) <> '99' then
        select count(*) 
        into v_count 
        from manu.cntl_rec 
        where ltrim(proc_order,'0') = ltrim(i_proc_order,'0');
        
        if v_count = 0 then
          o_result_msg := 'Proc Order is not valid.';
          o_result := 1;
          raise e_process_exception;
        end if;
      end if;
    end if;
       
    -- check material code 
    -- material can be a substitution so it doesnt have to be in the process order bom 
    if i_material_code is null then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := 1;
      raise e_process_exception;
    end if;
       
    -- check validity of qty 
    if i_qty = 0 then
      o_result_msg := 'Quantity cannot be Null.';
      o_result :=1;
      raise e_process_exception;
    end if;
  	
    /**********************************************************************************/
    /* create idoc package for create
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
    	 
      select plt_cnsmptn_id_seq.nextval 
      into v_seq 
      from dual;
      
      insert into plt_cnsmptn values 
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
        nvl(i_trans_id,''),
        'CREATE'
      ); 
    
      commit;
      o_result_msg := to_char(v_seq);
    
    exception
      when others then
        o_result := 1;
        rollback;
        o_result_msg := 'ERROR OCCURED'||substr(sqlerrm(sqlcode),0,255);
        raise e_process_exception;
    end;
				       
  exception
    when e_process_exception then
      o_result := 1;
      log_exception('Create Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
    when e_idoc_exception then
      commit;
      o_result := 0;
      log_exception('Create Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
    when others then
      o_result := 1;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      log_exception('Create Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
  end create_consumption;
   
  /******************************************************/
  /* Cancel_Consumption will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_consumption(o_result          in out number,
                               o_result_msg      in out varchar2,
                               i_trans_id		 in number, --  uniquie id 
                               i_xactn_date		 in date,
                               i_plant_code		 in varchar2,
                               i_proc_order		 in varchar2,
                               i_material_code	 in varchar2,
                               i_qty			 in number) as
  	 
    e_process_exception         exception;
    e_idoc_exception			 exception;
    	 
    v_work						 number;
    v_work1					 varchar2(10);
    v_result                	 number default 0;
    v_result_msg            	 varchar2(2000);
    v_transaction_type    	 	 varchar2(10);
    v_seq					     varchar2(10);
    	 
    	 
    /*-*/
    /* get storage location and uom from matl table
    /*-*/
    cursor csr_matl is
      select issue_strg_locn, decode(base_uom,'KGM','KG', base_uom) uom from matl_vw
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;  		
  	
  begin
         
    o_result := 0;
    
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
      select plt_cnsmptn_id_seq.nextval 
      into v_seq 
      from dual;
      
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
      o_result_msg := to_char(v_seq);
    exception
      when others then
        o_result := 1;
        rollback;
        o_result_msg := 'ERROR OCCURED'||substr(sqlerrm(sqlcode),0,255);
        raise e_process_exception;
    end;
  		  
  exception
    when e_process_exception then
      o_result := 1;
      log_exception('Cancel Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);      
    when e_idoc_exception then
      commit;
      o_result := 0;
      log_exception('Cancel Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
    when others then
      o_result := 1;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      log_exception('Cancel Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
  end;
    
  /*-*/
  /* set a v$session variable to lock the procedure
  /*-*/
  procedure set_lock is
       
    var_lock_handle varchar2(128);
    var_status      number;
    var_client_info varchar2(200);
           
  begin
    /*-*/ 
    /* get the client info sesssion information 
    /*-*/ 
    dbms_application_info.read_client_info(var_client_info);
    
    if var_client_info is null  then
      /*-*/
      /* if result is null so the tagsys_fctry_intfc procedure is not in use
      /* so setup lock for this user 
      /* set up a lock so that v$ession can be written to exclusivly 
      /*-*/
      dbms_lock.allocate_unique('PT_APP', var_lock_handle);        	
      var_status := dbms_lock.request(var_lock_handle, dbms_lock.x_mode, dbms_lock.maxwait); -- hope x_mode = 6  
      
      if var_status > 1 then
        raise_application_error(-20000, 'Tagsys_Sys_Intfc.Check_Sends_Plt  - Unable to aquire lock ');
      end if;
      
      /*-*/
      /* update the v$session client field 
      /*-*/
      dbms_application_info.set_client_info('IN_USE'); 
      
      /*-*/
      /* release lock  
      /*-*/
      var_status := dbms_lock.release(var_lock_handle);
               
    end if;  
          
  exception
    when others then
      raise_application_error(-20000, 'set_lock ERROR OCCURED' || substr(sqlerrm(sqlcode),0,255));
  end;
     
  /*-*/
  /* set a v$session variable to unlock the procedure
  /*-*/
  procedure set_unlock is
       
    var_lock_handle varchar2(128);
    var_status      number;
    var_client_info varchar2(200);
           
  begin
    dbms_lock.allocate_unique('PT_APP', var_lock_handle);      	
    var_status := dbms_lock.request(var_lock_handle, dbms_lock.x_mode, dbms_lock.maxwait); -- hope x_mode = 6  
    
    if var_status > 1 then
      raise_application_error(-20000, 'Tagsys_Sys_Intfc.Check_Sends_Plt  - Unable to aquire lock ');
    end if;
    
    /*-*/
    /* update the v$session client field 
    /*-*/
    dbms_application_info.set_client_info(''); 
    
    /*-*/
    /* release lock  
    /*-*/
    var_status := dbms_lock.release(var_lock_handle);
           
  exception
    when others then
      raise_application_error(-20000, 'set_unlock ERROR OCCURED' || substr(sqlerrm(sqlcode),0,255));
  end; 
  
  procedure log_exception(i_header in varchar2, i_search in varchar2, i_msg in varchar2, i_process_order in number default 0) is
  
  begin
  
    lics_logging.start_log(i_header, i_search);
    lics_logging.write_log(i_msg);
    
    if i_process_order <> 0 then
      lics_logging.write_log('Process Order: ' || i_process_order);
    end if;
    
    lics_logging.end_log;
  
  end;       
       
end tagsys_fctry_intfc;
/

grant execute on pt_app.tagsys_fctry_intfc to appsupport with grant option;
grant execute on pt_app.tagsys_fctry_intfc to fcs_reader;
grant execute on pt_app.tagsys_fctry_intfc to fcs_user with grant option;
grant execute on pt_app.tagsys_fctry_intfc to pkgspec_user;
grant execute on pt_app.tagsys_fctry_intfc to pt_user;

create or replace public synonym tagsys_fctry_intfc for pt_app.tagsys_fctry_intfc;