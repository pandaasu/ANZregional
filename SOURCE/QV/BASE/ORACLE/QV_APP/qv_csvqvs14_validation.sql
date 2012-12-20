
  CREATE OR REPLACE PACKAGE "QV_APP"."QV_CSVQVS14_VALIDATION" as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs14_validation
    Owner   : qv_app
    Author  : Jeff Phillipson

    Description
    -----------
    CSV to QV- CSVQVS - Petcare FPPS Values (Actuals and Forecast) Validation

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/05   Jeff Phillipson    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function on_start return varchar2;
   function on_data(par_record in varchar2) return varchar2;

end qv_csvqvs14_validation;


  CREATE OR REPLACE PACKAGE BODY "QV_APP"."QV_CSVQVS14_VALIDATION" as

   /*-*/
   /* Private functions 
   /*-*/
   function validate_mars_week(par_number in number) return number;
   function get_rep_item(par_coles_product in varchar2) return varchar2;
   
   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_unit_delimiter constant varchar2(1 char) := '/';  
   con_interface constant varchar2(10) := 'CSVQVS14';
   /* used to get the cast week from cell A1 */
   con_cast_week constant number := 1;
   con_date_heading constant number := 3;
   
   /*-*/
   /* Private definitions
   /*-*/
   var_line_count number;
   var_cast_week au_coles_forecast.acf_cast_yyyyppw%type;
   var_cast_entry varchar2(100);
   var_rep_item au_coles_forecast.acf_rep_item%type;
   
   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
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
      /* added CAST_WEEK fopr the first cell on the first row */
      lics_inbound_utility.set_csv_definition('CAST_WEEK',1);
      lics_inbound_utility.set_csv_definition('COLES_WAREHOUSE',1);
      lics_inbound_utility.set_csv_definition('COLES_PRODUCT',2);
      
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
      var_field varchar2(10 char);
      var_unit_field varchar2(100 char);
      
      var_line_item fpps_values.fvl_line_item%type;
      var_source fpps_values.fvl_source%type;
      var_customer fpps_values.fvl_customer%type;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the function
      /*-*/
      var_message := null;
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         return var_message;
      end if;
      
      var_line_count := var_line_count + 1;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);
       
      /*-*/
      /* Validate headings are correct mars week
      /*-*/  
      if var_line_count = con_cast_week then
         /* check if the casting week is available to be read */
         var_cast_entry := lics_inbound_utility.get_variable('CAST_WEEK');
         
         if qv_validation_utilities.check_number(var_cast_entry) then
            
            /* if not valid then use processed date */
            if validate_mars_week(var_cast_entry) = 0 then
                var_message := 'Casting week entered in Cell A1 not a valid mars week - "' || to_char(var_cast_entry) || '" Should be in YYYYPPW format';
            end if;
            
         else
            var_message := 'Casting week not found in Cell A1 - value found: "' || to_char(var_cast_entry) || '" Should be in YYYYPPW format';
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
   
   /****************************************************/
   /* This function validates the number as a mars week*/
   /****************************************************/
   function validate_mars_week(par_number in number) return number is
         
      /*-*/
      /* Local definitions
      /*-*/
      var_result number;
         
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_week is
         select count(max(mars_week)) as mars_week 
         from mars_date
         where mars_week = par_number
         group by mars_week;
      rcd_mars_week csr_mars_week%rowtype;   
   
   begin
   
     open csr_mars_week;
       fetch csr_mars_week into rcd_mars_week;
       if csr_mars_week%notfound then
         var_result := '0';
       else
         var_result := rcd_mars_week.mars_week;
       end if;
     close csr_mars_week;
     
     return var_result;
   
   end validate_mars_week;  
   
   /***************************************************/
   /* This function performs the get rep item routine */
   /***************************************************/   
   function get_rep_item(par_coles_product in varchar2) return varchar2 is
   
      /*-*/
      /* Local definitions
      /*-*/
      var_result varchar2(18 char);
      var_coles_code varchar2(18 char);
      
      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_rep_item is
        select acmm_rep_item
        from au_coles_matl_map
        where acmm_coles_code = var_coles_code;
      rcd_rep_item csr_rep_item%rowtype;         
   
   begin
   
     var_coles_code := substr(par_coles_product, 0, instr(par_coles_product, ' ') - 1);
   
     open csr_rep_item;
       fetch csr_rep_item into rcd_rep_item;
       if csr_rep_item%notfound then
         var_result := null;
       else
         var_result := rcd_rep_item.acmm_rep_item;
       end if;
     close csr_rep_item;
     
     return var_result;      
   
   end get_rep_item;   
   
end qv_csvqvs14_validation;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs14_validation to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs14_validation for qv_app.qv_csvqvs14_validation;