CREATE OR REPLACE package         ods_validation_v2 as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ODS
 Package : ods_validation
 Owner   : ODS_APP
 Author  : ISI


 Description
 -----------
 Controls the validation of the ODS reference and transaction data validation.


 PARAMETERS
   1. PAR_ACTION [MANDATORY]
      *ALL     - Executes all validation processing for both company and non-company specific types


 NOTES
   1. This package is NOT intended to be run in parallel.
   2. Package should be executed from schedule at specific points in time (recommended is hourly).
   3. Order of validation processing is important - reference data should preceed transactions.


 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/06   Peter Smith    Created
 2007/04   Kris Lee       Added check_pmx_accruals() validate_pmx_accrual() for promotion accrual data
 2007/04   Kris Lee       Added check_promotions(), validate_promotion(), check_promotion_types for promotion data
 2007/04   Kris Lee       Added check_pmx_claims(), validate_pmx_claim(), check_pmx_claim_docs for promotion Claim data
 2007/07   Linden Glen    Updated to use LICS_LOGGING in execute and write_log()
                          Included execution of Invoice Summary for both 147 and 149 (remove need to execute twice)
                          Single execution path (*ALL), not by company code (only one process requires company code)
                          Changed to use lics_locking (ensures only one execution at a time)

                          Recommended revisions (major)
                           - remove updates of linked documents after processing of each data type (overcome deadlocks)
                           - include both UNCHECKED and INVALID in processing criteria
                           - remove two stage validation (check, lock-validate)
                           - include detailed error trapping (has 'null;' in exception handlers)
                           - single commit block in each data type (reduce risk of only half commited processing)
 2007/07   Kris Lee       MOD: validate_material() - rename reference fcst_dtl.matl_code to fcst_dtl.matl_zrep_code
                          MOD: validate_forecast() - rename reference fcst_dtl_matl_code to fcst_dtl.matl_zrep_code
                                                   - add validation on matl_tdu_code, fcst_dtl_type_code fields
 2007/07   Kris Lee       ADD: check_dcs_orders(), validate_dcs_sales_order for fundraising sales order
 2008/04   Kris Lee       ADD: validate_pmx_accruals_bulk() - speed up the validation by validate in bulk

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2);

end ods_validation_v2; 
/


