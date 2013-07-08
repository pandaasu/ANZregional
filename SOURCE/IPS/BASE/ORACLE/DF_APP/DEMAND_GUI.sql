create or replace 
PACKAGE        demand_gui AS
  /******************************************************************************
   NAME:       DEMAND_GUI
   PURPOSE:    This package is used to support all the Demand Financials GUI
               functionality

  ******************************************************************************/

  /******************************************************************************
  ****   DEMAND GROUP MANAGEMENT FUNCTIONS                                   ****
  ******************************************************************************/

  /*******************************************************************************
   NAME:      RUN_BATCH
   PURPOSE:   Used to submit a batch run for processing.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   19/05/2006 Nick Bates           Created this procedure.
  1.1   30/05/2007 Chris Horn           Added the refresh option.

   NOTES:
   Used to restart a batch run after failire return nothing, results sent via email
  ********************************************************************************/
  PROCEDURE run_batch (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_refresh IN common.st_status);

  /*******************************************************************************
    NAME:      GET_DMND_GRP_CODES
    PURPOSE:   This procedure will return all demand group codes from dmnd_grp as a
               ref cursor.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   03/05/2006 Sal Sanghera         Created this procedure.

    NOTES:
    Used in the Demand Financials GUI to populate the Demand Group Codes list item
   ********************************************************************************/
  PROCEDURE get_dmnd_grp_codes (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_dmnd_grp_codes OUT common.t_ref_cursor);

   /*******************************************************************************
   NAME:       GET_RETUN_FILE_LIST
   PURPOSE:    This function get a list of files in errord to be reprocessed
               File status definitions , LOADED but not yet processed,
               ERRORED = loaded but fatal error in content , PRE-LOADED not yet loaded
               IGNORED , ignored by next batch run.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   15/05/2006 Nick Bates           Added this header

   NOTES:
  ********************************************************************************/
  PROCEDURE get_file_list (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_file_list OUT common.t_ref_cursor);

   /*******************************************************************************
   NAME:       SET_FILE_STATUS
   PURPOSE:    This function can be used to set the state of a file to loaded or ignored.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   15/05/2006 Nick Bates           Added this header

   NOTES:
  ********************************************************************************/
  PROCEDURE set_file_status (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_file_id IN common.st_id, i_status IN common.st_code);

  /*******************************************************************************
   NAME:      GET_COUNTRIES
   PURPOSE:   This procedure will return all country codes and country names from cntry as a
              ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera        Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Country list item with the country name
  ********************************************************************************/
  PROCEDURE get_countries (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_cntry_codes OUT common.t_ref_cursor);

  /*******************************************************************************
   NAME:      GET_DMND_GRP_TYPES
   PURPOSE:   This procedure will return all demand group types from dmnd_grp_type as a
              ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Demand Group Type list item
   with the demand group types.
  ********************************************************************************/
  PROCEDURE get_dmnd_grp_types (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_dmnd_grp_types OUT common.t_ref_cursor);

  /*******************************************************************************
   NAME:      GET_ACC_ASSGNMTS
   PURPOSE:   This procedure will return all account assignment names from accnt_assign as a
              ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Account Assignment Type list
   item with all account assignment names.
  ********************************************************************************/
  PROCEDURE get_accnt_assgnmts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_accnt_assnmts OUT common.t_ref_cursor);

  /*******************************************************************************
   NAME:      GET_DMND_GRP_RECORD
   PURPOSE:   This procedure will return the demand_grp record based on the dmnd_grp_code
              passed in.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   04/05/2006 Chris Horn           Update the procedure prototype.

   NOTES:
   Used in the Demand Financials GUI to Populate all the items on the Demand Groups
   tab of the Data Maintenance form.
  ********************************************************************************/
  PROCEDURE get_dmnd_grp_record (
    o_result              OUT     common.st_result,
    o_result_msg          OUT     common.st_message_string,
    i_dmnd_grp_code       IN      dmnd_grp.dmnd_grp_code%TYPE,
    o_dmnd_grp_name       OUT     dmnd_grp.dmnd_grp_name%TYPE,
    o_cntry_code          OUT     dmnd_cntry.cntry_code%TYPE,
    o_dmnd_grp_type_code  OUT     dmnd_grp_type.dmnd_grp_type_code%TYPE,
    o_dmnd_plng_node      OUT     dmnd_grp.dmnd_plng_node%TYPE,
    o_sply_whse_lst       OUT     dmnd_grp.sply_whse_lst%TYPE);

  /*******************************************************************************
   NAME:      GET_DMND_GRP_ORGS
   PURPOSE:   This procedure will return the demand_grp_org records as a ref cursor
              based on the dmnd_grp_code passed in.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   04/05/2006 Chris Horn           Update the procedure prototype.

   NOTES:
   Used in the Demand Financials GUI to Populate all the items on the Demand Groups Org
   tab of the Data Maintenance form.
  ********************************************************************************/
  PROCEDURE get_dmnd_grp_orgs (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_dmnd_grp_code  IN      dmnd_grp.dmnd_grp_code%TYPE,
    o_dmnd_grp_org   OUT     common.t_ref_cursor);

  /*******************************************************************************
   NAME:      GET_DMND_GRP_ORG
   PURPOSE:   This procedure will return the demand_grp_org record
              based on the dmnd_grp_org_id passed in.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   22/02/2008 Mary Ahyick          Modified procedure to includ cust_hrrchy

   NOTES:
   Used in the Demand Financials GUI to Populate all the items on the Demand Groups Org
   tab of the Data Maintenance form.
  ********************************************************************************/
  PROCEDURE get_dmnd_grp_org_record (
    o_result               OUT     common.st_result,
    o_result_msg           OUT     common.st_message_string,
    i_dmnd_grp_org_id      IN      dmnd_grp_org.dmnd_grp_org_id%TYPE,
    o_bus_sgmnt_code       OUT     dmnd_grp_org.bus_sgmnt_code%TYPE,
    o_source_code          OUT     dmnd_grp_org.source_code%TYPE,
    o_sales_org            OUT     dmnd_grp_org.sales_org%TYPE,
    o_currcy_code          OUT     dmnd_grp_org.currcy_code%TYPE,
    o_distbn_chnl          OUT     dmnd_grp_org.distbn_chnl%TYPE,
    o_acct_assign_code     OUT     dmnd_acct_assign.acct_assign_code%TYPE,
    o_cust_div             OUT     dmnd_grp_org.cust_div%TYPE,
    o_ship_to_code         OUT     dmnd_grp_org.ship_to_code%TYPE,
    o_bill_to_code         OUT     dmnd_grp_org.bill_to_code%TYPE,
    o_sold_to_cmpny_code   OUT     dmnd_grp_org.sold_to_cmpny_code%TYPE,
    o_cust_hrrchy_code     OUT     dmnd_grp_org.cust_hrrchy_code%TYPE,
    o_invc_prty            OUT     dmnd_grp_org.invc_prty%TYPE,
    o_pricing_formula      OUT     dmnd_grp_org.pricing_formula%TYPE,
    o_profit_centre        OUT     dmnd_grp_org.profit_centre%TYPE,
    o_account              OUT     dmnd_grp_org.ACCOUNT%TYPE,
    o_fpps_gsv_line_item   OUT     dmnd_grp_org.fpps_gsv_line_item%TYPE,
    o_fpps_qty_line_item   OUT     dmnd_grp_org.fpps_qty_line_item%TYPE,
    o_fpps_cust            OUT     dmnd_grp_org.fpps_cust%TYPE,
    o_fpps_dest            OUT     dmnd_grp_org.fpps_dest%TYPE,
    o_fpps_moe             OUT     dmnd_grp_org.fpps_moe%TYPE,
    o_pos_frmt_grpng_code  OUT     dmnd_grp_org.pos_frmt_grpng_code%TYPE,
    o_mltplr_code          OUT     dmnd_grp_org.mltplr_code%TYPE,
    o_mltplr_value         OUT     dmnd_grp_org.mltplr_value%TYPE);

  /*******************************************************************************
   NAME:      UPDATE_DMND_GRP
   PURPOSE:   This procedure will Save (insert or update based upon existance
              of the key column in the dmnd_grp table) the dmnd_grp row passed from
              the application.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   04/05/2006 Chris Horn           Update the procedure prototype.
   1.2   05/05/2006 Nick Bates           Wrote procedure.

   NOTES:
   Used in the Demand Financials GUI.
   Will call demand_forecast.? for functionality
  ********************************************************************************/
  PROCEDURE update_dmnd_grp (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_dmnd_grp_code   IN      dmnd_grp.dmnd_grp_code%TYPE,
    i_dmnd_grp_name   IN      dmnd_grp.dmnd_grp_name%TYPE,
    i_cntry           IN      dmnd_cntry.cntry_code%TYPE,
    i_dmnd_grp_type   IN      dmnd_grp_type.dmnd_grp_type_code%TYPE,
    i_dmnd_plng_node  IN      dmnd_grp.dmnd_plng_node%TYPE,
    i_sply_whse_lst   IN      dmnd_grp.sply_whse_lst%TYPE);

  /*******************************************************************************

  /*******************************************************************************
   NAME:      UPDATE_DMND_GRP_ORG
   PURPOSE:   This procedure will Save (insert or update based upon existance
              of the key column in the dmnd_grp_org table) the dmnd_grp_org row passed from
              the application.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   04/05/2006 Chris Horn           Update the procedure prototype.
   1.2   05/05/2006 Nick Bates           Wrote procedure.

   NOTES:
   Used in the Demand Financials GUI.
   Will call demand_forecast.? for functionality
  ********************************************************************************/
  PROCEDURE update_dmnd_grp_org (
    o_result               OUT     common.st_result,
    o_result_msg           OUT     common.st_message_string,
    i_dmnd_grp_code        IN      dmnd_grp.dmnd_grp_code%TYPE,
    i_bus_sgmnt_code       IN      dmnd_grp_org.bus_sgmnt_code%TYPE,
    i_source_code          IN      dmnd_grp_org.source_code%TYPE,
    i_sales_org            IN      dmnd_grp_org.sales_org%TYPE,
    i_currcy_code          IN      dmnd_grp_org.currcy_code%TYPE,
    i_distbn_chnl          IN      dmnd_grp_org.distbn_chnl%TYPE,
    i_acct_assign          IN      dmnd_acct_assign.acct_assign_code%TYPE,
    i_cust_div             IN      dmnd_grp_org.cust_div%TYPE,
    i_ship_to_code         IN      dmnd_grp_org.ship_to_code%TYPE,
    i_bill_to_code         IN      dmnd_grp_org.bill_to_code%TYPE,
    i_sold_to_cmpny_code   IN      dmnd_grp_org.sold_to_cmpny_code%TYPE,
    i_cust_hrrchy_code     IN      dmnd_grp_org.cust_hrrchy_code%TYPE,
    i_pricing_formula      IN      dmnd_grp_org.pricing_formula%TYPE,
    i_profit_centre        IN      dmnd_grp_org.profit_centre%TYPE,
    i_account              IN      dmnd_grp_org.ACCOUNT%TYPE,
    i_fpps_gsv_line_item   IN      dmnd_grp_org.fpps_gsv_line_item%TYPE,
    i_fpps_qty_line_item   IN      dmnd_grp_org.fpps_qty_line_item%TYPE,
    i_fpps_cust            IN      dmnd_grp_org.fpps_cust%TYPE,
    i_fpps_dest            IN      dmnd_grp_org.fpps_dest%TYPE,
    i_invc_prty            IN      dmnd_grp_org.invc_prty%TYPE,
    i_fpps_moe             IN      dmnd_grp_org.fpps_moe%TYPE,
    i_pos_frmt_grpng_code  IN      dmnd_grp_org.pos_frmt_grpng_code%TYPE,
    i_mltplr_code          IN      dmnd_grp_org.mltplr_code%TYPE,
    i_mltplr_value         IN      dmnd_grp_org.mltplr_value%TYPE);

  /*******************************************************************************
   NAME:      DELETE_DMND_GRP
   PURPOSE:   This procedure will delete the dmnd_grp row based on the dmnd_grp_code
              passed in.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   04/05/2006 Chris Horn           Update the procedure prototype.

   NOTES:
   Used in the Demand Financials GUI.
   Will call demand_forecast. for functionality
  ********************************************************************************/
  PROCEDURE delete_dmnd_grp (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_dmnd_grp_code IN dmnd_grp.dmnd_grp_code%TYPE);

  /*******************************************************************************
    NAME:      DELETE_DMND_GRP_ORG
    PURPOSE:   This procedure will delete the dmnd_grp_org row based on the dmnd_grp_org_id
               passed in.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   03/05/2006 Sal Sanghera         Created this procedure.
    1.1   04/05/2006 Chris Horn           Update the procedure prototype.

    NOTES:
    Used in the Demand Financials GUI.
    Will call demand_forecast. for functionality
   ********************************************************************************/
  PROCEDURE delete_dmnd_grp_org (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_dmnd_grp_code   IN      dmnd_grp.dmnd_grp_code%TYPE,
    i_bus_sgmnt_code  IN      dmnd_grp_org.bus_sgmnt_code%TYPE,
    i_source_code     IN      dmnd_grp_org.source_code%TYPE,
    i_sales_org       IN      dmnd_grp_org.sales_org%TYPE,
    i_mltplr_code     IN      dmnd_grp_org.mltplr_code%TYPE);

  /******************************************************************************
  ****   FORECAST MANAGEMENT FUNCTIONS                                       ****
  ******************************************************************************/

  /*******************************************************************************
   NAME:      GET_FORECASTS
   PURPOSE:   This procedure will return all forecast id rows from fcst as a ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera        Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Forecast list
  ********************************************************************************/
  PROCEDURE get_forecasts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_forecasts OUT common.t_ref_cursor);

  /*******************************************************************************
   NAME:      GET_DRAFT_FORECASTS
   PURPOSE:   This procedure will return all draft forecast id rows from fcst as a ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   08/06/2013 Chris Horn           Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Draft Forecast list
  ********************************************************************************/
  PROCEDURE get_draft_forecasts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_forecasts OUT common.t_ref_cursor);


   /*******************************************************************************
   NAME:      GET_FORECAST_RECORD
   PURPOSE:   This procedure will return the forecast record for a fcst id.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   11/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Forecast list
  ********************************************************************************/
  PROCEDURE get_forecast_record (
    o_result           OUT     common.st_result,
    o_result_msg       OUT     common.st_message_string,
    i_fcst_id          IN      common.st_id,
    o_last_updated     OUT     fcst.last_updated%TYPE,
    o_forecast_type    OUT     fcst.forecast_type%TYPE,
    o_srce_fcst_id     OUT     fcst.srce_fcst_id%TYPE,
    o_dataentity_code  OUT     fcst.dataentity_code%TYPE,
    o_period           OUT     common.st_code,
    o_status           OUT     fcst.status%TYPE,
    o_end_year_period  OUT     common.st_code,
    o_moe              OUT     common.st_code);

  /*******************************************************************************
   NAME:      GET_DATA_ENTITES
   PURPOSE:   This procedure will return a collection of data entities as a
              ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera        Created this procedure.
   1.1   04/05/2006 Chris Horn           Update the procedure prototype.

   NOTES:
   Don't want to give DF_APP access to data entity data held on PF so may create this
   procedure on PF and grant df_app access to run it.
  ********************************************************************************/
  PROCEDURE get_data_entites (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_data_entites OUT common.t_ref_cursor);

   /*******************************************************************************
   NAME:      COPY_FORECAST
   PURPOSE:   This procedure will create a forecast based on the values passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call demand_forecast.copy_forecast for functionality
  ********************************************************************************/
  PROCEDURE copy_forecast (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_fcst_id         IN      common.st_id,
    i_dest_fcst_type  IN      common.st_code,
    i_period_from     IN      common.st_code,
    i_period_to       IN      common.st_code,
    i_data_entity     IN      common.st_code);

