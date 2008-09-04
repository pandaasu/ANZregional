DROP PROCEDURE MANU_APP.DELETE_RECPE;

CREATE OR REPLACE PROCEDURE MANU_APP.Delete_Recpe IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       Delete_Recpe
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07-Sep-05          1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Delete_Recpe
      Sysdate:         07-Sep-05
      Date and Time:   07-Sep-05, 3:38:43 PM, and 07-Sep-05 3:38:43 PM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

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
	 
	 
	/*-*/
	/* delete Re timing records 
	/*-*/
	 DELETE FROM cntl_rec_lcl_resrce
	 WHERE proc_order NOT IN (SELECT LTRIM(proc_order,'0') FROM cntl_rec);
	 
    DELETE FROM cntl_rec_lcl
	 WHERE proc_order NOT IN (SELECT LTRIM(proc_order,'0') FROM cntl_rec);
	 
	 
	COMMIT;
	
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Delete_Recpe;
/


DROP PUBLIC SYNONYM DELETE_RECPE;

CREATE PUBLIC SYNONYM DELETE_RECPE FOR MANU_APP.DELETE_RECPE;


GRANT EXECUTE ON MANU_APP.DELETE_RECPE TO APPSUPPORT;

GRANT EXECUTE ON MANU_APP.DELETE_RECPE TO BTHSUPPORT;

