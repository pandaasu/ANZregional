create or replace package pt_app.pt_cisatl17_gr_ics as
/******************************************************************************
   NAME:       PT_CISATL17_GR
   PURPOSE:    Transfer data through ICS to Atlas

   REVISIONS:
   Ver        Date        Author                    Description
   ---------  ----------  ---------------------  ------------------------------------
   1.0        20/09/2007      Jeff Phillipson       1. Created this package.
   1.1        13/02/2008      Scott R. Harding      Added msg type to filename for uniqueness
   1.2        27/10/2008      Trevor G. Keon        Removed hard-coded values for file extensions
                                                    Added optional return of interface id
******************************************************************************/

  procedure execute(o_result        out number,
                o_result_msg        out varchar2,
                o_interface_id      out number,
                i_message_type      in varchar2, -- z_pi1 create or z_pi2 reverse , z_pi6 hu reversal 
                i_plant_code        in varchar2,
                i_sender_name       in varchar2,
                i_test_flag         in boolean,  -- if true, then create test atlas message
                i_proc_order        in number,
                i_xactn_date        in date,
                i_xactn_time        in number,
                i_material_code     in varchar2,
                i_qty               in number,   -- material produced
                i_uom               in varchar2,
                i_stor_loc_code     in number,
                i_dispn_code        in varchar2, -- stock type
                i_zpppi_batch       in varchar2, -- atlas batch code
                i_last_gr_flag      in boolean,  -- if true, then last message
                i_bb_date           in number,   -- best before date 
                i_plt_code          in varchar2,
                i_plt_type          in varchar2,
                i_pkg_matl          in varchar2,
                i_start_prodn_date  in date,
                i_start_prodn_time  in number,
                i_end_prodn_date    in date,
                i_end_prodn_time    in number);

  procedure execute(o_result        out number,
                o_result_msg        out varchar2,
                i_message_type      in varchar2, -- z_pi1 create or z_pi2 reverse , z_pi6 hu reversal 
                i_plant_code        in varchar2,
                i_sender_name       in varchar2,
                i_test_flag         in boolean,  -- if true, then create test atlas message
                i_proc_order        in number,
                i_xactn_date        in date,
                i_xactn_time        in number,
                i_material_code     in varchar2,
                i_qty               in number,     -- material produced
                i_uom               in varchar2,
                i_stor_loc_code     in number,
                i_dispn_code        in varchar2, -- stock type
                i_zpppi_batch       in varchar2, -- atlas batch code
                i_last_gr_flag      in boolean,  -- if true, then last message
                i_bb_date           in number,   -- best before date 
                i_plt_code          in varchar2,
                i_plt_type          in varchar2,
                i_pkg_matl          in varchar2,
                i_start_prodn_date  in date,
                i_start_prodn_time  in number,
                i_end_prodn_date    in date,
                i_end_prodn_time    in number);          

end pt_cisatl17_gr_ics; 
/

