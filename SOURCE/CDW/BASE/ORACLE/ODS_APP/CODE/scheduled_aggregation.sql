CREATE OR REPLACE PACKAGE ODS_APP.scheduled_aggregation IS

/*******************************************************************************
  NAME:      run_scheduled_aggregation
  PURPOSE:   This procedure is the main routine, which calls the other package
             procedures and functions. TThe scheduled aggregation process is
             initiated by an Oracle job that will run once daily at 12:15am
             (Local time based on the Company).  The scheduled job will call
             the aggregation procedure passing Company Code and Aggregation Date
             as parameters.  Aggregation Date will be set to SYSDATE-1 when called
             via the scheduled job.  However, by passing Aggregation Date as a
             parameter this will allow for re-running of past aggregations when
             required.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this procedure.
  1.1   22/03/2006 Toui Lepkhammany     MOD: Modify forecast_fact_aggregation to
                                        allow for forecast type FCST into FCST_FACT table.
                                        MOD: Modify forecast_fact_aggregation to  allow for
                                        net and gross value entries.
  1.2   01/05/2006 Naresh Sharma        MOD: delivery_fact_aggregation
                                        MOD: purch_order_fact_aggregation
                                        MOD: order_fact_aggregation
                                        The above procedures were modified to cater
                                        to the requirements for CSL reporting.
  1.3   3/06/2007 Kris Lee              MOD: forecast_fact_aggregation()
                                        MOD: dmd_plng_fcst_fact_aggregation()
                                        The above procedures were modified for catering for the
                                        forecast detail type dimensional aggregation
  1.4   3/07/2007  Kris Lee             ADD: dcs_order_fact_aggregation() - fundraising Sales Order
  1.5   27/07/2007 Kris Lee             ADD: csl_process_purch_order()
                                             csl_process_sales_order()
                                             csl_process_dlvry()
                                             created by Irina Saveluc on 05/2007
  1.6   30/08/2007 Kris Lee             Snackfood BR type forecast aggregate casting period - 2
                                        ADD: snack_br_fcst_fact_aggregation()
                                             get_mars_period()
                                        MOD: forecast_fact_aggregation()
                                               - Different logic for MOE 0009 BR type
                                               - Add moe_code to fcst_fact table
                                               - Add moe_code condition to all cursors, delete and insert statements
                                             dmd_plng_fcst_fact_aggregation
                                               - Add moe_code field to demand_plng_fcst_fact table
                                               - Add moe_code condition to all cursors, delete and insert statements
  1.7   31/10/2007 Steve Gregan         MOD: Changed the sales order aggregation table SAP_SAL_ORD_ISC to a grouping
                                             by BELNR and GENSEQ to prevent duplicate ORDER_FACT row exception when
                                             multiple order line schedule rows found. The scheduled quantity (WMENG)
                                             is summed and the max scheduled date is used.
  1.8   11/03/2008 Steve Gregan         MOD: Changed the delivery aggregation to separate select and insert
                                             new procedure delivery_fact_aggregation_v2 added
  1.9   12/03/2008 Jonathan Girling     MOD: Changed the purchase order aggregation to separate select and insert
                                             new procedure purch_order_fact_agg_v2 added
  1.10  12/03/2008 Steve Gregan         MOD: Changed the order aggregation to separate select and insert
                                             new procedure order_fact_aggregation_v2 added
  1.11  28/03/2008 Steve Gregan         MOD: Changed the purchase order aggregation to recode the select statement
                                             new procedure purch_order_fact_agg_v3 added
  1.12  15/04/2008 Kris Lee             MOD: Changed the NZ demand_plng_division_code logic 
                                              for order_fact, purch_order_fact and dlvry_fact
  1.13  02/06/2008 Paul Berude          MOD: Removed snack_br_fcst_fact_aggregation procedure as AUS Snack now want to 
                                             handle the BR forecast the same as other business units.
  1.14  28/07/2008 Jonathan Girling     MOD: Updated the tables dlvry_fact, order_fact and purch_order_fact to point to  
                                             the renamed dlvry_fact_old, order_fact_old and purch_order_fact_old tables
                                             as part of the Venus upgrade 
  1.15  24/09/2008 Jonathan Girling     MOD: Commented out the following aggregations, since they will not be required
                                             with the new dw_scheduled_aggregation:
                                              - purch_order_fact_agg_v3 
                                              - order_fact_aggregation_v2
                                              - delivery_fact_aggregation_v2

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     BOOLEAN  Whether to convert aggregation date  true
                       to the date and time at the company.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_scheduled_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN DATE,
  i_get_company_time IN BOOLEAN DEFAULT FALSE);

/*******************************************************************************
  NAME:      purch_order_fact_aggregation
  PURPOSE:   This function aggregates the purch_order_fact table based on the following
             purchase order tables:
             - sap_sto_po_hdr
             - sap_sto_po_org
             - sap_sto_po_dat
             - sap_sto_po_gen
             - sap_sto_po_itp
             - sap_sto_po_ipn
             - sap_sto_po_oid

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/07/2004 Paul Berude          Created this function.
  1.1   01/05/2006 Naresh Sharma        Modified the logic of "INSERT INTO PURCH_ORDER_FACT ..
                                        .. SELECT " statement. The SQL was modified to
                                        cater for the following new columns :
                                        (a) CREATN_YYYYPPDD
                                        (b) PURCH_ORDER_EFF_YYYYPPW
                                        PURCH_ORDER_STATUS column renamed to "PURCH_ORDER_LINE_STATUS"
  1.2   19/01/2007 Paul Jacobs          Added DEMAND_PLNG_GRP_DIVISION_CODE column, due to
                                        Demand Planning Group mapping changes for DTS transactions.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION purch_order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;


/*******************************************************************************
  NAME:      purch_order_fact_agg_v2
  PURPOSE:   This function aggregates the purch_order_fact table based on the following
             purchase order tables:
             - sap_sto_po_hdr
             - sap_sto_po_org
             - sap_sto_po_dat
             - sap_sto_po_gen
             - sap_sto_po_itp
             - sap_sto_po_ipn
             - sap_sto_po_oid

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/07/2004 Jonathan Girling     Created this function from the existing purch_order_fact_aggregation.
  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION purch_order_fact_agg_v2 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;


/*******************************************************************************
  NAME:      purch_order_fact_agg_v3
  PURPOSE:   This function aggregates the purch_order_fact table based on the following
             purchase order tables:
             - sap_sto_po_hdr
             - sap_sto_po_org
             - sap_sto_po_dat
             - sap_sto_po_gen
             - sap_sto_po_itp
             - sap_sto_po_ipn
             - sap_sto_po_oid

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   28/03/2008 Steve Gregan        Created this function from the existing purch_order_fact_aggregation_v2.
  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION purch_order_fact_agg_v3 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;


/*******************************************************************************
  NAME:      order_fact_aggregation
  PURPOSE:   This function aggregates the order_fact table based on the following
             sales order tables:
             - sap_sal_ord_hdr
             - sap_sal_ord_org
             - sap_sal_ord_dat
             - sap_sal_ord_gen
             - sap_sal_ord_ipn
             - sap_sal_ord_iid
             - sap_sal_ord_ico

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this function.
  1.1   01/05/2006 Naresh Sharma        Modified the logic of "INSERT INTO ORDER_FACT ..
                                        .. SELECT " statement. The SQL was modified to
                                        cater for the following new / existing columns :
                                        (a) CREATN_YYYYPPDD         (mars_date.yyyyppdd)
                                        (b) ORDER_EFF_DATE          (sap_sal_ord_isc.edatu)
                                        (c) ORDER_EFF_YYYYPPDD      (mars_date.yyyymmdd)
                                        (d) ORDER_EFF_YYYYPPW       (mars_date.mars_week)
                                        (e) CONFIRMED_QTY           (sap_sal_ord_isc.wmeng)
                                        (f) CONFIRMED_GSV           ((order_gsv/order_qty)*confirmed_qty))
                                        (g) BASE_UOM_CONFIRMED_QTY  (calculated value)
                                        (h) CONFIRMED_QTY_GROSS_TONNES (calculated value)
                                        (i) CONFIRMED_QTY_GROSS_TONNES (calculated value)
                                        (j) CUST_ORDER_DOC_NUM      (sap_sal_ord_irf.refnr)
                                        (h) CUST_ORDER_DOC_LINE_NUM (sap_sal_ord_irf.zeile)
                                        (i) CUST_ORDER_DUE_DATE     (sap_sal_ord_irf.datum)
                                        Renamed "GSV" columns to "ORDER_GSV"
                                        Renamed all "GSV_" columns to "ORDER_GSV_"
                                        DLVRY_STATUS column renamed to "DLVRY_LINE_STATUS"
                                        Additional filter added (do not retreive Item subsitution lines)
                                        AND sap_sal_ord_gen.pstyv <> 'ZAPS'
  1.2   19/01/2007 Paul Jacobs          Added DEMAND_PLNG_GRP_DIVISION_CODE column, due to
                                        Demand Planning Group mapping changes for DTS transactions.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sal_ord_hdr.sap_sal_ord_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;


/*******************************************************************************
  NAME:      order_fact_aggregation_v2
  PURPOSE:   This function aggregates the order_fact table based on the following
             sales order tables:
             - sap_sal_ord_hdr
             - sap_sal_ord_org
             - sap_sal_ord_dat
             - sap_sal_ord_gen
             - sap_sal_ord_ipn
             - sap_sal_ord_iid
             - sap_sal_ord_ico

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/03/2008 Steve Gregan         Created this function from the existing order_fact_aggregation.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION order_fact_aggregation_v2 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sal_ord_hdr.sap_sal_ord_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      delivery_fact_aggregation
  PURPOSE:   This function aggregates the dlvry_fact table based on the following
             sales order and delivery tables:
             - sap_del_hdr
             - sap_del_det
             - sap_del_tim
             - sap_del_add
             - sap_del_irf
             - sap_sal_ord_hdr
             - sap_sal_ord_gen
             - sap_sal_ord_icn

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this function.
  1.2   01/05/2006 Naresh Sharma        Modified the logic of "INSERT INTO DLVRY_FACT ..
                                        .. SELECT " statement. The SQL was modified to
                                        cater for the following new columns :
                                        (a) ORDER_DOC_NUM            (sap_del_irf.belnr)
                                        (b) ORDER_DOC_LINE_NUM       (sap_del_irf.posnr)
                                        (c) PURCH_ORDER_DOC_NUM      (sap_del_irf.belnr)
                                        (d) PURCH_ORDER_DOC_LINE_NUM (sap_del_irf.posnr)
                                        (e) DLVRY_PROCG_STAGE        (valid values : REQUEST, CONFIRMED)
                                        (f) GOODS_ISSUE_DATE         (sap_del_tim.isdd)
                                        (g) GOODS_ISSUE_YYYYPPDD     (calcualted value)
                                        (i) CREATN_YYYYPPDD          (calcualted value)
                                        (j) DLVRY_EFF_YYYYPPW        (calcualted value)
                                        DLVRY_STATUS column renamed to "DLVRY_LINE_STATUS"
                                        "AND sap_del_det.heivw IS NULL " ==> removed filter
                                        New filter added to return main lines from the sap_del_det table
                                        "AND sap_del_det.pstyv NOT IN ('ZBCH','ZRBC')
  1.2   19/01/2007 Paul Jacobs          Added DEMAND_PLNG_GRP_DIVISION_CODE column, due to
                                        Demand Planning Group mapping changes for DTS transactions.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION delivery_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_del_hdr.sap_del_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      delivery_fact_aggregation_v2
  PURPOSE:   This function aggregates the dlvry_fact table based on the following
             sales order and delivery tables:
             - sap_del_hdr
             - sap_del_det
             - sap_del_tim
             - sap_del_add
             - sap_del_irf
             - sap_sal_ord_hdr
             - sap_sal_ord_gen
             - sap_sal_ord_icn

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   11/03/2008 Steve Gregan         Created this function from the existing delivery_fact_aggregation.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION delivery_fact_aggregation_v2 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_del_hdr.sap_del_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;


/*******************************************************************************
  NAME:      forecast_fact_aggregation
  PURPOSE:   This function aggregates the fcst_fact table based on the following
             forecast tables:
             - fcst_hdr
             - fcst_dtl

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this function.
  1.1   27/01/2005 Paul Berude          Included consolidated currency columns.
  1.2   28/06/2007 Kris Lee             Modify for Snackfood rollout - fcst_dtl now to fcst_dtl_type_code level
                                        Replace mapping ods.fcst_dtl.matl_code to ods.fcst_dtl.matl_zrep_code
                                        Add matl_tdu_code, fcst_dtl_type_code dimensionalised xxx_qty and xxx_value fields
                                        Sum up the ods.fcst_dtl.fcst_value to current level
                                        Sum up the ods.fcst_dtl.fcst_qty to current level
                                        Assign qty and value to dimensionalised xxx_qty and xxx_value fields based on fcst_dtl_type_code
                                        (Don't aggregate to fcst_dtl_type_code level for report performance issue)
  1.3   30/08/2007 Kris Lee             Modify for Snackfood BR forecast aggregate [casting period - 2]
                                        Add moe_code to fcst_fact table becasue sales_org_code, distbn_chnl_code and division_code
                                        is not a unique group eg sales area [147/99/51] can belong to MOE 0009, 0021, 0196
                                        Without providing the moe_code, deletion will delete wrong rows which belong to other moe_code
                                        Add moe_code condition to all cursors, delete and insert statements
  1.4   4/12/2007  Kris Lee             Fix Snackfood BR Type forecast to reload and delete from fcst_yyyypp = casting_period - 2
  1.5   2/06/2008  Paul Berude          MOD: Removed snack_br_fcst_fact_aggregation procedure as AUS Snack now want to 
                                             handle the BR forecast the same as other business units.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION forecast_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      dmd_plng_fcst_fact_aggregation
  PURPOSE:   This function aggregates the demand_plng_fcst_fact table based on
             the following forecast tables:
             - fcst_hdr
             - fcst_dtl

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/05/2006 Raja Vaidyanathan    Created this function.
  1.1   28/06/2007 Kris Lee             Modify for Snackfood rollout - fcst_dtl now down to fcst_dtl_type_code level
                                        Replace mapping ods.fcst_dtl.matl_code to ods.fcst_dtl.matl_zrep_code
                                        Add matl_tdu_code, fcst_dtl_type_code dimensionalised xxx_qty and xxx_value fields
                                        Sum up the ods.fcst_dtl.fcst_value to current level
                                        Sum up the ods.fcst_dtl.fcst_qty to current level
                                        Assign qty and value to dimensionalised xxx_qty and xxx_value fields based on fcst_dtl_type_code
                                        (Don't aggregate to fcst_dtl_type_code level for report performance issue)
  1.1   30/08/2007 Kris Lee             Add moe_code to fcst_fact table
                                        Add moe_code condition to all cursors, delete and insert statements

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION dmd_plng_fcst_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      dcs_order_fact_aggregation
  PURPOSE:   This function aggregates the dsc_sales_order_fact table based on the following
             fundraising sales order table:
             - ods.dcs_sales_order

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2/07/2007  Kris Lee             Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20070701
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION dcs_order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN dcs_sales_order.load_date%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      csl_process_purch_order
  PURPOSE:   This function checks for new and updated purchase orders based on the following tables:
             - sap_sto_po_hdr
             - sap_sto_po_org
             - sap_sto_po_pnr
             - sap_cus_hdr
             - sap_ref_dat

      It then deletes all the old purchase orders that need update from csl_order_dlvy_fact.
      Next it inserts all the new and updated purchase orders from purch_order_fact with the
      coresponding deliveries, if any, from dlvry_fact, into csl_order_dlvy_fact.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   07/05/07   Irina Saveluc        Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Processing Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION csl_process_purch_order (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      csl_process_sales_order
  PURPOSE:   This function checks for new and updated sales orders based on the following tables:
             - sap_sal_ord_hdr
             - sap_sal_ord_org

      It then deletes all the old sales orders that need update from csl_order_dlvy_fact.
      Next it inserts all the new and updated sales orders from order_fact with the
      coresponding deliveries, if any, from dlvry_fact, into csl_order_dlvy_fact.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   09/05/07   Irina Saveluc        Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Processing Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION csl_process_sales_order (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sal_ord_hdr.sap_sal_ord_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      csl_process_dlvry
  PURPOSE:   This function checks for new and updated deliveries based on the following table:
             - sap_del_hdr

      It then deletes all the old deliveries that need update from csl_order_dlvy_fact.
      Next it inserts all the new and updated deliveries from dlvry_fact with the
      corresponding purchase orders from purch_order_fact or corresponding sales orders
      from order_fact, into csl_order_dlvy_fact.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   09/05/07   Irina Saveluc        Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Processing Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION csl_process_dlvry (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_del_hdr.sap_del_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      fcst_region_fact_aggregation
  PURPOSE:   This function aggregates the Snackfood BR Type forecast to the
             fcst_local_region_fact table on the following conditions:
               Forecast modified on aggregation date and
                 MOE = 0009, forecast type = BR  and min casting period <= current period -2
              or
                First day of a new mars period (based on current date), which triggers the
                MOE = 0009 and BR type to be reloaded.

             Source tables:
             - fcst_fact
             - fcst_local_region_pct

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   06/12/2007 Kris Lee             Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION fcst_region_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      get_mars_period
  PURPOSE:   This Function get the MARS_PERIOD by the given date and the offset number
             of days in MARS_PERIOD format.
             NOTE: Pass in negative offset days for prior PERIOD from given date
             positive offset days for future PERIOD from given date.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/08/2007 Kris Lee             Created this function

  PARAMETERS:
  Pos  Type   Format   Description                              Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     DATE     Date based on                            20061231
  2    IN     NUMBER   offset number of days on the date given  28
  3    IN     NUMBER   Log Level                                1

  RETURN VALUE: NUMBER IN yyyypp FORMAT
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION get_mars_period (
  i_date        IN DATE,
  i_offset_days IN NUMBER,
  i_log_level   IN ods.log.log_level%TYPE
 ) RETURN NUMBER;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Job Type                             Aggregation
  2    IN     VARCHAR2 Data Type                            Generic
  3    IN     VARCHAR2 Sort Field                           Aggregation Date
  4    IN     NUMBER   Log Level                            1
  5    IN     VARCHAR2 Log Text                             Starting Aggregations

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE);

END scheduled_aggregation;
/


/*** Package Body ***/

CREATE OR REPLACE PACKAGE BODY ODS_APP.scheduled_aggregation IS

  pc_fcst_dtl_typ_dfn_adj        CONSTANT VARCHAR2(1) := '0';
  pc_fcst_dtl_typ_base           CONSTANT VARCHAR2(1) := '1';
  pc_fcst_dtl_typ_aggr_mkt_act   CONSTANT VARCHAR2(1) := '2';
  pc_fcst_dtl_typ_lock           CONSTANT VARCHAR2(1) := '3';
  pc_fcst_dtl_typ_rcncl          CONSTANT VARCHAR2(1) := '4';
  pc_fcst_dtl_typ_auto_adj       CONSTANT VARCHAR2(1) := '5';
  pc_fcst_dtl_typ_override       CONSTANT VARCHAR2(1) := '6';
  pc_fcst_dtl_typ_mkt_act        CONSTANT VARCHAR2(1) := '7';
  pc_fcst_dtl_typ_data_driven    CONSTANT VARCHAR2(1) := '8';
  pc_fcst_dtl_typ_tgt_imapct     CONSTANT VARCHAR2(1) := '9';

PROCEDURE reload_fcst_region_fact (
  i_company_code     IN company.company_code%TYPE,
  i_moe_code         IN fcst_fact.moe_code%TYPE,
  i_reload_yyyypp    IN mars_date_dim.mars_period%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  );

PROCEDURE run_scheduled_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN DATE,
  i_get_company_time IN BOOLEAN DEFAULT FALSE) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg   constants.message_string;
  v_company_code     company.company_code%TYPE;
  v_aggregation_date DATE;
  v_log_level        ods.log.log_level%TYPE;
  v_status           NUMBER;
  v_db_name          VARCHAR2(256) := NULL;
  
  var_process_date varchar2(8);
  var_process_code varchar2(32);

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether the inputted company code exists in the company table.
  CURSOR csr_company_code IS
    SELECT
      company_code,
      company_timezone_code
    FROM
      company A
    WHERE
      company_code = v_company_code;
  rv_company_code csr_company_code%ROWTYPE;

BEGIN

  -- Initialise variables.
  v_log_level := 0;

  -- Get the Database name
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
  INTO
    v_db_name
  FROM
    dual;

  -- Start scheduled aggregation.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Aggregations - Start');

  -- Check the inputted company code.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Checking that the inputted parameter Company' ||
    ' Code [' || i_company_code || '] is correct.');
  BEGIN
    IF i_company_code IS NULL THEN
      RAISE e_processing_error;

    ELSE
      v_company_code := TRIM(i_company_code);

      -- Fetch the record from the csr_company_code cursor.
      OPEN csr_company_code;
      FETCH csr_company_code INTO rv_company_code;

      IF csr_company_code%NOTFOUND THEN
        CLOSE csr_company_code;
        RAISE e_processing_error;
      END IF;

      CLOSE csr_company_code;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'The inputted parameter Company Code [' || i_company_code || '] failed validation.';
      RAISE e_processing_error;
  END;

  -- Convert the inputted aggregation date to standard date format.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Converting the inputted Aggregation' ||
    ' Date [' || TO_CHAR(i_aggregation_date) || '] to standard date format.');
  BEGIN
    IF i_aggregation_date IS NULL THEN
      RAISE e_processing_error;

    ELSE

      IF (i_get_company_time) THEN

        v_aggregation_date := utils.tz_conv_date_time(i_aggregation_date,
                                                      ods_constants.db_timezone,
                                                      rv_company_code.company_timezone_code);
      ELSE
        v_aggregation_date := i_aggregation_date;
      END IF;

      v_aggregation_date := TO_DATE(TO_CHAR(v_aggregation_date, 'YYYYMMDD'), 'YYYYMMDD');
    END IF;

    write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Will be aggregating for date: ' || v_aggregation_date || '.');

  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'Unable to convert the inputted Aggregation Date [' || TO_CHAR(i_aggregation_date, 'YYYYMMDD') || '] from string to date format.';
      RAISE e_processing_error;
  END;


