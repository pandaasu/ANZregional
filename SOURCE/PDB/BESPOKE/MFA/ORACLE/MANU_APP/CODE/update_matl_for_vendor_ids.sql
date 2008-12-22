DROP FUNCTION MANU_APP.UPDATE_MATL_FOR_VENDOR_IDS;

CREATE OR REPLACE FUNCTION MANU_APP.Update_Matl_For_Vendor_Ids 

RETURN NUMBER

IS

   /*********************************************
  Converson Only
  
  will convert Site_Matl_rsupplier_xref Item codes to the latest material code 
  
  J.Phillipson 23 Aug 2004 
  
  *********************************************/
  
  
   success NUMBER;
  
   vcount NUMBER;
   vold NUMBER;
   vnew NUMBER;
   
   /* declare package cursor specification */
   CURSOR c1 IS 
   SELECT x.matl_code FROM SITE_MATL_supplier_XREF x, material_plan_vw m
   WHERE x.matl_code = m.old_MATERIAL_code;
  
   CURSOR c2 IS
   SELECT TO_NUMBER(m.material_code) FROM  material_vw m
   WHERE  old_material_code  = TO_CHAR(vold);
  
   
   
BEGIN
    vcount := 0;
    OPEN c1;
    DBMS_OUTPUT.PUT_LINE('VALUE OK  ');
    LOOP
       FETCH c1 INTO vold;
       EXIT WHEN c1%NOTFOUND;
       DBMS_OUTPUT.PUT_LINE('VALUE OK 1 ');
          OPEN c2;
              FETCH c2 INTO vnew;
              EXIT WHEN c2%NOTFOUND;
              UPDATE site_matl_supplier_xref SET matl_code = vnew
              WHERE matl_code = vold;
              --DBMS_OUTPUT.PUT_LINE('VALUE OK new ' || vnew || ' old ' || vold);
              vcount := vcount + 1;
       CLOSE c2;
    END LOOP;
    CLOSE c1;
    success := vcount;
    DBMS_OUTPUT.PUT_LINE('Total converted ' || vcount);
    
   RETURN success;
END;
/


DROP PUBLIC SYNONYM UPDATE_MATL_FOR_VENDOR_IDS;

CREATE PUBLIC SYNONYM UPDATE_MATL_FOR_VENDOR_IDS FOR MANU_APP.UPDATE_MATL_FOR_VENDOR_IDS;


