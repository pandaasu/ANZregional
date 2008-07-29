/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad01
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - atllad01 - Inbound Control Recipe Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad01;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad01 as

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
   procedure process_record_hpi(par_record in varchar2);
   procedure process_record_tpi(par_record in varchar2);
   procedure process_record_vpi(par_record in varchar2);
   procedure process_record_txt(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_ctl_rec_hpi lads_ctl_rec_hpi%rowtype;
   rcd_lads_ctl_rec_tpi lads_ctl_rec_tpi%rowtype;
   rcd_lads_ctl_rec_vpi lads_ctl_rec_vpi%rowtype;
   rcd_lads_ctl_rec_txt lads_ctl_rec_txt%rowtype;

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
      lics_inbound_utility.set_definition('HPI','IDOC_HPI',3);
      lics_inbound_utility.set_definition('HPI','CNTL_REC_ID',18);
      lics_inbound_utility.set_definition('HPI','PLANT',4);
      lics_inbound_utility.set_definition('HPI','PROC_ORDER',12);
      lics_inbound_utility.set_definition('HPI','DEST',2);
      lics_inbound_utility.set_definition('HPI','DEST_ADDRESS',32);
      lics_inbound_utility.set_definition('HPI','DEST_TYPE',1);
      lics_inbound_utility.set_definition('HPI','CNTL_REC_STATUS',5);
      lics_inbound_utility.set_definition('HPI','TEST_FLAG',1);
      lics_inbound_utility.set_definition('HPI','RECIPE_TEXT',40);
      lics_inbound_utility.set_definition('HPI','MATERIAL',18);
      lics_inbound_utility.set_definition('HPI','MATERIAL_TEXT',40);
      lics_inbound_utility.set_definition('HPI','INSPLOT',12);
      lics_inbound_utility.set_definition('HPI','MATERIAL_EXTERNAL',40);
      lics_inbound_utility.set_definition('HPI','MATERIAL_GUID',32);
      lics_inbound_utility.set_definition('HPI','MATERIAL_VERSION',10);
      lics_inbound_utility.set_definition('HPI','BATCH',10);
      lics_inbound_utility.set_definition('HPI','SCHEDULED_START_DATE',8);
      lics_inbound_utility.set_definition('HPI','SCHEDULED_START_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('TPI','IDOC_TPI',3);
      lics_inbound_utility.set_definition('TPI','CNTL_REC_ID',18);
      lics_inbound_utility.set_definition('TPI','PROC_INSTR_NUMBER',8);
      lics_inbound_utility.set_definition('TPI','PROC_INSTR_TYPE',1);
      lics_inbound_utility.set_definition('TPI','PROC_INSTR_CATEGORY',8);
      lics_inbound_utility.set_definition('TPI','PROC_INSTR_LINE_NO',4);
      lics_inbound_utility.set_definition('TPI','PHASE_NUMBER',4);
      /*-*/
      lics_inbound_utility.set_definition('VPI','IDOC_VPI',3);
      lics_inbound_utility.set_definition('VPI','CNTL_REC_ID',18);
      lics_inbound_utility.set_definition('VPI','PROC_INSTR_NUMBER',8);
      lics_inbound_utility.set_definition('VPI','CHAR_LINE_NUMBER',4);
      lics_inbound_utility.set_definition('VPI','NAME_CHAR',30);
      lics_inbound_utility.set_definition('VPI','CHAR_VALUE',30);
      lics_inbound_utility.set_definition('VPI','DATA_TYPE',4);
      lics_inbound_utility.set_definition('VPI','INSTR_CHAR_LINE_NUMBER',4);
      /*-*/
      lics_inbound_utility.set_definition('TXT','IDOC_TXT',3);
      lics_inbound_utility.set_definition('TXT','CNTL_REC_ID',18);
      lics_inbound_utility.set_definition('TXT','PROC_INSTR_NUMBER',8);
      lics_inbound_utility.set_definition('TXT','CHAR_LINE_NUMBER',4);
      lics_inbound_utility.set_definition('TXT','TDFORMAT',2);
      lics_inbound_utility.set_definition('TXT','TDLINE',132);

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
         when 'HPI' then process_record_hpi(par_record);
         when 'TPI' then process_record_tpi(par_record);
         when 'VPI' then process_record_vpi(par_record);
         when 'TXT' then process_record_txt(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD01';
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
            lads_atllad01_monitor.execute_before(rcd_lads_ctl_rec_hpi.cntl_rec_id);
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad01_monitor.execute_after(rcd_lads_ctl_rec_hpi.cntl_rec_id);
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
   /* This procedure performs the record HPI routine */
   /**************************************************/
   procedure process_record_hpi(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exists boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ctl_rec_hpi_01 is
         select
            t01.cntl_rec_id,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_ctl_rec_hpi t01
         where t01.cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id;
      rcd_lads_ctl_rec_hpi_01 csr_lads_ctl_rec_hpi_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('HPI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ctl_rec_hpi.cntl_rec_id := lics_inbound_utility.get_number('CNTL_REC_ID','999999999999999999');
      rcd_lads_ctl_rec_hpi.plant := lics_inbound_utility.get_variable('PLANT');
      rcd_lads_ctl_rec_hpi.proc_order := lics_inbound_utility.get_variable('PROC_ORDER');
      rcd_lads_ctl_rec_hpi.dest := lics_inbound_utility.get_variable('DEST');
      rcd_lads_ctl_rec_hpi.dest_address := lics_inbound_utility.get_variable('DEST_ADDRESS');
      rcd_lads_ctl_rec_hpi.dest_type := lics_inbound_utility.get_variable('DEST_TYPE');
      rcd_lads_ctl_rec_hpi.cntl_rec_status := lics_inbound_utility.get_variable('CNTL_REC_STATUS');
      rcd_lads_ctl_rec_hpi.test_flag := lics_inbound_utility.get_variable('TEST_FLAG');
      rcd_lads_ctl_rec_hpi.recipe_text := lics_inbound_utility.get_variable('RECIPE_TEXT');
      rcd_lads_ctl_rec_hpi.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_lads_ctl_rec_hpi.material_text := lics_inbound_utility.get_variable('MATERIAL_TEXT');
      rcd_lads_ctl_rec_hpi.insplot := lics_inbound_utility.get_number('INSPLOT','999999999999');
      rcd_lads_ctl_rec_hpi.material_external := lics_inbound_utility.get_variable('MATERIAL_EXTERNAL');
      rcd_lads_ctl_rec_hpi.material_guid := lics_inbound_utility.get_variable('MATERIAL_GUID');
      rcd_lads_ctl_rec_hpi.material_version := lics_inbound_utility.get_variable('MATERIAL_VERSION');
      rcd_lads_ctl_rec_hpi.batch := lics_inbound_utility.get_variable('BATCH');
      rcd_lads_ctl_rec_hpi.scheduled_start_date := lics_inbound_utility.get_variable('SCHEDULED_START_DATE');
      rcd_lads_ctl_rec_hpi.scheduled_start_time := lics_inbound_utility.get_variable('SCHEDULED_START_TIME');
      rcd_lads_ctl_rec_hpi.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_ctl_rec_hpi.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_ctl_rec_hpi.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_ctl_rec_hpi.lads_date := sysdate;
      rcd_lads_ctl_rec_hpi.lads_status := '1';

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
      if rcd_lads_ctl_rec_hpi.cntl_rec_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HPI.CNTL_REC_ID');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_ctl_rec_hpi.cntl_rec_id is null) then
         var_exists := true;
         open csr_lads_ctl_rec_hpi_01;
         fetch csr_lads_ctl_rec_hpi_01 into rcd_lads_ctl_rec_hpi_01;
         if csr_lads_ctl_rec_hpi_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_ctl_rec_hpi_01;
         if var_exists = true then
            if rcd_lads_ctl_rec_hpi.idoc_timestamp > rcd_lads_ctl_rec_hpi_01.idoc_timestamp then
               delete from lads_ctl_rec_txt where cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id;
               delete from lads_ctl_rec_vpi where cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id;
               delete from lads_ctl_rec_tpi where cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id;
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

      update lads_ctl_rec_hpi set
         plant = rcd_lads_ctl_rec_hpi.plant,
         proc_order = rcd_lads_ctl_rec_hpi.proc_order,
         dest = rcd_lads_ctl_rec_hpi.dest,
         dest_address = rcd_lads_ctl_rec_hpi.dest_address,
         dest_type = rcd_lads_ctl_rec_hpi.dest_type,
         cntl_rec_status = rcd_lads_ctl_rec_hpi.cntl_rec_status,
         test_flag = rcd_lads_ctl_rec_hpi.test_flag,
         recipe_text = rcd_lads_ctl_rec_hpi.recipe_text,
         material = rcd_lads_ctl_rec_hpi.material,
         material_text = rcd_lads_ctl_rec_hpi.material_text,
         insplot = rcd_lads_ctl_rec_hpi.insplot,
         material_external = rcd_lads_ctl_rec_hpi.material_external,
         material_guid = rcd_lads_ctl_rec_hpi.material_guid,
         material_version = rcd_lads_ctl_rec_hpi.material_version,
         batch = rcd_lads_ctl_rec_hpi.batch,
         scheduled_start_date = rcd_lads_ctl_rec_hpi.scheduled_start_date,
         scheduled_start_time = rcd_lads_ctl_rec_hpi.scheduled_start_time,
         idoc_name = rcd_lads_ctl_rec_hpi.idoc_name,
         idoc_number = rcd_lads_ctl_rec_hpi.idoc_number,
         idoc_timestamp = rcd_lads_ctl_rec_hpi.idoc_timestamp,
         lads_date = rcd_lads_ctl_rec_hpi.lads_date,
         lads_status = rcd_lads_ctl_rec_hpi.lads_status
      where cntl_rec_id = rcd_lads_ctl_rec_hpi.cntl_rec_id;
      if sql%notfound then
         insert into lads_ctl_rec_hpi
            (cntl_rec_id,
             plant,
             proc_order,
             dest,
             dest_address,
             dest_type,
             cntl_rec_status,
             test_flag,
             recipe_text,
             material,
             material_text,
             insplot,
             material_external,
             material_guid,
             material_version,
             batch,
             scheduled_start_date,
             scheduled_start_time,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_ctl_rec_hpi.cntl_rec_id,
             rcd_lads_ctl_rec_hpi.plant,
             rcd_lads_ctl_rec_hpi.proc_order,
             rcd_lads_ctl_rec_hpi.dest,
             rcd_lads_ctl_rec_hpi.dest_address,
             rcd_lads_ctl_rec_hpi.dest_type,
             rcd_lads_ctl_rec_hpi.cntl_rec_status,
             rcd_lads_ctl_rec_hpi.test_flag,
             rcd_lads_ctl_rec_hpi.recipe_text,
             rcd_lads_ctl_rec_hpi.material,
             rcd_lads_ctl_rec_hpi.material_text,
             rcd_lads_ctl_rec_hpi.insplot,
             rcd_lads_ctl_rec_hpi.material_external,
             rcd_lads_ctl_rec_hpi.material_guid,
             rcd_lads_ctl_rec_hpi.material_version,
             rcd_lads_ctl_rec_hpi.batch,
             rcd_lads_ctl_rec_hpi.scheduled_start_date,
             rcd_lads_ctl_rec_hpi.scheduled_start_time,
             rcd_lads_ctl_rec_hpi.idoc_name,
             rcd_lads_ctl_rec_hpi.idoc_number,
             rcd_lads_ctl_rec_hpi.idoc_timestamp,
             rcd_lads_ctl_rec_hpi.lads_date,
             rcd_lads_ctl_rec_hpi.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hpi;

   /**************************************************/
   /* This procedure performs the record TPI routine */
   /**************************************************/
   procedure process_record_tpi(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TPI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ctl_rec_tpi.cntl_rec_id := lics_inbound_utility.get_number('CNTL_REC_ID','999999999999999999');
      rcd_lads_ctl_rec_tpi.proc_instr_number := lics_inbound_utility.get_number('PROC_INSTR_NUMBER','99999999');
      rcd_lads_ctl_rec_tpi.proc_instr_type := lics_inbound_utility.get_variable('PROC_INSTR_TYPE');
      rcd_lads_ctl_rec_tpi.proc_instr_category := lics_inbound_utility.get_variable('PROC_INSTR_CATEGORY');
      rcd_lads_ctl_rec_tpi.proc_instr_line_no := lics_inbound_utility.get_variable('PROC_INSTR_LINE_NO');
      rcd_lads_ctl_rec_tpi.phase_number := lics_inbound_utility.get_variable('PHASE_NUMBER');

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
      if rcd_lads_ctl_rec_tpi.cntl_rec_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TPI.CNTL_REC_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_ctl_rec_tpi.proc_instr_number is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TPI.PROC_INSTR_NUMBER');
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

      insert into lads_ctl_rec_tpi
         (cntl_rec_id,
          proc_instr_number,
          proc_instr_type,
          proc_instr_category,
          proc_instr_line_no,
          phase_number)
      values
         (rcd_lads_ctl_rec_tpi.cntl_rec_id,
          rcd_lads_ctl_rec_tpi.proc_instr_number,
          rcd_lads_ctl_rec_tpi.proc_instr_type,
          rcd_lads_ctl_rec_tpi.proc_instr_category,
          rcd_lads_ctl_rec_tpi.proc_instr_line_no,
          rcd_lads_ctl_rec_tpi.phase_number);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_tpi;

   /**************************************************/
   /* This procedure performs the record VPI routine */
   /**************************************************/
   procedure process_record_vpi(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('VPI', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ctl_rec_vpi.cntl_rec_id := lics_inbound_utility.get_number('CNTL_REC_ID','999999999999999999');
      rcd_lads_ctl_rec_vpi.proc_instr_number := lics_inbound_utility.get_number('PROC_INSTR_NUMBER','99999999');
      rcd_lads_ctl_rec_vpi.char_line_number := lics_inbound_utility.get_number('CHAR_LINE_NUMBER','9999');
      rcd_lads_ctl_rec_vpi.name_char := lics_inbound_utility.get_variable('NAME_CHAR');
      rcd_lads_ctl_rec_vpi.char_value := lics_inbound_utility.get_variable('CHAR_VALUE');
      rcd_lads_ctl_rec_vpi.data_type := lics_inbound_utility.get_variable('DATA_TYPE');
      rcd_lads_ctl_rec_vpi.instr_char_line_number := lics_inbound_utility.get_variable('INSTR_CHAR_LINE_NUMBER');

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
      if rcd_lads_ctl_rec_vpi.cntl_rec_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VPI.CNTL_REC_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_ctl_rec_vpi.proc_instr_number is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VPI.PROC_INSTR_NUMBER');
         var_trn_error := true;
      end if;
      if rcd_lads_ctl_rec_vpi.char_line_number is null then
         lics_inbound_utility.add_exception('Missing Primary Key - VPI.CHAR_LINE_NUMBER');
         var_trn_error := true;
      end if;
      rcd_lads_ctl_rec_txt.arrival_sequence := 0;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      insert into lads_ctl_rec_vpi
         (cntl_rec_id,
          proc_instr_number,
          char_line_number,
          name_char,
          char_value,
          data_type,
          instr_char_line_number)
      values
         (rcd_lads_ctl_rec_vpi.cntl_rec_id,
          rcd_lads_ctl_rec_vpi.proc_instr_number,
          rcd_lads_ctl_rec_vpi.char_line_number,
          rcd_lads_ctl_rec_vpi.name_char,
          rcd_lads_ctl_rec_vpi.char_value,
          rcd_lads_ctl_rec_vpi.data_type,
          rcd_lads_ctl_rec_vpi.instr_char_line_number);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_vpi;

   /**************************************************/
   /* This procedure performs the record TXT routine */
   /**************************************************/
   procedure process_record_txt(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('TXT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ctl_rec_txt.cntl_rec_id := lics_inbound_utility.get_number('CNTL_REC_ID','999999999999999999');
      rcd_lads_ctl_rec_txt.proc_instr_number := lics_inbound_utility.get_number('PROC_INSTR_NUMBER','99999999');
      rcd_lads_ctl_rec_txt.char_line_number := lics_inbound_utility.get_number('CHAR_LINE_NUMBER','9999');
      rcd_lads_ctl_rec_txt.tdformat := lics_inbound_utility.get_variable('TDFORMAT');
      rcd_lads_ctl_rec_txt.tdline := lics_inbound_utility.get_variable('TDLINE');
      rcd_lads_ctl_rec_txt.arrival_sequence := rcd_lads_ctl_rec_txt.arrival_sequence + 1;

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
      if rcd_lads_ctl_rec_txt.cntl_rec_id is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXT.CNTL_REC_ID');
         var_trn_error := true;
      end if;
      if rcd_lads_ctl_rec_txt.proc_instr_number is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXT.PROC_INSTR_NUMBER');
         var_trn_error := true;
      end if;
      if rcd_lads_ctl_rec_txt.char_line_number is null then
         lics_inbound_utility.add_exception('Missing Primary Key - TXT.CHAR_LINE_NUMBER');
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

      insert into lads_ctl_rec_txt
         (cntl_rec_id,
          proc_instr_number,
          char_line_number,
          tdformat,
          tdline,
          arrival_sequence)
      values
         (rcd_lads_ctl_rec_txt.cntl_rec_id,
          rcd_lads_ctl_rec_txt.proc_instr_number,
          rcd_lads_ctl_rec_txt.char_line_number,
          rcd_lads_ctl_rec_txt.tdformat,
          rcd_lads_ctl_rec_txt.tdline,
          rcd_lads_ctl_rec_txt.arrival_sequence);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_txt;

end lads_atllad01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad01 for lads_app.lads_atllad01;
grant execute on lads_atllad01 to lics_app;
