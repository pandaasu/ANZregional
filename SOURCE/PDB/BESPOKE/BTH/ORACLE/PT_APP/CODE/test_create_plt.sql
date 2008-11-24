DROP PROCEDURE PT_APP.TEST_CREATE_PLT;

CREATE OR REPLACE PROCEDURE PT_APP.Test_Create_Plt( proc_order IN VARCHAR2, plt_code IN NUMBER DEFAULT 0) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       Test_Create_Plt
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12-Apr-06          1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Test_Create_Plt
      Sysdate:         12-Apr-06
      Date and Time:   12-Apr-06, 9:11:58 AM, and 12-Apr-06 9:11:58 AM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

    CURSOR csr_p IS
	 SELECT LTRIM(matl_code,'0') matl_code, strge_locn, plant, uom, qty 
	 FROM manu.cntl_rec
	 WHERE proc_order = LPAD(trim(proc_order),12,'0');
	 
	 rcd_p csr_p%ROWTYPE;  
	 
	 v_plt_code NUMBER;
	 x NUMBER;
	 y VARCHAR2(2000);
	 
BEGIN
 
     	IF plt_code = 0 THEN
		    v_plt_code := 11111111;
		ELSE
		    v_plt_code := plt_code;
	   END IF;
	
       OPEN csr_p;
       LOOP
          FETCH csr_p INTO rcd_p;
          EXIT WHEN csr_p%NOTFOUND;
			 DBMS_OUTPUT.PUT_LINE('Material=x');
			    Tagsys_Fctry_Intfc.Create_Pllt(x,y,
				 										SYSDATE, 
				 										rcd_p.plant,
				 										'TEST',
														'601AMWODMY', 
														proc_order,
														' ',
				 										SYSDATE+365,
														LTRIM(rcd_p.matl_code,'0'),  
														v_plt_code, 
														99, 
														'Y',
														'PHILLJEF',
														'',
														'A', 
				 										SYSDATE,
				 										SYSDATE);
    			 DBMS_OUTPUT.PUT_LINE('Material=' || rcd_p.matl_code);
				 EXIT;
       END LOOP;
       CLOSE csr_p;
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Test_Create_Plt;
/


DROP PUBLIC SYNONYM TEST_CREATE_PLT;

CREATE PUBLIC SYNONYM TEST_CREATE_PLT FOR PT_APP.TEST_CREATE_PLT;


GRANT EXECUTE ON PT_APP.TEST_CREATE_PLT TO APPSUPPORT;

GRANT EXECUTE ON PT_APP.TEST_CREATE_PLT TO BTHSUPPORT;

GRANT EXECUTE ON PT_APP.TEST_CREATE_PLT TO PUBLIC;

