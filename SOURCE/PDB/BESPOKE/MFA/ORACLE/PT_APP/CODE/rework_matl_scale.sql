DROP FUNCTION PT_APP.REWORK_MATL_SCALE;

CREATE OR REPLACE FUNCTION PT_APP.Rework_Matl_Scale(o_result OUT NUMBER, o_result_msg OUT VARCHAR2, i_proc_order IN VARCHAR2, i_matl_code IN VARCHAR2) RETURN NUMBER IS
/******************************************************************************
   NAME:       REWORK_MATL_SCALE
   PURPOSE:    Non stockable materials only
               Calculate the percentage of Chocolate that needs to be added 
               to the rework amount

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/11/2007   Jeff Phillipson       1. Created this function.

   NOTES:
******************************************************************************/

    /*-*/
    /* local variables */
    /*-*/
    var_count          NUMBER;
    
    /*-*/
    /* local constants */
    /*-*/
    cst_choc_enrobing    CONSTANT VARCHAR2(100) := 'CHOC';
    cst_choc_preparation CONSTANT VARCHAR2(100) := 'CHOC PREP';
    
    /*-*/
    /* cursors */
    /*-*/
    CURSOR csr_choc_preparation
    IS
    SELECT t01.proc_order,
           t01.plant_code,
           t01.operation,
           t01.material_code,
           CASE
               WHEN pan_size_flag = 'Y' THEN pan_size/total
               ELSE material_qty / total
           END extra_qty,
           COUNT(pan_size) OVER (PARTITION BY operation) AS total_records,
           phantom
      FROM (SELECT LTRIM(t01.proc_order,'0') proc_order,
                   t01.plant_code,
                   t01.operation, 
                   t01.material_code,
                   t01.material_qty,
                   t01.pan_size,
                   t01.pan_qty,
                   t01.pan_size_flag,
                   t01.phantom,
                   SUM(pan_size) OVER (PARTITION BY operation) AS total
              FROM BDS_RECIPE_BOM t01
             WHERE t01.operation IN (SELECT DISTINCT t11.operation
                                       FROM rework_cnvrsn t10,
                                            bds_recipe_resource t11,
                                            bds_recipe_src_value t12
                                      WHERE t11.proc_order = t12.proc_order
                                        AND t11.operation = t12.operation
                                        --AND t10.resrce_code = t11.resource_code
                                        AND t10.src_tag = t12.src_tag
                                        AND rework_cnvrsn_code = cst_choc_preparation
                                        AND t11.proc_order = t01.proc_order) 
       AND LTRIM(t01.material_code,'0') NOT IN (SELECT matl_code FROM recpe_phantom)
       AND LTRIM(proc_order,'0') = i_proc_order) t01,
           bds_material_plant_mfanz t02
     WHERE LTRIM(t01.material_code,'0') = LTRIM(t02.sap_material_code,'0')
       AND t01.plant_code = t02.plant_code
       AND procurement_type = 'E'
       AND special_procurement_type = '50';
       
    rcd_choc_preparation csr_choc_preparation%ROWTYPE;
    
    CURSOR csr_choc_enrobing
    IS
    SELECT t01.proc_order,
           t01.plant_code,
           t01.operation,
           t01.material_code,
           CASE
               WHEN pan_size_flag = 'Y' THEN pan_size/total
               ELSE material_qty / total
           END extra_qty,
           COUNT(pan_size) OVER (PARTITION BY operation) AS total_records,
           phantom
      FROM (SELECT LTRIM(t01.proc_order,'0') proc_order,
                   t01.plant_code,
                   t01.operation, 
                   t01.material_code,
                   t01.material_qty,
                   t01.pan_size,
                   t01.pan_qty,
                   t01.pan_size_flag,
                   t01.phantom,
                   SUM(pan_size) OVER (PARTITION BY operation) AS total
              FROM BDS_RECIPE_BOM t01
             WHERE t01.operation IN (SELECT DISTINCT t11.operation
                                       FROM rework_cnvrsn t10,
                                            bds_recipe_resource t11,
                                            bds_recipe_src_value t12
                                      WHERE t11.proc_order = t12.proc_order
                                        AND t11.operation = t12.operation
                                        --AND t10.resrce_code = t11.resource_code
                                        AND t10.src_tag = t12.src_tag
                                        AND rework_cnvrsn_code = cst_choc_enrobing
                                        AND t11.proc_order = t01.proc_order) 
       AND LTRIM(t01.material_code,'0') NOT IN (SELECT matl_code FROM recpe_phantom)
       AND (t01.phantom IS NULL OR t01.phantom <> 'M')
       AND LTRIM(proc_order,'0') = i_proc_order) t01,
           bds_material_plant_mfanz t02
     WHERE LTRIM(t01.material_code,'0') = LTRIM(t02.sap_material_code,'0')
       AND t01.plant_code = t02.plant_code
       AND procurement_type = 'E'
       AND special_procurement_type = '50';  
                             
    rcd_choc_enrobing csr_choc_enrobing%ROWTYPE;
   
    
