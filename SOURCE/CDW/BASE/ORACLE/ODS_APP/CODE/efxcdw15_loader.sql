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
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_error boolean;
   var_trn_count number;
   var_trn_interface varchar2(32);
   var_trn_market number;
   var_trn_extract varchar2(14);
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
      var_trn_count := 0;
      var_trn_interface := null;
      var_trn_market := 0;
      var_trn_extract := null;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','RCD_ID',3);
      lics_inbound_utility.set_definition('CTL','INT_ID',10);
      lics_inbound_utility.set_definition('CTL','MKT_ID',10);
      lics_inbound_utility.set_definition('CTL','EXT_ID',14);
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
         when 'CTL' then process_record_ctl(par_record);
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
         efxcdw00_loader.update_interface(var_trn_interface, var_trn_market, var_trn_extract, var_trn_count);
         commit;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('CTL', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      var_trn_interface := lics_inbound_utility.get_variable('INT_ID');
      var_trn_market := lics_inbound_utility.get_number('MKT_ID',null);
      var_trn_extract := lics_inbound_utility.get_variable('EXT_ID');

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
   end process_record_ctl;

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

      rcd_efex_timesheet_call.efex_cust_id := lics_inbound_utility.get_number('CUS_ID',null);
      rcd_efex_timesheet_call.timesheet_date := lics_inbound_utility.get_date('TIM_DATE','yyyymmddhh24miss');
      rcd_efex_timesheet_call.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_timesheet_call.sales_terr_id := lics_inbound_utility.get_number('STE_ID',null);
      rcd_efex_timesheet_call.sgmnt_id := lics_inbound_utility.get_number('SEG_ID',null);
      rcd_efex_timesheet_call.bus_unit_id := lics_inbound_utility.get_number('BUS_ID',null);
      rcd_efex_timesheet_call.calltime1_1 := lics_inbound_utility.get_number('CAL_TIME11',null);
      rcd_efex_timesheet_call.calltime1_2 := lics_inbound_utility.get_number('CAL_TIME12',null);
      rcd_efex_timesheet_call.calltime1_3 := lics_inbound_utility.get_number('CAL_TIME13',null);
      rcd_efex_timesheet_call.calltime1_4 := lics_inbound_utility.get_number('CAL_TIME14',null);
      rcd_efex_timesheet_call.calltime1_5 := lics_inbound_utility.get_number('CAL_TIME15',null);
      rcd_efex_timesheet_call.calltime1_6 := lics_inbound_utility.get_number('CAL_TIME16',null);
      rcd_efex_timesheet_call.traveltime1 := lics_inbound_utility.get_number('TRV_TIME1',null);
      rcd_efex_timesheet_call.travelkms1 := lics_inbound_utility.get_number('TRV_KMS1',null);
      rcd_efex_timesheet_call.calltime2_1 := lics_inbound_utility.get_number('CAL_TIME21',null);
      rcd_efex_timesheet_call.calltime2_2 := lics_inbound_utility.get_number('CAL_TIME22',null);
      rcd_efex_timesheet_call.calltime2_3 := lics_inbound_utility.get_number('CAL_TIME23',null);
      rcd_efex_timesheet_call.calltime2_4 := lics_inbound_utility.get_number('CAL_TIME24',null);
      rcd_efex_timesheet_call.calltime2_5 := lics_inbound_utility.get_number('CAL_TIME25',null);
      rcd_efex_timesheet_call.calltime2_6 := lics_inbound_utility.get_number('CAL_TIME26',null);
      rcd_efex_timesheet_call.traveltime2 := lics_inbound_utility.get_number('TRV_TIME2',null);
      rcd_efex_timesheet_call.travelkms2 := lics_inbound_utility.get_number('TRV_KMS2',null);
      rcd_efex_timesheet_call.calltime3_1 := lics_inbound_utility.get_number('CAL_TIME31',null);
      rcd_efex_timesheet_call.calltime3_2 := lics_inbound_utility.get_number('CAL_TIME32',null);
      rcd_efex_timesheet_call.calltime3_3 := lics_inbound_utility.get_number('CAL_TIME33',null);
      rcd_efex_timesheet_call.calltime3_4 := lics_inbound_utility.get_number('CAL_TIME34',null);
      rcd_efex_timesheet_call.calltime3_5 := lics_inbound_utility.get_number('CAL_TIME35',null);
      rcd_efex_timesheet_call.calltime3_6 := lics_inbound_utility.get_number('CAL_TIME36',null);
      rcd_efex_timesheet_call.traveltime3 := lics_inbound_utility.get_number('TRV_TIME3',null);
      rcd_efex_timesheet_call.travelkms3 := lics_inbound_utility.get_number('TRV_KMS3',null);
      rcd_efex_timesheet_call.calltime4_1 := lics_inbound_utility.get_number('CAL_TIME41',null);
      rcd_efex_timesheet_call.calltime4_2 := lics_inbound_utility.get_number('CAL_TIME42',null);
      rcd_efex_timesheet_call.calltime4_3 := lics_inbound_utility.get_number('CAL_TIME43',null);
      rcd_efex_timesheet_call.calltime4_4 := lics_inbound_utility.get_number('CAL_TIME44',null);
      rcd_efex_timesheet_call.calltime4_5 := lics_inbound_utility.get_number('CAL_TIME45',null);
      rcd_efex_timesheet_call.calltime4_6 := lics_inbound_utility.get_number('CAL_TIME46',null);
      rcd_efex_timesheet_call.traveltime4 := lics_inbound_utility.get_number('TRV_TIME4',null);
      rcd_efex_timesheet_call.travelkms4 := lics_inbound_utility.get_number('TRV_KMS4',null);
      rcd_efex_timesheet_call.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_timesheet_call.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_timesheet_call.efex_mkt_id := var_trn_market;
      var_trn_count := var_trn_count + 1;

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
                   valdtn_status = rcd_efex_timesheet_call.valdtn_status,
                   efex_mkt_id = rcd_efex_timesheet_call.efex_mkt_id
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
