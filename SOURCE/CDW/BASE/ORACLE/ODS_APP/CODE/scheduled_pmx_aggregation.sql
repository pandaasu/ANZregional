CREATE OR REPLACE PACKAGE         scheduled_pmx_aggregation IS

/*******************************************************************************
  NAME:      run_daily_aggregation
  PURPOSE:   This procedure is the main daily promotion aggregation routine, which
             calls the other daily run procedures and functions.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/04/2007 Craig Ford           Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_daily_aggregation (
  i_company_code               IN company.company_code%TYPE
 );

/*******************************************************************************
  NAME:      run_periodic_aggregation
  PURPOSE:   This procedure is the main periodical routine, which calls the other
             periodically run procedures and functions.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/04/2007 Kris Lee          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Any Date of Aggregation Period       20040101
  3    IN     BOOLEAN  Whether to convert aggregation date  true
                       to the date and time at the company.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_periodic_aggregation (
  i_company_code               IN company.company_code%TYPE,
  i_date_of_aggregation_period IN DATE,
  i_get_company_time           IN BOOLEAN DEFAULT FALSE);

/* *****************************************************************************
 *       Promotion Reference tables Flattening
 * ***************************************************************************** */

  /*******************************************************************************
    NAME:      promotion_reference_flattening
    PURPOSE:   Flatten the various promotion reference tables.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   05/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ******************************************************************************* */
PROCEDURE promotion_reference_flattening(
    i_company_code    IN pmx_cust.company_code%TYPE,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) ;

/*******************************************************************************
    NAME:      pmx_cust_flattening
    PURPOSE:   Flatten the Promotion Customer table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_cust_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;


  /*******************************************************************************
    NAME:      pmx_acct_mgr_flattening
    PURPOSE:   Flatten the Promotion Account Manager table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/04/2007 Kris Lee           Created this procedure.
    2.0   09/12/2009 Steve Gregan       Added additional customer fields.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_acct_mgr_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      pmx_claim_type_flattening
    PURPOSE:   Flatten the Promotion Claim Type table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_claim_type_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      pmx_fund_type_flattening
    PURPOSE:   Flatten the Promotion Fund Type table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_fund_type_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      pmx_prom_attrb_flattening
    PURPOSE:   Flatten the Promotion Attribute table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_prom_attrb_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      pmx_prom_status_flattening
    PURPOSE:   Flatten the Promotion Status table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_prom_status_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      pmx_prom_type_flattening
    PURPOSE:   Flatten the Promotion Type table.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   05/04/2007 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_prom_type_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER;

/* *****************************************************************************
 *    PERIODIC AGGREGATION
 * ***************************************************************************** */

 /*******************************************************************************
  NAME:      prom_fact_aggregation
  PURPOSE:   This function aggregates the prom_fact table based on the following
             promotion tables:
             - ods.pmx_prom_hdr
             - ods.pmx_prom_dtl
             - ods.pmx_prom_profile

             A transaction record is created for each promotion material promoted
             period at the period of a promotion is created/modified.
             If a promotion material falls in a Over Spend or Under Spend criteria
             an additional record is created to report the Over Spend or Under
             Spend amount on the mars period it is happened.

             NOTE:  BY DEFAULT it will aggregate any promotion loaded yesterday.
             DO not allow to run by a given date, becasue it can only be run by the
             loading date in ascending order, otherwise it will stuff up the
               slowly change approach.
             IF in any time we need to re-build the prom_fact table, we need to delete
             all the records from prom_fact and run by prom_hdr_load_date in ascending
             order in order to re-build the prom_fact table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   17/04/2007 Kris Lee             Created this function.
  1.1   01/04/2008 Kris Lee             Move the promotion reference flattening
                                        from ods_to_dds_flattening package to
                                         here
  1.2   16/10/2008 Steve Gregan         Redeveloped the function to process claims
                                        and phased values correctly
  2.0   17/11/2009 Steve Gregan         Changed aggregation to reaggregate from point in time

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION prom_fact_aggregation (
  i_company_code               IN company.company_code%TYPE,
  i_log_level                  IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      claim_fact_aggregation
  PURPOSE:   This function aggregates the claim_fact and claim_allocn_fact tables
             based on the following claim tables:
             - ods.pmx_claim_doc (dds.claim_fact)
             - ods.pmx_claim_hdr and ods.pmx_claim_dtl (dds.claim_allocn_fact)

             NOTE:  BY DEFAULT it will aggregate any claim document loaded yesterday.
             DO not allow to run by a given date, becasue it can only be run by the
             loading date in ascending order, otherwise it will stuff up the
             slowly change approach.
             IF in any time we need to re-build the claim_fact table, we need to delete
             all the records from claim_fact and run by claim_doc_load_date in ascending
             order in order to re-build the claim_fact and claim_allocn_fact table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/04/2007 Kris Lee             Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION claim_fact_aggregation (
  i_company_code               IN company.company_code%TYPE,
  i_log_level                  IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/* *****************************************************************************
 *    PERIODIC AGGREGATION
 * ***************************************************************************** */

/*******************************************************************************
  NAME:      accrls_fact_aggregation
  PURPOSE:   This function aggregates the accrls_fact table based on the following
             accuals table:
             - ods.pmx_accrls

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/04/2007 Kris Lee          Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Any Date of the Aggregation Period   20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION accrls_fact_aggregation (
  i_company_code               IN company.company_code%TYPE,
  i_date_of_aggregation_period IN DATE,
  i_log_level                  IN ods.log.log_level%TYPE
  ) RETURN NUMBER;


/* *****************************************************************************
 *          HELPER FUNCTIONS
 * *****************************************************************************/

  /*******************************************************************************
    NAME:      pmx_cust_dmd_plng_grp_mapping
    PURPOSE:   map the demand planning group to the pmx_cust_dim

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/04/2008 Kris Lee           Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN    log.log_level%TYPE
                            The log level to start logging at.   1

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
FUNCTION pmx_cust_dmd_plng_grp_mapping (
  i_company_code          IN pmx_cust.company_code%TYPE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      get_off_invoice_flag
  PURPOSE:   This Function return the off_invoice_flag for the Promotion Funding type.
             It allows to give two fund types, either one of the given fund type's
             off_invoice_flag = T, then the function will return T otherwise it
             will return F.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/04/2007 Craig Ford            Created this function

  PARAMETERS:
  Pos  Type   Format   Description                              Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                             147
  2    IN     VARCHAR2 Division Code                            05
  3    IN     VARCHAR2 Fund Code1                               CAE
  4    IN     VARCHAR2 Fund Code2                               CAE
  5    IN     NUMBER   Job Type Code                            15
  6    IN     NUMBER   Log Level                                1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION get_off_invoice_flag (
  i_company_code    IN pmx_prom_hdr.company_code%TYPE,
  i_division_code   IN pmx_prom_hdr.division_code%TYPE,
  i_fund_code1      IN pmx_prom_hdr.case1_fund_code%TYPE,
  i_fund_code2      IN pmx_prom_hdr.case1_fund_code%TYPE,
  i_job_type        IN ods.log.job_type_code%TYPE,
  i_log_level       IN ods.log.log_level%TYPE
 ) RETURN VARCHAR2;

/*******************************************************************************
  NAME:      convert_char_to_percent
  PURPOSE:   This function convert the promotion split char from A -> K to
             100 -> 0 as percentage based on the business rule

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/04/2004 Kris Lee          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Data Type                            A
  2   IN     NUMBER   Log Level                            1

  RETURN VALUE: 100 to 0
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
 FUNCTION convert_char_to_percent (
  i_char        IN pmx_prom_hdr.split%TYPE,
  i_log_level   IN ods.log.log_level%TYPE
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
  1.0   02/04/2007 Kris Lee           Created this function

  PARAMETERS:
  Pos  Type   Format   Description                              Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     DATE     date of based on                         20061231
  2    IN     NUMBER   offset number of days on the date given  28
  3    IN     NUMBER   Job Type Code                            15
  4    IN     NUMBER   Log Level                                1

  RETURN VALUE: NUMBER IN yyyypp FORMAT
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION get_mars_period (
  i_date        IN DATE,
  i_offset_days IN NUMBER,
  i_job_type    IN ods.log.job_type_code%TYPE,
  i_log_level   IN ods.log.log_level%TYPE
 ) RETURN NUMBER;


/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/04/2004 Kris Lee          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Data Type                            Generic
  2    IN     VARCHAR2 Sort Field                           Aggregation Date
  3    IN     NUMBER   Log Level                            1
  4    IN     VARCHAR2 Log Text                             Starting Aggregations

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE);

END scheduled_pmx_aggregation;
/


CREATE OR REPLACE PACKAGE BODY         scheduled_pmx_aggregation IS

  -- LOCAL USER TYPE DECLARATIONS
  TYPE tab_typ_phased_percent IS TABLE OF prom_fact.phased_percent%TYPE INDEX BY BINARY_INTEGER;
  TYPE tab_typ_phased_yyyypp  IS TABLE OF prom_fact.prom_yyyypp%TYPE INDEX BY BINARY_INTEGER;
  TYPE tab_type_amt           IS TABLE OF prom_fact.claim%TYPE INDEX BY BINARY_INTEGER;

  -- LOCAL CONTANTS DECLARATIONS
  c_future_eff_end_period CONSTANT mars_date_dim.mars_period%TYPE  := 999913;  --last period of year 9999
  c_rebate_type           CONSTANT pmx_prom_hdr.prom_type_class%TYPE := 'R';
  c_job_cntl              CONSTANT job_cntl.cntl_code%TYPE := 'PMX_AGGREGATION';

  c_rec_type_over_spend   CONSTANT VARCHAR2(1) := 'O';
  c_rec_type_under_spend  CONSTANT VARCHAR2(1) := 'U';
  c_rec_type_normal_tx    CONSTANT VARCHAR2(1) := 'N';

  c_idx_iss_deferred      CONSTANT PLS_INTEGER := 1;
  c_idx_case              CONSTANT PLS_INTEGER := 2;
  c_idx_scan              CONSTANT PLS_INTEGER := 3;
  c_idx_fixed             CONSTANT PLS_INTEGER := 4;
  c_idx_on_invoice        CONSTANT PLS_INTEGER := 5;
  c_idx_all               CONSTANT PLS_INTEGER := 6;

  v_cntl_str_date date;
  v_cntl_end_date date;

  -- LOCAL FUNCTION OR PROCEDURE DECLARATIONS
  /*******************************************************************************
    NAME:      get_prom_phased_periods
    PURPOSE:   This function get the mars_period(s) in a sql table by the given
               date frame

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   18/04/2007 Kris Lee             Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1   IN     NUMBER   Log Level                            1
    2   IN     DATE     start date                           20070401
    3   IN     DATE     end date                             20070629
    4   IN OUT table of NUMBER mars period

    RETURN VALUE: constants.failure or constants.success
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION get_prom_phased_periods (
    i_log_level          IN ods.log.log_level%TYPE,
    i_buy_start_date     IN prom_fact.buy_start_date%TYPE,
    i_buy_end_date       IN prom_fact.buy_end_date%TYPE,
    io_tab_phased_yyyypp IN OUT NOCOPY tab_typ_phased_yyyypp
  ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      get_prom_phased_percents
    PURPOSE:   This function get the percentage of each period in a sql table based
               on the promotion type class.
               Percentage for each period's calculation rules:
               (A). If Rebate Type :
                    First period percentage = interprete split value
                    Last period percentage = interprete split end value
                    Periods between = equally split the remaining percentages
               (B)  Not Rebate Type :
                    Have corresponding profile record,
                       then get weekly percentage from profile table
                    NO corresponding profile record,
                       then equally split 100 percent to promotion weeks

                    First period - based on start week of period, sum number of
                                   remainding weeks of a period
                                   eg: start week of first period = 2, then the percentage
                                   for first period will be wk1_pctg + wk2_pctg + wk3_pctg
                    Other periods - sum four weeks pctg

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   23/04/2007 Kris Lee             Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1   IN     NUMBER    Log Level                            1
    2   IN     VARCHAR2  Company Code                         147
    3   IN     VARCHAR2  Divsion Code                         05
    4   IN     VARCHAR2  Promotion Number                     12345678
    5   IN     DATE      Promotion Update Date                20070425
    6   IN     VARCHAR2  Promotion Type Class                 N
    7   IN     VARCHAR2  Split                                K
    8   IN     VARCHAR2  End Split                            K
    9   IN     NUMBER    First Period Start Week              2
    10  IN     NUMBER    Number of promotion periods          3
    11  IN OUT table of NUMBER phase percent
    12  IN     DATE      Buy start date                       20070401
    13  IN     DATE      Buy end date                         20070629

    RETURN VALUE: constants.failure or constants.success
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION get_prom_phased_percents (
   i_log_level           IN ods.log.log_level%TYPE,
   i_company_code        IN pmx_prom_hdr.company_code%TYPE,
   i_division_code       IN pmx_prom_hdr.division_code%TYPE,
   i_prom_num            IN pmx_prom_hdr.prom_num%TYPE,
   i_prom_chng_date      IN pmx_prom_hdr.prom_chng_date%TYPE,
   i_prom_type_class     IN pmx_prom_hdr.prom_type_class%TYPE,
   i_split               IN pmx_prom_hdr.split%TYPE,
   i_split_end           IN pmx_prom_hdr.split_end%TYPE,
   i_start_period_week   IN mars_date_dim.mars_week_of_period%TYPE,
   i_period_count        IN PLS_INTEGER,
   io_tab_phased_percent IN OUT NOCOPY tab_typ_phased_percent,
   i_buy_start           IN pmx_prom_hdr.buy_start%TYPE,
   i_buy_end             IN pmx_prom_hdr.buy_end%TYPE
  ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      get_origl_prom_cost
    PURPOSE:   This function sums up the promotion level promotion cost which is
               the:
               total of planned cost of issues deferred + case (on_invoice or off_invoice)
               + scan + fixed for a promotion

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   26/04/2007 Kris Lee          Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1   IN     NUMBER    Log Level                            1
    2   IN     VARCHAR2  Company Code                         147
    3   IN     VARCHAR2  Divsion Code                         05
    4   IN     VARCHAR2  Promotion Number                     12345678
    5   IN     DATE      Promotion Update Date                20070425

    RETURN VALUE: total promotion cost (number)
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION get_origl_prom_cost (
   i_log_level           IN ods.log.log_level%TYPE,
   i_company_code        IN pmx_prom_hdr.company_code%TYPE,
   i_division_code       IN pmx_prom_hdr.division_code%TYPE,
   i_prom_num            IN pmx_prom_hdr.prom_num%TYPE,
   i_prom_chng_date      IN pmx_prom_hdr.prom_chng_date%TYPE
  ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      check_phased_overspend
    PURPOSE:   This function checks whether a promotion is overspent based on the
               phasing of the promotion.

               The function compares year-to-period claims against the year-to-period
               accrual cost (i.e. Total Planned) from the claim table.
               This is used for all non on invoice promotions.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/11/2008 Steve Gregan         Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1   IN     NUMBER    Log Level                            1
    2   IN     VARCHAR2  Company Code                         147
    3   IN     VARCHAR2  Divsion Code                         05
    4   IN     VARCHAR2  Promotion Number                     12345678
    5   IN     DATE      Promotion Update Date                20070425
    6   IN     NUMBER    Phased Percentage                    .50
    7   IN     NUMBER    Promotion Period                     200704
    8   OUT    VARCHAR   Promotion Overspenf Flag             T (Overspend)


    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION check_phased_overspend (
   i_log_level           IN ods.log.log_level%TYPE,
   i_company_code        IN pmx_prom_hdr.company_code%TYPE,
   i_division_code       IN pmx_prom_hdr.division_code%TYPE,
   i_prom_num            IN pmx_prom_hdr.prom_num%TYPE,
   i_prom_chng_date      IN pmx_prom_hdr.prom_chng_date%TYPE,
   i_pctg                IN NUMBER,
   i_prom_yyyypp         IN prom_fact.prom_yyyypp%TYPE,
   o_isOverSpend         OUT VARCHAR2
  ) RETURN NUMBER;

  /*******************************************************************************
    NAME:      check_phased_oi_overspend
    PURPOSE:   This function checks whether a promotion is overspent based on the
               phasing of the promotion.

               The function compares year-to-period claims against the year-to-period
               accrual cost (i.e. Total Planned) from the promotion table.
               This is used for all on invoice promotions.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   05/08/2008 Paul Berude          Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1   IN     NUMBER    Log Level                            1
    2   IN     VARCHAR2  Company Code                         147
    3   IN     VARCHAR2  Divsion Code                         05
    4   IN     VARCHAR2  Promotion Number                     12345678
    5   IN     DATE      Promotion Update Date                20070425
    6   IN     NUMBER    Phased Percentage                    .50
    7   IN     NUMBER    Promotion Period                     200704
    8   OUT    VARCHAR   Promotion Overspenf Flag             T (Overspend)


    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION check_phased_oi_overspend (
   i_log_level           IN ods.log.log_level%TYPE,
   i_company_code        IN pmx_prom_hdr.company_code%TYPE,
   i_division_code       IN pmx_prom_hdr.division_code%TYPE,
   i_prom_num            IN pmx_prom_hdr.prom_num%TYPE,
   i_prom_chng_date      IN pmx_prom_hdr.prom_chng_date%TYPE,
   i_pctg                IN NUMBER,
   i_prom_yyyypp         IN prom_fact.prom_yyyypp%TYPE,
   o_isOverSpend         OUT VARCHAR2
  ) RETURN NUMBER;

   procedure execute_period_end(par_company_code in company.company_code%type);

 /* **************************************************************
  *                MAIN PROCEDURES
  ****************************************************************/

