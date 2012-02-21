create or replace package qv_app.qv_csvqvs03_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs03_validation
    Owner   : qv_app
    Author  : Trevor Keon

    Description
    -----------
    CSV to QV- CSVQVS - Qlikview dashboard comments

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/10   Trevor Keon    Created
    2011/02   Trevor Keon    Added blank line check
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs03_validation;

create or replace package body qv_app.qv_csvqvs03_validation as

   /*-*/
   /* Private constants 
   /*-*/
   con_interface constant varchar2(10) := 'CSVQVS03';
   con_header_row constant number := 1;
   con_delimiter constant varchar2(32)  := ',';

   /*-*/
   /* Private definitions
   /*-*/
   var_check_user boolean;
   var_valid_user boolean;
   var_line_count number;

   /*-*/
   /* Private declarations
   /*-*/
   function validate_add(par_dashboard in varchar2, par_tab in varchar2, par_comment in varchar2) return boolean;
   function validate_update_remove(par_id in number, par_dashboard in varchar2, par_tab in varchar2) return boolean;   

   function on_start return varchar2 is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);   
   
   /*-------------*/
   /* Begin block */
   /*-------------*/   
   begin
   
      /*-*/
      /* Initialise the variables
      /*-*/   
      var_line_count := 0;
 
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
      
      return var_message;
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   function on_data(par_record in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);
      var_action varchar2(20);
      
      var_dashboard qv_comments.qvc_dashboard%type;
      var_tab qv_comments.qvc_tab%type;
      var_id qv_comments.qvc_id%type;
      var_comment qv_comments.qvc_comment%type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_message := null;
      var_line_count := var_line_count + 1;
       
      /*-*/
      /* Dont need to validate the header row
      /*-*/       
      if var_line_count <= con_header_row then
         return var_message;
      end if;
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         return var_message;
      end if;      
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);
      
      var_action := lics_inbound_utility.get_variable('ACTION');
      var_dashboard := lics_inbound_utility.get_variable('DASHBOARD');
      var_tab := lics_inbound_utility.get_variable('TAB');
      var_comment := lics_inbound_utility.get_variable('COMMENT');
      var_id := lics_inbound_utility.get_variable('ID');
      
      if var_action is null then      
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'No action defined';
      else
         var_action := lower(var_action);
      end if;
      
      /*-*/
      /* Historical entries are ignored - no need to validate
      /*-*/        
      if var_action = 'historical' then
         return var_message;
      end if;

      /*-*/
      /* Validate the data
      /*-*/
      if var_dashboard is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Dashboard name not set';
      end if;
      if var_tab is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Tab name not set';
      end if;    
      if var_comment is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Comment not set';
      end if;         
      
      /*-*/
      /* Validate the integrity of the data
      /*-*/      
      if var_message is null then   
         if var_action = 'add' then
            if validate_add(var_dashboard, var_tab, var_comment) = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'Comment has been added in the past!  Use action "Force" or "Historical"';            
            end if;
         elsif var_action <> 'force' then    
            if qv_validation_utilities.check_number(var_id) = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'ID number must be defined for Update or Remove actions';
            end if;
            if not(var_id is null) and validate_update_remove(var_id, var_dashboard, var_tab) = false then
               if not(var_message is null) then
                  var_message := var_message || '; ';
               end if;
               var_message := var_message || 'Comment not found for update or remove action.  Confirm ID number - ' || var_id;            
            end if;
         end if;
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;
   
   /***************************************************/
   /* This function performs the validate add routine */
   /***************************************************/   
   function validate_add(par_dashboard in varchar2, par_tab in varchar2, par_comment in varchar2) return boolean is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validate is
         select 'x'
         from qv_comments_history
         where qch_dashboard = par_dashboard
            and qch_tab = par_tab
            and qch_comment = par_comment;
      rcd_validate csr_validate%rowtype;   
   
   begin
   
      open csr_validate;
      fetch csr_validate into rcd_validate;
      
      var_result := csr_validate%notfound;
      
      close csr_validate;
      
      return var_result;
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end validate_add;
   
   /*****************************************************************/
   /* This function performs the validate update and remove routine */
   /*****************************************************************/     
   function validate_update_remove(par_id in number, par_dashboard in varchar2, par_tab in varchar2) return boolean is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result boolean := true;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_validate is
         select 'x'
         from qv_comments
         where qvc_dashboard = par_dashboard
            and qvc_tab = par_tab
            and qvc_id = par_id;
      rcd_validate csr_validate%rowtype;   
   
   begin
   
      open csr_validate;
      fetch csr_validate into rcd_validate;
      
      var_result := csr_validate%found;
      
      close csr_validate;
      
      return var_result;
   
   /*-------------*/
   /* End routine */
   /*-------------*/   
   end validate_update_remove;
   
end qv_csvqvs03_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs03_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs03_validation for qv_app.qv_csvqvs03_validation;