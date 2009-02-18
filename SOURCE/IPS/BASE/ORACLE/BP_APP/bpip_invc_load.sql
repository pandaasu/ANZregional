/******************/
/* Package Header */
/******************/
create or replace package bp_app.bpip_invc_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : bpip_invc_load
    Owner   : bp_app

    Description
    -----------
    Integrated Planning Demand Financials - Invoices Load 

    YYYY/MM   Author             Description
    -------   ------             -----------
    2008/11   David Zhang        Created
    2009/02   Steve Gregan       Modified for all business segments

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end bpip_invc_load;
/

/******************/
/* Package Header */
/******************/
create or replace package body bp_app.bpip_invc_load as

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
   con_heading_count constant number := 1;

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
      lics_inbound_utility.set_csv_definition('PROFIT_CENTER',4);
      lics_inbound_utility.set_csv_definition('COST_CENTER',5);
      lics_inbound_utility.set_csv_definition('INTERNAL_ORDER',6);
      lics_inbound_utility.set_csv_definition('ACCOUNT',7);
      lics_inbound_utility.set_csv_definition('POSTING_DATE',8);
      lics_inbound_utility.set_csv_definition('PO_TYPE',9);
      lics_inbound_utility.set_csv_definition('DOCUMENT_TYPE',10);
      lics_inbound_utility.set_csv_definition('ITEM_GL_TYPE',11);
      lics_inbound_utility.set_csv_definition('ITEM_STATUS',12);
      lics_inbound_utility.set_csv_definition('PURCHASING_GROUP',13);
      lics_inbound_utility.set_csv_definition('VENDOR',14);
      lics_inbound_utility.set_csv_definition('MATERIAL_GROUP',15);
      lics_inbound_utility.set_csv_definition('MATERIAL',16);
      lics_inbound_utility.set_csv_definition('DOCUMENT_CURRENCY',17);
      lics_inbound_utility.set_csv_definition('AMOUNT_DC',18);
      lics_inbound_utility.set_csv_definition('AMOUNT_LC',19);
      lics_inbound_utility.set_csv_definition('INVOICE_QTY',20);
      lics_inbound_utility.set_csv_definition('LOCAL_CURRENCY',21);
     
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

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_mars_date csr_mars_date%rowtype;

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
         /* Retrieve the mars period based on SYSDATE
         /*-*/
         open csr_mars_date;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%notfound then
            raise_application_error(-20000, 'Date ' || to_char(sysdate,'yyyy/mm/dd') || ' not found in MARS_DATE');
         end if;
         close csr_mars_date;

         /*-*/
         /* Set the batch header values
         /*-*/
         rcd_load_bpip_batch.batch_id := null;
         rcd_load_bpip_batch.batch_type_code := 'INVOICES';
         rcd_load_bpip_batch.company := lics_inbound_utility.get_variable('COMPANY');
         rcd_load_bpip_batch.period := to_char(rcd_mars_date.mars_period,'fm000000');
         rcd_load_bpip_batch.dataentity := 'ACTUALS';
         rcd_load_bpip_batch.status := 'LOADED';
         rcd_load_bpip_batch.loaded_by := 370;
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
      rcd_load_invc_data.company := lics_inbound_utility.get_variable('COMPANY');
      rcd_load_invc_data.period := lics_inbound_utility.get_variable('PERIOD');
      rcd_load_invc_data.plant := lics_inbound_utility.get_variable('PLANT');
      rcd_load_invc_data.profit_center := lics_inbound_utility.get_variable('PROFIT_CENTER');
      rcd_load_invc_data.cost_center := lics_inbound_utility.get_variable('COST_CENTER');
      rcd_load_invc_data.internal_order := lics_inbound_utility.get_variable('INTERNAL_ORDER');
      rcd_load_invc_data.account := lics_inbound_utility.get_variable('ACCOUNT');
      rcd_load_invc_data.posting_date := lics_inbound_utility.get_variable('POSTING_DATE');
      rcd_load_invc_data.po_type := lics_inbound_utility.get_variable('PO_TYPE');
      rcd_load_invc_data.document_type := lics_inbound_utility.get_variable('DOCUMENT_TYPE');
      rcd_load_invc_data.item_gl_type := lics_inbound_utility.get_variable('ITEM_GL_TYPE');
      rcd_load_invc_data.item_status := lics_inbound_utility.get_variable('ITEM_STATUS');
      rcd_load_invc_data.purchasing_group := lics_inbound_utility.get_variable('PURCHASING_GROUP');
      rcd_load_invc_data.vendor := lics_inbound_utility.get_variable('VENDOR');
      rcd_load_invc_data.material_group := lics_inbound_utility.get_variable('MATERIAL_GROUP');
      rcd_load_invc_data.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_load_invc_data.document_currency := lics_inbound_utility.get_variable('DOCUMENT_CURRENCY');
      rcd_load_invc_data.amount_dc := to_number(translate(upper(lics_inbound_utility.get_variable('AMOUNT_DC')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.99');
      rcd_load_invc_data.amount_lc := to_number(translate(upper(lics_inbound_utility.get_variable('AMOUNT_LC')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.99');
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
    
end bpip_invc_load;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bpip_invc_load for bp_app.bpip_invc_load;
grant execute on bp_app.bpip_invc_load to lics_app;