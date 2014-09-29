create or replace package bi_app.qv_csvqvs05_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs05_loader
    Owner   : bi_app

    Description
    -----------
    CSV File to Qlikview - CSVQVS05 - Shipment Sales Tonnes OP 

    YYYY/MM   Author         Description
    -------   ------         -----------
    2011/02   Trevor Keon    Created 
    2011/11   Trevor Keon    Updated to support ICS v2 
    2014/07   Trevor Keon    Updated to support FLU 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;
   -- FFLU Hooks.
   function on_get_file_type return varchar2;
   function on_get_csv_qualifier return varchar2; 

end qv_csvqvs05_loader;

create or replace package body bi_app.qv_csvqvs05_loader as

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
   con_mars_periods constant number := 13;
   con_interface constant varchar2(10) := 'CSVQVS05';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   type period_table is table of number index by pls_integer;
      
   tbl_period period_table;
   rcd_shp_sls_tons_op shp_sls_tons_op%rowtype;  

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
      select qv.shp_sls_tons_op_seq.nextval
      into var_sequence
      from dual;
      
      lics_logging.write_log('Sequence number = ' || var_sequence);      

      /*-*/
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('ACCNT_ASSIGNMNT_CODE',1);
      lics_inbound_utility.set_csv_definition('ACCNT_ASSIGNMNT_DESC',2);
      lics_inbound_utility.set_csv_definition('PLNG_SRC_CODE',3);
      lics_inbound_utility.set_csv_definition('PLNG_SRC_DESC',4);
      lics_inbound_utility.set_csv_definition('PERIOD_1',5);
      lics_inbound_utility.set_csv_definition('PERIOD_2',6);
      lics_inbound_utility.set_csv_definition('PERIOD_3',7);
      lics_inbound_utility.set_csv_definition('PERIOD_4',8);
      lics_inbound_utility.set_csv_definition('PERIOD_5',9);
      lics_inbound_utility.set_csv_definition('PERIOD_6',10);
      lics_inbound_utility.set_csv_definition('PERIOD_7',11);
      lics_inbound_utility.set_csv_definition('PERIOD_8',12);
      lics_inbound_utility.set_csv_definition('PERIOD_9',13);
      lics_inbound_utility.set_csv_definition('PERIOD_10',14);
      lics_inbound_utility.set_csv_definition('PERIOD_11',15);
      lics_inbound_utility.set_csv_definition('PERIOD_12',16);
      lics_inbound_utility.set_csv_definition('PERIOD_13',17);

      /*-*/
      /* Delete the existing data
      /*-*/
      delete from qv.shp_sls_tons_op;

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
         lics_logging.write_log('Error on_start - ' || substr(SQLERRM, 1, 512));
         lics_logging.end_log;

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
      var_period_text varchar2(25);

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
      
      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_csv_record(par_record, con_delimiter);           
      
      /*-*/
      /* Retrieve field values
      /*-*/      
      if var_trn_count <= con_heading_count then
         for i in 1..con_mars_periods loop            
            var_period_text := 'PERIOD_' || to_char(i);            
            tbl_period(i) := to_number(lics_inbound_utility.get_variable(var_period_text));
         end loop;
              
      else     
         rcd_shp_sls_tons_op.sst_version := var_sequence;
         rcd_shp_sls_tons_op.sst_accnt_assignmnt := lics_inbound_utility.get_variable('ACCNT_ASSIGNMNT_CODE');
         rcd_shp_sls_tons_op.sst_plng_src := lics_inbound_utility.get_variable('PLNG_SRC_CODE');  
             
         for i in 1..con_mars_periods loop          
            var_period_text := 'PERIOD_' || to_char(i);
            rcd_shp_sls_tons_op.sst_forecast := to_number(lics_inbound_utility.get_variable(var_period_text));
            rcd_shp_sls_tons_op.sst_period := tbl_period(i);          
            /*-*/
            /* Insert the row when required
            /*-*/
            if not(rcd_shp_sls_tons_op.sst_accnt_assignmnt is null) or
               not(rcd_shp_sls_tons_op.sst_plng_src is null) then               
               insert into qv.shp_sls_tons_op values rcd_shp_sls_tons_op;
            else
               lics_logging.write_log('Found blank line - #' || var_trn_count);
            end if;
         end loop;
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
         lics_logging.write_log('Error on_data - ' || substr(SQLERRM, 1, 512));
         lics_logging.end_log;

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
   
  ------------------------------------------------------------------------------
  -- FFLU : ON_GET_FILE_TYPE
  ------------------------------------------------------------------------------
  function on_get_file_type return varchar2 is 
  begin 
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;

  ------------------------------------------------------------------------------
  -- FFLU : ON_GET_CSV_QUALIFER
  ------------------------------------------------------------------------------
  function on_get_csv_qualifier return varchar2 is
  begin 
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;   

end qv_csvqvs05_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs05_loader to lics_app, fflu_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs05_loader for bi_app.qv_csvqvs05_loader;