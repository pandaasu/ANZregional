create or replace package body pxipmx14_extract as
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- Package Name
  pc_package_name       constant pxi_common.st_package_name := 'PXIPMX14_EXTRACT';
  pc_outbound_interface constant pxi_common.st_interface_name := 'PXIPMX14';

/*******************************************************************************
  Package Variables
*******************************************************************************/  

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
*******************************************************************************/
  procedure execute(
    i_demand_seq in pxi_e2e_demand.st_sequence, 
    i_estimate_seq in pxi_e2e_demand.st_sequence) is
    v_instance pxi_e2e_demand.st_sequence;
    v_suffix pxi_common.st_interface_name;
  begin
    v_suffix := '3';
    v_instance := lics_outbound_loader.create_interface(pc_outbound_interface || '.' || v_suffix);
    lics_outbound_loader.append_data('"103986_0196","APBW","AU","20141207 00:00:00",10080,7,"PROMAXPX",1.000000,"0196","PROMAXPX","20141209 15:13:54"');
    lics_outbound_loader.append_data('"103986_0196","APBW","AU","20141214 00:00:00",10080,7,"PROMAXPX",1.000000,"0196","PROMAXPX","20141209 15:13:54"');
    lics_outbound_loader.append_data('"103986_0196","APBW","AU","20141221 00:00:00",10080,7,"PROMAXPX",1.000000,"0196","PROMAXPX","20141209 15:13:54"');
    lics_outbound_loader.append_data('"103986_0196","APBW","AU","20141228 00:00:00",10080,7,"PROMAXPX",1.000000,"0196","PROMAXPX","20141209 15:13:54"');
    lics_outbound_loader.finalise_interface;
   exception
     when others then
       if lics_outbound_loader.is_created = true then
          lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
          lics_outbound_loader.finalise_interface;
       end if;
       -- Re Raise the exception.
       pxi_common.reraise_promax_exception(pc_package_name,'EXECUTE');
  end execute;

end pxipmx14_extract;
/