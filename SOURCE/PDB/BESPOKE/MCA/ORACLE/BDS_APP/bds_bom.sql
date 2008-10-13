CREATE OR REPLACE PACKAGE BDS_APP.Bds_Bom
AS
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : BDS (Business Data Store)
 Package : bds_bom
 Owner   : BDS_APP
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - BOM Functions

 ***********************************************************************************
 NOTE: this package should be kept in sync with the version on AP0064P under BDS_APP
 ***********************************************************************************
 
  
 FUNCTION : GET_DATASET This function retrieves the factory BOM dataset for the requested parameters.
                         - The effective date parameter defaults to sysdate when null.
                         - The material code parameter defaults to all materials when null.
                         - The plant code parameter defaults to all plant when null.
                         - The function should be used as follows:
                              select * from table(bds_bom.get_dataset(date,'material_code','plant_code')).

 FUNCTION : GET_HIERARCHY This function retrieves the factory BOM hierarchy for the requested parameters.
                           - The effective date parameter defaults to sysdate when null.
                           - The material code parameter must be supplied.
                           - The plant code parameter must be supplied.
                           - The function should be used as follows:
                              select * from table(bds_bom.get_hierarchy(date,'material_code','plant_code')).
                              
FUNCTION : GET_HIERARCHY_REVERSE This function retrieves the factory BOM dataset of parents for the requested parameters.
                           - it reverses and goes upwards through the tree
                           - The effective date parameter defaults to sysdate when null.
                           - The child material code parameter must be supplied.
                           - The plant code parameter must be supplied.
                           - The function should be used as follows:
                              select * from table(bds_bom.get_hierarchy_reverse(date,'material_code','plant_code')).

FUNCTION : GET_COMPONENT_QTY This function retrieves the factory BOM for the requested parameters
                             with component quantity of materials based on top level bom quantity of 1
                           - The assembly scrap value is used to modify the component quantity to all
                             levels within the assembly ie until the heirarch level return to the same value again
                           - The effective date parameter defaults to sysdate when null.
                           - The child material code parameter must be supplied.
                           - The plant code parameter must be supplied.
                           - The function should be used as follows:
                              select * from table(bds_bom.get_component_qty(date,'material_code','plant_code')).

                              
                              
 dd-mmm-YYYY   Author          Description
 -----------   ------          -----------
 01-Mar-2007   Steve Gregan    Created
 01-Mar-2007   Jeff Phillipson added get_hierarchy_reverse
 01-Jun-2007   Jeff Phillipson added get_comonent_qty
 02-Nov-2007   JP              added '<' to the next statement to reset scrap if the hierarchy level drops 
 13-Oct-2008   Trevor Keon     Changed bds_bom_all to use code from view to improve performance
        
*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   FUNCTION get_dataset (
      par_eff_date        IN   DATE,
      par_material_code   IN   VARCHAR2,
      par_plant_code      IN   VARCHAR2
   )
      RETURN bds_bom_dataset PIPELINED;

   FUNCTION get_hierarchy (
      par_eff_date        IN   DATE,
      par_material_code   IN   VARCHAR2,
      par_plant_code      IN   VARCHAR2
   )
      RETURN bds_bom_hierarchy PIPELINED;
      
   FUNCTION get_hierarchy_reverse (
      par_eff_date        IN   DATE,
      par_material_code   IN   VARCHAR2,
      par_plant_code      IN   VARCHAR2
   )
      RETURN bds_bom_dataset PIPELINED;
   
   FUNCTION get_component_qty (
      par_eff_date        IN   DATE,
      par_material_code   IN   VARCHAR2,
      par_plant_code      IN   VARCHAR2
   )
      RETURN bds_bom_component_qty PIPELINED;
        
END Bds_Bom;
/

