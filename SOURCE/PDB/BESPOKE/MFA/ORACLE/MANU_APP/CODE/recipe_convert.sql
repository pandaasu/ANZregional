DROP PROCEDURE MANU_APP.RECIPE_CONVERT;

CREATE OR REPLACE PROCEDURE MANU_APP.Recipe_Convert IS

/******************************************************************************
   NAME:       Rec_Convert_Test
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2005          1. Created this procedure.

   NOTES:     Used to test the Recipe Conversion application 

   Automatically available Auto Replace Keywords:
      Object Name:     Rec_Convert_Test
      Sysdate:         22/08/2005
      
******************************************************************************/
   
   /*-*/
   /* Private exceptions
   /*-*/
   application_exception EXCEPTION;
   PRAGMA EXCEPTION_INIT(application_exception, -20000);
   
   /*-*/
   /* variables
   /*-*/
   var_work NUMBER(18);
    
   /*-*/
   /* cursors
   /*-*/
   CURSOR csr_cntl_rec IS
      SELECT cntl_rec_id 
        FROM cntl_rec
       WHERE cntl_rec_id NOT IN (SELECT cntl_rec_id FROM recpe_hdr)
     AND teco_status = 'NO'
     AND run_start_datime > sysdate;
   
BEGIN
  
   --DELETE FROM recpe_resource;
   --DELETE FROM recpe_dtl;
   --DELETE FROM recpe_hdr;
    
   OPEN csr_cntl_rec;
   LOOP
      FETCH csr_cntl_rec INTO var_work;
         IF NOT csr_cntl_rec%NOTFOUND THEN
            Recipe_Conversion.EXECUTE(var_work);
         ELSE
            EXIT;
         END IF;
      END LOOP;
   CLOSE csr_cntl_rec;
   
   COMMIT;
   
   /*-*/
   /* finished 
   /*-*/
   
   EXCEPTION
   
      WHEN OTHERS THEN
         /*-*/
         /* Rollback the database
         /*-*/
         ROLLBACK;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         RAISE_APPLICATION_ERROR(-20000, 'Recipe_Conversion - using Cntl Rec Id ' || var_work || CHR(13)
             || 'Oracle error ' || SUBSTR(SQLERRM, 1, 512));
             
             
END Recipe_Convert;
/


