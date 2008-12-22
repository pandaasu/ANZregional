DROP VIEW MANU.REF_MKT_SGMNT;

/* Formatted on 2008/12/22 10:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_mkt_sgmnt (mkt_sgmnt_code,
                                                 mkt_sgmnt_short_desc,
                                                 mkt_sgmnt_long_desc
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
              /* Provide a generic view of Market Segment data              */
              /*  Note:                                                     */
              /* /MARS/MD_CHC002' is the atlas code for Market Segment      */
              /**************************************************************/
         t01.sap_charistic_value_code AS code,
         t01.sap_charistic_value_shrt_desc AS short_desc,
         t01.sap_charistic_value_long_desc AS long_desc
    FROM bds_refrnc_charistic t01
   WHERE t01.sap_charistic_code = '/MARS/MD_CHC002';


DROP PUBLIC SYNONYM REF_MKT_SGMNT;

CREATE PUBLIC SYNONYM REF_MKT_SGMNT FOR MANU.REF_MKT_SGMNT;


GRANT SELECT ON MANU.REF_MKT_SGMNT TO MANU_APP WITH GRANT OPTION;

