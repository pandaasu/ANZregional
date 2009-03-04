CREATE OR REPLACE PACKAGE pricelist_reporting AS
  /******************************************************************************
     NAME:       PRICELIST_REPORTING
     PURPOSE:    This carries out pricing lookup functions based on available
                 input parameters.

     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/09/2004  Chris Horn       1. Created this package.
  ******************************************************************************/

  -- Default Reference Return Cursor.
  TYPE t_ref_cursor IS REF CURSOR;

  SUBTYPE st_message_string IS VARCHAR2 (500);

  -----------------------------------------------------------------------------
  -- Food Pricing Conditions.
  -----------------------------------------------------------------------------
  FUNCTION apply_zr05 (
    i_current_price         IN  NUMBER,
    i_sales_org             IN  VARCHAR2,
    i_distribution_channel  IN  VARCHAR2,
    i_division              IN  VARCHAR2,
    i_region                IN  VARCHAR2,
    i_material              IN  VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_zr05, WNDS, RNPS, WNPS);

  FUNCTION apply_zv01 (i_current_price IN NUMBER, i_sales_org IN VARCHAR2, i_distribution_channel IN VARCHAR2, i_price_list IN VARCHAR2, i_material IN VARCHAR2)
    RETURN NUMBER;

  FUNCTION apply_zv01 (i_current_price IN NUMBER, i_invoicing_party IN VARCHAR2, i_traded_unit_code IN VARCHAR2, i_info_type_catalogue IN VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_zv01, WNDS, RNPS, WNPS);

  FUNCTION apply_zk32 (
    i_current_price  IN  NUMBER,
    i_sales_org      IN  VARCHAR2,
    i_dstrbtn_chnl   IN  VARCHAR2,
    i_division       IN  VARCHAR2,
    i_trade_sector   IN  VARCHAR2,
    i_region         IN  VARCHAR2,
    i_brand_flag     IN  VARCHAR2,
    i_material       IN  VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_zk32, WNDS, RNPS, WNPS);

  FUNCTION apply_zk45_and_zk46 (
    i_current_price      IN  NUMBER,
    i_sales_org          IN  VARCHAR2,
    i_dstrbtn_chnl       IN  VARCHAR2,
    i_division           IN  VARCHAR2,
    i_storage_condition  IN  VARCHAR2,
    i_trade_sector       IN  VARCHAR2,
    i_brand_flag         IN  VARCHAR2,
    i_material           IN  VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_zk32, WNDS, RNPS, WNPS);

  FUNCTION get_pricing_unit_zr05 (
    i_sales_org             IN  VARCHAR2,
    i_distribution_channel  IN  VARCHAR2,
    i_division              IN  VARCHAR2,
    i_region                IN  VARCHAR2,
    i_material              IN  VARCHAR2)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (get_pricing_unit_zr05, WNDS, RNPS, WNPS);

  FUNCTION get_pricing_unit_zv01 (i_sales_org IN VARCHAR2, i_distribution_channel IN VARCHAR2, i_price_list IN VARCHAR2, i_material IN VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION get_pricing_unit_zv01 (i_invoicing_party IN VARCHAR2, i_traded_unit_code IN VARCHAR2, i_info_type_catalogue IN VARCHAR2)
    RETURN VARCHAR2;


  PRAGMA RESTRICT_REFERENCES (get_pricing_unit_zv01, WNDS, RNPS, WNPS);

  -----------------------------------------------------------------------------
  -- New Zealand Pricing Conditions.
  -----------------------------------------------------------------------------
  FUNCTION apply_zn00 (i_current_price IN NUMBER, i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_zn00, WNDS, RNPS, WNPS);

  FUNCTION apply_redist (i_current_price IN NUMBER, i_dsply_strg_cndtn_code IN VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_redist, WNDS, RNPS, WNPS);

  FUNCTION get_pricing_unit_zn00 (i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (get_pricing_unit_zn00, WNDS, RNPS, WNPS);

  FUNCTION get_zn00_status (i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (get_zn00_status, WNDS, RNPS, WNPS);

  -----------------------------------------------------------------------------
  -- Generic Code
  -----------------------------------------------------------------------------
  -- This procedure is called by the client to run a particular price list.
  -- o_result return 0 for success, 1 for failure/error
  PROCEDURE run_pricelist (o_result OUT INTEGER, o_result_msg OUT st_message_string, i_price_list IN st_message_string, o_return_cursor OUT t_ref_cursor);
  -- This procedure is called by the client to run a particular price list.

  -- o_result return 0 for success, 1 for failure/error
  PROCEDURE run_report (o_result OUT INTEGER, o_result_msg OUT st_message_string, i_report IN st_message_string, i_report_orderby IN st_message_string, o_return_cursor OUT t_ref_cursor);

  FUNCTION apply_zrsp (i_current_price IN NUMBER, i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (apply_zrsp, WNDS, RNPS, WNPS);

  FUNCTION get_product_category (i_material IN VARCHAR2)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (get_product_category, WNDS, RNPS, WNPS);

  FUNCTION get_product_type (i_material IN VARCHAR2)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (get_product_type, WNDS, RNPS, WNPS);

  FUNCTION get_market_segment (i_material IN VARCHAR2)
    RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (get_market_segment, WNDS, RNPS, WNPS);

  FUNCTION no_consumer_units (i_mltpck_qty_code IN VARCHAR2)
    RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (no_consumer_units, WNDS, RNPS, WNPS);


END pricelist_reporting;
/


CREATE OR REPLACE PACKAGE BODY pricelist_reporting AS
  PROCEDURE run_pricelist (o_result OUT INTEGER, o_result_msg OUT st_message_string, i_price_list IN st_message_string, o_return_cursor OUT t_ref_cursor) IS
  BEGIN
    -- Run return cursor
    o_result := 0;
    o_result_msg := NULL;

    OPEN o_return_cursor FOR 'SELECT * FROM ' || i_price_list || ' ORDER BY BRAND_FLAG_LONG_DESC, PRODUCT_CATEGORY, PRODUCT_TYPE, SIZE_CODE';
  EXCEPTION
    WHEN OTHERS THEN
      o_result := 1;
      o_result_msg := SQLERRM;

      OPEN o_return_cursor FOR
        SELECT NULL
        FROM DUAL
        WHERE 1 = 0;
  END run_pricelist;

  PROCEDURE run_report (
    o_result          OUT     INTEGER,
    o_result_msg      OUT     st_message_string,
    i_report          IN      st_message_string,
    i_report_orderby  IN      st_message_string,
    o_return_cursor   OUT     t_ref_cursor) IS
    v_sql  VARCHAR2 (4000);
  BEGIN
    -- Run return cursor
    o_result := 0;
    o_result_msg := NULL;
    v_sql := 'SELECT * FROM ' || i_report;

    IF i_report_orderby IS NOT NULL THEN
      v_sql := v_sql || ' ORDER BY ' || i_report_orderby;
    END IF;

    OPEN o_return_cursor FOR v_sql;
  EXCEPTION
    WHEN OTHERS THEN
      o_result := 1;
      o_result_msg := SQLERRM;

      OPEN o_return_cursor FOR
        SELECT NULL
        FROM DUAL
        WHERE 1 = 0;
  END run_report;

  FUNCTION apply_condition (
    i_current_price  IN  NUMBER,
    i_rate           IN  mfanz_price_list_dtl.rate_qty_or_pcntg%TYPE,
    i_type           IN  mfanz_price_list_dtl.crrncy_or_prcntg%TYPE)
    RETURN NUMBER IS
    v_result  NUMBER;
  BEGIN
    IF i_type = '%' THEN
      v_result := ROUND ( (i_current_price * (100 + i_rate) ) / 100, 2);
    ELSE
      v_result := i_current_price + i_rate;
    END IF;

    RETURN v_result;
  END apply_condition;

  FUNCTION apply_zr05 (
    i_current_price         IN  NUMBER,
    i_sales_org             IN  VARCHAR2,
    i_distribution_channel  IN  VARCHAR2,
    i_division              IN  VARCHAR2,
    i_region                IN  VARCHAR2,
    i_material              IN  VARCHAR2)
    RETURN NUMBER IS
    v_found   BOOLEAN;
    v_rate    pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type    pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_result  NUMBER;
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Distribution Channel / Division / Region / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZR05' AND
           t01.cndtn_table = '771' AND
           t01.vrbl_key = RPAD (i_sales_org, 4) || i_distribution_channel || i_division || i_region || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZR05' AND t01.cndtn_table = '811' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_distribution_channel || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZR05' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      v_result := apply_condition (i_current_price, v_rate, v_type);
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zr05;

  FUNCTION apply_zrsp (i_current_price IN NUMBER, i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN NUMBER IS
    v_found   BOOLEAN;
    v_rate    pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type    pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_result  NUMBER;
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZRSP' AND t01.cndtn_table = '599' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      v_result := apply_condition (i_current_price, v_rate, v_type);
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zrsp;

  FUNCTION get_pricing_unit_zr05 (
    i_sales_org             IN  VARCHAR2,
    i_distribution_channel  IN  VARCHAR2,
    i_division              IN  VARCHAR2,
    i_region                IN  VARCHAR2,
    i_material              IN  VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  VARCHAR2 (4);
  BEGIN
    v_result := NULL;

    -- Check Access Sequence : Sales Org / Distribution Channel / Division / Region / Material
    IF v_result IS NULL THEN
      BEGIN
        SELECT t01.prcng_unit
        INTO   v_result
        FROM pricelist_current_prices t01
        WHERE t01.cndtn_type = 'ZR05' AND
         t01.cndtn_table = '771' AND
         t01.vrbl_key = RPAD (i_sales_org, 4) || i_distribution_channel || i_division || i_region || i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Check Access Sequence : Sales Org / Distribution Channel / Material
    IF v_result IS NULL THEN
      BEGIN
        SELECT t01.prcng_unit
        INTO   v_result
        FROM pricelist_current_prices t01
        WHERE t01.cndtn_type = 'ZR05' AND t01.cndtn_table = '811' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_distribution_channel || i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Check Access Sequence : Sales Org / Material
    IF v_result IS NULL THEN
      BEGIN
        SELECT t01.prcng_unit
        INTO   v_result
        FROM pricelist_current_prices t01
        WHERE t01.cndtn_type = 'ZR05' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Now return the result.
    RETURN v_result;
  END get_pricing_unit_zr05;

  FUNCTION get_pricing_unit_zv01 (i_sales_org IN VARCHAR2, i_distribution_channel IN VARCHAR2, i_price_list IN VARCHAR2, i_material IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  VARCHAR2 (4);
  BEGIN
    v_result := NULL;

    -- Lookup the pricing unit.
    BEGIN
      SELECT t01.prcng_unit
      INTO   v_result
      FROM pricelist_current_prices t01
      WHERE t01.cndtn_type = 'ZV01' AND t01.cndtn_table = '956' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_distribution_channel || i_price_list || i_material;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- Now return the result.
    RETURN v_result;
  END get_pricing_unit_zv01;

  FUNCTION get_pricing_unit_zv01 (i_invoicing_party IN VARCHAR2, i_traded_unit_code IN VARCHAR2, i_info_type_catalogue IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  VARCHAR2 (4);
  BEGIN
    v_result := NULL;

    -- Lookup the pricing unit.
    BEGIN
      SELECT t01.prcng_unit
      INTO   v_result
      FROM pricelist_current_prices t01
      WHERE t01.cndtn_type = 'ZV01' AND
       t01.cndtn_table = '969' AND
       t01.vrbl_key = LPAD (i_invoicing_party, 10, '0') || RPAD (i_traded_unit_code, 18) || i_info_type_catalogue;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- Now return the result.
    RETURN v_result;
  END get_pricing_unit_zv01;

  FUNCTION apply_zk32 (
    i_current_price  IN  NUMBER,
    i_sales_org      IN  VARCHAR2,
    i_dstrbtn_chnl   IN  VARCHAR2,
    i_division       IN  VARCHAR2,
    i_trade_sector   IN  VARCHAR2,
    i_region         IN  VARCHAR2,
    i_brand_flag     IN  VARCHAR2,
    i_material       IN  VARCHAR2)
    RETURN NUMBER IS
    v_found   BOOLEAN;
    v_rate    pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type    pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_result  NUMBER;
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Distribution Channel / Division / Region / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK32' AND t01.cndtn_table = '771'
           AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_region || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel /Division / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK32' AND t01.cndtn_table = '967' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel /Division / Brand Flag
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK32' AND t01.cndtn_table = '772' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_brand_flag;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel /Division / Region / Brand Flag
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK32' AND t01.cndtn_table = '773'
           AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_region || i_brand_flag;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel / Division / Trade Sector / Region
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK32' AND
           t01.cndtn_table = '767' AND
           t01.vrbl_key = TRIM (RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_trade_sector || i_region);

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel / Division / Trade Sector
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK32' AND t01.cndtn_table = '768' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_trade_sector;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      v_result := apply_condition (i_current_price, v_rate, v_type);
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zk32;

  FUNCTION apply_zk45_and_zk46 (
    i_current_price      IN  NUMBER,
    i_sales_org          IN  VARCHAR2,
    i_dstrbtn_chnl       IN  VARCHAR2,
    i_division           IN  VARCHAR2,
    i_storage_condition  IN  VARCHAR2,
    i_trade_sector       IN  VARCHAR2,
    i_brand_flag         IN  VARCHAR2,
    i_material           IN  VARCHAR2)
    RETURN NUMBER IS
    v_found_zk45  BOOLEAN;
    v_rate_zk45   pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type_zk45   pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_found_zk46  BOOLEAN;
    v_rate_zk46   pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type_zk46   pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_rate_comb   pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_result      NUMBER;
  BEGIN
    -- This one is not mandatory so if there are not matching conditions just do a pass through.
    v_result := i_current_price;
    v_found_zk45 := FALSE;
    v_found_zk46 := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Distribution Channel / Division / Storage Condition
      IF v_found_zk45 = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate_zk45, v_type_zk45
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK45' AND t01.cndtn_table = '766'
           AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_storage_condition;

          v_found_zk45 := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel /Division / Material
      IF v_found_zk46 = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate_zk46, v_type_zk46
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK46' AND t01.cndtn_table = '967' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_material;

          v_found_zk46 := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel /Division / Brand Flag
      IF v_found_zk46 = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate_zk46, v_type_zk46
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK46' AND t01.cndtn_table = '772' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_brand_flag;

          v_found_zk46 := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;

      -- Check Access Sequence : Sales Org / Distribution Channel / Division / Trade Sector
      IF v_found_zk46 = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate_zk46, v_type_zk46
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZK46' AND t01.cndtn_table = '768' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_dstrbtn_chnl || i_division || i_trade_sector;

          v_found_zk46 := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found_zk45 = TRUE THEN
      v_rate_comb := v_rate_zk45;

      IF v_found_zk46 = TRUE THEN
        IF v_rate_zk46 = -100 THEN
          v_rate_comb := 0;
        END IF;
      END IF;

      v_result := apply_condition (i_current_price, v_rate_comb, '%');
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zk45_and_zk46;

  FUNCTION apply_zv01 (i_current_price IN NUMBER, i_sales_org IN VARCHAR2, i_distribution_channel IN VARCHAR2, i_price_list IN VARCHAR2, i_material IN VARCHAR2)
    RETURN NUMBER IS
    v_found   BOOLEAN;
    v_rate    pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type    pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_result  NUMBER;
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Distribution Channel / Price List / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZV01' AND t01.cndtn_table = '956'
           AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_distribution_channel || i_price_list || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      v_result := apply_condition (i_current_price, v_rate, v_type);
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zv01;

  FUNCTION apply_zv01 (i_current_price IN NUMBER, i_invoicing_party IN VARCHAR2, i_traded_unit_code IN VARCHAR2, i_info_type_catalogue IN VARCHAR2)
    RETURN NUMBER IS
    v_found   BOOLEAN;
    v_rate    pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type    pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_result  NUMBER;
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Distribution Channel / Price List / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZV01' AND
           t01.cndtn_table = '969' AND
           t01.vrbl_key = LPAD (i_invoicing_party, 10, '0') || RPAD (i_traded_unit_code, 18) || i_info_type_catalogue;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      v_result := apply_condition (i_current_price, v_rate, v_type);
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zv01;

  FUNCTION apply_zn00 (i_current_price IN NUMBER, i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN NUMBER IS
    v_found   BOOLEAN;
    v_rate    pricelist_current_prices.rate_qty_or_pcntg%TYPE;
    v_type    pricelist_current_prices.crrncy_or_prcntg%TYPE;
    v_result  NUMBER;
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    IF i_current_price IS NOT NULL THEN
      -- Check Access Sequence : Sales Org / Material
      IF v_found = FALSE THEN
        BEGIN
          SELECT t01.rate_qty_or_pcntg, t01.crrncy_or_prcntg
          INTO   v_rate, v_type
          FROM pricelist_current_prices t01
          WHERE t01.cndtn_type = 'ZN00' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material;

          v_found := TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      v_result := apply_condition (i_current_price, v_rate, v_type);
    END IF;

    -- Now return the result.
    RETURN v_result;
  END apply_zn00;

  FUNCTION apply_redist (i_current_price IN NUMBER, i_dsply_strg_cndtn_code IN VARCHAR2)
    RETURN NUMBER IS
    v_result  NUMBER;
  BEGIN
    IF i_dsply_strg_cndtn_code = '01' THEN   -- Chilled 6%
      v_result := ROUND ( (i_current_price * (100 - 6) ) / 100, 2);
    ELSIF i_dsply_strg_cndtn_code = '02' THEN   -- Fozen 9%
      v_result := ROUND ( (i_current_price * (100 - 9) ) / 100, 2);
    ELSIF i_dsply_strg_cndtn_code = '03' THEN   -- Shelf Stable (Ambient) 4%
      v_result := ROUND ( (i_current_price * (100 - 4) ) / 100, 2);
    ELSE
      v_result := i_current_price;
    END IF;

    RETURN v_result;
  END apply_redist;

  FUNCTION get_pricing_unit_zn00 (i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  VARCHAR2 (4);
  BEGIN
    v_result := NULL;

    -- Check Access Sequence : Sales Org / Material
    IF v_result IS NULL THEN
      BEGIN
        SELECT t01.prcng_unit
        INTO   v_result
        FROM pricelist_current_prices t01
        WHERE t01.cndtn_type = 'ZN00' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Now return the result.
    RETURN v_result;
  END get_pricing_unit_zn00;

  FUNCTION get_zn00_status (i_sales_org IN VARCHAR2, i_material IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_found      BOOLEAN;
    v_from_date  pricelist_current_prices.from_date%TYPE;
    v_to_date    pricelist_current_prices.TO_DATE%TYPE;
    v_date       pricelist_current_prices.from_date%TYPE;
    v_result     VARCHAR2 (50);
  BEGIN
    v_result := NULL;
    v_found := FALSE;

    -- Check Access Sequence : Sales Org / Material
    BEGIN
      SELECT t01.from_date, t01.TO_DATE
      INTO   v_from_date, v_to_date
      FROM pricelist_current_prices t01
      WHERE t01.cndtn_type = 'ZN00' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material;

      v_found := TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- Then perform a check to see if a condition was found.
    IF v_found = TRUE THEN
      IF v_from_date > TO_CHAR (SYSDATE, 'YYYYMMDD') THEN
        v_result := 'Launch ' || TO_CHAR (TO_DATE (v_from_date, 'YYYYMMDD'), 'DD/MM/YYYY');
      ELSIF v_from_date > TO_CHAR (SYSDATE - 28, 'YYYYMMDD') THEN
        BEGIN
          SELECT MIN (t01.from_date) AS from_date
          INTO   v_date
          FROM pricelist_all_prices t01
          WHERE t01.cndtn_type = 'ZN00' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material AND t01.from_date < v_from_date;

          IF v_date IS NULL THEN
            v_result := 'New';
          ELSE
            v_result := 'Changed ' || TO_CHAR (TO_DATE (v_from_date, 'YYYYMMDD'), 'DD/MM/YYYY');
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      ELSIF v_to_date < TO_CHAR (SYSDATE + 28, 'YYYYMMDD') THEN
        BEGIN
          SELECT MAX (t01.TO_DATE) AS TO_DATE
          INTO   v_date
          FROM pricelist_all_prices t01
          WHERE t01.cndtn_type = 'ZN00' AND t01.cndtn_table = '812' AND t01.vrbl_key = RPAD (i_sales_org, 4) || i_material AND t01.TO_DATE > v_to_date;

          IF v_date IS NULL THEN
            v_result := 'Discontinue ' || TO_CHAR (TO_DATE (v_to_date, 'YYYYMMDD'), 'DD/MM/YYYY');
          ELSE
            v_result := 'Changing ' || TO_CHAR (TO_DATE (v_to_date, 'YYYYMMDD'), 'DD/MM/YYYY');
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      ELSE
        -- Otherwise it is an established product in which case the text should be left blank.
        v_result := NULL;
      END IF;
    END IF;

    -- Now return the result.
    RETURN v_result;
  END get_zn00_status;

  FUNCTION get_product_category (i_material IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  local_classn.local_classn_desc%TYPE;
  --Lookup the product category
  BEGIN
    v_result := NULL;

    BEGIN
      SELECT l01.local_classn_desc
      INTO   v_result
      FROM local_classn l01, local_classn_type l02, local_matl_classn l03
      WHERE l03.local_classn_type_code = l02.local_classn_type_code AND
       l01.local_classn_type_code = l02.local_classn_type_code AND
       l03.local_classn_code = l01.local_classn_code AND
       l03.matl_code = i_material AND
       l03.local_matl_classn_status = 'ACTIVE' AND
       l02.local_classn_type_code = 5;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF v_result IS NULL THEN
      BEGIN
        SELECT t02.prdct_ctgry_long_desc
        INTO   v_result
        FROM mfanz_fg_matl_clssfctn t01, prdct_ctgry t02
        WHERE t01.prdct_ctgry_code = t02.prdct_ctgry_code AND t01.matl_code = i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Now return the result.
    RETURN v_result;
  END get_product_category;

  FUNCTION get_market_segment (i_material IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  local_classn.local_classn_desc%TYPE;
  --Lookup the product category
  BEGIN
    v_result := NULL;

    BEGIN
      SELECT l01.local_classn_desc
      INTO   v_result
      FROM local_classn l01, local_classn_type l02, local_matl_classn l03
      WHERE l03.local_classn_type_code = l02.local_classn_type_code AND
       l01.local_classn_type_code = l02.local_classn_type_code AND
       l03.local_classn_code = l01.local_classn_code AND
       l03.matl_code = i_material AND
       l03.local_matl_classn_status = 'ACTIVE' AND
       l02.local_classn_type_code = 4;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF v_result IS NULL THEN
      BEGIN
        SELECT t02.mkt_sgmnt_long_desc
        INTO   v_result
        FROM mfanz_fg_matl_clssfctn t01, mkt_sgmnt t02
        WHERE t01.mkt_sgmnt_code = t02.mkt_sgmnt_code AND t01.matl_code = i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Now return the result.
    RETURN v_result;
  END get_market_segment;

  FUNCTION get_product_type (i_material IN VARCHAR2)
    RETURN VARCHAR2 IS
    v_result  local_classn.local_classn_desc%TYPE;
  --Lookup the product category
  BEGIN
    v_result := NULL;

    BEGIN
      SELECT l01.local_classn_desc
      INTO   v_result
      FROM local_classn l01, local_classn_type l02, local_matl_classn l03
      WHERE l03.local_classn_type_code = l02.local_classn_type_code AND
       l01.local_classn_type_code = l02.local_classn_type_code AND
       l03.local_classn_code = l01.local_classn_code AND
       l03.matl_code = i_material AND
       l03.local_matl_classn_status = 'ACTIVE' AND
       l02.local_classn_type_code = 6;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF v_result IS NULL THEN
      BEGIN
        SELECT t02.prdct_type_long_desc
        INTO   v_result
        FROM mfanz_fg_matl_clssfctn t01, prdct_type t02
        WHERE t01.prdct_type_code = t02.prdct_type_code AND t01.matl_code = i_material;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- Now return the result.
    RETURN v_result;
  END get_product_type;

  FUNCTION no_consumer_units (i_mltpck_qty_code IN VARCHAR2)
    RETURN NUMBER IS
    v_qty  NUMBER;
  BEGIN
    v_qty := 1;
    -- Now try and conver number.
    v_qty := TO_NUMBER (i_mltpck_qty_code);

    IF v_qty < 2 OR v_qty > 50 THEN
      v_qty := 1;
    END IF;

    RETURN v_qty;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN v_qty;
  END;
END pricelist_reporting;
/
