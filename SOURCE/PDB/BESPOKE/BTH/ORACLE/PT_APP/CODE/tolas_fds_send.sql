create or replace procedure pt_app.tolas_fds_send(o_result          in out number,
                                                  o_result_msg      in out varchar2,
                                                  i_message_type		in varchar2,	-- z_pi1 create or z_pi2 reverse , z_pi6 hu reversal 
                                                  i_plant_code		in varchar2,
                                                  i_sender_name		in varchar2,
                                                  i_test_flag			in boolean,		-- if true, then create test atlas message
                                                  i_proc_order		in number,
                                                  i_xactn_date		in date,
                                                  i_xactn_time		in number,
                                                  i_material_code	in varchar2,
                                                  i_qty					in number,	   	-- material produced
                                                  i_uom					in varchar2,
                                                  i_stor_loc_code	in number,
                                                  i_dispn_code		in varchar2,	-- stock type
                                                  i_zpppi_batch		in varchar2,	-- atlas batch code
                                                  i_bb_date			in varchar2,	-- best before date 
                                                  i_plt_code			in varchar2,
                                                  i_plt_type			in varchar2,
                                                  i_pkg_matl 			in varchar2,
                                                  i_start_prodn_date in date,
                                                  i_start_prodn_time in number,
                                                  i_end_prodn_date	in date,
                                                  i_end_prodn_time	in number,
                                                  i_seq				in varchar2) as
                                                  
  /******************************************************************************
     NAME:       TOLAS_FDS_SEND
     PURPOSE:    Transfer data through ICS to Tolas

     REVISIONS:
     Ver        Date        Author                    Description
     ---------  ----------  ---------------------  ------------------------------------
     1.0        ??/??/????  Unknown                 1. Created this package.
     1.1        11/06/2009  Trevor G. Keon          2. Configured to send via ICS
  ******************************************************************************/                                                  
	
  /*-*/
  /* variables
  /*-*/
  var_intfc_rtn		number(15,0);
  var_test_flag		varchar2(1)  := '';
  var_dispn			  varchar2(2);
  	
  exc_process_exception	exception;	
  
  /*-*/
  /* Variables for ICS interface creation
  /*-*/    
  var_site              varchar2(4);
  var_db_value          varchar2(4);
  var_interface         varchar2(100);
  var_interface_id      number;

  var_vir_table lics_datastore_table := lics_datastore_table();  
  	
  /*-*/
  /* This value defines the interface to send
  /*-*/
  cst_file_interface  constant varchar2(20) := 'PDBTOL01';
  	
