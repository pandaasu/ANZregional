--
-- LADS_ATLLAD31  (Package) 
--
CREATE OR REPLACE PACKAGE LADS_APP.lads_atllad31 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
   System  : lads
   Package : lads_atllad31
   Owner   : lads_app
   Author  : Ben Halicki

   Description
   -----------
   Local Atlas Data Store - atllad31 - Plant Maintenance Equipment Master

   **Notes** 1. This package must NOT issue commit/rollback statements.
             2. This package must raise an exception on failure to exclude database activity from parent commit.

   TODO: Implement ATLLAD31_MONITOR
         Implement BDS Flattening logic

   YYYY/MM   Author         Description
   -------   ------         -----------
   2010/10   Ben Halicki    Created this package

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad31;
/


--
-- LADS_ATLLAD31  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_ATLLAD31 FOR LADS_APP.LADS_ATLLAD31;


GRANT EXECUTE ON LADS_APP.LADS_ATLLAD31 TO LICS_APP;

--
-- LADS_ATLLAD31  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY LADS_APP.lads_atllad31 as

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

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   
   rcd_lads_control lads_definition.idoc_control;
   rcd_lads_equ_hdr lads_equ_hdr%rowtype;
   
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
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',10);     
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','EQUNR',18);
      lics_inbound_utility.set_definition('HDR','SHTXT',40);
      lics_inbound_utility.set_definition('HDR','TPLNR',40);
      lics_inbound_utility.set_definition('HDR','EQFNR',30);
      lics_inbound_utility.set_definition('HDR','SWERK',4);
      
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
      con_ack_code constant varchar2(32) := 'ATLLAD31';
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
            lads_atllad31_monitor.execute_before(rcd_lads_equ_hdr.equnr); 
         exception
            when others then
               lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad31_monitor.execute_after(rcd_lads_equ_hdr.equnr);
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
      var_trn_start := false;
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
      rcd_lads_control.idoc_number := 9999999999999999;
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
      /* Set all records to status 4 
      /* Note: any deleted records will remain with status 4 once interface load completes 
      /*-*/
      update lads_equ_hdr set lads_status='4';
      
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

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transaction
      /*-*/
      complete_transaction;

      /*-*/
      /* Update the transaction variables
      /*-*/
      var_trn_start := true;

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
      rcd_lads_equ_hdr.equnr := lics_inbound_utility.get_variable('EQUNR');
      rcd_lads_equ_hdr.shtxt := lics_inbound_utility.get_variable('SHTXT');
      rcd_lads_equ_hdr.tplnr := lics_inbound_utility.get_variable('TPLNR');
      rcd_lads_equ_hdr.eqfnr := lics_inbound_utility.get_variable('EQFNR');
      rcd_lads_equ_hdr.swerk := lics_inbound_utility.get_variable('SWERK');
      rcd_lads_equ_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_equ_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_equ_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_equ_hdr.lads_date := sysdate;
      rcd_lads_equ_hdr.lads_status := '1';
      rcd_lads_equ_hdr.lads_flattened := '0';

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
      if rcd_lads_equ_hdr.equnr is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.EQUNR');
         var_trn_error := true;
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
      update lads_equ_hdr set
           shtxt = rcd_lads_equ_hdr.shtxt,
           tplnr = rcd_lads_equ_hdr.tplnr,
           eqfnr = rcd_lads_equ_hdr.eqfnr,
           swerk = rcd_lads_equ_hdr.swerk,
           idoc_name = rcd_lads_equ_hdr.idoc_name,
           idoc_number = rcd_lads_equ_hdr.idoc_number,
           idoc_timestamp = rcd_lads_equ_hdr.idoc_timestamp,
           lads_date = rcd_lads_equ_hdr.lads_date,
           lads_status = rcd_lads_equ_hdr.lads_status,
           lads_flattened = rcd_lads_equ_hdr.lads_flattened
      where
           equnr = rcd_lads_equ_hdr.equnr;

      if sql%notfound then
           insert into lads_equ_hdr
           (
                equnr,
                shtxt,
                tplnr,
                eqfnr,
                swerk,
                idoc_name,
                idoc_number,
                idoc_timestamp,
                lads_date,
                lads_status,
                lads_flattened
           )
           values
           (
                rcd_lads_equ_hdr.equnr,
                rcd_lads_equ_hdr.shtxt,
                rcd_lads_equ_hdr.tplnr,
                rcd_lads_equ_hdr.eqfnr,
                rcd_lads_equ_hdr.swerk,
                rcd_lads_equ_hdr.idoc_name,
                rcd_lads_equ_hdr.idoc_number,
                rcd_lads_equ_hdr.idoc_timestamp,
                rcd_lads_equ_hdr.lads_date,
                rcd_lads_equ_hdr.lads_status,
                rcd_lads_equ_hdr.lads_flattened
           );   
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end lads_atllad31;
/


--
-- LADS_ATLLAD31  (Synonym) 
--
CREATE PUBLIC SYNONYM LADS_ATLLAD31 FOR LADS_APP.LADS_ATLLAD31;


GRANT EXECUTE ON LADS_APP.LADS_ATLLAD31 TO LICS_APP;

