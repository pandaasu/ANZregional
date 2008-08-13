/******************/
/* Package Header */
/******************/
create or replace package ods_atlods12 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_atlods12
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - atlods12 - Inbound Invoice Summary

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/10   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_atlods12;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_atlods12 as

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
   rcd_ods_control ods_definition.idoc_control;
   rcd_sap_inv_sum_hdr sap_inv_sum_hdr%rowtype;
   rcd_sap_inv_sum_det sap_inv_sum_det%rowtype;

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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when commited
      /*-*/
      if var_trn_ignore = true then
         rollback;
      elsif var_trn_start = true then
         if var_trn_error = true then
            rollback;
         else
            commit;
            /*-*/
            /* Call the ODS_VALIDATION procedure.
            /*-*/
            begin
              lics_pipe.spray('*DAEMON','OV','*WAKE');
            exception
               when others then
                  lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
            end;
            /*-*/
            /* Call the interface monitor procedure.
            /*-*/
            begin
               ods_atlods12_monitor.execute(rcd_sap_inv_sum_hdr.fkdat,rcd_sap_inv_sum_hdr.bukrs,rcd_sap_inv_sum_hdr.hdrseq);
            exception
               when others then
                  lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
            end;
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
      rcd_ods_control.idoc_name := lics_inbound_utility.get_variable('IDOC_NAME');
      if rcd_ods_control.idoc_name is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NAME - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC number
      /*-*/
      rcd_ods_control.idoc_number := lics_inbound_utility.get_number('IDOC_NUMBER','9999999999999999');
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;
      if rcd_ods_control.idoc_number is null then
         lics_inbound_utility.add_exception('Field - CTL.IDOC_NUMBER - Must not be null');
         var_trn_error := true;
      end if;

      /*-*/
      /* Extract and validate the control IDOC timestamp
      /*-*/
      rcd_ods_control.idoc_timestamp := lics_inbound_utility.get_variable('IDOC_DATE') || lics_inbound_utility.get_variable('IDOC_TIME');
      if rcd_ods_control.idoc_timestamp is null then
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
      cursor csr_sap_inv_sum_hdr_01 is
         select
            sap_inv_sum_hdr_seq.nextval as nextseq
         from dual;
      rcd_sap_inv_sum_hdr_01 csr_sap_inv_sum_hdr_01%rowtype;

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
      rcd_sap_inv_sum_hdr.fkdat := lics_inbound_utility.get_variable('FKDAT');
      rcd_sap_inv_sum_hdr.bukrs := lics_inbound_utility.get_variable('BUKRS');
      rcd_sap_inv_sum_hdr.datum := lics_inbound_utility.get_variable('DATUM');
      rcd_sap_inv_sum_hdr.uzeit := lics_inbound_utility.get_variable('UZEIT');
      rcd_sap_inv_sum_hdr.idoc_name := rcd_ods_control.idoc_name;
      rcd_sap_inv_sum_hdr.idoc_number := rcd_ods_control.idoc_number;
      rcd_sap_inv_sum_hdr.idoc_timestamp := rcd_ods_control.idoc_timestamp;
      rcd_sap_inv_sum_hdr.procg_status := ods_constants.inv_sum_loaded;
      rcd_sap_inv_sum_hdr.valdtn_status := ods_constants.valdtn_unchecked;
      rcd_sap_inv_sum_hdr.balncd_flag := null;
      rcd_sap_inv_sum_hdr.flag_file_status := ods_constants.inv_sum_loaded;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_sap_inv_sum_det.detseq := 0;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sap_inv_sum_hdr.fkdat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.FKDAT');
         var_trn_error := true;
      end if;
      if rcd_sap_inv_sum_hdr.bukrs is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.BUKRS');
         var_trn_error := true;
      end if;

      /*-*/
      /* Update the header sequence when primary key supplied
      /*-*/
      if not(rcd_sap_inv_sum_hdr.fkdat is null) and
         not(rcd_sap_inv_sum_hdr.bukrs is null) then
         open csr_sap_inv_sum_hdr_01;
         fetch csr_sap_inv_sum_hdr_01 into rcd_sap_inv_sum_hdr_01;
            rcd_sap_inv_sum_hdr.hdrseq := rcd_sap_inv_sum_hdr_01.nextseq;
         close csr_sap_inv_sum_hdr_01;
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

      insert into sap_inv_sum_hdr
        (fkdat,
         bukrs,
         hdrseq,
         datum,
         uzeit,
         idoc_name,
         idoc_number,
         idoc_timestamp,
         procg_status,
         valdtn_status,
         balncd_flag,
         flag_file_status)
     values
        (rcd_sap_inv_sum_hdr.fkdat,
         rcd_sap_inv_sum_hdr.bukrs,
         rcd_sap_inv_sum_hdr.hdrseq,
         rcd_sap_inv_sum_hdr.datum,
         rcd_sap_inv_sum_hdr.uzeit,
         rcd_sap_inv_sum_hdr.idoc_name,
         rcd_sap_inv_sum_hdr.idoc_number,
         rcd_sap_inv_sum_hdr.idoc_timestamp,
         rcd_sap_inv_sum_hdr.procg_status,
         rcd_sap_inv_sum_hdr.valdtn_status,
         rcd_sap_inv_sum_hdr.balncd_flag,
         rcd_sap_inv_sum_hdr.flag_file_status);

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
      rcd_sap_inv_sum_det.fkdat := rcd_sap_inv_sum_hdr.fkdat;
      rcd_sap_inv_sum_det.vkorg := lics_inbound_utility.get_variable('VKORG');
      rcd_sap_inv_sum_det.hdrseq := rcd_sap_inv_sum_hdr.hdrseq;
      rcd_sap_inv_sum_det.detseq := rcd_sap_inv_sum_det.detseq + 1;
      rcd_sap_inv_sum_det.fkart := lics_inbound_utility.get_variable('FKART');
      rcd_sap_inv_sum_det.znumiv := lics_inbound_utility.get_number('ZNUMIV',null);
      rcd_sap_inv_sum_det.znumps := lics_inbound_utility.get_number('ZNUMPS',null);
      rcd_sap_inv_sum_det.netwr := lics_inbound_utility.get_number('NETWR',null);
      rcd_sap_inv_sum_det.waerk := lics_inbound_utility.get_variable('WAERK');

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
      if rcd_sap_inv_sum_det.fkdat is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.FKDAT');
         var_trn_error := true;
      end if;
      if rcd_sap_inv_sum_det.vkorg is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DET.VKORG');
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

      insert into sap_inv_sum_det
         (fkdat,
          vkorg,
          hdrseq,
          detseq,
          fkart,
          znumiv,
          znumps,
          netwr,
          waerk)
      values
         (rcd_sap_inv_sum_det.fkdat,
          rcd_sap_inv_sum_det.vkorg,
          rcd_sap_inv_sum_det.hdrseq,
          rcd_sap_inv_sum_det.detseq,
          rcd_sap_inv_sum_det.fkart,
          rcd_sap_inv_sum_det.znumiv,
          rcd_sap_inv_sum_det.znumps,
          rcd_sap_inv_sum_det.netwr,
          rcd_sap_inv_sum_det.waerk);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end ods_atlods12;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_atlods12 for ods_app.ods_atlods12;
grant execute on ods_atlods12 to lics_app;