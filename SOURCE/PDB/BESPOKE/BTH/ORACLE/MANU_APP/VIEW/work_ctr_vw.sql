DROP VIEW MANU_APP.WORK_CTR_VW;

/* Formatted on 2008/12/22 10:14 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.work_ctr_vw (work_ctr_code,
                                                   resrce_desc,
                                                   plant_code,
                                                   resrce_code,
                                                   work_ctr_type_code
                                                  )
AS
  SELECT RTRIM (work_ctr_code) work_ctr_code, work_ctr_name,
         DECODE (RTRIM (plant_code), '2000', 'AU30') plant_code, 'NONE',
         work_ctr_type_code
    FROM work_ctr
   WHERE eff_ind = 'Y';


DROP PUBLIC SYNONYM WORK_CTR_VW;

CREATE PUBLIC SYNONYM WORK_CTR_VW FOR MANU_APP.WORK_CTR_VW;


GRANT SELECT ON MANU_APP.WORK_CTR_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO BTHSUPPORT;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO CITECT_USER;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO SITESUPPORT WITH GRANT OPTION;