PROCEDURE run_daily_aggregation (
  i_company_code IN company.company_code%TYPE
 ) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg constants.message_string;
  v_company_code   company.company_code%TYPE;
  v_log_level      ods.log.log_level%TYPE;
  v_status         NUMBER;
  v_db_name        VARCHAR2(256) := NULL;

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

  CURSOR csr_job_cntl IS
    SELECT cntl_value
     FROM job_cntl
    WHERE cntl_code = c_job_cntl
      AND company_code = v_company_code;
  rv_job_cntl csr_job_cntl%ROWTYPE;

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

  -- Start promotion daily scheduled aggregation.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Daily PMX Aggregations - Start');

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

  --
  -- Retrieve the job control
  --
  OPEN csr_job_cntl;
  FETCH csr_job_cntl INTO rv_job_cntl;
  IF csr_job_cntl%NOTFOUND THEN
    v_processing_msg := 'Job control does not exist for PMX_AGGREGATION and company code [' || v_company_code || '].';
    RAISE e_processing_error;
  ELSE
    v_cntl_str_date := to_date(rv_job_cntl.cntl_value,'yyyymmddhh24miss');
  END IF;
  CLOSE csr_job_cntl;
  v_cntl_end_date := sysdate;

  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Call procedure to flatten all the promotion reference tables');
  promotion_reference_flattening(v_company_code, v_log_level+1);

  -- Calling the prom_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the prom_fact_aggregation function.');
  v_status := prom_fact_aggregation(v_company_code, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the prom_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the claim_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the claim_fact_aggregation function.');
  v_status := claim_fact_aggregation(v_company_code, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the claim_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  --
  -- Update the job control
  --
  update job_cntl
     set cntl_value = to_char(v_cntl_end_date,'yyyymmddhh24miss')
   where cntl_code = c_job_cntl
     and company_code = v_company_code;
  commit;

  -- End scheduled aggregation processing.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Daily PMX Aggregations - End');

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'scheduled_pmx_aggregation.run_daily_aggregation: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_pmx_aggregation,
                              'MFANZ CDW Scheduled PMX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'scheduled_pmx_aggregation.run_daily_aggregation: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'scheduled_pmx_aggregation.run_daily_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_pmx_aggregation,
                              'MFANZ CDW Scheduled PMX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'scheduled_pmx_aggregation.run_daily_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

END run_daily_aggregation;

PROCEDURE run_periodic_aggregation (
   i_company_code               IN company.company_code%TYPE,
   i_date_of_aggregation_period IN DATE,
   i_get_company_time           IN BOOLEAN DEFAULT FALSE) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg             constants.message_string;
  v_company_code               company.company_code%TYPE;
  v_date_of_aggregation_period DATE;
  v_log_level                  ods.log.log_level%TYPE;
  v_status                     NUMBER;
  v_db_name                    VARCHAR2(256) := NULL;
  v_aggregation_period         mars_date_dim.mars_period%TYPE;

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
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Periodical PMX Aggregations - Start');

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
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Converting the inputted Any Date of Aggregation' ||
    ' Period [' || TO_CHAR(i_date_of_aggregation_period) || '] to standard date format.');
  BEGIN
    IF i_date_of_aggregation_period IS NULL THEN
      RAISE e_processing_error;
    ELSE
      IF (i_get_company_time) THEN
        v_date_of_aggregation_period := utils.tz_conv_date_time(i_date_of_aggregation_period,
                                                                ods_constants.db_timezone,
                                                                rv_company_code.company_timezone_code);
      ELSE
        v_date_of_aggregation_period := i_date_of_aggregation_period;
      END IF;

      v_date_of_aggregation_period := TO_DATE(TO_CHAR(v_date_of_aggregation_period, 'YYYYMMDD'), 'YYYYMMDD');
    END IF;

    v_aggregation_period := get_mars_period (v_date_of_aggregation_period, 0, ods_constants.job_type_pmx_aggregation, v_log_level + 1);
    IF v_aggregation_period IS NULL THEN
      v_processing_msg := 'Error on converting Date Of aggregation to mars period';
      RAISE e_processing_error;
    END IF;

    write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Will be aggregating for Company Code [' || i_company_code || '] and Period [' || TO_CHAR(v_aggregation_period) ||'].');

  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'Unable to convert the inputted Date of Aggregation Period [' || TO_CHAR(i_date_of_aggregation_period, 'YYYYMMDD') || '] from string to date format.';
      RAISE e_processing_error;
  END;

  -- Calling the accrls_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the accrls_fact_aggregation function.');
  v_status := accrls_fact_aggregation(v_company_code,
                                      v_date_of_aggregation_period,
                                      v_log_level + 1);

  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the accrls_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- End scheduled aggregation processing.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Periodical PMX Aggregations - End');

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'scheduled_pmx_aggregation.run_periodic_aggregation: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_pmx_aggregation,
                              'MFANZ CDW Scheduled PMX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'scheduled_pmx_aggregation.run_periodic_aggregation: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'scheduled_pmx_aggregation.run_periodic_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_pmx_aggregation,
                              'MFANZ CDW Scheduled PMX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'scheduled_pmx_aggregation.run_periodic_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

END run_periodic_aggregation;

/*****************************************************************
 *  REFERENCE DATA FLATTENING PROCEDURES
 * *************************************************************** */
PROCEDURE promotion_reference_flattening(
    i_company_code    IN pmx_cust.company_code%TYPE,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    v_has_error      BOOLEAN := FALSE;
    v_status         NUMBER;
    v_processing_msg constants.message_string := '';
    v_db_name        VARCHAR2(256) := NULL;


  BEGIN
    v_data_type  := ods_constants.data_type_prom_refs;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field, v_log_level, 'Flattening various Promotion Reference Tables- Start');

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    v_log_level := v_log_level + 1;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Customer Flattening');

    v_status := pmx_cust_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := 'pmx_cust_flattening ';
      v_has_error := TRUE;
    ELSE
      write_log(v_data_type, v_sort_field, v_log_level, 'Calling pmx_cust_dmd_plng_grp_mapping to map customer demand planning group');

      v_status := pmx_cust_dmd_plng_grp_mapping(i_company_code, v_log_level + 1);
      IF v_status <> constants.success THEN
          v_processing_msg := 'pmx_cust_dmd_plng_grp_mapping ';
          v_has_error := TRUE;
      END IF;
    END IF;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Account Manager Flattening');

    v_status := pmx_acct_mgr_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := v_processing_msg || 'pmx_acct_mgr_flattening ';
      v_has_error := TRUE;
    END IF;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Claim Type Flattening');

    v_status := pmx_claim_type_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := v_processing_msg || 'pmx_claim_type_flattening ';
      v_has_error := TRUE;
    END IF;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Fund Type Flattening');

    v_status := pmx_fund_type_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := v_processing_msg || 'pmx_fund_type_flattening ';
      v_has_error := TRUE;
    END IF;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Attribute Flattening');

    v_status := pmx_prom_attrb_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := v_processing_msg || 'pmx_prom_attrb_flattening ';
      v_has_error := TRUE;
    END IF;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Status Flattening');

    v_status := pmx_prom_status_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := v_processing_msg || 'pmx_prom_status_flattening ';
      v_has_error := TRUE;
    END IF;

    write_log(v_data_type, v_sort_field, v_log_level, 'Calling Promotion Type Flattening');

    v_status := pmx_prom_type_flattening(v_log_level + 1);
    IF v_status <> constants.success THEN
      v_processing_msg := v_processing_msg || 'pmx_prom_type_flattening ';
      v_has_error := TRUE;
    END IF;

    v_log_level := v_log_level - 1;

    write_log(v_data_type, v_sort_field, v_log_level, 'Finished Flattening for the various Promotion Reference Tables');

    IF v_has_error THEN
      v_processing_msg := 'Unable to successfully running the ' || v_processing_msg;
      utils.send_email_to_group(ods_constants.job_type_pmx_aggregation,
                              'MFANZ CDW Scheduled PMX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'scheduled_pmx_aggregation.promotion_reference_flattening: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(v_data_type,
                'ERROR',
                0,
                '!!!ERROR!!! - FATAL ERROR FOR PROMOTION_REFERENCE_FLATTENING.' ||
                ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

  END promotion_reference_flattening;

FUNCTION pmx_cust_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_cust IS
      SELECT
        company_code,
        division_code,
        pmx_cust_name,
        cust_code,
        prmtbl_flag,
        acct_mgr_key,
        major_ref_code,
        major_ref_desc,
        mid_ref_code,
        mid_ref_desc,
        minor_ref_code,
        minor_ref_desc,
        main_code,
        main_name,
        cust_level,
        parent_cust_code,
        parent_cust_desc,
        parent_gl_cust_code,
        parent_gl_cust_desc,
        gl_code,
        distbn_chnl_code
      FROM
        pmx_cust_dim
      MINUS
      SELECT
        t01.company_code,
        t01.division_code,
        t01.cust_name as pmx_cust_name,
        t01.cust_code,
        t01.prom_flag as prmtbl_flag,
        t01.acct_mgr_key,
        t01.major_ref_code,
        t02.cust_name as major_ref_desc,
        t01.mid_ref_code,
        t03.cust_name as mid_ref_desc,
        t01.minor_ref_code,
        t04.cust_name as minor_ref_desc,
        t01.main_code,
        t05.cust_name as main_name,
        t01.cust_level,
        t01.parent_cust_code,
        t06.cust_name as parent_cust_desc,
        t01.parent_gl_cust_code,
        t07.cust_name as parent_gl_cust_desc,
        t01.gl_code,
        t01.distbn_chnl_code
      FROM
        pmx_cust t01,
        pmx_cust t02,
        pmx_cust t03,
        pmx_cust t04,
        pmx_cust t05,
        pmx_cust t06,
        pmx_cust t07
      WHERE t01.company_code = t02.company_code(+)
        AND t01.division_code = t02.division_code(+)
        AND t01.major_ref_code = t02.cust_code(+)
        AND t01.company_code = t03.company_code(+)
        AND t01.division_code = t03.division_code(+)
        AND t01.mid_ref_code = t03.cust_code(+)
        AND t01.company_code = t04.company_code(+)
        AND t01.division_code = t04.division_code(+)
        AND t01.minor_ref_code = t04.cust_code(+)
        AND t01.company_code = t05.company_code(+)
        AND t01.division_code = t05.division_code(+)
        AND t01.main_code = t05.cust_code(+)
        AND t01.company_code = t06.company_code(+)
        AND t01.division_code = t06.division_code(+)
        AND t01.parent_cust_code = t06.cust_code(+)
        AND t01.company_code = t07.company_code(+)
        AND t01.division_code = t07.division_code(+)
        AND t01.parent_gl_cust_code = t07.cust_code(+);
    rv_dim_minus_pmx_cust csr_dim_minus_pmx_cust%ROWTYPE;

  BEGIN

    v_data_type  := ods_constants.data_type_pmx_cust;
    v_sort_field := 'PMX CUST';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Customer Flattening.');

    write_log(v_data_type, v_sort_field,v_log_level+1,'Removing Promotion Customer from Dim that are not in the Source Tables.');


    -- Find rows in pmx_cust_dim that are changed or removed from pmx_cust
    -- and delete these rows from pmx_cust_dim
    OPEN csr_dim_minus_pmx_cust;

    LOOP
        FETCH csr_dim_minus_pmx_cust INTO rv_dim_minus_pmx_cust;

        EXIT WHEN csr_dim_minus_pmx_cust%NOTFOUND;

        -- Now remove them
        DELETE FROM
          pmx_cust_dim
        WHERE
          company_code = rv_dim_minus_pmx_cust.company_code
          AND division_code = rv_dim_minus_pmx_cust.division_code
          AND cust_code = rv_dim_minus_pmx_cust.cust_code;

        v_upd_count := v_upd_count + 1;
    END LOOP;
    CLOSE csr_dim_minus_pmx_cust;

    v_log_level := v_log_level + 1;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');


    -- Add these changes to the pmx_cust_dim table
    MERGE INTO
      pmx_cust_dim t1
    USING (SELECT
             t01.company_code,
             t01.division_code,
             t01.cust_name as pmx_cust_name,
             t01.cust_code,
             t01.prom_flag as prmtbl_flag,
             t01.acct_mgr_key,
             t01.major_ref_code,
             t02.cust_name as major_ref_desc,
             t01.mid_ref_code,
             t03.cust_name as mid_ref_desc,
             t01.minor_ref_code,
             t04.cust_name as minor_ref_desc,
             t01.main_code,
             t05.cust_name as main_name,
             t01.cust_level,
             t01.parent_cust_code,
             t06.cust_name as parent_cust_desc,
             t01.parent_gl_cust_code,
             t07.cust_name as parent_gl_cust_desc,
             t01.gl_code,
             t01.distbn_chnl_code
           FROM
             pmx_cust t01,
             pmx_cust t02,
             pmx_cust t03,
             pmx_cust t04,
             pmx_cust t05,
             pmx_cust t06,
             pmx_cust t07
           WHERE t01.company_code = t02.company_code(+)
             AND t01.division_code = t02.division_code(+)
             AND t01.major_ref_code = t02.cust_code(+)
             AND t01.company_code = t03.company_code(+)
             AND t01.division_code = t03.division_code(+)
             AND t01.mid_ref_code = t03.cust_code(+)
             AND t01.company_code = t04.company_code(+)
             AND t01.division_code = t04.division_code(+)
             AND t01.minor_ref_code = t04.cust_code(+)
             AND t01.company_code = t05.company_code(+)
             AND t01.division_code = t05.division_code(+)
             AND t01.main_code = t05.cust_code(+)
             AND t01.company_code = t06.company_code(+)
             AND t01.division_code = t06.division_code(+)
             AND t01.parent_cust_code = t06.cust_code(+)
             AND t01.company_code = t07.company_code(+)
             AND t01.division_code = t07.division_code(+)
             AND t01.parent_gl_cust_code = t07.cust_code(+)
           MINUS
           SELECT
             company_code,
             division_code,
             pmx_cust_name,
             cust_code,
             prmtbl_flag,
             acct_mgr_key,
             major_ref_code,
             major_ref_desc,
             mid_ref_code,
             mid_ref_desc,
             minor_ref_code,
             minor_ref_desc,
             main_code,
             main_name,
             cust_level,
             parent_cust_code,
             parent_cust_desc,
             parent_gl_cust_code,
             parent_gl_cust_desc,
             gl_code,
             distbn_chnl_code
           FROM
             pmx_cust_dim) t2
          ON (t1.company_code = t2.company_code
              AND t1.division_code = t2.division_code
              AND t1.cust_code = t2.cust_code)
    WHEN MATCHED THEN
      UPDATE SET
        t1.pmx_cust_name = t2.pmx_cust_name,
        t1.prmtbl_flag = t2.prmtbl_flag,
        t1.acct_mgr_key = t2.acct_mgr_key,
        t1.major_ref_code = t2.major_ref_code,
        t1.major_ref_desc = t2.major_ref_desc,
        t1.mid_ref_code = t2.mid_ref_code,
        t1.mid_ref_desc = t2.mid_ref_desc,
        t1.minor_ref_code = t2.minor_ref_code,
        t1.minor_ref_desc = t2.minor_ref_desc,
        t1.main_code = t2.main_code,
        t1.main_name = t2.main_name,
        t1.cust_level = t2.cust_level,
        t1.parent_cust_code = t2.parent_cust_code,
        t1.parent_cust_desc = t2.parent_cust_desc,
        t1.parent_gl_cust_code = t2.parent_gl_cust_code,
        t1.parent_gl_cust_desc = t2.parent_gl_cust_desc,
        t1.gl_code = t2.gl_code,
        t1.distbn_chnl_code = t2.distbn_chnl_code
    WHEN NOT MATCHED THEN
      INSERT
        (t1.company_code,
         t1.division_code,
         t1.cust_code,
         t1.pmx_cust_name,
         t1.prmtbl_flag,
         t1.acct_mgr_key,
         t1.major_ref_code,
         t1.major_ref_desc,
         t1.mid_ref_code,
         t1.mid_ref_desc,
         t1.minor_ref_code,
         t1.minor_ref_desc,
         t1.main_code,
         t1.main_name,
         t1.cust_level,
         t1.parent_cust_code,
         t1.parent_cust_desc,
         t1.parent_gl_cust_code,
         t1.parent_gl_cust_desc,
         t1.gl_code,
         t1.distbn_chnl_code)
      VALUES
        (t2.company_code,
         t2.division_code,
         t2.cust_code,
         t2.pmx_cust_name,
         t2.prmtbl_flag,
         t2.acct_mgr_key,
         t2.major_ref_code,
         t2.major_ref_desc,
         t2.mid_ref_code,
         t2.mid_ref_desc,
         t2.minor_ref_code,
         t2.minor_ref_desc,
         t2.main_code,
         t2.main_name,
         t2.cust_level,
         t2.parent_cust_code,
         t2.parent_cust_desc,
         t2.parent_gl_cust_code,
         t2.parent_gl_cust_desc,
         t2.gl_code,
         t2.distbn_chnl_code);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level,'Finished Promotion Customer Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_cust%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_cust;
      END IF;
      write_log( v_data_type,
                 'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR PMX_CUST_FLATTENING.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      RETURN constants.error;

  END pmx_cust_flattening;

FUNCTION pmx_acct_mgr_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_acct_mgr IS
      SELECT
        company_code,
        division_code,
        acct_mgr_code,
        acct_mgr_key,
        acct_mgr_name,
        active_flag
      FROM
        acct_mgr_dim
      MINUS
      SELECT
        company_code,
        division_code,
        acct_mgr_code,
        acct_mgr_key,
        acct_mgr_name,
        active_flag
      FROM
        pmx_acct_mgr;

    rv_dim_minus_pmx_acct_mgr csr_dim_minus_pmx_acct_mgr%ROWTYPE;

  BEGIN
    v_data_type  := ods_constants.data_type_pmx_acct_mgr;
    v_sort_field := 'PMX ACCT MGR';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Account Manager Flattening.');

    write_log(v_data_type, v_sort_field,v_log_level + 1,'Removing Promotion Account Manager from Dim that are not in the Source Tables.');


    -- Find rows in pmx_acct_mgr_dim that are changed or removed from pmx_acct_mgr
    -- and delete these rows from acct_mgr_dim
    OPEN csr_dim_minus_pmx_acct_mgr;

    LOOP
        FETCH csr_dim_minus_pmx_acct_mgr INTO rv_dim_minus_pmx_acct_mgr;

        EXIT WHEN csr_dim_minus_pmx_acct_mgr%NOTFOUND;

        -- Now remove them
        DELETE FROM
          acct_mgr_dim
        WHERE
          acct_mgr_key = rv_dim_minus_pmx_acct_mgr.acct_mgr_key;

        v_upd_count := v_upd_count + 1;
    END LOOP;
    CLOSE csr_dim_minus_pmx_acct_mgr;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');

    -- Add these changes to the acct_mgr_dim table
    MERGE INTO
      acct_mgr_dim t1
    USING (SELECT
             company_code,
             division_code,
             acct_mgr_code,
             acct_mgr_key,
             acct_mgr_name,
             active_flag
           FROM
             pmx_acct_mgr
           MINUS
           SELECT
             company_code,
             division_code,
             acct_mgr_code,
             acct_mgr_key,
             acct_mgr_name,
             active_flag
           FROM
             acct_mgr_dim ) t2
      ON (t1.acct_mgr_key = t2.acct_mgr_key )
      WHEN MATCHED THEN
        UPDATE SET
          t1.acct_mgr_name = t2.acct_mgr_name,
          t1.active_flag = t2.active_flag,
          t1.company_code = t2.company_code,
          t1.division_code = t2.division_code,
          t1.acct_mgr_code = t2.acct_mgr_code
      WHEN NOT MATCHED THEN
        INSERT
          (t1.company_code,
           t1.division_code,
           t1.acct_mgr_code,
           t1.acct_mgr_name,
           t1.active_flag,
           t1.acct_mgr_key)
        VALUES
          (t2.company_code,
           t2.division_code,
           t2.acct_mgr_code,
           t2.acct_mgr_name,
           t2.active_flag,
           t2.acct_mgr_key);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level+1,'Finished Promotion Account Manager Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_acct_mgr%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_acct_mgr;
      END IF;
      write_log( v_data_type,
                 'ERROR',
                  0,
                  '!!!ERROR!!! - FATAL ERROR FOR PMX_ACCT_MGR_FLATTENING.' ||
                  ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));


      RETURN constants.error;

  END pmx_acct_mgr_flattening;

  FUNCTION pmx_claim_type_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_claim_type IS
      SELECT
        claim_type_code,
        claim_type_desc
      FROM
        claim_type_dim
      MINUS
      SELECT
        claim_type_code,
        claim_type_desc
      FROM
        pmx_claim_type;

    rv_dim_minus_pmx_claim_type csr_dim_minus_pmx_claim_type%ROWTYPE;

  BEGIN
    v_data_type  := ods_constants.data_type_pmx_claim_type;
    v_sort_field := 'PMX CLAIM TYPE';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Claim Type Flattening.');


    write_log(v_data_type, v_sort_field,v_log_level+1,'Removing Promotion Claim Type from Dim that are not in the Source Tables.');


    -- Find rows in pmx_claim_type_dim that are changed or removed from pmx_claim_type
    -- and delete these rows from claim_type_dim
    OPEN csr_dim_minus_pmx_claim_type;

    LOOP
        FETCH csr_dim_minus_pmx_claim_type INTO rv_dim_minus_pmx_claim_type;

        EXIT WHEN csr_dim_minus_pmx_claim_type%NOTFOUND;

        -- Now remove them
        DELETE FROM
          claim_type_dim
        WHERE
          claim_type_code = rv_dim_minus_pmx_claim_type.claim_type_code;

        v_upd_count := v_upd_count + 1;
    END LOOP;

    CLOSE csr_dim_minus_pmx_claim_type;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');

    -- Add these changes to the claim_type_dim table
    MERGE INTO
      claim_type_dim t1
    USING (SELECT
             claim_type_code,
             claim_type_desc
           FROM
             pmx_claim_type
           MINUS
           SELECT
             claim_type_code,
             claim_type_desc
           FROM
             claim_type_dim ) t2
      ON (t1.claim_type_code = t2.claim_type_code)
      WHEN MATCHED THEN
        UPDATE SET
          t1.claim_type_desc = t2.claim_type_desc
      WHEN NOT MATCHED THEN
        INSERT
          (t1.claim_type_code,
           t1.claim_type_desc)
        VALUES
          (t2.claim_type_code,
           t2.claim_type_desc);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level+1,'Finished Promotion Claim Type Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_claim_type%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_claim_type;
      END IF;

      write_log(v_data_type,
                'ERROR',
                0,
                '!!!ERROR!!! - FATAL ERROR FOR PMX_CLAIM_TYPE_FLATTENING.' ||
                ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      RETURN constants.error;

  END pmx_claim_type_flattening;

FUNCTION pmx_fund_type_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- Select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_fund_type IS
      SELECT
        company_code,
        division_code,
        prom_fund_type_code,
        prom_fund_type_key,
        prom_fund_type_desc,
        prom_fund_type_ext_desc,
        mars_fund_type_code,
        off_invoice_flag
      FROM
        prom_fund_type_dim
      MINUS
      SELECT
        company_code,
        division_code as division_code,
        prom_fund_type_code,
        prom_fund_type_key,
        prom_fund_type_desc,
        prom_fund_type_ext_desc,
        mars_fund_type_code,
        off_invoice_flag
      FROM
        pmx_fund_type;

    rv_dim_minus_pmx_fund_type csr_dim_minus_pmx_fund_type%ROWTYPE;

  BEGIN
    v_data_type  := ods_constants.data_type_pmx_fund_type;
    v_sort_field := 'PMX FUND TYPE';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Fund Type Flattening.');

    write_log(v_data_type, v_sort_field,v_log_level+1,'Removing Promotion fund type from Dim that are not in the Source Tables.');


    -- Find rows in prom_fund_type_dim that are changed or removed from pmx_fund_type
    -- and delete these rows from pmx_fund_type_dim
    OPEN csr_dim_minus_pmx_fund_type;

    LOOP
        FETCH csr_dim_minus_pmx_fund_type INTO rv_dim_minus_pmx_fund_type;

        EXIT WHEN csr_dim_minus_pmx_fund_type%NOTFOUND;

        -- Now remove them
        DELETE FROM
          prom_fund_type_dim
        WHERE
          company_code = rv_dim_minus_pmx_fund_type.company_code
          AND division_code = rv_dim_minus_pmx_fund_type.division_code
          AND prom_fund_type_key = rv_dim_minus_pmx_fund_type.prom_fund_type_key;

        v_upd_count := v_upd_count + 1;
    END LOOP;
    CLOSE csr_dim_minus_pmx_fund_type;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');

    -- Add these changes to the pmx_fund_type_dim table
    MERGE INTO
      prom_fund_type_dim t1
    USING (SELECT
             company_code,
             division_code as division_code,
             prom_fund_type_code,
             prom_fund_type_key,
             prom_fund_type_desc,
             prom_fund_type_ext_desc,
             mars_fund_type_code,
             off_invoice_flag
           FROM
             pmx_fund_type
           MINUS
           SELECT
             company_code,
             division_code,
             prom_fund_type_code,
             prom_fund_type_key,
             prom_fund_type_desc,
             prom_fund_type_ext_desc,
             mars_fund_type_code,
             off_invoice_flag
           FROM
             prom_fund_type_dim ) t2
      ON (t1.company_code = t2.company_code
          AND t1.division_code = t2.division_code
          AND t1.prom_fund_type_key = t2.prom_fund_type_key)
      WHEN MATCHED THEN
        UPDATE SET
          t1.prom_fund_type_desc = t2.prom_fund_type_desc,
          t1.prom_fund_type_ext_desc = t2.prom_fund_type_ext_desc,
          t1.mars_fund_type_code = t2.mars_fund_type_code,
          t1.off_invoice_flag = t2.off_invoice_flag
      WHEN NOT MATCHED THEN
        INSERT
          (t1.company_code,
           t1.division_code,
           t1.prom_fund_type_code,
           t1.prom_fund_type_key,
           t1.prom_fund_type_desc,
           t1.prom_fund_type_ext_desc,
           t1.mars_fund_type_code,
           t1.off_invoice_flag)
        VALUES
          (t2.company_code,
           t2.division_code,
           t2.prom_fund_type_code,
           t2.prom_fund_type_key,
           t2.prom_fund_type_desc,
           t2.prom_fund_type_ext_desc,
           t2.mars_fund_type_code,
           t2.off_invoice_flag);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level+1,'Finished Promotion Fund Type Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_fund_type%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_fund_type;
      END IF;
      write_log( v_data_type,
                 'ERROR',
                 0,
                 '!!!ERROR!!! - FATAL ERROR FOR PMX_FUND_TYPE_FLATTENING.' ||
                 ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      RETURN constants.error;

  END pmx_fund_type_flattening;

  FUNCTION pmx_prom_attrb_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- Select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_prom_attrb IS
      SELECT
        company_code,
        division_code,
        prom_attrb_key,
        prom_attrb_code,
        prom_attrb_desc
      FROM
        prom_attrb_dim
      MINUS
      SELECT
        company_code,
        division_code,
        prom_attrb_key,
        prom_attrb_code,
        prom_attrb_desc
      FROM
        pmx_prom_attrb;

    rv_dim_minus_pmx_prom_attrb csr_dim_minus_pmx_prom_attrb%ROWTYPE;

  BEGIN
    v_data_type  := ods_constants.data_type_pmx_attrb;
    v_sort_field := 'PMX ATTRB';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Attribute Flattening.');

    write_log(v_data_type, v_sort_field,v_log_level+1,'Removing Promotion Attribute from Dim that are not in the Source Tables.');

    -- Find rows in prom_attrb_dim that are changed or removed from pmx_prom_attrb
    -- and delete these rows from prom_attrb_dim
    OPEN csr_dim_minus_pmx_prom_attrb;

    LOOP
        FETCH csr_dim_minus_pmx_prom_attrb INTO rv_dim_minus_pmx_prom_attrb;

        EXIT WHEN csr_dim_minus_pmx_prom_attrb%NOTFOUND;

        -- Now remove them
        DELETE FROM
          prom_attrb_dim
        WHERE
          company_code = rv_dim_minus_pmx_prom_attrb.company_code
          AND division_code = rv_dim_minus_pmx_prom_attrb.division_code
          AND prom_attrb_key = rv_dim_minus_pmx_prom_attrb.prom_attrb_key;

        v_upd_count := v_upd_count + 1;
    END LOOP;

    CLOSE csr_dim_minus_pmx_prom_attrb;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');

    -- Add these changes to the pmx_prom_attrb_dim table
    MERGE INTO
      prom_attrb_dim t1
    USING (SELECT
             company_code,
             division_code as division_code,
             prom_attrb_key,
             prom_attrb_code,
             prom_attrb_desc
           FROM
             pmx_prom_attrb
           MINUS
           SELECT
             company_code,
             division_code,
             prom_attrb_key,
             prom_attrb_code,
             prom_attrb_desc
           FROM
             prom_attrb_dim ) t2
      ON (t1.company_code = t2.company_code
          AND t1.division_code = t2.division_code
          AND t1.prom_attrb_key = t2.prom_attrb_key)
      WHEN MATCHED THEN
        UPDATE SET
          t1.prom_attrb_desc = t2.prom_attrb_desc,
          t1.prom_attrb_code = t2.prom_attrb_code
      WHEN NOT MATCHED THEN
        INSERT
          (t1.company_code,
           t1.division_code,
           t1.prom_attrb_code,
           t1.prom_attrb_key,
           t1.prom_attrb_desc)
        VALUES
          (t2.company_code,
           t2.division_code,
           t2.prom_attrb_code,
           t2.prom_attrb_key,
           t2.prom_attrb_desc);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level+1,'Finished Promotion Attribute Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_prom_attrb%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_prom_attrb;
      END IF;
      write_log(v_data_type,
                'ERROR',
                0,
                '!!!ERROR!!! - FATAL ERROR FOR PMX_PROM_ATTRB_FLATTENING.' ||
                ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      RETURN constants.error;

  END pmx_prom_attrb_flattening;

  FUNCTION pmx_prom_status_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- Select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_prom_status IS
      SELECT
        prom_status_code,
        prom_status_desc
      FROM
        prom_status_dim
      WHERE
        prom_status_code <> 'X'  -- Ignore 'X' (Deleted) status as this is a CDW specific status.
      MINUS
      SELECT
        prom_status_code,
        prom_status_desc
      FROM
        pmx_prom_status;

    rv_dim_minus_pmx_prom_status csr_dim_minus_pmx_prom_status%ROWTYPE;

  BEGIN
    v_data_type  := ods_constants.data_type_pmx_status;
    v_sort_field := 'PMX STATUS';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Status Flattening.');

    write_log(v_data_type, v_sort_field,v_log_level+1,'Removing Promotion Status from Dim that are not in the Source Tables.');

    -- Find rows in pmx_prom_status_dim that are changed or removed from pmx_prom_status
    -- and delete these rows from prom_status_dim
    OPEN csr_dim_minus_pmx_prom_status;

    LOOP
        FETCH csr_dim_minus_pmx_prom_status INTO rv_dim_minus_pmx_prom_status;

        EXIT WHEN csr_dim_minus_pmx_prom_status%NOTFOUND;

        -- Now remove them
        DELETE FROM
          prom_status_dim
        WHERE
          prom_status_code = rv_dim_minus_pmx_prom_status.prom_status_code;

        v_upd_count := v_upd_count + 1;
    END LOOP;

    CLOSE csr_dim_minus_pmx_prom_status;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');

    -- Add these changes to the prom_status_dim table
    MERGE INTO
      prom_status_dim t1
    USING (SELECT
             prom_status_code,
             prom_status_desc
           FROM
             pmx_prom_status
           UNION
           SELECT
             'X',
             'Deleted'
           FROM
             dual
           MINUS
           SELECT
             prom_status_code,
             prom_status_desc
           FROM
             prom_status_dim ) t2
      ON (t1.prom_status_code = t2.prom_status_code)
      WHEN MATCHED THEN
        UPDATE SET
          t1.prom_status_desc = t2.prom_status_desc
      WHEN NOT MATCHED THEN
        INSERT
          (t1.prom_status_code,
           t1.prom_status_desc)
        VALUES
          (t2.prom_status_code,
           t2.prom_status_desc);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level+1,'Finished PPromotion Status Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_prom_status%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_prom_status;
      END IF;
      write_log(v_data_type,
                'ERROR',
                0,
                '!!!ERROR!!! - FATAL ERROR FOR PMX_PROM_STATUS_FLATTENING.' ||
                ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      RETURN constants.error;

  END pmx_prom_status_flattening;

  FUNCTION pmx_prom_type_flattening(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- VARIABLES
    -- Logging Variables
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Counters
    v_upd_count     PLS_INTEGER := 0;

    -- CURSORS
    -- select the changed or removed records from dim
    CURSOR csr_dim_minus_pmx_prom_type IS
      SELECT
        company_code,
        division_code,
        prom_type_key,
        prom_type_code,
        prom_type_desc
      FROM
        prom_type_dim
      MINUS
      SELECT
        company_code,
        division_code,
        prom_type_key,
        prom_type_code,
        prom_type_desc
      FROM
        pmx_prom_type;

    rv_dim_minus_pmx_prom_type csr_dim_minus_pmx_prom_type%ROWTYPE;

  BEGIN
    v_data_type  := ods_constants.data_type_pmx_type;
    v_sort_field := 'PMX TYPE';
    v_log_level  := i_log_level;

    write_log(v_data_type, v_sort_field,v_log_level,'Starting Promotion Type Flattening.');

    write_log(v_data_type, v_sort_field,v_log_level+1,'Removing Promotion Type from Dim that are not in the Source Tables.');

    -- Find rows in prom_type_dim that are changed or removed from pmx_prom_type
    -- and delete these rows from prom_type_dim
    OPEN csr_dim_minus_pmx_prom_type;

    LOOP
        FETCH csr_dim_minus_pmx_prom_type INTO rv_dim_minus_pmx_prom_type;

        EXIT WHEN csr_dim_minus_pmx_prom_type%NOTFOUND;

        -- Now remove them
        DELETE FROM
          prom_type_dim
        WHERE
          company_code = rv_dim_minus_pmx_prom_type.company_code
          AND division_code = rv_dim_minus_pmx_prom_type.division_code
          AND prom_type_key = rv_dim_minus_pmx_prom_type.prom_type_key;

        v_upd_count := v_upd_count + 1;
    END LOOP;

    CLOSE csr_dim_minus_pmx_prom_type;

    write_log(v_data_type, v_sort_field,v_log_level + 1, v_upd_count || ' records deleted from DIM table');

    -- Add these changes to the pmx_prom_type_dim table
    MERGE INTO
      prom_type_dim t1
    USING (SELECT
             company_code,
             division_code,
             prom_type_key,
             prom_type_code,
             prom_type_desc
           FROM
             pmx_prom_type
           MINUS
           SELECT
             company_code,
             division_code,
             prom_type_key,
             prom_type_code,
             prom_type_desc
           FROM
             prom_type_dim ) t2
      ON (t1.company_code = t2.company_code
          AND t1.division_code = t2.division_code
          AND t1.prom_type_key = t2.prom_type_key)
      WHEN MATCHED THEN
        UPDATE SET
          t1.prom_type_desc = t2.prom_type_desc,
          t1.prom_type_code = t2.prom_type_code
      WHEN NOT MATCHED THEN
        INSERT
          (t1.company_code,
           t1.division_code,
           t1.prom_type_code,
           t1.prom_type_key,
           t1.prom_type_desc)
        VALUES
          (t2.company_code,
           t2.division_code,
           t2.prom_type_code,
           t2.prom_type_key,
           t2.prom_type_desc);

    v_upd_count := SQL%ROWCOUNT;

    COMMIT;

    write_log(v_data_type, v_sort_field,v_log_level+1,'Finished PPromotion Type Flattening with merge count - ' || v_upd_count);

    -- Completed successfully.
    RETURN constants.success;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_dim_minus_pmx_prom_type%ISOPEN) THEN
        CLOSE csr_dim_minus_pmx_prom_type;
      END IF;
      write_log(v_data_type,
                'ERROR',
                 0,
                '!!!ERROR!!! - FATAL ERROR FOR PMX_PROM_TYPE_FLATTENING.' ||
                ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      RETURN constants.error;

  END pmx_prom_type_flattening;

/* ***********************************************************
 *       DAILY AGGREGATION FUNCTIONS
 * *********************************************************** */

FUNCTION prom_fact_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level    IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- VARIABLE DECLARATIONS
  v_valdtn_status pmx_prom_hdr.valdtn_status%TYPE := ods_constants.valdtn_valid;

  -- VARIABLE DECLARATIONS

  v_prev_period           mars_date_dim.mars_period%TYPE;
  v_rec_chg_period        mars_date_dim.mars_period%TYPE := 190001; -- default to low low period

  v_processing_msg        constants.message_string;
  v_log_level             ods.log.log_level%TYPE;
  v_status                NUMBER;

  v_prom_ins_count        NUMBER      := 0;
  v_prom_period_count     PLS_INTEGER := 0;

  v_calc_type             VARCHAR2(1) := c_rec_type_normal_tx;
  v_off_inv_flag          VARCHAR2(1) := 'F';
  v_pctg                  NUMBER(5,2) := 0;
  v_is_new_claim          VARCHAR2(1) := 'F';
  v_is_new_closed         VARCHAR2(1) := 'F';
  v_spend_on_this_period  VARCHAR2(1) := 'F';

  v_prom_cost             prom_fact.prom_cost%TYPE := 0;
  v_origl_prom_cost       prom_fact.origl_prom_cost%TYPE := 0;
  v_current_period_claims prom_fact.claim%TYPE := 0;
  v_sum_pctg              NUMBER(5,2) := 0;

  v_eff_end_yyyypp        prom_fact.eff_end_yyyypp%TYPE;
  v_prom_yyyypp           prom_fact.prom_yyyypp%TYPE;
  v_next_period           mars_date_dim.mars_period%TYPE;
  v_isOverSpendProm       VARCHAR2(1);

  -- Local SQL table declaration
  tab_phased_percent     tab_typ_phased_percent;
  tab_phased_yyyypp      tab_typ_phased_yyyypp;
  tab_new_claim          tab_type_amt;
  tab_remain_claim       tab_type_amt;
  tab_prev_overspend     tab_type_amt;

   type rcd_claim is record(claim_yyyypp number(6,0),
                            claim_iss_deferred number,
                            claim_case number,
                            claim_scan number,
                            claim_fixed number,
                            claim_on_invoice number,
                            claim number);
   type typ_claim is table of rcd_claim index by binary_integer;
   tab_claim typ_claim;

   type rcd_fact is record(fact_yyyypp number(6,0),
                           str_yyyypp number(6,0),
                           end_yyyypp number(6,0),
                           phased_percent number(18,2),
                           phased_plnd_cost_iss_deferred number,
                           phased_plnd_cost_case number,
                           phased_plnd_cost_scan number,
                           phased_plnd_cost_fixed number,
                           phased_plnd_cost_on_invoice number,
                           phased_plnd_cost number,
                           phased_accrl_cost_iss_deferred number,
                           phased_accrl_cost_case number,
                           phased_accrl_cost_scan number,
                           phased_accrl_cost_fixed number,
                           phased_accrl_cost_on_invoice number,
                           phased_accrl_cost number,
                           claim_iss_deferred number,
                           claim_case number,
                           claim_scan number,
                           claim_fixed number,
                           claim_on_invoice number,
                           claim number);
   type typ_fact is table of rcd_fact index by binary_integer;
   tab_fact typ_fact;

   var_buy_accr_cost number;
   var_cur_accr_cost number;
   var_cur_claim number;
   var_tot_prom_cost number;
   var_tot_prom_claim number;
   var_first boolean;

   var_found boolean;
   var_index integer;
   v_ptd_pctg number(5,2);
   v_ptd_yyyypp number(6,0);

   /*-*/
   /* Local definitions
   /*-*/
   rcd_prom_fact prom_fact%rowtype;

  -- CURSOR DECLARATIONS
  -- Check whether any promotion records were received or updated on and after yesterday.
  CURSOR csr_prom_count IS
    SELECT
      count(*) AS prom_count
    FROM
      pmx_prom_hdr
    WHERE
      company_code = i_company_code
      AND prom_hdr_lupdt > v_cntl_str_date
      AND prom_hdr_lupdt <= v_cntl_end_date
      AND valdtn_status = v_valdtn_status;
    rv_prom_count csr_prom_count%ROWTYPE;

  -- Outer loop cursor promotions header.
  CURSOR csr_prom_hdr IS
    SELECT
      t1.company_code,
      t1.division_code,
      t1.prom_num,
      t1.cust_code,
      DECODE (t1.company_code,'147','AUD','NZD') as currcy_code,
      t1.prom_type_key,
      t1.prom_type_class,
      t1.prom_stat_code,
      t1.prom_attrb,
      t1.case1_fund_code,
      t1.case2_fund_code,
      t1.coop1_fund_code,
      t1.coop2_fund_code,
      t1.coop3_fund_code,
      t1.coup1_fund_code,
      t1.coup2_fund_code,
      t1.scan1_fund_code,
      t1.whse1_fund_code,
      t1.case1_pay_mthd,
      t1.case2_pay_mthd,
      t1.sell_start,
      t1.sell_end,
      t1.buy_start,
      t1.buy_end,
      t1.split,
      t1.split_end,
      t1.prom_chng_date,
      t1.prom_hdr_load_date,
      t2.mars_period as buy_start_yyyypp,
      t2.mars_year as buy_start_yyyy,
      t2.mars_week_of_period as buy_start_week_of_period,
      t3.mars_period as sell_start_yyyypp,
      t4.mars_period as eff_start_yyyypp,
      t4.mars_year as eff_start_yyyy,
      t1.cust_prom_type,
      t1.prom_comnt
    FROM
      pmx_prom_hdr t1,
      mars_date_dim t2,
      mars_date_dim t3,
      mars_date_dim t4,
      (select company_code,
              division_code,
              prom_num,
              min(prom_chng_date) as prom_chng_date
         from pmx_prom_hdr
        where company_code = i_company_code
          and prom_hdr_lupdt > v_cntl_str_date
          and prom_hdr_lupdt <= v_cntl_end_date
          and valdtn_status = v_valdtn_status
        group by company_code,
                 division_code,
                 prom_num) t5
   WHERE t1.company_code = i_company_code
      AND t1.buy_start = t2.calendar_date(+)
      AND t1.sell_start = t3.calendar_date(+)
      AND t1.prom_chng_date = t4.calendar_date(+)
      AND t1.company_code = t5.company_code
      AND t1.division_code = t5.division_code
      AND t1.prom_num = t5.prom_num
      AND t1.prom_chng_date >= t5.prom_chng_date
    ORDER BY company_code, division_code, prom_num, prom_chng_date;
    rv_prom_hdr csr_prom_hdr%ROWTYPE;

  -- Inner promotion detail cursor.
  CURSOR csr_prom_dtl IS
    SELECT
      company_code,
      division_code,
      prom_num,
      matl_zrep_code,
      prom_chng_date,
      retail_sell_price_plnd,
      round((whse_wthdrwl_case1_plnd * whse_wthdrwl_qty_plnd),2) as plnd_cost_iss_deferred,
      round(DECODE(v_off_inv_flag,'F',(xfact_case1_plnd + xfact_case2_plnd) * xfact_qty_plnd,0),2) as plnd_cost_case,
      round((scan_case1_plnd * scan_qty_plnd),2) as plnd_cost_scan,
      round((coop1_plnd + coop2_plnd + coop3_plnd),2) as plnd_cost_fixed,
      round(DECODE(v_off_inv_flag,'T',(xfact_case1_plnd + xfact_case2_plnd) * xfact_qty_plnd,0),2) as plnd_cost_on_invoice,
      round((whse_wthdrwl_case1_plnd * whse_wthdrwl_qty_plnd) +
       (xfact_case1_plnd + xfact_case2_plnd) * xfact_qty_plnd +
       (scan_case1_plnd * scan_qty_plnd) +
       (coop1_plnd + coop2_plnd + coop3_plnd),2) as plnd_cost,
      round((whse_wthdrwl_case1_actl * whse_wthdrwl_qty_actl),2) as claim_iss_deferred,
      round((xfact_case1_actl+xfact_case2_actl)*(xfact_qty1_actl+xfact_qty2_actl),2) as claim_case,
      round((scan_case1_actl * scan_qty_actl),2) as claim_scan,
      round((coop1_actl + coop2_actl + coop3_actl),2) as claim_fixed,
      0.0 as claim_on_invoice,
      round((whse_wthdrwl_case1_actl * whse_wthdrwl_qty_actl) +
       (xfact_case1_actl+xfact_case2_actl)*(xfact_qty1_actl+xfact_qty2_actl) +
       (scan_case1_actl * scan_qty_actl) +
       (coop1_actl + coop2_actl + coop3_actl),2) as claim,
      round((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl),2) as accrl_cost_iss_deferred,
      round(DECODE(v_off_inv_flag,'F',(case1_accrl + case2_accrl) * est_qty_accrl,0),2) as accrl_cost_case,
      round((scan_qty_accrl * scan_deal_accrl),2) as accrl_cost_scan,
      round((coop1_accrl + coop2_accrl + coop3_accrl),2) as accrl_cost_fixed,
      round(DECODE(v_off_inv_flag,'T',(case1_accrl + case2_accrl) * est_qty_accrl,0),2) as accrl_cost_on_invoice,
      round((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl) +
       (case1_accrl + case2_accrl) * est_qty_accrl +
       (scan_qty_accrl * scan_deal_accrl) +
       (coop1_accrl + coop2_accrl + coop3_accrl),2) as accrl_cost,
      -- Initial the phasing amount fields to avoid too many variables declaration
      0.00 as accrl_chng_iss_deferred,
      0.00 as accrl_chng_case,
      0.00 as accrl_chng_scan,
      0.00 as accrl_chng_fixed,
      0.00 as accrl_chng_on_invoice,
      0.00 as accrl_chng,
      0.00 as varc_chng_iss_deferred,
      0.00 as varc_chng_case,
      0.00 as varc_chng_scan,
      0.00 as varc_chng_fixed,
      0.00 as varc_chng_on_invoice,
      0.00 as varc_chng
    FROM
      pmx_prom_dtl
    WHERE
      company_code = rv_prom_hdr.company_code
      AND division_code = rv_prom_hdr.division_code
      AND prom_num = rv_prom_hdr.prom_num
      AND prom_chng_date = rv_prom_hdr.prom_chng_date
    ORDER BY matl_zrep_code;

  -- For material level
  rv_prom_dtl        csr_prom_dtl%ROWTYPE;
  -- For material phasing level
  rv_phased_prom_dtl csr_prom_dtl%ROWTYPE;

  -- Promotion claim cursors.

  CURSOR csr_current_claim IS
     select * from (
     select round(nvl(sum(decode(t01.claim_type_code,'W',t02.claim_dtl_amt,0)),0),2) as claim_iss_deferred,
            round(nvl(sum(decode(t01.claim_type_code,'A',t02.claim_dtl_amt,0)),0),2) as claim_case,
            round(nvl(sum(decode(t01.claim_type_code,'S',t02.claim_dtl_amt,0)),0),2) as claim_scan,
            round(nvl(sum(decode(t01.claim_type_code,'O',t02.claim_dtl_amt,0)),0),2) as claim_fixed,
            round(nvl(sum(t02.claim_dtl_amt),0),2) as claim,
            t03.mars_period
       from pmx_claim_hdr t01,
            pmx_claim_dtl t02,
            mars_date t03
      where t01.company_code = t02.company_code
        and t01.division_code = t02.division_code
        and t01.claim_key = t02.claim_key
        and trunc(t01.process_date) = t03.calendar_date(+)
        and t01.company_code = rv_prom_hdr.company_code
        and t01.division_code = rv_prom_hdr.division_code
        and t01.claim_hdr_prom_num = rv_prom_hdr.prom_num
        and trunc(t01.process_date) <= trunc(rv_prom_hdr.prom_chng_date)
        and t02.matl_zrep_code = rv_prom_dtl.matl_zrep_code
      group by t03.mars_period)
      where claim != 0
      order by mars_period;
  rv_current_claim csr_current_claim%ROWTYPE;

  CURSOR csr_detail_claim IS
    select * from (
    SELECT
      round(nvl((t1.whse_wthdrwl_case1_actl * t1.whse_wthdrwl_qty_actl),0),2) as claim_iss_deferred,
      round(nvl((t1.xfact_case1_actl+t1.xfact_case2_actl)*(t1.xfact_qty1_actl+t1.xfact_qty2_actl),0),2) as claim_case,
      round(nvl((t1.scan_case1_actl * t1.scan_qty_actl),0),2) as claim_scan,
      round(nvl((t1.coop1_actl + t1.coop2_actl + t1.coop3_actl),0),2) as claim_fixed,
      round(nvl((t1.whse_wthdrwl_case1_actl * t1.whse_wthdrwl_qty_actl) +
       (t1.xfact_case1_actl+t1.xfact_case2_actl)*(t1.xfact_qty1_actl+t1.xfact_qty2_actl) +
       (t1.scan_case1_actl * t1.scan_qty_actl) +
       (t1.coop1_actl + t1.coop2_actl + t1.coop3_actl),0),2) as claim,
      t02.mars_period
    FROM
      pmx_prom_dtl t1,
      mars_date t02
    WHERE trunc(t1.prom_chng_date) = t02.calendar_date(+)
      AND t1.company_code = rv_prom_hdr.company_code
      AND t1.division_code = rv_prom_hdr.division_code
      AND t1.prom_num = rv_prom_hdr.prom_num
      AND t1.prom_chng_date in (select max(prom_chng_date)
                                 from pmx_prom_hdr, mars_date
                                where trunc(prom_chng_date) = calendar_date(+)
                                  and company_code = rv_prom_hdr.company_code
                                  and division_code = rv_prom_hdr.division_code
                                  and prom_num = rv_prom_hdr.prom_num
                                  and prom_chng_date <= rv_prom_hdr.prom_chng_date
                                group by mars_period)
      AND t1.matl_zrep_code = rv_prom_dtl.matl_zrep_code)
      where claim != 0
      order by mars_period asc;
  rv_detail_claim csr_detail_claim%ROWTYPE;

  CURSOR csr_prom_year_accrual IS
      select round((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl),2) as accrl_cost_iss_deferred,
             round(DECODE(v_off_inv_flag,'F',(case1_accrl + case2_accrl) * est_qty_accrl,0),2) as accrl_cost_case,
             round((scan_qty_accrl * scan_deal_accrl),2) as accrl_cost_scan,
             round((coop1_accrl + coop2_accrl + coop3_accrl),2) as accrl_cost_fixed,
             round(DECODE(v_off_inv_flag,'T',(case1_accrl + case2_accrl) * est_qty_accrl,0),2) as accrl_cost_on_invoice,
             round((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl) +
                   (case1_accrl + case2_accrl) * est_qty_accrl +
                   (scan_qty_accrl * scan_deal_accrl) +
                   (coop1_accrl + coop2_accrl + coop3_accrl),2) as accrl_cost
        from pmx_prom_dtl
       where company_code = rv_prom_hdr.company_code
         and division_code = rv_prom_hdr.division_code
         and prom_num = rv_prom_hdr.prom_num
         and prom_chng_date = (select max(prom_chng_date)
                                 from pmx_prom_hdr, mars_date
                                where trunc(prom_chng_date) = calendar_date(+)
                                  and company_code = rv_prom_hdr.company_code
                                  and division_code = rv_prom_hdr.division_code
                                  and prom_num = rv_prom_hdr.prom_num
                                  and prom_chng_date <= rv_prom_hdr.prom_chng_date
                                  and mars_year <= rv_prom_hdr.buy_start_yyyy)
         and matl_zrep_code = rv_prom_dtl.matl_zrep_code;
  rv_prom_year_accrual csr_prom_year_accrual%ROWTYPE;

  CURSOR csr_prom_next_accrual IS
    select * from (
      select round((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl),2) as accrl_cost_iss_deferred,
             round(DECODE(v_off_inv_flag,'F',(case1_accrl + case2_accrl) * est_qty_accrl,0),2) as accrl_cost_case,
             round((scan_qty_accrl * scan_deal_accrl),2) as accrl_cost_scan,
             round((coop1_accrl + coop2_accrl + coop3_accrl),2) as accrl_cost_fixed,
             round(DECODE(v_off_inv_flag,'T',(case1_accrl + case2_accrl) * est_qty_accrl,0),2) as accrl_cost_on_invoice,
             round((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl) +
                   (case1_accrl + case2_accrl) * est_qty_accrl +
                   (scan_qty_accrl * scan_deal_accrl) +
                   (coop1_accrl + coop2_accrl + coop3_accrl),2) as accrl_cost,
             t02.mars_period
    FROM
      pmx_prom_dtl t1,
      mars_date t02
    WHERE trunc(t1.prom_chng_date) = t02.calendar_date(+)
      AND t1.company_code = rv_prom_hdr.company_code
      AND t1.division_code = rv_prom_hdr.division_code
      AND t1.prom_num = rv_prom_hdr.prom_num
      AND t1.prom_chng_date in (select max(prom_chng_date)
                                 from pmx_prom_hdr, mars_date
                                where trunc(prom_chng_date) = calendar_date(+)
                                  and company_code = rv_prom_hdr.company_code
                                  and division_code = rv_prom_hdr.division_code
                                  and prom_num = rv_prom_hdr.prom_num
                                  and prom_chng_date <= rv_prom_hdr.prom_chng_date
                                  and mars_year > rv_prom_hdr.buy_start_yyyy
                                group by mars_period)
      AND t1.matl_zrep_code = rv_prom_dtl.matl_zrep_code)
      where accrl_cost != 0
      order by mars_period asc;
  rv_prom_next_accrual csr_prom_next_accrual%ROWTYPE;


BEGIN
  -- Starting prom_fact aggregation.
  write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 1, 'Starting prom_fact aggregation.');

  -- Perform the period end execution
  write_log( ods_constants.data_type_prom, 'N/A', i_log_level + 2, 'Checking for and creating any period end Promotion timestamps for Company Code [' || i_company_code || '].');
  execute_period_end(i_company_code);

  -- Fetch the record from the csr_prom_count cursor.
  OPEN  csr_prom_count;
  FETCH csr_prom_count INTO rv_prom_count;
  CLOSE csr_prom_count;

  -- If any Promotion record continue the aggregation process.
  write_log( ods_constants.data_type_prom, 'N/A', i_log_level + 2, 'Checking for any Promotion records loaded for Company Code [' || i_company_code || '] between [' || TO_CHAR(v_cntl_str_date,'DD-MON-YYYY HH24:MI:SS') || ' - ' ||TO_CHAR(v_cntl_end_date,'DD-MON-YYYY HH24:MI:SS') ||'].');

  IF rv_prom_count.prom_count < 1 THEN
      write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 2, 'No new or updated Promotion data found for Company Code [' || i_company_code || '] between [' || TO_CHAR(v_cntl_str_date,'DD-MON-YYYY HH24:MI:SS') || ' - ' ||TO_CHAR(v_cntl_end_date,'DD-MON-YYYY HH24:MI:SS') ||'].');
  ELSE

    write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 2, 'Aggregating Company Code [' || i_company_code || '] between [' || TO_CHAR(v_cntl_str_date,'DD-MON-YYYY HH24:MI:SS') || ' - ' ||TO_CHAR(v_cntl_end_date,'DD-MON-YYYY HH24:MI:SS') ||'].');

    -- Open the Promotion cursor, used as the outer loop.
    OPEN  csr_prom_hdr;

    -- Read through the promotion header cursor.
    write_log(ods_constants.data_type_prom,'N/A', i_log_level + 2,'Looping through the csr_prom_hdr cursor.');
    LOOP
      FETCH csr_prom_hdr INTO rv_prom_hdr;
      EXIT WHEN csr_prom_hdr%NOTFOUND;

      -- In case aggregating more than one load date, so recalculate the loading period for correctly
      -- record the effective date frame
      IF v_rec_chg_period <> rv_prom_hdr.eff_start_yyyypp THEN
        v_rec_chg_period := rv_prom_hdr.eff_start_yyyypp;
        v_prev_period := get_mars_period(rv_prom_hdr.prom_chng_date, -28, ods_constants.job_type_pmx_aggregation, i_log_level + 1);
        v_next_period := get_mars_period(rv_prom_hdr.prom_chng_date, 28, ods_constants.job_type_pmx_aggregation, i_log_level + 1);
      END IF;

      -- ----------------------------------------------------------
      --      Close previous period loaded active record         --
      --      Delete this period loaded active record            --
      -- ----------------------------------------------------------
      -- Close the active records that have a eff_start_yyyypp less than loading period for this promotion
      UPDATE
        prom_fact
      SET
        eff_end_yyyypp = v_prev_period
      WHERE
        company_code = rv_prom_hdr.company_code
        AND division_code = rv_prom_hdr.division_code
        AND prom_num =  rv_prom_hdr.prom_num
        AND eff_start_yyyypp < v_rec_chg_period
        AND eff_end_yyyypp = c_future_eff_end_period;

      -- Delete records that have a eff_start_yyyypp equal or greater than record change period for this promotion
      DELETE
        prom_fact
      WHERE
        company_code = rv_prom_hdr.company_code
        AND division_code = rv_prom_hdr.division_code
        AND prom_num =  rv_prom_hdr.prom_num
        AND eff_start_yyyypp >= v_rec_chg_period;

      -- ----------------------------------------------------------
      --      INITIALISE AND GET PROMOTION LEVEL VALUES         --
      -- ----------------------------------------------------------
      v_prom_ins_count := 0;
      v_isOverSpendProm := 'F';

      -- Get promotion level promotion original cost.
      v_origl_prom_cost := get_origl_prom_cost(i_log_level + 2, rv_prom_hdr.company_code, rv_prom_hdr.division_code, rv_prom_hdr.prom_num, rv_prom_hdr.prom_chng_date);

      -- Determine if Promotion is an On-Invoice or not.
      v_off_inv_flag := get_off_invoice_flag (rv_prom_hdr.company_code, rv_prom_hdr.division_code, rv_prom_hdr.case1_fund_code, rv_prom_hdr.case2_fund_code, ods_constants.job_type_pmx_aggregation, v_log_level + 1);

      -- Get the phasing periods for a promotion into a sql table (tab_phased_yyyypp).
      v_status := get_prom_phased_periods (i_log_level, rv_prom_hdr.buy_start, rv_prom_hdr.buy_end, tab_phased_yyyypp);
      IF v_status = constants.error THEN
        RETURN constants.error;
      END IF;

      v_prom_period_count := tab_phased_yyyypp.COUNT;

      -- Get the phasing percents for a promotion into a sql table
      v_status := get_prom_phased_percents (i_log_level + 1,
                                            rv_prom_hdr.company_code,
                                            rv_prom_hdr.division_code,
                                            rv_prom_hdr.prom_num,
                                            rv_prom_hdr.prom_chng_date,
                                            rv_prom_hdr.prom_type_class,
                                            rv_prom_hdr.split,
                                            rv_prom_hdr.split_end,
                                            rv_prom_hdr.buy_start_week_of_period,
                                            v_prom_period_count,
                                            tab_phased_percent,   -- in and out sql table
                                            rv_prom_hdr.buy_start,
                                            rv_prom_hdr.buy_end);
      IF v_status = constants.error THEN
         RETURN constants.error;
      END IF;

      /*-*/
      /* Check the promotion for phased overspend
      /* Retrieve the highest phased period that is less than or equal to the current change period
      /* Sum the phased percent to this phased period
      /*-*/
      v_isOverSpendProm := 'F';
      v_ptd_pctg := 0;
      v_ptd_yyyypp := 0;
      for idx IN 1..tab_phased_yyyypp.count loop
         if tab_phased_yyyypp(idx) <= v_rec_chg_period then
            v_ptd_pctg := v_ptd_pctg + round(tab_phased_percent(idx)/100,2);
            v_ptd_yyyypp := tab_phased_yyyypp(idx);
         end if;
      end loop;
      if v_ptd_yyyypp != 0 then
         if v_off_inv_flag = 'F' then
            v_status := check_phased_overspend(i_log_level + 2, rv_prom_hdr.company_code, rv_prom_hdr.division_code, rv_prom_hdr.prom_num, rv_prom_hdr.prom_chng_date, v_ptd_pctg, v_ptd_yyyypp, v_isOverSpendProm);
         else
            v_status := check_phased_oi_overspend(i_log_level + 2, rv_prom_hdr.company_code, rv_prom_hdr.division_code, rv_prom_hdr.prom_num, rv_prom_hdr.prom_chng_date, v_ptd_pctg, v_ptd_yyyypp, v_isOverSpendProm);
         end if;
         if v_status = constants.error then
            return constants.error;
         end if;
      end if;

      ------------------------------------------------------------
      --       CALCULATE DETAIL LINE LEVEL VALUES               --
      ------------------------------------------------------------
      -- Open the the Promotion detail cursor.
      OPEN csr_prom_dtl;

      -- Read through the prom_dtl cursor, calcuate material level values
      LOOP
        FETCH csr_prom_dtl INTO rv_prom_dtl;
        EXIT WHEN csr_prom_dtl%NOTFOUND;


        /*-------------------------------------------------*/
        /* Perform the promotion detail level calculations */
        /*-------------------------------------------------*/


        BEGIN
          -- Reset material level variables
          v_prom_cost     := 0;
          v_is_new_claim  := 'F';
          v_is_new_closed := 'F';
          v_calc_type     := c_rec_type_normal_tx;

          -- Calculate accrual Change values
          -- rule: IF status is not planned, confirmed or deleted, then calculate the different between accrual and planned values, otherwise set to zero
          -- accrl_cost fields are zero when status = P, T or X we assign the planned amount to it so
          -- we can easy calculate the report item
          IF rv_prom_hdr.prom_stat_code in ('P','T','X') THEN   -- Planned, Confirmed, Deleted
             rv_prom_dtl.accrl_cost_iss_deferred := rv_prom_dtl.plnd_cost_iss_deferred ;
             rv_prom_dtl.accrl_cost_case         := rv_prom_dtl.plnd_cost_case ;
             rv_prom_dtl.accrl_cost_scan         := rv_prom_dtl.plnd_cost_scan ;
             rv_prom_dtl.accrl_cost_fixed        := rv_prom_dtl.plnd_cost_fixed;
             rv_prom_dtl.accrl_cost_on_invoice   := rv_prom_dtl.plnd_cost_on_invoice;
             rv_prom_dtl.accrl_cost              := rv_prom_dtl.plnd_cost;
          END IF;

          /*-*/
          /* Rerieve the claim values
          /*-*/
          tab_claim.delete;
          IF v_off_inv_flag = 'F' THEN
             OPEN csr_current_claim;
             LOOP
                FETCH csr_current_claim INTO rv_current_claim;
                IF csr_current_claim%NOTFOUND THEN
                   exit;
                END IF;
                tab_claim(tab_claim.count+1).claim_yyyypp := rv_current_claim.mars_period;
                tab_claim(tab_claim.count).claim_iss_deferred := rv_current_claim.claim_iss_deferred;
                tab_claim(tab_claim.count).claim_case := rv_current_claim.claim_case;
                tab_claim(tab_claim.count).claim_scan := rv_current_claim.claim_scan;
                tab_claim(tab_claim.count).claim_fixed := rv_current_claim.claim_fixed;
                tab_claim(tab_claim.count).claim_on_invoice := 0;
                tab_claim(tab_claim.count).claim := rv_current_claim.claim;
             END LOOP;
             CLOSE csr_current_claim;
          ELSE
             OPEN csr_detail_claim;
             LOOP
                FETCH csr_detail_claim INTO rv_detail_claim;
                IF csr_detail_claim%NOTFOUND THEN
                   exit;
                END IF;
                tab_claim(tab_claim.count+1).claim_yyyypp := rv_detail_claim.mars_period;
                tab_claim(tab_claim.count).claim_iss_deferred := rv_detail_claim.claim_iss_deferred;
                tab_claim(tab_claim.count).claim_case := rv_detail_claim.claim_case;
                tab_claim(tab_claim.count).claim_scan := rv_detail_claim.claim_scan;
                tab_claim(tab_claim.count).claim_fixed := rv_detail_claim.claim_fixed;
                tab_claim(tab_claim.count).claim_on_invoice := 0;
                tab_claim(tab_claim.count).claim := rv_detail_claim.claim;
             END LOOP;
             CLOSE csr_detail_claim;
             for idx in reverse 1..tab_claim.count loop
                if idx > 1 then
                   tab_claim(idx).claim_iss_deferred := tab_claim(idx).claim_iss_deferred - tab_claim(idx-1).claim_iss_deferred;
                   tab_claim(idx).claim_case := tab_claim(idx).claim_case - tab_claim(idx-1).claim_case;
                   tab_claim(idx).claim_scan := tab_claim(idx).claim_scan - tab_claim(idx-1).claim_scan;
                   tab_claim(idx).claim_fixed := tab_claim(idx).claim_fixed - tab_claim(idx-1).claim_fixed;
                   tab_claim(idx).claim := tab_claim(idx).claim - tab_claim(idx-1).claim;
                end if;
             end loop;
          END IF;
          IF v_off_inv_flag = 'T' AND (rv_prom_hdr.case1_pay_mthd = 'Y' OR rv_prom_hdr.case2_pay_mthd = 'Y') THEN
             for idx in 1..tab_claim.count loop
                tab_claim(idx).claim_on_invoice := tab_claim(idx).claim_case;
                tab_claim(idx).claim_case := 0;
             end loop;
          END IF;

          /*-*/
          /* Clear the fact table array
          /*-*/
          tab_fact.delete;

          /*-*/
          /* Assign the the planned values
          /*-*/
          FOR idx IN 1..tab_phased_yyyypp.count LOOP
            v_pctg := round(tab_phased_percent(idx)/100,2);
            tab_fact(idx).fact_yyyypp := tab_phased_yyyypp(idx);
            tab_fact(idx).str_yyyypp := v_rec_chg_period;
            tab_fact(idx).end_yyyypp := c_future_eff_end_period;
            tab_fact(idx).phased_percent := tab_phased_percent(idx);
            tab_fact(idx).phased_plnd_cost_iss_deferred := round(rv_prom_dtl.plnd_cost_iss_deferred * v_pctg, 2);
            tab_fact(idx).phased_plnd_cost_case := round(rv_prom_dtl.plnd_cost_case * v_pctg, 2);
            tab_fact(idx).phased_plnd_cost_scan := round(rv_prom_dtl.plnd_cost_scan * v_pctg, 2);
            tab_fact(idx).phased_plnd_cost_fixed := round(rv_prom_dtl.plnd_cost_fixed * v_pctg, 2);
            tab_fact(idx).phased_plnd_cost_on_invoice := round(rv_prom_dtl.plnd_cost_on_invoice * v_pctg, 2);
            tab_fact(idx).phased_plnd_cost := round(rv_prom_dtl.plnd_cost * v_pctg, 2);
            tab_fact(idx).phased_accrl_cost_iss_deferred := 0;
            tab_fact(idx).phased_accrl_cost_case := 0;
            tab_fact(idx).phased_accrl_cost_scan := 0;
            tab_fact(idx).phased_accrl_cost_fixed := 0;
            tab_fact(idx).phased_accrl_cost_on_invoice := 0;
            tab_fact(idx).phased_accrl_cost := 0;
            tab_fact(idx).claim_iss_deferred := 0;
            tab_fact(idx).claim_case := 0;
            tab_fact(idx).claim_scan := 0;
            tab_fact(idx).claim_fixed := 0;
            tab_fact(idx).claim_on_invoice := 0;
            tab_fact(idx).claim := 0;
          END LOOP;

          /*-*/
          /* Assign the the accrual values
          /*-*/
          if rv_prom_hdr.eff_start_yyyy <= rv_prom_hdr.buy_start_yyyy then

             FOR idx IN 1..tab_phased_yyyypp.count LOOP
                v_pctg := round(tab_fact(idx).phased_percent/100,2);
                tab_fact(idx).phased_accrl_cost_iss_deferred := round(rv_prom_dtl.accrl_cost_iss_deferred * v_pctg, 2);
                tab_fact(idx).phased_accrl_cost_case := round(rv_prom_dtl.accrl_cost_case * v_pctg, 2);
                tab_fact(idx).phased_accrl_cost_scan := round(rv_prom_dtl.accrl_cost_scan * v_pctg, 2);
                tab_fact(idx).phased_accrl_cost_fixed := round(rv_prom_dtl.accrl_cost_fixed * v_pctg, 2);
                tab_fact(idx).phased_accrl_cost_on_invoice := round(rv_prom_dtl.accrl_cost_on_invoice * v_pctg, 2);
                tab_fact(idx).phased_accrl_cost := round(rv_prom_dtl.accrl_cost * v_pctg, 2);
             END LOOP;

          ELSE

             OPEN csr_prom_year_accrual;
             FETCH csr_prom_year_accrual INTO rv_prom_year_accrual;
             IF csr_prom_year_accrual%FOUND THEN
                FOR idx IN 1..tab_phased_yyyypp.count LOOP
                   v_pctg := round(tab_fact(idx).phased_percent/100,2);
                   tab_fact(idx).phased_accrl_cost_iss_deferred := round(rv_prom_year_accrual.accrl_cost_iss_deferred * v_pctg, 2);
                   tab_fact(idx).phased_accrl_cost_case := round(rv_prom_year_accrual.accrl_cost_case * v_pctg, 2);
                   tab_fact(idx).phased_accrl_cost_scan := round(rv_prom_year_accrual.accrl_cost_scan * v_pctg, 2);
                   tab_fact(idx).phased_accrl_cost_fixed := round(rv_prom_year_accrual.accrl_cost_fixed * v_pctg, 2);
                   tab_fact(idx).phased_accrl_cost_on_invoice := round(rv_prom_year_accrual.accrl_cost_on_invoice * v_pctg, 2);
                   tab_fact(idx).phased_accrl_cost := round(rv_prom_year_accrual.accrl_cost * v_pctg, 2);
                END LOOP;
             ELSE
                rv_prom_year_accrual.accrl_cost_iss_deferred := 0;
                rv_prom_year_accrual.accrl_cost_case := 0;
                rv_prom_year_accrual.accrl_cost_scan := 0;
                rv_prom_year_accrual.accrl_cost_fixed := 0;
                rv_prom_year_accrual.accrl_cost_on_invoice := 0;
                rv_prom_year_accrual.accrl_cost := 0;
             END IF;
             CLOSE csr_prom_year_accrual;

             OPEN csr_prom_next_accrual;
             LOOP
                FETCH csr_prom_next_accrual INTO rv_prom_next_accrual;
                IF csr_prom_next_accrual%NOTFOUND THEN
                   exit;
                end if;
                tab_fact(tab_fact.count+1).fact_yyyypp := rv_prom_next_accrual.mars_period;
                tab_fact(tab_fact.count).str_yyyypp := v_rec_chg_period;
                tab_fact(tab_fact.count).end_yyyypp := c_future_eff_end_period;
                tab_fact(tab_fact.count).phased_percent := 0;
                tab_fact(tab_fact.count).phased_plnd_cost_iss_deferred := 0;
                tab_fact(tab_fact.count).phased_plnd_cost_case := 0;
                tab_fact(tab_fact.count).phased_plnd_cost_scan := 0;
                tab_fact(tab_fact.count).phased_plnd_cost_fixed := 0;
                tab_fact(tab_fact.count).phased_plnd_cost_on_invoice := 0;
                tab_fact(tab_fact.count).phased_plnd_cost := 0;
                tab_fact(tab_fact.count).phased_accrl_cost_iss_deferred := round(rv_prom_next_accrual.accrl_cost_iss_deferred - rv_prom_year_accrual.accrl_cost_iss_deferred, 2);
                tab_fact(tab_fact.count).phased_accrl_cost_case := round(rv_prom_next_accrual.accrl_cost_case - rv_prom_year_accrual.accrl_cost_case, 2);
                tab_fact(tab_fact.count).phased_accrl_cost_scan := round(rv_prom_next_accrual.accrl_cost_scan - rv_prom_year_accrual.accrl_cost_scan, 2);
                tab_fact(tab_fact.count).phased_accrl_cost_fixed := round(rv_prom_next_accrual.accrl_cost_fixed - rv_prom_year_accrual.accrl_cost_fixed, 2);
                tab_fact(tab_fact.count).phased_accrl_cost_on_invoice := round(rv_prom_next_accrual.accrl_cost_on_invoice - rv_prom_year_accrual.accrl_cost_on_invoice, 2);
                tab_fact(tab_fact.count).phased_accrl_cost := round(rv_prom_next_accrual.accrl_cost - rv_prom_year_accrual.accrl_cost, 2);
                tab_fact(tab_fact.count).claim_iss_deferred := 0;
                tab_fact(tab_fact.count).claim_case := 0;
                tab_fact(tab_fact.count).claim_scan := 0;
                tab_fact(tab_fact.count).claim_fixed := 0;
                tab_fact(tab_fact.count).claim_on_invoice := 0;
                tab_fact(tab_fact.count).claim := 0;
             END LOOP;
             CLOSE csr_prom_next_accrual;
             for idx in reverse tab_phased_yyyypp.count+1..tab_fact.count loop
                if idx > tab_phased_yyyypp.count+1 then
                   tab_fact(idx).phased_accrl_cost_iss_deferred := tab_fact(idx).phased_accrl_cost_iss_deferred - tab_fact(idx-1).phased_accrl_cost_iss_deferred;
                   tab_fact(idx).phased_accrl_cost_case := tab_fact(idx).phased_accrl_cost_case - tab_fact(idx-1).phased_accrl_cost_case;
                   tab_fact(idx).phased_accrl_cost_scan := tab_fact(idx).phased_accrl_cost_scan - tab_fact(idx-1).phased_accrl_cost_scan;
                   tab_fact(idx).phased_accrl_cost_fixed := tab_fact(idx).phased_accrl_cost_fixed - tab_fact(idx-1).phased_accrl_cost_fixed;
                   tab_fact(idx).phased_accrl_cost_on_invoice := tab_fact(idx).phased_accrl_cost_on_invoice - tab_fact(idx-1).phased_accrl_cost_on_invoice;
                   tab_fact(idx).phased_accrl_cost := tab_fact(idx).phased_accrl_cost - tab_fact(idx-1).phased_accrl_cost;
                end if;
             end loop;

          end if;

          /*-*/
          /* Assign the claim values to the phasing periods
          /*-*/
          for idx in 1..tab_claim.count loop
             var_found := false;
             for idy in 1..tab_fact.count loop
                if tab_claim(idx).claim_yyyypp = tab_fact(idy).fact_yyyypp then
                   tab_fact(idy).claim_iss_deferred := tab_claim(idx).claim_iss_deferred;
                   tab_fact(idy).claim_case := tab_claim(idx).claim_case;
                   tab_fact(idy).claim_scan := tab_claim(idx).claim_scan;
                   tab_fact(idy).claim_fixed := tab_claim(idx).claim_fixed;
                   tab_fact(idy).claim_on_invoice := tab_claim(idx).claim_on_invoice;
                   tab_fact(idy).claim := tab_claim(idx).claim;
                   var_found := true;
                end if;
             end loop;
             if var_found = false then
                var_index := 0;
                for idy in 1..tab_fact.count loop
                   if tab_claim(idx).claim_yyyypp < tab_fact(idy).fact_yyyypp then
                      var_index := idy;
                      exit;
                   end if;
                end loop;
                if var_index = 0 then
                   var_index := tab_fact.count+1;
                else
                   for idy in reverse var_index..tab_fact.count loop
                      tab_fact(idy+1).fact_yyyypp := tab_fact(idy).fact_yyyypp;
                      tab_fact(idy+1).str_yyyypp := tab_fact(idy).str_yyyypp;
                      tab_fact(idy+1).end_yyyypp := tab_fact(idy).end_yyyypp;
                      tab_fact(idy+1).phased_percent := tab_fact(idy).phased_percent;
                      tab_fact(idy+1).phased_plnd_cost_iss_deferred := tab_fact(idy).phased_plnd_cost_iss_deferred;
                      tab_fact(idy+1).phased_plnd_cost_case := tab_fact(idy).phased_plnd_cost_case;
                      tab_fact(idy+1).phased_plnd_cost_scan := tab_fact(idy).phased_plnd_cost_scan;
                      tab_fact(idy+1).phased_plnd_cost_fixed := tab_fact(idy).phased_plnd_cost_fixed;
                      tab_fact(idy+1).phased_plnd_cost_on_invoice := tab_fact(idy).phased_plnd_cost_on_invoice;
                      tab_fact(idy+1).phased_plnd_cost := tab_fact(idy).phased_plnd_cost;
                      tab_fact(idy+1).phased_accrl_cost_iss_deferred := tab_fact(idy).phased_accrl_cost_iss_deferred;
                      tab_fact(idy+1).phased_accrl_cost_case := tab_fact(idy).phased_accrl_cost_case;
                      tab_fact(idy+1).phased_accrl_cost_scan := tab_fact(idy).phased_accrl_cost_scan;
                      tab_fact(idy+1).phased_accrl_cost_fixed := tab_fact(idy).phased_accrl_cost_fixed;
                      tab_fact(idy+1).phased_accrl_cost_on_invoice := tab_fact(idy).phased_accrl_cost_on_invoice;
                      tab_fact(idy+1).phased_accrl_cost := tab_fact(idy).phased_accrl_cost;
                      tab_fact(idy+1).claim_iss_deferred := tab_fact(idy).claim_iss_deferred;
                      tab_fact(idy+1).claim_case := tab_fact(idy).claim_case;
                      tab_fact(idy+1).claim_scan := tab_fact(idy).claim_scan;
                      tab_fact(idy+1).claim_fixed := tab_fact(idy).claim_fixed;
                      tab_fact(idy+1).claim_on_invoice := tab_fact(idy).claim_on_invoice;
                      tab_fact(idy+1).claim := tab_fact(idy).claim;
                   end loop;
                end if;
                tab_fact(var_index).fact_yyyypp := tab_claim(idx).claim_yyyypp;
                tab_fact(var_index).str_yyyypp := v_rec_chg_period;
                tab_fact(var_index).end_yyyypp := c_future_eff_end_period;
                tab_fact(var_index).phased_percent := 0;
                tab_fact(var_index).phased_plnd_cost_iss_deferred := 0;
                tab_fact(var_index).phased_plnd_cost_case := 0;
                tab_fact(var_index).phased_plnd_cost_scan := 0;
                tab_fact(var_index).phased_plnd_cost_fixed := 0;
                tab_fact(var_index).phased_plnd_cost_on_invoice := 0;
                tab_fact(var_index).phased_plnd_cost := 0;
                tab_fact(var_index).phased_accrl_cost_iss_deferred := 0;
                tab_fact(var_index).phased_accrl_cost_case := 0;
                tab_fact(var_index).phased_accrl_cost_scan := 0;
                tab_fact(var_index).phased_accrl_cost_fixed := 0;
                tab_fact(var_index).phased_accrl_cost_on_invoice := 0;
                tab_fact(var_index).phased_accrl_cost := 0;
                tab_fact(var_index).claim_iss_deferred := tab_claim(idx).claim_iss_deferred;
                tab_fact(var_index).claim_case := tab_claim(idx).claim_case;
                tab_fact(var_index).claim_scan := tab_claim(idx).claim_scan;
                tab_fact(var_index).claim_fixed := tab_claim(idx).claim_fixed;
                tab_fact(var_index).claim_on_invoice := tab_claim(idx).claim_on_invoice;
                tab_fact(var_index).claim := tab_claim(idx).claim;
             end if;
          end loop;

          /*************************************************************
           Insert mutiple phasing records for a detail line
          *************************************************************/
          var_buy_accr_cost := 0;
          var_cur_accr_cost := 0;
          var_cur_claim := 0;
          var_tot_prom_cost := 0;
          var_tot_prom_claim := 0;
          var_first := true;
          FOR idx IN 1..tab_fact.count LOOP

             v_spend_on_this_period := 'F';


             /*-*/
             /* Calculate the promotion value
             /*-*/
              rcd_prom_fact.phased_plnd_cost_iss_deferred := tab_fact(idx).phased_plnd_cost_iss_deferred;
              rcd_prom_fact.phased_plnd_cost_case := tab_fact(idx).phased_plnd_cost_case;
              rcd_prom_fact.phased_plnd_cost_scan := tab_fact(idx).phased_plnd_cost_scan;
              rcd_prom_fact.phased_plnd_cost_fixed := tab_fact(idx).phased_plnd_cost_fixed;
              rcd_prom_fact.phased_plnd_cost_on_invoice := tab_fact(idx).phased_plnd_cost_on_invoice;
              rcd_prom_fact.phased_plnd_cost := rcd_prom_fact.phased_plnd_cost_iss_deferred +
                                                rcd_prom_fact.phased_plnd_cost_case +
                                                rcd_prom_fact.phased_plnd_cost_scan +
                                                rcd_prom_fact.phased_plnd_cost_fixed +
                                                rcd_prom_fact.phased_plnd_cost_on_invoice;

              rcd_prom_fact.phased_accrl_cost_iss_deferred := tab_fact(idx).phased_accrl_cost_iss_deferred;
              rcd_prom_fact.phased_accrl_cost_case := tab_fact(idx).phased_accrl_cost_case;
              rcd_prom_fact.phased_accrl_cost_scan := tab_fact(idx).phased_accrl_cost_scan;
              rcd_prom_fact.phased_accrl_cost_fixed := tab_fact(idx).phased_accrl_cost_fixed;
              rcd_prom_fact.phased_accrl_cost_on_invoice := tab_fact(idx).phased_accrl_cost_on_invoice;
              rcd_prom_fact.phased_accrl_cost := rcd_prom_fact.phased_accrl_cost_iss_deferred +
                                                 rcd_prom_fact.phased_accrl_cost_case +
                                                 rcd_prom_fact.phased_accrl_cost_scan +
                                                 rcd_prom_fact.phased_accrl_cost_fixed +
                                                 rcd_prom_fact.phased_accrl_cost_on_invoice;

              rcd_prom_fact.claim_iss_deferred := tab_fact(idx).claim_iss_deferred;
              rcd_prom_fact.claim_case := tab_fact(idx).claim_case;
              rcd_prom_fact.claim_scan := tab_fact(idx).claim_scan;
              rcd_prom_fact.claim_fixed := tab_fact(idx).claim_fixed;
              rcd_prom_fact.claim_on_invoice := tab_fact(idx).claim_on_invoice;
              rcd_prom_fact.claim := rcd_prom_fact.claim_iss_deferred +
                                     rcd_prom_fact.claim_case +
                                     rcd_prom_fact.claim_scan +
                                     rcd_prom_fact.claim_fixed +
                                     rcd_prom_fact.claim_on_invoice;

              rcd_prom_fact.phased_accrl_baln_iss_deferred := rcd_prom_fact.phased_accrl_cost_iss_deferred - rcd_prom_fact.claim_iss_deferred;
              rcd_prom_fact.phased_accrl_baln_case := rcd_prom_fact.phased_accrl_cost_case - rcd_prom_fact.claim_case;
              rcd_prom_fact.phased_accrl_baln_scan := rcd_prom_fact.phased_accrl_cost_scan - rcd_prom_fact.claim_scan;
              rcd_prom_fact.phased_accrl_baln_fixed := rcd_prom_fact.phased_accrl_cost_fixed - rcd_prom_fact.claim_fixed;
              rcd_prom_fact.phased_accrl_baln_on_invoice := rcd_prom_fact.phased_accrl_cost_on_invoice - rcd_prom_fact.claim_on_invoice;
              rcd_prom_fact.phased_accrl_baln := rcd_prom_fact.phased_accrl_cost - rcd_prom_fact.claim;

              rcd_prom_fact.phased_accrl_chng_iss_deferred := rcd_prom_fact.phased_accrl_cost_iss_deferred - rcd_prom_fact.phased_plnd_cost_iss_deferred;
              rcd_prom_fact.phased_accrl_chng_case := rcd_prom_fact.phased_accrl_cost_case - rcd_prom_fact.phased_plnd_cost_case;
              rcd_prom_fact.phased_accrl_chng_scan := rcd_prom_fact.phased_accrl_cost_scan - rcd_prom_fact.phased_plnd_cost_scan;
              rcd_prom_fact.phased_accrl_chng_fixed := rcd_prom_fact.phased_accrl_cost_fixed - rcd_prom_fact.phased_plnd_cost_fixed;
              rcd_prom_fact.phased_accrl_chng_on_invoice := rcd_prom_fact.phased_accrl_cost_on_invoice - rcd_prom_fact.phased_plnd_cost_on_invoice;
              rcd_prom_fact.phased_accrl_chng := rcd_prom_fact.phased_accrl_cost - rcd_prom_fact.phased_plnd_cost;

              rcd_prom_fact.phased_varc_chng_iss_deferred := rcd_prom_fact.phased_plnd_cost_iss_deferred - rcd_prom_fact.claim_iss_deferred;
              rcd_prom_fact.phased_varc_chng_case := rcd_prom_fact.phased_plnd_cost_case - rcd_prom_fact.claim_case;
              rcd_prom_fact.phased_varc_chng_scan := rcd_prom_fact.phased_plnd_cost_scan - rcd_prom_fact.claim_scan;
              rcd_prom_fact.phased_varc_chng_fixed := rcd_prom_fact.phased_plnd_cost_fixed - rcd_prom_fact.claim_fixed;
              rcd_prom_fact.phased_varc_chng_on_invoice := rcd_prom_fact.phased_plnd_cost_on_invoice - rcd_prom_fact.claim_on_invoice;
              rcd_prom_fact.phased_varc_chng := rcd_prom_fact.phased_plnd_cost - rcd_prom_fact.claim;

            /*-*/
            /* Accrual balance / accrual change set to zero
            /* **notes**
            /* 1. promotion status in (Finished, Closed Early, Inactive, Planned)
            /* 2. promotion status in (Confirmed) and buy start period within the report period
            /* 3. on invoice promotion
            /*-*/
            if v_off_inv_flag = 'T' then
               rcd_prom_fact.phased_accrl_baln_iss_deferred := 0;
               rcd_prom_fact.phased_accrl_baln_case := 0;
               rcd_prom_fact.phased_accrl_baln_scan := 0;
               rcd_prom_fact.phased_accrl_baln_fixed := 0;
               rcd_prom_fact.phased_accrl_baln_on_invoice := 0;
               rcd_prom_fact.phased_accrl_baln := 0;
               rcd_prom_fact.phased_accrl_chng_iss_deferred := 0;
               rcd_prom_fact.phased_accrl_chng_case := 0;
               rcd_prom_fact.phased_accrl_chng_scan := 0;
               rcd_prom_fact.phased_accrl_chng_fixed := 0;
               rcd_prom_fact.phased_accrl_chng_on_invoice := 0;
               rcd_prom_fact.phased_accrl_chng := 0;
            else
               if rv_prom_hdr.prom_stat_code in ('F','CE','C','P') then
                  rcd_prom_fact.phased_accrl_baln_iss_deferred := 0;
                  rcd_prom_fact.phased_accrl_baln_case := 0;
                  rcd_prom_fact.phased_accrl_baln_scan := 0;
                  rcd_prom_fact.phased_accrl_baln_fixed := 0;
                  rcd_prom_fact.phased_accrl_baln_on_invoice := 0;
                  rcd_prom_fact.phased_accrl_baln := 0;
               end if;
               if rv_prom_hdr.prom_stat_code in ('T') and
                  tab_fact(idx).fact_yyyypp > rv_prom_hdr.buy_start_yyyypp then
                  rcd_prom_fact.phased_accrl_baln_iss_deferred := 0;
                  rcd_prom_fact.phased_accrl_baln_case := 0;
                  rcd_prom_fact.phased_accrl_baln_scan := 0;
                  rcd_prom_fact.phased_accrl_baln_fixed := 0;
                  rcd_prom_fact.phased_accrl_baln_on_invoice := 0;
                  rcd_prom_fact.phased_accrl_baln := 0;
               end if;
            end if;

            /*-*/
            /* Calculate the promotion cost based on the fact year
            /* **notes**
            /* 1. promotion status in (Finished, Closed Early, Inactive) ==> promotion cost = claims (actuals)
            /* 2. promotion status = Planned ==> promotion cost = planned cost
            /* 3. promotion status = Deleted ==> promotion cost = 0
            /* 4. promotion is On-invoice Type ==> promotion cost = claims (actuals)
            /* 5. promotion is overspend (promotion level over spend) ==> promotion cost = claims (actuals)
            /* 6. default ==> promotion cost = accrual cost
            /*-*/
            if substr(to_char(tab_fact(idx).fact_yyyypp,'fm000000'),1,4) <= to_char(rv_prom_hdr.buy_start_yyyy,'fm0000') then
               if rv_prom_hdr.prom_stat_code in ('F','CE','C') then
                  v_prom_cost := rcd_prom_fact.claim;
               elsif rv_prom_hdr.prom_stat_code in ('P') then
                  v_prom_cost := rcd_prom_fact.phased_plnd_cost;
               elsif rv_prom_hdr.prom_stat_code in ('X') then
                  v_prom_cost := 0;
               elsif v_isOverSpendProm = 'T' then
                  v_prom_cost := rcd_prom_fact.claim;
               elsif v_off_inv_flag = 'T' then
                  v_prom_cost := rcd_prom_fact.claim;
               else
                  v_prom_cost := rcd_prom_fact.phased_accrl_cost;
               end if;
               var_buy_accr_cost := var_buy_accr_cost + rcd_prom_fact.phased_accrl_cost;
               var_tot_prom_cost := var_tot_prom_cost + v_prom_cost;
               var_tot_prom_claim := var_tot_prom_claim + rcd_prom_fact.claim;
            else
               if rv_prom_hdr.prom_stat_code in ('P') then
                  v_prom_cost := rcd_prom_fact.phased_plnd_cost;
               elsif rv_prom_hdr.prom_stat_code in ('X') then
                  v_prom_cost := 0;
               elsif v_off_inv_flag = 'T' then
                  if var_first = true then
                     var_first := false;
                     v_prom_cost := var_tot_prom_cost * -1;
                  else
                     v_prom_cost := 0;
                  end if;
               elsif (rv_prom_hdr.prom_stat_code in ('F','CE','C') or v_isOverSpendProm = 'T') then
                  v_prom_cost := (var_tot_prom_claim + rcd_prom_fact.claim) - var_buy_accr_cost - var_tot_prom_cost;
               else
                  v_prom_cost := (var_cur_accr_cost + rcd_prom_fact.phased_accrl_cost) - var_tot_prom_cost;
               end if;
               var_cur_claim := var_cur_claim + rcd_prom_fact.claim;
               var_cur_accr_cost := var_cur_accr_cost + rcd_prom_fact.phased_accrl_cost;
               var_tot_prom_cost := var_tot_prom_cost + v_prom_cost;
               var_tot_prom_claim := var_tot_prom_claim + rcd_prom_fact.claim;
            end if;

            -- Insert phasing record transaction
            INSERT INTO prom_fact
              (
               company_code,
               division_code,
               prom_num,
               matl_zrep_code,
               prom_yyyypp,
               eff_start_yyyypp,
               eff_end_yyyypp,
               cust_code,
               currcy_code,
               prom_type_key,
               prom_type_class_code,
               prom_status_code,
               prom_attrb_code,
               prom_fund_type_code_case1,
               prom_fund_type_code_case2,
               prom_fund_type_code_coop1,
               prom_fund_type_code_coop2,
               prom_fund_type_code_coop3,
               prom_fund_type_code_coup1,
               prom_fund_type_code_coup2,
               prom_fund_type_code_scan1,
               prom_fund_type_code_whse1,
               prom_price,
               buy_start_date,
               buy_end_date,
               buy_start_yyyypp,
               sell_start_date,
               sell_end_date,
               sell_start_yyyypp,
               origl_prom_cost,
               prom_cost,
               phased_percent,
               phased_plnd_cost_iss_deferred,
               phased_plnd_cost_case,
               phased_plnd_cost_scan,
               phased_plnd_cost_fixed,
               phased_plnd_cost_on_invoice,
               phased_plnd_cost,
               phased_accrl_cost_iss_deferred,
               phased_accrl_cost_case,
               phased_accrl_cost_scan,
               phased_accrl_cost_fixed,
               phased_accrl_cost_on_invoice,
               phased_accrl_cost,
               claim_iss_deferred,
               claim_case,
               claim_scan,
               claim_fixed,
               claim_on_invoice,
               claim,
               phased_accrl_baln_iss_deferred,
               phased_accrl_baln_case,
               phased_accrl_baln_scan,
               phased_accrl_baln_fixed,
               phased_accrl_baln_on_invoice,
               phased_accrl_baln,
               phased_accrl_chng_iss_deferred,
               phased_accrl_chng_case,
               phased_accrl_chng_scan,
               phased_accrl_chng_fixed,
               phased_accrl_chng_on_invoice,
               phased_accrl_chng,
               phased_varc_chng_iss_deferred,
               phased_varc_chng_case,
               phased_varc_chng_scan,
               phased_varc_chng_fixed,
               phased_varc_chng_on_invoice,
               phased_varc_chng,
               cust_prom_type,
               prom_comnt
              )
             VALUES
               (
               rv_prom_hdr.company_code,                              -- Company Code
               rv_prom_hdr.division_code,                             -- Division Code
               rv_prom_hdr.prom_num,                                  -- Promotion number
               rv_prom_dtl.matl_zrep_code,                            -- Material ZREP
               tab_fact(idx).fact_yyyypp,                                         -- Promotion YYYYPP
               tab_fact(idx).str_yyyypp,                                      -- Effective Start YYYYPP
               tab_fact(idx).end_yyyypp,
               rv_prom_hdr.cust_code,                                 -- Customer Code
               rv_prom_hdr.currcy_code,                               -- currency Code
               rv_prom_hdr.prom_type_key,                             -- Promotion Type Key
               rv_prom_hdr.prom_type_class,                           -- Promotion Type Class Code
               rv_prom_hdr.prom_stat_code,                            -- Promotion Status
               rv_prom_hdr.prom_attrb,                                -- Promotion Attribute Key
               rv_prom_hdr.case1_fund_code,                           -- Promotion Fund Type Code Case1
               rv_prom_hdr.case2_fund_code,                           -- Promotion Fund Type Code Case2
               rv_prom_hdr.coop1_fund_code,                           -- Promotion Fund Type Code Coop1
               rv_prom_hdr.coop2_fund_code,                           -- Promotion Fund Type Code Coop2
               rv_prom_hdr.coop3_fund_code,                           -- Promotion Fund Type Code Coop3
               rv_prom_hdr.coup1_fund_code,                           -- Promotion Fund Type Code Coup1
               rv_prom_hdr.coup2_fund_code,                           -- Promotion Fund Type Code Coup2
               rv_prom_hdr.scan1_fund_code,                           -- Promotion Fund Type Code Scan1
               rv_prom_hdr.whse1_fund_code,                           -- Promotion Fund Type Code Whse1
               rv_prom_dtl.retail_sell_price_plnd,                    -- Promotion Price
               rv_prom_hdr.buy_start,                                 -- Buy Start Date
               rv_prom_hdr.buy_end,                                   -- Buy End Date
               rv_prom_hdr.buy_start_yyyypp,                          -- Buy Start YYYYPP
               rv_prom_hdr.sell_start,                                -- Sell Start Date
               rv_prom_hdr.sell_end,                                  -- Sell End Date
               rv_prom_hdr.sell_start_yyyypp,                         -- Sell Start YYYYPP
               v_origl_prom_cost,                                     -- Original Promotion Cost
               v_prom_cost,                                           -- Promotion Cost
               tab_fact(idx).phased_percent,                                -- Phased percent
               rcd_prom_fact.phased_plnd_cost_iss_deferred, -- Phased plnd Cost Issues Deferred
               rcd_prom_fact.phased_plnd_cost_case,         -- Phased plnd Cost Case
               rcd_prom_fact.phased_plnd_cost_scan,         -- Phased plnd Cost Scan
               rcd_prom_fact.phased_plnd_cost_fixed,        -- Phased plnd Cost Fixed
               rcd_prom_fact.phased_plnd_cost_on_invoice,   -- Phased plnd Cost On Invoice
               rcd_prom_fact.phased_plnd_cost,              -- Phased plnd Cost
               rcd_prom_fact.phased_accrl_cost_iss_deferred,            -- Phased accrl Cost Issues Deferred
               rcd_prom_fact.phased_accrl_cost_case,                    -- Phased accrl Cost Case
               rcd_prom_fact.phased_accrl_cost_scan,                    -- Phased accrl Cost Scan
               rcd_prom_fact.phased_accrl_cost_fixed,                   -- Phased accrl Cost Fixed
               rcd_prom_fact.phased_accrl_cost_on_invoice,              -- Phased accrl Cost On Invoice
               rcd_prom_fact.phased_accrl_cost,                         -- Phased accrl Cost
               rcd_prom_fact.claim_iss_deferred,                 -- Phased Claim Value Issues Deferred
               rcd_prom_fact.claim_case,                         -- Phased Claim Value Case
               rcd_prom_fact.claim_scan,                         -- Phased Claim Value Scan
               rcd_prom_fact.claim_fixed,                        -- Phased Claim Value Fixed
               rcd_prom_fact.claim_on_invoice,                   -- Phased Claim Value On Invoice
               rcd_prom_fact.claim,                              -- Phased Claim Value
               rcd_prom_fact.phased_accrl_baln_iss_deferred,            -- Phased accrl Change Issues Deferred
               rcd_prom_fact.phased_accrl_baln_case,                    -- Phased accrl Change Case
               rcd_prom_fact.phased_accrl_baln_scan,                    -- Phased accrl Change Scan
               rcd_prom_fact.phased_accrl_baln_fixed,                   -- Phased accrl Change Fixed
               rcd_prom_fact.phased_accrl_baln_on_invoice,              -- Phased accrl Change On Invoice
               rcd_prom_fact.phased_accrl_baln,                         -- Phased accrl Change
               rcd_prom_fact.phased_accrl_chng_iss_deferred,            -- Phased accrl Change Issues Deferred
               rcd_prom_fact.phased_accrl_chng_case,                    -- Phased accrl Change Case
               rcd_prom_fact.phased_accrl_chng_scan,                    -- Phased accrl Change Scan
               rcd_prom_fact.phased_accrl_chng_fixed,                   -- Phased accrl Change Fixed
               rcd_prom_fact.phased_accrl_chng_on_invoice,              -- Phased accrl Change On Invoice
               rcd_prom_fact.phased_accrl_chng,                         -- Phased accrl Change
               rcd_prom_fact.phased_varc_chng_iss_deferred,             -- Phased Variance Change Issues Deferred
               rcd_prom_fact.phased_varc_chng_case,                     -- Phased Variance Change Case
               rcd_prom_fact.phased_varc_chng_scan,                     -- Phased Variance Change Scan
               rcd_prom_fact.phased_varc_chng_fixed,                    -- Phased Variance Change Fixed
               rcd_prom_fact.phased_varc_chng_on_invoice,               -- Phased Variance Change On Invoice
               rcd_prom_fact.phased_varc_chng,                          -- Phased Variance Change
               rv_prom_hdr.cust_prom_type,                              -- Customer Promotion Type
               rv_prom_hdr.prom_comnt                                   -- Promotion comment
               );

               v_prom_ins_count := v_prom_ins_count + 1;

          END LOOP; -- phasing loop

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            -- Identify which promotion material get error
            v_processing_msg := 'Company/Div/Prom/Matl [' || rv_prom_hdr.company_code || '/' || rv_prom_hdr.division_code ||
                    '/' || rv_prom_hdr.prom_num || '/' || rv_prom_dtl.matl_zrep_code || ']. Error: ' || SUBSTR(SQLERRM,1,512);
            IF csr_prom_dtl%ISOPEN THEN
              CLOSE csr_prom_dtl;
            END IF;
            IF csr_prom_hdr%ISOPEN THEN
              CLOSE csr_prom_hdr;
            END IF;
            RAISE e_processing_error;

        END;
      END LOOP;  -- detail loop
      CLOSE  csr_prom_dtl;

      -- Commit in a promotion level to avoid too much records in temp spaces
      COMMIT;

    END LOOP; -- header loop

    CLOSE  csr_prom_hdr;

  END IF;

  -- Commit.
  COMMIT;

  -- Completed prom_fact aggregation.
  write_log(ods_constants.data_type_prom, 'N/A', i_log_level + 1, 'Completed prom_fact aggregation.');

  -- Completed successfully.
  RETURN constants.success;

  EXCEPTION
    WHEN e_processing_error THEN
      write_log(ods_constants.data_type_prom,
                'ERROR',
                i_log_level+1,
               'scheduled_pmx_aggregation.prom_fact_aggregation: ERROR: ' || v_processing_msg);
      RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_prom,
              'ERROR',
              i_log_level+1,
             'scheduled_pmx_aggregation.prom_fact_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

  RETURN constants.error;
END prom_fact_aggregation;

FUNCTION claim_fact_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level    IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- VARIABLE DECLARATIONS

  v_valdtn_status       pmx_claim_doc.valdtn_status%TYPE := ods_constants.valdtn_valid;
  v_prev_period         mars_date_dim.mars_period%TYPE;
  v_rec_chg_period      mars_date_dim.mars_period%TYPE := 190001;  -- default to a low low period first

  v_processing_msg      constants.message_string;
  v_log_level           ods.log.log_level%TYPE;
  v_status              NUMBER;
  v_claim_dtl_ins_count PLS_INTEGER := 0;
  v_cur_claim_key       pmx_claim_hdr.claim_key%TYPE := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any claim document records were received or updated for given date and company
  -- NOTE: Any change to claim document, header and detail, the related document, header and detail
  --       are reloaded to ODS
  CURSOR csr_claim_doc_count IS
    SELECT
      count(*) AS claim_doc_count
    FROM
      pmx_claim_doc
    WHERE
      company_code = i_company_code
      AND claim_doc_lupdt > v_cntl_str_date
      AND claim_doc_lupdt <= v_cntl_end_date
      AND valdtn_status = v_valdtn_status;
    rv_claim_doc_count csr_claim_doc_count%ROWTYPE;

  -- Claim document cursor.
  CURSOR csr_claim_doc IS
    SELECT
      company_code,
      division_code,
      registry_key,
      t2.mars_period,
      cust_code,
      claim_doc_ref as claim_ref,
      acct_mgr_key,
      DECODE (t1.company_code,'147','AUD','NZD') as currcy_code,
      claim_doc_amt as claim_amt,
      claim_doc_sales_tax as claim_tax,
      (claim_doc_amt - claim_doc_bal) as claim_allocd_amt,
      (claim_doc_sales_tax - claim_doc_bal_tax) as claim_allocd_tax,
      claim_doc_bal as claim_unallocd_amt,
      claim_doc_bal_tax as claim_unallocd_tax,
      claim_doc_comnt as claim_comnt,
      rec_status,
      claim_doc_pay_by_chq as claim_pay_by_chq,
      claim_doc_seq,
      date_entrd as claim_date,
      process_date as claim_create_date,
      claim_chng_date as claim_chg_date,
      claim_doc_load_date,
      t3.mars_period as eff_start_yyyypp  -- based on claim_chng_date
    FROM
      pmx_claim_doc t1,
      mars_date_dim t2,
      mars_date_dim t3
    WHERE company_code = i_company_code
      AND claim_doc_lupdt > v_cntl_str_date
      AND claim_doc_lupdt <= v_cntl_end_date
      AND valdtn_status = v_valdtn_status
      AND t1.date_entrd = t2.calendar_date
      AND t1.claim_chng_date = t3.calendar_date
    ORDER BY claim_chng_date;  -- in case aggregating more than one effective period
  rv_claim_doc csr_claim_doc%ROWTYPE;

  -- Claim header an detail combined cursor for the current document
  CURSOR csr_claim_dtl IS
    SELECT
      t1.company_code,
      t1.division_code,
      t1.claim_key,
      t1.claim_hdr_prom_num,
      t2.matl_zrep_code,
      t1.internal_claim_num,
      t1.claim_num,
      t1.claim_type_code,
      t1.registry_key,
      t1.claim_hdr_ref,
      t1.claim_hdr_vndr_num,
      t1.disputed_flag,
      t2.matl_tdu_code,
      t1.claim_hdr_apprvl_date,
      t2.claim_dtl_amt,
      t2.claim_dtl_qty,
      t2.claim_dtl_tax
    FROM
      pmx_claim_hdr t1,
      pmx_claim_dtl t2
    WHERE
      t1.company_code = rv_claim_doc.company_code
      AND t1.division_code = rv_claim_doc.division_code
      AND t1.registry_key = rv_claim_doc.registry_key
      AND t1.company_code = t2.company_code
      AND t1.division_code = t2.division_code
      AND t1.claim_key = t2.claim_key
      AND t1.valdtn_status = v_valdtn_status;
  rv_claim_dtl csr_claim_dtl%ROWTYPE;

BEGIN
  -- Starting claim_fact aggregation.
  write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 1, 'Starting CLAIM_FACT aggregation.');

  -- Check any claim loaded on the load date
  OPEN  csr_claim_doc_count;
  FETCH csr_claim_doc_count INTO rv_claim_doc_count;
  CLOSE csr_claim_doc_count;

  -- If any claim record loaded then continue the aggregation process.
  write_log( ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Checking for any Claim Document records loaded for Company Code [' || i_company_code || '] between [' || TO_CHAR(v_cntl_str_date,'DD-MON-YYYY HH24:MI:SS') || ' - ' ||TO_CHAR(v_cntl_end_date,'DD-MON-YYYY HH24:MI:SS') ||'].');

  IF rv_claim_doc_count.claim_doc_count < 1 THEN
    write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'No new or updated Claim data loaded for Company Code [' || i_company_code || ']  between [' || TO_CHAR(v_cntl_str_date,'DD-MON-YYYY HH24:MI:SS') || ' - ' ||TO_CHAR(v_cntl_end_date,'DD-MON-YYYY HH24:MI:SS') ||'].');
  ELSE
    write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Aggregating Claims for Company Code [' || i_company_code || ']  between [' || TO_CHAR(v_cntl_str_date,'DD-MON-YYYY HH24:MI:SS') || ' - ' ||TO_CHAR(v_cntl_end_date,'DD-MON-YYYY HH24:MI:SS') ||'] with count - ' || rv_claim_doc_count.claim_doc_count );

    -- Open the claim document cursor.
    OPEN  csr_claim_doc;

    -- Read through the promotion header cursor.
    write_log(ods_constants.data_type_claim,'N/A', i_log_level + 2,'Looping through the csr_claim_doc cursor.');

    LOOP
      FETCH csr_claim_doc INTO rv_claim_doc;
      EXIT WHEN csr_claim_doc%NOTFOUND;

      -- NOTE: the eff_start_yyyypp will be based on
      --       the document record change date in case used for initial load of history records

      -- In case aggregating more than one effective period, so recalculate the previous period
      IF v_rec_chg_period <> rv_claim_doc.eff_start_yyyypp THEN
        v_rec_chg_period := rv_claim_doc.eff_start_yyyypp;
        v_prev_period := get_mars_period(rv_claim_doc.claim_chg_date, -28, ods_constants.job_type_pmx_aggregation, i_log_level + 1);
      END IF;

      -- ----------------------------------------------------------
      --      Close previous period loaded active record         --
      --      Delete this period loaded active record            --
      --      Insert this docuemnt into claim_fact again         --
      -- ----------------------------------------------------------
      write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Updating Effective End Date for existing active records on CLAIM_FACT Co/Div/RegKey : ' ||
                rv_claim_doc.company_code || '/' || rv_claim_doc.division_code || '/' || rv_claim_doc.registry_key || ' that have eff_start_yyyypp less than record change period [' || v_rec_chg_period || '].');

      -- Close the active records that have a eff_start_yyyypp less than loading period for this promotion
      UPDATE
        claim_fact
      SET
        eff_end_yyyypp = v_prev_period
      WHERE
        company_code = rv_claim_doc.company_code
        AND division_code = rv_claim_doc.division_code
        AND registry_key =  rv_claim_doc.registry_key
        AND eff_start_yyyypp < v_rec_chg_period
        AND eff_end_yyyypp = c_future_eff_end_period;

      write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Number of records in claim_fact table closed : ' || TO_CHAR(SQL%ROWCOUNT));

      -- delete this registry key document with eff_start_yyyypp equal to record change period
      write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Deleting records on CLAIM_FACT for Co/Div/RegKey : ' ||
                rv_claim_doc.company_code || '/' || rv_claim_doc.division_code || '/' || rv_claim_doc.registry_key || ' with eff_start_yyyypp eqaul to record change period [' || v_rec_chg_period || '].');

      DELETE
        claim_fact
      WHERE
        company_code = rv_claim_doc.company_code
        AND division_code = rv_claim_doc.division_code
        AND registry_key =  rv_claim_doc.registry_key
        AND eff_start_yyyypp >= v_rec_chg_period;

      -- store number of record deleted
      write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Number of records in claim_fact table deleted : ' || TO_CHAR(SQL%ROWCOUNT));

      -- insert the claim document to claim_fact
      INSERT INTO CLAIM_FACT
        (
          company_code,
          division_code,
          registry_key,
          claim_yyyypp,
          eff_start_yyyypp,
          eff_end_yyyypp,
          cust_code,
          claim_ref,
          acct_mgr_key,
          currcy_code,
          claim_amt,
          claim_tax,
          claim_allocd_amt,
          claim_allocd_tax,
          claim_unallocd_amt,
          claim_unallocd_tax,
          claim_comnt,
          rec_status,
          claim_pay_by_chq,
          claim_doc_seq,
          claim_date,
          claim_create_date,
          claim_chg_date
        )
      VALUES
        (
          rv_claim_doc.company_code,                              -- Company Code
          rv_claim_doc.division_code,                             -- Division Code
          rv_claim_doc.registry_key,                              -- Registry Key
          rv_claim_doc.mars_period,                               -- claim period
          v_rec_chg_period,                                       -- effective start period
          c_future_eff_end_period,                                -- effective end period
          rv_claim_doc.cust_code,                                 -- Customer Code
          rv_claim_doc.claim_ref,                                 -- claim reference
          rv_claim_doc.acct_mgr_key,                              -- account manager key
          rv_claim_doc.currcy_code,                               -- currency Code
          rv_claim_doc.claim_amt,                                -- Claim amount
          rv_claim_doc.claim_tax,                                 -- Claim Tax
          rv_claim_doc.claim_allocd_amt,                         -- Claim allocated amount
          rv_claim_doc.claim_allocd_tax,                          -- Claim allocated tax
          rv_claim_doc.claim_unallocd_amt,                        -- Claim unallocated amount
          rv_claim_doc.claim_unallocd_tax,                        -- Claim unallocated tax
          rv_claim_doc.claim_comnt,                               -- Claim Comments
          rv_claim_doc.rec_status,                                -- Claim Processed Status
          rv_claim_doc.claim_pay_by_chq,                          -- Claim Pay by Cheque Flag
          rv_claim_doc.claim_doc_seq,                             -- Document Sequence
          rv_claim_doc.claim_date,                                -- Claim Date
          rv_claim_doc.claim_create_date,                         -- Claim Create Date
          rv_claim_doc.claim_chg_date                             -- Last Change Date
        );

      -- ------------------------------------------------------------------------------------------------
      --  Handle claim detail for this claim document                                                  --
      --  Delete from claim_allocn_fact with same key claim_key to prevent allocation being backdated  --
      --  Insert details into claim_allocn_fact                                                         --
      -- ------------------------------------------------------------------------------------------------
      v_claim_dtl_ins_count := 0;
      v_cur_claim_key := -1;

      OPEN csr_claim_dtl;

      -- Read through the csr_claim_dtl cursor, delete existing record with same claim key and insert into claim_allocn_fact table
      LOOP
        FETCH csr_claim_dtl INTO rv_claim_dtl;
        EXIT WHEN csr_claim_dtl%NOTFOUND;

        -- Only delete when the claim key first changed
        IF v_cur_claim_key <> rv_claim_dtl.claim_key THEN
          DELETE claim_allocn_fact
          WHERE company_code = rv_claim_dtl.company_code
            AND division_code = rv_claim_dtl.division_code
            AND claim_key = rv_claim_dtl.claim_key;

          IF SQL%ROWCOUNT > 0 THEN
             write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Number of records deleted from claim_allocn_fact for claim_key [' || rv_claim_dtl.claim_key || '] is ' || TO_CHAR(SQL%ROWCOUNT));
          END IF;

          v_cur_claim_key := rv_claim_dtl.claim_key;
        END IF;

        BEGIN
          INSERT INTO claim_allocn_fact
            (
             company_code,
             division_code,
             claim_key,
             prom_num,
             matl_zrep_code,
             cust_code,
             internal_claim_num,
             claim_num,
             claim_type_code,
             registry_key,
             claim_ref,
             claim_vndr_num,
             disputed_flag,
             matl_tdu_code,
             currcy_code,
             claim_allocd_amt,
             claim_allocd_qty,
             claim_allocd_tax,
             claim_apprvl_date
            )
          VALUES
            (
             rv_claim_dtl.company_code,                     -- company code
             rv_claim_dtl.division_code,                    -- division code
             rv_claim_dtl.claim_key,                        -- claim key
             rv_claim_dtl.claim_hdr_prom_num,               -- promotion number
             rv_claim_dtl.matl_zrep_code,                   -- material zrep code
             rv_claim_doc.cust_code,                        -- customer code
             rv_claim_dtl.internal_claim_num,               -- internal claim number
             rv_claim_dtl.claim_num,                        -- claim number
             rv_claim_dtl.claim_type_code,                  -- claim type code
             rv_claim_dtl.registry_key,                     -- document registry key
             rv_claim_dtl.claim_hdr_ref,                    -- claim header reference
             rv_claim_dtl.claim_hdr_vndr_num,               -- vendor reference code
             rv_claim_dtl.disputed_flag,                    -- Disputed flag
             rv_claim_dtl.matl_tdu_code,                    -- material TDU code
             rv_claim_doc.currcy_code,                      -- currency code
             rv_claim_dtl.claim_dtl_amt,                    -- claimmed amount
             rv_claim_dtl.claim_dtl_qty,                    -- claimmed quantity
             rv_claim_dtl.claim_dtl_tax,                    -- claimmed tax
             rv_claim_dtl.claim_hdr_apprvl_date             -- claim approval date
            );
          v_claim_dtl_ins_count := v_claim_dtl_ins_count + 1;
        EXCEPTION
          WHEN OTHERS THEN
             ROLLBACK;
             -- identify which claim key material get error
             v_processing_msg := 'Insert error for Company/Div/ClaimKey/Matl [' || rv_claim_dtl.company_code || '/' || rv_claim_dtl.division_code ||
                     '/' ||  rv_claim_dtl.claim_key || rv_claim_dtl.matl_zrep_code || ']. Error: ' || SUBSTR(SQLERRM,1,512);
             IF csr_claim_dtl%ISOPEN THEN
                CLOSE csr_claim_dtl;
             END IF;
             IF csr_claim_doc%ISOPEN THEN
                CLOSE csr_claim_doc;
             END IF;
             RAISE e_processing_error;

        END;
      END LOOP; -- Detail Loop
      CLOSE  csr_claim_dtl;

      -- Commit in a document level  to avoid too much records kept in temp space
      COMMIT;

      -- Identify number of records inserted into claim_allocn_fact table for the current registry key
      write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 2, 'Number of records inserted into CLAIM_ALLOCN_FACT for Registry Key [' || rv_claim_doc.registry_key || '] is ' || TO_CHAR(v_claim_dtl_ins_count));

    END LOOP; -- Doc loop

    CLOSE  csr_claim_doc;

  END IF;

  -- Commit.
  COMMIT;

  -- Completed claim_fact aggregation.
  write_log(ods_constants.data_type_claim, 'N/A', i_log_level + 1, 'Completed CLAIM_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

  EXCEPTION
    WHEN e_processing_error THEN
      write_log(ods_constants.data_type_claim,
                'ERROR',
                i_log_level+1,
                'scheduled_pmx_aggregation.claim_fact_aggregation: ERROR: ' || v_processing_msg);
     RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_claim,
              'ERROR',
              i_log_level+1,
              'scheduled_pmx_aggregation.claim_fact_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

  RETURN constants.error;

END claim_fact_aggregation;

/* *************************************************************
 *        PERIODIC AGGREGATION FUNCTIONS
 * ************************************************************* */
FUNCTION accrls_fact_aggregation (
  i_company_code               IN company.company_code%TYPE,
  i_date_of_aggregation_period IN DATE,
  i_log_level                  IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- VARIABLE DECLARATIONS
  v_aggregation_period mars_date_dim.mars_period%TYPE;
  v_prev_period        mars_date_dim.mars_period%TYPE;
  v_processing_msg     constants.message_string;
  v_valdtn_status      pmx_accruals.valdtn_status%TYPE := ods_constants.valdtn_valid;

  -- CURSOR DECLARATIONS
  -- Check whether any promotion accrual data was received for the period.
  CURSOR csr_accrls_count IS
    SELECT
      count(*) AS accrls_count
    FROM
      pmx_accruals t1,
      mars_date_dim t2
    WHERE
      t1.company_code = i_company_code
      AND TRUNC(t1.accrl_date,'DD') = t2.calendar_date
      AND t1.valdtn_status = v_valdtn_status
      AND t2.mars_period = v_aggregation_period;
    rv_accrls_count csr_accrls_count%ROWTYPE;

BEGIN
  -- Starting accrls_fact aggregation.
  write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 1, 'Starting ACCRLS_FACT aggregation.');

  -- Get mars period for given date
  write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 2, 'Get Mars Period for DATE [' || TO_CHAR(i_date_of_aggregation_period,'DD-MON-YYYY') || '] - aggregation period');
  v_aggregation_period := get_mars_period (i_date_of_aggregation_period, 0, ods_constants.job_type_pmx_aggregation, i_log_level + 2);
  IF v_aggregation_period IS NULL THEN
     v_processing_msg := 'Error on converting Date Of aggregation to mars period';
     RAISE e_processing_error;
  END IF;

  -- Get Previous period for given date
  write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 2, 'Get Mars Period for DATE [' || TO_CHAR(i_date_of_aggregation_period - 28,'DD-MON-YYYY') || '] - previous aggregation period');
  v_prev_period := get_mars_period (i_date_of_aggregation_period, -28, ods_constants.job_type_pmx_aggregation, i_log_level + 2);
  IF v_prev_period IS NULL THEN
     v_processing_msg := 'Error on converting Date Of aggregation to previous mars period';
     RAISE e_processing_error;
  END IF;

  -- Fetch the record from the ccsr_accrls_count cursor.
  OPEN csr_accrls_count;
  FETCH csr_accrls_count INTO rv_accrls_count.accrls_count;
  CLOSE csr_accrls_count;

  -- If any accrls then continue the aggregation process.
  write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 2, 'Accrual record for aggregation period count - ' || rv_accrls_count.accrls_count);

  IF rv_accrls_count.accrls_count < 1 THEN
    write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 3, 'NO Accrual record for Company Code [' ||
      '' || i_company_code || '] and Period [' || TO_CHAR(v_aggregation_period) ||'].');
  ELSE
    write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 3, 'Aggregating Accruals for Company Code [' ||
      '' || i_company_code || '] and Period [' || TO_CHAR(v_aggregation_period) ||'].');

    -- Create a savepoint.
    SAVEPOINT accrls_fact_savepoint;

    -- Delete any accruals that may already exist for the company being aggregated.
    write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 3, 'Deleting from accrls_fact based on' ||
      ' Company Code [' || i_company_code || '] and Period [' || TO_CHAR(v_aggregation_period) || '].');

    DELETE FROM accrls_fact
    WHERE company_code = i_company_code
      AND accrl_yyyypp = v_aggregation_period;

    write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 3, 'Number of records deleted : ' || TO_CHAR(SQL%ROWCOUNT));

    -- Insert into purch_order_fact table based on company code and date.

    INSERT INTO accrls_fact
      (
      company_code,
      division_code,
      prom_num,
      matl_zrep_code,
      matl_tdu_code,
      cust_code,
      accrl_yyyypp,
      currcy_code,
      accrl_amt,
      accrl_amt_aud,
      accrl_chg_amt,
      accrl_chg_amt_aud,
      acct_mgr_code
      )
    SELECT
      t1.company_code,
      t1.division_code,
      t1.prom_num,
      t1.matl_zrep_code,
      t1.matl_tdu_code,
      t1.cust_code,
      t1.mars_period,
      t1.currcy_code,
      t1.accrl_amt,
      t1.accrl_amt_aud,
      DECODE(t2.accrl_amt, NULL, 0, (t1.accrl_amt - t2.accrl_amt)) as accrl_chg_amt,   -- this period minus last period
      DECODE(t2.accrl_amt_aud, NULL, 0, (t1.accrl_amt_aud - t2.accrl_amt_aud)) as accrl_chg_amt_aud,
      t1.acct_mgr_code
    FROM
      (
    SELECT       -- accrual data from ODS for given aggregation period
      t1.company_code,
      t1.division_code,
      t1.prom_num,
      t1.matl_zrep_code,
      t1.matl_tdu_code,
      t1.cust_code,
      t2.mars_period,
      t1.currcy_code,
      t1.accrl_amt,
      currcy_conv(t1.accrl_amt,currcy_code,ods_constants.currency_aud,t1.accrl_date,ods_constants.exchange_rate_type_mppr) accrl_amt_aud,
      t4.acct_mgr_code
    FROM
      pmx_accruals t1,
      mars_date_dim t2,
      pmx_cust_dim t3,
      acct_mgr_dim t4
    WHERE
      trunc(t1.accrl_date,'DD') = t2.calendar_date
      AND t1.valdtn_status = v_valdtn_status
      AND t2.mars_period = v_aggregation_period
      AND t1.company_code = i_company_code
      AND t1.company_code = t3.company_code (+)
      AND t1.division_code = t3.division_code (+)
      AND t1.cust_code = t3.cust_code (+)
      AND t3.acct_mgr_key = t4.acct_mgr_key (+)
      ) t1,
      (
    SELECT                             -- previous period accrual data from DDS
      t1.company_code,
      t1.division_code,
      t1.prom_num,
      t1.matl_zrep_code,
      t1.matl_tdu_code,
      t1.cust_code,
      t1.accrl_amt,
      t1.accrl_amt_aud
    FROM
      accrls_fact t1
    WHERE
          company_code = i_company_code
      AND accrl_yyyypp = v_prev_period
      ) t2
    WHERE
      t1.company_code = t2.company_code (+)
      AND t1.division_code = t2.division_code (+)
      AND t1.cust_code = t2.cust_code (+)
      AND t1.prom_num = t2.prom_num (+)
      AND t1.matl_zrep_code = t2.matl_zrep_code (+);

    write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 3, 'Number of records inserted : ' || TO_CHAR(SQL%ROWCOUNT));

    -- Commit.
    COMMIT;

  END IF;

  -- Completed purch_order_fact aggregation.
  write_log(ods_constants.data_type_accrl, 'N/A', i_log_level + 1, 'Completed ACCRLS_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO accrls_fact_savepoint;
    write_log(ods_constants.data_type_accrl,
              'ERROR',
              0,
              'scheduled_pmx_aggregation.accrls_fact_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END accrls_fact_aggregation;

/***************************************************************************
   HELPER FUNCTIONS
****************************************************************************/
FUNCTION pmx_cust_dmd_plng_grp_mapping (
  i_company_code    IN pmx_cust.company_code%TYPE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_division_code        division_dim.division_code%TYPE;
  v_hier_cust_code       std_hier.std_hier_cust_code%TYPE;
  v_company_code         pmx_cust_dim.company_code%TYPE;
  v_demand_plng_grp_code demand_plng_grp_dim.demand_plng_grp_code%TYPE;

  c_non_spec_div_code    CONSTANT    division_dim.division_code%TYPE := '51';
  c_cust_div_snack       CONSTANT    division_dim.division_code%TYPE := '55';
  c_cust_div_pet         CONSTANT    division_dim.division_code%TYPE := '56';
  c_cust_div_food        CONSTANT    division_dim.division_code%TYPE := '57';

  v_upd_count                    NUMBER := 0;
  v_total_found                  NUMBER := 0;
  v_from_51_count                NUMBER := 0;
  v_cust_count                   NUMBER := 0;


  -- CURSOR DECLARATIONS

  -- return all hier customer and promotion customer without demand planning group mapped
  CURSOR csr_pmx_cust IS
    SELECT
      cust_code,
      division_code matl_division_code,
      decode(division_code, '01',c_cust_div_snack,'02',c_cust_div_food,'05',c_cust_div_pet) division_code, -- mapping matl div to cust div
      company_code
    FROM pmx_cust_dim
    WHERE
      company_code = i_company_code
      AND demand_plng_grp_code is null
      AND cust_code like '004%'
    UNION  -- include those direct customer exists in promotion without mapping yet
    SELECT
      cust_code,
      division_code matl_division_code,
      decode(division_code, '01',c_cust_div_snack,'02',c_cust_div_food,'05',c_cust_div_pet) division_code, -- mapping matl div to cust div
      company_code
    FROM pmx_cust_dim t1
    WHERE
      company_code = i_company_code
      AND demand_plng_grp_code is null
      AND EXISTS (SELECT *
                  FROM pmx_prom_hdr t2
                  WHERE t1.company_code = t2.company_code
                    AND t1.division_code = t2.division_code
                    AND t1.cust_code = t2.cust_code);


  rv_pmx_cust csr_pmx_cust%ROWTYPE;

  -- for customer that doesn't have set up from demand_plng_grp_sales_area_dim
  -- NOTE: this can't be test properly until demand_plng_grp_code is set up in cust_code_level_1 for all divisions
  CURSOR csr_std_hier_dmd_plng_grp IS
    SELECT
      cust_code_level_1 as demand_plng_grp_code -- first level will be set up as the demand_plng_grp_code
    FROM
      std_hier
    WHERE
      sales_org_code_level_1 = v_company_code
      AND (   (std_hier_cust_code = v_hier_cust_code  and  division_code = v_division_code )
           or (cust_code_level_2 = v_hier_cust_code  and division_code_level_2 = v_division_code )
           or (cust_code_level_3 = v_hier_cust_code  and division_code_level_3 = v_division_code )
           or (cust_code_level_4 = v_hier_cust_code  and division_code_level_4 = v_division_code )
           or (cust_code_level_5 = v_hier_cust_code  and division_code_level_5 = v_division_code )
           or (cust_code_level_6 = v_hier_cust_code  and division_code_level_6 = v_division_code )
           or (cust_code_level_7 = v_hier_cust_code  and division_code_level_7 = v_division_code )
           or (cust_code_level_8 = v_hier_cust_code  and division_code_level_8 = v_division_code )
           or (cust_code_level_9 = v_hier_cust_code  and division_code_level_9 = v_division_code )
           or (cust_code_level_10 = v_hier_cust_code and division_code_level_10 = v_division_code )
          )
    GROUP BY cust_code_level_1;

    rv_std_hier_dmd_plng_grp    csr_std_hier_dmd_plng_grp%ROWTYPE;


BEGIN

  -- Starting mapping demand planning group code for pmx_cust_dim
  write_log( ods_constants.data_type_pmx_cust, 'N/A', i_log_level + 1, 'Start pmx customer demand planning group mapping for company_code - ' || i_company_code );

  -- try to map it from demand_plng_grp_sales_area_dim with mapped division
  UPDATE
    pmx_cust_dim t1
  SET demand_plng_grp_code = (SELECT MAX(demand_plng_grp_code)
                              FROM demand_plng_grp_sales_area_dim t2
                              WHERE
                                t1.company_code = t2.sales_org_code
                                and decode(t1.division_code, '01',c_cust_div_snack,'02',c_cust_div_food,'05',c_cust_div_pet) = t2.division_code
                                and t1.cust_code = t2.cust_code
                              )
  WHERE company_code= i_company_code;

  SELECT COUNT(*) INTO v_upd_count
  FROM pmx_cust_dim
  WHERE
    company_code= i_company_code
    AND demand_plng_grp_code IS NOT NULL;

  v_total_found := v_upd_count;

  write_log( ods_constants.data_type_pmx_cust, 'N/A', i_log_level + 2, 'Direct Division mapped count - ' || v_upd_count);


  -- try to map it from demand_plng_grp_sales_area_dim with mapped distbn channel for Pet
  UPDATE
    pmx_cust_dim t1
  SET demand_plng_grp_code = (SELECT MAX(t2.demand_plng_grp_code)
                              FROM
                                demand_plng_grp_sales_area_dim t2
                              WHERE
                                t1.company_code = t2.sales_org_code
                                AND t1.cust_code = t2.cust_code
                                AND t2.division_code = c_non_spec_div_code  -- through Non Spec division 51
                                AND t2.distbn_chnl_code in ('20')       -- Pet distbn channel
                              )
  WHERE
    company_code= i_company_code
    AND demand_plng_grp_code IS NULL
    AND division_code = '05';

  SELECT COUNT(*) INTO v_upd_count
  FROM pmx_cust_dim
  WHERE
    company_code= i_company_code
    AND demand_plng_grp_code IS NOT NULL;

  v_from_51_count := v_upd_count - v_total_found;
  v_total_found := v_upd_count;

  write_log( ods_constants.data_type_pmx_cust, 'N/A', i_log_level + 2, 'Pet mapped from 51 Division count - ' || v_from_51_count);


  -- try to map it from demand_plng_grp_sales_area_dim with mapped distbn channel for Snackfood
  UPDATE
    pmx_cust_dim t1
  SET demand_plng_grp_code = (SELECT MAX(t2.demand_plng_grp_code)
                              FROM
                                demand_plng_grp_sales_area_dim t2
                              WHERE
                                t1.company_code = t2.sales_org_code
                                AND t1.cust_code = t2.cust_code
                                AND t2.division_code = c_non_spec_div_code    -- through Non Spec division 51
                                AND t2.distbn_chnl_code in ('31')             -- Snackfood fundraising distbn channel
                              )
  WHERE
    company_code= i_company_code
    AND demand_plng_grp_code IS NULL
    AND division_code = '01';

  SELECT COUNT(*) INTO v_upd_count
  FROM pmx_cust_dim
  WHERE
    company_code= i_company_code
    AND demand_plng_grp_code IS NOT NULL;

  v_from_51_count := v_upd_count - v_total_found;
  v_total_found := v_upd_count;

  write_log( ods_constants.data_type_pmx_cust, 'N/A', i_log_level + 2, 'Snack mapped from 51 division count - ' || v_from_51_count);

  write_log( ods_constants.data_type_pmx_cust, 'N/A', i_log_level + 2, 'Try to map the rest from std_hier');

  v_upd_count := 0;

  FOR rv_pmx_cust IN csr_pmx_cust LOOP

   v_cust_count := v_cust_count + 1;
   v_division_code  := rv_pmx_cust.division_code;
   v_hier_cust_code := LTRIM(rv_pmx_cust.cust_code,'0');  -- remove leading zero to map the std_hier cust_code
   v_company_code   := rv_pmx_cust.company_code;
   v_demand_plng_grp_code := NULL;

   OPEN csr_std_hier_dmd_plng_grp;
   FETCH csr_std_hier_dmd_plng_grp INTO rv_std_hier_dmd_plng_grp;
   IF csr_std_hier_dmd_plng_grp%FOUND THEN
      v_demand_plng_grp_code := LPAD(rv_std_hier_dmd_plng_grp.demand_plng_grp_code, 10, '0');
   END IF;
   CLOSE csr_std_hier_dmd_plng_grp;

   IF v_demand_plng_grp_code IS NOT NULL THEN
       v_upd_count := v_upd_count + 1;

       UPDATE pmx_cust_dim
       SET demand_plng_grp_code = v_demand_plng_grp_code
       WHERE
         company_code = v_company_code
         AND division_code = rv_pmx_cust.matl_division_code
         AND cust_code = rv_pmx_cust.cust_code;

   END IF;

  END LOOP;

  COMMIT;
  write_log(ods_constants.data_type_pmx_cust, 'N/A', i_log_level + 2,
            'COMPLETE with mapped from std_hier count/cust in loop [' || v_upd_count || '/' || v_cust_count || ']');

  RETURN constants.success;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log( ods_constants.data_type_pmx_cust,'ERROR',i_log_level+1,
               'scheduled_pmx_aggregation.pmx_cust_dmd_plng_grp_mapping: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error;

END pmx_cust_dmd_plng_grp_mapping;

FUNCTION get_off_invoice_flag (
  i_company_code  IN pmx_prom_hdr.company_code%TYPE,
  i_division_code IN pmx_prom_hdr.division_code%TYPE,
  i_fund_code1    IN pmx_prom_hdr.case1_fund_code%TYPE,
  i_fund_code2    IN pmx_prom_hdr.case1_fund_code%TYPE,
  i_job_type      IN ods.log.job_type_code%TYPE,
  i_log_level     IN ods.log.log_level%TYPE
 ) RETURN VARCHAR2 IS

  -- CURSOR DECLARATIONS
  CURSOR csr_fund_desc IS
    SELECT
      off_invoice_flag as off_invoice_flag
    FROM
      prom_fund_type_dim
    WHERE company_code = i_company_code
      AND division_code = i_division_code
      AND prom_fund_type_code IN (i_fund_code1, i_fund_code2)
      AND off_invoice_flag = 'T';
  rv_fund_desc csr_fund_desc%ROWTYPE;

BEGIN
  -- Fetch the record from the csr_fund_desc cursor.
  OPEN csr_fund_desc;
  FETCH csr_fund_desc INTO rv_fund_desc;
  IF csr_fund_desc%NOTFOUND THEN
    CLOSE csr_fund_desc;
    RETURN 'F';
  ELSE
    CLOSE csr_fund_desc;
    RETURN rv_fund_desc.off_invoice_flag;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_fund_desc%ISOPEN THEN
      CLOSE csr_fund_desc;
    END IF;
    utils.ods_log(i_job_type,
                  ods_constants.data_type_prom,
                  'ERROR',
                  i_log_level,
                  'scheduled_pmx_aggregation.get_off_invoice_flag: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END get_off_invoice_flag;

FUNCTION convert_char_to_percent (
  i_char      IN pmx_prom_hdr.split%TYPE,
  i_log_level IN ods.log.log_level%TYPE
 ) RETURN NUMBER IS

  v_percent NUMBER := 0;

BEGIN
  v_percent := CASE i_char
                 WHEN 'A' THEN 100
                 WHEN 'B' THEN 90
                 WHEN 'C' THEN 80
                 WHEN 'D' THEN 70
                 WHEN 'E' THEN 60
                 WHEN 'F' THEN 50
                 WHEN 'G' THEN 40
                 WHEN 'H' THEN 30
                 WHEN 'I' THEN 20
                 WHEN 'J' THEN 10
                 WHEN 'K' THEN 0
                 ELSE 0
         END;

  RETURN v_percent;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_prom,
              'ERROR',
              i_log_level,
              'scheduled_pmx_aggregation.convert_char_to_percent: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END convert_char_to_percent;

FUNCTION get_mars_period (
  i_date        IN DATE,
  i_offset_days IN NUMBER,
  i_job_type    IN ods.log.job_type_code%TYPE,
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
    utils.ods_log(i_job_type,
                  ods_constants.data_type_generic,
                  'ERROR',
                  i_log_level,
                  'scheduled_pmx_aggregation.get_mars_period: ERROR: mars_period not found for [' || to_char(i_date+i_offset_days,'DD-MON-YYYY') || ']' );
    RETURN NULL;
  WHEN OTHERS THEN
    CLOSE csr_mars_period;
    utils.ods_log(i_job_type,
                  ods_constants.data_type_generic,
                  'ERROR',
                  i_log_level,
                  'scheduled_pmx_aggregation.get_mars_period: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END get_mars_period;

PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Write the entry into the log table.
  utils.ods_log (ods_constants.job_type_pmx_aggregation,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END write_log;

/* *******************************************************
 *      LOCAL HELPER FUNCTIONS
 * ******************************************************* */
FUNCTION get_prom_phased_periods (
  i_log_level          IN ods.log.log_level%TYPE,
  i_buy_start_date     IN prom_fact.buy_start_date%TYPE,
  i_buy_end_date       IN prom_fact.buy_end_date%TYPE,
  io_tab_phased_yyyypp IN OUT NOCOPY tab_typ_phased_yyyypp)
  RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_period IS
    SELECT DISTINCT mars_period AS mars_period
    FROM mars_date_dim
    WHERE calendar_date BETWEEN i_buy_start_date AND i_buy_end_date
    ORDER BY mars_period;

BEGIN
  -- Delete any previously loaded records
  IF io_tab_phased_yyyypp IS NOT NULL AND io_tab_phased_yyyypp.COUNT > 0 THEN
    io_tab_phased_yyyypp.DELETE(io_tab_phased_yyyypp.FIRST, io_tab_phased_yyyypp.LAST);
  END IF;

  -- Bulk load the source data into the sql table.
  OPEN csr_mars_period;
  FETCH csr_mars_period
  BULK COLLECT INTO io_tab_phased_yyyypp;

  IF csr_mars_period%ISOPEN THEN
    CLOSE csr_mars_period;
  END IF;
  RETURN constants.success;
EXCEPTION
  WHEN OTHERS THEN
    IF csr_mars_period%ISOPEN THEN
      CLOSE csr_mars_period;
    END IF;
    write_log(ods_constants.data_type_prom,
              'ERROR',
               i_log_level,
               'scheduled_pmx_aggregation.get_prom_phased_periods: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error;
END get_prom_phased_periods;

FUNCTION get_prom_phased_percents (
  i_log_level           IN ods.log.log_level%TYPE,
  i_company_code        IN pmx_prom_hdr.company_code%TYPE,
  i_division_code       IN pmx_prom_hdr.division_code%TYPE,
  i_prom_num            IN pmx_prom_hdr.prom_num%TYPE,
  i_prom_chng_date      IN pmx_prom_hdr.prom_chng_date%TYPE,
  i_prom_type_class     IN pmx_prom_hdr.prom_type_class%TYPE,
  i_split               IN pmx_prom_hdr.split%TYPE,
  i_split_end           IN pmx_prom_hdr.split_end%TYPE,
  i_start_period_week   IN mars_date_dim.mars_week_of_period%TYPE,
  i_period_count        IN PLS_INTEGER,
  io_tab_phased_percent IN OUT NOCOPY tab_typ_phased_percent,
  i_buy_start           IN pmx_prom_hdr.buy_start%TYPE,
  i_buy_end             IN pmx_prom_hdr.buy_end%TYPE
  ) RETURN NUMBER IS

  -- LOCAL VARIABLES
  v_week_in_period PLS_INTEGER := i_start_period_week;  -- default to first period week
  v_period         PLS_INTEGER := 1;
  v_period_percent prom_fact.phased_percent%TYPE := 0;
  v_total_percent  prom_fact.phased_percent%TYPE := 0;
  v_tab_wk_percent tab_typ_phased_percent;
  v_week_count     PLS_INTEGER := 1;
  v_prom_weeks     PLS_INTEGER;
  v_week_percent   pmx_prom_profile.wk1_pctg%TYPE;

  -- CURSOR DECLARATIONS
  CURSOR csr_prom_profile IS
    SELECT
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
      wk18_pctg
    FROM
      pmx_prom_profile
    WHERE
      company_code = i_company_code
      AND division_code = i_division_code
      AND prom_num = i_prom_num
      AND prom_chng_date = i_prom_chng_date;

  CURSOR csr_week_count IS
    SELECT
      COUNT(distinct mars_week) as num_of_weeks
    FROM
      mars_date_dim
    WHERE
      calendar_date BETWEEN i_buy_start AND i_buy_end;

BEGIN
  -- Delete the array previous loaded percentages.
  IF io_tab_phased_percent.COUNT > 0 THEN
    io_tab_phased_percent.DELETE(io_tab_phased_percent.FIRST, io_tab_phased_percent.LAST);
  END IF;

  -- Initial the percentage for each period to zero first.
  FOR i IN 1..i_period_count LOOP
    io_tab_phased_percent(i) := 0;
  END LOOP;

  -- Rebate type, phasing percentage stored in split and split_end.
  IF i_prom_type_class = c_rebate_type THEN
    -- Handle rebate type
    IF i_period_count = 1 THEN
      io_tab_phased_percent(1) := convert_char_to_percent(i_split,i_log_level+1);
    ELSIF i_period_count = 2 THEN
      io_tab_phased_percent(1) := convert_char_to_percent(i_split,i_log_level+1);
      io_tab_phased_percent(2) := convert_char_to_percent(i_split_end,i_log_level+1);
    ELSIF i_period_count > 2 THEN
      io_tab_phased_percent(1) := convert_char_to_percent(i_split,i_log_level+1);
      io_tab_phased_percent(i_period_count) := convert_char_to_percent(i_split_end,i_log_level+1);

      -- Equally split the rest of percentages for the middle periods
      v_period_percent := (100 - io_tab_phased_percent(1) - io_tab_phased_percent(i_period_count))/(i_period_count-2);
      FOR i IN 2..i_period_count - 1 LOOP
        io_tab_phased_percent(i) := v_period_percent;
      END LOOP;
    END IF;

  ELSE
    -- Promotion type stored in profile
    OPEN csr_prom_profile;
    FETCH csr_prom_profile INTO v_tab_wk_percent(1),v_tab_wk_percent(2),v_tab_wk_percent(3),v_tab_wk_percent(4),
                                v_tab_wk_percent(5),v_tab_wk_percent(6),v_tab_wk_percent(7),v_tab_wk_percent(8),
                                v_tab_wk_percent(9),v_tab_wk_percent(10),v_tab_wk_percent(11),v_tab_wk_percent(12),
                                v_tab_wk_percent(13),v_tab_wk_percent(14),v_tab_wk_percent(15),v_tab_wk_percent(16),
                                v_tab_wk_percent(17),v_tab_wk_percent(18);

    IF csr_prom_profile%NOTFOUND THEN
      CLOSE csr_prom_profile;

      -- No profile record then evenly split 100% to promotion weeks
      OPEN csr_week_count;
      FETCH csr_week_count INTO v_prom_weeks;
      IF csr_week_count%FOUND THEN
        CLOSE csr_week_count;

        -- initial the percent table
        FOR j IN 1..18 LOOP
          v_tab_wk_percent(j) := 0;
        END LOOP;

        -- Equally split the percentage to the promotion weeks
        v_week_percent := ROUND(100/v_prom_weeks,0);
        FOR i IN 1..v_prom_weeks LOOP
          -- The last promotion week do it differently to ensure the sum is not over 100
          IF i = v_prom_weeks THEN
            v_tab_wk_percent(i) := 100 - (v_week_percent * (v_prom_weeks - 1));
          ELSE
            v_tab_wk_percent(i) := v_week_percent;
          END IF;
        END LOOP;
      ELSE
        -- Not found put 100% to first week
        v_tab_wk_percent(1) := 100;
      END IF;

    END IF;

    IF csr_prom_profile%ISOPEN THEN
      CLOSE csr_prom_profile;
    END IF;

    WHILE v_period <= i_period_count  AND v_week_count <= v_tab_wk_percent.COUNT LOOP
      WHILE v_week_in_period <= 4  AND v_week_count <= v_tab_wk_percent.COUNT LOOP  -- max number of weeks in a period
        io_tab_phased_percent(v_period) := io_tab_phased_percent(v_period) + v_tab_wk_percent(v_week_count);
        v_week_count := v_week_count + 1;
        v_week_in_period := v_week_in_period + 1;
      END LOOP; -- weeks in period loop

      -- Next period
      v_period := v_period + 1;
      v_week_in_period := 1;  -- restart week of period from week 1

    END LOOP;  -- period loop
  END IF;        -- promotion type

  ---------------------------------------------------------
  -- Make sure that the total percentage equals 100%.
  -- Adjust the last period percentage either up or down
  ---------------------------------------------------------
  v_total_percent := 0;
  FOR i IN 1..i_period_count LOOP
    v_total_percent := v_total_percent + io_tab_phased_percent(i);
  END LOOP;
  IF v_total_percent != 100 then
    io_tab_phased_percent(i_period_count) := io_tab_phased_percent(i_period_count) + (100 - v_total_percent);
  END IF;

  RETURN constants.success;
EXCEPTION
  WHEN OTHERS THEN
    IF csr_prom_profile%ISOPEN THEN
      CLOSE csr_prom_profile;
    END IF;
    IF csr_week_count%ISOPEN THEN
      CLOSE csr_week_count;
    END IF;

    write_log(ods_constants.data_type_prom,
              'ERROR',
              i_log_level,
              'scheduled_pmx_aggregation.get_prom_phased_percents company/div/prom [' || i_company_code || '/' ||
                   i_division_code || '/' || i_prom_num || '] ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error;
END get_prom_phased_percents;

FUNCTION get_origl_prom_cost (
  i_log_level      IN ods.log.log_level%TYPE,
  i_company_code   IN pmx_prom_hdr.company_code%TYPE,
  i_division_code  IN pmx_prom_hdr.division_code%TYPE,
  i_prom_num       IN pmx_prom_hdr.prom_num%TYPE,
  i_prom_chng_date IN pmx_prom_hdr.prom_chng_date%TYPE
 ) RETURN NUMBER IS

  -- VARIABLE DECLARATTIONS
  v_origl_prom_cost prom_fact.origl_prom_cost%TYPE := 0;

  -- CURSOR DECLARATIONS
  CURSOR csr_prom_dtl IS
    SELECT
       round(SUM((whse_wthdrwl_case1_plnd * whse_wthdrwl_qty_plnd) +
           (xfact_case1_plnd + xfact_case2_plnd) * xfact_qty_plnd +
           (scan_case1_plnd * scan_qty_plnd) +
           (coop1_plnd + coop2_plnd + coop3_plnd)), 2) as origl_prom_cost
    FROM
      pmx_prom_dtl
    WHERE
      company_code = i_company_code
      AND division_code = i_division_code
      AND prom_num =  i_prom_num
      AND prom_chng_date = i_prom_chng_date;
  rv_prom_dtl csr_prom_dtl%ROWTYPE;

BEGIN
  -- Fetch the record from the csr_fund_desc cursor.
  OPEN csr_prom_dtl;
  FETCH csr_prom_dtl INTO rv_prom_dtl;
  IF csr_prom_dtl%NOTFOUND THEN
    CLOSE csr_prom_dtl;
  ELSE
    CLOSE csr_prom_dtl;
    v_origl_prom_cost := rv_prom_dtl.origl_prom_cost;
  END IF;

  RETURN v_origl_prom_cost;
EXCEPTION
  WHEN OTHERS THEN
    IF csr_prom_dtl%ISOPEN THEN
      CLOSE csr_prom_dtl;
    END IF;
    write_log(ods_constants.data_type_prom,
              'ERROR',
              i_log_level,
              'scheduled_pmx_aggregation.get_origl_prom_cost: company/div/prom [' || i_company_code || '/' ||
                   i_division_code || '/' || i_prom_num || '] ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END get_origl_prom_cost;

FUNCTION check_phased_overspend (
  i_log_level         IN ods.log.log_level%TYPE,
  i_company_code      IN pmx_prom_hdr.company_code%TYPE,
  i_division_code     IN pmx_prom_hdr.division_code%TYPE,
  i_prom_num          IN pmx_prom_hdr.prom_num%TYPE,
  i_prom_chng_date    IN pmx_prom_hdr.prom_chng_date%TYPE,
  i_pctg              IN NUMBER,
  i_prom_yyyypp       IN prom_fact.prom_yyyypp%TYPE,
  o_isOverSpend       OUT VARCHAR2
 ) RETURN NUMBER IS

  -- VARIABLE DECLARATTIONS
  v_isOverSpend BOOLEAN := FALSE;
  v_total_plnd prom_fact.phased_accrl_cost%TYPE := 0;
  v_total_phased_plnd prom_fact.phased_accrl_cost%TYPE := 0;

  -- CURSOR DECLARATIONS
  CURSOR csr_total_prom_amt IS
    SELECT
      t2.prom_stat_code,
      round(NVL(SUM((t1.whse_wthdrwl_case1_plnd * t1.whse_wthdrwl_qty_plnd) +
          (t1.xfact_case1_plnd + t1.xfact_case2_plnd) * t1.xfact_qty_plnd +
          (t1.scan_case1_plnd * t1.scan_qty_plnd) +
          (t1.coop1_plnd + t1.coop2_plnd + t1.coop3_plnd)),0), 2) as origl_prom_cost,
      round(NVL(SUM((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl) +
          (case1_accrl + case2_accrl) * est_qty_accrl +
          (scan_qty_accrl * scan_deal_accrl) +
          (coop1_accrl + coop2_accrl + coop3_accrl)),0), 2) as accrl_cost,
      nvl(max(t3.claim_amt),0) as claim
    FROM
      pmx_prom_dtl t1,
      pmx_prom_hdr t2,
      (select t01.claim_hdr_prom_num,
              round(sum(t02.claim_dtl_amt), 2) as claim_amt
         from pmx_claim_hdr t01,
              pmx_claim_dtl t02
        where t01.company_code = t02.company_code
          and t01.division_code = t02.division_code
          and t01.claim_key = t02.claim_key
          and t01.company_code = i_company_code
          and t01.division_code = i_division_code
          and t01.claim_hdr_prom_num = i_prom_num
          and trunc(t01.process_date) <= trunc(i_prom_chng_date)
        group by t01.claim_hdr_prom_num) t3
    WHERE
      t1.company_code = i_company_code
      AND t1.division_code = i_division_code
      AND t1.prom_num = i_prom_num
      AND t1.prom_chng_date = i_prom_chng_date
      AND t1.company_code = t2.company_code
      AND t1.division_code = t2.division_code
      AND t1.prom_num = t2.prom_num
      AND t1.prom_chng_date = t2.prom_chng_date
      AND t1.prom_num = t3.claim_hdr_prom_num(+)
    GROUP BY
      t2.prom_stat_code;
  rv_total_prom_amt csr_total_prom_amt%ROWTYPE;

BEGIN
  o_isOverSpend := 'F';
  -- Fetch the record from the csr_total_prom_amt cursor.
  OPEN csr_total_prom_amt;
  FETCH csr_total_prom_amt INTO rv_total_prom_amt;
  IF csr_total_prom_amt%FOUND THEN
    -- If promotion status in (P, T or X) then total planned equals original planned cost else equals phased accrual cost (i.e. Total Planned).
    IF rv_total_prom_amt.prom_stat_code in ('P','T','X') THEN -- Planned, Confirmed, Deleted
      v_total_phased_plnd := rv_total_prom_amt.origl_prom_cost;
      v_total_plnd := rv_total_prom_amt.origl_prom_cost;
    ELSE
      v_total_phased_plnd := rv_total_prom_amt.accrl_cost * i_pctg;
      v_total_plnd := rv_total_prom_amt.accrl_cost;
    END IF;
  END IF;
  CLOSE csr_total_prom_amt;

  -- If total phased claim is greater than total phased planned OR total claim greater total planned then promotion is overspent.
  IF (ROUND(rv_total_prom_amt.claim,0) > ROUND(v_total_phased_plnd,0)) OR (ROUND(rv_total_prom_amt.claim,0) > ROUND(v_total_plnd,0)) THEN
     o_isOverSpend := 'T';
  END IF;

  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_total_prom_amt%ISOPEN THEN
      CLOSE csr_total_prom_amt;
    END IF;
    write_log(ods_constants.data_type_prom,
              'ERROR',
              i_log_level,
              'scheduled_pmx_aggregation.check_phased_overspend: company/div/prom [' || i_company_code || '/' ||
                   i_division_code || '/' || i_prom_num || '] ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error;
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END check_phased_overspend;

FUNCTION check_phased_oi_overspend (
  i_log_level         IN ods.log.log_level%TYPE,
  i_company_code      IN pmx_prom_hdr.company_code%TYPE,
  i_division_code     IN pmx_prom_hdr.division_code%TYPE,
  i_prom_num          IN pmx_prom_hdr.prom_num%TYPE,
  i_prom_chng_date    IN pmx_prom_hdr.prom_chng_date%TYPE,
  i_pctg              IN NUMBER,
  i_prom_yyyypp       IN prom_fact.prom_yyyypp%TYPE,
  o_isOverSpend       OUT VARCHAR2
 ) RETURN NUMBER IS

  -- VARIABLE DECLARATTIONS
  v_isOverSpend BOOLEAN := FALSE;
  v_total_plnd prom_fact.phased_accrl_cost%TYPE := 0;
  v_total_phased_plnd prom_fact.phased_accrl_cost%TYPE := 0;

  -- CURSOR DECLARATIONS
  CURSOR csr_total_prom_amt IS
    SELECT
      t2.prom_stat_code,
      round(NVL(SUM((t1.whse_wthdrwl_case1_plnd * t1.whse_wthdrwl_qty_plnd) +
          (t1.xfact_case1_plnd + t1.xfact_case2_plnd) * t1.xfact_qty_plnd +
          (t1.scan_case1_plnd * t1.scan_qty_plnd) +
          (t1.coop1_plnd + t1.coop2_plnd + t1.coop3_plnd)),0),2) as origl_prom_cost,
      round(NVL(SUM((whse_wthdrwl_case_accrl * whse_wthdrwl_qty_accrl) +
          (case1_accrl + case2_accrl) * est_qty_accrl +
          (scan_qty_accrl * scan_deal_accrl) +
          (coop1_accrl + coop2_accrl + coop3_accrl)),0),2) as accrl_cost,
      round(NVL(SUM((t1.whse_wthdrwl_case1_actl * t1.whse_wthdrwl_qty_actl) +
          (t1.xfact_case1_actl + t1.xfact_case2_actl) * (t1.xfact_qty1_actl + t1.xfact_qty2_actl) +
          (t1.scan_case1_actl * t1.scan_qty_actl) +
          (t1.coop1_actl + t1.coop2_actl + t1.coop3_actl)),0),2) as claim
    FROM
      pmx_prom_dtl t1,
      pmx_prom_hdr t2
    WHERE
      t1.company_code = i_company_code
      AND t1.division_code = i_division_code
      AND t1.prom_num = i_prom_num
      AND t1.prom_chng_date = i_prom_chng_date
      AND t1.company_code = t2.company_code
      AND t1.division_code = t2.division_code
      AND t1.prom_num = t2.prom_num
      AND t1.prom_chng_date = t2.prom_chng_date
    GROUP BY
      t2.prom_stat_code;
  rv_total_prom_amt csr_total_prom_amt%ROWTYPE;

BEGIN
  o_isOverSpend := 'F';
  -- Fetch the record from the csr_total_prom_amt cursor.
  OPEN csr_total_prom_amt;
  FETCH csr_total_prom_amt INTO rv_total_prom_amt;
  IF csr_total_prom_amt%NOTFOUND THEN
    CLOSE csr_total_prom_amt;
  ELSE
    CLOSE csr_total_prom_amt;
    -- If promotion status in (P, T or X) then total planned equals original planned cost else equals phased accrual cost (i.e. Total Planned).
    IF rv_total_prom_amt.prom_stat_code in ('P','T','X') THEN -- Planned, Confirmed, Deleted
      v_total_phased_plnd := rv_total_prom_amt.origl_prom_cost;
      v_total_plnd := rv_total_prom_amt.origl_prom_cost;
    ELSE
      v_total_phased_plnd := rv_total_prom_amt.accrl_cost * i_pctg;
      v_total_plnd := rv_total_prom_amt.accrl_cost;
    END IF;
  END IF;

  -- If total phased claim is greater than total phased planned OR total claim greater total planned then promotion is overspent.
  IF (ROUND(rv_total_prom_amt.claim,0) > ROUND(v_total_phased_plnd,0)) OR (ROUND(rv_total_prom_amt.claim,0) > ROUND(v_total_plnd,0)) THEN
     o_isOverSpend := 'T';
  END IF;

  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    IF csr_total_prom_amt%ISOPEN THEN
      CLOSE csr_total_prom_amt;
    END IF;
    write_log(ods_constants.data_type_prom,
              'ERROR',
              i_log_level,
              'scheduled_pmx_aggregation.check_phased_oi_overspend: company/div/prom [' || i_company_code || '/' ||
                   i_division_code || '/' || i_prom_num || '] ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error;
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END check_phased_oi_overspend;

   /*******************************************************************/
   /* This procedure performs the period end active promotion routine */
   /*******************************************************************/
   procedure execute_period_end(par_company_code in company.company_code%type) is

      /*-*/
      /* Local variables
      /*-*/
      var_work_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_mars_this_date is
         select min(t01.calendar_date) min_date
           from mars_date t01
          where t01.mars_period = rcd_mars_date.mars_period;
      rcd_mars_this_date csr_mars_this_date%rowtype;

      cursor csr_active_promotions is
         select t01.*
           from pmx_prom_hdr t01
          where (t01.company_code,t01.division_code,t01.prom_num,prom_chng_date) in (select company_code,division_code,prom_num,max(prom_chng_date)
                                                                                       from pmx_prom_hdr
                                                                                      where company_code = par_company_code
                                                                                        and trunc(prom_chng_date) < trunc(rcd_mars_this_date.min_date)
                                                                                        and trunc(buy_start) < trunc(rcd_mars_this_date.min_date)
                                                                                      group by company_code,division_code,prom_num)
            and t01.prom_stat_code = 'S'
            and not((t01.company_code,t01.division_code,t01.prom_num) in (select company_code,division_code,prom_num
                                                                            from pmx_prom_hdr
                                                                           where company_code = par_company_code
                                                                             and trunc(prom_chng_date) = trunc(rcd_mars_this_date.min_date)));
      rcd_active_promotions csr_active_promotions%rowtype;

      cursor csr_pmx_prom_dtl is
         select t01.*
          from pmx_prom_dtl t01
         where t01.company_code = rcd_active_promotions.company_code
           and t01.division_code = rcd_active_promotions.division_code
           and t01.prom_num = rcd_active_promotions.prom_num
           and t01.prom_chng_date = var_work_date;
      rcd_pmx_prom_dtl csr_pmx_prom_dtl%rowtype;

      cursor csr_pmx_prom_profile is
         select t01.*
          from pmx_prom_profile t01
         where t01.company_code = rcd_active_promotions.company_code
           and t01.division_code = rcd_active_promotions.division_code
           and t01.prom_num = rcd_active_promotions.prom_num
           and t01.prom_chng_date = var_work_date;
      rcd_pmx_prom_profile csr_pmx_prom_profile%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current mars period based on sysdate
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         return;
      end if;
      close csr_mars_date;

      /*-*/
      /* Retrieve the current mars period day one
      /*-*/
      open csr_mars_this_date;
      fetch csr_mars_this_date into rcd_mars_this_date;
      if csr_mars_this_date%notfound then
         return;
      end if;
      close csr_mars_this_date;
      if rcd_mars_this_date.min_date is null then
         return;
      end if;

      /*-*/
      /* Retrieve the last period active promotions
      /* **notes**
      /* 1. This routine must run prior to the aggregation to ensure that
      /*    these period end timestamps are included
      /*-*/
      open csr_active_promotions;
      loop
         fetch csr_active_promotions into rcd_active_promotions;
         if csr_active_promotions%notfound then
            exit;
         end if;

         /*-*/
         /* Set the work date
         /*-*/
         var_work_date := rcd_active_promotions.prom_chng_date;

         /*-*/
         /* Set the header data
         /*-*/
         rcd_active_promotions.prom_chng_date := trunc(rcd_mars_this_date.min_date);
         rcd_active_promotions.prom_hdr_load_date := sysdate;
         rcd_active_promotions.last_userid := 'PSTR'||to_char(rcd_mars_date.mars_period,'fm000000');

         /*-*/
         /* Insert the period end header
         /*-*/
         insert into pmx_prom_hdr values rcd_active_promotions;

         /*-*/
         /* Retrieve the period end details
         /*-*/
         open csr_pmx_prom_dtl;
         loop
            fetch csr_pmx_prom_dtl into rcd_pmx_prom_dtl;
            if csr_pmx_prom_dtl%notfound then
               exit;
            end if;
            rcd_pmx_prom_dtl.prom_chng_date := trunc(rcd_mars_this_date.min_date);
            insert into pmx_prom_dtl values rcd_pmx_prom_dtl;
         end loop;
         close csr_pmx_prom_dtl;

         /*-*/
         /* Retrieve the period end profile
         /*-*/
         open csr_pmx_prom_profile;
         loop
            fetch csr_pmx_prom_profile into rcd_pmx_prom_profile;
            if csr_pmx_prom_profile%notfound then
               exit;
            end if;
            rcd_pmx_prom_profile.prom_chng_date := trunc(rcd_mars_this_date.min_date);
            insert into pmx_prom_profile values rcd_pmx_prom_profile;
         end loop;
         close csr_pmx_prom_profile;

      end loop;
      close csr_active_promotions;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_period_end;

end scheduled_pmx_aggregation;
/
