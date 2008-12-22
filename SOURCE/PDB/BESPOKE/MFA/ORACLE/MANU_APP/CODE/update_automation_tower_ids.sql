DROP FUNCTION MANU_APP.UPDATE_AUTOMATION_TOWER_IDS;

CREATE OR REPLACE FUNCTION MANU_APP.Update_Automation_tower_Ids 

RETURN NUMBER

IS

   /*********************************************
  Converson Only
  
  will convert Site_Automation Material /Item codes to the latest material code 
  
  J.Phillipson 23 Aug 2004 
  
  *********************************************/
  
  
   success NUMBER;
  
   vcount NUMBER;
   vold NUMBER;
   vnew NUMBER;
   
   /* declare package cursor specification */
   CURSOR c1 IS 
   SELECT x.tag_or_num FROM SITE_AUTOMATION_TOWER x, material_vw m
   WHERE x.tag_or_num = m.old_MATERIAL_code;
  
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
              UPDATE site_automation_tower SET tag_or_num = vnew
              WHERE tag_or_num = vold;
              DBMS_OUTPUT.PUT_LINE('VALUE OK new ' || vnew || ' old ' || vold);
              vcount := vcount + 1;
       CLOSE c2;
    END LOOP;
    CLOSE c1;
    success := vcount;
    
   RETURN success;
END;
/


DROP PUBLIC SYNONYM UPDATE_AUTOMATION_TOWER_IDS;

CREATE PUBLIC SYNONYM UPDATE_AUTOMATION_TOWER_IDS FOR MANU_APP.UPDATE_AUTOMATION_TOWER_IDS;


