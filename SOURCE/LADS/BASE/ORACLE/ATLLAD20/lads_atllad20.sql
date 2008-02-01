/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad20
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad20 - Inbound Hierarchy Customer Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2006/11   Steve Gregan   Added columns (DET): ZZCURRENTFLAG
                                               ZZFUTUREFLAG
                                               ZZMARKETACCTFLAG

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad20 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad20;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad20 as

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
   rcd_lads_hie_cus_hdr lads_hie_cus_hdr%rowtype;
   rcd_lads_hie_cus_det lads_hie_cus_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','HITYP',1);
      lics_inbound_utility.set_definition('HDR','DATAB',8);
      lics_inbound_utility.set_definition('HDR','DATBI',8);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','KUNNR',10);
      lics_inbound_utility.set_definition('DET','VKORG',4);
      lics_inbound_utility.set_definition('DET','VTWEG',2);
      lics_inbound_utility.set_definition('DET','SPART',2);
      lics_inbound_utility.set_definition('DET','HZUOR',2);
      lics_inbound_utility.set_definition('DET','DATAB',8);
      lics_inbound_utility.set_definition('DET','DATBI',8);
      lics_inbound_utility.set_definition('DET','KTOKD',4);
      lics_inbound_utility.set_definition('DET','SORTL',10);
      lics_inbound_utility.set_definition('DET','HIELV',2);
      lics_inbound_utility.set_definition('DET','ZZCURRENTFLAG',1);
      lics_inbound_utility.set_definition('DET','ZZFUTUREFLAG',1);
      lics_inbound_utility.set_definition('DET','ZZMARKETACCTFLAG',1);

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
      con_ack_code constant varchar2(32) := 'ATLLAD20';
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
            lads_atllad20_monitor.execute(rcd_lads_hie_cus_hdr.hdrdat, rcd_lads_hie_cus_hdr.hdrseq);
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
      cursor csr_lads_hie_cus_hdr_01 is
         select
            nvl(max(t01.hdrseq),0) as maxseq
         from lads_hie_cus_hdr t01
         where t01.hdrdat = rcd_lads_hie_cus_hdr.hdrdat;
      rcd_lads_hie_cus_hdr_01 csr_lads_hie_cus_hdr_01%rowtype;

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
      rcd_lads_hie_cus_hdr.hdrdat := substr(rcd_lads_control.idoc_timestamp,1,8);
      rcd_lads_hie_cus_hdr.hdrseq := 0;
      rcd_lads_hie_cus_hdr.hityp := lics_inbound_utility.get_variable('HITYP');
      rcd_lads_hie_cus_hdr.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_hie_cus_hdr.datbi := lics_inbound_utility.get_variable('DATBI');
      rcd_lads_hie_cus_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_hie_cus_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_hie_cus_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_hie_cus_hdr.lads_date := sysdate;
      rcd_lads_hie_cus_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_hie_cus_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_hie_cus_hdr.hdrdat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.HDRDAT');
         var_trn_error := true;
      end if;

      /*-*/
      /* Update the header sequence for the header date when primary key supplied
      /*-*/
      if not(rcd_lads_hie_cus_hdr.hdrdat is null) then
         open csr_lads_hie_cus_hdr_01;
         fetch csr_lads_hie_cus_hdr_01 into rcd_lads_hie_cus_hdr_01;
         if csr_lads_hie_cus_hdr_01%notfound then
            rcd_lads_hie_cus_hdr_01.maxseq := 0;
         end if;
         close csr_lads_hie_cus_hdr_01;
         rcd_lads_hie_cus_hdr.hdrseq := rcd_lads_hie_cus_hdr_01.maxseq + 1;
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

      insert into lads_hie_cus_hdr
         (hdrdat,
          hdrseq,
          hityp,
          datab,
          datbi,
          idoc_name,
          idoc_number,
          idoc_timestamp,
          lads_date,
          lads_status)
      values
         (rcd_lads_hie_cus_hdr.hdrdat,
          rcd_lads_hie_cus_hdr.hdrseq,
          rcd_lads_hie_cus_hdr.hityp,
          rcd_lads_hie_cus_hdr.datab,
          rcd_lads_hie_cus_hdr.datbi,
          rcd_lads_hie_cus_hdr.idoc_name,
          rcd_lads_hie_cus_hdr.idoc_number,
          rcd_lads_hie_cus_hdr.idoc_timestamp,
          rcd_lads_hie_cus_hdr.lads_date,
          rcd_lads_hie_cus_hdr.lads_status);

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
      rcd_lads_hie_cus_det.hdrdat := rcd_lads_hie_cus_hdr.hdrdat;
      rcd_lads_hie_cus_det.hdrseq := rcd_lads_hie_cus_hdr.hdrseq;
      rcd_lads_hie_cus_det.detseq := rcd_lads_hie_cus_det.detseq + 1;
      rcd_lads_hie_cus_det.kunnr := lics_inbound_utility.get_variable('KUNNR');
      rcd_lads_hie_cus_det.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_hie_cus_det.vtweg := lics_inbound_utility.get_variable('VTWEG');
      rcd_lads_hie_cus_det.spart := lics_inbound_utility.get_variable('SPART');
      rcd_lads_hie_cus_det.hzuor := lics_inbound_utility.get_variable('HZUOR');
      rcd_lads_hie_cus_det.datab := lics_inbound_utility.get_variable('DATAB');
      rcd_lads_hie_cus_det.datbi := lics_inbound_utility.get_variable('DATBI');
      rcd_lads_hie_cus_det.ktokd := lics_inbound_utility.get_variable('KTOKD');
      rcd_lads_hie_cus_det.sortl := lics_inbound_utility.get_variable('SORTL');
      rcd_lads_hie_cus_det.hielv := lics_inbound_utility.get_variable('HIELV');
      rcd_lads_hie_cus_det.zzcurrentflag := lics_inbound_utility.get_variable('ZZCURRENTFLAG');
      rcd_lads_hie_cus_det.zzfutureflag := lics_inbound_utility.get_variable('ZZFUTUREFLAG');
      rcd_lads_hie_cus_det.zzmarketacctflag := lics_inbound_utility.get_variable('ZZMARKETACCTFLAG');

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
      if rcd_lads_hie_cus_det.hdrdat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.HDRDAT');
         var_trn_error := true;
      end if;
      if rcd_lads_hie_cus_det.hdrseq is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.HDRSEQ');
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

      insert into lads_hie_cus_det
         (hdrdat,
          hdrseq,
          detseq,
          kunnr,
          vkorg,
          vtweg,
          spart,
          hzuor,
          datab,
          datbi,
          ktokd,
          sortl,
          hielv,
          zzcurrentflag,
          zzfutureflag,
          zzmarketacctflag)
      values
         (rcd_lads_hie_cus_det.hdrdat,
          rcd_lads_hie_cus_det.hdrseq,
          rcd_lads_hie_cus_det.detseq,
          rcd_lads_hie_cus_det.kunnr,
          rcd_lads_hie_cus_det.vkorg,
          rcd_lads_hie_cus_det.vtweg,
          rcd_lads_hie_cus_det.spart,
          rcd_lads_hie_cus_det.hzuor,
          rcd_lads_hie_cus_det.datab,
          rcd_lads_hie_cus_det.datbi,
          rcd_lads_hie_cus_det.ktokd,
          rcd_lads_hie_cus_det.sortl,
          rcd_lads_hie_cus_det.hielv,
          rcd_lads_hie_cus_det.zzcurrentflag,
          rcd_lads_hie_cus_det.zzfutureflag,
          rcd_lads_hie_cus_det.zzmarketacctflag);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad20;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad20 for lads_app.lads_atllad20;
grant execute on lads_atllad20 to lics_app;
