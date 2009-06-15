create or replace package re_timing_common is
/******************************************************************************************************
   NAME:       Re_timing_Common
   PURPOSE:    Constants used by Re Timing.

   REVISIONS:
   Ver        Date          Author              Description
   ---------  ----------    ---------------     ------------------------------------
   1.0        21/11/2005    Jeff Phillipson     1. Created this package.
   2.0        10/06/2008    Daniel Owen         Added 6 day RTT msg code and renamed all RTT msg codes
   3.0		    05/11/2008	  Chris Munn			    Added message codes for window withs 6 up to days wide.
*******************************************************************************************************/

  -- System Constants
  subtype  result_type is integer;
  success  constant result_type := 0;  -- worked successfully.
  failure  constant result_type := 1;  -- the request was failed to be carried out or the desired answer was false.  the reason for it being false will be containted in the error message.
  error    constant result_type := 2;  -- oracle error most likley or other serious problem.
    		
  istrue	constant result_type := 1;
  isfalse	constant result_type := 0;
  		
  subtype  access_type is integer;
  noaccess constant access_type := 0;
  readonly constant access_type := 1;
  edit     constant access_type := 2;
  		
  /*-*/
  /* note: the firm start and end times are defined in the re_timing package
  /*-*/
  schedule_days constant number := 21;  -- schedule period 
  		
  /*-*/
  /* this is the start time for the production schedule to be sent to atlas
  /* ie 6 pm = 6:00pm
  /*-*/
  schedule_time constant number := 18/24;
  /*-*/
  /* the schedule_time_delay is the estimated time to get into atlas and allow mrp to run 
  /*-*/
  schedule_time_delay constant number := 50/1440;  -- corresponds to 50 minutes 
  /*-*/
  /* this constant is used for the rtt schedule send
  /* if the time is before schedule_change then now + 1 is added as the firm date
  /* after schedule_change the firm date is now + 2 days
  /*-*/
  schedule_change constant number := schedule_time + schedule_time_delay;
  		
  /*-*/
  /* used as a string to lock the database
  /*-*/
  subtype     lock_type is varchar2(10);
  edit_mode   constant lock_type := 'PR_EDIT';
  		
  /*-*/
  /* wodonga settings 
  /*-*/
  --schedule_code constant varchar(3) := '011';
  --retiming_code constant varchar2(3) := '010';
  /*-*/
  /* bathurst values 
  /*-*/
  schedule_code constant varchar(3) := '012';
  -- on_demand_schedule_code added by chris munn 26-03-2009
  on_demand_schedule_code constant varchar(3) := 'B12';
  retiming_code_2days constant varchar2(3) := '013'; -- indicates a window width of 2 days
  retiming_code_3days constant varchar2(3) := '017'; -- indicates a window width of 3 days
  retiming_code_4days constant varchar2(3) := '020'; --  indicates a window width of 4 days
  retiming_code_5days constant varchar2(3) := '021'; --  indicates a window width of 5 days
  retiming_code_6days constant varchar2(3) := '022'; --  indicates a window width of 6 days
                  
  -- default reference return cursor.
  type return_ref_cursor is ref cursor;
end;

grant execute on manu_app.re_timing_common to appsupport;
grant execute on manu_app.re_timing_common to bthsupport;
grant execute on manu_app.re_timing_common to pr_admin;
grant execute on manu_app.re_timing_common to pr_app with grant option;
grant execute on manu_app.re_timing_common to pr_user;
grant execute on manu_app.re_timing_common to bth_scheduler;

create or replace public synonym re_timing_common for manu_app.re_timing_common;
