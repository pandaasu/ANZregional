DROP FUNCTION MANU_APP.GET_ALTERNATE_DATE_PLANT;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Alternate_Date_Plant(par_matl IN  VARCHAR2, par_plant IN VARCHAR2, par_xdate IN DATE DEFAULT SYSDATE) RETURN DATE
IS

/*******************************************************************************
    NAME:      Get_Alternate_Date_Plant
    PURPOSE:   Function to get the alternate version date for the material entered 
               his is used to provide BOM data in VIEW BOM_NOW_VW which only 
					provides valid data based on SYSDATE ie the time it is viewed - now

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   7/7/2004  Jeff Phillipson          Created this procedure.
    1.1   11/1/2008 Daniel Owen           Added plant filter

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 Load Material                           material code
    2    IN     VARCHAR2 Plant                                AU20
    3    IN     DATE     Input date - default is sysdate      date of interest
    

    RETURN VALUE:			 correct Alternate date to use 
    ASSUMPTIONS:
    NOTES:		 			 This is used in conjunction with GET_ALTERNATE_DATE to get the 
     							 correct date.
  ********************************************************************************/
  
   var_alt    DATE;
  
BEGIN
   
   SELECT r.eff_start_date 
   INTO var_alt
   FROM (SELECT DECODE(alt,NULL,'1', alt) alt, eff_start_date
   FROM MANU.BOM 
   WHERE MATL_CODE = par_matl 
   AND eff_start_date <= par_xdate
   and plant = par_plant
   ORDER BY 2 DESC) r WHERE ROWNUM = 1;
   
   RETURN var_alt;
   
EXCEPTION
    WHEN OTHERS THEN
        --Raise an error 
     	RAISE_APPLICATION_ERROR(-20000, 'MANU.Get_Alternate_Date_Plant function - ' || SUBSTR(SQLERRM, 1, 512));

END;
/


