/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw15_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw15_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Timesheet Call Data - EFEX to CDW

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

end efxcdw15_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw15_loader as

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
   rcd_efex_timesheet_call efex_timesheet_call%rowtype;

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
      lics_inbound_utility.set_definition('HDR','TIM_DATE',14);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','STE_ID',10);
      lics_inbound_utility.set_definition('HDR','SEG_ID',10);
      lics_inbound_utility.set_definition('HDR','BUS_ID',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME11',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME12',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME13',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME14',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME15',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME16',10);
      lics_inbound_utility.set_definition('HDR','TRV_TIME1',10);
      lics_inbound_utility.set_definition('HDR','TRV_KMS1',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME21',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME22',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME23',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME24',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME25',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME26',10);
      lics_inbound_utility.set_definition('HDR','TRV_TIME2',10);
      lics_inbound_utility.set_definition('HDR','TRV_KMS2',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME31',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME32',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME33',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME34',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME35',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME36',10);
      lics_inbound_utility.set_definition('HDR','TRV_TIME3',10);
      lics_inbound_utility.set_definition('HDR','TRV_KMS3',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME41',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME42',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME43',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME44',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME45',10);
      lics_inbound_utility.set_definition('HDR','CAL_TIME46',10);
      lics_inbound_utility.set_definition('HDR','TRV_TIME4',10);
      lics_inbound_utility.set_definition('HDR','TRV_KMS4',10);
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

      rcd_efex_timesheet_call.efex_cust_id := lics_inbound_utility.get_number('CUS_ID');
      rcd_efex_timesheet_call.timesheet_date := lics_inbound_utility.get_date('TIM_DATE','yyyymmddhh24miss');
      rcd_efex_timesheet_call.user_id := lics_inbound_utility.get_number('USR_ID');
      rcd_efex_timesheet_call.sales_terr_id := lics_inbound_utility.get_number('STE_ID');
      rcd_efex_timesheet_call.sgmnt_id := lics_inbound_utility.get_number('SEG_ID');
      rcd_efex_timesheet_call.bus_unit_id := lics_inbound_utility.get_number('BUS_ID');
      rcd_efex_timesheet_call.calltime1_1 := lics_inbound_utility.get_number('CAL_TIME11');
      rcd_efex_timesheet_call.calltime1_2 := lics_inbound_utility.get_number('CAL_TIME12');
      rcd_efex_timesheet_call.calltime1_3 := lics_inbound_utility.get_number('CAL_TIME13');
      rcd_efex_timesheet_call.calltime1_4 := lics_inbound_utility.get_number('CAL_TIME14');
      rcd_efex_timesheet_call.calltime1_5 := lics_inbound_utility.get_number('CAL_TIME15');
      rcd_efex_timesheet_call.calltime1_6 := lics_inbound_utility.get_number('CAL_TIME16');
      rcd_efex_timesheet_call.traveltime1 := lics_inbound_utility.get_number('TRV_TIME1');
      rcd_efex_timesheet_call.travelkms1 := lics_inbound_utility.get_number('TRV_KMS1');
      rcd_efex_timesheet_call.calltime2_1 := lics_inbound_utility.get_number('CAL_TIME21');
      rcd_efex_timesheet_call.calltime2_2 := lics_inbound_utility.get_number('CAL_TIME22');
      rcd_efex_timesheet_call.calltime2_3 := lics_inbound_utility.get_number('CAL_TIME23');
      rcd_efex_timesheet_call.calltime2_4 := lics_inbound_utility.get_number('CAL_TIME24');
      rcd_efex_timesheet_call.calltime2_5 := lics_inbound_utility.get_number('CAL_TIME25');
      rcd_efex_timesheet_call.calltime2_6 := lics_inbound_utility.get_number('CAL_TIME26');
      rcd_efex_timesheet_call.traveltime2 := lics_inbound_utility.get_number('TRV_TIME2');
      rcd_efex_timesheet_call.travelkms2 := lics_inbound_utility.get_number('TRV_KMS2');
      rcd_efex_timesheet_call.calltime3_1 := lics_inbound_utility.get_number('CAL_TIME31');
      rcd_efex_timesheet_call.calltime3_2 := lics_inbound_utility.get_number('CAL_TIME32');
      rcd_efex_timesheet_call.calltime3_3 := lics_inbound_utility.get_number('CAL_TIME33');
      rcd_efex_timesheet_call.calltime3_4 := lics_inbound_utility.get_number('CAL_TIME34');
      rcd_efex_timesheet_call.calltime3_5 := lics_inbound_utility.get_number('CAL_TIME35');
      rcd_efex_timesheet_call.calltime3_6 := lics_inbound_utility.get_number('CAL_TIME36');
      rcd_efex_timesheet_call.traveltime3 := lics_inbound_utility.get_number('TRV_TIME3');
      rcd_efex_timesheet_call.travelkms3 := lics_inbound_utility.get_number('TRV_KMS3');
      rcd_efex_timesheet_call.calltime4_1 := lics_inbound_utility.get_number('CAL_TIME41');
      rcd_efex_timesheet_call.calltime4_2 := lics_inbound_utility.get_number('CAL_TIME42');
      rcd_efex_timesheet_call.calltime4_3 := lics_inbound_utility.get_number('CAL_TIME43');
      rcd_efex_timesheet_call.calltime4_4 := lics_inbound_utility.get_number('CAL_TIME44');
      rcd_efex_timesheet_call.calltime4_5 := lics_inbound_utility.get_number('CAL_TIME45');
      rcd_efex_timesheet_call.calltime4_6 := lics_inbound_utility.get_number('CAL_TIME46');
      rcd_efex_timesheet_call.traveltime4 := lics_inbound_utility.get_number('TRV_TIME4');
      rcd_efex_timesheet_call.travelkms4 := lics_inbound_utility.get_number('TRV_KMS4');
      rcd_efex_timesheet_call.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_timesheet_call.valdtn_status := ods_constants.valdtn_unchecked;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_timesheet_call values rcd_efex_timesheet_call;
      exception
         when dup_val_on_index then
            update efex_timesheet_call
               set sales_terr_id = rcd_efex_timesheet_call.sales_terr_id,
                   sgmnt_id = rcd_efex_timesheet_call.sgmnt_id,
                   bus_unit_id = rcd_efex_timesheet_call.bus_unit_id,
                   calltime1_1 = rcd_efex_timesheet_call.calltime1_1,
                   calltime1_2 = rcd_efex_timesheet_call.calltime1_2,
                   calltime1_3 = rcd_efex_timesheet_call.calltime1_3,
                   calltime1_4 = rcd_efex_timesheet_call.calltime1_4,
                   calltime1_5 = rcd_efex_timesheet_call.calltime1_5,
                   calltime1_6 = rcd_efex_timesheet_call.calltime1_6,
                   traveltime1 = rcd_efex_timesheet_call.traveltime1,
                   travelkms1 = rcd_efex_timesheet_call.travelkms1,
                   calltime2_1 = rcd_efex_timesheet_call.calltime2_1,
                   calltime2_2 = rcd_efex_timesheet_call.calltime2_2,
                   calltime2_3 = rcd_efex_timesheet_call.calltime2_3,
                   calltime2_4 = rcd_efex_timesheet_call.calltime2_4,
                   calltime2_5 = rcd_efex_timesheet_call.calltime2_5,
                   calltime2_6 = rcd_efex_timesheet_call.calltime2_6,
                   traveltime2 = rcd_efex_timesheet_call.traveltime2,
                   travelkms2 = rcd_efex_timesheet_call.travelkms2,
                   calltime3_1 = rcd_efex_timesheet_call.calltime3_1,
                   calltime3_2 = rcd_efex_timesheet_call.calltime3_2,
                   calltime3_3 = rcd_efex_timesheet_call.calltime3_3,
                   calltime3_4 = rcd_efex_timesheet_call.calltime3_4,
                   calltime3_5 = rcd_efex_timesheet_call.calltime3_5,
                   calltime3_6 = rcd_efex_timesheet_call.calltime3_6,
                   traveltime3 = rcd_efex_timesheet_call.traveltime3,
                   travelkms3 = rcd_efex_timesheet_call.travelkms3,
                   calltime4_1 = rcd_efex_timesheet_call.calltime4_1,
                   calltime4_2 = rcd_efex_timesheet_call.calltime4_2,
                   calltime4_3 = rcd_efex_timesheet_call.calltime4_3,
                   calltime4_4 = rcd_efex_timesheet_call.calltime4_4,
                   calltime4_5 = rcd_efex_timesheet_call.calltime4_5,
                   calltime4_6 = rcd_efex_timesheet_call.calltime4_6,
                   traveltime4 = rcd_efex_timesheet_call.traveltime4,
                   travelkms4 = rcd_efex_timesheet_call.travelkms4,
                   status = rcd_efex_timesheet_call.status,
                   valdtn_status = rcd_efex_timesheet_call.valdtn_status
             where efex_cust_id = rcd_efex_timesheet_call.efex_cust_id 
               and timesheet_date = rcd_efex_timesheet_call.timesheet_date
               and user_id = rcd_efex_timesheet_call.user_id;
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

end efxcdw15_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw15_loader for ods_app.efxcdw15_loader;
grant execute on ods_app.efxcdw15_loader to lics_app;
