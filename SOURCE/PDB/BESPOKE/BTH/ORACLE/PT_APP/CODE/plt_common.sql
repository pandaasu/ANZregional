create or replace package pt_app.plt_common is

  -- System Constants
  subtype result_type is integer;
  success      constant  result_type := 0;  -- Worked Successfully.
  failure      constant  result_type := 1;  -- The request was failed to be carried out or the desired answer was false.  The reason for it being false will be containted in the error message.
  error        constant  result_type := 2;  -- Oracle Error Most likley or other serious problem.
  timeout      constant  result_type := 3;  -- Unable to complete the operation as the system timed out, or in the case of security if
                                  -- there have been no access for a certain period of time and hence the function should no be executed at this point in time.
  	                                                              
  /* Times to Disable the Idoc sending for Pallet Tagging during 
  || End of Period Financial processing in Atlas
  || During this time NO Goods Recipts or STO's should be sent to Atlas 
  ||
  || Note if this function needs to be disabled 
  || set the PERIOD_END_DATE to any number greater than 28  
  */
  period_end_day constant number := 28;
  -- based on 24hr clock in hours 
  disable_start constant number := 23;
  -- duration in hours - minutes in decimal 
  disable_duration constant number := 3;
  	  
  /*-*/
  /* added this test flag so that production file transfers of Atlas and Tolas data can be stopped
  /*-*/
  subtype disable_type is boolean;
  disable_atlas_tolas_send constant disable_type := true;
  
  type return_ref_cursor is ref cursor;	
end;
/

grant execute on pt_app.plt_common to appsupport;
grant execute on pt_app.plt_common to bthsupport;
grant execute on pt_app.plt_common to pt_maint;

create or replace public synonym plt_common for pt_app.plt_common;