--  -- Calling the purch_order_fact_aggregation function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the purch_order_fact_aggregation function.');
--  v_status := purch_order_fact_aggregation(v_company_code,
--                                           v_aggregation_date,
--                                           v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the purch_order_fact_aggregation.';
--    RAISE e_processing_error;
--  END IF;

--  -- Calling the purch_order_fact_agg_v2 function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the purch_order_fact_agg_v2 function.');
--  v_status := purch_order_fact_agg_v2(v_company_code,
--                                           v_aggregation_date,
--                                           v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the purch_order_fact_agg_v2.';
--    RAISE e_processing_error;
--  END IF;

  -- Calling the purch_order_fact_agg_v3 function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the purch_order_fact_agg_v3 function.');
--  v_status := purch_order_fact_agg_v3(v_company_code,
--                                      v_aggregation_date,
--                                      v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the purch_order_fact_agg_v3.';
--    RAISE e_processing_error;
--  END IF;

--  -- Calling the order_fact_aggregation function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the order_fact_aggregation function.');
--  v_status := order_fact_aggregation(v_company_code,
--                                     v_aggregation_date,
--                                     v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the order_fact_aggregation.';
--    RAISE e_processing_error;
--  END IF;

  -- Calling the order_fact_aggregation_v2 function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the order_fact_aggregation_v2 function.');
--  v_status := order_fact_aggregation_v2(v_company_code,
--                                        v_aggregation_date,
--                                        v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the order_fact_aggregation_v2.';
--    RAISE e_processing_error;
--  END IF;

--  -- Calling the delivery_fact_aggregation function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the delivery_fact_aggregation function.');
--  v_status := delivery_fact_aggregation(v_company_code,
--                                        v_aggregation_date,
--                                        v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the delivery_fact_aggregation.';
--    RAISE e_processing_error;
--  END IF;

  -- Calling the delivery_fact_aggregation_v2 function.
--  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the delivery_fact_aggregation_v2 function.');
--  v_status := delivery_fact_aggregation_v2(v_company_code,
--                                           v_aggregation_date,
--                                           v_log_level + 1);
--  IF v_status <> constants.success THEN
--    v_processing_msg := 'Unable to successfully complete the delivery_fact_aggregation_v2.';
--    RAISE e_processing_error;
--  END IF;

  -- Calling the forecast_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the forecast_fact_aggregation function.');
  v_status := forecast_fact_aggregation(v_company_code,
                                        v_aggregation_date,
                                        v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the forecast_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the dmd_plng_fcst_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the dmd_plng_fcst_fact_aggregation function.');
  v_status := dmd_plng_fcst_fact_aggregation(v_company_code,
                                             v_aggregation_date,
                                             v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the dmd_plng_fcst_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the dcs_order_fact_aggregation function. (Fundraising Sales Order)
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the dcs_order_fact_aggregation function.');
  v_status := dcs_order_fact_aggregation(v_company_code,
                                         v_aggregation_date,
                                         v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the dcs_order_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the fcst_region_fact_aggregation function
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the fcst_region_fact_aggregation function.');
  v_status := fcst_region_fact_aggregation(v_company_code,
                                           v_aggregation_date,
                                           v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the fcst_region_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

/*
  -- Note:  The below CSL aggregation procedures have been commented out due to the
            outstanding issue with multiple Sales Order lines effecting CSL reporting
            from the aggregate table.

  -- Calling the csl_process_purch_order function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the csl_process_purch_order function.');
  v_status := csl_process_purch_order(v_company_code,
                                      v_aggregation_date,
                                      v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the csl_process_purch_order.';
    RAISE e_processing_error;
  END IF;

  -- Calling the csl_process_sales_order function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the csl_process_sales_order function.');
  v_status := csl_process_sales_order(v_company_code,
                                      v_aggregation_date,
                                      v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the csl_process_sales_order.';
    RAISE e_processing_error;
  END IF;

  -- Calling the csl_process_dlvry function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the csl_process_dlvry function.');
  v_status := csl_process_dlvry(v_company_code,
                                v_aggregation_date,
                                v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the csl_process_dlvry.';
    RAISE e_processing_error;
  END IF;
*/

  -- End scheduled aggregation processing.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Aggregations - End');
  
  
  -- Stream trace
  var_process_date := to_char(i_aggregation_date,'yyyymmdd');
  var_process_code := 'OLD_SCHEDULED_AGGREGATION_'||i_company_code;

  lics_processing.set_trace(var_process_code, var_process_date);
  
  

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_sched_aggregation,
                              'MFANZ CDW Scheduled Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

    utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                            'Fatal Error occurred during Scheduled Aggregation.',
                            ods_constants.job_type_sched_aggregation,
                            i_company_code);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_sched_aggregation,
                              'MFANZ CDW Scheduled Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

    utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                            'Fatal Error occurred during Scheduled Aggregation.',
                            ods_constants.job_type_sched_aggregation,
                            i_company_code);

END run_scheduled_aggregation;



FUNCTION purch_order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any purchase orders were received or updated yesterday.
  CURSOR csr_purch_order_count IS
    SELECT
      count(*) AS purch_order_count
    FROM
      sap_sto_po_hdr a,
      sap_sto_po_org b,
      sap_sto_po_pnr c,
      sap_cus_hdr d,
      sap_ref_dat e
    WHERE a.belnr = b.belnr
      AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
      AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
      AND a.belnr = c.belnr
      AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
      AND c.partn = d.lifnr -- d Customer
      AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
      AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
      AND e.z_tabname = 'T001W'
      AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_purch_order_count csr_purch_order_count%ROWTYPE;

BEGIN

  -- Starting purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Starting PURCH_ORDER_FACT_OLD aggregation.');

  -- Fetch the record from the csr_purch_order_count cursor.
  OPEN csr_purch_order_count;
  FETCH csr_purch_order_count INTO rv_purch_order_count.purch_order_count;
  CLOSE csr_purch_order_count;

  -- If any purchase orders were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 2, 'Checking whether any purchase orders' ||
    ' were received or updated yesterday.');

  IF rv_purch_order_count.purch_order_count > 0 THEN

    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT purch_order_fact_savepoint;

    -- Delete any purchase orders that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Deleting from PURCH_ORDER_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    DELETE FROM dds.purch_order_fact_old
    WHERE company_code = i_company_code
    AND purch_order_doc_num IN
     (SELECT
        a.belnr
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_pnr c,
        sap_cus_hdr d,
        sap_ref_dat e
      WHERE a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
        AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = c.belnr
        AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
        AND c.partn = d.lifnr -- d Customer
        AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
        AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
        AND e.z_tabname = 'T001W'
        AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date);

    -- Insert into purch_order_fact table based on company code and date.
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Inserting into the PURCH_ORDER_FACT_OLD table.');
    INSERT INTO dds.purch_order_fact_old
      (
      company_code,
      purch_order_doc_num,
      purch_order_doc_line_num,
      purch_order_type_code,
      purch_order_line_status,
      creatn_date,
      creatn_yyyyppdd,
      purch_order_eff_date,
      purch_order_eff_yyyyppdd,
      purch_order_eff_yyyyppw,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      doc_currcy_code,
      company_currcy_code,
      exch_rate,
      purchg_company_code,
      purch_order_reasn_code,
      vendor_code,
      cust_code,
      purch_order_qty,
      base_uom_purch_order_qty,
      purch_order_qty_gross_tonnes,
      purch_order_qty_net_tonnes,
      matl_code,
      purch_order_qty_uom_code,
      purch_order_qty_base_uom_code,
      plant_code,
      storage_locn_code,
      purch_order_usage_code,
      gsv,
      gsv_xactn,
      gsv_aud,
      gsv_usd,
      gsv_eur,
      niv,
      niv_xactn,
      niv_aud,
      niv_usd,
      niv_eur,
      ngv,
      ngv_xactn,
      ngv_aud,
      ngv_usd,
      ngv_eur,
      mfanz_icb_flag,
      demand_plng_grp_division_code
      )
      SELECT
        q.company_code,
        a.belnr AS purch_order_doc_num,
        c.posex AS purch_order_doc_line_num,
        d.orgid AS purch_order_type_code,
        c.purch_order_line_status AS purch_order_line_status,
        TO_DATE(e.datum, 'YYYYMMDD') AS creatn_date,
        p.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(f.datum, 'YYYYMMDD') AS purch_order_eff_date,
        g.mars_yyyyppdd AS purch_order_eff_yyyyppdd,
        g.mars_week AS purch_order_eff_yyyyppw,
        q.sales_org_code,
        q.distbn_chnl_code,
        q.division_code,
        a.curcy AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        a.wkurs AS exch_rate,
        b.orgid AS purchg_company_code,
        a.augru AS purch_order_reasn_code,
        h.partn AS vendor_code,
        j.cust_code_plant AS cust_code,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.menge, 0) AS purch_order_qty,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL((c.menge / l.umren * l.umrez), 0)  AS base_uom_purch_order_qty,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                          0), 0) AS purch_order_qty_gross_tonnes, -- Purchase Order Qty Gross Tonnes
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                          0), 0) AS purch_order_qty_net_tonnes, -- Purchase Order Qty Net Tonnes*/
        LTRIM(k.idtnr, 0) AS matl_code,
        c.menee AS purch_order_qty_uom_code,
        m.meins AS purch_order_qty_base_uom_code,
        c.werks AS plant_code,
        c.lgort AS storage_locn_code,
        c.abrvw AS purch_order_usage_code,
        ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_usdx) AS gsv,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0) AS gsv_xactn,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_aud,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_usd,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_eur,
        ods_app.currcy_conv(0,
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv,
        0 AS niv_xactn,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_aud,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_usd,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_eur,
        ods_app.currcy_conv(0,
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv,
        0 AS ngv_xactn,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_aud,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_usd,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_eur,
        DECODE(q.company_code, ods_constants.company_australia, DECODE(b.orgid, ods_constants.company_new_zealand, ods_constants.abbrd_yes, ods_constants.abbrd_no),
                               ods_constants.company_new_zealand, DECODE(b.orgid, ods_constants.company_australia, ods_constants.abbrd_yes, ods_constants.abbrd_no),
                               ods_constants.abbrd_no) AS mfanz_icb_flag,
        DECODE(q.company_code || q.distbn_chnl_code, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(r.bus_sgmnt_code, '01', '55', 
                                                                                                                                                           '02', '57', 
                                                                                                                                                           '05', '56', q.division_code),
                                                                                                                                  DECODE(q.division_code, '57', DECODE(r.bus_sgmnt_code, '02', '57', '05', '56', q.division_code), q.division_code)) demand_plng_grp_division_code
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_gen c,
        sap_sto_po_org d,
        sap_sto_po_dat e,
        sap_sto_po_dat f,
        mars_date g,
        sap_sto_po_pnr h,
        sap_cus_hdr i,
        (SELECT
            trim(substr(t1.z_data, 4, 4)) AS plant_code,
            trim(substr(t1.z_data, 42, 10)) AS cust_code_plant
          FROM
              sap_ref_dat t1
          WHERE
              t1.z_tabname = 'T001W') j,
        sap_sto_po_oid k,
        sap_mat_uom l,
        sap_mat_hdr m,
        purch_order_type n,
        company o,
        mars_date p,
       (SELECT
          trim(substr(t1.z_data, 173, 3)) AS company_code,
          trim(substr(t1.z_data, 42, 10)) AS cust_code,
          trim(substr(t1.z_data, 173, 3)) AS sales_org_code,
          trim(substr(t1.z_data, 223, 2)) AS distbn_chnl_code,
          trim(substr(t1.z_data, 225, 2)) AS division_code
        FROM
           sap_ref_dat t1
        WHERE
           t1.z_tabname = 'T001W') q,
        matl_dim r
      WHERE
        a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purchasing_company -- b Purchasing Company
        AND a.belnr = c.belnr -- c Purchase Order Line
        AND a.belnr = d.belnr AND d.qualf = ods_constants.purch_order_purch_order_type -- d Purchase Order Type
        AND d.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = e.belnr AND e.iddat = ods_constants.purch_order_creation_date -- e Creation Date
        AND e.datum = p.yyyymmdd_date -- p Creation Effective YYYYPPDD
        AND a.belnr = f.belnr AND f.iddat =  ods_constants.purch_order_effective_date -- f Purchase Order Effective Date
        AND f.datum = g.yyyymmdd_date -- g Purchase Order Effective YYYYPPDD
        AND a.belnr = h.belnr AND h.parvw = ods_constants.purch_order_vendor -- h  Vendor
        AND h.partn = i.lifnr -- i Vendor Code
        AND i.kunnr = q.cust_code
        -- Plant Join
        AND c.werks = j.plant_code(+)
        AND c.belnr = k.belnr (+) AND c.genseq = k.genseq (+) AND k.qualf (+) = ods_constants.purch_order_material_code -- k Material Code
        AND k.idtnr = l.matnr (+) AND l.meinh = c.menee -- l BUOM Purchase Order Quantity
        AND k.idtnr = m.matnr (+) -- m Material BUOM
        AND d.orgid = n.purch_order_type_code (+) -- n Purchase Order Type Sign
        AND LTRIM(k.idtnr, '0') = r.matl_code (+)
        AND q.company_code = i_company_code
        AND o.company_code = i_company_code
        AND (TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date)
        AND a.valdtn_status = ods_constants.valdtn_valid;

      -- Commit.
      COMMIT;

  END IF;

  -- Completed purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Completed PURCH_ORDER_FACT_OLD aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO purch_order_fact_savepoint;
    write_log(ods_constants.data_type_purch_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.PURCH_ORDER_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END purch_order_fact_aggregation;



FUNCTION purch_order_fact_agg_v2 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- LOCAL DECLARATIONS
  type typ_table is table of dds.purch_order_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  -- CURSOR DECLARATIONS
  -- Check whether any purchase orders were received or updated yesterday.
  CURSOR csr_purch_order_count IS
    SELECT
      count(*) AS purch_order_count
    FROM
      sap_sto_po_hdr a,
      sap_sto_po_org b,
      sap_sto_po_pnr c,
      sap_cus_hdr d,
      sap_ref_dat e
    WHERE a.belnr = b.belnr
      AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
      AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
      AND a.belnr = c.belnr
      AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
      AND c.partn = d.lifnr -- d Customer
      AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
      AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
      AND e.z_tabname = 'T001W'
      AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_purch_order_count csr_purch_order_count%ROWTYPE;

  /*-*/
  /* Select query
  /*-*/
  CURSOR csr_select IS
    SELECT
        q.company_code,
        a.belnr AS purch_order_doc_num,
        c.posex AS purch_order_doc_line_num,
        d.orgid AS purch_order_type_code,
        c.purch_order_line_status AS purch_order_line_status,
        TO_DATE(e.datum, 'YYYYMMDD') AS creatn_date,
        p.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(f.datum, 'YYYYMMDD') AS purch_order_eff_date,
        g.mars_yyyyppdd AS purch_order_eff_yyyyppdd,
        g.mars_week AS purch_order_eff_yyyyppw,
        q.sales_org_code,
        q.distbn_chnl_code,
        q.division_code,
        a.curcy AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        a.wkurs AS exch_rate,
        b.orgid AS purchg_company_code,
        a.augru AS purch_order_reasn_code,
        h.partn AS vendor_code,
        j.cust_code_plant AS cust_code,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.menge, 0) AS purch_order_qty,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL((c.menge / l.umren * l.umrez), 0)  AS base_uom_purch_order_qty,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                          0), 0) AS purch_order_qty_gross_tonnes, -- Purchase Order Qty Gross Tonnes
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                          0), 0) AS purch_order_qty_net_tonnes, -- Purchase Order Qty Net Tonnes*/
        LTRIM(k.idtnr, 0) AS matl_code,
        c.menee AS purch_order_qty_uom_code,
        m.meins AS purch_order_qty_base_uom_code,
        c.werks AS plant_code,
        c.lgort AS storage_locn_code,
        c.abrvw AS purch_order_usage_code,
        ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_usdx) AS gsv,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0) AS gsv_xactn,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_aud,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_usd,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_eur,
        ods_app.currcy_conv(0,
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv,
        0 AS niv_xactn,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_aud,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_usd,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_eur,
        ods_app.currcy_conv(0,
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv,
        0 AS ngv_xactn,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_aud,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_usd,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_eur,
        DECODE(q.company_code, ods_constants.company_australia, DECODE(b.orgid, ods_constants.company_new_zealand, ods_constants.abbrd_yes, ods_constants.abbrd_no),
                               ods_constants.company_new_zealand, DECODE(b.orgid, ods_constants.company_australia, ods_constants.abbrd_yes, ods_constants.abbrd_no),
                               ods_constants.abbrd_no) AS mfanz_icb_flag,
        DECODE(q.company_code || q.distbn_chnl_code, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(r.bus_sgmnt_code, '01', '55', 
                                                                                                                                                           '02', '57', 
                                                                                                                                                           '05', '56', q.division_code),
                                                                                                                                  DECODE(q.division_code, '57', DECODE(r.bus_sgmnt_code, '02', '57', '05', '56', q.division_code), q.division_code)) demand_plng_grp_division_code
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_gen c,
        sap_sto_po_org d,
        sap_sto_po_dat e,
        sap_sto_po_dat f,
        mars_date g,
        sap_sto_po_pnr h,
        sap_cus_hdr i,
        (SELECT
            trim(substr(t1.z_data, 4, 4))   AS plant_code,
            trim(substr(t1.z_data, 42, 10)) AS cust_code_plant
          FROM
            sap_ref_dat t1
          WHERE
            t1.z_tabname = 'T001W') j,
        sap_sto_po_oid k,
        sap_mat_uom l,
        sap_mat_hdr m,
        purch_order_type n,
        company o,
        mars_date p,
        (SELECT
           trim(substr(t1.z_data, 173, 3)) AS company_code,
           trim(substr(t1.z_data, 42, 10)) AS cust_code,
           trim(substr(t1.z_data, 173, 3)) AS sales_org_code,
           trim(substr(t1.z_data, 223, 2)) AS distbn_chnl_code,
           trim(substr(t1.z_data, 225, 2)) AS division_code
         FROM
           sap_ref_dat t1
         WHERE
           t1.z_tabname = 'T001W') q,
        matl_dim r
      WHERE
        a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purchasing_company -- b Purchasing Company
        AND a.belnr = c.belnr -- c Purchase Order Line
        AND a.belnr = d.belnr AND d.qualf = ods_constants.purch_order_purch_order_type -- d Purchase Order Type
        AND d.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = e.belnr AND e.iddat = ods_constants.purch_order_creation_date -- e Creation Date
        AND e.datum = p.yyyymmdd_date -- p Creation Effective YYYYPPDD
        AND a.belnr = f.belnr AND f.iddat =  ods_constants.purch_order_effective_date -- f Purchase Order Effective Date
        AND f.datum = g.yyyymmdd_date -- g Purchase Order Effective YYYYPPDD
        AND a.belnr = h.belnr AND h.parvw = ods_constants.purch_order_vendor -- h  Vendor
        AND h.partn = i.lifnr -- i Vendor Code
        AND i.kunnr = q.cust_code
        -- Plant Join
        AND c.werks = j.plant_code(+)
        AND c.belnr = k.belnr (+) AND c.genseq = k.genseq (+) AND k.qualf (+) = ods_constants.purch_order_material_code -- k Material Code
        AND k.idtnr = l.matnr (+) AND l.meinh = c.menee -- l BUOM Purchase Order Quantity
        AND k.idtnr = m.matnr (+) -- m Material BUOM
        AND d.orgid = n.purch_order_type_code (+) -- n Purchase Order Type Sign
        AND LTRIM(k.idtnr, '0') = r.matl_code (+)
        AND q.company_code = i_company_code
        AND o.company_code = i_company_code
        AND (TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date)
        AND a.valdtn_status = ods_constants.valdtn_valid;

BEGIN

  -- Starting purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Starting PURCH_ORDER_FACT_OLD aggregation V2.');

  -- Fetch the record from the csr_purch_order_count cursor.
  dbms_application_info.SET_MODULE('PO agg v2', '1');
  OPEN csr_purch_order_count;
  FETCH csr_purch_order_count INTO rv_purch_order_count.purch_order_count;
  CLOSE csr_purch_order_count;

  -- If any purchase orders were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 2, 'Checking whether any purchase orders' ||
    ' were received or updated yesterday.');

  IF rv_purch_order_count.purch_order_count > 0 THEN

    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT purch_order_fact_savepoint_v2;

    -- Delete any purchase orders that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Deleting from PURCH_ORDER_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    dbms_application_info.SET_MODULE('PO agg v2', '2');
    DELETE FROM dds.purch_order_fact_old
    WHERE company_code = i_company_code
    AND purch_order_doc_num IN
     (SELECT
        a.belnr
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_pnr c,
        sap_cus_hdr d,
        sap_ref_dat e
      WHERE a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
        AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = c.belnr
        AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
        AND c.partn = d.lifnr -- d Customer
        AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
        AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
        AND e.z_tabname = 'T001W'
        AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date);


    /*-*/
    /* Retrieve the select data in to the array
    /*-*/
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Selecting the PURCH_ORDER_FACT_OLD table data.');
    dbms_application_info.SET_MODULE('PO agg v2', '3');
    tbl_insert.delete;
    open csr_select;
    fetch csr_select bulk collect into tbl_insert;
    close csr_select;


    /*-*/
    /* Insert the array data into PURCH_ORDER_FACT
    /*-*/
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Inserting into the PURCH_ORDER_FACT_OLD table.');
    forall idx in 1..tbl_insert.count
       insert into dds.purch_order_fact_old values tbl_insert(idx);

    -- Commit.
    COMMIT;

  END IF;

  -- Completed purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Completed PURCH_ORDER_FACT_OLD aggregation.');

  -- Completed successfully.
  dbms_application_info.SET_MODULE(null, null);
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO purch_order_fact_savepoint_v2;
    write_log(ods_constants.data_type_purch_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.PURCH_ORDER_FACT_AGG_V2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    dbms_application_info.SET_MODULE(null, null);
  RETURN constants.error;
END purch_order_fact_agg_v2;


FUNCTION purch_order_fact_agg_v3 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- LOCAL DECLARATIONS
  type typ_table is table of dds.purch_order_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  -- CURSOR DECLARATIONS
  -- Check whether any purchase orders were received or updated yesterday.
  CURSOR csr_purch_order_count IS
    SELECT
      count(*) AS purch_order_count
    FROM
      sap_sto_po_hdr a,
      sap_sto_po_org b,
      sap_sto_po_pnr c,
      sap_cus_hdr d,
      sap_ref_dat e
    WHERE a.belnr = b.belnr
      AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
      AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
      AND a.belnr = c.belnr
      AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
      AND c.partn = d.lifnr -- d Customer
      AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
      AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
      AND e.z_tabname = 'T001W'
      AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_purch_order_count csr_purch_order_count%ROWTYPE;

  /*-*/
  /* Select query
  /*-*/
  CURSOR csr_select IS
    SELECT
        q.company_code,
        a.belnr AS purch_order_doc_num,
        c.posex AS purch_order_doc_line_num,
        d.orgid AS purch_order_type_code,
        c.purch_order_line_status AS purch_order_line_status,
        TO_DATE(e.datum, 'YYYYMMDD') AS creatn_date,
        p.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(f.datum, 'YYYYMMDD') AS purch_order_eff_date,
        g.mars_yyyyppdd AS purch_order_eff_yyyyppdd,
        g.mars_week AS purch_order_eff_yyyyppw,
        q.sales_org_code,
        q.distbn_chnl_code,
        q.division_code,
        a.curcy AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        a.wkurs AS exch_rate,
        b.orgid AS purchg_company_code,
        a.augru AS purch_order_reasn_code,
        h.partn AS vendor_code,
        j.cust_code_plant AS cust_code,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.menge, 0) AS purch_order_qty,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL((c.menge / l.umren * l.umrez), 0)  AS base_uom_purch_order_qty,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                          0), 0) AS purch_order_qty_gross_tonnes, -- Purchase Order Qty Gross Tonnes
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                          0), 0) AS purch_order_qty_net_tonnes, -- Purchase Order Qty Net Tonnes*/
        LTRIM(k.idtnr, 0) AS matl_code,
        c.menee AS purch_order_qty_uom_code,
        m.meins AS purch_order_qty_base_uom_code,
        c.werks AS plant_code,
        c.lgort AS storage_locn_code,
        c.abrvw AS purch_order_usage_code,
        ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_usdx) AS gsv,
        DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0) AS gsv_xactn,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_aud,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_usd,
        ods_app.currcy_conv(ods_app.currcy_conv(DECODE(n.purch_order_type_sign, '-', -1, 1) * NVL(c.netwr, 0),
                                                a.curcy,
                                                o.company_currcy,
                                                TO_DATE(e.datum,'YYYYMMDD'),
                                                ods_constants.exchange_rate_type_usdx),
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS gsv_eur,
        ods_app.currcy_conv(0,
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv,
        0 AS niv_xactn,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_aud,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_usd,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_eur,
        ods_app.currcy_conv(0,
                            a.curcy,
                            o.company_currcy,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv,
        0 AS ngv_xactn,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_aud,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_usd,
        ods_app.currcy_conv(0,
                            o.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_eur,
        DECODE(q.company_code, ods_constants.company_australia, DECODE(b.orgid, ods_constants.company_new_zealand, ods_constants.abbrd_yes, ods_constants.abbrd_no),
                               ods_constants.company_new_zealand, DECODE(b.orgid, ods_constants.company_australia, ods_constants.abbrd_yes, ods_constants.abbrd_no),
                               ods_constants.abbrd_no) AS mfanz_icb_flag,
        DECODE(q.company_code || q.distbn_chnl_code, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(r.bus_sgmnt_code, '01', '55', 
                                                                                                                                                           '02', '57', 
                                                                                                                                                           '05', '56', q.division_code),
                                                                                                                                  DECODE(q.division_code, '57', DECODE(r.bus_sgmnt_code, '02', '57', '05', '56', q.division_code), q.division_code)) demand_plng_grp_division_code
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_gen c,
        sap_sto_po_org d,
        sap_sto_po_dat e,
        sap_sto_po_dat f,
        mars_date g,
        sap_sto_po_pnr h,
        sap_cus_hdr i,
        (SELECT trim(substr(t1.z_data, 4, 4))   AS plant_code,
                trim(substr(t1.z_data, 42, 10)) AS cust_code_plant
           FROM sap_ref_dat t1
          WHERE t1.z_tabname = 'T001W'
            AND not(trim(substr(t1.z_data, 4, 4)) is null)) j,
        sap_sto_po_oid k,
        sap_mat_uom l,
        sap_mat_hdr m,
        purch_order_type n,
        company o,
        mars_date p,
        (SELECT trim(substr(t1.z_data, 173, 3)) AS company_code,
                trim(substr(t1.z_data, 42, 10)) AS cust_code,
                trim(substr(t1.z_data, 173, 3)) AS sales_org_code,
                trim(substr(t1.z_data, 223, 2)) AS distbn_chnl_code,
                trim(substr(t1.z_data, 225, 2)) AS division_code
           FROM sap_ref_dat t1
          WHERE t1.z_tabname = 'T001W'
            AND trim(substr(t1.z_data, 173, 3)) = i_company_code
            AND not(trim(substr(t1.z_data, 173, 3)) is null)
            AND not(trim(substr(t1.z_data, 42, 10)) is null)) q,
        matl_dim r
      WHERE
        a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purchasing_company -- b Purchasing Company
        AND a.belnr = c.belnr -- c Purchase Order Line
        AND a.belnr = d.belnr AND d.qualf = ods_constants.purch_order_purch_order_type -- d Purchase Order Type
        AND d.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = e.belnr AND e.iddat = ods_constants.purch_order_creation_date -- e Creation Date
        AND e.datum = p.yyyymmdd_date -- p Creation Effective YYYYPPDD
        AND a.belnr = f.belnr AND f.iddat =  ods_constants.purch_order_effective_date -- f Purchase Order Effective Date
        AND f.datum = g.yyyymmdd_date -- g Purchase Order Effective YYYYPPDD
        AND a.belnr = h.belnr AND h.parvw = ods_constants.purch_order_vendor -- h  Vendor
        AND h.partn = i.lifnr -- i Vendor Code
        AND i.kunnr = q.cust_code
        AND c.werks = j.plant_code(+)
        AND c.belnr = k.belnr (+) AND c.genseq = k.genseq (+) AND k.qualf (+) = ods_constants.purch_order_material_code -- k Material Code
        AND k.idtnr = l.matnr (+) AND l.meinh = c.menee -- l BUOM Purchase Order Quantity
        AND k.idtnr = m.matnr (+) -- m Material BUOM
        AND d.orgid = n.purch_order_type_code (+) -- n Purchase Order Type Sign
        AND LTRIM(k.idtnr, '0') = r.matl_code (+)
        AND q.company_code = o.company_code
        AND (TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date)
        AND a.valdtn_status = ods_constants.valdtn_valid;

BEGIN

  -- Starting purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Starting PURCH_ORDER_FACT_OLD aggregation V3.');

  -- Fetch the record from the csr_purch_order_count cursor.
  dbms_application_info.SET_MODULE('PO agg v3', '1');
  OPEN csr_purch_order_count;
  FETCH csr_purch_order_count INTO rv_purch_order_count.purch_order_count;
  CLOSE csr_purch_order_count;

  -- If any purchase orders were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 2, 'Checking whether any purchase orders' ||
    ' were received or updated yesterday.');

  IF rv_purch_order_count.purch_order_count > 0 THEN

    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT purch_order_fact_savepoint_v3;

    -- Delete any purchase orders that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Deleting from PURCH_ORDER_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    dbms_application_info.SET_MODULE('PO agg v3', '2');
    DELETE FROM dds.purch_order_fact_old
    WHERE company_code = i_company_code
    AND purch_order_doc_num IN
     (SELECT
        a.belnr
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_pnr c,
        sap_cus_hdr d,
        sap_ref_dat e
      WHERE a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
        AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = c.belnr
        AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
        AND c.partn = d.lifnr -- d Customer
        AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
        AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
        AND e.z_tabname = 'T001W'
        AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date);

    /*-*/
    /* Retrieve the select data in to the array
    /*-*/
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Selecting the PURCH_ORDER_FACT_OLD table data.');
    dbms_application_info.SET_MODULE('PO agg v3', '3');
    tbl_insert.delete;
    open csr_select;
    fetch csr_select bulk collect into tbl_insert;
    close csr_select;

    /*-*/
    /* Insert the array data into PURCH_ORDER_FACT
    /*-*/
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Inserting into the PURCH_ORDER_FACT_OLD table.');
    forall idx in 1..tbl_insert.count
       insert into dds.purch_order_fact_old values tbl_insert(idx);

    -- Commit.
    COMMIT;

  END IF;

  -- Completed purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Completed PURCH_ORDER_FACT_OLD aggregation V3.');

  -- Completed successfully.
  dbms_application_info.SET_MODULE(null, null);
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO purch_order_fact_savepoint_v3;
    write_log(ods_constants.data_type_purch_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.PURCH_ORDER_FACT_AGG_V3: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    dbms_application_info.SET_MODULE(null, null);
  RETURN constants.error;
END purch_order_fact_agg_v3;



FUNCTION order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sal_ord_hdr.sap_sal_ord_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any sales orders were received or updated yesterday.
  CURSOR csr_order_count IS
    SELECT count(*) AS order_count
    FROM sap_sal_ord_hdr a, sap_sal_ord_org b
    WHERE a.belnr = b.belnr
      AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
      AND b.orgid = i_company_code
      AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_order_count csr_order_count%ROWTYPE;

BEGIN

  -- Starting order_fact aggregation.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 1, 'Starting ORDER_FACT_OLD aggregation.');

  -- Fetch the record from the csr_order_count cursor.
  OPEN csr_order_count;
  FETCH csr_order_count INTO rv_order_count.order_count;
  CLOSE csr_order_count;

  -- If any sales orders were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 2, 'Checking whether any sales orders' ||
    ' were received or updated yesterday.');

  IF rv_order_count.order_count > 0 THEN

    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT order_fact_savepoint;

    -- Delete any sales orders that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Deleting from ORDER_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    DELETE FROM dds.order_fact_old
    WHERE company_code = i_company_code
    AND order_doc_num IN
     (SELECT a.belnr
      FROM sap_sal_ord_hdr a, sap_sal_ord_org b
      WHERE a.belnr = b.belnr
        AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
        AND b.orgid = i_company_code
        AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date);

    -- Insert into order_fact table based on company code and date.
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Inserting into the ORDER_FACT_OLD table.');
    INSERT INTO dds.order_fact_old
      (
      company_code,
      order_doc_num,
      order_doc_line_num,
      cust_order_doc_num,
      cust_order_doc_line_num,
      cust_order_due_date,
      order_type_code,
      order_line_status,
      creatn_date,
      creatn_yyyyppdd,
      order_eff_date,
      order_eff_yyyyppdd,
      order_eff_yyyyppw,
      hdr_sales_org_code,
      hdr_distbn_chnl_code,
      hdr_division_code,
      doc_currcy_code,
      company_currcy_code,
      exch_rate,
      order_reasn_code,
      sold_to_cust_code,
      bill_to_cust_code,
      payer_cust_code,
      order_qty,
      confirmed_qty,
      base_uom_order_qty,
      base_uom_confirmed_qty,
      order_qty_gross_tonnes,
      confirmed_qty_gross_tonnes,
      order_qty_net_tonnes,
      confirmed_qty_net_tonnes,
      ship_to_cust_code,
      matl_code,
      matl_entd,
      order_qty_uom_code,
      order_qty_base_uom_code,
      plant_code,
      storage_locn_code,
      order_usage_code,
      order_gsv,
      confirmed_gsv,
      order_gsv_xactn,
      confirmed_gsv_xactn,
      order_gsv_aud,
      confirmed_gsv_aud,
      order_gsv_usd,
      confirmed_gsv_usd,
      order_gsv_eur,
      confirmed_gsv_eur,
      niv,
      niv_xactn,
      niv_aud,
      niv_usd,
      niv_eur,
      ngv,
      ngv_xactn,
      ngv_aud,
      ngv_usd,
      ngv_eur,
      mfanz_icb_flag,
      order_line_rejectn_code,
      demand_plng_grp_division_code
      )
      SELECT
        b.orgid AS company_code,
        a.belnr AS order_doc_num,
        c.posex AS order_doc_line_num,
        ae.refnr AS cust_order_doc_num,
        ae.zeile AS cust_order_doc_line_num,
        TO_DATE(ae.datum,'YYYYMMDD') AS cust_order_due_date,
        d.orgid AS order_type_code,
        c.order_line_status AS order_line_status,
        TZ_CONV(TO_DATE(e.datum || e.uzeit, 'YYYYMMDDHH24MISS'),'America/New_York','Australia/Victoria') AS creatn_date,
        ad.mars_yyyyppdd AS creatn_yyyyppdd,
        DECODE(TO_DATE(f.edatu,'YYYYMMDD'), NULL, TO_DATE(af.datum,'YYYYMMDD'), TO_DATE(f.edatu, 'YYYYMMDD')) AS order_eff_date,
        DECODE(g.mars_yyyyppdd, NULL, ag.mars_yyyyppdd, g.mars_yyyyppdd) AS order_eff_yyyyppdd,
        DECODE(g.mars_week, NULL, ag.mars_week, g.mars_week) AS order_eff_yyyyppw,
        h.orgid AS hdr_sales_org_code,
        i.orgid AS hdr_distbn_chnl_code,
        j.orgid AS hdr_division_code,
        a.curcy AS doc_currcy_code,
        z.company_currcy AS company_currcy_code,
        a.wkurs AS exch_rate,
        a.augru AS order_reasn_code,
        DECODE(k.partn, NULL, t.partn, k.partn) AS sold_to_cust_code,
        DECODE(l.partn, NULL, u.partn, l.partn) AS bill_to_cust_code,
        DECODE(m.partn, NULL, v.partn, m.partn) AS payer_cust_code,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(c.menge, 0) AS order_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(f.wmeng, 0) AS confirmed_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL((c.menge / p.umren * p.umrez),0)  AS base_uom_order_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL((f.wmeng / p.umren * p.umrez),0)  AS based_uom_confirmed_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                    ods_constants.uom_kilograms, c.brgew / 1000,
                                                                    ods_constants.uom_grams, c.brgew / 1000000,
                                                                    ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                    0), 0) AS order_qty_gross_tonnes, -- Order Qty Gross Tonnes
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                                          0), 0),
                              DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                                          0), 0) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_qty_gross_tonnes, -- Confirmed Qty Gross Tonnes
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                    ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                    ods_constants.uom_grams, c.ntgew / 1000000,
                                                                    ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                    0), 0) AS order_qty_net_tonnes, -- Order Qty Net Tonnes
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                                          0), 0),
                              DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                                          0), 0) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_qty_net_tonnes, -- Confirmed Qty Net Tonnes
        DECODE(r.partn, NULL, w.partn, r.partn) AS ship_to_cust_code,
        LTRIM(n.idtnr, 0) AS matl_code,
        LTRIM(o.idtnr, 0) AS matl_entd,
        c.menee AS order_qty_uom_code,
        x.meins AS order_qty_base_uom_code,
        c.werks AS plant_code,
        c.lgort AS storage_locn_code,
        c.abrvw AS order_usage_code,
        DECODE(y.order_type_sign, '-', -1, 1) /
               exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
               (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs) AS order_gsv,
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) /
                                     exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                              DECODE(y.order_type_sign, '-', -1, 1) /
                                     exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs) /
                                      (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv,  -- Confirmed GSV
        DECODE(y.order_type_sign, '-', -1, 1) *
               (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) +
                DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) +
                DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg)) AS order_gsv_xactn,
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg)),
                              DECODE(y.order_type_sign, '-', -1, 1) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg)) /
                                      (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_xactn, -- Confirmed gsv_xactn
        ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                            exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                           (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                            DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                            DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                            z.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS order_gsv_aud,
        DECODE(c.menge, NULL, ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_aud,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr),
                              ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_aud,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_aud,  -- confirmed gsv_aud
        ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                            exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                           (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                            DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                            DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                            z.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS order_gsv_usd,
        DECODE(c.menge, NULL, ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_usd,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr),
                              ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_usd,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_usd, -- Confirmed gsv_usd
        ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                            exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                           (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                            DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                            DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                            z.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS order_gsv_eur,
        DECODE(c.menge, NULL, ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_eur,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr),
                              ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_eur,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_eur,  -- Confirmed gsv_eur
        0 AS niv,
        0 AS niv_xactn,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_aud,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_usd,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_eur,
        0 AS ngv,
        0 AS ngv_xactn,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_aud,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_usd,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_eur,
        DECODE(b.orgid, ods_constants.company_australia, DECODE(DECODE(r.partn,NULL,w.partn,r.partn), ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.abbrd_no),
                        ods_constants.company_new_zealand, DECODE(DECODE(r.partn,NULL,w.partn,r.partn), ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.abbrd_no),
                        ods_constants.abbrd_no) AS mfanz_icb_flag,
        c.abgru AS order_line_rejectn_code,
        DECODE(b.orgid || i.orgid, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(ah.bus_sgmnt_code, '01', '55', 
                                                                                                                                          '02', '57', 
                                                                                                                                          '05', '56', j.orgid),
                                                                                                                DECODE(j.orgid, '57', DECODE(ah.bus_sgmnt_code, '02', '57', '05', '56', j.orgid), j.orgid)) demand_plng_grp_division_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_org b,
        sap_sal_ord_gen c,
        sap_sal_ord_org d,
        sap_sal_ord_dat e,
        (select belnr, genseq, sum(to_number(wmeng)) as wmeng, max(edatu) as edatu from sap_sal_ord_isc group by belnr, genseq) f,
        mars_date g,
        sap_sal_ord_org h,
        sap_sal_ord_org i,
        sap_sal_ord_org j,
        sap_sal_ord_ipn k,
        sap_sal_ord_ipn l,
        sap_sal_ord_ipn m,
        sap_sal_ord_iid n,
        sap_sal_ord_iid o,
        sap_mat_uom p,
        sap_sal_ord_ipn r,
        sap_sal_ord_ico s,
        sap_sal_ord_pnr t,
        sap_sal_ord_pnr u,
        sap_sal_ord_pnr v,
        sap_sal_ord_pnr w,
        sap_mat_hdr x,
        order_type y,
        company z,
        sap_sal_ord_ico aa,
        sap_sal_ord_ico ab,
        sap_sal_ord_ico ac,
        mars_date ad,
        sap_sal_ord_irf ae,
        sap_sal_ord_dat af,
        mars_date ag,
        matl_dim ah
      WHERE
        a.belnr = b.belnr
        AND b.qualf = ods_constants.sales_order_sales_org  AND b.orgid = i_company_code -- b Sales Organisation
        AND a.belnr = c.belnr -- c Order Line
        AND c.belnr = ae.belnr (+) -- ae Customer order doc number
        AND c.genseq = ae.genseq (+) -- ae Customer order doc line number
        AND ae.qualf (+) = ods_constants.sales_order_cust_order_flag -- Sales customer order flag '001'
        AND (c.abgru IS NULL OR c.abgru = 'ZA')   -- Ignore all rejected order lines
        AND c.pstyv <> 'ZAPS' -- Do not retreive Iten subsitution lines
        AND a.belnr = d.belnr (+) AND d.qualf (+) = ods_constants.sales_order_order_type -- d Order Type
        AND a.belnr = e.belnr AND e.iddat = ods_constants.sales_order_creation_date -- e Creation Date
        AND e.datum = ad.yyyymmdd_date -- ad Creation YYYYPPDD
        AND c.belnr = f.belnr (+) AND c.genseq = f.genseq (+) -- f Order Effective Date
        AND f.edatu = g.yyyymmdd_date (+) -- g Order Effective YYYYPPDD
        AND a.belnr = af.belnr AND af.iddat = ods_constants.sales_order_billing_date -- af Order Effective Date
        AND af.datum = ag.yyyymmdd_date -- ag Order Effective YYYYPPDD
        AND a.belnr = h.belnr AND h.qualf = ods_constants.sales_order_sales_org -- h  Header Sales Organisation
        AND a.belnr = i.belnr (+) AND i.qualf (+) = ods_constants.sales_order_distbn_chnl -- i Header Distribution Channel
        AND a.belnr = j.belnr (+) AND j.qualf (+) = ods_constants.sales_order_division -- i Header Division
        AND c.belnr = k.belnr (+) AND c.genseq = k.genseq (+) AND k.parvw (+) = ods_constants.sales_order_sold_to_partner -- k Sold-To (Partner - Detail record)
        AND c.belnr = l.belnr (+) AND c.genseq = l.genseq (+) AND l.parvw (+) = ods_constants.sales_order_bill_to_partner -- l Bill-To (Partner - Detail record)
        AND c.belnr = m.belnr (+) AND c.genseq = m.genseq (+) AND m.parvw (+) = ods_constants.sales_order_payer_partner -- m Payer-To (Partner - Detail record)
        AND c.belnr = n.belnr (+) AND c.genseq = n.genseq (+) AND n.qualf (+) = ods_constants.sales_order_material_code  -- n Material Code
        AND c.belnr = o.belnr (+) AND c.genseq = o.genseq (+) AND o.qualf (+) = ods_constants.sales_order_material_entered -- o Material Entered
        AND n.idtnr = LTRIM(p.matnr (+), 0) AND p.meinh = c.menee -- p BUOM Order Quantity
        AND n.idtnr = LTRIM(x.matnr (+), 0) -- x Material BUOM
        AND c.belnr = r.belnr (+) AND c.genseq = r.genseq (+) AND r.parvw (+) = ods_constants.sales_order_ship_to_partner -- r Ship-To (Partner - Detail record)
        AND c.belnr = s.belnr (+) AND c.genseq = s.genseq (+) AND s.kotxt (+) = ods_constants.sales_order_gsv -- s GSV
        AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date
        AND a.belnr = t.belnr (+) AND t.parvw (+) = ods_constants.sales_order_sold_to_partner -- k Sold-To (Partner - Header record)
        AND a.belnr = u.belnr (+) AND u.parvw (+) = ods_constants.sales_order_bill_to_partner  -- l Bill-To (Partner - Header record)
        AND a.belnr = v.belnr (+) AND v.parvw (+) = ods_constants.sales_order_payer_partner -- m Payer-To (Partner - Header record)
        AND a.belnr = w.belnr (+) AND w.parvw (+) = ods_constants.sales_order_ship_to_partner -- r Ship-To (Partner - Header record)
        AND d.orgid = y.order_type_code (+) -- y Order Type Sign
        AND y.order_type_gsv_flag = ods_constants.gsv_flag_gsv -- y GSV Order Type
        AND z.company_code = i_company_code
        AND c.belnr = aa.belnr (+) AND c.genseq = aa.genseq (+) AND aa.kschl (+) = ods_constants.sales_order_zv01
        AND c.belnr = ab.belnr (+) AND c.genseq = ab.genseq (+) AND ab.kschl (+) = ods_constants.sales_order_zz01
        AND c.belnr = ac.belnr (+) AND c.genseq = ac.genseq (+) AND ac.kotxt (+) = ods_constants.sales_order_gross_value
        AND LTRIM(n.idtnr, 0) = ah.matl_code (+)
        AND a.valdtn_status = ods_constants.valdtn_valid;

      -- Commit.
      COMMIT;

  END IF;

  -- Completed order_fact aggregation.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 1, 'Completed ORDER_FACT_OLD aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO order_fact_savepoint;
    write_log(ods_constants.data_type_sales_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.ORDER_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END order_fact_aggregation;


FUNCTION order_fact_aggregation_v2 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sal_ord_hdr.sap_sal_ord_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- LOCAL DECLARATIONS
  type typ_table is table of dds.order_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  -- CURSOR DECLARATIONS
  -- Check whether any sales orders were received or updated yesterday.
  CURSOR csr_order_count IS
    SELECT count(*) AS order_count
    FROM sap_sal_ord_hdr a, sap_sal_ord_org b
    WHERE a.belnr = b.belnr
      AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
      AND b.orgid = i_company_code
      AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_order_count csr_order_count%ROWTYPE;

  CURSOR csr_select IS
      SELECT
        b.orgid AS company_code,
        a.belnr AS order_doc_num,
        c.posex AS order_doc_line_num,
        ae.refnr AS cust_order_doc_num,
        ae.zeile AS cust_order_doc_line_num,
        TO_DATE(ae.datum,'YYYYMMDD') AS cust_order_due_date,
        d.orgid AS order_type_code,
        c.order_line_status AS order_line_status,
        TZ_CONV(TO_DATE(e.datum || e.uzeit, 'YYYYMMDDHH24MISS'),'America/New_York','Australia/Victoria') AS creatn_date,
        ad.mars_yyyyppdd AS creatn_yyyyppdd,
        DECODE(TO_DATE(f.edatu,'YYYYMMDD'), NULL, TO_DATE(af.datum,'YYYYMMDD'), TO_DATE(f.edatu, 'YYYYMMDD')) AS order_eff_date,
        DECODE(g.mars_yyyyppdd, NULL, ag.mars_yyyyppdd, g.mars_yyyyppdd) AS order_eff_yyyyppdd,
        DECODE(g.mars_week, NULL, ag.mars_week, g.mars_week) AS order_eff_yyyyppw,
        h.orgid AS hdr_sales_org_code,
        i.orgid AS hdr_distbn_chnl_code,
        j.orgid AS hdr_division_code,
        a.curcy AS doc_currcy_code,
        z.company_currcy AS company_currcy_code,
        a.wkurs AS exch_rate,
        a.augru AS order_reasn_code,
        DECODE(k.partn, NULL, t.partn, k.partn) AS sold_to_cust_code,
        DECODE(l.partn, NULL, u.partn, l.partn) AS bill_to_cust_code,
        DECODE(m.partn, NULL, v.partn, m.partn) AS payer_cust_code,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(c.menge, 0) AS order_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(f.wmeng, 0) AS confirmed_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL((c.menge / p.umren * p.umrez),0)  AS base_uom_order_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL((f.wmeng / p.umren * p.umrez),0)  AS based_uom_confirmed_qty,
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                    ods_constants.uom_kilograms, c.brgew / 1000,
                                                                    ods_constants.uom_grams, c.brgew / 1000000,
                                                                    ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                    0), 0) AS order_qty_gross_tonnes, -- Order Qty Gross Tonnes
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                                          0), 0),
                              DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.brgew,
                                                                                          ods_constants.uom_kilograms, c.brgew / 1000,
                                                                                          ods_constants.uom_grams, c.brgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.brgew / 1000000000,
                                                                                          0), 0) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_qty_gross_tonnes, -- Confirmed Qty Gross Tonnes
        DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                    ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                    ods_constants.uom_grams, c.ntgew / 1000000,
                                                                    ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                    0), 0) AS order_qty_net_tonnes, -- Order Qty Net Tonnes
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                                          0), 0),
                              DECODE(y.order_type_sign, '-', -1, 1) * NVL(DECODE(c.gewei, ods_constants.uom_tonnes, c.ntgew,
                                                                                          ods_constants.uom_kilograms, c.ntgew / 1000,
                                                                                          ods_constants.uom_grams, c.ntgew / 1000000,
                                                                                          ods_constants.uom_milligrams, c.ntgew / 1000000000,
                                                                                          0), 0) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_qty_net_tonnes, -- Confirmed Qty Net Tonnes
        DECODE(r.partn, NULL, w.partn, r.partn) AS ship_to_cust_code,
        LTRIM(n.idtnr, 0) AS matl_code,
        LTRIM(o.idtnr, 0) AS matl_entd,
        c.menee AS order_qty_uom_code,
        x.meins AS order_qty_base_uom_code,
        c.werks AS plant_code,
        c.lgort AS storage_locn_code,
        c.abrvw AS order_usage_code,
        DECODE(y.order_type_sign, '-', -1, 1) /
               exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
               (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs) AS order_gsv,
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) /
                                     exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                              DECODE(y.order_type_sign, '-', -1, 1) /
                                     exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs) /
                                      (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv,  -- Confirmed GSV
        DECODE(y.order_type_sign, '-', -1, 1) *
               (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) +
                DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) +
                DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg)) AS order_gsv_xactn,
        DECODE(c.menge, NULL, DECODE(y.order_type_sign, '-', -1, 1) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg)),
                              DECODE(y.order_type_sign, '-', -1, 1) *
                                     (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) +
                                      DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) +
                                      DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg)) /
                                      (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_xactn, -- Confirmed gsv_xactn
        ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                            exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                           (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                            DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                            DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                            z.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS order_gsv_aud,
        DECODE(c.menge, NULL, ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_aud,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr),
                              ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_aud,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_aud,  -- confirmed gsv_aud
        ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                            exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                           (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                            DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                            DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                            z.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS order_gsv_usd,
        DECODE(c.menge, NULL, ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_usd,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr),
                              ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_usd,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_usd, -- Confirmed gsv_usd
        ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                            exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                           (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                            DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                            DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                            z.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS order_gsv_eur,
        DECODE(c.menge, NULL, ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_eur,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr),
                              ods_app.currcy_conv(DECODE(y.order_type_sign, '-', -1, 1) /
                                                  exch_rate_factor('ICB', a.curcy, z.company_currcy, TO_DATE(e.datum,'YYYYMMDD')) *
                                                  (DECODE(s.alckz, '-', -1, 1) * DECODE(s.betrg, NULL, 0, s.betrg) * a.wkurs +
                                                   DECODE(aa.alckz, '-', -1, 1) * DECODE(aa.betrg, NULL, 0, aa.betrg) * a.wkurs +
                                                   DECODE(ab.kschl, NULL, 0, 1) * DECODE(ac.alckz, '-', -1, 1) * DECODE(ac.betrg, NULL, 0, ac.betrg) * a.wkurs),
                                                   z.company_currcy,
                                                   ods_constants.currency_eur,
                                                   TO_DATE(e.datum,'YYYYMMDD'),
                                                   ods_constants.exchange_rate_type_mppr) / (NVL(c.menge,0)) * NVL(f.wmeng,0)) AS confirmed_gsv_eur,  -- Confirmed gsv_eur
        0 AS niv,
        0 AS niv_xactn,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_aud,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_usd,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS niv_eur,
        0 AS ngv,
        0 AS ngv_xactn,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_aud,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_aud,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_usd,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_usd,
        ods_app.currcy_conv(0,
                            z.company_currcy,
                            ods_constants.currency_eur,
                            TO_DATE(e.datum,'YYYYMMDD'),
                            ods_constants.exchange_rate_type_mppr) AS ngv_eur,
        DECODE(b.orgid, ods_constants.company_australia, DECODE(DECODE(r.partn,NULL,w.partn,r.partn), ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                      ods_constants.abbrd_no),
                        ods_constants.company_new_zealand, DECODE(DECODE(r.partn,NULL,w.partn,r.partn), ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.abbrd_no),
                        ods_constants.abbrd_no) AS mfanz_icb_flag,
        c.abgru AS order_line_rejectn_code,
        DECODE(b.orgid || i.orgid, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(ah.bus_sgmnt_code, '01', '55', 
                                                                                                                                          '02', '57', 
                                                                                                                                          '05', '56', j.orgid),
                                                                                                                DECODE(j.orgid, '57', DECODE(ah.bus_sgmnt_code, '02', '57', '05', '56', j.orgid), j.orgid)) demand_plng_grp_division_code
      FROM
        sap_sal_ord_hdr a,
        sap_sal_ord_org b,
        sap_sal_ord_gen c,
        sap_sal_ord_org d,
        sap_sal_ord_dat e,
        (select belnr, genseq, sum(to_number(wmeng)) as wmeng, max(edatu) as edatu from sap_sal_ord_isc group by belnr, genseq) f,
        mars_date g,
        sap_sal_ord_org h,
        sap_sal_ord_org i,
        sap_sal_ord_org j,
        sap_sal_ord_ipn k,
        sap_sal_ord_ipn l,
        sap_sal_ord_ipn m,
        sap_sal_ord_iid n,
        sap_sal_ord_iid o,
        sap_mat_uom p,
        sap_sal_ord_ipn r,
        sap_sal_ord_ico s,
        sap_sal_ord_pnr t,
        sap_sal_ord_pnr u,
        sap_sal_ord_pnr v,
        sap_sal_ord_pnr w,
        sap_mat_hdr x,
        order_type y,
        company z,
        sap_sal_ord_ico aa,
        sap_sal_ord_ico ab,
        sap_sal_ord_ico ac,
        mars_date ad,
        sap_sal_ord_irf ae,
        sap_sal_ord_dat af,
        mars_date ag,
        matl_dim ah
      WHERE
        a.belnr = b.belnr
        AND b.qualf = ods_constants.sales_order_sales_org  AND b.orgid = i_company_code -- b Sales Organisation
        AND a.belnr = c.belnr -- c Order Line
        AND c.belnr = ae.belnr (+) -- ae Customer order doc number
        AND c.genseq = ae.genseq (+) -- ae Customer order doc line number
        AND ae.qualf (+) = ods_constants.sales_order_cust_order_flag -- Sales customer order flag '001'
        AND (c.abgru IS NULL OR c.abgru = 'ZA')   -- Ignore all rejected order lines
        AND c.pstyv <> 'ZAPS' -- Do not retreive Iten subsitution lines
        AND a.belnr = d.belnr (+) AND d.qualf (+) = ods_constants.sales_order_order_type -- d Order Type
        AND a.belnr = e.belnr AND e.iddat = ods_constants.sales_order_creation_date -- e Creation Date
        AND e.datum = ad.yyyymmdd_date -- ad Creation YYYYPPDD
        AND c.belnr = f.belnr (+) AND c.genseq = f.genseq (+) -- f Order Effective Date
        AND f.edatu = g.yyyymmdd_date (+) -- g Order Effective YYYYPPDD
        AND a.belnr = af.belnr AND af.iddat = ods_constants.sales_order_billing_date -- af Order Effective Date
        AND af.datum = ag.yyyymmdd_date -- ag Order Effective YYYYPPDD
        AND a.belnr = h.belnr AND h.qualf = ods_constants.sales_order_sales_org -- h  Header Sales Organisation
        AND a.belnr = i.belnr (+) AND i.qualf (+) = ods_constants.sales_order_distbn_chnl -- i Header Distribution Channel
        AND a.belnr = j.belnr (+) AND j.qualf (+) = ods_constants.sales_order_division -- i Header Division
        AND c.belnr = k.belnr (+) AND c.genseq = k.genseq (+) AND k.parvw (+) = ods_constants.sales_order_sold_to_partner -- k Sold-To (Partner - Detail record)
        AND c.belnr = l.belnr (+) AND c.genseq = l.genseq (+) AND l.parvw (+) = ods_constants.sales_order_bill_to_partner -- l Bill-To (Partner - Detail record)
        AND c.belnr = m.belnr (+) AND c.genseq = m.genseq (+) AND m.parvw (+) = ods_constants.sales_order_payer_partner -- m Payer-To (Partner - Detail record)
        AND c.belnr = n.belnr (+) AND c.genseq = n.genseq (+) AND n.qualf (+) = ods_constants.sales_order_material_code  -- n Material Code
        AND c.belnr = o.belnr (+) AND c.genseq = o.genseq (+) AND o.qualf (+) = ods_constants.sales_order_material_entered -- o Material Entered
        AND n.idtnr = LTRIM(p.matnr (+), 0) AND p.meinh = c.menee -- p BUOM Order Quantity
        AND n.idtnr = LTRIM(x.matnr (+), 0) -- x Material BUOM
        AND c.belnr = r.belnr (+) AND c.genseq = r.genseq (+) AND r.parvw (+) = ods_constants.sales_order_ship_to_partner -- r Ship-To (Partner - Detail record)
        AND c.belnr = s.belnr (+) AND c.genseq = s.genseq (+) AND s.kotxt (+) = ods_constants.sales_order_gsv -- s GSV
        AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date
        AND a.belnr = t.belnr (+) AND t.parvw (+) = ods_constants.sales_order_sold_to_partner -- k Sold-To (Partner - Header record)
        AND a.belnr = u.belnr (+) AND u.parvw (+) = ods_constants.sales_order_bill_to_partner  -- l Bill-To (Partner - Header record)
        AND a.belnr = v.belnr (+) AND v.parvw (+) = ods_constants.sales_order_payer_partner -- m Payer-To (Partner - Header record)
        AND a.belnr = w.belnr (+) AND w.parvw (+) = ods_constants.sales_order_ship_to_partner -- r Ship-To (Partner - Header record)
        AND d.orgid = y.order_type_code (+) -- y Order Type Sign
        AND y.order_type_gsv_flag = ods_constants.gsv_flag_gsv -- y GSV Order Type
        AND z.company_code = i_company_code
        AND c.belnr = aa.belnr (+) AND c.genseq = aa.genseq (+) AND aa.kschl (+) = ods_constants.sales_order_zv01
        AND c.belnr = ab.belnr (+) AND c.genseq = ab.genseq (+) AND ab.kschl (+) = ods_constants.sales_order_zz01
        AND c.belnr = ac.belnr (+) AND c.genseq = ac.genseq (+) AND ac.kotxt (+) = ods_constants.sales_order_gross_value
        AND LTRIM(n.idtnr, 0) = ah.matl_code (+)
        AND a.valdtn_status = ods_constants.valdtn_valid;

BEGIN

  -- Starting order_fact aggregation.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 1, 'Starting ORDER_FACT_OLD aggregation V2.');

  -- Fetch the record from the csr_order_count cursor.
  OPEN csr_order_count;
  FETCH csr_order_count INTO rv_order_count.order_count;
  CLOSE csr_order_count;

  -- If any sales orders were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 2, 'Checking whether any sales orders' ||
    ' were received or updated yesterday.');

  IF rv_order_count.order_count > 0 THEN

    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT order_fact_savepoint_v2;

    -- Delete any sales orders that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Deleting from ORDER_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    DELETE FROM dds.order_fact_old
    WHERE company_code = i_company_code
    AND order_doc_num IN
     (SELECT a.belnr
      FROM sap_sal_ord_hdr a, sap_sal_ord_org b
      WHERE a.belnr = b.belnr
        AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
        AND b.orgid = i_company_code
        AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date);

    /*-*/
    /* Retrieve the select data in to the array
    /*-*/
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Selecting the ORDER_FACT_OLD table data.');
    tbl_insert.delete;
    open csr_select;
    fetch csr_select bulk collect into tbl_insert;
    close csr_select;

    /*-*/
    /* Insert the array data into ORDER_FACT
    /*-*/
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Inserting into the ORDER_FACT_OLD table.');
    forall idx in 1..tbl_insert.count
       insert into dds.order_fact_old values tbl_insert(idx);

    -- Commit.
    COMMIT;

  END IF;

  -- Completed order_fact aggregation.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 1, 'Completed ORDER_FACT_OLD aggregation V2.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO order_fact_savepoint_v2;
    write_log(ods_constants.data_type_sales_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.ORDER_FACT_AGGREGATION_V2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END order_fact_aggregation_v2;



FUNCTION delivery_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_del_hdr.sap_del_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any deliveries were received or updated yesterday.
  CURSOR csr_delivery_count IS
    SELECT /*+ INDEX(SAP_DEL_HDR SAP_DEL_HDR_I1) */ count(*) AS delivery_count
    FROM sap_del_hdr
    WHERE vkorg = i_company_code
      AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_delivery_count csr_delivery_count%ROWTYPE;

BEGIN

  -- Starting dlvry_fact aggregation.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 1, 'Starting DLVRY_FACT_OLD aggregation.');

  -- Fetch the record from the csr_delivery_count cursor.
  OPEN csr_delivery_count;
  FETCH csr_delivery_count INTO rv_delivery_count.delivery_count;
  CLOSE csr_delivery_count;

  -- If any deliveries were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 2, 'Checking whether any deliveries' ||
    ' were received or updated yesterday.');

  IF rv_delivery_count.delivery_count > 0 THEN

    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT delivery_fact_savepoint;

    -- Delete any deliveries that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Deleting from DLVRY_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    DELETE FROM dds.dlvry_fact_old
    WHERE company_code = i_company_code
      AND dlvry_doc_num IN
        (SELECT /*+ INDEX(SAP_DEL_HDR SAP_DEL_HDR_I1) */ vbeln
         FROM sap_del_hdr
         WHERE vkorg = i_company_code
           AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date);

    -- Insert into dlvry_fact table based on company code and date.
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Inserting into the DLVRY_FACT_OLD table.');
    INSERT INTO dds.dlvry_fact_old
      (
      company_code,
      dlvry_doc_num,
      dlvry_doc_line_num,
      order_doc_num,
      order_doc_line_num,
      purch_order_doc_num,
      purch_order_doc_line_num,
      dlvry_type_code,
      dlvry_line_status,
      dlvry_procg_stage,
      creatn_date,
      creatn_yyyyppdd,
      dlvry_eff_date,
      dlvry_eff_yyyyppdd,
      dlvry_eff_yyyyppw,
      goods_issue_date,
      goods_issue_yyyyppdd,
      hdr_sales_org_code,
      det_distbn_chnl_code,
      det_division_code,
      doc_currcy_code,
      company_currcy_code,
      exch_rate,
      sold_to_cust_code,
      bill_to_cust_code,
      payer_cust_code,
      dlvry_qty,
      base_uom_dlvry_qty,
      dlvry_qty_gross_tonnes,
      dlvry_qty_net_tonnes,
      ship_to_cust_code,
      matl_code,
      matl_entd,
      dlvry_qty_uom_code,
      dlvry_qty_base_uom_code,
      plant_code,
      storage_locn_code,
      gsv,
      gsv_xactn,
      gsv_aud,
      gsv_usd,
      gsv_eur,
      niv,
      niv_xactn,
      niv_aud,
      niv_usd,
      niv_eur,
      ngv,
      ngv_xactn,
      ngv_aud,
      ngv_usd,
      ngv_eur,
      mfanz_icb_flag,
      demand_plng_grp_division_code
      )
      SELECT
        a.vkorg AS company_code,
        a.vbeln AS dlvry_doc_num,
        b.posnr AS dlvry_doc_line_num,
        f.belnr AS order_doc_num,
        f.posnr AS order_doc_line_num,
        NULL purch_order_doc_num,
        NULL purch_order_doc_line_num,
        a.lfart AS dlvry_type_code,
        b.dlvry_line_status AS dlvry_line_status,
        a.dlvry_procg_stage AS dlvry_procg_stage,
        TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') AS creatn_date,
        s.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') AS dlvry_eff_date,
        e.mars_yyyyppdd AS dlvry_eff_yyyyppdd,
        e.mars_week AS dlvry_eff_yyyyppw,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, NULL, q.isdd),'YYYYMMDD') END AS goods_issue_date,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN r.mars_yyyyppdd END AS good_issue_yyyyppdd,
        a.vkorg AS hdr_sales_org_code,
        b.vtweg AS det_distbn_chnl_code,
        g.hdr_division_code AS det_division_code,
        g.doc_currcy_code AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        g.exch_rate AS exch_rate,
        h.partner_id AS sold_to_cust_code,
        i.partner_id AS bill_to_cust_code,
        j.partner_id AS payer_cust_code,
        DECODE(p.order_type_sign, '-', -1, 1) * NVL(b.lfimg, 0) AS dlvry_qty,
        DECODE(p.order_type_sign, '-', -1, 1) * NVL((b.lfimg / m.umren * m.umrez), 0)  AS base_uom_dlvry_qty,
        DECODE(p.order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.brgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_gross_tonnes, -- Delivery Qty Gross Tonnes
        DECODE(p.order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.ntgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_net_tonnes, -- Delivery Qty Net Tonnes
        l.partner_id AS ship_to_cust_code,
        LTRIM(b.matnr, 0) AS matl_code,
        LTRIM(b.matwa, 0) AS matl_entd,
        b.vrkme AS dlvry_qty_uom_code,
        n.meins AS dlvry_qty_base_uom_code,
        b.werks AS plant_code,
        b.lgort AS storage_locn_code,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv / g.order_qty)) * b.lfimg) AS gsv,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_xactn / g.order_qty)) * b.lfimg) AS gsv_xactn,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_aud / g.order_qty)) * b.lfimg) AS gsv_aud,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_usd / g.order_qty)) * b.lfimg) AS gsv_usd,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_eur / g.order_qty)) * b.lfimg) AS gsv_eur,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv / g.order_qty)) * b.lfimg) AS niv,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_aud / g.order_qty)) * b.lfimg) AS niv_aud,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_xactn / g.order_qty)) * b.lfimg) AS niv_xactn,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_usd / g.order_qty)) * b.lfimg) AS niv_usd,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_eur / g.order_qty)) * b.lfimg) AS niv_eur,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv / g.order_qty)) * b.lfimg) AS ngv,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_xactn / g.order_qty)) * b.lfimg) AS ngv_xactn,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_aud / g.order_qty)) * b.lfimg) AS ngv_aud,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_usd / g.order_qty)) * b.lfimg) AS ngv_usd,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_eur / g.order_qty)) * b.lfimg) AS ngv_eur,
        DECODE(a.vkorg, ods_constants.company_australia, DECODE(l.partner_id, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.abbrd_no),
                        ods_constants.company_new_zealand, DECODE(l.partner_id, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.abbrd_no),
                        ods_constants.abbrd_no) AS mfanz_icb_flag,
         DECODE(a.vkorg || b.vtweg, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(t.bus_sgmnt_code, '01', '55', 
                                                                                                                                          '02', '57', 
                                                                                                                                          '05', '56', g.hdr_division_code),
                                                                                                                 DECODE(g.hdr_division_code, '57', DECODE(t.bus_sgmnt_code, '02', '57', '05', '56', g.hdr_division_code), g.hdr_division_code)) demand_plng_grp_division_code
      FROM
        sap_del_hdr a,
        sap_del_det b,
        sap_del_tim c,
        sap_del_tim d,
        mars_date e,
        sap_del_irf f,
        dds.order_fact_old g,
        sap_del_add h,
        sap_del_add i,
        sap_del_add j,
        sap_del_add l,
        sap_mat_uom m,
        sap_mat_hdr n,
        company o,
        order_type p,
        sap_del_tim q,
        mars_date r,
        mars_date s,
        matl_dim t
      WHERE
        a.vbeln = b.vbeln -- b Delivery Line
        AND b.pstyv NOT IN ('ZBCH', 'ZRBC') -- Return Main Item Lines only from the sap_del_det table
        AND a.vkorg = i_company_code -- Company
        AND a.vbeln = c.vbeln AND c.qualf = ods_constants.delivery_document_date -- c Creation Date
        AND TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') = TO_DATE(s.yyyymmdd_date, 'YYYYMMDD') -- e Creation Effective YYYYPPDD
        AND a.vbeln = d.vbeln AND d.qualf = ods_constants.delivery_billing_date -- d Delivery Effective Date
        AND TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') = TO_DATE(e.yyyymmdd_date, 'YYYYMMDD') -- e Delivery Effective YYYYPPDD
        AND a.vbeln = q.vbeln
        AND q.qualf = ods_constants.delivery_goods_issue_date -- Delivery Goods Issue Date '006'
        AND TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, LTRIM(q.ntanf,' 0'), LTRIM(q.isdd,' 0')), 'YYYYMMDD') = TO_DATE(r.yyyymmdd_date, 'YYYYMMDD') -- q Goods Issue Effective YYYYPPDD
        AND b.vbeln = f.vbeln AND b.detseq = f.detseq AND f.qualf IN (ods_constants.delivery_sales_order_flag,
                                                                      ods_constants.delivery_return_flag,
                                                                      ods_constants.delivery_order_wo_charge_flag,
                                                                      ods_constants.delivery_cr_memo_flag,
                                                                      ods_constants.delivery_db_memo_flag) AND f.irfseq = 1 -- f Reference to Sales Order Document and Line Number
                                                                                                                            -- Note: Return the first Sales Order, i.e. IRFSEQ = 1, as there may be multiple Sales Orders for the Delivery
        AND f.belnr = g.order_doc_num AND f.posnr = g.order_doc_line_num -- g Order Fact Note: Do not return record if Sales Order cannot be found.
        AND a.vbeln = h.vbeln (+) AND h.partner_q (+) = ods_constants.delivery_sold_to_partner -- Sold-To Customer
        AND a.vbeln = i.vbeln (+) AND i.partner_q (+) = ods_constants.delivery_bill_to_partner -- Bill-To Customer
        AND a.vbeln = j.vbeln (+) AND j.partner_q (+) = ods_constants.delivery_payer_partner -- Payer Customer
        AND a.vbeln = l.vbeln (+) AND l.partner_q (+) = ods_constants.delivery_ship_to_partner -- Ship-To Customer
        AND b.matnr = m.matnr (+) AND b.vrkme = m.meinh (+) -- m Base UOM Delivery Quantity
        AND b.matnr = n.matnr (+) -- n Material Weights
        AND LTRIM(b.matnr, 0) = t.matl_code (+)
        AND TRUNC(a.sap_del_hdr_lupdt, 'DD') = i_aggregation_date
        AND o.company_code = i_company_code
        AND g.order_type_code = p.order_type_code (+) -- p Order Type Sign
        AND p.order_type_gsv_flag = ods_constants.gsv_flag_gsv -- p GSV Order Type
        AND a.valdtn_status = ods_constants.valdtn_valid
      UNION
      SELECT
        a.vkorg AS company_code,
        a.vbeln AS dlvry_doc_num,
        b.posnr AS dlvry_doc_line_num,
        NULL AS order_doc_num,
        NULL AS order_doc_line_num,
        f.belnr AS purch_order_doc_num,
        SUBSTR(f.posnr,2,5) AS purch_order_doc_line_num,
        a.lfart AS dlvry_type_code,
        b.dlvry_line_status AS dlvry_line_status,
        a.dlvry_procg_stage AS dlvry_procg_stage,
        TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') AS creatn_date,
        s.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') AS dlvry_eff_date,
        e.mars_yyyyppdd AS dlvry_eff_yyyyppdd,
        e.mars_week AS dlvry_eff_yyyyppw,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, NULL, q.isdd),'YYYYMMDD') END AS goods_issue_date,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN r.mars_yyyyppdd END AS good_issue_yyyyppdd,
        a.vkorg AS hdr_sales_org_code,
        b.vtweg AS det_distbn_chnl_code,
        g.division_code AS det_division_code,
        g.doc_currcy_code AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        g.exch_rate AS exch_rate,
        h.partner_id AS sold_to_cust_code,
        i.partner_id AS bill_to_cust_code,
        j.partner_id AS payer_cust_code,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL(b.lfimg, 0) AS dlvry_qty,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL((b.lfimg / m.umren * m.umrez), 0)  AS base_uom_dlvry_qty,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.brgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_gross_tonnes, -- Delivery Qty Gross Tonnes
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.ntgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_net_tonnes, -- Delivery Qty Net Tonnes
        l.partner_id AS ship_to_cust_code,
        LTRIM(b.matnr, 0) AS matl_code,
        LTRIM(b.matwa, 0) AS matl_entd,
        b.vrkme AS dlvry_qty_uom_code,
        n.meins AS dlvry_qty_base_uom_code,
        b.werks AS plant_code,
        b.lgort AS storage_locn_code,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv / g.purch_order_qty)) * b.lfimg) AS gsv,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_xactn / g.purch_order_qty)) * b.lfimg) AS gsv_xactn,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_aud / g.purch_order_qty)) * b.lfimg) AS gsv_aud,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_usd / g.purch_order_qty)) * b.lfimg) AS gsv_usd,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_eur / g.purch_order_qty)) * b.lfimg) AS gsv_eur,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv / g.purch_order_qty)) * b.lfimg) AS niv,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_aud / g.purch_order_qty)) * b.lfimg) AS niv_aud,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_xactn / g.purch_order_qty)) * b.lfimg) AS niv_xactn,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_usd / g.purch_order_qty)) * b.lfimg) AS niv_usd,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_eur / g.purch_order_qty)) * b.lfimg) AS niv_eur,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv / g.purch_order_qty)) * b.lfimg) AS ngv,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_xactn / g.purch_order_qty)) * b.lfimg) AS ngv_xactn,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_aud / g.purch_order_qty)) * b.lfimg) AS ngv_aud,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_usd / g.purch_order_qty)) * b.lfimg) AS ngv_usd,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_eur / g.purch_order_qty)) * b.lfimg) AS ngv_eur,
        DECODE(a.vkorg, ods_constants.company_australia, DECODE(l.partner_id, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.abbrd_no),
                        ods_constants.company_new_zealand, DECODE(l.partner_id, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.abbrd_no),
                        ods_constants.abbrd_no) AS mfanz_icb_flag,
        DECODE(a.vkorg || b.vtweg, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(t.bus_sgmnt_code, '01', '55', 
                                                                                                                                         '02', '57', 
                                                                                                                                         '05', '56', g.division_code),
                                                                                                                DECODE(g.division_code, '57', DECODE(t.bus_sgmnt_code, '02', '57', '05', '56', g.division_code), g.division_code)) demand_plng_grp_division_code
      FROM
        sap_del_hdr a,
        sap_del_det b,
        sap_del_tim c,
        sap_del_tim d,
        mars_date e,
        sap_del_irf f,
        dds.purch_order_fact_old g,
        sap_del_add h,
        sap_del_add i,
        sap_del_add j,
        sap_del_add l,
        sap_mat_uom m,
        sap_mat_hdr n,
        company o,
        purch_order_type p,
        sap_del_tim q,
        mars_date r,
        mars_date s,
        matl_dim t
      WHERE
        a.vbeln = b.vbeln -- b Delivery Line
        AND b.pstyv NOT IN ('ZBCH', 'ZRBC') -- Return Main Item Lines only from the sap_del_det table
        AND a.vkorg = i_company_code -- Company
        AND a.vbeln = c.vbeln AND c.qualf = ods_constants.delivery_document_date -- c Creation Date
        AND TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') = TO_DATE(s.yyyymmdd_date, 'YYYYMMDD') -- e Creation Effective YYYYPPDD
        AND a.vbeln = d.vbeln AND d.qualf = ods_constants.delivery_billing_date -- d Delivery Effective Date
        AND TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') = TO_DATE(e.yyyymmdd_date, 'YYYYMMDD') -- e Delivery Effective YYYYPPDD
        AND a.vbeln = q.vbeln
        AND q.qualf = ods_constants.delivery_goods_issue_date -- Delivery Goods Issue Date '006'
        AND TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, LTRIM(q.ntanf,' 0'), LTRIM(q.isdd,' 0')), 'YYYYMMDD') = TO_DATE(r.yyyymmdd_date, 'YYYYMMDD') -- q Goods Issue Effective YYYYPPDD
        AND b.vbeln = f.vbeln AND b.detseq = f.detseq AND f.qualf = ods_constants.delivery_purch_order_flag
        AND f.irfseq = 1 -- f Reference to Purchase Order Document and Line Number                                                                                                                          -- Note: Return the first Sales Order, i.e. IRFSEQ = 1, as there may be multiple Sales Orders for the Delivery
        AND f.belnr = g.purch_order_doc_num
        AND LTRIM(f.posnr,'0') = LTRIM(g.purch_order_doc_line_num,'0') -- g purch_order_fact Note: Do not return record if Purchase Order cannot be found.
        AND a.vbeln = h.vbeln (+) AND h.partner_q (+) = ods_constants.delivery_sold_to_partner -- Sold-To Customer
        AND a.vbeln = i.vbeln (+) AND i.partner_q (+) = ods_constants.delivery_bill_to_partner -- Bill-To Customer
        AND a.vbeln = j.vbeln (+) AND j.partner_q (+) = ods_constants.delivery_payer_partner -- Payer Customer
        AND a.vbeln = l.vbeln (+) AND l.partner_q (+) = ods_constants.delivery_ship_to_partner -- Ship-To Customer
        AND b.matnr = m.matnr (+) AND b.vrkme = m.meinh (+) -- m Base UOM Delivery Quantity
        AND b.matnr = n.matnr (+) -- n Material Weights
        AND LTRIM(b.matnr, 0) = t.matl_code (+)
        AND TRUNC(a.sap_del_hdr_lupdt, 'DD') = i_aggregation_date
        AND o.company_code = i_company_code
        AND g.purch_order_type_code = p.purch_order_type_code (+) -- p Order Type Sign
        AND a.valdtn_status = ods_constants.valdtn_valid;

    -- Commit.
    COMMIT;

  END IF;

  -- Completed dlvry_fact aggregation.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 1, 'Completed DLVRY_FACT_OLD aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO delivery_fact_savepoint;
    write_log(ods_constants.data_type_delivery,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.DELIVERY_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END delivery_fact_aggregation;

FUNCTION delivery_fact_aggregation_v2 (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_del_hdr.sap_del_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- LOCAL DECLARATIONS
  type typ_table is table of dds.dlvry_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  -- CURSOR DECLARATIONS
  -- Check whether any deliveries were received or updated yesterday.
  CURSOR csr_delivery_count IS
    SELECT /*+ INDEX(SAP_DEL_HDR SAP_DEL_HDR_I1) */ count(*) AS delivery_count
    FROM sap_del_hdr
    WHERE vkorg = i_company_code
      AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_delivery_count csr_delivery_count%ROWTYPE;

  CURSOR csr_select IS
      SELECT
        a.vkorg AS company_code,
        a.vbeln AS dlvry_doc_num,
        b.posnr AS dlvry_doc_line_num,
        f.belnr AS order_doc_num,
        f.posnr AS order_doc_line_num,
        NULL purch_order_doc_num,
        NULL purch_order_doc_line_num,
        a.lfart AS dlvry_type_code,
        b.dlvry_line_status AS dlvry_line_status,
        a.dlvry_procg_stage AS dlvry_procg_stage,
        TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') AS creatn_date,
        s.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') AS dlvry_eff_date,
        e.mars_yyyyppdd AS dlvry_eff_yyyyppdd,
        e.mars_week AS dlvry_eff_yyyyppw,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, NULL, q.isdd),'YYYYMMDD') END AS goods_issue_date,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN r.mars_yyyyppdd END AS good_issue_yyyyppdd,
        a.vkorg AS hdr_sales_org_code,
        b.vtweg AS det_distbn_chnl_code,
        g.hdr_division_code AS det_division_code,
        g.doc_currcy_code AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        g.exch_rate AS exch_rate,
        h.partner_id AS sold_to_cust_code,
        i.partner_id AS bill_to_cust_code,
        j.partner_id AS payer_cust_code,
        DECODE(p.order_type_sign, '-', -1, 1) * NVL(b.lfimg, 0) AS dlvry_qty,
        DECODE(p.order_type_sign, '-', -1, 1) * NVL((b.lfimg / m.umren * m.umrez), 0)  AS base_uom_dlvry_qty,
        DECODE(p.order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.brgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_gross_tonnes, -- Delivery Qty Gross Tonnes
        DECODE(p.order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.ntgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_net_tonnes, -- Delivery Qty Net Tonnes
        l.partner_id AS ship_to_cust_code,
        LTRIM(b.matnr, 0) AS matl_code,
        LTRIM(b.matwa, 0) AS matl_entd,
        b.vrkme AS dlvry_qty_uom_code,
        n.meins AS dlvry_qty_base_uom_code,
        b.werks AS plant_code,
        b.lgort AS storage_locn_code,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv / g.order_qty)) * b.lfimg) AS gsv,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_xactn / g.order_qty)) * b.lfimg) AS gsv_xactn,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_aud / g.order_qty)) * b.lfimg) AS gsv_aud,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_usd / g.order_qty)) * b.lfimg) AS gsv_usd,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.order_gsv_eur / g.order_qty)) * b.lfimg) AS gsv_eur,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv / g.order_qty)) * b.lfimg) AS niv,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_aud / g.order_qty)) * b.lfimg) AS niv_aud,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_xactn / g.order_qty)) * b.lfimg) AS niv_xactn,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_usd / g.order_qty)) * b.lfimg) AS niv_usd,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.niv_eur / g.order_qty)) * b.lfimg) AS niv_eur,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv / g.order_qty)) * b.lfimg) AS ngv,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_xactn / g.order_qty)) * b.lfimg) AS ngv_xactn,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_aud / g.order_qty)) * b.lfimg) AS ngv_aud,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_usd / g.order_qty)) * b.lfimg) AS ngv_usd,
        DECODE(p.order_type_sign, '-', -1, 1) * (DECODE(g.order_qty,0,0,(g.ngv_eur / g.order_qty)) * b.lfimg) AS ngv_eur,
        DECODE(a.vkorg, ods_constants.company_australia, DECODE(l.partner_id, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.abbrd_no),
                        ods_constants.company_new_zealand, DECODE(l.partner_id, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.abbrd_no),
                        ods_constants.abbrd_no) AS mfanz_icb_flag,
        DECODE(a.vkorg || b.vtweg, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(t.bus_sgmnt_code, '01', '55', 
                                                                                                                                         '02', '57', 
                                                                                                                                         '05', '56', g.hdr_division_code),
                                                                                                                DECODE(g.hdr_division_code, '57', DECODE(t.bus_sgmnt_code, '02', '57', '05', '56', g.hdr_division_code), g.hdr_division_code)) demand_plng_grp_division_code
      FROM
        sap_del_hdr a,
        sap_del_det b,
        sap_del_tim c,
        sap_del_tim d,
        mars_date e,
        sap_del_irf f,
        dds.order_fact_old g,
        sap_del_add h,
        sap_del_add i,
        sap_del_add j,
        sap_del_add l,
        sap_mat_uom m,
        sap_mat_hdr n,
        company o,
        order_type p,
        sap_del_tim q,
        mars_date r,
        mars_date s,
        matl_dim t
      WHERE
        a.vbeln = b.vbeln -- b Delivery Line
        AND b.pstyv NOT IN ('ZBCH', 'ZRBC') -- Return Main Item Lines only from the sap_del_det table
        AND a.vkorg = i_company_code -- Company
        AND a.vbeln = c.vbeln AND c.qualf = ods_constants.delivery_document_date -- c Creation Date
        AND TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') = TO_DATE(s.yyyymmdd_date, 'YYYYMMDD') -- e Creation Effective YYYYPPDD
        AND a.vbeln = d.vbeln AND d.qualf = ods_constants.delivery_billing_date -- d Delivery Effective Date
        AND TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') = TO_DATE(e.yyyymmdd_date, 'YYYYMMDD') -- e Delivery Effective YYYYPPDD
        AND a.vbeln = q.vbeln
        AND q.qualf = ods_constants.delivery_goods_issue_date -- Delivery Goods Issue Date '006'
        AND TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, LTRIM(q.ntanf,' 0'), LTRIM(q.isdd,' 0')), 'YYYYMMDD') = TO_DATE(r.yyyymmdd_date, 'YYYYMMDD') -- q Goods Issue Effective YYYYPPDD
        AND b.vbeln = f.vbeln AND b.detseq = f.detseq AND f.qualf IN (ods_constants.delivery_sales_order_flag,
                                                                      ods_constants.delivery_return_flag,
                                                                      ods_constants.delivery_order_wo_charge_flag,
                                                                      ods_constants.delivery_cr_memo_flag,
                                                                      ods_constants.delivery_db_memo_flag) AND f.irfseq = 1 -- f Reference to Sales Order Document and Line Number
                                                                                                                            -- Note: Return the first Sales Order, i.e. IRFSEQ = 1, as there may be multiple Sales Orders for the Delivery
        AND f.belnr = g.order_doc_num AND f.posnr = g.order_doc_line_num -- g Order Fact Note: Do not return record if Sales Order cannot be found.
        AND a.vbeln = h.vbeln (+) AND h.partner_q (+) = ods_constants.delivery_sold_to_partner -- Sold-To Customer
        AND a.vbeln = i.vbeln (+) AND i.partner_q (+) = ods_constants.delivery_bill_to_partner -- Bill-To Customer
        AND a.vbeln = j.vbeln (+) AND j.partner_q (+) = ods_constants.delivery_payer_partner -- Payer Customer
        AND a.vbeln = l.vbeln (+) AND l.partner_q (+) = ods_constants.delivery_ship_to_partner -- Ship-To Customer
        AND b.matnr = m.matnr (+) AND b.vrkme = m.meinh (+) -- m Base UOM Delivery Quantity
        AND b.matnr = n.matnr (+) -- n Material Weights
        AND LTRIM(b.matnr, 0) = t.matl_code (+)
        AND TRUNC(a.sap_del_hdr_lupdt, 'DD') = i_aggregation_date
        AND o.company_code = i_company_code
        AND g.order_type_code = p.order_type_code (+) -- p Order Type Sign
        AND p.order_type_gsv_flag = ods_constants.gsv_flag_gsv -- p GSV Order Type
        AND a.valdtn_status = ods_constants.valdtn_valid
      UNION
      SELECT
        a.vkorg AS company_code,
        a.vbeln AS dlvry_doc_num,
        b.posnr AS dlvry_doc_line_num,
        NULL AS order_doc_num,
        NULL AS order_doc_line_num,
        f.belnr AS purch_order_doc_num,
        SUBSTR(f.posnr,2,5) AS purch_order_doc_line_num,
        a.lfart AS dlvry_type_code,
        b.dlvry_line_status AS dlvry_line_status,
        a.dlvry_procg_stage AS dlvry_procg_stage,
        TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') AS creatn_date,
        s.mars_yyyyppdd AS creatn_yyyyppdd,
        TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') AS dlvry_eff_date,
        e.mars_yyyyppdd AS dlvry_eff_yyyyppdd,
        e.mars_week AS dlvry_eff_yyyyppw,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, NULL, q.isdd),'YYYYMMDD') END AS goods_issue_date,
        CASE WHEN a.mesfct = ods_constants.delivery_pick_flag THEN r.mars_yyyyppdd END AS good_issue_yyyyppdd,
        a.vkorg AS hdr_sales_org_code,
        b.vtweg AS det_distbn_chnl_code,
        g.division_code AS det_division_code,
        g.doc_currcy_code AS doc_currcy_code,
        o.company_currcy AS company_currcy_code,
        g.exch_rate AS exch_rate,
        h.partner_id AS sold_to_cust_code,
        i.partner_id AS bill_to_cust_code,
        j.partner_id AS payer_cust_code,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL(b.lfimg, 0) AS dlvry_qty,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL((b.lfimg / m.umren * m.umrez), 0)  AS base_uom_dlvry_qty,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.brgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.brgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_gross_tonnes, -- Delivery Qty Gross Tonnes
        DECODE(p.purch_order_type_sign, '-', -1, 1) * NVL(DECODE(n.gewei, ods_constants.uom_tonnes, (b.lfimg / m.umren * m.umrez) * n.ntgew,
                                                                    ods_constants.uom_kilograms, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000),
                                                                    ods_constants.uom_grams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000),
                                                                    ods_constants.uom_milligrams, (b.lfimg / m.umren * m.umrez) * (n.ntgew / 1000000000),
                                                                    0), 0) AS dlvry_qty_net_tonnes, -- Delivery Qty Net Tonnes
        l.partner_id AS ship_to_cust_code,
        LTRIM(b.matnr, 0) AS matl_code,
        LTRIM(b.matwa, 0) AS matl_entd,
        b.vrkme AS dlvry_qty_uom_code,
        n.meins AS dlvry_qty_base_uom_code,
        b.werks AS plant_code,
        b.lgort AS storage_locn_code,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv / g.purch_order_qty)) * b.lfimg) AS gsv,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_xactn / g.purch_order_qty)) * b.lfimg) AS gsv_xactn,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_aud / g.purch_order_qty)) * b.lfimg) AS gsv_aud,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_usd / g.purch_order_qty)) * b.lfimg) AS gsv_usd,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.gsv_eur / g.purch_order_qty)) * b.lfimg) AS gsv_eur,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv / g.purch_order_qty)) * b.lfimg) AS niv,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_aud / g.purch_order_qty)) * b.lfimg) AS niv_aud,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_xactn / g.purch_order_qty)) * b.lfimg) AS niv_xactn,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_usd / g.purch_order_qty)) * b.lfimg) AS niv_usd,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.niv_eur / g.purch_order_qty)) * b.lfimg) AS niv_eur,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv / g.purch_order_qty)) * b.lfimg) AS ngv,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_xactn / g.purch_order_qty)) * b.lfimg) AS ngv_xactn,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_aud / g.purch_order_qty)) * b.lfimg) AS ngv_aud,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_usd / g.purch_order_qty)) * b.lfimg) AS ngv_usd,
        DECODE(p.purch_order_type_sign, '-', -1, 1) * (DECODE(g.purch_order_qty,0,0,(g.ngv_eur / g.purch_order_qty)) * b.lfimg) AS ngv_eur,
        DECODE(a.vkorg, ods_constants.company_australia, DECODE(l.partner_id, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                              ods_constants.abbrd_no),
                        ods_constants.company_new_zealand, DECODE(l.partner_id, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                ods_constants.abbrd_no),
                        ods_constants.abbrd_no) AS mfanz_icb_flag,
        DECODE(a.vkorg || b.vtweg, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(t.bus_sgmnt_code, '01', '55', 
                                                                                                                                         '02', '57', 
                                                                                                                                         '05', '56', g.division_code),
                                                                                                                DECODE(g.division_code, '57', DECODE(t.bus_sgmnt_code, '02', '57', '05', '56', g.division_code), g.division_code)) demand_plng_grp_division_code
      FROM
        sap_del_hdr a,
        sap_del_det b,
        sap_del_tim c,
        sap_del_tim d,
        mars_date e,
        sap_del_irf f,
        dds.purch_order_fact_old g,
        sap_del_add h,
        sap_del_add i,
        sap_del_add j,
        sap_del_add l,
        sap_mat_uom m,
        sap_mat_hdr n,
        company o,
        purch_order_type p,
        sap_del_tim q,
        mars_date r,
        mars_date s,
        matl_dim t
      WHERE
        a.vbeln = b.vbeln -- b Delivery Line
        AND b.pstyv NOT IN ('ZBCH', 'ZRBC') -- Return Main Item Lines only from the sap_del_det table
        AND a.vkorg = i_company_code -- Company
        AND a.vbeln = c.vbeln AND c.qualf = ods_constants.delivery_document_date -- c Creation Date
        AND TO_DATE(DECODE(LTRIM(c.isdd,' 0'), NULL, LTRIM(c.ntanf,' 0'), LTRIM(c.isdd,' 0')), 'YYYYMMDD') = TO_DATE(s.yyyymmdd_date, 'YYYYMMDD') -- e Creation Effective YYYYPPDD
        AND a.vbeln = d.vbeln AND d.qualf = ods_constants.delivery_billing_date -- d Delivery Effective Date
        AND TO_DATE(DECODE(LTRIM(d.isdd,' 0'), NULL, LTRIM(d.ntanf,' 0'), LTRIM(d.isdd,' 0')), 'YYYYMMDD') = TO_DATE(e.yyyymmdd_date, 'YYYYMMDD') -- e Delivery Effective YYYYPPDD
        AND a.vbeln = q.vbeln
        AND q.qualf = ods_constants.delivery_goods_issue_date -- Delivery Goods Issue Date '006'
        AND TO_DATE(DECODE(LTRIM(q.isdd,' 0'), NULL, LTRIM(q.ntanf,' 0'), LTRIM(q.isdd,' 0')), 'YYYYMMDD') = TO_DATE(r.yyyymmdd_date, 'YYYYMMDD') -- q Goods Issue Effective YYYYPPDD
        AND b.vbeln = f.vbeln AND b.detseq = f.detseq AND f.qualf = ods_constants.delivery_purch_order_flag
        AND f.irfseq = 1 -- f Reference to Purchase Order Document and Line Number                                                                                                                          -- Note: Return the first Sales Order, i.e. IRFSEQ = 1, as there may be multiple Sales Orders for the Delivery
        AND f.belnr = g.purch_order_doc_num
        AND LTRIM(f.posnr,'0') = LTRIM(g.purch_order_doc_line_num,'0') -- g purch_order_fact Note: Do not return record if Purchase Order cannot be found.
        AND a.vbeln = h.vbeln (+) AND h.partner_q (+) = ods_constants.delivery_sold_to_partner -- Sold-To Customer
        AND a.vbeln = i.vbeln (+) AND i.partner_q (+) = ods_constants.delivery_bill_to_partner -- Bill-To Customer
        AND a.vbeln = j.vbeln (+) AND j.partner_q (+) = ods_constants.delivery_payer_partner -- Payer Customer
        AND a.vbeln = l.vbeln (+) AND l.partner_q (+) = ods_constants.delivery_ship_to_partner -- Ship-To Customer
        AND b.matnr = m.matnr (+) AND b.vrkme = m.meinh (+) -- m Base UOM Delivery Quantity
        AND b.matnr = n.matnr (+) -- n Material Weights
        AND LTRIM(b.matnr, 0) = t.matl_code (+)
        AND TRUNC(a.sap_del_hdr_lupdt, 'DD') = i_aggregation_date
        AND o.company_code = i_company_code
        AND g.purch_order_type_code = p.purch_order_type_code (+) -- p Order Type Sign
        AND a.valdtn_status = ods_constants.valdtn_valid;

