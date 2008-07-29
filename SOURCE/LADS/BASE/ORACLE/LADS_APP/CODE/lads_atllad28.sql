/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_atllad28
 Owner   : lads_app
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_lads_atllad28 - Open Purachase Order/Requisition

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created
 2008/05   Trevor Keon    Added calls to monitor before and after procedure

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_atllad28 as

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end lads_atllad28;
/

/****************/
/* Package Body */
/****************/
create or replace package body lads_atllad28 as

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
   rcd_lads_opr_hdr lads_opr_hdr%rowtype;

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
      lics_inbound_utility.set_definition('CTL','IDENTIFIER',3);
      lics_inbound_utility.set_definition('CTL','IDOC_NAME',30);
      lics_inbound_utility.set_definition('CTL','IDOC_NUMBER',16);
      lics_inbound_utility.set_definition('CTL','IDOC_DATE',8);
      lics_inbound_utility.set_definition('CTL','IDOC_TIME',6);
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDENTIFIER',3);
      lics_inbound_utility.set_definition('HDR','TARGET',10);
      lics_inbound_utility.set_definition('HDR','MATERIAL',18);
      lics_inbound_utility.set_definition('HDR','MRP_ELEMENT',2);
      lics_inbound_utility.set_definition('HDR','VENDOR',10);
      lics_inbound_utility.set_definition('HDR','STO_LOCATION',4);
      lics_inbound_utility.set_definition('HDR','DATE',8);
      lics_inbound_utility.set_definition('HDR','RECREQ_QTY',15);
      lics_inbound_utility.set_definition('HDR','REC_INDICATOR',1);
      lics_inbound_utility.set_definition('HDR','UOM',3);
      lics_inbound_utility.set_definition('HDR','ORDER_NUM',10);
      lics_inbound_utility.set_definition('HDR','ORDER_ITEM',5);
      lics_inbound_utility.set_definition('HDR','MRP_TYPE',2);
      lics_inbound_utility.set_definition('HDR','PLANT',4);
      lics_inbound_utility.set_definition('HDR','BUSINESS',2);
      lics_inbound_utility.set_definition('HDR','DOC_TYPE',4);
      lics_inbound_utility.set_definition('HDR','CO_CODE',4);
      lics_inbound_utility.set_definition('HDR','SOURCE_PLANT',4);
      lics_inbound_utility.set_definition('HDR','ISSUE_SLOC',4);
      lics_inbound_utility.set_definition('HDR','SHIP_DATE',8);
      lics_inbound_utility.set_definition('HDR','ITEM_CATEGORY',1);

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
      con_ack_code constant varchar2(32) := 'LADS_ATLLAD28';
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false Then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true Then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
         
         begin
            lads_atllad28_monitor.execute_before(rcd_lads_opr_hdr.order_num,rcd_lads_opr_hdr.order_item);
         exception
            when others then
                lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
         end;
         
         commit;
         
         begin
            lads_atllad28_monitor.execute_after(rcd_lads_opr_hdr.order_num,rcd_lads_opr_hdr.order_item);
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
      cursor csr_lads_opr_hdr_01 is
         select
            t01.order_num,
            t01.order_item,
            t01.idoc_number,
            t01.idoc_timestamp
         from lads_opr_hdr t01
         where t01.order_num = rcd_lads_opr_hdr.order_num
           and t01.order_item = rcd_lads_opr_hdr.order_item;
      rcd_lads_opr_hdr_01 csr_lads_opr_hdr_01%rowtype;

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
      rcd_lads_opr_hdr.target := lics_inbound_utility.get_variable('TARGET');
      rcd_lads_opr_hdr.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_lads_opr_hdr.mrp_element := lics_inbound_utility.get_variable('MRP_ELEMENT');
      rcd_lads_opr_hdr.vendor := lics_inbound_utility.get_variable('VENDOR');
      rcd_lads_opr_hdr.sto_location := lics_inbound_utility.get_variable('STO_LOCATION');
      rcd_lads_opr_hdr.opr_date := lics_inbound_utility.get_number('DATE',null);
      rcd_lads_opr_hdr.recreq_qty := lics_inbound_utility.get_number('RECREQ_QTY',null);
      rcd_lads_opr_hdr.rec_indicator := lics_inbound_utility.get_variable('REC_INDICATOR');
      rcd_lads_opr_hdr.uom := lics_inbound_utility.get_variable('UOM');
      rcd_lads_opr_hdr.order_num := lics_inbound_utility.get_number('ORDER_NUM',null);
      rcd_lads_opr_hdr.order_item := lics_inbound_utility.get_number('ORDER_ITEM',null);
      rcd_lads_opr_hdr.mrp_type := lics_inbound_utility.get_variable('MRP_TYPE');
      rcd_lads_opr_hdr.plant := lics_inbound_utility.get_variable('PLANT');
      rcd_lads_opr_hdr.business := lics_inbound_utility.get_variable('BUSINESS');
      rcd_lads_opr_hdr.doc_type := lics_inbound_utility.get_variable('DOC_TYPE');
      rcd_lads_opr_hdr.co_code := lics_inbound_utility.get_variable('CO_CODE');
      rcd_lads_opr_hdr.source_plant := lics_inbound_utility.get_variable('SOURCE_PLANT');
      rcd_lads_opr_hdr.issue_sloc := lics_inbound_utility.get_variable('ISSUE_SLOC');
      rcd_lads_opr_hdr.ship_date := lics_inbound_utility.get_number('SHIP_DATE',null);
      rcd_lads_opr_hdr.item_category := lics_inbound_utility.get_variable('ITEM_CATEGORY');
      rcd_lads_opr_hdr.idoc_name := rcd_lads_control.idoc_name;
      rcd_lads_opr_hdr.idoc_number := rcd_lads_control.idoc_number;
      rcd_lads_opr_hdr.idoc_timestamp := rcd_lads_control.idoc_timestamp;
      rcd_lads_opr_hdr.lads_date := sysdate;
      rcd_lads_opr_hdr.lads_status := '1';

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
      if rcd_lads_opr_hdr.order_num is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_OPR_HDR - ORDER_NUM');
         var_trn_error := true;
      end if;
      /*-*/
      if rcd_lads_opr_hdr.order_item is null then
         lics_inbound_utility.add_exception('Missing Primary Key - LADS_OPR_HDR - ORDER_ITEM');
         var_trn_error := true;
      end if;

      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      if not(rcd_lads_opr_hdr.order_num is null) then
         var_exists := true;
         open csr_lads_opr_hdr_01;
         fetch csr_lads_opr_hdr_01 into rcd_lads_opr_hdr_01;
         if csr_lads_opr_hdr_01%notfound then
            var_exists := false;
         end if;
         close csr_lads_opr_hdr_01;
         if var_exists = true then
            if rcd_lads_opr_hdr.idoc_timestamp > rcd_lads_opr_hdr_01.idoc_timestamp then
               null;
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

      update lads_opr_hdr set
         target = rcd_lads_opr_hdr.target,
         material = rcd_lads_opr_hdr.material,
         mrp_element = rcd_lads_opr_hdr.mrp_element,
         vendor = rcd_lads_opr_hdr.vendor,
         sto_location = rcd_lads_opr_hdr.sto_location,
         opr_date = rcd_lads_opr_hdr.opr_date,
         recreq_qty = rcd_lads_opr_hdr.recreq_qty,
         rec_indicator = rcd_lads_opr_hdr.rec_indicator,
         uom = rcd_lads_opr_hdr.uom,
         order_num = rcd_lads_opr_hdr.order_num,
         order_item = rcd_lads_opr_hdr.order_item,
         mrp_type = rcd_lads_opr_hdr.mrp_type,
         plant = rcd_lads_opr_hdr.plant,
         business = rcd_lads_opr_hdr.business,
         doc_type = rcd_lads_opr_hdr.doc_type,
         co_code = rcd_lads_opr_hdr.co_code,
         source_plant = rcd_lads_opr_hdr.source_plant,
         issue_sloc = rcd_lads_opr_hdr.issue_sloc,
         ship_date = rcd_lads_opr_hdr.ship_date,
         item_category = rcd_lads_opr_hdr.item_category,
         idoc_name = rcd_lads_opr_hdr.idoc_name,
         idoc_number = rcd_lads_opr_hdr.idoc_number,
         idoc_timestamp = rcd_lads_opr_hdr.idoc_timestamp,
         lads_date = rcd_lads_opr_hdr.lads_date,
         lads_status = rcd_lads_opr_hdr.lads_status
      where order_num = rcd_lads_opr_hdr.order_num
        and order_item = rcd_lads_opr_hdr.order_item;
      if sql%notfound then
         insert into lads_opr_hdr
            (target,
             material,
             mrp_element,
             vendor,
             sto_location,
             opr_date,
             recreq_qty,
             rec_indicator,
             uom,
             order_num,
             order_item,
             mrp_type,
             plant,
             business,
             doc_type,
             co_code,
             source_plant,
             issue_sloc,
             ship_date,
             item_category,
             idoc_name,
             idoc_number,
             idoc_timestamp,
             lads_date,
             lads_status)
         values
            (rcd_lads_opr_hdr.target,
             rcd_lads_opr_hdr.material,
             rcd_lads_opr_hdr.mrp_element,
             rcd_lads_opr_hdr.vendor,
             rcd_lads_opr_hdr.sto_location,
             rcd_lads_opr_hdr.opr_date,
             rcd_lads_opr_hdr.recreq_qty,
             rcd_lads_opr_hdr.rec_indicator,
             rcd_lads_opr_hdr.uom,
             rcd_lads_opr_hdr.order_num,
             rcd_lads_opr_hdr.order_item,
             rcd_lads_opr_hdr.mrp_type,
             rcd_lads_opr_hdr.plant,
             rcd_lads_opr_hdr.business,
             rcd_lads_opr_hdr.doc_type,
             rcd_lads_opr_hdr.co_code,
             rcd_lads_opr_hdr.source_plant,
             rcd_lads_opr_hdr.issue_sloc,
             rcd_lads_opr_hdr.ship_date,
             rcd_lads_opr_hdr.item_category,
             rcd_lads_opr_hdr.idoc_name,
             rcd_lads_opr_hdr.idoc_number,
             rcd_lads_opr_hdr.idoc_timestamp,
             rcd_lads_opr_hdr.lads_date,
             rcd_lads_opr_hdr.lads_status);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

end lads_atllad28;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lads_atllad28 for lads_app.lads_atllad28;
grant execute on lads_atllad28 to lics_app;
