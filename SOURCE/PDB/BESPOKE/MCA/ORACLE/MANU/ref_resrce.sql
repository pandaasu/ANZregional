DROP VIEW MANU.REF_RESRCE;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_resrce (resrce_code,
                                              resrce_desc,
                                              plant,
                                              upd_datime
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
              /* Provide a generic view of Plant Resource data              */
              /*  Note:                                                     */
              /*                                                            */
              /**************************************************************/
         resrc_code resrce_code, resrc_text resrce_desc,
         resrc_plant_code plant, NULL upd_datime
    FROM bds_prodctn_resrc_en
   WHERE resrc_plant_code = 'AU40';


DROP PUBLIC SYNONYM REF_RESRCE;

CREATE PUBLIC SYNONYM REF_RESRCE FOR MANU.REF_RESRCE;


GRANT SELECT ON MANU.REF_RESRCE TO MANU_APP WITH GRANT OPTION;

