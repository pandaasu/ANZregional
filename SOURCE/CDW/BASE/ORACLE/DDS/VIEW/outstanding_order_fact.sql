/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : outstanding_order_fact 
 Owner  : dds 

 DESCRIPTION 
 -----------
 Dimensional Data Store - outstanding_order_fact_old view over the dds.*_fact views 

 YYYY/MM   Author           Description 
 -------   ------           ----------- 
 2008/08   Jonathan Girling Created 

*******************************************************************************/

/*-*/ 
/* View creation 
/*-*/ 
CREATE OR REPLACE FORCE VIEW dds.outstanding_order_fact (
    company_code,
    doc_xactn_type_code,
    doc_num,
    doc_line_num,
    doc_type_code,
    creatn_date,
    eff_date,
    eff_yyyyppdd,
    cdw_eff_date,
    cdw_eff_yyyyppdd,
    sales_org_code,
    distbn_chnl_code,
    division_code,
    doc_currcy_code,
    company_currcy_code,
    exch_rate,
    purchg_company_code,
    reasn_code,
    sold_to_cust_code,
    bill_to_cust_code,
    payer_cust_code,
    qty,
    base_uom_qty,
    qty_gross_tonnes,
    qty_net_tonnes,
    ship_to_cust_code,
    hier_link_cust_code,
    matl_code,
    qty_uom_code,
    qty_base_uom_code,
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
AS

SELECT 
    t1.company_code AS company_code, 
    1 AS doc_xactn_type_code, -- 1 = Purchase Order
    t1.purch_order_doc_num AS doc_num,
    t1.purch_order_doc_line_num AS doc_line_num,
    t1.purch_order_type_code AS doc_type_code,
    t1.purch_order_eff_date AS creatn_date,
    t1.purch_order_eff_date AS eff_date,
    t1.purch_order_eff_yyyyppdd AS eff_yyyyppdd,
    CASE
        WHEN t1.purch_order_eff_date < SYSDATE
            THEN TRUNC (SYSDATE - 1, 'DD')
        ELSE t1.purch_order_eff_date
    END AS cdw_eff_date,
    CASE
    WHEN t1.purch_order_eff_date < SYSDATE
    THEN (SELECT mars_yyyyppdd
            FROM mars_date
            WHERE calendar_date =
            TRUNC (SYSDATE - 1, 'DD'))
    ELSE t1.purch_order_eff_yyyyppdd
    END AS cdw_eff_yyyyppdd,
    t1.sales_org_code AS sales_org_code,
    t1.distbn_chnl_code AS distbn_chnl_code,
    t1.division_code AS division_code,
    t1.doc_currcy_code AS doc_currcy_code,
    t1.company_currcy_code AS company_currcy_code,
    t1.exch_rate AS exch_rate,
    t1.purchg_company_code AS purchg_company_code,
    t1.purch_order_reasn_code AS reasn_code, 
    NULL AS sold_to_cust_code,
    NULL AS bill_to_cust_code, 
    NULL AS payer_cust_code,
    t1.OUT_QTY AS qty,
    t1.OUT_QTY_BASE_UOM AS base_uom_qty,
    t1.OUT_QTY_GROSS_TONNES AS qty_gross_tonnes,
    t1.OUT_QTY_NET_TONNES AS qty_net_tonnes,
    t1.cust_code AS ship_to_cust_code,
    t1.cust_code AS hier_link_cust_code, 
    t1.matl_code AS matl_code,
    t1.PURCH_ORDER_UOM_CODE AS qty_uom_code,
    t1.PURCH_ORDER_BASE_UOM_CODE AS qty_base_uom_code,
    t1.plant_code AS plant_code,
    t1.storage_locn_code AS storage_locn_code, 
    t1.out_gsv AS gsv,
    t1.out_gsv_xactn AS gsv_xactn, 
    t1.out_gsv_aud AS gsv_aud,
    t1.out_gsv_usd AS gsv_usd, 
    t1.out_gsv_eur AS gsv_eur, 
    0 AS niv,
    0 AS niv_xactn, 
    0 AS niv_aud,
    0 AS niv_usd, 
    0 AS niv_eur, 
    0 AS ngv,
    0 AS ngv_xactn, 
    0 AS ngv_aud,
    0 AS ngv_usd, 
    0 AS ngv_eur,
    t1.mfanz_icb_flag AS mfanz_icb_flag,
    t1.demand_plng_grp_division_code AS demand_plng_grp_division_code
FROM 
    dds.dw_purch_base t1
WHERE  --'OUTSTANDING'
    t1.purch_order_line_status = '*OPEN'
UNION ALL
SELECT
    t1.company_code AS company_code, 
    2 AS doc_xactn_type_code, -- 2 = Sales Order
    t1.order_doc_num AS doc_num, 
    t1.order_doc_line_num AS doc_line_num,
    t1.order_type_code AS doc_type_code, 
    t1.creatn_date AS creatn_date,
    t1.order_eff_date AS eff_date,
    t1.order_eff_yyyyppdd AS eff_yyyyppdd,
    CASE
        WHEN t1.order_eff_date < SYSDATE
            THEN TRUNC (SYSDATE - 1, 'DD')
        ELSE t1.order_eff_date
    END AS cdw_eff_date,
    CASE
        WHEN t1.order_eff_date < SYSDATE
            THEN (SELECT mars_yyyyppdd
                    FROM mars_date
                    WHERE calendar_date =
                    TRUNC (SYSDATE - 1, 'DD'))
            ELSE t1.order_eff_yyyyppdd
    END AS cdw_eff_yyyyppdd,
    t1.SALES_ORG_CODE AS sales_org_code,
    t1.DISTBN_CHNL_CODE AS distbn_chnl_code,
    t1.DIVISION_CODE AS division_code,
    t1.doc_currcy_code AS doc_currcy_code,
    t1.company_currcy_code AS company_currcy_code,
    t1.exch_rate AS exch_rate, 
    NULL AS purchg_company_code,
    t1.order_reasn_code AS reasn_code,
    t1.sold_to_cust_code AS sold_to_cust_code,
    t1.bill_to_cust_code AS bill_to_cust_code,
    t1.payer_cust_code AS payer_cust_code, 
    t1.OUT_QTY AS qty,
    t1.OUT_QTY_BASE_UOM AS base_uom_qty,
    t1.OUT_QTY_GROSS_TONNES AS qty_gross_tonnes,
    t1.OUT_QTY_NET_TONNES AS qty_net_tonnes,
    t1.ship_to_cust_code AS ship_to_cust_code,
    t1.sold_to_cust_code AS hier_link_cust_code,
    t1.matl_code AS matl_code, 
    t1.ORDER_UOM_CODE AS qty_uom_code,
    t1.ORDER_BASE_UOM_CODE AS qty_base_uom_code,
    t1.plant_code AS plant_code,
    t1.storage_locn_code AS storage_locn_code, 
    t1.OUT_GSV AS gsv,
    t1.OUT_GSV_XACTN AS gsv_xactn,
    t1.OUT_GSV_AUD AS gsv_aud, 
    t1.OUT_GSV_USD AS gsv_usd,
    t1.OUT_GSV_EUR AS gsv_eur, 
    0 AS niv,
    0 AS niv_xactn, 
    0 AS niv_aud,
    0 AS niv_usd, 
    0 AS niv_eur, 
    0 AS ngv,
    0 AS ngv_xactn, 
    0 AS ngv_aud,
    0 AS ngv_usd, 
    0 AS ngv_eur,
    t1.mfanz_icb_flag AS mfanz_icb_flag,
    t1.demand_plng_grp_division_code AS demand_plng_grp_division_code
FROM 
    dds.dw_order_base t1
WHERE  --'OUTSTANDING'
    t1.order_line_status = '*OPEN'
UNION ALL
SELECT 
    t1.company_code AS company_code, 
    3 AS doc_xactn_type_code, -- 3 = Delivery
    t1.dlvry_doc_num AS doc_num,
    TO_CHAR (t1.dlvry_doc_line_num) AS doc_line_num,
    t1.dlvry_type_code AS doc_type_code, 
    t1.creatn_date AS creatn_date,
    t1.dlvry_eff_date AS eff_date,
    t1.dlvry_eff_yyyyppdd AS eff_yyyyppdd,
    CASE
        WHEN t1.dlvry_eff_date < SYSDATE
            THEN TRUNC (SYSDATE - 1, 'DD')
        ELSE t1.dlvry_eff_date
    END AS cdw_eff_date,
    CASE
    WHEN t1.dlvry_eff_date < SYSDATE
        THEN (
                SELECT mars_yyyyppdd
                FROM mars_date
                WHERE calendar_date =
                TRUNC (SYSDATE - 1, 'DD'))
        ELSE t1.dlvry_eff_yyyyppdd
    END AS cdw_eff_yyyyppdd,
    t1.SALES_ORG_CODE AS sales_org_code,
    t1.DISTBN_CHNL_CODE AS distbn_chnl_code,
    t1.DIVISION_CODE AS division_code,
    t1.doc_currcy_code AS doc_currcy_code,
    t1.company_currcy_code AS company_currcy_code,
    t1.exch_rate AS exch_rate, 
    NULL AS purchg_company_code,
    NULL AS reasn_code, 
    t1.sold_to_cust_code AS sold_to_cust_code,
    t1.bill_to_cust_code AS bill_to_cust_code,
    t1.payer_cust_code AS payer_cust_code, 
    t1.DEL_QTY AS qty,
    t1.DEL_QTY_BASE_UOM AS base_uom_qty,
    t1.DEL_QTY_GROSS_TONNES AS qty_gross_tonnes,
    t1.DEL_QTY_NET_TONNES AS qty_net_tonnes,
    t1.ship_to_cust_code AS ship_to_cust_code,
    t1.sold_to_cust_code AS hier_link_cust_code,
    t1.matl_code AS matl_code, 
    t1.DLVRY_UOM_CODE AS qty_uom_code,
    t1.DLVRY_BASE_UOM_CODE AS qty_base_uom_code,
    t1.plant_code AS plant_code,
    t1.storage_locn_code AS storage_locn_code, 
    t1.DEL_GSV AS gsv,
    t1.DEL_GSV_XACTN AS gsv_xactn, 
    t1.DEL_GSV_AUD AS gsv_aud,
    t1.DEL_GSV_USD AS gsv_usd, 
    t1.DEL_GSV_EUR AS gsv_eur, 
    0 AS niv,
    0 AS niv_xactn, 
    0 AS niv_aud,
    0 AS niv_usd, 
    0 AS niv_eur, 
    0 AS ngv,
    0 AS ngv_xactn, 
    0 AS ngv_aud,
    0 AS ngv_usd, 
    0 AS ngv_eur,
    t1.mfanz_icb_flag AS mfanz_icb_flag,
    t1.demand_plng_grp_division_code AS demand_plng_grp_division_code
FROM 
    dds.dw_dlvry_base t1
WHERE --OUTSTANDING
    t1.dlvry_line_status = '*OPEN';



/*-*/
/* Authority 
/*-*/

GRANT SELECT ON DDS.OUTSTANDING_ORDER_FACT TO ODS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.OUTSTANDING_ORDER_FACT TO DDS_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.OUTSTANDING_ORDER_FACT TO KPI_APP WITH GRANT OPTION;
GRANT SELECT ON DDS.OUTSTANDING_ORDER_FACT TO PUBLIC;



/*-*/
/* Synonym 
/*-*/
CREATE OR REPLACE PUBLIC SYNONYM OUTSTANDING_ORDER_FACT FOR DDS.OUTSTANDING_ORDER_FACT;
