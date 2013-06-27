/* Formatted on 2013-6-27 23:48:42 (QP5 v5.163.1008.3004) */
--
-- BDS_MATL_CLSSFCTN_PACK  (View)
--

CREATE OR REPLACE FORCE VIEW BDS_APP.BDS_MATL_CLSSFCTN_PACK
(
   SAP_MATERIAL_CODE,
   PACK_FMLY_CODE,
   PACK_SUB_FMLY_CODE,
   SAP_BRAND_FLAG_CODE
)
AS
   SELECT      /*************************************************************/
          /*  Created:  09 Feb 2007                                     */
          /*    By:   Jeff Phillipson                                   */
          /*                                                            */
          /*    Ver   Date       Author       Description               */
          /*  ----- ---------- ------------------------------------     */
          /*   1.0  09/02/2007 J Phillipson Converted for snack food    */
          /*   1.1  26/04/2013 R Saini      Adjusted for new GRD codes  */
          /*                               (GRD-02233)                  */
          /*  PURPOSE                                                   */
          /* Provide a generic view of Material Classification for pack */
          /*  materials                                                 */
          /*  Note:                                                     */
          /*   This contains all requirements for all plants to date    */
          /**************************************************************/
          SAP_MATERIAL_CODE,
          t01.sap_pack_family_code AS PACK_FMLY_CODE,
          t01.sap_pack_sub_family_code AS PACK_SUB_FMLY_CODE,
          sap_brand_flag_code
     FROM BDS_MATERIAL_CLASSFCTN t01
    WHERE EXISTS
             (SELECT 'x'
                FROM bds_material_plant_mfanz t02
               WHERE t02.sap_material_code = t01.SAP_MATERIAL_CODE
                     AND t02.material_type = 'VERP')
          AND SAP_PACK_FAMILY_CODE IS NOT NULL
          AND SAP_PACK_SUB_FAMILY_CODE IS NOT NULL;


--
-- BDS_MATL_CLSSFCTN_PACK  (Synonym) 
--
CREATE OR REPLACE PUBLIC SYNONYM BDS_MATL_CLSSFCTN_PACK FOR BDS_APP.BDS_MATL_CLSSFCTN_PACK;


GRANT SELECT ON BDS_APP.BDS_MATL_CLSSFCTN_PACK TO APPSUPPORT;

GRANT SELECT ON BDS_APP.BDS_MATL_CLSSFCTN_PACK TO PKGSPEC;

GRANT SELECT ON BDS_APP.BDS_MATL_CLSSFCTN_PACK TO PKGSPEC_APP;
