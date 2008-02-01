CREATE OR REPLACE FORCE VIEW DW_APP.SAP_MAX_MIN_BILLING_DATE
   (PERIOD_DAY_NUM,
    MIN_BILLING_DATE,
    MAX_BILLING_DATE,
    MIN_YYYYMMDD_DATE,
    MAX_YYYYMMDD_DATE, 
    MIN_YYYYMM_DATE,
    MAX_YYYYMM_DATE,
    MIN_YYYYPPDD_DATE,
    MAX_YYYYPPDD_DATE,
    MIN_YYYYPP_DATE, 
    MAX_YYYYPP_DATE) AS 
   SELECT TTTT1.PERIOD_DAY_NUM,
          TTTT1.MIN_BILLING_DATE,
          TTTT1.MAX_BILLING_DATE,
          TO_NUMBER(TO_CHAR(TTTT1.MIN_BILLING_DATE,'YYYYMMDD')) AS MIN_YYYYMMDD_DATE,
          TO_NUMBER(TO_CHAR(TTTT1.MAX_BILLING_DATE,'YYYYMMDD')) AS MAX_YYYYMMDD_DATE,
          TO_NUMBER(TO_CHAR(TTTT1.MIN_BILLING_DATE,'YYYYMM')) AS MIN_YYYYMM_DATE,
          TO_NUMBER(TO_CHAR(TTTT1.MAX_BILLING_DATE,'YYYYMM')) AS MAX_YYYYMM_DATE,
          TTTT1.MIN_YYYYPPDD_DATE,
          TTTT2.MARS_YYYYPPDD AS MAX_YYYYPPDD_DATE,
          TRUNC(TTTT1.MIN_YYYYPPDD_DATE/100) AS MIN_YYYYPP_DATE,
          TRUNC(TTTT2.MARS_YYYYPPDD/100) AS MAX_YYYYPP_DATE
     FROM (SELECT TTT1.PERIOD_DAY_NUM,
                  TTT1.MIN_BILLING_DATE,
                  TTT1.MAX_BILLING_DATE,
                  TO_NUMBER(TO_CHAR(TTT1.MIN_BILLING_DATE,'YYYYMMDD')) AS MIN_YYYYMMDD_DATE,
                  TO_NUMBER(TO_CHAR(TTT1.MAX_BILLING_DATE,'YYYYMMDD')) AS MAX_YYYYMMDD_DATE,
                  TTT2.MARS_YYYYPPDD AS MIN_YYYYPPDD_DATE
             FROM (SELECT TT1.PERIOD_DAY_NUM,
                          TT1.MIN_BILLING_DATE,
                          TT1.MAX_BILLING_DATE,
                          TO_NUMBER(TO_CHAR(TT1.MIN_BILLING_DATE,'YYYYMMDD')) AS MIN_YYYYMMDD_DATE,
                          TO_NUMBER(TO_CHAR(TT1.MAX_BILLING_DATE,'YYYYMMDD')) AS MAX_YYYYMMDD_DATE
                     FROM (SELECT T1.PERIOD_DAY_NUM,
                                  DECODE(TO_NUMBER(TO_CHAR(T1.CALENDAR_DATE,'D')), 7, (SELECT MAX(DD.SALES_FACT.SAP_BILLING_DATE) FROM DD.SALES_FACT WHERE SAP_BILLING_DATE < TRUNC(T1.CALENDAR_DATE)),
                                                                                      T1.CALENDAR_DATE) AS MIN_BILLING_DATE,
                                  T1.CALENDAR_DATE AS MAX_BILLING_DATE
                             FROM (SELECT PERIOD_DAY_NUM, 
                                          CALENDAR_DATE, 
                                          CALENDAR_DATE AS MIN_DATE,
                                          CALENDAR_DATE AS MAX_DATE
                                     FROM MM.MARS_DATE
                                    WHERE CALENDAR_DATE = (SELECT MAX(DD.SALES_FACT.SAP_BILLING_DATE) AS MAX_BILLING_DATE FROM DD.SALES_FACT WHERE SAP_BILLING_DATE < TRUNC(SYSDATE))
                                  ) T1
                          ) TT1
                  ) TTT1,
                  MM.MARS_DATE TTT2
            WHERE TTT1.MIN_YYYYMMDD_DATE = TTT2.YYYYMMDD_DATE
          ) TTTT1,
          MM.MARS_DATE TTTT2
    WHERE TTTT1.MAX_YYYYMMDD_DATE = TTTT2.YYYYMMDD_DATE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.sap_max_min_billing_date to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym sap_max_min_billing_date for dw_app.sap_max_min_billing_date;