BEGIN

  -- Starting dlvry_fact aggregation.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 1, 'Starting DLVRY_FACT_OLD aggregation V2.');

  -- Fetch the record from the csr_delivery_count cursor.
  OPEN csr_delivery_count;
  FETCH csr_delivery_count INTO rv_delivery_count.delivery_count;
  CLOSE csr_delivery_count;

  -- If any deliveries were received or updated yesterday continue the aggregation process.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 2, 'Checking whether any deliveries' ||
    ' were received or updated yesterday.');

  IF rv_delivery_count.delivery_count > 0 THEN

    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Aggregating Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT delivery_fact_savepoint_v2;

    -- Delete any deliveries that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Deleting from DLVRY_FACT_OLD based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    DELETE FROM dds.dlvry_fact_old
    WHERE company_code = i_company_code
      AND dlvry_doc_num IN
        (SELECT /*+ INDEX(SAP_DEL_HDR SAP_DEL_HDR_I1) */ vbeln
         FROM sap_del_hdr
         WHERE vkorg = i_company_code
           AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date);

    /*-*/
    /* Retrieve the select data in to the array
    /*-*/
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Selecting the DLVRY_FACT_OLD table data.');
    tbl_insert.delete;
    open csr_select;
    fetch csr_select bulk collect into tbl_insert;
    close csr_select;

    /*-*/
    /* Insert the array data into DLVRY_FACT
    /*-*/
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Inserting into the DLVRY_FACT_OLD table.');
    forall idx in 1..tbl_insert.count
       insert into dds.dlvry_fact_old values tbl_insert(idx);

    -- Commit.
    COMMIT;

  END IF;

  -- Completed dlvry_fact aggregation.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 1, 'Completed DLVRY_FACT_OLD aggregation V2.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO delivery_fact_savepoint_v2;
    write_log(ods_constants.data_type_delivery,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.DELIVERY_FACT_AGGREGATION_V2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END delivery_fact_aggregation_v2;




FUNCTION forecast_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_fcst_type_code             fcst_hdr.fcst_type_code%TYPE;
  v_sales_org_code             fcst_hdr.sales_org_code%TYPE;
  v_distbn_chnl_code           fcst_hdr.distbn_chnl_code%TYPE;
  v_division_code              fcst_hdr.division_code%TYPE;
  v_moe_code                   fcst_hdr.moe_code%TYPE;
  v_adjust_min_casting_yyyypp  NUMBER(6);
  v_adjust_min_casting_yyyyppw NUMBER(7);

  -- CURSOR DECLARATIONS
  -- Check whether any forecasts are to be aggregated.
  CURSOR csr_forecast IS
    SELECT DISTINCT
      fcst_type_code,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      moe_code
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid;
    rv_forecast csr_forecast%ROWTYPE;

  -- Select the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_min_casting_period IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_period csr_min_casting_period%ROWTYPE;

  -- Select all casting periods starting at the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_casting_period IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      (casting_year || LPAD(casting_period,2,0)) AS casting_yyyypp
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) >= v_adjust_min_casting_yyyypp
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period) ASC;
    rv_casting_period csr_casting_period%ROWTYPE;

  -- Select the minimum casting week for a forecast that is to be aggregated (used for forecast type FCST).
  CURSOR csr_min_casting_week IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0) || casting_week) AS min_casting_yyyyppw,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_week csr_min_casting_week%ROWTYPE;

  -- Select all casting weeks starting at the minimum casting week for a weekly forecast that is to be aggregated.
  CURSOR csr_casting_week IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      casting_week AS casting_w,
      (casting_year || LPAD(casting_period,2,0) || casting_week) AS casting_yyyyppw
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) || casting_week >= v_adjust_min_casting_yyyyppw
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period || casting_week) ASC;
  rv_casting_week csr_casting_week%ROWTYPE;