BEGIN
   o_result := 0;
   o_result_msg := '';
   
   IF i_proc_order IS NULL THEN
       o_result := 1;
       o_result_msg := 'The process order cannot be null';
       RETURN 0;
   END IF;
   IF i_matl_code IS NULL THEN
       o_result := 1;
       o_result_msg := 'The material code cannot be null';
       RETURN 0;
   END IF;
   /*-*/
   /* check if non stockable */
   /*-*/
   SELECT COUNT(*) INTO var_count
   FROM BDS_MATERIAL_PLANT_MFANZ
   WHERE LTRIM(sap_material_code,'0') = trim(i_matl_code)
     AND plant_code = (SELECT plant_code FROM BDS_RECIPE_HEADER WHERE LTRIM(proc_order,'0') = trim(i_proc_order))
     AND procurement_type = 'E'
     AND special_procurement_type = '50';
   IF var_count = 0 THEN
       o_result := 1;
       o_result_msg := 'The material code: ' || i_matl_code || ' is Stockable - should be Non Stockable';
       RETURN 0;
   END IF;  
   
   /*-*/
   /* check if material is in the current proc order */
   /*-*/
   SELECT COUNT(*) INTO var_count
     FROM BDS_RECIPE_BOM
    WHERE LTRIM(proc_order,'0') = i_proc_order
      AND LTRIM(material_code,'0') = i_matl_code;
   IF var_count = 0 THEN
       o_result := 1;
       o_result_msg := 'The material code: ' || i_matl_code || ' is not in the current proc order Bom';
       RETURN 0;
   END IF;  
   
   /*-*/
   /* check if the main bar line resource  */
   /* and there is a chocolate enrobing SRC in the same operation */
   /*-*/
   SELECT COUNT(*) INTO var_count
     FROM BDS_RECIPE_RESOURCE t01,
          BDS_RECIPE_SRC_VALUE t02
    WHERE t01.proc_order = t02.proc_order
      AND t01.operation = t02.operation
      AND t01.resource_code || t02.src_tag IN (SELECT resrce_code || src_tag
                                                 FROM rework_cnvrsn
                                                WHERE rework_cnvrsn_code = cst_choc_enrobing)
                                                  AND LTRIM(t01.proc_order,'0') = i_proc_order;
   IF var_count = 0 THEN
       o_result := 0;
       o_result_msg := '';
       RETURN 0;
   END IF; 
  
   /*-*/
   /* and there is a chocolate preparation SRC in another operation */
   /*-*/
   SELECT COUNT(*) INTO var_count
     FROM BDS_RECIPE_SRC_VALUE t02
    WHERE trim(t02.src_tag) IN (SELECT trim(src_tag)
                            FROM rework_cnvrsn
                           WHERE rework_cnvrsn_code = cst_choc_preparation)
      AND LTRIM(t02.proc_order,'0') = trim(i_proc_order);     
   IF var_count = 0 THEN
       o_result := 0;
       o_result_msg := '';
       RETURN 0;
   END IF;                            
                                        
   /*-*/
   /* calculate percentage
   /*-*/
   OPEN csr_choc_preparation;
       FETCH csr_choc_preparation INTO rcd_choc_preparation;
       IF csr_choc_preparation%NOTFOUND OR rcd_choc_preparation.total_records <> 1 THEN
           o_result := 1;
           o_result_msg := 'There has to be a Chocolate Preparation SRC before a Chocolate Enrobing SRC';
           RETURN 0;  -- there always has to be a chocolate preparationwith the Choclate material in it
       END IF;
   CLOSE csr_choc_preparation;

   OPEN csr_choc_enrobing;
   LOOP
       FETCH csr_choc_enrobing INTO rcd_choc_enrobing;
       EXIT WHEN csr_choc_enrobing%NOTFOUND;
       IF rcd_choc_enrobing.material_code <> rcd_choc_preparation.material_code THEN
           o_result := 0;
           o_result_msg := '';
           RETURN rcd_choc_enrobing.extra_qty;
       END IF;
   END LOOP;
   CLOSE csr_choc_enrobing; 
   
   /*-*/
   /* return percentage to multiply quantity by
   /*-*/
   RETURN 0;
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Rework_Matl_Scale;
/