/*******************************************************************************
   NAME:      COPY_DRAFT_FORECAST
   PURPOSE:   This procedure will create a forecast based on the selected draft
              forecast supplied.  Note it does not trigger the normal on creation
              events for a forecast as the system will not automatically send the
              forecast onto the downstream systems. 

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   07/07/2013 Chris Horn         Created this procedure.

   NOTES:
   Will call demand_forecast.copy_draft_forecast for functionality
  ********************************************************************************/
  PROCEDURE copy_draft_forecast (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_fcst_id         IN      common.st_id);

   /*******************************************************************************
   NAME:      REDO_MATERIAL_DETERMINATION
   PURPOSE:   This procedure will recalculates the material determination based on the fcst_id
               passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call demand_forecast.redo_tdu for functionality
  ********************************************************************************/
  PROCEDURE redo_material_determination (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      REDO_PRICING
   PURPOSE:   This procedure will recalculates the price for all records suppply and demand.
              based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.
   1.1   18/12/2006 Steve Gregan         Added demand group and account assignment parameters.

   NOTES:
   Will call demand_forecast.redo_prices for functionality
  ********************************************************************************/
  PROCEDURE redo_pricing (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_fcst_id         IN      common.st_id,
    i_dmnd_grp_id     IN      common.st_id,
    i_acct_assign_id  IN      common.st_id);

   /*******************************************************************************
   NAME:      ARCHIVE_FORECAST
   PURPOSE:   This procedure removes the records for a forecast from the dmnd_data table,
              and moves them to the dmnd_data_acrh table and then update the forecast status
     to archived based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call demand_forecast.archive_forecast for functionality
  ********************************************************************************/
  PROCEDURE archive_forecast (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      UNARCHIVE_FORECAST
   PURPOSE:   This procedure will unarchive a forecast based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call demand_forecast.? for functionality
  ********************************************************************************/
  PROCEDURE unarchive_forecast (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      PURGE_FORECAST
   PURPOSE:   This procedure will purge a forecast based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call demand_forecast.? for functionality
  ********************************************************************************/
  PROCEDURE purge_forecast (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      VENUS_DEMAND_PLAN_EXTRACT
   PURPOSE:   This procedure will produce a Venus extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call extract_venus.extract_demand_forecast for functionality
  ********************************************************************************/
  PROCEDURE venus_demand_plan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      VENUS_PRODUCTION_PLAN_EXTRACT
   PURPOSE:   This procedure will produce a Venus extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call extract_venus.extract_production_plan for functionality
  ********************************************************************************/
  PROCEDURE venus_production_plan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      VENUS_INV_FORECAST_EXTRACT
   PURPOSE:   This procedure will produce a Venus extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call extract_venus.extract_projected_inventory for functionality
  ********************************************************************************/
  PROCEDURE venus_inv_forecast_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      LOGISTICS_DEMAND_PLAN_EXTRACT
   PURPOSE:   This procedure will produce a Logistics extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   02/06/2006 Chris Horn           Created this procedure.

   NOTES:
   Will call extract_lg.populate_model
  ********************************************************************************/
  PROCEDURE logistics_demand_plan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      LOGISTICS_PPLAN_EXTRACT.
   PURPOSE:   This procedure will produce a Logistics extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   20/12/2007 Sal Sanghera         Created this procedure.

   NOTES:

  ********************************************************************************/
  PROCEDURE logistics_pplan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      FPPS_DEMAND_PLAN_EXTRACT
   PURPOSE:   This procedure will produce a FPPS extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call extract_fpps.extract_demand_forecast for functionality
  ********************************************************************************/
  PROCEDURE fpps_demand_plan_extract (
    o_result         OUT  common.st_result,
    o_result_msg     OUT  common.st_message_string,
    i_dataentity          common.st_code,
    i_fcst_id             common.st_id,
    i_df_extct_type       common.st_code);

   /*******************************************************************************
   NAME:      FPPS_INVENTORY_FORECAST_EXTRACT
   PURPOSE:   This procedure will produce a FPPS extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call extract_fpps.? for functionality
  ********************************************************************************/
  PROCEDURE fpps_inv_forecast_extract (
    o_result      OUT  common.st_result,
    o_result_msg  OUT  common.st_message_string,
    i_dataentity       common.st_code,
    i_fcst_id          common.st_id,
    i_fpps_moe         common.st_code);

   /*******************************************************************************
   NAME:      FPPS_PRODUCTION_PLAN_EXTRACT
   PURPOSE:   This procedure will produce a FPPS extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   24/05/2006 Chris Horn           Created this procedure.

   NOTES:
   Will call extract_fpps.? for functionality
  ********************************************************************************/
  PROCEDURE fpps_production_plan_extract (
    o_result      OUT  common.st_result,
    o_result_msg  OUT  common.st_message_string,
    i_dataentity       common.st_code,
    i_fcst_id          common.st_id,
    i_fpps_moe         common.st_code);

   /*******************************************************************************
   NAME:       FIN_PLAN_DEMAND_EXTRACT
   PURPOSE:   This procedure will produce a Finance extract based on the fcst_id passed in

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/05/2006 Sal Sanghera         Created this procedure.

   NOTES:
   Will call extract_fp.populate_model for functionality
  ********************************************************************************/
  PROCEDURE fin_plan_demand_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id);

   /*******************************************************************************
   NAME:      GET_ACCNT_ASSGNMT_IDS
   PURPOSE:   This procedure will return all account assignment IDS from accnt_assign as a
              ref cursor.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   15/01/2007 Sal Sanghera         Created this procedure.

   NOTES:
   Used in the Demand Financials GUI to populate the Account Assignment list for Redo pricing
   and also to return the ID to the form
  ********************************************************************************/
  PROCEDURE get_accnt_assgnmt_ids (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_accnt_assnmts OUT common.t_ref_cursor);

  /*******************************************************************************
    NAME:      GET_dmnd_grp_IDS
    PURPOSE:   This procedure will return all demand group IDS (and names )from dmnd_grp as a
               ref cursor.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   15/01/2007 Sal Sanghera         Created this procedure.

    NOTES:
    Used in the Demand Financials GUI to populate the demand group list for Redo pricing
    and also to return the ID to the form
   ********************************************************************************/
  PROCEDURE get_dmnd_grp_ids (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_dmnd_grp OUT common.t_ref_cursor);

  /*******************************************************************************
     NAME:      get_mltplr_code
     PURPOSE:   This procedure will return all the multiplier codes from dmnd_grp_org as a ref cursor.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   06/02/2007 Sal Sanghera         Created this procedure.

     NOTES:
     Used in the Demand Financials GUI to populate the multiplier code list
    ********************************************************************************/
  PROCEDURE get_mltplr_code (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_mltplr_code OUT common.t_ref_cursor);
    /*******************************************************************************
    NAME:      GET_DROP_DOWN_LIST
    PURPOSE:   This procedure will return all classification for dmnd_adjust

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   03/05/2006 Sal Sanghera         Created this procedure.
    1.1   07-Apr-2008 Mary Ahyick         Merged Demand Adjust Gui and Demand 
                                          Financials 
    NOTES:
    Used in the Demand Financials GUI to populate the Demand Group Codes list item
   ********************************************************************************/
  PROCEDURE get_drop_down_list (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_drop_down       IN      common.st_code,
    o_drop_down_list  OUT     common.t_ref_cursor);

  /*******************************************************************************
    NAME:      ADJUST_FORECAST
    PURPOSE:   This procedure is used to adjust the forecast.
               This procedure will drop any bit map indexes that are in place
               before performing the adjustment.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   11/07/2007 Chris Horn           Created this procedure.
    1.1   07-Apr-2008 Mary Ahyick         Merged Demand Adjust Gui and Demand 
                                          Financials 
    NOTES:
   ********************************************************************************/
  PROCEDURE adjust_forecast (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_mode           IN      common.st_status,
    i_fcst_id        IN      common.st_code,
    i_dmnd_grp       IN      common.st_code,
    i_acct_assign    IN      common.st_code,
    i_sales_org      IN      common.st_code,
    i_multiplier     IN      common.st_code,
    i_source         IN      common.st_code,
    i_fromweek       IN      common.st_code,
    i_toweek         IN      common.st_code,
    i_class_type_1   IN      common.st_code,
    i_class_value_1  IN      common.st_code,
    i_class_type_2   IN      common.st_code,
    i_class_value_2  IN      common.st_code,
    i_class_type_3   IN      common.st_code,
    i_class_value_3  IN      common.st_code,
    i_class_type_4   IN      common.st_code,
    i_class_value_4  IN      common.st_code,
    i_class_type_5   IN      common.st_code,
    i_class_value_5  IN      common.st_code,
    i_matl_code      IN      common.st_code,
    i_adjustment     IN      common.st_code,
    i_target_cases   IN      common.st_code,
    i_target_gsv     IN      common.st_code,
    o_case_total     OUT     common.st_value,
    o_gsv_total      OUT     common.st_value,
    o_case_change    OUT     common.st_value,
    o_gsv_change     OUT     common.st_value);


  /*******************************************************************************
    NAME:      DELETE_ADJUSTMENTS
    PURPOSE:   This procedure is used to delete all adjustments that may have
               been applied to a forecast.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   15/07/2007 Chris Horn           Created this procedure.
    1.1   07-Apr-2008 Mary Ahyick         Merged Demand Adjust Gui and Demand 
                                          Financials 
    NOTES:
   ********************************************************************************/
  PROCEDURE delete_adjustments (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_fcst_id        IN      common.st_code);

END demand_gui; 
 