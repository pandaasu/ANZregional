CREATE OR REPLACE PACKAGE BODY FPPS_EXTRACT IS

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

PROCEDURE RUN_SALES_EXTRACT(pc_extract_date in VARCHAR2) IS

  --VARIABLE DECLARATION
  v_data CONSTANTS.MESSAGE_STRING;
  v_processing_msg CONSTANTS.MESSAGE_STRING;
  v_result_msg CONSTANTS.MESSAGE_STRING;
  v_status NUMBER;
  v_rec_count NUMBER := 0;
  v_log_level NUMBER;
  v_this_period NUMBER;
  v_mfj_sales_date NUMBER(8);
  v_org_reg_desc VARCHAR2(75);
  var_item VARCHAR2(18);

  var_instance number(15,0); -- 17/07/2005 (ICS/LADS install)
  var_log_prefix varchar2(256); -- 17/07/2005 (ICS/LADS install)
  var_log_search varchar2(256); -- 17/07/2005 (ICS/LADS install)

  --EXCEPTIONS DECALRATIONS
  e_processing_error EXCEPTION;
  e_processing_failure EXCEPTION;

  --CURSOR DECLARATION
  -- Unsure how great the risk of getting BCP with zero volume and zero list price.
  -- May need to re-write if this occurs.

  CURSOR csr_sales IS
   SELECT
     G.SAP_MATERIAL_CODE AS ITEM,
     'SOURCE' AS SOURCE, -- As source provided and maintained in FPPS.
     UPPER(SUBSTR((DECODE(C.CUST_NAME_EN_LEVEL_1, NULL, 'Not Applicable', RTRIM(C.CUST_NAME_EN_LEVEL_1)) || ' - ' ||
     DECODE(C.CUST_NAME_EN_LEVEL_2, NULL, 'Not Applicable', RTRIM(C.CUST_NAME_EN_LEVEL_2))),1,40)) AS DESTINATION,  -- SALES DIVISION / REGION
     '3404' AS CUSTOMER,
     B.MARS_YEAR AS YYYY,
     SUBSTR(TO_CHAR(B.MARS_PERIOD),5,2) AS PP,
     DECODE(SUM(A.SALES_DTL_PRICE_VALUE_2),0,(sign(SUM(A.BILLED_QTY))*1),SUM(A.SALES_DTL_PRICE_VALUE_2)) AS LIST_PRICE,
     DECODE(SUM(A.BILLED_QTY),0,(sign(SUM(A.SALES_DTL_PRICE_VALUE_2))*1),SUM(A.BILLED_QTY)) AS VOLUME,
     DECODE(SUM(A.SALES_DTL_PRICE_VALUE_3),0,NULL,SUM(A.SALES_DTL_PRICE_VALUE_3)) AS BCP,
     'JPY' AS CURRENCY
   FROM
     SALES_FACT A,
     MATERIAL_DIM G,
     MARS_DATE B,
     SALES_FORCE_GEO_HIER C,
     SALES_ORG_DIM D,
     DISTBN_CHNL_DIM E,
     DIVISION_DIM F
   WHERE
     A.SAP_MATERIAL_CODE = G.SAP_MATERIAL_CODE(+)                     -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_BILLING_DATE = B.CALENDAR_DATE(+)
     AND A.SAP_SALES_FORCE_HIER_CUST_CODE = C.SAP_HIER_CUST_CODE(+)   -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_SALES_DTL_SALES_ORG_CODE = C.SAP_SALES_ORG_CODE(+)     -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_SALES_DTL_DIVISION_CODE = C.SAP_DIVISION_CODE(+)       -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_SALES_DTL_DISTBN_CHNL_CODE = C.SAP_DISTBN_CHNL_CODE(+) -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_SALES_DTL_SALES_ORG_CODE = D.SAP_SALES_ORG_CODE(+)     -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_SALES_DTL_DISTBN_CHNL_CODE = E.SAP_DISTBN_CHNL_CODE(+) -- 17/07/2005 Changed column names (ICS/LADS install)
     AND A.SAP_SALES_DTL_DIVISION_CODE = F.SAP_DIVISION_CODE(+)       -- 17/07/2005 Changed column names (ICS/LADS install)
     AND SUBSTR(TO_CHAR(A.SAP_BILLING_YYYYPPDD),1,6) = pc_extract_date -- From user input
     AND ((D.SAP_SALES_ORG_CODE='131' AND F.SAP_DIVISION_CODE='51' AND E.SAP_DISTBN_CHNL_CODE='11')  --- MFJ - PETCARE   - GROCERY
     OR  (D.SAP_SALES_ORG_CODE='131' AND F.SAP_DIVISION_CODE='51' AND E.SAP_DISTBN_CHNL_CODE='20')  --- MFJ - PETCARE   - PET SPECIALIST
     OR  (D.SAP_SALES_ORG_CODE='131' AND F.SAP_DIVISION_CODE='51' AND E.SAP_DISTBN_CHNL_CODE='10')  --- MFJ - SNACKFOOD - NON-SPECIFIC
     OR  (D.SAP_SALES_ORG_CODE='131' AND F.SAP_DIVISION_CODE='57' AND E.SAP_DISTBN_CHNL_CODE='10')) --- MFJ - FOOD      - NON-SPECIFIC
   GROUP BY
     G.SAP_MATERIAL_CODE,
     C.CUST_NAME_EN_LEVEL_1,
     C.CUST_NAME_EN_LEVEL_2,
     B.MARS_YEAR,
     B.MARS_PERIOD
   HAVING
     (SUM(A.SALES_DTL_PRICE_VALUE_2) <> 0 OR SUM(A.BILLED_QTY) <> 0 OR SUM(A.SALES_DTL_PRICE_VALUE_4) <> 0);

