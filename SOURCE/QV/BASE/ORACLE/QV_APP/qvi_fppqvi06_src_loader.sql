set define off;
/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fppqvi06_src_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fppqvi06_src_loader
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Source Loader Template

    This package contain the source loader template.

    **NOTES**

    1. A source loader package is required for each fact part.

    2. A unique template_object_type is required for each fact part that describes the data layout.

    3. The source loader package procedure are invoked directly from the ICS inbound processor.

    4. Commit and rollback should be executed at the appropriate places in code.

    5. Any untrapped exceptions will cause the load processing to abort in the ICS inbound processor
       and the database will be rolled back.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qvi_fppqvi06_src_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fppqvi06_src_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_FPPQVI06_SRC_LOADER';
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Module name is fully qualified schema.package.module used for error reporting
   
   con_delimiter constant varchar2(32)  := ',';
   con_regexp_switch constant varchar2(4) := null; -- oracle regexp_like match_parameter
   con_trim_flag constant boolean := true;

   /*-*/
   /* Private definitions
   /*-*/   
   var_src_created boolean;
   var_src_error boolean;
   
   var_src_first_header boolean;
   var_src_complete_header boolean;

   var_src_filename varchar2(256);

   var_das_code varchar2(32);
   var_fac_code varchar2(32);
   var_tim_code varchar2(32);
   var_par_code varchar2(32);
   var_currency_code varchar2(3);
   var_current_rec qvi_fppqvi06_src_obj;
   var_previous_rec qvi_fppqvi06_src_obj;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_START';

      /*-*/
      /* Initialise the package level variables
      /*-*/
      var_src_created := false;
      var_src_error := false;
      
      var_src_complete_header := false;
      var_src_first_header := true;

      var_current_rec := qvi_fppqvi06_src_obj(null,null,null,null,null,null,null,null,null,null,null);
      var_previous_rec := qvi_fppqvi06_src_obj(null,null,null,null,null,null,null,null,null,null,null);
      
      /*-*/
      /* Get source filename, throwing error if not found
      /*-*/
      var_src_filename := lics_inbound_processor.callback_file_name;
      if trim(var_src_filename) is null then
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - Source filename not found');
      end if;
      
      var_das_code := 'fpps_anz_pet';
      if regexp_like(var_src_filename, '^plan.csv$') then
         var_fac_code := 'fpps_plan';
         var_current_rec."Period" := -1; -- will be set in parsing for loop
      elsif regexp_like(var_src_filename, '^actual.csv$') then
         var_fac_code := 'fpps_actual';
      else
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - Unknown source filename "'||var_src_filename||'"');
      end if;
      
      var_currency_code := 'USD';
      var_current_rec."Currency" := var_currency_code;

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      lics_inbound_utility.set_csv_definition('Line Item Code',1);
      lics_inbound_utility.set_csv_definition('Material Code',2);
      lics_inbound_utility.set_csv_definition('Source Code',3);
      if var_fac_code = 'fpps_plan' then 
         lics_inbound_utility.set_csv_definition('P01',4);
         lics_inbound_utility.set_csv_definition('P02',5);
         lics_inbound_utility.set_csv_definition('P03',6);
         lics_inbound_utility.set_csv_definition('P04',7);
         lics_inbound_utility.set_csv_definition('P05',8);
         lics_inbound_utility.set_csv_definition('P06',9);
         lics_inbound_utility.set_csv_definition('P07',10);
         lics_inbound_utility.set_csv_definition('P08',11);
         lics_inbound_utility.set_csv_definition('P09',12);
         lics_inbound_utility.set_csv_definition('P10',13);
         lics_inbound_utility.set_csv_definition('P11',14);
         lics_inbound_utility.set_csv_definition('P12',15);
         lics_inbound_utility.set_csv_definition('P13',16);
      else -- fpps_actual
         lics_inbound_utility.set_csv_definition('Value',4);
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - ' || substr(sqlerrm, 1, 1536));
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
      var_record varchar2(4000);
      var_header_row_tag varchar2(20) := null;
      var_header_row_value varchar2(256) := null;
      var_period_column_name varchar2(30) := null;

   /*-------------*
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_DATA';
   
      var_record := regexp_replace(par_record,'[[:space:]]*$',null); -- remove extraneous trailing whitespace (cr/lf/tab/etc..)

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      /*-*/
      /* Empty rows
      /*-*/
      if trim(var_record) is null or trim(replace(var_record,con_delimiter,' ')) is null then
         return;
      end if;

      /*---------------------------*/
      /* STRIP - Strip header data */
      /*---------------------------*/
      var_header_row_tag := rtrim(substr(var_record,1,20));
      var_header_row_value := rtrim(substr(var_record,21));

      /*-*/
      /* Parse Unit record
      /*-*/
      if var_header_row_tag = 'Unit' then
         var_current_rec."Unit Code" := qvi_util.get_validated_string(
            'Unit Code',var_header_row_value,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;

      /*-*/
      /* Parse Plan_Version record
      /*-*/
      elsif var_header_row_tag = 'Plan_Version' then
         var_current_rec."Plan Version" := qvi_util.get_validated_string(
            'Plan Version',var_header_row_value,'String of 1 to 64 characters','^[[:print:]|[:space:]]{1,64}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_current_rec."Year" := to_number(qvi_util.get_validated_string(
            'Year',substr(var_header_row_value,1,4),'Number of 4 digits','^[[:digit:]]{4}$',con_regexp_switch,con_trim_flag,var_src_error));
         return;

      /*-*/
      /* Parse Dest record
      /*-*/
      elsif var_header_row_tag = 'Dest_MOE' then
         var_current_rec."Dest Code" := qvi_util.get_validated_string(
            'Dest Code',var_header_row_value,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;

      /*-*/
      /* Parse Customer record
      /*-*/
      elsif var_header_row_tag = 'Customer' then
         var_current_rec."Cust Code" := qvi_util.get_validated_string(
            'Cust Code',var_header_row_value,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;

      /*-*/
      /* Parse Period header record
      /*-*/
      elsif trim(substr(var_record,1,3)) = ',,,' then
         /*-*/
         /* Parse Period header record for fpps_actual only .. as fpps_plan has all periods
         /*-*/
         if var_fac_code = 'fpps_actual' then
            var_current_rec."Period" := to_number(qvi_util.get_validated_string(
               'Period',substr(var_record,5,2),'Number of 1 to 2 digits','^[[:digit:]]{1,2}$',con_regexp_switch,con_trim_flag,var_src_error));
         end if;
         /*-*/
         /* Check header is complete
         /*-*/
         var_src_complete_header := true;
         if var_current_rec."Unit Code" is null then
            lics_inbound_utility.add_exception('Source data is missing the Unit Code');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Plan Version" is null then
            lics_inbound_utility.add_exception('Source data is missing the Plan Version');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Year" is null then
            lics_inbound_utility.add_exception('Source data is missing the Plan Year');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Dest Code" is null then
            lics_inbound_utility.add_exception('Source data is missing the Destination Code');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Cust Code" is null then
            lics_inbound_utility.add_exception('Source data is missing the Customer Code');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Period" is null then
            lics_inbound_utility.add_exception('Source data is missing the Period');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Currency" is null then
            lics_inbound_utility.add_exception('Currency not set');
            var_src_complete_header := false;
         end if;
         if var_src_complete_header = false then
            var_src_error := true;
         end if;

         /*-*/
         /* Start the source loader on first header .. or on change of Unit Code, Year
         /*-*/
         if (var_src_first_header = true
            or NVL(var_current_rec."Unit Code", '*NULL') != NVL(var_previous_rec."Unit Code", '*NULL')
            or NVL(var_current_rec."Year", '*NULL') != NVL(var_previous_rec."Year", '*NULL'))
            and
            (var_fac_code = 'fpps_plan'
            or (var_fac_code = 'fpps_actual' and NVL(var_current_rec."Period", '*NULL') != NVL(var_previous_rec."Period", '*NULL'))) then

            if var_src_first_header = true then
               var_src_first_header := false;
            else
               /*-*/
               /* Commit/rollback the header when required
               /*-*/
               if var_src_created = true then
                  if var_src_error = false then
                     qvi_src_function.finalise_loader;
                     var_src_created := false;
                     commit;
                  else
                     rollback;
                  end if;
               end if;
            end if;
            
            /*-*/
            /* Time code is year for plan and year/period for actual
            /*-*/
            if var_fac_code = 'fpps_plan' then
               var_tim_code := var_current_rec."Year";
            else -- fpps_actual
               var_tim_code := var_current_rec."Year"||to_char(var_current_rec."Period", 'FM00');
            end if;
            
            if var_src_created = false then
               qvi_src_function.start_loader(var_das_code, var_fac_code, var_tim_code, var_current_rec."Unit Code"||'-'||lower(var_currency_code));
               var_src_created := true;
               var_src_error := false;
            else
               lics_inbound_utility.add_exception('Previous source has not been finalised');
               var_src_error := true;
            end if;

            /*-*/
            /* Take copy of key header values .. used to determine part (split)
            /*-*/
            var_previous_rec."Unit Code" := var_current_rec."Unit Code";
            var_previous_rec."Year" := var_current_rec."Year";
            var_previous_rec."Period" := var_current_rec."Period";
         end if;

         return;
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      else
      
         /*-*/
         /* Source header must have been created when a detail row
         /*-*/
         if var_src_created = false then
            var_src_error := true;
         end if;

         /*-*/
         /* Parse the input data record
         /*-*/
         lics_inbound_utility.parse_csv_record(var_record, con_delimiter);
         
         var_current_rec."Line Item Code" := qvi_util.get_validated_string(
            'Line Item Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_current_rec."Material Code" := qvi_util.get_validated_string(
            'Material Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_current_rec."Source Code" := qvi_util.get_validated_string(
            'Source Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
            
         /*-*/
         /* Loop through Periods for plan .. Exit after one period on actual
         /*-*/
         var_period_column_name := null;
         for var_period in 1..13 loop
            if var_fac_code = 'fpps_plan' then
               var_current_rec."Period" := var_period;
               var_period_column_name := 'P'||to_char(var_period,'FM00'); 
            else -- fpps_actual
--               null; -- period already set as part of processing
               var_period_column_name := 'Value'; 
            end if;

            var_current_rec."Value" := to_number(qvi_util.get_validated_string(
               var_period_column_name,'Number of up to percision 15, scale 5','^[-]?[[:digit:]]{1,10}[[\.]?[[:digit:]]{0,5}]?$',con_regexp_switch,con_trim_flag,var_src_error), '9999999999.00000');
   
            /*-*/
            /* Append the source data when required (no errors)
            /*-*/
            if var_src_error = false then
               qvi_src_function.append_data(sys.anydata.ConvertObject(var_current_rec));
            end if;
 
            -- exit when var_fac_code = 'fpps_actual'; 
            exit when var_period = 1; 
         end loop;
            
         /*-*/
         /* Exit the procedure
         /*-*/

      end if;
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
   procedure on_end is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_END';

      /*-*/
      /* Commit/rollback the loader when required
      /*-*/
      if var_src_created = true then
         if var_src_error = false then
            qvi_src_function.finalise_loader;
            commit;
         else
            rollback;
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
         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end qvi_fppqvi06_src_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_fppqvi06_src_loader for qv_app.qvi_fppqvi06_src_loader;
grant execute on qvi_fppqvi06_src_loader to lics_app;

set define on;
set define ^;

