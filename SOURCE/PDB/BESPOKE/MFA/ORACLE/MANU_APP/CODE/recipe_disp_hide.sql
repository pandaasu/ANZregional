DROP FUNCTION MANU_APP.RECIPE_DISP_HIDE;

CREATE OR REPLACE FUNCTION MANU_APP.Recipe_Disp_Hide(i_proc_order IN VARCHAR2,
                                     i_opertn IN VARCHAR2,
                                     i_phase IN VARCHAR2,
                                     i_matl_code IN VARCHAR2) RETURN VARCHAR2 IS

/******************************************************************************
   NAME:       Recipe_Disp_Hide
   PURPOSE:    determine if the material should be displayed or hidden
               based on the HIDE_DUPLICATES
   RETURN:     D - Display
               H - Hide
   INPUT:      Proc_order
               opertn
               phase
               matl_code
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        8-Jun-2007   Jeff Phillipson       1. Created this function.
   1.1        4-Oct-2007   Jeff Phillipson       2. Added matl code filter to Min(Phase) query
   1.2        8-Oct-2007   Jeff Phillipson       3. added material code as a filter on the var_count01 query
   1.3        18-Oct-2007  Jeff Phillipson       added distinct and filter by recpe_phantom to get_phantom query
   RULES:
   SINGLE STEP 
   OPERATION
            PHASE    -  SRC 1998    SINGLE STEP
            PHASE   } 
            PHASE   } all duplicates
            PHASE   }
   MULTI STEP
   OPERATION
            PHASE   -   SRC 1998    MULTI STEP
            PHASE   -   SRC 1998    MULTI STEP
            PHASE   -   SRC 1998    MULTI STEP
            PHASE   -   SRC 1998    MULTI STEP
   OPERATION
            PHASE   }
            PHASE   } all duplicates
            PHASE   }
            PHASE   }
******************************************************************************/
    
    var_count   NUMBER;
    var_count01 NUMBER;
    var_result    VARCHAR2(1);
    var_work      VARCHAR2(2000) DEFAULT '';
    var_phase     VARCHAR2(4);
    var_proc_order VARCHAR2(20);
    var_matl_code VARCHAR2(20);
    var_phantom   VARCHAR2(20);
    var_links     VARCHAR2(4);
    
