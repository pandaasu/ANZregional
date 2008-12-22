DROP VIEW MANU.REF_BRAND_FLAG;

/* Formatted on 2008/12/22 11:01 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_brand_flag (brand_flag_code,
                                                  brand_flag_short_desc,
                                                  brand_flag_long_desc
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
              /* Provide a generic view of Brand Flag data                  */
              /*  Note:                                                     */
              /* '/MARS/MD_CHC003' is the atlas code for Brand Flag         */
              /**************************************************************/
         t01.sap_charistic_value_code AS code,
         t01.sap_charistic_value_shrt_desc AS short_desc,
         t01.sap_charistic_value_long_desc AS long_desc
    FROM bds_refrnc_charistic t01
   WHERE t01.sap_charistic_code = '/MARS/MD_CHC003';


DROP PUBLIC SYNONYM REF_BRAND_FLAG;

CREATE PUBLIC SYNONYM REF_BRAND_FLAG FOR MANU.REF_BRAND_FLAG;


GRANT SELECT ON MANU.REF_BRAND_FLAG TO MANU_APP WITH GRANT OPTION;

