DROP VIEW MANU.REF_RAW_FMLY;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_raw_fmly (raw_fmly_code,
                                                raw_fmly_long_desc
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
              /* Provide a generic view of BRaw Family data                 */
              /*  Note:                                                     */
              /* '/MARS/MD_ROH01' is the atlas code for Raw Family          */
              /**************************************************************/
         t01.sap_charistic_value_code AS code,
         t01.sap_charistic_value_long_desc AS long_desc
    FROM bds_refrnc_charistic t01
   WHERE t01.sap_charistic_code = '/MARS/MD_ROH01';


DROP PUBLIC SYNONYM REF_RAW_FMLY;

CREATE PUBLIC SYNONYM REF_RAW_FMLY FOR MANU.REF_RAW_FMLY;


GRANT SELECT ON MANU.REF_RAW_FMLY TO MANU_APP WITH GRANT OPTION;

