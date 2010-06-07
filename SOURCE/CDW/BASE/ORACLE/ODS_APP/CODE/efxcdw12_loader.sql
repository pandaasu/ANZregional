/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw12_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw12_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Route Scheduler Data - EFEX to CDW

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/05   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end efxcdw12_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw12_loader as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   rcd_efex_route_sched efex_route_sched%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the transaction variables
      /*-*/
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','RSC_DATE',14);
      lics_inbound_utility.set_definition('HDR','TOT_SCANNED',15);
      lics_inbound_utility.set_definition('HDR','TOT_SCHEDULED',15);
      lics_inbound_utility.set_definition('HDR','TOT_SKIPPED',15);
      lics_inbound_utility.set_definition('HDR','TOT_ERRORS',15);
      lics_inbound_utility.set_definition('HDR','TOT_CALLS',15);
      lics_inbound_utility.set_definition('HDR','STATUS',1);

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
      var_record_identifier varchar2(3);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Process the data based on record identifier
      /*-*/
      var_record_identifier := substr(par_record,1,3);
      case var_record_identifier
         when 'HDR' then process_record_hdr(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));

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
      /* Commit/rollback as required
      /*-*/
      if var_trn_error = true then
         rollback;
      else
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_efex_route_sched.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_route_sched.route_sched_date := lics_inbound_utility.get_date('RSC_DATE','yyyymmddhh24miss');
      rcd_efex_route_sched.tot_scanned := lics_inbound_utility.get_number('TOT_SCANNED',null);
      rcd_efex_route_sched.tot_sched := lics_inbound_utility.get_number('TOT_SCHEDULED',null);
      rcd_efex_route_sched.tot_skipped := lics_inbound_utility.get_number('TOT_SKIPPED',null);
      rcd_efex_route_sched.tot_errors := lics_inbound_utility.get_number('TOT_ERRORS',null);
      rcd_efex_route_sched.tot_calls := lics_inbound_utility.get_number('TOT_CALLS',null);
      rcd_efex_route_sched.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_route_sched.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_route_sched values rcd_efex_route_sched;
      exception
         when dup_val_on_index then
            update efex_route_sched
               set tot_scanned = rcd_efex_route_sched.tot_scanned,
                   tot_sched = rcd_efex_route_sched.tot_sched,
                   tot_skipped = rcd_efex_route_sched.tot_skipped,
                   tot_errors = rcd_efex_route_sched.tot_errors,
                   tot_calls = rcd_efex_route_sched.tot_calls,
                   status = rcd_efex_route_sched.status,
                   valdtn_status = rcd_efex_route_sched.valdtn_status
             where user_id = rcd_efex_route_sched.user_id
               and route_sched_date = rcd_efex_route_sched.route_sched_date;
      end;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Exception trap
      /*-*/
      when others then
         lics_inbound_utility.add_exception(substr(SQLERRM, 1, 1024));
         var_trn_error := true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end efxcdw12_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw12_loader for ods_app.efxcdw12_loader;
grant execute on ods_app.efxcdw12_loader to lics_app;
