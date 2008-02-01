/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad07
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad07 - Inbound Classification Master Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad07 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad07;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad07 as

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
   rcd_lads_cla_mas_hdr lads_cla_mas_hdr%rowtype;
   rcd_lads_cla_mas_det lads_cla_mas_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','KLART',3);
      lics_inbound_utility.set_definition('HDR','CLASS',18);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','ATNAM',30);
      lics_inbound_utility.set_definition('DET','POSNR',3);

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
      con_ack_code constant varchar2(32) := 'ATLLAD07';
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
         begin
            lads_atllad07_monitor.execute(rcd_lads_cla_mas_hdr.klart, rcd_lads_cla_mas_hdr.class);
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
      cursor csr_lads_cla_mas_hdr_01 is
         select
            t01.klart,
            t01.class,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_cla_mas_hdr t01
         where t01.klart = rcd_lads_cla_mas_hdr.klart
           and t01.class = rcd_lads_cla_mas_hdr.class;
      rcd_lads_cla_mas_hdr_01 csr_lads_cla_mas_hdr_01%rowtype;

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
      rcd_lads_cla_mas_hdr.klart := lics_inbound_utility.get_variable('KLART');
      rcd_lads_cla_mas_hdr.class := lics_inbound_utility.get_variable('CLASS');
      rcd_lads_cla_mas_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_cla_mas_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_cla_mas_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_cla_mas_hdr.lads_date := sysdate;
      rcd_lads_cla_mas_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_cla_mas_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_cla_mas_hdr.klart is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.KLART');
         var_trn_error := true;
      end if;
      if rcd_lads_cla_mas_hdr.class is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.CLASS');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_cla_mas_hdr.klart is null) and
         not(rcd_lads_cla_mas_hdr.class is null) then
         var_exists := true;
         open csr_lads_cla_mas_hdr_01;
         fetch csr_lads_cla_mas_hdr_01 into rcd_lads_cla_mas_hdr_01;
         if csr_lads_cla_mas_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_cla_mas_hdr_01;
         if var_exists = true then
            if rcd_lads_cla_mas_hdr.idoc_timestamp > rcd_lads_cla_mas_hdr_01.idoc_timestamp then
               delete from lads_cla_mas_det where klart = rcd_lads_cla_mas_hdr.klart
                                              and class = rcd_lads_cla_mas_hdr.class;
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

      update lads_cla_mas_hdr set
         idoc_name = rcd_lads_cla_mas_hdr.idoc_name,
         idoc_number = rcd_lads_cla_mas_hdr.idoc_number,
         idoc_timestamp = rcd_lads_cla_mas_hdr.idoc_timestamp,
         lads_date = rcd_lads_cla_mas_hdr.lads_date,
         lads_status = rcd_lads_cla_mas_hdr.lads_status
      where klart = rcd_lads_cla_mas_hdr.klart
        and class = rcd_lads_cla_mas_hdr.class;
      if sql%notfound then
         insert into lads_cla_mas_hdr
            (klart,
             class,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_cla_mas_hdr.klart,
             rcd_lads_cla_mas_hdr.class,
             rcd_lads_cla_mas_hdr.idoc_name,
             rcd_lads_cla_mas_hdr.idoc_number,
             rcd_lads_cla_mas_hdr.idoc_timestamp,
             rcd_lads_cla_mas_hdr.lads_date,
             rcd_lads_cla_mas_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record DET routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

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
      rcd_lads_cla_mas_det.klart := rcd_lads_cla_mas_hdr.klart;
      rcd_lads_cla_mas_det.class := rcd_lads_cla_mas_hdr.class;
      rcd_lads_cla_mas_det.detseq := rcd_lads_cla_mas_det.detseq + 1;
      rcd_lads_cla_mas_det.atnam := lics_inbound_utility.get_variable('ATNAM');
      rcd_lads_cla_mas_det.posnr := lics_inbound_utility.get_number('POSNR',null);

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
      if rcd_lads_cla_mas_det.klart is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.KLART');
         var_trn_error := true;
      end if;
      if rcd_lads_cla_mas_det.class is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.CLASS');
         var_trn_error := true;
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

      insert into lads_cla_mas_det
         (klart,
          class,
          detseq,
          atnam,
          posnr)
      values
         (rcd_lads_cla_mas_det.klart,
          rcd_lads_cla_mas_det.class,
          rcd_lads_cla_mas_det.detseq,
          rcd_lads_cla_mas_det.atnam,
          rcd_lads_cla_mas_det.posnr);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad07;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad07 for lads_app.lads_atllad07;
grant execute on lads_atllad07 to lics_app;