CREATE OR REPLACE PACKAGE BODY         ods_validation_v2 AS

  -- Private exceptions
   application_exception exception;
   snapshot_exception exception;
   resource_busy exception;
   pragma exception_init(application_exception, -20000);
   pragma exception_init(snapshot_exception, -1555);
   pragma exception_init(resource_busy, -54);

  c_commit_count CONSTANT PLS_INTEGER := 100;

  v_inv_sum_flag BOOLEAN;

  -- Private declarations
  PROCEDURE write_log(
    i_data_type    IN ods.log.data_type%TYPE,
    i_sort_field   IN ods.log.sort_field%TYPE,
    i_log_level    IN ods.log.log_level%TYPE,
    i_log_text     IN ods.log.log_text%TYPE);

  PROCEDURE check_order_usages(
    i_log_level    IN ods.log.log_level%TYPE);         -- Order Usage

  PROCEDURE validate_order_usage(
    i_log_level        IN ods.log.log_level%TYPE,
    i_order_usage_code IN order_usage.order_usage_code%TYPE);

  PROCEDURE check_order_types(
    i_log_level    IN ods.log.log_level%TYPE);         -- Order Type

  PROCEDURE validate_order_type(
    i_log_level       IN ods.log.log_level%TYPE,
    i_order_type_code IN order_type.order_type_code%TYPE);

  PROCEDURE check_addresses(                        -- Addresses
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE check_address_types(
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_address(
    i_log_level    IN ods.log.log_level%TYPE,
    i_obj_type     IN sap_adr_hdr.obj_type%TYPE,
    i_obj_id       IN sap_adr_hdr.obj_id%TYPE,
    i_context      IN sap_adr_hdr.context%TYPE);

    /******************************************************
     * UNCOMMENT THE BELOW BLOCK IF ANY VALIDATIONS FOR   *
     * SAP_REF DATA NEEDS TO BE IMPLEMENTED BY THE SYSTEM *
     ******************************************************/

/*  PROCEDURE check_sap_refs(                                -- SAP Refernce Data
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_sap_ref(
    i_log_level    IN ods.log.log_level%TYPE,
    i_z_tabname    IN sap_ref_hdr.z_tabname%TYPE);*/

    /*******************************************************
     * UNCOMMENT THE BELOW BLOCK IF ANY VALIDATIONS FOR    *
     * CUSTOMER DATA NEEDS TO BE IMPLEMENTED BY THE SYSTEM *
     *******************************************************/
  /*PROCEDURE check_customers(                               -- Customers
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_customer(
    i_log_level    IN ods.log.log_level%TYPE,
    i_kunnr        IN sap_cus_hdr.kunnr%TYPE);*/

  PROCEDURE check_materials(
    i_log_level    IN ods.log.log_level%TYPE);             -- Materials

  PROCEDURE validate_material(
    i_log_level    IN ods.log.log_level%TYPE,
    i_material_nbr IN VARCHAR2);

  PROCEDURE check_exchange_rate_details(
    i_log_level    IN ods.log.log_level%TYPE);             -- Exchange Rate Details

  PROCEDURE validate_exchange_rate_detail(
    i_log_level    IN ods.log.log_level%TYPE,
    i_rate_type    IN VARCHAR2,
    i_from_curr    IN VARCHAR2,
    i_to_currncy   IN VARCHAR2,
    i_valid_from   IN VARCHAR2);

  PROCEDURE check_purchase_orders(
    i_log_level    IN ods.log.log_level%TYPE);             -- Purchase Orders

  PROCEDURE check_purchase_order_types(
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_purchase_order(
    i_log_level    IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2);

  PROCEDURE check_sales_orders(
    i_log_level    IN ods.log.log_level%TYPE);             -- Sales Orders

  PROCEDURE check_sales_order_types(
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_sales_order(
    i_log_level    IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2);

  PROCEDURE check_deliveries(
    i_log_level    IN ods.log.log_level%TYPE);             -- Deliveries

  PROCEDURE check_delivery_types(
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_delivery(
    i_log_level    IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2);

  PROCEDURE check_invoices(
    i_log_level    IN ods.log.log_level%TYPE);             -- Invoices

  PROCEDURE validate_invoice(
    i_log_level    IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2);

  PROCEDURE check_invoice_summaries(
    i_log_level    IN ods.log.log_level%TYPE,
    i_company_code IN ods.company.company_code%TYPE
    );             -- Invoice Summary

  PROCEDURE check_invoice_summary_types(
    i_log_level    IN ods.log.log_level%TYPE);

  PROCEDURE validate_invoice_summary(
    i_log_level       IN ods.log.log_level%TYPE,
    i_inv_creatn_date IN VARCHAR2,
    i_company_code    IN VARCHAR2,
    i_header_seq      IN PLS_INTEGER);

  PROCEDURE check_forecasts(
    i_log_level     IN ods.log.log_level%TYPE);             -- Forecasts

  PROCEDURE validate_forecast(
    i_log_level     IN ods.log.log_level%TYPE,
    i_fcst_hdr_code IN fcst_hdr.fcst_hdr_code%TYPE);

  PROCEDURE check_prodn_plan(
    i_log_level IN ods.log.log_level%TYPE);                 -- Production Plan

  PROCEDURE validate_prodn_plan(
    i_log_level     IN ods.log.log_level%TYPE,
    i_prodn_plan_hdr_code IN prodn_plan_hdr.prodn_plan_hdr_code%TYPE);

  PROCEDURE check_proc_plan_order(
    i_log_level IN ods.log.log_level%TYPE);               -- Process And Planned Orders

  PROCEDURE validate_proc_plan_order(
    i_log_level IN ods.log.log_level%TYPE,
    i_order_id IN sap_ppo_hdr.order_id%TYPE);

  PROCEDURE check_purch_order_bifg(
    i_log_level IN ods.log.log_level%TYPE);               -- Purchase Order BIFG

  PROCEDURE validate_purch_order_bifg(
    i_log_level IN ods.log.log_level%TYPE,
    i_order_num IN sap_opr_hdr.order_num%TYPE,
    i_order_item IN sap_opr_hdr.order_item%TYPE);

  PROCEDURE check_inventory_balance(
    i_log_level     IN ods.log.log_level%TYPE);             -- Inventory Balance

  PROCEDURE check_inventory_balance_types(
    i_log_level     IN ods.log.log_level%TYPE);

  PROCEDURE validate_inventory_balance(
  i_log_level         IN ods.log.log_level%TYPE,
  i_company_code      IN sap_stk_bal_hdr.bukrs%TYPE,
  i_plant_code        IN sap_stk_bal_hdr.werks%TYPE,
  i_storage_locn_code IN sap_stk_bal_hdr.lgort%TYPE,
  i_balance_date      IN sap_stk_bal_hdr.budat%TYPE,
  i_balance_time      IN sap_stk_bal_hdr.timlo%TYPE);

  PROCEDURE check_intransit_balance(
    i_log_level     IN ods.log.log_level%TYPE);             -- Intransit Balance

  PROCEDURE check_intransit_balance_types(
    i_log_level     IN ods.log.log_level%TYPE);

  PROCEDURE validate_intransit_balance(
  i_log_level       IN ods.log.log_level%TYPE,
  i_plant_code      IN sap_int_stk_hdr.werks%TYPE);

  PROCEDURE check_regl_sales(i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_regl_sales(i_log_level IN ods.log.log_level%TYPE,
                                i_intfc_id  IN ods.regl_sales_hdr.intfc_id%type);

  PROCEDURE check_pmx_accruals(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_pmx_accrual(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN pmx_accruals.company_code%TYPE,
    i_division_code     IN pmx_accruals.division_code%TYPE,
    i_cust_code         IN pmx_accruals.cust_code%TYPE,
    i_prom_num          IN pmx_accruals.prom_num%TYPE,
    i_matl_zrep_code    IN pmx_accruals.matl_zrep_code%TYPE,
    i_accrl_date        IN pmx_accruals.accrl_date%TYPE,
    i_matl_tdu_code     IN pmx_accruals.matl_tdu_code%TYPE,
    i_currcy_code       IN pmx_accruals.currcy_code%TYPE
   );

  PROCEDURE check_promotions(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE check_promotion_types(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_promotion(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN pmx_prom_hdr.company_code%TYPE,
    i_division_code     IN pmx_prom_hdr.division_code%TYPE,
    i_prom_num          IN pmx_prom_hdr.prom_num%TYPE,
    i_prom_chng_date    IN pmx_prom_hdr.prom_chng_date%TYPE
   );

  PROCEDURE check_pmx_claims(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE check_pmx_claim_docs(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_pmx_claim(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN pmx_claim_hdr.company_code%TYPE,
    i_division_code     IN pmx_claim_hdr.division_code%TYPE,
    i_claim_key         IN pmx_claim_hdr.claim_key%TYPE
   );

  PROCEDURE check_dcs_sales_orders(
    i_log_level IN ods.log.log_level%TYPE);  
    
  PROCEDURE validate_dcs_sales_order(
    i_log_level           IN ods.log.log_level%TYPE,
    i_company_code        IN dcs_sales_order.company_code%TYPE,
    i_order_doc_num       IN dcs_sales_order.order_doc_num%TYPE,
    i_order_doc_line_num  IN dcs_sales_order.order_doc_line_num%TYPE
   );    

  PROCEDURE validate_pmx_accrual_bulk(
    i_log_level IN ods.log.log_level%TYPE);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'ODS Validation V2';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'VENUS - ODS_VALIDATION';
      var_log_search := 'ODS_VALIDATION';
      var_loc_string := 'ODS_VALIDATION_' || par_action;
      var_email := lics_setting_configuration.retrieve_setting('ODS_VALIDATION', 'EMAIL_GROUP');
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*ALL' then
         raise_application_error(-20000, 'Action parameter must be *ALL');
      end if;

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - ODS_VALIDATION - Parameters(' || upper(par_action) || ')');
      lics_logging.write_log('Alerts/Failures sent to ' || nvl(var_email,'n/a'));

      /*-*/
      /* Request the lock on the ODS Validation
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the Validation procedures
         /*-*/
         if upper(par_action) = '*ALL' then
            begin

               check_order_usages(0);
               check_order_types(0);
               check_addresses(0);
               check_materials(0);
               check_exchange_rate_details(0);
               check_purchase_orders(0);
               check_sales_orders(0);
               check_deliveries(0);
               check_invoices(0);
               check_invoice_summaries(0, '147');
               check_invoice_summaries(0, '149');
               check_forecasts(0);
               check_prodn_plan(0);
               check_proc_plan_order(0);
               check_purch_order_bifg(0);
               check_inventory_balance(0);
               check_intransit_balance(0);
               check_regl_sales(0);
               check_promotions(0);
               check_pmx_claims(0);
               validate_pmx_accrual_bulk(0);
               check_dcs_sales_orders(0);

            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock on the ODS Validation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - ODS_VALIDATION');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         lics_notification.send_email(ods_parameter.business_unit_code,
                                      'VENUS',
                                      ods_parameter.system_environment,
                                      con_function,
                                      'ODS_VALIDATION_V2',
                                      var_email,
                                      'One or more errors occurred during the ODS Validation execution - refer to web log - ' || lics_logging.callback_identifier);
      end if;


   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || substr(SQLERRM, 1, 1024));
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the ODS_VALIDATION
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - VENUS - ODS_VALIDATION_V2 - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;


   /*************************************************/
   /* This procedure performs the write log routine */
   /*************************************************/
   procedure write_log(i_data_type  in ods.log.data_type%type,
                       i_sort_field in ods.log.sort_field%type,
                       i_log_level  in ods.log.log_level%type,
                       i_log_text   in ods.log.log_text%type) is

   begin

      lics_logging.write_log(i_log_text);

   exception
      when others then
        raise;
   end write_log;


  /*******************************************************************************
    NAME:       CHECK_ORDER_USAGES
    PURPOSE:    This code reads through all Order Usage records with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
  ********************************************************************************/
  PROCEDURE check_order_usages(
    i_log_level IN ods.log.log_level%TYPE) IS

  CURSOR csr_order_usage IS
    SELECT
      *
    FROM
      order_usage
    WHERE
      valdtn_status = ods_constants.valdtn_unchecked;
    rv_order_usage csr_order_usage%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_order_usage, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_ORDER_USAGES: Started.');

    OPEN csr_order_usage;
    LOOP
      FETCH csr_order_usage INTO rv_order_usage;
      EXIT WHEN csr_order_usage%NOTFOUND;

      -- Validate each unchecked Order Usage record.
      write_log(ods_constants.data_type_order_usage, 'n/a', i_log_level + 2,
                'Validating Order Usage: ' || rv_order_usage.order_usage_code);
      validate_order_usage(i_log_level + 2, rv_order_usage.order_usage_code);

      -- To stop a cursor too old error, open and close the cursor between each check.
      CLOSE csr_order_usage;
      OPEN csr_order_usage;

    END LOOP;
    CLOSE csr_order_usage;
    COMMIT;

    write_log(ods_constants.data_type_order_usage, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_ORDER_USAGES: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_order_usage, 'n/a', 0, 'ODS_VALIDATION.CHECK_ORDER_USAGES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_order_usages;

  /*******************************************************************************
    NAME:       VALIDATE_ORDER_USAGE
    PURPOSE:    This code validates an Order Usage, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_order_usage(
    i_log_level        IN ods.log.log_level%TYPE,
    i_order_usage_code IN order_usage.order_usage_code%TYPE) IS

    -- Variable Declarations
    v_valdtn_status order_usage.valdtn_status%TYPE := ods_constants.valdtn_valid;

    -- Cursor Declarations
    -- Only process the Order Usage record if we can lock it. That way we can parallel validate.
    -- We also recheck the status just in case another validator got in a valdiated it first.
    CURSOR csr_order_usage IS
      SELECT
        *
      FROM
        order_usage
      WHERE
        order_usage_code = i_order_usage_code AND
        valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
      rv_order_usage csr_order_usage%ROWTYPE;

  BEGIN

    OPEN csr_order_usage;
    FETCH csr_order_usage INTO rv_order_usage;
    IF csr_order_usage%FOUND THEN

      -- Clear the validation reason tables of this order usage
      utils.clear_validation_reason(ods_constants.valdtn_type_order_usage,
                                    i_order_usage_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);


      -- Any Order Usage with a gsv flag of UNCLASSIFIED is INVALID, otherwise its VALID.
      IF rv_order_usage.order_usage_gsv_flag = ods_constants.gsv_flag_unclassified THEN
        v_valdtn_status := ods_constants.valdtn_invalid;

        utils.add_validation_reason(ods_constants.valdtn_type_order_usage,
                              'GSV_Flag has value of UNCLASSIFIED. Set to valid working value.',
                              ods_constants.valdtn_severity_warning,
                              i_order_usage_code,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              i_log_level + 1);

      ELSE
        v_valdtn_status := ods_constants.valdtn_valid;

        -- OK. We've made the Order Usage valid. Now set all invalid Billing Documents which
        -- use the Order Usage to unchecked, just in case it was the Order Usage that was
        -- making the Invoice invalid.
        UPDATE /*+ INDEX(SAP_INV_HDR SAP_INV_HDR_I1) */
          sap_inv_hdr a
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE
          a.valdtn_status = ods_constants.valdtn_invalid AND
          a.belnr in (SELECT /*+ INDEX(SAP_INV_GEN SAP_INV_GEN_I1) */
                         distinct belnr
                       FROM
                         sap_inv_gen a
                       WHERE
                         a.abrvw = i_order_usage_code);

      END IF;

      -- Now update the actual Order Usage record with the appropriate validation status.
      UPDATE
        order_usage
      SET
        valdtn_status = v_valdtn_status
      WHERE
        order_usage_code = i_order_usage_code;

    END IF;
    CLOSE csr_order_usage;

    -- As we're potentially updating many invoice records each time we update an Order Usage
    -- we're going to commit each time so as to release the locks on the invoice records asap.
    COMMIT;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_order_usage;


  /*******************************************************************************
    NAME:       CHECK_ORDER_TYPES
    PURPOSE:    This code reads through all Order Types records with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
  ********************************************************************************/
  PROCEDURE check_order_types(
    i_log_level IN ods.log.log_level%TYPE) IS

  CURSOR csr_order_type IS
    SELECT
      *
    FROM
      order_type
    WHERE
      valdtn_status = ods_constants.valdtn_unchecked;
    rv_order_type csr_order_type%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_order_type, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_ORDER_TYPES: Started.');

    OPEN csr_order_type;
    LOOP
      FETCH csr_order_type INTO rv_order_type;
      EXIT WHEN csr_order_type%NOTFOUND;

      -- Validate each unchecked Order Type record.
      write_log(ods_constants.data_type_order_type, 'n/a', i_log_level + 2,
                'Validating Order Type: ' || rv_order_type.order_type_code);
      validate_order_type(i_log_level + 2, rv_order_type.order_type_code);

      -- To stop a cursor too old error, open and close the cursor between each check.
      CLOSE csr_order_type;
      OPEN csr_order_type;

    END LOOP;
    CLOSE csr_order_type;
    COMMIT;

    write_log(ods_constants.data_type_order_type, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_ORDER_TYPES: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_order_type, 'n/a', 0, 'ODS_VALIDATION.CHECK_ORDER_TYPES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_order_types;

  /*******************************************************************************
    NAME:       VALIDATE_ORDER_TYPE
    PURPOSE:    This code validates an Order Type, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_order_type(
    i_log_level       IN ods.log.log_level%TYPE,
    i_order_type_code IN order_type.order_type_code%TYPE) IS

    -- Variable Declarations
    v_valdtn_status order_type.valdtn_status%TYPE := ods_constants.valdtn_valid;

    -- Cursor Declarations
    -- Only process the Order Type record if we can lock it. That way we can parallel validate.
    -- We also recheck the status just in case another validator got in a valdiated it first.
    CURSOR csr_order_type IS
      SELECT
        *
      FROM
        order_type
      WHERE
        order_type_code = i_order_type_code AND
        valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
      rv_order_type csr_order_type%ROWTYPE;

  BEGIN

    OPEN csr_order_type;
    FETCH csr_order_type INTO rv_order_type;
    IF csr_order_type%FOUND THEN

      -- Clear the validation reason tables of this order type
      utils.clear_validation_reason(ods_constants.valdtn_type_order_type,
                                    i_order_type_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);


      -- Any Order Type with a gsv flag of UNCLASSIFIED is INVALID, otherwise its VALID.
      IF rv_order_type.order_type_gsv_flag = ods_constants.gsv_flag_unclassified THEN
        v_valdtn_status := ods_constants.valdtn_invalid;

        utils.add_validation_reason(ods_constants.valdtn_type_order_type,
                              'GSV_Flag has value of UNCLASSIFIED. Set to valid working value.',
                              ods_constants.valdtn_severity_warning,
                              i_order_type_code,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              i_log_level + 1);

      ELSE
        v_valdtn_status := ods_constants.valdtn_valid;

        -- OK. We've made the Order Type valid. Now set all invalid Sales Order Documents which
        -- use the Order Type to unchecked, just in case it was the Order Type that was
        -- making the Sales Order invalid.
        UPDATE /*+ INDEX(a SAP_SAL_ORD_HDR_I2) */
          sap_sal_ord_hdr a
        SET
          a.valdtn_status = ods_constants.valdtn_unchecked
        WHERE
          a.valdtn_status = ods_constants.valdtn_invalid AND
          a.belnr IN (SELECT
                        DISTINCT belnr
                      FROM
                        sap_sal_ord_org a
                      WHERE
                        a.qualf = ods_constants.sales_order_order_type
                        AND a.orgid = i_order_type_code);

      END IF;

      -- Now update the actual Order Type record with the appropriate validation status.
      UPDATE
        order_type
      SET
        valdtn_status = v_valdtn_status
      WHERE
        order_type_code = i_order_type_code;

    END IF;
    CLOSE csr_order_type;

    COMMIT;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_order_type;


  /*******************************************************************************
    NAME:       CHECK_ADDRESSES
    PURPOSE:    This code reads through all addresses with a validation status of
                "UNCHECKED", nd calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_addresses(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count  PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_address_hdr IS
      SELECT /*+ INDEX(SAP_ADR_HDR SAP_ADR_HDR_I1) */
        *
      FROM
        sap_adr_hdr
      WHERE
        sap_adr_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_address_hdr csr_address_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_address, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_ADDRESSES: Started.');

    -- Check the various types in the addresses
    check_address_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_address_hdr;
    LOOP
      FETCH csr_address_hdr INTO rv_address_hdr;
      EXIT WHEN csr_address_hdr%NOTFOUND;

      -- PROCESS DATA
      write_log(ods_constants.data_type_address, 'n/a', i_log_level + 2, 'Validating Address Obj Type: ' ||
                                                                         rv_address_hdr.obj_type ||
                                                                         ' Obj ID: ' ||
                                                                         rv_address_hdr.obj_id ||
                                                                         ' Context: ' ||
                                                                         rv_address_hdr.context);
      validate_address(i_log_level + 2, rv_address_hdr.obj_type, rv_address_hdr.obj_id, rv_address_hdr.context);

      -- Commit when required, and recheck which materials need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

    END LOOP;
    CLOSE csr_address_hdr;

    COMMIT;

    write_log(ods_constants.data_type_address, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_ADDRESSES: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_address, 'n/a', 0, 'ODS_VALIDATION.CHECK_ADDRESSES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_addresses;



  /*******************************************************************************
    NAME:       CHECK_ADDRESS_TYPES
    PURPOSE:    This code checks to see is the various type included in the address
                records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_address_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- CURSOR DECLARATIONS
    CURSOR csr_country IS
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_ADR_HDR_I1) INDEX(b SAP_ADR_DET_PK) */
        DISTINCT b.country AS country_code
      FROM
        sap_adr_hdr a,
        sap_adr_det b,
        cntry c
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND a.obj_type  = b.obj_type
        AND a.obj_id    = b.obj_id
        AND a.context   = b.context
        AND b.country = c.cntry_code(+)
        AND b.country IS NOT NULL
        AND c.cntry_code IS NULL;
    rv_country csr_country%ROWTYPE;


    -- There is no NOT IN statement as the region table has
    -- country and region codes as the PK
    CURSOR csr_region IS
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_ADR_HDR_I1) INDEX(b SAP_ADR_DET_PK) */ DISTINCT
        b.region  AS region_code,
        b.country AS country_code
      FROM
        sap_adr_hdr a,
        sap_adr_det b,
        region c
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND a.obj_type  = b.obj_type
        AND a.obj_id    = b.obj_id
        AND a.context   = b.context
        AND b.region IS NOT NULL
        AND b.country IS NOT NULL
        AND c.cntry_code(+) = b.country
        AND c.region_code(+) = b.region
        AND c.cntry_code IS NULL
        AND c.region_code IS NULL;
    rv_region csr_region%ROWTYPE;

  BEGIN

    -- check the Countries in the address detail records.
    write_log(ods_constants.data_type_address, 'n/a', i_log_level + 1, 'Check for new Countries.');
    OPEN csr_country;
    LOOP
      FETCH csr_country INTO rv_country;
      EXIT WHEN csr_country%NOTFOUND;

      write_log(ods_constants.data_type_address, 'n/a', i_log_level + 1, 'Inserting Country Code: ' || rv_country.country_code || ' found in address.');

      append.append_cntry_code(rv_country.country_code);
    END LOOP;
    CLOSE csr_country;

    -- check the Regions in the address detail records.
    write_log(ods_constants.data_type_address, 'n/a', i_log_level + 1, 'Check for new Regions.');
    OPEN csr_region;
    LOOP
      FETCH csr_region INTO rv_region;
      EXIT WHEN csr_region%NOTFOUND;

      write_log(ods_constants.data_type_address, 'n/a', i_log_level + 1, 'Inserting Region Code/Country Code: ' || rv_region.region_code || '/' || rv_region.country_code || ' found in the Address into the Region table.');

      append.append_region_code(rv_region.region_code, rv_region.country_code);

    END LOOP;
    CLOSE csr_region;

  END check_address_types;



  /*******************************************************************************
    NAME:       VALIDATE_ADDRESS
    PURPOSE:    This code validates an address, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_address(
    i_log_level IN ods.log.log_level%TYPE,
    i_obj_type  IN sap_adr_hdr.obj_type%TYPE,
    i_obj_id    IN sap_adr_hdr.obj_id%TYPE,
    i_context   IN sap_adr_hdr.context%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_adr_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_address_hdr IS
      SELECT
        *
      FROM
        sap_adr_hdr A
      WHERE
        A.obj_type     = i_obj_type
        AND A.obj_id   = i_obj_id
        AND A.context  = i_context
        AND A.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_address_hdr csr_address_hdr%ROWTYPE;

  BEGIN

    OPEN csr_address_hdr;
    FETCH csr_address_hdr INTO rv_address_hdr;
    IF csr_address_hdr%FOUND THEN

      -- Clear the validation reason tables of this address
      -- UNCOMMENT THIS BLOCK IF VALIDATION THAT WOULD CAUSE THE ADDRESS
      -- TO BECOME INVALID IS IMPLEMENTED.
      /*
      utils.clear_validation_reason(ods_constants.valdtn_type_address,
                                    i_obj_type,
                                    i_obj_id,
                                    i_context,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);*/

      -- Make the address valid
      UPDATE
        sap_adr_hdr
      SET
        valdtn_status=v_valdtn_status
      WHERE
        obj_type = i_obj_type
        AND obj_id   = i_obj_id
        AND context  = i_context;

    END IF;
    CLOSE csr_address_hdr;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_address;


      /******************************************************
       * UNCOMMENT THE BELOW BLOCK IF ANY VALIDATIONS FOR   *
       * SAP_REF DATA NEEDS TO BE IMPLEMENTED BY THE SYSTEM *
       ******************************************************/

  /*******************************************************************************
    NAME:       CHECK_SAP_REF
    PURPOSE:    This code reads through all SAP_REF data with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  /*PROCEDURE check_sap_refs(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count  PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_sap_ref_hdr IS
      SELECT
        *
      FROM
        sap_ref_hdr
      WHERE
        sap_ref_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_sap_ref_hdr csr_sap_ref_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_reference, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_SAP_REF: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_sap_ref_hdr;
    LOOP
      FETCH csr_sap_ref_hdr INTO rv_sap_ref_hdr;
      EXIT WHEN csr_sap_ref_hdr%NOTFOUND;

      -- PROCESS DATA
      write_log(ods_constants.data_type_reference, 'n/a', i_log_level + 2, 'Validating Reference Data: ' ||
                                                                           rv_sap_ref_hdr.z_tabname);
      validate_sap_ref(i_log_level + 2, rv_sap_ref_hdr.z_tabname);

      -- Commit when required, and recheck which sap reference data need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

    END LOOP;
    CLOSE csr_sap_ref_hdr;

    COMMIT;

    write_log(ods_constants.data_type_reference, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_SAP_REF: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_reference, 'n/a', 0, 'ODS_VALIDATION.CHECK_SAP_REF: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_sap_refs;*/


      /******************************************************
       * UNCOMMENT THE BELOW BLOCK IF ANY VALIDATIONS FOR   *
       * SAP_REF DATA NEEDS TO BE IMPLEMENTED BY THE SYSTEM *
       ******************************************************/

  /*******************************************************************************
    NAME:       VALIDATE_SAP_REF
    PURPOSE:    This code validates SAP Reference Data, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  /*PROCEDURE validate_sap_ref(
    i_log_level    IN ods.log.log_level%TYPE,
    i_z_tabname    IN sap_ref_hdr.z_tabname%TYPE) IS

    -- Variable Declarations
    v_valdtn_status sap_ref_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;

    -- CURSOR DECLARATIONS
    CURSOR csr_sap_ref_hdr IS
      SELECT
        *
      FROM
        sap_ref_hdr
      WHERE
        sap_ref_hdr.z_tabname = i_z_tabname AND
        sap_ref_hdr.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_sap_ref_hdr csr_sap_ref_hdr%ROWTYPE;

  BEGIN

    OPEN csr_sap_ref_hdr;
    FETCH csr_sap_ref_hdr INTO rv_sap_ref_hdr;

    -- Clear the validation reason tables of this sap_ref data
    utils.clear_validation_reason(ods_constants.valdtn_type_sap_ref,
                                  i_z_tabname,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

    UPDATE
      sap_ref_hdr
    SET
      valdtn_status = ods_constants.valdtn_valid
    WHERE
      z_tabname = rv_sap_ref_hdr.z_tabname;

    CLOSE csr_sap_ref_hdr;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_sap_ref;*/



      /*******************************************************
       * UNCOMMENT THE BELOW BLOCK IF ANY VALIDATIONS FOR    *
       * CUSTOMER DATA NEEDS TO BE IMPLEMENTED BY THE SYSTEM *
       *******************************************************/
  /*******************************************************************************
    NAME:       CHECK_CUSTOMERS
    PURPOSE:    This code reads through all CUSTOMER data with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  /*PROCEDURE check_customers(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count  PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_cus_hdr IS
      SELECT
        *
      FROM
        sap_cus_hdr
      WHERE
        sap_cus_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_cus_hdr csr_cus_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_customer, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_CUSTOMER: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_cus_hdr;
    LOOP
      FETCH csr_cus_hdr INTO rv_cus_hdr;
      EXIT WHEN csr_cus_hdr%NOTFOUND;

      -- PROCESS DATA
      write_log(ods_constants.data_type_customer, 'n/a', i_log_level + 2, 'Validating Customer: ' ||
                                                                           rv_cus_hdr.kunnr);
      validate_customer(i_log_level + 2, rv_cus_hdr.kunnr);

      -- Commit when required, and recheck which customer data need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

    END LOOP;
    CLOSE csr_cus_hdr;

    COMMIT;

    write_log(ods_constants.data_type_customer, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_CUSTOMER: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_customer, 'n/a', 0, 'ODS_VALIDATION.CHECK_CUSTOMER: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_customers;*/



      /*******************************************************
       * UNCOMMENT THE BELOW BLOCK IF ANY VALIDATIONS FOR    *
       * CUSTOMER DATA NEEDS TO BE IMPLEMENTED BY THE SYSTEM *
       *******************************************************/
  /*******************************************************************************
    NAME:       VALIDATE_CUSTOMER
    PURPOSE:    This code validates Customer Data, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  /*PROCEDURE validate_customer(
    i_log_level IN ods.log.log_level%TYPE,
    i_kunnr     IN sap_cus_hdr.kunnr%TYPE) IS

    -- Variable Declarations
    v_valdtn_status sap_cus_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;

    -- CURSOR DECLARATIONS
    CURSOR csr_cus_hdr IS
      SELECT
        *
      FROM
        sap_cus_hdr
      WHERE
        sap_cus_hdr.kunnr = i_kunnr AND
        sap_cus_hdr.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_cus_hdr csr_cus_hdr%ROWTYPE;

  BEGIN

    OPEN csr_cus_hdr;
    FETCH csr_cus_hdr INTO rv_cus_hdr;

    -- Clear the validation reason tables of this customer
    utils.clear_validation_reason(ods_constants.valdtn_type_customer,
                                  i_kunnr,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

    UPDATE
      sap_cus_hdr
    SET
      valdtn_status = ods_constants.valdtn_valid
    WHERE
      kunnr = rv_cus_hdr.kunnr;

    CLOSE csr_cus_hdr;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END;*/



  /*******************************************************************************
    NAME:       CHECK_MATERIALS
    PURPOSE:    This code reads through all materials with a validation status of
                "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_materials(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_material_hdr IS
      SELECT
        *
      FROM
        sap_mat_hdr
      WHERE
        sap_mat_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_material_hdr csr_material_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_material, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_MATERIALS: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_material_hdr;
    FETCH csr_material_hdr INTO rv_material_hdr;
    WHILE csr_material_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Validating Material: ' || rv_material_hdr.matnr);
      validate_material(i_log_level + 2, rv_material_hdr.matnr);

      -- Commit each 10 records, and recheck which materials need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= 10 THEN
        COMMIT;
        v_record_count := 0;

        -- To avoid snapshot too old errors, recheck material needing to be checked.
        CLOSE csr_material_hdr;
        OPEN csr_material_hdr;
      END IF;

      FETCH csr_material_hdr INTO rv_material_hdr;
    END LOOP;
    CLOSE csr_material_hdr;
    COMMIT;

    write_log(ods_constants.data_type_material, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_MATERIALS: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_material, 'n/a', 0, 'ODS_VALIDATION.CHECK_MATERIALS: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_materials;


/*******************************************************************************
      NAME:       VALIDATE_MATERIAL
      PURPOSE:    This code validates a material, as specified by the input
                  parameter, and updates the status on the record accordingly.
    ********************************************************************************/
    PROCEDURE validate_material(
      i_log_level    IN ods.log.log_level%TYPE,
      i_material_nbr IN VARCHAR2) IS

      -- VARIABLE DECLARATIONS
      v_valdtn_status sap_mat_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
      v_count         PLS_INTEGER;

      -- CURSOR DECLARATIONS
      CURSOR csr_material_hdr IS
        SELECT
          *
        FROM
          sap_mat_hdr
        WHERE
          sap_mat_hdr.matnr = i_material_nbr AND
          sap_mat_hdr.valdtn_status = ods_constants.valdtn_unchecked
        FOR UPDATE NOWAIT;
      rv_material_hdr csr_material_hdr%ROWTYPE;

    BEGIN

      -- Validate the material header record.
      OPEN csr_material_hdr;
      FETCH csr_material_hdr INTO rv_material_hdr;
      IF csr_material_hdr%FOUND THEN

        -- Clear the validation reason tables of this material
        utils.clear_validation_reason(ods_constants.valdtn_type_material,
                                      i_material_nbr,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);

      -- Weight Unit of Measure must exist and be valid, ONLY when the material type is a FERT
      -- (Finished Good) or a ZREP (Representative Item).
      IF rv_material_hdr.mtart = ods_constants.material_type_fert OR
         rv_material_hdr.mtart = ods_constants.material_type_zrep THEN
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          sap_mat_hdr a,
          uom b
        WHERE
          a.matnr = rv_material_hdr.matnr
          AND a.gewei = b.uom_code;
        IF v_count <> 1 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_material, 'n/a', i_log_level + 1, 'Material: ' || rv_material_hdr.matnr || ': Invalid or non-existant Weight Unit of Measure.');

          -- Add this reason to the validation reason table
          utils.add_validation_reason(ods_constants.valdtn_type_material,
                                      'Invalid or non-existant Weight Unit of Measure.',
                                      ods_constants.valdtn_severity_critical,
                                      i_material_nbr,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
        END IF;
      END IF;

      -- Net Weight must exist and be > 0, ONLY when the material type is a FERT
      -- (Finished Good) or a ZREP (Representative Item).
      IF rv_material_hdr.mtart = ods_constants.material_type_fert OR
         rv_material_hdr.mtart = ods_constants.material_type_zrep THEN
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          sap_mat_hdr a
        WHERE
          a.matnr = rv_material_hdr.matnr
          AND (a.ntgew IS NULL OR a.ntgew <= 0);
        IF v_count > 0 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_material, 'n/a', i_log_level + 1, 'Material: ' || rv_material_hdr.matnr || ': Invalid or non-existant Net Weight Value.');

          -- Add this reason to the validation reason table
          utils.add_validation_reason(ods_constants.valdtn_type_material,
                                      'Invalid or non-existant Net Weight Value.',
                                      ods_constants.valdtn_severity_critical,
                                      i_material_nbr,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
        END IF;
      END IF;

       -- Base Unit of Measure must exist and be valid.
       v_count := 0;
       SELECT
         count(*) INTO v_count
       FROM
         sap_mat_hdr a,
         uom b
       WHERE
         a.matnr = rv_material_hdr.matnr
         AND a.meins = b.uom_code
         AND b.valdtn_status = ods_constants.valdtn_valid;
       IF v_count <> 1 THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.data_type_material, 'n/a', i_log_level + 1, 'Material: ' || rv_material_hdr.matnr || ': Invalid or non-existant Base Unit of Measure.');

         -- Add this reason to the validation reason table
         utils.add_validation_reason(ods_constants.valdtn_type_material,
                                     'Invalid or non-existant Base Unit of Measure.',
                                     ods_constants.valdtn_severity_critical,
                                     i_material_nbr,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
       END IF;

        -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Material: ' || i_material_nbr || ' is ' || v_valdtn_status);
        UPDATE sap_mat_hdr
        SET
          sap_mat_hdr.valdtn_status = v_valdtn_status
        WHERE
          CURRENT OF csr_material_hdr;

        -- Update all purchase orders which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the purchase orders to be revalidated,
        -- just in case it was this material which caused the purchase order to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Purchase Orders');
        UPDATE sap_sto_po_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE belnr IN (SELECT /*+ USE_NL(SAP_STO_PO_OID) INDEX(a SAP_STO_PO_HDR_I2) INDEX(b SAP_STO_PO_OID_PK) */
                                a.belnr
                        FROM    sap_sto_po_hdr a,
                                sap_sto_po_oid b
                        WHERE   (a.valdtn_status = ods_constants.valdtn_invalid
                                  OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                AND b.belnr = a.belnr
                                AND b.qualf = ods_constants.purch_order_material_code
                                AND b.idtnr = rv_material_hdr.matnr);

        -- Update all sales order which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the sales orders to be revalidated,
        -- just in case it was this material which caused the sales order to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Sales Orders');
        UPDATE /*+ INDEX(a SAP_SAL_ORD_HDR_PK) */ sap_sal_ord_hdr a
        SET
          a.valdtn_status = ods_constants.valdtn_unchecked
        WHERE a.belnr IN (SELECT /*+ ORDERED USE_NL(b) INDEX(b SAP_SAL_ORD_IID_PK) */
                                  a.belnr
                          FROM    sap_sal_ord_hdr a,
                                  sap_sal_ord_iid b
                          WHERE   (a.valdtn_status = ods_constants.valdtn_invalid
                                    OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                  AND b.belnr = a.belnr
                                  AND b.qualf = ods_constants.sales_order_material_code
                                  AND b.idtnr = LTRIM(rv_material_hdr.matnr,'0'));

        -- Update all deliveries which use the material, and have a validation status of INVALID or UNCHECKED, setting
        -- the validation status to UNCHECKED. This forces the deliveries to be revalidated, just in case
        -- it was this material which caused the delivery to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Deliveries');
        UPDATE /*+ ORDERED USE_NL(a) */ sap_del_hdr a
        SET
          a.valdtn_status = ods_constants.valdtn_unchecked
        WHERE a.vbeln IN (SELECT  /*+ ORDERED USE_NL(b) */
                                a.vbeln
                        FROM    sap_del_hdr a,
                                sap_del_det b
                        WHERE   (a.valdtn_status = ods_constants.valdtn_invalid
                                  OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                AND b.vbeln = a.vbeln
                                AND b.matnr = rv_material_hdr.matnr);

        -- Update all invoices which use the material, and have a validation status of INVALID or UNCHECKED, setting
        -- the validation status to UNCHECKED. This forces the invoices to be revalidated, just in case
        -- it was this material which caused the invoice to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Invoices');
        UPDATE sap_inv_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE belnr IN (SELECT  a.belnr
                        FROM    sap_inv_hdr a,
                                sap_inv_iob b
                        WHERE   (a.valdtn_status = ods_constants.valdtn_invalid
                                  OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                AND b.belnr = a.belnr
                                AND b.qualf = ods_constants.invoice_material_code
                                AND b.idtnr = rv_material_hdr.matnr);

        -- Update all inventory balances which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the inventory balances to be revalidated,
        -- just in case it was this material which caused the inventory balance to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Stock Balances');
        UPDATE sap_stk_bal_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE bukrs || werks || lgort || budat || timlo IN (
          SELECT /*+ ORDERED INDEX(b SAP_STK_BAL_DET_PK) */
            a.bukrs || a.werks || a.lgort || a.budat || a.timlo
          FROM
            sap_stk_bal_hdr a,
            sap_stk_bal_det b
          WHERE
            a.bukrs = b.bukrs
            AND a.werks = b.werks
            AND a.lgort = b.lgort
            AND a.budat = b.budat
            AND a.timlo = b.timlo
            AND (a.valdtn_status = ods_constants.valdtn_invalid
              OR a.valdtn_status = ods_constants.valdtn_unchecked)
            AND b.matnr = rv_material_hdr.matnr);

        -- Update all intransits which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the intransits to be revalidated,
        -- just in case it was this material which caused the intransit to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Stock Intransits');
        UPDATE sap_int_stk_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE werks IN (SELECT /*+ INDEX(b SAP_INT_STK_DET_PK) */
                          a.werks
                        FROM
                          sap_int_stk_hdr a,
                          sap_int_stk_det b
                        WHERE
                          a.werks = b.werks
                          AND (a.valdtn_status = ods_constants.valdtn_invalid
                            OR a.valdtn_status = ods_constants.valdtn_unchecked)
                          AND b.matnr = rv_material_hdr.matnr);

        -- Update all production plans which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the production plans to be revalidated,
        -- just in case it was this material which caused the production plan to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Production Plan');
        UPDATE prodn_plan_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE prodn_plan_hdr_code IN (SELECT DISTINCT
                                  a.prodn_plan_hdr_code
                                FROM
                                  prodn_plan_hdr a,
                                  prodn_plan_dtl b
                                WHERE
                                  a.prodn_plan_hdr_code = b.prodn_plan_hdr_code
                                  AND (a.valdtn_status = ods_constants.valdtn_invalid
                                  OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                  AND b.matl_code = LTRIM(rv_material_hdr.matnr,'0'));

        -- Update all open purchase orders which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the open purchase orders to be revalidated,
        -- just in case it was this material which caused the open purchase orders to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Open Purchase Orders');
        UPDATE sap_opr_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE order_num || order_item IN (SELECT
                                            a.order_num || a.order_item
                                          FROM
                                            sap_opr_hdr a
                                          WHERE
                                            (a.valdtn_status = ods_constants.valdtn_invalid
                                            OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                            AND a.material = rv_material_hdr.matnr);

        -- Update all planned processed orders which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the planned processed orders to be revalidated,
        -- just in case it was this material which caused the planned processed orders to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Planned Process Orders');
        UPDATE sap_ppo_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE order_id IN (SELECT
                             a.order_id
                           FROM
                             sap_ppo_hdr a
                           WHERE
                             (a.valdtn_status = ods_constants.valdtn_invalid
                             OR a.valdtn_status = ods_constants.valdtn_unchecked)
                             AND a.item = rv_material_hdr.matnr);

        -- Update all forecasts which use the material, and have a validation status of INVALID or UNCHECKED,
        -- setting the validation status to UNCHECKED. This forces the forecasts to be revalidated,
        -- just in case it was this material which caused the forecast to be invalid.
        write_log(ods_constants.data_type_material, 'n/a', i_log_level + 2, 'Update INVALID Forecast Headers');
        UPDATE fcst_hdr
        SET
          valdtn_status = ods_constants.valdtn_unchecked
        WHERE fcst_hdr_code IN (
        SELECT   /*+ ORDERED USE_NL(b) */
                                a.fcst_hdr_code
                        FROM    fcst_hdr a,
                                fcst_dtl b
                        WHERE   ((a.valdtn_status = ods_constants.valdtn_invalid AND a.current_fcst_flag <> ods_constants.fcst_deleted_fcst)
                                  OR a.valdtn_status = ods_constants.valdtn_unchecked)
                                AND b.fcst_hdr_code = a.fcst_hdr_code
                                AND b.matl_zrep_code = LTRIM(rv_material_hdr.matnr,'0'));



      END IF;
      CLOSE csr_material_hdr;

    EXCEPTION
      WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
        NULL;
  END validate_material;


  /*******************************************************************************
    NAME:       CHECK_EXCHANGE_RATE_DETAILS
    PURPOSE:    This code reads through all exchange rate details records with a
                validation status of "UNCHECKED", and calls a routine to validate
                the record. The logic opens and closes the cursor before checking
                for each new group of records, so that if any additional records
                are written in while validation is occurring, then these are also
                validated.
  ********************************************************************************/
  PROCEDURE check_exchange_rate_details(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count  PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_exchange_rate IS
      SELECT
        *
      FROM
        sap_xch_rat_det
      WHERE
        sap_xch_rat_det.valdtn_status = ods_constants.valdtn_unchecked;
    rv_exchange_rate csr_exchange_rate%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_EXCHANGE_RATE_DETAILS: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_exchange_rate;
    FETCH csr_exchange_rate INTO rv_exchange_rate;
    WHILE csr_exchange_rate%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 2,
          'Validating Exchange Rate Detail: ' || rv_exchange_rate.rate_type || '/' ||
                                                 rv_exchange_rate.from_curr || '/' ||
                                                 rv_exchange_rate.to_currncy || '/' ||
                                                 rv_exchange_rate.valid_from);
      validate_exchange_rate_detail(i_log_level + 2, rv_exchange_rate.rate_type,
                                                     rv_exchange_rate.from_curr,
                                                     rv_exchange_rate.to_currncy,
                                                     rv_exchange_rate.valid_from);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_exchange_rate INTO rv_exchange_rate;
    END LOOP;
    CLOSE csr_exchange_rate;
    COMMIT;

    write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_EXCHANGE_RATE_DETAILS: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_exch_rate_det, 'n/a', 0, 'ODS_VALIDATION.CHECK_EXCHANGE_RATE_DETAILS: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_exchange_rate_details;

  /*******************************************************************************
    NAME:       VALIDATE_EXCHANGE_RATE_DETAIL
    PURPOSE:    This code validates a sales order record, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_exchange_rate_detail(
    i_log_level  IN ods.log.log_level%TYPE,
    i_rate_type  IN VARCHAR2,
    i_from_curr  IN VARCHAR2,
    i_to_currncy IN VARCHAR2,
    i_valid_from IN VARCHAR2) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_xch_rat_det.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_repg_currcy_flag currcy.repg_currcy_flag%TYPE;
    v_purch_order_valdtn_status sap_xch_rat_det.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_order_valdtn_status sap_xch_rat_det.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_dlvry_valdtn_status sap_xch_rat_det.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_sales_valdtn_status sap_xch_rat_det.valdtn_status%TYPE := ods_constants.valdtn_valid;

    v_max_purch_order_fact_date VARCHAR2(8);
    v_max_order_fact_date       VARCHAR2(8);
    v_max_dlvry_fact_date       VARCHAR2(8);
    v_max_sales_fact_date       VARCHAR2(8);

    v_count     PLS_INTEGER;
    v_mars_week PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_exchange_rate_hdr IS
      SELECT
        *
      FROM
        sap_xch_rat_det
      WHERE
        sap_xch_rat_det.rate_type     = i_rate_type  AND
        sap_xch_rat_det.from_curr     = i_from_curr  AND
        sap_xch_rat_det.to_currncy    = i_to_currncy AND
        sap_xch_rat_det.valid_from    = i_valid_from AND
        sap_xch_rat_det.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_exchange_rate_hdr csr_exchange_rate_hdr%ROWTYPE;

  BEGIN

    -- Validate the record.
    OPEN csr_exchange_rate_hdr;
    FETCH csr_exchange_rate_hdr INTO rv_exchange_rate_hdr;
    IF csr_exchange_rate_hdr%FOUND THEN

      -- Clear the validation reason tables of this exchange rate
      utils.clear_validation_reason(ods_constants.valdtn_type_exchange_rate,
                                    i_rate_type,
                                    i_from_curr,
                                    i_to_currncy,
                                    i_valid_from,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- If not null, append into the exchange rate type table.
      IF rv_exchange_rate_hdr.rate_type IS NOT NULL THEN
        append.append_exch_rate_type_code(rv_exchange_rate_hdr.rate_type);
      END IF;

      /*****************************************************************/
      /*  The below validation checks whether any re-aggregations are  */
      /*  required due to back-dated exchange rate valid from dates    */
      /*****************************************************************/

      -- First check whether it is the fourth week of the period.
      SELECT MOD(mars_week,10) INTO v_mars_week
      FROM mars_date
      WHERE yyyymmdd_date = TO_CHAR(SYSDATE,'YYYYMMDD');

      -- If it is not the fourth week of the period then continue the validation.
      IF NOT v_mars_week = 4 THEN

        -- Only check exchange rates records of type 'MPPR'.
        IF rv_exchange_rate_hdr.rate_type = ods_constants.exchange_rate_type_mppr THEN

          -- Retreive the reporting currency flag for the currency being validated.
          SELECT repg_currcy_flag INTO v_repg_currcy_flag
          FROM currcy
          WHERE currcy_code = rv_exchange_rate_hdr.from_curr;

          -- If the exchange rate record currency is used by aggregated tables then continue.
          IF v_repg_currcy_flag = 'Y' THEN

            -- Select the maximum creation date in the purchase order fact table.
            SELECT TO_CHAR(MAX(creatn_date),'YYYYMMDD') INTO v_max_purch_order_fact_date
            FROM purch_order_fact;

            -- Select the maximum creation date in the order fact table.
            SELECT TO_CHAR(MAX(creatn_date),'YYYYMMDD') INTO v_max_order_fact_date
            FROM order_fact;

            -- Select the maximum creation date in the delivery fact table.
            SELECT TO_CHAR(MAX(creatn_date),'YYYYMMDD') INTO v_max_dlvry_fact_date
            FROM dlvry_fact;

            -- Select the maximum creation date in the sales fact table.
            SELECT TO_CHAR(MAX(creatn_date),'YYYYMMDD') INTO v_max_sales_fact_date
            FROM sales_fact;

            -- Check whether the 'valid from' date in the exchange rate record is less than
            -- the maximum creation date in each of the aggregated tables.  If so, then the
            -- fact table will need to be aggregated from that point forward.

            -- Check the purchase order fact table.
            IF rv_exchange_rate_hdr.valid_from < v_max_purch_order_fact_date THEN

              BEGIN
                -- Update the sap_sto_po_hdr table.
                UPDATE sap_sto_po_hdr
                SET sap_sto_po_hdr_lupdt = SYSDATE
                WHERE belnr IN (
                  SELECT
                    a.belnr
                  FROM
                    sap_sto_po_hdr a,
                    sap_sto_po_dat b
                  WHERE
                    a.belnr = b.belnr AND
                    b.iddat = ods_constants.purch_order_creation_date AND
                    b.datum > rv_exchange_rate_hdr.valid_from);

                -- Commit the update.
                COMMIT;

                -- Set purchase order fact validation status to 'VALID'.
                v_purch_order_valdtn_status := ods_constants.valdtn_valid;

              EXCEPTION
                WHEN OTHERS THEN
                  -- If an error occurred on the update then set validation status to 'INVALID'.
                  write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 2,
                  'ERROR: Update of sap_sto_po_hdr table failed on Exchange Rate Detail: ' ||
                    i_rate_type || '/' ||
                    i_from_curr || '/' ||
                    i_to_currncy || '/' ||
                    i_valid_from);
                  v_purch_order_valdtn_status := ods_constants.valdtn_invalid;

                  -- Add an entry into the validation reason tables
                  utils.add_validation_reason(ods_constants.valdtn_type_exchange_rate,
                                              'Update of sap_sto_po_hdr table failed on Exchange Rate Detail',
                                              ods_constants.valdtn_severity_critical,
                                              i_rate_type,
                                              i_from_curr,
                                              i_to_currncy,
                                              i_valid_from,
                                              NULL,
                                              NULL,
                                              i_log_level + 1);
              END;

            ELSE
              -- Set purchase order fact validation status to 'VALID'.
              v_purch_order_valdtn_status := ods_constants.valdtn_valid;
            END IF;


            -- Check the order fact table.
            IF rv_exchange_rate_hdr.valid_from < v_max_order_fact_date THEN

              BEGIN
                -- Update the sap_sal_ord_hdr table.
                UPDATE sap_sal_ord_hdr
                SET sap_sal_ord_hdr_lupdt = SYSDATE
                WHERE belnr IN (
                  SELECT
                    a.belnr
                  FROM
                    sap_sal_ord_hdr a,
                    sap_sal_ord_dat b
                  WHERE
                    a.belnr = b.belnr AND
                    b.iddat = ods_constants.sales_order_creation_date AND
                    b.datum > rv_exchange_rate_hdr.valid_from);

                -- Commit the update.
                COMMIT;

                -- Set order fact validation status to 'VALID'.
                v_order_valdtn_status := ods_constants.valdtn_valid;

              EXCEPTION
                WHEN OTHERS THEN
                  -- If an error occurred on the update then set validation status to 'INVALID'.
                  write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 2,
                  'ERROR: Update of sap_sal_ord_hdr table failed on Exchange Rate Detail: ' ||
                    i_rate_type || '/' ||
                    i_from_curr || '/' ||
                    i_to_currncy || '/' ||
                    i_valid_from);
                  v_order_valdtn_status := ods_constants.valdtn_invalid;

                  -- Add an entry into the validation reason tables
                  utils.add_validation_reason(ods_constants.valdtn_type_exchange_rate,
                                              'Update of sap_sal_ord_hdr table failed on Exchange Rate Detail',
                                              ods_constants.valdtn_severity_critical,
                                              i_rate_type,
                                              i_from_curr,
                                              i_to_currncy,
                                              i_valid_from,
                                              NULL,
                                              NULL,
                                              i_log_level + 1);
              END;

            ELSE    -- Set order fact validation status to 'VALID'.
              v_order_valdtn_status := ods_constants.valdtn_valid;
            END IF;


            -- Check the delivery fact table.
            IF rv_exchange_rate_hdr.valid_from < v_max_dlvry_fact_date THEN

              BEGIN
                -- Update the sap_del_hdr table.
                UPDATE sap_del_hdr
                SET sap_del_hdr_lupdt = SYSDATE
                WHERE vbeln IN (
                  SELECT
                    a.vbeln
                  FROM
                    sap_del_hdr a,
                    sap_del_tim b
                  WHERE
                    a.vbeln = b.vbeln AND
                    b.qualf = ods_constants.delivery_document_date AND
                    DECODE(LTRIM(b.isdd,' 0'),NULL,LTRIM(b.ntanf,' 0'),LTRIM(b.isdd,' 0')) > rv_exchange_rate_hdr.valid_from);

                -- Commit the update.
                COMMIT;

                -- Set delivery fact validation status to 'VALID'.
                v_dlvry_valdtn_status := ods_constants.valdtn_valid;

              EXCEPTION
                WHEN OTHERS THEN
                  -- If an error occurred on the update then set validation status to 'INVALID'.
                  write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 2,
                  'ERROR: Update of sap_del_hdr table failed on Exchange Rate Detail: ' ||
                    i_rate_type || '/' ||
                    i_from_curr || '/' ||
                    i_to_currncy || '/' ||
                    i_valid_from);
                  v_dlvry_valdtn_status := ods_constants.valdtn_invalid;

                  -- Add an entry into the validation reason tables
                  utils.add_validation_reason(ods_constants.valdtn_type_exchange_rate,
                                              'Update of sap_del_hdr table failed on Exchange Rate Detail',
                                              ods_constants.valdtn_severity_critical,
                                              i_rate_type,
                                              i_from_curr,
                                              i_to_currncy,
                                              i_valid_from,
                                              NULL,
                                              NULL,
                                              i_log_level + 1);
              END;

            ELSE    -- Set delivery fact validation status to 'VALID'.
              v_dlvry_valdtn_status := ods_constants.valdtn_valid;
            END IF;

            -- Check the sales fact table.
            IF rv_exchange_rate_hdr.valid_from < v_max_sales_fact_date THEN

              BEGIN
                -- Update the sap_inv_sum_hdr table.
                UPDATE
                  sap_inv_sum_hdr
                SET
                  procg_status = ods_constants.inv_sum_loaded,
                  valdtn_status = ods_constants.valdtn_unchecked
                WHERE
                  fkdat > rv_exchange_rate_hdr.valid_from AND
                  procg_status = ods_constants.inv_sum_complete;

                -- Commit the update.
                COMMIT;

                -- Set sales fact validation status to 'VALID'.
                v_sales_valdtn_status := ods_constants.valdtn_valid;

              EXCEPTION
                WHEN OTHERS THEN
                  -- If an error occurred on the update then set validation status to 'INVALID'.
                  write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 2,
                  'ERROR: Update of sap_inv_sum_hdr table failed on Exchange Rate Detail: ' ||
                    i_rate_type || '/' ||
                    i_from_curr || '/' ||
                    i_to_currncy || '/' ||
                    i_valid_from);
                  v_sales_valdtn_status := ods_constants.valdtn_invalid;

                  -- Add an entry into the validation reason tables
                  utils.add_validation_reason(ods_constants.valdtn_type_exchange_rate,
                                              'Update of sap_inv_sum_hdr table failed on Exchange Rate Detail',
                                              ods_constants.valdtn_severity_critical,
                                              i_rate_type,
                                              i_from_curr,
                                              i_to_currncy,
                                              i_valid_from,
                                              NULL,
                                              NULL,
                                              i_log_level + 1);
              END;

            ELSE    -- Set sales fact validation status to 'VALID'.
              v_sales_valdtn_status := ods_constants.valdtn_valid;
            END IF;

            -- Set validation status to 'VALID' if all successfully completed.
            IF v_purch_order_valdtn_status = ods_constants.valdtn_valid AND
              v_order_valdtn_status = ods_constants.valdtn_valid AND
              v_dlvry_valdtn_status = ods_constants.valdtn_valid AND
              v_sales_valdtn_status = ods_constants.valdtn_valid THEN
                v_valdtn_status := ods_constants.valdtn_valid;
            ELSE
              v_valdtn_status := ods_constants.valdtn_invalid;
            END IF;

          ELSE    -- Set the validation status to 'VALID'.
            v_valdtn_status := ods_constants.valdtn_valid;
          END IF;

        ELSE    -- Set the validation status to 'VALID'.
          v_valdtn_status := ods_constants.valdtn_valid;
        END IF;

      ELSE
        -- Set the validation status to 'UNCHECKED'.
        v_valdtn_status := ods_constants.valdtn_unchecked;
      END IF;

      -- Update the validation status to VALID, INVALID or UNCHECKED as is appropriate, and commit the change.
      write_log(ods_constants.data_type_exch_rate_det, 'n/a', i_log_level + 2,
                'Exchange Rate Detail: ' || i_rate_type || '/' ||
                                            i_from_curr || '/' ||
                                            i_to_currncy || '/' ||
                                            i_valid_from);
      UPDATE
        sap_xch_rat_det
      SET
        sap_xch_rat_det.valdtn_status = v_valdtn_status
      WHERE
        CURRENT OF csr_exchange_rate_hdr;

    END IF;
    CLOSE csr_exchange_rate_hdr;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_exchange_rate_detail;

  /*******************************************************************************
    NAME:       CHECK_PURCHASE_ORDERS
    PURPOSE:    This code reads through all purchase order records with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_purchase_orders(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_purchase_order_hdr IS
      SELECT
        belnr
      FROM
        sap_sto_po_hdr
      WHERE
        sap_sto_po_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_purchase_order_hdr csr_purchase_order_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PURCHASE_ORDERS: Started.');

    -- Check to see whether there are any records to be processed.
    check_purchase_order_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_purchase_order_hdr;
    FETCH csr_purchase_order_hdr INTO rv_purchase_order_hdr;
    WHILE csr_purchase_order_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 2, 'Validating Purchase Order: ' || rv_purchase_order_hdr.belnr);
      validate_purchase_order(i_log_level + 2, rv_purchase_order_hdr.belnr);

      -- Commit when required, and recheck which purchase orders need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_purchase_order_hdr INTO rv_purchase_order_hdr;
    END LOOP;
    CLOSE csr_purchase_order_hdr;
    COMMIT;

    write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PURCHASE_ORDERS: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_purch_order, 'n/a', 0, 'ODS_VALIDATION.CHECK_PURCHASE_ORDERS: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_purchase_orders;



  /*******************************************************************************
    NAME:       CHECK_PURCHASE_ORDER_TYPES
    PURPOSE:    This code checks to see is the various type included in the purchase
                order records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_purchase_order_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;


    -- CURSOR
    CURSOR csr_country IS
      SELECT DISTINCT
        A.land1 AS country_code
      FROM
        sap_sto_po_pnr A,
        sap_sto_po_hdr B
      WHERE
        B.valdtn_status = ods_constants.valdtn_unchecked
        AND B.belnr = A.belnr
        AND A.land1 IS NOT NULL
        AND LENGTH(A.land1) > 0
        AND A.land1 NOT IN (SELECT
                              cntry_code
                            FROM
                              cntry)
      UNION
      SELECT DISTINCT
        A.land1 AS country_code
      FROM
        sap_sto_po_itp A,
        sap_sto_po_hdr B
      WHERE
        B.valdtn_status = ods_constants.valdtn_unchecked
        AND B.belnr = A.belnr
        AND A.land1 IS NOT NULL
        AND LENGTH(A.land1) > 0
        AND A.land1 NOT IN (SELECT
                              cntry_code
                            FROM
                              cntry);
    rv_country csr_country%ROWTYPE;


    CURSOR csr_currency IS
      SELECT DISTINCT
        A.curcy AS currency_code
      FROM
        sap_sto_po_hdr A
      WHERE
        A.valdtn_status = ods_constants.valdtn_unchecked
        AND A.curcy IS NOT NULL
        AND LENGTH(A.curcy) > 0
        AND A.curcy NOT IN (SELECT
                              currcy_code
                            FROM
                              currcy)
      UNION
      SELECT DISTINCT
        A.curcy AS currency_code
      FROM
        sap_sto_po_gen A,
        sap_sto_po_hdr B
      WHERE
        B.valdtn_status = ods_constants.valdtn_unchecked
        AND B.belnr = A.belnr
        AND A.curcy IS NOT NULL
        AND LENGTH(A.curcy) > 0
        AND A.curcy NOT IN (SELECT
                              currcy_code
                            FROM
                              currcy);
    rv_currency csr_currency%ROWTYPE;


    CURSOR csr_region IS
      SELECT DISTINCT
        A.regio AS region_code,
        A.land1 AS country_code
      FROM
        sap_sto_po_pnr A,
        sap_sto_po_hdr B
      WHERE
        B.valdtn_status = ods_constants.valdtn_unchecked
        AND B.belnr = A.belnr
        AND A.regio IS NOT NULL
        AND LENGTH(A.regio) > 0
        AND A.land1 IS NOT NULL
        AND LENGTH(A.land1) > 0
      UNION
      SELECT DISTINCT
        A.regio AS region_code,
        A.land1 AS country_code
      FROM
        sap_sto_po_itp A,
        sap_sto_po_hdr B
      WHERE
        B.valdtn_status = ods_constants.valdtn_unchecked
        AND B.belnr = A.belnr
        AND A.regio IS NOT NULL
        AND LENGTH(A.regio) > 0
        AND A.land1 IS NOT NULL
        AND LENGTH(A.land1) > 0;
    rv_region csr_region%ROWTYPE;


    CURSOR csr_purch_order_type IS
      SELECT DISTINCT
        A.bsart AS purch_order_type_code
      FROM
        sap_sto_po_hdr A
      WHERE
        A.valdtn_status = ods_constants.valdtn_unchecked
        AND A.bsart IS NOT NULL
        AND LENGTH(A.bsart) > 0
        AND A.bsart NOT IN (SELECT
                              purch_order_type_code
                            FROM
                              purch_order_type)
      UNION
      SELECT DISTINCT
        A.orgid AS purch_order_type_code
      FROM
        sap_sto_po_org A,
        sap_sto_po_hdr B
      WHERE
        B.valdtn_status = ods_constants.valdtn_unchecked
        AND B.belnr = A.belnr
        AND A.qualf = ods_constants.purch_order_purch_order_type
        AND A.orgid IS NOT NULL
        AND LENGTH(A.orgid) > 0
        AND A.orgid NOT IN (SELECT
                              purch_order_type_code
                            FROM
                              purch_order_type);
    rv_purch_order_type csr_purch_order_type%ROWTYPE;


  BEGIN
    -- Adding countries
    OPEN csr_country;
    LOOP
      FETCH csr_country INTO rv_country;
      EXIT WHEN csr_country%NOTFOUND;

      write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Inserting Country: ' || rv_country.country_code || ' found in the purchase order into the Country table.');

      append.append_cntry_code(rv_country.country_code);

    END LOOP;
    CLOSE csr_country;


    -- Adding currency
    OPEN csr_currency;
    LOOP
      FETCH csr_currency INTO rv_currency;
      EXIT WHEN csr_currency%NOTFOUND;

      write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Inserting Currency: ' || rv_currency.currency_code || ' found in the purchase order into the Currency table.');

      append.append_currcy_code(rv_currency.currency_code);

    END LOOP;
    CLOSE csr_currency;


    -- Adding region
    OPEN csr_region;
    LOOP
      FETCH csr_region INTO rv_region;
      EXIT WHEN csr_region%NOTFOUND;

      write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Inserting Region Code/Country Code: ' || rv_region.region_code || '/' || rv_region.country_code || ' found in the purchase order into the region table.');

      append.append_region_code(rv_region.region_code, rv_region.country_code);

    END LOOP;
    CLOSE csr_region;


    -- Adding Purchase Order Type
    OPEN csr_purch_order_type;
    LOOP
      FETCH csr_purch_order_type INTO rv_purch_order_type;
      EXIT WHEN csr_purch_order_type%NOTFOUND;

      write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Inserting Purchase Order Type: ' || rv_purch_order_type.purch_order_type_code || ' found in the purchase order into the Purchase Order Type table.');

      append.append_purch_order_type_code(rv_purch_order_type.purch_order_type_code);

    END LOOP;
    CLOSE csr_purch_order_type;
  END check_purchase_order_types;



  /*******************************************************************************
    NAME:       VALIDATE_PURCHASE_ORDER
    PURPOSE:    This code validates a purchase order record, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_purchase_order(
    i_log_level    IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_sto_po_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_purchase_order_hdr IS
      SELECT
        belnr,
        bsart
      FROM
        sap_sto_po_hdr
      WHERE
        sap_sto_po_hdr.belnr = i_document_nbr AND
        sap_sto_po_hdr.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_purchase_order_hdr csr_purchase_order_hdr%ROWTYPE;

    /*
      Check whether the Partner Reference column is populated. If so, then
      this indicates that the Purchase Order was created to request Materials
      from a Non-Atlas Vendor. In the case, the Validation Status is changed
      to 'EXCLUDED' as this should not be recorded as a sale transaction.
      The value in the Partner Reference column references the Invoice Number
      created in the Vendors system.
      */
      CURSOR csr_partner_ref_check IS
      SELECT /*+ INDEX(a SAP_STO_PO_PNR_PK) */
        a.ihrez -- Partner Reference
      FROM
        sap_sto_po_pnr a
      WHERE
        a.belnr = i_document_nbr
        AND a.parvw = ods_constants.purch_order_vendor;
    rv_partner_ref_check csr_partner_ref_check%ROWTYPE;

    -- Check whether a delivery exists for the purchase order.
    CURSOR csr_delivery IS
      SELECT DISTINCT /*+ INDEX(t01 SAP_DEL_IRF_PK) */
        vbeln
      FROM
        sap_del_irf
      WHERE
        qualf = ods_constants.delivery_purch_order_flag
        AND belnr = i_document_nbr;
    rv_delivery csr_delivery%ROWTYPE;

    -- Check whether an invoice exists for the purchase order.
    CURSOR csr_invoice IS
      SELECT DISTINCT /*+ INDEX(t01 SAP_INV_IRF_PK) */
        t01.belnr
      FROM
        sap_inv_irf t01
      WHERE
        t01.qualf = ods_constants.invoice_purch_order_flag
        AND t01.refnr = i_document_nbr;
    rv_invoice csr_invoice%ROWTYPE;

    -- Check whether the Purchase Order has been DELETED in Atlas.
    CURSOR csr_deleted_po IS
      SELECT DISTINCT /*+ INDEX(a SAP_STO_PO_PNR_PK) */
        UPPER(a.ihrez) AS ihrez -- Your reference (Partner)
      FROM
        sap_sto_po_pnr a
      WHERE
        a.belnr = i_document_nbr
        AND a.parvw = ods_constants.purch_order_sold_to_partner;
    rv_deleted_po csr_deleted_po%ROWTYPE;


  BEGIN

    -- Validate the purchase order header record.
    OPEN csr_purchase_order_hdr;
    FETCH csr_purchase_order_hdr INTO rv_purchase_order_hdr;
    IF csr_purchase_order_hdr%FOUND THEN

      -- Clear the validation reason tables of this purchase order
      utils.clear_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Purchase Order Type must exist and be valid.
      v_count := 0;
      SELECT
        count(*)
      INTO
        v_count
      FROM
        sap_sto_po_org a,
        purch_order_type b
      WHERE
        a.belnr = rv_purchase_order_hdr.belnr AND
        a.qualf = ods_constants.purch_order_purch_order_type AND
        a.orgid = b.purch_order_type_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Invalid or non-existant Purchase Order Type.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Invalid or non-existant Purchase Order Type.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Purchase Order Purchasing Company must exist.
      v_count := 0;
      SELECT
        count(*)
      INTO
        v_count
      FROM
        sap_sto_po_org a
      WHERE
        a.belnr = rv_purchase_order_hdr.belnr AND
        a.qualf = ods_constants.purch_order_purchasing_company AND
        a.orgid IS NOT NULL;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Purchasing Company is blank or does not exist.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Purchasing Company is blank or does not exist.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Document Currency must exist and be valid.
      v_count := 0;
      SELECT
        count(*)
      INTO
        v_count
      FROM
        sap_sto_po_hdr a,
        currcy b
      WHERE
        a.belnr = rv_purchase_order_hdr.belnr AND
        a.curcy = b.currcy_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Invalid or non-existant Currency.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Invalid or non-existant Currency.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Document Exchange Rate must exist.
      v_count := 0;
      SELECT
        count(*)
      INTO
        v_count
      FROM
        sap_sto_po_hdr a
      WHERE
        a.belnr = rv_purchase_order_hdr.belnr AND
        a.wkurs IS NOT NULL;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Exchange Rate is blank.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Exchange Rate is blank.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Purchase Order Vendor must exist.
      v_count := 0;
      SELECT
        count(*)
      INTO
        v_count
      FROM
        sap_sto_po_pnr a,
        sap_cus_hdr b
      WHERE
        a.belnr = rv_purchase_order_hdr.belnr AND
        a.parvw = ods_constants.purch_order_vendor AND
        a.partn = b.lifnr;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Non-existant Vendor.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Non-existant Vendor.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Purchase Order Creation Date must exist and be valid.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*)
        INTO
          v_count
        FROM
          sap_sto_po_dat a,
          mars_date  b
        WHERE
          a.belnr = rv_purchase_order_hdr.belnr AND
          a.iddat = ods_constants.purch_order_creation_date AND
          b.yyyymmdd_date = to_number(a.datum);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF v_count <> 1 THEN                    -- There should be 1 valid date!
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Invalid, duplicate or non-existant Creation Date.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Invalid, duplicate or non-existant Creation Date.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Purchase Order Effective Date must exist and be valid.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*)
        INTO
          v_count
        FROM
          sap_sto_po_dat a,
          mars_date  b
        WHERE
          a.belnr = rv_purchase_order_hdr.belnr AND
          a.iddat = ods_constants.purch_order_effective_date AND
          b.yyyymmdd_date = to_number(a.datum);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF v_count <> 1 THEN                    -- There should be 1 valid date!
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Invalid, duplicate or non-existant Effective Date.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Invalid, duplicate or non-existant Effective Date.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Any material line associated with the Purchase Order (of type Inter-Company Business) must have a non-null material code.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*)
        INTO
          v_count
        FROM
          sap_sto_po_oid a,
          sap_sto_po_org b
        WHERE
          a.belnr = rv_purchase_order_hdr.belnr AND
          a.belnr = b.belnr AND
          a.qualf = ods_constants.purch_order_material_code AND
          b.qualf = ods_constants.purch_order_purch_order_type AND
          b.orgid = ods_constants.purch_order_icb_purch_order AND
          a.idtnr IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF v_count > 0 THEN                    -- There should not be any null material codes.
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Has null material code(s) (sap_sto_po_oid).');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Has null material code(s) (sap_sto_po_oid).',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Any material line associated with the Purchase Order (of type Inter-Company Business) must have a validation status equal to valid.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*)
        INTO
          v_count
        FROM
          sap_sto_po_oid a,
          sap_sto_po_org b,
          sap_mat_hdr    c
        WHERE
          a.belnr = rv_purchase_order_hdr.belnr AND
          a.belnr = b.belnr AND
          a.qualf = ods_constants.purch_order_material_code AND
          b.qualf = ods_constants.purch_order_purch_order_type AND
          b.orgid = ods_constants.purch_order_icb_purch_order AND
          a.idtnr = c.matnr AND
          c.valdtn_status <> ods_constants.valdtn_valid;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF v_count > 0 THEN                    -- There should not be any material codes not marked as valid.
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Has material code(s) that are not marked as valid.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                    'Has material code(s) that are not marked as valid.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Perform the following validations if Purchase Order is of type Inter-Company Business.
      IF rv_purchase_order_hdr.bsart = ods_constants.purch_order_icb_purch_order THEN

        -- Account Assignment Group must exist for Inter-Company Business Purchase Orders.
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          sap_sto_po_org a,
          sap_sto_po_pnr b,
          sap_cus_hdr c,
          sap_cus_sad d
        WHERE a.belnr = rv_purchase_order_hdr.belnr AND
          a.qualf = ods_constants.purch_order_purch_order_type AND
          a.orgid = ods_constants.purch_order_icb_purch_order AND
          a.belnr = b.belnr AND
          b.parvw = ods_constants.purch_order_vendor AND
          b.partn = c.lifnr AND
          c.kunnr = d.kunnr AND
          d.ktgrd = ods_constants.purch_order_acct_assgnmnt_grp;
        IF v_count = 0 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Non-existant Account Assignment Group for ICB Purchase Order.');

          -- Add an entry into the validation reason tables
          utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                      'Non-existant Account Assignment Group for ICB Purchase Order.',
                                      ods_constants.valdtn_severity_critical,
                                      i_document_nbr,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
        END IF;

        -- Company must exist and be valid for Inter-Company Business Purchase Orders.
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          sap_sto_po_org a,
          sap_sto_po_pnr b,
          sap_cus_hdr c,
          sap_cus_sad d,
          company e
        WHERE a.belnr = rv_purchase_order_hdr.belnr AND
          a.qualf = ods_constants.purch_order_purch_order_type AND
          a.orgid = ods_constants.purch_order_icb_purch_order AND
          a.belnr = b.belnr AND
          b.parvw = ods_constants.purch_order_vendor AND
          b.partn = c.lifnr AND
          c.kunnr = d.kunnr AND
          d.ktgrd = ods_constants.purch_order_acct_assgnmnt_grp AND
          d.vkorg = e.company_code;
        IF v_count = 0 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || rv_purchase_order_hdr.belnr || ': Invalid or non-existant Company for ICB Purchase Order.');

          -- Add an entry into the validation reason tables
          utils.add_validation_reason(ods_constants.valdtn_type_purchase_order,
                                      'Invalid or non-existant Company for ICB Purchase Order.',
                                      ods_constants.valdtn_severity_critical,
                                      i_document_nbr,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
        END IF;

      END IF;

      -- Check whether the Partner Reference column is populated. If so, then update
      -- validation status to EXCLUDED.
      OPEN csr_partner_ref_check;
      FETCH csr_partner_ref_check INTO rv_partner_ref_check;
      CLOSE csr_partner_ref_check;

      IF rv_partner_ref_check.ihrez IS NOT NULL THEN
        v_valdtn_status := ods_constants.valdtn_excluded;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || i_document_nbr || ': Partner Reference column is popluated.');
      END IF;


      -- Check whether the reference column is populated with the deleted flag. If so,
      -- then update validation status to DELETED.
      OPEN csr_deleted_po;
      FETCH csr_deleted_po INTO rv_deleted_po;
      CLOSE csr_deleted_po;

      IF rv_deleted_po.ihrez = ods_constants.purch_order_deleted_flag THEN
        v_valdtn_status := ods_constants.valdtn_deleted;
        write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 1, 'Purchase Order: ' || i_document_nbr || ': has been flagged to ' || ods_constants.purch_order_deleted_flag || ' and thus its status will be set to deleted.');
      END IF;

      -- Update the validation status to VALID, INVALID or EXCLUDED as is appropriate, and commit the change.
      write_log(ods_constants.data_type_purch_order, 'n/a', i_log_level + 2, 'Purchase Order: ' || i_document_nbr || ' is ' || v_valdtn_status);
      UPDATE sap_sto_po_hdr
      SET
        sap_sto_po_hdr.valdtn_status = v_valdtn_status
      WHERE
        CURRENT OF csr_purchase_order_hdr;

    END IF;
    CLOSE csr_purchase_order_hdr;

    -- Update the valdtn_status column to 'UNCHECKED' in the sap_del_hdr table.
    FOR rv_delivery IN csr_delivery LOOP

      -- Now update the sap_del_hdr table.
      UPDATE sap_del_hdr
        SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE vbeln = rv_delivery.vbeln;

      -- Commit.
      COMMIT;

    END LOOP;

    -- Update the valdtn_status column to 'UNCHECKED' in the sap_inv_hdr table.
    FOR rv_invoice IN csr_invoice LOOP

      -- Now update the sap_inv_hdr table.
      UPDATE sap_inv_hdr
        SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE belnr = rv_invoice.belnr;

      -- Commit.
      COMMIT;

    END LOOP;


   EXCEPTION

      -- Ignore records locked by competing ODS_VALIDATION jobs.
      WHEN resource_busy THEN
         ROLLBACK;

      -- Raise alert
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20000,'VALIDATE_PURCHASE_ORDER - ' || substr(SQLERRM, 1, 1024));

  END validate_purchase_order;

  /*******************************************************************************
    NAME:       CHECK_SALES_ORDERS
    PURPOSE:    This code reads through all sales order records with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_sales_orders(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_sales_order_hdr IS
      SELECT /*+ INDEX(SAP_SAL_ORD_HDR SAP_SAL_ORD_HDR_I2) */
        belnr
      FROM
        sap_sal_ord_hdr
      WHERE
        sap_sal_ord_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_order_hdr csr_sales_order_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_SALES_ORDERS: Started.');

    -- Check the various types in the sales order
    check_sales_order_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_sales_order_hdr;
    FETCH csr_sales_order_hdr INTO rv_sales_order_hdr;
    WHILE csr_sales_order_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 2, 'Validating Sales Order: ' || rv_sales_order_hdr.belnr);
      validate_sales_order(i_log_level + 2, rv_sales_order_hdr.belnr);

      -- Commit when required, and recheck which sales orders need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_sales_order_hdr INTO rv_sales_order_hdr;
    END LOOP;
    CLOSE csr_sales_order_hdr;
    COMMIT;

    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_SALES_ORDERS: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_sales_order, 'n/a', 0, 'ODS_VALIDATION.CHECK_SALES_ORDERS: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;
  END check_sales_orders;



  /*******************************************************************************
    NAME:       CHECK_SALES_ORDER_TYPES
    PURPOSE:    This code checks to see is the various type included in the sales
                order records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_sales_order_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- CURSORS
    CURSOR csr_country IS
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_SAL_ORD_HDR_I2) INDEX(b SAP_SAL_ORD_PNR_PK) */
        DISTINCT b.land1 AS cntry_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_pnr b,
        cntry c
      WHERE
        b.belnr = a.belnr
        AND a.valdtn_status = ods_constants.valdtn_unchecked
        AND b.land1 = c.cntry_code(+)
        AND b.land1 IS NOT NULL
        AND c.cntry_code IS NULL
      UNION
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_SAL_ORD_HDR_I2) INDEX(b SAP_SAL_ORD_IPN_PK) */
        DISTINCT b.land1 AS cntry_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_ipn b,
        cntry c
      WHERE
        b.belnr = a.belnr
        AND a.valdtn_status = ods_constants.valdtn_unchecked
        AND b.land1 =  c.cntry_code(+)
        AND b.land1 IS NOT NULL
        AND c.cntry_code IS NULL;
    rv_country csr_country%ROWTYPE;


    CURSOR csr_currency IS
      SELECT /*+ ORDERED USE_NL(b) INDEX(A SAP_SAL_ORD_HDR_I2) */
        DISTINCT A.curcy AS currcy_code
      FROM
        sap_sal_ord_hdr a,
        currcy b
      WHERE
        A.valdtn_status = ods_constants.valdtn_unchecked
        AND b.currcy_code(+) = a.curcy
        AND a.curcy IS NOT NULL
        AND b.currcy_code IS NULL
      UNION
      SELECT /*+ ORDERED USE_NL(b) INDEX(A SAP_SAL_ORD_HDR_I2) INDEX(B SAP_SAL_ORD_GEN_PK) */
        DISTINCT b.curcy AS currcy_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_gen b,
        currcy c
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND b.belnr = a.belnr
        AND b.curcy = c.currcy_code(+)
        AND b.curcy IS NOT NULL
        AND c.currcy_code IS NULL;
    rv_currency csr_currency%ROWTYPE;


    CURSOR csr_invoice_type IS
      SELECT /*+ INDEX(A SAP_SAL_ORD_HDR_I2) */ DISTINCT
        A.fkart_rl AS invc_type_code
      FROM
        sap_sal_ord_hdr A
      WHERE
        A.valdtn_status = ods_constants.valdtn_unchecked
        AND A.fkart_rl NOT IN (SELECT invc_type_code FROM invc_type)
        AND LENGTH(A.fkart_rl) > 0
        AND A.fkart_rl IS NOT NULL;
    rv_invoice_type csr_invoice_type%ROWTYPE;


    CURSOR csr_order_type IS
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_SAL_ORD_HDR_I2) INDEX(b SAP_SAL_ORD_ORG_PK) */
        DISTINCT b.orgid AS order_type_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_org b,
        order_type c
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND b.belnr = a.belnr
        AND b.qualf = ods_constants.sales_order_order_type
        AND b.orgid = c.order_type_code(+)
        AND b.orgid IS NOT NULL
        AND c.order_type_code IS NULL;
    rv_order_type csr_order_type%ROWTYPE;


    CURSOR csr_order_reason IS
      SELECT /*+ ORDERED INDEX(A SAP_SAL_ORD_HDR_I2) */ DISTINCT
        A.augru AS order_reasn_code
      FROM
        sap_sal_ord_hdr A
      WHERE
        A.valdtn_status = ods_constants.valdtn_unchecked
        AND LENGTH(A.augru) > 0
        AND A.augru IS NOT NULL
        AND A.augru NOT IN (SELECT order_reasn_code FROM order_reasn);
    rv_order_reason csr_order_reason%ROWTYPE;


    CURSOR csr_order_usage IS
      SELECT /*+ INDEX(a SAP_SAL_ORD_HDR_I2) */
        DISTINCT a.abrvw AS order_usage_code
      FROM
        sap_sal_ord_hdr a,
        order_usage b
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND a.abrvw = b.order_usage_code(+)
        AND A.abrvw IS NOT NULL
        AND b.order_usage_code IS NULL
      UNION
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_SAL_ORD_HDR_I2) INDEX(b SAP_SAL_ORD_GEN_PK) */
        DISTINCT b.abrvw AS order_usage_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_gen b,
        order_usage c
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND a.belnr = b.belnr
        AND b.abrvw = c.order_usage_code(+)
        AND b.abrvw IS NOT NULL
        AND c.order_usage_code IS NULL;
    rv_order_usage csr_order_usage%ROWTYPE;


  BEGIN
    -- Adding countries
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Countries.');
    OPEN csr_country;
    LOOP
      FETCH csr_country INTO rv_country;
      EXIT WHEN csr_country%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Country: ' || rv_country.cntry_code || ' found in the order into the Country table.');

      append.append_cntry_code(rv_country.cntry_code);

    END LOOP;
    CLOSE csr_country;


    -- Adding currency
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Currencies.');
    OPEN csr_currency;
    LOOP
      FETCH csr_currency INTO rv_currency;
      EXIT WHEN csr_currency%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Currency: ' || rv_currency.currcy_code || ' found in the order into the Currency table.');

      append.append_currcy_code(rv_currency.currcy_code);

    END LOOP;
    CLOSE csr_currency;


    -- Adding invoice_type
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Invoice Types.');
    OPEN csr_invoice_type;
    LOOP
      FETCH csr_invoice_type INTO rv_invoice_type;
      EXIT WHEN csr_invoice_type%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Invoice Type: ' || rv_invoice_type.invc_type_code || ' found in the order into the Invoice Type table.');

      append.append_invc_type_code(rv_invoice_type.invc_type_code);

    END LOOP;
    CLOSE csr_invoice_type;


    -- Adding order_type
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Order Types.');
    OPEN csr_order_type;
    LOOP
      FETCH csr_order_type INTO rv_order_type;
      EXIT WHEN csr_order_type%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Order Type: ' || rv_order_type.order_type_code || ' found in the order into the Order Type table.');

      append.append_order_type_code(rv_order_type.order_type_code);

    END LOOP;
    CLOSE csr_order_type;


    -- Adding order_reason
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Order Reasons.');
    OPEN csr_order_reason;
    LOOP
      FETCH csr_order_reason INTO rv_order_reason;
      EXIT WHEN csr_order_reason%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Order Reason: ' || rv_order_reason.order_reasn_code || ' found in the order into the Order Reason table.');

      append.append_order_reasn_code(rv_order_reason.order_reasn_code);

    END LOOP;
    CLOSE csr_order_reason;


    -- Adding order_usage
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Order Usages.');
    OPEN csr_order_usage;
    LOOP
      FETCH csr_order_usage INTO rv_order_usage;
      EXIT WHEN csr_order_usage%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Order Usage: ' || rv_order_usage.order_usage_code || ' found in the order into the Order Usage table.');

      append.append_order_usage_code(rv_order_usage.order_usage_code);

    END LOOP;
    CLOSE csr_order_usage;


  END check_sales_order_types;


  /***********************************************************
     NAME    : VALIDATE_SALES_ORDER
     PURPOSE : Executes validation for sales order (BELNR)
               specified - updating status accordingly
   ************************************************************/
  PROCEDURE validate_sales_order(
    i_log_level IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_sal_ord_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count PLS_INTEGER;
    var_rejected BOOLEAN;
    var_open BOOLEAN;

    -- CURSOR DECLARATIONS
    CURSOR csr_sales_order_hdr IS
      SELECT
        *
      FROM
        sap_sal_ord_hdr
      WHERE
        sap_sal_ord_hdr.belnr = i_document_nbr AND
        sap_sal_ord_hdr.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_sales_order_hdr csr_sales_order_hdr%ROWTYPE;

    -- Check whether a delivery exists for the sales order.
    CURSOR csr_delivery IS
      SELECT DISTINCT
        a.vbeln
      FROM
        sap_del_hdr a,
        sap_del_irf b
      WHERE
        a.vbeln = b.vbeln
        AND b.qualf IN (ods_constants.delivery_sales_order_flag,
                        ods_constants.delivery_return_flag,
                        ods_constants.delivery_order_wo_charge_flag,
                        ods_constants.delivery_cr_memo_flag,
                        ods_constants.delivery_db_memo_flag)
        AND NOT(b.datum IS NULL)
        AND a.valdtn_status <> ods_constants.valdtn_deleted
        AND b.belnr = i_document_nbr;
    rv_delivery csr_delivery%ROWTYPE;

    -- Check whether a invoice exists for the sales order.
    CURSOR csr_invoice IS
       SELECT DISTINCT
         belnr
       FROM
         sap_inv_ref
       WHERE
         qualf = ods_constants.invoice_sales_order_flag
         AND refnr = i_document_nbr;
    rv_invoice csr_invoice%ROWTYPE;

    CURSOR csr_sap_sal_ord_gen_01 IS
      SELECT
        t01.belnr,
        t01.posex,
        t01.abgru,
        t01.menge,
        t01.menee
      FROM
        sap_sal_ord_gen t01
      WHERE
        t01.belnr = rv_sales_order_hdr.belnr;
    rcd_sap_sal_ord_gen_01 csr_sap_sal_ord_gen_01%ROWTYPE;

    CURSOR csr_sap_del_irf_01 IS
      SELECT
        t01.vbeln
      FROM
        sap_del_irf t01,
        sap_del_hdr t02
      WHERE
        t01.vbeln = t02.vbeln(+)
        AND t01.belnr = rcd_sap_sal_ord_gen_01.belnr
        AND t01.posnr = rcd_sap_sal_ord_gen_01.posex
        AND t01.qualf IN (ods_constants.delivery_sales_order_flag,
                          ods_constants.delivery_return_flag,
                          ods_constants.delivery_order_wo_charge_flag,
                          ods_constants.delivery_cr_memo_flag,
                          ods_constants.delivery_db_memo_flag)
        AND NOT(t01.datum IS NULL)
        AND t02.valdtn_status <> ods_constants.valdtn_deleted;
    rcd_sap_del_irf_01 csr_sap_del_irf_01%ROWTYPE;

    cursor csr_region is
       select region,
              cntry
       from (select a.regio as region,
                    a.land1 as cntry
             from sap_sal_ord_pnr a
             where a.belnr = i_document_nbr
               and a.regio is not null
               and a.land1 is not null
             union all
             select a.regio as region,
                    a.land1 as cntry
             from sap_sal_ord_ipn a
             where a.belnr = i_document_nbr
               and a.regio is not null
               and a.land1 is not null)
       group by region, cntry;
    rv_region csr_region%rowtype;


  BEGIN


    -- Adding region
    write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Checking for new Regions.');
    OPEN csr_region;
    LOOP
      FETCH csr_region INTO rv_region;
      EXIT WHEN csr_region%NOTFOUND;

      write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Inserting Region Code/Country Code: ' || rv_region.region || '/' || rv_region.cntry || ' found in the order into the region table.');

      append.append_region_code(rv_region.region, rv_region.cntry);

    END LOOP;
    CLOSE csr_region;

    -- Validate the sales order header record.
    OPEN csr_sales_order_hdr;
    FETCH csr_sales_order_hdr INTO rv_sales_order_hdr;
    IF csr_sales_order_hdr%FOUND THEN
       ---------------------------------------
       -- Sales Order and Delivery Deletion --
       ---------------------------------------
       -- 1. Rejected sales order lines flag related deliveries as deleted
       -- 2. Sales orders with no open lines are flagged as deleted


       -- Retrieve the sales order lines
       var_open := FALSE;
       OPEN csr_sap_sal_ord_gen_01;
       LOOP
          FETCH csr_sap_sal_ord_gen_01 INTO rcd_sap_sal_ord_gen_01;
          IF csr_sap_sal_ord_gen_01%NOTFOUND THEN
             EXIT;
          END IF;


          -- Rejected sales order line (reason code is not null)
          IF (NOT(rcd_sap_sal_ord_gen_01.abgru IS NULL) AND rcd_sap_sal_ord_gen_01.abgru != 'ZA') OR
             ((rcd_sap_sal_ord_gen_01.abgru IS NULL OR rcd_sap_sal_ord_gen_01.abgru = 'ZA')  AND rcd_sap_sal_ord_gen_01.menge IS NULL AND rcd_sap_sal_ord_gen_01.menee IS NULL) THEN


             -- Retrieve any related delivery detail internal reference data
             -- ** note ** the relationship is based on sales order and sales order line
             OPEN csr_sap_del_irf_01;
             LOOP
                FETCH csr_sap_del_irf_01 INTO rcd_sap_del_irf_01;
                IF csr_sap_del_irf_01%NOTFOUND THEN
                   EXIT;
                END IF;


                -- Update the related delivery status (deleted)
                -- ** notes **
                -- 1. Any one delivery line will cause the deletion of the whole delivery
                UPDATE sap_del_hdr SET valdtn_status = ods_constants.valdtn_deleted
                WHERE vbeln = rcd_sap_del_irf_01.vbeln;

             END LOOP;
             CLOSE csr_sap_del_irf_01;


          -- Open sales order line
          ELSE
             var_open := TRUE;
          END IF;

       END LOOP;
       CLOSE csr_sap_sal_ord_gen_01;


       -- Set the sales order status to deleted when no open lines
       IF var_open = FALSE THEN
          UPDATE sap_sal_ord_hdr SET valdtn_status = ods_constants.valdtn_deleted
           WHERE belnr = rv_sales_order_hdr.belnr;
       END IF;



       -- Clear the validation reason tables of this sales order
       utils.clear_validation_reason(ods_constants.valdtn_type_sales_order,
                                     i_document_nbr,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);



       -- If the Sales Order was flagged as deleted, do not validate further
       IF (var_open = TRUE) THEN

         -- Sales Order Sales Organisation must be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           sap_sal_ord_org a,
           company b
         WHERE
           a.belnr = rv_sales_order_hdr.belnr AND
           a.qualf = ods_constants.sales_order_sales_org AND
           a.orgid = b.company_code;
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Invalid or non-existant Sales Organisation.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Invalid or non-existant Sales Organisation.',
                                       ods_constants.valdtn_severity_critical,
                                       i_document_nbr,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
         END IF;

         -- Document Currency must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           sap_sal_ord_hdr a,
           currcy b
         WHERE
           a.belnr = rv_sales_order_hdr.belnr AND
           a.curcy = b.currcy_code;
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Invalid or non-existant Currency.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Invalid or non-existant Currency.',
                                       ods_constants.valdtn_severity_critical,
                                       i_document_nbr,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
         END IF;

         -- Document Exchange Rate must exist.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           sap_sal_ord_hdr a
         WHERE
           a.belnr = rv_sales_order_hdr.belnr AND
           a.wkurs IS NOT NULL;
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Exchange Rate is blank.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Exchange Rate is blank.',
                                       ods_constants.valdtn_severity_critical,
                                       i_document_nbr,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
         END IF;

         -- Sales Order Creation Date must exist and be valid.
         v_count := 0;
         BEGIN
           SELECT
           COUNT(*) INTO v_count
         FROM
           sap_sal_ord_dat a,
           mars_date  b
         WHERE
           a.belnr = rv_sales_order_hdr.belnr AND
           a.iddat = ods_constants.sales_order_creation_date AND
           b.yyyymmdd_date = to_number(a.datum);
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
         END;
         IF v_count <> 1 THEN                    -- There should be 1 valid date!
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Invalid, duplicate or non-existant Creation Date.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Invalid, duplicate or non-existant Creation Date.',
                                       ods_constants.valdtn_severity_critical,
                                       i_document_nbr,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
         END IF;

         -- Sales Order Billing Date must exist and be valid.
         v_count := 0;
         BEGIN
           SELECT
             COUNT(*) INTO v_count
           FROM
             sap_sal_ord_dat a,
             mars_date  b
           WHERE
             a.belnr = rv_sales_order_hdr.belnr AND
             a.iddat = ods_constants.sales_order_billing_date AND
             b.yyyymmdd_date = to_number(a.datum);
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
         END;
         IF v_count <> 1 THEN                    -- There should be 1 valid date!
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Invalid, duplicate or non-existant Billing Date.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                      'Invalid, duplicate or non-existant Billing Date.',
                                      ods_constants.valdtn_severity_critical,
                                      i_document_nbr,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
         END IF;

         -- Order Type must not have a status of UNCLASSIFIED.
         v_count := 0;
         SELECT
           COUNT(*) INTO v_count
         FROM
           sap_sal_ord_org a,
           order_type b
         WHERE
           a.belnr = i_document_nbr
           AND a.qualf = ods_constants.sales_order_order_type
           AND a.orgid = b.order_type_code
           AND b.order_type_gsv_flag = ods_constants.gsv_flag_unclassified;

         -- If so, then the Sales Order is invalid.
         IF v_count > 0 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': associated Order Type is unclassified.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Sales Order references UNCLASSIFIED Order Type record; classify Order Type.',
                                       ods_constants.valdtn_severity_critical,
                                       i_document_nbr,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                      i_log_level + 1);
          END IF;

          -- Any material line associated with the Sales Order must have a non-null material code, WHERE
          -- the entire material line has not been cleared in SAP. We determine this by only triggering
          -- and error if the quantity on the GEN record is NOT NULL.
          v_count := 0;
          BEGIN
            SELECT
              COUNT(*) INTO v_count
            FROM
              sap_sal_ord_iid a,
              sap_sal_ord_gen b
            WHERE
              a.belnr = rv_sales_order_hdr.belnr AND
              a.qualf = ods_constants.sales_order_material_code AND
              b.genseq = a.genseq AND
              b.belnr = a.belnr AND
              a.idtnr IS NULL AND
              b.menge IS NOT NULL;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          IF v_count > 0 THEN                    -- There should not be any null material codes.
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Has null material code(s) (sap_sal_ord_iid).');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Has null material code(s) (sap_sal_ord_iid).',
                                        ods_constants.valdtn_severity_critical,
                                        i_document_nbr,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;

          -- Any material line associated with the Sales Order must have a material code
          -- with a validation status of valid.
          v_count := 0;
          BEGIN
            SELECT
              COUNT(*) INTO v_count
            FROM
              sap_sal_ord_iid a,
              sap_mat_hdr     b
            WHERE
              a.belnr         = rv_sales_order_hdr.belnr AND
              a.qualf         = ods_constants.sales_order_material_code AND
              a.idtnr         = b.matnr AND
              b.valdtn_status <> ods_constants.valdtn_valid;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          IF v_count > 0 THEN                    -- There should not be any material codes that have a status <> valid.
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 1, 'Sales Order: ' || rv_sales_order_hdr.belnr || ': Has material code(s) that have a validation status not equal to VALID.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_sales_order,
                                       'Has material code(s) that have a validation status not equal to VALID.',
                                        ods_constants.valdtn_severity_critical,
                                        i_document_nbr,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;

          -- Update the validation status to VALID or INVALID as is appropriate
          write_log(ods_constants.data_type_sales_order, 'n/a', i_log_level + 2, 'Sales Order: ' || i_document_nbr || ' is ' || v_valdtn_status);
          UPDATE sap_sal_ord_hdr
          SET
            sap_sal_ord_hdr.valdtn_status = v_valdtn_status
          WHERE
            CURRENT OF csr_sales_order_hdr;

       END IF;  -- For var_open = true statement

       /*-*/
       /* Update the valdtn_status column to 'UNCHECKED' in the related
       /* sap_del_hdr and sap_inv_hdr tables.
       /*
       /*   note : this is in place to ensure that resends of Sales Orders are
       /*          correctly reflected in subsequent documents.
       /*
       /*          It is possible that deliveries will be flagged as
       /*          deleted in the next step of processing below.
       /*-*/
       FOR rv_delivery IN csr_delivery LOOP
         UPDATE sap_del_hdr
         SET
           valdtn_status = ods_constants.valdtn_unchecked
         WHERE
           vbeln = rv_delivery.vbeln;
       END LOOP;

       FOR rv_invoice IN csr_invoice LOOP
         UPDATE sap_inv_hdr
         SET
           valdtn_status = ods_constants.valdtn_unchecked
         WHERE
           belnr = rv_invoice.belnr;
       END LOOP;

   END IF;
   CLOSE csr_sales_order_hdr;

   -- Commit
   COMMIT;
   EXCEPTION

      -- Ignore records locked by competing ODS_VALIDATION jobs.
      WHEN resource_busy THEN
         ROLLBACK;

      -- Raise alert
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20000,'VALIDATE_SALES_ORDER - ' || substr(SQLERRM, 1, 1024));

   END validate_sales_order;


  /*******************************************************************************
    NAME:       CHECK_DELIVERIES
    PURPOSE:    This code reads through all delivery records with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_deliveries(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_deliveries_hdr IS
      SELECT /*+ INDEX(SAP_DEL_HDR SAP_DEL_HDR_I2) */
        vbeln
      FROM
        sap_del_hdr
      WHERE
        sap_del_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_deliveries_hdr csr_deliveries_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_DELIVERIES: Started.');

    -- Check to see whether there are any records to be processed.
    check_delivery_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_deliveries_hdr;
    FETCH csr_deliveries_hdr INTO rv_deliveries_hdr;
    WHILE csr_deliveries_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 2, 'Validating Delivery: ' || rv_deliveries_hdr.vbeln);
      validate_delivery(i_log_level + 2, rv_deliveries_hdr.vbeln);

      -- Commit when required
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_deliveries_hdr INTO rv_deliveries_hdr;
    END LOOP;
    CLOSE csr_deliveries_hdr;
    COMMIT;

    write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_DELIVERIES: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_delivery, 'n/a', 0, 'ODS_VALIDATION.CHECK_DELIVERIES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_deliveries;



  /*******************************************************************************
    NAME:       CHECK_DELIVERY_TYPES
    PURPOSE:    This code checks to see is the various type included in the delivery
                records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_delivery_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- CURSORS
    CURSOR csr_delivery_type IS
      SELECT /*+ INDEX(A SAP_DEL_HDR_I2) */ DISTINCT
        A.lfart AS delivery_type_code
      FROM
        sap_del_hdr A
      WHERE
        A.valdtn_status = ods_constants.valdtn_unchecked
        AND A.lfart IS NOT NULL
        AND LENGTH(A.lfart) > 0
        AND A.lfart NOT IN (SELECT dlvry_type_code FROM dlvry_type);
    rv_delivery_type csr_delivery_type%ROWTYPE;


    CURSOR csr_order_reason IS
      SELECT /*+ ORDERED USE_NL(b) INDEX(a SAP_DEL_HDR_I2) INDEX(b SAP_DEL_IRF_PK) */
        DISTINCT b.reason AS order_reason_code
      FROM
        sap_del_hdr a,
        sap_del_irf b,
        order_reasn c
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND a.vbeln = b.vbeln
        AND b.reason = c.order_reasn_code(+)
        AND b.reason IS NOT NULL
        AND c.order_reasn_code IS NULL;
    rv_order_reason csr_order_reason%ROWTYPE;


  BEGIN

    -- Check to see if there are new Delivery Types
    write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Checking for new Delivery Types.');
    OPEN csr_delivery_type;
    LOOP
      FETCH csr_delivery_type INTO rv_delivery_type;
      EXIT WHEN csr_delivery_type%NOTFOUND;

      write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Inserting Delivery Type: ' || rv_delivery_type.delivery_type_code || ' found in the Delivery into the Delivery Type table.');

      append.append_dlvry_type_code(rv_delivery_type.delivery_type_code);

    END LOOP;
    CLOSE csr_delivery_type;


    -- Check to see if there are new Order Reason
    write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Checking for new Order Reasons.');
    OPEN csr_order_reason;
    LOOP
      FETCH csr_order_reason INTO rv_order_reason;
      EXIT WHEN csr_order_reason%NOTFOUND;

      write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Inserting Order Reason: ' || rv_order_reason.order_reason_code || ' found in the Delivery into the Order Reason table.');

      append.append_order_reasn_code(rv_order_reason.order_reason_code);

    END LOOP;
    CLOSE csr_order_reason;


  END check_delivery_types;


 /***********************************************************
    NAME    : VALIDATE_DELIVERY
    PURPOSE : Executes validation for delivery (VBELN)
              specified - updating status accordingly
  ************************************************************/
  PROCEDURE validate_delivery(
    i_log_level IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_del_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count PLS_INTEGER;
    var_deleted BOOLEAN;

     -- CURSOR DECLARATIONS
    CURSOR csr_delivery_hdr IS
      SELECT
        *
      FROM
        sap_del_hdr
      WHERE
        sap_del_hdr.vbeln = i_document_nbr AND
        sap_del_hdr.valdtn_status = ods_constants.valdtn_unchecked
    FOR UPDATE NOWAIT;
    rv_delivery_hdr csr_delivery_hdr%ROWTYPE;

    -- Select the Sales Order Document Number and Sales Order Document Line Number for the Delivery.
    -- Also select the Sales Order Document Number and Sales Order Line Number for Sales Orders that
    -- have a Zero Confirmed Quantity and therefore no Delivery line.
    CURSOR csr_sales_order IS
      SELECT DISTINCT
        t03.belnr,
        t03.posnr
      FROM
        sap_del_hdr t01,
        sap_del_det t02,
        sap_del_irf t03
      WHERE
        t01.vbeln = t02.vbeln
        AND t02.pstyv NOT IN ('ZBCH','ZRBC')
        AND t02.vbeln = t03.vbeln
        AND t02.detseq = t03.detseq
        AND t03.qualf IN (ods_constants.delivery_sales_order_flag,
                          ods_constants.delivery_return_flag,
                          ods_constants.delivery_order_wo_charge_flag,
                          ods_constants.delivery_cr_memo_flag,
                          ods_constants.delivery_db_memo_flag)
        AND NOT(t03.datum IS NULL)
        AND t01.valdtn_status <> ods_constants.valdtn_deleted
        AND t03.vbeln = i_document_nbr
        AND t03.belnr IS NOT NULL
      UNION ALL
      SELECT
        t04.belnr AS belnr,
        t04.posex AS posnr
      FROM
        sap_del_hdr t01,
        sap_del_det t02,
        sap_del_irf t03,
        sap_sal_ord_gen t04
      WHERE
        t01.vbeln = t02.vbeln
        AND t02.pstyv NOT IN ('ZBCH','ZRBC')
        AND t02.vbeln = t03.vbeln
        AND t02.detseq = t03.detseq
        AND t03.qualf IN (ods_constants.delivery_sales_order_flag,
                          ods_constants.delivery_return_flag,
                          ods_constants.delivery_order_wo_charge_flag,
                          ods_constants.delivery_cr_memo_flag,
                          ods_constants.delivery_db_memo_flag)
        AND NOT (t03.datum IS NULL)
        AND t01.valdtn_status <> ods_constants.valdtn_deleted
        AND t03.vbeln = i_document_nbr
        AND t03.belnr IS NOT NULL
        AND t03.belnr = t04.belnr
        AND t04.abgru = 'ZA'; -- 'ZA' equals 'APO Zero Confirmed Qty', which means that no Delivery line is generated.
    rv_sales_order csr_sales_order%ROWTYPE;

    -- Select the Purchase Order Document Number and Purchase Order Document Line Number
    -- for the Delivery.
    CURSOR csr_purchase_order IS
      SELECT DISTINCT
        t03.belnr,
        t03.posnr
      FROM
        sap_del_hdr t01,
        sap_del_det t02,
        sap_del_irf t03
      WHERE
        t01.vbeln = t02.vbeln
        AND t02.pstyv NOT IN ('ZBCH','ZRBC')
        AND t02.vbeln = t03.vbeln
        AND t02.detseq = t03.detseq
        AND t03.qualf = ods_constants.delivery_purch_order_flag
        AND t01.valdtn_status <> ods_constants.valdtn_deleted
        AND t03.vbeln = i_document_nbr
        AND t03.belnr IS NOT NULL;
    rv_purchase_order csr_purchase_order%ROWTYPE;


    -- Check whether a invoice exists for the Delivery.
    CURSOR csr_invoice IS
      SELECT DISTINCT
        belnr
      FROM
        sap_inv_irf
      WHERE
        qualf = ods_constants.invoice_delivery_flag
        AND refnr = i_document_nbr;
    rv_invoice csr_invoice%ROWTYPE;

    CURSOR csr_sap_del_irf_01 IS
      SELECT DISTINCT
        t01.belnr,
        t01.posnr
      FROM
         sap_del_irf t01
      WHERE
        t01.vbeln = rv_delivery_hdr.vbeln
        AND ((t01.qualf IN (ods_constants.delivery_sales_order_flag,
                            ods_constants.delivery_return_flag,
                            ods_constants.delivery_order_wo_charge_flag,
                            ods_constants.delivery_cr_memo_flag,
                            ods_constants.delivery_db_memo_flag)
              AND NOT(t01.datum IS NULL))
              OR (t01.qualf LIKE ods_constants.delivery_purch_order_flag));
    rcd_sap_del_irf_01 csr_sap_del_irf_01%ROWTYPE;

    CURSOR csr_sap_del_irf_02 IS
      SELECT DISTINCT
        t02.vbeln,
        t02.idoc_timestamp
      FROM
        sap_del_irf t01,
        sap_del_hdr t02
      WHERE
        t01.vbeln = t02.vbeln(+)
        AND t01.vbeln <> rv_delivery_hdr.vbeln
        AND t01.belnr = rcd_sap_del_irf_01.belnr
        AND t01.posnr = rcd_sap_del_irf_01.posnr
        AND ((t01.qualf IN (ods_constants.delivery_sales_order_flag,
                            ods_constants.delivery_return_flag,
                            ods_constants.delivery_order_wo_charge_flag,
                            ods_constants.delivery_cr_memo_flag,
                            ods_constants.delivery_db_memo_flag)
              AND NOT(t01.datum IS NULL))
              OR (t01.qualf LIKE ods_constants.delivery_purch_order_flag))
        AND t02.valdtn_status <> ods_constants.valdtn_deleted;
    rcd_sap_del_irf_02 csr_sap_del_irf_02%ROWTYPE;

    CURSOR csr_sap_sal_ord_gen_01 IS
      SELECT 'x'
      FROM
        sap_sal_ord_gen t01,
        sap_sal_ord_hdr t02
      WHERE
        t01.belnr = t02.belnr(+)
        AND t01.belnr = rcd_sap_del_irf_01.belnr
        AND t01.posex = rcd_sap_del_irf_01.posnr
        AND ((NOT(t01.abgru IS NULL) AND t01.abgru != 'ZA') OR
            ((t01.abgru IS NULL OR t01.abgru = 'ZA') AND t01.menge IS NULL AND t01.menee IS NULL) OR
             t02.valdtn_status = ods_constants.valdtn_deleted);
    rcd_sap_sal_ord_gen_01 csr_sap_sal_ord_gen_01%ROWTYPE;

    -- Used in delivery validation to check if an invoice exists for a return delivery.
    -- If it is, that invoice will be flagged to unchecked, so that it is revalidated and thus updates
    -- all its related documents.
    CURSOR csr_return_dlvry IS
      SELECT
        t01.belnr
      FROM
        sap_inv_irf t01,
        sap_sal_ord_gen t02,
        sap_del_irf t03,
        sap_del_det t04
      WHERE
        t01.qualf = ods_constants.invoice_sales_order_flag
        AND t03.vbeln = i_document_nbr
        AND t01.refnr IS NOT NULL
        AND t01.refnr = t02.belnr
        AND t02.belnr = t03.belnr
        AND t02.posex = t03.posnr
        AND t03.vbeln = t04.vbeln
        AND t03.detseq = t04.detseq
        AND t04.hipos IS NULL
        AND t03.datum IS NOT NULL
        AND t03.belnr IS NOT NULL;
    rv_return_dlvry csr_return_dlvry%ROWTYPE;

    CURSOR csr_country IS
       select country_code
       from (select a.land1 as country_code
             from sap_del_hdr a
             where a.vbeln = i_document_nbr
               and a.land1 is not null
             union all
             select b.country1 as country_code
             from sap_del_add b
             where b.vbeln = i_document_nbr
               and b.country1 is not null)
       group by country_code;
    rv_country csr_country%ROWTYPE;

    CURSOR csr_region IS
      SELECT DISTINCT
        A.region   AS region_code,
        A.country1 AS country_code
      FROM
        sap_del_add A
      WHERE A.vbeln = i_document_nbr
        AND A.region IS NOT NULL
        AND A.country1 IS NOT NULL;
    rv_region csr_region%ROWTYPE;

    BEGIN

    -- Check to see if there are new Countries
    write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Checking for new Countries.');
    OPEN csr_country;
    LOOP
      FETCH csr_country INTO rv_country;
      EXIT WHEN csr_country%NOTFOUND;

      write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Inserting Country: ' || rv_country.country_code || ' found in the Delivery into the Country table.');

      append.append_cntry_code(rv_country.country_code);

    END LOOP;
    CLOSE csr_country;

    -- Check to see if there are new Region
    write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Checking for new Regions.');
    OPEN csr_region;
    LOOP
      FETCH csr_region INTO rv_region;
      EXIT WHEN csr_region%NOTFOUND;

      write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Inserting Region Code/Country Code: ' || rv_region.region_code || '/' || rv_region.country_code || ' found in the Delivery into the Region table.');

      append.append_region_code(rv_region.region_code, rv_region.country_code);

    END LOOP;
    CLOSE csr_region;


      -- Initialise Variables
      var_deleted := false;

      -- Open Delivery for processing
      OPEN csr_delivery_hdr;
      FETCH csr_delivery_hdr INTO rv_delivery_hdr;
      IF csr_delivery_hdr%FOUND THEN

         ----------------------
         -- Delivery Deletion--
         ----------------------
         -- Notes
         -- 1. Older deliveries referencing the same sales order line are flagged as deleted
         -- 2. Deliveries related to deleted sales orders or rejected sales order lines are flagged as deleted

         -- Retrieve the delivery detail internal reference data
         OPEN csr_sap_del_irf_01;
         LOOP
            FETCH csr_sap_del_irf_01 INTO rcd_sap_del_irf_01;
            IF csr_sap_del_irf_01%NOTFOUND THEN
               EXIT;
            END IF;

            -- Update the all delivery status (deleted) when sales order or sales order line deleted
            OPEN csr_sap_sal_ord_gen_01;
            FETCH csr_sap_sal_ord_gen_01 INTO rcd_sap_sal_ord_gen_01;
            IF csr_sap_sal_ord_gen_01%FOUND THEN
               -- Flag to Deleted
               var_deleted := TRUE;
               UPDATE sap_del_hdr
               SET valdtn_status = ods_constants.valdtn_deleted
               WHERE vbeln = rv_delivery_hdr.vbeln;
            END IF;
            CLOSE csr_sap_sal_ord_gen_01;


            -- Retrieve any related delivery detail internal reference data
            -- ** note ** the relationship is based on sales order and sales order line
            OPEN csr_sap_del_irf_02;
            LOOP
               FETCH csr_sap_del_irf_02 INTO rcd_sap_del_irf_02;
               IF csr_sap_del_irf_02%NOTFOUND THEN
                  EXIT;
               END IF;

               -- Update the related delivery status (deleted) when sales order or sales order line deleted
               IF var_deleted = TRUE THEN
                  UPDATE sap_del_hdr
                  SET valdtn_status = ods_constants.valdtn_deleted
                  WHERE vbeln = rcd_sap_del_irf_02.vbeln;
               END IF;


               -- If the deletion flag is set to TRUE, all deliveries have been deleted and the
               -- processing below is not necessary.
               IF var_deleted = FALSE THEN
                 -- Update the relevant delivery status (deleted) based on the idoc timestamp
                 -- ** notes **
                 -- 1. The older delivery is flagged as deleted
                 -- 2. Any one delivery line will cause the deletion of the whole delivery
                 IF rv_delivery_hdr.idoc_timestamp >= rcd_sap_del_irf_02.idoc_timestamp THEN
                    UPDATE sap_del_hdr
                    SET valdtn_status = ods_constants.valdtn_deleted
                    WHERE vbeln = rcd_sap_del_irf_02.vbeln;
                 ELSE
                    UPDATE sap_del_hdr
                    SET valdtn_status = ods_constants.valdtn_deleted
                    WHERE vbeln = rv_delivery_hdr.vbeln;
                    -- The delivery has been deleted and thus no data validation is required.
                    var_deleted := TRUE;
                 END IF;
               END IF;

            END LOOP;
            CLOSE csr_sap_del_irf_02;

         END LOOP;
         CLOSE csr_sap_del_irf_01;

         -- Clear the validation reason tables of this delivery
         utils.clear_validation_reason(ods_constants.valdtn_type_delivery,
                                       i_document_nbr,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);


         -- If the Delivery was flagged as deleted, do not validate further
         IF (var_deleted = FALSE) THEN

           -- Delivery Sales Organisation must be valid.
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             sap_del_hdr a,
             company b
           WHERE
             a.vbeln = rv_delivery_hdr.vbeln AND
             a.vkorg = b.company_code;
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Delivery: ' || rv_delivery_hdr.vbeln || ': Invalid or non-existant Sales Organisation.');

             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_delivery,
                                        'Invalid or non-existant Sales Organisation.',
                                         ods_constants.valdtn_severity_critical,
                                         i_document_nbr,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         i_log_level + 1);
           END IF;

           -- Delivery Creation Date must exist and be valid.
           v_count := 0;
           BEGIN
             SELECT
               count(*) INTO v_count
             FROM
               sap_del_tim a,
               mars_date b
             WHERE
               vbeln = rv_delivery_hdr.vbeln AND
               qualf = ods_constants.delivery_document_date AND
               b.calendar_date = TO_DATE(DECODE(ltrim(isdd,' 0'), NULL, ltrim(ntanf,' 0'), ltrim(isdd,' 0')), 'YYYYMMDD');
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;
           IF v_count <> 1 THEN                    -- There should be 1 valid date!
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Delivery: ' || rv_delivery_hdr.vbeln || ': Invalid, duplicate or non-existant Creation Date.');

             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_delivery,
                                         'Invalid, duplicate or non-existant Creation Date.',
                                         ods_constants.valdtn_severity_critical,
                                         i_document_nbr,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         i_log_level + 1);
           END IF;

           -- Delivery Billing Date must exist and be valid.
           v_count := 0;
           BEGIN
             SELECT
               count(*) INTO v_count
             FROM
               sap_del_tim a,
               mars_date b
             WHERE
               vbeln = rv_delivery_hdr.vbeln AND
               qualf = ods_constants.delivery_billing_date AND
               b.calendar_date = TO_DATE(DECODE(ltrim(isdd,' 0'), NULL, ltrim(ntanf,' 0'), ltrim(isdd,' 0')), 'YYYYMMDD');
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;
           IF v_count <> 1 THEN                    -- There should be 1 valid date!
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Delivery: ' || rv_delivery_hdr.vbeln || ': Invalid, duplicate or non-existant Billing Date.');

             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_delivery,
                                        'Invalid, duplicate or non-existant Billing Date.',
                                         ods_constants.valdtn_severity_critical,
                                         i_document_nbr,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         i_log_level + 1);
           END IF;

           -- Any material line associated with the Delivery must have a non-null material code.
           v_count := 0;
           BEGIN
             SELECT
               COUNT(*) INTO v_count
             FROM
               sap_del_det a
             WHERE
               a.vbeln = rv_delivery_hdr.vbeln AND
               a.matnr IS NULL;
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;
           IF v_count > 0 THEN                    -- There should not be any null material codes.
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Delivery: ' || rv_delivery_hdr.vbeln || ': Has null material code(s) (sap_del_det).');

             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_delivery,
                                        'Has null material code(s) (sap_del_det).',
                                        ods_constants.valdtn_severity_critical,
                                        i_document_nbr,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
           END IF;

           -- Any material line associated with the Delivery must have a material code with a status equal to VALID.
           v_count := 0;
           BEGIN
             SELECT
               COUNT(*) INTO v_count
             FROM
               sap_del_det a,
               sap_mat_hdr b
             WHERE
               a.vbeln = rv_delivery_hdr.vbeln AND
               a.matnr = b.matnr AND
               b.valdtn_status <> ods_constants.valdtn_valid;
           EXCEPTION
             WHEN OTHERS THEN
               NULL;
           END;
           IF v_count > 0 THEN                    -- There should not be any material codes with a status not equal to VALID.
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_delivery, 'n/a', i_log_level + 1, 'Delivery: ' || rv_delivery_hdr.vbeln || ': Has a material code(s) with a status not equal to VALID.');

             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_delivery,
                                         'Has a material code(s) with a status not equal to VALID.',
                                         ods_constants.valdtn_severity_critical,
                                         i_document_nbr,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         NULL,
                                         i_log_level + 1);
           END IF;

           -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
           UPDATE sap_del_hdr
           SET
             sap_del_hdr.valdtn_status = v_valdtn_status
           WHERE
             CURRENT OF csr_delivery_hdr;

         END IF;

         /*-*/
         /* Update the order_status column to 'DELIVERED' in related
         /* sap_sal_ord_hdr and sap_sto_po_hdr records
         /*
         /* Update the valdtn_status column to 'UNCHECKED in related sap_inv_hdr records
         /*
         /*   note : this is in place to ensure that resends of Sales Orders are
         /*          correctly reflected in subsequent documents.
         /*
         /*          It is possible that deliveries will be flagged as
         /*          deleted in the next step of processing below.
         /*-*/

         -- Update the order_status column to 'DELIVERED' in the sap_sal_ord_gen table.
         FOR rv_sales_order IN csr_sales_order LOOP

           -- Now update the sap_sal_ord_gen table
           UPDATE sap_sal_ord_gen
           SET order_line_status = ods_constants.sales_order_status_delivered
           WHERE belnr = rv_sales_order.belnr
           AND posex = rv_sales_order.posnr;

         END LOOP;

         -- Update the purch_order_status column to 'DELIVERED' in the sap_sto_po_gen table.
         FOR rv_purchase_order IN csr_purchase_order LOOP

           -- Now update the sap_sto_po_gen table
           UPDATE sap_sto_po_gen
           SET purch_order_line_status = ods_constants.sales_order_status_delivered
           WHERE belnr = rv_purchase_order.belnr
           AND LTRIM(posex,0) = LTRIM(rv_purchase_order.posnr,0);

         END LOOP;

         -- If delivery is a return, the csr_return_dlvry cursor must be used to update the invoice to UNCHECKED.
         IF (rv_delivery_hdr.lfart = ods_constants.delivery_return_dlvry OR rv_delivery_hdr.lfart = ods_constants.delivery_icb_return_dlvry
             OR rv_delivery_hdr.lfart = ods_constants.delivery_return_dlvry_com OR rv_delivery_hdr.lfart = ods_constants.delivery_icb_po_return_dlvry) THEN

           -- Update the valdtn_status column to 'UNCHECKED' in the sap_inv_hdr table.
           FOR rv_return_dlvry IN csr_return_dlvry LOOP

             -- Now update the sap_inv_hdr table.
             UPDATE sap_inv_hdr
             SET valdtn_status = ods_constants.valdtn_unchecked
             WHERE belnr = rv_return_dlvry.belnr;

           END LOOP;
         -- If NOT a return delivery
         ELSE

           -- Update the valdtn_status column to 'UNCHECKED' in the sap_inv_hdr table.
           FOR rv_invoice IN csr_invoice LOOP

             -- Now update the sap_inv_hdr table.
             UPDATE sap_inv_hdr
             SET valdtn_status = ods_constants.valdtn_unchecked
             WHERE belnr = rv_invoice.belnr;

           END LOOP;

         END IF;

      END IF;
      CLOSE csr_delivery_hdr;

      -- Commit the database
      COMMIT;

   EXCEPTION
      -- Ignore records locked by competing ODS_VALIDATION jobs.
      WHEN resource_busy tHEN
         ROLLBACK;


      -- Raise alert
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20000,'VALIDATE_DELIVERY - ' || substr(SQLERRM, 1, 1024));

   END validate_delivery;


  /*******************************************************************************
    NAME:       CHECK_INVOICES
    PURPOSE:    This code reads through all invoice records with a validation
                status of "UNCHECKED", and calls a routine to validate the record.
                The logic opens and closes the cursor before checking for each new
                group of records, so that if any additional records are written in
                while validation is occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_invoices(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_invoices_hdr IS
      SELECT
        belnr
      FROM
        sap_inv_hdr
      WHERE
        sap_inv_hdr.valdtn_status = ods_constants.valdtn_unchecked;
    rv_invoices_hdr csr_invoices_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INVOICES: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_invoices_hdr;
    FETCH csr_invoices_hdr INTO rv_invoices_hdr;
    WHILE csr_invoices_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 2, 'Validating Invoice: ' || rv_invoices_hdr.belnr);
      validate_invoice(i_log_level + 2, rv_invoices_hdr.belnr);

      -- Commit when required, and recheck which addresses need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_invoices_hdr INTO rv_invoices_hdr;
    END LOOP;
    CLOSE csr_invoices_hdr;
    COMMIT;

    write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INVOICES: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_invoice, 'n/a', 0, 'ODS_VALIDATION.CHECK_INVOICES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_invoices;


  /*******************************************************************************
    NAME:       VALIDATE_INVOICE
    PURPOSE:    This code validates a invoice record, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_invoice(
    i_log_level    IN ods.log.log_level%TYPE,
    i_document_nbr IN VARCHAR2) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_inv_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count           PLS_INTEGER;
    v_inv_type_return VARCHAR2(1) := 'N';

    -- CURSOR DECLARATIONS
    CURSOR csr_invoice_hdr IS
      SELECT
        belnr
      FROM
        sap_inv_hdr
      WHERE
        sap_inv_hdr.belnr = i_document_nbr
      AND sap_inv_hdr.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_invoice_hdr csr_invoice_hdr%ROWTYPE;


    -- Check to see if the invoice is a stock transfer
    -- The outer joins and the nvl were put into this query
    -- to help catch the change in the invoice idoc than
    -- now makes stock transfer invoices have on creation
    -- date instead of having a creation date of 00000000
    CURSOR csr_creation_date_check IS
      SELECT
        NVL(B.datum, '00000000') AS datum, -- creation date
        C.summe  -- net invoice value
      FROM
        sap_inv_hdr A,
        sap_inv_dat B,
        sap_inv_smy C
      WHERE
        A.belnr = i_document_nbr
        AND A.belnr = B.belnr (+)
        AND A.belnr = C.belnr (+)
        AND B.iddat (+) = ods_constants.invoice_document_date
        AND C.sumid (+) = ods_constants.invoice_smy_qualifier;
    rv_creation_date_check csr_creation_date_check%ROWTYPE;


    -- Select the Sales Order Document Number and Sales Order Document Line Number for the Invoice.
    -- Also select the Sales Order Document Number and Sales Order Line Number for Sales Orders that
    -- have a Zero Confirmed Quantity and therefore no Invoice line.
    CURSOR csr_sales_order IS
      SELECT DISTINCT
        t01.refnr,
        t01.zeile
      FROM
        sap_inv_irf t01
      WHERE
        t01.qualf = ods_constants.invoice_sales_order_flag
        AND t01.belnr = i_document_nbr
        AND t01.refnr IS NOT NULL
      UNION ALL
      SELECT DISTINCT
        t02.belnr AS refnr,
        t02.posex AS zeile
      FROM
        sap_inv_irf t01,
        sap_sal_ord_gen t02
      WHERE
        t01.qualf = ods_constants.invoice_sales_order_flag
        AND t01.belnr = i_document_nbr
        AND t01.refnr IS NOT NULL
        AND t01.refnr = t02.belnr
        AND t02.abgru = 'ZA'; -- 'ZA' equals 'APO Zero Confirmed Qty', which means that no Invoice line is generated.
    rv_sales_order csr_sales_order%ROWTYPE;


    -- Select the Purchase Order Document Number and Purchase Order Document Line Number for the Invoice.
    CURSOR csr_purch_order IS
      SELECT DISTINCT
        t01.refnr,
        LPAD(LTRIM(t01.zeile,'0'), 5, '0') AS zeile
      FROM
        sap_inv_irf t01
      WHERE
        t01.qualf = ods_constants.invoice_purch_order_flag
        AND t01.belnr = i_document_nbr
        AND t01.refnr IS NOT NULL;
    rv_purch_order csr_purch_order%ROWTYPE;


    -- Check if the invoice has a sales order. Needed to check if a sales order OR purchase
    -- order update is required.
    CURSOR csr_sales_order_check IS
      SELECT DISTINCT
        t02.belnr AS refnr
      FROM
        sap_inv_irf t01,
        sap_sal_ord_hdr t02
      WHERE
        t01.qualf = ods_constants.invoice_sales_order_flag
        AND t01.belnr = i_document_nbr
        AND t01.refnr IS NOT NULL
        AND t01.refnr = t02.belnr;
    rv_sales_order_check csr_sales_order_check%ROWTYPE;


    -- Select the Delivery Document Number and Delivery Document Line Number
    -- for the Invoice.
    CURSOR csr_delivery IS
      SELECT DISTINCT
        t01.refnr,
        t01.zeile
      FROM
        sap_inv_irf t01
      WHERE
        t01.qualf = ods_constants.invoice_delivery_flag
        AND t01.belnr = i_document_nbr
        AND t01.refnr IS NOT NULL;
    rv_delivery csr_delivery%ROWTYPE;


   -- Used in invoice validation to check if a delivery exists for the sales order that belongs to the
   -- invoice being validated. If a delivery exists then it must be flagged to invoiced.
   CURSOR csr_return_invoice IS
     SELECT
       t03.vbeln,
       t04.posnr
     FROM
       sap_inv_irf t01,
       sap_sal_ord_gen t02,
       sap_del_irf t03,
       sap_del_det t04
     WHERE
       t01.qualf = ods_constants.invoice_sales_order_flag
       AND t01.belnr = i_document_nbr
       AND t01.refnr IS NOT NULL
       AND t01.refnr = t02.belnr
       AND t02.belnr = t03.belnr
       AND t02.posex = t03.posnr
       AND t03.vbeln = t04.vbeln
       AND t03.detseq = t04.detseq
       AND t04.hipos IS NULL
       AND t03.datum IS NOT NULL
       AND t03.belnr IS NOT NULL;
    rv_return_invoice csr_return_invoice%ROWTYPE;

    CURSOR csr_country IS
       select country_code
       from (select b.land1 as country_code
             from sap_inv_pnr b
             where b.belnr = i_document_nbr
               and b.land1 is not null
             union all
             select b.land1 as country_code
               from sap_inv_ipn b
             where b.belnr = i_document_nbr
               and b.land1 is not null)
       group by country_code;
    rv_country csr_country%ROWTYPE;


    CURSOR csr_region IS
       select region_code, country_code
       from (select b.regio as region_code,
                    b.land1 as country_code
             from sap_inv_pnr b
             where b.belnr = i_document_nbr
               and b.regio is not null
               and b.land1 is not null
             union all
             select b.regio as region_code,
                    b.land1 as country_code
             from sap_inv_ipn b
             where b.belnr = i_document_nbr
               and b.regio is not null
               and b.land1 is not null)
       group by region_code, country_code;
    rv_region csr_region%ROWTYPE;

    CURSOR csr_invoice_type IS
       select invoice_type_code
       from (select a.fkart_rl as invoice_type_code
             from sap_inv_hdr a
             where a.belnr = i_document_nbr
               and a.fkart_rl is not null
             union all
             select b.orgid
             from sap_inv_org b
             where b.belnr = i_document_nbr
               and b.qualf = ods_constants.invoice_invoice_type
               and b.orgid is not null)
       group by invoice_type_code;
    rv_invoice_type csr_invoice_type%ROWTYPE;

  BEGIN

    -- Check to see if there are new Countries
    write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Checking for new Countries.');
    OPEN csr_country;
    LOOP
      FETCH csr_country INTO rv_country;
      EXIT WHEN csr_country%NOTFOUND;

      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Inserting Country: ' || rv_country.country_code || ' found in the Invoice into the Country table.');

      append.append_cntry_code(rv_country.country_code);

    END LOOP;
    CLOSE csr_country;


    -- Check to see if there are new Region
    write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Checking for new Regions.');
    OPEN csr_region;
    LOOP
      FETCH csr_region INTO rv_region;
      EXIT WHEN csr_region%NOTFOUND;

      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Inserting Region Code/Country Code: ' || rv_region.region_code || '/' || rv_region.country_code || ' found in the Invoice into the Region table.');

      append.append_region_code(rv_region.region_code, rv_region.country_code);

    END LOOP;
    CLOSE csr_region;

    -- Check to see if there are new Invocie Types
    write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Checking for new Invoice Types.');
    OPEN csr_invoice_type;
    LOOP
      FETCH csr_invoice_type INTO rv_invoice_type;
      EXIT WHEN csr_invoice_type%NOTFOUND;

      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Inserting Invoice Type: ' || rv_invoice_type.invoice_type_code || ' found in the Invoice into the Invoice Type table.');

      append.append_invc_type_code(rv_invoice_type.invoice_type_code);

    END LOOP;
    CLOSE csr_invoice_type;


    -- Validate the invoice header record.
    OPEN csr_invoice_hdr;
    FETCH csr_invoice_hdr INTO rv_invoice_hdr;
    IF csr_invoice_hdr%FOUND THEN

      -- Clear the validation reason tables of this invoice
      utils.clear_validation_reason(ods_constants.valdtn_type_invoice,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Check to see if this invoice is a stock transfer
      OPEN csr_creation_date_check;
      FETCH csr_creation_date_check INTO rv_creation_date_check;
      CLOSE csr_creation_date_check;

      -- Check to see if the Creation Date is equal to 00000000 and the
      -- net invoice value equals zero
      IF (rv_creation_date_check.datum = '00000000'
          AND rv_creation_date_check.summe = '0' ) THEN
        v_valdtn_status := ods_constants.valdtn_omitted;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Is A Stock Transfer Invoice.');

      ELSE
        -- Invoice Creation Date (Local Time) must exist and be valid.
        v_count := 0;

        BEGIN
          SELECT
            COUNT(*) INTO v_count
          FROM
            sap_inv_dat a,
            mars_date   b
          WHERE
            a.belnr = rv_invoice_hdr.belnr
            AND a.iddat = ods_constants.invoice_document_date
            AND b.yyyymmdd_date = to_number(a.datum);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        IF v_count <> 1 THEN                    -- There should be 1 valid date!
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Invalid, duplicate or non-existant Creation Date.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Invalid, duplicate or non-existant Creation Date.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
        END IF;
      END IF;


      -- Sales Organisation (Invoice Header) must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_org a,
        company     b
      WHERE
        a.belnr = rv_invoice_hdr.belnr
        AND a.qualf = ods_constants.invoice_sales_org
        AND a.orgid = b.company_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Invalid or non-existant (Invoice Header) Sales Organisation.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Invalid or non-existant (Invoice Header) Sales Organisation.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Distribution Channel (Invoice Header) must exist.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_org a
      WHERE
        a.belnr = rv_invoice_hdr.belnr
        AND a.qualf = ods_constants.invoice_distbn_chnl
        AND a.orgid IS NOT NULL;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Non-existant (Invoice Header) Distribution Channel.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Non-existant (Invoice Header) Distribution Channel.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Division (Invoice Header) must exist.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_org a
      WHERE
        a.belnr = rv_invoice_hdr.belnr
        AND a.qualf = ods_constants.invoice_division
        AND a.orgid IS NOT NULL;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Non-existant (Invoice Header) Division.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Non-existant (Invoice Header) Division.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Invoice Type must exist and will be checked if it is a 'RETURN' type.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_org a
      WHERE
        a.belnr = rv_invoice_hdr.belnr
        AND a.qualf = ods_constants.invoice_invoice_type
        AND a.orgid IS NOT NULL;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Non-existant Invoice Type.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Non-existant Invoice Type.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      ELSE
        v_inv_type_return := 'N';
        SELECT
          DECODE(a.orgid, ods_constants.invoice_icb_return, 'Y', ods_constants.invoice_icb_po_return, 'Y', ods_constants.invoice_credit_return, 'Y', 'N') INTO v_inv_type_return
        FROM
          sap_inv_org a
        WHERE
          a.belnr = rv_invoice_hdr.belnr
          AND a.qualf = ods_constants.invoice_invoice_type
          AND a.orgid IS NOT NULL;
      END IF;

      -- Order Usage: must not have a status of UNCLASSIFIED.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        sap_inv_gen a,
        order_usage b
      WHERE
        a.belnr = i_document_nbr
        AND b.order_usage_code = a.abrvw
        AND b.order_usage_gsv_flag = ods_constants.gsv_flag_unclassified;

      -- If so, then the Invoice is invalid.
      IF v_count > 0 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': associated Order Usage is unclassified.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Invoice references UNCLASSIFIED Order Usage record; classify Order Usage.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Document Currency must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_hdr a,
        currcy b
      WHERE
        a.belnr = rv_invoice_hdr.belnr
      AND a.curcy = b.currcy_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Invalid or non-existant Currency.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Invalid or non-existant Currency.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Document Exchange Rate must exist.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_hdr a
      WHERE
        a.belnr = rv_invoice_hdr.belnr
      AND a.wkurs IS NOT NULL;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Exchange Rate is blank.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Exchange Rate is blank.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Any material line associated with the Invoice must have a non-null material code.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*) INTO v_count
        FROM
          sap_inv_iob a
        WHERE
          a.belnr = rv_invoice_hdr.belnr
      AND a.qualf = ods_constants.invoice_material_code
      AND a.idtnr IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF v_count > 0 THEN                    -- There should not be any null material codes.
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Has null material code(s) (sap_inv_iob).');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Has null material code(s) (sap_inv_iob).',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Any non-null material must have a valid weight UOM.
      v_count := 0;
      BEGIN
        SELECT /*+ INDEX(a SAP_INV_IOB_PK) */
          COUNT(*) INTO v_count
        FROM
          sap_inv_iob a,
          sap_mat_hdr b,
          uom c
        WHERE
          a.belnr = rv_invoice_hdr.belnr
          AND a.qualf = ods_constants.invoice_material_code
          AND NOT a.idtnr IS NULL
          AND b.matnr = a.idtnr
          AND b.gewei = c.uom_code(+)
          AND c.uom_code IS NULL;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF v_count > 0 THEN                    -- There should not be invalid UOMs.
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Has invalid missing weight UOM code(s) (sap_inv_iob).');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Has invalid missing weight UOM code(s) (sap_inv_iob).',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Any material line associated with the Invoice must have a material code that has a validation status equal to VALID.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*) INTO v_count
        FROM
          sap_inv_iob a,
          sap_mat_hdr b
        WHERE
          a.belnr = rv_invoice_hdr.belnr
          AND a.qualf = ods_constants.invoice_material_code
          AND a.idtnr = b.matnr
          AND b.valdtn_status <> ods_constants.valdtn_valid;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF v_count > 0 THEN                    -- There should not be any material codes with a validation status not equal to VALID.
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Has a material code(s) with a validation status not equal to VALID.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Has a material code(s) with a validation status not equal to VALID.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Sales Organisation (Invoice Line) must be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_inv_gen a
      WHERE
        a.belnr = rv_invoice_hdr.belnr
        AND a.vkorg IS NOT NULL
        AND a.vkorg NOT IN (SELECT company_code FROM company);

      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Invalid (Invoice Line) Sales Organisation.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Invalid (Invoice Line) Sales Organisation.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Invoice Billing Date must exist and be valid.
      v_count := 0;
      BEGIN
        SELECT
          COUNT(*) INTO v_count
        FROM
          sap_inv_dat a,
          mars_date  b
        WHERE
          a.belnr = rv_invoice_hdr.belnr
          AND a.iddat = ods_constants.invoice_billing_date
          AND b.yyyymmdd_date = to_number(a.datum);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF v_count <> 1 THEN                    -- There should be 1 valid date!
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 1, 'Invoice: ' || rv_invoice_hdr.belnr || ': Invalid, duplicate or non-existant Billing Date.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_invoice,
                                    'Invalid, duplicate or non-existant Billing Date.',
                                    ods_constants.valdtn_severity_critical,
                                    i_document_nbr,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 2, 'Invoice: ' || i_document_nbr || ' is ' || v_valdtn_status);
      UPDATE sap_inv_hdr
        SET sap_inv_hdr.valdtn_status = v_valdtn_status
      WHERE
        CURRENT OF csr_invoice_hdr;

    END IF;
    CLOSE csr_invoice_hdr;


    -- An invoice must have either a Sales Order or a Purchase Order. Thus the following
    -- 'IF' statement checks if the invoice has Sales Orders and updates them, although
    -- if no Sales Orders are found, then it updates the invoice's Purchase Orders.
    OPEN csr_sales_order_check;
    FETCH csr_sales_order_check INTO rv_sales_order_check;
    -- Do Sales Orders exist for this invoice
    IF csr_sales_order_check%FOUND THEN
      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 2, 'Invoice: ' || i_document_nbr || ' has a Sales Order ');

      OPEN csr_sales_order;
      FETCH csr_sales_order INTO rv_sales_order;
      -- Update the order_status column to 'INVOICED' in the sap_sal_ord_gen table.
      WHILE csr_sales_order%FOUND LOOP

        -- Now update the sap_sal_ord_gen table
        UPDATE sap_sal_ord_gen
          SET order_line_status = ods_constants.sales_order_status_invoiced
        WHERE
          belnr = rv_sales_order.refnr
          AND posex = rv_sales_order.zeile;

        -- Commit.
        COMMIT;
        -- Fetch next record, if one does not exist procedure will stop looping
        FETCH csr_sales_order INTO rv_sales_order;

      END LOOP;

      -- Close Check Sales Order cursor
      CLOSE csr_sales_order;

    -- Sales Orders do NOT exist for this invoice, thus update any Purchase Orders
    -- that exist against the invoice.
    ELSE
      write_log(ods_constants.data_type_invoice, 'n/a', i_log_level + 2, 'Invoice: ' || i_document_nbr || ' has a Purchase Order ');

      OPEN csr_purch_order;
      FETCH csr_purch_order INTO rv_purch_order;
      WHILE csr_purch_order%FOUND LOOP

        -- Now update the sap_sal_ord_gen table
        UPDATE sap_sto_po_gen
          SET purch_order_line_status = ods_constants.purch_order_status_invoiced
        WHERE
          belnr = rv_purch_order.refnr
          AND posex = rv_purch_order.zeile;

        -- Commit.
        COMMIT;
        -- Fetch next record, if one does not exist procedure will stop looping
        FETCH csr_purch_order INTO rv_purch_order;

      END LOOP;

      -- Close Check Purchase Order cursor
      CLOSE csr_purch_order;

    END IF; -- End of 'IF' to check if records are found in sales order cursor

    -- Cloase sales order check cursor.
    CLOSE csr_sales_order_check;

    -- Check if invoice is a return type, if so the csr_return_invoice cursor must be used to update the
    -- sap_del_det table as the delivery number is not stored on the sap_inv_irf table.
    IF v_inv_type_return = 'Y' THEN
      FOR rv_return_invoice IN csr_return_invoice LOOP

        -- Now update the sap_del_det table.
        UPDATE sap_del_det
          SET dlvry_line_status = ods_constants.delivery_status_invoiced
        WHERE vbeln = rv_return_invoice.vbeln
          AND posnr = rv_return_invoice.posnr;

        -- Commit.
        COMMIT;

      END LOOP;
    ELSE
      -- Update the dlvry_status column to 'INVOICED' in the sap_del_det table.
      FOR rv_delivery IN csr_delivery LOOP

        -- Now update the sap_del_det table.
        UPDATE sap_del_det
          SET dlvry_line_status = ods_constants.delivery_status_invoiced
        WHERE vbeln = rv_delivery.refnr
          AND posnr = rv_delivery.zeile;

        -- Commit.
        COMMIT;

      END LOOP;
    END IF;

  EXCEPTION
    -- Ignore records locked by competing ODS_VALIDATION jobs.
    WHEN resource_busy THEN
      ROLLBACK;

     -- Raise alert
     WHEN OTHERS THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20000,'VALIDATE_INVOICE - ' || substr(SQLERRM, 1, 1024));

  END validate_invoice;



  /*******************************************************************************
    NAME:       CHECK_INVOICE_SUMMARIES
    PURPOSE:    This code reads through all invoice summary records with a
                validation status of "UNCHECKED", and calls a routine to validate
                the record. The logic opens and closes the cursor before checking
                for each new group of records, so that if any additional records
                are written in while validation is occurring, then these are also
                validated.

                Note: unlike the other controlling procedures, this does not have
                an outer loop which continues to process until all are valid. This
                is because we may skip processing an invoice summary if an
                aggregation is in progress, and we don't want the routine to
                endlessly loop until the aggregation is finished.
  ********************************************************************************/
  PROCEDURE check_invoice_summaries(
    i_log_level    IN ods.log.log_level%TYPE,
    i_company_code IN ods.company.company_code%TYPE) IS

    -- Cursor Declarations
    CURSOR csr_inv_sum_hdr IS
      SELECT
        *
      FROM
        sap_inv_sum_hdr
      WHERE
        sap_inv_sum_hdr.valdtn_status = ods_constants.valdtn_unchecked
        AND bukrs = i_company_code;
    rv_inv_sum_hdr csr_inv_sum_hdr%ROWTYPE;

  BEGIN

    write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INVOICE_SUMMARIES: Started: ' || i_company_code);

    v_inv_sum_flag := FALSE;

    -- Check to see whether there are any records to be processed.
    check_invoice_summary_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_inv_sum_hdr;
    FETCH csr_inv_sum_hdr INTO rv_inv_sum_hdr;
    WHILE csr_inv_sum_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 2, 'Validating Invoice Summary: ' || rv_inv_sum_hdr.fkdat || '/' || rv_inv_sum_hdr.bukrs || '/' || to_char(rv_inv_sum_hdr.hdrseq,'FM99999990'));
      validate_invoice_summary(i_log_level + 2, rv_inv_sum_hdr.fkdat, rv_inv_sum_hdr.bukrs,rv_inv_sum_hdr.hdrseq);

      FETCH csr_inv_sum_hdr INTO rv_inv_sum_hdr;
    END LOOP;
    CLOSE csr_inv_sum_hdr;
    COMMIT;

    -- Wake up all aggregation processors.
 --   IF v_inv_sum_flag = TRUE THEN
 --     write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'Waking up aggregation processor.');
 --     lics_pipe.spray(lics_constant.type_daemon,
 --                     ods_constants.queue_aggregate,
 --                   lics_constant.pipe_wake);
 --   END IF;

    write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INVOICE_SUMMARIES: Ended: ' || i_company_code);

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_inv_summ, 'n/a', 0, 'ODS_VALIDATION.CHECK_INVOICE_SUMMARIES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_invoice_summaries;



  /*******************************************************************************
    NAME:       CHECK_INVOICE_SUMMARY_TYPES
    PURPOSE:    This code checks to see is the various type included in the invoice
                summary records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_invoice_summary_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- Check to make sure that all the invoice type in the
    -- summary exist in the invoice type table
    CURSOR csr_invoice_type IS
      SELECT DISTINCT
        A.fkart
      FROM
        sap_inv_sum_det A,
        sap_inv_sum_hdr C
      WHERE
        C.valdtn_status = ods_constants.valdtn_unchecked
        AND C.fkdat = A.fkdat
        AND C.bukrs = A.vkorg
        AND C.hdrseq = A.hdrseq
        AND A.fkart NOT IN (SELECT
                              B.invc_type_code
                            FROM
                              invc_type B);
    rv_invoice_type csr_invoice_type%ROWTYPE;

  BEGIN

    -- Check to see if the invoice types in the summary exist in the invoice type table
    OPEN csr_invoice_type;
    LOOP
      FETCH csr_invoice_type INTO rv_invoice_type;
      EXIT WHEN csr_invoice_type%NOTFOUND;

      write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'Inserting Invoice Type: ' || rv_invoice_type.fkart || ' found in the Invoice Summary into the Invoice Type table.');

      append.append_invc_type_code(rv_invoice_type.fkart);

    END LOOP;
    CLOSE csr_invoice_type;

  END check_invoice_summary_types;



  /*******************************************************************************
    NAME:       VALIDATE_INVOICE_SUMMARY
    PURPOSE:    This code validates a invoice summary record, as specified by the
                input parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_invoice_summary(
    i_log_level       IN ods.log.log_level%TYPE,
    i_inv_creatn_date IN VARCHAR2,
    i_company_code    IN VARCHAR2,
    i_header_seq      IN PLS_INTEGER) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_inv_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER := 0;
    v_max_seq       PLS_INTEGER := 0;

    -- Cursor Declarations
    CURSOR csr_company IS
      SELECT
        *
      FROM
        company
      WHERE
        company_code = i_company_code
      FOR UPDATE NOWAIT;
    rv_company csr_company%ROWTYPE;

    CURSOR csr_inv_sum_hdr IS
      SELECT
        *
      FROM
        sap_inv_sum_hdr
      WHERE
        sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
        sap_inv_sum_hdr.bukrs = i_company_code AND
        procg_status <> ods_constants.inv_sum_loaded;
    rv_inv_sum_hdr csr_inv_sum_hdr%ROWTYPE;

    CURSOR csr_loaded_inv_sum_hdr IS
      SELECT
        *
      FROM
        sap_inv_sum_hdr
      WHERE
        sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
        sap_inv_sum_hdr.bukrs = i_company_code AND
        procg_status = ods_constants.inv_sum_loaded;
    rv_loaded_inv_sum_hdr  csr_loaded_inv_sum_hdr %ROWTYPE;

  BEGIN

    -- First thing, try and lock the company. This is done to ensure that there are no
    -- aggregations in progress. We should not try and replace an existing invoice summary
    -- if it is currently being used by an aggregation. If the company cannot be locked,
    -- then do nothing; simply do not process the invoice summary. When the aggregation does
    -- finish, it will trigger flag file creation, which will again trigger validation, to
    -- see whether there are any outstanding transactions to be processed.
    OPEN csr_company;
    FETCH csr_company INTO rv_company;
    IF csr_company%NOTFOUND THEN

      -- Clear the validation reason tables of this item
      utils.clear_validation_reason(ods_constants.valdtn_type_invoice_summary,
                                    i_inv_creatn_date,
                                    i_company_code,
                                    i_header_seq,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- If the record wasn't found, the company code is invalid.
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'Invoice Summary: ' || i_inv_creatn_date  || '/' || i_company_code || ': Invalid or non-existant Company Code.');

      UPDATE sap_inv_sum_hdr
      SET
        sap_inv_sum_hdr.valdtn_status = v_valdtn_status
      WHERE
        sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
        sap_inv_sum_hdr.bukrs = i_company_code AND
        sap_inv_sum_hdr.hdrseq = i_header_seq;

    ELSE

      -- Clear the validation reason tables of this invoice summary
      utils.clear_validation_reason(ods_constants.valdtn_type_invoice_summary,
                                    i_inv_creatn_date,
                                    i_company_code,
                                    i_header_seq,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Now that we've locked the company, we can only continue processing If no invoice
      -- summary exists with a status other than LOADED, OR if one does exist, it must have a status
      -- of COMPLETE or ERROR. This ensures that flag file has also finished with the invoice summary.
      OPEN csr_inv_sum_hdr;
      FETCH csr_inv_sum_hdr INTO rv_inv_sum_hdr;
      IF csr_inv_sum_hdr%NOTFOUND
         OR (csr_inv_sum_hdr%FOUND AND (rv_inv_sum_hdr.procg_status = ods_constants.inv_sum_complete
                                        OR rv_inv_sum_hdr.procg_status = ods_constants.inv_sum_error)) THEN

        -- Get the maximum sequence number for summaries with a status of LOADED. The summary
        -- with the maximum sequence number is treated as the next one to process. All the other
        -- summaries (with a status of LOADED) have been superseded and will be deleted.
        SELECT
          max(hdrseq) INTO v_max_seq
        FROM
          sap_inv_sum_hdr
        WHERE
          sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
          sap_inv_sum_hdr.bukrs = i_company_code AND
          procg_status = ods_constants.inv_sum_loaded;

        -- Read through all invoice summaries with a status of LOADED
        OPEN csr_loaded_inv_sum_hdr;
        FETCH csr_loaded_inv_sum_hdr INTO rv_loaded_inv_sum_hdr;
        LOOP
          EXIT WHEN csr_loaded_inv_sum_hdr%NOTFOUND;

          IF rv_loaded_inv_sum_hdr.hdrseq = v_max_seq THEN

            -- Check the company code for the new invoice summary.
            v_count := 0;
            SELECT
              count(*) INTO v_count
            FROM
              company
            WHERE
              company_code = rv_loaded_inv_sum_hdr.bukrs;
            IF v_count <> 1 THEN
              v_valdtn_status := ods_constants.valdtn_invalid;
              write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'Invoice Summary: ' || rv_loaded_inv_sum_hdr.fkdat || '/' || rv_loaded_inv_sum_hdr.bukrs || ': Invalid or non-existant Company Code.');

              -- Add an entry into the validation reason tables
              utils.add_validation_reason(ods_constants.valdtn_type_invoice_summary,
                                          'Invalid or non-existant Company Code.',
                                          ods_constants.valdtn_severity_critical,
                                          i_inv_creatn_date,
                                          i_company_code,
                                          i_header_seq,
                                          NULL,
                                          NULL,
                                          NULL,
                                          i_log_level + 1);
            END IF;

            -- Invoice Summary Creation Date must exist and be valid.
            v_count := 0;
            BEGIN
              SELECT
                COUNT(*) INTO v_count
              FROM
                mars_date
              WHERE
                yyyymmdd_date = to_number(rv_loaded_inv_sum_hdr.fkdat);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
            IF v_count <> 1 THEN                    -- There should be 1 valid date!
              v_valdtn_status := ods_constants.valdtn_invalid;
              write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'Invoice Summary: ' || rv_loaded_inv_sum_hdr.fkdat || '/' || rv_loaded_inv_sum_hdr.bukrs || ': Invalid, duplicate or non-existant Creation Date.');

              -- Add an entry into the validation reason tables
              utils.add_validation_reason(ods_constants.valdtn_type_invoice_summary,
                                          'Invalid, duplicate or non-existant Creation Date.',
                                          ods_constants.valdtn_severity_critical,
                                          i_inv_creatn_date,
                                          i_company_code,
                                          i_header_seq,
                                          NULL,
                                          NULL,
                                          NULL,
                                          i_log_level + 1);
            END IF;

            -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
            IF v_valdtn_status = ods_constants.valdtn_valid THEN

              -- DELETE the latest (non-LOADED) invoice summary
              IF csr_inv_sum_hdr%FOUND THEN

                -- Delete all the detail records associated with the latest invoice summary.
                DELETE FROM
                  sap_inv_sum_det
                WHERE
                  sap_inv_sum_det.fkdat = rv_inv_sum_hdr.fkdat AND
                  sap_inv_sum_det.vkorg = rv_inv_sum_hdr.bukrs AND
                  sap_inv_sum_det.hdrseq = rv_inv_sum_hdr.hdrseq;

                -- Delete the header record for the invoice summary.
                DELETE FROM
                  sap_inv_sum_hdr
                WHERE
                  sap_inv_sum_hdr.fkdat = rv_inv_sum_hdr.fkdat AND
                  sap_inv_sum_hdr.bukrs = rv_inv_sum_hdr.bukrs AND
                  sap_inv_sum_hdr.hdrseq = rv_inv_sum_hdr.hdrseq;

              END IF;

              -- The invoice summary is valid, so change its processing status as PROCESS and
              -- change the validation status to VALID.
              UPDATE sap_inv_sum_hdr
              SET
                sap_inv_sum_hdr.valdtn_status = v_valdtn_status,
                sap_inv_sum_hdr.procg_status = ods_constants.inv_sum_process
              WHERE
                sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
                sap_inv_sum_hdr.bukrs = i_company_code AND
                sap_inv_sum_hdr.hdrseq = rv_loaded_inv_sum_hdr.hdrseq;

              -- Set flag so that the aggregation processor will be woken up.
              v_inv_sum_flag := TRUE;

            ELSE

              write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 1, 'Invalid');

              -- The invoice summary is invalid, so leave its processing status as LOADED and
              -- change the validation status to INVALID.
              UPDATE sap_inv_sum_hdr
              SET
                sap_inv_sum_hdr.valdtn_status = v_valdtn_status
              WHERE
                sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
                sap_inv_sum_hdr.bukrs = i_company_code AND
                sap_inv_sum_hdr.hdrseq = rv_loaded_inv_sum_hdr.hdrseq;

            END IF;

          ELSE

            -- Delete all the detail records associated with this invoice summary.
            DELETE FROM
              sap_inv_sum_det
            WHERE
              sap_inv_sum_det.fkdat = i_inv_creatn_date AND
              sap_inv_sum_det.vkorg = i_company_code AND
              sap_inv_sum_det.hdrseq = rv_loaded_inv_sum_hdr.hdrseq;

            -- Delete the header record for the invoice summary.
            DELETE FROM
              sap_inv_sum_hdr
            WHERE
              sap_inv_sum_hdr.fkdat = i_inv_creatn_date AND
              sap_inv_sum_hdr.bukrs = i_company_code AND
              sap_inv_sum_hdr.hdrseq = rv_loaded_inv_sum_hdr.hdrseq;

          END IF;

          FETCH csr_loaded_inv_sum_hdr INTO rv_loaded_inv_sum_hdr;
        END LOOP;
        CLOSE csr_loaded_inv_sum_hdr;

      ELSE
        write_log(ods_constants.data_type_inv_summ, 'n/a', i_log_level + 2, 'SUMMARY PROCESSING BYPASSED: Summaries exist with status other than LOADED and/or COMPLETE.');
      END IF;
      CLOSE csr_inv_sum_hdr;

    END IF;
    CLOSE csr_company;
    COMMIT;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_invoice_summary;

  /*******************************************************************************
    NAME:       CHECK_FORECASTS
    PURPOSE:    This code reads through all forecast header records with a validation
                status of "UNCHECKED", and calls a routine to validate the header
                and detail records. The logic opens and closes the cursor before
                checking for each new group of records, so that if any additional
                records are written in while validation is occurring, then these
                are also validated.
  ********************************************************************************/
  PROCEDURE check_forecasts(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_forecast_hdr IS
      SELECT
        *
      FROM
        fcst_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_forecast_hdr csr_forecast_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_FORECASTS: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_forecast_hdr;
    FETCH csr_forecast_hdr INTO rv_forecast_hdr;
    WHILE csr_forecast_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 2, 'Validating Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code);
      validate_forecast(i_log_level + 2, rv_forecast_hdr.fcst_hdr_code);
      COMMIT;

      FETCH csr_forecast_hdr INTO rv_forecast_hdr;
    END LOOP;
    CLOSE csr_forecast_hdr;
    COMMIT;

    write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_FORECASTS: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_forecast, 'n/a', 0, 'ODS_VALIDATION.CHECK_FORECASTS: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_forecasts;

/*******************************************************************************
    NAME:       VALIDATE_FORECAST
    PURPOSE:    This code validates a forecast record, as specified by the input
                parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_forecast(
    i_log_level     IN ods.log.log_level%TYPE,
    i_fcst_hdr_code IN fcst_hdr.fcst_hdr_code%TYPE) IS

     -- VARIABLE DECLARATIONS
    v_valdtn_status fcst_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;
      v_fcst_hdr_casting_week NUMBER :=0;
      v_fcst_dtl_forecast_week NUMBER :=0;


    -- CURSOR DECLARATIONS
    -- Forecast Header
    CURSOR csr_forecast_hdr IS
      SELECT
        *
      FROM
        fcst_hdr
      WHERE
        fcst_hdr_code = i_fcst_hdr_code AND
        valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_forecast_hdr csr_forecast_hdr%ROWTYPE;

  BEGIN

    -- Validate the forecast header record.
    OPEN csr_forecast_hdr;
    FETCH csr_forecast_hdr INTO rv_forecast_hdr;
    IF csr_forecast_hdr%FOUND THEN

      -- Clear the validation reason tables of this item
      utils.clear_validation_reason(ods_constants.valdtn_type_forecast,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Sales Organisation must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        fcst_hdr a,
        sales_org_dim b
      WHERE
        a.fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code
        AND a.sales_org_code = b.sales_org_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or non-existant (Forecast Header) Sales Organisation.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or non-existant (Forecast Header) Sales Organisation.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Distribution Channel must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        fcst_hdr a,
        distbn_chnl_dim b
      WHERE
        a.fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code
        AND a.distbn_chnl_code = b.distbn_chnl_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or non-existant (Forecast Header) Distribution Channel.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or non-existant (Forecast Header) Distribution Channel.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Division must be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        fcst_hdr a
      WHERE
        a.fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code
        AND a.division_code IS NOT NULL
        AND a.division_code NOT IN (SELECT division_code FROM division_dim);
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Header) Division.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Header) Division.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Forecast type must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        fcst_type
      WHERE
        fcst_type_code = rv_forecast_hdr.fcst_type_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or non-existant (Forecast Header) Forecast Type.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or non-existant (Forecast Header) Forecast Type.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Company must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        company
      WHERE
        company_code = rv_forecast_hdr.company_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or non-existant (Forecast Header) Company.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or non-existant (Forecast Header) Company.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Moe code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        moe
      WHERE
        moe_code = rv_forecast_hdr.moe_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or non-existant (Forecast Header) MOE.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or non-existant (Forecast Header) MOE.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Current Forecast Flag must not be "I" Invalid, as this indicates that an issues was
      -- found reconciling number of lines, total quantity or total GSV from the details lines
      -- with the hash totals on the control records.
      IF rv_forecast_hdr.current_fcst_flag = 'I' THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Current Forecast Flag set to "I" - detail line imbalance to hash totals.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Record count, Quantity total or GSV total does not balance with hash totals.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Validate the forecast detail records. Note that forecast detail records are not
      -- individually validated. To validate Multi-Market Account (for example), a list of
      -- unique multi-market accounts is found for the forecast, and if any in the distinct
      -- list are invalid, then the forecast is invalid. This does not tell you which line
      -- in the forecast is invalid, but its required for the quick validation of forecasts.
      -- If individual line validation is required, implement this separately.

      -- Country must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT cntry_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND cntry_code IS NOT NULL) T1,
        cntry T2
      WHERE
        T1.cntry_code = T2.cntry_code(+) AND
        T2.cntry_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Country.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Country.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Region must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT cntry_code, region_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND region_code IS NOT NULL AND cntry_code IS NOT NULL) T1,
        region T2
      WHERE
        T1.cntry_code = T2.cntry_code(+) AND
        T1.region_code = T2.region_code(+) AND
        T2.region_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Country Region.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Country Region.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Currency must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT currcy_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code) T1,
        currcy T2
      WHERE
        T1.currcy_code = T2.currcy_code(+) AND
        T2.currcy_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Currency');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Currency.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Multi-Market Account must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT multi_mkt_acct_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND multi_mkt_acct_code IS NOT NULL) T1,
        multi_mkt_acct_dim T2
      WHERE
        T1.multi_mkt_acct_code = T2.multi_mkt_acct_code(+) AND
        T2.multi_mkt_acct_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Multi-Market Account.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Multi-Market Account.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Banner must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT banner_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND banner_code IS NOT NULL) T1,
        banner_dim T2
      WHERE
        T1.banner_code = T2.banner_code(+) AND
        T2.banner_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Banner.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Banner.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Customer Buying Group must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT cust_buying_grp_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND cust_buying_grp_code IS NOT NULL) T1,
        cust_buying_grp_dim T2
      WHERE
        T1.cust_buying_grp_code = T2.cust_buying_grp_code(+) AND
        T2.cust_buying_grp_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Customer Buying Group.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Customer Buying Group.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Account Assignment Group must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT acct_assgnmnt_grp_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND acct_assgnmnt_grp_code IS NOT NULL) T1,
        acct_assgnmnt_grp_dim T2
      WHERE
        T1.acct_assgnmnt_grp_code = T2.acct_assgnmnt_grp_code(+) AND
        T2.acct_assgnmnt_grp_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Account Assignment Group.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Account Assignment Group.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- POS Format Grouping must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT pos_format_grpg_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND pos_format_grpg_code IS NOT NULL) T1,
        pos_format_grpg_dim T2
      WHERE
        T1.pos_format_grpg_code = T2.pos_format_grpg_code(+) AND
        T2.pos_format_grpg_code IS NULL;
      IF v_count > 0 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) POS Format Grouping.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) POS Format Grouping.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Distribution Route must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT distbn_route_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND distbn_route_code IS NOT NULL) T1,
        distbn_route_dim T2
      WHERE
        T1.distbn_route_code = T2.distbn_route_code(+) AND
        T2.distbn_route_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Distribution Route.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Distribution Route.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Customer Code must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT cust_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND cust_code IS NOT NULL) T1,
        cust_dim T2
      WHERE
        T1.cust_code = T2.cust_code(+) AND
        T2.cust_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Customer.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Customer.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Material Code must exist and be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT matl_zrep_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND matl_zrep_code IS NOT NULL) T1,
        matl_dim T2
      WHERE
        T1.matl_zrep_code = T2.matl_code(+) AND
        T2.matl_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or Non-existant (Forecast Detail) Material.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or Non-existant (Forecast Detail) Material.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Material TDU Code must exist and be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT matl_tdu_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND matl_tdu_code IS NOT NULL) T1,
        matl_dim T2
      WHERE
        T1.matl_tdu_code = T2.matl_code(+) AND
        T2.matl_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Invalid or Non-existant (Forecast Detail) Material TDU Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Invalid or Non-existant (Forecast Detail) Material TDU Code.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;
      
      -- Forecast Detail Type Code must be valid.
      v_count := 0;
      SELECT
        COUNT(*) INTO v_count
      FROM
        (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT fcst_dtl_type_code
                FROM fcst_dtl  WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND fcst_dtl_type_code IS NOT NULL) T1,
        fcst_dtl_type T2
      WHERE
        T1.fcst_dtl_type_code = T2.fcst_dtl_type_code(+) AND
        T2.fcst_dtl_type_code IS NULL;
      IF v_count > 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Forecast Detail Type.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                    'Non-existant (Forecast Detail) Forecast Detail Type.',
                                    ods_constants.valdtn_severity_critical,
                                    i_fcst_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- If the forecast is of type FCST then do these extra validations.
      IF rv_forecast_hdr.fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

        -- Check the forecast header casting week is not null and is valid.
        IF rv_forecast_hdr.casting_week IS NULL THEN

             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' ||
             rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Header) Casting Week.');

                -- Add an entry into the validation reason tables
                utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                            'Non-existant (Forecast Header) Casting Week.',
                                            ods_constants.valdtn_severity_critical,
                                            i_fcst_hdr_code,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            i_log_level + 1);

        ELSE
          --Check to see if casting year, period and week is a valid mars date.
          v_count := 0;
          SELECT
            COUNT(*) INTO v_count
          FROM
             dds.mars_date_dim
          WHERE
            mars_week = rv_forecast_hdr.casting_year || LPAD(rv_forecast_hdr.casting_period,2,0) || rv_forecast_hdr.casting_week;

          IF v_count <= 0 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code
            || ': Invalid (Forecast Header) Casting Week.');

                 -- Add an entry into the validation reason tables
                 utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                            'Invalid (Forecast Header) Casting Week.',
                                            ods_constants.valdtn_severity_critical,
                                            i_fcst_hdr_code,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            i_log_level + 1);
          END IF;

        END IF; --End Casting week check

        -- Demand Planning node must be valid.
        v_count := 0;
        SELECT
           COUNT(*) INTO v_count
           FROM
           (SELECT /*+ INDEX(FCST_DTL FCST_DTL_PK) */ DISTINCT demand_plng_grp_code
            FROM fcst_dtl WHERE fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code AND demand_plng_grp_code IS NOT NULL) T1,
                demand_plng_grp_dim T2
              WHERE
                T1.demand_plng_grp_code= T2.demand_plng_grp_code(+) AND
                T2.demand_plng_grp_code IS NULL;

              IF v_count > 0 THEN
                v_valdtn_status := ods_constants.valdtn_invalid;
                write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' ||
                rv_forecast_hdr.fcst_hdr_code || ': Non-existant (Forecast Detail) Demand Planning Node.');

                -- Add an entry into the validation reason tables
                utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                            'Non-existant (Forecast Detail) Demand Planning Node.',
                                            ods_constants.valdtn_severity_critical,
                                            i_fcst_hdr_code,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            i_log_level + 1);
              END IF;

        -- Ensure Customer Code has a distinct demand group.
        v_count := 0;
        SELECT count(*) INTO v_count
        FROM (
          SELECT DISTINCT
            cust_code,
            sales_org_code,
                  distbn_chnl_code,
                  division_code,
            count(*)
          FROM (
            SELECT DISTINCT
                    b.cust_code,
                    b.demand_plng_grp_code,
                     a.sales_org_code,
                    a.distbn_chnl_code,
                    a.division_code
                  FROM
                    fcst_hdr a,
                    fcst_dtl b
                  WHERE
                     a.fcst_hdr_code = b.fcst_hdr_code
                    AND a.fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code
              AND b.cust_code IS NOT NULL)
          GROUP BY
            cust_code,
            sales_org_code,
              distbn_chnl_code,
              division_code
          HAVING count(*) > 1);

        IF v_count > 0 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' || rv_forecast_hdr.fcst_hdr_code || ': Customer Code does not have a distinct demand group.');

          -- Add an entry into the validation reason tables
          utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                              'Customer Code does not have a distinct demand group.',
                              ods_constants.valdtn_severity_critical,
                              i_fcst_hdr_code,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              NULL,
                              i_log_level + 1);
        END IF;

        -- Check to make sure Casting year, period and week is less than  the minimum FCST_DTL entry's Forecast year, period and week.
        v_fcst_hdr_casting_week := rv_forecast_hdr.casting_year || LPAD(rv_forecast_hdr.casting_period,2,0) || rv_forecast_hdr.casting_week;
        v_fcst_dtl_forecast_week := 0;

        -- Select the minimum forecast date from fcst_dtl and check it against the casting date.
        SELECT
           MIN(fcst_year || LPAD(fcst_period,2,0) || fcst_week) INTO v_fcst_dtl_forecast_week
         FROM
           fcst_dtl
         WHERE
           fcst_hdr_code = rv_forecast_hdr.fcst_hdr_code;

         IF v_fcst_hdr_casting_week >= v_fcst_dtl_forecast_week THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 1, 'Forecast Header: ' ||
            rv_forecast_hdr.fcst_hdr_code || ': Invalid (Forecast Header) Casting Week.');

              -- Add an entry into the validation reason tables
              utils.add_validation_reason(ods_constants.valdtn_type_forecast,
                                          'Invalid (Forecast Header) Casting Week.',
                                          ods_constants.valdtn_severity_critical,
                                          i_fcst_hdr_code,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          i_log_level + 1);

         END IF;

      END IF; -- End FCST type check

      -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
      write_log(ods_constants.data_type_forecast, 'n/a', i_log_level + 2, 'Forecast Header: ' || i_fcst_hdr_code || ' is ' || v_valdtn_status);
      UPDATE fcst_hdr
      SET
        valdtn_status = v_valdtn_status
      WHERE
        CURRENT OF csr_forecast_hdr;

    END IF;
    CLOSE csr_forecast_hdr;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_forecast;

