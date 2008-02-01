/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad29
 Owner   : lads_app
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_lads_atllad29 - LADS Planned Process Orders

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad29 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad29;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad29 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_hdr(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_ppo_hdr lads_ppo_hdr%rowtype;

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
      var_trn_start := false;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CTL','IDENTIFIER',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HDR','LOCATION',10);
      lics_inbound_utility.set_definition('HDR','COCO',4);
      lics_inbound_utility.set_definition('HDR','LINE',30);
      lics_inbound_utility.set_definition('HDR','ITEM',18);
      lics_inbound_utility.set_definition('HDR','ORDER_PROFIL',4);
      lics_inbound_utility.set_definition('HDR','MRP_AREA',8);
      lics_inbound_utility.set_definition('HDR','SEQ_RESOURCE',8);
      lics_inbound_utility.set_definition('HDR','START_DATE_TIME',16);
      lics_inbound_utility.set_definition('HDR','END_DATE_TIME',16);
      lics_inbound_utility.set_definition('HDR','QUANTITY',16);
      lics_inbound_utility.set_definition('HDR','ORDER_ID',12);
      lics_inbound_utility.set_definition('HDR','ORDER_STATUS',5);
      lics_inbound_utility.set_definition('HDR','MP_RESOURCE',10);
      lics_inbound_utility.set_definition('HDR','SEGMENT',2);
      lics_inbound_utility.set_definition('HDR','ACHIEVEMENT',16);
      lics_inbound_utility.set_definition('HDR','UOM',3);
      lics_inbound_utility.set_definition('HDR','MAT_TYPE',4);

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* End the IDOC acknowledgement
      /*-*/
      ics_cisatl16.end_acknowledgement;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
   procedure complete_transaction is

      /*-*/
      /* Local definitions
      /*-*/
      con_ack_group constant varchar2(32) := 'LADS_IDOC_ACK';
      con_ack_code constant varchar2(32) := 'LADS_ATLLAD29';
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false Then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true Then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         commit;
         begin
            lads_atllad29_monitor.execute(rcd_lads_ppo_hdr.order_id);
         exception
            when others then
                lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
      end if;

      /*-*/
      /* Add the IDOC acknowledgement
      /*-*/
      if upper(lics_setting_configuration.retrieve_setting(con_ack_group, con_ack_code)) = 'Y' then
         if var_accepted = false then
            ics_cisatl16.add_document(to_char(rcd_lads_control.idoc_number,'FM0000000000000000'),
                                      to_char(sysdate,'YYYYMMDD'),
                                      to_char(sysdate,'HH24MISS'),
                                      '40');
         else
            ics_cisatl16.add_document(to_char(rcd_lads_control.idoc_number,'FM0000000000000000'),
                                      to_char(sysdate,'YYYYMMDD'),
                                      to_char(sysdate,'HH24MISS'),
                                      '41');
         end if;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;

   /**************************************************/
   /* This procedure performs the record CTL routine */
   /**************************************************/
   procedure process_record_ctl(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Reset the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Parse the data record
      /*-*/
      lics_inbound_utility.parse_record('CTL', par_record);

      /*-*/
      /* Extract and validate the control IDOC name
      /*-*/
      rcd_lads_control.idoc_name := lics_inbound_utility.get_variable('IDOC_NAME');
      if rcd_lads_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_lads_control.idoc_number := lics_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_lads_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_lads_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_DATE') || lics_inbound_utility.get_variable('IDOC_TIME');
      if rcd_lads_control.idoc_timestamp is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_TIMESTAMP - Must not be null');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_ctl;

   /**************************************************/
   /* This procedure performs the record HDR routine */
   /**************************************************/
   procedure process_record_hdr(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ppo_hdr_01 is
         select
            t01.order_id,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_ppo_hdr t01
         where t01.order_id = rcd_lads_ppo_hdr.order_id;
      rcd_lads_ppo_hdr_01 csr_lads_ppo_hdr_01%rowtype;

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

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ppo_hdr.location := lics_inbound_utility.get_variable('LOCATION');
      rcd_lads_ppo_hdr.coco := lics_inbound_utility.get_variable('COCO');
      rcd_lads_ppo_hdr.line := lics_inbound_utility.get_variable('LINE');
      rcd_lads_ppo_hdr.item := lics_inbound_utility.get_variable('ITEM');
      rcd_lads_ppo_hdr.order_profil := lics_inbound_utility.get_variable('ORDER_PROFIL');
      rcd_lads_ppo_hdr.mrp_area := lics_inbound_utility.get_variable('MRP_AREA');
      rcd_lads_ppo_hdr.seq_resource := lics_inbound_utility.get_variable('SEQ_RESOURCE');
      rcd_lads_ppo_hdr.start_date_time := lics_inbound_utility.get_number('START_DATE_TIME',null);
      rcd_lads_ppo_hdr.end_date_time := lics_inbound_utility.get_number('END_DATE_TIME',null);
      rcd_lads_ppo_hdr.quantity := lics_inbound_utility.get_number('QUANTITY',null);
      rcd_lads_ppo_hdr.order_id := lics_inbound_utility.get_variable('ORDER_ID');
      rcd_lads_ppo_hdr.order_status := lics_inbound_utility.get_variable('ORDER_STATUS');
      rcd_lads_ppo_hdr.mp_resource := lics_inbound_utility.get_variable('MP_RESOURCE');
      rcd_lads_ppo_hdr.segment := lics_inbound_utility.get_variable('SEGMENT');
      rcd_lads_ppo_hdr.achievement := lics_inbound_utility.get_number('ACHIEVEMENT',null);
      rcd_lads_ppo_hdr.uom := lics_inbound_utility.get_variable('UOM');
      rcd_lads_ppo_hdr.mat_type := lics_inbound_utility.get_variable('MAT_TYPE');
      rcd_lads_ppo_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_ppo_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_ppo_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_ppo_hdr.lads_date := sysdate;
      rcd_lads_ppo_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ppo_hdr.order_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_PPO_HDR - ORDER_ID');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_ppo_hdr.order_id is null) then
         var_exists := true;
         open csr_lads_ppo_hdr_01;
         fetch csr_lads_ppo_hdr_01 into rcd_lads_ppo_hdr_01;
         if csr_lads_ppo_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_ppo_hdr_01;
         if var_exists = true then
            if rcd_lads_ppo_hdr.idoc_timestamp > rcd_lads_ppo_hdr_01.idoc_timestamp then
               null;
            else
               var_trn_ignore := true;
            end if;
         end if;
      end if;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      update lads_ppo_hdr set
         location = rcd_lads_ppo_hdr.location,
         coco = rcd_lads_ppo_hdr.coco,
         line = rcd_lads_ppo_hdr.line,
         item = rcd_lads_ppo_hdr.item,
         order_profil = rcd_lads_ppo_hdr.order_profil,
         mrp_area = rcd_lads_ppo_hdr.mrp_area,
         seq_resource = rcd_lads_ppo_hdr.seq_resource,
         start_date_time = rcd_lads_ppo_hdr.start_date_time,
         end_date_time = rcd_lads_ppo_hdr.end_date_time,
         quantity = rcd_lads_ppo_hdr.quantity,
         order_id = rcd_lads_ppo_hdr.order_id,
         order_status = rcd_lads_ppo_hdr.order_status,
         mp_resource = rcd_lads_ppo_hdr.mp_resource,
         segment = rcd_lads_ppo_hdr.segment,
         achievement = rcd_lads_ppo_hdr.achievement,
         uom = rcd_lads_ppo_hdr.uom,
         mat_type = rcd_lads_ppo_hdr.mat_type,
         idoc_name = rcd_lads_ppo_hdr.idoc_name,
         idoc_number = rcd_lads_ppo_hdr.idoc_number,
         idoc_timestamp = rcd_lads_ppo_hdr.idoc_timestamp,
         lads_date = rcd_lads_ppo_hdr.lads_date,
         lads_status = rcd_lads_ppo_hdr.lads_status
      where order_id = rcd_lads_ppo_hdr.order_id;
      if sql%notfound then
         insert into lads_ppo_hdr
            (location,
             coco,
             line,
             item,
             order_profil,
             mrp_area,
             seq_resource,
             start_date_time,
             end_date_time,
             quantity,
             order_id,
             order_status,
             mp_resource,
             segment,
             achievement,
             uom,
             mat_type,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_ppo_hdr.location,
             rcd_lads_ppo_hdr.coco,
             rcd_lads_ppo_hdr.line,
             rcd_lads_ppo_hdr.item,
             rcd_lads_ppo_hdr.order_profil,
             rcd_lads_ppo_hdr.mrp_area,
             rcd_lads_ppo_hdr.seq_resource,
             rcd_lads_ppo_hdr.start_date_time,
             rcd_lads_ppo_hdr.end_date_time,
             rcd_lads_ppo_hdr.quantity,
             rcd_lads_ppo_hdr.order_id,
             rcd_lads_ppo_hdr.order_status,
             rcd_lads_ppo_hdr.mp_resource,
             rcd_lads_ppo_hdr.segment,
             rcd_lads_ppo_hdr.achievement,
             rcd_lads_ppo_hdr.uom,
             rcd_lads_ppo_hdr.mat_type,
             rcd_lads_ppo_hdr.idoc_name,
             rcd_lads_ppo_hdr.idoc_number,
             rcd_lads_ppo_hdr.idoc_timestamp,
             rcd_lads_ppo_hdr.lads_date,
             rcd_lads_ppo_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end lads_atllad29;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad29 for lads_app.lads_atllad29;
grant execute on lads_atllad29 to lics_app;
