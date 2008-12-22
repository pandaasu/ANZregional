DROP PROCEDURE MANU_APP.VALIDATE_SNAPSHOTS;

CREATE OR REPLACE PROCEDURE MANU_APP.Validate_Snapshots IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       Validate_Snapshots
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        25-Oct-06   Jeff Phillipson  1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Validate_Snapshots
      Sysdate:         25-Oct-06
      Date and Time:   25-Oct-06, 9:03:39 AM, and 25-Oct-06 9:03:39 AM
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

    CURSOR csr_snap IS
	SELECT table_name, last_refresh 
	  FROM ALL_SNAPSHOTS 
	 WHERE owner = 'MANU' AND TYPE = 'COMPLETE';
	 
	rcd_snap csr_snap%ROWTYPE;
	 
	var_count 				  NUMBER;
	
BEGIN

    OPEN csr_snap;
    LOOP
       FETCH csr_snap INTO rcd_snap;
       EXIT WHEN csr_snap%NOTFOUND;
	   
	   EXECUTE IMMEDIATE 'SELECT count(*) from MANU.' || rcd_snap.table_name
	      INTO var_count;
	   IF var_count = 0 THEN
	       DBMS_OUTPUT.PUT_LINE('ERROR ' || rcd_snap.table_name || ' has zero records at' || TO_CHAR(SYSDATE,'dd-mon-yyyy hh24:mi:ss') || ' Last refresh at ' || TO_CHAR(rcd_snap.last_refresh,'dd-mon-yyyy hh24:mi:ss'));
	   END IF;
    END LOOP;
    CLOSE csr_snap;
    
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Validate_Snapshots;
/


