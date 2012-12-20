
  CREATE OR REPLACE PACKAGE "QV_APP"."QV_CSVQVS15_LOADER" as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs15_loader 
    Owner   : qv_app 

    Description 
    ----------- 
    CSV File to Qlikview - CSVQVS15 - AU Coles Material Mapping  

    YYYY/MM   Author         Description 
    -------   ------         ----------- 
    2012/07   Trevor Keon    Created 
    2012/08   Trevor Keon    Added support for all AU sites 
    2012/12   Jeff Phillipson Added extra column for Coles Code divisor
   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs15_loader;


  CREATE OR REPLACE PACKAGE BODY "QV_APP"."QV_CSVQVS15_LOADER" as

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
   con_interface constant varchar2(10) := 'CSVQVS15';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_inserts_count number;
   var_sequence number;  
      
   rcd_matl_map au_coles_matl_map%rowtype;  

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      lics_logging.start_log(con_interface, con_interface);
      lics_logging.write_log('Load started');

      /*-*/
      /* Initialise the transaction variables 
      /*-*/
      var_trn_error := false;
      var_trn_count := 0;  
      var_inserts_count := 0;
      
      /*-*/
      /* Set sequence number
      /*-*/
      select au_coles_matl_map_seq.nextval
      into var_sequence
      from dual;

      /*-*/
      /* Initialise the definitions 
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('REP_ITEM',1);
      lics_inbound_utility.set_csv_definition('COLES_CODE',2);
      lics_inbound_utility.set_csv_definition('COLES_DIVISOR',3);

      /*-*/
      /* Delete the existing data 
      /*-*/
      delete from au_coles_matl_map;      

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
      
      /*-*/
      /* Ignore blank lines
      /*-*/      
      if qv_validation_utilities.check_blank_line(par_record, con_delimiter) = true then
         --lics_logging.write_log('Found blank line - #' || var_trn_count);
         return;
      end if;
      
      lics_logging.write_log('Line count = ' || to_char(var_trn_count));
      var_trn_count := var_trn_count + 1; 
      
      /*-*/
      /* Ignore the header record 
      /*-*/         
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
      rcd_matl_map.acmm_version := var_sequence;
      rcd_matl_map.acmm_rep_item := lics_inbound_utility.get_variable('REP_ITEM');
      rcd_matl_map.acmm_coles_code := lics_inbound_utility.get_variable('COLES_CODE');
      rcd_matl_map.acmm_coles_divisor := lics_inbound_utility.get_number('COLES_DIVISOR','999999');

      /*-*/
      /* Insert the row when required
      /*-*/
      if (rcd_matl_map.acmm_rep_item is null) 
            or (rcd_matl_map.acmm_coles_code is null) 
            or (rcd_matl_map.acmm_coles_divisor is null) then               
         lics_logging.write_log('Line contains null values - #' || var_trn_count);
      else
         insert into au_coles_matl_map values rcd_matl_map;
         var_inserts_count := var_inserts_count + 1;
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
      
      lics_logging.write_log('Completed successfully, Records loaded: '  || to_char(var_inserts_count));       
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
   
end qv_csvqvs15_loader;


/**/
/* Authority 
/**/
grant execute on qv_csvqvs15_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs15_loader for qv_app.qv_csvqvs15_loader;