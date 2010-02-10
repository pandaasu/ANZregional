/******************/
/* Package Header */
/******************/
CREATE OR REPLACE package BP_APP.bpip_invoice_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : bpip_invoice_load
    Owner   : bp_app

    Description
    -----------
    Integrated Planning Demand Financials - Invoice Load

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/02   Steve Gregan       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end bpip_invoice_load;
/

/******************/
/* Package Body   */
/******************/
CREATE OR REPLACE package body BP_APP.bpip_invoice_load as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_delimiter constant varchar2(32)  := ';';
   con_qualifier constant varchar2(10) := '"';
   con_heading_count constant number := 5;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_error boolean;
   var_trn_count number;
   rcd_load_bpip_batch load_bpip_batch%rowtype;
   rcd_load_invc_data load_invc_data%rowtype;
   var_batch_id_01 number;
   var_batch_id_02 number;
   var_batch_id_05 number;
   var_line_count number;

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
      var_trn_error := false;
      var_trn_count := 0;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('PERIOD',1);
      lics_inbound_utility.set_csv_definition('COMPANY',2);      
      lics_inbound_utility.set_csv_definition('PLANT',3);
      lics_inbound_utility.set_csv_definition('PROFIT_CTR',4);
      lics_inbound_utility.set_csv_definition('COST_CTR',5);
      lics_inbound_utility.set_csv_definition('INT_ORD',6);
      lics_inbound_utility.set_csv_definition('ACCT',7);
      lics_inbound_utility.set_csv_definition('POST_DATE',8);
      lics_inbound_utility.set_csv_definition('PO_TYPE',9);
      lics_inbound_utility.set_csv_definition('DOC_TYPE',10);
      lics_inbound_utility.set_csv_definition('ITEM_GL_TYPE',11);
      lics_inbound_utility.set_csv_definition('ITEM_STAT',12);
      lics_inbound_utility.set_csv_definition('PURCHASE_GRP',13);
      lics_inbound_utility.set_csv_definition('VENDOR',14);
      lics_inbound_utility.set_csv_definition('MATL_GRP',15);
      lics_inbound_utility.set_csv_definition('MATL',16);
      lics_inbound_utility.set_csv_definition('DOC_CURR',17);
      lics_inbound_utility.set_csv_definition('AMNT_DC',18);
      lics_inbound_utility.set_csv_definition('AMNT_LC',19);
      lics_inbound_utility.set_csv_definition('INV_QTY',20);

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
   end on_start;

   /***********************************************/
   /* This procedure performs the on data routine */
   /***********************************************/
   procedure on_data(par_record in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/

      var_trn_count := var_trn_count + 1;
      if var_trn_count <= con_heading_count then
         return;
      end if;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_qualifier);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Create the batch headers when required
      /* **notes** 1. Assumes only one company per interface file
      /*-*/
      if var_trn_start = false then

         /*-*/
         /* Set the start indicator
         /*-*/
         var_trn_start := true;

         /*-*/
         /* Set the batch header values
         /*-*/
         rcd_load_bpip_batch.batch_id := null;
         rcd_load_bpip_batch.batch_type_code := 'INVOICES';
         rcd_load_bpip_batch.company := lics_inbound_utility.get_variable('COMPANY');
         rcd_load_bpip_batch.period := substr(lics_inbound_utility.get_variable('PERIOD'),8,4)||substr(lics_inbound_utility.get_variable('PERIOD'),4,2);
         rcd_load_bpip_batch.dataentity := 'ACTUALS';
         rcd_load_bpip_batch.status := 'LOADED';
         rcd_load_bpip_batch.loaded_by := 259; /* For ID in testing */
         rcd_load_bpip_batch.load_start_time := sysdate;
         rcd_load_bpip_batch.load_end_time := null;
         rcd_load_bpip_batch.validate_start_time := null;
         rcd_load_bpip_batch.validate_end_time := null;
         rcd_load_bpip_batch.process_start_time := null;
         rcd_load_bpip_batch.process_end_time := null;
         rcd_load_bpip_batch.bus_sgmnt := null;

         /*-*/
         /* Replace any batch headers with the same key values
         /*-*/

         update load_bpip_batch
            set status = 'REPLACED'
          where batch_type_code = rcd_load_bpip_batch.batch_type_code
            and company = rcd_load_bpip_batch.company
            and period = rcd_load_bpip_batch.period
            and dataentity = rcd_load_bpip_batch.dataentity;

         /*-*/
         /* Insert the batch headers
         /* **notes** 1. All business segments are loaded because this is determined
         /*              by BPIP processing based on the interface type
         /*-*/
         select bpip_id_seq.nextval into var_batch_id_01 from dual;
         rcd_load_bpip_batch.batch_id := var_batch_id_01;
         rcd_load_bpip_batch.bus_sgmnt := '01';
         insert into load_bpip_batch values rcd_load_bpip_batch;
         select bpip_id_seq.nextval into var_batch_id_02 from dual;
         rcd_load_bpip_batch.batch_id := var_batch_id_02;
         rcd_load_bpip_batch.bus_sgmnt := '02';
         insert into load_bpip_batch values rcd_load_bpip_batch;
         select bpip_id_seq.nextval into var_batch_id_05 from dual;
         rcd_load_bpip_batch.batch_id := var_batch_id_05;
         rcd_load_bpip_batch.bus_sgmnt := '05';
         insert into load_bpip_batch values rcd_load_bpip_batch;
         var_line_count := 0;


      end if;

      /*-*/
      /* Retrieve field values
      /*-*/
      var_line_count := var_line_count + 1;
      rcd_load_invc_data.batch_id := null;
      rcd_load_invc_data.line_no := var_line_count;
      rcd_load_invc_data.period             := lics_inbound_utility.get_variable('PERIOD');
      rcd_load_invc_data.company             := lics_inbound_utility.get_variable('COMPANY');
      rcd_load_invc_data.plant              := lics_inbound_utility.get_variable('PLANT');
      rcd_load_invc_data.profit_center      := lics_inbound_utility.get_variable('PROFIT_CTR');
      rcd_load_invc_data.cost_center        := lics_inbound_utility.get_variable('COST_CTR');
      rcd_load_invc_data.internal_order     := lics_inbound_utility.get_variable('INT_ORD');
      rcd_load_invc_data.account            := lics_inbound_utility.get_variable('ACCT');
      rcd_load_invc_data.posting_date       := lics_inbound_utility.get_variable('POST_DATE');
      rcd_load_invc_data.po_type            := lics_inbound_utility.get_variable('PO_TYPE');
      rcd_load_invc_data.document_type      := lics_inbound_utility.get_variable('DOC_TYPE');
      rcd_load_invc_data.item_gl_type       := lics_inbound_utility.get_variable('ITEM_GL_TYPE');
      rcd_load_invc_data.item_status        := lics_inbound_utility.get_variable('ITEM_STAT');
      rcd_load_invc_data.purchasing_group   := lics_inbound_utility.get_variable('PURCHASE_GRP');
      rcd_load_invc_data.vendor             := lics_inbound_utility.get_variable('VENDOR');
      rcd_load_invc_data.material_group     := lics_inbound_utility.get_variable('MATL_GRP');
      rcd_load_invc_data.material           := lics_inbound_utility.get_variable('MATL');
      rcd_load_invc_data.document_currency  := lics_inbound_utility.get_variable('DOC_CURR');
      rcd_load_invc_data.amount_dc := to_number(translate(upper(lics_inbound_utility.get_variable('AMNT_DC')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      rcd_load_invc_data.amount_lc := to_number(translate(upper(lics_inbound_utility.get_variable('AMNT_LC')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      rcd_load_invc_data.invoice_qty := to_number(translate(upper(lics_inbound_utility.get_variable('INVOICE_QTY')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');            
      rcd_load_invc_data.status := 'LOADED';
      rcd_load_invc_data.error_msg := null;
      rcd_load_invc_data.bus_sgmnt := null;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
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
      /* Business segment 01
      /*-*/
      rcd_load_invc_data.batch_id := var_batch_id_01;
      insert into load_invc_data values rcd_load_invc_data;

      /*-*/
      /* Business segment 02
      /*-*/
      rcd_load_invc_data.batch_id := var_batch_id_02;
      insert into load_invc_data values rcd_load_invc_data;

      /*-*/
      /* Business segment 05
      /*-*/
      rcd_load_invc_data.batch_id := var_batch_id_05;
      insert into load_invc_data values rcd_load_invc_data;

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
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the transaction as required
      /*-*/
      if var_trn_error = true then

         /*-*/
         /* Rollback the transaction
         /*-*/
         rollback;

      else

         /*-*/
         /* Log finish time in batch header table
         /*-*/
         update load_bpip_batch
            set load_end_time = sysdate
          where batch_id in (var_batch_id_01, var_batch_id_02, var_batch_id_05);

         /*-*/
         /* Commit the transaction
         /*-*/
         commit;

         /*-*/
         /* Analyse the table and related indexes
         /*-*/
         bp.schema_management.analyze_table('LOAD_INVC_DATA');
         bp.schema_management.analyze_index('LOAD_INVC_DATA_PK01');

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end bpip_invoice_load;
/



/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bpip_invoice_load for bp_app.bpip_invoice_load;
grant execute on bp_app.bpip_invoice_load to lics_app;