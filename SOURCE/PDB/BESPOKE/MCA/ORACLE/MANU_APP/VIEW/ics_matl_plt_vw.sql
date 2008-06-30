DROP VIEW MANU_APP.ICS_MATL_PLT_VW;

/* Formatted on 2008/06/30 14:33 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu_app.ics_matl_plt_vw (matl_code,
                                                       plant,
                                                       plant_sts_start,
                                                       units_per_case_date,
                                                       apn,
                                                       units_per_case,
                                                       inners_per_case_date,
                                                       inners_per_case,
                                                       pi_start_date,
                                                       pi_end_date,
                                                       pllt_gross_wght,
                                                       crtns_per_pllt,
                                                       crtns_per_layer,
                                                       uom_qty
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
              /* Provide a generic view of Material Packaging data          */
              /*  Note:                                                     */
              /*   This contains all requirements for all plants to date    */
              /**************************************************************/
         LTRIM (t01.sap_material_code, '0') matl_code, t01.plant_code plant,
         t01.plant_specific_status_valid plant_sts_start,
         t03.bom_eff_date units_per_case_date, t03.child_ian apn,
         t03.child_per_parent units_per_case,
         t04.bom_eff_date inners_per_case_date,
         t04.child_per_parent inners_per_case,
         t02.pkg_instr_start_date pi_start_date,
         t02.pkg_instr_end_date pi_end_date,
         t02.hu_total_weight pllt_gross_wght, t02.target_qty crtns_per_pllt,
         t02.rounding_qty crtns_per_layer, t02.uom uom_qty
    FROM (SELECT t01.*, t02.plant_sales_organisation
            FROM bds_material_plant_mfanz_test t01, bds_refrnc_plant t02
           WHERE t01.plant_code = t02.plant_code) t01,
         bds_material_pkg_instr_det_t t02,
         (SELECT *
            FROM bds_material_bom_all_ics
           WHERE (parent_tdu_flag = 'X' OR parent_intr_flag = 'X')
             AND child_rsu_flag = 'X'
             AND bom_usage = '5') t03,
         (SELECT *
            FROM bds_material_bom_all_ics
           WHERE (parent_tdu_flag = 'X' OR parent_intr_flag = 'X')
             AND child_mcu_flag = 'X'
             AND bom_usage = '1') t04
   WHERE t01.sap_material_code = t02.sap_material_code(+)
     AND t01.sap_material_code = t03.parent_material_code
     AND t01.sap_material_code = t04.parent_material_code(+)
     /* sales organisation code 147 Aus, 149 NZ from plant table */
     AND t01.plant_sales_organisation = t02.sales_organisation(+)
     /* get the package instructions valid for now */
     AND t02.pkg_instr_start_date(+) <= SYSDATE
     AND t02.pkg_instr_end_date(+) >= SYSDATE
     /* only get valid material codes */
     --AND t01.plant_specific_status = '20'
     --AND t01.xplant_status = '10'
     /* slecify only plants required for this site */
     AND t01.plant_code = 'AU40';


