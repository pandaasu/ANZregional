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
   var_statement_tag varchar2(128) := null;

   con_delimiter constant varchar2(32)  := ',';
   con_regexp_switch constant varchar2(4) := null; -- oracle regexp_like match_parameter
   con_trim_flag constant boolean := true;

   /*-*/
   /* Private definitions
   /*-*/
   var_src_error boolean;

   var_src_first_header boolean;
   var_src_complete_header boolean;
   var_src_plan_flag boolean;
   var_src_filename varchar2(512);
   var_src_file_format varchar2(16);

   var_das_code varchar2(32);
   var_fac_code varchar2(32);
   var_tim_code varchar2(32);
   var_par_code varchar2(32);
   var_current_rec qvi_fppqvi06_src_obj;
   var_year number(4);
   var_period number(2);
   var_rec_no number := 0;

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
      var_statement_tag := null;

      /*-*/
      /* Initialise the package level variables
      /*-*/
      var_src_error := false;

      var_src_complete_header := false;
      var_src_first_header := true;

      var_current_rec := qvi_fppqvi06_src_obj(null,null,null,null,null,null,null,null,null,null,null,null);

      /*-*/
      /* Get source filename, throwing error if not found
      /*-*/
      var_src_filename := upper(lics_inbound_processor.callback_file_name);
      if trim(var_src_filename) is null then
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - Source filename not found');
      end if;
      
      var_das_code := 'FPPS';

      if substr(var_src_filename,1,3)= 'QV_' then
         var_current_rec."Dashboard Unit Code" := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 3);
         var_current_rec."Currency" := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 7);
         var_src_file_format := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 9)||'_'||regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 11);
         var_current_rec."Solve Type" := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 11);
      end if;

      var_fac_code := 'FPPS_'||var_current_rec."Dashboard Unit Code";
      var_par_code :=  substr(substr(var_src_filename,1,instr(var_src_filename,'_',1,6)-1),4);
      
      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      
      if var_src_file_format in ('1_PDITMSRCTOTTOT','1_PDTOTTOTTOTTOT') then
         lics_inbound_utility.set_csv_definition('Line Item Code',1);
         lics_inbound_utility.set_csv_definition('Material Code',2);
         lics_inbound_utility.set_csv_definition('Source Code',3);
         lics_inbound_utility.set_csv_definition('Value',4);
      else
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||'] - Unknown source filename format "'||var_src_file_format||'"');
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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - ' || substr(sqlerrm, 1, 1536));
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
      var_rec varchar2(4000);
      var_rec_type varchar2(20) := null;
      var_rec_data varchar2(256) := null;
      var_period_column_name varchar2(30) := null;

   /*-------------*
   /* Begin block */
   /*-------------*/
   begin
      var_rec_no := var_rec_no + 1;
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_DATA';
      var_statement_tag := null;

      /*-*/
      /* Remove extraneous trailing whitespace (cr/lf/tab/etc..) from record
      /* and return is nothing to process
      /*-*/
      var_rec := regexp_replace(par_record,'[[:space:]]*$',null); -- remove extraneous trailing whitespace (cr/lf/tab/etc..)
      if trim(var_rec) is null or trim(replace(var_rec,con_delimiter,' ')) is null then
         return;
      end if;

      /*-*/
      /* Break out record type and data
      /*-*/
      var_rec_type := rtrim(substr(var_rec,1,20));
      var_rec_data := rtrim(substr(var_rec,21));

      /*-*/
      /* Process Unit record
      /*-*/
      if var_rec_type = 'Unit' then
         var_statement_tag := 'Process Unit record';
         var_current_rec."Unit Code" := qvi_util.get_validated_string(
            'Unit Code',var_rec_data,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;
      end if;

      /*-*/
      /* Process Plan Version record
      /*-*/
      if var_rec_type = 'Plan_Version' then
         var_statement_tag := 'Process Plan Version record';
         var_current_rec."Plan Version" := qvi_util.get_validated_string(
            'Plan Version',var_rec_data,'String of 1 to 64 characters','^[[:print:]]{1,64}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_year := to_number(qvi_util.get_validated_string(
            'Year',substr(var_rec_data,1,4),'Number of 4 digits','^[[:digit:]]{4}$',con_regexp_switch,con_trim_flag,var_src_error));
         return;
      end if;

      /*-*/
      /* Process Destination record
      /*-*/
      if var_rec_type = 'Dest_MOE' then
         var_statement_tag := 'Process Destination record';
         var_current_rec."Dest Code" := qvi_util.get_validated_string(
            'Dest Code',var_rec_data,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;
      end if;

      /*-*/
      /* Process Customer record
      /*-*/
      if var_rec_type = 'Customer' then
         var_statement_tag := 'Process Customer record';
         var_current_rec."Cust Code" := qvi_util.get_validated_string(
            'Cust Code',var_rec_data,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;
      end if;

      /*-*/
      /* Process Period header record
      /*-*/
      if trim(substr(var_rec,1,3)) = ',,,' then
         var_statement_tag := 'Process Period header record';
         /*-*/
         /* Parse Period header record for fpps_actual only .. as fpps_plan has all periods
         /*-*/
         if var_src_file_format in ('1_PDITMSRCTOTTOT','1_PDTOTTOTTOTTOT') then
            var_statement_tag := 'Process Period record';
            var_period := to_number(qvi_util.get_validated_string(
               'Period',substr(var_rec,5,2),'Number of 1 to 2 digits','^[[:digit:]]{1,2}$',con_regexp_switch,con_trim_flag,var_src_error));
         end if;
         /*-*/
         /* Check header is complete
         /*-*/
         var_statement_tag := 'Check header is complete';
         var_src_complete_header := true;
         if var_current_rec."Unit Code" is null then
            lics_inbound_utility.add_exception('Source data is missing the Unit Code');
            var_src_complete_header := false;
         end if;
         if var_current_rec."Plan Version" is null then
            lics_inbound_utility.add_exception('Source data is missing the Plan Version');
            var_src_complete_header := false;
         end if;
         if var_year is null then
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
         if var_period is null then
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
         /* Start the source loader on first header .
         /*-*/
         var_statement_tag := 'Check need to start source loader';
         if var_src_first_header = true then
            var_src_first_header := false;
            if var_src_error = false then
               /*-*/
               /* Time code is year for plan and year/period for actual
               /*-*/
               if var_src_file_format in ('1_PDITMSRCTOTTOT','1_PDTOTTOTTOTTOT') then
                  var_tim_code := to_char(var_year, 'FM0000')||to_char(var_period, 'FM00');
               else -- fpps_plan
                  var_tim_code := var_year;
               end if;
   
               qvi_src_function.start_loader(var_das_code, var_fac_code, var_tim_code, var_par_code);
               
            else 
               lics_inbound_utility.add_exception('Cannot start loader due to source errors');
            end if;
         end if;
         
         return;
      end if;

      /*-*/
      /* Process the data records ..
      /*-*/

      var_statement_tag := 'Parse the data records';
      lics_inbound_utility.parse_csv_record(var_rec, con_delimiter);

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
      var_statement_tag := 'Loop through Periods';
      
      for var_period_iterator in 1..13 loop
         if var_src_file_format in ('1_PDITMSRCTOTTOT','1_PDTOTTOTTOTTOT') then -- single period file formats
            var_period_column_name := 'Value';
         else -- 13 periods
            var_period := var_period_iterator;
            var_period_column_name := 'P'||to_char(var_period,'FM00');
         end if;
         var_current_rec."YYYYPP" := var_year * 100 + var_period;
         
         var_current_rec."Value" := qvi_util.get_validated_string(
            var_period_column_name,'Number of any percision and scale','^[-]?[[:digit:]]+[[\.]?[[:digit:]]*]?$',con_regexp_switch,con_trim_flag,var_src_error);

         /*-*/
         /* Append the source data when required (no errors)
         /*-*/
         if var_src_error = false then
            qvi_src_function.append_data(sys.anydata.ConvertObject(var_current_rec));
         end if;
         
         exit when var_src_file_format in ('1_PDITMSRCTOTTOT','1_PDTOTTOTTOTTOT'); -- single period file formats
      end loop;

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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - ' || substr(sqlerrm, 1, 1536));
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
      var_statement_tag := null;

      /*-*/
      /* Commit/rollback the loader when required
      /*-*/
      if var_src_error = false then
         qvi_src_function.finalise_loader;
         commit;
      else
         rollback;
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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - ' || substr(sqlerrm, 1, 1536));
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

