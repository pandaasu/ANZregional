/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad22
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad22 - Inbound Exchange Rate Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad22 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad22;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad22 as

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
   procedure process_record_det(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_xch_rat_det lads_xch_rat_det%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','LOG_SYSTEM',10);
      lics_inbound_utility.set_definition('HDR','UPD_ALLOW',1);
      lics_inbound_utility.set_definition('HDR','CHG_FIXED',1);
      lics_inbound_utility.set_definition('HDR','DEV_ALLOW',3);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','RATE_TYPE',4);
      lics_inbound_utility.set_definition('DET','FROM_CURR',5);
      lics_inbound_utility.set_definition('DET','TO_CURRNCY',5);
      lics_inbound_utility.set_definition('DET','VALID_FROM',8);
      lics_inbound_utility.set_definition('DET','EXCH_RATE',15);
      lics_inbound_utility.set_definition('DET','FROM_FACTOR',9);
      lics_inbound_utility.set_definition('DET','TO_FACTOR',9);
      lics_inbound_utility.set_definition('DET','EXCH_RATE_V',15);
      lics_inbound_utility.set_definition('DET','FROM_FACTOR_V',9);
      lics_inbound_utility.set_definition('DET','TO_FACTOR_V',9);

      /*-*/
      /* Start the IDOC acknowledgement
      /*-*/
      ics_cisatl16.start_acknowledgement;

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
         when 'DET' then process_record_det(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD22';
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         commit;
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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-----------------------------*/
      /* IGNORE - Ignore the HDR row */
      /*-----------------------------*/

      return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_xch_rat_det_01 is
         select
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_xch_rat_det t01
         where t01.rate_type = rcd_lads_xch_rat_det.rate_type
           and t01.from_curr = rcd_lads_xch_rat_det.from_curr
           and t01.to_currncy = rcd_lads_xch_rat_det.to_currncy
           and t01.valid_from = rcd_lads_xch_rat_det.valid_from;
      rcd_lads_xch_rat_det_01 csr_lads_xch_rat_det_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_xch_rat_det.rate_type := lics_inbound_utility.get_variable('RATE_TYPE');
      rcd_lads_xch_rat_det.from_curr := lics_inbound_utility.get_variable('FROM_CURR');
      rcd_lads_xch_rat_det.to_currncy := lics_inbound_utility.get_variable('TO_CURRNCY');
      rcd_lads_xch_rat_det.valid_from := lics_inbound_utility.get_variable('VALID_FROM');
      rcd_lads_xch_rat_det.exch_rate := lics_inbound_utility.get_number('EXCH_RATE',null);
      rcd_lads_xch_rat_det.from_factor := lics_inbound_utility.get_number('FROM_FACTOR',null);
      rcd_lads_xch_rat_det.to_factor := lics_inbound_utility.get_number('TO_FACTOR',null);
      rcd_lads_xch_rat_det.exch_rate_v := lics_inbound_utility.get_number('EXCH_RATE_V',null);
      rcd_lads_xch_rat_det.from_factor_v := lics_inbound_utility.get_number('FROM_FACTOR_V',null);
      rcd_lads_xch_rat_det.to_factor_v := lics_inbound_utility.get_number('TO_FACTOR_V',null);
      rcd_lads_xch_rat_det.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_xch_rat_det.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_xch_rat_det.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_xch_rat_det.lads_date := sysdate;
      rcd_lads_xch_rat_det.lads_status := '1';

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
      if rcd_lads_xch_rat_det.rate_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.RATE_TYPE');
         var_trn_error := true;
      end if;
      if rcd_lads_xch_rat_det.from_curr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FROM_CURR');
         var_trn_error := true;
      end if;
      if rcd_lads_xch_rat_det.to_currncy is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.TO_CURRNCY');
         var_trn_error := true;
      end if;
      if rcd_lads_xch_rat_det.valid_from is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.VALID_FROM');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_xch_rat_det.rate_type is null) and
         not(rcd_lads_xch_rat_det.from_curr is null) and
         not(rcd_lads_xch_rat_det.to_currncy is null) and
         not(rcd_lads_xch_rat_det.valid_from is null) then
         var_exists := true;
         open csr_lads_xch_rat_det_01;
         fetch csr_lads_xch_rat_det_01 into rcd_lads_xch_rat_det_01;
         if csr_lads_xch_rat_det_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_xch_rat_det_01;
         if var_exists = true then
            if rcd_lads_xch_rat_det.idoc_timestamp <= rcd_lads_xch_rat_det_01.idoc_timestamp then
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

      update lads_xch_rat_det set
         exch_rate = rcd_lads_xch_rat_det.exch_rate,
         from_factor = rcd_lads_xch_rat_det.from_factor,
         to_factor = rcd_lads_xch_rat_det.to_factor,
         exch_rate_v = rcd_lads_xch_rat_det.exch_rate_v,
         from_factor_v = rcd_lads_xch_rat_det.from_factor_v,
         to_factor_v = rcd_lads_xch_rat_det.to_factor_v,
         idoc_name = rcd_lads_xch_rat_det.idoc_name,
         idoc_number = rcd_lads_xch_rat_det.idoc_number,
         idoc_timestamp = rcd_lads_xch_rat_det.idoc_timestamp,
         lads_date = rcd_lads_xch_rat_det.lads_date,
         lads_status = rcd_lads_xch_rat_det.lads_status
      where rate_type = rcd_lads_xch_rat_det.rate_type
        and from_curr = rcd_lads_xch_rat_det.from_curr
        and to_currncy = rcd_lads_xch_rat_det.to_currncy
        and valid_from = rcd_lads_xch_rat_det.valid_from;
      if sql%notfound then
         insert into lads_xch_rat_det
            (rate_type,
             from_curr,
             to_currncy,
             valid_from,
             exch_rate,
             from_factor,
             to_factor,
             exch_rate_v,
             from_factor_v,
             to_factor_v,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_xch_rat_det.rate_type,
             rcd_lads_xch_rat_det.from_curr,
             rcd_lads_xch_rat_det.to_currncy,
             rcd_lads_xch_rat_det.valid_from,
             rcd_lads_xch_rat_det.exch_rate,
             rcd_lads_xch_rat_det.from_factor,
             rcd_lads_xch_rat_det.to_factor,
             rcd_lads_xch_rat_det.exch_rate_v,
             rcd_lads_xch_rat_det.from_factor_v,
             rcd_lads_xch_rat_det.to_factor_v,
             rcd_lads_xch_rat_det.idoc_name,
             rcd_lads_xch_rat_det.idoc_number,
             rcd_lads_xch_rat_det.idoc_timestamp,
             rcd_lads_xch_rat_det.lads_date,
             rcd_lads_xch_rat_det.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad22;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad22 for lads_app.lads_atllad22;
grant execute on lads_atllad22 to lics_app;
