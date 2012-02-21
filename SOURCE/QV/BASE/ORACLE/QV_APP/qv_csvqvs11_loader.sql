create or replace package qv_app.qv_csvqvs11_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs11_loader
    Owner   : qv_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS11 - FPPS Line Item Master Data

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

end qv_csvqvs11_loader;

create or replace package body qv_app.qv_csvqvs11_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_delimiter constant varchar2(32)  := ',';
   con_heading_count constant number := 1;
   con_interface constant varchar2(10) := 'CSVQVS11';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   rcd_fpps_customer fpps_customer%rowtype;

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
      select fpps_customer_seq.nextval
      into var_sequence
      from dual;
      
      lics_logging.write_log('Sequence number = ' || var_sequence);      

      /*-*/
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('TOTAL',1);
      lics_inbound_utility.set_csv_definition('TOTAL_DESCRIPTION',2);
      lics_inbound_utility.set_csv_definition('INT_ACC',3);
      lics_inbound_utility.set_csv_definition('INT_ACC_DESCRIPTION',4);

      /*-*/
      /* Delete the existing data
      /*-*/
      delete from fpps_customer;

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

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_fpps_customer.fcs_version := var_sequence;
      rcd_fpps_customer.fcs_total := lics_inbound_utility.get_variable('TOTAL');
      rcd_fpps_customer.fcs_total_desc := lics_inbound_utility.get_variable('TOTAL_DESCRIPTION');
      rcd_fpps_customer.fcs_int_acc := lics_inbound_utility.get_variable('INT_ACC');
      rcd_fpps_customer.fcs_int_acc_desc := lics_inbound_utility.get_variable('INT_ACC_DESCRIPTION');

      /*-*/
      /* Insert the row when required
      /*-*/
      if not(rcd_fpps_customer.fcs_total is null) or
        not(rcd_fpps_customer.fcs_total_desc is null) or
        not(rcd_fpps_customer.fcs_int_acc is null) or
        not(rcd_fpps_customer.fcs_int_acc_desc is null) then               
         insert into fpps_customer values rcd_fpps_customer;
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

end qv_csvqvs11_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs11_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs11_loader for qv_app.qv_csvqvs11_loader;