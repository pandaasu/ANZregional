/******************/
/* Package Header */
/******************/
create or replace package asn_ediasn_dcs as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_ediasn_dcs
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - Amtrix to ASN Distribution Centre Acknowledgement Interface

    YYYY/MM   Author          Description
    -------   ------          -----------
    2006/10   Steve Gregan    Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end asn_ediasn_dcs;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_ediasn_dcs as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure process_record_000(par_record in varchar2);
   procedure process_record_010(par_record in varchar2);
   procedure process_record_020(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_prv_record varchar2(32);
   rcd_asn_dcs_hdr asn_dcs_hdr%rowtype;

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
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;
      var_prv_record := null;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('000','000_INTFCID',8);
      lics_inbound_utility.set_definition('000','000_INTCVRSN',6);
      lics_inbound_utility.set_definition('000','000_EDIDOCNUM',6);
      lics_inbound_utility.set_definition('000','000_RECID',3);
      lics_inbound_utility.set_definition('000','000_SENDERID',35);
      lics_inbound_utility.set_definition('000','000_SENDERQUAL',4);
      lics_inbound_utility.set_definition('000','000_RECEIVEID',35);
      lics_inbound_utility.set_definition('000','000_RECEIVEQUAL',4);
      lics_inbound_utility.set_definition('000','000_MESSDATE',6);
      lics_inbound_utility.set_definition('000','000_MESSTIME',4);
      lics_inbound_utility.set_definition('000','000_INTNUM',14);
      lics_inbound_utility.set_definition('000','000_MESGREF',14);
      lics_inbound_utility.set_definition('000','000_MESTYPID',6);
      lics_inbound_utility.set_definition('000','000_MESTYPVER',3);
      lics_inbound_utility.set_definition('000','000_MESTYPREL',3);
      lics_inbound_utility.set_definition('000','000_CONTRLAG',2);
      lics_inbound_utility.set_definition('000','000_ASSOCCODE',6);
      lics_inbound_utility.set_definition('000','000_TESTFLG',1);
      /*-*/
      lics_inbound_utility.set_definition('010','010_INTFCID',8);
      lics_inbound_utility.set_definition('010','010_INTCVRSN',6);
      lics_inbound_utility.set_definition('010','010_EDIDOCNUM',6);
      lics_inbound_utility.set_definition('010','010_RECID',3);
      lics_inbound_utility.set_definition('010','010_ACKINTNUM',14);
      lics_inbound_utility.set_definition('010','010_SENDERID',35);
      lics_inbound_utility.set_definition('010','010_SENDERQUAL',4);
      lics_inbound_utility.set_definition('010','010_REVROUTEADD',14);
      lics_inbound_utility.set_definition('010','010_RECEIVEID',35);
      lics_inbound_utility.set_definition('010','010_RECEIVEQUAL',4);
      lics_inbound_utility.set_definition('010','010_ROUTEADD',14);
      lics_inbound_utility.set_definition('010','010_ACTION',3);
      /*-*/
      lics_inbound_utility.set_definition('020','020_INTFCID',8);
      lics_inbound_utility.set_definition('020','020_INTCVRSN',6);
      lics_inbound_utility.set_definition('020','020_EDIDOCNUM',6);
      lics_inbound_utility.set_definition('020','020_RECID',3);
      lics_inbound_utility.set_definition('020','020_TOTLIN',3);

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
      var_record_identifier := substr(par_record,21,3);
      case var_record_identifier
         when '000' then process_record_000(par_record);
         when '010' then process_record_010(par_record);
         when '020' then process_record_020(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

      /*-*/
      /* Set the control values
      /*-*/
      var_trn_start := false;
      var_prv_record := var_record_identifier;

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
      /* No data found
      /*-*/
      if var_trn_start = true then
         lics_inbound_utility.add_exception('Interface file contains no data');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

   /**************************************************/
   /* This procedure performs the record 000 routine */
   /**************************************************/
   procedure process_record_000(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('000', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Attempt to convert the message data into a date
      /*-*/
      rcd_asn_dcs_hdr.dch_smsg_ack := null;
      begin
         rcd_asn_dcs_hdr.dch_smsg_ack := to_date(lics_inbound_utility.get_variable('000_MESSDATE')||lics_inbound_utility.get_variable('000_MESSTIME'),'yyyymmddhhmi');
      exception
         when others then
            lics_inbound_utility.add_exception('Unable to convert (' || lics_inbound_utility.get_variable('000_MESSDATE') || lics_inbound_utility.get_variable('000_MESSTIME') || ') into a date');
            var_trn_error := true;
      end;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_000;

   /**************************************************/
   /* This procedure performs the record 010 routine */
   /**************************************************/
   procedure process_record_010(par_record in varchar2) is

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

      lics_inbound_utility.parse_record('010', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      rcd_asn_dcs_hdr.dch_smsg_nbr := lics_inbound_utility.get_number('010_REVROUTEADD',null);

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
      /* Check the record sequencing
      /*-*/
      if var_prv_record != '000' and var_prv_record != '010' then
         lics_inbound_utility.add_exception('Record type 010 must follow record type 000 or 010');
         var_trn_error := true;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      /*-*/
      /* Perform the database update when required
      /*-*/
      if var_trn_error = false then

         /*-*/
         /* Update the ASN DCS header row
         /*-*/
         update asn_dcs_hdr
            set dch_smsg_ack = rcd_asn_dcs_hdr.dch_smsg_ack
          where dch_smsg_nbr = rcd_asn_dcs_hdr.dch_smsg_nbr;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_010;

   /**************************************************/
   /* This procedure performs the record 020 routine */
   /**************************************************/
   procedure process_record_020(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('020', par_record);

      /*------------------------------*/
      /* COMMIT - Commit the database */
      /*------------------------------*/

      /*-*/
      /* Commit the database when required
      /*-*/
      if var_trn_error = false and
         var_trn_ignore = false then
         commit;
      else
         rollback;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_020;

end asn_ediasn_dcs;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_ediasn_dcs for ics_app.asn_ediasn_dcs;
grant execute on asn_ediasn_dcs to public;