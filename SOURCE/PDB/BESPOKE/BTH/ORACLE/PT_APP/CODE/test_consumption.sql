DROP PROCEDURE PT_APP.TEST_CONSUMPTION;

CREATE OR REPLACE PROCEDURE PT_APP.Test_Consumption IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       Test_Consumption
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12-Apr-06          1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Test_Consumption
      Sysdate:         12-Apr-06
      Date and Time:   12-Apr-06, 8:22:41 AM, and 12-Apr-06 8:22:41 AM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
    CURSOR csr_con IS
	  SELECT LTRIM(matl_code,'0'), 0.1*qty FROM cntl_rec_bom
	  WHERE proc_order LIKE '%1008140'
	  AND uom = 'KG' AND qty > 0;
	  
	  var_work VARCHAR2(20);
	  var_work1 NUMBER;
	  x NUMBER;
	  y VARCHAR2(2000);
	  
BEGIN
    OPEN csr_con;
    LOOP
       FETCH csr_con INTO var_work, var_work1;
		 
       EXIT WHEN csr_con%NOTFOUND;
		      Tagsys_Fctry_Intfc.Create_Consumption(x,y,1111,SYSDATE,'AU20','1008140',var_work,var_work1);
    			DBMS_OUTPUT.PUT_LINE('Material=' || var_work || ' Qty=' || var_work1);
	 END LOOP;
    CLOSE csr_con;
    
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Test_Consumption;
/


