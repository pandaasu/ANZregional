DROP FUNCTION MANU_APP.GET_BOM_BATCH_QTY;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Bom_Batch_Qty(matl IN  VARCHAR2) RETURN NUMBER
IS
/****************************************************

Function to get the alternate version number for the material entered 

This is used to provide BOM quantity data in VIEW RECIPE_FCS_VW 
rather than the process order quantity

The output is the correct qty based on BOM value number to use 
   
     
Author:  Jeff Phillipson  7/10/2004 

****************************************************/

   
   v_matl    VARCHAR2(8);
   v_qty     NUMBER;
   
   CURSOR c1
   IS
   SELECT DISTINCT batch_qty FROM bom_vw r
       WHERE material = v_matl
       AND alternate = Get_Alternate(material) 
       AND eff_start_date = Get_Alternate_Date(material);
       
       
   
BEGIN
     
   v_matl := LTRIM(matl,'0');
   OPEN c1;
      LOOP
         FETCH c1 INTO v_qty;
        -- DBMS_OUTPUT.PUT_LINE('VALUE OK qty- ' || v_qty || '-' ||  v_seq || '-' ||  v_matl || '-' ||  v_sub);
         EXIT WHEN c1%NOTFOUND;
         EXIT ;
   END LOOP;
   CLOSE c1;
   
   RETURN v_qty;
   
EXCEPTION

    
    
    WHEN OTHERS THEN

        --Raise an error 
     	RAISE_APPLICATION_ERROR(-20000, 'MANU. Get_BOM_BATCH_QTY function - ' || SUBSTR(SQLERRM, 1, 512));


END;
/


GRANT EXECUTE ON MANU_APP.GET_BOM_BATCH_QTY TO APPSUPPORT;