/*******************************************************************************
    NAME:       CHECK_PRODN_PLAN
    PURPOSE:    This code reads through all production plan header records with a
                validation status of "UNCHECKED", and calls a routine to validate
                the header and detail records. The logic opens and closes the cursor
                before checking for each new group of records, so that if any additional
                records are written in while validation is occurring, then these
                are also validated.
  ********************************************************************************/
  PROCEDURE check_prodn_plan(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_prodn_plan_hdr IS
      SELECT
        *
      FROM
        prodn_plan_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_prodn_plan_hdr csr_prodn_plan_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PRODN_PLAN: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_prodn_plan_hdr;
    FETCH csr_prodn_plan_hdr INTO rv_prodn_plan_hdr;
    WHILE csr_prodn_plan_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 2, 'Validating Production Plan Header: ' || rv_prodn_plan_hdr.prodn_plan_hdr_code);
      validate_prodn_plan(i_log_level + 2, rv_prodn_plan_hdr.prodn_plan_hdr_code);
      COMMIT;

      FETCH csr_prodn_plan_hdr INTO rv_prodn_plan_hdr;
    END LOOP;
    CLOSE csr_prodn_plan_hdr;
    COMMIT;

    write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PRODN_PLAN: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', 0, 'ODS_VALIDATION.CHECK_PRODN_PLAN: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_prodn_plan;


 /*******************************************************************************
    NAME:       VALIDATE_PRODN_PLAN
    PURPOSE:    This code validates a production plan record, as specified by the
                input parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_prodn_plan(
    i_log_level     IN ods.log.log_level%TYPE,
    i_prodn_plan_hdr_code IN prodn_plan_hdr.prodn_plan_hdr_code%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status prodn_plan_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count    PLS_INTEGER;
    v_pk_count NUMBER := 0;

    -- CURSOR DECLARATIONS
    -- Production Plan Header
    CURSOR csr_prodn_plan IS
      SELECT
        *
      FROM
        prodn_plan_hdr
      WHERE
        prodn_plan_hdr_code = i_prodn_plan_hdr_code AND
        valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_prodn_plan csr_prodn_plan%ROWTYPE;

  BEGIN
    write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Starting validate_prodn_plan.');

    -- Validate the Production Plan header record.
    OPEN csr_prodn_plan;
    FETCH csr_prodn_plan INTO rv_prodn_plan;
    IF csr_prodn_plan%FOUND THEN

      -- Clear the validation reason tables of this item
      utils.clear_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                    i_prodn_plan_hdr_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

    -- Material Code must exist and be valid.
    v_count := 0;
    SELECT
      COUNT(*) INTO v_count
    FROM
      prodn_plan_dtl t01,
      matl_dim t02
    WHERE
      t01.matl_code = t02.matl_code(+) AND
      t01.prodn_plan_hdr_code = rv_prodn_plan.prodn_plan_hdr_code AND
      t02.matl_code IS NULL;
    IF v_count > 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Detail: ' || rv_prodn_plan.prodn_plan_hdr_code || ' : Invalid or Non-existant (Production Plan Detail) Material.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                  'Invalid or Non-existant (Production Plan Detail) Material.',
                                  ods_constants.valdtn_severity_critical,
                                  i_prodn_plan_hdr_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Plant Code must exist and be valid.
    v_count := 0;
    SELECT
      COUNT(*) INTO v_count
    FROM
      prodn_plan_dtl t01,
      plant_dim t02
    WHERE
      t01.plant_code = t02.plant_code(+) AND
      t01.prodn_plan_hdr_code = rv_prodn_plan.prodn_plan_hdr_code AND
      t02.plant_code IS NULL;
    IF v_count > 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Detail: ' || rv_prodn_plan.prodn_plan_hdr_code || ' : Invalid or Non-existant (Production Plan Detail) Plant.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                  'Invalid or Non-existant (Production Plan Detail) Plant.',
                                  ods_constants.valdtn_severity_critical,
                                  i_prodn_plan_hdr_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Production Plan week must exist and be valid.
    v_count := 0;
   SELECT
     COUNT(*) INTO v_count
   FROM
     (SELECT DISTINCT
        prodn_plan_week
      FROM
        prodn_plan_dtl
      WHERE
        prodn_plan_hdr_code = rv_prodn_plan.prodn_plan_hdr_code) T1,
     dds.mars_date_dim T2
   WHERE
     T1.prodn_plan_week = T2.mars_week(+) AND
     T2.mars_week IS NULL;
   IF v_count > 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Detail ' || rv_prodn_plan.prodn_plan_hdr_code || ': Invalid (Production Plan Detail) Production Plan Week.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                 'Invalid (Production Plan Detail) Production Plan Week.',
                                 ods_constants.valdtn_severity_critical,
                                 i_prodn_plan_hdr_code,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 i_log_level + 1);
    END IF; --End Production Plan week check

    -- Check to see if casting year is a valid mars date.
    v_count := 0;
    SELECT
      COUNT(*) INTO v_count
    FROM
      dds.mars_date_dim
    WHERE
      mars_year = rv_prodn_plan.casting_year;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Header ' || rv_prodn_plan.prodn_plan_hdr_code
      || ': Invalid (Production Plan Header) Casting Year.');

       -- Add an entry into the validation reason tables
       utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                  'Invalid (Production Plan Header) Casting Year.',
                                  ods_constants.valdtn_severity_critical,
                                  i_prodn_plan_hdr_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF; --End Casting Year check

    -- Check to see if casting period is a valid mars date.
    v_count := 0;
    SELECT
      COUNT(*) INTO v_count
    FROM
      dds.mars_date_dim
    WHERE
      mars_period = rv_prodn_plan.casting_year || LPAD(rv_prodn_plan.casting_period,2,0);
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Header ' || rv_prodn_plan.prodn_plan_hdr_code
      || ': Invalid (Production Plan Header) Casting Period.');

       -- Add an entry into the validation reason tables
       utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                  'Invalid (Production Plan Header) Casting Period.',
                                  ods_constants.valdtn_severity_critical,
                                  i_prodn_plan_hdr_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF; --End Casting Period check

    -- If the production plan is of type FCST then do these extra validations.
    IF rv_prodn_plan.prodn_plan_type_code = ods_constants.fcst_type_fcst_weekly THEN

      -- If casting week exists check if its valid.
      IF rv_prodn_plan.casting_week IS NULL THEN
        write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Header ' || rv_prodn_plan.prodn_plan_hdr_code
        || ': Missing (Production Plan Header) Casting Week.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                    'Missing (Production Plan Header) Casting Week.',
                                     ods_constants.valdtn_severity_critical,
                                     i_prodn_plan_hdr_code,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
      ELSE
        -- Check to see if casting week is a valid mars date.
        v_count := 0;
        SELECT
          COUNT(*) INTO v_count
        FROM
          dds.mars_date_dim
        WHERE
          mars_week = rv_prodn_plan.casting_year || LPAD(rv_prodn_plan.casting_period,2,0) || rv_prodn_plan.casting_week ;
        IF v_count = 0 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan Header ' || rv_prodn_plan.prodn_plan_hdr_code
          || ': Invalid (Production Plan Header) Casting Week.');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                      'Invalid (Production Plan Header) Casting Week.',
                                      ods_constants.valdtn_severity_critical,
                                      i_prodn_plan_hdr_code,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
        END IF;
      END IF;

    END IF;--End Casting week check

    -- Count records to ensure surrogate primary key has been inforced.
    v_count := 0;
    v_pk_count := 0;
    SELECT
      COUNT(*) INTO v_count
    FROM
      prodn_plan_dtl
    WHERE
      prodn_plan_hdr_code = i_prodn_plan_hdr_code;

    SELECT
      COUNT(*) INTO v_pk_count
    FROM
      (SELECT DISTINCT
         t01.prodn_plan_type_code,
         t01.moe_code,
         t01.casting_week,
         t02.prodn_plan_week,
         t02.plant_code,
         t02.matl_code
       FROM
         prodn_plan_hdr t01,
         prodn_plan_dtl t02
       WHERE
         t01.prodn_plan_hdr_code = t02.prodn_plan_hdr_code AND
         t02.prodn_plan_hdr_code = i_prodn_plan_hdr_code);
    IF v_count <> v_pk_count THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 1, 'Production Plan violates pseudo primary key, thus is INVALID.');

       -- Add an entry into the validation reason tables
       utils.add_validation_reason(ods_constants.valdtn_type_prodn_plan,
                                  'Surrogate Key Constraint. Total Records [' || v_count || '], Total Surrogate Key Records [' || v_pk_count || '].',
                                  ods_constants.valdtn_severity_critical,
                                  i_prodn_plan_hdr_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF; --End of PK count

    -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
    write_log(ods_constants.data_type_prodn_plan, 'n/a', i_log_level + 2, 'Production Plan Header: ' || rv_prodn_plan.prodn_plan_hdr_code || ' is ' || v_valdtn_status);
    UPDATE prodn_plan_hdr
    SET
      valdtn_status = v_valdtn_status
    WHERE
      CURRENT OF csr_prodn_plan;

    END IF;
    CLOSE csr_prodn_plan;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_prodn_plan;

/*******************************************************************************
    NAME:       check_proc_plan_order
    PURPOSE:    This code reads through all process and planned order header records
                with a validation status of "UNCHECKED", and calls a routine to
                validate the header and detail records. The logic opens and closes
                the cursor before checking for each new group of records, so that
                if any additional records are written in while validation is
                occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_proc_plan_order(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_prodn_plan_hdr IS
      SELECT
        order_id
      FROM
        sap_ppo_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_prodn_plan_hdr csr_prodn_plan_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PROC_PLAN_ORDER: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_prodn_plan_hdr;
    FETCH csr_prodn_plan_hdr INTO rv_prodn_plan_hdr;
    WHILE csr_prodn_plan_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 2, 'Validating Process and Planned Order: ' || rv_prodn_plan_hdr.order_id);
      validate_proc_plan_order(i_log_level + 2, rv_prodn_plan_hdr.order_id);
      COMMIT;

      FETCH csr_prodn_plan_hdr INTO rv_prodn_plan_hdr;
    END LOOP;
    CLOSE csr_prodn_plan_hdr;
    COMMIT;

    write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PROC_PLAN_ORDER: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', 0, 'ODS_VALIDATION.CHECK_PROC_PLAN_ORDER: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_proc_plan_order;

 /*******************************************************************************
    NAME:       VALIDATE_PROC_PLAN_ORDER
    PURPOSE:    This code validates a process and planned order record, as specified by the
                input parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_proc_plan_order(
    i_log_level IN ods.log.log_level%TYPE,
    i_order_id IN sap_ppo_hdr.order_id%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_ppo_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count    PLS_INTEGER;
    v_pk_count NUMBER := 0;
    v_time     NUMBER := 0;

    -- CURSOR DECLARATIONS
    -- Process and Planned Orders Header
    CURSOR csr_proc_plan_order IS
      SELECT
        *
      FROM
        sap_ppo_hdr
      WHERE
        order_id = i_order_id AND
        valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_proc_plan_order csr_proc_plan_order%ROWTYPE;

  BEGIN
    -- Validate the Process and Planned Orders header record.
    OPEN csr_proc_plan_order;
    FETCH csr_proc_plan_order INTO rv_proc_plan_order;
    IF csr_proc_plan_order%FOUND THEN

      -- Clear the validation reason tables of this item ods_constants.valdtn_type_prodn_plan
      utils.clear_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                    i_order_id,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

    -- Company Code (Process and Planned Orders) must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_ppo_hdr t01,
      company     t02
    WHERE
      t01.order_id = rv_proc_plan_order.order_id
      AND t01.coco = t02.company_code(+)
      AND t02.company_code IS NULL;
    IF v_count > 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'Process and Planned Orders: ' || rv_proc_plan_order.order_id || ': Invalid or non-existant (sap_ppo_hdr) Company Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                  'Invalid or non-existant (sap_ppo_hdr) Company Code.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_proc_plan_order.order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Material Code must exist and be valid.
    v_count := 0;
    SELECT
      COUNT(*) INTO v_count
    FROM
      sap_ppo_hdr t01,
      sap_mat_hdr t02
    WHERE
      t01.order_id = rv_proc_plan_order.order_id
      AND t01.item = t02.matnr
      AND t02.valdtn_status = ods_constants.valdtn_valid;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'Process and planned orders header: ' || rv_proc_plan_order.order_id || ': Invalid or Non-existant (sap_ppo_hdr) Material.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                  'Invalid or Non-existant (sap_ppo_hdr) Material.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_proc_plan_order.order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Any non-null material must have a valid weight UOM.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_ppo_hdr t01,
      sap_mat_uom t02
    WHERE
      t01.order_id = rv_proc_plan_order.order_id
      AND t01.item = t02.matnr
      AND t01.uom = t02.meinh;
    IF v_count = 0 THEN                    -- There should not be invalid UOMs.
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'Process and Planned Order: ' || rv_proc_plan_order.order_id || ': Has invalid or missing weight UOM code(s).');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                  'Has invalid or missing weight UOM code(s) (sap_ppo_hdr).',
                                  ods_constants.valdtn_severity_critical,
                                  rv_proc_plan_order.order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Validate the start date
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      mars_date
    WHERE
      yyyymmdd_date = SUBSTR(rv_proc_plan_order.start_date_time, 0, 8);
    IF v_count = 0 THEN                    -- There should not be an invalid date.
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'Process and Planned Order: ' || rv_proc_plan_order.order_id || ': Has invalid Start Date.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                  'Has invalid or missing start date (sap_ppo_hdr).',
                                  ods_constants.valdtn_severity_critical,
                                  rv_proc_plan_order.order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Validate the end date
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      mars_date
    WHERE
      yyyymmdd_date = SUBSTR(rv_proc_plan_order.end_date_time, 0, 8);
    IF v_count = 0 THEN                    -- There should not be an invalid date.
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'Process and Planned Order: ' || rv_proc_plan_order.order_id || ': Has invalid End Date.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                  'Has invalid or missing end date (sap_ppo_hdr).',
                                  ods_constants.valdtn_severity_critical,
                                  rv_proc_plan_order.order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Check that Purchase Order UOM exists in conversion table.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_ppo_hdr t01,
      sap_mat_hdr t02,
      sap_mat_uom t03
    WHERE
      t01.order_id = rv_proc_plan_order.order_id
      AND t01.item = t02.matnr
      AND t02.matnr = t03.matnr
      AND t01.uom = t03.meinh
      AND t02.valdtn_status = ods_constants.valdtn_valid;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 1, 'Process and Planned Order: ' || rv_proc_plan_order.order_id || ': Invalid or non-existant (sap_ppo_hdr) UOM code for material.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_proc_plan_order,
                                 'Invalid or non-existant (sap_ppo_hdr) UOM code for material.',
                                 ods_constants.valdtn_severity_critical,
                                 rv_proc_plan_order.order_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 i_log_level + 1);
    END IF;

    -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
    write_log(ods_constants.data_type_proc_plan_order, 'n/a', i_log_level + 2, 'Process and Planned Orders Header: ' || rv_proc_plan_order.order_id || ' is ' || v_valdtn_status);
    UPDATE sap_ppo_hdr
    SET
      valdtn_status = v_valdtn_status
    WHERE
      CURRENT OF csr_proc_plan_order;

    END IF;
    CLOSE csr_proc_plan_order;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_proc_plan_order;

/*******************************************************************************
    NAME:       check_purch_order_bifg
    PURPOSE:    This code reads through all open purchase orders for finished goods
                with a validation status of "UNCHECKED", and calls a routine to
                validate the header and detail records. The logic opens and closes
                the cursor before checking for each new group of records, so that
                if any additional records are written in while validation is
                occurring, then these are also validated.
  ********************************************************************************/
  PROCEDURE check_purch_order_bifg(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_sap_opr_hdr IS
      SELECT
        order_num, order_item
      FROM
        sap_opr_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_sap_opr_hdr csr_sap_opr_hdr%ROWTYPE;

  BEGIN

    write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PURCH_ORDER_BIFG: Started.');

    -- Check to see whether there are any records that need to be processed.
    OPEN csr_sap_opr_hdr;
    FETCH csr_sap_opr_hdr INTO rv_sap_opr_hdr;
    WHILE csr_sap_opr_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 2, 'Validating Purchase Orders BIFG: ' || rv_sap_opr_hdr.order_num || ' line item ' || rv_sap_opr_hdr.order_item);
      validate_purch_order_bifg(i_log_level + 2, rv_sap_opr_hdr.order_num, rv_sap_opr_hdr.order_item);
      COMMIT;

      FETCH csr_sap_opr_hdr INTO rv_sap_opr_hdr;
    END LOOP;
    CLOSE csr_sap_opr_hdr;
    COMMIT;

    write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_PURCH_ORDER_BIFG: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', 0, 'ODS_VALIDATION.CHECK_PURCH_ORDER_BIFG: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_purch_order_bifg;

 /*******************************************************************************
    NAME:       VALIDATE_PURCH_ORDER_BIFG
    PURPOSE:    This code validates a purchase order BIFG record, as specified by the
                input parameter, and updates the status on the record accordingly.
  ********************************************************************************/
  PROCEDURE validate_purch_order_bifg(
    i_log_level IN ods.log.log_level%TYPE,
    i_order_num IN sap_opr_hdr.order_num%TYPE,
    i_order_item IN sap_opr_hdr.order_item%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_opr_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count    PLS_INTEGER;


    -- CURSOR DECLARATIONS
    -- BIFG Header
    CURSOR csr_purch_order_bifg IS
      SELECT
        *
      FROM
        sap_opr_hdr
      WHERE
        order_num = i_order_num AND
        order_item = i_order_item AND
        valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_purch_order_bifg csr_purch_order_bifg%ROWTYPE;

  BEGIN
    -- Validate the BIFG header record.
    OPEN csr_purch_order_bifg;
    FETCH csr_purch_order_bifg INTO rv_purch_order_bifg;
    IF csr_purch_order_bifg%FOUND THEN

      -- Clear the validation reason tables of this item
      utils.clear_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                    rv_purch_order_bifg.order_num,
                                    rv_purch_order_bifg.order_item,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

    -- Company Code (BIFG) must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_opr_hdr t01,
      company     t02
    WHERE
      t01.order_num = rv_purch_order_bifg.order_num
      AND t01.order_item = rv_purch_order_bifg.order_item
      AND t01.co_code = t02.company_code(+)
      AND t02.company_code IS NULL;
    IF v_count > 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'BIFG: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Invalid or non-existant (sap_ppo_hdr) Company Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                  'Invalid or non-existant (sap_opr_hdr) Company Code.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_purch_order_bifg.order_num,
                                  rv_purch_order_bifg.order_item,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Material Code must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_opr_hdr t01,
      sap_mat_hdr t02
    WHERE
      t01.order_num = rv_purch_order_bifg.order_num
      AND t01.order_item = rv_purch_order_bifg.order_item
      AND t01.material = t02.matnr
      AND t02.valdtn_status = ods_constants.valdtn_valid;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'BIFG header: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Invalid or Non-existant (sap_opr_hdr) Material.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                  'Invalid or Non-existant (sap_opr_hdr) Material.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_purch_order_bifg.order_num,
                                  rv_purch_order_bifg.order_item,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Any non-null material must have a valid UOM.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_opr_hdr t01,
      sap_mat_uom t02
    WHERE
      t01.order_num = rv_purch_order_bifg.order_num
      AND t01.order_item = rv_purch_order_bifg.order_item
      AND t01.material = t02.matnr
      AND t01.uom = t02.meinh;
    IF v_count = 0 THEN                    -- A valid UOM will be found
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'BIFG header: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Has invalid or missing weight UOM code(s).');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                  'Has invalid missing weight (sap_ppo_hdr) UOM code(s).',
                                  ods_constants.valdtn_severity_critical,
                                  rv_purch_order_bifg.order_num,
                                  rv_purch_order_bifg.order_item,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Validate the expected delivery date (opr_date)
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      mars_date
    WHERE
      yyyymmdd_date = rv_purch_order_bifg.opr_date;
    IF v_count = 0 THEN                    -- Expected delivery date (opr_date) should be in the MARS_DATE table.
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'Purchase Order BIFG: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Has invalid OPR_DATE (expected dlvry date).');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                  'Has invalid or missing (sap_opr_hdr) opr_date.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_purch_order_bifg.order_num,
                                  rv_purch_order_bifg.order_item,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Target Plant must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_opr_hdr t01,
      plant t02
    WHERE
      t01.order_num = rv_purch_order_bifg.order_num
      AND t01.order_item = rv_purch_order_bifg.order_item
      AND t01.plant = t02.plant_code
      AND t02.valdtn_status = ods_constants.valdtn_valid;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'BIFG: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Invalid or non-existant (sap_ppo_hdr) Target Plant Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                 'Invalid or non-existant (sap_opr_hdr) Target Plant Code.',
                                 ods_constants.valdtn_severity_critical,
                                 rv_purch_order_bifg.order_num,
                                 rv_purch_order_bifg.order_item,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 i_log_level + 1);
    END IF;

    -- Target Storage Location must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_opr_hdr t01,
      storage_locn t02
    WHERE
      t01.order_num = rv_purch_order_bifg.order_num
      AND t01.order_item = rv_purch_order_bifg.order_item
      AND t01.plant = t02.plant_code
      AND t01.sto_location = t02.storage_locn_code
      AND t02.valdtn_status = ods_constants.valdtn_valid;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'BIFG: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Invalid or non-existant (sap_ppo_hdr) Target Storage Location Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                 'Invalid or non-existant (sap_opr_hdr) Target Storage Location Code',
                                 ods_constants.valdtn_severity_critical,
                                 rv_purch_order_bifg.order_num,
                                 rv_purch_order_bifg.order_item,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 i_log_level + 1);
    END IF;

    -- Check that Purchase Order UOM exists in conversion table.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      sap_opr_hdr t01,
      sap_mat_hdr t02,
      sap_mat_uom t03
    WHERE
      t01.order_num = rv_purch_order_bifg.order_num
      AND t01.order_item = rv_purch_order_bifg.order_item
      AND t01.material = t02.matnr
      AND t02.matnr = t03.matnr
      AND t01.uom = t03.meinh
      AND t02.valdtn_status = ods_constants.valdtn_valid;
    IF v_count = 0 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 1, 'BIFG: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ': Invalid or non-existant (sap_opr_hdr) UOM code for material.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_purch_order_bifg,
                                 'Invalid or non-existant (sap_opr_hdr) UOM code for material.',
                                 ods_constants.valdtn_severity_critical,
                                 rv_purch_order_bifg.order_num,
                                 rv_purch_order_bifg.order_item,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 i_log_level + 1);
    END IF;


    -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
    write_log(ods_constants.data_type_purch_order_bifg, 'n/a', i_log_level + 2, 'BIFG Header: ' || rv_purch_order_bifg.order_num || ' line item' || rv_purch_order_bifg.order_item || ' is ' || v_valdtn_status);
    UPDATE sap_opr_hdr
    SET
      valdtn_status = v_valdtn_status
    WHERE
      CURRENT OF csr_purch_order_bifg;

    END IF;
    CLOSE csr_purch_order_bifg;

  EXCEPTION
    WHEN resource_busy THEN           -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_purch_order_bifg;