BEGIN

  -- Starting fcst_fact aggregation.
  write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 1, 'Starting FCST_FACT aggregation.');

  -- Loop through all records in the cursor.
  write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 2, 'Check whether any forecasts are' ||
    ' to be aggregated.');

  FOR rv_forecast IN csr_forecast LOOP

    -- Handling the following unique forecast type.
    write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Handling - Forecast Type/MOE/Sales Org/Distribute Channel/Division [' ||
      rv_forecast.fcst_type_code || '/' || rv_forecast.moe_code || '/' || rv_forecast.sales_org_code ||
       '/' || rv_forecast.distbn_chnl_code || '/' || rv_forecast.division_code || '].');

    -- Now pass cursor results into variables.
    v_fcst_type_code :=  rv_forecast.fcst_type_code;
    v_sales_org_code := rv_forecast.sales_org_code;
    v_distbn_chnl_code := rv_forecast.distbn_chnl_code;
    v_division_code := rv_forecast.division_code;
    v_moe_code := rv_forecast.moe_code;

  /* -----------------------------------------------------------------------------------
    Check to see if the forecast type is weekly i.e. FCST. If it is then process
    weekly forecast, if not then bypass this section as the forecast is a period forecast.
  -------------------------------------------------------------------------------------*/

  IF v_fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

      -- Fetch only the first record from the csr_min_casting_week cursor.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_week cursor.');

      OPEN csr_min_casting_week;
      FETCH csr_min_casting_week INTO rv_min_casting_week;
      CLOSE csr_min_casting_week;

      -- Fetched the minimum casting_yyyyppw for the forecast being aggregated.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'The forecast being aggregated' ||
        ' has the Minimum Casting week of [' || rv_min_casting_week.min_casting_yyyyppw || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_week.current_fcst_flag || '].');

      -- Update the min_casting_yyyyppw variable based on the status of the current_fcst_flag.
      IF rv_min_casting_week.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        /*
        The current_fcst_flag = 'D' (Deleted) therefore set min_casting_yyyyppw to that of the prior
        forecast before the forecast which is to be deleted.
        */
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Updating the min_casting_yyyyppw' ||
          ' as the current_fcst_flag = ''D'' (Deleted).');

        SELECT MAX(casting_year || LPAD(casting_period,2,0) || casting_week) INTO v_adjust_min_casting_yyyyppw
        FROM fcst_hdr
        WHERE (casting_year || LPAD(casting_period,2,0) || casting_week) < rv_min_casting_week.min_casting_yyyyppw
          AND company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND moe_code = v_moe_code
          AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
          AND valdtn_status = ods_constants.valdtn_valid;

        -- If no prior forecast exists then set v_adjust_min_casting_yyyyppw to zero.
        IF v_adjust_min_casting_yyyyppw IS NULL THEN
          v_adjust_min_casting_yyyyppw := 0;
        END IF;

      ELSE
        -- Else the current_fcst_flag = 'Y', therefore use min_casting_yyyyppw.
        v_adjust_min_casting_yyyyppw := rv_min_casting_week.min_casting_yyyyppw;

      END IF;

      /*
      Loop through and aggregate forecast for all casting weeks starting with the minimum
      changed casting week through to the maximum casting week for the forecast.
      */
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
        ' starting with the minimum casting week through to the maximum casting week.');

      FOR rv_casting_week IN csr_casting_week LOOP
        -- Create a savepoint.
        SAVEPOINT forecast_fact_savepoint;

        -- Delete forecasts from the fcst_fact table that are to be rebuilt.
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Deleting from FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');
        DELETE FROM fcst_fact
        WHERE company_code = i_company_code
        AND fcst_type_code = v_fcst_type_code
        AND sales_org_code = v_sales_org_code
        AND distbn_chnl_code = v_distbn_chnl_code
        AND ((division_code = v_division_code) OR
             (division_code IS NULL AND v_division_code IS NULL))
        AND (moe_code = v_moe_code OR moe_code IS NULL)
        AND fcst_yyyyppw > rv_casting_week.casting_yyyyppw;

        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Delete Count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Insert the forecast into the fcst_fact table.
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Inserting into FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');

        INSERT INTO fcst_fact
          (
          company_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          moe_code,
          fcst_type_code,
          fcst_yyyypp,
          fcst_yyyyppw,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          currcy_code,
          fcst_value,
          fcst_value_aud,
          fcst_value_usd,
          fcst_value_eur,
          fcst_qty,
          fcst_qty_gross_tonnes,
          fcst_qty_net_tonnes,
          base_value,
          base_qty,
          aggreg_mkt_actvty_value,
          aggreg_mkt_actvty_qty,
          lock_value,
          lock_qty,
          rcncl_value,
          rcncl_qty,
          auto_adjmt_value,
          auto_adjmt_qty,
          override_value,
          override_qty,
          mkt_actvty_value,
          mkt_actvty_qty,
          data_driven_event_value,
          data_driven_event_qty,
          tgt_impact_value,
          tgt_impact_qty,
          dfn_adjmt_value,
          dfn_adjmt_qty
          )
          SELECT
            t1.company_code,
            t1.sales_org_code,
            t1.distbn_chnl_code,
            t1.division_code,
            t1.moe_code,
            t1.fcst_type_code,
            t1.fcst_yyyypp,
            t1.fcst_yyyyppw,
            t1.demand_plng_grp_code,
            t1.cntry_code,
            t1.region_code,
            t1.multi_mkt_acct_code,
            t1.banner_code,
            t1.cust_buying_grp_code,
            t1.acct_assgnmnt_grp_code,
            t1.pos_format_grpg_code,
            t1.distbn_route_code,
            t1.cust_code,
            t1.matl_zrep_code,
            t1.matl_tdu_code,
            t1.currcy_code,
            t1.fcst_value,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
            t1.fcst_qty,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
            base_value,
            base_qty,
            aggreg_mkt_actvty_value,
            aggreg_mkt_actvty_qty,
            lock_value,
            lock_qty,
            rcncl_value,
            rcncl_qty,
            auto_adjmt_value,
            auto_adjmt_qty,
            override_value,
            override_qty,
            mkt_actvty_value,
            mkt_actvty_qty,
            data_driven_event_value,
            data_driven_event_qty,
            tgt_impact_value,
            tgt_impact_qty,
            dfn_adjmt_value,
            dfn_adjmt_qty
          FROM  -- Sum up to material level before calling the functions to convert currency and tonnes for performance
            (SELECT /*+ INDEX(B FCST_DTL_PK) */
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week) AS fcst_yyyyppw,
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
               LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
               b.currcy_code,
               SUM(b.fcst_value) as fcst_value,
               SUM(b.fcst_qty) AS fcst_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
             FROM
               fcst_hdr a,
               fcst_dtl b
             WHERE
               a.fcst_hdr_code = b.fcst_hdr_code
               AND (a.casting_year = rv_casting_week.casting_yyyy AND
                    a.casting_period = rv_casting_week.casting_pp AND
                    a.casting_week = rv_casting_week.casting_w)
               AND a.company_code = i_company_code
               AND a.fcst_type_code = v_fcst_type_code
               AND a.sales_org_code = v_sales_org_code
               AND a.distbn_chnl_code = v_distbn_chnl_code
               AND ((a.division_code = v_division_code) OR
                    (a.division_code IS NULL AND v_division_code IS NULL))
               AND a.moe_code = v_moe_code
               AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
               AND a.valdtn_status = ods_constants.valdtn_valid
             GROUP BY
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               (b.fcst_year || LPAD(b.fcst_period,2,0)),
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week),
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               b.matl_zrep_code,
               b.matl_tdu_code,
               b.currcy_code ) t1,
            company t2,
            sap_mat_hdr t3
         WHERE t1.company_code = t2.company_code
         AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Insert Count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Commit.
        COMMIT;

      END LOOP;

  ELSE --Do fact entry for forecast types other than the weekly FCST type.

      -- Fetch only the first record from the csr_min_casting_period cursor.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_period cursor.');

      OPEN csr_min_casting_period;
      FETCH csr_min_casting_period INTO rv_min_casting_period;
      CLOSE csr_min_casting_period;

      -- Fetched the minimum casting_yyyypp for the forecast being aggregated.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'The forecast being handled' ||
        ' has the Minimum Casting Period of [' || rv_min_casting_period.min_casting_yyyypp || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_period.current_fcst_flag || '].');

      -- Update the min_casting_yyyypp variable based on the status of the current_fcst_flag.
      IF rv_min_casting_period.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        /*
        The current_fcst_flag = 'D' (Deleted) therefore set min_casting_yyyypp to that of the prior
        forecast before the forecast which is to be deleted.
        */
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Updating the min_casting_yyyypp' ||
          ' as the current_fcst_flag = ''D'' (Deleted).');

        SELECT MAX(casting_year || LPAD(casting_period,2,0)) INTO v_adjust_min_casting_yyyypp
        FROM fcst_hdr
        WHERE (casting_year || LPAD(casting_period,2,0)) < rv_min_casting_period.min_casting_yyyypp
          AND company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND moe_code = v_moe_code
          AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
          AND valdtn_status = ods_constants.valdtn_valid;

        -- If no prior forecast exists then set v_adjust_min_casting_yyyypp to zero.
        IF v_adjust_min_casting_yyyypp IS NULL THEN
          v_adjust_min_casting_yyyypp := 0;
        END IF;

      ELSE
        -- Else the current_fcst_flag = 'Y', therefore use min_casting_yyyypp.
        v_adjust_min_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;

      END IF;

      /*
      Loop through and aggregate forecast for all casting periods starting with the minimum
      changed casting period through to the maximum casting period for the forecast.
      */
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
        ' starting with the minimum casting period through to the maximum casting period.');

      FOR rv_casting_period IN csr_casting_period LOOP

        -- Create a savepoint.
        SAVEPOINT forecast_fact_savepoint;

           -- Delete forecasts from the fcst_fact table that are to be rebuilt.
           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Deleting from FCST_FACT where fcst_yyyypp > [' ||
             rv_casting_period.casting_yyyypp || '].');

           DELETE FROM fcst_fact
           WHERE company_code = i_company_code
           AND fcst_type_code = v_fcst_type_code
           AND sales_org_code = v_sales_org_code
           AND distbn_chnl_code = v_distbn_chnl_code
           AND ((division_code = v_division_code) OR
                (division_code IS NULL AND v_division_code IS NULL))
           AND (moe_code = v_moe_code OR moe_code IS NULL)
           AND fcst_yyyypp > rv_casting_period.casting_yyyypp;

           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Delete count : ' || TO_CHAR(SQL%ROWCOUNT) );

           -- Insert the forecast into the fcst_fact table.
           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Inserting into FCST_FACT where ' ||
             ' Casting Period = [' || rv_casting_period.casting_yyyypp || '] and fcst_yyyypp > [' || rv_casting_period.casting_yyyypp || ']' );

           INSERT INTO fcst_fact
             (
              company_code,
              sales_org_code,
              distbn_chnl_code,
              division_code,
              moe_code,
              fcst_type_code,
              fcst_yyyypp,
              fcst_yyyyppw,
              demand_plng_grp_code,
              cntry_code,
              region_code,
              multi_mkt_acct_code,
              banner_code,
              cust_buying_grp_code,
              acct_assgnmnt_grp_code,
              pos_format_grpg_code,
              distbn_route_code,
              cust_code,
              matl_zrep_code,
              matl_tdu_code,
              currcy_code,
              fcst_value,
              fcst_value_aud,
              fcst_value_usd,
              fcst_value_eur,
              fcst_qty,
              fcst_qty_gross_tonnes,
              fcst_qty_net_tonnes,
              base_value,
              base_qty,
              aggreg_mkt_actvty_value,
              aggreg_mkt_actvty_qty,
              lock_value,
              lock_qty,
              rcncl_value,
              rcncl_qty,
              auto_adjmt_value,
              auto_adjmt_qty,
              override_value,
              override_qty,
              mkt_actvty_value,
              mkt_actvty_qty,
              data_driven_event_value,
              data_driven_event_qty,
              tgt_impact_value,
              tgt_impact_qty,
              dfn_adjmt_value,
              dfn_adjmt_qty
             )
             SELECT
               t1.company_code,
               t1.sales_org_code,
               t1.distbn_chnl_code,
               t1.division_code,
               t1.moe_code,
               t1.fcst_type_code,
               t1.fcst_yyyypp,
               t1.fcst_yyyyppw,
               t1.demand_plng_grp_code,
               t1.cntry_code,
               t1.region_code,
               t1.multi_mkt_acct_code,
               t1.banner_code,
               t1.cust_buying_grp_code,
               t1.acct_assgnmnt_grp_code,
               t1.pos_format_grpg_code,
               t1.distbn_route_code,
               t1.cust_code,
               t1.matl_zrep_code,
               t1.matl_tdu_code,
               t1.currcy_code,
               t1.fcst_value,
               ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
               ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
               ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
               t1.fcst_qty,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
               base_value,
               base_qty,
               aggreg_mkt_actvty_value,
               aggreg_mkt_actvty_qty,
               lock_value,
               lock_qty,
               rcncl_value,
               rcncl_qty,
               auto_adjmt_value,
               auto_adjmt_qty,
               override_value,
               override_qty,
               mkt_actvty_value,
               mkt_actvty_qty,
               data_driven_event_value,
               data_driven_event_qty,
               tgt_impact_value,
               tgt_impact_qty,
               dfn_adjmt_value,
               dfn_adjmt_qty
             FROM
               (SELECT /*+ INDEX(B FCST_DTL_PK) */
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
                  NULL AS fcst_yyyyppw,
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
                  LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
                  b.currcy_code,
                  SUM(b.fcst_value) as fcst_value,
                  SUM(b.fcst_qty) AS fcst_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
                FROM
                  fcst_hdr a,
                  fcst_dtl b
                WHERE
                  a.fcst_hdr_code = b.fcst_hdr_code
                  AND (a.casting_year = rv_casting_period.casting_yyyy AND
                       a.casting_period = rv_casting_period.casting_pp )
                  AND a.company_code = i_company_code
                  AND a.fcst_type_code = v_fcst_type_code
                  AND a.sales_org_code = v_sales_org_code
                  AND a.distbn_chnl_code = v_distbn_chnl_code
                  AND ((a.division_code = v_division_code) OR
                       (a.division_code IS NULL AND v_division_code IS NULL))
                  AND a.moe_code = v_moe_code
                  AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
                  AND a.valdtn_status = ods_constants.valdtn_valid
                  AND (b.fcst_year || LPAD(b.fcst_period,2,0)) > rv_casting_period.casting_yyyypp
                GROUP BY
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)),
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  b.matl_zrep_code,
                  b.matl_tdu_code,
                  b.currcy_code ) t1,
               company t2,
               sap_mat_hdr t3
            WHERE t1.company_code = t2.company_code
            AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Insert count : ' || TO_CHAR(SQL%ROWCOUNT) );

        -- Commit.
        COMMIT;

      END LOOP;

  END IF;

  END LOOP;

  -- Completed fcst_fact aggregation.
  write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 1, 'Completed FCST_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO forecast_fact_savepoint;
    write_log(ods_constants.data_type_forecast,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.FORECAST_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END forecast_fact_aggregation;



FUNCTION dmd_plng_fcst_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_fcst_type_code fcst_hdr.fcst_type_code%TYPE;
  v_sales_org_code fcst_hdr.sales_org_code%TYPE;
  v_distbn_chnl_code fcst_hdr.distbn_chnl_code%TYPE;
  v_division_code fcst_hdr.division_code%TYPE;
  v_no_insert_flag BOOLEAN := FALSE;
  v_min_casting_yyyyppw VARCHAR2(7);
  v_min_casting_yyyypp VARCHAR2(6);
  v_moe_code fcst_hdr.moe_code%TYPE;

  -- CURSOR DECLARATIONS
  -- Check whether any forecasts are to be aggregated.
  CURSOR csr_forecast IS
    SELECT DISTINCT
      fcst_type_code,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      moe_code
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid;
    rv_forecast csr_forecast%ROWTYPE;

  -- Select the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_min_casting_period IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_period csr_min_casting_period%ROWTYPE;

  -- Select all casting periods starting at the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_casting_period IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      (casting_year || LPAD(casting_period,2,0)) AS casting_yyyypp
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) >= v_min_casting_yyyypp
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period) ASC;  -- KL (fix bug) convert to number otherwise the order is not as expected
    rv_casting_period csr_casting_period%ROWTYPE;

  -- Select the minimum casting week for a forecast that is to be aggregated (used for forecast type FCST).
  CURSOR csr_min_casting_week IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0) || casting_week) AS min_casting_yyyyppw,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_week csr_min_casting_week%ROWTYPE;

  -- Select all casting weeks starting at the minimum casting week for a weekly forecast that is to be aggregated.
  CURSOR csr_casting_week IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      casting_week AS casting_w,
      (casting_year || LPAD(casting_period,2,0) || casting_week) AS casting_yyyyppw
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) || casting_week >= v_min_casting_yyyyppw
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period || casting_week) ASC;  -- KL (fix bug) convert to number otherwise the order is not as expected
  rv_casting_week csr_casting_week%ROWTYPE;

