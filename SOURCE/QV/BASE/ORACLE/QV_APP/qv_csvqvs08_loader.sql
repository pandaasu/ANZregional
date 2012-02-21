create or replace package qv_app.qv_csvqvs08_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs08_loader
    Owner   : qv_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS08 - FPPS Line Item Master Data

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/05   Trevor Keon    Created
    2011/11   Trevor Keon    Updated to support ICS v2

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs08_loader;

create or replace package body qv_app.qv_csvqvs08_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_text_qualifier constant varchar2(5) := '"';
   con_heading_count constant number := 1;
   con_interface constant varchar2(10) := 'CSVQVS08';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   rcd_fpps_line_item fpps_line_item%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      lics_logging.start_log(con_interface, con_interface);

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;

      /*-*/
      /* Set sequence number
      /*-*/
      select fpps_line_item_seq.nextval
      into var_sequence
      from dual;
      
      lics_logging.write_log('Sequence number = ' || var_sequence);      

      /*-*/
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('LINE_ITEM',2);
      lics_inbound_utility.set_csv_definition('LINE_ITEM_OWNER',3);
      lics_inbound_utility.set_csv_definition('LINE_ITEM_USAGE_OWNER',4);
      lics_inbound_utility.set_csv_definition('LINE_ITEM_CLASSIFICATION',5);
      lics_inbound_utility.set_csv_definition('LINE_ITEM_SHORT_DESCRIPTION',6);
      lics_inbound_utility.set_csv_definition('LINE_ITEM_LONG_DESCRIPTION',7);
      lics_inbound_utility.set_csv_definition('SIGN_CONVENTION',8);
      lics_inbound_utility.set_csv_definition('FINANCIAL_UNIT',9);
      lics_inbound_utility.set_csv_definition('STD_REF_INDICATOR',10);
      lics_inbound_utility.set_csv_definition('AGGREGATE_DATA_INDICATOR',11);
      lics_inbound_utility.set_csv_definition('IGNORE_INDICATOR',12);
      lics_inbound_utility.set_csv_definition('USAGE',13);
      lics_inbound_utility.set_csv_definition('FORCE_CALCULATION',14);
      lics_inbound_utility.set_csv_definition('DISABLE_ALLOCATION',15);

      /*-*/
      /* Delete the existing data
      /*-*/
      delete from fpps_line_item;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap 
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

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

      if trim(par_record) is null then
         return;
      end if;
      var_trn_count := var_trn_count + 1;
      if var_trn_count <= con_heading_count then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_text_qualifier);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_fpps_line_item.fli_version := var_sequence;
      rcd_fpps_line_item.fli_line_item := lics_inbound_utility.get_variable('LINE_ITEM');
      rcd_fpps_line_item.fli_line_item_owner := lics_inbound_utility.get_variable('LINE_ITEM_OWNER');
      rcd_fpps_line_item.fli_line_item_usage_owner := lics_inbound_utility.get_variable('LINE_ITEM_USAGE_OWNER');
      rcd_fpps_line_item.fli_line_item_classification := lics_inbound_utility.get_variable('LINE_ITEM_CLASSIFICATION');
      rcd_fpps_line_item.fli_line_item_short_desc := lics_inbound_utility.get_variable('LINE_ITEM_SHORT_DESCRIPTION');
      rcd_fpps_line_item.fli_line_item_long_desc := lics_inbound_utility.get_variable('LINE_ITEM_LONG_DESCRIPTION');
      rcd_fpps_line_item.fli_sign_conversion := lics_inbound_utility.get_variable('SIGN_CONVENTION');
      rcd_fpps_line_item.fli_financial_unit := lics_inbound_utility.get_variable('FINANCIAL_UNIT');
      rcd_fpps_line_item.fli_std_ref_indicator := lics_inbound_utility.get_variable('STD_REF_INDICATOR');
      rcd_fpps_line_item.fli_aggregate_data := lics_inbound_utility.get_variable('AGGREGATE_DATA_INDICATOR');
      rcd_fpps_line_item.fli_ignore := lics_inbound_utility.get_variable('IGNORE_INDICATOR');
      rcd_fpps_line_item.fli_usage := lics_inbound_utility.get_variable('USAGE');
      rcd_fpps_line_item.fli_force_calc := lics_inbound_utility.get_variable('FORCE_CALCULATION');
      rcd_fpps_line_item.fli_disable_allocation := lics_inbound_utility.get_variable('DISABLE_ALLOCATION');

      /*-*/
      /* Insert the row when required
      /*-*/
      if not(rcd_fpps_line_item.fli_line_item is null) or
        not(rcd_fpps_line_item.fli_line_item_owner is null) or
        not(rcd_fpps_line_item.fli_line_item_usage_owner is null) or
        not(rcd_fpps_line_item.fli_line_item_classification is null) or
        not(rcd_fpps_line_item.fli_line_item_short_desc is null) or
        not(rcd_fpps_line_item.fli_line_item_long_desc is null) or
        not(rcd_fpps_line_item.fli_financial_unit is null) or
        not(rcd_fpps_line_item.fli_std_ref_indicator is null) or
        not(rcd_fpps_line_item.fli_aggregate_data is null) or
        not(rcd_fpps_line_item.fli_ignore is null) or
        not(rcd_fpps_line_item.fli_usage is null) then               
         insert into fpps_line_item values rcd_fpps_line_item;
      else
         lics_logging.write_log('Found blank line - #' || var_trn_count);
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         var_trn_error := true;

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
      var_exception varchar2(4000);      
      var_session number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
         
      /*-*/
      /* Ignore when required
      /*-*/
      if var_trn_error = true then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;
      
      lics_logging.write_log('Completed successfully');      
      lics_logging.end_log;        

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Add the exception to the interface
         /*-*/
         lics_inbound_utility.add_exception(var_exception);        
         lics_logging.end_log;
         
   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end qv_csvqvs08_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs08_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs08_loader for qv_app.qv_csvqvs08_loader;