begin

  o_result := 0;
  o_result_msg := 'OK';
  
  /*-*/
  /* Get site specific settings
  /*-*/     
  var_site := lics_app.lics_setting_configuration.retrieve_setting('pdb','site_code');
  var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'GR');
  var_db_value := var_vir_table(1).dsv_value;
  
  var_interface := cst_file_interface || '.' || var_db_value;
        
  if (i_test_flag = true) then
    var_test_flag := 'X';
  else
    var_test_flag := ' ';
  end if;
    	 
  if i_dispn_code = ' ' then
    -- unrestrited 
    var_dispn := 'GD';
  end if;
  
  if i_dispn_code = 'S' then
    -- blocked 
    var_dispn := 'HD';
  end if;
  
  if i_dispn_code = 'X' then
    -- qi - dont know the choice for this yet 
    var_dispn := 'HD';
  end if;
			
  /*-*/
  /* Create local interface to send Tolas data
  /*-*/ 
  var_interface_id := lics_outbound_loader.create_interface(var_interface);  			

  /*-*/
  /* HEADER: Header Record 
  /* Including 'X' at the end of the header record will cause Atlas
  /* to treat the message as a test, meaning no further processing
  /* will be completed once it reaches Atlas.
  /*-*/			
  lics_outbound_loader.append_data('HDR'
    ||'000000000000000001'
    ||rpad(trim(i_plant_code),4,' ')
    ||rpad(i_message_type,8,' ')
    ||rpad(trim(i_sender_name),32,' ')
    ||rpad(var_test_flag,1,' ')
    ||rpad('R',1,' ')  -- could be r and h 
    ||rpad(var_dispn,4,' '));

  														 
  --det: process order
  lics_outbound_loader.append_data('DET'
    ||'000000000000000001'
    ||rpad('PPPI_PROCESS_ORDER',30,' ')
    ||rpad(lpad(trim(to_char(i_proc_order)),12,0),30,' ')
    ||'CHAR');

  --det: event date 
  lics_outbound_loader.append_data('DET000000000000000001'
    ||rpad('PPPI_EVENT_DATE',30,' ')
    ||rpad(to_char(i_xactn_date,'YYYYMMDD'),30,' ')
    ||'DATE');

  --det: event time 
  lics_outbound_loader.append_data('DET000000000000000001'
    ||rpad('PPPI_EVENT_TIME',30,' ')
    ||rpad(trim(to_char(i_xactn_time)),30,' ')
    ||'TIME');

  if ascii(rtrim(ltrim(substr(i_material_code,1,1)))) >= 48 and  ascii(rtrim(ltrim(substr(i_material_code,1,1)))) <= 57 then
    --det: material code
    lics_outbound_loader.append_data('DET000000000000000001'
      ||rpad('PPPI_MATERIAL',30,' ')
      ||rpad(lpad(trim(i_material_code),18,'0'),30,' ')
      ||'CHAR');
  else
    lics_outbound_loader.append_data('DET000000000000000001'
      ||rpad('PPPI_MATERIAL',30,' ')
      ||rpad(trim(i_material_code),30,' ')
      ||'CHAR');
  end if;

  --det: material produced (qty)
  lics_outbound_loader.append_data('DET000000000000000001'
    ||rpad('PPPI_MATERIAL_PRODUCED',30,' ')
    ||rpad(lpad(trim(to_char(i_qty)),4,'0'),30,' ')
    ||'NUM');

  --det: unit of measure (uom)
  lics_outbound_loader.append_data('DET000000000000000001'
    ||rpad('PPPI_UNIT_OF_MEASURE',30,' ')
    ||rpad(trim(i_uom),30,' ')
    ||'CHAR');

  --det: storage location
  if (i_stor_loc_code is not null) then
    lics_outbound_loader.append_data('DET000000000000000001'
      ||rpad('PPPI_STORAGE_LOCATION',30,' ')
      ||rpad(lpad(trim(to_char('H001')),4,0),30,' ')
      ||'CHAR');
  end if;

  --det: stock type (dispn)
  if (i_dispn_code is not null) then
    lics_outbound_loader.append_data('DET000000000000000001'
      ||rpad('PPPI_STOCK_TYPE',30,' ')
      ||rpad(var_dispn,30,' ')
      ||'CHAR');
  end if;

  -- batch send 
  if (i_zpppi_batch is not null) then
    lics_outbound_loader.append_data('DET000000000000000001'
      ||rpad('PPPI_BATCH',30,' ')
      ||rpad(i_zpppi_batch,30,' ')
      ||'CHAR');
  end if;
  	  
  /*-*/
  /* det: best before date (shelf life expiration date = sled) 
  /*-*/
  if (i_bb_date is not null) then
    if i_message_type  = 'Z_PI1' then
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('ZPPPI_SLED',30,' ')
        ||rpad(trim(i_bb_date),30,' ')
        ||'DATE');
    end if;
  end if;

  	  
  if (i_plt_code is not null) then
    if (i_message_type  = 'Z_PI1' or i_message_type = 'Z_PI6') then
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('ZPPPI_EXIDV',30,' ')
        ||rpad(trim(i_plt_code),30,' ')
        ||'CHAR');
    end if;
  end if;
  	  
  if (i_plt_type is not null) then
    if i_message_type  = 'Z_PI1' then
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('ZPPPI_VHILM',30,' ')
        ||rpad(trim(i_pkg_matl),30,' ')
        ||'CHAR');
    end if;
  end if;
  	  
  	  
  if (i_plt_type is not null and i_plt_type <> ' ' ) then
    if i_message_type  = 'Z_PI1' then
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('ZPPPI_ZZENDPRDATE',30,' ')
        ||rpad(trim(i_start_prodn_date),30,' ')
        ||'CHAR');
      
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('ZPPPI_ZZENDPRTIME',30,' ')
        ||rpad(trim(i_start_prodn_time),30,' ')
        ||'CHAR');
    end if;
  end if;
	  
  if (lics_outbound_loader.is_created) then
    lics_outbound_loader.finalise_interface;
  end if;
	  
  o_result := o_result; 
exception
  when others then
    if (lics_outbound_loader.is_created) then
      lics_outbound_loader.finalise_interface;
    end if;
    		
    o_result := 1;
    o_result_msg := 'Tolas_Fds_Send failed [' || substr(sqlerrm,0.250) || substr(sqlerrm,251.350) || ']';
    raise_application_error(-20001, o_result_msg);
end;
/

grant execute on pt_app.tolas_fds_send to appsupport;
grant execute on pt_app.tolas_fds_send to bthsupport;

create or replace public synonym tolas_fds_send for pt_app.tolas_fds_send;