/*******************************************************************************
    NAME:       CHECK_INVENTORY_BALANCE
    PURPOSE:    This code reads through all inventory balance header records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the header and detail records. The logic opens and closes the
                cursor before checking for each new group of records, so that if
                any additional records are written in while validation is occurring,
                then these are also validated.
  ********************************************************************************/
  PROCEDURE check_inventory_balance(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_inv_bal_hdr IS
      SELECT
        *
      FROM
        sap_stk_bal_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_inv_bal_hdr csr_inv_bal_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INVENTORY_BALANCE: Started.');

    check_inventory_balance_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_inv_bal_hdr;
    FETCH csr_inv_bal_hdr INTO rv_inv_bal_hdr;
    WHILE csr_inv_bal_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 2, 'Validating Inventory Balance Header: ' || rv_inv_bal_hdr.bukrs || '/'
                                                                                                                  || rv_inv_bal_hdr.werks || '/'
                                                                                                                  || rv_inv_bal_hdr.lgort || '/'
                                                                                                                  || rv_inv_bal_hdr.budat || '/'
                                                                                                                  || rv_inv_bal_hdr.timlo);
      validate_inventory_balance(i_log_level + 2, rv_inv_bal_hdr.bukrs,
                                                  rv_inv_bal_hdr.werks,
                                                  rv_inv_bal_hdr.lgort,
                                                  rv_inv_bal_hdr.budat,
                                                  rv_inv_bal_hdr.timlo);
      COMMIT;

      FETCH csr_inv_bal_hdr INTO rv_inv_bal_hdr;
    END LOOP;
    CLOSE csr_inv_bal_hdr;
    COMMIT;

    write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INVENTORY_BALANCE: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_inv_baln, 'n/a', 0, 'ODS_VALIDATION.CHECK_INVENTORY_BALANCE: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_inventory_balance;



  /*******************************************************************************
    NAME:       CHECK_INVENTORY_BALANCE_TYPES
    PURPOSE:    This code checks to see is the various type included in the
                inventory_balance records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_inventory_balance_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- CURSORS
    CURSOR csr_inventory_type IS
      SELECT DISTINCT
        B.insmk AS inventory_type_code
      FROM
        sap_stk_bal_hdr A,
        sap_stk_bal_det B
      WHERE
        A.bukrs = B.bukrs AND
        A.werks = B.werks AND
        A.lgort = B.lgort AND
        A.budat = B.budat AND
        A.timlo = B.timlo AND
        A.valdtn_status = ods_constants.valdtn_unchecked AND
        B.insmk NOT IN (SELECT
                          inv_type_code
                        FROM
                          inv_type);
    rv_inventory_type csr_inventory_type%ROWTYPE;

  BEGIN
    OPEN csr_inventory_type;
    LOOP
      FETCH csr_inventory_type INTO rv_inventory_type;
      EXIT WHEN csr_inventory_type%NOTFOUND;

      write_log(ods_constants.data_type_inventory, 'n/a', i_log_level + 1, 'Inserting Inventory Type: ' || rv_inventory_type.inventory_type_code || ' found in the Inventory Balance record into the Inventory Type table.');

      append.append_inv_type_code(rv_inventory_type.inventory_type_code);

    END LOOP;
    CLOSE csr_inventory_type;
  END check_inventory_balance_types;


/*******************************************************************************
    NAME:       VALIDATE_INVENTORY_BALANCE
    PURPOSE:    This code validates a inventory balance record, as specified by the
                input parameter, and updates the status on the record accordingly.
  ********************************************************************************/
   PROCEDURE validate_inventory_balance(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN sap_stk_bal_hdr.bukrs%TYPE,
    i_plant_code        IN sap_stk_bal_hdr.werks%TYPE,
    i_storage_locn_code IN sap_stk_bal_hdr.lgort%TYPE,
    i_balance_date      IN sap_stk_bal_hdr.budat%TYPE,
    i_balance_time      IN sap_stk_bal_hdr.timlo%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_stk_bal_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    -- Inventory Balance Header
    CURSOR csr_inv_bal_det IS
      SELECT
        *
      FROM
        sap_stk_bal_det a
      WHERE
        bukrs = i_company_code AND
        werks = i_plant_code AND
        lgort = i_storage_locn_code AND
        budat = i_balance_date AND
        timlo = i_balance_time
      FOR UPDATE NOWAIT;
    rv_inv_bal_det csr_inv_bal_det%ROWTYPE;

  BEGIN

    -- Clear the validation reason tables of this inventory balance
    utils.clear_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                  i_company_code,
                                  i_plant_code,
                                  i_storage_locn_code,
                                  i_balance_date,
                                  i_balance_time,
                                  NULL,
                                  i_log_level + 1);

    -- Company must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      company_dim a
    WHERE
      a.company_code = i_company_code;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                          i_company_code      || '/' ||
                                                                          i_plant_code        || '/' ||
                                                                          i_storage_locn_code || '/' ||
                                                                          i_balance_date      || '/' ||
                                                                          i_balance_time      ||
                                                                          ': Invalid or non-existant Company Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                  'Invalid or non-existant Company.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_plant_code,
                                  i_storage_locn_code,
                                  i_balance_date,
                                  i_balance_time,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Plant must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      plant a
    WHERE
      a.plant_code = i_plant_code; --AND
      --b.valdtn_status = ods_constants.valdtn_valid;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                          i_company_code      || '/' ||
                                                                          i_plant_code        || '/' ||
                                                                          i_storage_locn_code || '/' ||
                                                                          i_balance_date      || '/' ||
                                                                          i_balance_time      ||
                                                                          ': Invalid or non-existant Plant Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                  'Invalid or non-existant Plant.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_plant_code,
                                  i_storage_locn_code,
                                  i_balance_date,
                                  i_balance_time,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Storage Location must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      storage_locn a
    WHERE
      a.plant_code        = i_plant_code AND
      a.storage_locn_code = i_storage_locn_code AND
      a.valdtn_status     = ods_constants.valdtn_valid;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                          i_company_code      || '/' ||
                                                                          i_plant_code        || '/' ||
                                                                          i_storage_locn_code || '/' ||
                                                                          i_balance_date      || '/' ||
                                                                          i_balance_time      ||
                                                                          ': Invalid or non-existant Storage Location Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                  'Invalid or non-existant Storage Location.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_plant_code,
                                  i_storage_locn_code,
                                  i_balance_date,
                                  i_balance_time,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Inventory Balance Date must be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      mars_date a
    WHERE
      TRUNC(a.calendar_date, 'DD') = TRUNC(TO_DATE(i_balance_date, 'YYYYMMDD'), 'DD');
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                          i_company_code      || '/' ||
                                                                          i_plant_code        || '/' ||
                                                                          i_storage_locn_code || '/' ||
                                                                          i_balance_date      || '/' ||
                                                                          i_balance_time      ||
                                                                          ': Invalid Inventory Balance Date.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                  'Invalid Inventory Balance Date.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_plant_code,
                                  i_storage_locn_code,
                                  i_balance_date,
                                  i_balance_time,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Inventory Balance Time must be valid.
    IF (i_balance_time < 0 OR i_balance_time >= 240000) THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                          i_company_code      || '/' ||
                                                                          i_plant_code        || '/' ||
                                                                          i_storage_locn_code || '/' ||
                                                                          i_balance_date      || '/' ||
                                                                          i_balance_time      ||
                                                                          ': Invalid Inventory Balance Time.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                  'Invalid Inventory Balance Time.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_plant_code,
                                  i_storage_locn_code,
                                  i_balance_date,
                                  i_balance_time,
                                  NULL,
                                  i_log_level + 1);
    END IF;


      -- Validate the Inventory Balance header record.
    OPEN csr_inv_bal_det;
    FETCH csr_inv_bal_det INTO rv_inv_bal_det;
    WHILE csr_inv_bal_det%FOUND LOOP

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_stk_bal_det a
      WHERE
        a.bukrs = i_company_code AND
        a.werks = i_plant_code AND
        a.lgort = i_storage_locn_code AND
        a.budat = i_balance_date AND
        a.timlo = i_balance_time AND
        a.detseq = rv_inv_bal_det.detseq AND
        a.matnr IS NULL;
      IF v_count <> 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                            i_company_code      || '/' ||
                                                                            i_plant_code        || '/' ||
                                                                            i_storage_locn_code || '/' ||
                                                                            i_balance_date      || '/' ||
                                                                            i_balance_time      ||
                                                                            ': Null Material.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                    'Null Material.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_plant_code,
                                    i_storage_locn_code,
                                    i_balance_date,
                                    i_balance_time,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_stk_bal_det a,
        sap_mat_hdr     b
      WHERE
        a.bukrs = i_company_code AND
        a.werks = i_plant_code AND
        a.lgort = i_storage_locn_code AND
        a.budat = i_balance_date AND
        a.timlo = i_balance_time AND
        a.detseq = rv_inv_bal_det.detseq AND
        a.matnr = b.matnr AND
        b.valdtn_status = ods_constants.valdtn_valid;
      IF v_count = 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                            i_company_code      || '/' ||
                                                                            i_plant_code        || '/' ||
                                                                            i_storage_locn_code || '/' ||
                                                                            i_balance_date      || '/' ||
                                                                            i_balance_time      ||
                                                                            ': Non-Valid Material.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                    'Non-Valid Material.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_plant_code,
                                    i_storage_locn_code,
                                    i_balance_date,
                                    i_balance_time,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Quantity must be null.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_stk_bal_det a
      WHERE
        a.bukrs = i_company_code AND
        a.werks = i_plant_code AND
        a.lgort = i_storage_locn_code AND
        a.budat = i_balance_date AND
        a.timlo = i_balance_time AND
        a.detseq = rv_inv_bal_det.detseq AND
        a.menga IS NULL;
      IF v_count <> 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 1, 'Inventory Balance Header: ' ||
                                                                            i_company_code      || '/' ||
                                                                            i_plant_code        || '/' ||
                                                                            i_storage_locn_code || '/' ||
                                                                            i_balance_date      || '/' ||
                                                                            i_balance_time      ||
                                                                            ': Material Quantity is NULL.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_inventory_balance,
                                    'Material Quantity is NULL.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_plant_code,
                                    i_storage_locn_code,
                                    i_balance_date,
                                    i_balance_time,
                                    NULL,
                                    i_log_level + 1);
      END IF;


    FETCH csr_inv_bal_det INTO rv_inv_bal_det;
    END LOOP;

      -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
      write_log(ods_constants.data_type_inv_baln, 'n/a', i_log_level + 2, 'Inventory Balance Header: ' ||
                                                                          i_company_code      || '/' ||
                                                                          i_plant_code        || '/' ||
                                                                          i_storage_locn_code || '/' ||
                                                                          i_balance_date      || '/' ||
                                                                          i_balance_time      ||
                                                                          ' is ' || v_valdtn_status);

    CLOSE csr_inv_bal_det;

    UPDATE
      sap_stk_bal_hdr
    SET
      valdtn_status = v_valdtn_status
    WHERE
      bukrs = i_company_code AND
      werks = i_plant_code AND
      lgort = i_storage_locn_code AND
      budat = i_balance_date AND
      timlo = i_balance_time;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;

  END validate_inventory_balance;


  /*******************************************************************************
    NAME:       CHECK_INTRANSIT_BALANCE
    PURPOSE:    This code reads through all intransit balance header records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the header and detail records. The logic opens and closes the
                cursor before checking for each new group of records, so that if
                any additional records are written in while validation is occurring,
                then these are also validated.
  ********************************************************************************/
  PROCEDURE check_intransit_balance(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_int_bal_hdr IS
      SELECT
        *
      FROM
        sap_int_stk_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_int_bal_hdr csr_int_bal_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INTRANSIT_BALANCE: Started.');

    check_intransit_balance_types(i_log_level + 2);

    -- Check to see whether there are any records to be processed.
    OPEN csr_int_bal_hdr;
    FETCH csr_int_bal_hdr INTO rv_int_bal_hdr;
    WHILE csr_int_bal_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 2, 'Validating Intransit Balance Header: ' || rv_int_bal_hdr.werks);
      validate_intransit_balance(i_log_level + 2, rv_int_bal_hdr.werks);
      COMMIT;

      FETCH csr_int_bal_hdr INTO rv_int_bal_hdr;

    END LOOP;

    CLOSE csr_int_bal_hdr;
    COMMIT;

    write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_INTRANSIT_BALANCE: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_intransit, 'n/a', 0, 'ODS_VALIDATION.CHECK_INTRANSIT_BALANCE: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_intransit_balance;


  /*******************************************************************************
    NAME:       CHECK_INTRANSIT_BALANCE_TYPES
    PURPOSE:    This code checks to see is the various type included in the
                inventory_balance records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_intransit_balance_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- CURSORS
    CURSOR csr_inventory_type IS
      SELECT DISTINCT
        B.insmk AS inventory_type_code
      FROM
        sap_int_stk_hdr A,
        sap_int_stk_det B
      WHERE
        A.werks = B.werks AND
        A.valdtn_status = ods_constants.valdtn_unchecked AND
        B.insmk NOT IN (SELECT
                           inv_type_code
                        FROM
                          inv_type);
    rv_inventory_type csr_inventory_type%ROWTYPE;


    CURSOR csr_transport_model IS
      SELECT DISTINCT
        B.vsbed AS transport_model_code
      FROM
        sap_int_stk_hdr A,
        sap_int_stk_det B
      WHERE
        A.werks = B.werks AND
        A.valdtn_status = ods_constants.valdtn_unchecked AND
        B.vsbed NOT IN (SELECT
                          transport_model_code
                        FROM
                          transport_model);
    rv_transport_model csr_transport_model%ROWTYPE;

  BEGIN
    OPEN csr_inventory_type;
    LOOP
      FETCH csr_inventory_type INTO rv_inventory_type;
      EXIT WHEN csr_inventory_type%NOTFOUND;

      write_log(ods_constants.data_type_inventory, 'n/a', i_log_level + 1, 'Inserting Inventory Type: ' || rv_inventory_type.inventory_type_code || ' found in the Intransit Balance record into the Inventory Type table.');

      append.append_inv_type_code(rv_inventory_type.inventory_type_code);

    END LOOP;
    CLOSE csr_inventory_type;


    OPEN csr_transport_model;
    LOOP
      FETCH csr_transport_model INTO rv_transport_model;
      EXIT WHEN csr_transport_model%NOTFOUND;

      write_log(ods_constants.data_type_inventory, 'n/a', i_log_level + 1, 'Inserting Transport Model: ' || rv_transport_model.transport_model_code || ' found in the Intransit Balance record into the Transport Model table.');

      append.append_transport_model_code(rv_transport_model.transport_model_code);

    END LOOP;
    CLOSE csr_transport_model;

  END check_intransit_balance_types;


  PROCEDURE validate_intransit_balance(
    i_log_level  IN ods.log.log_level%TYPE,
    i_plant_code IN sap_int_stk_hdr.werks%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status sap_int_stk_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    -- Intransit Balance Header
    CURSOR csr_int_bal_det IS
      SELECT
        *
      FROM
        sap_int_stk_det
      WHERE
        werks = i_plant_code
      FOR UPDATE NOWAIT;
    rv_int_bal_det csr_int_bal_det%ROWTYPE;

  BEGIN
    -- Clear the validation reason tables of this inventory balance
    utils.clear_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                  i_plant_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

    -- Plant must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      plant a
    WHERE
      a.plant_code = i_plant_code;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'Intransit Balance Header: ' ||
                                                                           i_plant_code ||
                                                                           ': Invalid or non-existant Plant Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                  'Invalid or non-existant Plant.',
                                  ods_constants.valdtn_severity_critical,
                                  i_plant_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
    END IF;

    -- Validate the Intransit Balance header record.
    OPEN csr_int_bal_det;
    FETCH csr_int_bal_det INTO rv_int_bal_det;
    WHILE csr_int_bal_det%FOUND LOOP

      -- Company must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_int_stk_det a,
        company_dim     b
      WHERE
        a.werks = i_plant_code AND
        a.detseq = rv_int_bal_det.detseq AND
        a.burks = b.company_code(+) AND
        a.aedat > 20060601 AND -- JG 20080617 Temporary fix to resolve the NZ Intransit problems caused by archiving PO's
        b.company_code IS NULL;
      IF v_count <> 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'Intransit Balance Header: ' ||
                                                                             i_plant_code ||
                                                                             ': Invalid or non-existant Company.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                    'Invalid or non-existant Company.',
                                    ods_constants.valdtn_severity_critical,
                                    i_plant_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_int_stk_det a
      WHERE
        a.werks = i_plant_code AND
        a.detseq = rv_int_bal_det.detseq AND
        a.matnr IS NULL;
      IF v_count <> 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'Intransit Balance Header: ' ||
                                                                             i_plant_code      ||
                                                                             ': Null Material.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                    'Null Material. Dtl Seq:' || rv_int_bal_det.detseq,
                                    ods_constants.valdtn_severity_critical,
                                    i_plant_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_int_stk_det a,
        sap_mat_hdr     b
      WHERE
        a.werks = i_plant_code AND
        a.detseq = rv_int_bal_det.detseq AND
        a.matnr = b.matnr AND
        b.valdtn_status = ods_constants.valdtn_valid;
      IF v_count = 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'Intransit Balance Header: ' ||
                                                                             i_plant_code      ||
                                                                             ': Non-Valid Material.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                    'Non-Valid Material: ' || rv_int_bal_det.matnr,
                                    ods_constants.valdtn_severity_critical,
                                    i_plant_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;


      -- Inbound Delivery Number must not be null.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_int_stk_det a
      WHERE
        a.werks = i_plant_code AND
        a.detseq = rv_int_bal_det.detseq AND
        a.vbeln IS NULL;
      IF v_count <> 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'Intransit Balance Header: ' ||
                                                                             i_plant_code      ||
                                                                             ': Null Inbound Delivery Number.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                    'Null Inbound Delivery Number. Dtl Seq:' || rv_int_bal_det.detseq,
                                    ods_constants.valdtn_severity_critical,
                                    i_plant_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Quantity Delivered must not be null.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_int_stk_det a
      WHERE
        a.werks = i_plant_code AND
        a.detseq = rv_int_bal_det.detseq AND
        a.lfimg IS NULL;
      IF v_count <> 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 1, 'Intransit Balance Header: ' ||
                                                                             i_plant_code      ||
                                                                             ': Null Quantity Delivered.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_intransit_balance,
                                    'Null Quantity Delivered. Dtl Seq ' || rv_int_bal_det.detseq,
                                    ods_constants.valdtn_severity_critical,
                                    i_plant_code,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      FETCH csr_int_bal_det INTO rv_int_bal_det;
      END LOOP;
      CLOSE csr_int_bal_det;

      -- Update the validation status to VALID or INVALID as is appropriate, and commit the change.
      write_log(ods_constants.data_type_intransit, 'n/a', i_log_level + 2, 'Intransit Balance Header: ' ||
                                                                            i_plant_code ||
                                                                            ' is ' || v_valdtn_status);
      UPDATE
        sap_int_stk_hdr
      SET
        valdtn_status = v_valdtn_status
      WHERE
        werks = i_plant_code;


  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;
  END validate_intransit_balance;


/******************************************************************************/
/* Procedure Definition                                                       */
/******************************************************************************/
/**
 Procedure : CHECK_REGL_SALES
 Owner     : ODS_APP
 Author    : Linden Glen

 Description
 -----------
 Selects all UNCHECKED regional sales records and calls the validate routine.
 The cursor is reopened before checking for each new group of records, allowing
 any new inserts to be validated.

 YYYY/MM   Author            Description
 -------   ------            -----------
 2005/05   Linden Glen       Created

*******************************************************************************/
PROCEDURE check_regl_sales(i_log_level IN ods.log.log_level%TYPE) IS

   /*-*/
   /* Variable declarations
   /*-*/
   v_record_count number := 0;

   /*-*/
   /* Cursor declarations
   /*-*/
   CURSOR csr_regl_sales_hdr IS
      SELECT a.intfc_id,
             a.rprting_yyyymmdd,
             a.company_code
      FROM regl_sales_hdr a
      WHERE a.valdtn_status = ods_constants.valdtn_unchecked;

   rec_regl_sales_hdr csr_regl_sales_hdr%ROWTYPE;


  BEGIN

    /*-*/
    /* Retrieve all UNCHECKED records
    /*-*/
    write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_REGL_SALES: Started.');

    OPEN csr_regl_sales_hdr;
    LOOP
       FETCH csr_regl_sales_hdr INTO rec_regl_sales_hdr;
       IF (csr_regl_sales_hdr%NOTFOUND) THEN
          EXIT;
       END IF;

       write_log(ods_constants.data_type_regl_sales,
                 'n/a', i_log_level + 2,
                 'Validating Regional Sales for Company ' || rec_regl_sales_hdr.company_code
                  || ' for date ' || rec_regl_sales_hdr.rprting_yyyymmdd
                  || ' - Interface ID : '||rec_regl_sales_hdr.intfc_id);

      /*-*/
      /* Validate record
      /*-*/
      validate_regl_sales(i_log_level + 2, rec_regl_sales_hdr.intfc_id);

      /*-*/
      /* Commit by count
      /*-*/
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
         commit;
         v_record_count := 0;
      END IF;

   END LOOP;
   CLOSE csr_regl_sales_hdr;

   /*-*/
   /* Commit
   /*-*/
   commit;


   write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1, 'ODS_VALIDATION.CHECK_REGL_SALES: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_regl_sales, 'n/a', 0, 'ODS_VALIDATION.CHECK_REGL_SALES: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
      raise_application_error(-20000, 'ODS_VALIDATION.CHECK_REGL_SALES: FATAL ERROR: ' || SQLERRM);
  END check_regl_sales;



