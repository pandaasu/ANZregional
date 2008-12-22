DROP VIEW MANU.REF_PRDCT_CTGRY;

/* Formatted on 2008/12/22 10:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_prdct_ctgry (prdct_ctgry_code,
                                                   prdct_ctgry_short_desc,
                                                   prdct_ctgry_long_desc
                                                  )
AS
  SELECT       /*************************************************************/
              /*  Created:  09 Feb 2007                                     */
              /*    By:   Jeff Phillipson                                   */
              /*                                                            */
              /*    Ver   Date       Author       Description               */
              /*  ----- ---------- ------------------------------------     */
              /*   1.0  09/02/2007 J Phillipson Converted for snack food    */
              /*  PURPOSE                                                   */
              /* Provide a generic view of Product Category data            */
              /*  Note:                                                     */
              /* '/MARS/MD_CHC012' is the atlas code for Product Category   */
              /**************************************************************/
         t01.sap_charistic_value_code AS code,
         t01.sap_charistic_value_shrt_desc AS short_desc,
         t01.sap_charistic_value_long_desc AS long_desc
    FROM bds_refrnc_charistic t01
   WHERE t01.sap_charistic_code = '/MARS/MD_CHC012';


DROP PUBLIC SYNONYM REF_PRDCT_CTGRY;

CREATE PUBLIC SYNONYM REF_PRDCT_CTGRY FOR MANU.REF_PRDCT_CTGRY;


GRANT SELECT ON MANU.REF_PRDCT_CTGRY TO MANU_APP WITH GRANT OPTION;

