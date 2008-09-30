DROP VIEW MANU_APP.WORK_CTR_VW;

/* Formatted on 2008/10/01 09:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.work_ctr_vw (work_ctr_code,
                                                   resrce_desc,
                                                   plant_code,
                                                   resrce_code,
                                                   work_ctr_type_code,
                                                   resource_desc
                                                  )
AS
  SELECT RTRIM (work_ctr_code) work_ctr_code, work_ctr_name resrce_desc,
         DECODE (RTRIM (plant_code),
                 '1000', 'AU20',
                 '1001', 'AU21',
                 '2000', 'AU30',
                 '1002', 'AU22',
                 '1015', 'AU23',
                 'AU25', 'AU25'
                ) plant_code,
         'NONE' resrce_code, work_ctr_type_code, work_ctr_name resource_desc
    FROM work_ctr
   WHERE eff_ind = 'Y' AND LENGTH (RTRIM (work_ctr_code)) > 1;


DROP PUBLIC SYNONYM WORK_CTR_VW;

CREATE PUBLIC SYNONYM WORK_CTR_VW FOR MANU_APP.WORK_CTR_VW;


GRANT SELECT ON MANU_APP.WORK_CTR_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO CITSRV1 WITH GRANT OPTION;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO PR_USER;

