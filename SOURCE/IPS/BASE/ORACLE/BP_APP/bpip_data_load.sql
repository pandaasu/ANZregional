
  CREATE OR REPLACE PACKAGE "BP_APP"."BPIP_DATA_LOAD" AS
  /*******************************************************************************
    NAME:      BPIP_DATA_LOAD
    PURPOSE:   This package provides all the processing required to enable the bpip
               data to be loaded into the bpip model

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   5/04/2006 Sal Sanghera          Created
   ********************************************************************************/
  gc_batch_type_inventory     CONSTANT common.st_code := 'INVENTORY';
  gc_batch_type_ppv           CONSTANT common.st_code := 'PPV';
  gc_batch_type_mrp           CONSTANT common.st_code := 'MRP';
  gc_batch_type_safety_stock  CONSTANT common.st_code := 'SAFETY_STOCK';
  gc_batch_type_invoices      CONSTANT common.st_code := 'INVOICES';
  gc_batch_type_movement      CONSTANT common.st_code := 'MOVEMENT';
  gc_batch_type_contracts     CONSTANT common.st_code := 'CONTRACTS';
  gc_batch_type_standards     CONSTANT common.st_code := 'STANDARDS';
  gc_batch_type_recvd         CONSTANT common.st_code := 'RECEIVED';
  gc_batch_type_clsng_inv     CONSTANT common.st_code := 'CLOSING_INVENTORY';


  /*******************************************************************************
     NAME:      INITILISE
     PURPOSE:   This procedure setups parameters for the batches.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   14/12/2006 Nick Bates           Created this procedure.

     NOTES:
    ********************************************************************************/
  PROCEDURE initialise;

  /*************************************************************************
     NAME:      START_LOADING_BATCH
     PURPOSE:   Initialise the processing routine.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: Get the batch id from the sequence and assign it to a package variable.
   Insert the batch id, from_mars_week and to_mars_week into the LOAD_BATCH table.
            Get a lock prior to start of batch processing.
   *************************************************************************/
  PROCEDURE start_loading_batch (
    o_result           OUT     common.st_result,
    o_result_msg       OUT     common.st_message_string,
    i_batch_type_code  IN      common.st_code,
    i_company          IN      common.st_code,
    i_period           IN      common.st_code,
    i_dataentity       IN      common.st_code,
    i_bus_sgmnt        IN      common.st_code);

  /*************************************************************************
      NAME:       END_LOADING_BATCH
      PURPOSE:   End the processing routine.

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------
      1.0   06/06/2006  Sal Sanghera        Created this function.

      NOTES: This procedure will release the lock after completion of batch processing.

    *************************************************************************/
  PROCEDURE end_loading_batch (o_result OUT common.st_result, o_result_msg OUT common.st_message_string);

  /*******************************************************************************
   NAME:      LOAD_INV
   PURPOSE:   This procedure will insert a row into the LOAD_INV_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Sal Sanghera
   NOTES:

  ********************************************************************************/
  PROCEDURE load_inv (
    o_result      OUT     common.st_result,
    o_result_msg  OUT     common.st_message_string,
    i_company     IN      common.st_code,
    i_period      IN      common.st_code,
    i_plant       IN      common.st_code,
    i_material    IN      common.st_code,
    i_stock_type  IN      common.st_code,
    i_inv_qty     IN      common.st_name);

   /*******************************************************************************
   NAME:      LOAD_MRP
   PURPOSE:   This procedure will insert a row into the LOAD_MRP_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
  PROCEDURE load_mrp (
    o_result            OUT     common.st_result,
    o_result_msg        OUT     common.st_message_string,
    i_company           IN      common.st_code,
    i_casting_period    IN      common.st_code,
    i_plant             IN      common.st_code,
    i_material          IN      common.st_code,
    i_period            IN      common.st_code,
    i_requirements_qty  IN      common.st_name,
    i_receipt_qty       IN      common.st_name);

   /*******************************************************************************
   NAME:      LOAD_PPV
   PURPOSE:   This procedure will insert a row into the LOAD_PPV_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
  PROCEDURE load_ppv (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_period          IN      common.st_code,
    i_company         IN      common.st_code,
    i_posting_date    IN      common.st_code,
    i_document_no     IN      common.st_code,
    i_document_type   IN      common.st_code,
    i_document_item   IN      common.st_code,
    i_profit_center   IN      common.st_code,
    i_cost_center     IN      common.st_code,
    i_internal_order  IN      common.st_code,
    i_account         IN      common.st_code,
    i_material_group  IN      common.st_code,
    i_material        IN      common.st_code,
    i_vendor          IN      common.st_code,
    i_item_text       IN      common.st_code,
    i_plant           IN      common.st_code,
    i_local_currency  IN      common.st_code,
    i_ppv_type        IN      common.st_code,
    i_ppv_total       IN      common.st_name,
    i_ppv_po          IN      common.st_name,
    i_ppv_invoice     IN      common.st_name,
    i_ppv_finance     IN      common.st_name,
    i_ppv_freight     IN      common.st_name,
    i_ppv_other       IN      common.st_name);

   /*******************************************************************************
   NAME:      LOAD_CNTCT
   PURPOSE:   This procedure will insert a row into the LOAD_CNTCT_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
  PROCEDURE load_cntct (
    o_result               OUT     common.st_result,
    o_result_msg           OUT     common.st_message_string,
    i_company              IN      common.st_code,
    i_vendor               IN      common.st_code,
    i_contract             IN      common.st_code,
    i_contract_item        IN      common.st_code,
    i_plant                IN      common.st_code,
    i_purchasing_group     IN      common.st_code,
    i_purchase_order       IN      common.st_code,
    i_purchase_order_item  IN      common.st_code,
    i_purchase_doc_type    IN      common.st_code,
    i_purchase_doc_cat     IN      common.st_code,
    i_material             IN      common.st_code,
    i_valid_from_date      IN      common.st_code,
    i_valid_to_date        IN      common.st_code,
    i_open_quantity        IN      common.st_name);

   /*******************************************************************************
   NAME:      LOAD_SAFTY_STK
   PURPOSE:   This procedure will insert a row into the LOAD_SAFTY_STK_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera
   NOTES:

  ********************************************************************************/
  PROCEDURE load_safty_stk (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_company         IN      common.st_code,
    i_casting_period  IN      common.st_code,
    i_plant           IN      common.st_code,
    i_material        IN      common.st_code,
    i_safety_stock    IN      common.st_name);

  /*******************************************************************************
    NAME:      LOAD_STD_COST
    PURPOSE:   This procedure will insert a set of standard cost data into to the
               standards loading table for processing.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   14/08/2006 Chris Horn           Created this procedure.

    NOTES:

   ********************************************************************************/
  PROCEDURE load_std_cost (o_result OUT common.st_result, o_result_msg OUT common.st_message_string);

   /*******************************************************************************
   NAME:      LOAD_MVMT
   PURPOSE:   This procedure will insert a row into the LOAD_MVMT_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
  PROCEDURE load_mvmt (
    o_result           OUT     common.st_result,
    o_result_msg       OUT     common.st_message_string,
    i_company          IN      common.st_code,
    i_period           IN      common.st_code,
    i_plant            IN      common.st_code,
    i_material         IN      common.st_code,
    i_consumption_qty  IN      common.st_name,
    i_sales_qty        IN      common.st_name,
    i_production_qty   IN      common.st_name);

   /*******************************************************************************
   NAME:      LOAD_INVC
   PURPOSE:   This procedure will insert a row into the LOAD_INVC_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
    PROCEDURE load_invc (
    o_result             OUT     common.st_result,
    o_result_msg         OUT     common.st_message_string,
    i_company            IN      common.st_code,
    i_period             IN      common.st_code,
    i_plant              IN      common.st_code,
    i_profit_center      IN      common.st_code,
    i_cost_center        IN      common.st_code,
    i_internal_order     IN      common.st_code,
    i_account            IN      common.st_code,
    i_posting_date       IN      common.st_code,
    i_po_type            IN      common.st_code,
    i_document_type      IN      common.st_code,
    i_item_gl_type       IN      common.st_code,
    i_item_status        IN      common.st_code,
    i_purchasing_group   IN      common.st_code,
    i_vendor             IN      common.st_code,
    i_material_group     IN      common.st_code,
    i_material           IN      common.st_code,
    i_document_currency  IN      common.st_code,
    i_amount_dc          IN      common.st_name,
    i_amount_lc          IN      common.st_name,
    i_invoice_qty        IN      common.st_name);

    /*******************************************************************************
   NAME:      LOAD_RECVD
   PURPOSE:   This procedure will insert a row into the lOAD_RECVD_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   17/07/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
  PROCEDURE load_recvd (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_company        IN      common.st_code,
    i_period         IN      common.st_code,
    i_profit_center  IN      common.st_code,
    i_plant          IN      common.st_code,
    i_vendor         IN      common.st_code,
    i_material       IN      common.st_code,
    i_received_qty   IN      common.st_name);

    /*******************************************************************************
   NAME:      LOAD_CLSNG_INV
   PURPOSE:   This procedure will load a set of data into the LOAD_CLSNG_INV_DATA table

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   01/12/2006 Sal Sanghera

   NOTES:

  ********************************************************************************/
  PROCEDURE load_clsng_inv (o_result OUT common.st_result, o_result_msg OUT common.st_message_string);

  /*************************************************************************
      NAME:      VALIDATE_BATCH
      PURPOSE:

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------
      1.0   06/06/2006  Sal Sanghera        Created this function.

      NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
          procedures to populate the columns that are not directly loaded from SAP BW for
    the bpip cost query.
    *************************************************************************/
  FUNCTION validate_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
      NAME:      VALIDATE_INV_BATCH
      PURPOSE:

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------
      1.0   06/06/2006  Sal Sanghera        Created this function.

      NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
          procedures to populate the columns that are not directly loaded from SAP BW for
    the bpip cost query.
    *************************************************************************/
  FUNCTION validate_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_MRP_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   06/06/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will validate the loaded data.  It will call all the required
            procedures to populate the columns that are not directly loaded from SAP BW for
      the bpip cost query.
      *************************************************************************/
  FUNCTION validate_mrp_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_MRP_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_mrp_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_PPV_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   06/06/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
            procedures to populate the columns that are not directly loaded from SAP BW for
      the bpip cost query.
      *************************************************************************/
  FUNCTION validate_ppv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_PPV_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_ppv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_CNTCT_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   06/06/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
            procedures to populate the columns that are not directly loaded from SAP BW for
      the bpip cost query.
      *************************************************************************/
  FUNCTION validate_cntct_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_cntct_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_SAFTY_STK_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   06/06/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
            procedures to populate the columns that are not directly loaded from SAP BW for
      the bpip cost query.
      *************************************************************************/
  FUNCTION validate_safty_stk_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_SAFTY_STK_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_safty_stk_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_MVMT_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   06/06/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
            procedures to populate the columns that are not directly loaded from SAP BW for
      the bpip cost query.
      *************************************************************************/
  FUNCTION validate_mvmt_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_MVMT_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_mvmt_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_INVC_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   06/06/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
               procedures to populate the columns that are not directly loaded from SAP BW for
               the bpip cost query.
      *************************************************************************/
  FUNCTION validate_invc_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_INVC_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_invc_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
       NAME:      VALIDATE_RECVD_BATCH
       PURPOSE:

       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------
       1.0   06/06/2006  Sal Sanghera        Created this function.

       NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
              procedures to populate the columns that are not directly loaded from SAP BW for
              the bpip cost query.
     *************************************************************************/
  FUNCTION validate_recvd_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
     NAME:      PROCESS_RECVD_BATCH
     PURPOSE:

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------
     1.0   06/06/2006  Sal Sanghera        Created this function.

     NOTES: This procedure will load the staging data into the BPIP Data Model

   *************************************************************************/
  FUNCTION process_recvd_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_STD_COST_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   15/08/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
               procedures to populate the columns that are not directly loaded from SAP BW for
               the bpip cost query.
  *************************************************************************/
  FUNCTION validate_std_cost_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
       NAME:      PROCESS_STD_COST_BATCH
       PURPOSE:   This procedure will load the standard costs into the
                  data entity specified and into actuals for the current
                  period.

       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------
       1.0   28/07/2006 Chris Horn           Created this function.

       NOTES:
  *************************************************************************/
  FUNCTION process_std_cost_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
        NAME:      VALIDATE_CLSNG_INV_BATCH
        PURPOSE:

        REVISIONS:
        Ver   Date       Author               Description
        ----- ---------- -------------------- ----------------------------------
        1.0   15/08/2006  Sal Sanghera        Created this function.

        NOTES: This procedure will VALIDATE the loaded data.  It will call all the required
               procedures to populate the columns that are not directly loaded.
  *************************************************************************/
  FUNCTION validate_clsng_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
       NAME:      PROCESS_CLSNG_INV_BATCH
       PURPOSE:   This procedure will load the clsng_inv into the
                  data entity specified and into actuals for the current
                  period.

       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------
       1.0   01/12/2006 Sal Sanghera         Created this function.

       NOTES:
  *************************************************************************/
  FUNCTION process_clsng_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_BATCH_TYPE
    PURPOSE:   Get the batch type.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   06/06/2006 Sal Sanghera         Created this function.

    NOTES:
  *************************************************************************/
  FUNCTION get_batch_type (i_batch_id IN common.st_id)
    RETURN common.st_code;

   /*************************************************************************
    NAME:      get_batch_loaded_by_id
    PURPOSE:   Get the batch loaded by user id.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   30/08/2006 Chris Horn         Created this function.

    NOTES:
  *************************************************************************/
  FUNCTION get_batch_loaded_by_id (i_batch_id IN common.st_id)
    RETURN common.st_id;

  /*************************************************************************
       NAME:      DELETE_OLD_BATCHES
       PURPOSE:   Delete old batches from the load tables.
       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------
       1.0   12/12/2006 Nick Bates           Created this function.
    1.1   16/04/2007 Chris Horn           Updated code to not require paramaters.

       NOTES: Look for batches which are older then a given date and remove the rows
             from the load tables.
             load_bpip_batch , load_inv_data , load_mrp_data, load_ppv_data , load_cntct_data ,
             load_safty_stk_data , load_std_cost_data, load_mvmt_data ,
             load_invc_data , load_recvd_data, load_clsng_inv_data
     *************************************************************************/
  PROCEDURE delete_old_batches;
