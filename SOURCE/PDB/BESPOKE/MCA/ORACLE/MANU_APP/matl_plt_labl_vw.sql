create or replace force view manu_app.matl_plt_labl_vw as
/****************************************************************/
/*    NAME:      MATL_PLT_LABL_VW                                                                   */
/*    PURPOSE:   Combines the required information into one view that is required for               */
/*        the inbound and outbound pallet labels.                                                   */
/*        Replaces PET_MATL_PLT_LABL and PET_MATL_PLT_LABL_VW                                       */
/*    REVISIONS:                                                                                    */
/*    Ver   Date       Author               Description                                             */
/*    ----- ---------- -------------------- ----------------------------------------                */
/*    1.0   07/03/2006  Jasmina Drew          Created this view                                     */
/*    1.1  26/04/2006   Jasmina Drew           Added decode to change UOM                           */
/*                      (EA=EA, KGM=KG, MTR=M)                                                      */
/*    1.2  14/07/2006   Jeff Phillipson       plants added - AU15 and AU16                          */
/*    1.3  27/07/2006   Jasmina Drew          Removed plant join from inbound query to              */
/*                                           remove blank row coming back                           */
/*    1.4  29/08/2006   Jasmina Drew          Added padding to 13 length EAN codes                  */
/*    1.5  23/10/2006   Jeff Phillipson       Added extra criterea to select only CS from           */
/*                                           pet_all_matl_pllt table                                */
/*    1.6 17/11/2006    Jeff Phillipson    converted view for Snack                                 */
/*    1.7 05-JUL-2007   Scott R. Harding    Moved to manu_app and removed 'pet' prefix              */
/*    1.8 22-Oct-2007   Jeff Phillipson     changed the ROH and package section to get vendors      */
/*    1.9 16-Nov-2007   Liam Watson         changed to use only currently active packaging          */
/*                                          instructions for sales org 147 (australia)              */
/*    2.0 13-Mar-2008   Liam Watson         Changed to generic view that contains data for all      */
/*                                          units.  No longer Snack specific.  New SQL provided     */
/*                                          by Scott Harding.                                       */
/*    2.1 19-Jun-2008   Liam Watson         Changed shelf_life to max_storage_period for ROH & VERP */
/*    2.2 30-Jun-2008   Liam Watson         Changed to filter by sales org (147 - australia)        */
/*                                          for FG. Needed to prevent pallet tagging                */
/*                                          app from using case quantities as setup for NZ.         */
/*                                          Changed R&P part of query to  filter by plant, as       */
/*                                          shelf lifes are not always set for all plants.          */
/*                                                                                                  */
/*    ASSUMPTIONS: View is based on bringing matl and vendor data for all the snack                 */
/*   plants.                                                                                        */
/*    NOTES:                                                                                        */
/* ************************************************************************************/
  select distinct ltrim(t01.sap_material_code, '0') matl_code,
    t01.bds_material_desc_en matl_desc,
    t01.plant_code as plant,
    t01.material_type matl_type,
    ltrim(t01.regional_code_19, '0') rgnl_code_nmbr,
    decode
    (t01.base_uom,
      'KGM', 'KG',
      'MTR', 'M',
      'EA', 'EA',
      t01.base_uom
    ) as base_uom,
    null as altrntv_uom,
    t01.net_weight net_wght,
    decode(length(ltrim(t01.interntl_article_no, 0)),
      13, 1 || ltrim(t01.interntl_article_no, 0),
      t01.interntl_article_no
    ) ean_code,
    t01.max_storage_prd shelf_life,
    t01.mars_traded_unit_flag trdd_unit,
    t01.mars_semi_finished_prdct_flag semi_fnshd_prdct,                  
    null as vndr_code,
    null as vndr_name, 
    t02.target_qty crtns_per_pllt
  from
    bds_material_plant_mfanz t01, 
    bds_material_pkg_instr_all t02
  where t01.sap_material_code = t02.sap_material_code(+)
    and t01.plant_code = 'AU40'
    and t01.plant_specific_status = '20'
    and t01.material_type in ('ROH', 'VERP')
    and t02.sales_organisation(+) = '147'
    
  union
  
  select ltrim(t02.sap_material_code, '0'), t02.bds_material_desc_en,
    t02.plant_code, t02.material_type,
    ltrim(t02.regional_code_19, '0') regional_code, 
    t02.base_uom, 
    'CS',
    t02.net_weight,
    decode(length(ltrim(t02.interntl_article_no, 0)),
      13, 1 || ltrim(t02.interntl_article_no, 0),
      t02.interntl_article_no
    ), -- for pallet label printing it needs to be a length of 14 - so we pad with a 1.
    t02.total_shelf_life, 
    t02.mars_traded_unit_flag,
    t02.mars_semi_finished_prdct_flag, 
    null as vndr_code,
    null as vndr_name, 
    t03.target_qty crtns_per_pllt
  from bds_material_plant_mfanz t02, 
    bds_material_pkg_instr_all t03
  where t02.sap_material_code = t03.sap_material_code(+)
    and t03.pkg_instr_start_date(+) <= sysdate
    and t03.pkg_instr_end_date(+) >= sysdate
    and t03.sales_organisation(+) = '147'
    and t02.material_type = 'FERT'                     -- only finished goods
    and t02.plant_specific_status = '20'
    and t03.uom = 'CS';

grant select on manu_app.matl_plt_labl_vw to appsupport;
grant select on manu_app.matl_plt_labl_vw to barnehel;
grant select on manu_app.matl_plt_labl_vw to manu_maint;
grant select on manu_app.matl_plt_labl_vw to manu_user;
grant select on manu_app.matl_plt_labl_vw to pt_app with grant option;

create or replace public synonym matl_plt_labl_vw for manu_app.matl_plt_labl_vw;