/******************************************************************************/
/* Procedure Definition                                                       */
/******************************************************************************/
/**
 Procedure : VALIDATE_REGL_SALES
 Owner     : ODS_APP
 Author    : Linden Glen

 Description
 -----------
 Validates a regional sales record and updates the header status accordingly.

 YYYY/MM   Author            Description
 -------   ------            -----------
 2005/05   Linden Glen       Created

*******************************************************************************/
PROCEDURE validate_regl_sales(i_log_level IN ods.log.log_level%TYPE,
                              i_intfc_id  IN ods.regl_sales_hdr.intfc_id%type) IS

   /*-*/
   /* Variable declarations
   /*-*/
   v_valdtn_status ods.regl_sales_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
   v_count         number;

    /* CURSOR DECLARATIONS */
    cursor csr_regl_sales_hdr is
      SELECT *
      FROM regl_sales_hdr a
      WHERE a.intfc_id = i_intfc_id
      AND   a.valdtn_status = ods_constants.valdtn_unchecked
    FOR UPDATE NOWAIT;
    rec_regl_sales_hdr  csr_regl_sales_hdr%ROWTYPE;

    cursor csr_mars_date(i_date number) is
      select t1.mars_yyyyppdd
      from mars_date t1
      where t1.yyyymmdd_date = i_date;
    rec_mars_date csr_mars_date%rowtype;


   BEGIN

      /*-*/
      /* Attempt to open and lock header record to validate
      /*-*/
      OPEN csr_regl_sales_hdr;
      FETCH csr_regl_sales_hdr INTO rec_regl_sales_hdr;


         IF csr_regl_sales_hdr%FOUND THEN

            /*-*/
            /* Clear validation reason tables for this record
            /*-*/
            utils.clear_validation_reason(ods_constants.valdtn_type_regl_sales,
                                          i_intfc_id,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          i_log_level + 1);


            /*---------------------------------------------*/
            /* VALIDATE : Company code must be valid       */
            /*            Checked against REGL_SALES_CNTL  */
            /*---------------------------------------------*/
            v_count := 0;

            SELECT count(*)
            INTO v_count
            FROM regl_sales_cntl a,
                 regl_sales_hdr b
            WHERE a.cntl_code = b.company_code
            AND b.intfc_id = i_intfc_id
            AND a.group_id in ('REGL_SALES_CMPNY','CDW_SALES_CMPNY');

            if not(v_count = 1) then

               v_valdtn_status := ods_constants.valdtn_invalid;

               write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1,
                         'Validation for Company ' || rec_regl_sales_hdr.company_code
                         || ' for date ' || rec_regl_sales_hdr.rprting_yyyymmdd
                         || ' - Interface ID : '||rec_regl_sales_hdr.intfc_id
                         || ' - FAILED : Invalid Company Code');

               utils.add_validation_reason(ods_constants.valdtn_type_regl_sales,
                                           'Invalid Company Code',
                                           ods_constants.valdtn_severity_critical,
                                           i_intfc_id,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           i_log_level + 1);

            end if;


            /*-------------------------------------------------------------------*/
            /* VALIDATE : Account Assignment Group code must be valid and active */
            /*            Checked against DDS.ACCT_ASSGNMNT_GRP_DIM              */
            /*-------------------------------------------------------------------*/
            v_count := 0;

            SELECT count(*)
            INTO v_count
            FROM regl_sales_det a
            WHERE a.acct_assgnmnt_grp_code not in (select acct_assgnmnt_grp_code
                                                   from acct_assgnmnt_grp_dim)
            AND a.hdr_intfc_id = i_intfc_id
            AND a.acct_assgnmnt_grp_code <> '99';

            if not(v_count = 0) then

               v_valdtn_status := ods_constants.valdtn_invalid;

               write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1,
                         'Validation for Company ' || rec_regl_sales_hdr.company_code
                         || ' for ' || rec_regl_sales_hdr.rprting_yyyymmdd
                         || ' - Interface ID : '||rec_regl_sales_hdr.intfc_id
                         || ' - FAILED : Contains invalid account code(s)');


               utils.add_validation_reason(ods_constants.valdtn_type_regl_sales,
                                           'Invalid Account Assignment Codes(s)',
                                           ods_constants.valdtn_severity_critical,
                                           i_intfc_id,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           i_log_level + 1);

            end if;

            /*----------------------------------------------------------*/
            /* VALIDATE : Currency code must be valid and active        */
            /*            Checked against DDS.CURRCY_DIM                */
            /*----------------------------------------------------------*/
            v_count := 0;

            SELECT count(*)
            INTO v_count
            FROM regl_sales_hdr a
            WHERE a.currcy_code not in (select currcy_code
                                        from currcy_dim)
            AND a.intfc_id = i_intfc_id;


            if not(v_count = 0) then

               v_valdtn_status := ods_constants.valdtn_invalid;

               write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1,
                         'Validation for Company ' || rec_regl_sales_hdr.company_code
                         || ' for date ' || rec_regl_sales_hdr.rprting_yyyymmdd
                         || ' - Interface ID : '||rec_regl_sales_hdr.intfc_id
                         || ' - FAILED : Invalid Currency Code');


               utils.add_validation_reason(ods_constants.valdtn_type_regl_sales,
                                           'Invalid Currency Code',
                                           ods_constants.valdtn_severity_critical,
                                           i_intfc_id,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           i_log_level + 1);

            end if;


            /*------------------------------------------------------------------------*/
            /* VALIDATE : Reporting date must be valid and NOT greater than sysdate   */
            /*            Checked against MARS_DATE                                   */
            /*------------------------------------------------------------------------*/

            open csr_mars_date(rec_regl_sales_hdr.rprting_yyyymmdd);
            fetch csr_mars_date into rec_mars_date;
            if csr_mars_date%notfound then

               v_valdtn_status := ods_constants.valdtn_invalid;

               write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1,
                         'Validation for Company ' || rec_regl_sales_hdr.company_code
                         || ' for date ' || rec_regl_sales_hdr.rprting_yyyymmdd
                         || ' - Interface ID : '||rec_regl_sales_hdr.intfc_id
                         || ' - FAILED : Invalid Reporting Date');

               utils.add_validation_reason(ods_constants.valdtn_type_regl_sales,
                                           'Invalid Reporting Date',
                                           ods_constants.valdtn_severity_critical,
                                           i_intfc_id,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           i_log_level + 1);

            end if;
            close csr_mars_date;


            if (rec_regl_sales_hdr.rprting_yyyymmdd > to_char(sysdate,'YYYYMMDD')) then

               v_valdtn_status := ods_constants.valdtn_invalid;

               write_log(ods_constants.data_type_regl_sales, 'n/a', i_log_level + 1,
                         'Validation for Company ' || rec_regl_sales_hdr.company_code
                         || ' for date ' || rec_regl_sales_hdr.rprting_yyyymmdd
                         || ' - Interface ID : '||rec_regl_sales_hdr.intfc_id
                         || ' - FAILED : Reporting Date is greater than today');

               utils.add_validation_reason(ods_constants.valdtn_type_regl_sales,
                                           'Reporting Date is greater than system date',
                                           ods_constants.valdtn_severity_critical,
                                           i_intfc_id,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           i_log_level + 1);
            end if;


            /*-------------------------------------------------*/
            /* UPDATE validation status to VALID or INVALID    */
            /*-------------------------------------------------*/
            update regl_sales_hdr a
            set a.valdtn_status = v_valdtn_status
            where current of csr_regl_sales_hdr;

            /*-*/
            /* Commit
            /*-*/
            commit;


      end if;

      /*-*/
      /* Close cursor
      /*-*/
      close csr_regl_sales_hdr;


   EXCEPTION
      WHEN resource_busy THEN

         /*-*/
         /* Ignore locked records
         /*-*/
         NULL;

      WHEN OTHERS THEN

         /*-*/
         /* Pass exception to calling object
         /*-*/
         RAISE;
