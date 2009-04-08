CREATE OR REPLACE PACKAGE        pricelist_common AS
  /*************************************************************************
    NAME:      PRICELIST_COMMON
    PURPOSE:   This package provdes some basic price list system functionality.
  *************************************************************************/

  /*******************************************************************************
    NAME:      PERFORM_HOUSEKEEPING
    PURPOSE:   This procedure initalises the pricing model with the latest
               pricing item information.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   17/07/2006 Chris Horn           Created this procedure.
    NOTES:
  ********************************************************************************/
  PROCEDURE perform_housekeeping;

  /*******************************************************************************
    NAME:      ANALYSE_AND_ALERT_OWNERS
    PURPOSE:   This procedure will analyse the materials that are in each report
               that has alerting turned on and detected any differences in the
               materials rule set vs the report and vs the material status.  Ie.
               Assumption is that only active materials should be in the report.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   17/07/2006 Chris Horn           Created this procedure.
    NOTES:
  ********************************************************************************/
  PROCEDURE analyse_and_alert_owners;

  /*******************************************************************************
    NAME:      <Procedures Below>
    PURPOSE:   All the procedures below are used by the initialisation package
               to add new configuration items to the pricelist system.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   17/07/2006 Chris Horn           Created this procedure.
    NOTES:
  ********************************************************************************/
  PROCEDURE add_item (
    i_item_code        IN  common.st_code,
    i_price_mdl_code   IN  common.st_code,
    i_item_name        IN  common.st_name,
    i_item_select_sql  IN  common.st_sql,
    i_item_descr       IN  common.st_description);

  PROCEDURE add_price_mdl (
    i_price_mdl_code   IN  common.st_code,
    i_price_mdl_name   IN  common.st_name,
    i_sql_from_tables  IN  common.st_sql,
    i_sql_where_joins  IN  common.st_sql);

  PROCEDURE add_sales_org (i_sales_org_code IN common.st_code, i_sales_org_name IN common.st_name);

  PROCEDURE add_distbn_chnl (i_distbn_chnl_code IN common.st_code, i_distbn_chnl_name IN common.st_name);

  PROCEDURE add_price_mdl_by_sales_area (i_price_mdl_code IN common.st_code, i_sales_org_code IN common.st_code, i_distbn_chnl_code IN common.st_code);

  PROCEDURE add_rule_type (
    i_rule_type_column  IN  common.st_oracle_name,
    i_rule_type_name    IN  common.st_name,
    i_sql_vlu           IN  common.st_sql,
    i_sql_where         IN  common.st_sql);
END pricelist_common; 
/


