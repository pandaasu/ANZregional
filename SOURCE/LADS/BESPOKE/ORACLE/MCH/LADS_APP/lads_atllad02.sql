/******************/
/* Package Header */
/******************/
create or replace package lads_atllad02 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad02
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad02 - Inbound Stock Balance Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2007/03   Steve Gregan   Updated locking strategy
                             Changed IDOC timestamp check from < to <
    2008/05   Trevor Keon    Added calls to monitor before and after procedure

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad02;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad02 as

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
   rcd_lads_stk_bal_hdr lads_stk_bal_hdr%rowtype;
   rcd_lads_stk_bal_det lads_stk_bal_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','BUKRS',3);
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','LGORT',4);
      lics_inbound_utility.set_definition('HDR','BUDAT',8);
      lics_inbound_utility.set_definition('HDR','CREDAT',8);
      lics_inbound_utility.set_definition('HDR','CRETIM',6);
      lics_inbound_utility.set_definition('HDR','VBUND',6);
      lics_inbound_utility.set_definition('HDR','TIMLO',8);
      lics_inbound_utility.set_definition('HDR','MBLNR',10);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','MATNR',18);
      lics_inbound_utility.set_definition('DET','CHARG',10);
      lics_inbound_utility.set_definition('DET','SOBKZ',1);
      lics_inbound_utility.set_definition('DET','MENGA',15);
      lics_inbound_utility.set_definition('DET','ALTME',3);
      lics_inbound_utility.set_definition('DET','VFDAT',8);
      lics_inbound_utility.set_definition('DET','KUNNR',10);
      lics_inbound_utility.set_definition('DET','UMLGO',4);
      lics_inbound_utility.set_definition('DET','INSMK',2);

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
      con_ack_code constant varchar2(32) := 'ATLLAD02';
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
      /* Execute the interface monitor/flattening when required
      /*-*/
      if var_trn_ignore = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := true;
         rollback;

      elsif var_trn_error = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the IDOC transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := false;
         rollback;

      else

         /*-*/
         /* Set the transaction accepted indicator
         /*-*/
         var_accepted := true;

         /*-*/
         /* Execute the interface monitor/flattening
         /* **note** - savepoint is established to ensure IDOC transaction commit
         /*          - child procedure can see IDOC transaction data as part of same commit cycle
         /*          - child procedure must NOT issue commit/rollback
         /*          - child procedure must raise an exception on failure
         /*          - update the LADS flattened flag on success
         /*          - savepoint is used for child procedure failure
         /*-*/
         savepoint transaction_savepoint;
         begin
            lads_atllad02_monitor.execute_before(rcd_lads_stk_bal_hdr.bukrs,
                                          rcd_lads_stk_bal_hdr.werks,
                                          rcd_lads_stk_bal_hdr.lgort,
                                          rcd_lads_stk_bal_hdr.budat,
                                          rcd_lads_stk_bal_hdr.timlo);
         exception
            when others then
               rollback to transaction_savepoint;
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;

         /*-*/
         /* Commit the IDOC transaction and successful monitor code
         /* **note** - releases transaction lock
         /*-*/
         commit;
         
         begin
            lads_atllad02_monitor.execute_after(rcd_lads_stk_bal_hdr.bukrs,
                                          rcd_lads_stk_bal_hdr.werks,
                                          rcd_lads_stk_bal_hdr.lgort,
                                          rcd_lads_stk_bal_hdr.budat,
                                          rcd_lads_stk_bal_hdr.timlo);
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
      var_idoc_timestamp lads_adr_hdr.idoc_timestamp%type;

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
      rcd_lads_stk_bal_hdr.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_lads_stk_bal_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_stk_bal_hdr.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_stk_bal_hdr.budat := lics_inbound_utility.get_variable('BUDAT');
      rcd_lads_stk_bal_hdr.credat := lics_inbound_utility.get_variable('CREDAT');
      rcd_lads_stk_bal_hdr.cretim := lics_inbound_utility.get_variable('CRETIM');
      rcd_lads_stk_bal_hdr.vbund := lics_inbound_utility.get_variable('VBUND');
      rcd_lads_stk_bal_hdr.timlo := lics_inbound_utility.get_variable('TIMLO');
      rcd_lads_stk_bal_hdr.mblnr := lics_inbound_utility.get_variable('MBLNR');
      rcd_lads_stk_bal_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_stk_bal_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_stk_bal_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_stk_bal_hdr.lads_date := sysdate;
      rcd_lads_stk_bal_hdr.lads_status := '1';
      rcd_lads_stk_bal_hdr.lads_flattened := '0';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Intransit and consignment have no stock location
      /*-*/
      if rcd_lads_stk_bal_hdr.lgort is null then
         rcd_lads_stk_bal_hdr.lgort := '****';
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_stk_bal_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_stk_bal_hdr.bukrs is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BUKRS');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_hdr.werks is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.WERKS');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_hdr.lgort is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.LGORT');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_hdr.budat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BUDAT');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_hdr.timlo is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.TIMLO');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      /*----------------------------------------*/
      /* LOCK- Lock the interface transaction   */
      /*----------------------------------------*/

      /*-*/
      /* Lock the IDOC transaction
      /* **note** - attempt to lock the transaction header row (oracle default wait behaviour)
      /*              - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index
      /*              - update/update (exists) - logic goes to update and default wait behaviour
      /*          - validate the IDOC sequence when locking row exists
      /*          - lock and commit cycle encompasses transaction child procedure execution
      /*-*/
      begin
         insert into lads_stk_bal_hdr
            (bukrs,
             werks,
             lgort,
             budat,
             timlo,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status,
             lads_flattened)
         values
            (rcd_lads_stk_bal_hdr.bukrs,
             rcd_lads_stk_bal_hdr.werks,
             rcd_lads_stk_bal_hdr.lgort,
             rcd_lads_stk_bal_hdr.budat,
             rcd_lads_stk_bal_hdr.timlo,
             rcd_lads_stk_bal_hdr.idoc_name,
             rcd_lads_stk_bal_hdr.idoc_number,
             rcd_lads_stk_bal_hdr.idoc_timestamp,
             rcd_lads_stk_bal_hdr.lads_date,
             rcd_lads_stk_bal_hdr.lads_status,
             rcd_lads_stk_bal_hdr.lads_flattened);
      exception
         when dup_val_on_index then
            update lads_stk_bal_hdr
               set lads_status = lads_status
             where bukrs = rcd_lads_stk_bal_hdr.bukrs
               and werks = rcd_lads_stk_bal_hdr.werks
               and lgort = rcd_lads_stk_bal_hdr.lgort
               and budat = rcd_lads_stk_bal_hdr.budat
               and timlo = rcd_lads_stk_bal_hdr.timlo
             returning idoc_timestamp into var_idoc_timestamp;
            if sql%found and var_idoc_timestamp <= rcd_lads_stk_bal_hdr.idoc_timestamp then
               delete from lads_stk_bal_det where bukrs = rcd_lads_stk_bal_hdr.bukrs
                                              and werks = rcd_lads_stk_bal_hdr.werks
                                              and lgort = rcd_lads_stk_bal_hdr.lgort
                                              and budat = rcd_lads_stk_bal_hdr.budat
                                              and timlo = rcd_lads_stk_bal_hdr.timlo;
            else
               var_trn_ignore := true;
            end if;
      end;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      if var_trn_ignore = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      update lads_stk_bal_hdr set
         credat = rcd_lads_stk_bal_hdr.credat,
         cretim = rcd_lads_stk_bal_hdr.cretim,
         vbund = rcd_lads_stk_bal_hdr.vbund,
         mblnr = rcd_lads_stk_bal_hdr.mblnr,
         idoc_name = rcd_lads_stk_bal_hdr.idoc_name,
         idoc_number = rcd_lads_stk_bal_hdr.idoc_number,
         idoc_timestamp = rcd_lads_stk_bal_hdr.idoc_timestamp,
         lads_date = rcd_lads_stk_bal_hdr.lads_date,
         lads_status = rcd_lads_stk_bal_hdr.lads_status,
         lads_flattened = rcd_lads_stk_bal_hdr.lads_flattened
      where bukrs = rcd_lads_stk_bal_hdr.bukrs
        and werks = rcd_lads_stk_bal_hdr.werks
        and lgort = rcd_lads_stk_bal_hdr.lgort
        and budat = rcd_lads_stk_bal_hdr.budat
        and timlo = rcd_lads_stk_bal_hdr.timlo;

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
      rcd_lads_stk_bal_det.bukrs := rcd_lads_stk_bal_hdr.bukrs;
      rcd_lads_stk_bal_det.werks := rcd_lads_stk_bal_hdr.werks;
      rcd_lads_stk_bal_det.lgort := rcd_lads_stk_bal_hdr.lgort;
      rcd_lads_stk_bal_det.budat := rcd_lads_stk_bal_hdr.budat;
      rcd_lads_stk_bal_det.timlo := rcd_lads_stk_bal_hdr.timlo;
      rcd_lads_stk_bal_det.detseq := rcd_lads_stk_bal_det.detseq + 1;
      rcd_lads_stk_bal_det.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_stk_bal_det.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_stk_bal_det.sobkz := lics_inbound_utility.get_variable('SOBKZ');
      rcd_lads_stk_bal_det.menga := lics_inbound_utility.get_number('MENGA',null);
      rcd_lads_stk_bal_det.altme := lics_inbound_utility.get_variable('ALTME');
      rcd_lads_stk_bal_det.vfdat := lics_inbound_utility.get_variable('VFDAT');
      rcd_lads_stk_bal_det.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_stk_bal_det.umlgo := lics_inbound_utility.get_variable('UMLGO');
      rcd_lads_stk_bal_det.insmk := lics_inbound_utility.get_variable('INSMK');

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
      if rcd_lads_stk_bal_det.bukrs is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.BUKRS');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_det.werks is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.WERKS');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_det.lgort is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.LGORT');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_det.budat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.BUDAT');
         var_trn_error := true;
      end if;
      if rcd_lads_stk_bal_det.timlo is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.TIMLO');
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

      insert into lads_stk_bal_det
         (bukrs,
          werks,
          lgort,
          budat,
          timlo,
          detseq,
          matnr,
          charg,
          sobkz,
          menga,
          altme,
          vfdat,
          kunnr,
          umlgo,
          insmk)
      values
         (rcd_lads_stk_bal_det.bukrs,
          rcd_lads_stk_bal_det.werks,
          rcd_lads_stk_bal_det.lgort,
          rcd_lads_stk_bal_det.budat,
          rcd_lads_stk_bal_det.timlo,
          rcd_lads_stk_bal_det.detseq,
          rcd_lads_stk_bal_det.matnr,
          rcd_lads_stk_bal_det.charg,
          rcd_lads_stk_bal_det.sobkz,
          rcd_lads_stk_bal_det.menga,
          rcd_lads_stk_bal_det.altme,
          rcd_lads_stk_bal_det.vfdat,
          rcd_lads_stk_bal_det.kunnr,
          rcd_lads_stk_bal_det.umlgo,
          rcd_lads_stk_bal_det.insmk);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad02;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad02 for lads_app.lads_atllad02;
grant execute on lads_atllad02 to lics_app;
