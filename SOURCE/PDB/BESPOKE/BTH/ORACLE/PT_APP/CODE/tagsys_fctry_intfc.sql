create or replace package pt_app.tagsys_fctry_intfc as

  /******************************************************?
  /* this package contains 4 fprocedures 
  /*\
  /*  This package is used for PETCARE - Bathurst and Wodonga only 
  /*
  /* Creat_Pllt - will perform a Goods receipt of either a pallet or process 
  /* Cancel_Pllt - will reverse a process qty 
  /* Cancel_HU_Pllt - will reverse a pallet from atlas ie cancel 
  /******************************************************/
   
   
  /******************************************************/
  /* NOTE: This Package is not the same as the one used in Wanganui or Food 
  /* it has been modified to handle the new HANDLING UNITS (pallet codes)
  /* and the package now uses the REMOTE_LOADER for transfer of data
  /* from Oracle to a file location on the Plant Database Server.
  /* this is then transferred via MQ Series Light to the LADS server 
  /* where is is sent again via MQ Series to Atlas via the HUB 
   
  /* Developer 	 Jeff Phillipson 
  /* Date			 13 Jan 2006 
  /* 11-Jun-2009      Trevor Keon   Added logging on exceptions and using
  /*                                the new pt_cisatl17_gr package to send   
  /* 17-Jun-2009      Trevor Keon   Added create_scrap_rework procedure     
  /******************************************************/
   
  /******************************************************/
  /* Create_Pllt will record data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_pllt(o_result          in out number,
                        o_result_msg      in out varchar2,
                        i_xactn_date		 in date,
                        i_plant_code		 in varchar2,
                        i_sender_name	 in varchar2,
                        i_zpppi_batch	 in varchar2,
                        i_proc_order		 in number,
                        i_dispn_code		 in varchar2,
                        i_use_by_date	 in date,
                        i_material_code	 in varchar2,
                        i_plt_code		 in varchar2,
                        i_qty			 in number,
                        i_full_plt_flag	 in varchar2,
                        i_user_id		 in varchar2,
                        i_last_gr_flag	 in varchar2,
                        i_plt_type			   in varchar2,
                        i_start_prodn_date 	   in date,
                        i_end_prodn_date  	   in date);
     
  /******************************************************/
  /* Cancel_Pllt will cancel process only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_pllt(o_result          in out number,
                        o_result_msg      in out varchar2,
                        i_xactn_date		  in date,
                        i_sender_name		in varchar2,
                        i_plt_code			in varchar2,
                        i_user_id			in varchar2);  
     
  /******************************************************/
  /* Cancel_HU_Pllt will cancel pallets only data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure cancel_hu_pllt(o_result          in out number,
                           o_result_msg      in out varchar2,
                           i_xactn_date		in date,
                           i_sender_name		in varchar2,
                           i_plt_code			in varchar2,
                           i_user_id			in varchar2);    	
  	
  /******************************************************/
  /* Create_Consumption will record data in PT schema and send on to Atlas 
  /* this will record consumption of any material used within a 
  /* valid process order 
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_consumption(o_result          in out number,
                               o_result_msg      in out varchar2,
                               i_trans_id			in number, --  uniquie id 
                               i_xactn_date				in date,
                               i_plant_code		in varchar2,
                               i_proc_order		in varchar2,
                               i_material_code	in varchar2,
                               i_qty					in number);  	
   
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
                               i_qty			 in number);  	
                               
/******************************************************************************
   OUTPUT:    result            number 0: success, 1: oracle error, 2: process error
              result_msg        string 2000chars message if above is 1 or 2
   INPUT:     process order     string
              material          string
              qty               number
              batch_code        string
              plant_code        string
              event datime      date
              scrap_rework      string      R = rework; S = scrap    
              reason code       string      4 char as per RESASON_CODES_VW
              rework code       string      reworked material
              rework batch      string      reworked batch code
              rework expiration date date
              rework storage location string 4 chars
******************************************************************************/
  procedure create_scrap_rework(o_result out number,
                                o_result_msg out varchar2,
                                i_proc_order in varchar2,
                                i_plt_code in varchar2 default 0,
                                i_matl_code in varchar2,
                                i_qty in number,
                                i_batch_code in varchar2,
                                i_plant_code in varchar2,
                                i_event_datime in date,
                                i_scrap_rework in varchar2,
                                i_reason_code in varchar2,
                                i_rework_code in varchar2,
                                i_rework_batch in varchar2,
                                i_rework_exp_date in date,
                                i_rework_storage_locn in varchar2,
                                i_bin_code in varchar2,
                                i_area_in_code in varchar2,
                                i_area_out_code in varchar2,
                                i_status_code in varchar2); 

 /******************************************************************************
 INPUT:       pallet code       sscc code     string
              status            string        values - not known yet
 ******************************************************************************/
  procedure update_status(o_result out number,
                          o_result_msg out varchar2,
                          i_plt_code in varchar2,
                          i_status in varchar2);     
                                                    
