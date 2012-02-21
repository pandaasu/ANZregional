create or replace package qv_app.qv_csvqvs03_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs03_loader
    Owner   : qv_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS03 - Qlikview Comments

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/10   Trevor Keon    Created
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs03_loader;

create or replace package body qv_app.qv_csvqvs03_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_heading_count constant number := 1;
   con_interface constant varchar2(10) := 'CSVQVS03';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   rcd_qv_comments qv_comments%rowtype;
   
   /*-*/
   /* Private declarations
   /*-*/
   function calculate_removal_date(par_valid_period in varchar2) return date;
   function calculate_next_id(par_dashboard in varchar2, par_tab in varchar2) return number;
   procedure add_history(par_id in number, par_dashboard in varchar2, par_tab in varchar2);   

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      lics_logging.start_log(con_interface, con_interface);

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;

      /*-*/
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('ID',1);
      lics_inbound_utility.set_csv_definition('VALID_PERIOD',2);
      lics_inbound_utility.set_csv_definition('ACTION',3);
      lics_inbound_utility.set_csv_definition('DASHBOARD',4);
      lics_inbound_utility.set_csv_definition('TAB',5);
      lics_inbound_utility.set_csv_definition('OBJECT',6);
      lics_inbound_utility.set_csv_definition('COMMENT',7); 

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap 
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_action varchar2(20);
      var_valid_period qv_comments.qvc_valid_period%type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if trim(par_record) is null then
         return;
      end if;
      var_trn_count := var_trn_count + 1;
      if var_trn_count <= con_heading_count then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/      
      var_action := lower(lics_inbound_utility.get_variable('ACTION'));
      var_valid_period := lower(lics_inbound_utility.get_variable('VALID_PERIOD'));
      
      /*-*/
      /* Ignore historical lines - for user reference only
      /*-*/       
      if var_action = 'historical' then
         return;
      end if;

      /*-*/
      /* Retrieve field values
      /*-*/ 
      rcd_qv_comments.qvc_date := sysdate;
      rcd_qv_comments.qvc_user := 'N/A';
      rcd_qv_comments.qvc_valid_period := var_valid_period;
      rcd_qv_comments.qvc_dashboard := lics_inbound_utility.get_variable('DASHBOARD');
      rcd_qv_comments.qvc_tab := lics_inbound_utility.get_variable('TAB');
      rcd_qv_comments.qvc_object := lics_inbound_utility.get_variable('OBJECT');
      rcd_qv_comments.qvc_comment := lics_inbound_utility.get_variable('COMMENT');   
    
      if var_action = 'add' or var_action = 'force' then
         rcd_qv_comments.qvc_id := calculate_next_id(rcd_qv_comments.qvc_dashboard, rcd_qv_comments.qvc_tab);
         rcd_qv_comments.qvc_remove_date := calculate_removal_date(var_valid_period);     
         
         /*-*/
         /* Insert the row when required
         /*-*/
         if not(rcd_qv_comments.qvc_id is null) or
            not(rcd_qv_comments.qvc_date is null) or
            not(rcd_qv_comments.qvc_user is null) or
            not(rcd_qv_comments.qvc_remove_date is null) or
            not(rcd_qv_comments.qvc_valid_period is null) or
            not(rcd_qv_comments.qvc_dashboard is null) or
            not(rcd_qv_comments.qvc_tab is null) or
            not(rcd_qv_comments.qvc_comment is null) then 
                      
            insert into qv_comments values rcd_qv_comments;
         else
            lics_logging.write_log('Found invalid line - #' || var_trn_count);
         end if;         
                     
      elsif var_action = 'update' then      
         rcd_qv_comments.qvc_id := lics_inbound_utility.get_variable('ID');
         rcd_qv_comments.qvc_remove_date := calculate_removal_date(var_valid_period);
         add_history(rcd_qv_comments.qvc_id, rcd_qv_comments.qvc_dashboard, rcd_qv_comments.qvc_tab);       
         
         /*-*/
         /* Update the row when required
         /*-*/
         if not(rcd_qv_comments.qvc_id is null) or
            not(rcd_qv_comments.qvc_date is null) or
            not(rcd_qv_comments.qvc_user is null) or
            not(rcd_qv_comments.qvc_remove_date is null) or
            not(rcd_qv_comments.qvc_valid_period is null) or
            not(rcd_qv_comments.qvc_dashboard is null) or
            not(rcd_qv_comments.qvc_tab is null) or
            not(rcd_qv_comments.qvc_comment is null) then           
            
            update qv_comments
            set qvc_date = rcd_qv_comments.qvc_date,
               qvc_user = rcd_qv_comments.qvc_user,
               qvc_remove_date = rcd_qv_comments.qvc_remove_date,
               qvc_valid_period = rcd_qv_comments.qvc_valid_period,
               qvc_object = rcd_qv_comments.qvc_object,
               qvc_comment = rcd_qv_comments.qvc_comment
            where qvc_id = rcd_qv_comments.qvc_id
               and qvc_dashboard = rcd_qv_comments.qvc_dashboard
               and qvc_tab = rcd_qv_comments.qvc_tab;
         else
            lics_logging.write_log('Found invalid line - #' || var_trn_count);
         end if;          
                     
      elsif var_action = 'remove' then
         rcd_qv_comments.qvc_id := lics_inbound_utility.get_variable('ID');         
         add_history(rcd_qv_comments.qvc_id, rcd_qv_comments.qvc_dashboard, rcd_qv_comments.qvc_tab);
            
         /*-*/
         /* Update the row when required
         /*-*/
         if not(rcd_qv_comments.qvc_id is null) or
            not(rcd_qv_comments.qvc_dashboard is null) or
            not(rcd_qv_comments.qvc_tab is null) then           
            
            delete
            from qv_comments
            where qvc_id = rcd_qv_comments.qvc_id
               and qvc_dashboard = rcd_qv_comments.qvc_dashboard
               and qvc_tab = rcd_qv_comments.qvc_tab;
         else
            lics_logging.write_log('Found invalid line - #' || var_trn_count);
         end if;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);      
      var_session number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
         
      /*-*/
      /* Ignore when required
      /*-*/
      if var_trn_error = true then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;
      
      lics_logging.write_log('Completed successfully');      
      lics_logging.end_log;        

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Add the exception to the interface
         /*-*/
         lics_inbound_utility.add_exception(var_exception);        
         lics_logging.end_log;
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;
   
   /***************************************************************/
   /* This procedure performs the calculate removal date function */
   /***************************************************************/   
   function calculate_removal_date(par_valid_period in varchar2) return date is
   
   
      /*-*/
      /* Local types
      /*-*/   
      type csr_date is ref cursor;
      type rcd_date is record (remove_date date);   
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result date := null;      
      
      /*-*/
      /* Dynamic cursor
      /*-*/      
      csr_removal_date csr_date;
      rcd_removal_date rcd_date;
   
   begin
   
      if par_valid_period = 'day' then
         open csr_removal_date for
            select trunc(sysdate+1) as calendar_date
            from dual; 
      elsif par_valid_period = 'week' then
         open csr_removal_date for
            select min(calendar_date) as calendar_date
            from mars_date t01,
              (   
                  select mars_week
                  from mars_date
                  where calendar_date = trunc(sysdate+7)
              ) t02
            where t01.mars_week = t02.mars_week; 
      elsif par_valid_period = 'period' then
         open csr_removal_date for
            select min(calendar_date) as calendar_date
            from mars_date t01
            where t01.mars_period = 
            (
               select mars_period
               from mars_date
               where calendar_date = 
               (
                  select trunc(sysdate) + max(period_day_num) as next_period_date
                  from mars_date t01
                  where t01.mars_period = 
                    (
                       select mars_period
                       from mars_date
                       where calendar_date = trunc(sysdate)
                    )     
               )
            ); 
      elsif par_valid_period = 'year' then
         open csr_removal_date for
            select min(calendar_date)-1 as calendar_date
            from mars_date
            where year_num = 
               (
                  select year_num + 1 as next_year
                  from mars_date
                  where calendar_date = trunc(sysdate)
               );
      else
         return var_result;
      end if;
      
      fetch csr_removal_date into rcd_removal_date;
      
      if csr_removal_date%found then
         var_result := rcd_removal_date.remove_date;
      end if;      
         
      close csr_removal_date;
      
      return var_result;  

   /*-------------*/
   /* End routine */
   /*-------------*/   
   end calculate_removal_date;
   
   /**********************************************************/
   /* This procedure performs the calculate next id function */
   /**********************************************************/      
   function calculate_next_id(par_dashboard in varchar2, par_tab in varchar2) return number is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result number := 1;
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_next_id is
         select nvl(max(qvc_id),0) + 1 as next_id
         from qv_comments
         where qvc_dashboard = par_dashboard
            and qvc_tab = par_tab;
      rcd_next_id csr_next_id%rowtype;     
   
   begin
   
      open csr_next_id;
      
      fetch csr_next_id into rcd_next_id;
      if csr_next_id%found then
         var_result := rcd_next_id.next_id;
      end if;
      
      close csr_next_id;
      
      return var_result;
   
   /*-------------*/
   /* End routine */
   /*-------------*/      
   end calculate_next_id;
   
   /*****************************************************/
   /* This procedure performs the add history procedure */
   /*****************************************************/      
   procedure add_history(par_id in number, par_dashboard in varchar2, par_tab in varchar2) is
   
      /*-*/
      /* Local definitions
      /*-*/   
      rcd_qv_comments_history qv_comments_history%rowtype;
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_qv_comments is
         select qvc_object,
            qvc_date,
            qvc_user,
            qvc_comment
         from qv_comments
         where qvc_id = par_id
            and qvc_dashboard = par_dashboard
            and qvc_tab = par_tab;
      rcd_qv_comments csr_qv_comments%rowtype;        
   
   begin

      rcd_qv_comments_history.qch_dashboard := par_dashboard;
      rcd_qv_comments_history.qch_tab := par_tab;
      rcd_qv_comments_history.qch_date_removed := sysdate;
      rcd_qv_comments_history.qch_removing_user := 'N/A';
      
      open csr_qv_comments;
      fetch csr_qv_comments into rcd_qv_comments;
      
      if csr_qv_comments%notfound then
         raise_application_error(-20000, 'Entry into history table failed - entry not found');
      end if;
      
      rcd_qv_comments_history.qch_object := rcd_qv_comments.qvc_object;
      rcd_qv_comments_history.qch_date_added := rcd_qv_comments.qvc_date;
      rcd_qv_comments_history.qch_adding_user := rcd_qv_comments.qvc_user;
      rcd_qv_comments_history.qch_comment := rcd_qv_comments.qvc_comment;
      
      close csr_qv_comments;
      
      insert into qv_comments_history values rcd_qv_comments_history;
         
   /*-------------*/
   /* End routine */
   /*-------------*/      
   end add_history;

end qv_csvqvs03_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs03_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs03_loader for qv_app.qv_csvqvs03_loader;