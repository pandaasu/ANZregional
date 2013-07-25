-- This script is run as PF_APP and is used to install the PX_DMND_LOOKUP 
-- table into the table maintence system of the planning and forecasting 
-- system.
declare
  v_result_msg common.st_message_string;
  v_result common.st_result;
begin
  dbms_output.put_line('Installing Promax Demand Lookup Table');
  v_result := table_maint_gui.install_table('PX_DMND_LOOKUP','Promax PX Demand Lookup Table','DEMAND',v_result_msg);
  dbms_output.put_line('Result : ' || v_result || ' - ' || v_result_msg); 
  commit;
end;

-- Check that the table is there.
select * from tbl_list;

-- Then go into Planning System and go to the security system.
-- Select Group Object Security.  Select the group that will be given access
-- to this table.
-- Add a TBL_LIST PX_DMND_LOOKUP READ/WRITE entry.

