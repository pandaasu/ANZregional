DROP FUNCTION MANU_APP.GET_PAN;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Pan (i_proc_order IN VARCHAR2, i_matl_code IN VARCHAR2, i_phase IN NUMBER) RETURN NUMBER IS

/******************************************************************************
   NAME:       Get_Pan 
   PURPOSE:    This function will return the qty of the material based on the 
	            Pan size if used 

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        28-Nov-05          1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Get_Pan
      Sysdate:         28-Nov-05
      Date and Time:   28-Nov-05, 11:59:17 AM, and 28-Nov-05 11:59:17 AM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
    
	 /*-*/
	 /* variable allocations 
	 /*-*/
	 var_result NUMBER DEFAULT 0;
	 --var_pan_qty NUMBER DEFAULT 0;

    /*-*/
	 /* cursor allocations 
	 /*-*/
	 CURSOR cur_phase IS
	 SELECT * FROM cntl_rec_bom
     WHERE LTRIM(proc_order,'0') = LTRIM(i_proc_order,'0')
       AND pan_size_flag = 'Y'
       AND (LTRIM(matl_code,'0') = LTRIM(i_matl_code,'0') OR phantom = 'M')
       AND LTRIM(phase,'0') = LTRIM(i_phase,'0')
     ORDER BY phantom;
	  
	 rcd_phase cur_phase%ROWTYPE;

BEGIN
    
    OPEN cur_phase;
    LOOP
       FETCH cur_phase INTO rcd_phase;
       EXIT WHEN cur_phase%NOTFOUND;
		 IF  (rcd_phase.pan_qty IS NULL OR rcd_phase.pan_qty = '') THEN
		     var_result := rcd_phase.pan_size;
		 ELSE
		     IF rcd_phase.pan_qty = 1  THEN
			      var_result := rcd_phase.pan_size;
			  ELSE
			      var_result := (rcd_phase.pan_size * (rcd_phase.pan_qty - 1  )) + rcd_phase.last_pan_size;
			      --DBMS_OUTPUT.PUT_LINE(rcd_phase.pan_size || '-' || rcd_phase.pan_qty || '-' || rcd_phase.last_pan_size || '-' || var_result);
			  END IF;
			  
		 END IF;
		 EXIT;
    END LOOP;
    CLOSE cur_phase;
    
	/*-*/
	/* if a phantom the value could be null so make the result 0
	/*-*/
	IF var_result = NULL OR var_result = '' THEN
       var_result := 0;
    END IF; 
   
    RETURN ROUND(var_result,3);
	
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       var_result := 0;
END Get_Pan;
/


DROP PUBLIC SYNONYM GET_PAN;

CREATE PUBLIC SYNONYM GET_PAN FOR MANU_APP.GET_PAN;


GRANT EXECUTE ON MANU_APP.GET_PAN TO APPSUPPORT;

