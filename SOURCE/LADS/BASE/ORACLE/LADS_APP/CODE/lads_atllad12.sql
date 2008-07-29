/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad12
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad12 - Inbound Invoice Summary Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad12 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad12;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad12 as

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
   rcd_lads_inv_sum_hdr lads_inv_sum_hdr%rowtype;
   rcd_lads_inv_sum_det lads_inv_sum_det%rowtype;

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
      lics_inbound_utility.set_definition('HDR','FKDAT',8);
      lics_inbound_utility.set_definition('HDR','BUKRS',4);
      lics_inbound_utility.set_definition('HDR','DATUM',8);
      lics_inbound_utility.set_definition('HDR','UZEIT',6);
      /*-*/
      lics_inbound_utility.set_definition('DET','IDOC_DET',3);
      lics_inbound_utility.set_definition('DET','VKORG',4);
      lics_inbound_utility.set_definition('DET','FKART',4);
      lics_inbound_utility.set_definition('DET','ZNUMIV',8);
      lics_inbound_utility.set_definition('DET','ZNUMPS',8);
      lics_inbound_utility.set_definition('DET','NETWR',15);
      lics_inbound_utility.set_definition('DET','WAERK',5);

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
      con_ack_code constant varchar2(32) := 'ATLLAD12';
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
            lads_atllad12_monitor.execute_before(rcd_lads_inv_sum_hdr.fkdat, rcd_lads_inv_sum_hdr.bukrs);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad12_monitor.execute_after(rcd_lads_inv_sum_hdr.fkdat, rcd_lads_inv_sum_hdr.bukrs);
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
      cursor csr_lads_inv_sum_hdr_01 is
         select
            t01.fkdat,
            t01.bukrs,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_inv_sum_hdr t01
         where t01.fkdat = rcd_lads_inv_sum_hdr.fkdat
           and t01.bukrs = rcd_lads_inv_sum_hdr.bukrs;
      rcd_lads_inv_sum_hdr_01 csr_lads_inv_sum_hdr_01%rowtype;

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
      rcd_lads_inv_sum_hdr.fkdat := lics_inbound_utility.get_variable('FKDAT');
      rcd_lads_inv_sum_hdr.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_lads_inv_sum_hdr.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_lads_inv_sum_hdr.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_lads_inv_sum_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_inv_sum_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_inv_sum_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_inv_sum_hdr.lads_date := sysdate;
      rcd_lads_inv_sum_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_inv_sum_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_inv_sum_hdr.fkdat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.FKDAT');
         var_trn_error := true;
      end if;
      if rcd_lads_inv_sum_hdr.bukrs is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BUKRS');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_inv_sum_hdr.fkdat is null) and
         not(rcd_lads_inv_sum_hdr.bukrs is null) then
         var_exists := true;
         open csr_lads_inv_sum_hdr_01;
         fetch csr_lads_inv_sum_hdr_01 into rcd_lads_inv_sum_hdr_01;
         if csr_lads_inv_sum_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_inv_sum_hdr_01;
         if var_exists = true then
            if rcd_lads_inv_sum_hdr.idoc_timestamp >= rcd_lads_inv_sum_hdr_01.idoc_timestamp then
               delete from lads_inv_sum_det where fkdat = rcd_lads_inv_sum_hdr.fkdat
                                              and bukrs = rcd_lads_inv_sum_hdr.bukrs;
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

      update lads_inv_sum_hdr set
         datum = rcd_lads_inv_sum_hdr.datum,
         uzeit = rcd_lads_inv_sum_hdr.uzeit,
         idoc_name = rcd_lads_inv_sum_hdr.idoc_name,
         idoc_number = rcd_lads_inv_sum_hdr.idoc_number,
         idoc_timestamp = rcd_lads_inv_sum_hdr.idoc_timestamp,
         lads_date = rcd_lads_inv_sum_hdr.lads_date,
         lads_status = rcd_lads_inv_sum_hdr.lads_status
      where fkdat = rcd_lads_inv_sum_hdr.fkdat
        and bukrs = rcd_lads_inv_sum_hdr.bukrs;
      if sql%notfound then
         insert into lads_inv_sum_hdr
            (fkdat,
             bukrs,
             datum,
             uzeit,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_inv_sum_hdr.fkdat,
             rcd_lads_inv_sum_hdr.bukrs,
             rcd_lads_inv_sum_hdr.datum,
             rcd_lads_inv_sum_hdr.uzeit,
             rcd_lads_inv_sum_hdr.idoc_name,
             rcd_lads_inv_sum_hdr.idoc_number,
             rcd_lads_inv_sum_hdr.idoc_timestamp,
             rcd_lads_inv_sum_hdr.lads_date,
             rcd_lads_inv_sum_hdr.lads_status);
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
      rcd_lads_inv_sum_det.fkdat := rcd_lads_inv_sum_hdr.fkdat;
      rcd_lads_inv_sum_det.bukrs := rcd_lads_inv_sum_hdr.bukrs;
      rcd_lads_inv_sum_det.detseq := rcd_lads_inv_sum_det.detseq + 1;
      rcd_lads_inv_sum_det.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_lads_inv_sum_det.fkart := lics_inbound_utility.get_variable('FKART');
      rcd_lads_inv_sum_det.znumiv := lics_inbound_utility.get_number('ZNUMIV',null);
      rcd_lads_inv_sum_det.znumps := lics_inbound_utility.get_number('ZNUMPS',null);
      rcd_lads_inv_sum_det.netwr := lics_inbound_utility.get_number('NETWR',null);
      rcd_lads_inv_sum_det.waerk := lics_inbound_utility.get_variable('WAERK');

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
      if rcd_lads_inv_sum_det.fkdat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FKDAT');
         var_trn_error := true;
      end if;
      if rcd_lads_inv_sum_det.bukrs is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.BUKRS');
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

      insert into lads_inv_sum_det
         (fkdat,
          bukrs,
          detseq,
          vkorg,
          fkart,
          znumiv,
          znumps,
          netwr,
          waerk)
      values
         (rcd_lads_inv_sum_det.fkdat,
          rcd_lads_inv_sum_det.bukrs,
          rcd_lads_inv_sum_det.detseq,
          rcd_lads_inv_sum_det.vkorg,
          rcd_lads_inv_sum_det.fkart,
          rcd_lads_inv_sum_det.znumiv,
          rcd_lads_inv_sum_det.znumps,
          rcd_lads_inv_sum_det.netwr,
          rcd_lads_inv_sum_det.waerk);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end lads_atllad12;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad12 for lads_app.lads_atllad12;
grant execute on lads_atllad12 to lics_app;