END bpip_data_load; /
 

  CREATE OR REPLACE PACKAGE BODY "BP_APP"."BPIP_DATA_LOAD" AS
  pc_package_name                CONSTANT common.st_package_name := 'BPIP_DATA_LOAD';
  pc_lock_name                   CONSTANT lockit.st_lock_name    := 'BPIP_BATCH_LOCK';
  pc_param_bch_day_hist_code     CONSTANT common.st_code         := 'BATCH_DAYS_HIST';
  pc_param_bch_default_day_hist  CONSTANT common.st_value        := 365;
  -- This variable is set at the beginning of the batch.
  pv_batch_id                             common.st_counter;
  pv_line_number                          common.st_counter;

  ---------------------------------------------------------------------------------
  --
  -- Local Procedures
  --
  PROCEDURE initialise IS
    e_system_load_failure  EXCEPTION;
    v_result_msg           common.st_message_string;
    v_return               common.st_result;
  -- standard prcedure message variable
  BEGIN
    logit.enter_method (pc_package_name, 'INITIALISE');
    -- Check the number of load days history to store
    v_return := system_params.exists_parameter (bpip_system.gc_system_code, pc_param_bch_day_hist_code, v_result_msg);

    IF v_return = common.gc_failure THEN
      v_return := system_params.set_parameter_value (bpip_system.gc_system_code, pc_param_bch_day_hist_code, pc_param_bch_default_day_hist, v_result_msg);

      IF v_return != common.gc_success THEN
        logit.log_error (common.create_failure_msg ('Unable to set batch load days history parameter') );
      END IF;

      v_return :=
        system_params.set_parameter_comment (bpip_system.gc_system_code,
                                             pc_param_bch_day_hist_code,
                                             'This parameter controls the number of days worth of batch load history to keep in the system.',
                                             v_result_msg);

      IF v_return != common.gc_success THEN
        logit.log_error (common.create_failure_msg ('Unable to set batch load days history parameter comments.') );
      END IF;
    END IF;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN e_system_load_failure THEN
      logit.log_error (common.create_failure_msg ('Event Failure. ') || common.nest_err_msg (v_result_msg) );
      logit.leave_method;
    WHEN OTHERS THEN
      -- Unhandled exception.
      logit.log_error (common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg () );
      logit.leave_method;
  END initialise;



  PROCEDURE update_bus_sgmnt (i_batch_id IN common.st_id) IS
    v_batch_type  common.st_code;
    v_batch_bus_segment common.st_code; /* David Zhang */
  BEGIN
    logit.LOG ('IN update_bus_sgmnt');
    logit.LOG ('Get the Batch type and use it to evaluate which load table to process ');
    v_batch_type := get_batch_type (i_batch_id);
    /* Added by David Zhang, Dec, 2009 */
    /* To prevent users seeing errors for not selected business segment, set non relavant data to Ignored. */
    SELECT bus_sgmnt
      INTO v_batch_bus_segment
      FROM load_bpip_batch
     WHERE batch_id = i_batch_id;

    logit.LOG('Get Batch level segment '||v_batch_bus_segment);

    CASE v_batch_type
      WHEN gc_batch_type_inventory THEN
        UPDATE load_inv_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt (reference_functions.full_matl_code (a.material), a.plant) )
         WHERE batch_id = i_batch_id;

        UPDATE load_inv_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using material plant to profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;
         
         /* David Zhang */
         UPDATE load_inv_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_ppv THEN
        UPDATE load_ppv_data a
           SET a.bus_sgmnt = bpip_reference.get_bus_sgmnt (SUBSTR (a.profit_center, 6, 6) )
         WHERE batch_id = i_batch_id;

        UPDATE load_ppv_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment using profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;

         /* David Zhang */
         UPDATE load_ppv_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       


      WHEN gc_batch_type_mrp THEN
        UPDATE load_mrp_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt (reference_functions.full_matl_code (a.material), a.plant) )
         WHERE batch_id = i_batch_id;

        UPDATE load_mrp_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using material plant to profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;
         
         /* David Zhang */
         UPDATE load_mrp_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_safety_stock THEN
        UPDATE load_safty_stk_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt (reference_functions.full_matl_code (a.material), a.plant) )
         WHERE batch_id = i_batch_id;

        UPDATE load_safty_stk_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using material plant to profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;
         
         /* David Zhang */
         UPDATE load_safty_stk_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_invoices THEN
        UPDATE load_invc_data a
           SET a.bus_sgmnt = bpip_reference.get_bus_sgmnt (SUBSTR (a.profit_center, 6, 6) )
         WHERE a.status != common.gc_ignored AND batch_id = i_batch_id;

        UPDATE load_invc_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using profit center information. '
         WHERE a.bus_sgmnt IS NULL AND a.status != common.gc_ignored AND batch_id = i_batch_id;
         
         /* David Zhang */
         UPDATE load_invc_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_movement THEN
        UPDATE load_mvmt_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt (reference_functions.full_matl_code (a.material), a.plant) )
         WHERE batch_id = i_batch_id;

        UPDATE load_mvmt_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using material plant to profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;

         /* David Zhang */
         UPDATE load_mvmt_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_contracts THEN
        UPDATE load_cntct_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt_via_srce_list (contract, contract_item) )
         WHERE batch_id = i_batch_id AND status = common.gc_validated AND a.material = lads_characteristics.gc_chrstc_na;

        UPDATE load_cntct_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for contract item using source list lookup. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id AND status = common.gc_validated AND a.material = lads_characteristics.gc_chrstc_na;

        UPDATE load_cntct_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt (reference_functions.full_matl_code (a.material), a.plant) )
         WHERE batch_id = i_batch_id AND status = common.gc_validated AND a.material <> lads_characteristics.gc_chrstc_na;

        UPDATE load_cntct_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using material plant to profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id AND status = common.gc_validated;
         
         /* David Zhang */
         UPDATE load_cntct_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_recvd THEN
        UPDATE load_recvd_data a
           SET a.bus_sgmnt = bpip_reference.get_bus_sgmnt (SUBSTR (a.profit_center, 6, 6) )
         WHERE batch_id = i_batch_id;

        UPDATE load_recvd_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment using profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;

         /* David Zhang */
         UPDATE load_recvd_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       
         
      WHEN gc_batch_type_standards THEN
        UPDATE load_std_cost_data a
           SET a.bus_sgmnt = (bpip_reference.get_bus_sgmnt (reference_functions.full_matl_code (a.material), a.plant) )
         WHERE batch_id = i_batch_id;

        UPDATE load_std_cost_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Unable to lookup business segment for material using material plant to profit center information. '
         WHERE a.bus_sgmnt IS NULL AND batch_id = i_batch_id;

         /* David Zhang */
         UPDATE load_std_cost_data a
            SET a.status = common.gc_ignored,
               a.error_msg = 'Ignored. This business segment is not desired in the batch.'
          WHERE batch_id = i_batch_id AND a.bus_sgmnt <> v_batch_bus_segment;       

    -- clsng_inv bus segment
    END CASE;

    COMMIT;
  END update_bus_sgmnt;

  ---------------------------------------------------------------------------------
  PROCEDURE validate_matl (i_batch_id IN common.st_id) IS
    v_batch_type  common.st_code;
  BEGIN
    logit.LOG ('IN validate_matl');
    logit.LOG ('Get the Batch type and use it to evaluate which load table to process ');
    v_batch_type := get_batch_type (i_batch_id);

    CASE v_batch_type
      WHEN gc_batch_type_inventory THEN
        UPDATE load_inv_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND batch_id = i_batch_id;
      WHEN gc_batch_type_ppv THEN
        UPDATE load_ppv_data a
           SET a.status = common.gc_warning,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND
               batch_id = i_batch_id AND
               a.material <> lads_characteristics.gc_chrstc_na;
      WHEN gc_batch_type_mrp THEN
        logit.LOG ('gc_batch_type_mrp = ' || gc_batch_type_mrp);

        UPDATE load_mrp_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND batch_id = i_batch_id;
      WHEN gc_batch_type_safety_stock THEN
        UPDATE load_safty_stk_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND batch_id = i_batch_id;
      WHEN gc_batch_type_invoices THEN
        UPDATE load_invc_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE a.status != common.gc_ignored AND
               bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND
               a.material <> lads_characteristics.gc_chrstc_na AND
               batch_id = i_batch_id;
      WHEN gc_batch_type_movement THEN
        UPDATE load_inv_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND batch_id = i_batch_id;
      WHEN gc_batch_type_contracts THEN
        UPDATE load_cntct_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND
               batch_id = i_batch_id AND
               status = common.gc_validated AND
               material <> lads_characteristics.gc_chrstc_na;
      WHEN gc_batch_type_recvd THEN
        UPDATE load_recvd_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND
               batch_id = i_batch_id AND
               a.material <> lads_characteristics.gc_chrstc_na;
      WHEN gc_batch_type_standards THEN
        UPDATE load_std_cost_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || 'Material did not exist in LADS. '
         WHERE bpip_reference.validate_matl (reference_functions.full_matl_code (a.material) ) IS NULL AND batch_id = i_batch_id;
    END CASE;

    COMMIT;
  END validate_matl;

  ---------------------------------------------------------------------------------
  PROCEDURE validate_matl_prfcnr (i_batch_id IN common.st_id) IS
    v_batch_type  common.st_code;
  BEGIN
    UPDATE load_invc_data a
       SET a.status = common.gc_ignored,
           a.error_msg = a.error_msg || 'Row Ignored due to # value for material or profit centre. '
     WHERE (a.material = lads_characteristics.gc_chrstc_na OR SUBSTR (a.profit_center, 6, 6) = lads_characteristics.gc_chrstc_na) AND batch_id = i_batch_id;

    COMMIT;
  END validate_matl_prfcnr;

  ---------------------------------------------------------------------------------
  PROCEDURE set_requirement IS
    CURSOR csr_mrp IS
      SELECT a.material, a.plant
      FROM load_mrp_data a
      WHERE a.status IN (common.gc_validated)
      FOR UPDATE;

    CURSOR csr_get_prcrmnt (i_matl IN VARCHAR2, i_plant IN VARCHAR2) IS
      SELECT a.prcrmnt_type, a.spcl_prcrmnt_type
      FROM matl_by_plant a
      WHERE a.matl_code = reference_functions.full_matl_code (i_matl) AND a.plant = i_plant;

    CURSOR csr_get_requirement (i_prcrmnt_type IN VARCHAR2, i_spcl_prcrmnt_type IN VARCHAR2, i_plant IN VARCHAR2) IS
      SELECT b.consumption
      FROM mrp_prcrmnt_xref b
      WHERE b.prcrmnt_type = i_prcrmnt_type AND b.spcl_prcrmnt_type = i_spcl_prcrmnt_type AND b.plant = i_plant;

    v_prcrmnt            common.st_code;
    v_spcl_prcrmnt_type  common.st_code;
    v_requirement        common.st_code;
  BEGIN
    --logit.LOG ('In SET_REQUIREMENT');
    FOR v_mrp IN csr_mrp
    LOOP
      -- logit.LOG ('In csr_mrp LOOP MATERIAL,PLANT :' || v_mrp.material || ', ' || v_mrp.plant);
      OPEN csr_get_prcrmnt (v_mrp.material, v_mrp.plant);

      FETCH csr_get_prcrmnt
      INTO v_prcrmnt, v_spcl_prcrmnt_type;

      CLOSE csr_get_prcrmnt;

      IF v_prcrmnt IS NULL OR v_spcl_prcrmnt_type IS NULL THEN
        logit.LOG ('v_prcrmnt IS NULL OR v_spcl_prcrmnt_type IS NULL');

        UPDATE load_mrp_data a
           SET a.status = common.gc_errored,
               a.error_msg = a.error_msg || ' prcrmnt_type OR a.spcl_prcrmnt_type IS NULL'
         WHERE CURRENT OF csr_mrp;
      END IF;

      OPEN csr_get_requirement (v_prcrmnt, v_spcl_prcrmnt_type, v_mrp.plant);

      FETCH csr_get_requirement
      INTO v_requirement;

      IF csr_get_requirement%NOTFOUND THEN
        logit.LOG (' UPDATE load_mrp_data No matching row found in mrp_prcrmnt_xref for prcrmnt_type');

        UPDATE load_mrp_data a
           SET a.status = common.gc_errored,
               a.error_msg =
                 a.error_msg || 'No matching row found in mrp_prcrmnt_xref for prcrmnt_type : ' || v_prcrmnt || ' and spcl_prcrmnt_type : '
                 || v_spcl_prcrmnt_type
         WHERE CURRENT OF csr_mrp;
      ELSIF v_requirement = 'N' THEN
        logit.LOG (' Row Ignored for requirement');

        UPDATE load_mrp_data a
           SET a.status = common.gc_ignored,
               a.error_msg = a.error_msg || 'Row Ignored for requirement : ' || v_requirement
         WHERE CURRENT OF csr_mrp;
      ELSIF v_requirement = 'Y' THEN
        logit.LOG (' v_requirement = Y, ROW STILL VALID');
      END IF;

      CLOSE csr_get_requirement;
    END LOOP;

    COMMIT;
  END set_requirement;

  PROCEDURE start_loading_batch (
    o_result           OUT     common.st_result,
    o_result_msg       OUT     common.st_message_string,
    i_batch_type_code  IN      common.st_code,
    i_company          IN      common.st_code,
    i_period           IN      common.st_code,
    i_dataentity       IN      common.st_code,
    i_bus_sgmnt        IN      common.st_code) IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
    --v_batch_id        common.st_id;
    e_lock_error      EXCEPTION;   -- failed to get exclusive lock
    e_batch_id        EXCEPTION;

    --
    CURSOR csr_batch_key IS
      SELECT a.batch_id
      FROM load_bpip_batch a
      WHERE a.batch_type_code = i_batch_type_code AND
       a.company = i_company AND
       common.sql_are_equal (a.bus_sgmnt, i_bus_sgmnt) = 1 AND
       common.sql_are_equal (a.period, i_period) = 1 AND
       common.sql_are_equal (a.dataentity, i_dataentity) = 1;

    rv_batch_key      csr_batch_key%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'START_LOADING_BATCH');
    v_result := common.gc_success;

    -- Make sure the batch is in the defined set of batches.
    IF UPPER (i_batch_type_code) NOT IN
         (gc_batch_type_inventory,
          gc_batch_type_ppv,
          gc_batch_type_mrp,
          gc_batch_type_safety_stock,
          gc_batch_type_invoices,
          gc_batch_type_movement,
          gc_batch_type_contracts,
          gc_batch_type_standards,
          gc_batch_type_recvd,
          gc_batch_type_clsng_inv) THEN
      v_processing_msg := 'Unknown batch type code : ' || i_batch_type_code;
      RAISE common.ge_error;
    END IF;

    -- get the batch id from the sequence and assign it to a package variable
    IF bpip_object_tracking.get_new_id ('LOAD_BPIP_BATCH', 'BATCH_ID', pv_batch_id, v_result_msg) != common.gc_success THEN
      RAISE e_batch_id;
    END IF;

    -- Get lock
    IF lockit.request_lock (pc_lock_name || '_' || pv_batch_id, lockit.gc_lock_mode_exclusive, FALSE, v_result_msg) != common.gc_success THEN
      RAISE e_lock_error;
    END IF;

    -- set the package variable pv_line_number
    pv_line_number := 1;

    -- If any batches exist with the same key columns (company, period, dataentity, business segment) for a given batch type
    -- then change the status of these batches to replaced
    FOR v_batch_key IN csr_batch_key
    LOOP
      UPDATE load_bpip_batch a
         SET a.status = common.gc_replaced
       WHERE a.batch_id = v_batch_key.batch_id;
    END LOOP;

    -- commit any updates
    COMMIT;

    -- Insert batch details into the LOAD_BPIP_BATCH table.
    logit.log('Business Segment: ' || i_bus_sgmnt);
    INSERT INTO load_bpip_batch
                (batch_id, batch_type_code, company, period, dataentity, bus_sgmnt, status, loaded_by, load_start_time)
         VALUES (pv_batch_id, i_batch_type_code, i_company, i_period, i_dataentity, i_bus_sgmnt, common.gc_loading, security.current_user_id, SYSDATE);

    COMMIT;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      o_result := common.gc_failure;
      logit.LOG (o_result_msg);
      logit.leave_method;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
    WHEN e_batch_id THEN
      o_result_msg := common.create_failure_msg ('Could not allocate batch id :' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_lock_error THEN
      o_result_msg := common.create_failure_msg ('Lock Error' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
  END start_loading_batch;

  ---------------------------------------------------------------------------------
  PROCEDURE end_loading_batch (o_result OUT common.st_result, o_result_msg OUT common.st_message_string) IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
    v_batch_type      common.st_code;
    e_lock_error      EXCEPTION;   -- failed to get exclusive lock
    e_event_error     EXCEPTION;   -- event processing error
  BEGIN
    logit.enter_method (pc_package_name, 'END_LOADING_BATCH');
    v_result := common.gc_success;
    -- Release lock
    logit.LOG ('bpip processing complete.');

    -- Update the LOAD_BPIP_BATCH status to LOADED when the processing is complete
    UPDATE load_bpip_batch a
       SET a.status = common.gc_loaded,
           a.load_end_time = SYSDATE
     WHERE a.batch_id = pv_batch_id;
    COMMIT;

    -- Release the lock.
    IF lockit.release_lock (pc_lock_name || '_' || pv_batch_id, v_result_msg) != common.gc_success THEN
      RAISE e_lock_error;
    END IF;

    -- gather table and index stats for the loaded table
    logit.LOG ('Get the Batch type and use it to evaluate which Validate batch function to call ');
    v_batch_type := get_batch_type (pv_batch_id);

    CASE v_batch_type
      WHEN gc_batch_type_inventory THEN
        logit.LOG ('Analyze table and index for LOAD_INV_DATA');
        bp.schema_management.analyze_table ('LOAD_INV_DATA');
        bp.schema_management.analyze_index ('LOAD_INV_DATA_PK01');
      WHEN gc_batch_type_ppv THEN
        logit.LOG ('Analyze table and index for LOAD_PPV_DATA');
        bp.schema_management.analyze_table ('LOAD_PPV_DATA');
        bp.schema_management.analyze_index ('LOAD_PPV_DATA_PK01');
      WHEN gc_batch_type_mrp THEN
        logit.LOG ('Analyze table and index for LOAD_MRP_DATA');
        bp.schema_management.analyze_table ('LOAD_MRP_DATA');
        bp.schema_management.analyze_index ('LOAD_MRP_DATA_PK01');
      WHEN gc_batch_type_safety_stock THEN
        logit.LOG ('Analyze table and index for LOAD_SAFTY_STK_DATA');
        bp.schema_management.analyze_table ('LOAD_SAFTY_STK_DATA');
        bp.schema_management.analyze_index ('LOAD_SAFTY_STK_DATA_PK01');
      WHEN gc_batch_type_invoices THEN
        logit.LOG ('Analyze table and index for LOAD_INVC_DATA');
        bp.schema_management.analyze_table ('LOAD_INVC_DATA');
        bp.schema_management.analyze_index ('LOAD_INVC_DATA_PK01');
      WHEN gc_batch_type_movement THEN
        logit.LOG ('Analyze table and index for LOAD_MVMT_DATA');
        bp.schema_management.analyze_table ('LOAD_MVMT_DATA');
        bp.schema_management.analyze_index ('LOAD_MVMT_DATA_PK01');
      WHEN gc_batch_type_contracts THEN
        logit.LOG ('Analyze table and index for LOAD_CNTCT_DATA');
        bp.schema_management.analyze_table ('LOAD_CNTCT_DATA');
        bp.schema_management.analyze_index ('LOAD_CNTCT_DATA_PK01');
      WHEN gc_batch_type_recvd THEN
        logit.LOG ('Analyze table and index for LOAD_RECVD_DATA');
        bp.schema_management.analyze_table ('LOAD_RECVD_DATA');
        bp.schema_management.analyze_index ('LOAD_RECVD_QTY_DATA_PK01');
      WHEN gc_batch_type_standards THEN
        logit.LOG ('Analyze table and index for LOAD_STD_COST_DATA');
        bp.schema_management.analyze_table ('LOAD_STD_COST_DATA');
        bp.schema_management.analyze_index ('LOAD_STD_COST_DATA_PK01');
      WHEN gc_batch_type_clsng_inv THEN
        logit.LOG ('Analyze table and index for LOAD_CLSNG_INV_DATA');
        bp.schema_management.analyze_table ('LOAD_CLSNG_INV_DATA');
        bp.schema_management.analyze_index ('LOAD_CLSNG_INV_DATA_PK01');
        bp.schema_management.analyze_index ('LOAD_CLSNG_INV_DATA_NU02');
    --         ELSE
    --           v_processing_msg := 'No batch type code found for supplied batch id :' || i_batch_id;
    --           RAISE common.ge_failure;
    END CASE;

    -- end gather table and index stats for the loaded table

    -- data loaded sucessfully , so create event.
    IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_validate_batch, pv_batch_id, 'File loaded', v_result_msg) != common.gc_success THEN
      RAISE e_event_error;
    END IF;

    -- now trigger the event
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to trigger event process. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now change the status to PENDING ready for procssing.
    UPDATE load_bpip_batch a
       SET a.status = common.gc_pending
     WHERE a.batch_id = pv_batch_id;

    COMMIT;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      o_result := common.gc_failure;
      logit.LOG (o_result_msg);
      logit.leave_method;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
    WHEN e_lock_error THEN
      o_result_msg := common.create_failure_msg ('Lock Error' || v_result_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
  END end_loading_batch;

  ---------------------------------------------------------------------------------
  PROCEDURE load_inv (
    o_result      OUT     common.st_result,
    o_result_msg  OUT     common.st_message_string,
    i_company     IN      common.st_code,
    i_period      IN      common.st_code,
    i_plant       IN      common.st_code,
    i_material    IN      common.st_code,
    i_stock_type  IN      common.st_code,
    i_inv_qty     IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_INV');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into load_inv_data table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_inv_data
                (batch_id, line_no, company, period, plant, material, stock_type, inventory_qty, status)
         VALUES (pv_batch_id, pv_line_number, i_company, i_period, i_plant, i_material, i_stock_type, i_inv_qty, common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_inv;

  ---------------------------------------------------------------------------------
  PROCEDURE load_mrp (
    o_result            OUT     common.st_result,
    o_result_msg        OUT     common.st_message_string,
    i_company           IN      common.st_code,
    i_casting_period    IN      common.st_code,
    i_plant             IN      common.st_code,
    i_material          IN      common.st_code,
    i_period            IN      common.st_code,
    i_requirements_qty  IN      common.st_name,
    i_receipt_qty       IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_MRP');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into load_mrp_data table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_mrp_data
                (batch_id, line_no, company, casting_period, plant, material, period, requirements_qty, receipt_qty, status)
         VALUES (pv_batch_id, pv_line_number, i_company, i_casting_period, i_plant, i_material, i_period, i_requirements_qty, i_receipt_qty, common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_mrp;

  ---------------------------------------------------------------------------------
  PROCEDURE load_ppv (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_period          IN      common.st_code,
    i_company         IN      common.st_code,
    i_posting_date    IN      common.st_code,
    i_document_no     IN      common.st_code,
    i_document_type   IN      common.st_code,
    i_document_item   IN      common.st_code,
    i_profit_center   IN      common.st_code,
    i_cost_center     IN      common.st_code,
    i_internal_order  IN      common.st_code,
    i_account         IN      common.st_code,
    i_material_group  IN      common.st_code,
    i_material        IN      common.st_code,
    i_vendor          IN      common.st_code,
    i_item_text       IN      common.st_code,
    i_plant           IN      common.st_code,
    i_local_currency  IN      common.st_code,
    i_ppv_type        IN      common.st_code,
    i_ppv_total       IN      common.st_name,
    i_ppv_po          IN      common.st_name,
    i_ppv_invoice     IN      common.st_name,
    i_ppv_finance     IN      common.st_name,
    i_ppv_freight     IN      common.st_name,
    i_ppv_other       IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_PPV');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into load_mrp_data table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_ppv_data
                (batch_id, line_no, period, company, posting_date, document_no, document_type, document_item, profit_center,
                 cost_center, internal_order, ACCOUNT, material_group, material, vendor, item_text, plant, local_currency, ppv_type,
                 ppv_total, ppv_po, ppv_invoice, ppv_finance, ppv_freight, ppv_other, status)
         VALUES (pv_batch_id, pv_line_number, i_period, i_company, i_posting_date, i_document_no, i_document_type, i_document_item, i_profit_center,
                 i_cost_center, i_internal_order, i_account, i_material_group, i_material, i_vendor, i_item_text, i_plant, i_local_currency, i_ppv_type,
                 i_ppv_total, i_ppv_po, i_ppv_invoice, i_ppv_finance, i_ppv_freight, i_ppv_other, common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_ppv;

  ---------------------------------------------------------------------------------
  PROCEDURE load_cntct (
    o_result               OUT     common.st_result,
    o_result_msg           OUT     common.st_message_string,
    i_company              IN      common.st_code,
    i_vendor               IN      common.st_code,
    i_contract             IN      common.st_code,
    i_contract_item        IN      common.st_code,
    i_plant                IN      common.st_code,
    i_purchasing_group     IN      common.st_code,
    i_purchase_order       IN      common.st_code,
    i_purchase_order_item  IN      common.st_code,
    i_purchase_doc_type    IN      common.st_code,
    i_purchase_doc_cat     IN      common.st_code,
    i_material             IN      common.st_code,
    i_valid_from_date      IN      common.st_code,
    i_valid_to_date        IN      common.st_code,
    i_open_quantity        IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_CNTCT');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into load_cntct_data table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_cntct_data
                (batch_id, line_no, company, vendor, contract, contract_item, plant, purchasing_group, purchase_order,
                 purchase_order_item, purchase_doc_type, purchase_doc_category, material, valid_from_date, valid_to_date, open_quantity,
                 status)
         VALUES (pv_batch_id, pv_line_number, i_company, i_vendor, i_contract, i_contract_item, i_plant, i_purchasing_group, i_purchase_order,
                 i_purchase_order_item, i_purchase_doc_type, i_purchase_doc_cat, i_material, i_valid_from_date, i_valid_to_date, i_open_quantity,
                 common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_cntct;

  ---------------------------------------------------------------------------------
  PROCEDURE load_safty_stk (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_company         IN      common.st_code,
    i_casting_period  IN      common.st_code,
    i_plant           IN      common.st_code,
    i_material        IN      common.st_code,
    i_safety_stock    IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_SAFTY_STK');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into load_cntct_data table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_safty_stk_data
                (batch_id, line_no, company, casting_period, plant, material, safety_stock, status)
         VALUES (pv_batch_id, pv_line_number, i_company, i_casting_period, i_plant, i_material, i_safety_stock, common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_safty_stk;

  ---------------------------------------------------------------------------------
  PROCEDURE load_std_cost (o_result OUT common.st_result, o_result_msg OUT common.st_message_string) IS
    v_return                  common.st_result;
    v_result                  common.st_result;
    v_processing_msg          common.st_message_string;
    v_period_codes            common.t_codes;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity  common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id    common.st_id;
    -- Other
    v_result_msg              common.st_message_string;
    v_dataentity_fromperiod   common.st_code;
    v_dataentity_toperiod     common.st_code;
    v_current_period          common.st_code;
    v_period_counter          common.st_counter;

    CURSOR csr_batch_details IS
      SELECT company, period, dataentity, bus_sgmnt
      FROM load_bpip_batch
      WHERE batch_id = pv_batch_id;

    rv_batch_details          csr_batch_details%ROWTYPE;

       -- Cursor to return the calculated price based on the order of precedence below.  Used for BR
    -- L - PLANNED PRICE
    --      F - FUTURE STANDARD PRICE
    --         C - CURRENT STANDARD PRICE
    --          P - PREVIOUS STANDARD PRICE
    CURSOR csr_standards (i_company_code IN common.st_code, i_period IN common.st_code) IS
      SELECT t2.matl_code, t3.vltn_area AS plant, i_period AS period, t3.planned_price_date, t3.planned_price, t3.future_std_period, t3.future_std_price,
        t3.current_std_period, t3.current_std_price, t3.previous_std_period, t3.previous_std_price,
        (CASE
           WHEN DECODE (t3.planned_price_date, '00000000', '99999999', t3.planned_price_date) <= (SELECT MIN (yyyymmdd_date)
                                                                                                  FROM mars_date
                                                                                                  WHERE mars_period = i_period) THEN t3.planned_price
           ELSE (CASE
                   WHEN i_period > DECODE (t3.future_std_period, '000000', i_period, t3.future_std_period) THEN t3.future_std_price
                   ELSE (CASE
                           WHEN (DECODE (t3.current_std_period, '000000', i_period, t3.current_std_period) > i_period) THEN (CASE
                                                                                                                               WHEN (i_period >=
                                                                                                                                       DECODE
                                                                                                                                         (t3.previous_std_period,
                                                                                                                                          '000000', '999999',
                                                                                                                                          t3.previous_std_period) ) THEN t3.previous_std_price
                                                                                                                               ELSE NULL
                                                                                                                             END)
                           ELSE t3.current_std_price
                         END)
                 END)
         END) AS calculated_price,
        (CASE
           WHEN DECODE (t3.planned_price_date, '00000000', '99999999', t3.planned_price_date) <= (SELECT MIN (yyyymmdd_date)
                                                                                                  FROM mars_date
                                                                                                  WHERE mars_period = i_period) THEN 'L'
           ELSE (CASE
                   WHEN i_period > DECODE (t3.future_std_period, '000000', i_period, t3.future_std_period) THEN 'F'
                   ELSE (CASE
                           WHEN (DECODE (t3.current_std_period, '000000', i_period, t3.current_std_period) > i_period) THEN (CASE
                                                                                                                               WHEN (i_period >=
                                                                                                                                       DECODE
                                                                                                                                         (t3.previous_std_period,
                                                                                                                                          '000000', '999999',
                                                                                                                                          t3.previous_std_period) ) THEN 'P'
                                                                                                                               ELSE 'E'
                                                                                                                             END)
                           ELSE 'C'
                         END)
                 END)
         END) AS calculated_source
      FROM plant t1, matl t2, matl_vltn t3
      WHERE t1.plant = t3.vltn_area AND
       t3.vltn_area_dltn_indctr IS NULL AND
       t2.matl_code = t3.matl_code AND
       t2.matl_type IN
               (lads_characteristics.gc_chrstc_matl_type_roh, lads_characteristics.gc_chrstc_matl_type_verp, lads_characteristics.gc_chrstc_matl_type_fert) AND
       t2.x_plant_matl_sts IN ('10', '40') AND
       t2.dltn_indctr IS NULL AND
       EXISTS (SELECT *
               FROM matl_by_plant t0
               WHERE t0.matl_code = t2.matl_code AND t0.plant = t1.plant AND t0.dltn_indctr IS NULL AND t0.plant_sts IN ('03', '20') AND t0.no_cost IS NULL)
                                                                                                                                                            -- planning, active  (others are 99 Retired, 50 and 23 Data Input)
      AND
       (t3.current_std_price <> 0 OR t3.future_std_price <> 0) AND
       t1.sales_org = i_company_code;

    rv_standards              csr_standards%ROWTYPE;

    -- Cursor to return the calculated price based on the order of precedence below.  Used for ACTUALS.

    --         C - CURRENT STANDARD PRICE
    --          P - PREVIOUS STANDARD PRICE
    CURSOR csr_standards_actuals (i_company_code IN common.st_code, i_period IN common.st_code) IS
      SELECT t2.matl_code, t3.vltn_area AS plant, i_period AS period, t3.planned_price_date, t3.planned_price, t3.future_std_period, t3.future_std_price,
        t3.current_std_period, t3.current_std_price, t3.previous_std_period, t3.previous_std_price,
        (CASE
           WHEN (DECODE (t3.current_std_period, '000000', i_period, t3.current_std_period) > i_period) THEN (CASE
                                                                                                               WHEN (i_period >=
                                                                                                                       DECODE (t3.previous_std_period,
                                                                                                                               '000000', '999999',
                                                                                                                               t3.previous_std_period) ) THEN t3.previous_std_price
                                                                                                               ELSE NULL
                                                                                                             END)
           ELSE t3.current_std_price
         END) AS calculated_price,
        (CASE
           WHEN (DECODE (t3.current_std_period, '000000', i_period, t3.current_std_period) > i_period) THEN (CASE
                                                                                                               WHEN (i_period >=
                                                                                                                       DECODE (t3.previous_std_period,
                                                                                                                               '000000', '999999',
                                                                                                                               t3.previous_std_period) ) THEN 'P'
                                                                                                               ELSE 'E'
                                                                                                             END)
           ELSE 'C'
         END) AS calculated_source
      FROM plant t1, matl t2, matl_vltn t3
      WHERE t1.plant = t3.vltn_area AND
       t3.vltn_area_dltn_indctr IS NULL AND
       t2.matl_code = t3.matl_code AND
       t2.matl_type IN
               (lads_characteristics.gc_chrstc_matl_type_roh, lads_characteristics.gc_chrstc_matl_type_verp, lads_characteristics.gc_chrstc_matl_type_fert) AND
       t2.x_plant_matl_sts IN ('10', '40') AND
       t2.dltn_indctr IS NULL AND
       EXISTS (SELECT *
               FROM matl_by_plant t0
               WHERE t0.matl_code = t2.matl_code AND t0.plant = t1.plant AND t0.dltn_indctr IS NULL AND t0.plant_sts IN ('03', '20') AND t0.no_cost IS NULL) AND
       (t3.current_std_price <> 0 OR t3.future_std_price <> 0) AND
       t1.sales_org = i_company_code;

    rv_standards_actuals      csr_standards_actuals%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_STD_COST');
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_processing_msg := 'Batch id has not currently been allocated.';
      RAISE common.ge_error;
    END IF;

    IF pv_line_number IS NULL THEN
      v_processing_msg := 'Line number is currently null.';
      RAISE common.ge_error;
    END IF;

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND = TRUE THEN
      v_processing_msg := 'Unable to find Batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    -- get the periods and assign to an array
    -- process the array of periods
    IF rv_batch_details.dataentity = finance_characteristics.gc_chrstc_dataentity_actuals THEN
      --v_period_codes (1) := rv_batch_details.period;
      logit.LOG ('Inserting Standards data into Standards table for ACTUALS.  Batch :' || pv_batch_id);

      -- Process standards for all periods in the period codes array
      OPEN csr_standards_actuals (rv_batch_details.company, rv_batch_details.period);

      LOOP
        FETCH csr_standards_actuals
        INTO rv_standards_actuals;

        EXIT WHEN csr_standards_actuals%NOTFOUND;

        INSERT INTO load_std_cost_data
                    (batch_id, line_no, company, material,
                     plant, current_std_price, current_std_period,
                     future_std_price, future_std_period, planned_price,
                     planned_price_date, calculated_price, status, period,
                     calculated_source, previous_std_price, previous_std_period)
             VALUES (pv_batch_id, pv_line_number, rv_batch_details.company, reference_functions.short_matl_code (rv_standards_actuals.matl_code),
                     rv_standards_actuals.plant, rv_standards_actuals.current_std_price, rv_standards_actuals.current_std_period,
                     rv_standards_actuals.future_std_price, rv_standards_actuals.future_std_period, rv_standards_actuals.planned_price,
                     rv_standards_actuals.planned_price_date, rv_standards_actuals.calculated_price, common.gc_loaded, rv_batch_details.period,
                     rv_standards_actuals.calculated_source, rv_standards_actuals.previous_std_price, rv_standards_actuals.previous_std_period);

        -- Increment the line number package varaiable
        pv_line_number := pv_line_number + 1;
      END LOOP;

      CLOSE csr_standards_actuals;

      COMMIT;
    ELSE
      -- get the chrstc type for the data entity
      v_return := characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic Type lookups for bpip failed or errored.';
        RAISE common.ge_error;
      END IF;

      -- get the chrstc id for the data entity
      v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity, rv_batch_details.dataentity, v_chrstc_dataentity_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Data Entity failed or errored';
        RAISE common.ge_error;
      END IF;

      -- Get the from period for this data entity.
      v_return :=
        characteristics.get_chrstc_attrb_value (v_chrstc_dataentity_id,
                                                finance_characteristics.gc_chrstc_dataentity_fromprd,
                                                v_dataentity_fromperiod,
                                                v_result_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Could not lookup data entity from period.';
        RAISE common.ge_error;
      END IF;

      -- Get the to_period for this DataEntity.
      v_return :=
        characteristics.get_chrstc_attrb_value (v_chrstc_dataentity_id, finance_characteristics.gc_chrstc_dataentity_toprd, v_dataentity_toperiod, v_result_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Could not lookup data entity from period.';
        RAISE common.ge_error;
      END IF;

      logit.LOG ('Data Entity : ' || rv_batch_details.dataentity || ' From Period : ' || v_dataentity_fromperiod || ' To Period : ' || v_dataentity_toperiod);
      v_current_period := v_dataentity_fromperiod;
      v_period_counter := 0;

      LOOP
        -- Now lookup the period characteristic id.
        v_period_counter := v_period_counter + 1;
        v_period_codes (v_period_counter) := v_current_period;

        -- Now increment the period counter and see if we can move onto the next period.
        BEGIN
          v_current_period := TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_current_period), 1) );
        EXCEPTION
          WHEN OTHERS THEN
            v_processing_msg := 'Failed to increment the current period during the period array processing.';
            RAISE common.ge_error;
        END;

        EXIT WHEN v_current_period > v_dataentity_toperiod;
      END LOOP;

      logit.LOG ('Inserting Standards data into Standards table.  Batch :' || pv_batch_id);
      -- Process standards for all periods in the period codes array
      v_period_counter := 1;

      WHILE v_period_counter <= v_period_codes.COUNT
      LOOP
        OPEN csr_standards (rv_batch_details.company, v_period_codes (v_period_counter));

        LOOP
          FETCH csr_standards
          INTO rv_standards;

          EXIT WHEN csr_standards%NOTFOUND;

          INSERT INTO load_std_cost_data
                      (batch_id, line_no, company, material,
                       plant, current_std_price, current_std_period, future_std_price,
                       future_std_period, planned_price, planned_price_date, calculated_price,
                       status, period, calculated_source, previous_std_price,
                       previous_std_period)
               VALUES (pv_batch_id, pv_line_number, rv_batch_details.company, reference_functions.short_matl_code (rv_standards.matl_code),
                       rv_standards.plant, rv_standards.current_std_price, rv_standards.current_std_period, rv_standards.future_std_price,
                       rv_standards.future_std_period, rv_standards.planned_price, rv_standards.planned_price_date, rv_standards.calculated_price,
                       common.gc_loaded, v_period_codes (v_period_counter), rv_standards.calculated_source, rv_standards.previous_std_price,
                       rv_standards.previous_std_period);

          -- Increment the line number package varaiable
          pv_line_number := pv_line_number + 1;
        END LOOP;

        CLOSE csr_standards;

        COMMIT;
        v_period_counter := v_period_counter + 1;
      END LOOP;
    END IF;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
  END load_std_cost;

  ---------------------------------------------------------------------------------
  PROCEDURE load_mvmt (
    o_result           OUT     common.st_result,
    o_result_msg       OUT     common.st_message_string,
    i_company          IN      common.st_code,
    i_period           IN      common.st_code,
    i_plant            IN      common.st_code,
    i_material         IN      common.st_code,
    i_consumption_qty  IN      common.st_name,
    i_sales_qty        IN      common.st_name,
    i_production_qty   IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_MVMT');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into load_mvmt_data table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_mvmt_data
                (batch_id, line_no, company, period, plant, material, consumption_qty, sales_qty, production_qty, status)
         VALUES (pv_batch_id, pv_line_number, i_company, i_period, i_plant, i_material, i_consumption_qty, i_sales_qty, i_production_qty, common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_mvmt;

  ---------------------------------------------------------------------------------
  PROCEDURE load_invc (
    o_result             OUT     common.st_result,
    o_result_msg         OUT     common.st_message_string,
    i_company            IN      common.st_code,
    i_period             IN      common.st_code,
    i_plant              IN      common.st_code,
    i_profit_center      IN      common.st_code,
    i_cost_center        IN      common.st_code,
    i_internal_order     IN      common.st_code,
    i_account            IN      common.st_code,
    i_posting_date       IN      common.st_code,
    i_po_type            IN      common.st_code,
    i_document_type      IN      common.st_code,
    i_item_gl_type       IN      common.st_code,
    i_item_status        IN      common.st_code,
    i_purchasing_group   IN      common.st_code,
    i_vendor             IN      common.st_code,
    i_material_group     IN      common.st_code,
    i_material           IN      common.st_code,
    i_document_currency  IN      common.st_code,
    i_amount_dc          IN      common.st_name,
    i_amount_lc          IN      common.st_name,
    i_invoice_qty        IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_INVC');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into LOAD_INVC_DATA table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_invc_data
                (batch_id, line_no, period, company, plant, profit_center, cost_center, internal_order, ACCOUNT, posting_date,
                 po_type, document_type, item_gl_type, item_status, purchasing_group, vendor, material_group, material, document_currency,
                 amount_dc, amount_lc, status, invoice_qty)
         VALUES (pv_batch_id, pv_line_number, i_period, i_company, i_plant, i_profit_center, i_cost_center, i_internal_order, i_account, i_posting_date,
                 i_po_type, i_document_type, i_item_gl_type, i_item_status, i_purchasing_group, i_vendor, i_material_group, i_material, i_document_currency,
                 i_amount_dc, i_amount_lc, common.gc_loaded, i_invoice_qty);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_invc;

  ---------------------------------------------------------------------------------
  PROCEDURE load_recvd (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_company        IN      common.st_code,
    i_period         IN      common.st_code,
    i_profit_center  IN      common.st_code,
    i_plant          IN      common.st_code,
    i_vendor         IN      common.st_code,
    i_material       IN      common.st_code,
    i_received_qty   IN      common.st_name) IS
    v_return       common.st_result;
    v_result       common.st_result;
    v_line_number  common.st_value;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_RECVD_QTY');
    v_result := common.gc_success;
    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_return := common.gc_failure;
    --  RAISE common.ge_failure;
    END IF;

    IF pv_line_number IS NULL THEN
      v_return := common.gc_failure;
    -- RAISE common.ge_failure;
    END IF;

    logit.LOG ('Inserting row into LOAD_RECVD_QTY_DATA table.  Batch :Line no' || pv_batch_id || ' : ' || pv_line_number);

    INSERT INTO load_recvd_data
                (batch_id, line_no, period, company, profit_center, plant, vendor, material, received_qty, status)
         VALUES (pv_batch_id, pv_line_number, i_period, i_company, i_profit_center, i_plant, i_vendor, i_material, i_received_qty, common.gc_loaded);

    -- commit every 1000 lines
    IF MOD (pv_line_number, 1000) = 0 THEN
      COMMIT;
    END IF;

    -- Increment the line number package varaiable
    pv_line_number := pv_line_number + 1;
    logit.leave_method;
    o_result := v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.LOG (o_result_msg);
      logit.leave_method;
  END load_recvd;

  ---------------------------------------------------------------------------------
  PROCEDURE load_clsng_inv (o_result OUT common.st_result, o_result_msg OUT common.st_message_string) IS
    v_return                   common.st_result;
    v_result                   common.st_result;
    v_processing_msg           common.st_message_string;
    v_result_msg               common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_clsng        common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity   common.st_id;
    v_chrstc_type_company      common.st_id;
    v_chrstc_type_bus_sgmnt    common.st_id;
    v_chrstc_type_matl         common.st_id;
    v_chrstc_type_period       common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id     common.st_id;
    v_chrstc_dataentity_od_id  common.st_id;
    v_chrstc_company_id        common.st_id;
    v_chrstc_bus_sgmnt_id      common.st_id;
    v_chrstc_matl_id           common.st_id;
    v_chrstc_period_id         common.st_id;
    -- Characteristic codes
    v_chrstc_bus_sgmnt_code    common.st_code;
    v_chrstc_matl_code         common.st_code;
    v_dataentity_chrstc_code   common.st_code;
    -- Characteristic Array
    v_chrstc_ids               common.t_ids;
    -- Data id Array
    v_data_ids                 common.t_ids;
    -- Other
    v_data_counter             common.st_counter;
    v_value                    common.st_value;
    v_top_down                 common.st_status;
    v_revision                 common.st_count;
    v_line_counter             common.st_count;
    v_chrstc_attrb_fromperiod  common.st_description;
    v_chrstc_attrb_opening_de  common.st_description;
    v_chrstc_attrb_value       common.st_description;
    v_loaded_counter           common.st_counter;

    CURSOR csr_batch_details IS
      SELECT company, period, dataentity, bus_sgmnt
      FROM load_bpip_batch
      WHERE batch_id = pv_batch_id;

    rv_batch_details           csr_batch_details%ROWTYPE;

    CURSOR csr_clsng_distinct_chrstcs (i_bus_sgmnt IN common.st_code, i_material IN common.st_code) IS
      SELECT a.line_no
      FROM load_clsng_inv_data a
      WHERE a.bus_sgmnt = i_bus_sgmnt AND a.material = i_material AND a.batch_id = pv_batch_id;

    v_csr_clsng                common.st_counter;

    -- Local procedure to load data into LOAD_CLSNG_INV_DATA
    PROCEDURE load_clsng_inv_data (i_chrstc_ids IN common.t_ids) IS
      v_return  common.st_result;
    BEGIN
      v_return := data_values.get_data_ids (v_mdl_isct_id_clsng, data_values.gc_data_vlu_status_valid, i_chrstc_ids, v_data_ids, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Unable to get CLSN intersect data ids. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;

      -- Now process each CLSNG entry.
      logit.LOG ('Now processing each CLSNG line. ' || v_data_ids.COUNT || ' to process.');
      v_loaded_counter := 1;
      v_data_counter := 1;

      WHILE v_data_counter <= v_data_ids.COUNT
      LOOP
        logit.LOG ('get_data_vlu');
        v_return := data_values.get_data_vlu (v_data_ids (v_data_counter), v_value, v_top_down, v_revision, v_result_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg :=
               'Unable to perform extract as the data was invalidated or not error occured during fetch of data id : '
            || v_data_ids (v_data_counter)
            || ' '
            || common.nest_err_msg (v_result_msg);
          RAISE common.ge_error;
        END IF;

        -- Only process if value is not 0
        IF v_value != 0 THEN
          v_return := common.gc_success;
          v_return := data_values.get_chrstc_id (v_data_ids (v_data_counter), v_chrstc_type_matl, v_chrstc_matl_id, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := 'Characteristic lookups for Material failed or errored';
            RAISE common.ge_error;
          END IF;

          v_return := characteristics.get_chrstc_code (v_chrstc_matl_id, v_chrstc_matl_code, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := 'Characteristic Code lookups for Material failed or errored';
            RAISE common.ge_error;
          END IF;

          v_return := data_values.get_chrstc_id (v_data_ids (v_data_counter), v_chrstc_type_bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := 'Characteristic lookups for Business segment failed or errored';
            RAISE common.ge_error;
          END IF;

          v_return := characteristics.get_chrstc_code (v_chrstc_bus_sgmnt_id, v_chrstc_bus_sgmnt_code, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := 'Characteristic Code lookups for Business segment failed or errored';
            RAISE common.ge_error;
          END IF;

          logit.LOG ('Now attempt to insert into the load table, LOAD_CLSNG_INV_DATA.');

          OPEN csr_clsng_distinct_chrstcs (v_chrstc_bus_sgmnt_code, v_chrstc_matl_code);

          FETCH csr_clsng_distinct_chrstcs
          INTO v_csr_clsng;

          IF csr_clsng_distinct_chrstcs%NOTFOUND THEN
            logit.LOG ('Now insert into the load table, LOAD_CLSNG_INV_DATA as business segment and material dont already exist.');

            INSERT INTO load_clsng_inv_data
                        (batch_id, line_no, bus_sgmnt, material, status)
                 VALUES (pv_batch_id, pv_line_number, v_chrstc_bus_sgmnt_code, v_chrstc_matl_code, common.gc_loaded);

            pv_line_number := pv_line_number + 1;
            v_loaded_counter := v_loaded_counter + 1;
            COMMIT;
          END IF;

          CLOSE csr_clsng_distinct_chrstcs;
        END IF;

        logit.LOG ('Processed ' || v_data_counter || ' of ' || v_data_ids.COUNT || ' ...');
        v_data_counter := v_data_counter + 1;
      END LOOP;

      logit.LOG ('Loaded ' || v_loaded_counter || ' rows.');
    END load_clsng_inv_data;
  --
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_CLSNG_INV');
    logit.LOG ('Get the characteristic types.');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'One or more of the characteristic Type lookups for bpip failed or errored.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be reading bpip base information from.
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_clsng);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_clsng, v_mdl_isct_id_clsng, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect for CLSNG.';
      RAISE common.ge_error;
    END IF;

    logit.LOG ('Check package variable batch id is not null');

    IF pv_batch_id IS NULL THEN
      v_processing_msg := 'Batch id has not currently been allocated.';
      RAISE common.ge_error;
    END IF;

    IF pv_line_number IS NULL THEN
      v_processing_msg := 'Line number is currently null.';
      RAISE common.ge_error;
    END IF;

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND = TRUE THEN
      v_processing_msg := 'Unable to find Batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    -- Get characteristic ID for COMPANY
    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    -- Get characteristic ID for DATAENTITY
    v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity, rv_batch_details.dataentity, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to get chrstc id for : ' || v_chrstc_type_dataentity || ' ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- get the chrstc code for the dataentity
    v_result := characteristics.get_chrstc_code (v_chrstc_dataentity_id, v_dataentity_chrstc_code, v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('Data Entity characteristic code : ' || v_dataentity_chrstc_code);

    --
    IF v_dataentity_chrstc_code = finance_characteristics.gc_chrstc_dataentity_actuals THEN
      -- period is period from load_bpip_batch
      -- data entity is dataentity from load_bpip_batch ie ACTUALS
      logit.LOG ('data entity characteristic code : ' || v_dataentity_chrstc_code);
      -- Get characteristic ID for PERIOD
      v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored';
        RAISE common.ge_error;
      END IF;
    ELSE
      -- This piece of code is to look at every existing closing inv qty in plan.
      -- do at this point as we are dealing with original supplied data entity
         --logit.LOG ('Assign the batch header characteristics to an array.');
      v_chrstc_ids.DELETE;
      v_chrstc_ids (1) := v_chrstc_dataentity_id;
      v_chrstc_ids (2) := v_chrstc_company_id;
      --
      logit.LOG ('Loading for dataentity and a distinct material code ');
      load_clsng_inv_data (v_chrstc_ids);
      -- period is period from load_bpip_batch
      -- data entity is dataentity from load_bpip_batch
      --
      logit.LOG ('Get the chrstc attribute value for BPIP_OPENING_DATAENTITY of this chrstc id : ' || v_chrstc_dataentity_id);
      v_result :=
            characteristics.get_chrstc_attrb_value (v_chrstc_dataentity_id, bpip_model.gc_chrstc_dataentity_open_dten, v_chrstc_attrb_opening_de, v_result_msg);
      logit.LOG ('attribute value : ' || v_chrstc_attrb_opening_de);
      logit.LOG ('Now get the chrstc_id for the attribute value');

      IF v_result = common.gc_success THEN
        -- get the chrstc_id for the dataentity value
        v_result := characteristics.get_chrstc_id (v_chrstc_type_dataentity, v_chrstc_attrb_opening_de, v_chrstc_dataentity_od_id, v_result_msg);

        IF v_result != common.gc_success THEN
          v_processing_msg := common.nest_err_msg (v_result_msg);
          RAISE common.ge_failure;
        END IF;
      ELSE
        logit.LOG ('get the chrstc_id for the dataentity value ACTUALS as BPIP_OPENING_DATAENTITY is not defined');
        v_result :=
          characteristics.get_chrstc_id (v_chrstc_type_dataentity,
                                         finance_characteristics.gc_chrstc_dataentity_actuals,
                                         v_chrstc_dataentity_od_id,
                                         v_result_msg);

        IF v_result != common.gc_success THEN
          v_processing_msg := common.nest_err_msg (v_result_msg);
          RAISE common.ge_failure;
        END IF;
      END IF;

      logit.LOG ('Get the chrstc attribute value for FROMPERIOD of the supplied dataentity');
      v_result :=
        characteristics.get_chrstc_attrb_value (v_chrstc_dataentity_id,
                                                finance_characteristics.gc_chrstc_dataentity_fromprd,
                                                v_chrstc_attrb_fromperiod,
                                                v_result_msg);

      IF v_result != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      logit.LOG ('FROMPERIOD : ' || v_chrstc_attrb_fromperiod);
      v_return := characteristics.get_chrstc_id (v_chrstc_type_period, v_chrstc_attrb_fromperiod, v_chrstc_period_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored';
        RAISE common.ge_error;
      END IF;

      logit.LOG (' now set the data entity chrstc id to the opening data entity chrstc id : ' || v_chrstc_dataentity_od_id);
      v_chrstc_dataentity_id := v_chrstc_dataentity_od_id;
    END IF;

    -- now get the previous period characteristic id
    v_result := characteristics.get_chrstc_attrb_value (v_chrstc_period_id, chrstc_mars_date.gc_chrstc_period_prevperiod, v_chrstc_attrb_value, v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('PREVPERIOD : ' || v_chrstc_attrb_value);
    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, v_chrstc_attrb_value, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period failed or errored';
      RAISE common.ge_error;
    END IF;

    --
    logit.LOG (   'Assign the batch header characteristics to an array. v _chrstc_dataentity_id: '
               || v_chrstc_dataentity_id
               || ' v_chrstc_period_id : '
               || v_chrstc_period_id
               || ' v_chrstc_company_id : '
               || v_chrstc_company_id);
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_period_id;
    v_chrstc_ids (3) := v_chrstc_company_id;
    --
    --logit.LOG ('Loading for dataentity and for period -1 of this dataentity ');
    load_clsng_inv_data (v_chrstc_ids);
    --

    --
    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
  END load_clsng_inv;

  ---------------------------------------------------------------------------------
  FUNCTION validate_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
    v_batch_type      common.st_code;
    e_lock_error      EXCEPTION;   -- failed to get exclusive lock
    e_event_error     EXCEPTION;   -- event processing error
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_BATCH');

    -- Get lock
    IF lockit.request_lock (pc_lock_name || '_' || i_batch_id, lockit.gc_lock_mode_exclusive, FALSE, v_result_msg) != common.gc_success THEN
      RAISE e_lock_error;
    END IF;

    BEGIN
      logit.LOG ('Get the Batch type and use it to evaluate which Validate batch function to call ');
      v_batch_type := get_batch_type (i_batch_id);

      UPDATE load_bpip_batch a
         SET a.status = common.gc_processing,
             a.validate_start_time = SYSDATE
       WHERE a.batch_id = i_batch_id;

      COMMIT;

      CASE v_batch_type
        WHEN gc_batch_type_inventory THEN
          v_return := validate_inv_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_ppv THEN
          v_return := validate_ppv_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_mrp THEN
          v_return := validate_mrp_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_safety_stock THEN
          v_return := validate_safty_stk_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_invoices THEN
          v_return := validate_invc_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_movement THEN
          v_return := validate_mvmt_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_contracts THEN
          v_return := validate_cntct_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_recvd THEN
          v_return := validate_recvd_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_standards THEN
          v_return := validate_std_cost_batch (i_batch_id, v_result_msg);
        WHEN gc_batch_type_clsng_inv THEN
          v_return := validate_clsng_inv_batch (i_batch_id, v_result_msg);
        ELSE
          v_processing_msg := 'No batch type code found for supplied batch id :' || i_batch_id;
          RAISE common.ge_failure;
      END CASE;

      IF v_return <> common.gc_success THEN
        UPDATE load_bpip_batch a
           SET a.status = common.gc_errored,
               a.validate_end_time = SYSDATE
         WHERE a.batch_id = i_batch_id;

        COMMIT;
        v_processing_msg := 'Unable to successfully validate entire batch (' || v_batch_type || '). ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;

      -- Update the LOAD_BPIP_BATCH status to validated when the processing is complete
      logit.LOG ('Marking batch as validated.');

      UPDATE load_bpip_batch a
         SET a.status = common.gc_validated,
             a.validate_end_time = SYSDATE
       WHERE a.batch_id = i_batch_id;

      COMMIT;

      IF lockit.release_lock (pc_lock_name || '_' || i_batch_id, v_result_msg) != common.gc_success THEN
        RAISE e_lock_error;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF lockit.release_lock (pc_lock_name || '_' || i_batch_id, v_result_msg) != common.gc_success THEN
          RAISE e_lock_error;
        END IF;

        RAISE;
    END;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN e_lock_error THEN
      o_result_msg := common.create_failure_msg ('Lock Error' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_batch;

  -- This function is used to perform the saving of a value into the model using a standard approach of
  -- looking for the data id, seting the value if it is deleted, or creating if it doesn't exist.
  FUNCTION save_value (
    i_mdl_isct_set_id  IN      common.st_id,
    i_chrstc_ids       IN      common.t_ids,
    i_value            IN      common.st_value,
    i_add              IN      BOOLEAN,
    o_result_msg       OUT     common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_return_msg      common.st_message_string;
    v_processing_msg  common.st_message_string;
    v_status          common.st_status;
    v_data_id         common.st_id;
    v_failure_code    common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'SAVE_VALUE');
    logit.LOG ('Now check to see if the data value already exists.');
    v_return := data_values.get_data_id (i_mdl_isct_set_id, i_chrstc_ids, v_data_id, v_return_msg);

    IF v_return = common.gc_success THEN
      logit.LOG ('Data value already existed : ' || v_data_id);
      v_return := data_values.get_data_vlu_status (v_data_id, v_status, v_return_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to get data id status. ' || common.nest_err_msg (v_return_msg);
        RAISE common.ge_error;
      END IF;

      IF v_status = data_values.gc_data_vlu_status_deleted THEN
        logit.LOG ('Now set the data value.');
        v_return := data_values.set_data_vlu_bot_up (v_data_id, i_value, v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Unable to set the bottom up value for data id. ' || common.nest_err_msg (v_return_msg);
          RAISE common.ge_error;
        END IF;

        logit.LOG ('Now set the status to invalid for this data id.');
        v_return := data_values.set_data_vlu_status (v_data_id, data_values.gc_data_vlu_status_invalid, v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Unable to set the data id status to invalid. ' || common.nest_err_msg (v_return_msg);
          RAISE common.ge_error;
        END IF;
      ELSE
        -- add to the current data value
        IF i_add = TRUE THEN
          logit.LOG ('Add the new value to the existing data id.');
          v_return := data_values.add_to_data_vlu (v_data_id, i_value, v_return_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := 'Unable to add value to data id. ' || common.nest_err_msg (v_return_msg);
            RAISE common.ge_error;
          END IF;
        ELSE
          logit.LOG ('Now set the data value.');
          v_return := data_values.set_data_vlu_bot_up (v_data_id, i_value, v_return_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := 'Unable to set the bottom up value for data id. ' || common.nest_err_msg (v_return_msg);
            RAISE common.ge_error;
          END IF;
        END IF;
      END IF;

      -- Then trigger a data change event as required.
      logit.LOG ('Now create a data change event for this data id.');
      v_return := data_values.data_change_event (v_data_id, v_return_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to create a data change event for the data id. ' || common.nest_err_msg (v_return_msg);
        RAISE common.ge_error;
      END IF;
    ELSIF v_return = common.gc_failure THEN
      logit.LOG ('Data value did not exist.  Creating.');
      v_return := data_values.set_data_vlu_rtn_id (i_mdl_isct_set_id, i_chrstc_ids, i_value, NULL, v_data_id, v_failure_code, v_return_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to create data id. ' || common.nest_err_msg (v_return_msg);
        RAISE common.ge_error;
      END IF;
    ELSE
      v_processing_msg := 'Unable to find data id. ' || common.nest_err_msg (v_return_msg);
      RAISE common.ge_error;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END save_value;

  ---------------------------------------------------------------------------------
  FUNCTION process_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
    v_batch_type      common.st_code;
    e_lock_error      EXCEPTION;   -- failed to get exclusive lock
    e_event_error     EXCEPTION;   -- event processing error
    v_errored_count   common.st_count;
    v_warning_count   common.st_count;
    v_user_id         common.st_id;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_BATCH');
    v_result := common.gc_success;
    
    -- Get lock
    IF lockit.request_lock (pc_lock_name || '_' || i_batch_id, lockit.gc_lock_mode_exclusive, FALSE, v_result_msg) != common.gc_success THEN
      RAISE e_lock_error;
    END IF;

    BEGIN
      -- Backup the previous user id.
      v_user_id := security.current_user_id;
      logit.LOG ('Set the user id to the user that loaded the batch.');
      v_return := security.set_user_id (get_batch_loaded_by_id (i_batch_id), v_result_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to set the security user id to be the same as the id that loaded the batch. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;

      -- Now change the status of the batch to processing.
      logit.LOG ('Now change the status of the batch to processing.');

      UPDATE load_bpip_batch a
         SET a.status = common.gc_processing,
             a.process_start_time = SYSDATE
       WHERE a.batch_id = i_batch_id;

      COMMIT;
      logit.LOG ('Now get the batch type.');
      v_batch_type := get_batch_type (i_batch_id);
      v_errored_count := 0;
      logit.LOG ('Call the function to process the batch based on the batch type code.');

      CASE v_batch_type
        -- INVENTORY
      WHEN gc_batch_type_inventory THEN
          v_return := process_inv_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_inventory, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of Errored rows and Warning rows to count variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_inv_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_inv_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        --PPV
      WHEN gc_batch_type_ppv THEN
          v_return := process_ppv_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_ppv, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_ppv_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_ppv_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- MRP
      WHEN gc_batch_type_mrp THEN
          v_return := process_mrp_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_mrp, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_mrp_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_mrp_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- SAFETY_STOCK
      WHEN gc_batch_type_safety_stock THEN
          v_return := process_safty_stk_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_safety_stk, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_safty_stk_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_safty_stk_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- INVOICES
      WHEN gc_batch_type_invoices THEN
          logit.LOG ('Call process_invc_batch.');
          v_return := process_invc_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_invoices, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_invc_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_invc_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- MOVEMENT
      WHEN gc_batch_type_movement THEN
          v_return := process_mvmt_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_movement, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_mvmt_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_mvmt_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- CONTRACTS
      WHEN gc_batch_type_contracts THEN
          v_return := process_cntct_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_contracts, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_cntct_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_cntct_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- RECEIVED
      WHEN gc_batch_type_recvd THEN
          v_return := process_recvd_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_recvd, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_recvd_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_recvd_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- STANDARDS
      WHEN gc_batch_type_standards THEN
          v_return := process_std_cost_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_standards, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_std_cost_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_std_cost_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        -- CLSNG_INV
      WHEN gc_batch_type_clsng_inv THEN
          v_return := process_clsng_inv_batch (i_batch_id, v_result_msg);

          IF v_return = common.gc_success THEN
            -- Create Batch Type event
            IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_batch_type_clsng_inv, i_batch_id, 'Batch Processed.', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
              RAISE e_event_error;
            END IF;
          END IF;

          -- Assign the counts of errored rows and warning rows to variables.
          SELECT COUNT (*)
          INTO   v_errored_count
          FROM load_clsng_inv_data
          WHERE batch_id = i_batch_id AND status = common.gc_errored;

          SELECT COUNT (*)
          INTO   v_warning_count
          FROM load_clsng_inv_data
          WHERE batch_id = i_batch_id AND status = common.gc_warning;
        ELSE
          v_processing_msg := 'No batch type code found for supplied batch id :' || i_batch_id;
          RAISE common.ge_failure;
      END CASE;

      IF v_return = common.gc_error OR v_errored_count > 0 THEN
        UPDATE load_bpip_batch a
           SET a.status = common.gc_errored,
               a.process_end_time = SYSDATE
         WHERE a.batch_id = i_batch_id;

        COMMIT;
        v_processing_msg :=
             'Batch:'
          || i_batch_id
          || ' ('
          || v_batch_type
          || '). Did not process correctly. It had '
          || v_errored_count
          || ' errored records and '
          || v_warning_count
          || ' warnings. '
          || common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;

      IF v_return = common.gc_failure OR v_warning_count > 0 THEN
        UPDATE load_bpip_batch a
           SET a.status = common.gc_failed,
               a.process_end_time = SYSDATE
         WHERE a.batch_id = i_batch_id;

        COMMIT;
        v_processing_msg :=
             'Batch:'
          || i_batch_id
          || ' ('
          || v_batch_type
          || '). Did not process correctly. It had '
          || v_warning_count
          || ' warnings. '
          || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      -- Update the LOAD_BPIP_BATCH status to processed when the processing is complete
      UPDATE load_bpip_batch a
         SET a.status = common.gc_processed,
             a.process_end_time = SYSDATE
       WHERE a.batch_id = i_batch_id;

      COMMIT;
      -- Now set the user id back.
      v_return := security.set_user_id (v_user_id, v_result_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to change user id back to previous user id. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;

      IF lockit.release_lock (pc_lock_name || '_' || i_batch_id, v_result_msg) != common.gc_success THEN
        RAISE e_lock_error;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- If exception has occured, still always try to release the lock and trigger caclculation.
        v_result := lockit.release_lock (pc_lock_name || '_' || i_batch_id, v_result_msg);
        data_calc.trigger_calculation (v_result, v_result_msg);
        RAISE;
    END;

    logit.LOG ('All rows processed. Perform Calculation');
    data_calc.trigger_calculation (v_result, v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN e_lock_error THEN
      o_result_msg := common.create_failure_msg ('Lock Error' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_INV_BATCH');
    v_result := common.gc_success;

    UPDATE load_inv_data b
       SET error_msg = NULL,
           status = common.gc_validated
     WHERE batch_id = i_batch_id;

    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_inv_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                  common.st_result;
    v_result                  common.st_result;
    v_processing_msg          common.st_message_string;
    v_result_msg              common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_inv_bal     common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity  common.st_id;
    v_chrstc_type_company     common.st_id;
    v_chrstc_type_bus_sgmnt   common.st_id;
    v_chrstc_type_matl        common.st_id;
    v_chrstc_type_plant       common.st_id;
    v_chrstc_type_period      common.st_id;
    v_chrstc_type_stock_type  common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id    common.st_id;
    v_chrstc_company_id       common.st_id;
    v_chrstc_bus_sgmnt_id     common.st_id;
    v_chrstc_matl_id          common.st_id;
    v_chrstc_plant_id         common.st_id;
    v_chrstc_period_id        common.st_id;
    v_chrstc_stock_type_id    common.st_id;
    -- Characteristic Array
    v_chrstc_ids              common.t_ids;
    -- Other Variables.
    v_counter                 common.st_counter;
    v_process_state           common.st_code;
    v_data_id                 common.st_id;
    v_failure_code            common.st_code;
    v_status                  common.st_code;

    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details          csr_batch_details%ROWTYPE;

    -- select data from the load_inv_data table
    CURSOR csr_load_inv_data IS
      SELECT a.batch_id, a.line_no, bus_sgmnt, a.material full_matl, a.plant, stock_type, a.inventory_qty
      FROM load_inv_data a
      WHERE a.batch_id = i_batch_id AND a.status = common.gc_validated;

    TYPE t_inv IS TABLE OF csr_load_inv_data%ROWTYPE
      INDEX BY common.st_counter;

    v_inv                     t_inv;
    v_dataentity              common.st_code;
    v_company                 common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_INV_BATCH');
    logit.LOG ('get required chrstc types');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_stk_typ, v_chrstc_type_stock_type, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_invtry_plnt || ' : ' || v_mdl_isct_id_inv_bal);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_invtry_plnt, v_mdl_isct_id_inv_bal, v_result_msg);
    --
       -- Get characteristic ID for data entity of ACTUALS which is a constant characteristic value for this data entity
    v_return :=
            characteristics.get_chrstc_id (v_chrstc_type_dataentity, finance_characteristics.gc_chrstc_dataentity_actuals, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('Load the batch details and find the characteristics required.');

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period failed or errored';
      RAISE common.ge_error;
    END IF;
    
    v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;    

    -- Set the status to deleted for all data values with this mars week and data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_period_id;
    v_chrstc_ids (3) := v_chrstc_company_id;
    v_chrstc_ids (4) := v_chrstc_bus_sgmnt_id;
    logit.LOG ('Setting data value status to Deleted for Lowest level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_inv_bal, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- LOOP through the staging table and load the data into the bpip data model
    OPEN csr_load_inv_data;

    FETCH csr_load_inv_data
    BULK COLLECT INTO v_inv;

    CLOSE csr_load_inv_data;

    logit.LOG ('Now commence processing any rows that are ready for processing.');
    v_counter := 1;

    WHILE v_counter <= v_inv.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of success.
      v_process_state := common.gc_processed;
      v_processing_msg := '';
      logit.LOG (' If any chrstcs are null then mark row as IGNORED');

      IF v_inv (v_counter).full_matl IS NULL OR v_inv (v_counter).bus_sgmnt IS NULL OR v_inv (v_counter).plant IS NULL OR v_inv (v_counter).stock_type IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Characteristic was null. ';
      --1
      ELSIF v_inv (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSIF v_inv (v_counter).inventory_qty = 0 THEN
        logit.LOG ('Zero Inventory Quantity.  Row Ignored. ');
        v_process_state := common.gc_ignored;
        v_processing_msg := v_processing_msg || 'Zero inventory Quantity. ';
      ELSE
        --  IF v_process_state = common.gc_success THEN   --2
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_inv (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_inv (v_counter).full_matl, v_chrstc_matl_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_inv (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_stock_type, v_inv (v_counter).stock_type, v_chrstc_stock_type_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Stock Type failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        -- Assign chrstc ids to the array
        v_chrstc_ids.DELETE;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_dataentity_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_period_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_stock_type_id;

        -- Processing for INVTRY_BAL_PLANT mdl isct
        IF v_process_state = common.gc_processed THEN   -- 3
          logit.LOG ('Calling save value for INVTRY BAL PLANT intersect.');
          v_return := save_value (v_mdl_isct_id_inv_bal, v_chrstc_ids, v_inv (v_counter).inventory_qty, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := common.nest_err_msg (v_result_msg);
            v_process_state := common.gc_errored;
          END IF;
        END IF;   -- 3
      END IF;   --1

         --  logit.LOG ('Set the status for the load_inv_data row after processing for batch :'
      --  ||i_batch_id||' line : '||v_inv (v_counter).line_no||' process state : '||v_process_state
      --  ||'v_processing_msg : '||v_processing_msg);
      UPDATE load_inv_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_inv (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_inv_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_mrp_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_BATCH');
    v_result := common.gc_success;

    UPDATE load_mrp_data
       SET error_msg = NULL,
           status = common.gc_validated
     WHERE batch_id = i_batch_id;

    logit.LOG ('In validate_mrp_batch, calling update_bus_sgmnt, validate_matl');
    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_mrp_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_mrp_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                   common.st_result;
    v_result                   common.st_result;
    v_processing_msg           common.st_message_string;
    v_result_msg               common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_cons_qty     common.st_id;
    v_mdl_isct_id_req_qty      common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity   common.st_id;
    v_chrstc_type_company      common.st_id;
    v_chrstc_type_bus_sgmnt    common.st_id;
    v_chrstc_type_matl         common.st_id;
    v_chrstc_type_plant        common.st_id;
    v_chrstc_type_period       common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id     common.st_id;
    v_chrstc_company_id        common.st_id;
    v_chrstc_bus_sgmnt_id      common.st_id;
    v_chrstc_matl_id           common.st_id;
    v_chrstc_plant_id          common.st_id;
    v_chrstc_period_id         common.st_id;
    v_chrstc_attrb_fromperiod  common.st_value;
    v_chrstc_attrb_toperiod    common.st_value;
    -- Characteristic Array
    v_chrstc_ids               common.t_ids;
      -- Other Variables.
    --
    v_chrstc_attrb_value       common.st_value;
    v_counter                  common.st_counter;
    v_process_state            common.st_code;
    v_data_id                  common.st_id;
    v_failure_code             common.st_code;
    v_status                   common.st_code;
    v_prevperiod_chrstc_id     common.st_id;

    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.dataentity, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details           csr_batch_details%ROWTYPE;

    -- select data from the load_mrp_data table
    CURSOR csr_load_mrp_data IS
      SELECT a.batch_id, a.line_no, a.company, bus_sgmnt, a.material, a.plant,
        SUBSTR (a.period, INSTR (a.period, '/') + 5, 4) || SUBSTR (a.period, INSTR (a.period, '/') + 2, 2) mars_period, a.requirements_qty, a.receipt_qty
      FROM load_mrp_data a
      WHERE a.status IN (common.gc_validated) AND a.batch_id = i_batch_id;

    TYPE t_mrp IS TABLE OF csr_load_mrp_data%ROWTYPE
      INDEX BY common.st_counter;

    CURSOR csr_get_prcrmnt (i_matl IN VARCHAR2, i_plant IN VARCHAR2) IS
      SELECT a.prcrmnt_type, a.spcl_prcrmnt_type
      FROM matl_by_plant a
      WHERE a.matl_code = reference_functions.full_matl_code (i_matl) AND a.plant = i_plant;

    v_prcrmnt_type             common.st_code;
    v_spcl_prcrmnt_type        common.st_code;

    CURSOR csr_mrp_prcrmnt_xref (i_prcrmnt_type IN VARCHAR2, i_spcl_prcrmnt_type IN VARCHAR2, i_plant IN VARCHAR2) IS
      SELECT b.consumption, b.requisition
      FROM mrp_prcrmnt_xref b
      WHERE b.prcrmnt_type = i_prcrmnt_type AND
       b.spcl_prcrmnt_type = i_spcl_prcrmnt_type AND
       b.plant = i_plant AND
       (b.consumption IS NOT NULL OR b.requisition IS NOT NULL);

    rsr_mrp_prcrmnt_xref       csr_mrp_prcrmnt_xref%ROWTYPE;
    v_mrp                      t_mrp;
    v_dataentity               common.st_code;
    v_company                  common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_MRP_BATCH');
    logit.LOG ('get required chrstc types');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_cons_reqmnt_plnt);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_cons_reqmnt_plnt, v_mdl_isct_id_cons_qty, v_result_msg);
    --
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_reqst_plnt);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_reqst_plnt, v_mdl_isct_id_req_qty, v_result_msg);
    logit.LOG ('pre process the rows.  Call set_requirement procedure');

    --set_requirement;

    -- Get the chrstc_id for the COMPANY chrstc code.
     -- This is performed outside the v_mvmt loop below as the value will be the same for the
     -- set of data being processed
    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    -- get the dataentity chrstc code
    -- There is only 1 dataentity per batch so source the value from the load batch table
    v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity, rv_batch_details.dataentity, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to get chrstc id for : ' || v_dataentity || ' ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- get the from period chrstc attrb for the dataentity

    -- Get the chrstc attribute value for FROMPERIOD of this chrstc id
    v_result :=
      characteristics.get_chrstc_attrb_value (v_chrstc_dataentity_id,
                                              finance_characteristics.gc_chrstc_dataentity_fromprd,
                                              v_chrstc_attrb_fromperiod,
                                              v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Get the chrstc attribute value for TOPERIOD of this chrstc id
    v_result :=
      characteristics.get_chrstc_attrb_value (v_chrstc_dataentity_id, finance_characteristics.gc_chrstc_dataentity_toprd, v_chrstc_attrb_toperiod, v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    --  Get characteristic ID for period
    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period failed or errored';
      RAISE common.ge_error;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;    
    
    -- Set the status to deleted for all data values with this data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_company_id;
    v_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
    logit.LOG ('Setting data value status to Deleted for Lowest level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_cons_qty, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_req_qty, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed into memory.');

    OPEN csr_load_mrp_data;

    FETCH csr_load_mrp_data
    BULK COLLECT INTO v_mrp;

    CLOSE csr_load_mrp_data;

    -- LOOP through the staging table and load the data into the bpip data model
    logit.LOG ('Now commence processing any rows that are ready for processing.');
    v_counter := 1;

    WHILE v_counter <= v_mrp.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of success.
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_mrp (v_counter).company IS NULL OR
         v_mrp (v_counter).material IS NULL OR
         v_mrp (v_counter).bus_sgmnt IS NULL OR
         v_mrp (v_counter).plant IS NULL OR
         v_mrp (v_counter).mars_period IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Characteristic was null. ';
      ELSIF v_mrp (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSIF v_mrp (v_counter).mars_period < v_chrstc_attrb_fromperiod THEN
        logit.LOG ('Period :' || v_mrp (v_counter).mars_period || 'is less than FROM PERIOD of data entity : ' || v_chrstc_attrb_fromperiod);
        v_process_state := common.gc_ignored;
        v_processing_msg := v_processing_msg || 'Period is less than FROM PERIOD of data entity :';
      ELSIF v_mrp (v_counter).mars_period > v_chrstc_attrb_toperiod THEN
        logit.LOG ('Period :' || v_mrp (v_counter).mars_period || 'is greater than TO PERIOD of data entity : ' || v_chrstc_attrb_toperiod);
        v_process_state := common.gc_ignored;
        v_processing_msg := v_processing_msg || 'Period is greater than TO PERIOD of data entity :';
      ELSE
        --
        -- check that prcrmnt_type and spcl_prcrmnt_type exist on matl_by_plant for this material and plant
        OPEN csr_get_prcrmnt (v_mrp (v_counter).material, v_mrp (v_counter).plant);

        FETCH csr_get_prcrmnt
        INTO v_prcrmnt_type, v_spcl_prcrmnt_type;

        IF csr_get_prcrmnt%NOTFOUND THEN
          v_process_state := common.gc_ignored;
          v_processing_msg :=
               v_processing_msg || 'No data found in matl_by_plant for mrp material : ' || v_mrp (v_counter).material || ' plant : ' || v_mrp (v_counter).plant;
          logit.LOG ('No data found in matl_by_plant for mrp material : ' || v_mrp (v_counter).material || ' plant : ' || v_mrp (v_counter).plant);
        END IF;

        CLOSE csr_get_prcrmnt;

        -- IF v_prcrmnt_type IS NULL mark row as ignored and process next row
        IF v_process_state = common.gc_processed THEN
          IF v_prcrmnt_type IS NULL THEN
            v_process_state := common.gc_ignored;
            v_processing_msg := v_processing_msg || 'Material Plant Procurement type was NULL. ';
          END IF;
        END IF;

        -- IF v_spcl_prcrmnt_type IS NULL mark row as ignored and process next row
        IF v_process_state = common.gc_processed THEN
          IF v_spcl_prcrmnt_type IS NULL THEN
            v_process_state := common.gc_ignored;
            v_processing_msg := v_processing_msg || 'Material by Plant Special Procurement Key was Null.';
          END IF;
        END IF;

        -- check the consumption / requisition value
        IF v_process_state = common.gc_processed THEN
          OPEN csr_mrp_prcrmnt_xref (v_prcrmnt_type, v_spcl_prcrmnt_type, v_mrp (v_counter).plant);

          FETCH csr_mrp_prcrmnt_xref
          INTO rsr_mrp_prcrmnt_xref;

          IF csr_mrp_prcrmnt_xref%NOTFOUND THEN
            v_process_state := common.gc_errored;
            v_processing_msg :=
                 v_processing_msg
              || 'Could not find MRP Procurement Type XREF, Looked For: '
              || v_prcrmnt_type
              || '-'
              || v_spcl_prcrmnt_type
              || '-'
              || v_mrp (v_counter).plant;
          END IF;

          CLOSE csr_mrp_prcrmnt_xref;
        END IF;
      END IF;

      -- only enter main body of processing if the process state is set to success
      IF v_process_state = common.gc_processed THEN   -- 1
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_mrp (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_mrp (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_mrp (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_period, v_mrp (v_counter).mars_period, v_chrstc_period_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Period failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        -- Assign chrstc ids to the array
        v_chrstc_ids.DELETE;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_dataentity_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_period_id;

        -- Check if the consumption could be loaded.
        IF v_process_state = common.gc_processed AND rsr_mrp_prcrmnt_xref.consumption = common.gc_yes AND v_mrp (v_counter).requirements_qty IS NOT NULL THEN
          logit.LOG ('Calling save value for CONS_REQ_QTY_PLANT intersect.');
          v_return := save_value (v_mdl_isct_id_cons_qty, v_chrstc_ids, v_mrp (v_counter).requirements_qty, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;
              -- Removed Code here, that used to ensure that the previous 2 periods after the period just loaded have a value of at least zero
        -- no longer required as superceded by the closing inv batch and also it was corrupting data.
        END IF;

        -- Now check for requisition = Y
        IF v_process_state = common.gc_processed AND rsr_mrp_prcrmnt_xref.requisition = common.gc_yes AND v_mrp (v_counter).receipt_qty IS NOT NULL THEN
          logit.LOG ('Calling save value for REQ_QTY_PLANT intersect.');
          v_return := save_value (v_mdl_isct_id_req_qty, v_chrstc_ids, v_mrp (v_counter).receipt_qty, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;
        END IF;   -- check for requisition

        -- If both requisition AND consumption are N then set row to ignored
        IF rsr_mrp_prcrmnt_xref.requisition = common.gc_no AND rsr_mrp_prcrmnt_xref.consumption = common.gc_no AND v_process_state = common.gc_processed THEN
          v_processing_msg := 'Values neither represented a consumption requirement or a planned requisition.';
          v_process_state := common.gc_ignored;
        END IF;
      END IF;   --1

      logit.LOG (' Set the status for the load_mrp_data row after processing.');

      UPDATE load_mrp_data a
         SET a.status = v_process_state,
             a.error_msg = a.error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_mrp (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_mrp_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_ppv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_PPV_BATCH');

    UPDATE load_ppv_data
       SET error_msg = NULL,
           status = common.gc_validated
     WHERE batch_id = i_batch_id;

    logit.LOG ('In VALIDATE_PPV_BATCH, calling update_bus_sgmnt, validate_matl');
    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    -- Update the  status to validated when the processing is complete
    logit.LOG ('In validate_ppv_batch, i_batch_id : ' || i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_ppv_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_ppv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                  common.st_result;
    v_result                  common.st_result;
    v_processing_msg          common.st_message_string;
    v_result_msg              common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_ppv_act     common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity  common.st_id;
    v_chrstc_type_company     common.st_id;
    v_chrstc_type_bus_sgmnt   common.st_id;
    v_chrstc_type_purch_grp   common.st_id;
    v_chrstc_type_matl        common.st_id;
    v_chrstc_type_plant       common.st_id;
    v_chrstc_type_period      common.st_id;
    v_chrstc_type_vendor      common.st_id;
    v_chrstc_type_activity    common.st_id;
    v_chrstc_type_clssfctn    common.st_id;
    v_chrstc_type_ppv_type    common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id    common.st_id;
    v_chrstc_period_id        common.st_id;
    v_chrstc_company_id       common.st_id;
    v_chrstc_bus_sgmnt_id     common.st_id;
    v_chrstc_purch_grp_id     common.st_id;
    v_chrstc_matl_id          common.st_id;
    v_chrstc_plant_id         common.st_id;
    v_chrstc_vendor_id        common.st_id;
    v_chrstc_activity_id      common.st_id;
    v_chrstc_clssfctn_id      common.st_id;
    v_chrstc_ppv_type_id      common.st_id;
    -- Characteristic Array
    v_chrstc_ids              common.t_ids;
    -- Other Variables.
    v_counter                 common.st_counter;
    v_process_state           common.st_code;

    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details          csr_batch_details%ROWTYPE;

    -- select data from the load_ppv_data table
    CURSOR csr_load_ppv_data IS
      SELECT a.line_no, bus_sgmnt, a.material, a.plant, a.vendor, a.internal_order, a.ppv_type, a.ppv_po, a.ppv_invoice, a.ppv_finance, a.ppv_freight,
        a.ppv_other
      FROM load_ppv_data a
      WHERE a.batch_id = i_batch_id AND a.status IN (common.gc_validated, common.gc_warning);

    TYPE t_ppv IS TABLE OF csr_load_ppv_data%ROWTYPE
      INDEX BY common.st_counter;

    v_ppv                     t_ppv;

    -- Local Procedure to create data values
    PROCEDURE process_ppv (i_clssfctn IN common.st_code, i_value IN common.st_name) IS
    BEGIN
      -- get chrstc id for the ppv classification
      v_return := characteristics.get_chrstc_id (v_chrstc_type_clssfctn, i_clssfctn, v_chrstc_clssfctn_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := v_processing_msg || 'Characteristic lookups for classification failed or errored. ';
        v_process_state := common.gc_errored;
      END IF;

      -- Assign chrstc ids to the array
      v_chrstc_ids.DELETE;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_dataentity_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_vendor_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_period_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_activity_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_clssfctn_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_ppv_type_id;
      v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_purch_grp_id;
      -- MAIN PROCESSING
      logit.LOG ('Now create a data value for classification : ' || i_clssfctn || ', value : ' || i_value);
      v_return := save_value (v_mdl_isct_id_ppv_act, v_chrstc_ids, i_value, TRUE, v_result_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
        v_process_state := common.gc_errored;
      END IF;
    END process_ppv;
  --
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_PPV_BATCH');
    logit.LOG ('Get the characteristic types.');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_purch_group, v_chrstc_type_purch_grp, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_vndr, v_chrstc_type_vendor, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_activity, v_chrstc_type_activity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_ppv_clssfctn, v_chrstc_type_clssfctn, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_ppv_type, v_chrstc_type_ppv_type, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'One or more of the characteristic Type lookups for bpip failed or errored.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into. - PPV_ACTUALS
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_ppv_actual);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_ppv_actual, v_mdl_isct_id_ppv_act, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect for PPV.';
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the 'ACTUALS' DATAENTITY.
    -- This is performed outside the v_ppv loop below as the value is a constant.
    logit.LOG ('Now lookup the actuals data entity.');
    v_return :=
            characteristics.get_chrstc_id (v_chrstc_type_dataentity, finance_characteristics.gc_chrstc_dataentity_actuals, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Data Entity failed or errored';
      RAISE common.ge_error;
    END IF;

    logit.LOG (' Get the chrstc_id for PURCHASING GROUP.  Set value to # - N/A');
    v_return := characteristics.get_chrstc_id (v_chrstc_type_purch_grp, bpip_characteristics.gc_chrstc_na, v_chrstc_purch_grp_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Data Entity failed or errored';
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the COMPANY and  PERIOD chrstc code.
    -- This is performed outside the v_ppv loop below as the value will be the same for the
    -- set of data being processed
    logit.LOG ('Load the batch details and find the characteristics required.');

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period failed or errored';
      RAISE common.ge_error;
    END IF;
    
    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for business segment failed or errored';
      RAISE common.ge_error;
    END IF; 

    -- Now mark any existing records in the system as deleted.
    logit.LOG ('Now mark any existing records in the system as deleted.');
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_period_id;
    v_chrstc_ids (3) := v_chrstc_company_id;
    v_chrstc_ids (4) := v_chrstc_bus_sgmnt_id;
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_ppv_act, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed into memory.');

    OPEN csr_load_ppv_data;

    FETCH csr_load_ppv_data
    BULK COLLECT INTO v_ppv;

    CLOSE csr_load_ppv_data;

    -- LOOP through the staging table and load the data into the bpip data model
    logit.LOG ('Now process the found records into the model intersect.');
    v_counter := 1;

    WHILE v_counter <= v_ppv.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of success.
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_ppv (v_counter).bus_sgmnt IS NULL OR
         v_ppv (v_counter).material IS NULL OR
         v_ppv (v_counter).plant IS NULL OR
         v_ppv (v_counter).vendor IS NULL OR
         v_ppv (v_counter).internal_order IS NULL OR
         v_ppv (v_counter).ppv_type IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Characteristic was null. ';
      ELSIF v_ppv (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSE
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_ppv (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_ppv (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return = common.gc_failure THEN
          v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, lads_characteristics.gc_chrstc_na, v_chrstc_matl_id, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || 'Characteristic lookup for Material # failed or errored. ' || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          v_processing_msg := v_processing_msg || 'Could not find Material defaulted to #. ';
          v_process_state := common.gc_warning;
        ELSIF v_return <> common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookup for Material errored. ' || common.nest_err_msg (v_result_msg) || ' ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_ppv (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_vendor, v_ppv (v_counter).vendor, v_chrstc_vendor_id, v_result_msg);

        IF v_return = common.gc_failure THEN
          v_return := characteristics.get_chrstc_id (v_chrstc_type_vendor, lads_characteristics.gc_chrstc_na, v_chrstc_vendor_id, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || 'Characteristic lookup for Vendor # failed or errored. ' || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          v_processing_msg := v_processing_msg || 'Could not find Vendor defaulted to #. ';
          v_process_state := common.gc_warning;
        ELSIF v_return <> common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookup for Vendor errored. ' || common.nest_err_msg (v_result_msg) || ' ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_activity, v_ppv (v_counter).internal_order, v_chrstc_activity_id, v_result_msg);

        IF v_return = common.gc_failure THEN
          v_return := characteristics.get_chrstc_id (v_chrstc_type_activity, lads_characteristics.gc_chrstc_na, v_chrstc_activity_id, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || 'Characteristic lookup for Activity # failed or errored. ' || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          v_processing_msg := v_processing_msg || 'Could not find Activity defaulted to #. ';
          v_process_state := common.gc_warning;
        ELSIF v_return <> common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookup for Activity errored. ' || common.nest_err_msg (v_result_msg) || ' ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_ppv_type, v_ppv (v_counter).ppv_type, v_chrstc_ppv_type_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for ppv_type failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        IF v_process_state IN (common.gc_processed, common.gc_warning) THEN
          IF v_ppv (v_counter).ppv_po != 0 THEN
            process_ppv (bpip_characteristics.gc_chrstc_ppv_clssfctn_po, v_ppv (v_counter).ppv_po);
          END IF;

          IF v_ppv (v_counter).ppv_invoice != 0 THEN
            process_ppv (bpip_characteristics.gc_chrstc_ppv_clssfctn_invc, v_ppv (v_counter).ppv_invoice);
          END IF;

          IF v_ppv (v_counter).ppv_finance != 0 THEN
            process_ppv (bpip_characteristics.gc_chrstc_ppv_clssfctn_fin, v_ppv (v_counter).ppv_finance);
          END IF;

          IF v_ppv (v_counter).ppv_freight != 0 THEN
            process_ppv (bpip_characteristics.gc_chrstc_ppv_clssfctn_frght, v_ppv (v_counter).ppv_freight);
          END IF;

          IF v_ppv (v_counter).ppv_other != 0 THEN
            process_ppv (bpip_characteristics.gc_chrstc_ppv_clssfctn_other, v_ppv (v_counter).ppv_other);
          END IF;
        END IF;
      END IF;   --2

      logit.LOG ('Processed Row : ' || v_counter || ' Result : ' || v_process_state || ' - ' || v_processing_msg);

      UPDATE load_ppv_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_ppv (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_ppv_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_cntct_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_CNTCT_BATCH');

    -- Initially mark the whole batch as valid.
    UPDATE load_cntct_data b
       SET b.status = common.gc_validated,
           error_msg = NULL
     WHERE b.batch_id = i_batch_id;

    UPDATE load_cntct_data b
       SET b.status = common.gc_ignored,
           error_msg = 'Framework orders are not loaded into BPIP.'
     WHERE b.batch_id = i_batch_id AND purchase_doc_type = 'FO' AND status = common.gc_validated;

    UPDATE load_cntct_data b
       SET b.status = common.gc_ignored,
           error_msg = 'Purchase orders with nothing left to receipt against them can be ignored.'
     WHERE b.open_quantity = 0 AND b.purchase_doc_type IN ('NB', 'ZNB') AND status = common.gc_validated AND batch_id = i_batch_id;

    UPDATE load_cntct_data b
       SET b.status = common.gc_ignored,
           error_msg = 'Unknown Document Category. Was #.'
     WHERE b.purchase_doc_category = '#' AND status = common.gc_validated AND batch_id = i_batch_id;

    logit.LOG ('In VALIDATE_CNTCT_BATCH, calling update_bus_sgmnt, validate_matl');
    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    -- Update the  status to validated when the processing is complete
    logit.LOG ('In VALIDATE_CNTCT_BATCH, i_batch_id : ' || i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_cntct_batch;

  FUNCTION update_matl_purch_grp (
    i_company           IN      common.st_code,
    i_bus_sgmnt         IN      common.st_code,
    i_material          IN      common.st_code,
    i_vendor            IN      common.st_code,
    i_purchasing_group  IN      common.st_code,
    o_result_msg        OUT     common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'UPDATE_MATL_PURCH_GRP');
    logit.LOG ('Updates the matl purchasing group xref table.');

    UPDATE matl_purch_grp
       SET purchasing_group = i_purchasing_group,
           update_time = SYSDATE
     WHERE company = i_company AND bus_sgmnt = i_bus_sgmnt AND material = i_material AND vendor = i_vendor;

    IF SQL%ROWCOUNT = 0 THEN
      INSERT INTO matl_purch_grp
                  (company, bus_sgmnt, material, vendor, purchasing_group, update_time)
           VALUES (i_company, i_bus_sgmnt, i_material, i_vendor, i_purchasing_group, SYSDATE);
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END update_matl_purch_grp;

  ---------------------------------------------------------------------------------
  FUNCTION process_cntct_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                     common.st_result;
    v_result_msg                 common.st_message_string;
    v_processing_msg             common.st_message_string;
    -- Model Intersect IDS
    v_mi_cntrct_vndr_plnt        common.st_id;
    v_mi_reqst_plnt              common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_id_dataentity  common.st_id;
    v_chrstc_type_id_company     common.st_id;
    v_chrstc_type_id_bus_sgmnt   common.st_id;
    v_chrstc_type_id_matl        common.st_id;
    v_chrstc_type_id_plant       common.st_id;
    v_chrstc_type_id_period      common.st_id;
    v_chrstc_type_id_vendor      common.st_id;
    -- Characteristic IDs
    v_chrstc_id_dataentity       common.st_id;
    v_chrstc_id_company          common.st_id;
    v_chrstc_id_bus_sgmnt        common.st_id;
    v_chrstc_id_matl             common.st_id;
    v_chrstc_id_plant            common.st_id;
    v_chrstc_id_period           common.st_id;
    v_chrstc_id_vendor           common.st_id;
    -- Characteristic Array
    v_chrstc_ids                 common.t_ids;
    -- Other Variables.
    v_counter                    common.st_counter;
    v_process_state              common.st_code;
    v_data_id                    common.st_id;
    v_failure_code               common.st_code;
    v_status                     common.st_code;
    v_dataentity_fromperiod      common.st_code;
    v_dataentity_toperiod        common.st_code;
    v_current_period             common.st_code;
    v_period_ids                 common.t_ids;
    v_period_counter             common.st_counter;
    v_period_codes               common.t_codes;
    v_qty_per_day                common.st_value;
    v_valid_to_date              DATE;
    v_valid_from_date            DATE;
    v_value                      common.st_value;
    v_period_endday              common.st_code;
    v_period_startday            common.st_code;
    v_days                       NUMBER;
    v_start_day                  DATE;
    v_end_day                    DATE;
    v_materials                  common.t_codes;
    v_material_counter           common.st_counter;

    -- select the plan
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.dataentity, a.bus_sgmnt, load_start_time
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details             csr_batch_details%ROWTYPE;

    -- select data from the load_cntct_data table
    CURSOR csr_load_cntct_data IS
      SELECT a.batch_id, a.line_no, a.contract, a.contract_item, a.purchase_doc_type, a.purchase_doc_category, a.company, bus_sgmnt, a.material, a.plant,
        a.vendor, a.valid_from_date, a.valid_to_date, a.open_quantity, a.purchasing_group
      FROM load_cntct_data a
      WHERE a.status IN (common.gc_validated) AND batch_id = i_batch_id
      ORDER BY a.contract ASC, a.contract_item ASC, a.purchase_doc_type DESC;

    CURSOR csr_source_list (i_cntrc_nmbr IN common.st_code, i_cntrc_line_no IN common.st_code) IS
      SELECT reference_functions.short_matl_code (matl_code) AS material
      FROM srce_list
      WHERE cntrc_nmbr = i_cntrc_nmbr AND cntrc_line_no = LPAD (i_cntrc_line_no, 5, '0');

    TYPE t_cntct IS TABLE OF csr_load_cntct_data%ROWTYPE
      INDEX BY common.st_counter;

    rv_last_contract             csr_load_cntct_data%ROWTYPE;
    v_cntct                      t_cntct;
    v_dataentity                 common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_CNTCT_BATCH');
    logit.LOG ('Lookup the characteristic types used in this batch processing.');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_id_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_id_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_id_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_id_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_id_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_vndr, v_chrstc_type_id_vendor, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_id_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_cntrct_vndr_plnt, v_mi_cntrct_vndr_plnt, v_result_msg);
    logit.LOG ('Found mdl isct set id for ' || bpip_model.gc_mi_cntrct_vndr_plnt || ' : ' || v_mi_cntrct_vndr_plnt);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_reqst_plnt, v_mi_reqst_plnt, v_result_msg);
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_reqst_plnt || ' : ' || v_mi_reqst_plnt);
    -- Get the chrstc_id for the COMPANY and  PERIOD chrstc code.
    -- This is performed outside the v_ppv loop below as the value will be the same for the
    -- set of data being processed
    logit.LOG ('Load the batch details and find the characteristics required.');

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_id_company, rv_batch_details.company, v_chrstc_id_company, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_id_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_id_bus_sgmnt, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;

    -- get the dataentity chrstc code
    -- There is only 1 dataentity per batch so source the value from the load batch table
    v_return := characteristics.get_chrstc_id (v_chrstc_type_id_dataentity, rv_batch_details.dataentity, v_chrstc_id_dataentity, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to get chrstc id for : ' || rv_batch_details.dataentity || ' ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Get the chrstc attribute value for FROMPERIOD of this chrstc id
    v_return :=
      characteristics.get_chrstc_attrb_value (v_chrstc_id_dataentity,
                                              finance_characteristics.gc_chrstc_dataentity_fromprd,
                                              v_dataentity_fromperiod,
                                              v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Get the chrstc attribute value for TOPERIOD of this chrstc id
    v_return :=
        characteristics.get_chrstc_attrb_value (v_chrstc_id_dataentity, finance_characteristics.gc_chrstc_dataentity_toprd, v_dataentity_toperiod, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now iterate though the periods that we are loading data into and allocate the qty per day into the days of the plan we are loading data into.
    logit.LOG ('Data Entity : ' || rv_batch_details.dataentity || ' From Period : ' || v_dataentity_fromperiod || ' To Period : ' || v_dataentity_toperiod);
    v_current_period := v_dataentity_fromperiod;
    v_period_counter := 0;
    -- Period collection.
    logit.LOG ('Now create the data entity period collection.');

    LOOP
      -- Now lookup the period characteristic id.
      v_return := characteristics.get_chrstc_id (v_chrstc_type_id_period, v_current_period, v_chrstc_id_period, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored';
        RAISE common.ge_error;
      END IF;

      v_period_counter := v_period_counter + 1;
      v_period_ids (v_period_counter) := v_chrstc_id_period;
      v_period_codes (v_period_counter) := v_current_period;

      -- Now increment the period counter and see if we can move onto the next period.
      BEGIN
        v_current_period := TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_current_period), 1) );
      EXCEPTION
        WHEN OTHERS THEN
          v_processing_msg := 'Failed to increment the current period during the period array processing.';
          RAISE common.ge_error;
      END;

      EXIT WHEN v_current_period > v_dataentity_toperiod;
    END LOOP;

    -- Set the status to deleted for all data values with this data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_id_dataentity;
    v_chrstc_ids (2) := v_chrstc_id_company;
    v_chrstc_ids (3) := v_chrstc_id_bus_sgmnt;
    logit.LOG ('Setting data value status to Deleted for Lowest level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mi_cntrct_vndr_plnt, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- LOOP through the staging table and load the data into the bpip data model
    logit.LOG ('Load the contract data into memory.');

    OPEN csr_load_cntct_data;

    FETCH csr_load_cntct_data
    BULK COLLECT INTO v_cntct;

    CLOSE csr_load_cntct_data;

    logit.LOG ('Now commence processing any rows that are ready for processing.');
    v_counter := 1;

    WHILE v_counter <= v_cntct.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of success.
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_cntct (v_counter).company IS NULL OR
         v_cntct (v_counter).material IS NULL OR
         v_cntct (v_counter).bus_sgmnt IS NULL OR
         v_cntct (v_counter).plant IS NULL OR
         v_cntct (v_counter).vendor IS NULL OR
         v_cntct (v_counter).valid_from_date IS NULL OR
         v_cntct (v_counter).valid_to_date IS NULL THEN
        logit.LOG ('Required chracteristic value was null.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := 'Required chracteristic value was null.';
      ELSIF v_cntct (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSE
        --IF v_process_state = common.gc_success THEN
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_id_bus_sgmnt, v_cntct (v_counter).bus_sgmnt, v_chrstc_id_bus_sgmnt, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_chrstc_ids (3) := v_chrstc_id_bus_sgmnt;

        -- First determine if the is a contract line or a po line.
        IF v_cntct (v_counter).purchase_doc_category = 'K' THEN
          IF common.are_equal (rv_last_contract.contract, v_cntct (v_counter).contract_item) AND
             common.are_equal (rv_last_contract.contract_item, v_cntct (v_counter).contract_item) THEN
            v_processing_msg :=
                 v_processing_msg
              || 'Safely ignore duplicate contract lines as they are associated with material groups which would have already been processed from the source list on the previous record. ';
            v_process_state := common.gc_ignored;
          END IF;

          -- Update the last contract line.
          rv_last_contract := v_cntct (v_counter);
        ELSIF v_cntct (v_counter).purchase_doc_category = 'F' THEN
          v_processing_msg := v_processing_msg || 'Ignore purchase orders. ';
          v_process_state := common.gc_ignored;
        ELSE
          v_processing_msg := v_processing_msg || 'Unknown document category. ';
          v_process_state := common.gc_errored;
        END IF;

        -- Detect if this is a quanity contract
        IF v_process_state = common.gc_processed THEN
          IF v_cntct (v_counter).purchase_doc_type IN ('Z00Q', 'MK') THEN
            -- Now determine if this is a quantity contract line, a non quantity contract line
            IF v_process_state = common.gc_processed THEN
              v_return := characteristics.get_chrstc_id (v_chrstc_type_id_matl, v_cntct (v_counter).material, v_chrstc_id_matl, v_result_msg);

              IF v_return != common.gc_success THEN
                v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored. ';
                v_process_state := common.gc_errored;
              END IF;

              v_return := characteristics.get_chrstc_id (v_chrstc_type_id_plant, v_cntct (v_counter).plant, v_chrstc_id_plant, v_result_msg);

              IF v_return != common.gc_success THEN
                v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored. ';
                v_process_state := common.gc_errored;
              END IF;

              v_return := characteristics.get_chrstc_id (v_chrstc_type_id_vendor, v_cntct (v_counter).vendor, v_chrstc_id_vendor, v_result_msg);

              IF v_return != common.gc_success THEN
                v_processing_msg := v_processing_msg || 'Characteristic lookups for Vendor failed or errored. ';
                v_process_state := common.gc_errored;
              END IF;

              v_chrstc_ids (4) := v_chrstc_id_plant;
              v_chrstc_ids (5) := v_chrstc_id_matl;
              v_chrstc_ids (7) := v_chrstc_id_vendor;

              -- Now calculate the quantity per day.
              BEGIN
                v_valid_to_date := TO_DATE (v_cntct (v_counter).valid_to_date, 'DD.MM.YYYY');
                -- Update the valid from date.
                v_valid_from_date := TO_DATE (v_cntct (v_counter).valid_from_date, 'DD.MM.YYYY');

                IF v_valid_from_date < TRUNC (rv_batch_details.load_start_time) THEN
                  v_valid_from_date := TRUNC (rv_batch_details.load_start_time);
                END IF;

                            -- The following change of adding 1 to the v_days calc below is to account for Oracle date
                -- arithmetic. A contract with a valid_to_date ='28032007' and v_valid_from_date='30032007'
                -- would equal 2 days instead of 3 hence the extra '+1'
                v_days := v_valid_to_date - v_valid_from_date + 1;

                IF v_days >= 1 THEN
                  v_qty_per_day := v_cntct (v_counter).open_quantity / v_days;
                ELSE
                  v_qty_per_day := 0;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  v_process_state := common.gc_errored;
                  v_processing_msg := 'Unable to calculate the open quanity allocation from the valid to date and loading date.';
              END;

              -- Now process each period and add the relevant contract information.
              v_period_counter := 1;

              LOOP
                -- Exit loop when we have finished processing all the periods.
                EXIT WHEN v_period_counter > v_period_ids.COUNT;
                -- Now lookup the number of days in this period.
                v_return :=
                  characteristics.get_chrstc_attrb_value (v_period_ids (v_period_counter),
                                                          chrstc_mars_date.gc_chrstc_period_startday,
                                                          v_period_startday,
                                                          v_result_msg);

                IF v_return != common.gc_success THEN
                  v_processing_msg := common.nest_err_msg (v_result_msg);
                  RAISE common.ge_failure;
                END IF;

                -- Now lookup the number of days in this period.
                v_return :=
                  characteristics.get_chrstc_attrb_value (v_period_ids (v_period_counter),
                                                          chrstc_mars_date.gc_chrstc_period_endday,
                                                          v_period_endday,
                                                          v_result_msg);

                IF v_return != common.gc_success THEN
                  v_processing_msg := common.nest_err_msg (v_result_msg);
                  RAISE common.ge_failure;
                END IF;

                -- Add the values to the database.
                BEGIN
                  v_start_day := TO_DATE (v_period_startday, 'YYYYMMDD');
                  v_end_day := TO_DATE (v_period_endday, 'YYYYMMDD');
                  v_days := v_end_day - v_start_day + 1;

                  IF v_end_day > v_valid_to_date THEN
                    IF v_start_day <= v_valid_to_date THEN
                      v_days := v_days - (v_end_day - v_valid_to_date);
                    ELSE
                      v_days := 0;
                    END IF;
                  END IF;

                  IF v_start_day < v_valid_from_date THEN
                    IF v_end_day >= v_valid_from_date THEN
                      v_days := v_days - (v_valid_from_date - v_start_day);
                    ELSE
                      v_days := 0;
                    END IF;
                  END IF;

                  -- Now calculate the value.
                  v_value := v_days * v_qty_per_day;
                EXCEPTION
                  WHEN OTHERS THEN
                    v_processing_msg := 'Unable to calculate the contract quantity per period.';
                    RAISE common.ge_failure;
                END;

                -- Update characteristics list.
                v_chrstc_ids (6) := v_period_ids (v_period_counter);

                -- Processing for CNTRCT_VNDR_PLNT mdl isct
                IF v_process_state = common.gc_processed THEN
                  -- Only create or attempt to save a data point if the calculated days was not zero.
                  IF v_days <> 0 THEN
                    logit.LOG ('Calling save value for CNTRCT_VNDR_PLNT intersect.');
                    v_return := save_value (v_mi_cntrct_vndr_plnt, v_chrstc_ids, v_value, TRUE, v_result_msg);

                    IF v_return != common.gc_success THEN
                      v_processing_msg := common.nest_err_msg (v_result_msg);
                      v_process_state := common.gc_errored;
                    END IF;
                  END IF;
                END IF;

                -- Increment the period counter.
                v_period_counter := v_period_counter + 1;
              END LOOP;

              -- Update the material purchasing group xref table while we are here.
              IF v_process_state = common.gc_processed THEN
                v_return :=
                  update_matl_purch_grp (v_cntct (v_counter).company,
                                         v_cntct (v_counter).bus_sgmnt,
                                         v_cntct (v_counter).material,
                                         v_cntct (v_counter).vendor,
                                         v_cntct (v_counter).purchasing_group,
                                         v_result_msg);

                IF v_return != common.gc_success THEN
                  v_processing_msg := common.nest_err_msg (v_result_msg);
                  v_process_state := common.gc_errored;
                END IF;
              END IF;
            END IF;
          -- Detect if this a a non quantity contract
          ELSIF v_cntct (v_counter).purchase_doc_type IN ('Z0NQ', 'ZNQ', 'Z001', 'Z008', 'Z009') THEN
            -- Vendor Lookup
            IF v_process_state = common.gc_processed THEN
              v_return := characteristics.get_chrstc_id (v_chrstc_type_id_vendor, lads_characteristics.gc_chrstc_na, v_chrstc_id_vendor, v_result_msg);

              IF v_return != common.gc_success THEN
                v_processing_msg := v_processing_msg || 'Characteristic lookups for Vendor failed or errored. ';
                v_process_state := common.gc_errored;
              END IF;
            END IF;

            -- Now lookup the plant characteristic for this contract.
            IF v_process_state = common.gc_processed THEN
              v_return := characteristics.get_chrstc_id (v_chrstc_type_id_plant, v_cntct (v_counter).plant, v_chrstc_id_plant, v_result_msg);

              IF v_return != common.gc_success THEN
                v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored. ';
                v_process_state := common.gc_errored;
              END IF;
            END IF;

            v_chrstc_ids (4) := v_chrstc_id_plant;
            -- Now look at the material setup to produce a list of materials to use.
            v_materials.DELETE;

            IF v_cntct (v_counter).material = lads_characteristics.gc_chrstc_na THEN
              OPEN csr_source_list (v_cntct (v_counter).contract, v_cntct (v_counter).contract_item);

              FETCH csr_source_list
              BULK COLLECT INTO v_materials;

              CLOSE csr_source_list;
            ELSE
              v_materials (1) := v_cntct (v_counter).material;
            END IF;

            IF v_materials.COUNT = 0 THEN
              v_processing_msg := 'Unable to find any materials for this contract to add to model.';
              v_process_state := common.gc_warning;
            END IF;

            -- Now figure out the contract valid to and from dates.
            BEGIN
              v_valid_to_date := TO_DATE (v_cntct (v_counter).valid_to_date, 'DD.MM.YYYY');
              -- Update the valid from date.
              v_valid_from_date := TO_DATE (v_cntct (v_counter).valid_from_date, 'DD.MM.YYYY');
            EXCEPTION
              WHEN OTHERS THEN
                v_process_state := common.gc_errored;
                v_processing_msg := 'Unable to calculate the valid from and to date and or loading date.';
            END;

            -- Now continue processing each of the materials for this contract.
            IF v_process_state = common.gc_processed THEN
              v_material_counter := 1;

              LOOP
                -- Exit when there are no more materials left to process.
                EXIT WHEN v_material_counter > v_materials.COUNT;

                IF v_process_state = common.gc_processed THEN
                  v_return := characteristics.get_chrstc_id (v_chrstc_type_id_matl, v_materials (v_material_counter), v_chrstc_id_matl, v_result_msg);

                  IF v_return != common.gc_success THEN
                    v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored. ';
                    v_process_state := common.gc_errored;
                  END IF;
                END IF;

                v_chrstc_ids (5) := v_chrstc_id_matl;
                -- Now process each period and add the relevant contract information.
                v_period_counter := 1;

                LOOP
                  -- Exit loop when we have finished processing all the periods.
                  EXIT WHEN v_period_counter > v_period_ids.COUNT;
                  
                  -- Now ensure that the vendor characteristics has been cleared from previous processing.
                  v_chrstc_ids.DELETE (7);

                  -- Now lookup the number of days in this period.
                  v_return :=
                    characteristics.get_chrstc_attrb_value (v_period_ids (v_period_counter),
                                                            chrstc_mars_date.gc_chrstc_period_startday,
                                                            v_period_startday,
                                                            v_result_msg);

                  IF v_return != common.gc_success THEN
                    v_processing_msg := common.nest_err_msg (v_result_msg);
                    RAISE common.ge_failure;
                  END IF;

                  -- Now lookup the number of days in this period.
                  v_return :=
                    characteristics.get_chrstc_attrb_value (v_period_ids (v_period_counter),
                                                            chrstc_mars_date.gc_chrstc_period_endday,
                                                            v_period_endday,
                                                            v_result_msg);

                  IF v_return != common.gc_success THEN
                    v_processing_msg := common.nest_err_msg (v_result_msg);
                    RAISE common.ge_failure;
                  END IF;

                  -- Add the values to the database.
                  BEGIN
                    v_start_day := TO_DATE (v_period_startday, 'YYYYMMDD');
                    v_end_day := TO_DATE (v_period_endday, 'YYYYMMDD');
                    v_days := v_end_day - v_start_day + 1;

                    -- Only load this data if we have a complete period covered by the contract.
                    IF v_end_day > v_valid_to_date THEN
                      IF v_start_day <= v_valid_to_date THEN
                        v_days := 0;
                      ELSE
                        v_days := 0;
                      END IF;
                    END IF;

                    IF v_start_day < v_valid_from_date THEN
                      IF v_end_day >= v_valid_from_date THEN
                        v_days := 0;
                      ELSE
                        v_days := 0;
                      END IF;
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      v_processing_msg := 'Unable to calculate the days that this contract is valid for.';
                      RAISE common.ge_failure;
                  END;

                  -- Update characteristics list.
                  v_chrstc_ids (6) := v_period_ids (v_period_counter);

                  -- Now lookup the mrp requsition quanitity for this material plant period.
                  v_value := null;  
                  IF v_process_state = common.gc_processed THEN
                    IF v_days <> 0 THEN
                      v_return := data_values.get_data_id (v_mi_reqst_plnt, v_chrstc_ids, v_data_id, v_result_msg);

                      IF v_return = common.gc_success THEN
                        v_return := data_values.get_data_vlu_status (v_data_id, v_status, v_result_msg);

                        IF v_return <> common.gc_success THEN
                          v_process_state := common.gc_errored;
                          v_processing_msg := 'Unable to get data id status for data id : ' || v_data_id || '.';
                        ELSE
                          IF v_status = data_values.gc_data_vlu_status_deleted THEN
                            v_value := NULL;
                          ELSE
                            v_return := data_values.get_data_vlu_bot_up (v_data_id, v_value, v_result_msg);

                            IF v_return <> common.gc_success THEN
                              v_process_state := common.gc_errored;
                              v_processing_msg := 'Unable to retrieve MRP Requistion data value for data id : ' || v_data_id || '.';
                            END IF;
                          END IF;
                        END IF;
                      ELSIF v_return = common.gc_failure THEN
                        v_value := NULL;
                      ELSE
                        v_process_state := common.gc_errored;
                        v_processing_msg := common.nest_err_msg (v_result_msg);
                      END IF;
                    END IF;
                  END IF;

                  -- Processing for CNTRCT_VNDR_PLNT mdl isct
                  IF v_process_state = common.gc_processed THEN
                    -- Only create or attempt to save a data point if the calculated days was not zero.
                    IF v_days <> 0 AND v_value IS NOT NULL THEN
                      logit.LOG ('Calling save value for CNTRCT_VNDR_PLNT intersect.');
                      v_chrstc_ids (7) := v_chrstc_id_vendor;
                      v_return := save_value (v_mi_cntrct_vndr_plnt, v_chrstc_ids, v_value, FALSE, v_result_msg);

                      IF v_return != common.gc_success THEN
                        v_processing_msg := common.nest_err_msg (v_result_msg);
                        v_process_state := common.gc_errored;
                      END IF;

                    END IF;
                  END IF;

                  -- Increment the period counter.
                  v_period_counter := v_period_counter + 1;
                END LOOP;

                -- Update the material purchasing group xref table while we are here.
                IF v_process_state = common.gc_processed THEN
                  v_return :=
                    update_matl_purch_grp (v_cntct (v_counter).company,
                                           v_cntct (v_counter).bus_sgmnt,
                                           v_materials (v_material_counter),
                                           v_cntct (v_counter).vendor,
                                           v_cntct (v_counter).purchasing_group,
                                           v_result_msg);

                  IF v_return != common.gc_success THEN
                    v_processing_msg := common.nest_err_msg (v_result_msg);
                    v_process_state := common.gc_errored;
                  END IF;
                END IF;

                -- Increase the Material Counter.
                v_material_counter := v_material_counter + 1;
              END LOOP;
            END IF;
          ELSE
            v_process_state := common.gc_errored;
            v_processing_msg := 'Unknown contract document type.';
          END IF;
        END IF;
      END IF;

      logit.LOG (' Set the status for the load_cntct_data row after processing, v_process_state : ' || v_process_state);

      UPDATE load_cntct_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_cntct (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
      -- Commit any changes made after processing this row.
      COMMIT;
    END LOOP;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_cntct_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_safty_stk_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_SAFTY_STK_BATCH');
    logit.LOG ('In validate_safty_stk_batch, calling update_bus_sgmnt, validate_matl');

    UPDATE load_safty_stk_data b
       SET b.status = common.gc_validated,
           error_msg = NULL
     WHERE b.batch_id = i_batch_id;

    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_safty_stk_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_safty_stk_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                  common.st_result;
    v_result                  common.st_result;
    v_processing_msg          common.st_message_string;
    v_result_msg              common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_ssp         common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity  common.st_id;
    v_chrstc_type_company     common.st_id;
    v_chrstc_type_bus_sgmnt   common.st_id;
    v_chrstc_type_matl        common.st_id;
    v_chrstc_type_plant       common.st_id;
    -- Characteristic IDs
    v_chrstc_id_dataentity    common.st_id;
    v_chrstc_company_id       common.st_id;
    v_chrstc_bus_sgmnt_id     common.st_id;
    v_chrstc_matl_id          common.st_id;
    v_chrstc_plant_id         common.st_id;
    -- Characteristic Array
    v_chrstc_ids              common.t_ids;
    -- Other Variables.
    v_counter                 common.st_counter;
    v_process_state           common.st_code;
    v_data_id                 common.st_id;
    v_failure_code            common.st_code;
    v_status                  common.st_code;

    -- select the plan
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.dataentity, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details          csr_batch_details%ROWTYPE;

    -- select data from the load_safty_stk_data table
    CURSOR csr_load_safty_stk_data IS
      SELECT a.batch_id, a.line_no, a.company, bus_sgmnt, a.material, a.plant, a.safety_stock
      FROM load_safty_stk_data a
      WHERE a.status IN (common.gc_validated) AND a.batch_id = i_batch_id;

    TYPE t_safety_stock IS TABLE OF csr_load_safty_stk_data%ROWTYPE
      INDEX BY common.st_counter;

    v_safety_stock            t_safety_stock;
    v_dataentity              common.st_code;
    v_company                 common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_SAFTY_STK_BATCH');
    logit.LOG ('get required chrstc types');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_safe_stck_plnt || ' : ' || v_mdl_isct_id_ssp);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_safe_stck_plnt, v_mdl_isct_id_ssp, v_result_msg);
    logit.LOG ('pre process the rows.  Call set_requirement procedure');
    set_requirement;

    -- Get the chrstc_id for the COMPANY chrstc code.
      -- This is performed outside the v_mvmt loop below as the value will be the same for the
      -- set of data being processed
    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('Characteristic lookups for COMPANY failed or errored :' || v_company);
      RAISE common.ge_error;
    END IF;

    -- get the dataentity chrstc code
    -- There is only 1 dataentity per batch so source the value from the load batch table
    v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity, rv_batch_details.dataentity, v_chrstc_id_dataentity, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to get chrstc id for : ' || v_dataentity || ' ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;
    
    -- Set the status to deleted for all data values with this data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_id_dataentity;
    v_chrstc_ids (2) := v_chrstc_company_id;
    v_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
    logit.LOG ('Setting data value status to Deleted for Lowest level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_ssp, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- LOOP through the staging table and load the data into the bpip data model
    OPEN csr_load_safty_stk_data;

    FETCH csr_load_safty_stk_data
    BULK COLLECT INTO v_safety_stock;

    CLOSE csr_load_safty_stk_data;

    logit.LOG ('Now commence processing any rows that are ready for processing.');
    v_counter := 1;

    WHILE v_counter <= v_safety_stock.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of processed.
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_safety_stock (v_counter).company IS NULL OR
         v_safety_stock (v_counter).material IS NULL OR
         v_safety_stock (v_counter).bus_sgmnt IS NULL OR
         v_safety_stock (v_counter).plant IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Characteristic was null.';
      ELSIF v_safety_stock (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSIF v_safety_stock (v_counter).safety_stock = 0 THEN
        logit.LOG ('Zero Safety Stock.  Row Ignored. ');
        v_process_state := common.gc_ignored;
        v_processing_msg := v_processing_msg || 'Zero Safety Stock.';
      ELSE
        -- IF v_process_state = common.gc_success THEN
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_safety_stock (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_safety_stock (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_safety_stock (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        --  Assign chrstc ids to the array
        v_chrstc_ids.DELETE;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_id_dataentity;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;

        -- Processing for the mdl isct
        IF v_process_state = common.gc_processed THEN
          logit.LOG ('Calling save value for SAFE_STCK_PLNT intersect.');
          v_return := save_value (v_mdl_isct_id_ssp, v_chrstc_ids, v_safety_stock (v_counter).safety_stock, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := common.nest_err_msg (v_result_msg);
            v_process_state := common.gc_errored;
          END IF;
        END IF;
      END IF;

      logit.LOG (' set the status for the load_safty_stk_data row after processing.');

      UPDATE load_safty_stk_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_safety_stock (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_safty_stk_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_mvmt_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_MVMT_BATCH');
    v_result := common.gc_success;

    UPDATE load_mvmt_data a
       SET a.status = common.gc_validated,
           error_msg = NULL
     WHERE a.batch_id = i_batch_id;

    logit.LOG ('In validate_mvmt_batch, calling update_bus_sgmnt, validate_matl');
    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    -- Update the  status to validated when the processing is complete
    logit.LOG ('In validate_mvmt_batch, i_batch_id : ' || i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_mvmt_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_mvmt_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                       common.st_result;
    v_result                       common.st_result;
    v_processing_msg               common.st_message_string;
    v_result_msg                   common.st_message_string;
    v_mdl_isct_id_sales_qty        common.st_id;
    v_mdl_isct_id_c_qty            common.st_id;
    v_mdl_isct_id_prodn_qty_plant  common.st_id;
    v_chrstc_type_dataentity       common.st_id;
    v_chrstc_type_company          common.st_id;
    v_chrstc_type_bus_sgmnt        common.st_id;
    v_chrstc_type_matl             common.st_id;
    v_chrstc_type_plant            common.st_id;
    v_chrstc_type_period           common.st_id;
    v_chrstc_type_vendor           common.st_id;
    v_chrstc_dataentity_id         common.st_id;
    v_chrstc_company_id            common.st_id;
    v_chrstc_bus_sgmnt_id          common.st_id;
    v_chrstc_matl_id               common.st_id;
    v_chrstc_plant_id              common.st_id;
    v_chrstc_period_id             common.st_id;
    v_chrstc_vendor_id             common.st_id;
    v_chrstc_ids                   common.t_ids;
    v_counter                      common.st_counter;
    v_process_state                common.st_code;
    --
    v_chrstc_attrb_value           common.st_value;
    v_nextperiod_chrstc_id         common.st_id;
    v_chrstc_type                  common.st_code;
    v_dataentity                   common.st_code;
    v_company                      common.st_code;
    v_matl_type                    common.st_code;
    v_nextperiod_counter           common.st_counter;

    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details               csr_batch_details%ROWTYPE;

    -- select data from the load_mvmt_data table
    CURSOR csr_load_mvmt_data IS
      SELECT a.batch_id, a.line_no, a.company, bus_sgmnt, a.material, a.plant, a.sales_qty, a.consumption_qty, a.production_qty
      FROM load_mvmt_data a
      WHERE a.batch_id = i_batch_id AND a.status = common.gc_validated;

    TYPE t_mvmt IS TABLE OF csr_load_mvmt_data%ROWTYPE
      INDEX BY common.st_counter;

    v_mvmt                         t_mvmt;
  -- LOCAL FUNCTION TO RETURN MATERIAL TYPE
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_MVMT_BATCH');
    logit.LOG ('get required chrstc types');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_sales_plnt || ' : ' || v_mdl_isct_id_sales_qty);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_sales_plnt, v_mdl_isct_id_sales_qty, v_result_msg);
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_cons_reqmnt_plnt || ' : ' || v_mdl_isct_id_c_qty);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_cons_reqmnt_plnt, v_mdl_isct_id_c_qty, v_result_msg);
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_prodn_plnt || ' : ' || v_mdl_isct_id_prodn_qty_plant);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_prodn_plnt, v_mdl_isct_id_prodn_qty_plant, v_result_msg);
    -- Get characteristic ID for data entity of ACTUALS which is a constant characteristic value for this data entity
    v_return :=
            characteristics.get_chrstc_id (v_chrstc_type_dataentity, finance_characteristics.gc_chrstc_dataentity_actuals, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg :=
                 common.create_error_msg ('Characteristic lookups for Data Entity failed or errored :' || finance_characteristics.gc_chrstc_dataentity_actuals);
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the COMPANY chrstc code.
    -- This is performed outside the v_mvmt loop below as the value will be the same for the
    -- set of data being processed
    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    -- Get characteristic ID for company
    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    -- Get characteristic ID for period
    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period failed or errored';
      RAISE common.ge_error;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;
    
    -- Set the status to deleted for all data values with this period and data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (3) := v_chrstc_company_id;
    v_chrstc_ids (2) := v_chrstc_period_id;
    v_chrstc_ids (4) := v_chrstc_bus_sgmnt_id;
    logit.LOG ('Setting data value status to Deleted for SALES_QTY_PLANT level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_sales_qty, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('Setting data value status to Deleted for CON_REQ_QTY_PLANT level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_c_qty, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('Setting data value status to Deleted for PRODUCTION_QTY_PLANT level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_prodn_qty_plant, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed into memory.');

    OPEN csr_load_mvmt_data;

    FETCH csr_load_mvmt_data
    BULK COLLECT INTO v_mvmt;

    CLOSE csr_load_mvmt_data;

    logit.LOG ('Now commence processing any rows that are ready for processing.');
    v_counter := 1;

    WHILE v_counter <= v_mvmt.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of success.
      -- Start with a default processing state of success.
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_mvmt (v_counter).company IS NULL OR
         v_mvmt (v_counter).material IS NULL OR 
         v_mvmt (v_counter).bus_sgmnt IS NULL OR 
         v_mvmt (v_counter).plant IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Required characteristic was null. ';
      ELSIF v_mvmt (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSE
        --IF v_process_state = common.gc_success THEN   --2
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_mvmt (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_mvmt (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_mvmt (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        -- Assign chrstc ids to the array
        v_chrstc_ids.DELETE;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_dataentity_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_period_id;

        -- Logit.log('Loading data into SALES_QTY_PLANT');
        IF v_process_state = common.gc_processed AND v_mvmt (v_counter).sales_qty IS NOT NULL THEN   -- 3
          logit.LOG ('Call save data value for sales qty model intersect.');
          v_return := save_value (v_mdl_isct_id_sales_qty, v_chrstc_ids, v_mvmt (v_counter).sales_qty, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;
        END IF;

        -- Logit.log('Loading data into CON_REQ_QTY_PLANT');
        IF v_process_state = common.gc_processed AND v_mvmt (v_counter).consumption_qty IS NOT NULL THEN
          IF (bpip_reference.get_matl_type (reference_functions.full_matl_code (v_mvmt (v_counter).material) ) =
                                                                                                               lads_characteristics.gc_chrstc_matl_type_fert AND
              bpip_reference.is_contracted (reference_functions.full_matl_code (v_mvmt (v_counter).material), v_mvmt (v_counter).plant) = TRUE) OR
             bpip_reference.get_matl_type (reference_functions.full_matl_code (v_mvmt (v_counter).material) ) !=
                                                                                                                lads_characteristics.gc_chrstc_matl_type_fert THEN
            logit.LOG (   'Call save values for CONSUMPTION QTY, bought_in is true and material type :'
                       || bpip_reference.get_matl_type (reference_functions.full_matl_code (v_mvmt (v_counter).material) ) );
            v_return := save_value (v_mdl_isct_id_c_qty, v_chrstc_ids, v_mvmt (v_counter).consumption_qty, TRUE, v_result_msg);

            IF v_return <> common.gc_success THEN
              v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
              v_process_state := common.gc_errored;
            END IF;
          ELSE   -- not a FERT
            --
            logit.LOG (   'Could not load consumption qty as the finished good was not a bought in one and material type :'
                       || bpip_reference.get_matl_type (reference_functions.full_matl_code (v_mvmt (v_counter).material) ) );
            v_processing_msg := v_processing_msg || 'Could not load consumption qty as the finished good was not a bought in one. ';
            v_process_state := common.gc_ignored;
          END IF;
        END IF;

              --
        -- PRODUCTION_QTY_PLANT
        IF v_process_state = common.gc_processed AND v_mvmt (v_counter).production_qty IS NOT NULL THEN
          logit.LOG ('Call save values PRODUCTION QTY intersect.');
          v_return := save_value (v_mdl_isct_id_prodn_qty_plant, v_chrstc_ids, v_mvmt (v_counter).production_qty, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          -- Code to ensure next 3 periods after the period just loaded have a value of at least zero
          -- Code to ensure next 3 periods have a value of at least zero
          v_nextperiod_counter := 1;

          WHILE v_nextperiod_counter <= 3
          LOOP
            -- loop through the chrstcs array until we find the chrstc type of period
              -- Get the chrstc attribute value for NEXTperiod of this chrstc id
            v_result :=
              characteristics.get_chrstc_attrb_value (v_chrstc_ids (v_chrstc_ids.COUNT),
                                                      chrstc_mars_date.gc_chrstc_period_nextprd,
                                                      v_chrstc_attrb_value,
                                                      v_result_msg);

            IF v_result != common.gc_success THEN
              v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
              v_process_state := common.gc_errored;
            END IF;

            -- Get chrstc_id for the NEXTperiod attribute value
            v_result := characteristics.get_chrstc_id (v_chrstc_type_period, TO_CHAR (v_chrstc_attrb_value), v_nextperiod_chrstc_id, v_result_msg);

            IF v_result != common.gc_success THEN
              v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
              v_process_state := common.gc_errored;
            END IF;

            -- replace the period chrstc id with the new period chrstc id ie the previous period
            v_chrstc_ids (v_chrstc_ids.COUNT) := v_nextperiod_chrstc_id;
            v_return := save_value (v_mdl_isct_id_prodn_qty_plant, v_chrstc_ids, 0, TRUE, v_result_msg);

            IF v_return != common.gc_success THEN
              v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
              v_process_state := common.gc_errored;
            END IF;

            v_nextperiod_counter := v_nextperiod_counter + 1;
          END LOOP;
        --
        END IF;
      END IF;   --1

      logit.LOG ('Set the status for the load_mvmt_data row after processing, v_process_state : ' || v_process_state);

      UPDATE load_mvmt_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_mvmt (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_mvmt_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_invc_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_INVC_BATCH');

    UPDATE load_invc_data b
       SET b.status = common.gc_validated,
           error_msg = NULL
     WHERE b.batch_id = i_batch_id;

    validate_matl_prfcnr (i_batch_id);
    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    COMMIT;
    -- Update the  status to validated when the processing is complete
    logit.LOG ('In validate_invc_batch, i_batch_id : ' || i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_invc_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_invc_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                     common.st_result;
    v_result                     common.st_result;
    v_processing_msg             common.st_message_string;
    v_processing_msg_spnd        common.st_message_string;
    v_processing_msg_qty         common.st_message_string;
    v_result_msg                 common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_spnd_vnd       common.st_id;
    v_mdl_isct_id_invc_qty_plnt  common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity     common.st_id;
    v_chrstc_type_company        common.st_id;
    v_chrstc_type_bus_sgmnt      common.st_id;
    v_chrstc_type_matl           common.st_id;
    v_chrstc_type_plant          common.st_id;
    v_chrstc_type_period         common.st_id;
    v_chrstc_type_vendor         common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id       common.st_id;
    v_chrstc_company_id          common.st_id;
    v_chrstc_bus_sgmnt_id        common.st_id;
    v_chrstc_matl_id             common.st_id;
    v_chrstc_plant_id            common.st_id;
    v_chrstc_period_id           common.st_id;
    v_chrstc_id_vendor           common.st_id;
    -- Characteristic Array
    v_chrstc_ids                 common.t_ids;
    -- Other Variables
    v_counter                    common.st_counter;
    v_process_state              common.st_code;
    v_process_state_spnd         common.st_code;
    v_process_state_qty          common.st_code;
    v_data_id                    common.st_id;
    v_failure_code               common.st_code;
    v_status                     common.st_code;
    v_chrstc_attrb_value         common.st_value;
    v_nextperiod_chrstc_id       common.st_id;
    v_chrstc_count               common.st_counter;
    v_chrstc_type                common.st_code;
    v_period_chrstc_type_id      common.st_id;

    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details             csr_batch_details%ROWTYPE;

    -- select data from the load_invc_data table
    CURSOR csr_load_invc_data IS
      SELECT a.batch_id, a.line_no, a.company, SUBSTR (a.period, INSTR (a.period, '/') + 5, 4) || SUBSTR (a.period, INSTR (a.period, '/') + 2, 2) mars_period,
        a.bus_sgmnt, a.plant, a.profit_center, a.cost_center, a.internal_order, a.ACCOUNT, a.posting_date, a.po_type, a.document_type, a.item_gl_type,
        a.item_status, a.purchasing_group, a.vendor, a.material_group, a.material, a.document_currency, a.amount_dc, a.amount_lc, a.invoice_qty
      FROM load_invc_data a
      WHERE a.batch_id = i_batch_id AND a.status = common.gc_validated;

    TYPE t_invc IS TABLE OF csr_load_invc_data%ROWTYPE
      INDEX BY common.st_counter;

    v_invc                       t_invc;
    v_dataentity                 common.st_code;
    v_company                    common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_INVC_BATCH');
    logit.LOG ('get required chrstc types');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_vndr, v_chrstc_type_vendor, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_spnd_vndr_plnt);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_spnd_vndr_plnt, v_mdl_isct_id_spnd_vnd, v_result_msg);
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_invc_qty_plnt);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_invc_qty_plnt, v_mdl_isct_id_invc_qty_plnt, v_result_msg);
 
    -- Get characteristic ID for data entity of ACTUALS which is a constant characteristic value for this data entity

    -- Get the chrstc_id for the 'ACTUALS' DATAENTITY.
    -- This is performed outside the v_invc loop below as the value is a constant.
    v_return :=
            characteristics.get_chrstc_id (v_chrstc_type_dataentity, finance_characteristics.gc_chrstc_dataentity_actuals, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('Characteristic lookups for Data Entity failed or errored');
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the COMPANY chrstc code.
       -- This is performed outside the v_invc loop below as the value will be the same for the
       -- set of data being processed
    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company on batch header failed or errored';
      RAISE common.ge_error;
    END IF;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period on batch header failed or errored';
      RAISE common.ge_error;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;

    -- Set the status to deleted for all data values with this mars week and data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_period_id;
    v_chrstc_ids (3) := v_chrstc_company_id;
    v_chrstc_ids (4) := v_chrstc_bus_sgmnt_id;
    logit.LOG ('Setting data value status to Deleted for Lowest level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_spnd_vnd, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_invc_qty_plnt, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed for Spend Per Vendor Plant into memory.');

    -- LOOP through the staging table and load the data into the bpip data model
    OPEN csr_load_invc_data;

    FETCH csr_load_invc_data
    BULK COLLECT INTO v_invc;

    CLOSE csr_load_invc_data;

    -- LOOP through the staging table and load the data into the bpip data model
    logit.LOG ('Now process the found records into the model intersect.');
    v_counter := 1;

    WHILE v_counter <= v_invc.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of success.
      v_process_state := common.gc_processed;
      v_processing_msg := '';
      -- new processing states to handle the state of a load to a particular intersect
      v_process_state_spnd := common.gc_processed;
      v_processing_msg_spnd := '';
      v_process_state_qty := common.gc_processed;
      v_processing_msg_qty := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_invc (v_counter).company IS NULL OR
         v_invc (v_counter).material IS NULL OR
         v_invc (v_counter).bus_sgmnt IS NULL OR
         v_invc (v_counter).plant IS NULL OR
         v_invc (v_counter).vendor IS NULL OR
         v_invc (v_counter).mars_period IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Characteristic was null. ';
      ELSIF v_invc (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
     ELSIF v_invc (v_counter).amount_lc = 0 AND
           ( (v_invc (v_counter).invoice_qty = 0 AND v_invc (v_counter).item_gl_type = 'W') OR (v_invc (v_counter).item_gl_type != 'W') ) THEN
       logit.LOG ('Zero Amount and Zero Qty OR Item GL Type not equal to W.  Row Ignored for Spend Per Vendor Plant and Invoice Qty Plant. ');
       v_process_state := common.gc_ignored;
       v_processing_msg := v_processing_msg || 'Zero Amount and Zero Qty OR Item GL Type not equal to W. Row Ignored for Spend Per Vendor Plant and Invoice Qty Plant. ';
      ELSE
        -- Set the intermediate processing state and messsage
        IF v_invc (v_counter).amount_lc = 0 AND
            v_invc (v_counter).invoice_qty != 0 AND v_invc (v_counter).item_gl_type = 'W' THEN
          logit.LOG ('Zero Amount.  Row Ignored for Spend Per Vendor Plant. ');
          v_process_state_spnd := common.gc_ignored;
          v_processing_msg_spnd := v_processing_msg || 'Zero Amount.  Row Ignored for Spend Per Vendor Plant. ';
        ELSIF v_invc (v_counter).invoice_qty = 0 AND v_invc (v_counter).item_gl_type = 'W' AND v_invc (v_counter).amount_lc != 0 THEN
          logit.LOG ('Zero Invoice Qty.  Row Ignored for Invoice Qty Plant. ');
          v_process_state_qty := common.gc_ignored;
          v_processing_msg_qty := v_processing_msg || 'Zero Invoice Qty.  Row Ignored for Invoice Qty Plant. ';
        ELSIF v_invc (v_counter).item_gl_type != 'W' AND v_invc (v_counter).amount_lc != 0 THEN
          logit.LOG ('Item GL Type not equal to W.  Row Ignored for Invoice Qty Plant. ');
          v_process_state_qty := common.gc_ignored;
          v_processing_msg_qty := v_processing_msg || 'Item GL Type not equal to W.  Row Ignored for Invoice Qty Plant. ';
        END IF;

        --
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_invc (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_invc (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_invc (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        IF v_invc (v_counter).vendor = lads_characteristics.gc_chrstc_na THEN
          v_processing_msg :=
               v_processing_msg
            || 'Vendor was # this usually is because of an internal transfer and goods receipt. As a result this record has been ignored. '
            || common.nest_err_msg (v_result_msg)
            || ' ';
          v_process_state := common.gc_ignored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_vendor, v_invc (v_counter).vendor, v_chrstc_id_vendor, v_result_msg);

        IF v_return = common.gc_failure THEN
          v_return := characteristics.get_chrstc_id (v_chrstc_type_vendor, lads_characteristics.gc_chrstc_na, v_chrstc_id_vendor, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || 'Characteristic lookup for Vendor # failed or errored. ' || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          v_processing_msg := v_processing_msg || 'Could not find Vendor defaulted to #. ';
          v_process_state := common.gc_warning;
        ELSIF v_return <> common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookup for Vendor errored. ' || common.nest_err_msg (v_result_msg) || ' ';
          v_process_state := common.gc_errored;
        END IF;


        -- Assign chrstc ids to the array
        v_chrstc_ids.DELETE;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_dataentity_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_id_vendor;
        v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_period_id;
        logit.LOG ('v_chrstc_ids.COUNT : ' || v_chrstc_ids.COUNT);

        -- Processing for SPND_VNDR_PLNT mdl isct.
          -- 
       IF v_process_state IN (common.gc_processed, common.gc_warning) THEN

          IF v_process_state_spnd IN (common.gc_processed, common.gc_warning) THEN
            logit.LOG ('Calling save value for SPND_VNDR_PLNT intersect.');
            v_return := save_value (v_mdl_isct_id_spnd_vnd, v_chrstc_ids, v_invc (v_counter).amount_lc, TRUE, v_result_msg);

            IF v_return != common.gc_success THEN
              v_processing_msg := common.nest_err_msg (v_result_msg);
              v_process_state := common.gc_errored;
            END IF;
          END IF;

          -- Processing for INVC_QTY_PLNT mdl isct.
          IF v_process_state_qty IN (common.gc_processed, common.gc_warning) THEN
            logit.LOG ('Calling save_value for INVC_QTY_PLNT intersect.');
            v_return := save_value (v_mdl_isct_id_invc_qty_plnt, v_chrstc_ids, v_invc (v_counter).invoice_qty, TRUE, v_result_msg);

            IF v_return != common.gc_success THEN
              v_processing_msg := common.nest_err_msg (v_result_msg);
              v_process_state := common.gc_errored;
            END IF;
          END IF;

          -- Code to ensure next 12 periods have a value of at least zero.
          -- only process if v_process_state_spnd or v_process_state_qty is processed.
          IF v_process_state_spnd IN (common.gc_processed, common.gc_warning) OR v_process_state_qty IN (common.gc_processed, common.gc_warning) THEN
          logit.LOG ('Ensure next 12 periods have a value of at least zero. v_process_state_spnd : '||v_process_state_spnd||' v_process_state_qty : '||v_process_state_qty );
            FOR v_counter_1 IN 1 .. 12
            LOOP
              -- Get the chrstc attribute value for NEXTperiod of this chrstc id
              v_result :=
                       characteristics.get_chrstc_attrb_value (v_chrstc_ids (7), chrstc_mars_date.gc_chrstc_period_nextprd, v_chrstc_attrb_value, v_result_msg);

              IF v_result != common.gc_success THEN
                v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
                v_process_state := common.gc_errored;
              END IF;

              -- Get chrstc type id for period
              v_result := characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_period_chrstc_type_id, v_result_msg);

              IF v_result != common.gc_success THEN
                v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
                v_process_state := common.gc_errored;
              END IF;

              -- Get chrstc_id for the NEXTPERIOD attribute value
              v_result := characteristics.get_chrstc_id (v_period_chrstc_type_id, TO_CHAR (v_chrstc_attrb_value), v_nextperiod_chrstc_id, v_result_msg);

              IF v_result != common.gc_success THEN
                v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
                v_process_state := common.gc_errored;
              END IF;

               -- replace the period chrstc id with the new period chrstc id ie the previous period
              -- v_chrstc_ids (v_counter_2) := v_nextperiod_chrstc_id;
              v_chrstc_ids (7) := v_nextperiod_chrstc_id;

              -- Save to SPND_VNDR_PLNT if v_process_state_spnd is processed
              IF v_process_state_spnd IN (common.gc_processed, common.gc_warning) THEN
                v_return := save_value (v_mdl_isct_id_spnd_vnd, v_chrstc_ids, 0, TRUE, v_result_msg);
              END IF;

              -- Save to INVC_QTY_PLNT if v_process_state_qty is processed
              IF v_process_state_qty IN (common.gc_processed, common.gc_warning) THEN
                v_return := save_value (v_mdl_isct_id_invc_qty_plnt, v_chrstc_ids, 0, TRUE, v_result_msg);
              END IF;

              IF v_return != common.gc_success THEN
                v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
                v_process_state := common.gc_errored;
              END IF;
            END LOOP;
          END IF;
        --
        END IF;   
      --
      END IF;

     logit.LOG ('Set the status for the load_invc_data row after processing, v_process_state : ' || v_process_state);

      UPDATE load_invc_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg || v_processing_msg_spnd || v_processing_msg_qty
       WHERE a.batch_id = i_batch_id AND a.line_no = v_invc (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_invc_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_recvd_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return          common.st_result;
    v_result          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_RECVD_BATCH');

    UPDATE load_recvd_data b
       SET b.status = common.gc_validated,
           error_msg = NULL
     WHERE b.batch_id = i_batch_id;

    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_recvd_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_recvd_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                  common.st_result;
    v_result                  common.st_result;
    v_processing_msg          common.st_message_string;
    v_result_msg              common.st_message_string;
    -- Model Intersect IDS
    v_mdl_isct_id_rec_qty_vp  common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity  common.st_id;
    v_chrstc_type_company     common.st_id;
    v_chrstc_type_bus_sgmnt   common.st_id;
    v_chrstc_type_matl        common.st_id;
    v_chrstc_type_plant       common.st_id;
    v_chrstc_type_period      common.st_id;
    v_chrstc_type_vendor      common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id    common.st_id;
    v_chrstc_company_id       common.st_id;
    v_chrstc_bus_sgmnt_id     common.st_id;
    v_chrstc_matl_id          common.st_id;
    v_chrstc_plant_id         common.st_id;
    v_chrstc_period_id        common.st_id;
    v_chrstc_vendor_id        common.st_id;
    -- Characteristic Array
    v_chrstc_ids              common.t_ids;
    -- Other Variables.
    v_counter                 common.st_counter;
    v_process_state           common.st_code;
    v_data_id                 common.st_id;
    v_failure_code            common.st_code;
    v_status                  common.st_code;

        -- select dates for the data to be loaded
    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details          csr_batch_details%ROWTYPE;

    -- select data from the load_recvd_data table
    CURSOR csr_load_recvd_data IS
      SELECT a.batch_id, a.line_no, a.company, bus_sgmnt, a.material, a.plant, a.vendor,
        SUBSTR (a.period, INSTR (a.period, '/') + 5, 4) || SUBSTR (a.period, INSTR (a.period, '/') + 2, 2) mars_period, a.received_qty
      FROM load_recvd_data a
      WHERE a.batch_id = i_batch_id AND a.status = common.gc_validated;

    TYPE t_recvd IS TABLE OF csr_load_recvd_data%ROWTYPE
      INDEX BY common.st_counter;

    v_recvd                   t_recvd;
    v_dataentity              common.st_code;
    v_company                 common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_RECVD_BATCH');
    logit.LOG ('get required chrstc types');
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_vndr, v_chrstc_type_vendor, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('One or more of the characteristic Type lookups for bpip failed or errored.');
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('getting mdl isct set id for ' || bpip_model.gc_mi_rcvd_vndr_plnt || ' : ' || v_mdl_isct_id_rec_qty_vp);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_rcvd_vndr_plnt, v_mdl_isct_id_rec_qty_vp, v_result_msg);
    -- Get the chrstc_id for the 'ACTUALS' DATAENTITY.
    -- This is performed outside the v_recvd loop below as the value is a constant.
    v_return :=
            characteristics.get_chrstc_id (v_chrstc_type_dataentity, finance_characteristics.gc_chrstc_dataentity_actuals, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.create_error_msg ('Characteristic lookups for Data Entity failed or errored');
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the COMPANY chrstc code.
    -- This is performed outside the v_recvd loop below as the value will be the same for the
    -- set of data being processed
    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, rv_batch_details.company, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

    v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Period failed or errored';
      RAISE common.ge_error;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;
    
    -- set the status to deleted for data values for a given chrstcs

    -- Set the status to deleted for all data values with this period and data entity value
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_period_id;
    v_chrstc_ids (3) := v_chrstc_company_id;
    v_chrstc_ids (4) := v_chrstc_bus_sgmnt_id;
    logit.LOG ('Setting data value status to Deleted for Lowest level model intersects');
    v_return := data_values.set_multiple_data_vlu_status (v_mdl_isct_id_rec_qty_vp, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed into memory.');

    OPEN csr_load_recvd_data;

    FETCH csr_load_recvd_data
    BULK COLLECT INTO v_recvd;

    CLOSE csr_load_recvd_data;

    logit.LOG ('Now commence processing any rows that are ready for processing.');
    v_counter := 1;

    WHILE v_counter <= v_recvd.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      -- Start with a default processing state of processed.
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_recvd (v_counter).company IS NULL OR
         v_recvd (v_counter).material IS NULL OR
         v_recvd (v_counter).bus_sgmnt IS NULL OR
         v_recvd (v_counter).plant IS NULL OR
         v_recvd (v_counter).vendor IS NULL OR
         v_recvd (v_counter).mars_period IS NULL THEN
        logit.LOG ('Null chracteristic value.  Row errored. ');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'Characteristic was null. ';
      ELSIF v_recvd (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      ELSE
        --  IF v_process_state = common.gc_success THEN   --2
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_recvd (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_recvd (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return = common.gc_failure THEN
          v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, lads_characteristics.gc_chrstc_na, v_chrstc_matl_id, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || 'Characteristic lookup for Material # failed or errored. ' || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          v_processing_msg := v_processing_msg || 'Could not find Material defaulted to #. ';
          v_process_state := common.gc_warning;
        ELSIF v_return <> common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookup for Material errored. ' || common.nest_err_msg (v_result_msg) || ' ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_plant, v_recvd (v_counter).plant, v_chrstc_plant_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Plant failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        IF v_recvd (v_counter).vendor = lads_characteristics.gc_chrstc_na THEN
          v_processing_msg :=
               v_processing_msg
            || 'Vendor was # this usually is because of an internal transfer and goods receipt. As a result this record has been ignored. '
            || common.nest_err_msg (v_result_msg)
            || ' ';
          v_process_state := common.gc_ignored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_vendor, v_recvd (v_counter).vendor, v_chrstc_vendor_id, v_result_msg);

        IF v_return = common.gc_failure THEN
          v_return := characteristics.get_chrstc_id (v_chrstc_type_vendor, lads_characteristics.gc_chrstc_na, v_chrstc_vendor_id, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || 'Characteristic lookup for Vendor # failed or errored. ' || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;

          v_processing_msg := v_processing_msg || 'Could not find Vendor defaulted to #. ';
          v_process_state := common.gc_warning;
        ELSIF v_return <> common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookup for Vendor errored. ' || common.nest_err_msg (v_result_msg) || ' ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_period, v_recvd (v_counter).mars_period, v_chrstc_period_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Period failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        -- Processing for RECEIVED_QTY mdl isct
        IF v_process_state IN (common.gc_processed, common.gc_warning) THEN   --3
          -- Assign chrstc ids to the array
          v_chrstc_ids.DELETE;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_dataentity_id;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_company_id;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_bus_sgmnt_id;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_matl_id;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_plant_id;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_vendor_id;
          v_chrstc_ids (v_chrstc_ids.COUNT + 1) := v_chrstc_period_id;
          logit.LOG ('Process state is success. Call data_values.get_data_id for RECEIVED_QUANTITY.');
          v_return := save_value (v_mdl_isct_id_rec_qty_vp, v_chrstc_ids, v_recvd (v_counter).received_qty, TRUE, v_result_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
          END IF;
        END IF;   --3
      END IF;   --1

      logit.LOG (' set the status for the load_recvd_data row after processing, v_process_state : ' || v_process_state);

      UPDATE load_recvd_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_recvd (v_counter).line_no;

      --         Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_recvd_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_std_cost_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                common.st_result;
    v_result                common.st_result;
    v_processing_msg        common.st_message_string;
    v_result_msg            common.st_message_string;
    v_planned_price_source  common.st_code;
    v_commit_counter        common.st_counter;

    CURSOR csr_distinct_material IS
      SELECT DISTINCT a.material, a.bus_sgmnt, a.period
      FROM load_std_cost_data a
      WHERE a.batch_id = i_batch_id;

    TYPE t_distinct_material IS TABLE OF csr_distinct_material%ROWTYPE;

    v_distinct_material     t_distinct_material;
    v_material_counter      common.st_counter;

    CURSOR csr_standards (i_material IN common.st_code, i_period IN common.st_code, i_bus_sgmnt IN common.st_code) IS
      SELECT a.planned_price, a.planned_price_date, a.exclude, a.calculated_source, a.batch_id, a.line_no
      FROM load_std_cost_data a
      WHERE a.batch_id = i_batch_id AND a.material = i_material AND a.period = i_period AND a.bus_sgmnt = i_bus_sgmnt
      ORDER BY a.calculated_source DESC;

    TYPE t_standards IS TABLE OF csr_standards%ROWTYPE;

    v_standards             t_standards;
    v_standards_counter     common.st_counter;
  --
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_STD_COST_BATCH');
    v_result := common.gc_success;

    UPDATE load_std_cost_data
       SET error_msg = NULL,
           status = common.gc_validated
     WHERE batch_id = i_batch_id;

    update_bus_sgmnt (i_batch_id);
    validate_matl (i_batch_id);
    COMMIT;
    v_commit_counter := 0;

    -- populate exclude column
    OPEN csr_distinct_material;

    FETCH csr_distinct_material
    BULK COLLECT INTO v_distinct_material;

    CLOSE csr_distinct_material;

    v_material_counter := 1;

    -- loop
    WHILE v_material_counter <= v_distinct_material.COUNT
    LOOP
      -- reset the v_planned_price_source to 'F' ie non L (pLanned)value
      v_planned_price_source := 'F';

      -- open the set of standard costs for the material, period, and business segment
      FOR v_standards IN csr_standards (v_distinct_material (v_material_counter).material,
                                        v_distinct_material (v_material_counter).period,
                                        v_distinct_material (v_material_counter).bus_sgmnt)
      -- loop through this set of data and set the exclude flag
      LOOP
        -- as the set of data is ordered by calculated_source DESC, any pLanned rows will
        -- be validated first

        -- increase the commit counter;
        v_commit_counter := v_commit_counter + 1;

        IF v_standards.calculated_source = 'L' THEN
          v_planned_price_source := 'L';

          UPDATE load_std_cost_data a
             SET a.exclude = common.gc_no
           WHERE a.batch_id = i_batch_id AND a.line_no = v_standards.line_no;
        ELSE
          -- If a row with calculated_source = 'L' has already been processed
          IF v_planned_price_source = 'L' THEN
            UPDATE load_std_cost_data a
               SET a.exclude = common.gc_yes
             WHERE a.batch_id = i_batch_id AND a.line_no = v_standards.line_no;
          ELSE
            -- there are no calculated_source = 'L' rows in this set of data so set exclude to No
            UPDATE load_std_cost_data a
               SET a.exclude = common.gc_no
             WHERE a.batch_id = i_batch_id AND a.line_no = v_standards.line_no;
          END IF;
        END IF;
      END LOOP;

      IF MOD (v_commit_counter, 1000) = 0 THEN
        logit.LOG ('commiting data');
        COMMIT;
      END IF;

      v_material_counter := v_material_counter + 1;
    END LOOP;

    -- Update the batch and set the status to 'ERRORED' for all rows with a calulated source of E
    UPDATE load_std_cost_data a
       SET a.error_msg =
             'The Load Period is prior to the Current Standard Period and either the Previous Standard Period is after the Load Period OR the Previous Standard Period has not been loaded. ',
           a.status = common.gc_errored
     WHERE a.batch_id = i_batch_id AND a.calculated_source = 'E';

    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_std_cost_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_std_cost_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                   common.st_result;
    v_result                   common.st_result;
    v_processing_msg           common.st_message_string;
    v_result_msg               common.st_message_string;
    -- Model Intersect IDS
    v_mi_std_cost              common.st_id;
    v_mi_clsng                 common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity   common.st_id;
    v_chrstc_type_company      common.st_id;
    v_chrstc_type_bus_sgmnt    common.st_id;
    v_chrstc_type_matl         common.st_id;
    v_chrstc_type_period       common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id     common.st_id;
    v_chrstc_period_id         common.st_id;
    v_chrstc_company_id        common.st_id;
    v_chrstc_bus_sgmnt_id      common.st_id;
    v_chrstc_matl_id           common.st_id;
    -- Characteristic Array
    v_chrstc_ids               common.t_ids;
    v_clsng_chrstc_ids         common.t_ids;
    -- Other Variables.
    v_counter                  common.st_counter;
    v_counter_std_cost_data    common.st_counter;
    v_process_state            common.st_code;
    v_cost                     common.st_code;
    v_loading_period           common.st_code;
    v_period_ids               common.t_ids;
    v_period_codes             common.t_codes;
    v_period_counter           common.st_counter;
    v_processing_actuals       BOOLEAN;
    v_process_std_cost         BOOLEAN;
    v_processed_false_counter  common.st_counter;
    v_company_code             common.st_code;
    v_price_count              common.st_counter;
    v_price_change             common.st_code;
    v_price                    common.st_value;

    -- select dates for the data to be loaded
    
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.dataentity, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;
    

    rv_batch_details           csr_batch_details%ROWTYPE;

    -- distinct material,period,bus_segment rows
    /* Add select only Validated status records. David Zhang, Dec, 2009*/
    CURSOR csr_distinct_material IS
      SELECT DISTINCT a.material, a.bus_sgmnt, a.period
      FROM load_std_cost_data a
      WHERE a.batch_id = i_batch_id
        AND a.status = common.gc_validated;

    TYPE t_distinct_material IS TABLE OF csr_distinct_material%ROWTYPE
      INDEX BY common.st_counter;

    v_distinct_material        t_distinct_material;

    -- select data from the load_std_cost_data table
    CURSOR csr_std_cost_data (i_material IN common.st_code, i_period IN common.st_code, i_bus_sgmnt IN common.st_code) IS
      SELECT a.calculated_price, a.exclude, a.batch_id, a.line_no
      FROM load_std_cost_data a
      WHERE a.batch_id = i_batch_id AND a.material = i_material AND a.bus_sgmnt = i_bus_sgmnt AND a.period = i_period AND a.status = common.gc_validated;

    TYPE t_std_cost IS TABLE OF csr_std_cost_data%ROWTYPE
      INDEX BY common.st_counter;

    v_std_cost                 t_std_cost;

    -- select periods to be processed
    CURSOR csr_periods IS
      SELECT DISTINCT period AS period
      FROM load_std_cost_data a
      WHERE a.batch_id = i_batch_id AND a.status = common.gc_validated;

    TYPE t_periods IS TABLE OF csr_periods%ROWTYPE
      INDEX BY common.st_counter;

    v_periods                  t_periods;

    -- LOCAL function
    FUNCTION process_std_cost
      RETURN BOOLEAN IS
      v_saved    BOOLEAN;
      v_data_id  common.st_id;
    BEGIN
      v_saved := TRUE;
      -- Assign the cost to a variable
      --v_price := v_average_price;
      -- Check for closing inventory model intersect data value for the same characteristics MINUS plant.
      -- if get data id not found THEN set  v_saved := false
      v_return := data_values.get_data_id (v_mi_clsng, v_clsng_chrstc_ids, v_data_id, v_result_msg);

      IF v_return <> common.gc_success THEN
        v_saved := FALSE;
        v_processing_msg := v_processing_msg || 'No Closing Inventory to warrant processing of this Cost';
        v_process_state := common.gc_ignored;
      ELSE
        -- Processing for STANDARD_COST mdl isct
        IF v_process_state = common.gc_processed THEN   -- 3
          logit.LOG ('Saving the value into STANDARD COST intersect.');
          -- NOTE : The parameter i_add is set to false meaning the value is always SET and not ADDed
          v_return := save_value (v_mi_std_cost, v_chrstc_ids, v_price, FALSE, v_result_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := v_processing_msg || common.nest_err_msg (v_result_msg) || ' ';
            v_process_state := common.gc_errored;
            v_saved := FALSE;
          END IF;
        END IF;
      END IF;

      RETURN v_saved;
    END process_std_cost;
  --
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_STD_COST_BATCH');
    -- Note the source for STANDARD_COST can be ACTUALS or a Dataentity
    v_processing_actuals := TRUE;
    logit.LOG ('Get the required chrstc types.');
    v_return := characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'One or more of the characteristic Type lookups for bpip failed or errored.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into. - STD COST
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_std_cost);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_std_cost, v_mi_std_cost, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect for std_cost.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersect id for checking against. - CLSNG
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_clsng);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_clsng, v_mi_clsng, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect : CLSNG.';
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the COMPANY and PERIOD chrstc code.
    -- This is performed outside the v_std_cost loop below as the value will be the same for the
    -- set of data being processed.
    logit.LOG ('Load the batch details and find the characteristics required.');

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    logit.LOG ('Now lookup the company.');
    -- assign to variable as it is used in the get_chrstc_id call below and also as part of the key used to
    -- identify the load_std_cost_data row to update after processing each price
    v_company_code := rv_batch_details.company;
    v_return := characteristics.get_chrstc_id (v_chrstc_type_company, v_company_code, v_chrstc_company_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored. ';
      RAISE common.ge_error;
    END IF;

    logit.LOG ('Now lookup the data entity.');
    v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity, rv_batch_details.dataentity, v_chrstc_dataentity_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Data Entity failed or errored. ';
      RAISE common.ge_error;
    END IF;

    -- Now calculate an array of periods that this data will now need to be loaded into.
    logit.LOG ('Now calculate the periods that this data will be loaded into.');
    v_period_counter := 0;
    v_period_ids.DELETE;
    v_period_codes.DELETE;

    IF rv_batch_details.dataentity = finance_characteristics.gc_chrstc_dataentity_actuals THEN
      -- Use the batch loading period as the period that we will be loading this data into.
      v_return := characteristics.get_chrstc_id (v_chrstc_type_period, rv_batch_details.period, v_chrstc_period_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored. ';
        RAISE common.ge_error;
      END IF;

      v_period_counter := v_period_counter + 1;
      v_period_ids (v_period_counter) := v_chrstc_period_id;
      v_period_codes (v_period_counter) := rv_batch_details.period;
    ELSE
      OPEN csr_periods;

      FETCH csr_periods
      BULK COLLECT INTO v_periods;

      CLOSE csr_periods;

      v_period_counter := 1;

      WHILE v_period_counter <= v_periods.COUNT
      LOOP
        v_return := characteristics.get_chrstc_id (v_chrstc_type_period, v_periods (v_period_counter).period, v_chrstc_period_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := 'Characteristic lookups for Period failed or errored. ';
          RAISE common.ge_error;
        END IF;

        v_period_ids (v_period_counter) := v_chrstc_period_id;
        v_period_counter := v_period_counter + 1;
      END LOOP;
    END IF;

    --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;

    -- Now mark any existing records in the system as deleted.
    logit.LOG ('Now mark any existing records in the system as deleted.');
    v_period_counter := 1;
    v_chrstc_ids.DELETE;
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_company_id;
    v_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;

    WHILE v_period_counter <= v_period_ids.COUNT
    LOOP
      v_chrstc_ids (3) := v_period_ids (v_period_counter);
      v_period_counter := v_period_counter + 1;
      -- Set the status to Deleted for ACTUALS dataentity
      v_return := data_values.set_multiple_data_vlu_status (v_mi_std_cost, data_values.gc_data_vlu_status_deleted, v_chrstc_ids, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;
    END LOOP;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed into memory.');

    OPEN csr_distinct_material;

    FETCH csr_distinct_material
    BULK COLLECT INTO v_distinct_material;

    CLOSE csr_distinct_material;

    -- LOOP through the staging table and load the data into the bpip data model
    logit.LOG ('Now process the found records into the model intersect.');
    v_counter := 1;

    -- Initialise the characteristic array.
    WHILE v_counter <= v_distinct_material.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_distinct_material (v_counter).bus_sgmnt IS NULL OR v_distinct_material (v_counter).material IS NULL
         OR v_distinct_material (v_counter).period IS NULL THEN   --1
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'A required characteristic was null. ';
      ELSIF v_distinct_material (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt THEN
        /* Modified log message, David Zhang */
        v_processing_msg := 'Matl:'||v_distinct_material (v_counter).material||' PRD:'||v_distinct_material (v_counter).period||' SEG:'||v_distinct_material (v_counter).bus_sgmnt;
        logit.log('Matl.segment is not in line with batch.segment. Row ignored');
        logit.log (v_processing_msg);
        v_process_state := common.gc_ignored;      
      ELSE
        logit.LOG ('Get the chrstc ids for the set of chrstcs for material : ' || v_distinct_material (v_counter).material);
        v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt, v_distinct_material (v_counter).bus_sgmnt, v_chrstc_bus_sgmnt_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_matl, v_distinct_material (v_counter).material, v_chrstc_matl_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_period, v_distinct_material (v_counter).period, v_chrstc_period_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Period failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        -- Only process if processing state is not errored.
        IF v_process_state = common.gc_processed THEN   --2
          -- initialise v_chrstc_ids array here
          v_chrstc_ids.DELETE;
          v_chrstc_ids (1) := v_chrstc_dataentity_id;
          v_chrstc_ids (2) := v_chrstc_company_id;
          v_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
          v_chrstc_ids (4) := v_chrstc_matl_id;
          v_chrstc_ids (5) := v_chrstc_period_id;
          -- initialise v_clsng_chrstc_ids array here
          v_clsng_chrstc_ids := v_chrstc_ids;
          logit.LOG (   'Processing, v_chrstc_dataentity_id: '
                     || v_chrstc_dataentity_id
                     || ' v_chrstc_company_id '
                     || v_chrstc_company_id
                     || ' v_chrstc_bus_sgmnt_id '
                     || v_chrstc_bus_sgmnt_id
                     || ' v_chrstc_matl_id '
                     || v_chrstc_matl_id
                     || ' v_chrstc_period_id '
                     || v_chrstc_period_id);

          OPEN csr_std_cost_data (v_distinct_material (v_counter).material, v_distinct_material (v_counter).period, v_distinct_material (v_counter).bus_sgmnt);

          FETCH csr_std_cost_data
          BULK COLLECT INTO v_std_cost;

          CLOSE csr_std_cost_data;

          -- LOOP through the staging table and load the data into the bpip data model
          logit.LOG ('Now process the found records into the model intersect.');
          v_counter_std_cost_data := 1;
          v_price_count := 0;
          v_price_change := common.gc_no;
          -- Reset the processing message
          v_processing_msg := '';

          -- Initialise the characteristic array.
          WHILE v_counter_std_cost_data <= v_std_cost.COUNT
          LOOP
            logit.LOG (   'processing for material '
                       || v_distinct_material (v_counter).material
                       || ' exclude : '
                       || v_std_cost (v_counter_std_cost_data).exclude
                       || ' calc price : '
                       || v_std_cost (v_counter_std_cost_data).calculated_price);
            v_process_state := common.gc_processed;
            v_processing_msg := '';

            IF v_std_cost (v_counter_std_cost_data).exclude = common.gc_yes THEN
              v_processing_msg := v_processing_msg || 'Excluded due to Planned price being available. ';
              v_process_state := common.gc_ignored;
            ELSE
              -- if more than 1 price in included in this loop then ensure it is the same
                 -- as the previous price for this material,business segment,period
              IF v_price_count > 0 AND v_price != v_std_cost (v_counter_std_cost_data).calculated_price THEN
                v_price_change := common.gc_yes;
              END IF;

              v_price := v_std_cost (v_counter_std_cost_data).calculated_price;
              v_price_count := v_price_count + 1;
            END IF;

            logit.LOG ('UPDATE load_std_cost_data.');

            UPDATE load_std_cost_data a
               SET a.status = v_process_state,
                   a.error_msg = error_msg || v_processing_msg
             WHERE a.batch_id = i_batch_id AND a.line_no = v_std_cost (v_counter_std_cost_data).line_no;

            -- Increase the counter.
            v_counter_std_cost_data := v_counter_std_cost_data + 1;
          END LOOP;

          v_process_state := common.gc_processed;
          v_processing_msg := '';

          -- if all included rows don't have the same price ie v_price_change=y
          -- the error all rows on this key
          IF v_price_change = common.gc_yes THEN
            v_processing_msg := v_processing_msg || 'Different prices for the same material and period and business segment. ';
            v_process_state := common.gc_errored;
            logit.LOG ('Set the status for the LOAD_STD_COST_DATA where there are different prices on the same key.');

            UPDATE load_std_cost_data a
               SET a.status = v_process_state,
                   a.error_msg = error_msg || v_processing_msg
             WHERE a.batch_id = i_batch_id AND
                   a.company = v_company_code AND
                   a.bus_sgmnt = v_distinct_material (v_counter).bus_sgmnt AND
                   a.material = v_distinct_material (v_counter).material AND
                   a.period = v_distinct_material (v_counter).period;
          END IF;

          --end  processing for each price with the distinct material set
          -- Initialise variable
          v_process_std_cost := TRUE;

          IF v_price_count > 0 THEN
                  -- Now perform the require processing here for each standard cost.
                  -- Maintain a variable to check whether all calls to the local function PROCESS_STD_COST
            -- return false
                  -- If this is true then set procesing_state to ignored
            logit.LOG ('call local function process_std_cost.');
            --v_processed_false_counter := 0;
            v_process_std_cost := process_std_cost;
          END IF;

          IF v_process_std_cost = FALSE THEN
            logit.LOG
                   ('Set the status for the LOAD_STD_COST_DATA where there No Closing Inventory to warrant processing or error during saving of standard cost.');

            UPDATE load_std_cost_data a
               SET a.status = v_process_state,
                   a.error_msg = error_msg || v_processing_msg
             WHERE a.batch_id = i_batch_id AND
                   a.company = v_company_code AND
                   a.bus_sgmnt = v_distinct_material (v_counter).bus_sgmnt AND
                   a.material = v_distinct_material (v_counter).material AND
                   a.period = v_distinct_material (v_counter).period;
          END IF;
        --
        ELSE
          UPDATE load_std_cost_data a
             SET a.status = v_process_state,
                 a.error_msg = error_msg || v_processing_msg
           WHERE a.batch_id = i_batch_id AND
                 a.company = v_company_code AND
                 a.bus_sgmnt = v_distinct_material (v_counter).bus_sgmnt AND
                 a.material = v_distinct_material (v_counter).material AND
                 a.period = v_distinct_material (v_counter).period;
        END IF;   --   2
      --
      END IF;   --1

      IF MOD (v_counter, common.gc_common_commit_point) = 0 THEN
        logit.LOG ('commiting data');
        COMMIT;
      END IF;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_std_cost_batch;

  ---------------------------------------------------------------------------------
  FUNCTION validate_clsng_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
  BEGIN
    logit.enter_method (pc_package_name, 'VALIDATE_CLSNG_INV_BATCH');
    logit.LOG ('This function returns success and nothing else as the data is sourced from the BPIP model and therefore does not require validation');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END validate_clsng_inv_batch;

  ---------------------------------------------------------------------------------
  FUNCTION process_clsng_inv_batch (i_batch_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_return                     common.st_result;
    v_result                     common.st_result;
    v_processing_msg             common.st_message_string;
    v_result_msg                 common.st_message_string;
    -- Model Intersect IDS
    v_mi_other                   common.st_id;
    v_mi_clsng                   common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_id_dataentity  common.st_id;
    v_chrstc_type_id_company     common.st_id;
    v_chrstc_type_id_bus_sgmnt   common.st_id;
    v_chrstc_type_id_matl        common.st_id;
    v_chrstc_type_id_plant       common.st_id;
    v_chrstc_type_id_period      common.st_id;
    v_chrstc_type_id_vendor      common.st_id;
    -- Characteristic IDs
    v_chrstc_id_dataentity       common.st_id;
    v_chrstc_id_company          common.st_id;
    v_chrstc_id_bus_sgmnt        common.st_id;
    v_chrstc_id_matl             common.st_id;
    v_chrstc_id_plant            common.st_id;
    v_chrstc_id_period           common.st_id;
    v_chrstc_id_vendor           common.st_id;
    -- Characteristic Array
    v_chrstc_ids                 common.t_ids;
    v_clsng_chrstc_ids           common.t_ids;
    -- Other Variables.
    v_counter                    common.st_counter;
    v_process_state              common.st_code;
    v_cost                       common.st_code;
    v_loading_period             common.st_code;
    v_dataentity_fromperiod      common.st_code;
    v_dataentity_toperiod        common.st_code;
    v_current_period             common.st_code;
    v_period_ids                 common.t_ids;
    v_period_counter             common.st_counter;
    v_period_codes               common.t_codes;
    v_processing_actuals         BOOLEAN;
    v_process_clsng_inv          BOOLEAN;
    v_processed_false_counter    common.st_counter;
    v_company_code               common.st_code;
    e_lock_error                 EXCEPTION;   -- failed to get exclusive lock

    -- select dates for the data to be loaded
    CURSOR csr_batch_details IS
      SELECT a.company, a.period, a.dataentity, a.bus_sgmnt
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    rv_batch_details             csr_batch_details%ROWTYPE;

       -- select data from the load_clsng_inv_data table
    -- note status is loaded and not validated as validate_clsng_inv_batch does nothing currently
    CURSOR csr_clsng_inv_data IS
      SELECT a.batch_id, a.line_no, a.bus_sgmnt, a.material
      FROM load_clsng_inv_data a
      WHERE a.batch_id = i_batch_id AND a.status = common.gc_loaded;

    TYPE t_clsng_inv IS TABLE OF csr_clsng_inv_data%ROWTYPE
      INDEX BY common.st_counter;

    v_clsng_inv                  t_clsng_inv;

    -- LOCAL function
    FUNCTION process_clsng_inv (i_mdl_isct_set_id IN common.st_id, i_chrstc_ids IN common.t_ids)
      RETURN BOOLEAN IS
      v_price           common.st_value;
      v_saved           BOOLEAN;
      v_data_id         common.st_id;
      v_failure_code    common.st_code;
      v_return_msg      common.st_message_string;
      v_processing_msg  common.st_message_string;
    BEGIN
      v_saved := TRUE;

      -- Assign the cost to a variable
           -- if get data id  found THEN set  v_saved := false
      --get model intersect lock.
      IF data_values.request_data_vlu_lock (i_mdl_isct_set_id, v_return_msg) != common.gc_success THEN
        RAISE e_lock_error;
      END IF;

      v_return := data_values.get_data_id (i_mdl_isct_set_id, i_chrstc_ids, v_data_id, v_result_msg);

      IF v_return = common.gc_success THEN
        v_saved := FALSE;
        logit.LOG ('Triggering data change event');
        v_return := data_values.data_change_event (v_data_id, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := 'Could not call data_change_event : OTHER.';
          RAISE common.ge_error;
        END IF;
      ELSIF v_return = common.gc_failure THEN
        logit.LOG ('Data value did not exist.  Creating.');
        v_return := data_values.create_data_vlu (i_mdl_isct_set_id, i_chrstc_ids, v_data_id, v_result_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Unable to create data id. ' || common.nest_err_msg (v_result_msg);
          RAISE common.ge_error;
        END IF;
      ELSE
        v_processing_msg := 'Unable to find data id. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_error;
      END IF;

      IF data_values.release_data_vlu_lock (i_mdl_isct_set_id, v_return_msg) != common.gc_success THEN
        RAISE e_lock_error;
      END IF;

      RETURN v_saved;
    EXCEPTION
      WHEN e_lock_error THEN
        o_result_msg := common.create_failure_msg ('Lock Error for Mdl Isct : ' || i_mdl_isct_set_id || ' ' || v_return_msg);
        logit.LOG (o_result_msg);
        logit.leave_method;
      WHEN OTHERS THEN
        IF data_values.release_data_vlu_lock (i_mdl_isct_set_id, v_return_msg) != common.gc_success THEN
          RAISE e_lock_error;
        END IF;

        RAISE;
    END process_clsng_inv;
  --
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_CLSNG_INV_BATCH');
    -- Note the source for STANDARD_COST can be ACTUALS or a Dataentity
    v_processing_actuals := TRUE;
    logit.LOG ('Get the required chrstc types.');
    v_return := characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_id_dataentity, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_id_company, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_id_bus_sgmnt, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_id_matl, v_result_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_id_period, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'One or more of the characteristic Type lookups for bpip failed or errored.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into : OTHER
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_other);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_other, v_mi_other, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect : OTHER.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into : CLSNG
    logit.LOG ('Getting mdl isct set id for ' || bpip_model.gc_mi_clsng);
    v_return := models.get_mdl_isct_set_id (bpip_model.gc_mi_clsng, v_mi_clsng, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect : CLSNG.';
      RAISE common.ge_error;
    END IF;

    -- Get the chrstc_id for the COMPANY and PERIOD and DATAENTITY chrstc code.
    -- This is performed outside the v_clsng_inv loop below as the value will be the same for the
    -- set of data being processed
    logit.LOG ('Load the batch details and find the characteristics required.');

    OPEN csr_batch_details;

    FETCH csr_batch_details
    INTO rv_batch_details;

    IF csr_batch_details%NOTFOUND THEN
      v_processing_msg := 'Unable to find batch header record details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_batch_details;

    logit.LOG ('Now lookup the company.');
    -- identify the load_clsng_inv_data row to update
    v_company_code := rv_batch_details.company;
    v_return := characteristics.get_chrstc_id (v_chrstc_type_id_company, v_company_code, v_chrstc_id_company, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Company failed or errored';
      RAISE common.ge_error;
    END IF;

   --  Get characteristic ID for business segment
   v_return := characteristics.get_chrstc_id (v_chrstc_type_id_bus_sgmnt, rv_batch_details.bus_sgmnt, v_chrstc_id_bus_sgmnt, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Business Segment failed or errored';
      RAISE common.ge_error;
    END IF;


    logit.LOG ('Now lookup the data entity.');
    v_return := characteristics.get_chrstc_id (v_chrstc_type_id_dataentity, rv_batch_details.dataentity, v_chrstc_id_dataentity, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic lookups for Data Entity failed or errored';
      RAISE common.ge_error;
    END IF;

     -- Now calculate an array of periods that this data will now need to be loaded into.
    logit.LOG ('Now calculate the periods that this data will be loaded into.');
    v_period_counter := 0;
    v_period_ids.DELETE;
    v_period_codes.DELETE;

    IF rv_batch_details.dataentity = finance_characteristics.gc_chrstc_dataentity_actuals THEN
      -- Use the batch loading period as the period that we will be loading this data into.
      v_return := characteristics.get_chrstc_id (v_chrstc_type_id_period, rv_batch_details.period, v_chrstc_id_period, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored';
        RAISE common.ge_error;
      END IF;

      v_period_counter := v_period_counter + 1;
      v_period_ids (v_period_counter) := v_chrstc_id_period;
      v_period_codes (v_period_counter) := rv_batch_details.period;
    ELSE
      -- get the fromperiod and toperiod characteristics
      -- Get the chrstc attribute value for FROMPERIOD of this chrstc id
      v_result :=
        characteristics.get_chrstc_attrb_value (v_chrstc_id_dataentity,
                                                finance_characteristics.gc_chrstc_dataentity_fromprd,
                                                v_dataentity_fromperiod,
                                                v_result_msg);

      IF v_result != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      -- Get the chrstc attribute value for TOPERIOD of this chrstc id
      v_result :=
        characteristics.get_chrstc_attrb_value (v_chrstc_id_dataentity, finance_characteristics.gc_chrstc_dataentity_toprd, v_dataentity_toperiod, v_result_msg);

      IF v_result != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      -- Now iterate though the periods that we are loading data into and allocate the qty per day into the days of the plan we are loading data into.
      logit.LOG ('Data Entity : ' || rv_batch_details.dataentity || ' From Period : ' || v_dataentity_fromperiod || ' To Period : ' || v_dataentity_toperiod);
      v_current_period := v_dataentity_fromperiod;
      v_period_counter := 0;
      -- Period collection.
      logit.LOG ('Now create the data entity period collection.');

      LOOP
        -- Now lookup the period characteristic id.
        v_return := characteristics.get_chrstc_id (v_chrstc_type_id_period, v_current_period, v_chrstc_id_period, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := 'Characteristic lookups for Period failed or errored';
          RAISE common.ge_error;
        END IF;

        v_period_counter := v_period_counter + 1;
        v_period_ids (v_period_counter) := v_chrstc_id_period;
        v_period_codes (v_period_counter) := v_current_period;

        -- Now increment the period counter and see if we can move onto the next period.
        BEGIN
          v_current_period := TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_current_period), 1) );
        EXCEPTION
          WHEN OTHERS THEN
            v_processing_msg := 'Failed to increment the current period during the period array processing.';
            RAISE common.ge_error;
        END;

        EXIT WHEN v_current_period > v_dataentity_toperiod;
      END LOOP;
    END IF;

    -- Now load the data for the processing into a collection.
    logit.LOG ('Load the batch being processed into memory.');

    OPEN csr_clsng_inv_data;

    FETCH csr_clsng_inv_data
    BULK COLLECT INTO v_clsng_inv;

    CLOSE csr_clsng_inv_data;

    -- LOOP through the staging table and load the data into the bpip data model
    logit.LOG ('Now process the found records into the model intersect.');
    v_counter := 1;

    -- Initialise the characteristic array.
    WHILE v_counter <= v_clsng_inv.COUNT
    LOOP
      logit.LOG ('In loop to insert data into model');
      v_process_state := common.gc_processed;
      v_processing_msg := '';

      -- If any chrstcs are null then mark row as ERRORED
      IF v_clsng_inv (v_counter).bus_sgmnt IS NULL OR v_clsng_inv (v_counter).material IS NULL THEN
        logit.LOG ('A required characteristic was NULL.');
        v_process_state := common.gc_errored;
        v_processing_msg := v_processing_msg || 'A required characteristic was null. ';
      ELSIF v_clsng_inv (v_counter).bus_sgmnt <> rv_batch_details.bus_sgmnt then
        logit.log ('Business Segment. Row ignored. ');
        v_process_state := common.gc_ignored;      
        v_processing_msg := v_processing_msg || 'Business Segment';
      --1
      ELSE
        -- IF v_process_state = common.gc_success THEN   --2
        logit.LOG ('Get the chrstc ids for the set of chrstcs.');
        v_return := characteristics.get_chrstc_id (v_chrstc_type_id_bus_sgmnt, v_clsng_inv (v_counter).bus_sgmnt, v_chrstc_id_bus_sgmnt, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Business Segment failed or errored. ';
          v_process_state := common.gc_errored;
        END IF;

        v_return := characteristics.get_chrstc_id (v_chrstc_type_id_matl, v_clsng_inv (v_counter).material, v_chrstc_id_matl, v_result_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := v_processing_msg || 'Characteristic lookups for Material failed or errored';
          v_process_state := common.gc_errored;
        END IF;

        -- for each detail row returned from LOAD_CLSNG_INV_DATA, loop through all periods that require checking

        -- initialise v_chrstc_ids array here
        v_chrstc_ids.DELETE;
        v_chrstc_ids (1) := v_chrstc_id_dataentity;
        v_chrstc_ids (2) := v_chrstc_id_company;
        v_chrstc_ids (3) := v_chrstc_id_bus_sgmnt;
        v_chrstc_ids (4) := v_chrstc_id_matl;
        -- Now process each period and add the relevant contract information.
        v_period_counter := 1;

        LOOP
          -- Exit loop when we have finished processing all the periods.
          EXIT WHEN v_period_counter > v_period_ids.COUNT;
          -- Update characteristics list.
          v_chrstc_ids (5) := v_period_ids (v_period_counter);

          -- Processing for CLSNG and OTHER mdl iscts
          IF v_process_state = common.gc_processed THEN
            v_process_clsng_inv := process_clsng_inv (v_mi_clsng, v_chrstc_ids);

            -- Load for CLSNG
            IF v_process_clsng_inv = TRUE THEN
              logit.LOG (   'CLSNG value created for '
                         || rv_batch_details.dataentity
                         || ', '
                         || rv_batch_details.company
                         || ', '
                         || v_clsng_inv (v_counter).bus_sgmnt
                         || ', '
                         || v_clsng_inv (v_counter).material
                         || ', '
                         || v_period_codes (v_period_counter) );
            END IF;

            -- load for OTHER
            v_process_clsng_inv := process_clsng_inv (v_mi_other, v_chrstc_ids);

            -- If v_process_clsng_inv return false then increase the count of number of times False is returned
            IF v_process_clsng_inv = TRUE THEN
              logit.LOG (   'OTHER value created for '
                         || rv_batch_details.dataentity
                         || ', '
                         || rv_batch_details.company
                         || ', '
                         || v_clsng_inv (v_counter).bus_sgmnt
                         || ', '
                         || v_clsng_inv (v_counter).material
                         || ', '
                         || v_period_codes (v_period_counter) );
            END IF;
          END IF;

          -- Increment the period counter.
          v_period_counter := v_period_counter + 1;
        END LOOP;
      END IF;   --1

      logit.LOG ('Set the status for the LOAD_CLSNG_INV_DATA row after processing.');

         -- As the data to be loaded is averaged, there is no concept of a line number here
      -- so update all rows that are grouped for a given average row
      -- i.e. for company,bus_sgmnt,material,period for a batch_id.
      UPDATE load_clsng_inv_data a
         SET a.status = v_process_state,
             a.error_msg = error_msg || v_processing_msg
       WHERE a.batch_id = i_batch_id AND a.line_no = v_clsng_inv (v_counter).line_no;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    --Commit all changes
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END process_clsng_inv_batch;

  ---------------------------------------------------------------------------------
  FUNCTION get_batch_type (i_batch_id IN common.st_id)
    RETURN common.st_code IS
    CURSOR csr_batch_type IS
      SELECT a.batch_type_code
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    v_batch_type_code  common.st_code;
  BEGIN
    OPEN csr_batch_type;

    FETCH csr_batch_type
    INTO v_batch_type_code;

    CLOSE csr_batch_type;

    RETURN v_batch_type_code;
  END get_batch_type;

  FUNCTION get_batch_loaded_by_id (i_batch_id IN common.st_id)
    RETURN common.st_id IS
    CURSOR csr_batch_type IS
      SELECT a.loaded_by
      FROM load_bpip_batch a
      WHERE a.batch_id = i_batch_id;

    v_batch_loaded_by_id  common.st_id;
  BEGIN
    OPEN csr_batch_type;

    FETCH csr_batch_type
    INTO v_batch_loaded_by_id;

    CLOSE csr_batch_type;

    RETURN v_batch_loaded_by_id;
  END get_batch_loaded_by_id;

  PROCEDURE delete_old_batches IS
    v_return        common.st_result;
    v_days_history  common.st_value;
    v_result_msg    common.st_message_string;
    v_old_batches   common.t_ids;
    -- used to bulk collect batch id into, loop and purge.
    v_counter       common.st_counter;

    -- main cursor list of batches to delete
    CURSOR csr_batches (i_days_history common.st_value) IS
      SELECT batch_id
      FROM load_bpip_batch
      WHERE NVL (process_end_time, load_start_time) < SYSDATE - i_days_history;
  BEGIN
    -- Now delete old batches.
    logit.enter_method (pc_package_name, 'DELETE_OLD_BATCHES');
    v_return := system_params.get_parameter_value (bpip_system.gc_system_code, pc_param_bch_day_hist_code, v_days_history, v_result_msg);

    IF v_return != common.gc_success THEN
      logit.LOG ('Unable to find parameter, using default.');
      v_days_history := pc_param_bch_default_day_hist;
    END IF;

    logit.LOG ('Start deletes');

    -- retrieve batch id from the database and store in array.
    OPEN csr_batches (v_days_history);

    FETCH csr_batches
    BULK COLLECT INTO v_old_batches;

    CLOSE csr_batches;

    logit.LOG ('Now start deleting any old batches older than ' || TO_CHAR (v_days_history) || ' days');
    v_counter := 1;

    -- start of main loop, delete batches stores in array,
    WHILE v_counter <= v_old_batches.COUNT
    LOOP
      logit.LOG ('Delete batch:' || TO_CHAR (v_old_batches (v_counter) ) );
      logit.LOG ('Deleting from :load_inv_data');

      LOOP
        DELETE FROM load_inv_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_mrp_data');

      LOOP
        DELETE FROM load_mrp_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_ppv_data');

      LOOP
        DELETE FROM load_ppv_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_cntct_data');

      LOOP
        DELETE FROM load_cntct_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_safty_stk_data');

      LOOP
        DELETE FROM load_safty_stk_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_std_cost_data');

      LOOP
        DELETE FROM load_std_cost_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_mvmt_data');

      LOOP
        DELETE FROM load_mvmt_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_invc_data');

      LOOP
        DELETE FROM load_invc_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_recvd_data');

      LOOP
        DELETE FROM load_recvd_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_clsng_inv_data');

      LOOP
        DELETE FROM load_clsng_inv_data
              WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('Deleting from :load_bpip_batch');
      logit.LOG ('Batch ID:' || v_old_batches (v_counter));

      DELETE FROM load_bpip_batch
            WHERE batch_id = v_old_batches (v_counter) AND ROWNUM < common.gc_common_commit_point;

      COMMIT;
      v_counter := v_counter + 1;
      logit.LOG ('Batch deleted');
    END LOOP;

    logit.LOG ('Finish deletes');
    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      v_result_msg := common.create_sql_error_msg;
      logit.log_error (v_result_msg);
      ROLLBACK;
      logit.leave_method;
  END delete_old_batches;
END bpip_data_load;
/
 
