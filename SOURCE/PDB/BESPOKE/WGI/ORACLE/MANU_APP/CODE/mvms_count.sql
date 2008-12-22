DROP FUNCTION MANU_APP.MVMS_COUNT;

CREATE OR REPLACE FUNCTION MANU_APP.Mvms_Count( matl IN VARCHAR2) RETURN NUMBER IS

/******************************************************************************
   NAME:       MVMS_COUNT
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        24/02/2005   Jeff Phillipson 1. Created this function.
   1.01       19/02/2008   Beau Frericks   2. Updated SQL on FIND the quantity of the RSU to the 
                                              TDU  oninclude a filter on finshed goods only

   This function will attempt to find the quantity of MPOs used to create the FG number
   sent into the function
   
   Results: if not a FG - 0 is returned
            if a FG with no MPOs - 0 is retunred 
            if FG with MPOs then the total qty calculated by getting the individual 
               piece quantity and multiplying by the TDU - RSU quantity.
               
******************************************************************************/
    v_count    NUMBER;
    NAME               CONSTANT VARCHAR2(100) := 'MVMS_Count function';
    
                                                                              
BEGIN
    
    v_count := 0;
    
    -- check if the number is a FG 
    
    IF (ASCII(RTRIM(LTRIM(SUBSTR(matl,1,1)))) >= 48 
        AND  ASCII(RTRIM(LTRIM(SUBSTR(matl,1,1)))) <= 57 
        AND LENGTH(matl)  = 8) 
        OR (ASCII(RTRIM(LTRIM(SUBSTR(matl,1,1)))) > 57) THEN
        
           -- numeric of 8 chars long 
           -- or alpha numeric 
           --dbms_output.put_line (matl);
           
        SELECT DECODE(SUM(r.qty * x.qty), NULL, 0, SUM(r.qty * x.qty)) qty INTO v_count
          FROM (
               -- Find all materials defined by PCE or SB if in NZ11 ( all the MPOs) 
               SELECT LEVEL lvl,  MATERIAL, sub_matl, qty,uom, alternate, ROWNUM id, batch_qty 
                 FROM bom 
                WHERE   uom = 'PCE' OR uom = 'SB'
                START WITH MATERIAL = matl 
                  AND alternate = Get_Alternate(MATERIAL) 
                  AND eff_start_date = Get_Alternate_Date(MATERIAL)
              CONNECT BY PRIOR sub_matl = MATERIAL 
                  AND alternate = Get_Alternate(MATERIAL) 
                  AND eff_start_date = Get_Alternate_Date(MATERIAL)
               ) r, 
               (
               -- FIND the quantity of the RSU to the TDU 
               SELECT qty  
                 FROM bom
                WHERE MATERIAL = matl
                  AND alternate = Get_Alternate(MATERIAL) 
                  AND eff_start_date = Get_Alternate_Date(MATERIAL)
                  AND uom = 'EA' and length(sub_matl) = 8
               ) x 
        ORDER BY id;
        
    END IF;
    
    RETURN v_count;
   
   
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN v_count;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RETURN v_count;
END Mvms_Count;
/


GRANT EXECUTE ON MANU_APP.MVMS_COUNT TO PT_APP WITH GRANT OPTION;

GRANT EXECUTE ON MANU_APP.MVMS_COUNT TO PUBLIC;

GRANT EXECUTE ON MANU_APP.MVMS_COUNT TO SHIFTLOG WITH GRANT OPTION;

GRANT EXECUTE ON MANU_APP.MVMS_COUNT TO SHIFTLOG_APP WITH GRANT OPTION;

