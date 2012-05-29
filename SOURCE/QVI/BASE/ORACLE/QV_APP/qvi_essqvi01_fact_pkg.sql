set define off;
/******************************************************************************/
/* Package Header                                                             */
/******************************************************************************/
create or replace package qv_app.qvi_essqvi01_fact_pkg as

   /***************************************************************************/
   /* Package Definition                                                      */
   /***************************************************************************/
   /**
   Package : qvi_essqvi01_fact_pkg
   Owner   : qv_app

   Description
   -----------
   QlikView Interfacing - Package for ESSQVI01 Interface, Essbase Report

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

    5. QlikView is passed the function string, for example, qvi_app.qvi_essqvi01_fact_retriever.get_table('DAS_CODE','FAC_CODE','TIME_CODE')
       that it will substitute in a select * from table(xxxx) statement to retrieve the fact data based on the template_object_type layout.
    
      
    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/05   Mal Chambeyron Customised for Essbase report

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
   -- function final_pass(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_essqvi01_fact_tab pipelined;

   /*-*/
   /* SECTION : FACT RETRIEVER
   /*-*/
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_essqvi01_fact_tab pipelined;
   
end qvi_essqvi01_fact_pkg;
/

/******************************************************************************/
/* Package Body                                                               */
/******************************************************************************/
create or replace package body qv_app.qvi_essqvi01_fact_pkg as
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_ESSQVI01_FACT_PKG';

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

   var_current_year number(4);
   var_year number(4);
   var_period number(2);
   var_currency varchar2(3);

   var_current_rec qvi_essqvi01_fact_obj;
   
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

      var_current_rec := qvi_essqvi01_fact_obj(null,null,null,null,null,null,null);

      var_das_code := 'ESSBASE';
      var_fac_code := 'ACTUAL';
      var_par_code := '-';
      
      var_currency := 'USD';
      
      var_current_year := null;
      var_year := null;
      var_period := null;

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      lics_inbound_utility.set_csv_definition('FILLER-1',1); -- Expect []
      lics_inbound_utility.set_csv_definition('RAW-CYFX',2); -- Expect [CYFX], Current Year Exchange Rate
      lics_inbound_utility.set_csv_definition('RAW-US Dollars',3); -- Expect [US Dollars]
      lics_inbound_utility.set_csv_definition('RAW-Denominator',4); -- Expect [Millions|Thousands]
      lics_inbound_utility.set_csv_definition('Essbase Measure',5); -- Expect [MAT] (Moving Annual Total)
      lics_inbound_utility.set_csv_definition('RAW-Year',6); -- Current Year, Previous Year (eg Yr 2012, Yr 2011)
      lics_inbound_utility.set_csv_definition('Essbase Unit',7); -- Essbase Unit Name
      lics_inbound_utility.set_csv_definition('Essbase Line Item',8); -- Essbase Line Item Name
      lics_inbound_utility.set_csv_definition('RAW-All Products',9); -- Expect [All Products] 
      lics_inbound_utility.set_csv_definition('RAW-Value',10); -- Essbase Value
   
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
      var_rec_header_expected varchar2(4000) := ',, All Brands , Grand Total , All Versions , All Currencies , All Destinations , All Accounts ,,P'; -- 97 Characters Long
      var_rec_type varchar2(20) := null;
      var_rec_data varchar2(256) := null;
      var_tmp varchar2(256) := null;
      var_denominator number(7) := 0;
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
      var_row_data := regexp_replace(par_record,'[[:space:]]*$'); 
      if trim(var_row_data) is null or trim(replace(var_row_data,con_delimiter)) is null then
         return;
      end if;

      /*-*/
      /* Process header record
      /*-*/
      if var_row_no = 1 then
         if substr(var_row_data,1,97) = ',, All Brands , Grand Total , All Versions , All Currencies , All Destinations , All Accounts ,,P' then
            var_statement_tag := 'Process Header record';
            /*-*/
            /* Parse Period header record 
            /*-*/
            var_period := to_number(qvi_util.get_validated_value('Period',substr(var_row_data,98,2),'Number of 1 to 2 digits','^[[:digit:]]{1,2}$',var_src_error));
         else
            raise_application_error(-20000,substr('FATAL ERROR - Invalid Header Record - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
         end if;
         return;
      end if;

      /*-*/
      /* Process the data records ..
      /*-*/
      var_statement_tag := 'Parse the data records';
      lics_inbound_utility.parse_csv_record(var_row_data, con_delimiter, '"');

      var_tmp := qvi_util.get_validated_column('RAW-CYFX','Value - CYFX','^(CYFX){1}$',var_src_error);

      var_tmp := qvi_util.get_validated_column('RAW-US Dollars','Value - US Dollars','^(US Dollars){1}$',var_src_error);
      var_current_rec."Essbase Currency" := var_currency; -- Constant USD

      var_tmp := qvi_util.get_validated_column('RAW-All Products','Value - All Products','^(All Products){1}$',var_src_error);
      
      var_tmp := qvi_util.get_validated_column('RAW-Denominator','Value - Millions | Thousands','^(Millions|Thousands){1}$',var_src_error);
      if var_tmp = 'Millions' then
         var_denominator := 1000000;
      elsif var_tmp = 'Thousands' then
         var_denominator := 1000;
      else
         var_denominator := 0;
      end if;
      
      var_current_rec."Essbase Measure" := qvi_util.get_validated_column('Essbase Measure','Value - MAT','^(MAT){1}$',var_src_error);

      var_current_rec."Essbase Unit" := qvi_util.get_validated_column('Essbase Unit','String of 1 to 64 characters','^[[:print:]]{1,64}$',var_src_error);

      var_current_rec."Essbase Line Item" := qvi_util.get_validated_column('Essbase Line Item','String of 1 to 64 characters','^[[:print:]]{1,64}$',var_src_error);

      var_current_rec."Essbase Value" := to_number(replace(
         qvi_util.get_validated_column('RAW-Value','Number of any percision and scale','^[-]?([[:digit:]]|,)+[[\.]?[[:digit:]]*]?$',var_src_error),',')) * var_denominator;

      var_year := to_number(substr(qvi_util.get_validated_column('RAW-Year','Value - Yr YYYY','^(Yr [[:digit:]]{4})$',var_src_error),4,4));
      if var_current_year is null then
         var_current_year := var_year;
      end if;
      
      if var_current_year = var_year then
         var_current_rec."Essbase Current YYYYPP Flag" := '1';
      else
         var_current_rec."Essbase Current YYYYPP Flag" := null;
      end if;
      
      var_current_rec."Essbase YYYYPP" := var_year * 100 + var_period;

      if var_row_no = 2 then
         if var_src_error = false then
            var_tim_code := to_char(var_current_year, 'FM0000')||to_char(var_period, 'FM00');
            qvi_src_function.start_loader(var_das_code, var_fac_code, var_tim_code, var_par_code);
         else 
            -- lics_inbound_utility.add_exception('Cannot start loader due to source errors');
            raise_application_error(-20000,substr('FATAL ERROR - Cannot start loader due to source errors - ['||var_module_name||']['||var_statement_tag||'] - '||sqlerrm, 1, 4000));
         end if;
      end if;
         
      if var_src_error = false then
         qvi_src_function.append_data(sys.anydata.ConvertObject(var_current_rec));
      end if;
      var_src_error := false;
      
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
      var_data qvi_essqvi01_fact_obj;

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
   function get_table(par_das_code in varchar2, par_fac_code in varchar2, par_tim_code in varchar2) return qvi_essqvi01_fact_tab pipelined is
      /*-*/
      /* Local definitions
      /*-*/
      var_pointer pls_integer;
      var_data qvi_essqvi01_fact_obj;

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
   
end qvi_essqvi01_fact_pkg;
/

/******************************************************************************/
/* Package Synonym/Grants                                                     */
/******************************************************************************/
create or replace public synonym qvi_essqvi01_fact_pkg for qv_app.qvi_essqvi01_fact_pkg;
grant execute on qvi_essqvi01_fact_pkg to lics_app, qv_app, qv_user;

/******************************************************************************/
set define on;
set define ^;

