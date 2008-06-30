DROP PROCEDURE MANU_APP.RECIPE_PURGE;

CREATE OR REPLACE PROCEDURE MANU_APP.Recipe_Purge IS
/******************************************************************************
   NAME:       Delete_Recpe
   PURPOSE:    
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07-Sep-05          1. Created this procedure.
   NOTES:
   This procedure will delete all records from the RECPE_.. tables
   where they don't exist in the main proc_order table
******************************************************************************/

   
BEGIN
	/*-*/
	/* delete recipe records 
	/*-*/
   DELETE FROM recpe_dtl
	 WHERE cntl_rec_id NOT IN (SELECT cntl_rec_id FROM cntl_rec);

   DELETE FROM recpe_resrce
    WHERE cntl_rec_id NOT IN (SELECT cntl_rec_id FROM cntl_rec);

   DELETE FROM recpe_val
    WHERE cntl_rec_id NOT IN (SELECT cntl_rec_id FROM cntl_rec);
	 
   DELETE FROM recpe_hdr
    WHERE cntl_rec_id NOT IN (SELECT cntl_rec_id FROM cntl_rec);
	 
	 
	COMMIT;
	
   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20000, 'Recipe_Purge failed ' 
			 || 'Oracle error ' || SUBSTR(SQLERRM, 1, 1000));
END Recipe_Purge;
/


DROP PUBLIC SYNONYM RECIPE_PURGE;

CREATE PUBLIC SYNONYM RECIPE_PURGE FOR MANU_APP.RECIPE_PURGE;


GRANT EXECUTE ON MANU_APP.RECIPE_PURGE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.RECIPE_PURGE TO LICS_APP;

