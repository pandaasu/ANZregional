DROP VIEW MANU_APP.AUTOMATION_LIQUID_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.automation_liquid_vw (proc_order,
                                                            operation,
                                                            phase,
                                                            seq,
                                                            box_no
                                                           )
AS
  SELECT "PROC_ORDER", "OPERATION", "PHASE", "SEQ", "BOX_NO"
    FROM automation_liquid;


DROP PUBLIC SYNONYM AUTOMATION_LIQUID_VW;

CREATE PUBLIC SYNONYM AUTOMATION_LIQUID_VW FOR MANU_APP.AUTOMATION_LIQUID_VW;


GRANT SELECT ON MANU_APP.AUTOMATION_LIQUID_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.AUTOMATION_LIQUID_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.AUTOMATION_LIQUID_VW TO PT_APP WITH GRANT OPTION;

