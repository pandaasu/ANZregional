DROP FUNCTION MANU_APP.GET_BOM_BATCH_QTY;

CREATE OR REPLACE FUNCTION MANU_APP.Get_Bom_Batch_Qty(par_matl IN  VARCHAR2) RETURN NUMBER
IS

/*******************************************************************************
    NAME:      Get_Bom_Batch_Qty
    PURPOSE:   Gets tha Batch quantity of the Bom for a given material code 

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   7/7/2004  Jeff Phillipson          Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     VARCHAR2 Load Material                           material code
   \
    

    RETURN VALUE:    Batch qty based on BOM value for material code entered
    ASSUMPTIONS:
    NOTES:       
  ********************************************************************************/
   
   var_matl    VARCHAR2(8);
   var_qty     NUMBER;
   
   CURSOR c1
   IS
  
   SELECT DISTINCT bom_base_qty batch_qty 
  FROM TABLE(bds_bom.get_dataset(SYSDATE,var_matl,NULL));
      
          
BEGIN
     
   var_matl := LTRIM(par_matl,'0');
   OPEN c1;
      LOOP
         FETCH c1 INTO var_qty;
        -- DBMS_OUTPUT.PUT_LINE('VALUE OK qty- ' || v_qty || '-' ||  v_seq || '-' ||  v_matl || '-' ||  v_sub);
         EXIT WHEN c1%NOTFOUND;
         EXIT ;
   END LOOP;
   CLOSE c1;
   
   RETURN var_qty;
   
EXCEPTION

    WHEN OTHERS THEN

        --Raise an error 
      RAISE_APPLICATION_ERROR(-20000, 'MANU. Get_BOM_BATCH_QTY function - ' || SUBSTR(SQLERRM, 1, 512));


END;
/


DROP PUBLIC SYNONYM GET_BOM_BATCH_QTY;

CREATE PUBLIC SYNONYM GET_BOM_BATCH_QTY FOR MANU_APP.GET_BOM_BATCH_QTY;


