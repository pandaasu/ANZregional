CREATE OR REPLACE PACKAGE         ODS_PMX_DELETED_PROMOTION IS
/*******************************************************************************
  NAME:      execute

  PURPOSE:   This function calls the check_deleted_promotion procedure.

             The schedule is initiated by an Oracle job that runs everyday 5:30am.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/07/2008 Paul Berude          Created this function.
  1.1   14/11/2008 Steve Gregan         Modified to run by company.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company code                         147

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
 PROCEDURE execute (
  i_company_code IN company.company_code%TYPE);

/*******************************************************************************
  NAME:      check_deleted_promotion

  PURPOSE:   This function checks whether a Promotion in Promax has been physically
             deleted.  If so, then a copy is taken of the latest Promotion record
             in the ODS and a new Promotion record is created with the status of
             'X' (DELETED).

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/07/2008 Paul Berude          Created this function.
  1.1   14/11/2008 Steve Gregan         Modified to run by company and use the job_cntl
                                        table to control the date range.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company code                         147

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
 FUNCTION check_deleted_promotion (
  i_company_code IN company.company_code%TYPE,
  i_log_level    IN ods.log.log_level%TYPE
 ) RETURN NUMBER;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/07/2008 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Data Type                            Generic
  2    IN     VARCHAR2 Sort Field                           N/A
  3    IN     NUMBER   Log Level                            1
  4    IN     VARCHAR2 Log Text                             Checking Deleted Promotion

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE);

END ODS_PMX_DELETED_PROMOTION;
/


CREATE OR REPLACE PACKAGE BODY         ODS_PMX_DELETED_PROMOTION IS

PROCEDURE execute (
  i_company_code IN company.company_code%TYPE
 ) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg            constants.message_string := NULL;
  v_log_level                 ods.log.log_level%TYPE;
  v_db_name                   VARCHAR2(256) := NULL;
  v_status                    NUMBER;
  v_company_code              company.company_code%TYPE;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether the inputted company code exists in the company table.
  CURSOR csr_company_code IS
    SELECT
      company_code
    FROM
      company A
    WHERE
      company_code = v_company_code;
  rv_company_code csr_company_code%ROWTYPE;

BEGIN
  -- Initialise variables.
  v_log_level := 0;

  -- Get the database name.
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
  INTO
    v_db_name
  FROM
    dual;

  -- Starting ods_pmx_deleted_promotion package.
  write_log(ods_constants.data_type_prom, 'N/A', v_log_level, 'Start - ODS_PMX_DELETED_PROMOTION (Promax Deleted Promotion) for company [' ||
            i_company_code || ']');

  -- Check the inputted company code.
  write_log(ods_constants.data_type_prom, 'N/A', v_log_level + 1, 'Checking that the inputted parameter Company' || ' Code [' || i_company_code || '] is correct.');
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

  -- Call the check_deleted_promotion function.
  write_log(ods_constants.data_type_prom, 'N/A', v_log_level + 1, 'Calling the check_deleted_promotion function');
  v_status := check_deleted_promotion(v_company_code, v_log_level+1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the check_deleted_promotion function.';
    RAISE e_processing_error;
  END IF;

  -- Completed ods_pmx_deleted_promotion package.
  write_log(ods_constants.data_type_prom, 'N/A', v_log_level, 'ODS_PMX_DELETED_PROMOTION (Promax Deleted Promotion) - End.');

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_prom,
              'ERROR',
              v_log_level,
              'ODS_PMX_DELETED_PROMOTION.EXECUTE : ERROR: ' || v_processing_msg);

    ods_app.utils.send_email_to_group(ods_constants.job_type_ods_load,
                              'Promax Deleted Promotion',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'ODS_PMX_DELETED_PROMOTION.EXECUTE: ERROR: ' ||
                              v_processing_msg ||
                              utl_tcp.crlf);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_prom,
              'ERROR',
              v_log_level,
             'ODS_PMX_DELETED_PROMOTION.EXECUTE: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    ods_app.utils.send_email_to_group(ods_constants.job_type_ods_load,
                              'Promax Deleted Promotion',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'ODS_PMX_DELETED_PROMOTION.EXECUTE: ERROR: ' ||
                              SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

END execute;


FUNCTION check_deleted_promotion (
  i_company_code IN company.company_code%TYPE,
  i_log_level    IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- LOCAL CONTANTS DECLARATIONS
  c_job_cntl CONSTANT job_cntl.cntl_code%TYPE := 'PMX_DELETION';

  -- VARIABLE DECLARATIONS
  v_rec_count               NUMBER := 0;
  v_deleted_str_date        DATE;
  v_deleted_end_date        DATE;
  v_deleted_prom_date       DATE;
  v_deleted_prom_cmpny_code VARCHAR2(3);
  v_deleted_prom_div_code   VARCHAR2(2);
  v_deleted_prom_num        VARCHAR2(8);
  v_deleted_prom_chng_date  DATE;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Jon control.
  CURSOR csr_job_cntl IS
    SELECT cntl_value
     FROM job_cntl
    WHERE cntl_code = c_job_cntl
      AND company_code = i_company_code;
  rv_job_cntl csr_job_cntl%ROWTYPE;

  -- Check whether any promax promotions were deleted yesterday.
  CURSOR csr_deleted_promotions IS
    SELECT
      cocode,
      divcode,
      pmnum,
      datemod
    FROM
      promax.promotrack@ap0110p.world
    WHERE cocode = substr(v_deleted_prom_cmpny_code,2,2)
      AND UPPER(meth_name) = 'DELETING'
      AND datemod > v_deleted_str_date
      AND datemod <= v_deleted_end_date;
  rv_deleted_promotions csr_deleted_promotions%ROWTYPE;

  -- Check whether promotion already exists in ODS table.
  CURSOR csr_check_promotion_exists IS
    SELECT count(*) AS rec_count
    FROM
      ods.pmx_prom_hdr
    WHERE company_code = v_deleted_prom_cmpny_code
      AND division_code = v_deleted_prom_div_code
      AND prom_num = v_deleted_prom_num
      AND prom_chng_date = v_deleted_prom_date;
  rv_check_promotion_exists csr_check_promotion_exists%ROWTYPE;

  -- Select the latest ODS promotion record for the deleted promotion.
  CURSOR csr_promotion_header IS
    SELECT
      company_code,
      division_code,
      prom_num,
      prom_chng_date,
      cust_code,
      prom_type_key,
      'X' as prom_stat_code,
      natl_cust_code,
      prom_date_entrd,
      coop_pay_mthd,
      case1_pay_mthd,
      case2_pay_mthd,
      case1_fund_code,
      case2_fund_code,
      coop1_fund_code,
      coop2_fund_code,
      coop3_fund_code,
      coup1_fund_code,
      coup2_fund_code,
      scan1_fund_code,
      whse1_fund_code,
      sell_start,
      sell_end,
      buy_start,
      buy_end,
      instore_buy_start,
      instore_buy_end,
      split,
      split_end,
      disc_load,
      upload,
      upload_date,
      prom_comnt,
      store_list_code,
      cust_prom_type,
      prom_attrb,
      gross_terms,
      net_terms,
      prom_link,
      last_userid,
      add_pln_comnt1,
      add_pln_comnt2,
      add_act_comnt,
      prom_type_class,
      trnsfr_cls
    FROM
      ods.pmx_prom_hdr
    WHERE company_code = v_deleted_prom_cmpny_code
      AND division_code = v_deleted_prom_div_code
      AND prom_num = v_deleted_prom_num
      AND prom_chng_date = (select max(prom_chng_date)
                            from ods.pmx_prom_hdr
                            where company_code = v_deleted_prom_cmpny_code
                              and division_code = v_deleted_prom_div_code
                              and prom_num = v_deleted_prom_num);
  rv_promotion_header csr_promotion_header%ROWTYPE;

BEGIN
  -- Starting pmx_deleted_promotion procedure.
  write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 1, 'Starting CHECK_DELETED_PROMOTION function for company code [' || i_company_code || '].');

  --
  -- Retrieve the job control
  --
  OPEN csr_job_cntl;
  FETCH csr_job_cntl INTO rv_job_cntl;
  IF csr_job_cntl%NOTFOUND THEN
    write_log(ods_constants.data_type_prom,'ERROR',i_log_level+1,'Job control does not exist for PMX_DELETION and company code [' || i_company_code || '].');
    RAISE e_processing_error;
  ELSE
    v_deleted_str_date := to_date(rv_job_cntl.cntl_value,'yyyymmdd');
  END IF;
  CLOSE csr_job_cntl;
  v_deleted_end_date := trunc(sysdate-1);

  --
  -- Set the company code variable
  --
  v_deleted_prom_cmpny_code := i_company_code;

  -- Open cursor csr_deleted_promotions and loop through deleted promotions.
  write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 2, 'Open cursor csr_deleted_promotions and loop through deleted promotions.');
  OPEN csr_deleted_promotions;
  LOOP
    FETCH csr_deleted_promotions INTO rv_deleted_promotions;
    EXIT WHEN csr_deleted_promotions%NOTFOUND;

    BEGIN

      -- Pass the deleted promotion results into the below variables.
      v_deleted_prom_div_code := rv_deleted_promotions.divcode;
      v_deleted_prom_num := rv_deleted_promotions.pmnum;
      v_deleted_prom_date := rv_deleted_promotions.datemod;

      write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Deleted Promotion: Company [' || v_deleted_prom_cmpny_code ||
                '] / Division [' || v_deleted_prom_div_code || '] / Promotion [' || v_deleted_prom_num || '].');

      -- Fetch the record from the csr_check_promotion_exists cursor.
      OPEN  csr_check_promotion_exists;
      FETCH csr_check_promotion_exists INTO v_rec_count;
      CLOSE csr_check_promotion_exists;

      -- If the deleted promotion record already exists in the ODS table then do nothing, else insert new promotion record.
      IF v_rec_count > 0 THEN
        -- Promotion record already exists in ODS table, therefore do not insert new promotion record.
        write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Promotion already exists: Company [' || v_deleted_prom_cmpny_code ||
                  '] / Division [' || v_deleted_prom_div_code || '] / Promotion [' || v_deleted_prom_num || '].');
      ELSE
        -- Retrieve the latest version of the promotion.
        write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Opening csr_promotion_header.');
        OPEN csr_promotion_header;
        LOOP
          FETCH csr_promotion_header INTO rv_promotion_header;
          EXIT WHEN csr_promotion_header%NOTFOUND;

          -- Pass the latest promotion records change date into variable.  This is required to retrieve the promotion detail records.
          v_deleted_prom_chng_date := rv_promotion_header.prom_chng_date;

          write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Latest Promotion Record: Company [' || rv_promotion_header.company_code ||
                    '] / Division [' || rv_promotion_header.division_code || '] / Promotion [' || rv_promotion_header.prom_num ||
                    '] / Promotion Change Date [' || rv_promotion_header.prom_chng_date ||'].');

          -- Insert new promotion header record with the status of 'X' (DELETED).
          write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Insert new promotion header record with the status of ''X'' (DELETED).');
          INSERT INTO pmx_prom_hdr
           (
            company_code,
            division_code,
            prom_num,
            prom_chng_date,
            cust_code,
            prom_type_key,
            prom_stat_code,
            natl_cust_code,
            prom_date_entrd,
            coop_pay_mthd,
            case1_pay_mthd,
            case2_pay_mthd,
            case1_fund_code,
            case2_fund_code,
            coop1_fund_code,
            coop2_fund_code,
            coop3_fund_code,
            coup1_fund_code,
            coup2_fund_code,
            scan1_fund_code,
            whse1_fund_code,
            sell_start,
            sell_end,
            buy_start,
            buy_end,
            instore_buy_start,
            instore_buy_end,
            split,
            split_end,
            disc_load,
            upload,
            upload_date,
            prom_comnt,
            store_list_code,
            cust_prom_type,
            prom_attrb,
            gross_terms,
            net_terms,
            prom_link,
            last_userid,
            add_pln_comnt1,
            add_pln_comnt2,
            add_act_comnt,
            prom_type_class,
            trnsfr_cls,
            prom_hdr_load_date,
            valdtn_status
           )
          VALUES
           (
            rv_promotion_header.company_code,
            rv_promotion_header.division_code,
            rv_promotion_header.prom_num,
            v_deleted_prom_date,
            rv_promotion_header.cust_code,
            rv_promotion_header.prom_type_key,
            rv_promotion_header.prom_stat_code,
            rv_promotion_header.natl_cust_code,
            rv_promotion_header.prom_date_entrd,
            rv_promotion_header.coop_pay_mthd,
            rv_promotion_header.case1_pay_mthd,
            rv_promotion_header.case2_pay_mthd,
            rv_promotion_header.case1_fund_code,
            rv_promotion_header.case2_fund_code,
            rv_promotion_header.coop1_fund_code,
            rv_promotion_header.coop2_fund_code,
            rv_promotion_header.coop3_fund_code,
            rv_promotion_header.coup1_fund_code,
            rv_promotion_header.coup2_fund_code,
            rv_promotion_header.scan1_fund_code,
            rv_promotion_header.whse1_fund_code,
            rv_promotion_header.sell_start,
            rv_promotion_header.sell_end,
            rv_promotion_header.buy_start,
            rv_promotion_header.buy_end,
            rv_promotion_header.instore_buy_start,
            rv_promotion_header.instore_buy_end,
            rv_promotion_header.split,
            rv_promotion_header.split_end,
            rv_promotion_header.disc_load,
            rv_promotion_header.upload,
            rv_promotion_header.upload_date,
            rv_promotion_header.prom_comnt,
            rv_promotion_header.store_list_code,
            rv_promotion_header.cust_prom_type,
            rv_promotion_header.prom_attrb,
            rv_promotion_header.gross_terms,
            rv_promotion_header.net_terms,
            rv_promotion_header.prom_link,
            rv_promotion_header.last_userid,
            rv_promotion_header.add_pln_comnt1,
            rv_promotion_header.add_pln_comnt2,
            rv_promotion_header.add_act_comnt,
            rv_promotion_header.prom_type_class,
            rv_promotion_header.trnsfr_cls,
            v_deleted_prom_date,
            'UNCHECKED'
           );

          -- Insert new promotion detail record.
          write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Insert new promotion detail record.');
          INSERT INTO pmx_prom_dtl
           (
            company_code,
            division_code,
            prom_num,
            matl_zrep_code,
            prom_chng_date,
            matl_tdu_code,
            tot_case_disc,
            revenue_plnd,
            retail_sell_price_plnd,
            std_cost_plnd,
            contrib_plnd,
            coop1_plnd,
            coop2_plnd,
            coop3_plnd,
            xfact_case1_plnd,
            xfact_case1_pctg_plnd,
            case1_use_pctg_plnd,
            xfact_case2_plnd,
            xfact_case2_pctg_plnd,
            case2_use_pctg_plnd,
            xfact_qty_plnd,
            bonus_qty_plnd,
            scan_qty_plnd,
            scan_case1_plnd,
            coup_qty_plnd,
            coup_mult_plnd,
            coup_rate_plnd,
            coup_fee_plnd,
            incrmntl_qty_plnd,
            non_trade_spend_cost_plnd,
            stock_post_plnd,
            whse_wthdrwl_case1_plnd,
            whse_wthdrwl_qty_plnd,
            non_promtd_rprice_plnd,
            std_cost_actl,
            revenue_actl,
            xfact_qty1_actl,
            xfact_qty2_actl,
            bonus_qty_actl,
            cost_actl,
            contrib_actl,
            incrmntl_qty_actl,
            coop1_actl,
            coop2_actl,
            coop3_actl,
            xfact_case1_actl,
            xfact_case2_actl,
            coup_hndlg_fee_qty_actl,
            coup_qty_actl,
            coup_mult_actl,
            coup_rate_actl,
            coup_fee_actl,
            tot_case_disc_actl,
            scan_qty_actl,
            scan_case1_actl,
            retail_price_actl,
            scan_buy_qty_actl,
            ntscost_actl,
            whse_wthdrwl_case1_actl,
            whse_wthdrwl_qty_actl,
            scan_qty_accrl,
            scan_deal_accrl,
            coop1_accrl,
            coop2_accrl,
            coop3_accrl,
            case1_accrl,
            case2_accrl,
            coup_qty_accrl,
            est_qty_accrl,
            qty_accrl,
            qty_cl_accrl,
            coup_rate_accrl,
            whse_wthdrwl_case_accrl,
            whse_wthdrwl_qty_accrl,
            list_price,
            buy_base_qty,
            gross_terms,
            net_terms,
            min_qty,
            line_num,
            recnt_chng,
            tpr_disc,
            vrtl_grs_terms,
            vrtl_net_terms,
            wks_online
           )
          SELECT
            company_code,
            division_code,
            prom_num,
            matl_zrep_code,
            v_deleted_prom_date,
            matl_tdu_code,
            tot_case_disc,
            revenue_plnd,
            retail_sell_price_plnd,
            std_cost_plnd,
            contrib_plnd,
            coop1_plnd,
            coop2_plnd,
            coop3_plnd,
            xfact_case1_plnd,
            xfact_case1_pctg_plnd,
            case1_use_pctg_plnd,
            xfact_case2_plnd,
            xfact_case2_pctg_plnd,
            case2_use_pctg_plnd,
            xfact_qty_plnd,
            bonus_qty_plnd,
            scan_qty_plnd,
            scan_case1_plnd,
            coup_qty_plnd,
            coup_mult_plnd,
            coup_rate_plnd,
            coup_fee_plnd,
            incrmntl_qty_plnd,
            non_trade_spend_cost_plnd,
            stock_post_plnd,
            whse_wthdrwl_case1_plnd,
            whse_wthdrwl_qty_plnd,
            non_promtd_rprice_plnd,
            std_cost_actl,
            revenue_actl,
            xfact_qty1_actl,
            xfact_qty2_actl,
            bonus_qty_actl,
            cost_actl,
            contrib_actl,
            incrmntl_qty_actl,
            coop1_actl,
            coop2_actl,
            coop3_actl,
            xfact_case1_actl,
            xfact_case2_actl,
            coup_hndlg_fee_qty_actl,
            coup_qty_actl,
            coup_mult_actl,
            coup_rate_actl,
            coup_fee_actl,
            tot_case_disc_actl,
            scan_qty_actl,
            scan_case1_actl,
            retail_price_actl,
            scan_buy_qty_actl,
            ntscost_actl,
            whse_wthdrwl_case1_actl,
            whse_wthdrwl_qty_actl,
            scan_qty_accrl,
            scan_deal_accrl,
            coop1_accrl,
            coop2_accrl,
            coop3_accrl,
            case1_accrl,
            case2_accrl,
            coup_qty_accrl,
            est_qty_accrl,
            qty_accrl,
            qty_cl_accrl,
            coup_rate_accrl,
            whse_wthdrwl_case_accrl,
            whse_wthdrwl_qty_accrl,
            list_price,
            buy_base_qty,
            gross_terms,
            net_terms,
            min_qty,
            line_num,
            v_deleted_prom_date,
            tpr_disc,
            vrtl_grs_terms,
            vrtl_net_terms,
            wks_online
          FROM
           ods.pmx_prom_dtl
          WHERE company_code = v_deleted_prom_cmpny_code
           AND division_code = v_deleted_prom_div_code
           AND prom_num = v_deleted_prom_num
           AND prom_chng_date = v_deleted_prom_chng_date;

          -- Insert new promotion profile record.
          write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Insert new promotion profile record.');
          INSERT INTO pmx_prom_profile
           (
            company_code,
            division_code,
            prom_num,
            prom_chng_date,
            wk1_pctg,
            wk2_pctg,
            wk3_pctg,
            wk4_pctg,
            wk5_pctg,
            wk6_pctg,
            wk7_pctg,
            wk8_pctg,
            wk9_pctg,
            wk10_pctg,
            wk11_pctg,
            wk12_pctg,
            wk13_pctg,
            wk14_pctg,
            wk15_pctg,
            wk16_pctg,
            wk17_pctg,
            wk18_pctg,
            cust_offset
           )
          SELECT
            company_code,
            division_code,
            prom_num,
            v_deleted_prom_date,
            wk1_pctg,
            wk2_pctg,
            wk3_pctg,
            wk4_pctg,
            wk5_pctg,
            wk6_pctg,
            wk7_pctg,
            wk8_pctg,
            wk9_pctg,
            wk10_pctg,
            wk11_pctg,
            wk12_pctg,
            wk13_pctg,
            wk14_pctg,
            wk15_pctg,
            wk16_pctg,
            wk17_pctg,
            wk18_pctg,
            cust_offset
          FROM
           ods.pmx_prom_profile
          WHERE company_code = v_deleted_prom_cmpny_code
            AND division_code = v_deleted_prom_div_code
            AND prom_num = v_deleted_prom_num
            AND prom_chng_date = v_deleted_prom_chng_date;

        END LOOP;

        -- Closing csr_promotion_header.
        write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 3, 'Closing csr_promotion_header.');
        CLOSE csr_promotion_header;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_prom,'ERROR',i_log_level+1,
           'CHECK_DELETED_PROMOTION: cmpny_code [' || v_deleted_prom_cmpny_code || '] / div_code [' ||
            v_deleted_prom_cmpny_code || '] / prom_num [' || v_deleted_prom_num || '], Error: ' || SUBSTR(SQLERRM, 1, 512));
      RAISE e_processing_error;
    END;

     -- Commit inserted promotion.
    COMMIT;

  END LOOP;

  -- Close cursor csr_deleted_promotions.
  write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 2, 'Close cursor csr_deleted_promotions.');
  CLOSE csr_deleted_promotions;

  --
  -- Update the job control
  --
  update job_cntl
     set cntl_value = to_char(v_deleted_end_date,'yyyymmdd')
   where cntl_code = c_job_cntl
     and company_code = i_company_code;
  commit;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN e_processing_error THEN
    ROLLBACK;
    RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_prom,'ERROR',i_log_level+1,
             'ODS_PMX_DELETED_PROMOTION.CHECK_DELETED_PROMOTION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END check_deleted_promotion;


PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Write the entry into the log table.
  utils.ods_log (ods_constants.job_type_ods_load,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END write_log;

END ODS_PMX_DELETED_PROMOTION;
/
