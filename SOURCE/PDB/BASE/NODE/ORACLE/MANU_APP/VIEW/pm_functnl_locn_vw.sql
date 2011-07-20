/* Formatted on 15-Jul-2011 11:30:03 AM (QP5 v5.139.911.3011) */
CREATE OR REPLACE FORCE VIEW MANU_APP.PM_FUNCTNL_LOCN_VW
(
   FUNCTNL_LOCN_CODE,
   FUNCTNL_LOCN_DESC,
   SORT_FIELD,
   PARENT_FUNCTNL_LOCN_CODE,
   PLANT_CODE
)
AS
   SELECT functnl_locn_code,
          functnl_locn_desc,
          sort_field,
          SUBSTR (functnl_locn_code, 1, INSTR (functnl_locn_code,
                                               '-',
                                               -1,
                                               1)
                                        - 1)
             AS parent_functnl_locn_code,
          plant_code
     FROM bds_functnl_locn_hdr;

COMMENT ON TABLE MANU_APP.PM_FUNCTNL_LOCN_VW IS 'Plant Maintenance Functional Locations';

COMMENT ON COLUMN MANU_APP.PM_FUNCTNL_LOCN_VW.FUNCTNL_LOCN_CODE IS 'Functional Location (IFLO-TPLNR)';

COMMENT ON COLUMN MANU_APP.PM_FUNCTNL_LOCN_VW.FUNCTNL_LOCN_DESC IS 'Functional Location Description (IFLO-PLTXT)';

COMMENT ON COLUMN MANU_APP.PM_FUNCTNL_LOCN_VW.SORT_FIELD IS 'Sort Field (ITOB-EQFNR)';

COMMENT ON COLUMN MANU_APP.PM_FUNCTNL_LOCN_VW.PARENT_FUNCTNL_LOCN_CODE IS 'Parent Functional Location Code (calculated)';

COMMENT ON COLUMN MANU_APP.PM_FUNCTNL_LOCN_VW.PLANT_CODE IS 'Plant Code (calculated in the hub)';


CREATE PUBLIC SYNONYM PM_FUNCTNL_LOCN_VW FOR MANU_APP.PM_FUNCTNL_LOCN_VW;


GRANT SELECT ON MANU_APP.PM_FUNCTNL_LOCN_VW TO APPSUPPORT;

GRANT SELECT ON MANU_APP.PM_FUNCTNL_LOCN_VW TO MANU_MAINT;

GRANT SELECT ON MANU_APP.PM_FUNCTNL_LOCN_VW TO MANU_USER;
