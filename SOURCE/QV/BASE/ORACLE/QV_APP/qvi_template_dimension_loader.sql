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
   var_dim_created boolean;
   var_dim_error boolean;
   var_dest_moe varchar2(20);
   var_plan_year varchar2(20);
   var_plan_code varchar2(20);
   var_customer varchar2(20);
   var_unit varchar2(20);
   var_period varchar2(20);

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
      var_dest_moe := null;
      var_plan_year := null;
      var_plan_code := null;
      var_customer := null;
      var_unit := null;
      var_period := null;

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('DEST_CODE',1);
      lics_inbound_utility.set_csv_definition('DEST_TEXT',2);
      lics_inbound_utility.set_csv_definition('DEST_LVL01',3);
      lics_inbound_utility.set_csv_definition('DEST_LVL02',4);

      /*-*/
      /* Create the new header
      /*-*/
      qvi_dim_function.create_header('DESTINATION_MOE');

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
      var_data template_object_type;

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

      /*----------------------------------------------*/
      /* STRIP - Strip the control data when required */
      /*----------------------------------------------*/

      /*-*/
      /* Destination MOE record
      /*-*/
      if upper(trim(substr(par_record,1,20))) = 'DEST_MOE' then

         /*-*/
         /* Commit/rollback the header when required
         /*-*/
         if var_src_created = true then
            if var_src_error = false then
               qvi_src_function.finalise_header;
               commit;
            else
               rollback;
            end if;
         end if;
         var_src_created := false;
         var_src_error := false;
         var_dest_moe := null;
         var_plan_year := null;
         var_plan_code := null;
         var_customer := null;
         var_unit := null;
         var_period := null;

         /*-*/
         /* Strip the destination MOE and exit the procedure
         /*-*/
         var_dest_moe := substr(par_record,21,3);
         return;

      /*-*/
      /* Plan Version record
      /*-*/
      elsif upper(trim(substr(par_record,1,20))) = 'PLAN_VERSION' then

         /*-*/
         /* Validate the source header status
         /*-*/
         if var_src_created = true then
            lics_inbound_utility.add_exception('Previous source header has not been finalised');
            var_src_error := true;
         end if;

         /*-*/
         /* Strip the plan version and exit the procedure
         /*-*/
         var_plan_year := substr(par_record,21,4);
         var_plan_code := substr(par_record,26,10);
         return;

      /*-*/
      /* Customer record
      /*-*/
      elsif upper(trim(substr(par_record,1,20))) = 'CUSTOMER' then

         /*-*/
         /* Validate the source header status
         /*-*/
         if var_src_created = true then
            lics_inbound_utility.add_exception('Previous source header has not been finalised');
            var_src_error := true;
         end if;

         /*-*/
         /* Strip the customer and exit the procedure
         /*-*/
         var_customer := substr(par_record,21,3);
         return;

      /*-*/
      /* Unit record
      /*-*/
      elsif upper(trim(substr(par_record,1,20))) = 'UNIT' then

         /*-*/
         /* Validate the source header status
         /*-*/
         if var_src_created = true then
            lics_inbound_utility.add_exception('Previous source header has not been finalised');
            var_src_error := true;
         end if;

         /*-*/
         /* Strip the unit and exit the procedure
         /*-*/
         var_unit := substr(par_record,21,4);
         return;

      /*-*/
      /* Period record
      /*-*/
      elsif upper(trim(substr(par_record,1,3))) = ',,,' then

         /*-*/
         /* Extract the period and ensure that all control variables are present
         /*-*/
         var_period := substr(par_record,5,2);
         if var_src_created = true then
            lics_inbound_utility.add_exception('Previous source has not been finalised');
            var_src_error := true;
         end if;
         if var_dest_moe is null then
            lics_inbound_utility.add_exception('Source data is missing the destination MOE');
            var_src_error := true;
         end if;
         if var_plan_year is null then
            lics_inbound_utility.add_exception('Source data is missing the plan year');
            var_src_error := true;
         end if;
         if var_plan_code is null then
            lics_inbound_utility.add_exception('Source data is missing the plan code');
            var_src_error := true;
         end if;
         if var_customer is null then
            lics_inbound_utility.add_exception('Source data is missing the customer');
            var_src_error := true;
         end if;
         if var_unit is null then
            lics_inbound_utility.add_exception('Source data is missing the unit');
            var_src_error := true;
         end if;
         if var_period is null then
            lics_inbound_utility.add_exception('Source data is missing the period');
            var_src_error := true;
         end if;

         /*-*/
         /* Create the new header
         /*-*/
         qvi_src_function.create_header('FPPS_REGIONAL', 'ACTUALS', var_plan_year||var_period, var_unit);
         var_src_created := true;

         /*-*/
         /* Exit the procedure
         /*-*/
         return;

      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      /*-*/
      /* Source header must have been created when a detail row
      /*-*/
      if var_src_created = false then
         var_src_error := true;
         return;
      end if;

      /*-*/
      /* Parse the input data record
      /*-*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

      /*-*/
      /* Create the source object
      /*-*/
      var_data := template_object_type(var_dest_moe,
                                       var_customer,
                                       lics_inbound_utility.get_variable('LINE_ITEM'),
                                       lics_inbound_utility.get_variable('MATERIAL'),
                                       lics_inbound_utility.get_variable('SRC_MOE'),
                                       lics_inbound_utility.get_number('VALUE'));

      /*-*/
      /* Exceptions raised in LICS_INBOUND_UTILITY
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_src_error := true;
      end if;

      /*-*/
      /* Append the destination data when required (no errors)
      /*-*/
      if var_src_error = false then
         qvi_dim_function.append_data(sys.anydata.ConvertObject(var_data));
      end if;

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
      /* Commit/rollback the header when required
      /*-*/
      if var_src_error = false then
         qvi_dim_function.finalise_header;
         commit;
      else
         rollback;
      end if;

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
