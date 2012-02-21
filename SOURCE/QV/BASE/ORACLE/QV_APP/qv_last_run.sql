create or replace package qv_app.qv_trigger_utilities as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_last_run
    Owner   : qv_app
    Author  : Trevor Keon

    Description
    -----------
    Qlikview Loader - Last Run

    PURPOSE:  Stores the details for any given interface so a trigger file sent
    to the QlikView server can load the data required.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/06   Trevor Keon    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure send_trigger(par_interface in varchar2, par_file_contents in varchar2);
   procedure add_csvqvs13_trigger_data(par_period in varchar2, par_bus_sgmnt in varchar2, par_date date);    
   
end qv_last_run;

create or replace package body qv_app.qv_trigger_utilities as

   procedure send_trigger(par_interface in varchar2, par_file_contents in varchar2)
   
   begin
   
   end send_trigger;
   

   procedure add_csvqvs13_trigger_data(par_period in varchar2, par_bus_sgmnt in varchar2, par_date date)

      /*-*/
      /* Private delcarations 
      /*-*/
      var_interface varchar2(10 char);
   
      /*-*/
      /* Autonomous transaction 
      /*-*/
      pragma autonomous_transaction;   
   
   begin
      
      if not(par_period is null) or
        not(par_bus_sgmnt is null) then      

         /*-*/
         /* Check the business segment to use the correct interface  
         /*-*/           
         if par_bus_sgmnt = '05' then
            var_interface := 'CSVQVS13.1';
         end if;

         /*-*/
         /* Update the trigger data
         /*-*/   
         update qv_trigger_data
         set date_updated = par_date
         where interface_num = var_interface
            and filter_01 = par_period
            and filter_02 = par_bus_sgmnt;
                   
         if ( sql%notfound ) then
            /*-*/
            /* Insert the identifier row 
            /*-*/    
            insert into qv_trigger_data
            (
               interface_num,          
               date_updated,
               filter_01,
               filter_02,
            )
            values
            (
               var_interface,
               par_date,
               par_period,
               par_bus_sgmnt
            );
         end if;
         
        /*-*/
        /* Commit the database 
        /* note - isolated commit (autonomous transaction) 
        /*-*/   
        commit;
         
      end if;      
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end add_csvqvs13_trigger_data;     

end qv_trigger_utilities;

/**/
/* Synonym 
/**/
create or replace public synonym qv_trigger_utilities for qv_app.qv_trigger_utilities;