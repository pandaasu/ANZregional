DROP VIEW MANU.REF_PLANT;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.ref_plant (plant, plant_name)
AS
  SELECT       /*************************************************************/
              /*  Created:  09 Feb 2007                                     */
              /*    By:   Jeff Phillipson                                   */
              /*                                                            */
              /*    Ver   Date       Author       Description               */
              /*  ----- ---------- ------------------------------------     */
              /*   1.0  09/02/2007 J Phillipson Converted for snack food    */
              /*  PURPOSE                                                   */
              /* Provide a generic view of Plant data                       */
              /*  Note:                                                     */
              /*                                                            */
              /**************************************************************/
         plant_code plant, plant_name
    FROM bds_refrnc_plant
   WHERE plant_country_key = 'AU';


DROP PUBLIC SYNONYM REF_PLANT;

CREATE PUBLIC SYNONYM REF_PLANT FOR MANU.REF_PLANT;


GRANT SELECT ON MANU.REF_PLANT TO MANU_APP;

