create or replace procedure pt_app.tolas_ltds_send(o_result          in out number,
                                                   o_result_msg      in out varchar2,
                                                   i_message_type	  in varchar2,	-- z_pi1 create or z_pi2 reverse , z_pi6 hu reversal 
                                                   i_plant_code	  in varchar2,
                                                   i_material_code	  in varchar2,
                                                   i_qty			  in number,	   	-- material produced
                                                   i_dispn_code	  in varchar2,	-- stock type
                                                   i_zpppi_batch	  in varchar2,	-- atlas batch code
                                                   i_bb_date		  in varchar2,	-- best before date 
                                                   i_plt_code		  in varchar2,
                                                   i_seq			  in varchar2) as

  /******************************************************************************
     NAME:       TOLAS_LTDS_SEND
     PURPOSE:    Transfer data through ICS to Tolas

     REVISIONS:
     Ver        Date        Author                    Description
     ---------  ----------  ---------------------  ------------------------------------
     1.0        ??/??/????  Unknown                 1. Created this package.
     1.1        11/06/2009  Trevor G. Keon          2. Configured to send via ICS
  ******************************************************************************/      
	
  /*-*/
  /* Variables
  /*-*/
  var_work 			varchar2(20);
  var_dispn			varchar2(2);
  var_bb_date			varchar2(12);
  	
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
  cst_file_interface  constant varchar2(20) := 'PDBTOL02';  
  
  /*-*/
  /* cursor definitions 
  /*-*/
  cursor csr_gtin is
    select ean_code 
    from manu.matl
    where matl_code = trim(i_material_code)
      and plant = i_plant_code;
	
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

  /*-*/
  /* get ean code which is the same as gtin code 
  /*-*/
  open csr_gtin;
  fetch csr_gtin into var_work;
  if  csr_gtin%notfound then
    var_work := ' ';
  end if;	 
  close csr_gtin;
      
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
           
  if i_bb_date is null then
    var_bb_date := ' ';
  else
    var_bb_date := i_bb_date;
  end if;
  
  /*-*/
  /* Create local interface to send Tolas data
  /*-*/ 
  var_interface_id := lics_outbound_loader.create_interface(var_interface);  	

  /*-*/
  /* header: header record 
  /*-*/			
  lics_outbound_loader.append_data('HDR'
    ||rpad(trim(i_plt_code),20,' ')
    ||rpad(' ',5,' ')
    ||rpad(trim(i_material_code),8,' ')
    ||rpad(var_work,14,' ')
    ||rpad(trim(i_zpppi_batch),10,' ')
    ||rpad(trim(var_bb_date),8,' ')
    ||lpad(i_qty,4,' ')
    ||rpad(i_plant_code,4,' ')
    ||'R'
    ||rpad(var_dispn,4, ' ')
    ||rpad(' ',12, ' '));										
	  
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
    o_result_msg := 'Tolas_Ltds_Send failed error is - ['||sqlerrm||']';
    raise_application_error(-20001, o_result_msg);
end;
/

grant execute on pt_app.tolas_ltds_send to appsupport;
grant execute on pt_app.tolas_ltds_send to bthsupport;

create or replace public synonym tolas_ltds_send for pt_app.tolas_ltds_send;