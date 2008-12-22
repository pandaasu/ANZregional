DROP VIEW MANU.MATL_CLSSFCTN_PACK;

/* Formatted on 2008/12/22 11:00 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_clssfctn_pack (matl_code,
                                                      pack_family_code,
                                                      pack_sub_family_code
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
              /* Provide a generic view of Material Classification for pack */
              /*  materials                                                 */
              /*  Note:                                                     */
              /*   This contains all requirements for all plants to date    */
              /**************************************************************/
         LTRIM (sap_material_code, '0') matl_code,
         sap_pack_family_code pack_family_code,
         sap_pack_sub_family_code pack_sub_family_code
    FROM bds_material_classfctn t01
   WHERE EXISTS (
           SELECT 'x'
             FROM bds_material_plant_mfanz t02
            WHERE t02.sap_material_code = LTRIM (t01.sap_material_code, '0')
              AND t02.material_type = 'VERP');


DROP PUBLIC SYNONYM MATL_CLSSFCTN_PACK;

CREATE PUBLIC SYNONYM MATL_CLSSFCTN_PACK FOR MANU.MATL_CLSSFCTN_PACK;


GRANT SELECT ON MANU.MATL_CLSSFCTN_PACK TO MANU_APP WITH GRANT OPTION;

