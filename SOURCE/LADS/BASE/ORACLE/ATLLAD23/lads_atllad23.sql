/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad23
 Owner   : lads_app
 Author  : Megan Henderson

 Description
 -----------
 Local Atlas Data Store - atllad23 - Intransit Stock Interface

 YYYY/MM   Author            Description
 -------   ------            -----------
 2004/11   Megan Henderson   Created
 2005/01   Linden Glen       Added processing for exidv2,inhalt,exti1,signi

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad23 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad23;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad23 as

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
   rcd_lads_int_stk_hdr lads_int_stk_hdr%rowtype;
   rcd_lads_int_stk_det lads_int_stk_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','BERID',10);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','BURKS',4);
      lics_inbound_utility.set_definition('DET','CLF01',2);
      lics_inbound_utility.set_definition('DET','LIFEX',35);
      lics_inbound_utility.set_definition('DET','VGBEL',10);
      lics_inbound_utility.set_definition('DET','VEND',10);
      lics_inbound_utility.set_definition('DET','TKNUM',10);
      lics_inbound_utility.set_definition('DET','VBELN',10);
      lics_inbound_utility.set_definition('DET','WERKS1',4);
      lics_inbound_utility.set_definition('DET','LOGORT1',4);
      lics_inbound_utility.set_definition('DET','WERKS2',4);
      lics_inbound_utility.set_definition('DET','LGORT',4);
      lics_inbound_utility.set_definition('DET','WERKS3',4);
      lics_inbound_utility.set_definition('DET','AEDAT',8);
      lics_inbound_utility.set_definition('DET','ZARDTE',8);
      lics_inbound_utility.set_definition('DET','VERAB',8);
      lics_inbound_utility.set_definition('DET','CHARG',10);
      lics_inbound_utility.set_definition('DET','ATWRT',8);
      lics_inbound_utility.set_definition('DET','VSBED',2);
      lics_inbound_utility.set_definition('DET','TDLNR',10);
      lics_inbound_utility.set_definition('DET','TRAIL',10);
      lics_inbound_utility.set_definition('DET','MATNR',18);
      lics_inbound_utility.set_definition('DET','LFIMG',15);
      lics_inbound_utility.set_definition('DET','MEINS',3);
      lics_inbound_utility.set_definition('DET','INSMK',1);
      lics_inbound_utility.set_definition('DET','BSART',4);
      lics_inbound_utility.set_definition('DET','EXIDV2',20);
      lics_inbound_utility.set_definition('DET','INHALT',40);
      lics_inbound_utility.set_definition('DET','EXTI1',20);
      lics_inbound_utility.set_definition('DET','SIGNI',20);
      lics_inbound_utility.set_definition('DET','RECORD_NB',15);
      lics_inbound_utility.set_definition('DET','RECORD_CNT',15);
      lics_inbound_utility.set_definition('DET','TIME',12);


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
      con_ack_code constant varchar2(32) := 'ATLLAD23';
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
            lads_atllad23_monitor.execute(rcd_lads_int_stk_hdr.werks);
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
      cursor csr_lads_int_stk_hdr_01 is
         select
            t01.werks,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_int_stk_hdr t01
         where t01.werks = rcd_lads_int_stk_hdr.werks;
      rcd_lads_int_stk_hdr_01 csr_lads_int_stk_hdr_01%rowtype;

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
      rcd_lads_int_stk_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_int_stk_hdr.berid := lics_inbound_utility.get_variable('BERID');
      rcd_lads_int_stk_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_int_stk_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_int_stk_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_int_stk_hdr.lads_date := sysdate;
      rcd_lads_int_stk_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_int_stk_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_int_stk_hdr.werks is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.WERKS');
         var_trn_error := true;
      end if;


      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_int_stk_hdr.werks is null) then
         var_exists := true;
         open csr_lads_int_stk_hdr_01;
         fetch csr_lads_int_stk_hdr_01 into rcd_lads_int_stk_hdr_01;
         if csr_lads_int_stk_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_int_stk_hdr_01;
         if var_exists = true then
            if rcd_lads_int_stk_hdr.idoc_timestamp > rcd_lads_int_stk_hdr_01.idoc_timestamp then
               delete from lads_int_stk_det where werks = rcd_lads_int_stk_hdr.werks;
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

      update lads_int_stk_hdr set
         berid = rcd_lads_int_stk_hdr.berid,
         idoc_name = rcd_lads_int_stk_hdr.idoc_name,
         idoc_number = rcd_lads_int_stk_hdr.idoc_number,
         idoc_timestamp = rcd_lads_int_stk_hdr.idoc_timestamp,
         lads_date = rcd_lads_int_stk_hdr.lads_date,
         lads_status = rcd_lads_int_stk_hdr.lads_status
      where werks = rcd_lads_int_stk_hdr.werks;
      if sql%notfound then
         insert into lads_int_stk_hdr
            (werks,
             berid,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_int_stk_hdr.werks,
             rcd_lads_int_stk_hdr.berid,
             rcd_lads_int_stk_hdr.idoc_name,
             rcd_lads_int_stk_hdr.idoc_number,
             rcd_lads_int_stk_hdr.idoc_timestamp,
             rcd_lads_int_stk_hdr.lads_date,
             rcd_lads_int_stk_hdr.lads_status);
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
      rcd_lads_int_stk_det.WERKS := rcd_lads_int_stk_hdr.WERKS;
      rcd_lads_int_stk_det.DETSEQ := rcd_lads_int_stk_det.DETSEQ + 1;
      rcd_lads_int_stk_det.BURKS := lics_inbound_utility.get_variable('BURKS');
      rcd_lads_int_stk_det.CLF01 := lics_inbound_utility.get_number('CLF01',null);
      rcd_lads_int_stk_det.LIFEX := lics_inbound_utility.get_variable('LIFEX');
      rcd_lads_int_stk_det.VGBEL := lics_inbound_utility.get_variable('VGBEL');
      rcd_lads_int_stk_det.VEND := lics_inbound_utility.get_variable('VEND');
      rcd_lads_int_stk_det.TKNUM := lics_inbound_utility.get_variable('TKNUM');
      rcd_lads_int_stk_det.VBELN := lics_inbound_utility.get_variable('VBELN');
      rcd_lads_int_stk_det.WERKS1 := lics_inbound_utility.get_variable('WERKS1');
      rcd_lads_int_stk_det.LOGORT1 := lics_inbound_utility.get_variable('LOGORT1');
      rcd_lads_int_stk_det.WERKS2 := lics_inbound_utility.get_variable('WERKS2');
      rcd_lads_int_stk_det.LGORT := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_int_stk_det.WERKS3 := lics_inbound_utility.get_variable('WERKS3');
      rcd_lads_int_stk_det.AEDAT := lics_inbound_utility.get_variable('AEDAT');
      rcd_lads_int_stk_det.ZARDTE := lics_inbound_utility.get_variable('ZARDTE');
      rcd_lads_int_stk_det.VERAB := lics_inbound_utility.get_variable('VERAB');
      rcd_lads_int_stk_det.CHARG := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_int_stk_det.ATWRT := lics_inbound_utility.get_variable('ATWRT');
      rcd_lads_int_stk_det.VSBED := lics_inbound_utility.get_variable('VSBED');
      rcd_lads_int_stk_det.TDLNR := lics_inbound_utility.get_variable('TDLNR');
      rcd_lads_int_stk_det.TRAIL := lics_inbound_utility.get_variable('TRAIL');
      rcd_lads_int_stk_det.MATNR := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_int_stk_det.LFIMG := lics_inbound_utility.get_number('LFIMG',null);
      rcd_lads_int_stk_det.MEINS := lics_inbound_utility.get_variable('MEINS');
      rcd_lads_int_stk_det.INSMK := lics_inbound_utility.get_variable('INSMK');
      rcd_lads_int_stk_det.BSART := lics_inbound_utility.get_variable('BSART');
      rcd_lads_int_stk_det.EXIDV2 := lics_inbound_utility.get_variable('EXIDV2');
      rcd_lads_int_stk_det.INHALT := lics_inbound_utility.get_variable('INHALT');
      rcd_lads_int_stk_det.EXTI1 := lics_inbound_utility.get_variable('EXTI1');
      rcd_lads_int_stk_det.SIGNI := lics_inbound_utility.get_variable('SIGNI');
      rcd_lads_int_stk_det.RECORD_NB := lics_inbound_utility.get_variable('RECORD_NB');
      rcd_lads_int_stk_det.RECORD_CNT := lics_inbound_utility.get_variable('RECORD_CNT');
      rcd_lads_int_stk_det.TIME := lics_inbound_utility.get_variable('TIME');


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

      if rcd_lads_int_stk_det.werks is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.WERKS');
         var_trn_error := true;
      end if;

      /*-----------------------------------------*/
      /* ERROR - Bypass the update when required */
      /*-----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into lads_int_stk_det
         (WERKS,
      	  DETSEQ,
          BURKS,
          CLF01,
          LIFEX,
          VGBEL,
          VEND,
          TKNUM,
          VBELN,
          WERKS1,
          LOGORT1,
          WERKS2,
          LGORT,
          WERKS3,
          AEDAT,
          ZARDTE,
          VERAB,
          CHARG,
          ATWRT,
          VSBED,
          TDLNR,
          TRAIL,
          MATNR,
          LFIMG,
          MEINS,
          INSMK,
          BSART,
          EXIDV2,
          INHALT,
          EXTI1,
          SIGNI,
          RECORD_NB,
          RECORD_CNT,
          TIME)
      values
         (rcd_lads_int_stk_det.WERKS,
          rcd_lads_int_stk_det.DETSEQ,
          rcd_lads_int_stk_det.BURKS,
          rcd_lads_int_stk_det.CLF01,
          rcd_lads_int_stk_det.LIFEX,
          rcd_lads_int_stk_det.VGBEL,
          rcd_lads_int_stk_det.VEND,
          rcd_lads_int_stk_det.TKNUM,
          rcd_lads_int_stk_det.VBELN,
          rcd_lads_int_stk_det.WERKS1,
          rcd_lads_int_stk_det.LOGORT1,
          rcd_lads_int_stk_det.WERKS2,
          rcd_lads_int_stk_det.LGORT,
          rcd_lads_int_stk_det.WERKS3,
          rcd_lads_int_stk_det.AEDAT,
          rcd_lads_int_stk_det.ZARDTE,
          rcd_lads_int_stk_det.VERAB,
          rcd_lads_int_stk_det.CHARG,
          rcd_lads_int_stk_det.ATWRT,
          rcd_lads_int_stk_det.VSBED,
          rcd_lads_int_stk_det.TDLNR,
          rcd_lads_int_stk_det.TRAIL,
          rcd_lads_int_stk_det.MATNR,
          rcd_lads_int_stk_det.LFIMG,
          rcd_lads_int_stk_det.MEINS,
          rcd_lads_int_stk_det.INSMK,
          rcd_lads_int_stk_det.BSART,
          rcd_lads_int_stk_det.EXIDV2,
          rcd_lads_int_stk_det.INHALT,
          rcd_lads_int_stk_det.EXTI1,
          rcd_lads_int_stk_det.SIGNI,
          rcd_lads_int_stk_det.RECORD_NB,
          rcd_lads_int_stk_det.RECORD_CNT,
          rcd_lads_int_stk_det.TIME);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad23;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad23 for lads_app.lads_atllad23;
grant execute on lads_atllad23 to lics_app;