END;

 /********************************************************************************
    NAME:       check_pmx_accruals
    PURPOSE:    This code reads through all promotion accruals records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records. The logic opens and closes the
                cursor before checking for each new group of records, so that if
                any additional records are written in while validation is occurring,
                then these are also validated.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created

  ********************************************************************************/
  PROCEDURE check_pmx_accruals(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_pmx_accruals IS
      SELECT
        *
      FROM
        pmx_accruals
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_pmx_accruals csr_pmx_accruals%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'ods_validation.check_pmx_accruals: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_pmx_accruals;
    FETCH csr_pmx_accruals INTO rv_pmx_accruals;
    WHILE csr_pmx_accruals%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 2, 'Validating Promotion Accruals: ' || rv_pmx_accruals.company_code   || '/'
                                                                                                             || rv_pmx_accruals.division_code  || '/'
                                                                                                             || rv_pmx_accruals.prom_num       || '/'
                                                                                                             || rv_pmx_accruals.cust_code      || '/'
                                                                                                             || rv_pmx_accruals.matl_zrep_code || '/'
                                                                                                             || rv_pmx_accruals.accrl_date);
      validate_pmx_accrual(i_log_level + 2, rv_pmx_accruals.company_code,
                                            rv_pmx_accruals.division_code,
                                            rv_pmx_accruals.cust_code,
                                            rv_pmx_accruals.prom_num,
                                            rv_pmx_accruals.matl_zrep_code,
                                            rv_pmx_accruals.accrl_date,
                                            rv_pmx_accruals.matl_tdu_code,
                                            rv_pmx_accruals.currcy_code);
      COMMIT;

      FETCH csr_pmx_accruals INTO rv_pmx_accruals;
    END LOOP;
    CLOSE csr_pmx_accruals;
    COMMIT;

    write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'ods_validation.check_pmx_accruals: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_accrual, 'n/a', 0, 'ods_validation.check_pmx_accruals: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_pmx_accruals;

  /* ******************************************************************************
    NAME:       validate_pmx_accrual
    PURPOSE:    This code validates a promotion accrual record, as specified by the
                input parameter, and updates the status on the record accordingly.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created
  ********************************************************************************/
   PROCEDURE validate_pmx_accrual(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN pmx_accruals.company_code%TYPE,
    i_division_code     IN pmx_accruals.division_code%TYPE,
    i_cust_code         IN pmx_accruals.cust_code%TYPE,
    i_prom_num          IN pmx_accruals.prom_num%TYPE,
    i_matl_zrep_code    IN pmx_accruals.matl_zrep_code%TYPE,
    i_accrl_date        IN pmx_accruals.accrl_date%TYPE,
    i_matl_tdu_code     IN pmx_accruals.matl_tdu_code%TYPE,
    i_currcy_code       IN pmx_accruals.currcy_code%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status pmx_accruals.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

  BEGIN

    -- Clear the validation reason tables of this promotion accrual
    utils.clear_validation_reason(ods_constants.valdtn_type_accrual,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);

    -- Company must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      company_dim
    WHERE
      company_code = i_company_code;

    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       || '/' ||
                                                                          i_cust_code      || '/' ||
                                                                          i_matl_zrep_code || '/' ||
                                                                          i_accrl_date     ||
                                                                          ': Invalid or non-existant Company Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'Invalid or non-existant Company.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);
    END IF;

    -- Division must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      division_dim
    WHERE
      division_code = i_division_code;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       || '/' ||
                                                                          i_cust_code      || '/' ||
                                                                          i_matl_zrep_code || '/' ||
                                                                          i_accrl_date     ||
                                                                          ': Invalid or non-existant Division Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'Invalid or non-existant Division Code.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);
    END IF;

    -- prom_num must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      pmx_prom_hdr
    WHERE
      company_code        = i_company_code
      AND division_code   = i_division_code
      AND prom_num        = i_prom_num
      AND valdtn_status     = ods_constants.valdtn_valid;
    IF v_count < 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       || '/' ||
                                                                          i_cust_code      || '/' ||
                                                                          i_matl_zrep_code || '/' ||
                                                                          i_accrl_date     ||
                                                                          ': Invalid or non-existant Promotion Number.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'Invalid or non-existant Promotion Number.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);
    END IF;

    -- Customer must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      pmx_cust
    WHERE
      company_code        = i_company_code
      AND division_code   = i_division_code
      AND cust_code       = i_cust_code;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       || '/' ||
                                                                          i_cust_code      || '/' ||
                                                                          i_matl_zrep_code || '/' ||
                                                                          i_accrl_date     ||
                                                                          ': Invalid or non-existant Promotion Customer.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'Invalid or non-existant Promotion Customer Code.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);
    END IF;

    -- zrep matl code must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      matl_dim
    WHERE
      matl_code = i_matl_zrep_code;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       || '/' ||
                                                                          i_cust_code      || '/' ||
                                                                          i_matl_zrep_code || '/' ||
                                                                          i_accrl_date     ||
                                                                          ': Invalid or non-existant Zrep Material Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'Invalid or non-existant Zrep Material Code.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);
    END IF;

    -- Currcy Code must exist and be valid.
    v_count := 0;
    SELECT
      count(*) INTO v_count
    FROM
      currcy_dim
    WHERE
      currcy_code = i_currcy_code;
    IF v_count <> 1 THEN
      v_valdtn_status := ods_constants.valdtn_invalid;
      write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       || '/' ||
                                                                          i_cust_code      || '/' ||
                                                                          i_matl_zrep_code || '/' ||
                                                                          i_accrl_date     ||
                                                                          ': Invalid or non-existant Currency Code.');

      -- Add an entry into the validation reason tables
      utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'Invalid or non-existant Currency Code.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_division_code,
                                  i_prom_num,
                                  i_cust_code,
                                  i_matl_zrep_code,
                                  i_accrl_date,
                                  i_log_level + 1);
    END IF;

    write_log(ods_constants.data_type_accrl, 'n/a', i_log_level + 1,    'pmx_accruals: ' ||
                                                                        i_company_code   || '/' ||
                                                                        i_division_code  || '/' ||
                                                                        i_prom_num       || '/' ||
                                                                        i_cust_code      || '/' ||
                                                                        i_matl_zrep_code || '/' ||
                                                                        i_accrl_date     ||
                                                                        ' is ' || v_valdtn_status);


    UPDATE
      pmx_accruals
    SET
      valdtn_status = v_valdtn_status
    WHERE
      company_code = i_company_code
      AND division_code = i_division_code
      AND prom_num = i_prom_num
      AND cust_code = i_cust_code
      AND matl_zrep_code = i_matl_zrep_code
      AND accrl_date = i_accrl_date;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;

  END validate_pmx_accrual;

  /*******************************************************************************
    NAME:       CHECK_PROMOTION_TYPES
    PURPOSE:    This code checks to see is the various type included in the Promotion
                header and detail records already exist in the type tables.
  ********************************************************************************/
  PROCEDURE check_promotion_types(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- CURSORS
    CURSOR csr_type_class IS
      SELECT
        DISTINCT a.prom_type_class As prom_type_class_code
      FROM
        pmx_prom_hdr a,
        dds.prom_type_class_dim b
      WHERE
        a.valdtn_status = ods_constants.valdtn_unchecked
        AND a.prom_type_class = b.prom_type_class_code (+)
        AND a.prom_type_class IS NOT NULL
        AND b.prom_type_class_code IS NULL;
    rv_type_class csr_type_class%ROWTYPE;

  BEGIN
    -- Adding promotion type class
    write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'Checking for new promotion type class - Start.');

    OPEN csr_type_class;
    LOOP
      FETCH csr_type_class INTO rv_type_class;
      EXIT WHEN csr_type_class%NOTFOUND;

      write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'Inserting promotion type class code: ' || rv_type_class.prom_type_class_code || ' found in the promotion into the promotion type class table.');

      append.append_prom_type_class_code(rv_type_class.prom_type_class_code);

    END LOOP;
    CLOSE csr_type_class;

    write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'Checking for new promotion type class - End.');

  END check_promotion_types;

 /********************************************************************************
    NAME:       check_promotions
    PURPOSE:    This code reads through all promotion and detail records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records. The logic opens and closes the
                cursor before checking for each new group of records, so that if
                any additional records are written in while validation is occurring,
                then these are also validated.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created

  ********************************************************************************/
  PROCEDURE check_promotions(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_pmx_prom_hdr IS
      SELECT
        company_code,
        division_code,
        prom_num,
        prom_chng_date
      FROM
        pmx_prom_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_pmx_prom_hdr csr_pmx_prom_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'ods_validation.check_promotions: Started.');

    -- Check the various types in the sales order
    check_promotion_types(i_log_level + 2);

    OPEN csr_pmx_prom_hdr;
    FETCH csr_pmx_prom_hdr INTO rv_pmx_prom_hdr;
    WHILE csr_pmx_prom_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 2, 'Validating Promotion Co/Div/Prom : ' || rv_pmx_prom_hdr.company_code   || '/'
                                                                                                              || rv_pmx_prom_hdr.division_code  || '/'
                                                                                                              || rv_pmx_prom_hdr.prom_num);
      validate_promotion(i_log_level + 2,
                         rv_pmx_prom_hdr.company_code,
                         rv_pmx_prom_hdr.division_code,
                         rv_pmx_prom_hdr.prom_num,
                         rv_pmx_prom_hdr.prom_chng_date);

      -- Commit when required, and recheck which sales orders need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_pmx_prom_hdr INTO rv_pmx_prom_hdr;
    END LOOP;
    CLOSE csr_pmx_prom_hdr;
    COMMIT;

    write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'ods_validation.check_promotions: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_prom, 'n/a', 0, 'ods_validation.check_promotions: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_promotions;

  /* ******************************************************************************
    NAME:       validate_promotion
    PURPOSE:    This code validates a promotion record, as specified by the
                input parameter, and updates the status on the record accordingly.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created
  ********************************************************************************/
   PROCEDURE validate_promotion(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN pmx_prom_hdr.company_code%TYPE,
    i_division_code     IN pmx_prom_hdr.division_code%TYPE,
    i_prom_num          IN pmx_prom_hdr.prom_num%TYPE,
    i_prom_chng_date    IN pmx_prom_hdr.prom_chng_date%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status pmx_prom_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_pmx_prom_hdr IS
      SELECT
        company_code,
        division_code,
        prom_num,
        prom_chng_date,
        cust_code,
        prom_type_key,
        prom_stat_code,
        case1_fund_code,
        case2_fund_code,
        coop1_fund_code,
        coop2_fund_code,
        coop3_fund_code,
        coup1_fund_code,
        coup2_fund_code,
        scan1_fund_code,
        whse1_fund_code,
        prom_attrb
      FROM
        pmx_prom_hdr
      WHERE
        company_code = i_company_code
        AND division_code = i_division_code
        AND prom_num = i_prom_num
        AND prom_chng_date = i_prom_chng_date
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_pmx_prom_hdr csr_pmx_prom_hdr%ROWTYPE;

    -- Promotion zrep matl code not exist in matl_dim
    CURSOR csr_pmx_prom_dtl IS
      SELECT
        a.company_code,
        a.division_code,
        a.prom_num,
        a.matl_zrep_code
      FROM
        pmx_prom_dtl a,
        matl_dim b
      WHERE
        a.company_code = i_company_code
        AND a.division_code = i_division_code
        AND a.prom_num = i_prom_num
        AND a.prom_chng_date = rv_pmx_prom_hdr.prom_chng_date
        AND a.matl_zrep_code = b.matl_code (+)
        AND a.matl_zrep_code IS NOT NULL
        AND b.matl_code IS NULL;
    rv_pmx_prom_dtl csr_pmx_prom_dtl%ROWTYPE;

  BEGIN

    -- Validate the promotion header record.
    OPEN csr_pmx_prom_hdr;
    FETCH csr_pmx_prom_hdr INTO rv_pmx_prom_hdr;
    IF csr_pmx_prom_hdr%FOUND THEN

      -- Clear the validation reason tables of this promotion
      utils.clear_validation_reason(ods_constants.valdtn_type_prom,
                                    i_company_code,
                                    i_division_code,
                                    i_prom_num,
                                    i_prom_chng_date,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Company must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        company_dim
      WHERE
        company_code = i_company_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1,   'pmx_prom_hdr Co/Div/Prom : ' ||
                                                                            i_company_code   || '/' ||
                                                                            i_division_code  || '/' ||
                                                                            i_prom_num       ||
                                                                            ': Invalid or non-existant Company Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                    'Invalid or non-existant Company Code.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_prom_num,
                                    i_prom_chng_date,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Division must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        division_dim
      WHERE
        division_code = i_division_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1,    'pmx_prom_hdr Co/Div/Prom : ' ||
                                                                            i_company_code   || '/' ||
                                                                            i_division_code  || '/' ||
                                                                            i_prom_num       ||
                                                                            ': Invalid or non-existant Division Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                    'Invalid or non-existant Division Code.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_prom_num,
                                    i_prom_chng_date,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Customer must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.cust_code IS NOT NULL THEN
        SELECT
          count(*) INTO v_count
        FROM
          pmx_cust
        WHERE
          company_code        = i_company_code
          AND division_code   = i_division_code
          AND cust_code       = rv_pmx_prom_hdr.cust_code;
        IF v_count <> 1 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1,   'pmx_prom_hdr Co/Div/Prom/Cust : ' ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.cust_code ||
                                                                              ': Invalid or non-existant Promotion Customer.');

          -- Add an entry into the validation reason tables
          utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                      'Invalid or non-existant Promotion Customer Code.' || rv_pmx_prom_hdr.cust_code || '.',
                                      ods_constants.valdtn_severity_critical,
                                      i_company_code,
                                      i_division_code,
                                      i_prom_num,
                                      i_prom_chng_date,
                                      NULL,
                                      NULL,
                                      i_log_level + 1);
        END IF;
      END IF;

      -- CASE1_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.case1_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.case1_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.case1_fund_code ||
                                                                              ': Invalid or non-existant Case1 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                    'Invalid or non-existant Case1 Fund Type Code - ' || rv_pmx_prom_hdr.case1_fund_code,
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_prom_num,
                                    i_prom_chng_date,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
          END IF;
      END IF;

      -- CASE2_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.case2_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.case2_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                            i_company_code   || '/' ||
                                                                            i_division_code  || '/' ||
                                                                            i_prom_num       || '/' ||
                                        rv_pmx_prom_hdr.case2_fund_code ||
                                                                            ': Invalid or non-existant Case2 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                    'Invalid or non-existant Case2 Fund Type Code - ' || rv_pmx_prom_hdr.case2_fund_code,
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_prom_num,
                                    i_prom_chng_date,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
          END IF;
      END IF;

      -- COOP1_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.coop1_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.coop1_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.coop1_fund_code ||
                                                                              ': Invalid or non-existant COOP1 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant COOP1 Fund Type Code - ' || rv_pmx_prom_hdr.coop1_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- COOP2_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.coop2_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.coop2_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.coop2_fund_code ||
                                                                              ': Invalid or non-existant COOP2 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant COOP2 Fund Type Code - ' || rv_pmx_prom_hdr.coop2_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;


      -- COOP3_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.coop3_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.coop3_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.coop3_fund_code ||
                                                                              ': Invalid or non-existant COOP3 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant COOP3 Fund Type Code - ' || rv_pmx_prom_hdr.coop3_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- COUP1_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.coup1_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.coup1_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.coup1_fund_code ||
                                                                              ': Invalid or non-existant COUP1 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant COUP1 Fund Type Code - ' || rv_pmx_prom_hdr.coup1_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- COUP2_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.coup2_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.coup2_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.coup2_fund_code ||
                                                                              ': Invalid or non-existant COUP2 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant COUP2 Fund Type Code - ' || rv_pmx_prom_hdr.coup2_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- SCAN1_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.scan1_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.scan1_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.scan1_fund_code ||
                                                                              ': Invalid or non-existant SCAN1 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant SCAN1 Fund Type Code - ' || rv_pmx_prom_hdr.scan1_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- WHSE1_FUND_TYPE Code must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.whse1_fund_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_fund_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_fund_type_code = rv_pmx_prom_hdr.whse1_fund_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/FundType : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.whse1_fund_code ||
                                                                              ': Invalid or non-existant WHSE1 Fund Type Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant WHSE1 Fund Type Code - ' || rv_pmx_prom_hdr.whse1_fund_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- PROM_TYPE_KEY must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.prom_type_key IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_prom_type
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_type_key = rv_pmx_prom_hdr.prom_type_key;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/PromTypeKey : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              TO_CHAR(rv_pmx_prom_hdr.prom_type_key) ||
                                                                              ': Invalid or non-existant Promotion Type Key.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant Promotion Type Key - ' || TO_CHAR(rv_pmx_prom_hdr.prom_type_key),
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- PROM_STAT_CODE must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.prom_stat_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           prom_status_dim
         WHERE
           prom_status_code = rv_pmx_prom_hdr.prom_stat_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/PromStatus : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.prom_stat_code ||
                                                                              ': Invalid or non-existant Promotion Status Code.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant Promotion Status Code - ' || rv_pmx_prom_hdr.prom_stat_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- PROM_ATTRB must exist and be valid.
      v_count := 0;
      IF rv_pmx_prom_hdr.prom_attrb IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_prom_attrb
         WHERE
           company_code = i_company_code
           AND division_code = i_division_code
           AND prom_attrb_code = rv_pmx_prom_hdr.prom_attrb;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1, 'pmx_prom_hdr Co/Div/Prom/PromAttrb : '  ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_hdr.prom_attrb ||
                                                                              ': Invalid or non-existant Promotion Attribute.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                        'Invalid or non-existant Promotion Attribute - ' || rv_pmx_prom_hdr.prom_attrb,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_prom_num,
                                        i_prom_chng_date,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      -- Loop through the not exist zrep matl code from detail
      OPEN csr_pmx_prom_dtl;
      LOOP
         FETCH csr_pmx_prom_dtl INTO rv_pmx_prom_dtl;
         EXIT WHEN csr_pmx_prom_dtl%NOTFOUND;

          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1,   'pmx_prom_dtl Co/Div/Prom/Matl: ' ||
                                                                              i_company_code   || '/' ||
                                                                              i_division_code  || '/' ||
                                                                              i_prom_num       || '/' ||
                                                                              rv_pmx_prom_dtl.matl_zrep_code ||
                                                                              ': Invalid or non-existant Zrep Material Code.');
        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_prom,
                                    'Invalid or non-existant Zrep Material Code - ' || rv_pmx_prom_dtl.matl_zrep_code || '.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_prom_num,
                                    i_prom_chng_date,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END LOOP;
      CLOSE csr_pmx_prom_dtl;

      write_log(ods_constants.valdtn_type_prom, 'n/a', i_log_level + 1,   'pmx_prom_hdr: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_division_code  || '/' ||
                                                                          i_prom_num       ||
                                                                          ' is ' || v_valdtn_status);

      UPDATE
        pmx_prom_hdr
      SET
        valdtn_status = v_valdtn_status
      WHERE
        company_code = i_company_code
        AND division_code = i_division_code
        AND prom_num = i_prom_num
        AND prom_chng_date = rv_pmx_prom_hdr.prom_chng_date;

   END IF;
   CLOSE csr_pmx_prom_hdr;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;

  END validate_promotion;