BEGIN

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_FPPS_EXTRACT';
      var_log_search := 'DW_FPPS_EXTRACT';

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FPPS Period Sales Extract - Parameters(' || pc_extract_date || ')');

      /*-*/
      /* Begin procedure -- 17/07/2005 (ICS/LADS install)
      /*-*/
      lics_logging.write_log('Begin - FPPS Period Sales Extract - Create interface');

      /*-*/
      /* Create the new interface -- 17/07/2005 (ICS/LADS install)
      /*-*/
      var_instance := lics_outbound_loader.create_interface('ICSFPS01','mfj_clio_prd_sales.csv');

      /*-*/
      /* Output header -- 17/07/2005 (ICS/LADS install)
      /*-*/
      lics_outbound_loader.append_data('[ File created on ' || TO_CHAR(SYSDATE,'DD-MON-YYYY') || ' at ' || TO_CHAR(SYSDATE,'HH24:MI:SS') || ' ]');

--  v_mfj_sales_date := to_number(pc_extract_date);

  -- Open the SALES Cursor
  FOR recs in csr_sales LOOP
    BEGIN
      v_rec_count := v_rec_count + 1;

      ---------------------------------------------
      -- 17/07/2005 Modification (ICS/LADS install)
      -- Left pad numeric material codes to 8 long
      ---------------------------------------------
      var_item := recs.item;
      begin
         var_item := to_char(to_number(recs.item),'fm00000000');
      exception
         when others then
            null;
      end;

      -- Format sales data
	  v_data := var_item || ',' ||
	  recs.source || ',' ||
	  recs.destination || ',' ||
	  recs.customer || ',' ||
	  recs.yyyy || ',' ||
	  recs.pp || ',' ||
	  recs.list_price || ',' ||
	  recs.volume || ',' ||
	  recs.bcp || ',' ||
	  recs.currency;

      /*-*/
      /* Output header -- 17/07/2005 (ICS/LADS install)
      /*-*/
      lics_outbound_loader.append_data(v_data);

      EXCEPTION
      WHEN OTHERS THEN
        v_processing_msg := 'Could not open SALES cursor.';
      RAISE e_processing_failure;
    END;
  END LOOP;

      /*-*/
      /* Write log -- 17/07/2005 (ICS/LADS install)
      /*-*/
      lics_logging.write_log('Records Extracted: ' || v_rec_count);

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FPPS Period Sales Extract - Create Interface');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

EXCEPTION

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - FPPS Period Sales Extract - Create interface - ' || substr(SQLERRM, 1, 1024));
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR** - FPPS Period Sales Extract - Create interface - ' || substr(SQLERRM, 1, 1024));

END RUN_SALES_EXTRACT;

END FPPS_EXTRACT;
/


create or replace public synonym fpps_extract for dw_app.fpps_extract;
grant execute on fpps_extract to public;