CREATE OR REPLACE PACKAGE BODY        pricelist_common AS
  ------------------------ PACKAGE DECLARATIONS ---------------------------------
  -- Package Constants
  pc_package_name  CONSTANT common.st_package_name := 'PRICELIST_COMMON';

  ---------------------------------------------------------------------------------

  PROCEDURE perform_housekeeping IS
  BEGIN
    logit.enter_method (pc_package_name, 'PERFORM_HOUSEKEEPING');
    -- Now call the delete of formatting orphans
    pricelist_object_tracking.delete_orphans;
    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add item. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END perform_housekeeping;

  PROCEDURE analyse_and_alert_owners is
  begin
    logit.enter_method (pc_package_name, 'ANALYSE_AND_ALERT_OWNERS');
    -- Now analyse each report.
    -- TODO
    -- Now commit any changes and exit.
    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg (common.create_sql_error_msg) );
      logit.leave_method;
  end analyse_and_alert_owners;


  ---------------------------------------------------------------------------------
  --  PUBLIC FUNCTIONS/PROCEDURES.
  ---------------------------------------------------------------------------------
  PROCEDURE add_item (
    i_item_code        IN  common.st_code,
    i_price_mdl_code   IN  common.st_code,
    i_item_name        IN  common.st_name,
    i_item_select_sql  IN  common.st_sql,
    i_item_descr       IN  common.st_description) IS
    v_return        common.st_result;
    v_return_msg    common.st_message_string;
    v_item_id       common.st_id;
    v_price_mdl_id  common.st_id;

    CURSOR csr_item IS
      SELECT price_item_id
      FROM price_item
      WHERE price_item_code = UPPER (i_item_code);

    CURSOR csr_price_mdl IS
      SELECT price_mdl_id
      FROM price_mdl
      WHERE price_mdl_code = UPPER (i_price_mdl_code);
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_ITEM');

    -- Check to see if the price model exists.
    OPEN csr_price_mdl;

    FETCH csr_price_mdl
    INTO v_price_mdl_id;

    IF csr_price_mdl%NOTFOUND = TRUE THEN
      v_price_mdl_id := NULL;
    END IF;

    CLOSE csr_price_mdl;

    -- Check if the item already exists.
    OPEN csr_item;

    FETCH csr_item
    INTO v_item_id;

    IF csr_item%FOUND = TRUE THEN
      logit.LOG ('Updating Item : ' || i_item_code);

      UPDATE price_item
         SET price_mdl_id = v_price_mdl_id,
             price_item_name = i_item_name,
             sql_select = i_item_select_sql,
             price_item_desc = i_item_descr
       WHERE price_item_id = v_item_id;
    ELSE
      logit.LOG ('Inserting Item : ' || i_item_code);
      v_return := pricelist_object_tracking.get_new_id ('PRICE_ITEM', 'PRICE_ITEM_ID', v_item_id, v_return_msg);

      IF v_return <> common.gc_success THEN
        logit.log_error (common.create_error_msg ('Unable to get id for item id. ' || common.nest_err_msg (v_return_msg) ) );
      ELSE
        INSERT INTO price_item
                    (price_item_id, price_item_code, price_mdl_id, price_item_name, sql_select, price_item_desc)
             VALUES (v_item_id, UPPER (i_item_code), v_price_mdl_id, i_item_name, i_item_select_sql, i_item_descr);
      END IF;
    END IF;

    CLOSE csr_item;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add item. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END add_item;

  PROCEDURE add_price_mdl (
    i_price_mdl_code   IN  common.st_code,
    i_price_mdl_name   IN  common.st_name,
    i_sql_from_tables  IN  common.st_sql,
    i_sql_where_joins  IN  common.st_sql) IS
    CURSOR csr_price_mdl IS
      SELECT price_mdl_id
      FROM price_mdl
      WHERE price_mdl_code = UPPER (i_price_mdl_code);

    v_price_mdl_id  common.st_id;
    v_return        common.st_result;
    v_return_msg    common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_PRICE_MODEL');

    -- Check to see if the price model exists.
    OPEN csr_price_mdl;

    FETCH csr_price_mdl
    INTO v_price_mdl_id;

    IF csr_price_mdl%FOUND = TRUE THEN
      logit.LOG ('Updating Price Model : ' || i_price_mdl_code);

      UPDATE price_mdl
         SET price_mdl_name = i_price_mdl_name,
             sql_from_tables = i_sql_from_tables,
             sql_where_joins = i_sql_where_joins
       WHERE price_mdl_id = v_price_mdl_id;
    ELSE
      logit.LOG ('Inserting Price Model : ' || i_price_mdl_code);
      v_return := pricelist_object_tracking.get_new_id ('PRICE_MDL', 'PRICE_MDL_ID', v_price_mdl_id, v_return_msg);

      IF v_return <> common.gc_success THEN
        logit.log_error (common.create_error_msg ('Unable to get id for price model id. ' || common.nest_err_msg (v_return_msg) ) );
      ELSE
        INSERT INTO price_mdl
                    (price_mdl_id, price_mdl_code, price_mdl_name, sql_from_tables, sql_where_joins)
             VALUES (v_price_mdl_id, UPPER (i_price_mdl_code), i_price_mdl_name, i_sql_from_tables, i_sql_where_joins);
      END IF;
    END IF;

    CLOSE csr_price_mdl;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add price model. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END add_price_mdl;

  PROCEDURE add_sales_org (i_sales_org_code IN common.st_code, i_sales_org_name IN common.st_name) IS
    CURSOR csr_sales_org IS
      SELECT price_sales_org_id
      FROM price_sales_org
      WHERE price_sales_org_code = UPPER (i_sales_org_code);

    v_sales_org_id  common.st_id;
    v_return        common.st_result;
    v_return_msg    common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_SALES_ORG');

    -- Check to see if the price model exists.
    OPEN csr_sales_org;

    FETCH csr_sales_org
    INTO v_sales_org_id;

    IF csr_sales_org%FOUND = TRUE THEN
      logit.LOG ('Updating Sales Org : ' || i_sales_org_code);

      UPDATE price_sales_org
         SET price_sales_org_name = i_sales_org_name
       WHERE price_sales_org_id = v_sales_org_id;
    ELSE
      logit.LOG ('Inserting Sales Org : ' || i_sales_org_code);
      v_return := pricelist_object_tracking.get_new_id ('PRICE_SALES_ORG', 'PRICE_SALES_ORG_ID', v_sales_org_id, v_return_msg);

      IF v_return <> common.gc_success THEN
        logit.log_error (common.create_error_msg ('Unable to get id for sales org id. ' || common.nest_err_msg (v_return_msg) ) );
      ELSE
        INSERT INTO price_sales_org
                    (price_sales_org_id, price_sales_org_code, price_sales_org_name)
             VALUES (v_sales_org_id, UPPER (i_sales_org_code), i_sales_org_name);
      END IF;
    END IF;

    CLOSE csr_sales_org;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add sales org. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END add_sales_org;

  PROCEDURE add_distbn_chnl (i_distbn_chnl_code IN common.st_code, i_distbn_chnl_name IN common.st_name) IS
    CURSOR csr_distbn_chnl IS
      SELECT price_distbn_chnl_id
      FROM price_distbn_chnl
      WHERE price_distbn_chnl_code = UPPER (i_distbn_chnl_code);

    v_distbn_chnl_id  common.st_id;
    v_return          common.st_result;
    v_return_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_DISTBN_CHNL');

    -- Check to see if the price model exists.
    OPEN csr_distbn_chnl;

    FETCH csr_distbn_chnl
    INTO v_distbn_chnl_id;

    IF csr_distbn_chnl%FOUND = TRUE THEN
      logit.LOG ('Updating Distribution Channel : ' || i_distbn_chnl_code);

      UPDATE price_distbn_chnl
         SET price_distbn_chnl_name = i_distbn_chnl_name
       WHERE price_distbn_chnl_id = v_distbn_chnl_id;
    ELSE
      logit.LOG ('Inserting Distribution Channel : ' || i_distbn_chnl_code);
      v_return := pricelist_object_tracking.get_new_id ('PRICE_DISTBN_CHNL', 'PRICE_DISTBN_CHNL_ID', v_distbn_chnl_id, v_return_msg);

      IF v_return <> common.gc_success THEN
        logit.log_error (common.create_error_msg ('Unable to get id for distribution channel id. ' || common.nest_err_msg (v_return_msg) ) );
      ELSE
        INSERT INTO price_distbn_chnl
                    (price_distbn_chnl_id, price_distbn_chnl_code, price_distbn_chnl_name)
             VALUES (v_distbn_chnl_id, UPPER (i_distbn_chnl_code), i_distbn_chnl_name);
      END IF;
    END IF;

    CLOSE csr_distbn_chnl;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add distribution channel. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END add_distbn_chnl;

  PROCEDURE add_price_mdl_by_sales_area (i_price_mdl_code IN common.st_code, i_sales_org_code IN common.st_code, i_distbn_chnl_code IN common.st_code) IS
    CURSOR csr_price_mdl IS
      SELECT price_mdl_id
      FROM price_mdl
      WHERE price_mdl_code = UPPER (i_price_mdl_code);

    v_price_mdl_id              common.st_id;

    CURSOR csr_sales_org IS
      SELECT price_sales_org_id
      FROM price_sales_org
      WHERE price_sales_org_code = UPPER (i_sales_org_code);

    v_sales_org_id              common.st_id;

    CURSOR csr_distbn_chnl IS
      SELECT price_distbn_chnl_id
      FROM price_distbn_chnl
      WHERE price_distbn_chnl_code = UPPER (i_distbn_chnl_code);

    v_distbn_chnl_id            common.st_id;

    CURSOR csr_price_mdl_by_sales_area IS
      SELECT *
      FROM price_mdl_by_sales_area
      WHERE price_mdl_id = v_price_mdl_id AND price_sales_org_id = v_sales_org_id AND price_distbn_chnl_id = v_distbn_chnl_id;

    rv_price_mdl_by_sales_area  csr_price_mdl_by_sales_area%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_PRICE_MDL_BY_SALES_AREA');

    -- Check to see if the price model exists.
    OPEN csr_price_mdl;

    FETCH csr_price_mdl
    INTO v_price_mdl_id;

    IF csr_price_mdl%FOUND = TRUE THEN
      OPEN csr_sales_org;

      FETCH csr_sales_org
      INTO v_sales_org_id;

      IF csr_sales_org%FOUND = TRUE THEN
        OPEN csr_distbn_chnl;

        FETCH csr_distbn_chnl
        INTO v_distbn_chnl_id;

        IF csr_distbn_chnl%FOUND = TRUE THEN
          OPEN csr_price_mdl_by_sales_area;

          FETCH csr_price_mdl_by_sales_area
          INTO rv_price_mdl_by_sales_area;

          IF csr_price_mdl_by_sales_area%FOUND = TRUE THEN
            logit.LOG ('Price Model Sales Area Already Exists : ' || i_price_mdl_code || ',' || i_sales_org_code || ',' || i_distbn_chnl_code);
          ELSE
            logit.LOG ('Inserting Price Model Sales Area : ' || i_price_mdl_code || ',' || i_sales_org_code || ',' || i_distbn_chnl_code);

            INSERT INTO price_mdl_by_sales_area
                        (price_mdl_id, price_sales_org_id, price_distbn_chnl_id)
                 VALUES (v_price_mdl_id, v_sales_org_id, v_distbn_chnl_id);
          END IF;

          CLOSE csr_price_mdl_by_sales_area;
        END IF;

        CLOSE csr_distbn_chnl;
      END IF;

      CLOSE csr_sales_org;
    END IF;

    CLOSE csr_price_mdl;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add price model sales area. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END add_price_mdl_by_sales_area;

  PROCEDURE add_rule_type (
    i_rule_type_column  IN  common.st_oracle_name,
    i_rule_type_name    IN  common.st_name,
    i_sql_vlu           IN  common.st_sql,
    i_sql_where         IN  common.st_sql) IS
    CURSOR csr_rule_type IS
      SELECT price_rule_type_id
      FROM price_rule_type
      WHERE price_rule_type_column = UPPER (i_rule_type_column);

    v_rule_type_id  common.st_id;
    v_return        common.st_result;
    v_return_msg    common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_RULE_TYPE');

    -- Check to see if the price model exists.
    OPEN csr_rule_type;

    FETCH csr_rule_type
    INTO v_rule_type_id;

    IF csr_rule_type%FOUND = TRUE THEN
      logit.LOG ('Updating rule Type : ' || i_rule_type_column);

      UPDATE price_rule_type
         SET price_rule_type_name = i_rule_type_name,
             sql_vlu = i_sql_vlu,
             sql_where = i_sql_where
       WHERE price_rule_type_id = v_rule_type_id;
    ELSE
      logit.LOG ('Inserting rule Type : ' || i_rule_type_column);
      v_return := pricelist_object_tracking.get_new_id ('PRICE_RULE_TYPE', 'PRICE_RULE_TYPE_ID', v_rule_type_id, v_return_msg);

      IF v_return <> common.gc_success THEN
        logit.log_error (common.create_error_msg ('Unable to get id for rule type id. ' || common.nest_err_msg (v_return_msg) ) );
      ELSE
        INSERT INTO price_rule_type
                    (price_rule_type_id, price_rule_type_column, price_rule_type_name, sql_vlu, sql_where)
             VALUES (v_rule_type_id, UPPER (i_rule_type_column), i_rule_type_name, i_sql_vlu, i_sql_where);
      END IF;
    END IF;

    CLOSE csr_rule_type;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      logit.log_error (common.create_error_msg ('Unable to add rule type. ' || common.create_sql_error_msg) );
      logit.leave_method;
  END add_rule_type;
END pricelist_common; 
/
