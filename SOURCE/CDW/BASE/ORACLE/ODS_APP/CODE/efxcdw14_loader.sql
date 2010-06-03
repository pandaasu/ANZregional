/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw14_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw14_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Call Data - EFEX to CDW

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

end efxcdw14_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw14_loader as

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
   rcd_efex_call efex_call%rowtype;

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
      lics_inbound_utility.set_definition('HDR','CUS_ID',10);
      lics_inbound_utility.set_definition('HDR','CAL_DATE',14);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_USR_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','ACC_USR_ID',10);
      lics_inbound_utility.set_definition('HDR','CAL_TYPE',50);
      lics_inbound_utility.set_definition('HDR','END_DATE',14);
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

      rcd_efex_call.efex_cust_id := lics_inbound_utility.get_number('CUS_ID');
      rcd_efex_call.call_date := lics_inbound_utility.get_date('CAL_DATE','yyyymmddhh24miss');
      rcd_efex_call.user_id := lics_inbound_utility.get_number('USR_ID');
      rcd_efex_call.sales_terr_id := lics_inbound_utility.get_number('STE_ID');
      rcd_efex_call.sales_terr_user_id := lics_inbound_utility.get_number('STE_USR_ID');
      rcd_efex_call.sgmnt_id := lics_inbound_utility.get_number('SEG_ID');
      rcd_efex_call.bus_unit_id := lics_inbound_utility.get_number('BUS_ID');
      rcd_efex_call.accomp_user_id := lics_inbound_utility.get_number('ACC_USR_ID');
      rcd_efex_call.call_type := lics_inbound_utility.get_variable('CAL_TYPE');
      rcd_efex_call.end_date := lics_inbound_utility.get_date('END_DATE','yyyymmddhh24miss');
      rcd_efex_call.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_call.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_call values rcd_efex_call;
      exception
         when dup_val_on_index then
            update efex_call
               set sales_terr_id = rcd_efex_call.sales_terr_id,
                   sales_terr_user_id = rcd_efex_call.sales_terr_user_id,
                   sgmnt_id = rcd_efex_call.sgmnt_id,
                   bus_unit_id = rcd_efex_call.bus_unit_id,
                   accomp_user_id = rcd_efex_call.accomp_user_id,
                   call_type = rcd_efex_call.call_type,
                   end_date = rcd_efex_call.end_date,
                   status = rcd_efex_call.status,
                   valdtn_status = rcd_efex_call.valdtn_status
             where efex_cust_id = rcd_efex_call.efex_cust_id
               and call_date = rcd_efex_call.call_date
               and user_id = rcd_efex_call.user_id;
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

end efxcdw14_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw14_loader for ods_app.efxcdw14_loader;
grant execute on ods_app.efxcdw14_loader to lics_app;
