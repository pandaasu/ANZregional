/* Formatted on 2013-6-27 23:50:15 (QP5 v5.163.1008.3004) */
--
-- BDS_PACK_FMLY  (View)
--

CREATE OR REPLACE FORCE VIEW BDS_APP.BDS_PACK_FMLY
(
   PACK_FMLY_CODE,
   PACK_FMLY_LONG_DESC
)
AS
   SELECT t01.sap_charistic_value_code AS code,
          t01.sap_charistic_value_long_desc AS long_desc
     FROM BDS_REFRNC_CHARISTIC t01
    WHERE t01.sap_charistic_code = '/MARS/MD_VERP01';


--
-- BDS_PACK_FMLY  (Synonym) 
--
CREATE OR REPLACE PUBLIC SYNONYM BDS_PACK_FMLY FOR BDS_APP.BDS_PACK_FMLY;


GRANT SELECT ON BDS_APP.BDS_PACK_FMLY TO APPSUPPORT;

GRANT SELECT ON BDS_APP.BDS_PACK_FMLY TO MANU WITH GRANT OPTION;

GRANT SELECT ON BDS_APP.BDS_PACK_FMLY TO PKGSPEC WITH GRANT OPTION;

GRANT SELECT ON BDS_APP.BDS_PACK_FMLY TO PKGSPEC_APP WITH GRANT OPTION;
