/******************/
/* Package Header */
/******************/
create or replace package ods_sapods01 as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ods
    Package : ods_sapods01
    Owner   : ods_app
    Author  : Steve Gregan

    Description
    -----------
    Operational Data Store - sapod01 - Inbound SAP Document Interface

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/06   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ods_sapods01;
/

/****************/
/* Package Body */
/****************/
create or replace package body ods_sapods01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_cpy(par_record in varchar2);
   procedure process_record_ctl(par_record in varchar2);
   procedure process_record_nod(par_record in varchar2);
   procedure process_record_dat(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   var_company_code varchar2(30);
   var_transaction varchar2(30);
   rcd_ods_control ods_definition.idoc_control;

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
      var_company_code := null;
      var_transaction := null;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('CPY','IDOC_CPY',3);
      lics_inbound_utility.set_definition('CPY','CPY_COMPANY',30);
      /*-*/
      lics_inbound_utility.set_definition('CTL','IDOC_CTL',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('NOD','INT_NOD',3);
      lics_inbound_utility.set_definition('NOD','INT_TRANSACTION',30);
      /*-*/
      lics_inbound_utility.set_definition('DAT','INT_DAT',3);
      lics_inbound_utility.set_definition('DAT','INT_DOC_TYPE',30);
      lics_inbound_utility.set_definition('DAT','INT_DOC_NUMBER',10);
      lics_inbound_utility.set_definition('DAT','INT_DOC_LINE',6);
      lics_inbound_utility.set_definition('DAT','INT_DOC_STATUS',1);

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
         when 'CPY' then process_record_cpy(par_record);
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

      /*-*/
      /* Trigger the data warehouse alignment stream when required
      /*-*/
      if not(var_company_code is null) then
         lics_stream_loader.execute('DW_ALIGNMENT_STREAM_'||var_company_code,null);
      end if;

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
   /* This procedure performs the record CPY routine */
   /**************************************************/
   procedure process_record_cpy(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_record('CPY', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      var_company_code := lics_inbound_utility.get_variable('CPY_COMPANY');

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if var_company_code is null then
         lics_inbound_utility.add_exception('Missing Trigger - CPY.CPY_COMPANY');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_cpy;

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
      var_transaction := null;

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
   /* This procedure performs the record NOD routine */
   /**************************************************/
   procedure process_record_nod(par_record in varchar2) is

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
      var_transaction := lics_inbound_utility.get_variable('INT_TRANSACTION');

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
         lics_inbound_utility.add_exception('Missing Primary Key - NOD.INT_TRANSACTION');
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
      var_doc_type varchar2(128);
      var_doc_number varchar2(128);
      var_doc_line varchar2(128);
      var_doc_status varchar2(128);
      var_wrk_status varchar2(128);

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
      var_doc_type := lics_inbound_utility.get_variable('INT_DOC_TYPE');
      var_doc_number := lics_inbound_utility.get_variable('INT_DOC_NUMBER');
      var_doc_line := lics_inbound_utility.get_variable('INT_DOC_LINE');
      var_doc_status  := lics_inbound_utility.get_variable('INT_DOC_STATUS');
      if var_doc_line is null then
         var_doc_line := '*NONE';
      end if;
      if var_doc_status is null then
         var_doc_status := 'C';
      end if;

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
         lics_inbound_utility.add_exception('Missing Primary Key - NOD.INT_TRANSACTION');
         var_trn_error := true;
      end if;
      if var_doc_type is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.INT_DOC_TYPE');
         var_trn_error := true;
      end if;
      if var_doc_number is null then
         lics_inbound_utility.add_exception('Missing Primary Key - DAT.INT_DOC_NUMBER');
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
         when 'PURCHASE_ORDER_DELETED' then
            if trim(upper(var_doc_type)) != 'PURCHASE_ORDER' then
               lics_inbound_utility.add_exception('Document (' || trim(upper(var_doc_type)) || ') not recognised for transaction PURCHASE_ORDER_DELETED');
               var_trn_error := true;
            else
               var_wrk_status := '*DELETED';
            end if;
         when 'SALES_ORDER_DELETED' then
            if trim(upper(var_doc_type)) != 'SALES_ORDER' then
               lics_inbound_utility.add_exception('Document (' || trim(upper(var_doc_type)) || ') not recognised for transaction SALES_ORDER_DELETED');
               var_trn_error := true;
            else
               var_wrk_status := '*DELETED';
            end if;
         when 'DELIVERY_DELETED' then
            if trim(upper(var_doc_type)) != 'DELIVERY' then
               lics_inbound_utility.add_exception('Document (' || trim(upper(var_doc_type)) || ') not recognised for transaction DELIVERY_DELETED');
               var_trn_error := true;
            else
               var_wrk_status := '*DELETED';
            end if;
         when 'SALES_ORDER_LINE_STATUS' then
            if trim(upper(var_doc_type)) != 'SALES_ORDER_LINE' then
               lics_inbound_utility.add_exception('Document (' || trim(upper(var_doc_type)) || ') not recognised for transaction SALES_ORDER_LINE_STATUS');
               var_trn_error := true;
            else
               var_wrk_status := '*OPEN';
               if var_doc_status = 'C' then
                  var_wrk_status := '*CLOSED';
               end if;
            end if;
         when 'DELIVERY_LINE_STATUS' then
            if trim(upper(var_doc_type)) != 'DELIVERY_LINE' then
               lics_inbound_utility.add_exception('Document (' || trim(upper(var_doc_type)) || ') not recognised for transaction DELIVERY_LINE_STATUS');
               var_trn_error := true;
            else
               var_wrk_status := '*OPEN';
               if var_doc_status = 'C' then
                  var_wrk_status := '*CLOSED';
               end if;
            end if;
         else
            lics_inbound_utility.add_exception('Transaction (' || var_transaction || ') not recognised');
            var_trn_error := true;

      end case;

      /*-*/
      /* Insert/update the SAP document status
      /*-*/
      begin
         insert into sap_doc_status
            values (trim(upper(var_doc_type)),
                    var_doc_number,
                    var_doc_line,
                    var_wrk_status,
                    sysdate);
      exception
         when dup_val_on_index then
            update sap_doc_status
               set doc_status = var_wrk_status,
                   ods_date = sysdate
             where doc_type = trim(upper(var_doc_type))
               and doc_number = var_doc_number
               and doc_line = var_doc_line;
      end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_dat;

end ods_sapods01;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_sapods01 for ods_app.ods_sapods01;
grant execute on ods_sapods01 to lics_app;
grant execute on ods_sapods01 to ics_app;
