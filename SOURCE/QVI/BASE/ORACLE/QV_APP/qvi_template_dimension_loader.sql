/******************/
/* Package Header */
/******************/
create or replace package qv_app.template_dimension_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : template_dimension_loader
    Owner   : qv_app

    Description
    -----------
    QlikView Interfacing - Dimension Loader Template

    This package contain the dimension loader template.

    **NOTES**

    1. A dimension loader package is required for each dimension definition.

    2. A unique template_object_type is required for each dimension definition that describes the data layout.

    3. The dimension loader package procedure are invoked directly from the ICS inbound processor.

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

end template_dimension_loader;

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.template_dimension_loader as

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
   type rcd_data is record (dim_code varchar2(20),
                            dim_text varchar2(80),
                            dim_lvl01 varchar2(20),
                            dim_lvl02 varchar2(20));
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
      lics_inbound_utility.set_csv_definition('DIM_CODE',1);
      lics_inbound_utility.set_csv_definition('DIM_TEXT',2);
      lics_inbound_utility.set_csv_definition('DIM_LVL01',3);
      lics_inbound_utility.set_csv_definition('DIM_LVL02',4);

      /*-*/
      /* Start the dimension loader
      /*-*/
      qvi_dim_function.start_loader('DESTINATION_MOE');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

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
      if trim(par_record) is null or trim(replace(par_record,con_delimiter,' ')) is null then
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
      tbl_data(tbl_data.count+1).dim_code := lics_inbound_utility.get_variable('DIM_CODE');
      tbl_data(tbl_data.count).dim_text := lics_inbound_utility.get_variable('DIM_TEXT');
      tbl_data(tbl_data.count).dim_lvl01 := lics_inbound_utility.get_variable('DIM_LVL01');
      tbl_data(tbl_data.count).dim_lvl02 := lics_inbound_utility.get_variable('DIM_LVL02');

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
      var_data template_object_type;

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
      /* Perform the dimension explosion logic
      /*-*/
      for idx in 1..tbl_data.count loop
         -- load the exploded data to the array
      end loop;

      /*-*/
      /* Load the dimension data
      /*-*/
      for idx in 1..tbl_data.count loop
         var_data := template_object_type(tbl_data(idx).dim_code,
                                          tbl_data(idx).dim_text,
                                          tbl_data(idx).dim_lvl01,
                                          tbl_data(idx).dim_lvl02);
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

end template_dimension_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym template_dimension_loader for qv_app.template_dimension_loader;
grant execute on template_dimension_loader to lics_app;
