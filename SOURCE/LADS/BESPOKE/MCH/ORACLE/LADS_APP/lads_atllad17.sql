/******************/
/* Package Header */
/******************/
create or replace package lads_atllad17 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_atllad17
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - atllad17 - Inbound Bill Of Material Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2006/12   Linden Glen    Added STLST field to header processing
                             Updated locking strategy
                             Changed IDOC timestamp check from < to <=
    2007/05   Steve Gregan   Changed the BDS invoke logic to cover all HDR rows
    2008/05   Trevor Keon    Added calls to monitor before and after procedure

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad17;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad17 as

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
   rcd_lads_bom_hdr lads_bom_hdr%rowtype;
   rcd_lads_bom_det lads_bom_det%rowtype;
   type rcd_bds is record(stlal varchar2(2 char),
                          matnr varchar2(18 char),
                          werks varchar2(4 char));
   type typ_bds is table of rcd_bds index by binary_integer;
   tbl_bds typ_bds;

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
      lics_inbound_utility.set_definition('HDR','MSGFN',3);
      lics_inbound_utility.set_definition('HDR','STLNR',8);
      lics_inbound_utility.set_definition('HDR','STLAL',2);
      lics_inbound_utility.set_definition('HDR','MATNR',18);
      lics_inbound_utility.set_definition('HDR','WERKS',4);
      lics_inbound_utility.set_definition('HDR','STLAN',1);
      lics_inbound_utility.set_definition('HDR','DATUV',8);
      lics_inbound_utility.set_definition('HDR','DATUB',8);
      lics_inbound_utility.set_definition('HDR','BMENG',14);
      lics_inbound_utility.set_definition('HDR','BMEIN',3);
      lics_inbound_utility.set_definition('HDR','STLST',2);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','MSGFN',3);
      lics_inbound_utility.set_definition('DET','MATNR',18);
      lics_inbound_utility.set_definition('DET','STLAL',2);
      lics_inbound_utility.set_definition('DET','WERKS',4);
      lics_inbound_utility.set_definition('DET','POSNR',4);
      lics_inbound_utility.set_definition('DET','POSTP',1);
      lics_inbound_utility.set_definition('DET','IDNRK',18);
      lics_inbound_utility.set_definition('DET','MENGE',14);
      lics_inbound_utility.set_definition('DET','MEINS',3);
      lics_inbound_utility.set_definition('DET','DATUV',8);
      lics_inbound_utility.set_definition('DET','DATUB',8);

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
      con_ack_code constant varchar2(32) := 'ATLLAD17';
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
         /*          - savepoint is used for child procedure failure
         /*-*/
         savepoint transaction_savepoint;
         begin
            for idx in 1..tbl_bds.count loop
               lads_atllad17_monitor.execute_before(tbl_bds(idx).stlal, tbl_bds(idx).matnr, tbl_bds(idx).werks);
            end loop;
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
            for idx in 1..tbl_bds.count loop
               lads_atllad17_monitor.execute_after(tbl_bds(idx).stlal, tbl_bds(idx).matnr, tbl_bds(idx).werks);
            end loop;
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

      /*-*/
      /* Clear the BDS table
      /*-*/
      tbl_bds.delete;

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
      var_idoc_timestamp lads_mat_hdr.idoc_timestamp%type;
      var_index number(5,0);

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
      rcd_lads_bom_hdr.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_bom_hdr.stlnr := lics_inbound_utility.get_variable('STLNR');
      rcd_lads_bom_hdr.stlal := lics_inbound_utility.get_variable('STLAL');
      rcd_lads_bom_hdr.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_bom_hdr.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_bom_hdr.stlan := lics_inbound_utility.get_variable('STLAN');
      rcd_lads_bom_hdr.datuv := lics_inbound_utility.get_variable('DATUV');
      rcd_lads_bom_hdr.datub := lics_inbound_utility.get_variable('DATUB');
      rcd_lads_bom_hdr.bmeng := lics_inbound_utility.get_number('BMENG',null);
      rcd_lads_bom_hdr.bmein := lics_inbound_utility.get_variable('BMEIN');
      rcd_lads_bom_hdr.stlst := lics_inbound_utility.get_variable('STLST');
      rcd_lads_bom_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_bom_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_bom_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_bom_hdr.lads_date := sysdate;
      rcd_lads_bom_hdr.lads_status := '1';
      rcd_lads_bom_hdr.lads_flattened := '0';    

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_bom_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_bom_hdr.stlal is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.STLAL');
         var_trn_error := true;
      end if;
      if rcd_lads_bom_hdr.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.MATNR');
         var_trn_error := true;
      end if;
      if rcd_lads_bom_hdr.werks is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.WERKS');
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
         insert into lads_bom_hdr
            (msgfn,
             stlnr,
             stlal,
             matnr,
             werks,
             stlan,
             datuv,
             datub,
             bmeng,
             bmein,
             stlst,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status,
             lads_flattened)
         values
            (rcd_lads_bom_hdr.msgfn,
             rcd_lads_bom_hdr.stlnr,
             rcd_lads_bom_hdr.stlal,
             rcd_lads_bom_hdr.matnr,
             rcd_lads_bom_hdr.werks,
             rcd_lads_bom_hdr.stlan,
             rcd_lads_bom_hdr.datuv,
             rcd_lads_bom_hdr.datub,
             rcd_lads_bom_hdr.bmeng,
             rcd_lads_bom_hdr.bmein,
             rcd_lads_bom_hdr.stlst,
             rcd_lads_bom_hdr.idoc_name,
             rcd_lads_bom_hdr.idoc_number,
             rcd_lads_bom_hdr.idoc_timestamp,
             rcd_lads_bom_hdr.lads_date,
             rcd_lads_bom_hdr.lads_status,
             rcd_lads_bom_hdr.lads_flattened);
      exception
         when dup_val_on_index then
            update lads_bom_hdr
               set lads_status = lads_status
             where stlal = rcd_lads_bom_hdr.stlal
               and matnr = rcd_lads_bom_hdr.matnr
               and werks = rcd_lads_bom_hdr.werks
             returning idoc_timestamp into var_idoc_timestamp;
            if sql%found and var_idoc_timestamp <= rcd_lads_bom_hdr.idoc_timestamp then
               delete from lads_bom_det where stlal = rcd_lads_bom_hdr.stlal
                                          and matnr = rcd_lads_bom_hdr.matnr
                                          and werks = rcd_lads_bom_hdr.werks;
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

      update lads_bom_hdr set
         msgfn = rcd_lads_bom_hdr.msgfn,
         stlnr = rcd_lads_bom_hdr.stlnr,
         stlan = rcd_lads_bom_hdr.stlan,
         datuv = rcd_lads_bom_hdr.datuv,
         datub = rcd_lads_bom_hdr.datub,
         bmeng = rcd_lads_bom_hdr.bmeng,
         bmein = rcd_lads_bom_hdr.bmein,
         stlst = rcd_lads_bom_hdr.stlst,
         idoc_name = rcd_lads_bom_hdr.idoc_name,
         idoc_number = rcd_lads_bom_hdr.idoc_number,
         idoc_timestamp = rcd_lads_bom_hdr.idoc_timestamp,
         lads_date = rcd_lads_bom_hdr.lads_date,
         lads_status = rcd_lads_bom_hdr.lads_status,
         lads_flattened = rcd_lads_bom_hdr.lads_flattened
      where stlal = rcd_lads_bom_hdr.stlal
        and matnr = rcd_lads_bom_hdr.matnr
        and werks = rcd_lads_bom_hdr.werks;

      /*------------------------------*/
      /* SAVE - BDS key values        */
      /*------------------------------*/
      var_index := tbl_bds.count + 1;
      tbl_bds(var_index).stlal := rcd_lads_bom_hdr.stlal;
      tbl_bds(var_index).matnr := rcd_lads_bom_hdr.matnr;
      tbl_bds(var_index).werks := rcd_lads_bom_hdr.werks;

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
      rcd_lads_bom_det.detseq := rcd_lads_bom_det.detseq + 1;
      rcd_lads_bom_det.msgfn := lics_inbound_utility.get_variable('MSGFN');
      rcd_lads_bom_det.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_bom_det.stlal := lics_inbound_utility.get_variable('STLAL');
      rcd_lads_bom_det.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_bom_det.posnr := lics_inbound_utility.get_variable('POSNR');
      rcd_lads_bom_det.postp := lics_inbound_utility.get_variable('POSTP');
      rcd_lads_bom_det.idnrk := lics_inbound_utility.get_variable('IDNRK');
      rcd_lads_bom_det.menge := lics_inbound_utility.get_number('MENGE',null);
      rcd_lads_bom_det.meins := lics_inbound_utility.get_variable('MEINS');
      rcd_lads_bom_det.datuv := lics_inbound_utility.get_variable('DATUV');
      rcd_lads_bom_det.datub := lics_inbound_utility.get_variable('DATUB');

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
      if rcd_lads_bom_det.stlal is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.STLAL');
         var_trn_error := true;
      end if;
      if rcd_lads_bom_det.matnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.MATNR');
         var_trn_error := true;
      end if;
      if rcd_lads_bom_det.werks is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.WERKS');
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

      insert into lads_bom_det
         (msgfn,
          matnr,
          stlal,
          werks,
          detseq,
          posnr,
          postp,
          idnrk,
          menge,
          meins,
          datuv,
          datub)
      values
         (rcd_lads_bom_det.msgfn,
          rcd_lads_bom_det.matnr,
          rcd_lads_bom_det.stlal,
          rcd_lads_bom_det.werks,
          rcd_lads_bom_det.detseq,
          rcd_lads_bom_det.posnr,
          rcd_lads_bom_det.postp,
          rcd_lads_bom_det.idnrk,
          rcd_lads_bom_det.menge,
          rcd_lads_bom_det.meins,
          rcd_lads_bom_det.datuv,
          rcd_lads_bom_det.datub);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad17;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad17 for lads_app.lads_atllad17;
grant execute on lads_atllad17 to lics_app;
