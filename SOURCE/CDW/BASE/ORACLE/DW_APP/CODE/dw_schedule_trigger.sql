create or replace package dw_app.dw_schedule_trigger as

   /******************************************************************************/
   /* Package Definition                                                        */
   /******************************************************************************/
   /**
    Package : dw_schedule_trigger 
    Owner   : dw_app 

    Description
    -----------
    Dimensional Data Store - Scheduled Aggregation Trigger 

    This package contain procedures to trigger the scheduled aggregation tasks 

    **notes**
    1. This package does NOT perform commits or rollbacks. 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2015/06   Trevor Keon    Created 
    *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure trigger_scheduled_aggregation(par_company_code in varchar2);
   
end dw_schedule_trigger;

create or replace package body dw_app.dw_schedule_trigger as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************************/
   /* This procedure performs the purchase order base status routine */
   /******************************************************************/
   procedure trigger_scheduled_aggregation(par_company_code in varchar2) is    
     
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

       lics_stream_loader.load('DW_SCHEDULED_STREAM_'||par_company_code, 'Running DW scheduled stream for company '||par_company_code, null);    
       lics_stream_loader.execute;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end trigger_scheduled_aggregation;

end dw_schedule_trigger;
/

grant execute on dw_app.dw_schedule_trigger to lics_app;
create or replace public synonym dw_schedule_trigger for dw_app.dw_schedule_trigger;