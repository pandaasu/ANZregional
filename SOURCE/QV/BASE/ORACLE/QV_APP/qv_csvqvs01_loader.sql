create or replace package qv_app.qv_csvqvs01_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : qv_csvqvs01_loader 
    Owner   : qv_app 

    Description 
    ----------- 
    CSV File to Qlikview - CSVQVS01 - NZ Demand Planning ReGroup 

    YYYY/MM   Author         Description 
    -------   ------         ----------- 
    2010/09   Trevor Keon    Created 
    2011/11   Trevor Keon    Updated to support ICS v2 
    2012/01   Trevor Keon    Added abbreviation for Regroup name 
    2012/05   Trevor Keon    Added sort order 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end qv_csvqvs01_loader;

create or replace package body qv_app.qv_csvqvs01_loader as

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
   con_interface constant varchar2(10) := 'CSVQVS01';

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_sequence number;
   
   rcd_nz_demand_plng_regroup nz_demand_plng_regroup%rowtype;

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
      select nz_dmnd_plng_regrp_seq.nextval
      into var_sequence
      from dual;
      
      lics_logging.write_log('Sequence number = ' || var_sequence);      

      /*-*/
      /* Initialise the definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('REGROUP_DPG',1);
      lics_inbound_utility.set_csv_definition('DEMAND_PLANNING_GRP',2);
      lics_inbound_utility.set_csv_definition('REGROUP_ABBR',3);  
      lics_inbound_utility.set_csv_definition('SORT_ORDER',4);  

      /*-*/
      /* Delete the existing data
      /*-*/
      delete from nz_demand_plng_regroup;

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
      rcd_nz_demand_plng_regroup.dpr_version := var_sequence;
      rcd_nz_demand_plng_regroup.dpr_regroup_dpg := lics_inbound_utility.get_variable('REGROUP_DPG');
      rcd_nz_demand_plng_regroup.dpr_demand_plng_grp := lics_inbound_utility.get_variable('DEMAND_PLANNING_GRP');
      rcd_nz_demand_plng_regroup.dpr_regroup_abbr := lics_inbound_utility.get_variable('REGROUP_ABBR');
      rcd_nz_demand_plng_regroup.dpr_sort_order := lics_inbound_utility.get_variable('SORT_ORDER');

      /*-*/
      /* Insert the row when required
      /*-*/
      if not(rcd_nz_demand_plng_regroup.dpr_regroup_dpg is null) or
         not(rcd_nz_demand_plng_regroup.dpr_demand_plng_grp is null) then               
         insert into nz_demand_plng_regroup values rcd_nz_demand_plng_regroup;
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

end qv_csvqvs01_loader;

/**/
/* Authority 
/**/
grant execute on qv_csvqvs01_loader to lics_app;

/**/
/* Synonym 
/**/
create or replace public synonym qv_csvqvs01_loader for qv_app.qv_csvqvs01_loader;