BEGIN

  -- Starting dmd_plng_fcst_fact aggregation.
  write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 1, 'Starting DMD_PLNG_FCST_FACT aggregation.');

  -- Loop through all records in the cursor.
  write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 2, 'Check whether any forecasts are' ||
    ' to be aggregated.');

  FOR rv_forecast IN csr_forecast LOOP

    -- The following forecast requires aggregation.
    write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Aggregating: Forecast Type/MOE/Sales Org/Distribute Channel/Division [' ||
      rv_forecast.fcst_type_code || '/' || rv_forecast.moe_code || '/' || rv_forecast.sales_org_code ||
       '/' || rv_forecast.distbn_chnl_code || '/' || rv_forecast.division_code || '].');

    -- Now pass cursor results into variables.
    v_fcst_type_code :=  rv_forecast.fcst_type_code;
    v_sales_org_code := rv_forecast.sales_org_code;
    v_distbn_chnl_code := rv_forecast.distbn_chnl_code;
    v_division_code := rv_forecast.division_code;
    v_moe_code := rv_forecast.moe_code;

  /* -----------------------------------------------------------------------------------
    Check to see if the forecast type is weekly i.e. FCST. If it is then process
    weekly forecast, if not then bypass this section as the forecast is a period forecast.
  -------------------------------------------------------------------------------------*/

  IF v_fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

      -- Fetch only the first record from the csr_min_casting_week cursor.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_week cursor.');

      OPEN csr_min_casting_week;
      FETCH csr_min_casting_week INTO rv_min_casting_week;
      CLOSE csr_min_casting_week;

      -- Fetched the minimum casting_yyyyppw for the forecast being aggregated.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'The forecast being aggregated' ||
        ' has the Minimum Casting week of [' || rv_min_casting_week.min_casting_yyyyppw || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_week.current_fcst_flag || '].');

      -- Check the status of the current_fcst_flag.
      IF rv_min_casting_week.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        -- If current_fcst_flag = 'D' (deleted) then delete the data from DEMAND_PLNG_FCST_FACT table for that
        -- casting week as it is no longer needed and no insert will be done into DEMAND_PLNG_FCST_FACT table.
        -- if the status is D.
        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT ' ||
          ' as the current_fcst_flag = ''D'' (Deleted) for Casting Week ' || rv_min_casting_week.min_casting_yyyyppw || ' .');

        DELETE FROM demand_plng_fcst_fact
        WHERE company_code = i_company_code
        AND fcst_type_code = v_fcst_type_code
        AND sales_org_code = v_sales_org_code
        AND distbn_chnl_code = v_distbn_chnl_code
        AND ((division_code = v_division_code) OR
             (division_code IS NULL AND v_division_code IS NULL))
        AND (moe_code = v_moe_code OR moe_code IS NULL)
        AND casting_yyyyppw = rv_min_casting_week.min_casting_yyyyppw;

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- The current_fcst_flag = 'D', therefore no insert is required.
        v_no_insert_flag      := TRUE;
        v_min_casting_yyyyppw := NULL;

        -- Commit.
        COMMIT;

      ELSE -- Status of minimum casting week forecast is not 'D'.

        -- The current_fcst_flag = 'Y', therefore use min_casting_yyyyppw.
        v_no_insert_flag       := FALSE;
        v_min_casting_yyyyppw  := rv_min_casting_week.min_casting_yyyyppw;

      END IF;

      /*
       Loop through and aggregate forecast for all casting weeks starting with the minimum changed casting
       week through to the maximum casting week for the forecast.
       Do this only if the minimum casting week selected above is not DELETED.
      */

      -- If the status of minimum forecast week is not 'D', then open the cursor and process.
      IF v_no_insert_flag = FALSE  THEN

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
          ' starting with the minimum casting week through to the maximum casting week.');

        FOR rv_casting_week IN csr_casting_week LOOP
          -- Create a savepoint.
          SAVEPOINT dmd_plng_fcst_fact_savepoint;

          -- Delete forecasts from the demand_plng_fcst_fact table that are to be rebuilt.
          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');
          DELETE FROM demand_plng_fcst_fact
          WHERE company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND (moe_code = v_moe_code OR moe_code IS NULL)
          AND casting_yyyyppw = rv_casting_week.casting_yyyyppw;

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Insert the forecast into the demand_plng_fcast_fact table.
        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Inserting into DEMAND_PLNG_FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');

        INSERT INTO demand_plng_fcst_fact
          (
          company_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          moe_code,
          fcst_type_code,
          casting_yyyypp,
          casting_yyyyppw,
          fcst_yyyypp,
          fcst_yyyyppw,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          currcy_code,
          fcst_value,
          fcst_value_aud,
          fcst_value_usd,
          fcst_value_eur,
          fcst_qty,
          fcst_qty_gross_tonnes,
          fcst_qty_net_tonnes,
          base_value,
          base_qty,
          aggreg_mkt_actvty_value,
          aggreg_mkt_actvty_qty,
          lock_value,
          lock_qty,
          rcncl_value,
          rcncl_qty,
          auto_adjmt_value,
          auto_adjmt_qty,
          override_value,
          override_qty,
          mkt_actvty_value,
          mkt_actvty_qty,
          data_driven_event_value,
          data_driven_event_qty,
          tgt_impact_value,
          tgt_impact_qty,
          dfn_adjmt_value,
          dfn_adjmt_qty
          )
          SELECT
            t1.company_code,
            t1.sales_org_code,
            t1.distbn_chnl_code,
            t1.division_code,
            t1.moe_code,
            t1.fcst_type_code,
            t1.casting_yyyypp,
            t1.casting_yyyyppw,
            t1.fcst_yyyypp,
            t1.fcst_yyyyppw,
            t1.demand_plng_grp_code,
            t1.cntry_code,
            t1.region_code,
            t1.multi_mkt_acct_code,
            t1.banner_code,
            t1.cust_buying_grp_code,
            t1.acct_assgnmnt_grp_code,
            t1.pos_format_grpg_code,
            t1.distbn_route_code,
            t1.cust_code,
            t1.matl_zrep_code,
            t1.matl_tdu_code,
            t1.currcy_code,
            t1.fcst_value,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
            t1.fcst_qty,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
            base_value,
            base_qty,
            aggreg_mkt_actvty_value,
            aggreg_mkt_actvty_qty,
            lock_value,
            lock_qty,
            rcncl_value,
            rcncl_qty,
            auto_adjmt_value,
            auto_adjmt_qty,
            override_value,
            override_qty,
            mkt_actvty_value,
            mkt_actvty_qty,
            data_driven_event_value,
            data_driven_event_qty,
            tgt_impact_value,
            tgt_impact_qty,
            dfn_adjmt_value,
            dfn_adjmt_qty
          FROM
            (SELECT /*+ INDEX(B FCST_DTL_PK) */
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0) AS casting_yyyypp,
               a.casting_year || LPAD(a.casting_period,2,0) || a.casting_week AS casting_yyyyppw,
               (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week) AS fcst_yyyyppw,
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
               LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
               b.currcy_code,
               SUM(b.fcst_value) as fcst_value,
               SUM(b.fcst_qty) AS fcst_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
             FROM
               fcst_hdr a,
               fcst_dtl b
             WHERE
               a.fcst_hdr_code = b.fcst_hdr_code
               AND (a.casting_year = rv_casting_week.casting_yyyy AND
                    a.casting_period = rv_casting_week.casting_pp AND
                    a.casting_week = rv_casting_week.casting_w)
               AND a.company_code = i_company_code
               AND a.fcst_type_code = v_fcst_type_code
               AND a.sales_org_code = v_sales_org_code
               AND a.distbn_chnl_code = v_distbn_chnl_code
               AND ((a.division_code = v_division_code) OR
                    (a.division_code IS NULL AND v_division_code IS NULL))
               AND moe_code = v_moe_code
               AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
               AND a.valdtn_status = ods_constants.valdtn_valid
             GROUP BY
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0),
               a.casting_year || LPAD(a.casting_period,2,0) || a.casting_week,
               (b.fcst_year || LPAD(b.fcst_period,2,0)),
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week),
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               b.matl_zrep_code,
               b.matl_tdu_code,
               b.currcy_code ) t1,
            company t2,
            sap_mat_hdr t3
         WHERE t1.company_code = t2.company_code
         AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Commit.
        COMMIT;

      END LOOP;   -- End of csr_casting_week cursor.
    END IF;       -- End of v_no_insert_flag = FALSE check.

  --  Forecast type is not weekly 'FCST', therefore process period forecast.
  ELSE

      -- Fetch only the first record from the csr_min_casting_period cursor.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_period cursor.');

      OPEN csr_min_casting_period;
      FETCH csr_min_casting_period INTO rv_min_casting_period;
      CLOSE csr_min_casting_period;

      -- Fetched the minimum casting_yyyypp for the forecast being aggregated.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'The forecast being aggregated' ||
        ' has the Minimum Casting Period of [' || rv_min_casting_period.min_casting_yyyypp || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_period.current_fcst_flag || '].');

      -- Check the status of the current_fcst flag.
      IF rv_min_casting_period.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        -- If current_fcst_flag = 'D' (deleted) then delete the data from DEMAND_PLNG_FCST_FACT table for that
        -- casting period as it is no longer needed and no insert will be done into DEMAND_PLNG_FCST_FACT table
        -- if the status is D.
        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT ' ||
          ' as the current_fcst_flag = ''D'' (Deleted) for Casting Period ' || rv_min_casting_period.min_casting_yyyypp || ' .');

        DELETE FROM demand_plng_fcst_fact
        WHERE company_code = i_company_code
        AND fcst_type_code = v_fcst_type_code
        AND sales_org_code = v_sales_org_code
        AND distbn_chnl_code = v_distbn_chnl_code
        AND ((division_code = v_division_code) OR
             (division_code IS NULL AND v_division_code IS NULL))
        AND (moe_code = v_moe_code OR moe_code IS NULL)
        AND casting_yyyypp = rv_min_casting_period.min_casting_yyyypp;

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- The current_fcst_flag = 'D', therefore no insert is required.
        v_no_insert_flag      := TRUE;
        v_min_casting_yyyypp  := NULL;

        -- Commit.
        COMMIT;

      ELSE -- Status of minimum casting period forecast is not 'D'.

        -- The current_fcst_flag = 'Y', therefore use min_casting_yyyypp.
        v_no_insert_flag     := FALSE;
        v_min_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;

      END IF;

      /*
       Loop through and aggregate forecast for all casting periods starting with the minimum changed casting
       period through to the maximum casting period for the forecast.
       Do this only if the minimum casting period selected above is not DELETED.
      */

      -- If the status of minimum forecast period is not 'D' then open the cursor and process.
      IF  v_no_insert_flag = FALSE  THEN

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
            ' starting with the minimum casting period through to the maximum casting period.');

        FOR rv_casting_period IN csr_casting_period LOOP

          -- Create a savepoint.
          SAVEPOINT dmd_plng_fcst_fact_savepoint;

          -- Delete forecasts from the demand_plng_fcst_fact table that are to be rebuilt.
          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT based' ||
            ' on Casting Period [' || rv_casting_period.casting_yyyypp || '].');
          DELETE FROM demand_plng_fcst_fact
          WHERE company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND (moe_code = v_moe_code OR moe_code IS NULL)
          AND casting_yyyypp = rv_casting_period.casting_yyyypp;

          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete Count: ' || TO_CHAR(SQL%ROWCOUNT));

          -- Insert the forecast into the demand_plng_fcst_fact table.
          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Inserting into DEMAND_PLNG_FCST_FACT based' ||
            ' on Casting Period [' || rv_casting_period.casting_yyyypp || '].');
          INSERT INTO demand_plng_fcst_fact
          (
          company_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          moe_code,
          fcst_type_code,
          casting_yyyypp,
          casting_yyyyppw,
          fcst_yyyypp,
          fcst_yyyyppw,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          currcy_code,
          fcst_value,
          fcst_value_aud,
          fcst_value_usd,
          fcst_value_eur,
          fcst_qty,
          fcst_qty_gross_tonnes,
          fcst_qty_net_tonnes,
          base_value,
          base_qty,
          aggreg_mkt_actvty_value,
          aggreg_mkt_actvty_qty,
          lock_value,
          lock_qty,
          rcncl_value,
          rcncl_qty,
          auto_adjmt_value,
          auto_adjmt_qty,
          override_value,
          override_qty,
          mkt_actvty_value,
          mkt_actvty_qty,
          data_driven_event_value,
          data_driven_event_qty,
          tgt_impact_value,
          tgt_impact_qty,
          dfn_adjmt_value,
          dfn_adjmt_qty
          )
          SELECT
            t1.company_code,
            t1.sales_org_code,
            t1.distbn_chnl_code,
            t1.division_code,
            t1.moe_code,
            t1.fcst_type_code,
            t1.casting_yyyypp,
            t1.casting_yyyyppw,
            t1.fcst_yyyypp,
            t1.fcst_yyyyppw,
            t1.demand_plng_grp_code,
            t1.cntry_code,
            t1.region_code,
            t1.multi_mkt_acct_code,
            t1.banner_code,
            t1.cust_buying_grp_code,
            t1.acct_assgnmnt_grp_code,
            t1.pos_format_grpg_code,
            t1.distbn_route_code,
            t1.cust_code,
            t1.matl_zrep_code,
            t1.matl_tdu_code,
            t1.currcy_code,
            t1.fcst_value,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
            t1.fcst_qty,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
            base_value,
            base_qty,
            aggreg_mkt_actvty_value,
            aggreg_mkt_actvty_qty,
            lock_value,
            lock_qty,
            rcncl_value,
            rcncl_qty,
            auto_adjmt_value,
            auto_adjmt_qty,
            override_value,
            override_qty,
            mkt_actvty_value,
            mkt_actvty_qty,
            data_driven_event_value,
            data_driven_event_qty,
            tgt_impact_value,
            tgt_impact_qty,
            dfn_adjmt_value,
            dfn_adjmt_qty
          FROM
            (SELECT /*+ INDEX(B FCST_DTL_PK) */
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0) AS casting_yyyypp,
               NULL casting_yyyyppw,        -- casting_yyyyppw is null if fcst_type is not FCST.
               (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
               NULL AS fcst_yyyyppw,        -- forecast_yyyyppw is null if fcst_type is not FCST.
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
               LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
               b.currcy_code,
               SUM(b.fcst_value) as fcst_value,
               SUM(b.fcst_qty) AS fcst_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
             FROM
               fcst_hdr a,
               fcst_dtl b
             WHERE
               a.fcst_hdr_code = b.fcst_hdr_code
               AND (a.casting_year = rv_casting_period.casting_yyyy AND
                    a.casting_period = rv_casting_period.casting_pp )
               AND a.company_code = i_company_code
               AND a.fcst_type_code = v_fcst_type_code
               AND a.sales_org_code = v_sales_org_code
               AND a.distbn_chnl_code = v_distbn_chnl_code
               AND ((a.division_code = v_division_code) OR
                    (a.division_code IS NULL AND v_division_code IS NULL))
               AND moe_code = v_moe_code
               AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
               AND a.valdtn_status = ods_constants.valdtn_valid
             GROUP BY
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0),
               (b.fcst_year || LPAD(b.fcst_period,2,0)),
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               b.matl_zrep_code,
               b.matl_tdu_code,
               b.currcy_code ) t1,
            company t2,
            sap_mat_hdr t3
         WHERE t1.company_code = t2.company_code
         AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Insert Count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Commit.
        COMMIT;

      END LOOP;   -- End of csr_casting_period cursor.
    END IF;       -- End of v_no_insert_flag = FALSE check.

  END IF; -- End forecast type check for weekly FCST.

  END LOOP;

  -- Completed dmd_plng_fcst_fact aggregation.
  write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 1, 'Completed DMD_PLNG_FCST_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO dmd_plng_fcst_fact_savepoint;
    write_log(ods_constants.data_type_dmd_plng_forecast,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.DMD_PLNG_FCST_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END dmd_plng_fcst_fact_aggregation;



FUNCTION dcs_order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN dcs_sales_order.load_date%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any fundraising orders were received or updated yesterday.
  CURSOR csr_dcs_order_count IS
    SELECT
      count(*) AS dcs_order_count
    FROM
      dcs_sales_order
    WHERE
      company_code = i_company_code
      AND TRUNC(dcs_sales_order_lupdt) = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid;

    rv_dcs_order_count csr_dcs_order_count%ROWTYPE;

BEGIN

  -- Starting dcs_sales_order_fact aggregation.
  write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Start - DCS_SALES_ORDER_FACT aggregation.');

  -- Fetch the record from the csr_dcs_order_count cursor.
  OPEN csr_dcs_order_count;
  FETCH csr_dcs_order_count INTO rv_dcs_order_count.dcs_order_count;
  CLOSE csr_dcs_order_count;

  -- Create a savepoint.
  SAVEPOINT dcs_order_fact_savepoint;

  -- If any fundraising orders were received or updated then continue the aggregation process.
  write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Checking whether any fundraising orders' ||
    ' were received or updated yesterday.');

  IF rv_dcs_order_count.dcs_order_count > 0 THEN

    -- Delete all existing dsc orders for the company first.
    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Deleting from DCS_SALES_ORDER_FACT based on' ||
      ' Company Code [' || i_company_code || ']');

    -- delete all the existing record first, becasue no history required to be kept in this table
    DELETE FROM dcs_sales_order_fact
    WHERE company_code = i_company_code;

    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

    -- Insert into dcs_sales_order_fact table based on company code.
    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Inserting into the DCS_SALES_ORDER_FACT table.');
    INSERT INTO dcs_sales_order_fact
      (
        company_code,
        order_doc_num,
        order_doc_line_num,
        order_type_code,
        creatn_date,
        order_eff_date,
        sales_org_code,
        distbn_chnl_code,
        division_code,
        doc_currcy_code,
        exch_rate,
        sold_to_cust_code,
        ship_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        base_uom_order_qty,
        order_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        order_gsv,
        matl_zrep_code,
        creatn_yyyyppdd,
        order_eff_yyyyppdd
      )
    SELECT
      company_code,
      order_doc_num,
      order_doc_line_num,
      order_type_code,
      creatn_date,
      order_eff_date,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      doc_currcy_code,
      exch_rate,
      sold_to_cust_code,
      ship_to_cust_code,
      bill_to_cust_code,
      payer_cust_code,
      base_uom_order_qty,
      order_qty_base_uom_code,
      t1.plant_code,
      storage_locn_code,
      order_gsv,
      decode(t2.matl_type_code, 'ZREP', t2.matl_code, t2.rep_item) as matl_zrep_code,
      t3.mars_yyyyppdd as creatn_yyyyppdd,
      t4.mars_yyyyppdd as order_eff_yyyyppdd
    FROM
      dcs_sales_order t1,     -- this list is refreshed every day, no need to check the load date
      matl_dim t2,
      mars_date_dim t3,
      mars_date_dim t4
    WHERE
      t1.company_code = i_company_code
      AND t1.valdtn_status = ods_constants.valdtn_valid
      AND t1.matl_code = t2.matl_code (+)
      AND t1.creatn_date = t3.calendar_date (+)
      AND t1.order_eff_date = t4.calendar_date (+);

    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

    -- Commit.
    COMMIT;

  END IF;

  -- Completed DCS_SALES_ORDER_FACT aggregation.
  write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Completed DCS_SALES_ORDER_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO dcs_order_fact_savepoint;
    write_log(ods_constants.data_type_dcs_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.DCS_ORDER_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END dcs_order_fact_aggregation;



FUNCTION csl_process_purch_order (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sto_po_hdr.sap_sto_po_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any purchase orders were received or updated yesterday.
  CURSOR crs_csl_po_count IS
    SELECT
      count(*) AS csl_po_count
    FROM
      sap_sto_po_hdr a,
      sap_sto_po_org b,
      sap_sto_po_pnr c,
      sap_cus_hdr d,
      sap_ref_dat e
    WHERE a.belnr = b.belnr
      AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
      AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
      AND a.belnr = c.belnr
      AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
      AND c.partn = d.lifnr -- d Customer
      AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
      AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
      AND e.z_tabname = 'T001W'
      AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_csl_po_count crs_csl_po_count%ROWTYPE;

BEGIN
  -- Starting csl purchase orders processing.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Starting csl_process_purch_order.');

  -- Fetch the records from the crs_csl_po_count cursor.
  OPEN crs_csl_po_count;
  FETCH crs_csl_po_count INTO rv_csl_po_count.csl_po_count;
  CLOSE crs_csl_po_count;

  -- If any purchase orders were received or updated yesterday continue the csl processing.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 2, 'Checking for new or updated CSL PO ' ||
  'and Count is [' || TO_CHAR(rv_csl_po_count.csl_po_count) || ']');

  IF rv_csl_po_count.csl_po_count > 0 THEN

    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Processing CSL PO Based on Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT csl_process_po_savepoint;

    -- Delete any purchase orders that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Deleting CSL PO from csl_order_dlvry_fact based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
    DELETE FROM csl_order_dlvry_fact
    WHERE company_code = i_company_code
      AND csl_order_type = 'PO'
      AND order_doc_num IN
      (
        SELECT a.belnr
        FROM
          sap_sto_po_hdr a,
          sap_sto_po_org b,
          sap_sto_po_pnr c,
          sap_cus_hdr d,
          sap_ref_dat e
        WHERE a.belnr = b.belnr
          AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
          AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
          AND a.belnr = c.belnr
          AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
          AND c.partn = d.lifnr -- d Customer
          AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
          AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
          AND e.z_tabname = 'T001W'
          AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date);

    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Delete Count: ' || to_char(SQL%ROWCOUNT));

    -- Insert into csl_order_dlvry_fact table based on company code and date.
    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Inserting CSL PO into csl_order_dlvry_fact.');
    INSERT INTO csl_order_dlvry_fact
    (
      company_code,
      order_doc_num,
      order_doc_line_num,
      csl_order_type,
      order_creatn_date,
      cust_order_due_date,
      csl_date,
      sales_org_code,
      distbn_chnl_code,
      demand_plng_grp_division_code,
      division_code,
      sold_to_cust_code,
      ship_to_cust_code,
      matl_code,
      base_uom_order_qty,
      base_uom_confirmed_qty,
      order_gsv,
      confirmed_gsv,
      order_line_status,
      order_line_rejectn_code,
      dlvry_doc_num,
      dlvry_doc_line_num,
      dlvry_creatn_date,
      goods_issue_date,
      base_uom_dlvry_qty,
      dlvry_gsv,
      dlvry_line_status,
      dlvry_procg_stage,
      order_lupdt,
      dlvry_lupdt
    )
    SELECT
      p.company_code,
      p.purch_order_doc_num,
      p.purch_order_doc_line_num,
      'PO',
      p.creatn_date,
      NULL,
      p.creatn_date,
      p.sales_org_code,
      p.distbn_chnl_code,
      p.demand_plng_grp_division_code,
      p.division_code,
      p.cust_code,
      p.cust_code,
      p.matl_code,
      p.base_uom_purch_order_qty,
      p.base_uom_purch_order_qty,
      p.gsv,
      p.gsv,
      p.purch_order_line_status,
      NULL,
      d.dlvry_doc_num,
      d.dlvry_doc_line_num,
      d.creatn_date,
      d.goods_issue_date,
      d.base_uom_dlvry_qty,
      d.gsv,
      d.dlvry_line_status,
      d.dlvry_procg_stage,
      SYSDATE,
      NULL
    FROM
      dds.purch_order_fact_old p,
      dds.dlvry_fact_old d,
      (
      SELECT
        TRIM(SUBSTR(e.z_data, 173, 3)) as company_code, a.belnr as purch_order_doc_num
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_pnr c,
        sap_cus_hdr d,
        sap_ref_dat e
      WHERE a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
        AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = c.belnr
        AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
        AND c.partn = d.lifnr -- d Customer
        AND d.kunnr = TRIM(SUBSTR(e.z_data, 42, 10))
        AND TRIM(SUBSTR(e.z_data, 173, 3)) = i_company_code -- e Company
        AND e.z_tabname = 'T001W'
        AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = i_aggregation_date
      ) e
    WHERE
      p.company_code = i_company_code
      AND p.purch_order_doc_num = d.purch_order_doc_num(+)
      AND p.purch_order_doc_line_num = d.purch_order_doc_line_num(+)
      AND e.company_code = p.company_code
      AND e.purch_order_doc_num = p.purch_order_doc_num;

    write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 3, 'Insert Count: ' || to_char(SQL%ROWCOUNT));

    -- Commit.
    COMMIT;

  END IF;

  -- Completed purch_order_fact aggregation.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 1, 'Completed csl_process_purch_order.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO csl_process_po_savepoint;
    write_log(ods_constants.data_type_purch_order,
              'ERROR',
              0,
              'scheduled_aggregation.csl_process_purch_order: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END csl_process_purch_order;



FUNCTION csl_process_sales_order (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_sal_ord_hdr.sap_sal_ord_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any sales orders were received or updated yesterday.
  CURSOR crs_csl_so_count IS
    SELECT count(*) AS csl_so_count
    FROM
      sap_sal_ord_hdr a,
      sap_sal_ord_org b
    WHERE
      a.belnr = b.belnr
      AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
      AND b.orgid = i_company_code
      AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date;
     rv_csl_so_count crs_csl_so_count%ROWTYPE;

BEGIN
  -- Starting csl_sales_orders processing.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 1, 'Starting csl_process_sales_order');

  -- Fetch the record from the crs_csl_so_count cursor.
  OPEN crs_csl_so_count;
  FETCH crs_csl_so_count INTO rv_csl_so_count.csl_so_count;
  CLOSE crs_csl_so_count;

  -- If any sales orders were received or updated yesterday continue the csl processing.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 2, 'Checking for new or updated CSL SO ' ||
    'and Count is [' || TO_CHAR(rv_csl_so_count.csl_so_count) || ']');

  IF rv_csl_so_count.csl_so_count > 0 THEN

    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Processing CSL SO based on Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT csl_process_so_savepoint;

    -- Delete any sales orders that need update based on company code and date.
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Deleting CSL SO from csl_order_dlvry_fact based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');
     DELETE FROM csl_order_dlvry_fact
     WHERE company_code = i_company_code
       AND csl_order_type = 'SO'
       AND order_doc_num  IN
        (
          SELECT a.belnr
          FROM
            sap_sal_ord_hdr a,
            sap_sal_ord_org b
          WHERE a.belnr = b.belnr
            AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
            AND b.orgid = i_company_code
            AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date);

    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Delete Count: ' || to_char(SQL%ROWCOUNT));

    -- Insert into csl_order_dlvry_fact table the new and updated sales orders with the coresponsing deliveries, if any
    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Inserting CSL SO into csl_order_dlvry_fact.');
    INSERT INTO csl_order_dlvry_fact
      (
        company_code,
        order_doc_num,
        order_doc_line_num,
        csl_order_type,
        order_creatn_date,
        cust_order_due_date,
        csl_date,
        sales_org_code,
        distbn_chnl_code,
        demand_plng_grp_division_code,
        division_code,
        sold_to_cust_code,
        ship_to_cust_code,
        matl_code,
        base_uom_order_qty,
        base_uom_confirmed_qty,
        order_gsv,
        confirmed_gsv,
        order_line_status,
        order_line_rejectn_code,
        dlvry_doc_num,
        dlvry_doc_line_num,
        dlvry_creatn_date,
        goods_issue_date,
        base_uom_dlvry_qty,
        dlvry_gsv,
        dlvry_line_status,
        dlvry_procg_stage,
        order_lupdt,
        dlvry_lupdt
      )
      SELECT
        o.company_code,
        o.order_doc_num,
        o.order_doc_line_num,
        'SO',
        o.creatn_date,
        o.cust_order_due_date,
        CASE
          WHEN o.order_line_rejectn_code = 'ZA'
            THEN o.cust_order_due_date
          ELSE o.creatn_date
        END,
        o.hdr_sales_org_code,
        o.hdr_distbn_chnl_code,
        o.demand_plng_grp_division_code,
        o.hdr_division_code,
        o.sold_to_cust_code,
        o.ship_to_cust_code,
        o.matl_code,
        o.base_uom_order_qty,
        o.base_uom_confirmed_qty,
        o.order_gsv,
        o.confirmed_gsv,
        o.order_line_status,
        o.order_line_rejectn_code,
        d.dlvry_doc_num,
        d.dlvry_doc_line_num,
        d.creatn_date,
        d.goods_issue_date,
        d.base_uom_dlvry_qty,
        d.gsv,
        d.dlvry_line_status,
        d.dlvry_procg_stage,
        SYSDATE,
        NULL
      FROM
        dds.order_fact_old o,
        dds.dlvry_fact_old d,
       (
          SELECT
            b.orgid as company_code, a.belnr as order_doc_num
          FROM
            sap_sal_ord_hdr a,
            sap_sal_ord_org b
          WHERE
            a.belnr = b.belnr
            AND b.qualf = ods_constants.sales_order_sales_org -- Sales Organisation
            AND b.orgid = i_company_code
            AND TRUNC(a.sap_sal_ord_hdr_lupdt, 'DD') = i_aggregation_date
        ) e
      WHERE
        o.company_code = i_company_code
        AND o.order_doc_num = d.order_doc_num(+)
        AND o.order_doc_line_num = d.order_doc_line_num(+)
        AND e.company_code = o.company_code
        AND e.order_doc_num = o.order_doc_num;

    write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 3, 'Insert Count: ' || to_char(SQL%ROWCOUNT));

    -- Commit.
    COMMIT;

  END IF;

  -- Completed csl_process_sales_order processing.
  write_log(ods_constants.data_type_sales_order, 'N/A', i_log_level + 1, 'Completed csl_process_sales_order');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO csl_process_so_savepoint;
    write_log(ods_constants.data_type_sales_order,
              'ERROR',
              0,
              'scheduled_aggregation.csl_process_sales_order: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END csl_process_sales_order;



FUNCTION csl_process_dlvry (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN sap_del_hdr.sap_del_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any deliveries were received or updated yesterday.
  CURSOR csr_csl_dlvry_count IS
    SELECT count(*) AS csl_dlvry_count
    FROM
      sap_del_hdr
    WHERE
      vkorg = i_company_code
      AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date;
    rv_csl_dlvry_count csr_csl_dlvry_count%ROWTYPE;

BEGIN
  -- Starting dlvry_fact aggregation.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 1, 'Starting csl_process_dlvry.');

  -- Fetch the record from the csr_delivery_count cursor.
  OPEN csr_csl_dlvry_count;
  FETCH csr_csl_dlvry_count INTO rv_csl_dlvry_count.csl_dlvry_count;
  CLOSE csr_csl_dlvry_count;

  -- If any deliveries were received or updated yesterday continue csl processing.
  write_log(ods_constants.data_type_purch_order, 'N/A', i_log_level + 2, 'Checking for new or updated CSL dlvry ' ||
    'and Count is [' || TO_CHAR( rv_csl_dlvry_count.csl_dlvry_count) || ']');

  IF rv_csl_dlvry_count.csl_dlvry_count > 0 THEN

    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Processing CSL dlvry based on Company Code [' ||
      '' || i_company_code || '] and Date [' || i_aggregation_date ||'].');

    -- Create a savepoint.
    SAVEPOINT csl_dlvry_savepoint;

    -- Delete any deliveries that need update from csl_order_dlvry_fact
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Deleting  dlvry from csl_order_dlvry_fact based on' ||
      ' Company Code [' || i_company_code || '] and Date [' || i_aggregation_date || '].');

    DELETE FROM csl_order_dlvry_fact
    WHERE company_code = i_company_code
      AND dlvry_doc_num IN
        (
          SELECT
            vbeln
          FROM sap_del_hdr
         WHERE vkorg = i_company_code
           AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date
           );

    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Delete Count: ' || to_char(SQL%ROWCOUNT));

    -- Insert new and updated deliveries with coresponding purchase orders into csl_order_dlvry_fact table based on company code and date.
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Inserting so/dlvry  into csl_order_dlvry_fact.');
    INSERT INTO csl_order_dlvry_fact
    (
      company_code,
      order_doc_num,
      order_doc_line_num,
      csl_order_type,
      order_creatn_date,
      cust_order_due_date,
      csl_date,
      sales_org_code,
      distbn_chnl_code,
      demand_plng_grp_division_code,
      division_code,
      sold_to_cust_code,
      ship_to_cust_code,
      matl_code,
      base_uom_order_qty,
      base_uom_confirmed_qty,
      order_gsv,
      confirmed_gsv,
      order_line_status,
      order_line_rejectn_code,
      dlvry_doc_num,
      dlvry_doc_line_num,
      dlvry_creatn_date,
      goods_issue_date,
      base_uom_dlvry_qty,
      dlvry_gsv,
      dlvry_line_status,
      dlvry_procg_stage,
      order_lupdt,
      dlvry_lupdt
    )
      SELECT
        o. company_code,
        o.order_doc_num,
        o.order_doc_line_num,
       'SO',
        o.creatn_date,
        o.cust_order_due_date,
        CASE
          WHEN o.order_line_rejectn_code = 'ZA'
            THEN o.cust_order_due_date
          ELSE o.creatn_date
        END,
        o.hdr_sales_org_code,
        o.hdr_distbn_chnl_code,
        o.demand_plng_grp_division_code,
        o.hdr_division_code,
        o.sold_to_cust_code,
        o.ship_to_cust_code,
        o.matl_code,
        o.base_uom_order_qty,
        o.base_uom_confirmed_qty,
        o.order_gsv,
        o.confirmed_gsv,
        o.order_line_status,
        o.order_line_rejectn_code,
        d.dlvry_doc_num,
        d.dlvry_doc_line_num,
        d.creatn_date,
        d.goods_issue_date,
        d.base_uom_dlvry_qty,
        d.gsv,
        d.dlvry_line_status,
        d.dlvry_procg_stage,
        NULL,
        SYSDATE
      FROM
        dds.order_fact_old o,
        dds.dlvry_fact_old d,
        (SELECT vkorg as company_code, vbeln as dlvry_doc_num
         FROM sap_del_hdr
         WHERE vkorg = i_company_code
           AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date) e
      WHERE
        o.company_code = i_company_code
        AND o.order_doc_num = d.order_doc_num
        AND o.order_doc_line_num = d.order_doc_line_num
        AND e.company_code = d.company_code
        and e.dlvry_doc_num = d.dlvry_doc_num;

    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Insert Count: ' || to_char(SQL%ROWCOUNT));

    -- Insert updated and new deliveries with  coresponding sales orders into csl_order_dlvry_fact table
    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Inserting po/dlvry into csl_order_dlvry_fact.');

    INSERT INTO csl_order_dlvry_fact
    (
      company_code,
      order_doc_num,
      order_doc_line_num,
      csl_order_type,
      order_creatn_date,
      cust_order_due_date,
      csl_date,
      sales_org_code,
      distbn_chnl_code,
      demand_plng_grp_division_code,
      division_code,
      sold_to_cust_code,
      ship_to_cust_code,
      matl_code,
      base_uom_order_qty,
      base_uom_confirmed_qty,
      order_gsv,
      confirmed_gsv,
      order_line_status,
      order_line_rejectn_code,
      dlvry_doc_num,
      dlvry_doc_line_num,
      dlvry_creatn_date,
      goods_issue_date,
      base_uom_dlvry_qty,
      dlvry_gsv,
      dlvry_line_status,
      dlvry_procg_stage,
      order_lupdt,
      dlvry_lupdt
     )
      SELECT
        p.company_code,
        p.purch_order_doc_num,
        p.purch_order_doc_line_num,
        'PO',
        p.creatn_date,
        TO_DATE(null),
        p.creatn_date,
        p.sales_org_code,
        p.distbn_chnl_code,
        p.demand_plng_grp_division_code,
        p.division_code,
        P.cust_code,
        P.cust_code,
        p.matl_code,
        p.base_uom_purch_order_qty,
        p.base_uom_purch_order_qty,
        p.gsv,
        p.gsv,
        p.purch_order_line_status,
        NULL ,
        d.dlvry_doc_num,
        d.dlvry_doc_line_num,
        d.creatn_date,
        d.goods_issue_date,
        d.base_uom_dlvry_qty,
        d.gsv,
        d.dlvry_line_status,
        d.dlvry_procg_stage,
        NULL,
        SYSDATE
      FROM
        dds.purch_order_fact_old p,
        dds.dlvry_fact_old d,
        (SELECT vkorg as company_code, vbeln as dlvry_doc_num
         FROM sap_del_hdr
         WHERE vkorg = i_company_code
           AND TRUNC(sap_del_hdr_lupdt, 'DD') = i_aggregation_date) e
      WHERE
        p.company_code = i_company_code
        AND p.purch_order_doc_num = d.purch_order_doc_num
        AND p.purch_order_doc_line_num = d.purch_order_doc_line_num
        AND e.company_code = d.company_code
        and e.dlvry_doc_num = d.dlvry_doc_num;

    write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 3, 'Insert Count: ' || to_char(SQL%ROWCOUNT));

    -- Commit.
    COMMIT;

  END IF;

  -- Completed dlvry_fact aggregation.
  write_log(ods_constants.data_type_delivery, 'N/A', i_log_level + 1, 'Completed csl_process_dlvry.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO csl_dlvry_savepoint;
    write_log(ods_constants.data_type_delivery,
              'ERROR',
              0,
              'scheduled_aggregation.csl_process_dlvry: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END csl_process_dlvry;



FUNCTION get_mars_period (
  i_date        IN DATE,
  i_offset_days IN NUMBER,
  i_log_level   IN ods.log.log_level%TYPE
 ) RETURN NUMBER IS

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_period IS
    SELECT mars_period as mars_period
    FROM mars_date_dim
    WHERE calendar_date = TRUNC(i_date + i_offset_days,'DD');
  rv_mars_period csr_mars_period%ROWTYPE;

BEGIN

  -- Fetch the record from the csr_mars_week cursor.
  OPEN csr_mars_period;
  FETCH csr_mars_period INTO rv_mars_period;
  IF csr_mars_period%NOTFOUND THEN
        CLOSE csr_mars_period;
        RAISE e_processing_error;
  ELSE
        CLOSE csr_mars_period;
        RETURN rv_mars_period.mars_period;
  END IF;

EXCEPTION
  WHEN e_processing_error THEN
    write_log( ods_constants.data_type_generic,'ERROR',
               i_log_level,'scheduled_aggregation.get_mars_period: ERROR: mars_period not found for [' || to_char(i_date+i_offset_days,'DD-MON-YYYY') || ']' );
    RAISE_APPLICATION_ERROR(-20000, 'mars_period not found');

  WHEN OTHERS THEN
    CLOSE csr_mars_period;
    write_log( ods_constants.data_type_generic,'ERROR',
               i_log_level,'scheduled_aggregation.get_mars_period: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END get_mars_period;



PROCEDURE reload_fcst_region_fact (
  i_company_code     IN company.company_code%TYPE,
  i_moe_code         IN fcst_fact.moe_code%TYPE,
  i_reload_yyyypp    IN mars_date_dim.mars_period%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) IS

BEGIN
  write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Start - reload_fcst_region_fact.');

      -- Delete given moe_code and fcst_yyyypp > reload_yyyypp.
      DELETE FROM fcst_local_region_fact
      WHERE
        company_code = i_company_code
        AND moe_code = i_moe_code
        AND fcst_type_code = 'BR'
        AND fcst_yyyypp > i_reload_yyyypp;

      write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Delete from fcst_local_region_fact where moe_code [' || i_moe_code ||
                '] and fcst_yyyypp > [' || i_reload_yyyypp || '] with count [ ' || TO_CHAR(SQL%ROWCOUNT) || ']');
      INSERT INTO fcst_local_region_fact
        (
          company_code,
          moe_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          fcst_type_code,
          fcst_yyyypp,
          acct_assgnmnt_grp_code,
          demand_plng_grp_code,
          local_region_code,
          fcst_value
        )
      SELECT
        t1.company_code,
        t1.moe_code,
        t1.sales_org_code,
        t1.distbn_chnl_code,
        t1.division_code,
        t1.fcst_type_code,
        t1.fcst_yyyypp,
        t1.acct_assgnmnt_grp_code,
        t1.demand_plng_grp_code,
        t2.local_region_code,
        (t1.fcst_value * pct) as region_fcst_value
      FROM
        ( -- Sum up the fcst_value to group value.
          SELECT
            company_code,
            moe_code,
            sales_org_code,
            distbn_chnl_code,
            division_code,
            fcst_type_code,
            fcst_yyyypp,
            acct_assgnmnt_grp_code,
            demand_plng_grp_code,
            SUM(fcst_value) as fcst_value  -- Sum up to above grouping before dividing to local region amount.
          FROM
            fcst_fact t1
          WHERE
            fcst_yyyypp > i_reload_yyyypp
            AND company_code = i_company_code
            AND moe_code = i_moe_code
            AND fcst_type_code = 'BR'
            AND EXISTS (SELECT *
                        FROM
                          fcst_local_region_pct t2,
                          fcst_demand_grp_local_region t3
                        WHERE t2.demand_plng_grp_code = t3.demand_plng_grp_code
                          AND t3.moe_code = i_moe_code
                          AND t2.fcst_yyyypp = t1.fcst_yyyypp
                          AND t2.demand_plng_grp_code = t1.demand_plng_grp_code
                          AND t2.fcst_yyyypp > i_reload_yyyypp)  -- Only the demand group and fcst period have been set up.
          GROUP BY
            company_code,
            moe_code,
            sales_org_code,
            distbn_chnl_code,
            division_code,
            fcst_type_code,
            t1.fcst_yyyypp,
            acct_assgnmnt_grp_code,
            t1.demand_plng_grp_code) t1,
        fcst_local_region_pct t2
      WHERE t1.fcst_yyyypp = t2.fcst_yyyypp
        AND t1.demand_plng_grp_code = t2.demand_plng_grp_code
        AND t2.fcst_yyyypp > i_reload_yyyypp;

      write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

      -- Commit.
      COMMIT;

  -- Completed fcst_local_region_fact aggregation.
  write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Completed reload_fcst_region_fact.');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_fcst_local_region,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.reload_fcst_region_fact: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    raise_application_error(-20000, 'LOG ERROR - ' || SUBSTR(SQLERRM, 1, 512));

END reload_fcst_region_fact;



FUNCTION fcst_region_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_casting_yyyypp        mars_date_dim.mars_period%TYPE;
  v_aggregation_date      DATE;
  v_reload_yyyypp         mars_date_dim.mars_period%TYPE;
  v_snack_br_cast_period  mars_date_dim.mars_period%TYPE;
  v_moe_code              fcst_fact.moe_code%TYPE;
  v_snack_reload          BOOLEAN := FALSE;
  v_reload                BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Check the min casting period for the BR forecast type and moe_code exist in fcst_demand_grp_local_region
  -- and changed on the aggregation date.
  CURSOR csr_min_casting_period IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
      moe_code
    FROM fcst_hdr  t1
    WHERE company_code = i_company_code
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND fcst_type_code = 'BR'  -- Period forecast
      AND EXISTS (SELECT * FROM fcst_demand_grp_local_region t2 WHERE t1.moe_code = t2.moe_code) -- only has moe set up
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY
      moe_code;
  rv_min_casting_period csr_min_casting_period%ROWTYPE;

  -- Get the reload period for snack BR which is one period ahead then the other business.
  CURSOR csr_snack_reload_period IS
    SELECT mars_period AS reload_yyyypp
    FROM mars_date_dim
    WHERE calendar_date = (SELECT MAX(calendar_date) + 1
                           FROM mars_date_dim
                           WHERE mars_period = v_casting_yyyypp);

  -- Used to check whether this is the first day of the current period for snack business
  -- becasue this day the moe_code = 0009 will reload to fcst_fact and we need to reload to
  -- fcst_local_region_fact as well.
  CURSOR csr_mars_date IS
    SELECT
      mars_period,
      period_day_num
    FROM mars_date_dim
    WHERE calendar_date = v_aggregation_date;
  rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
   write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Start - fcst_region_fact_aggregation.');

   FOR rv_min_casting_period IN csr_min_casting_period LOOP

     -- Handling the following unique moe_code.
     write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 2, 'Handling - MOE/MIN Casting Period [' ||
               rv_min_casting_period.moe_code || '/' || rv_min_casting_period.min_casting_yyyypp || ']');

     v_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;
     v_moe_code := rv_min_casting_period.moe_code;
     v_reload_yyyypp := rv_min_casting_period.min_casting_yyyypp;
     v_reload := TRUE;

     -- Snack BR type has special reload trigger.
     IF v_moe_code = '0009' THEN

        -- Get the current expected Snackfood BR casting period and compare with the received min casting period
        v_snack_br_cast_period := get_mars_period (i_aggregation_date, -56, i_log_level+1);

        IF v_casting_yyyypp <= v_snack_br_cast_period THEN
           v_snack_reload := TRUE;
           v_reload := TRUE;

           -- Then reload forecast period greater than casting_yyyypp + 1
           OPEN csr_snack_reload_period;
           FETCH csr_snack_reload_period INTO v_reload_yyyypp;
           CLOSE csr_snack_reload_period;

        ELSE
           write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 2, 'No action taken for this snackfood BR type. Reason: this casting period > casting period - 2 [' ||
                       v_casting_yyyypp || ' > ' || v_snack_br_cast_period || '].');

           v_reload :=  FALSE;
        END IF;

     END IF;

     IF v_reload = TRUE THEN
        reload_fcst_region_fact (i_company_code, v_moe_code, v_reload_yyyypp, i_log_level+1);

     END IF;
   END LOOP;

   -- Only checking for first day of period trigger if we have reload for snack today.
   IF v_snack_reload = FALSE THEN

      -- Use current date as the aggregation_date AND check whether today is the first day of the current period
      -- Snackfood, BR type has been reloaded on first day of the period, we need to reload fcst_local_region_fact
      v_aggregation_date := TRUNC(sysdate);

      OPEN csr_mars_date;
      FETCH csr_mars_date INTO rv_mars_date;
      CLOSE csr_mars_date;

      IF rv_mars_date.period_day_num = 1 THEN

         write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level, 'First day of period [' || rv_mars_date.mars_period || ']');

         -- We reload from current period so pass in last period becasue the reload function use greater than
         v_reload_yyyypp := get_mars_period (v_aggregation_date, -20, i_log_level+1);
         v_moe_code := '0009';

         reload_fcst_region_fact (i_company_code, v_moe_code, v_reload_yyyypp, i_log_level+1);
      ELSE
         write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level, 'First day of period [' || rv_mars_date.mars_period || ']');
      END IF;

   END IF;

  -- Completed fcst_local_region_fact aggregation.
  write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Completed fcst_region_fact_aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_fcst_local_region,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.fcst_region_fact_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END fcst_region_fact_aggregation;



PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Write the entry into the log table.
  utils.ods_log (ods_constants.job_type_sched_aggregation,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              i_log_level,
              'SCHEDULED_AGGREGATION.WRITE_LOG: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
END write_log;

END scheduled_aggregation;
/
