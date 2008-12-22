DROP FUNCTION MANU_APP.UPDATE_BATCHED_IDS;

CREATE OR REPLACE FUNCTION MANU_APP.Update_Batched_Ids 

RETURN NUMBER

IS
   success NUMBER;
  
   vcount NUMBER;
   vold NUMBER;
   vnew NUMBER;
   
   /* declare package cursor specification */
   CURSOR c1 IS 
   SELECT x.material_code FROM SITE_BATCHED_matl x, material_vw m
   WHERE x.material_code = m.old_MATERIAL_code;
  
   CURSOR c2 IS
   SELECT TO_NUMBER(m.material_code) FROM  material_vw m
   WHERE  old_material_code  = TO_CHAR(vold);
  
   
   
BEGIN
    vcount := 1;
    OPEN c1;
    DBMS_OUTPUT.PUT_LINE('VALUE OK  ');
    LOOP
       FETCH c1 INTO vold;
       EXIT WHEN c1%NOTFOUND;
       DBMS_OUTPUT.PUT_LINE('VALUE OK 1 ');
          OPEN c2;
              FETCH c2 INTO vnew;
              EXIT WHEN c2%NOTFOUND;
              UPDATE site_batched_matl SET material_code = vnew
              WHERE material_code = vold;
              --DBMS_OUTPUT.PUT_LINE('VALUE OK new ' || vnew || ' old ' || vold);
              vcount := vcount + 1;
       CLOSE c2;
    END LOOP;
    CLOSE c1;
    success := vcount;
    
   RETURN success;
END;
/


DROP PUBLIC SYNONYM UPDATE_BATCHED_IDS;

CREATE PUBLIC SYNONYM UPDATE_BATCHED_IDS FOR MANU_APP.UPDATE_BATCHED_IDS;