create or replace package body pt_app.pt_cisatl17_gr_ics as
/******************************************************************************
   NAME:       PT_CISATL17_GR
   PURPOSE:    Transfer data through ICS to Atlas

******************************************************************************/


  procedure execute(o_result          out number,
                  o_result_msg        out varchar2,
                  o_interface_id      out number,
                  i_message_type      in varchar2, -- z_pi1 create or z_pi2 reverse , z_pi6 hu reversal 
                  i_plant_code        in varchar2,
                  i_sender_name       in varchar2,
                  i_test_flag         in boolean,  -- if true, then create test atlas message
                  i_proc_order        in number,
                  i_xactn_date        in date,
                  i_xactn_time        in number,
                  i_material_code     in varchar2,
                  i_qty               in number,   -- material produced
                  i_uom               in varchar2,
                  i_stor_loc_code     in number,
                  i_dispn_code        in varchar2, -- stock type
                  i_zpppi_batch       in varchar2, -- atlas batch code
                  i_last_gr_flag      in boolean,  -- if true, then last message
                  i_bb_date           in number,   -- best before date 
                  i_plt_code          in varchar2,
                  i_plt_type          in varchar2,
                  i_pkg_matl          in varchar2,
                  i_start_prodn_date  in date,
                  i_start_prodn_time  in number,
                  i_end_prodn_date    in date,
                  i_end_prodn_time    in number) as
	
    /*-*/
    /* Variables
    /*-*/
    var_timestamp     	  varchar2(200);
    var_test_flag		      varchar2(1)  := '';
    var_db_value          varchar2(4);
    var_extension         varchar2(2);
    var_site              varchar2(4);

    /*-*/
    /* Variables for ICS interface creation
    /*-*/    
    var_interface         varchar2(100);
    var_fil_name          varchar2(500);
    var_msg_name          varchar2(500);

    var_vir_table lics_datastore_table := lics_datastore_table();
            
    exc_process_exception	exception;	
	
    /*-*/
    /* This value defines the interface to send
    /*-*/
    cst_file_name	      constant varchar2(20) := 'CISATL17';   
    cst_file_interface  constant varchar2(20) := 'PDBICS17';
	
  begin 
    /*-*/
    /* Initialise output variables
    /*-*/      
    o_result := 0;
    o_result_msg := 'OK';
	  
    /*-*/
    /* Get site specific settings
    /*-*/     
    var_site := lics_app.lics_setting_configuration.retrieve_setting('pdb','site_code');
    var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'GR');
    var_db_value := var_vir_table(1).dsv_value;
    
    var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'BU');
    var_extension := var_vir_table(1).dsv_value;       
        
    if ( upper(trim(i_message_type)) = 'ZPI_CONS' or upper(trim(i_message_type)) = 'Z_PI4' ) then
      var_timestamp := to_char(systimestamp,'yyyymmddhh24missff') || 'C' || trim(i_plant_code) || 'PO' || trim(i_proc_order) || 'M' || trim(i_material_code);
    else
      var_timestamp := to_char(systimestamp,'yyyymmddhh24missff') ||  'P' || i_plt_code || 'MT' || upper(trim(i_message_type));
    end if;
	 
	  if ( i_test_flag = true ) then
      var_test_flag := 'X';
	  end if;

    var_interface := cst_file_interface || '.' || var_db_value;
    var_fil_name := cst_file_name || '_' || var_timestamp || '.' || var_extension;
    var_msg_name := cst_file_name || '.' || var_extension;

    /*-*/
    /* Create local interface to send GR data
    /*-*/ 
    o_interface_id := lics_outbound_loader.create_interface(var_interface, var_fil_name, var_msg_name);
	 
    /*-*/
    /* CREATE DATA LINES FOR MESSAGE 
    /* HEADER: Header Record 
    /* Including 'X' at the end of the header record will cause Atlas
    /* to treat the message as a test, meaning no further processing
    /* will be completed once it reaches Atlas.
    /*-*/
	  lics_outbound_loader.append_data('HDR000000000000000001'      
      || rpad(trim(i_plant_code),4,' ')
      || rpad(i_message_type,8,' ')
      || rpad(trim(i_sender_name),32,' ')
      || trim(var_test_flag));
		
    if ( i_plt_type is not null and i_plt_type <> ' ' ) then
      if ( i_message_type  = 'Z_PI1' ) then
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_VHILM',30,' ')
          || rpad(trim(i_pkg_matl),30,' ')
          || 'CHAR');
      end if;
    end if;
	  												 
    --DET: PROCESS ORDER
    lics_outbound_loader.append_data('DET000000000000000001'
      || rpad('PPPI_PROCESS_ORDER',30,' ')
      || rpad(lpad(trim(to_char(i_proc_order)),12,0),30,' ')
      || 'CHAR');

    --DET: EVENT DATE
    lics_outbound_loader.append_data('DET000000000000000001'
      || rpad('PPPI_EVENT_DATE',30,' ')
      || rpad(to_char(i_xactn_date,'yyyymmdd'),30,' ')
      || 'DATE');

    --DET: EVENT TIME
    lics_outbound_loader.append_data('DET000000000000000001'
      || rpad('PPPI_EVENT_TIME',30,' ')
      || rpad(trim(to_char(i_xactn_time)),30,' ')
      || 'TIME');
      
    --DET: MATERIAL CODE
    if ( ascii(rtrim(ltrim(substr(i_material_code,1,1)))) >= 48 and ascii(rtrim(ltrim(substr(i_material_code,1,1)))) <= 57 ) then
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('PPPI_MATERIAL',30,' ')
        || rpad(lpad(trim(i_material_code),18,'0'),30,' ')
        || 'CHAR');
    else
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('PPPI_MATERIAL',30,' ')
        || rpad(trim(i_material_code),30,' ')
        || 'CHAR');
    end if;

    --DET: MATERIAL PRODUCED (QTY) 
    if ( upper(trim(i_message_type)) = 'ZPI_CONS' or upper(trim(i_message_type)) = 'Z_PI4' ) then
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('PPPI_MATERIAL_CONSUMED',30,' ')
        || rpad(trim(to_char(i_qty)),30,' ')
        || 'NUM');
    else
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('PPPI_MATERIAL_PRODUCED',30,' ')
        || rpad(trim(to_char(i_qty)),30,' ')
        || 'NUM');
    end if;

    --DET: UNIT OF MEASURE (UOM)
    lics_outbound_loader.append_data('DET000000000000000001'
      || rpad('PPPI_UNIT_OF_MEASURE',30,' ')
      || rpad(i_UOM,30,' ')
      || 'CHAR');

    --DET: STORAGE LOCATION
    if ( i_stor_loc_code is not null ) then
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('PPPI_STORAGE_LOCATION',30,' ')
        || rpad(lpad(to_char(i_stor_loc_code),4,0),30,' ')
        || 'CHAR');
    end if;

    --DET: STOCK TYPE (DISPN)
    if ( i_dispn_code is not null ) then
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('Z_PPPI_STOCK_TYPE',30,' ')
        || rpad(i_dispn_code,30,' ')
        || 'CHAR');
    end if;

    --DET: ZPPPI BATCH CODE 
    if ( i_zpppi_batch is not null and i_zpppi_batch <> ' ' ) then
      if ( i_message_type = 'Z_PI2' or i_message_type = 'Z_PI6' ) then
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('PPPI_BATCH',30,' ')
          || rpad(i_zpppi_batch,30,' ')
          || 'CHAR');
      else 
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_BATCH',30,' ')
          || rpad(i_zpppi_batch,30,' ')
          || 'CHAR');
      end if;
    end if;

    --DET: DELIVER COMPLETE (LAST GR/RGR) 
    if ( i_last_gr_flag = true ) then
      lics_outbound_loader.append_data('DET000000000000000001'
        || rpad('PPPI_DELIVERY_COMPLETE',30,' ')
        || rpad(trim('X'),30,' ')
        || 'CHAR');
    end if;
										   
    --DET: BEST BEFORE DATE (SHELF LIFE EXPIRATION DATE = SLED) 
    if (i_bb_date is not null) then
      if ( i_message_type  = 'Z_PI1' ) then
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_SLED',30,' ')
          || rpad(trim(i_bb_date),30,' ')
          || 'DATE');
      end if;
    end if;

    	  
    if ( i_plt_type is not null and i_plt_type <> ' ' ) then
      if ( i_message_type  = 'Z_PI1' or i_message_type = 'Z_PI6' ) then
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_EXIDV',30,' ')
          || rpad(trim(i_plt_code),30,' ')
          || 'CHAR');
      end if;
    end if;
    	  
    if ( i_plt_type is not null and i_plt_type <> ' '  ) then
      if ( i_message_type  = 'Z_PI1' ) then
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_ZZPALETCHAR',30,' ')
          || rpad(trim(i_plt_type),30,' ')
          || 'CHAR');
      end if;
    end if;
	  
    if ( i_plt_type is not null and i_plt_type <> ' ' ) then
      if ( i_message_type  = 'Z_PI1' ) then
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_ZZSRTPRDATE',30,' ')
          || rpad(to_char(i_start_prodn_date,'yyyymmdd'),30,' ')
          || 'DATE');
          
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_ZZSRTPRTIME',30,' ')
          || rpad(lpad(trim(i_start_prodn_time),6,'0'),30,' ')
          || 'TIME');
          
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_ZZENDPRDATE',30,' ')
          || rpad(to_char(i_end_prodn_date,'yyyymmdd'),30,' ')
          || 'DATE');
          
        lics_outbound_loader.append_data('DET000000000000000001'
          || rpad('ZPPPI_ZZENDPRTIME',30,' ')
          || rpad(lpad(trim(i_end_prodn_time),6,'0'),30,' ')
          || 'TIME');
      end if;
    end if;
	  
	
    /*-*/
    /*Close Remote Interface and send Unix script 
    /*-*/
    lics_outbound_loader.finalise_interface();
    
    lics_logging.start_log('Goods Recipt & Consumption', 'Message type' || i_message_type);
    lics_logging.write_log('Pallet: ' || i_plt_code || ' Material code: ' || i_material_code || ' Quantity: ' || i_qty);
    lics_logging.end_log;
    
    /*-*/
    /* add file name to error message
    /*-*/
    o_result_msg := var_timestamp;

  <<finish>>
    o_result := 0;
  exception
    when others then
      if ( lics_outbound_loader.is_created() ) then
        lics_outbound_loader.finalise_interface();
      end if;
      
      if ( not lics_logging.is_created ) then
        lics_logging.start_log('Goods Recipt & Consumption', 'Message type' || i_message_type);
      end if;
      
      lics_logging.write_log('Creation of Idoc failed [' || substr(sqlerrm,0,1900) || ']');
      lics_logging.end_log;
               
      o_result := 1;
      o_result_msg := 'Creation of Idoc failed [' || substr(sqlerrm,0,1900) || ']';
  end execute;
   
  procedure execute(o_result        out number,
                o_result_msg        out varchar2,
                i_message_type      in varchar2, -- z_pi1 create or z_pi2 reverse , z_pi6 hu reversal 
                i_plant_code        in varchar2,
                i_sender_name       in varchar2,
                i_test_flag         in boolean,  -- if true, then create test atlas message
                i_proc_order        in number,
                i_xactn_date        in date,
                i_xactn_time        in number,
                i_material_code     in varchar2,
                i_qty               in number,   -- material produced
                i_uom               in varchar2,
                i_stor_loc_code     in number,
                i_dispn_code        in varchar2, -- stock type
                i_zpppi_batch       in varchar2, -- atlas batch code
                i_last_gr_flag      in boolean,  -- if true, then last message
                i_bb_date           in number,   -- best before date 
                i_plt_code          in varchar2,
                i_plt_type          in varchar2,
                i_pkg_matl          in varchar2,
                i_start_prodn_date  in date,
                i_start_prodn_time  in number,
                i_end_prodn_date    in date,
                i_end_prodn_time    in number) as
    var_dummy number;                
  begin
    execute
    (
      o_result,
      o_result_msg,
      var_dummy,
      i_message_type,
      i_plant_code,
      i_sender_name,
      i_test_flag,
      i_proc_order,
      i_xactn_date,
      i_xactn_time,
      i_material_code,
      i_qty,
      i_uom,
      i_stor_loc_code,
      i_dispn_code,
      i_zpppi_batch,
      i_last_gr_flag,
      i_bb_date,
      i_plt_code,
      i_plt_type,
      i_pkg_matl,
      i_start_prodn_date,
      i_start_prodn_time,
      i_end_prodn_date,
      i_end_prodn_time      
    );
  end execute;  
       
end pt_cisatl17_gr_ics; 
/

