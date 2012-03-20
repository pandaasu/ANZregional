/******************/
/* Package Header */
/******************/
create or replace package qv_app.qvi_fppqvi07_source_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qvi_fppqvi07_source_loader
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

end qvi_fppqvi07_source_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body qv_app.qvi_fppqvi07_source_loader as

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
   var_src_created boolean;
   var_src_error boolean;
   var_src_complete_header boolean;
   var_src_first_header boolean;

   var_current_rec qvi_fppqvi07_source_object;
   var_previous_rec qvi_fppqvi07_source_object;

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
      var_src_created := false;
      var_src_error := false;
      var_src_complete_header := false;
      var_src_first_header := true;

      var_current_rec := qvi_fppqvi07_source_object(null,null,null,null,null,null,null,null,null,null);
      var_previous_rec := qvi_fppqvi07_source_object(null,null,null,null,null,null,null,null,null,null);

      /*-*/
      /* Initialise the layout definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      lics_inbound_utility.set_csv_definition('Line Item Code',1);
      lics_inbound_utility.set_csv_definition('Material Code',2);
      lics_inbound_utility.set_csv_definition('Source Code',3);
      lics_inbound_utility.set_csv_definition('Actual Value',4);

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
      var_data qvi_fppqvi07_source_object;
      var_header_row_tag varchar2(20) := null;
      var_header_row_value varchar2(256) := null;

   /*-------------*
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

      /*---------------------------*/
      /* STRIP - Strip header data */
      /*---------------------------*/
      var_header_row_tag := rtrim(substr(par_record,1,20));
      var_header_row_value := rtrim(substr(par_record,21));

      /*-*/
      /* Parse Unit record
      /*-*/
      if var_header_row_tag = 'Unit' then
         var_current_rec."Unit Code" := qvi_util.get_validated_string(
            'Unit Code',var_header_row_value,'Alphanumeric of 1 to 8 characters','^[[:alnum:]]{1,8}$',con_regexp_switch,con_trim_flag,var_src_error);
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
            'Dest Code',var_header_row_value,'Alphanumeric of 1 to 8 characters','^[[:alnum:]]{1,8}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;

      /*-*/
      /* Parse Customer record
      /*-*/
      elsif var_header_row_tag = 'Customer' then
         var_current_rec."Cust Code" := qvi_util.get_validated_string(
            'Cust Code',var_header_row_value,'Alphanumeric of 1 to 8 characters','^[[:alnum:]]{1,8}$',con_regexp_switch,con_trim_flag,var_src_error);
         return;

      /*-*/
      /* Parse Period record
      /*-*/
      elsif trim(substr(par_record,1,3)) = ',,,' then
         var_current_rec."Period" := to_number(qvi_util.get_validated_string(
            'Period',substr(par_record,5,2),'Number of 1 to 2 digits','^[[:digit:]]{1,2}$',con_regexp_switch,con_trim_flag,var_src_error));

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
         if var_src_complete_header = false then
            var_src_error := true;
         end if;

         /*-*/
         /* Start the source loader on first header .. or on change of Unit Code, Year, Period
         /*-*/
         if var_src_first_header = true
            or NVL(var_current_rec."Unit Code", '*NULL') != NVL(var_previous_rec."Unit Code", '*NULL')
            or NVL(var_current_rec."Year", '*NULL') != NVL(var_previous_rec."Year", '*NULL')
            or NVL(var_current_rec."Period", '*NULL') != NVL(var_previous_rec."Period", '*NULL') then

            if var_src_first_header = true then
               var_src_first_header := false;
            else
               /*-*/
               /* Commit/rollback the header when required
               /*-*/
               if var_src_created = true then
                  if var_src_error = false then
                     qvi_src_function.finalise_loader;
                     commit;
                  else
                     rollback;
                  end if;
               end if;
            end if;

            if var_src_created = true then
               lics_inbound_utility.add_exception('Previous source has not been finalised');
               var_src_error := true;
            end if;

            qvi_src_function.start_loader('fpps_anz_pet', 'fpps_actuals', var_current_rec."Year"||var_current_rec."Period", var_current_rec."Unit Code");
            var_src_created := true;
            var_src_error := false;
            /*-*/
            /* Take copy of key header values
            /*-*/
            var_previous_rec."Unit Code" := var_current_rec."Unit Code";
            var_previous_rec."Plan Version" := var_current_rec."Plan Version";
            var_previous_rec."Year" := var_current_rec."Year";
            var_previous_rec."Dest Code" := var_current_rec."Dest Code";
            var_previous_rec."Cust Code" := var_current_rec."Cust Code";
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
            return;
         end if;

         /*-*/
         /* Parse the input data record
         /*-*/
         lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

         var_current_rec."Line Item Code" := qvi_util.get_validated_string(
            'Line Item Code','Alphanumeric of 1 to 8 characters','^[[:alnum:]]{1,8}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_current_rec."Material Code" := qvi_util.get_validated_string(
            'Material Code','Alphanumeric of 1 to 8 characters','^[[:alnum:]]{1,8}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_current_rec."Source Code" := qvi_util.get_validated_string(
            'Source Code','Alphanumeric of 1 to 8 characters','^[[:alnum:]]{1,8}$',con_regexp_switch,con_trim_flag,var_src_error);
         var_current_rec."Actual Value" := to_number(qvi_util.get_validated_string(
            'Actual Value','Number of up to percision 15, scale 5','^[-]?[[:digit:]]{1,10}[\.]?[[:digit:]]{0,5}$',con_regexp_switch,con_trim_flag,var_src_error));
         
         /*-*/
         /* Create the source object
         /*-*/
         var_data := qvi_fppqvi07_source_object(var_current_rec."Unit Code",
                      var_current_rec."Plan Version",
                      var_current_rec."Dest Code",
                      var_current_rec."Cust Code",
                      var_current_rec."Year",
                      var_current_rec."Period",
                      var_current_rec."Line Item Code",
                      var_current_rec."Material Code",
                      var_current_rec."Source Code",
                      var_current_rec."Actual Value");

         /*-*/
         /* Exceptions raised in LICS_INBOUND_UTILITY
         /*-*/
         if lics_inbound_utility.has_errors = true then
            var_src_error := true;
         end if;

         /*-*/
         /* Append the source data when required (no errors)
         /*-*/
         if var_src_error = false then
            qvi_src_function.append_data(sys.anydata.ConvertObject(var_data));
         end if;
         /*-*/
         /* Exit the procedure
         /*-*/

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

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end qvi_fppqvi07_source_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym qvi_fppqvi07_source_loader for qv_app.qvi_fppqvi07_source_loader;
grant execute on qvi_fppqvi07_source_loader to lics_app;