BEGIN

   var_proc_order := LTRIM(TRIM(i_proc_order),'0');
   var_matl_code  := trim(i_matl_code);
   /*-*/
   /* get the number of phantoms within the operation 
   /*-*/
   SELECT COUNT(*) INTO var_count
     FROM cntl_rec_bom
    WHERE LTRIM(proc_order,'0') = LTRIM(var_proc_order,'0')
      AND LTRIM(MATeriaL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
      AND operation = i_opertn
      AND phantom = 'M';
      
   /*-*/
   /* check if this is a multi phase to see if the previous operation
   /* contains a hide duplicate
   /* if var_count > 1 then it is a multi phase operation
   /*-*/
   IF var_count > 1 THEN
        /*-*/
        /* get previous opertn and 
        /* check if a phantom in this operation is present in the previous operation
        /*-*/
        BEGIN
            /* get previous op */
            SELECT opertn INTO var_work
             FROM (SELECT opertn,
                          rank() OVER (
                    ORDER BY opertn DESC) rnk
                     FROM cntl_rec_resrce 
                    WHERE LTRIM(proc_order,'0') = LTRIM(var_proc_order,'0')
                      AND opertn < i_opertn)
             WHERE rnk = 1;
             /*-*/
             /* added 18-Oct-2007  JP
             /*-*/
            IF var_work < i_opertn THEN
                /* check if a phantom is in both operations */
                SELECT COUNT(*) INTO var_links 
                  FROM cntl_rec_bom t01, 
                       cntl_rec_bom t02
                 WHERE t01.proc_order = t02.proc_order
                   AND t01.phantom = t02.phantom
                   AND t01.material_code = t02.material_code
                   AND t01.phantom = 'M'
                   AND t01.operation = i_opertn
                   AND t02.operation = var_work
                   AND LTRIM(t01.proc_order,'0') = LTRIM(var_proc_order,'0')
                   AND LTRIM(t01.material_code,'0') NOT IN (SELECT matl_code FROM recpe_phantom);
                IF var_links = 0 THEN
                    var_work := i_opertn;
                END IF;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                var_work := i_opertn;
        END;
        
                                    
       IF var_work >= i_opertn THEN
           /*-*/
           /* this must be the first operation so ignore 
           /*-*/
           var_count := var_count;
       ELSE
           /*-*/
           /* check if the previous operation contains 1 phantom and a hide duplicates 
           /*-*/
           SELECT COUNT(*) INTO var_count01 
             FROM (SELECT DISTINCT t01.material_code FROM cntl_rec_bom t01,
                          cntl_rec_mpi_val t02,
                          cntl_rec_bom t03
                    WHERE t01.proc_order = t02.proc_order
                      AND t01.operation = t02.operation
                      AND t01.proc_order = t03.proc_order
                      AND LTRIM(t01.proc_order,'0') = LTRIM(var_proc_order,'0')
                      AND t01.operation = var_work
                      AND t03.operation = i_opertn
                      AND t01.material_code = t03.material_code
                      AND t01.phantom = t03.phantom
                      AND t01.phantom = 'M'
                      AND t01.material_code = t03.material_code
                      AND t02.mpi_tag = 1998); 
              
                
           IF var_count01 = 1 THEN
               /*-*/
               /* get the phantom code 
               /*-*/
               SELECT DISTINCT LTRIM(t01.material_code,'0') INTO var_phantom
                 FROM cntl_rec_bom t01
                WHERE LTRIM(t01.proc_order,'0') = LTRIM(var_proc_order,'0')
                  AND t01.operation = var_work
                  AND phantom = 'M'
                  AND LTRIM(t01.material_code,'0') NOT IN (SELECT matl_code FROM recpe_phantom);
                  
               /*-*/   
               /* This is the second operation of a hide duplicate so make value = 0 
               /*-*/
               var_count := 0;
           ELSE
               /*-*/
               /* dont change value since this is not a hide duplicate 
               /*-*/
               var_count := var_count;
           END IF;
       END IF;                              
   END IF;
   

   IF var_count > 1 THEN
       /*-*/
       /* This phase is part of a single step
       /* for a single step rule there should be multiple phase phantoms
       /*
       /* find an associtated hide dup
       /* if this is the same phase as the hide_dup the return 0
       /*
       /* get the first phase */
       /*-*/
       SELECT MIN(phase) INTO var_phase
        FROM cntl_rec_bom 
        WHERE LTRIM(proc_order,'0') = LTRIM(var_proc_order,'0')
          /* JP 4/10/2007 add the next line may fix multiple phantom in 1 phase where the start is not bthe first */
          AND LTRIM(material_code,'0') = LTRIM(var_matl_code,'0')
          AND operation = i_opertn;
          
       IF var_phase = i_phase THEN
           /*-*/
           /* this is the same phase
           /*-*/
           var_result := 'D';
       ELSE
        
           SELECT DECODE(COUNT(*),0,'D','H') INTO var_result
             FROM (SELECT COUNT(*), t02.phase
                    FROM cntl_rec_bom t01,
                         cntl_rec_mpi_val t02,
                         recpe_spcl_cndtn t03
                   WHERE t01.proc_order = t02.proc_order
                     AND t01.operation = t02.operation
                     /* JP 4/10/2007 comment the next line out may fix multiple phantom in 1 phase where the start is not bthe first */
                     --AND t01.phase = t02.phase
                     AND t02.mpi_tag = t03.mpi_tag
                     AND t03.spcl_cndtn_name= 'HIDE_DUPLICATES'
                     AND LTRIM(t01.proc_order,'0') =  LTRIM(var_proc_order,'0')
                     AND t01.phase = trim(var_phase)
                     AND LTRIM(t01.material_code,'0') = LTRIM(var_matl_code,'0')
                   GROUP BY t02.phase);
        
       END IF; 
       
   ELSIF var_count = 1 THEN
       /*-*/
       /* allways display
       /* this is a single phantom within an operation
       /*-*/
       var_result := 'D';
   ELSE
       /*-*/
       /* hide all occurances of materials where the phantom is the same 
       /* as the previous operation
       /*-*/
       SELECT CASE
                  WHEN COUNT(*) = 1 THEN 'H'
                  ELSE 'D' 
              END INTO var_result
         FROM (SELECT COUNT(*), t01.operation 
                 FROM cntl_rec_bom t01
                WHERE LTRIM(t01.proc_order,'0') =  LTRIM(var_proc_order,'0')
                  AND t01.operation = var_work
                  AND LTRIM(t01.material_code,'0') = LTRIM(var_phantom,'0')
                GROUP BY t01.operation) t01;
          
   END IF;  
   
   
   RETURN var_result;
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 'D';
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RETURN 'D';
END Recipe_Disp_Hide;
/


DROP PUBLIC SYNONYM RECIPE_DISP_HIDE;

CREATE PUBLIC SYNONYM RECIPE_DISP_HIDE FOR MANU_APP.RECIPE_DISP_HIDE;


GRANT EXECUTE ON MANU_APP.RECIPE_DISP_HIDE TO PUBLIC;

