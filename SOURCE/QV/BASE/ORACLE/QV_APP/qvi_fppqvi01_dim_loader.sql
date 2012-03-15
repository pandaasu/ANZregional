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
      lics_inbound_utility.set_definition('DAT','Cust Code',6);
      lics_inbound_utility.set_definition('DAT','Customer',32);
      lics_inbound_utility.set_definition('DAT','Cust Parent Code',6);
      lics_inbound_utility.set_definition('DAT','Cust Parent',32);

      /*-*/
      /* Start the dimension loader
      /*-*/
      qvi_dim_function.start_loader('FPPQVI01');

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
      var_row_count := var_row_count + 1;
   
      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      /*-*/
      /* Ignore Header
      /*-*/
      if var_row_count <= 1 then
         return;
      end if;

      /*-*/
      /* Empty rows
      /*-*/
      if trim(par_record) is null then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      /*-*/
      /* Parse the input data record
      /*-*/
      lics_inbound_utility.parse_record('DAT', par_record);

      /*-*/
      /* Load the source data into the array
      /*-*/
      tbl_data(tbl_data.count+1)."Cust Code" := lics_inbound_utility.get_variable('Cust Code');
      tbl_data(tbl_data.count)."Customer" := lics_inbound_utility.get_variable('Customer');
      tbl_data(tbl_data.count)."Cust Parent Code" := lics_inbound_utility.get_variable('Cust Parent Code');
      tbl_data(tbl_data.count)."Cust Parent" := lics_inbound_utility.get_variable('Cust Parent');

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
