/******************/
/* Package Header */
/******************/
create or replace package qv_app.test_dim_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : test_dim_loader
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

end test_dim_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.test_dim_loader as

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
   type rcd_data is record (mat_code varchar2(20),
                            mat_name varchar2(40));
   type typ_data is table of rcd_data index by binary_integer;
   tbl_data typ_data;

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
      tbl_data.delete;

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('DAT','LVL_DATA',6);
      lics_inbound_utility.set_definition('DAT','LVL_CODE',2);
      lics_inbound_utility.set_definition('DAT','MAT_CODE',18);
      lics_inbound_utility.set_definition('DAT','MAT_NAME',40);

      /*-*/
      /* Start the dimension loader
      /*-*/
      qvi_dim_function.start_loader('TEST');

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
   
      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

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
      var_code := lics_inbound_utility.get_variable('LVL_CODE');
      if var_code = '04' or var_code = '05' then
         tbl_data(tbl_data.count+1).mat_code := lics_inbound_utility.get_variable('MAT_CODE');
         tbl_data(tbl_data.count).mat_name := lics_inbound_utility.get_variable('MAT_NAME');
      end if;

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
      var_data test_dim_object;

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
         var_data := test_dim_object(tbl_data(idx).mat_code,
                                     tbl_data(idx).mat_name);
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

end test_dim_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on test_dim_loader to lics_app;
