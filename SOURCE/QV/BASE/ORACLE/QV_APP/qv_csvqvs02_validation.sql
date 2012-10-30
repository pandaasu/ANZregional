create or replace package qv_app.qv_csvqvs02_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs02_validation 
    Owner   : qv_app 
    Author  : Trevor Keon 

    Description 
    ----------- 
    CSV to QV- CSVQVS - NZ KAM Forecast Validation 

    YYYY/MM   Author         Description 
    -------   ------         ----------- 
    2012/08   Trevor Keon    Created 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs02_validation;

create or replace package body qv_app.qv_csvqvs02_validation as

   /*-*/
   /* Private declarations  
   /*-*/
   function check_nz_regroup(par_value in varchar2) return varchar2;

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_header_row constant number := 1;

   /*-*/
   /* Private definitions
   /*-*/
   var_line_count number;

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
      lics_inbound_utility.set_csv_definition('MARS_PERIOD',1);
      lics_inbound_utility.set_csv_definition('MARS_WEEK',2);
      lics_inbound_utility.set_csv_definition('NZ_REGROUP',3);
      lics_inbound_utility.set_csv_definition('FORECAST',4); 
      
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

      /*-*/
      /* Validate the data 
      /*-*/
      if qv_validation_utilities.check_mars_calendar(lics_inbound_utility.get_variable('MARS_PERIOD'), '*PERIOD') = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Mars Period [' || lics_inbound_utility.get_variable('MARS_PERIOD') || '] does not exist';
      end if;
      if qv_validation_utilities.check_mars_calendar(lics_inbound_utility.get_variable('MARS_WEEK'), '*PERIOD_WEEK') = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Mars Week [' || lics_inbound_utility.get_variable('MARS_WEEK') || '] does not exist';
      end if;
      if check_nz_regroup(lics_inbound_utility.get_variable('NZ_REGROUP')) is null then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'NZ Regroup value not set or not found [' || lics_inbound_utility.get_variable('NZ_REGROUP') || ']';
      end if;
      if qv_validation_utilities.check_number(lics_inbound_utility.get_variable('FORECAST')) = false then
         if not(var_message is null) then
            var_message := var_message || '; ';
         end if;
         var_message := var_message || 'Forecast is not a valid number';
      end if;

      /*-*/
      /* Return the message
      /*-*/
      return var_message;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;
   
   function check_nz_regroup(par_value in varchar2) return varchar2 is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result varchar2(100 char);
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_nz_regroup is
        select nkf_regroup_dpg
        from nz_kam_forecast
        where nkf_regroup_dpg = par_value;
      rcd_nz_regroup csr_nz_regroup%rowtype;    
   
   begin
     open csr_nz_regroup;
       fetch csr_nz_regroup into rcd_nz_regroup;
       if csr_nz_regroup%notfound then
         var_result := null;
       else
         var_result := rcd_nz_regroup.nkf_regroup_dpg;
       end if;
     close csr_nz_regroup;
     
     return var_result;    
   end;
   
end qv_csvqvs02_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs02_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs02_validation for qv_app.qv_csvqvs02_validation;