CREATE OR REPLACE PACKAGE BODY BDS_APP.Bds_Bom AS

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);

   /*******************************************************/
   /* This procedure performs the get bom dataset routine */
   /*******************************************************/
   FUNCTION get_dataset(par_eff_date IN DATE, par_material_code IN VARCHAR2, par_plant_code IN VARCHAR2) RETURN bds_bom_dataset pipelined IS

      /*-*/
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%TYPE;
      var_material_code bds_bom_all.bom_material_code%TYPE;
      var_plant_code bds_bom_all.bom_plant%TYPE;

      /*-*/
      /* Cursor definitions
      /*-*/
      CURSOR csr_bom_dataset IS
         SELECT t01.bom_material_code,
                t01.bom_alternative,
                t01.bom_plant,
                t01.bom_number,
                t01.bom_msg_function,
                t01.bom_usage,
                t01.bom_eff_from_date,
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
           FROM (SELECT t01.*,
                        rank() OVER (PARTITION BY t01.bom_material_code,
                                                  t01.bom_plant
                                         ORDER BY t01.bom_eff_from_date DESC,
                                                  t01.bom_alternative DESC) AS rnkseq
                   FROM 
                   (
                    SELECT t01.bom_material_code, t01.bom_alternative, t01.bom_plant,
                           t01.bom_number, t01.bom_msg_function, t01.bom_usage,
                           CASE
                             WHEN COUNT = 1
                             AND t02.bom_eff_from_date IS NOT NULL
                               THEN t02.bom_eff_from_date
                             WHEN COUNT = 1 AND t02.bom_eff_from_date IS NULL
                               THEN t01.bom_eff_from_date
                             WHEN COUNT > 1 AND t02.bom_eff_from_date IS NULL
                               THEN NULL
                             WHEN COUNT > 1 AND t02.bom_eff_from_date IS NOT NULL
                               THEN t02.bom_eff_from_date
                           END AS bom_eff_from_date,
                           t01.bom_eff_to_date, t01.bom_base_qty, t01.bom_base_uom,
                           t01.bom_status, t01.item_sequence, t01.item_number,
                           t01.item_msg_function, t01.item_material_code, t01.item_category,
                           t01.item_base_qty, t01.item_base_uom, t01.item_eff_from_date,
                           t01.item_eff_to_date
                      FROM bds_bom_det t01,
                           bds_refrnc_hdr_altrnt t02,
                           (SELECT   bom_material_code, bom_plant, COUNT (*) AS COUNT
                                FROM (SELECT DISTINCT bom_material_code, bom_plant,
                                                      bom_alternative
                                                 FROM bds_bom_det)
                            GROUP BY bom_material_code, bom_plant) t03
                     WHERE t01.bom_material_code = LTRIM (t02.bom_material_code(+), ' 0')
                       AND t01.bom_alternative = LTRIM (t02.bom_alternative(+), ' 0')
                       AND t01.bom_plant = t02.bom_plant(+)
                       AND t01.bom_usage = t02.bom_usage(+)
                       AND t01.bom_material_code = t03.bom_material_code
                       AND t01.bom_plant = t03.bom_plant
                       AND t01.item_sequence != 0
                       AND TRUNC(t01.bom_eff_from_date) <= TRUNC(var_eff_date)
                       AND (var_material_code IS NULL OR t01.bom_material_code = var_material_code)
                       AND (var_plant_code IS NULL OR t01.bom_plant = var_plant_code)
                   ) t01
                 ) t01
          WHERE t01.rnkseq = 1
            AND t01.item_sequence != 0;
      rcd_bom_dataset csr_bom_dataset%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      IF par_eff_date IS NULL THEN
         var_eff_date := SYSDATE;
      END IF;
      var_material_code := par_material_code;
      var_plant_code := par_plant_code;

      /*-*/
      /* Retrieve the BOM header information and pipe to output
      /*-*/
      OPEN csr_bom_dataset;
      LOOP
         FETCH csr_bom_dataset INTO rcd_bom_dataset;
         IF csr_bom_dataset%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe ROW(bds_bom_dataset_object(rcd_bom_dataset.bom_material_code,
                                         rcd_bom_dataset.bom_alternative,
                                         rcd_bom_dataset.bom_plant,
                                         rcd_bom_dataset.bom_number,
                                         rcd_bom_dataset.bom_msg_function,
                                         rcd_bom_dataset.bom_usage,
                                         rcd_bom_dataset.bom_eff_from_date,
                                         rcd_bom_dataset.bom_eff_to_date,
                                         rcd_bom_dataset.bom_base_qty,
                                         rcd_bom_dataset.bom_base_uom,
                                         rcd_bom_dataset.bom_status,
                                         rcd_bom_dataset.item_sequence,
                                         rcd_bom_dataset.item_number,
                                         rcd_bom_dataset.item_msg_function,
                                         rcd_bom_dataset.item_material_code,
                                         rcd_bom_dataset.item_category,
                                         rcd_bom_dataset.item_base_qty,
                                         rcd_bom_dataset.item_base_uom,
                                         rcd_bom_dataset.item_eff_from_date,
                                         rcd_bom_dataset.item_eff_to_date));

      END LOOP;
      CLOSE csr_bom_dataset;

      /*-*/
      /* Return
      /*-*/  
      RETURN;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'BDS_BOM - GET_DATASET (' || par_eff_date || ',' || NVL(par_material_code,'*ALL') || ',' || NVL(par_plant_code,'*ALL') || ') - ' || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END get_dataset;

   /*********************************************************/
   /* This procedure performs the get bom hierarchy routine */
   /*********************************************************/
   FUNCTION get_hierarchy(par_eff_date IN DATE, par_material_code IN VARCHAR2, par_plant_code IN VARCHAR2) RETURN bds_bom_hierarchy pipelined IS

      /*-*/
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%TYPE;
      var_material_code bds_bom_all.bom_material_code%TYPE;
      var_plant_code bds_bom_all.bom_plant%TYPE;

      /*-*/
      /* Cursor definitions
      /*-*/
      CURSOR csr_bom_hierarchy IS
         SELECT ROWNUM AS hierarchy_rownum,
                LEVEL AS hierarchy_level,
                t01.*, 
                CONNECT_BY_ISCYCLE AS CYCLE 
           FROM (SELECT t01.bom_material_code,
                        t01.bom_alternative,
                        t01.bom_plant,
                        t01.bom_number,
                        t01.bom_msg_function,
                        t01.bom_usage,
                        t01.bom_eff_from_date,
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
                   FROM (SELECT t01.*,
                                rank() OVER (PARTITION BY t01.bom_material_code,
                                                          t01.bom_plant
                                                 ORDER BY t01.bom_eff_from_date DESC,
                                                          t01.bom_alternative DESC) AS rnkseq
                           FROM 
                           (
                            SELECT t01.bom_material_code, t01.bom_alternative, t01.bom_plant,
                                   t01.bom_number, t01.bom_msg_function, t01.bom_usage,
                                   CASE
                                     WHEN COUNT = 1
                                     AND t02.bom_eff_from_date IS NOT NULL
                                       THEN t02.bom_eff_from_date
                                     WHEN COUNT = 1 AND t02.bom_eff_from_date IS NULL
                                       THEN t01.bom_eff_from_date
                                     WHEN COUNT > 1 AND t02.bom_eff_from_date IS NULL
                                       THEN NULL
                                     WHEN COUNT > 1 AND t02.bom_eff_from_date IS NOT NULL
                                       THEN t02.bom_eff_from_date
                                   END AS bom_eff_from_date,
                                   t01.bom_eff_to_date, t01.bom_base_qty, t01.bom_base_uom,
                                   t01.bom_status, t01.item_sequence, t01.item_number,
                                   t01.item_msg_function, t01.item_material_code, t01.item_category,
                                   t01.item_base_qty, t01.item_base_uom, t01.item_eff_from_date,
                                   t01.item_eff_to_date
                              FROM bds_bom_det t01,
                                   bds_refrnc_hdr_altrnt t02,
                                   (SELECT   bom_material_code, bom_plant, COUNT (*) AS COUNT
                                        FROM (SELECT DISTINCT bom_material_code, bom_plant,
                                                              bom_alternative
                                                         FROM bds_bom_det)
                                    GROUP BY bom_material_code, bom_plant) t03
                             WHERE t01.bom_material_code = LTRIM (t02.bom_material_code(+), ' 0')
                               AND t01.bom_alternative = LTRIM (t02.bom_alternative(+), ' 0')
                               AND t01.bom_plant = t02.bom_plant(+)
                               AND t01.bom_usage = t02.bom_usage(+)
                               AND t01.bom_material_code = t03.bom_material_code
                               AND t01.bom_plant = t03.bom_plant
                               AND t01.item_sequence != 0
                               AND t01.bom_plant = var_plant_code                  
                           ) t01
                          WHERE TRUNC(t01.bom_eff_from_date) <= TRUNC(var_eff_date)) t01
                  WHERE t01.rnkseq = 1
                    AND t01.item_sequence != 0) t01
          START WITH t01.bom_material_code = var_material_code
                 AND t01.bom_plant = var_plant_code
        CONNECT BY NOCYCLE PRIOR t01.item_material_code = t01.bom_material_code
          ORDER SIBLINGS BY TO_NUMBER(t01.item_number);
          
      rcd_bom_hierarchy csr_bom_hierarchy%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      IF par_eff_date IS NULL THEN
         var_eff_date := SYSDATE;
      END IF;
      var_material_code := par_material_code;
      IF par_material_code IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Hierarchy material code must be supplied');
      END IF;
      var_plant_code := par_plant_code;
      IF par_plant_code IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Hierarchy plant code must be supplied');
      END IF;

      /*-*/
      /* Retrieve the BOM header information and pipe to output
      /*-*/
      OPEN csr_bom_hierarchy;
      LOOP
         FETCH csr_bom_hierarchy INTO rcd_bom_hierarchy;
         IF csr_bom_hierarchy%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe ROW(bds_bom_hierarchy_object(rcd_bom_hierarchy.hierarchy_rownum,
                                           rcd_bom_hierarchy.hierarchy_level,
                                           rcd_bom_hierarchy.bom_material_code,
                                           rcd_bom_hierarchy.bom_alternative,
                                           rcd_bom_hierarchy.bom_plant,
                                           rcd_bom_hierarchy.bom_number,
                                           rcd_bom_hierarchy.bom_msg_function,
                                           rcd_bom_hierarchy.bom_usage,
                                           rcd_bom_hierarchy.bom_eff_from_date,
                                           rcd_bom_hierarchy.bom_eff_to_date,
                                           rcd_bom_hierarchy.bom_base_qty,
                                           rcd_bom_hierarchy.bom_base_uom,
                                           rcd_bom_hierarchy.bom_status,
                                           rcd_bom_hierarchy.item_sequence,
                                           rcd_bom_hierarchy.item_number,
                                           rcd_bom_hierarchy.item_msg_function,
                                           rcd_bom_hierarchy.item_material_code,
                                           rcd_bom_hierarchy.item_category,
                                           rcd_bom_hierarchy.item_base_qty,
                                           rcd_bom_hierarchy.item_base_uom,
                                           rcd_bom_hierarchy.item_eff_from_date,
                                           rcd_bom_hierarchy.item_eff_to_date));

      END LOOP;
      CLOSE csr_bom_hierarchy;

      /*-*/
      /* Return
      /*-*/  
      RETURN;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'BDS_BOM - GET_HIERARCHY (' || par_eff_date || ',' || NVL(par_material_code,'NULL') || ',' || NVL(par_plant_code,'NULL') || ') - ' || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END get_hierarchy;
   
   
   /*******************************************************/
   /* This procedure performs the get bom hierarchy       */
   /* upwards                                             */
   /*******************************************************/
   FUNCTION get_hierarchy_reverse(par_eff_date IN DATE, par_material_code IN VARCHAR2, 
                                          par_plant_code IN VARCHAR2) RETURN bds_bom_dataset pipelined IS

      /*-*/
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%TYPE;
      var_material_code bds_bom_all.item_material_code%TYPE;
      var_plant_code bds_bom_all.bom_plant%TYPE;
      var_bom_number bds_bom_all.bom_number%TYPE;

      /*-*/
      /* Cursor definitions
      /*-*/
      CURSOR csr_bom_parents IS
          SELECT ROWNUM AS hierarchy_rownum,
                LEVEL AS hierarchy_level,
                t01.*, 
                CONNECT_BY_ISCYCLE AS CYCLE 
           FROM (SELECT t01.bom_material_code,
                        t01.bom_alternative,
                        t01.bom_plant,
                        t01.bom_number,
                        t01.bom_msg_function,
                        t01.bom_usage,
                        t01.bom_eff_from_date,
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
                   FROM (SELECT t01.*,
                                rank() OVER (PARTITION BY t01.bom_material_code,
                                                          t01.bom_plant
                                                 ORDER BY t01.bom_eff_from_date DESC,
                                                          t01.bom_alternative DESC) AS rnkseq
                           FROM 
                           (
                            SELECT t01.bom_material_code, t01.bom_alternative, t01.bom_plant,
                                   t01.bom_number, t01.bom_msg_function, t01.bom_usage,
                                   CASE
                                     WHEN COUNT = 1
                                     AND t02.bom_eff_from_date IS NOT NULL
                                       THEN t02.bom_eff_from_date
                                     WHEN COUNT = 1 AND t02.bom_eff_from_date IS NULL
                                       THEN t01.bom_eff_from_date
                                     WHEN COUNT > 1 AND t02.bom_eff_from_date IS NULL
                                       THEN NULL
                                     WHEN COUNT > 1 AND t02.bom_eff_from_date IS NOT NULL
                                       THEN t02.bom_eff_from_date
                                   END AS bom_eff_from_date,
                                   t01.bom_eff_to_date, t01.bom_base_qty, t01.bom_base_uom,
                                   t01.bom_status, t01.item_sequence, t01.item_number,
                                   t01.item_msg_function, t01.item_material_code, t01.item_category,
                                   t01.item_base_qty, t01.item_base_uom, t01.item_eff_from_date,
                                   t01.item_eff_to_date
                              FROM bds_bom_det t01,
                                   bds_refrnc_hdr_altrnt t02,
                                   (SELECT   bom_material_code, bom_plant, COUNT (*) AS COUNT
                                        FROM (SELECT DISTINCT bom_material_code, bom_plant,
                                                              bom_alternative
                                                         FROM bds_bom_det)
                                    GROUP BY bom_material_code, bom_plant) t03
                             WHERE t01.bom_material_code = LTRIM (t02.bom_material_code(+), ' 0')
                               AND t01.bom_alternative = LTRIM (t02.bom_alternative(+), ' 0')
                               AND t01.bom_plant = t02.bom_plant(+)
                               AND t01.bom_usage = t02.bom_usage(+)
                               AND t01.bom_material_code = t03.bom_material_code
                               AND t01.bom_plant = t03.bom_plant
                               AND t01.item_sequence != 0
                               AND t01.bom_plant = var_plant_code                     
                           ) t01
                          WHERE TRUNC(t01.bom_eff_from_date) <= TRUNC(par_eff_date)) t01
                  WHERE t01.rnkseq = 1
                    AND t01.item_sequence != 0) t01
          START WITH t01.item_material_code = var_material_code
                 AND t01.bom_plant = var_plant_code 
        CONNECT BY NOCYCLE PRIOR t01.bom_material_code = t01.item_material_code
         ORDER SIBLINGS BY TO_NUMBER(t01.bom_material_code);
      rcd_bom_parents csr_bom_parents%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      IF par_eff_date IS NULL THEN
         var_eff_date := SYSDATE;
      END IF;
      var_material_code := par_material_code;
      var_plant_code := par_plant_code;

      /*-*/
      /* Retrieve the BOM header information and pipe to output
      /*-*/
      OPEN csr_bom_parents;
      LOOP
         FETCH csr_bom_parents INTO rcd_bom_parents;
         IF csr_bom_parents%NOTFOUND THEN
            EXIT;
         END IF;

         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe ROW(bds_bom_dataset_object(rcd_bom_parents.bom_material_code,
                                         rcd_bom_parents.bom_alternative,
                                         rcd_bom_parents.bom_plant,
                                         rcd_bom_parents.bom_number,
                                         rcd_bom_parents.bom_msg_function,
                                         rcd_bom_parents.bom_usage,
                                         rcd_bom_parents.bom_eff_from_date,
                                         rcd_bom_parents.bom_eff_to_date,
                                         rcd_bom_parents.bom_base_qty,
                                         rcd_bom_parents.bom_base_uom,
                                         rcd_bom_parents.bom_status,
                                         rcd_bom_parents.item_sequence,
                                         rcd_bom_parents.item_number,
                                         rcd_bom_parents.item_msg_function,
                                         rcd_bom_parents.item_material_code,
                                         rcd_bom_parents.item_category,
                                         rcd_bom_parents.item_base_qty,
                                         rcd_bom_parents.item_base_uom,
                                         rcd_bom_parents.item_eff_from_date,
                                         rcd_bom_parents.item_eff_to_date));

      END LOOP;
      CLOSE csr_bom_parents;

      /*-*/
      /* Return
      /*-*/  
      RETURN;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'BDS_BOM - get_hierarchy_up (' || par_eff_date || ',' || NVL(par_material_code,'*ALL') || ',' || NVL(par_plant_code,'*ALL') || ') - ' || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END get_hierarchy_reverse;
   
   

   /*********************************************************/
   /* This procedure performs the get component quantity routine */
   /*********************************************************/
   FUNCTION get_component_qty(par_eff_date IN DATE, par_material_code IN VARCHAR2, par_plant_code IN VARCHAR2) RETURN bds_bom_component_qty pipelined IS

      /*-*/
      /* Declare Variables
      /*-*/
      var_eff_date bds_bom_all.bom_eff_from_date%TYPE;
      var_material_code bds_bom_all.bom_material_code%TYPE;
      var_plant_code bds_bom_all.bom_plant%TYPE;
      var_scale bds_bom_all.bom_base_qty%TYPE;
      var_bom_qty bds_bom_all.bom_base_qty%TYPE;
      var_count NUMBER DEFAULT 0;
      var_assembly_scrap_percntg bds_material_plant_mfanz.assembly_scrap_percntg%TYPE;
      var_scrap_hierarchy_level NUMBER;
      
      TYPE id_table_object IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      id_table id_table_object;
      
      /*-*/
      /* Cursor definitions
      /*-*/
      CURSOR csr_bom_hierarchy IS
      SELECT t01.*,
       CASE
           WHEN t02.assembly_scrap_percntg IS NULL THEN 0
           WHEN t02.assembly_scrap_percntg = '' THEN 0
           WHEN t02.assembly_scrap_percntg = 0 THEN 0
           ELSE t02.assembly_scrap_percntg
       END assembly_scrap_percntg,
	   CASE
	       WHEN t01.item_base_uom = 'PCE' THEN t02.bds_pce_factor_from_base_uom
		   ELSE 1
	   END factor_from_base_uom    
      FROM (SELECT ROWNUM AS hierarchy_rownum,
                   LEVEL AS hierarchy_level,
                   t01.*, 
           CONNECT_BY_ISCYCLE AS CYCLE 
             FROM (SELECT t01.bom_material_code,
                          t01.bom_alternative,
                          t01.bom_plant,
                          t01.bom_number,
                          t01.bom_msg_function,
                          t01.bom_usage,
                          t01.bom_eff_from_date,
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
                     FROM (SELECT t01.*,
                                  rank() OVER (PARTITION BY t01.bom_material_code,
                                                            t01.bom_plant
                                                   ORDER BY t01.bom_eff_from_date DESC,
                                                            t01.bom_alternative DESC) AS rnkseq
                             FROM 
                             (
                              SELECT t01.bom_material_code, t01.bom_alternative, t01.bom_plant,
                                     t01.bom_number, t01.bom_msg_function, t01.bom_usage,
                                     CASE
                                       WHEN COUNT = 1
                                       AND t02.bom_eff_from_date IS NOT NULL
                                         THEN t02.bom_eff_from_date
                                       WHEN COUNT = 1 AND t02.bom_eff_from_date IS NULL
                                         THEN t01.bom_eff_from_date
                                       WHEN COUNT > 1 AND t02.bom_eff_from_date IS NULL
                                         THEN NULL
                                       WHEN COUNT > 1 AND t02.bom_eff_from_date IS NOT NULL
                                         THEN t02.bom_eff_from_date
                                     END AS bom_eff_from_date,
                                     t01.bom_eff_to_date, t01.bom_base_qty, t01.bom_base_uom,
                                     t01.bom_status, t01.item_sequence, t01.item_number,
                                     t01.item_msg_function, t01.item_material_code, t01.item_category,
                                     t01.item_base_qty, t01.item_base_uom, t01.item_eff_from_date,
                                     t01.item_eff_to_date
                                FROM bds_bom_det t01,
                                     bds_refrnc_hdr_altrnt t02,
                                     (SELECT   bom_material_code, bom_plant, COUNT (*) AS COUNT
                                          FROM (SELECT DISTINCT bom_material_code, bom_plant,
                                                                bom_alternative
                                                           FROM bds_bom_det)
                                      GROUP BY bom_material_code, bom_plant) t03
                               WHERE t01.bom_material_code = LTRIM (t02.bom_material_code(+), ' 0')
                                 AND t01.bom_alternative = LTRIM (t02.bom_alternative(+), ' 0')
                                 AND t01.bom_plant = t02.bom_plant(+)
                                 AND t01.bom_usage = t02.bom_usage(+)
                                 AND t01.bom_material_code = t03.bom_material_code
                                 AND t01.bom_plant = t03.bom_plant
                                 AND t01.item_sequence != 0
                                 AND t01.bom_plant = var_plant_code                             
                             ) t01
                            WHERE TRUNC(t01.bom_eff_from_date) <= TRUNC(var_eff_date)) t01
                    WHERE t01.rnkseq = 1
                      AND t01.item_sequence != 0
                      AND t01.bom_plant = var_plant_code
					  ) t01
            START WITH t01.bom_material_code = var_material_code
                   AND t01.bom_plant = var_plant_code
            CONNECT BY NOCYCLE PRIOR t01.item_material_code = t01.bom_material_code
            ORDER SIBLINGS BY TO_NUMBER(t01.item_number)) t01,
           (SELECT assembly_scrap_percntg, sap_material_code, plant_code,
		           bds_pce_factor_from_base_uom 
              FROM bds_material_plant_mfanz) t02
      WHERE t01.item_material_code = LTRIM(t02.sap_material_code(+),'0')
        AND t01.bom_plant = t02.plant_code(+)
      ORDER BY 1;
          
      rcd_bom_hierarchy csr_bom_hierarchy%ROWTYPE;

    
      
   /*-------------*/
   /* Begin block */
   /*-------------*/
   BEGIN

      /*-*/
      /* Initialise variables
      /*-*/
      var_eff_date := par_eff_date;
      IF par_eff_date IS NULL THEN
         var_eff_date := SYSDATE;
      END IF;
      var_material_code := par_material_code;
      IF par_material_code IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Hierarchy material code must be supplied');
      END IF;
      var_plant_code := par_plant_code;
      IF par_plant_code IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000, 'Hierarchy plant code must be supplied');
      END IF;
      var_assembly_scrap_percntg := 0;
      var_scrap_hierarchy_level := 0;
      
      id_table.DELETE;
      
      /*-*/
      /* Retrieve the BOM header information and pipe to output
      /*-*/
      OPEN csr_bom_hierarchy;
      LOOP
         FETCH csr_bom_hierarchy INTO rcd_bom_hierarchy;
         IF csr_bom_hierarchy%NOTFOUND THEN
            EXIT;
         END IF;
         
         IF var_count = 0 THEN
             var_bom_qty := rcd_bom_hierarchy.bom_base_qty;
             var_count := 1;
         END IF;
         
         /*-*/
         /* save each levels bo qty
         /*-*/
         id_table(rcd_bom_hierarchy.hierarchy_level) :=
		      (rcd_bom_hierarchy.item_base_qty/rcd_bom_hierarchy.factor_from_base_uom)
		       /rcd_bom_hierarchy.bom_base_qty;
         /*-*/
         /* convert bom ratio
         /*-*/
         var_scale := 1;
         FOR i IN 1 .. rcd_bom_hierarchy.hierarchy_level
             LOOP
             var_scale :=  var_scale * id_table(i);
         END LOOP;
         --var_scale := var_scale; --* var_bom_qty;
         /*-*/
         /* add losses to values
         /*-*/
         /* 2-Nov-2007 JP added '<' to the next statement to reset scrap if the hierarchy level drops */
         IF var_scrap_hierarchy_level <= rcd_bom_hierarchy.hierarchy_level THEN
             var_assembly_scrap_percntg := 0;
         END IF;
         IF rcd_bom_hierarchy.assembly_scrap_percntg <> 0 THEN
             var_assembly_scrap_percntg := rcd_bom_hierarchy.assembly_scrap_percntg;
             var_scrap_hierarchy_level := rcd_bom_hierarchy.hierarchy_level;
         END IF;
         var_scale := var_scale * (1 +  var_assembly_scrap_percntg/100);
         IF rcd_bom_hierarchy.item_material_code = '1104205' OR rcd_bom_hierarchy.item_material_code = '1104209' THEN
             DBMS_OUTPUT.PUT_LINE('Scale:' || var_scale || '-' || rcd_bom_hierarchy.hierarchy_level);
         END IF;
         /*-*/
         /* Pipe the output to the consumer
         /*-*/
         pipe ROW(bds_bom_component_qty_object(rcd_bom_hierarchy.hierarchy_rownum,
                                           rcd_bom_hierarchy.hierarchy_level,
                                           rcd_bom_hierarchy.bom_material_code,
                                           rcd_bom_hierarchy.bom_alternative,
                                           rcd_bom_hierarchy.bom_plant,
                                           rcd_bom_hierarchy.bom_number,
                                           rcd_bom_hierarchy.bom_msg_function,
                                           rcd_bom_hierarchy.bom_usage,
                                           rcd_bom_hierarchy.bom_eff_from_date,
                                           rcd_bom_hierarchy.bom_eff_to_date,
                                           rcd_bom_hierarchy.bom_base_qty,
                                           rcd_bom_hierarchy.bom_base_uom,
                                           rcd_bom_hierarchy.bom_status,
                                           rcd_bom_hierarchy.item_sequence,
                                           rcd_bom_hierarchy.item_number,
                                           rcd_bom_hierarchy.item_msg_function,
                                           rcd_bom_hierarchy.item_material_code,
                                           rcd_bom_hierarchy.item_category,
                                           rcd_bom_hierarchy.item_base_qty,
                                           rcd_bom_hierarchy.item_base_uom,
                                           rcd_bom_hierarchy.item_eff_from_date,
                                           rcd_bom_hierarchy.item_eff_to_date,
                                           ROUND(var_scale,4)));

      END LOOP;
      CLOSE csr_bom_hierarchy;

      /*-*/
      /* Return
      /*-*/  
      RETURN;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   EXCEPTION

      /**/
      /* Exception trap
      /**/
      WHEN OTHERS THEN

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'BDS_BOM - GET_HIERARCHY (' || par_eff_date || ',' || NVL(par_material_code,'NULL') || ',' || NVL(par_plant_code,'NULL') || ') - ' || SUBSTR(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   END get_component_qty;
   
   
   
END Bds_Bom;
/
GRANT EXECUTE ON BDS_APP.BDS_BOM TO APPSUPPORT;
GRANT EXECUTE ON BDS_APP.BDS_BOM TO ESCHED_APP WITH GRANT OPTION;
GRANT EXECUTE ON BDS_APP.BDS_BOM TO MANU WITH GRANT OPTION;
GRANT EXECUTE ON BDS_APP.BDS_BOM TO MANU_APP WITH GRANT OPTION;
GRANT EXECUTE ON BDS_APP.BDS_BOM TO PKGSPEC_APP WITH GRANT OPTION;
GRANT EXECUTE ON BDS_APP.BDS_BOM TO PPLAN_APP WITH GRANT OPTION;

CREATE OR REPLACE PUBLIC SYNONYM BDS_BOM FOR BDS_APP.BDS_BOM;