/******************/
/* Package Header */
/******************/
create or replace package lads_saplad04 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lads
    Package : lads_saplad04
    Owner   : lads_app
    Author  : Steve Gregan

    Description
    -----------
    Local Atlas Data Store - saplad04 - Inbound SAP Deleted Transaction Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/03   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_saplad04;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_saplad04 as

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
   procedure process_record_nod(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_lads_control lads_definition.idoc_control;

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
      lics_inbound_utility.set_definition('NOD','INT_NOD',3);
      lics_inbound_utility.set_definition('NOD','INT_QUERY',30);
      /*-*/
      lics_inbound_utility.set_definition('DAT','INT_DAT',3);
      lics_inbound_utility.set_definition('DAT','INT_TRANSACTION',30);
      lics_inbound_utility.set_definition('DAT','INT_IDENTIFIER',128);

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
         when 'NOD' then process_record_nod(par_record);
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
         /* Set the transaction accepted indicator and rollback the transaction
         /* **note** - releases transaction lock
         /*-*/
         var_accepted := true;
         rollback;

      elsif var_trn_error = true then

         /*-*/
         /* Set the transaction accepted indicator and rollback the transaction
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
         /* Commit the transaction and object code
         /* **note** - releases transaction lock
         /*-*/
         commit;

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
   /* This procedure performs the record NOD routine */
   /**************************************************/
   procedure process_record_nod(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_query varchar2(30);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('NOD', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_query := lics_inbound_utility.get_variable('INT_QUERY');

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
      if var_query is null then
         lics_inbound_utility.add_exception('Missing Primary Key - NOD.INT_QUERY');
         var_trn_error := true;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_nod;

   /**************************************************/
   /* This procedure performs the record DAT routine */
   /**************************************************/
   procedure process_record_dat(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_transaction varchar2(30);
      var_identifier varchar2(128);

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
      var_transaction := lics_inbound_utility.get_variable('INT_TRANSACTION');
      var_identifier := lics_inbound_utility.get_variable('INT_IDENTIFIER');

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
      if var_transaction is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.INT_TRANSACTION');
         var_trn_error := true;
      end if;
      if var_identifier is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.INT_IDENTIFIER');
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
      /* Process the transaction
      /*-*/
      case trim(upper(var_transaction))
         when 'PURCHASE_ORDER' then
            update lads_sto_po_hdr
               set idoc_name = rcd_lads_control.idoc_name,
                   idoc_number = rcd_lads_control.idoc_number,
                   idoc_timestamp = rcd_lads_control.idoc_timestamp,
                   lads_date = sysdate,
                   lads_status = '4'
             where belnr = var_identifier;
         when 'SALES_ORDER' then
            update lads_sal_ord_hdr
               set idoc_name = rcd_lads_control.idoc_name,
                   idoc_number = rcd_lads_control.idoc_number,
                   idoc_timestamp = rcd_lads_control.idoc_timestamp,
                   lads_date = sysdate,
                   lads_status = '4'
             where belnr = var_identifier;
         when 'DELIVERY' then
            update lads_del_hdr
               set idoc_name = rcd_lads_control.idoc_name,
                   idoc_number = rcd_lads_control.idoc_number,
                   idoc_timestamp = rcd_lads_control.idoc_timestamp,
                   lads_date = sysdate,
                   lads_status = '4'
             where vbeln = var_identifier;
         else
            lics_inbound_utility.add_exception('Transaction (' || var_transaction || ') not recognised');
            var_trn_error := true;
      end case;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

end lads_saplad04;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_saplad04 for lads_app.lads_saplad04;
grant execute on lads_saplad04 to lics_app;
