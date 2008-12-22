DROP VIEW MANU.REF_PACK_SUB_FMLY;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_pack_sub_fmly (pack_sub_fmly_code,
                                                     pack_sub_fmly_long_desc
                                                    )
AS
  SELECT t01.sap_charistic_value_code AS code,
         t01.sap_charistic_value_long_desc AS long_desc
    FROM bds_refrnc_charistic t01
   WHERE t01.sap_charistic_code = '/MARS/MD_VERP02';


DROP PUBLIC SYNONYM REF_PACK_SUB_FMLY;

CREATE PUBLIC SYNONYM REF_PACK_SUB_FMLY FOR MANU.REF_PACK_SUB_FMLY;


GRANT SELECT ON MANU.REF_PACK_SUB_FMLY TO MANU_APP WITH GRANT OPTION;

