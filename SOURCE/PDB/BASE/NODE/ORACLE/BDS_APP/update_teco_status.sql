create or replace procedure bds_app.update_teco_status (i_proc_order in varchar2, i_plant_code in varchar2, i_teco_status in varchar2) is
/******************************************************************************
   NAME:       update_teco_status
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/01/2008  Liam Watson       1. Created this procedure.  
   1.1        27-Feb-2008 Jeff Phillipson   Added error checking 
   
   Notes:
   Allows manual updating of teco_status in the bds_recipe_header table.
   Manual updating required due to bug in Atlas whereby process orders closed
   after period end do not have their status updated in LADS.
******************************************************************************/
  var_count number;
   
begin
    
  /*-*/
  /* check for valid proc order  
  /*-*/
  select count(*) into var_count
  from bds_recipe_header
  where ltrim(proc_order,'0') = ltrim(i_proc_order,'0');

  if ( var_count = 0 ) then
    raise_application_error(-20001, 'Invalid Process Order value');
  end if;
      
  /*-*/
  /* check for valid plant  
  /*-*/
  select count(*) into var_count
  from bds_recipe_header
  where plant_code = i_plant_code
    and ltrim(proc_order,'0') = ltrim(i_proc_order,'0');

  if ( var_count = 0 ) then
    raise_application_error(-20002, 'Invalid Plant code');
  end if;
      
  /*-*/
  /* check teco value can be YES or NO only 
  /*-*/
  if not(upper(i_teco_status) = 'YES' or upper(i_teco_status) = 'NO') then
    raise_application_error(-20003, 'Invalid Teco Status value. Only YES and NO are acceptable');
  end if;
      
  /*-*/
  /* update teco_status in bds_recipe_header table
  /*-*/
  update bds_recipe_header
  set teco_status = i_teco_status 
  where ltrim(proc_order,'0') = ltrim(i_proc_order,'0')
  and plant_code = i_plant_code;
        
  commit;
    
exception
  when others then
    rollback;
    raise_application_error(-20000, 'teco_status update failed.' || 'Oracle error ' || substr(sqlerrm, 1, 1000));
             
end update_teco_status;

create or replace public synonym update_teco_status for bds_app.update_teco_status;