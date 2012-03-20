/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fppqvi01_dim_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fppqvi01_dim_loader
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Test Dimension Loader

    This package contain the test dimension loader functions.

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

end qvi_fppqvi01_dim_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fppqvi01_dim_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_regexp_switch varchar2(4) := null; -- oracle regexp_like match_parameter       
   con_trim_flag boolean := true;

   /*-*/
   /* Private definitions
   /*-*/
   var_src_error boolean;
   type rcd_data is record ("Cust Code" varchar2(6),
                            "Customer" varchar2(32),
                            "Cust Parent Code" varchar2(6),
                            "Cust Parent" varchar2(32));
   type typ_data is table of rcd_data index by binary_integer;
   tbl_data typ_data;
   
   var_row_count number;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the package level variables
      /*-*/
      var_src_error := false;
      var_row_count := 0;
      tbl_data.delete;

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('Cust Code',1);
      lics_inbound_utility.set_csv_definition('Customer',2);
      lics_inbound_utility.set_csv_definition('Cust Parent Code',3);
      lics_inbound_utility.set_csv_definition('Cust Parent',4);

      /*-*/
      /* Start the dimension loader
      /*-*/
      qvi_dim_function.start_loader('fpps_customer');

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
      var_code varchar2(2);
      var_header varchar2(1024);
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      var_row_count := var_row_count + 1;
   
      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      /*-*/
      /* Empty rows
      /*-*/
      if trim(par_record) is null then
         return;
      end if;
      
      /*-----------------------*/
      /* PARSE - Header record */
      /*-----------------------*/
      
      if var_row_count = 1 then
         var_header :=  'Int Acc -,Description,Total,Description';
      	 if trim(substr(par_record,1,length(trim(var_header)))) != var_header then
            lics_inbound_utility.add_exception('File header "'||par_record||'" not recognised, expected "'||var_header||'".');
            var_src_error := true;
         end if;
         return;
      end if;
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      /*-*/
      /* Parse the input data record
      /*-*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

      /*-*/
      /* Load the source data into the array
      /*-*/
      tbl_data(tbl_data.count+1)."Cust Code" := qvi_util.get_validated_string(
         'Cust Code','Alphanumeric of 1 to 6 characters','^[[:alnum:]]{1,6}$',con_regexp_switch,con_trim_flag,var_src_error);
      tbl_data(tbl_data.count)."Customer" := qvi_util.get_validated_string(
         'Customer','String of 1 to 32 characters','^[[:print:]|[:space:]]{1,32}$',con_regexp_switch,con_trim_flag,var_src_error);
      tbl_data(tbl_data.count)."Cust Parent Code" := qvi_util.get_validated_string(
         'Cust Parent Code','Alphanumeric of 1 to 6 characters','^[[:alnum:]]{1,6}$',con_regexp_switch,con_trim_flag,var_src_error);
      tbl_data(tbl_data.count)."Cust Parent" := qvi_util.get_validated_string(
         'Cust Parent','String of 1 to 32 characters','^[[:print:]|[:space:]]{1,32}$',con_regexp_switch,con_trim_flag,var_src_error);

      /*-*/
      /* Exceptions raised in LICS_INBOUND_UTILITY
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_src_error := true;
      end if;

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
      var_data qvi_fppqvi01_dim_object;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
      for idx in 1..tbl_data.count loop
         var_data := qvi_fppqvi01_dim_object(tbl_data(idx)."Cust Code",
         		             tbl_data(idx)."Customer",
         		             tbl_data(idx)."Cust Parent Code",
                                     tbl_data(idx)."Cust Parent");
         qvi_dim_function.append_data(sys.anydata.ConvertObject(var_data));
      end loop;

      /*-*/
      /* Finalise the loader and commit the database
      /*-*/
      qvi_dim_function.finalise_loader;
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;
   
end qvi_fppqvi01_dim_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on qvi_fppqvi01_dim_loader to lics_app;
