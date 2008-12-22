DROP VIEW MANU.MATL_CLSSFCTN_RAW;

/* Formatted on 2008/12/22 10:59 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_clssfctn_raw (matl_code,
                                                     raw_family_code,
                                                     raw_sub_family_code,
                                                     raw_group_code,
                                                     animal_parts_code,
                                                     physical_condtn_code
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
              /* Provide a generic view of Material Classification for RAWS */
              /*  Note:                                                     */
              /*   This contains all requirements for all plants to date    */
              /**************************************************************/
         LTRIM (sap_material_code, '0') matl_code,
         sap_raw_family_code raw_family_code,
         sap_raw_sub_family_code raw_sub_family_code,
         sap_raw_group_code raw_group_code,
         sap_animal_parts_code animal_parts_code,
         sap_physical_condtn_code physical_condtn_code
    FROM bds_material_classfctn t01
   WHERE EXISTS (
           SELECT 'x'
             FROM bds_material_plant_mfanz t02
            WHERE t02.sap_material_code = LTRIM (t01.sap_material_code, '0')
              AND t02.material_type = 'ROH');


DROP PUBLIC SYNONYM MATL_CLSSFCTN_RAW;

CREATE PUBLIC SYNONYM MATL_CLSSFCTN_RAW FOR MANU.MATL_CLSSFCTN_RAW;


GRANT SELECT ON MANU.MATL_CLSSFCTN_RAW TO MANU_APP WITH GRANT OPTION;

