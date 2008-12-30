CREATE OR REPLACE package BP_APP.bpip_invc_load as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : bpip_invc_load
    Owner   : bp_app
    Author  : David Zhang

    Description
    -----------
    Integrated Planning Demand Financials - Pet and Food Invoices Load 

    YYYY/MM   Author             Description
    -------   ------             -----------
    2008/11   David Zhang        Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end bpip_invc_load;


CREATE OR REPLACE package body BP_APP.bpip_invc_load as

   /*-*/
   /* Private exceptions 
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants 
   /*-*/
   con_invcld_alt_group constant varchar2(32) := 'INVCLOAD_ALERT';
   con_invcld_alt_code constant varchar2(32) := 'INVCLOAD_PROCESSING';
   con_invcld_ema_group constant varchar2(32) := 'INVCLOAD_EMAIL_GROUP';
   con_invcld_ema_code constant varchar2(32) := 'INVCLOAD_PROCESSING';
   con_invcld_tri_group constant varchar2(32) := 'INVCLOAD_JOB_GROUP';
   con_invcld_tri_code constant varchar2(32) := 'INVCLOAD_PROCESSING';

   con_delimiter constant varchar2(32)  := ';';
   con_qualifier constant varchar2(10) := '"';

   /*-*/
   /* Private definitions 
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   
   function isnumber(in_var in varchar2) return NUMBER;
 
   /* Variables used for table load_bpip_batch */  
   var_pet_batch_id  NUMBER;
   var_food_batch_id NUMBER;
   

   /* Variables used for table load_invc_batch */
   var_count number;
   var_amount_dc_str VARCHAR2(40);
   var_amount_lc_str VARCHAR2(40);
   var_invoice_qty   VARCHAR2(40);
   
   /* casting period */
   var_mars_prd             mars_date.mars_yyyyppdd%TYPE; 
   var_casting_prd          load_bpip_batch.period%TYPE;
   var_date_msg             common.st_message_string;
   

   var_result_msg varchar2(3900);
   
   rec_load_invc_data  load_invc_data%ROWTYPE;
  
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
      var_count := 0;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_csv_definition('PERIOD',1);
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
 
      /* Get batch sequence for Pet data */        
      SELECT bpip_id_seq.NEXTVAL
        INTO var_pet_batch_id
        FROM sys.dual;

      /* Get batch sequence for Food data */
      SELECT bpip_id_seq.NEXTVAL
        INTO var_food_batch_id
        FROM sys.dual;
        
      /* Get Mars Period */  
      IF mars_date_utils.lookup_mars_yyyyppdd (TRUNC(SYSDATE), var_mars_prd, var_date_msg) <> common.gc_success THEN
         raise_application_error(-20000, 'Error getting Mars period. '||var_date_msg);
      END IF;
      
      -- var_mars_prd is presented in YYYYPPDD. We only need YYYYPP. 
      var_casting_prd := TRUNC(var_mars_prd/100);
      
      /* Pet batch record */
      INSERT INTO LOAD_BPIP_BATCH 
             (BATCH_ID,   BATCH_TYPE_CODE,    COMPANY, 
              PERIOD,     DATAENTITY,         STATUS, 
              LOADED_BY,  LOAD_START_TIME,    BUS_SGMNT)
      VALUES (var_pet_batch_id,     'INVOICES',   '147',
              var_casting_prd,      'ACTUALS',    'LOADED',
              370,                  SYSDATE,      '05');
                
      /* Food batch record */
      INSERT INTO LOAD_BPIP_BATCH 
             (BATCH_ID,   BATCH_TYPE_CODE,    COMPANY, 
              PERIOD,     DATAENTITY,         STATUS, 
              LOADED_BY,  LOAD_START_TIME,    BUS_SGMNT)
      VALUES (var_food_batch_id,    'INVOICES',   '147',
              var_casting_prd,      'ACTUALS',    'LOADED',
              370,                  SYSDATE,      '02');
                 
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
       var_strlen NUMBER;   
       var_len   NUMBER;
     
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

      lics_inbound_utility.parse_csv_record(par_record, con_delimiter, con_qualifier);
      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/
     
      /*-*/
      /* Retrieve field values
      /*-*/
      
      var_count := var_count + 1;
      
      rec_load_invc_data.period             := lics_inbound_utility.get_variable('PERIOD');
      rec_load_invc_data.plant              := lics_inbound_utility.get_variable('PLANT');
      rec_load_invc_data.profit_center      := lics_inbound_utility.get_variable('PROFIT_CTR');
      rec_load_invc_data.cost_center        := lics_inbound_utility.get_variable('COST_CTR');
      rec_load_invc_data.internal_order     := lics_inbound_utility.get_variable('INT_ORD');
      rec_load_invc_data.account            := lics_inbound_utility.get_variable('ACCT');
      rec_load_invc_data.posting_date       := lics_inbound_utility.get_variable('POST_DATE');
      rec_load_invc_data.po_type            := lics_inbound_utility.get_variable('PO_TYPE');
      rec_load_invc_data.document_type      := lics_inbound_utility.get_variable('DOC_TYPE');
      rec_load_invc_data.item_gl_type       := lics_inbound_utility.get_variable('ITEM_GL_TYPE');
      rec_load_invc_data.item_status        := lics_inbound_utility.get_variable('ITEM_STAT');
      rec_load_invc_data.purchasing_group   := lics_inbound_utility.get_variable('PURCHASE_GRP');
      rec_load_invc_data.vendor             := lics_inbound_utility.get_variable('VENDOR');
      rec_load_invc_data.material_group     := lics_inbound_utility.get_variable('MATL_GRP');
      rec_load_invc_data.material           := lics_inbound_utility.get_variable('MATL');
      rec_load_invc_data.document_currency  := lics_inbound_utility.get_variable('DOC_CURR');
      
      var_amount_dc_str                     := lics_inbound_utility.get_variable('AMNT_DC');
      var_amount_dc_str                     := LTRIM(RTRIM( var_amount_dc_str ));
      var_strlen                            := LENGTH( var_amount_dc_str );
      var_len                               := var_strlen;
      IF isnumber( var_amount_dc_str ) = 1 THEN
        /* not a numberic value */
         FOR i IN 1..var_strlen LOOP
           IF isNumber(SUBSTR( var_amount_dc_str ,-1,1)) = 1  THEN
             -- not a number
             var_len := var_len - 1;     
             /* build a new string */
              var_amount_dc_str  := SUBSTR( var_amount_dc_str , 1, var_len);  
           ELSE
             EXIT;
           END IF;    
         END LOOP; 
         
      END IF; 
      
      rec_load_invc_data.amount_dc          := TO_NUMBER(NVL(var_amount_dc_str,'0'),'999,999,999,990.99');
      
      var_amount_lc_str                     := lics_inbound_utility.get_variable('AMNT_LC');
      var_amount_lc_str                     := LTRIM(RTRIM(var_amount_lc_str));
      var_strlen                            := LENGTH(var_amount_lc_str);
      var_len                               := var_strlen;
      IF isnumber(var_amount_lc_str) = 1 THEN
        /* not a numberic value */
         FOR i IN 1..var_strlen LOOP
           IF isNumber(SUBSTR(var_amount_lc_str,-1,1)) = 1  THEN
             -- not a number
             var_len := var_len - 1;     
             /* build a new string */
             var_amount_lc_str := SUBSTR(var_amount_lc_str, 1, var_len);  
           ELSE
             EXIT;
           END IF;    
         END LOOP; 
         
      END IF; 
      
      rec_load_invc_data.amount_lc          := TO_NUMBER(NVL(var_amount_lc_str,'0'), '999,999,999,990.99');
      
      var_invoice_qty                       := lics_inbound_utility.get_variable('INV_QTY');
      var_invoice_qty                       := LTRIM(RTRIM(var_invoice_qty));
      var_strlen                            := LENGTH(var_invoice_qty);
      var_len                               := var_strlen;
      IF isnumber(var_invoice_qty) = 1 THEN
        /* not a numberic value */
         FOR i IN 1..var_strlen LOOP
           IF isNumber(SUBSTR(var_invoice_qty,-1,1)) = 1  THEN
             -- not a number
             var_len := var_len - 1;     
             /* build a new string */
             var_invoice_qty := SUBSTR(var_invoice_qty, 1, var_len);  
           ELSE
             EXIT;
           END IF;    
         END LOOP; 
         
      END IF; 
      rec_load_invc_data.invoice_qty      := TO_NUMBER(var_invoice_qty,'999,999,999,990.999' );

      rec_load_invc_data.line_no            := var_count;
      rec_load_invc_data.company            := '147';
      rec_load_invc_data.status             := 'LOADED';
      rec_load_invc_data.error_msg          := NULL;
      rec_load_invc_data.bus_sgmnt          := NULL;

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

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/

      if var_trn_error = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/

      /* Two inserts are required concerning the same set of data for both Pet and Food with separate batch id */
      
      /* Pet data */
      INSERT INTO LOAD_INVC_DATA
        (BATCH_ID,                  LINE_NO, 
         PERIOD,                    COMPANY, 
         PLANT,                     PROFIT_CENTER, 
         COST_CENTER,               INTERNAL_ORDER, 
         ACCOUNT,                   POSTING_DATE, 
         PO_TYPE,                   DOCUMENT_TYPE, 
         ITEM_GL_TYPE,              ITEM_STATUS, 
         PURCHASING_GROUP,          VENDOR, 
         MATERIAL_GROUP,            MATERIAL, 
         DOCUMENT_CURRENCY,         AMOUNT_DC, 
         AMOUNT_LC,                 STATUS, 
         ERROR_MSG,                 BUS_SGMNT, 
         INVOICE_QTY )
      VALUES 
        (var_pet_batch_id,                      var_count,
         rec_load_invc_data.period,             rec_load_invc_data.company,
         rec_load_invc_data.plant,              rec_load_invc_data.profit_center,
         rec_load_invc_data.cost_center,        rec_load_invc_data.internal_order,
         rec_load_invc_data.account,            rec_load_invc_data.posting_date,
         rec_load_invc_data.po_type,            rec_load_invc_data.document_type,
         rec_load_invc_data.item_gl_type,       rec_load_invc_data.item_status,
         rec_load_invc_data.purchasing_group,   rec_load_invc_data.vendor,
         rec_load_invc_data.material_group,     rec_load_invc_data.material,
         rec_load_invc_data.document_currency,  rec_load_invc_data.amount_dc,
         rec_load_invc_data.amount_lc,          rec_load_invc_data.status,
         rec_load_invc_data.error_msg,          rec_load_invc_data.bus_sgmnt,
         rec_load_invc_data.invoice_qty
         );
      
       INSERT INTO LOAD_INVC_DATA
        (BATCH_ID,                  LINE_NO, 
         PERIOD,                    COMPANY, 
         PLANT,                     PROFIT_CENTER, 
         COST_CENTER,               INTERNAL_ORDER, 
         ACCOUNT,                   POSTING_DATE, 
         PO_TYPE,                   DOCUMENT_TYPE, 
         ITEM_GL_TYPE,              ITEM_STATUS, 
         PURCHASING_GROUP,          VENDOR, 
         MATERIAL_GROUP,            MATERIAL, 
         DOCUMENT_CURRENCY,         AMOUNT_DC, 
         AMOUNT_LC,                 STATUS, 
         ERROR_MSG,                 BUS_SGMNT, 
         INVOICE_QTY )
      VALUES 
        (var_food_batch_id,                     var_count,
         rec_load_invc_data.period,             rec_load_invc_data.company,
         rec_load_invc_data.plant,              rec_load_invc_data.profit_center,
         rec_load_invc_data.cost_center,        rec_load_invc_data.internal_order,
         rec_load_invc_data.account,            rec_load_invc_data.posting_date,
         rec_load_invc_data.po_type,            rec_load_invc_data.document_type,
         rec_load_invc_data.item_gl_type,       rec_load_invc_data.item_status,
         rec_load_invc_data.purchasing_group,   rec_load_invc_data.vendor,
         rec_load_invc_data.material_group,     rec_load_invc_data.material,
         rec_load_invc_data.document_currency,  rec_load_invc_data.amount_dc,
         rec_load_invc_data.amount_lc,          rec_load_invc_data.status,
         rec_load_invc_data.error_msg,          rec_load_invc_data.bus_sgmnt,
         rec_load_invc_data.invoice_qty
         );
      
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
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when commited
      /*-*/
       if ( var_trn_start = false ) then
      rollback;
      return;
    end if;

    /*-*/
    /* Commit/rollback the transaction as required 
    /*-*/
    if ( var_trn_ignore = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    elsif ( var_trn_error = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    else
      /*-*/
      /* Commit the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      /* Log finish time in batch header table */
      UPDATE load_bpip_batch
        SET load_end_time = sysdate
      WHERE batch_id in (var_pet_batch_id, var_food_batch_id);
      
      COMMIT;      
    end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end on_end;

    function isnumber(in_var in varchar2)
    return number
    is
    v_number number;
    begin

    select to_number(in_var) 
    into v_number
    from dual; 

    return 0; ---- Number...

    exception
    when others then
    return 1; --- Not a number..

    end;
    
end bpip_invc_load;

-- grants
grant execute on BP_APP.bpip_invc_load to appsupport;
grant execute on BP_APP.bpip_invc_load to lics_app;

create or replace public synonym bpip_invc_load for BP_APP.bpip_invc_load;







