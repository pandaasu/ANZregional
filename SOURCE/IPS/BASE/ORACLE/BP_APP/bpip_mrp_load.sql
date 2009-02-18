/******************/
/* Package Header */
/******************/
create or replace package bp_app.bpip_mrp_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : bpip_mrp_load
    Owner   : bp_app

    Description
    -----------
    Integrated Planning Demand Financials - MRP Load 

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

end bpip_mrp_load;
/

/****************/
/* Package Body */
/****************/
create or replace package body bp_app.bpip_mrp_load as

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
   con_heading_count constant number := 2;

   /*-*/
   /* Private definitions 
   /*-*/
   var_trn_start boolean;
   var_trn_error boolean;
   var_trn_count number;
   rcd_load_bpip_batch load_bpip_batch%rowtype;
   rcd_load_mrp_data load_mrp_data%rowtype;
   var_batch_id_01 number;
   var_batch_id_02 number;
   var_batch_id_05 number;
   var_line_count number;
   type typ_period is table of varchar2(20) index by binary_integer;
   tbl_period typ_period;
   type typ_reqqty is table of number index by binary_integer;
   tbl_reqqty typ_reqqty;
   type typ_rctqty is table of number index by binary_integer;
   tbl_rctqty typ_rctqty;

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
      tbl_period.delete;
      tbl_reqqty.delete;
      tbl_rctqty.delete;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('COMPANY',1);
      lics_inbound_utility.set_csv_definition('CASTING_PERIOD',2);
      lics_inbound_utility.set_csv_definition('PLANT',3);
      lics_inbound_utility.set_csv_definition('MATERIAL',4);
      lics_inbound_utility.set_csv_definition('PERIOD',5);
      lics_inbound_utility.set_csv_definition('REQ_QTY_01',6);
      lics_inbound_utility.set_csv_definition('RCT_QTY_01',7);
      lics_inbound_utility.set_csv_definition('REQ_QTY_02',8);
      lics_inbound_utility.set_csv_definition('RCT_QTY_02',9);
      lics_inbound_utility.set_csv_definition('REQ_QTY_03',10);
      lics_inbound_utility.set_csv_definition('RCT_QTY_03',11);
      lics_inbound_utility.set_csv_definition('REQ_QTY_04',12);
      lics_inbound_utility.set_csv_definition('RCT_QTY_04',13);
      lics_inbound_utility.set_csv_definition('REQ_QTY_05',14);
      lics_inbound_utility.set_csv_definition('RCT_QTY_05',15);
      lics_inbound_utility.set_csv_definition('REQ_QTY_06',16);
      lics_inbound_utility.set_csv_definition('RCT_QTY_06',17);
      lics_inbound_utility.set_csv_definition('REQ_QTY_07',18);
      lics_inbound_utility.set_csv_definition('RCT_QTY_07',19);
      lics_inbound_utility.set_csv_definition('REQ_QTY_08',20);
      lics_inbound_utility.set_csv_definition('RCT_QTY_08',21);
      lics_inbound_utility.set_csv_definition('REQ_QTY_09',22);
      lics_inbound_utility.set_csv_definition('RCT_QTY_09',23);
      lics_inbound_utility.set_csv_definition('REQ_QTY_10',24);
      lics_inbound_utility.set_csv_definition('RCT_QTY_10',25);
      lics_inbound_utility.set_csv_definition('REQ_QTY_11',26);
      lics_inbound_utility.set_csv_definition('RCT_QTY_11',27);
      lics_inbound_utility.set_csv_definition('REQ_QTY_12',28);
      lics_inbound_utility.set_csv_definition('RCT_QTY_12',29);
      lics_inbound_utility.set_csv_definition('REQ_QTY_13',30);
      lics_inbound_utility.set_csv_definition('RCT_QTY_13',31);

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

         /*-*/
         /* Set the batch header values
         /*-*/
         rcd_load_bpip_batch.batch_id := null;
         rcd_load_bpip_batch.batch_type_code := 'MRP';
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

         /*-*/
         /* Populate the period array
         /*-*/
         var_period := to_number(substr(lics_inbound_utility.get_variable('CASTING_PERIOD'),1,3));
         var_year := to_number(substr(lics_inbound_utility.get_variable('CASTING_PERIOD'),5,4));
         for idx in 1..13 loop
            tbl_period(tbl_period.count+1) := '13/'||to_char(var_period,'fm000')||'.'||to_char(var_year,'fm0000');
            var_period := var_period + 1;
            if var_period > 13 then
               var_year := var_year + 1;
               var_period := 1;
            end if;
         end loop;


      end if;
     
      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_load_mrp_data.batch_id := null;
      rcd_load_mrp_data.company := lics_inbound_utility.get_variable('COMPANY');
      rcd_load_mrp_data.casting_period := lics_inbound_utility.get_variable('CASTING_PERIOD');
      rcd_load_mrp_data.plant := lics_inbound_utility.get_variable('PLANT');
      rcd_load_mrp_data.material := lics_inbound_utility.get_variable('MATERIAL');
      rcd_load_mrp_data.status := 'LOADED';
      rcd_load_mrp_data.error_msg := null;
      rcd_load_mrp_data.bus_sgmnt := null;
      tbl_reqqty(1) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_01'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(2) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_02'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(3) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_03'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(4) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_04'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(5) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_05'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(6) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_06'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(7) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_07'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(8) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_08'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(9) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_09'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(10) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_10'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(11) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_11'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(12) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_12'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_reqqty(13) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('REQ_QTY_13'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(1) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_01'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(2) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_02'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(3) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_03'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(4) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_04'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(5) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_05'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(6) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_06'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(7) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_07'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(8) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_08'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(9) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_09'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(10) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_10'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(11) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_11'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(12) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_12'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');
      tbl_rctqty(13) := to_number(translate(upper(nvl(lics_inbound_utility.get_variable('RCT_QTY_13'),'0')),'# ABCDEFGHIJKLMNOPQRSTUVWXYZ','#'),'999,999,999,990.999');

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
      /* Create the period data
      /*-*
      for idx in 1..13 loop

         /*-*/
         /* Set the variables
         /*-*/
         var_line_count := var_line_count + 1;
         rcd_load_mrp_data.line_no := var_line_count;
         rcd_load_mrp_data.period := tbl_period(idx);
         rcd_load_mrp_data.requirements_qty := tbl_reqqty(idx);
         rcd_load_mrp_data.receipt_qty := tbl_rctqty(idx);

         /*-*/
         /* Business segment 01
         /*-*/
         rcd_load_mrp_data.batch_id := var_batch_id_01;
         insert into load_mrp_data values rcd_load_mrp_data;

         /*-*/
         /* Business segment 02
         /*-*/
         rcd_load_mrp_data.batch_id := var_batch_id_02;
         insert into load_mrp_data values rcd_load_mrp_data;

         /*-*/
         /* Business segment 05
         /*-*/
         rcd_load_mrp_data.batch_id := var_batch_id_05;
         insert into load_mrp_data values rcd_load_mrp_data;

      end loop;
      
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
         bp.schema_management.analyze_table('LOAD_MRP_DATA');
         bp.schema_management.analyze_index('LOAD_MRP_DATA_PK01');

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;
    
end bpip_mrp_load;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym bpip_mrp_load for bp_app.bpip_mrp_load;
grant execute on bp_app.bpip_mrp_load to lics_app;