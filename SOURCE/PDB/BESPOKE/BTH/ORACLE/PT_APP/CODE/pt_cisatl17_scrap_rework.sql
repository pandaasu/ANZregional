create or replace package pt_app.pt_cisatl17_scrap_rework as
/******************************************************************************
   NAME:       SCRAP_REWORK_SEND
   PURPOSE:    This procedure will be called from an Oracle job running
               every 30mins typical
               It will collect all scrap or rework records and
               send grouped by proc-order and material
   REVISIONS:
   Ver        Date          Author             Description
   ---------  ----------    ---------------    ------------------------------------
   1.0        18-05-2007    Jeff Phillipson    1. Created this package.
   1.1        21-Nov-2007   Jeff Phillipson    Added proc order filter to sending material count
   1.2        20-Dec-2007   Jeff Phillipson    Added purge of INTERFACE_ERROR tableafter 4 days
   1.3        20-Dec-2007   Jeff Phillipson    Changed material for a GR reversal to POs matl code
   1.4        17-Jun-2009   Trevor Keon        Removed hard-coded values for file extensions
                                               Removed the INTERFACE_ERROR table call  
******************************************************************************/

  procedure execute;

end pt_cisatl17_scrap_rework;
/

create or replace package body pt_app.pt_cisatl17_scrap_rework as
/******************************************************************************
   NAME:       SCRAP_REWORK_SEND
   PURPOSE:    This procedure will be called from an Oracle job running
               every 30mins typical
               It will collect all scrap or rework records and
               send grouped by proc-order and material

******************************************************************************/

  /*-*/
  /* Private exceptions
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  procedure execute is

    /*-*/
    /* Variables
    /*-*/                  
    var_success               number;
    var_count                 number;
    var_stockable             number;
    var_scale                 number;
    var_result                number;
    var_result_msg            varchar2(2000);   
    var_db_value              varchar2(4);
    var_extension             varchar2(2);
    var_site                  varchar2(4);       
          
    /*-*/
    /* Variables for ICS interface creation
    /*-*/    
    var_interface         varchar2(100);
    var_msg_name          varchar2(500);

    var_vir_table lics_datastore_table := lics_datastore_table();
    
    /*-*/
    /* This value defines the interface to send
    /*-*/
    cst_file_name	      constant varchar2(20) := 'CISATL17';   
    cst_file_interface  constant varchar2(20) := 'PDBICS17';         
    
    /*-*/
    /* these values defines the interface and file constants 
    /*-*/
    cst_message_type   constant varchar2(10) := 'Z_PI8';
    cst_max_files      constant number := 100;    
    
    cursor csr_scrap_rework is
      select * 
      from scrap_rework
      where sent_flag is null 
        and rownum < cst_max_files + 1
      order by event_datime;           
    rcd_scrap_rework csr_scrap_rework%rowtype;          
                   
  begin
  
    /*-*/
    /* Get site specific settings
    /*-*/     
    var_site := lics_app.lics_setting_configuration.retrieve_setting('pdb','site_code');
    var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'GR');
    var_db_value := var_vir_table(1).dsv_value;
    
    var_vir_table := lics_app.lics_datastore.retrieve_value('PDB',var_site,'BU');
    var_extension := var_vir_table(1).dsv_value;   
    
    var_interface := cst_file_interface || '.' || var_db_value;
    var_msg_name := cst_file_name || '.' || var_extension;   
          
    open csr_scrap_rework;
    loop
      fetch csr_scrap_rework into rcd_scrap_rework;
      exit when csr_scrap_rework%notfound;
      
      if not lics_outbound_loader.is_created then
        var_success := lics_outbound_loader.create_interface(var_interface, null, var_msg_name);
      end if; 
             
      /*-*/
      /* determine if material code is stockable */
      /*-*/
      select count(*) 
      into var_stockable
      from bds_material_plant_mfanz
      where ltrim(sap_material_code,'0') = rcd_scrap_rework.matl_code
        and plant_code = rcd_scrap_rework.plant_code
        and procurement_type || special_procurement_type <> 'E50';      
             
      lics_outbound_loader.append_data('HDR000000000000000001'
        ||rpad(trim(rcd_scrap_rework.plant_code),4,' ')
        ||rpad(cst_message_type,8,' ')
        ||rpad(' ',32,' ')
        ||trim(' '));  -- test flag    
               
      if rcd_scrap_rework.proc_order is not null and var_stockable = 0 then            
        lics_outbound_loader.append_data('DET000000000000000001'
          ||rpad('PPPI_PROCESS_ORDER',30,' ')
          ||rpad(lpad(rcd_scrap_rework.proc_order,12,'0'),30,' ')
          ||'CHAR');
      end if; 
                                            
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('PPPI_EVENT_DATE',30,' ')
        ||nvl(rpad(to_char(rcd_scrap_rework.event_datime, 'YYYYMMDD'),30,' '),'0')
        ||'DATE');  
              
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('PPPI_EVENT_TIME',30,' ')
        ||nvl(rpad(to_char(rcd_scrap_rework.event_datime, 'HH24MISS'),30,' '),'0')
        ||'TIME');                                           
                   
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('PPPI_MATERIAL',30,' ')
        ||rpad(lpad(trim(rcd_scrap_rework.matl_code),18,'0'),30,' ')
        ||'CHAR');             
                   
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('PPPI_MATERIAL_QUANTITY',30,' ')
        ||rpad(nvl(to_char(rcd_scrap_rework.qty),'0'),30,' ')
        ||'NUM');
             
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('PPPI_UNIT_OF_MEASURE',30,' ')
        ||rpad(trim(rcd_scrap_rework.uom),30,' ')
        ||'CHAR');
             
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('PPPI_STORAGE_LOCATION',30,' ')
        ||rpad(lpad(rcd_scrap_rework.storage_locn,4,'0'),30,' ')
        ||'CHAR');
             
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('ZPPPI_PLANT',30,' ')
        ||rpad(trim(rcd_scrap_rework.plant_code),30,' ')
        ||'CHAR');
             
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('Z_SNR_REASON_CODE',30,' ')
        ||rpad(lpad(rcd_scrap_rework.reason_code,4,'0'),30,' ')
        ||'CHAR'); 
       
      if (rcd_scrap_rework.proc_order is null or var_stockable = 1)  then                            
        lics_outbound_loader.append_data('DET000000000000000001'
          ||rpad('ZPPPI_COSTCENTER',30,' ')
          ||rpad(rcd_scrap_rework.cost_centre,30,' ')
          ||'CHAR');  
      end if;  
                                                               
      lics_outbound_loader.append_data('DET000000000000000001'
        ||rpad('Z_SNR_RW_INDICATOR',30,' ')
        ||rpad(trim(rcd_scrap_rework.scrap_rework_code),30,' ')
        ||'CHAR'); 
                                  
      if length(ltrim(rcd_scrap_rework.matl_code,'0')) = 8 then
        lics_outbound_loader.append_data('DET000000000000000001'
          ||rpad('PPPI_BATCH',30,' ')
          ||rpad(rcd_scrap_rework.batch_code,30,' ')
          ||'CHAR');
      end if;
                                        
      if rcd_scrap_rework.scrap_rework_code = 'R' then 
        if rcd_scrap_rework.rework_code is not null then
          lics_outbound_loader.append_data('DET000000000000000001'
            ||rpad('Z_SNR_REWORK',30,' ')
            ||rpad(lpad(rcd_scrap_rework.rework_code,18,'0'),30,' ')
            ||'CHAR'); 
        end if; 
        
        if rcd_scrap_rework.rework_exp_date is not null then
          lics_outbound_loader.append_data('DET000000000000000001'
            ||rpad('Z_SNR_REWORK_EXPDATE',30,' ')
            ||rpad(to_char(rcd_scrap_rework.rework_exp_date,'YYYYMMDD'),30,' ')
            ||'DATE');  
        end if; 
           
        if rcd_scrap_rework.rework_sloc is not null then
          lics_outbound_loader.append_data('DET000000000000000001'
            ||rpad('Z_SNR_REWORK_SLOC',30,' ')
            ||rpad(lpad(rcd_scrap_rework.rework_sloc,4,'0'),30,' ')
            ||'CHAR'); 
        end if; 
                                        
      end if;                   
        	     
      /*-*/
      /* update sent flag
      /*-*/
      begin
        select * 
        into rcd_scrap_rework
        from scrap_rework 
        where scrap_rework_id = rcd_scrap_rework.scrap_rework_id
        for update nowait;
        
        update scrap_rework
        set sent_flag = 'Y'
        where scrap_rework_id = rcd_scrap_rework.scrap_rework_id;
      exception
        when others then
          if not lics_logging.is_created then
            lics_logging.start_log('PT_CISATL17_Scrap_Rework.execute','Send file');
          end if;
          lics_logging.write_log('Failed to update scrap_rework table - date: ' || ' Material code ' || rcd_scrap_rework.matl_code);
      end;
             
    end loop;
    close csr_scrap_rework;
              
    if lics_outbound_loader.is_created then
      lics_outbound_loader.finalise_interface();
    end if;
    
    if lics_logging.is_created then
      lics_logging.end_log;
    end if;
    
    commit;   
        
  exception
    when others then
      if (lics_outbound_loader.is_created()) then
        lics_outbound_loader.finalise_interface();
      end if;
      
      if not lics_logging.is_created then
        lics_logging.start_log('PT_CISATL17_Scrap_Rework.execute','Send file');
      end if; 
           
      lics_logging.write_log('PDBICS15 failed - ' || 'Oracle error ' || substr(sqlerrm, 1, 512));
      
      if lics_logging.is_created then
        lics_logging.end_log;
      end if;
      
      raise_application_error(-20000, 'Pt_Cisatl17_Scrap_Rework - failed' || chr(13) || 'Oracle error ' || substr(sqlerrm, 1, 1000));
  end;

end pt_cisatl17_scrap_rework;
/

grant execute on pt_app.pt_cisatl17_scrap_rework to appsupport;
grant execute on pt_app.pt_cisatl17_scrap_rework to lics_app with grant option;

create or replace public synonym pt_cisatl17_scrap_rework for pt_app.pt_cisatl17_scrap_rework;