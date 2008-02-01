/******************************************************************************/
/*  NAME: BDS_BOM_ALL                                                         */
/*                                                                            */
/*  REVISIONS:                                                                */
/*  Ver    Date        Author           Description                           */
/*  -----  ----------  ---------------  ------------------------------------  */
/*  1.0    26-02-2007  Steve Gregan     Created view                          */
/*  2.0    02-11-2007  Site Team        Updated view                          */
/******************************************************************************/

create or replace force view bds.bds_bom_all
   (bom_material_code,
    bom_alternative,
    bom_plant,
    bom_number,
    bom_msg_function,
    bom_usage,
    bom_eff_from_date,
    bom_eff_to_date,
    bom_base_qty,
    bom_base_uom,
    bom_status,
    item_sequence,
    item_number,
    item_msg_function,
    item_material_code,
    item_category,
    item_base_qty,
    item_base_uom,
    item_eff_from_date,
    item_eff_to_date) as
   SELECT t01.bom_material_code,
          t01.bom_alternative,
          t01.bom_plant,
          t01.bom_number,
          t01.bom_msg_function,
          t01.bom_usage,
          CASE
              WHEN COUNT = 1 AND t02.valid_from_date IS NOT NULL THEN t02.valid_from_date
              WHEN COUNT = 1 AND t02.valid_from_date IS NULL THEN t01.bom_eff_from_date
              WHEN COUNT > 1 AND t02.valid_from_date IS NULL THEN NULL
              WHEN COUNT > 1 AND t02.valid_from_date IS NOT NULL THEN t02.valid_from_date
          END AS bom_eff_from_date,
          t01.bom_eff_to_date,
          t01.bom_base_qty,
          t01.bom_base_uom,
          t01.bom_status,
          t01.item_sequence,
          t01.item_number,
          t01.item_msg_function,
          t01.item_material_code,
          t01.item_category,
          t01.item_base_qty,
          t01.item_base_uom,
          t01.item_eff_from_date,
          t01.item_eff_to_date
     FROM bds_bom_det t01,
          bds_refrnc_bom_altrnt_t415a t02,
          (SELECT bom_material_code
		        , bom_plant
				, count(*) AS COUNT
             FROM (SELECT  DISTINCT bom_material_code
			    , bom_plant
				, bom_alternative
             FROM bds_bom_det)	
		   GROUP BY
		          bom_material_code
				, bom_plant	) t03
    WHERE t01.bom_material_code = LTRIM(t02.sap_material_code(+),' 0')
      AND t01.bom_alternative = LTRIM(t02.altrntv_bom(+),' 0')
      AND t01.bom_plant = t02.plant_code(+)
      AND t01.bom_usage = t02.bom_usage(+)
      AND t01.bom_material_code = t03.bom_material_code
      AND t01.bom_plant = t03.bom_plant
      AND t01.bds_lads_status = '1';

/*-*/
/* Authority
/*-*/
grant select on bds.bds_bom_all to bds_app with grant option;

/*-*/
/* Synonym
/*-*/
create or replace public synonym bds_bom_all for bds.bds_bom_all;