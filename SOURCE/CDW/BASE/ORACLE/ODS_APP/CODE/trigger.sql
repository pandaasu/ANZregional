create or replace TRIGGER SAP_SAL_ORD_GEN_UPDT
/*********************************************************************************
 DESCRIPTION:
  Updates sap_sal_ord_hdr_lupdp and sal_sal_ord_hdr_lupdt columns in
  sap_sal_ord_hdr(header) table whenever a new record in added or updated
  in sap_sal_ord_gen(detail) table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   Jan 2007   Paul Jacobs          Created the Trigger.

*********************************************************************************/
BEFORE INSERT OR UPDATE
ON ods.sap_sal_ord_gen
FOR EACH ROW
DECLARE
  v_company_code varchar2(3) := NULL;
  v_lupdt DATE := NULL;
  v_lupdp VARCHAR2(8) := NULL;

  -- cursor
  CURSOR csr_company_code is
   SELECT
      orgid
    FROM
      sap_sal_ord_org
    WHERE
      qualf = ods_constants.sales_order_sales_org
      AND belnr = :new.belnr;

  BEGIN
    OPEN csr_company_code;
    FETCH csr_company_code INTO v_company_code;
    CLOSE csr_company_code;
    v_lupdt :=
      CASE v_company_code
        WHEN ods_constants.company_australia THEN sysdate
        WHEN ods_constants.company_new_zealand THEN ods_app.utils.tz_conv_date_time(SYSDATE, ods_constants.db_timezone, 'NZ')
        ELSE sysdate
      END;
    v_lupdp := USER;

    UPDATE sap_sal_ord_hdr
    SET sap_sal_ord_hdr_lupdt = v_lupdt,
        sap_sal_ord_hdr_lupdp = v_lupdp
    WHERE belnr = :new.belnr;
  END;
