DROP PACKAGE CR_APP.CARE_SALCAR01;

CREATE OR REPLACE PACKAGE CR_APP.care_salcar01 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CARE
 Package : care_salcar01
 Owner   : CR_APP
 Author  : Ann-Marie Ingeme

 Description
 -----------
 Periodic Sales Data to CARE - Inbound Sales Interface

 YYYY/MM   Author              Description
 -------   ------              -----------
 2005/12   Ann-Marie Ingeme    Created
 2006/08   Linden Glen         ADD: MATL_CODE_TYPE processings
 2007/03   Steve Gregan        ADD: SOURCE_TYPE and SALES_TAR processing

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end care_salcar01;
/


DROP PACKAGE BODY CR_APP.CARE_SALCAR01;

CREATE OR REPLACE PACKAGE BODY CR_APP.care_salcar01 as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure complete_transaction;
   procedure process_record_hdr(par_record in varchar2);
   procedure process_record_det(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start  boolean;
   var_trn_ignore boolean;
   rcd_sales_data_hdr sales_data_hdr%rowtype;
   rcd_sales_data_det sales_data_det%rowtype;


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

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      sil_inbound_utility.clear_definition;
      /*-*/
      sil_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      sil_inbound_utility.set_definition('HDR','XTRCT_TIMESTAMP',14);
      sil_inbound_utility.set_definition('HDR','SALES_SRC',20);
      sil_inbound_utility.set_definition('HDR','SALES_PERIOD',6);
      sil_inbound_utility.set_definition('HDR','SALES_DET_CNT',10);
      sil_inbound_utility.set_definition('HDR','MATL_CODE_TYPE',3);
      sil_inbound_utility.set_definition('HDR','SOURCE_TYPE',3);
      /*-*/
      sil_inbound_utility.set_definition('DET','IDOC_DET',3);
      sil_inbound_utility.set_definition('DET','MATL_CODE',18);
      sil_inbound_utility.set_definition('DET','CASE_QTY',20);
      sil_inbound_utility.set_definition('DET','PCS_PER_CASE',4);
      sil_inbound_utility.set_definition('DET','OUTERS_PER_CASE',4);
      sil_inbound_utility.set_definition('DET','SALES_TAR',20);


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
         when 'HDR' then process_record_hdr(par_record);
         when 'DET' then process_record_det(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
      end case;

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
      /* Complete the Transaction
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
      /* Execute the data load when required
      /*-*/
      if var_trn_ignore = true then
         rollback;
      else
         commit;
         begin
            care_sales_load.execute(rcd_sales_data_hdr.source_type, rcd_sales_data_hdr.sales_src, rcd_sales_data_hdr.sales_period);
         exception
            when others then
               null;
         end;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end complete_transaction;


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
      cursor csr_sales_data_hdr_01 is
         select
            t01.sales_src,
            t01.sales_period,
            t01.xtrct_timestamp
         from sales_data_hdr t01
         where t01.sales_src = rcd_sales_data_hdr.sales_src
           and t01.sales_period = rcd_sales_data_hdr.sales_period;
      rcd_sales_data_hdr_01 csr_sales_data_hdr_01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Complete the previous transactions
      /*-*/
      complete_transaction;


      /*-*/
      /* Reset transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      sil_inbound_utility.parse_record('HDR', par_record);


      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sales_data_hdr.xtrct_timestamp := sil_inbound_utility.get_variable('XTRCT_TIMESTAMP');
      rcd_sales_data_hdr.SALES_SRC := sil_inbound_utility.get_variable('SALES_SRC');
      rcd_sales_data_hdr.SALES_PERIOD := sil_inbound_utility.get_variable('SALES_PERIOD');
      rcd_sales_data_hdr.SALES_DET_CNT := sil_inbound_utility.get_variable('SALES_DET_CNT');
      rcd_sales_data_hdr.sil_date := sysdate;
      rcd_sales_data_hdr.MATL_CODE_TYPE := sil_inbound_utility.get_variable('MATL_CODE_TYPE');
      rcd_sales_data_hdr.SOURCE_TYPE := sil_inbound_utility.get_variable('SOURCE_TYPE');

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_sales_data_hdr.sales_src is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_HDR - SALES_SRC');
         var_trn_ignore := true;
      end if;
      /*-*/
      if rcd_sales_data_hdr.sales_period is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_HDR - SALES_PERIOD');
         var_trn_ignore := true;
      end if;
      /*-*/
      if rcd_sales_data_hdr.sales_det_cnt is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_HDR - SALES_DET_CNT');
         var_trn_ignore := true;
      end if;
      /*-*/
      if rcd_sales_data_hdr.xtrct_timestamp is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_HDR - XTRCT_TIMESTAMP');
         var_trn_ignore := true;
      end if;


      /*-*/
      /* Validate the IDOC sequence when primary key supplied
      /*-*/
      var_exists := true;
      open csr_sales_data_hdr_01;
      fetch csr_sales_data_hdr_01 into rcd_sales_data_hdr_01;
      if csr_sales_data_hdr_01%notfound then
         var_exists := false;
      end if;
      close csr_sales_data_hdr_01;

      if var_exists = true then
         if rcd_sales_data_hdr.xtrct_timestamp > rcd_sales_data_hdr_01.xtrct_timestamp then
            delete from sales_data_det
               where sales_src = rcd_sales_data_hdr.sales_src
               and sales_period = rcd_sales_data_hdr.sales_period;
         else
            var_trn_ignore := true;
         end if;
      end if;

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      update sales_data_hdr set
         xtrct_timestamp = rcd_sales_data_hdr_01.xtrct_timestamp,
         sales_det_cnt = rcd_sales_data_hdr.sales_det_cnt,
         sil_date = rcd_sales_data_hdr.sil_date,
         matl_code_type = rcd_sales_data_hdr.matl_code_type,
         source_type = rcd_sales_data_hdr.source_type
      where sales_src = rcd_sales_data_hdr.sales_src
        and sales_period = rcd_sales_data_hdr.sales_period;
      if sql%notfound then
         insert into sales_data_hdr
            (sales_src,
             sales_period,
             sales_det_cnt,
             xtrct_timestamp,
             sil_date,
             matl_code_type,
             source_type)
         values
            (rcd_sales_data_hdr.sales_src,
             rcd_sales_data_hdr.sales_period,
             rcd_sales_data_hdr.sales_det_cnt,
             rcd_sales_data_hdr.xtrct_timestamp,
             rcd_sales_data_hdr.sil_date,
             rcd_sales_data_hdr.matl_code_type,
             rcd_sales_data_hdr.source_type);
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record PCH routine */
   /**************************************************/
   procedure process_record_det(par_record in varchar2) is

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
      sil_inbound_utility.parse_record('DET', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/
      rcd_sales_data_det.SALES_SRC := rcd_sales_data_hdr.sales_src;
      rcd_sales_data_det.SALES_PERIOD := rcd_sales_data_hdr.sales_period;
      rcd_sales_data_det.MATL_CODE := sil_inbound_utility.get_variable('MATL_CODE');
      rcd_sales_data_det.CASE_QTY := sil_inbound_utility.get_variable('CASE_QTY');
      rcd_sales_data_det.PCS_PER_CASE := sil_inbound_utility.get_variable('PCS_PER_CASE');
      rcd_sales_data_det.OUTERS_PER_CASE := sil_inbound_utility.get_variable('OUTERS_PER_CASE');
      rcd_sales_data_det.SALES_TAR := sil_inbound_utility.get_variable('SALES_TAR');
      if rcd_sales_data_det.SALES_TAR is null then
         rcd_sales_data_det.SALES_TAR := '*NONE';
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/
      if rcd_sales_data_det.sales_src is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_DET - SALES_SRC');
         var_trn_ignore := true;
      end if;
      /*-*/
      if rcd_sales_data_det.sales_period is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_DET - SALES_PERIOD');
         var_trn_ignore := true;
      end if;
      /*-*/
      if rcd_sales_data_det.matl_code is null then
         raise_application_error(-20000, 'Missing Primary Key - SALES_DATA_DET - MATL_CODE');
         var_trn_ignore := true;
      end if;
      /*-*/

      /*--------------------------------------------*/
      /* IGNORE - Ignore the data row when required */
      /*--------------------------------------------*/
      if var_trn_ignore = true then
         return;
      end if;

      /*------------------------------*/
      /* UPDATE - Update the database */
      /*------------------------------*/
      insert into sales_data_det
         (sales_src,
          sales_period,
          matl_code,
          sales_tar,
          case_qty,
          pcs_per_case,
          outers_per_case)
      values
         (rcd_sales_data_det.sales_src,
          rcd_sales_data_det.sales_period,
          rcd_sales_data_det.matl_code,
          rcd_sales_data_det.sales_tar,
          rcd_sales_data_det.case_qty,
          rcd_sales_data_det.pcs_per_case,
          rcd_sales_data_det.outers_per_case);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_det;

end care_salcar01;
/


DROP PUBLIC SYNONYM CARE_SALCAR01;

CREATE PUBLIC SYNONYM CARE_SALCAR01 FOR CR_APP.CARE_SALCAR01;


GRANT EXECUTE ON CR_APP.CARE_SALCAR01 TO PUBLIC;

