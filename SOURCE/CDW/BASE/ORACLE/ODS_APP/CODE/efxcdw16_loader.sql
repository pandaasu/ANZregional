/******************/
/* Package Header */
/******************/
create or replace package ods_app.efxcdw16_loader as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw16_loader
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Timesheet Day Data - EFEX to CDW

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

end efxcdw16_loader;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.efxcdw16_loader as

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
   rcd_efex_timesheet_day efex_timesheet_day%rowtype;

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
      lics_inbound_utility.set_definition('CTL','INT_ID',32);
      lics_inbound_utility.set_definition('CTL','MKT_ID',10);
      lics_inbound_utility.set_definition('CTL','EXT_ID',14);
      /*-*/
      lics_inbound_utility.set_definition('HDR','RCD_ID',3);
      lics_inbound_utility.set_definition('HDR','USR_ID',10);
      lics_inbound_utility.set_definition('HDR','TIM_DATE',14);
      lics_inbound_utility.set_definition('HDR','TIM_TIME1',10);
      lics_inbound_utility.set_definition('HDR','TIM_TIME2',10);
      lics_inbound_utility.set_definition('HDR','TIM_TIME3',10);
      lics_inbound_utility.set_definition('HDR','TIM_TIME4',10);
      lics_inbound_utility.set_definition('HDR','TIM_TIME5',10);
      lics_inbound_utility.set_definition('HDR','TIM_TIME6',10);
      lics_inbound_utility.set_definition('HDR','TRV_TIME',10);
      lics_inbound_utility.set_definition('HDR','TRV_KMS',10);
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

      rcd_efex_timesheet_day.user_id := lics_inbound_utility.get_number('USR_ID',null);
      rcd_efex_timesheet_day.timesheet_date := lics_inbound_utility.get_date('TIM_DATE','yyyymmddhh24miss');
      rcd_efex_timesheet_day.time1 := lics_inbound_utility.get_number('TIM_TIME1',null);
      rcd_efex_timesheet_day.time2 := lics_inbound_utility.get_number('TIM_TIME2',null);
      rcd_efex_timesheet_day.time3 := lics_inbound_utility.get_number('TIM_TIME3',null);
      rcd_efex_timesheet_day.time4 := lics_inbound_utility.get_number('TIM_TIME4',null);
      rcd_efex_timesheet_day.time5 := lics_inbound_utility.get_number('TIM_TIME5',null);
      rcd_efex_timesheet_day.time6 := lics_inbound_utility.get_number('TIM_TIME6',null);
      rcd_efex_timesheet_day.traveltime := lics_inbound_utility.get_number('TRV_TIME',null);
      rcd_efex_timesheet_day.travelkms := lics_inbound_utility.get_number('TRV_KMS',null);
      rcd_efex_timesheet_day.status := lics_inbound_utility.get_variable('STATUS');
      rcd_efex_timesheet_day.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_efex_timesheet_day.efex_mkt_id := var_trn_market;
      var_trn_count := var_trn_count + 1;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      begin
         insert into efex_timesheet_day values rcd_efex_timesheet_day;
      exception
         when dup_val_on_index then
            update efex_timesheet_day
               set time1 = rcd_efex_timesheet_day.time1,
                   time2 = rcd_efex_timesheet_day.time2,
                   time3 = rcd_efex_timesheet_day.time3,
                   time4 = rcd_efex_timesheet_day.time4,
                   time5 = rcd_efex_timesheet_day.time5,
                   time6 = rcd_efex_timesheet_day.time6,
                   traveltime = rcd_efex_timesheet_day.traveltime,
                   travelkms = rcd_efex_timesheet_day.travelkms,
                   status = rcd_efex_timesheet_day.status,
                   valdtn_status = rcd_efex_timesheet_day.valdtn_status,
                   efex_mkt_id = rcd_efex_timesheet_day.efex_mkt_id
             where user_id = rcd_efex_timesheet_day.user_id 
               and timesheet_date = rcd_efex_timesheet_day.timesheet_date;
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

end efxcdw16_loader;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym efxcdw16_loader for ods_app.efxcdw16_loader;
grant execute on ods_app.efxcdw16_loader to lics_app;
