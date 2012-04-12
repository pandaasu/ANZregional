set define off;
/******************************************************************************/
/* Package Header                                                             */
/******************************************************************************/
create or replace package qv_app.qvi_fppqvi06_fact_pkg as

   /***************************************************************************/
   /* Package Definition                                                      */
   /***************************************************************************/
   /**
   Package : qvi_fppqvi06_fact_pkg
   Owner   : qv_app

   Description
   -----------
   QlikView Interfacing - Package for FPPQVI06 Interface, FPPS Actuals

   Source loader **NOTES**

   1. A source loader package is required for each fact part.

   2. A unique template_object_type is required for each fact part that 
      describes the data layout.

   3. The source loader package procedure are invoked directly from the ICS 
      inbound processor.

   4. Commit and rollback should be executed at the appropriate places in code.

   5. Any untrapped exceptions will cause the load processing to abort in the 
      ICS inbound processor and the database will be rolled back.
      
    Fact builder **NOTES**

    1. A fact builder package is required for each fact definition.

    2. A unique template_object_type is required for each fact part that describes the data layout.

    3. The source loader package procedure are invoked directly from the ICS inbound processor.

    4. Commit and rollback should be executed at the appropriate places in code.

    5. Any untrapped exceptions will cause the load processing to abort in the ICS inbound processor
       and the database will be rolled back.
      
    Fact retriever **NOTES**

    1. A fact retrieval pipelined table function is required for each fact definition.

    2. A unique template_object_type is required for each fact that describes the data layout.

    3. A unique template_table_type is required for each fact that encapsulates the template_object_type as a table.

    4. Replacing the template_table_type and template_object_type names and comments are the only required code changes.

    5. QlikView is passed the function string, for example, qvi_app.qvi_fppqvi06_fact_retriever.get_table('DAS_CODE','FAC_CODE','TIME_CODE')
       that it will substitute in a select * from table(xxxx) statement to retrieve the fact data based on the template_object_type layout.
    
      
    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created

   ****************************************************************************/

   /*-*/
   /* SECTION : SOURCE LOADER
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

   /*-*/
   /* SECTION : FACT BUILDER
   /*-*/
   procedure build_fact(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2);
   -- function final_pass(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_fppqvi06_fact_tab pipelined;

   /*-*/
   /* SECTION : FACT RETRIEVER
   /*-*/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_fppqvi06_fact_tab pipelined;
   
end qvi_fppqvi06_fact_pkg;
/

/******************************************************************************/
/* Package Body                                                               */
/******************************************************************************/
create or replace package body qv_app.qvi_fppqvi06_fact_pkg as
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_FPPQVI06_FACT_PKG';

   con_delimiter constant varchar2(32)  := ',';

   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   var_src_error boolean;
   var_row_no number;

   var_src_filename varchar2(512);
   var_src_file_format varchar2(16);
   var_src_file_format_id varchar2(16);
   var_src_plan_flag boolean;

   var_src_first_header boolean;
   var_src_header_complete_flag boolean;

   var_das_code varchar2(32);
   var_fac_code varchar2(32);
   var_tim_code varchar2(32);
   var_par_code varchar2(32);

   var_year number(4);
   var_period number(2);

   var_current_rec qvi_fppqvi06_fact_obj;
   
   /* ======================================================================= */
   /* SECTION : SOURCE LOADER                                                 */
   /* ======================================================================= */

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is
   
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting 
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_START';
      var_statement_tag := null;

      /*-*/
      /* Initialise the package level variables
      /*-*/
      var_row_no := 0;
      var_src_error := false;

      var_src_header_complete_flag := false;
      var_src_first_header := true;

      var_current_rec := qvi_fppqvi06_fact_obj(null,null,null,null,null,null,null,null,null,null,null,null);

      /*-*/
      /* Get source filename, throwing error if not found
      /*-*/
      var_src_filename := upper(lics_inbound_processor.callback_file_name);
      if trim(var_src_filename) is null then
         raise_application_error(-20000,'FATAL ERROR - ['||var_module_name||'] - Source filename not found');
      end if;
      
      /*-*/
      /* Parse encoded values from filename
      /*-*/
      if substr(var_src_filename,1,4)= 'QVI_' then
         var_current_rec."Dashboard Unit Code" := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 3);
         var_current_rec."Currency" := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 7);
         var_src_file_format_id := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 9);
         var_current_rec."Solve Type" := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 11);
         var_src_file_format := regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 9)||'_'||regexp_substr(var_src_filename, '[[:alnum:]]*', 1, 11);
      end if;
      
      if var_current_rec."Dashboard Unit Code" is null
         or var_current_rec."Currency" is null
         or var_src_file_format is null
         or var_current_rec."Solve Type" is null then
         raise_application_error(-20000,'FATAL ERROR - ['||var_module_name||'] - Source filename unknown "'||var_src_file_format||'"');
      end if;  

      var_das_code := 'FPPS';
      var_par_code :=  substr(substr(var_src_filename,1,instr(var_src_filename,'_',1,6)-1),5);
      
      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      
      if var_src_file_format_id = '1' then -- actual format 1
         var_fac_code := 'ACTUAL_'||var_current_rec."Dashboard Unit Code";
         lics_inbound_utility.set_csv_definition('Line Item Code',1);
         lics_inbound_utility.set_csv_definition('Material Code',2);
         lics_inbound_utility.set_csv_definition('Source Code',3);
         lics_inbound_utility.set_csv_definition('Value',4);
      elsif var_src_file_format_id = '4' then -- plan format 4
         var_fac_code := 'PLAN_'||var_current_rec."Dashboard Unit Code";
         lics_inbound_utility.set_csv_definition('Line Item Code',1);
         lics_inbound_utility.set_csv_definition('Material Code',2);
         lics_inbound_utility.set_csv_definition('Source Code',3);
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
      elsif var_src_file_format_id = '5' then -- actual format 5
         var_fac_code := 'ACTUAL_'||var_current_rec."Dashboard Unit Code";
         lics_inbound_utility.set_csv_definition('Line Item Code',1);
         lics_inbound_utility.set_csv_definition('Material Code',2);
         lics_inbound_utility.set_csv_definition('Source Code',3);
         lics_inbound_utility.set_csv_definition('Dest Code',4);
         lics_inbound_utility.set_csv_definition('Value',5);
      else
         raise_application_error(-20000,'FATAL ERROR - ['||var_module_name||'] - Unknown source filename format "'||var_src_file_format||'"');
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
         raise_application_error(-20000,substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
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
      var_row_data varchar2(4000);
      var_rec_header_expected varchar2(4000);
      var_rec_type varchar2(20) := null;
      var_rec_data varchar2(256) := null;
      var_period_column_name varchar2(30) := null;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Keep track of row number
      /*-*/
      var_row_no := var_row_no + 1;
      
      /*-*/
      /* Fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_DATA';
      var_statement_tag := null;

      /*-*/
      /* Remove extraneous trailing whitespace (cr/lf/tab/etc..) from row and
      /* return if empty row
      /*-*/
      var_row_data := regexp_replace(par_record,'[[:space:]]*$',null); 
      if trim(var_row_data) is null or trim(replace(var_row_data,con_delimiter,' ')) is null then
         return;
      end if;

      /*-*/
      /* Break out record type and data
      /*-*/
      var_rec_type := rtrim(substr(var_row_data,1,20));
      var_rec_data := rtrim(substr(var_row_data,21));

      /*-*/
      /* Process Unit record
      /*-*/
      if var_rec_type = 'Unit' then
         var_statement_tag := 'Process Unit record';
         var_current_rec."Unit Code" := qvi_util.get_validated_value(
            'Unit Code',var_rec_data,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
         return;
      end if;

      /*-*/
      /* Process Plan Version record
      /*-*/
      if var_rec_type = 'Plan_Version' then
         var_statement_tag := 'Process Plan Version record';
         var_current_rec."Plan Version" := qvi_util.get_validated_value(
            'Plan Version',var_rec_data,'String of 1 to 64 characters','^[[:print:]]{1,64}$',var_src_error);
         var_year := to_number(qvi_util.get_validated_value(
            'Year',substr(var_rec_data,1,4),'Number of 4 digits','^[[:digit:]]{4}$',var_src_error));
         return;
      end if;

      /*-*/
      /* Process Destination record
      /*-*/
      if var_rec_type = 'Dest_MOE' then
         var_statement_tag := 'Process Destination record';
         var_current_rec."Dest Code" := qvi_util.get_validated_value(
            'Dest Code',var_rec_data,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
         return;
      end if;

      /*-*/
      /* Process Customer record
      /*-*/
      if var_rec_type = 'Customer' then
         var_statement_tag := 'Process Customer record';
         var_current_rec."Cust Code" := qvi_util.get_validated_value(
            'Cust Code',var_rec_data,'Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
         return;
      end if;

      /*-*/
      /* Process Period header record
      /*-*/
      if trim(substr(var_row_data,1,3)) = ',,,' then
         var_statement_tag := 'Process Period header record';
         /*-*/
         /* Parse Period header record for fpps_actual only .. as fpps_plan has all periods
         /*-*/
         var_statement_tag := 'Process Period record';
         if var_src_file_format_id in ('1','5') then -- actual formats 1,5 report on a single period
            var_period := to_number(qvi_util.get_validated_value(
               'Period',substr(replace(var_row_data,','),2,2),'Number of 1 to 2 digits','^[[:digit:]]{1,2}$',var_src_error));
         elsif var_src_file_format_id = '4' then -- plan format 4 reports on an entire year
            var_period := null;
            var_rec_header_expected := ',,,P01,P02,P03,P04,P05,P06,P07,P08,P09,P10,P11,P12,P13';
            if trim(substr(var_row_data,1,length(trim(var_rec_header_expected)))) != var_rec_header_expected then
               lics_inbound_utility.add_exception('Header record "'||var_row_data||'" not recognised, expected "'||var_rec_header_expected||'".');
               var_src_header_complete_flag := false;
            end if;
         end if;
         /*-*/
         /* Check header is complete
         /*-*/
         var_statement_tag := 'Check header is complete';
         var_src_header_complete_flag := true;
         if var_current_rec."Unit Code" is null then
            lics_inbound_utility.add_exception('Source data is missing the Unit Code');
            var_src_header_complete_flag := false;
         end if;
         if var_current_rec."Plan Version" is null then
            lics_inbound_utility.add_exception('Source data is missing the Plan Version');
            var_src_header_complete_flag := false;
         end if;
         if var_year is null then
            lics_inbound_utility.add_exception('Source data is missing the Plan Year');
            var_src_header_complete_flag := false;
         end if;
         if var_src_file_format_id != '5' and var_current_rec."Dest Code" is null then -- format 5, destination in the data, not the header
            lics_inbound_utility.add_exception('Source data is missing the Destination Code');
            var_src_header_complete_flag := false;
         end if;
         if var_current_rec."Cust Code" is null then
            lics_inbound_utility.add_exception('Source data is missing the Customer Code');
            var_src_header_complete_flag := false;
         end if;
         if var_src_file_format_id != '4' and var_period is null then -- format 4, is by year
            lics_inbound_utility.add_exception('Source data is missing the Period');
            var_src_header_complete_flag := false;
         end if;
         if var_current_rec."Currency" is null then
            lics_inbound_utility.add_exception('Currency not set');
            var_src_header_complete_flag := false;
         end if;
         if var_src_header_complete_flag = false then
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
               if var_src_file_format_id in ('1','5') then -- format 1,5 by period
                  var_tim_code := to_char(var_year, 'FM0000')||to_char(var_period, 'FM00');
               elsif var_src_file_format_id = '4' then -- format 4 by year
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
      lics_inbound_utility.parse_csv_record(var_row_data, con_delimiter);

      var_current_rec."Line Item Code" := qvi_util.get_validated_column(
         'Line Item Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
      var_current_rec."Material Code" := qvi_util.get_validated_column(
         'Material Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
      var_current_rec."Source Code" := qvi_util.get_validated_column(
         'Source Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
         
      if var_src_file_format_id = '5' then -- format 5, destination in the data
         var_current_rec."Dest Code" := qvi_util.get_validated_column(
            'Dest Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
      end if;
      /*-*/
      /* Loop through Periods for plan .. Exit after one period on actual
      /*-*/
      var_period_column_name := null;
      var_statement_tag := 'Loop through Periods';
      
      for var_period_iterator in 1..13 loop
         if var_src_file_format_id in ('1','5') then -- format 1,5 single period
            var_period_column_name := 'Value';
         elsif var_src_file_format_id = '4' then -- format 4 year (13 periods)
            var_period := var_period_iterator;
            var_period_column_name := 'P'||to_char(var_period,'FM00');
         end if;
         var_current_rec."YYYYPP" := var_year * 100 + var_period;
         
         var_current_rec."Value" := qvi_util.get_validated_column(
            var_period_column_name,'Number of any percision and scale','^[-]?[[:digit:]]+[[\.]?[[:digit:]]*]?$',var_src_error);

         /*-*/
         /* Append the source data when required (no errors)
         /*-*/
         if var_src_error = false then
            qvi_src_function.append_data(sys.anydata.ConvertObject(var_current_rec));
         end if;
         
         exit when var_src_file_format_id in ('1','5'); -- format 1,5 single period
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
         raise_application_error(-20000,substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
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
         raise_application_error(-20000,substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /* ======================================================================= */
   /* SECTION : FACT BUILDER                                                  */
   /* ======================================================================= */
   
   /*********************************************************************/
   /* This procedure performs the build fact build_fact routine         */
   /* CUSTOMISE : var_data type, update var_module_name and create obj  */
   /*********************************************************************/
   procedure build_fact(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) is
      /*-*/
      /* Local definitions
      /*-*/
      var_data qvi_fppqvi06_fact_obj;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.BUILD_FACT';
      var_statement_tag := null;

      /*-*/
      /* Create the fact loader
      /*-*/
      qvi_fac_function.start_loader(par_das_code, par_fac_code, par_tim_code);

      /*-*
      /* Would normally copy data from source to fact table here .. however 
      /* bypassing for effiency, as data is the same format.
      /*-*
      
      /*-*/
      /* Finalise the fact loader
      /*-*/
      qvi_fac_function.finalise_loader;

      /*-*/
      /* Commit the database
      /*-*/
      commit;
      return;
   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Rollback and raise exception to the calling application
         /*-*/
         rollback;
         raise_application_error(-20000,substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end build_fact;

   /* ======================================================================= */
   /* SECTION : FACT RETRIEVER                                                */
   /* ======================================================================= */

   /*********************************************************************/
   /* This procedure performs the get fact table routine                */
   /* CUSTOMISE : return_type, var_data type and update var_module_name */
   /*********************************************************************/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_fppqvi06_fact_tab pipelined is
      /*-*/
      /* Local definitions
      /*-*/
      var_pointer pls_integer;
      var_data qvi_fppqvi06_fact_obj;

      /*-*/
      /* Local cursors .. *** getting fact data from source data table *** 
      /*-*/
      cursor csr_fact_table is
         select t01.*
           from table(qvi_src_function.get_tables(par_das_code, par_fac_code, par_tim_code, '*ALL')) t01;
      rcd_fact_table csr_fact_table%rowtype;
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.GET_TABLE';
      var_statement_tag := null;

      /*------------------------------------------------*/
      /* NOTE - This procedure must not commit/rollback */
      /*------------------------------------------------*/

      /*-*/
      /* Retrieve the fact data from the QVI_FAC_FUNCTION.GET_TABLE pipelined table function
      /* **notes**
      /* 1. The QVI_FAC_FUNCTION.GET_TABLE function returns a table of QVI_FAC_OBJECT type rows
      /* 2. The QVI_FAC_OBJECT type contains the fact data in column DAT_DATA as SYS.ANYDATA
      /* 3. The column DAT_DATA is cast to the TEMPLATE_OBJECT_TYPE using SYS.ANYDATA.GET_OBJECT
      /* 4. The TEMPLATE_OBJECT_TYPE is piped to the consumer
      /* 5. An Exception will be raised when DAT_DATA is unable to be cast to TEMPLATE_OBJECT_TYPE
      /*-*/
      open csr_fact_table;
      loop
         fetch csr_fact_table into rcd_fact_table;
         if csr_fact_table%notfound then
            exit;
         end if;
         var_pointer := rcd_fact_table.dat_data.GetObject(var_data);
         pipe row(var_data);
      end loop;
      close csr_fact_table;

      /*-*/
      /* Return
      /*-*/
      return;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception
      /*-*/
      /* Exception trap
      /*-*/
      when others then
         /*-*/
         /* Raise exception to the calling application
         /*-*/
         raise_application_error(-20000,substr('FATAL ERROR - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_table;
   
end qvi_fppqvi06_fact_pkg;
/

/******************************************************************************/
/* Package Synonym/Grants                                                     */
/******************************************************************************/
create or replace public synonym qvi_fppqvi06_fact_pkg for qv_app.qvi_fppqvi06_fact_pkg;
grant execute on qvi_fppqvi06_fact_pkg to lics_app, qv_app, qv_user;

/******************************************************************************/
set define on;
set define ^;

