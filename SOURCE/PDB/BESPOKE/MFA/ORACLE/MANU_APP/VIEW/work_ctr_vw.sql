DROP VIEW MANU_APP.WORK_CTR_VW;

/* Formatted on 2008/09/05 10:49 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.work_ctr_vw (work_ctr_code,
                                                   resource_desc,
                                                   plant_code,
                                                   resource_code,
                                                   work_ctr_type_code
                                                  )
AS
  SELECT    '300'
         || SUBSTR (resource_code, LENGTH (resource_code) - 2, 3)
                                                                work_ctr_code,
         resource_desc, plant plant_code, resource_code,
         'ATLAS' work_ctr_type_code
    FROM ref_resource
   WHERE resource_code <> 'DURATION'
  UNION
  SELECT RTRIM (work_ctr_code) work_ctr_code, work_ctr_name,
         DECODE (plant_code, '230       ', 'AU10', plant_code), 'NONE',
         work_ctr_type_code
    FROM work_ctr
   WHERE eff_ind = 'Y';


DROP PUBLIC SYNONYM WORK_CTR_VW;

CREATE PUBLIC SYNONYM WORK_CTR_VW FOR MANU_APP.WORK_CTR_VW;


GRANT SELECT ON MANU_APP.WORK_CTR_VW TO CL_APP;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO MANU_USER;

GRANT SELECT ON MANU_APP.WORK_CTR_VW TO PT_APP WITH GRANT OPTION;

