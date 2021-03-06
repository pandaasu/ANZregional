/******************/
/* Package Header */
/******************/
create or replace package bp_app.bpip_cntct_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : bpip_cntct_load
    Owner   : bp_app

    Description
    -----------
    Integrated Planning Demand Financials - Contracts Load 

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

end bpip_cntct_load;
/

/****************/
/* Package Body */
/****************/
CREATE OR REPLACE package body BP_APP.bpip_cntct_load as

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
   con_heading_count constant number := 4;

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_error boolean;
   var_trn_count number;
   rcd_load_bpip_batch load_bpip_batch%rowtype;
   rcd_load_cntct_data load_cntct_data%rowtype;
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
      lics_inbound_utility.set_csv_definition('COMPANY',1);
      lics_inbound_utility.set_csv_definition('VENDOR',2);
      lics_inbound_utility.set_csv_definition('CONTRACT',3);
      lics_inbound_utility.set_csv_definition('CONTRACT_ITEM',4);
      lics_inbound_utility.set_csv_definition('PLANT',5);
      lics_inbound_utility.set_csv_definition('PURCHASING_GROUP',6);
      lics_inbound_utility.set_csv_definition('PURCHASE_ORDER',7);
      lics_inbound_utility.set_csv_definition('PURCHASE_ORDER_ITEM',8);
      lics_inbound_utility.set_csv_definition('PURCHASE_DOC_TYPE',9);
      lics_inbound_utility.set_csv_definition('PURCHASE_DOC_CATEGORY',10);
      lics_inbound_utility.set_csv_definition('MATERIAL',11);
      lics_inbound_utility.set_csv_definition('MATERIAL_GROUP',12);
      lics_inbound_utility.set_csv_definition('VALID_FROM_DATE',13);
      lics_inbound_utility.set_csv_definition('VALID_TO_DATE',14);
      lics_inbound_utility.set_csv_definition('OPEN_QUANTITY',15);

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
      /* Local definitions
      /*-*/
      var_year number;
      var_period number;

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
         var_year := to_number(substr(to_char(rcd_mars_date.mars_period,'fm000000'),1,4));
         var_period := to_number(substr(to_char(rcd_mars_date.mars_period,'fm000000'),5,2));
         var_period := var_period - 1;
         if var_period < 1 then
            var_year := var_year - 1;
            var_period := 13;
         end if;

         /*-*/
         /* Set the batch header values
         /*-*/
         rcd_load_bpip_batch.batch_id := null;
         rcd_load_bpip_batch.batch_type_code := 'CONTRACTS';
         rcd_load_bpip_batch.company := lics_inbound_utility.get_variable('COMPANY');
         rcd_load_bpip_batch.period := null;
         rcd_load_bpip_batch.dataentity := to_char(var_year,'fm0000')||' BR'||to_char(var_period,'fm00');
         rcd_load_bpip_batch.status := 'LOADED';
         rcd_load_bpip_batch.loaded_by := 259;
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
      rcd_load_cntct_data.batch_id := null;
      rcd_load_cntct_data.line_no := var_line_count;
      rcd_load_cntct_data.company := lics_inbound_utility.get_variable('COMPANY');
      rcd_load_cntct_data.vendor := lics_inbound_utility.get_variable('VENDOR');
      rcd_load_cntct_data.contract := lics_inbound_utility.get_variable('CONTRACT');
      rcd_load_cntct_data.contract_item := lics_inbound_utility.get_variable('CONTRACT_ITEM');
      rcd_load_cntct_data.plant := lics_inbound_utility.get_variable('PLANT');
      rcd_load_cntct_data.purchasing_group := lics_inbound_utility.get_variable('PURCHASING_GROUP');
      rcd_load_cntct_data.purchase_order := lics_inbound_utility.get_variable('PURCHASE_ORDER');
      rcd_load_cntct_data.purchase_order_item := lics_inbound_utility.get_variable('PURCHASE_ORDER_ITEM');
      rcd_load_cntct_data.purchase_doc_type := lics_inbound_utility.get_variable('PURCHASE_DOC_TYPE');
      rcd_load_cntct_data.purchase_doc_category := lics_inbound_utility.get_variable('PURCHASE_DOC_CATEGORY');
      rcd_load_cntct_data.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_load_cntct_data.valid_from_date := lics_inbound_utility.get_variable('VALID_FROM_DATE');
      rcd_load_cntct_data.valid_to_date := lics_inbound_utility.get_variable('VALID_TO_DATE');
      rcd_load_cntct_data.open_quantity := to_number(translate(upper(lics_inbound_utility.get_variable('OPEN_QUANTITY')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      rcd_load_cntct_data.status := 'LOADED';
      rcd_load_cntct_data.error_msg := null;
      rcd_load_cntct_data.bus_sgmnt := null;

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
      rcd_load_cntct_data.batch_id := var_batch_id_01;
      insert into load_cntct_data values rcd_load_cntct_data;

      /*-*/
      /* Business segment 02
      /*-*/
      rcd_load_cntct_data.batch_id := var_batch_id_02;
      insert into load_cntct_data values rcd_load_cntct_data;

      /*-*/
      /* Business segment 05
      /*-*/
      rcd_load_cntct_data.batch_id := var_batch_id_05;
      insert into load_cntct_data values rcd_load_cntct_data;

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
         bp.schema_management.analyze_table('LOAD_CNTCT_DATA');
         bp.schema_management.analyze_index('LOAD_CNTCT_DATA_PK01');

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

end bpip_cntct_load;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bpip_cntct_load for bp_app.bpip_cntct_load;
grant execute on bp_app.bpip_cntct_load to lics_app;