DROP FUNCTION MANU_APP.GET_ALTERNATE_DATE;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Alternate_Date(matl IN  VARCHAR2, xdate IN DATE DEFAULT SYSDATE) RETURN DATE
IS
/****************************************************

Function to get the alternate no for the material entered 

This is used to provide BOM data in VIEW BOM_NOW_VW which only
provides valid data based on SYSDATE ie the time it is viewed.

Note this is used in conjunction with GET_ALTERNATE to get the 
     correctalternate value 
     

Author:  Jeff Phillipson  7/7/2004 

****************************************************/

   
   v_alt    DATE;
  
   
BEGIN
   
   SELECT r.eff_start_date 
   INTO v_alt
   FROM (SELECT DECODE(alternate,NULL,'1', alternate) alternate, eff_start_date
   FROM BOM_vw 
   WHERE MATERIAL = matl 
   AND eff_start_date <= xdate
   ORDER BY 2 DESC) r WHERE ROWNUM = 1;
   
   RETURN v_alt;
   
EXCEPTION
    WHEN OTHERS THEN

        --Raise an error 
     	RAISE_APPLICATION_ERROR(-20000, 'MANU.Get_Alternate function - ' || SUBSTR(SQLERRM, 1, 512));


END;
/


GRANT EXECUTE ON MANU_APP.GET_ALTERNATE_DATE TO APPSUPPORT;

