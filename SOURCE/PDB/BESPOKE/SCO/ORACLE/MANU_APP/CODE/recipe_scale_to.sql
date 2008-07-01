DROP FUNCTION MANU_APP.RECIPE_SCALE_TO;

CREATE OR REPLACE FUNCTION MANU_APP.Recipe_Scale_To(i_proc_order IN VARCHAR2,
                                     i_opertn IN VARCHAR2,
                                     i_matl_code IN VARCHAR2) RETURN VARCHAR2 IS

/******************************************************************************
   NAME:       Recipe_Scale_To
   PURPOSE:    determine if the material should scaled to Parent or BOM
       
   RETURN:     SB - Scale to BOM
               SP - Scale to parent
               NO - None
   INPUT:      Proc_order
               opertn
               phase
               matl_code
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        8/06/2007   Jeff Phillipson       1. Created this function.
   RULES:
   SINGLE STEP 
   OPERATION   1 PHANTOM
            PHASE    -  SRC 1997 or 1999    SINGLE STEP
            PHASE   } 
            PHASE   } all scale
            PHASE   }
   MULTI STEP
   OPERATION  MULTI PHANTOMS
            PHASE   -   SRC 1997    scale per phase
            PHASE   -   SRC 
            PHASE   -   SRC 
            PHASE   -   SRC 
   
******************************************************************************/
    
    var_count NUMBER;
    var_result VARCHAR2(200);
    
    CURSOR csr_scale 
    IS
    SELECT CASE
                 WHEN COUNT = 1 AND spcl_cndtn_name = 'SCALE_TO_BOM' THEN 'SB'
                 WHEN COUNT = 1 AND spcl_cndtn_name = 'SCALE_TO_PARENT' THEN 'SP'
                 ELSE 'NO'
              END scale INTO var_result
         FROM (SELECT COUNT(*) COUNT, t03.spcl_cndtn_name
                 FROM cntl_rec_bom t01,
                      cntl_rec_mpi_val t02,
                      (SELECT mpi_tag, spcl_cndtn_name 
                         FROM recpe_spcl_cndtn
                         WHERE  spcl_cndtn_name IN ('SCALE_TO_PARENT', 'SCALE_TO_BOM')) t03
                WHERE t01.proc_order = t02.proc_order
                  AND t01.opertn = t02.opertn
                  AND t02.mpi_tag = t03.mpi_tag
                  AND LTRIM(t01.proc_order,'0') =  LTRIM(i_proc_order,'0')
                  AND t01.opertn = i_opertn
                  AND LTRIM(t01.matl_code,'0') = LTRIM(i_matl_code,'0')
                GROUP BY spcl_cndtn_name) t01
                ORDER BY 1;
                
             
BEGIN

   
   SELECT COUNT(*) INTO var_count
     FROM cntl_rec_bom
    WHERE LTRIM(proc_order,'0') = LTRIM(i_proc_order,'0')
      AND LTRIM(MATL_CODE,'0') NOT IN (SELECT LTRIM(matl_code,'0') FROM RECPE_PHANTOM)
      AND opertn = i_opertn
      AND phantom = 'M';
   IF var_count > 1 THEN
       /*-*/
       /* This phase is part of a single step
       /* for a single step rule there should be multiple phase phantoms
       /*-*/
       /* find an associtated hide dup
       /* if this is the same phase as the hide_dup the return 0
       /*-*/     
       var_result := 'NO';
   ELSIF var_count = 1 THEN
       --DBMS_OUTPUT.PUT_LINE('here07'||i_proc_order||i_matl_code||i_opertn);
       /*-*/
       /* This is a 1 phantom so make all ingredients within the operation scale if appropriate
       /*-*/
        OPEN csr_scale;
        LOOP
           FETCH csr_scale INTO var_result;
           IF csr_scale%NOTFOUND THEN
               var_result := 'NO';
           END IF;
           EXIT;
        END LOOP;
        CLOSE csr_scale;
   ELSE
       var_result := 'NO';
   END IF;  
   
   
   RETURN var_result;
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN 'NO';
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RETURN 'NO';
END Recipe_Scale_To;
/


DROP PUBLIC SYNONYM RECIPE_SCALE_TO;

CREATE PUBLIC SYNONYM RECIPE_SCALE_TO FOR MANU_APP.RECIPE_SCALE_TO;


GRANT EXECUTE ON MANU_APP.RECIPE_SCALE_TO TO APPSUPPORT;

