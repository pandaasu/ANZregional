DROP FUNCTION MANU_APP.GET_BOM_QTY;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Bom_Qty(matl IN  VARCHAR2, sub IN VARCHAR2, seq IN VARCHAR2) RETURN NUMBER
IS
/****************************************************

Function to get the alternate version number for the material entered 

This is used to provide BOM quantity data in VIEW RECIPE_FCS_VW 
rather than the process order quantity

The output is the correct qty based on BOM value number to use 
   
     
Author:  Jeff Phillipson  7/7/2004 

****************************************************/

   
   v_matl    VARCHAR2(8);
   v_sub     VARCHAR2(8);
   v_seq     VARCHAR2(4);
   v_qty     NUMBER;
   
   CURSOR c1
   IS
   SELECT MAX(qty) qty 
       FROM (
       SELECT LEVEL lvl, material, sub_matl,qty, seq FROM bom r
       WHERE LEVEL < 2
       START WITH material = v_matl
       AND alternate = Get_Alternate(material) 
       AND eff_start_date = Get_Alternate_Date(material)
       CONNECT BY PRIOR sub_matl = material
       ) r
       WHERE  sub_matl = v_sub
       AND LTRIM(seq,'0') = v_seq;
       
       
   
BEGIN
     
   v_matl := LTRIM(matl,'0');
   v_sub :=  LTRIM(sub,'0');
   v_seq :=  LTRIM(seq,'0');
   IF LENGTH(v_seq) = 0 THEN
      v_seq := '0';
   END IF;
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
     	RAISE_APPLICATION_ERROR(-20000, 'MANU. Get_BOM_QTY function - ' || SUBSTR(SQLERRM, 1, 512));


END;
/


DROP PUBLIC SYNONYM GET_BOM_QTY;

CREATE PUBLIC SYNONYM GET_BOM_QTY FOR MANU_APP.GET_BOM_QTY;


GRANT EXECUTE ON MANU_APP.GET_BOM_QTY TO APPSUPPORT;