end;
/

create or replace package body pt_app.tagsys_fctry_intfc as
	
  procedure log_exception(i_header in varchar2, i_search in varchar2, i_msg in varchar2, i_process_order in number default 0);

  /******************************************************?
  /* this package contains 4 procedures 
  /*\
  /*  This package is used for PETCARE - Bathurst and Wodonga only 
  /*
  /* Creat_Pllt - will perform a Goods receipt of either a pallet or process 
  /* Cancel_Pllt - will reverse a process qty 
  /* Cancel_HU_Pllt - will reverse a pallet from atlas ie cancel 
  /******************************************************/
   
  /******************************************************/
  /* NOTE: This Package is not the same as the one used in Wanganui or Food 
  /* it has been modified to handle the new HANDLING UNITS (pallet codes)
  /* and the package now uses the REMOTE_LOADER for transfer of data
  /* from Oracle to a file location on the Plant Database Server.
  /* this is then transferred via MQ Series Light to the LADS server 
  /* where is is sent again via MQ Series to Atlas via the HUB 
   
  /* Developer 	 Jeff Phillipson 
  /* Date			 13 Jan 2006 
   
  /******************************************************/
     
  b_test_flag				       boolean := false; 
  reclaim_proc_order       constant varchar2(12) := '1';
   
  /******************************************************/
  /* Create_Pllt will record data in PT schema and send on to Atlas
  /* o_result - 0 for successfull
  /*      		- 1 for a failure 
  /* o_result_msg - if o_result is 1 then this will contain the error message 
  /******************************************************/
  procedure create_pllt(o_result                 in out number,
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
    		
    cursor csr_matl is
      select issue_strg_locn, 
        decode(base_uom,'KGM','KG', base_uom) uom 
      from matl
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;  		
  		
  begin

    o_result := plt_common.success;
    o_result_msg := 'Pallet ' || i_plt_code || ' created';
    	
    /*-*/
    /* set prodn times to 6 char strings 
    /*-*/
    v_start_prodn_date := i_start_prodn_date;
    v_end_prodn_date := i_end_prodn_date;
	
    /**********************************************************************************/
    /* Validate data before saving in table 
    /**********************************************************************************/
    	
    /*-*/
    /*  check if pallet code exists in the pallet tables
    /*-*/
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = to_char(i_plt_code);
    
    if v_count > 0 then
      o_result_msg := 'Transaction Failed: Pallet code already exists. Please select a unique value.';
      o_result := plt_common.failure;
      raise e_process_exception; 
    end if;
       
    /*-*/
    /*  check validity of date - transaction date cannot be null
    /*-*/
    if i_xactn_date is null then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    /*-*/
    /* check plant code is valid and not null
    /*-*/
    if i_plant_code is null then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from manu.ref_plant 
      where plant = i_plant_code;
      
      if v_count = 0 then
        o_result_msg := 'Plant Code is not correct.';
        o_result := plt_common.failure;
        raise e_process_exception;
      end if;
    end if;
       
    /*-*/
    /* check for valid proc order
    /*-*/
    if i_proc_order is null then
      o_result_msg := 'Proc Order is not valid.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      if substr(i_proc_order,1,2) <> '99' then
        select count(*) 
        into v_count 
        from manu.cntl_rec 
        where ltrim(proc_order,'0') = ltrim(to_char(i_proc_order),'0');
        
        if v_count = 0 then
          o_result_msg := 'Proc Order is not valid.';
          o_result := plt_common.failure;
          raise e_process_exception;
        end if;
      end if;
    end if;
       
    /*-*/
    /* check for a valid material code 
    /*-*/
    if i_material_code is null then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      select count(*) 
      into v_count 
      from matl 
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
      o_result :=plt_common.failure;
      raise e_process_exception;
    end if;
       
    /*-*/
    /* check validity of best before date
    /*-*/
    if length(i_plt_code) > 12 then
      if i_use_by_date is null then
        o_result_msg := 'Best before date cannot be Null.';
        o_result :=plt_common.failure;
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
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      if i_dispn_code <> ' ' and i_dispn_code <> 'S' and i_dispn_code <> 'X' then
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
    
    if i_zpppi_batch is null then
      v_batch := ' ';
    else
      -- fg 
      v_batch := substr(i_zpppi_batch,1,30);
    end if;    
   
    if i_proc_order = reclaim_proc_order then
      select plt_tolas_seq.nextval 
      into v_seq 
      from dual;
      
      /*-*/
      /* just send tolas ltds file
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
      
    else  
  
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
          trans_type,
          upper(i_user_id),
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
          o_result := plt_common.failure;
          raise e_process_exception;
      end;

      /*-*/
      /* only send if the pallet code is areal Atlas code
      /* anything begining with 99 is a dummy - local code
      /* This will still allow FG Pallet Codes and Process to be sent
      /* Process will use an auto generated id for plt codes this will be less than 
      /* 10 digits long
      /*-*/
      if substr(i_proc_order,1,2) <> '99' then    			 	
        v_transaction_type := 'Z_PI1';          				
        if (i_last_gr_flag = 'Y') then
          b_last_gr_flag := true;
        end if;
      				
        /*-*/
        /* if the hold flag is not set then send the files to atlas and tolas
        /*-*/
        if not idoc_hold then
        				
        /**********************************************************************************/
        /* Create idoc package for create
        /**********************************************************************************/  
        	
          begin
        				
            /*-*/
            /* make call to create idoc 
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
              o_result := plt_common.failure;
              rollback;
              raise e_process_exception;
          end;
          				
          			
          begin
          				
            if v_result = 0 then
              update pt.plt_det
              set sent_flag = 'Y'
              where plt_code = upper(i_plt_code);  
            else
              /*-*/
              /*  error has occured 
              /*  insert record in log file 
              /* and a retry will be made latter
              /*-*/
              o_result_msg := v_result_msg;
              o_result := v_result;
                               
              insert into plt_idoc_log
              values 
              (
                i_plt_code, 
                trans_type, 
                0, 
                'FAIL', 
                o_result_msg, 
                sysdate, 
                1
              );                 
            end if;
          					
          exception
            when others then
              o_result_msg := 'Insert SEND flag (create) Failed ['|| sqlcode || ' ' || substr(sqlerrm,1,255) ||']';
              o_result := plt_common.failure;
              raise e_process_exception;
          end;
        				    
        end if; -- on not on hold section complete 
  			
        /*-*/
        /* only send tolas files if the pallet code is for a finished good
        /*-*/
        if length(i_plt_code) > 10 and length(ltrim(i_material_code,'0')) = 8 then
        				
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
            /* only for plant codes cannery and bathurst 
            /*-*/
            if i_plant_code = 'AU20'  or  i_plant_code = 'AU30' then
              /*-*/
              /* send the fds file to tolas
              /* this file is based on plant and will be assigned to a different queue for the 2 plant codes
              /* defined in the if statement
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
                to_number(to_char(i_xactn_date,'HH24MISS')),
                i_material_code,
                i_qty,
                v_work1,
                v_work,
                i_dispn_code,
                v_batch,
                to_char(i_use_by_date,'YYYYMMDD'),
                i_plt_code,
                i_plt_type,
                'CHEP',
                trunc(i_start_prodn_date),
                to_number(to_char(i_start_prodn_date,'HH24MISS')),
                trunc(i_end_prodn_date),
                to_number(to_char(i_end_prodn_date,'HH24MISS')),
                to_char(lpad(v_seq,8,'0'))
              );
            end if;
            											 
            					
            /*-*/
            /* the ldts file is sent to the same queue for all plants
            /* for petcare
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
              to_char(i_use_by_date,'YYYYMMDD'),
              i_plt_code,
              to_char(lpad(v_seq,8,'0'))
            );
            
            commit;
          					
          exception
            when others then
              o_result_msg := 'Call to Tolas_Send (create) Failed ['|| sqlcode || ' ' || substr(sqlerrm,1,255) ||']';
              o_result := plt_common.failure;
              rollback;
              raise   e_process_exception;
          end;
        end if;  -- end of send if pallet code is a real code 
  								
      else
        update pt.plt_det
        set sent_flag = 'X'
        where plt_code = upper(i_plt_code);   
      end if;  -- end of temp pallet or fg/process pallet                        
      
		end if; 
      		
  exception
    when e_process_exception then
      o_result := plt_common.failure;
      log_exception('Create Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, i_proc_order);
      rollback;
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
      log_exception('Create Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, i_proc_order);
    when others then
      o_result := plt_common.failure;
      rollback;
      o_result_msg := 'ERROR OCCURED'||sqlcode || '-' || substr(sqlerrm,1,255);
      log_exception('Create Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, i_proc_order);
  end;

  /**********************************************************************************/
  /* Cancel Pallet record - special for Handling Units 
  /* - the pallet record has to exist and it should be CREATE status
  /**********************************************************************************/     
  procedure cancel_pllt(o_result      in out number,
                        o_result_msg   in out varchar2,
                        i_xactn_date	in date,
                        i_sender_name	in varchar2,
                        i_plt_code		in varchar2,
                        i_user_id		in varchar2) as
    /*-*/
    /* Variables 
    /*-*/
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
   /* VALIDATE data BEFORE saving IN TABLE
   /**********************************************************************************/
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    	  
    if v_count <> 1 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
      
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CANCEL';
    		
    if v_count > 0 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check validity of dates
    if i_xactn_date is null then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check sender name
    if i_sender_name is null then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
              
    v_transaction_type := 'Z_PI2'; -- set atlas type code 
   
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
          o_result := plt_common.failure;
          o_result_msg := 'UPDATE (CANCEL) INTO pt.plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
      end;

      /**********************************************************************************/
      /* Create Idoc package for Cancel 
      /**********************************************************************************/
      if not idoc_hold then
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
              -- insert record in log file
              o_result_msg := v_result_msg;
              o_result := v_result;
              
              insert into plt_idoc_log
              values 
              (
                i_plt_code, 
                trans_type, 
                0, 
                'FAIL',
                o_result_msg, 
                sysdate, 
                o_result
              );
              
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
          update pt.plt_det
          set sent_flag = 'X'
          where plt_code = upper(i_plt_code);
        else
          if not idoc_hold then
            update pt.plt_det
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
      log_exception('Cancel Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
      log_exception('Cancel Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when others then
      o_result := plt_common.failure;
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
    /*-*/
    /* Variables 
    /*-*/  	  
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

    o_result := plt_common.success;
    o_result_msg := 'Pallet ' || i_plt_code || ' cancelled';   
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE
   /**********************************************************************************/
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CREATE';
    	  
    if v_count <> 1 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CREATE'' has to exist.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
      
    select count(*) 
    into v_count
    from plt_hdr
    where plt_code = i_plt_code
      and status = 'CANCEL';
    		
    if v_count > 0 then
      o_result_msg := 'Transaction Failed: A Pallet record with status ''CANCEL'' already exists.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check validity of dates
    if i_xactn_date is null then
      o_result_msg := 'Transaction Date cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    end if;
       
    -- check sender name
    if i_sender_name is null then
      o_result_msg := 'Sender Name cannot be Null for a Cancel Pallet.';
      o_result := plt_common.failure;
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
          o_result := plt_common.failure;
          o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> UPDATE INTO pt.plt_hdr and plt_det FAILED, RETURN [' || substr(sqlerrm,1,255) || ']';
      end;

      /**********************************************************************************/
      /* Create idoc package for cancel 
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
        /* only send cancel to atlas and tolas if the pallet code is a valid value
        /*-*/
        if substr(v_proc_order,1,2) <> '99'  then	
          if r_plt.last_gr_flag = 'Y' then
            b_last_gr_flag := true;
          else
            b_last_gr_flag := false;
          end if;

          if not idoc_hold then
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
              -- insert record in log file
              o_result_msg := v_result_msg;
              o_result := v_result;
              
              insert into plt_idoc_log
              values 
              (
                i_plt_code, 
                trans_type, 
                0, 
                'FAIL', 
                substr(o_result_msg,0,500), 
                sysdate, 
                o_result
                );
                
              o_result_msg := '';
              o_result := plt_common.success;
              raise e_idoc_exception;
            end if;                    
          end if; 
        end if;
         
      exception
        when others then
          o_result_msg := '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error: Call to Goods_Recipte_Send Failed ['||substr(sqlerrm,0,255)||']';
          o_result := plt_common.failure;
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
          if not idoc_hold then
            update pt.plt_det
            set sent_flag = 'Y'
            where plt_code = upper(i_plt_code);
          end if;
        end if;

      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error updating sent flag on pts_intfc: ['||sqlerrm||']';
          o_result := plt_common.failure;
          raise e_process_exception;
      end;
		/*-*/
		/* Cancel sent to atlas
		/*-*/

      /*-*/
      /* now send tolas files if required
      /*-*/
      begin
        /*-*/
        /* only for plant codes cannery and bathurst 
        /*-*/
        if r_plt.plant_code = 'AU20' or r_plt.plant_code = 'AU30' then
          			
          /*-*/
          /* get a sequence number for the tolas interface
          /*-*/
          begin
            select plt_tolas_seq.nextval 
            into v_seq from dual;
            insert into plt_tolas
            values (i_plt_code, v_seq);
          end;          					
          					
          /*-*/
          /* send the fds file to tolas
          /* this file is based on plant and will be assigned to a different queue for the 2 plant codes
          /* defined in the if statement
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
            to_number(to_char(i_xactn_date,'HH24MISS')),
            r_plt.matl_code,
            r_plt.qty,
            r_plt.uom,
            r_plt.stor_locn_code,
            r_plt.dispn_code,
            r_plt.zpppi_batch,
            to_char(r_plt.use_by_date,'YYYYMMDD'),
            i_plt_code,
            r_plt.plt_type,
            'CHEP',
            trunc(sysdate), -- dummy entry 
            0, 			    -- dummy entry 
            trunc(sysdate), -- dummy entry 
            0, 			    -- dummy entry 
            to_char(lpad(v_seq,8,'0'))
          );
          
        end if;		
        		
      exception
        when others then
          o_result_msg :=  '<TAGSYS_FCTRY_INTFC.Cancel_HU_Pllt> Error sending Tolas files: ['||substr(sqlerrm,0,255)||']';
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
      log_exception('Cancel HU Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
      log_exception('Cancel HU Pallet Exception', 'Pallet Code: ' || i_plt_code, o_result_msg, v_proc_order);
    when others then
      o_result := plt_common.failure;
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
    /*-*/
    /* Variables 
    /*-*/    		
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
      from matl
      where ltrim(matl_code,'0') = i_material_code
        and plant = i_plant_code;
		
  begin
  	
    o_result := plt_common.success;
    o_result_msg := '';
   
   /**********************************************************************************/
   /* VALIDATE data BEFORE saving IN TABLE 
   /**********************************************************************************/

    -- check plant code 
    if i_plant_code is null then
      o_result_msg := 'Plant Code cannot be Null.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      select count(*) into v_count 
      from manu.ref_plant 
      where plant = i_plant_code;
      
      if v_count = 0 then
        o_result_msg := 'Plant Code is not correct.';
        o_result := plt_common.failure;
        raise e_process_exception;
      end if;
    end if;
       
    -- check for valid proc order
    if i_proc_order is null then
      o_result_msg := 'Proc Order is not valid.';
      o_result := plt_common.failure;
      raise e_process_exception;
    else
      if substr(i_proc_order,1,2) <> '99' then
        select count(*) 
        into v_count 
        from manu.cntl_rec 
        where ltrim(proc_order,'0') = ltrim(i_proc_order,'0');
      
        if v_count = 0 then
          o_result_msg := 'Proc Order is not valid.';
          o_result := plt_common.failure;
          raise e_process_exception;
        end if;
      end if;
    end if;
       
    -- check material code 
    -- material may be a substitution so may not be in the process order bom
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
        'CREATE'
      );
      
      commit;
      	 
    exception
      when others then
        o_result := plt_common.failure;
        rollback;
        o_result_msg := 'ERROR OCCURED' || substr(sqlerrm(sqlcode),0,256);
        raise e_process_exception;
    end ;
       
  exception
    when e_process_exception then
      o_result := plt_common.failure;
      log_exception('Create Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
      log_exception('Create Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);
    when others then
      o_result := plt_common.failure;
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
    /*-*/
    /* Variables 
    /*-*/    	 
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
      select issue_strg_locn, 
        decode(base_uom,'KGM','KG', base_uom) as uom 
      from matl
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
      	 
    exception
      when others then
        o_result := plt_common.failure;
        rollback;
        o_result_msg := 'ERROR OCCURED' || substr(sqlerrm(sqlcode),0,255);
        raise e_process_exception;
    end;
  		 
  		  
  exception
    when e_process_exception then
      o_result := plt_common.failure;
      log_exception('Cancel Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);   
    when e_idoc_exception then
      commit;
      o_result := plt_common.success;
      log_exception('Cancel Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);   
    when others then
      o_result := plt_common.failure;
      rollback;
      o_result_msg := 'ERROR OCCURED' || sqlerrm(sqlcode);
      log_exception('Cancel Consumption Exception', 'Process Order: ' || i_proc_order, o_result_msg);   
  end;
  
  procedure create_scrap_rework(o_result out number,
                                o_result_msg out varchar2,
                                i_proc_order in varchar2,
                                i_plt_code in varchar2 default 0,
                                i_matl_code in varchar2,
                                i_qty in number,
                                i_batch_code in varchar2,
                                i_plant_code in varchar2,
                                i_event_datime in date,
                                i_scrap_rework in varchar2,
                                i_reason_code in varchar2,
                                i_rework_code in varchar2,
                                i_rework_batch in varchar2,
                                i_rework_exp_date in date,
                                i_rework_storage_locn in varchar2,
                                i_bin_code in varchar2,
                                i_area_in_code in varchar2,
                                i_area_out_code in varchar2,
                                i_status_code in varchar2) is 
                                 
    e_process_exception      exception;
    e_oracle_exception       exception;
         
    var_count                  number;
    var_count01                number;
    var_rework_sloc            varchar2(4);
    var_rework_expiry          date;
          
    rcd_scrap_rework scrap_rework%rowtype;
          
    /*-*/
    /* cursor definitions
    /*-*/
    cursor csr_proc_order is
      select t01.plant_code, 
        t01.uom,
        ltrim(t01.material,'0') material,
        t01.storage_locn
      from bds_recipe_header t01
      where ltrim(t01.proc_order,'0') = i_proc_order
        and ltrim(t01.material,'0') = i_matl_code
      union all
      select t01.plant_code, 
        t02.material_uom uom, 
        ltrim(t02.material_code,'0') as material,
        t03.issue_storage_location
      from bds_recipe_header t01,
        bds_recipe_bom t02,
        bds_material_plant_mfanz t03
      where t01.proc_order = t02.proc_order
        and t02.material_code = t03.sap_material_code(+)
        and t02.plant_code = t03.plant_code(+)
        and ltrim(t01.proc_order,'0') = i_proc_order
        and ltrim(t02.material_code,'0') = i_matl_code;
    rcd_proc_order csr_proc_order%rowtype;
         
    cursor csr_reason_code is
      select cost_centre
      from reason_codes
      where reason_code = i_reason_code;
    rcd_reason_code csr_reason_code%rowtype;
        
  begin
    o_result := constants.success;
    o_result_msg := '';
        
    /*-*/
    /* validate data 
    /*-*/
    /* check for valid proc order */
    if i_proc_order is not null then
      select count(*) 
      into var_count
      from cntl_rec 
      where ltrim(proc_order,'0') = ltrim(i_proc_order,'0');
      
      if var_count = 0 then
        o_result_msg := 'Process order is not valid: ' || i_proc_order;
        o_result := constants.error;
        raise e_process_exception;
      end if;
    end if;
    /* check validity of qty */ 
    if i_qty = 0 or i_qty is null then
      o_result_msg := 'Quantity cannot be Null or zero.';
      o_result := constants.error;
      raise e_process_exception;
    end if;
    /* check material code */
    /*  material can be a substitution so it doesnt have to be in the process order bom */
    if i_matl_code is null then
      o_result_msg := 'Material Code cannot be Null.';
      o_result := constants.error;
      raise e_process_exception;
    else
      /*-*/
      /* check the matl is in the po or the header of the po
      /*-*/
      select sum(count) 
      into var_count
      from 
      (
        select count(*) as count 
        from bds_recipe_header 
        where ltrim(proc_order,'0') = i_proc_order
          and ltrim(material,'0') = i_matl_code
        union all
        select count(*) as count  
        from bds_recipe_bom
        where ltrim(proc_order,'0') = i_proc_order
          and ltrim(material_code,'0') = i_matl_code
      );
      
      if var_count = 0 then
        o_result_msg := 'Material Code is not part of the Processder.' || i_matl_code;
        o_result := constants.error;
      end if;
    end if;
    
    /* check reason code is valid */
    select count(*) 
    into var_count 
    from reason_codes 
    where reason_code = i_reason_code;
    
    if var_count = 0 then
      o_result_msg := 'Reason Code is incorrect: ' || i_reason_code;
      o_result := constants.error;
      raise e_process_exception;
    end if;
    
    /* batch code needed if material is fert */
    select count(*) 
    into var_count 
    from bds_material_plant_mfanz 
    where material_type = 'FERT'
      and ltrim(sap_material_code,'0') = ltrim(i_matl_code,'0');
      
    if var_count > 0 then -- finished good
      /*-*/
      /* check batch code
      /*-*/
      if i_batch_code is null or i_batch_code = '' then
        o_result_msg := 'Batch code required for a Finished Good: ' || i_matl_code;
        o_result := constants.error;
        raise e_process_exception;
      else
        select count(*) 
        into var_count01
        from batch_date
        where calendar_date = trunc(sysdate)
          and atlas_batch = substr(i_batch_code,1,4);
          
        if var_count01 = 0 then
          o_result_msg := 'Batch code not valid: ' || i_batch_code;
          o_result := constants.error;
          raise e_process_exception;
        end if;
      end if;
      
      /*-*/
      /* check rework batch code
      /*-*/
      if i_scrap_rework = 'R' then
        if i_rework_batch is null or i_rework_batch = '' then
          o_result_msg := 'Rework Batch code required for a Finished Good: ' || i_matl_code ;
          o_result := constants.error;
          raise e_process_exception;
        end if;
      end if;
    end if;
        
    /*-*/
    /* check uom's are equal
    /*-*/
    if i_scrap_rework = 'R' then
      select count (*) 
      into var_count
      from 
      (
        select distinct base_uom  
        from bds_material_plant_mfanz
        where (ltrim(sap_material_code,'0') = ltrim(i_rework_code,'0') or ltrim(sap_material_code,'0') = ltrim(i_matl_code,'0'))
          and plant_code = i_plant_code
      );
      
      if var_count =2 then
        o_result_msg := 'Rework code and Material code have to have the same UOM. Rework code= ' || i_rework_code  || ' Material code= ' || i_matl_code ;
        o_result := constants.error;
        raise e_process_exception;
      end if;
    end if;
        
    /*-*/
    /* validation complete
    /*-*/        
        
    /*-*/
    /* get extra proc order data required for saving to table
    /*-*/
    if i_proc_order is not null then
      open csr_proc_order;
      fetch csr_proc_order into rcd_proc_order;
      if csr_proc_order%notfound then
        o_result_msg := 'Material code is not valid.';
        o_result := constants.error;
        raise e_process_exception;
      else
        rcd_scrap_rework.uom := rcd_proc_order.uom;
        rcd_scrap_rework.storage_locn := rcd_proc_order.storage_locn;
      end if;
      close csr_proc_order;
    else
      /* get data from material table */
      begin
        select decode(base_uom,'KGM','KG',base_uom), 
          decode(issue_storage_location,null,'0020',issue_storage_location) 
        into rcd_scrap_rework.uom, 
          rcd_scrap_rework.storage_locn
        from bds_material_plant_mfanz
        where ltrim(sap_material_code,'0') = ltrim(i_matl_code,'0')
          and plant_code = i_plant_code;
      exception
        when no_data_found then
          rcd_scrap_rework.uom := 'ERR';
          rcd_scrap_rework.storage_locn := '0020';
        when others then
          o_result_msg := 'Material/plant code is not valid.';
          o_result := constants.error;
          raise e_process_exception;
      end;
    end if;
    
    /*-*/
    /* get cost centre data
    /*-*/
    open csr_reason_code;
    fetch csr_reason_code into rcd_reason_code;
    if csr_reason_code%notfound then
      o_result_msg := 'Storage Location and or UOM not found in GDR material table.';
      o_result := constants.error;
      raise e_process_exception;
    end if;
    close csr_reason_code;
        
    /*-*/
    /* get rework expiry date and sloc
    /*-*/
    if i_rework_code is not null then
      begin
        select issue_storage_location,
          trunc(sysdate) + to_number(max_storage_prd)  
        into var_rework_sloc, 
          var_rework_expiry
        from bds_material_plant_mfanz
        where ltrim(sap_material_code,'0') = i_rework_code
          and plant_code = i_plant_code;
      exception
        when no_data_found then
          var_rework_sloc := '0020';
          var_rework_expiry := trunc(sysdate);
      end;
    end if;
       
    /*-*/
    /* save data to table 
    /*-*/
    begin
            
      select scrap_rework_id_seq.nextval 
      into rcd_scrap_rework.scrap_rework_id
      from dual;
      
      rcd_scrap_rework.proc_order := i_proc_order;
      rcd_scrap_rework.matl_code := i_matl_code;
      rcd_scrap_rework.qty := i_qty;
      
      if rcd_scrap_rework.storage_locn is null or rcd_scrap_rework.storage_locn = ''  then
        rcd_scrap_rework.storage_locn := '0020';
      end if;
      if rcd_scrap_rework.uom is null or rcd_scrap_rework.uom = '' then
        rcd_scrap_rework.uom := 'KG';
      end if;
      
      rcd_scrap_rework.plant_code := trim(i_plant_code);
      rcd_scrap_rework.event_datime := i_event_datime;
      rcd_scrap_rework.scrap_rework_code := i_scrap_rework;
      rcd_scrap_rework.reason_code := i_reason_code;
      rcd_scrap_rework.sent_flag := '';
      rcd_scrap_rework.rework_code := i_rework_code;
      rcd_scrap_rework.rework_batch_code := i_rework_batch;                                                                                                                                                                                                                                                                                                                                                                                                                         
      rcd_scrap_rework.rework_exp_date := var_rework_expiry;
      rcd_scrap_rework.rework_sloc := var_rework_sloc; 
      rcd_scrap_rework.cost_centre := rcd_reason_code.cost_centre;
      rcd_scrap_rework.bin_code := i_bin_code;
      rcd_scrap_rework.plt_code := i_plt_code;
      rcd_scrap_rework.area_in_code := i_area_in_code;
      rcd_scrap_rework.area_out_code := i_area_out_code;
      rcd_scrap_rework.status_code := i_status_code;
      rcd_scrap_rework.batch_code := trim(i_batch_code);
            
      insert into scrap_rework
      (
        scrap_rework_id,
        proc_order,
        matl_code,
        qty,
        uom,
        storage_locn,
        plant_code,
        event_datime,
        scrap_rework_code,
        reason_code,
        sent_flag,
        rework_code,
        rework_batch_code,
        rework_exp_date,
        rework_sloc,
        cost_centre,
        bin_code,
        plt_code,
        area_in_code,
        area_out_code,
        status_code,
        batch_code
      )
      values 
      (
        rcd_scrap_rework.scrap_rework_id,
        rcd_scrap_rework.proc_order,
        rcd_scrap_rework.matl_code,
        rcd_scrap_rework.qty,
        rcd_scrap_rework.uom,
        rcd_scrap_rework.storage_locn,
        rcd_scrap_rework.plant_code,
        rcd_scrap_rework.event_datime,
        rcd_scrap_rework.scrap_rework_code,
        rcd_scrap_rework.reason_code,
        rcd_scrap_rework.sent_flag,
        nvl(rcd_scrap_rework.rework_code,''),
        nvl(rcd_scrap_rework.rework_batch_code,''),
        nvl(rcd_scrap_rework.rework_exp_date,''),
        nvl(rcd_scrap_rework.rework_sloc,''),
        rcd_scrap_rework.cost_centre,
        nvl(rcd_scrap_rework.bin_code,''),
        nvl(rcd_scrap_rework.plt_code,''),
        nvl(rcd_scrap_rework.area_in_code,''),
        nvl(rcd_scrap_rework.area_out_code,''),
        nvl(rcd_scrap_rework.status_code,''),
        nvl(rcd_scrap_rework.batch_code,'')
      ); 
    commit;
       
    exception
      when others then
        rollback;
        o_result_msg := 'ERROR OCCURED saving data to SCRAP_REWORK table. '||substr(sqlerrm(sqlcode),0,1900);
        raise e_oracle_exception;
    end;
     
  exception
    when e_process_exception then
      o_result := plt_common.failure;
      rollback;
      log_exception('Create Scrap Rework Exception', 'Process Order: ' || i_proc_order, o_result_msg);   
    when e_oracle_exception then
      rollback;
      o_result := plt_common.failure;
      log_exception('Create Scrap Rework Exception', 'Process Order: ' || i_proc_order, o_result_msg);   
    when others then
      o_result := plt_common.failure;
      rollback;
      o_result_msg := 'ERROR OCCURED in CREATE_REWORK_SCRAP: ' || chr(13) || sqlcode || '-' || substr(sqlerrm,1,1900);
      log_exception('Create Scrap Rework Exception', 'Process Order: ' || i_proc_order, o_result_msg);   
                        
  end create_scrap_rework;

  procedure update_status(o_result out number,
                          o_result_msg out varchar2,
                          i_plt_code in varchar2,
                          i_status in varchar2) is
                          
    e_process_exception      exception;
    var_count                number;
        
  begin
    o_result := constants.success;
    o_result_msg := '';
          
    select count(*) 
    into var_count
    from scrap_rework
    where plt_code = i_plt_code;
    
    if var_count = 1 then
      update scrap_rework
      set status_code = i_status
      where plt_code = i_plt_code;
    else
      o_result_msg := 'SSCC code does not exist.';
      o_result := constants.error;
      raise e_process_exception;
    end if;
    commit;
      
  exception
    when e_process_exception then
      o_result := plt_common.failure;
      rollback;
      log_exception('Update Status', 'Pallet Code: ' || i_plt_code, o_result_msg);
    when others then
      o_result := plt_common.failure;
      rollback;
      o_result_msg := 'ERROR OCCURED in UPDATE_STATUS: ' || chr(13) || sqlcode || '-' || substr(sqlerrm,1,1900);
      log_exception('Update Status', 'Pallet Code: ' || i_plt_code, o_result_msg); 
  end update_status;  
   
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

grant execute on pt_app.tagsys_fctry_intfc to appsupport;
grant execute on pt_app.tagsys_fctry_intfc to bthsupport;
grant execute on pt_app.tagsys_fctry_intfc to pt_maint;
grant execute on pt_app.tagsys_fctry_intfc to pt_user;

create or replace public synonym tagsys_fctry_intfc for pt_app.tagsys_fctry_intfc;