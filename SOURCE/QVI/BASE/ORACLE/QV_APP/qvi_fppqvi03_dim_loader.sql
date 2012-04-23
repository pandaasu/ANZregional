/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fppqvi03_dim_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fppqvi03_dim_loader
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Line Item

    This package contain the Line Item dimension loader functions.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2012/03   Steve Gregan   Created
    2012/03   Mal Chambeyron Created loader from templace

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qvi_fppqvi03_dim_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fppqvi03_dim_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_schema_name constant varchar2(30) := 'QV_APP';
   con_package_name constant varchar2(30) := 'QVI_FPPQVI03_DIM_LOADER';
   
   con_delimiter constant varchar2(32)  := ',';

   /*-*/
   /* Private definitions
   /*-*/
   var_module_name varchar2(128) := trim(con_schema_name)||'.'||trim(con_package_name)||'.*PACKAGE'; -- Module name is fully qualified schema.package.module used for error reporting
   var_statement_tag varchar2(128) := null;

   var_src_first_rec boolean := true;
   var_src_header_verified boolean := false;
   var_src_error boolean;

   type array_dim_type is table of qvi_fppqvi03_dim_obj index by binary_integer;
   var_array_dim array_dim_type;

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
      var_src_first_rec := true;
      var_src_error := false;
      var_array_dim.delete;

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('Line Item Code',1);
      lics_inbound_utility.set_csv_definition('Line Item Owner',2);
      lics_inbound_utility.set_csv_definition('Line Item User Owner',3);
      lics_inbound_utility.set_csv_definition('Line Item Classification',4);
      lics_inbound_utility.set_csv_definition('Line Item Short',5);
      lics_inbound_utility.set_csv_definition('Line Item',6);
      lics_inbound_utility.set_csv_definition('Line Item Sign Flag',7);
      lics_inbound_utility.set_csv_definition('Line Item Financial Unit',8);
      
      /*-*/
      /* Start the dimension loader
      /*-*/
      qvi_dim_function.start_loader('FPPS_LINE_ITEM');

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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||nvl(var_statement_tag,'')||'] - ' || substr(sqlerrm, 1, 1536));
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
      var_rec_header_expected varchar2(4000);
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      /*-*/
      /* Module name is fully qualified schema.package.module used for error reporting
      /*-*/
      var_module_name := trim(con_schema_name)||'.'||trim(con_package_name)||'.ON_DATA';
      var_statement_tag := null;

      /*-*/
      /* Remove extraneous trailing whitespace (cr/lf/tab/etc..) from record
      /* and return if nothing to process
      /*-*/
      var_rec := regexp_replace(par_record,'[[:space:]]*$',null);
      if trim(var_rec) is null or trim(replace(var_rec,con_delimiter,' ')) is null then
         return;
      end if;

      /*-*/
      /* Check header record is as expected
      /*-*/
      if var_src_first_rec = true then
         var_src_first_rec := false;
         var_rec_header_expected := 'Line Item ID,Line Item Owner,Line Item Usage Owner,Line Item Classification,Line Item Short Description,Line Item Long Description,Sign Convention,Financial Unit,Std Ref Indicator,Aggregate Data,Ignore MAA/MAT/YT D/YEE/YTG,Usage,Calculation,Force Calc,Disable Allocation';
         if trim(substr(var_rec,1,length(trim(var_rec_header_expected)))) = var_rec_header_expected then
            var_src_header_verified := true;
         else
            var_src_header_verified := false;
            lics_inbound_utility.add_exception('Header record "'||var_rec||'" not recognised, expected "'||var_rec_header_expected||'".');
            var_src_error := true;
         end if;
         return;
      end if;
      
      /*-*/
      /* Process data records 
      /*-*/
      if var_src_header_verified = true then
         /*-*/
         /* Parse the input data record
         /*-*/
         lics_inbound_utility.parse_csv_record(var_rec, con_delimiter, '"');
   
         /*-*/
         /* Create object
         /*-*/         
         var_array_dim(var_array_dim.count+1) := qvi_fppqvi03_dim_obj(null,null,null,null,null,null,null,null);
         
         /*-*/
         /* Load the source data into the array
         /*-*/
         var_array_dim(var_array_dim.count)."Line Item Code" := qvi_util.get_validated_column(
            'Line Item Code','Alphanumeric of 1 to 18 characters','^[[:alnum:]]{1,18}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item Owner" := qvi_util.get_validated_column(
            'Line Item Owner','String of 1 to 32 characters','^.{1,32}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item User Owner" := qvi_util.get_validated_column(
            'Line Item User Owner','String of 1 to 32 characters','^.{1,32}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item Classification" := qvi_util.get_validated_column(
            'Line Item Classification','String of 1 to 128 characters','^.{1,128}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item Short" := qvi_util.get_validated_column(
            'Line Item Short','String of 1 to 16 characters','^.{1,16}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item" := qvi_util.get_validated_column(
            'Line Item','String of 1 to 64 characters','^.{1,64}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item Sign Flag" := qvi_util.get_validated_column(
            'Line Item Sign Flag','+ or -','^[\+|-]{1}$',var_src_error);
         var_array_dim(var_array_dim.count)."Line Item Financial Unit" := qvi_util.get_validated_column(
            'Line Item Financial Unit','String of 1 to 32 characters','^.{1,32}$',var_src_error);
         return;
      end if;            

      /*-*/
      /* Exceptions raised in LICS_INBOUND_UTILITY
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_src_error := true;
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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||nvl(var_statement_tag,'')||'] - ' || substr(sqlerrm, 1, 1536));
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
      /* Rollback the database when required
      /*-*/
      if var_src_error = true then
         rollback;
         return;
      end if;
      
      /*-*/
      /* Load the dimension data
      /*-*/
      for idx in 1..var_array_dim.count loop
         qvi_dim_function.append_data(sys.anydata.ConvertObject(var_array_dim(idx)));
      end loop;
      
      /*-*/
      /* Finalise the loader and commit the database
      /*-*/
      qvi_dim_function.finalise_loader;
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - ['||var_module_name||']['||nvl(var_statement_tag,'')||'] - ' || substr(sqlerrm, 1, 1536));
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;
   
end qvi_fppqvi03_dim_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on qvi_fppqvi03_dim_loader to lics_app;
