/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad03
 Owner   : lads_app
 Author  : Matthew Hardinge

 Description
 -----------
 Local Atlas Data Store - atllad03 - Inbound ICB LLT Intransit Interface

 * NOTE : This interface must be run in serial


 YYYY/MM   Author             Description
 -------   ------             -----------
 2006/05   Matthew Hardinge   Created
 2006/05   Linden Glen        ADD: Batch receiving/processing logic
 2008/05   Trevor Keon        Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad03 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad03;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad03 as

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
   rcd_lads_icb_llt_hdr lads_icb_llt_hdr%rowtype;
   rcd_lads_icb_llt_det lads_icb_llt_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','VENUM',10);
      lics_inbound_utility.set_definition('HDR','EXIDV',20);
      lics_inbound_utility.set_definition('HDR','BUKRS',4);
      lics_inbound_utility.set_definition('HDR','EXIDV2',20);
      lics_inbound_utility.set_definition('HDR','WHARDAT',8);
      lics_inbound_utility.set_definition('HDR','EINDT',8);
      lics_inbound_utility.set_definition('HDR','ZFWRD',10);
      lics_inbound_utility.set_definition('HDR','EXTI1',20);
      lics_inbound_utility.set_definition('HDR','SIGNI',20);
      lics_inbound_utility.set_definition('HDR','ZFNAM',35);
      lics_inbound_utility.set_definition('HDR','LIFNR',10);
      lics_inbound_utility.set_definition('HDR','EBELN',10);
      lics_inbound_utility.set_definition('HDR','ZHUSTAT',1);
      lics_inbound_utility.set_definition('HDR','HUDAT',8);
      lics_inbound_utility.set_definition('HDR','DATUM',8);
      lics_inbound_utility.set_definition('HDR','UZEIT',6);
      lics_inbound_utility.set_definition('HDR','SLFDT',8);
      lics_inbound_utility.set_definition('HDR','NAME1',35);
      lics_inbound_utility.set_definition('HDR','ZZSEAL',40);
      lics_inbound_utility.set_definition('HDR','VHILM',18);
      lics_inbound_utility.set_definition('HDR','ZCOUNT',8);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','VENUM1',10);
      lics_inbound_utility.set_definition('DET','MATNR',18);
      lics_inbound_utility.set_definition('DET','VEMNG',17);
      lics_inbound_utility.set_definition('DET','CHARG',10);
      lics_inbound_utility.set_definition('DET','VFDAT',8);
      lics_inbound_utility.set_definition('DET','WERKS',4);
      lics_inbound_utility.set_definition('DET','LGORT',4);
      lics_inbound_utility.set_definition('DET','MEINS',3);

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
      con_ack_code constant varchar2(32) := 'ATLLAD03';
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
         
         begin
            lads_atllad03_monitor.execute_before(rcd_lads_icb_llt_hdr.venum);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad03_monitor.execute_after(rcd_lads_icb_llt_hdr.venum);
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
      cursor csr_lads_icb_llt_hdr_01 is
         select
            t01.venum,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_icb_llt_hdr t01
         where t01.venum = rcd_lads_icb_llt_hdr.venum;
      rcd_lads_icb_llt_hdr_01 csr_lads_icb_llt_hdr_01%rowtype;

      cursor csr_batch is
         select nvl(min(datum||uzeit),0) as curr_batch
         from lads_icb_llt_hdr;
      rcd_batch csr_batch%rowtype;


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
      rcd_lads_icb_llt_hdr.venum := lics_inbound_utility.get_variable('VENUM');
      rcd_lads_icb_llt_hdr.exidv := lics_inbound_utility.get_variable('EXIDV');
      rcd_lads_icb_llt_hdr.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_lads_icb_llt_hdr.exidv2 := lics_inbound_utility.get_variable('EXIDV2');
      rcd_lads_icb_llt_hdr.slfdt := lics_inbound_utility.get_variable('SLFDT');
      rcd_lads_icb_llt_hdr.eindt := lics_inbound_utility.get_variable('EINDT');
      rcd_lads_icb_llt_hdr.zfwrd := lics_inbound_utility.get_variable('ZFWRD');
      rcd_lads_icb_llt_hdr.exti1 := lics_inbound_utility.get_variable('EXTI1');
      rcd_lads_icb_llt_hdr.signi := lics_inbound_utility.get_variable('SIGNI');
      rcd_lads_icb_llt_hdr.zfnam := lics_inbound_utility.get_variable('ZFNAM');
      rcd_lads_icb_llt_hdr.lifnr := lics_inbound_utility.get_variable('LIFNR');
      rcd_lads_icb_llt_hdr.ebeln := lics_inbound_utility.get_variable('EBELN');
      rcd_lads_icb_llt_hdr.zhustat := lics_inbound_utility.get_variable('ZHUSTAT');
      rcd_lads_icb_llt_hdr.hudat := lics_inbound_utility.get_variable('HUDAT');
      rcd_lads_icb_llt_hdr.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_icb_llt_hdr.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_lads_icb_llt_hdr.whardat := lics_inbound_utility.get_variable('WHARDAT');
      rcd_lads_icb_llt_hdr.name1 := lics_inbound_utility.get_variable('NAME1');
      rcd_lads_icb_llt_hdr.zzseal := lics_inbound_utility.get_variable('ZZSEAL');
      rcd_lads_icb_llt_hdr.vhilm := lics_inbound_utility.get_variable('VHILM');
      rcd_lads_icb_llt_hdr.zcount := lics_inbound_utility.get_variable('ZCOUNT');

      rcd_lads_icb_llt_hdr.idoc_name:= rcd_lads_control.idoc_name;
      rcd_lads_icb_llt_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_icb_llt_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_icb_llt_hdr.lads_date := sysdate;
      rcd_lads_icb_llt_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_icb_llt_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_icb_llt_hdr.venum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.VENUM');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_icb_llt_hdr.venum is null) then
         var_exists := true;

         /*-*/
         /* Define current batch code
         /*   note : batch code is based on the concatination of DATUM and UZEIT
         /*          these variables will be consistent for each header in the batch
         /*-*/
         open csr_batch;
         fetch csr_batch into rcd_batch;
         close csr_batch;
     

         /*-*/
         /* The following receival scenarios exist
         /*   1. HDR record is part of current batch - allow to load into tables
         /*   2. HDR record is newer than current batch - indicates a newer batch exists
         /*      and is most likely the first HDR of the batch, therefore, purge tables
         /*      and load
         /*   3. HDR record is older than current batch - ignore transaction
         /*-*/    
         case

            when rcd_lads_icb_llt_hdr.datum||rcd_lads_icb_llt_hdr.uzeit = rcd_batch.curr_batch then

               open csr_lads_icb_llt_hdr_01;
               fetch csr_lads_icb_llt_hdr_01 into rcd_lads_icb_llt_hdr_01;
               if csr_lads_icb_llt_hdr_01%notfound then
                  var_exists := false;
               end if;
               close csr_lads_icb_llt_hdr_01;

               if var_exists = true then
                  if rcd_lads_icb_llt_hdr.idoc_timestamp > rcd_lads_icb_llt_hdr_01.idoc_timestamp then
                     delete from lads_icb_llt_det where venum = rcd_lads_icb_llt_hdr.venum;
                  else
                     var_trn_ignore := true;
                  end if;
               end if;

            when rcd_lads_icb_llt_hdr.datum||rcd_lads_icb_llt_hdr.uzeit > rcd_batch.curr_batch then

               delete from lads_icb_llt_det;
               delete from lads_icb_llt_hdr;

            when rcd_lads_icb_llt_hdr.datum||rcd_lads_icb_llt_hdr.uzeit < rcd_batch.curr_batch then     
               var_trn_ignore := true;

         end case;

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

      update lads_icb_llt_hdr set
         exidv = rcd_lads_icb_llt_hdr.exidv,
         bukrs = rcd_lads_icb_llt_hdr.bukrs,
         exidv2 = rcd_lads_icb_llt_hdr.exidv2,
         slfdt = rcd_lads_icb_llt_hdr.slfdt,
         eindt = rcd_lads_icb_llt_hdr.eindt,
         zfwrd = rcd_lads_icb_llt_hdr.zfwrd,
         exti1 = rcd_lads_icb_llt_hdr.exti1,
         signi = rcd_lads_icb_llt_hdr.signi,
         zfnam = rcd_lads_icb_llt_hdr.zfnam,
         lifnr = rcd_lads_icb_llt_hdr.lifnr,
         ebeln = rcd_lads_icb_llt_hdr.ebeln,
         zhustat = rcd_lads_icb_llt_hdr.zhustat,
         hudat = rcd_lads_icb_llt_hdr.hudat,
         datum = rcd_lads_icb_llt_hdr.datum,
         uzeit = rcd_lads_icb_llt_hdr.uzeit,
         whardat = rcd_lads_icb_llt_hdr.whardat,
         name1 = rcd_lads_icb_llt_hdr.name1,
         zzseal = rcd_lads_icb_llt_hdr.zzseal,
         vhilm = rcd_lads_icb_llt_hdr.vhilm,
         zcount = rcd_lads_icb_llt_hdr.zcount,
         idoc_name = rcd_lads_icb_llt_hdr.idoc_name,
         idoc_number = rcd_lads_icb_llt_hdr.idoc_number,
         idoc_timestamp = rcd_lads_icb_llt_hdr.idoc_timestamp,
         lads_date = rcd_lads_icb_llt_hdr.lads_date,
         lads_status = rcd_lads_icb_llt_hdr.lads_status
      where venum = rcd_lads_icb_llt_hdr.venum;
      if sql%notfound then
         insert into lads_icb_llt_hdr
            (venum,
	     exidv,
             bukrs,
             exidv2,
             slfdt,
             eindt,
             zfwrd,
             exti1,
             signi,
             zfnam,
             lifnr,
             ebeln,
             zhustat,
             hudat,
             datum,
             uzeit,
	     whardat,
	     name1,
	     zzseal,
	     vhilm,
	     zcount,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_icb_llt_hdr.venum,
	     rcd_lads_icb_llt_hdr.exidv,
             rcd_lads_icb_llt_hdr.bukrs,
             rcd_lads_icb_llt_hdr.exidv2,
             rcd_lads_icb_llt_hdr.slfdt,
             rcd_lads_icb_llt_hdr.eindt,
             rcd_lads_icb_llt_hdr.zfwrd,
             rcd_lads_icb_llt_hdr.exti1,
             rcd_lads_icb_llt_hdr.signi,
             rcd_lads_icb_llt_hdr.zfnam,
             rcd_lads_icb_llt_hdr.lifnr,
             rcd_lads_icb_llt_hdr.ebeln,
             rcd_lads_icb_llt_hdr.zhustat,
             rcd_lads_icb_llt_hdr.hudat,
             rcd_lads_icb_llt_hdr.datum,
             rcd_lads_icb_llt_hdr.uzeit,
             rcd_lads_icb_llt_hdr.whardat,
             rcd_lads_icb_llt_hdr.name1,
             rcd_lads_icb_llt_hdr.zzseal,
             rcd_lads_icb_llt_hdr.vhilm,
             rcd_lads_icb_llt_hdr.zcount,
             rcd_lads_icb_llt_hdr.idoc_name,
             rcd_lads_icb_llt_hdr.idoc_number,
             rcd_lads_icb_llt_hdr.idoc_timestamp,
             rcd_lads_icb_llt_hdr.lads_date,
             rcd_lads_icb_llt_hdr.lads_status);
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
      rcd_lads_icb_llt_det.venum := rcd_lads_icb_llt_hdr.venum;
      rcd_lads_icb_llt_det.detseq := rcd_lads_icb_llt_det.detseq + 1;
      rcd_lads_icb_llt_det.matnr := lics_inbound_utility.get_variable('MATNR');
      rcd_lads_icb_llt_det.vemng := lics_inbound_utility.get_number('VEMNG',null);
      rcd_lads_icb_llt_det.charg := lics_inbound_utility.get_variable('CHARG');
      rcd_lads_icb_llt_det.vfdat := lics_inbound_utility.get_variable('VFDAT');
      rcd_lads_icb_llt_det.werks := lics_inbound_utility.get_variable('WERKS');
      rcd_lads_icb_llt_det.lgort := lics_inbound_utility.get_variable('LGORT');
      rcd_lads_icb_llt_det.venum1 := lics_inbound_utility.get_variable('VENUM1');
      rcd_lads_icb_llt_det.meins := lics_inbound_utility.get_variable('MEINS');

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
      if rcd_lads_icb_llt_det.venum is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.VENUM');
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

      insert into lads_icb_llt_det
         (venum,
          detseq,
          matnr,
          vemng,
          charg,
	  vfdat,
          werks,
          lgort,
	  venum1,
	  meins)
      values
         (rcd_lads_icb_llt_det.venum,
          rcd_lads_icb_llt_det.detseq,
          rcd_lads_icb_llt_det.matnr,
          rcd_lads_icb_llt_det.vemng,
          rcd_lads_icb_llt_det.charg,
	  rcd_lads_icb_llt_det.vfdat,
          rcd_lads_icb_llt_det.werks,
          rcd_lads_icb_llt_det.lgort,
	  rcd_lads_icb_llt_det.venum1,
	  rcd_lads_icb_llt_det.meins);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad03;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad03 for lads_app.lads_atllad03;
grant execute on lads_atllad03 to lics_app;
