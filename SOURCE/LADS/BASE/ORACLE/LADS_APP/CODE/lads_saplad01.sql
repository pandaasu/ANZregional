/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_saplad01
 Owner   : lads_app
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - saplad01 - Inbound SAP Audit Interface

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/06   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_saplad01 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_saplad01;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_saplad01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_nod(par_record in varchar2);
   procedure process_record_fld(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_ref_hdr lads_ref_hdr%rowtype;
   rcd_lads_ref_fld lads_ref_fld%rowtype;
   rcd_lads_ref_dat lads_ref_dat%rowtype;
   var_chg_only boolean;

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
      lics_inbound_utility.set_definition('NOD','IDOC_HDR',3);
      lics_inbound_utility.set_definition('NOD','Z_TABGRP',4);
      lics_inbound_utility.set_definition('NOD','Z_TABNAME',30);
      lics_inbound_utility.set_definition('NOD','Z_TABHIE',2);
      lics_inbound_utility.set_definition('NOD','Z_CHNGONLY',1);
      lics_inbound_utility.set_definition('NOD','Z_KEYLEN',5);
      lics_inbound_utility.set_definition('NOD','Z_WALEN',5);
      /*-*/
      lics_inbound_utility.set_definition('FLD','IDOC_FLD',3);
      lics_inbound_utility.set_definition('FLD','Z_TABNAME',30);
      lics_inbound_utility.set_definition('FLD','Z_FIELDNAME',30);
      lics_inbound_utility.set_definition('FLD','Z_OFFSET',6);
      lics_inbound_utility.set_definition('FLD','Z_LENG',6);
      /*-*/
      lics_inbound_utility.set_definition('DAT','IDOC_DAT',3);
      lics_inbound_utility.set_definition('DAT','Z_TABNAME',30);
      lics_inbound_utility.set_definition('DAT','Z_RECNR',4);
      lics_inbound_utility.set_definition('DAT','Z_CHGTYP',1);
      lics_inbound_utility.set_definition('DAT','Z_DATA',451);

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
         when 'NOD' then process_record_hdr(par_record);
         when 'FLD' then process_record_fld(par_record);
         when 'DAT' then process_record_dat(par_record);
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
      con_ack_code constant varchar2(32) := 'ATLLAD10';
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
            lads_atllad10_monitor.execute(rcd_lads_ref_hdr.z_tabname);
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
      cursor csr_lads_ref_hdr_01 is
         select
            t01.z_tabname,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_ref_hdr t01
         where t01.z_tabname = rcd_lads_ref_hdr.z_tabname;
      rcd_lads_ref_hdr_01 csr_lads_ref_hdr_01%rowtype;

      cursor csr_lads_ref_dat_01 is
         select
            nvl(max(t01.datseq),0) as maxseq
         from lads_ref_dat t01
         where t01.z_tabname = rcd_lads_ref_hdr.z_tabname;
      rcd_lads_ref_dat_01 csr_lads_ref_dat_01%rowtype;

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
      rcd_lads_ref_hdr.z_tabgrp := lics_inbound_utility.get_variable('Z_TABGRP');
      rcd_lads_ref_hdr.z_tabname := lics_inbound_utility.get_variable('Z_TABNAME');
      rcd_lads_ref_hdr.z_tabhie := lics_inbound_utility.get_number('Z_TABHIE',null);
      rcd_lads_ref_hdr.z_chngonly := lics_inbound_utility.get_variable('Z_CHNGONLY');
      rcd_lads_ref_hdr.z_keylen := lics_inbound_utility.get_number('Z_KEYLEN',null);
      rcd_lads_ref_hdr.z_walen := lics_inbound_utility.get_number('Z_WALEN',null);
      rcd_lads_ref_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_ref_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_ref_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_ref_hdr.lads_date := sysdate;
      rcd_lads_ref_hdr.lads_status := '1';

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*-*/
      /* Reset child sequences
      /*-*/
      rcd_lads_ref_fld.fldseq := 0;
      rcd_lads_ref_dat.datseq := 0;

      /*-*/
      /* Reset the change only indicator
      /*-*/
      var_chg_only := false;
      if upper(rcd_lads_ref_hdr.z_chngonly) = 'X' then
         var_chg_only := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_lads_ref_hdr.z_tabname is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.Z_TABNAME');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if var_chg_only = false then
         if not(rcd_lads_ref_hdr.z_tabname is null) then
            var_exists := true;
            open csr_lads_ref_hdr_01;
            fetch csr_lads_ref_hdr_01 into rcd_lads_ref_hdr_01;
            if csr_lads_ref_hdr_01%notfound then
               var_exists := false;
            end if;
            close csr_lads_ref_hdr_01;
            if var_exists = true then
               if rcd_lads_ref_hdr.idoc_timestamp > rcd_lads_ref_hdr_01.idoc_timestamp then
                  delete from lads_ref_dat where z_tabname = rcd_lads_ref_hdr.z_tabname;
                  delete from lads_ref_fld where z_tabname = rcd_lads_ref_hdr.z_tabname;
               else
                  var_trn_ignore := true;
               end if;
            end if;
         end if;
      else
         open csr_lads_ref_dat_01;
         fetch csr_lads_ref_dat_01 into rcd_lads_ref_dat_01;
         if csr_lads_ref_dat_01%notfound then
            rcd_lads_ref_dat_01.maxseq := 0;
         end if;
         close csr_lads_ref_dat_01;
         rcd_lads_ref_dat.datseq := rcd_lads_ref_dat_01.maxseq;
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

      update lads_ref_hdr set
         z_tabgrp = rcd_lads_ref_hdr.z_tabgrp,
         z_tabhie = rcd_lads_ref_hdr.z_tabhie,
         z_chngonly = rcd_lads_ref_hdr.z_chngonly,
         z_keylen = rcd_lads_ref_hdr.z_keylen,
         z_walen = rcd_lads_ref_hdr.z_walen,
         idoc_name = rcd_lads_ref_hdr.idoc_name,
         idoc_number = rcd_lads_ref_hdr.idoc_number,
         idoc_timestamp = rcd_lads_ref_hdr.idoc_timestamp,
         lads_date = rcd_lads_ref_hdr.lads_date,
         lads_status = rcd_lads_ref_hdr.lads_status
      where z_tabname = rcd_lads_ref_hdr.z_tabname;
      if sql%notfound then
         insert into lads_ref_hdr
            (z_tabgrp,
             z_tabname,
             z_tabhie,
             z_chngonly,
             z_keylen,
             z_walen,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_ref_hdr.z_tabgrp,
             rcd_lads_ref_hdr.z_tabname,
             rcd_lads_ref_hdr.z_tabhie,
             rcd_lads_ref_hdr.z_chngonly,
             rcd_lads_ref_hdr.z_keylen,
             rcd_lads_ref_hdr.z_walen,
             rcd_lads_ref_hdr.idoc_name,
             rcd_lads_ref_hdr.idoc_number,
             rcd_lads_ref_hdr.idoc_timestamp,
             rcd_lads_ref_hdr.lads_date,
             rcd_lads_ref_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record FLD routine */
   /**************************************************/
   procedure process_record_fld(par_record in varchar2) is

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

      if var_chg_only = true then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('FLD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ref_fld.z_tabname := rcd_lads_ref_hdr.z_tabname;
      rcd_lads_ref_fld.fldseq := rcd_lads_ref_fld.fldseq + 1;
      rcd_lads_ref_fld.z_fieldname := lics_inbound_utility.get_variable('Z_FIELDNAME');
      rcd_lads_ref_fld.z_offset := lics_inbound_utility.get_number('Z_OFFSET',null);
      rcd_lads_ref_fld.z_leng := lics_inbound_utility.get_number('Z_LENG',null);

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
      if rcd_lads_ref_fld.z_tabname is null then
         lics_inbound_utility.add_exception('Missing Primary Key - FLD.Z_TABNAME');
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

      insert into lads_ref_fld
         (z_tabname,
          fldseq,
          z_fieldname,
          z_offset,
          z_leng)
      values
         (rcd_lads_ref_fld.z_tabname,
          rcd_lads_ref_fld.fldseq,
          rcd_lads_ref_fld.z_fieldname,
          rcd_lads_ref_fld.z_offset,
          rcd_lads_ref_fld.z_leng);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_fld;

   /**************************************************/
   /* This procedure performs the record DAT routine */
   /**************************************************/
   procedure process_record_dat(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_update boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_ref_dat_01 is
         select
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_ref_dat t01
         where t01.z_tabname = rcd_lads_ref_dat.z_tabname
           and substr(t01.z_data,1,rcd_lads_ref_hdr.z_keylen) = substr(rcd_lads_ref_dat.z_data,1,rcd_lads_ref_hdr.z_keylen);
      rcd_lads_ref_dat_01 csr_lads_ref_dat_01%rowtype;

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

      lics_inbound_utility.parse_record('DAT', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_lads_ref_dat.z_tabname := rcd_lads_ref_hdr.z_tabname;
      rcd_lads_ref_dat.z_recnr := lics_inbound_utility.get_number('Z_RECNR',null);
      rcd_lads_ref_dat.z_chgtyp := lics_inbound_utility.get_variable('Z_CHGTYP');
      rcd_lads_ref_dat.z_data := lics_inbound_utility.get_variable('Z_DATA');
      rcd_lads_ref_dat.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_ref_dat.idoc_timestamp := rcd_lads_control.idoc_timestamp;

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
      if rcd_lads_ref_dat.z_tabname is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.Z_TABNAME');
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

      /*-*/
      /* Full replacement - insert new data rows
      /*-*/
      if var_chg_only = false then

         rcd_lads_ref_dat.datseq := rcd_lads_ref_dat.datseq + 1;

         insert into lads_ref_dat
            (z_tabname,
             datseq,
             z_recnr,
             z_chgtyp,
             z_data,
             idoc_number,
             idoc_timestamp)
         values
            (rcd_lads_ref_dat.z_tabname,
             rcd_lads_ref_dat.datseq,
             rcd_lads_ref_dat.z_recnr,
             rcd_lads_ref_dat.z_chgtyp,
             rcd_lads_ref_dat.z_data,
             rcd_lads_ref_dat.idoc_number,
             rcd_lads_ref_dat.idoc_timestamp);

      /*-*/
      /* Changes - update/insert data rows
      /*-*/
      else

         var_update := false;
         open csr_lads_ref_dat_01;
         fetch csr_lads_ref_dat_01 into rcd_lads_ref_dat_01;
         if csr_lads_ref_dat_01%found then
            if rcd_lads_ref_dat.idoc_timestamp > rcd_lads_ref_dat_01.idoc_timestamp then
               var_update := true;
            end if;
         else
            var_update := true;
         end if;
         close csr_lads_ref_dat_01;

         if var_update = true then

            update lads_ref_dat set
               z_chgtyp = rcd_lads_ref_dat.z_chgtyp,
               z_data = rcd_lads_ref_dat.z_data,
               idoc_number = rcd_lads_ref_hdr.idoc_number,
               idoc_timestamp = rcd_lads_ref_hdr.idoc_timestamp
            where z_tabname = rcd_lads_ref_dat.z_tabname
              and substr(z_data,1,rcd_lads_ref_hdr.z_keylen) = substr(rcd_lads_ref_dat.z_data,1,rcd_lads_ref_hdr.z_keylen);
            if sql%notfound then

               rcd_lads_ref_dat.datseq := rcd_lads_ref_dat.datseq + 1;

               insert into lads_ref_dat
                  (z_tabname,
                   datseq,
                   z_recnr,
                   z_chgtyp,
                   z_data,
                   idoc_number,
                   idoc_timestamp)
               values
                  (rcd_lads_ref_dat.z_tabname,
                   rcd_lads_ref_dat.datseq,
                   rcd_lads_ref_dat.z_recnr,
                   rcd_lads_ref_dat.z_chgtyp,
                   rcd_lads_ref_dat.z_data,
                   rcd_lads_ref_dat.idoc_number,
                   rcd_lads_ref_dat.idoc_timestamp);

            end if;

         end if;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

end lads_saplad01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_saplad01 for lads_app.lads_saplad01;
grant execute on lads_saplad01 to lics_app;