PROCEDURE check_pmx_claim_docs(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;
    v_valdtn_status pmx_claim_doc.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_pmx_claim_doc IS
      SELECT
        company_code,
        division_code,
        registry_key,
        cust_code,
        acct_mgr_Key
      FROM
        pmx_claim_doc
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;

    rv_pmx_claim_doc csr_pmx_claim_doc%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'ods_validation.check_pmx_claim_doc: Started.');

    OPEN csr_pmx_claim_doc;
    FETCH csr_pmx_claim_doc INTO rv_pmx_claim_doc;
    WHILE csr_pmx_claim_doc%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 2, 'Validating Promotion Claim Doc Co/Div/RegKey : ' || rv_pmx_claim_doc.company_code   || '/'
                                                                                                                           || rv_pmx_claim_doc.division_code  || '/'
                                                                                                                           || rv_pmx_claim_doc.registry_key);


      -- Clear the validation reason tables of this promotion
      utils.clear_validation_reason(ods_constants.valdtn_type_claim,
                                    rv_pmx_claim_doc.company_code,
                                    rv_pmx_claim_doc.division_code,
                                    rv_pmx_claim_doc.registry_key,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Company must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        company_dim
      WHERE
        company_code = rv_pmx_claim_doc.company_code;

      IF v_count <> 1 THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_doc Co/Div/RegKey : ' ||
                                                                             rv_pmx_claim_doc.company_code   || '/' ||
                                                                             rv_pmx_claim_doc.division_code  || '/' ||
                                                                             rv_pmx_claim_doc.registry_key   ||
                                                                             ': Invalid or non-existant Company Code.');

         -- Add an entry into the validation reason tables
         utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                     'Invalid or non-existant Company Code.',
                                     ods_constants.valdtn_severity_critical,
                                     rv_pmx_claim_doc.company_code,
                                     rv_pmx_claim_doc.division_code,
                                     rv_pmx_claim_doc.registry_key,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
       END IF;

       -- Division must exist and be valid.
       v_count := 0;
       SELECT
         count(*) INTO v_count
       FROM
         division_dim
       WHERE
         division_code = rv_pmx_claim_doc.division_code;
       IF v_count <> 1 THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_doc Co/Div/RegKey : ' ||
                                                                             rv_pmx_claim_doc.company_code   || '/' ||
                                                                             rv_pmx_claim_doc.division_code  || '/' ||
                                                                             rv_pmx_claim_doc.registry_key   ||
                                                                             ': Invalid or non-existant Division Code.');

         -- Add an entry into the validation reason tables
         utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                     'Invalid or non-existant Division Code.',
                                     ods_constants.valdtn_severity_critical,
                                     rv_pmx_claim_doc.company_code,
                                     rv_pmx_claim_doc.division_code,
                                     rv_pmx_claim_doc.registry_key,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
       END IF;

       -- Customer must exist and be valid.
       v_count := 0;
       IF rv_pmx_claim_doc.cust_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_cust
         WHERE
           company_code = rv_pmx_claim_doc.company_code
           AND division_code = rv_pmx_claim_doc.division_code
           AND cust_code = rv_pmx_claim_doc.cust_code;
         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_doc Co/Div/RegKey/Cust : ' ||
                                                                               rv_pmx_claim_doc.company_code   || '/' ||
                                                                               rv_pmx_claim_doc.division_code  || '/' ||
                                                                               rv_pmx_claim_doc.registry_key       || '/' ||
                                                                               rv_pmx_claim_doc.cust_code ||
                                                                               ': Invalid or non-existant Promotion Customer.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                       'Invalid or non-existant Promotion Customer Code.' || rv_pmx_claim_doc.cust_code || '.',
                                       ods_constants.valdtn_severity_critical,
                                       rv_pmx_claim_doc.company_code,
                                       rv_pmx_claim_doc.division_code,
                                       rv_pmx_claim_doc.registry_key,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
         END IF;
       END IF;

       -- Account Manager must exist and be valid.
       v_count := 0;
       IF rv_pmx_claim_doc.acct_mgr_key IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_acct_mgr
         WHERE
           company_code = rv_pmx_claim_doc.company_code
           AND division_code = rv_pmx_claim_doc.division_code
           AND acct_mgr_key = rv_pmx_claim_doc.acct_mgr_key;
         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_doc Co/Div/RegKey/AcctMgrKey : ' ||
                                                                               rv_pmx_claim_doc.company_code   || '/' ||
                                                                               rv_pmx_claim_doc.division_code  || '/' ||
                                                                               rv_pmx_claim_doc.registry_key       || '/' ||
                                                                               rv_pmx_claim_doc.acct_mgr_key ||
                                                                               ': Invalid or non-existant Promotion Account Manager Key.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                       'Invalid or non-existant Promotion Account Manager Key.' || rv_pmx_claim_doc.acct_mgr_key || '.',
                                       ods_constants.valdtn_severity_critical,
                                       rv_pmx_claim_doc.company_code,
                                       rv_pmx_claim_doc.division_code,
                                       rv_pmx_claim_doc.registry_key,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
         END IF;
       END IF;

       write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1,   'pmx_claim_doc Co/Div/RegKey : ' ||
                                                                             rv_pmx_claim_doc.company_code   || '/' ||
                                                                             rv_pmx_claim_doc.division_code  || '/' ||
                                                                             rv_pmx_claim_doc.registry_key   ||
                                                                             ' is ' || v_valdtn_status);

     UPDATE
       pmx_claim_doc
     SET
       valdtn_status = v_valdtn_status
     WHERE
       company_code = rv_pmx_claim_doc.company_code
       AND division_code = rv_pmx_claim_doc.division_code
       AND registry_key = rv_pmx_claim_doc.registry_key;

      -- Commit when required
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_pmx_claim_doc INTO rv_pmx_claim_doc;
    END LOOP;
    CLOSE csr_pmx_claim_doc;
    COMMIT;

    write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'ods_validation.check_pmx_claim_doc: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_claim, 'n/a', 0, 'ods_validation.check_pmx_claim_doc: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_pmx_claim_docs;

 /********************************************************************************
    NAME:       check_pmx_claims
    PURPOSE:    This code reads through all promotion claim and detail records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records. The logic opens and closes the cursor before checking
                or each new group of records, so that if any additional records are
                written in while validation is occurring, then these are also validated.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created

  ********************************************************************************/
  PROCEDURE check_pmx_claims(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_pmx_claim_hdr IS
      SELECT
        company_code,
        division_code,
        claim_key
      FROM
        pmx_claim_hdr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_pmx_claim_hdr csr_pmx_claim_hdr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'ods_validation.check_pmx_claims: Started.');

    -- Check the claim documents
    check_pmx_claim_docs(i_log_level + 1);

    OPEN csr_pmx_claim_hdr;
    FETCH csr_pmx_claim_hdr INTO rv_pmx_claim_hdr;
    WHILE csr_pmx_claim_hdr%FOUND LOOP

      -- PROCESS DATA
      write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 2, 'Validating Promotion Claim Co/Div/Claim : ' || rv_pmx_claim_hdr.company_code   || '/'
                                                                                                                     || rv_pmx_claim_hdr.division_code  || '/'
                                                                                                                     || rv_pmx_claim_hdr.claim_key);
      validate_pmx_claim(i_log_level + 2, rv_pmx_claim_hdr.company_code,
                                          rv_pmx_claim_hdr.division_code,
                                          rv_pmx_claim_hdr.claim_key);

      -- Commit when required, and recheck which sales orders need validating.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_pmx_claim_hdr INTO rv_pmx_claim_hdr;
    END LOOP;
    CLOSE csr_pmx_claim_hdr;
    COMMIT;

    write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'ods_validation.check_pmx_claims: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_claim, 'n/a', 0, 'ods_validation.check_pmx_claims: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_pmx_claims;

  /*******************************************************************************
    NAME:       validate_pmx_claim
    PURPOSE:    This code validates a promotion claim record and its detail, as
                specified by the input parameter, and updates the status on the record
                accordingly.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created
  ********************************************************************************/
   PROCEDURE validate_pmx_claim(
    i_log_level         IN ods.log.log_level%TYPE,
    i_company_code      IN pmx_claim_hdr.company_code%TYPE,
    i_division_code     IN pmx_claim_hdr.division_code%TYPE,
    i_claim_key         IN pmx_claim_hdr.claim_key%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status pmx_claim_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_pmx_claim_hdr IS
      SELECT
        company_code,
        division_code,
        claim_key,
        claim_type_code
      FROM
        pmx_claim_hdr
      WHERE
        company_code = i_company_code
        AND division_code = i_division_code
        AND claim_key = i_claim_key
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_pmx_claim_hdr csr_pmx_claim_hdr%ROWTYPE;

    -- promotion claim zrep matl code not exist in matl_dim
    CURSOR csr_pmx_claim_dtl IS
      SELECT
        a.company_code,
        a.division_code,
        a.claim_key,
        a.matl_zrep_code
      FROM
        pmx_claim_dtl a,
        matl_dim b
      WHERE
        a.company_code = i_company_code
        AND a.division_code = i_division_code
        AND a.claim_key = i_claim_key
        AND a.matl_zrep_code = b.matl_code (+)
        AND a.matl_zrep_code IS NOT NULL
        AND b.matl_code IS NULL;
    rv_pmx_claim_dtl csr_pmx_claim_dtl%ROWTYPE;

  BEGIN

    -- Validate the promotion header record.
    OPEN csr_pmx_claim_hdr;
    FETCH csr_pmx_claim_hdr INTO rv_pmx_claim_hdr;
    IF csr_pmx_claim_hdr%FOUND THEN

      -- Clear the validation reason tables of this promotion
      utils.clear_validation_reason(ods_constants.valdtn_type_claim,
                                    i_company_code,
                                    i_division_code,
                                    i_claim_key,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);

      -- Company must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        company_dim
      WHERE
        company_code = i_company_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1,  'pmx_claim_hdr Co/Div/Claim : ' ||
                                                                            i_company_code   || '/' ||
                                                                            i_division_code  || '/' ||
                                                                            i_claim_key      ||
                                                                            ': Invalid or non-existant Company Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                    'Invalid or non-existant Company Code.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_claim_key,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Division must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        division_dim
      WHERE
        division_code = i_division_code;
      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1,  'pmx_claim_hdr Co/Div/Claim : ' ||
                                                                            i_company_code   || '/' ||
                                                                            i_division_code  || '/' ||
                                                                            i_claim_key      ||
                                                                            ': Invalid or non-existant Division Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                    'Invalid or non-existant Division Code.',
                                    ods_constants.valdtn_severity_critical,
                                    i_company_code,
                                    i_division_code,
                                    i_claim_key,
                                    NULL,
                                    NULL,
                                    NULL,
                                    i_log_level + 1);
      END IF;

      -- Claim Type must exist and be valid.
      v_count := 0;
      IF rv_pmx_claim_hdr.claim_type_code IS NOT NULL THEN
         SELECT
           count(*) INTO v_count
         FROM
           pmx_claim_type
         WHERE
           claim_type_code = rv_pmx_claim_hdr.claim_type_code;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_hdr Co/Div/Claim/ClaimType : '  ||
                                                                               i_company_code   || '/' ||
                                                                               i_division_code  || '/' ||
                                                                               i_claim_key      || '/' ||
                                                                               rv_pmx_claim_hdr.claim_type_code ||
                                                                               ': Invalid or non-existant Promotion Claim Type.');

            -- Add an entry into the validation reason tables
            utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                        'Invalid or non-existant Promotion Claim Type Code - ' || rv_pmx_claim_hdr.claim_type_code,
                                        ods_constants.valdtn_severity_critical,
                                        i_company_code,
                                        i_division_code,
                                        i_claim_key,
                                        NULL,
                                        NULL,
                                        NULL,
                                        i_log_level + 1);
          END IF;
      END IF;

      OPEN csr_pmx_claim_dtl;
        LOOP
          FETCH csr_pmx_claim_dtl INTO rv_pmx_claim_dtl;
          EXIT WHEN csr_pmx_claim_dtl%NOTFOUND;
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_dtl Co/Div/Claim/Matl: ' ||
                                                                                i_company_code   || '/' ||
                                                                                i_division_code  || '/' ||
                                                                                i_claim_key       || '/' ||
                                                                                rv_pmx_claim_dtl.matl_zrep_code ||
                                                                                ': Invalid or non-existant Zrep Material Code.');
             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_claim,
                                         'Invalid or non-existant Zrep Material Code - ' || rv_pmx_claim_dtl.matl_zrep_code || '.',
                                         ods_constants.valdtn_severity_critical,
                                         i_company_code,
                                         i_division_code,
                                         i_claim_key,
                                         NULL,
                                         NULL,
                                         NULL,
                                         i_log_level + 1);

      END LOOP;
      CLOSE csr_pmx_claim_dtl;

      write_log(ods_constants.valdtn_type_claim, 'n/a', i_log_level + 1, 'pmx_claim_hdr Co/Div/Claim: ' ||
                                                                         i_company_code   || '/' ||
                                                                         i_division_code  || '/' ||
                                                                         i_claim_key       ||
                                                                         ' is ' || v_valdtn_status );


      UPDATE
        pmx_claim_hdr
      SET
        valdtn_status = v_valdtn_status
      WHERE
        company_code = i_company_code
        AND division_code = i_division_code
        AND claim_key = i_claim_key;

   END IF;
   CLOSE csr_pmx_claim_hdr;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;

  END validate_pmx_claim;

  /********************************************************************************
    NAME:       check_dcs_sales_orders
    PURPOSE:    This code reads through all fundraising sales order records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records. The logic opens and closes the
                cursor before checking for each new group of records, so that if
                any additional records are written in while validation is occurring,
                then these are also validated.
                
    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/07   Kris Lee          Created                
                
  ********************************************************************************/
  PROCEDURE check_dcs_sales_orders(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_rec_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_dcs_orders IS
      SELECT
        *
      FROM
        dcs_sales_order
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_dcs_orders csr_dcs_orders%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_dcs_order, 'n/a', i_log_level + 1, 'ods_validation.check_dcs_orders: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_dcs_orders;
    FETCH csr_dcs_orders INTO rv_dcs_orders;
    IF (csr_dcs_orders%FOUND) THEN

       write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'DELETE previous error detail and header first.');

      -- this list can be different each day, so we need to delete the old errors reason 
      -- before validate the new list (do it at the start of the list)
      -- Clear error detail 
      DELETE 
      FROM valdtn_reasn_dtl t1
      WHERE EXISTS (SELECT *
                    FROM valdtn_reasn_hdr t2
                    WHERE t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
                      AND t2.valdtn_type_code = ods_constants.valdtn_type_dcs_order);  -- DCS validation type

      write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'DELETED error detail count [' || SQL%ROWCOUNT || ']');

      -- Clear the header table.
      DELETE 
      FROM valdtn_reasn_hdr
      WHERE valdtn_type_code = ods_constants.valdtn_type_dcs_order;  -- DCS validation type

      write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'DELETED error header count [' || SQL%ROWCOUNT || ']');

      COMMIT;

      LOOP
        EXIT WHEN csr_dcs_orders%NOTFOUND;

        -- PROCESS DATA
        validate_dcs_sales_order(i_log_level + 2, rv_dcs_orders.company_code,
                                            rv_dcs_orders.order_doc_num,
                                            rv_dcs_orders.order_doc_line_num);


        FETCH csr_dcs_orders INTO rv_dcs_orders;
      END LOOP;
      COMMIT;

    END IF;
    CLOSE csr_dcs_orders;

    write_log(ods_constants.valdtn_type_dcs_order, 'n/a', i_log_level + 1, 'ods_validation.check_dcs_orders: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_dcs_order, 'n/a', 0, 'ods_validation.check_dcs_orders: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_dcs_sales_orders;

  /*******************************************************************************
    NAME:       validate_dcs_sales_order
    PURPOSE:    This code validates a dcs (fundraising) sales order record, as specified by the
                input parameter, and updates the status on the record accordingly.
                
    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/04   Kris Lee          Created                

  ********************************************************************************/
   PROCEDURE validate_dcs_sales_order(
    i_log_level           IN ods.log.log_level%TYPE,
    i_company_code        IN dcs_sales_order.company_code%TYPE,
    i_order_doc_num       IN dcs_sales_order.order_doc_num%TYPE,
    i_order_doc_line_num  IN dcs_sales_order.order_doc_line_num%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status dcs_sales_order.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_dcs_sales_order IS
      SELECT
        company_code,
        order_type_code,
        sales_org_code,
        distbn_chnl_code,
        division_code,
        sold_to_cust_code,
        ship_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        matl_code
      FROM
        dcs_sales_order
      WHERE
        company_code = i_company_code
        AND order_doc_num = i_order_doc_num
        AND order_doc_line_num = i_order_doc_line_num
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;

    rv_dcs_sales_order csr_dcs_sales_order%ROWTYPE;

  BEGIN

    OPEN csr_dcs_sales_order;
    FETCH csr_dcs_sales_order INTO rv_dcs_sales_order;
    IF csr_dcs_sales_order%FOUND THEN

      -- Company must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        company
      WHERE
        company_code = rv_dcs_sales_order.company_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Company Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Company.',
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;


      -- Order Type Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        order_type
      WHERE
        order_type_code = rv_dcs_sales_order.order_type_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Order Type Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Order Type Code - ' || rv_dcs_sales_order.order_type_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Sales Org Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sales_org_dim
      WHERE
        sales_org_code = rv_dcs_sales_order.sales_org_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Sales Org Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Sales Org Code - ' || rv_dcs_sales_order.sales_org_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Distribution Channel Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        distbn_chnl_dim
      WHERE
        distbn_chnl_code = rv_dcs_sales_order.distbn_chnl_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Distribution Channel Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Distribution Channel Code - ' || rv_dcs_sales_order.distbn_chnl_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Division Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        division_dim
      WHERE
        division_code = rv_dcs_sales_order.division_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Division Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Division Code - ' || rv_dcs_sales_order.division_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Sold To Customer Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_cus_hdr
      WHERE
        kunnr = rv_dcs_sales_order.sold_to_cust_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Sold To Customer Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Sold To Customer Code - ' || rv_dcs_sales_order.sold_to_cust_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Ship To Customer Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_cus_hdr
      WHERE
        kunnr = rv_dcs_sales_order.ship_to_cust_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Ship To Customer Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Ship To Customer Code - ' || rv_dcs_sales_order.ship_to_cust_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Bill To Customer Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_cus_hdr
      WHERE
        kunnr = rv_dcs_sales_order.bill_to_cust_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Bill To Customer Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Bill To Customer Code - ' || rv_dcs_sales_order.bill_to_cust_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Payer Customer Code must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        sap_cus_hdr
      WHERE
        kunnr = rv_dcs_sales_order.payer_cust_code;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Payer Customer Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Payer Customer Code - ' || rv_dcs_sales_order.payer_cust_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      -- Matl Code must be zrep level code or has zrep level code.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        matl_dim
      WHERE
        matl_code = rv_dcs_sales_order.matl_code
        AND (matl_type_code = 'ZREP' OR rep_item IS NOT NULL);

      IF v_count = 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_dcs_order, 'n/a', i_log_level + 1,    'dcs_sales_order: ' ||
                                                                          i_company_code   || '/' ||
                                                                          i_order_doc_num  || '/' ||
                                                                          i_order_doc_line_num ||
                                                                          ': Invalid or non-existant Material Code.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_dcs_order,
                                  'Invalid or non-existant Material Code - ' || rv_dcs_sales_order.matl_code,
                                  ods_constants.valdtn_severity_critical,
                                  i_company_code,
                                  i_order_doc_num,
                                  i_order_doc_line_num,
                                  null,
                                  null,
                                  null,
                                  i_log_level + 1);
      END IF;

      UPDATE
        dcs_sales_order
      SET
        valdtn_status = v_valdtn_status
      WHERE
        company_code = i_company_code 
        AND order_doc_num = i_order_doc_num 
        AND order_doc_line_num = i_order_doc_line_num;

    END IF;
    CLOSE csr_dcs_sales_order;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_VALIDATION jobs.
      NULL;

  END validate_dcs_sales_order;

PROCEDURE validate_pmx_accrual_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- Variable Declarations
    v_rec_count PLS_INTEGER := 0;
    v_invalid_flg  BOOLEAN := FALSE;
    v_invalid_count NUMBER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM pmx_accruals
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT cust_code
      FROM 
        pmx_accruals t1
        WHERE NOT EXISTS (SELECT * FROM pmx_cust t2 WHERE t2.cust_code = t1.cust_code)
        AND t1.cust_code IS NOT NULL
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_matl_zrep IS
      SELECT DISTINCT matl_zrep_code
      FROM 
        pmx_accruals t1
        WHERE NOT EXISTS (SELECT * FROM matl_dim t2 WHERE t2.matl_code = t1.matl_zrep_code)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl_zrep csr_matl_zrep%ROWTYPE;

    CURSOR csr_prom IS
      SELECT DISTINCT company_code, division_code, prom_num
      FROM 
        pmx_accruals t1
        WHERE NOT EXISTS (SELECT * FROM pmx_prom_hdr t2 
                           WHERE t2.company_code = t1.company_code
                             AND t2.division_code = t1.division_code
                             AND t2.prom_num = t1.prom_num 
                             AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND t1.prom_num IS NOT NULL
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_prom csr_prom%ROWTYPE;


  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'ods_validation.validate_pmx_accrual_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE pmx_accruals
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      -- Clear the detail table.
      DELETE FROM
        valdtn_reasn_dtl t1
      WHERE EXISTS (SELECT *
                    FROM valdtn_reasn_hdr t2
                    WHERE t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
                    AND t2.valdtn_type_code = ods_constants.valdtn_type_accrual);

      -- Clear the header table.
      DELETE FROM
        valdtn_reasn_hdr
      WHERE
        valdtn_type_code = ods_constants.valdtn_type_accrual;

      COMMIT;

      write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Check for invalid cust_code in pmx_accruals.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Invalid cust_code: ' || rv_cust.cust_code || ' found in pmx_accruals.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'One or more pmx_accruals records with Invalid or non-existant cust_code - ' || rv_cust.cust_code,
                                  ods_constants.valdtn_severity_critical,
                                   'pmx_cust',
                                  rv_cust.cust_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Check for invalid malt_zrep_code in pmx_accruals.');
      OPEN csr_matl_zrep;
      LOOP
        FETCH csr_matl_zrep INTO rv_matl_zrep;
        EXIT WHEN csr_matl_zrep%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Invalid matl_zrep_code: ' || rv_matl_zrep.matl_zrep_code || ' found in pmx_accruals.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'One or more pmx_accruals records with Invalid or non-existant matl_zrep_code - ' || rv_matl_zrep.matl_zrep_code,
                                  ods_constants.valdtn_severity_critical,
                                   'matl_dim',
                                  rv_matl_zrep.matl_zrep_code,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl_zrep;

      write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Check for invalid prom_num in pmx_accruals.');
      OPEN csr_prom;
      LOOP
        FETCH csr_prom INTO rv_prom;
        EXIT WHEN csr_prom%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Invalid prom_num: ' || rv_prom.prom_num || ' found in pmx_accruals.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_accrual,
                                  'One or more pmx_accruals records with Invalid or non-existant prom_num - ' || rv_prom.prom_num,
                                  ods_constants.valdtn_severity_critical,
                                   'pmx_prom_hdr',
                                  rv_prom.company_code,
                                  rv_prom.division_code,
                                  rv_prom.prom_num,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_prom;

      IF v_invalid_flg THEN
         write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in pmx_accruals.');

         UPDATE pmx_accruals t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM pmx_cust t2 WHERE t2.cust_code = t1.cust_code)
           AND t1.cust_code IS NOT NULL
           AND t1.valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         UPDATE pmx_accruals t1
         SET valdtn_status = ods_constants.valdtn_invalid
        WHERE NOT EXISTS (SELECT * FROM matl_dim t2 WHERE t2.matl_code = t1.matl_zrep_code)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         UPDATE pmx_accruals t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM pmx_prom_hdr t2 
                           WHERE t2.company_code = t1.company_code
                             AND t2.division_code = t1.division_code
                             AND t2.prom_num = t1.prom_num 
                             AND t2.valdtn_status = ods_constants.valdtn_valid)
          AND t1.prom_num IS NOT NULL
          AND t1.valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;
      END IF;

     IF v_invalid_count > 0 THEN

       COMMIT;
       write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'There were [' || v_invalid_count || '] records update with INVALID status in pmx_accruals.');

     END IF;

     write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in pmx_accruals.');

     UPDATE pmx_accruals t1
     SET valdtn_status = ods_constants.valdtn_valid
     WHERE valdtn_status = ods_constants.valdtn_unchecked;

     write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] records update with VALID status in pmx_accruals.');

     COMMIT;
   END IF;

   write_log(ods_constants.valdtn_type_accrual, 'n/a', i_log_level + 1, 'ods_validation.validate_pmx_accrual_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_accrual, 'n/a', 0, 'ods_validation.validate_pmx_accrual_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END validate_pmx_accrual_bulk;

END ods_validation_v2; 
/
