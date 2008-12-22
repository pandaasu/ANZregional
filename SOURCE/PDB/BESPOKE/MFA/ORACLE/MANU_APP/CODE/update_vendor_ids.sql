DROP FUNCTION MANU_APP.UPDATE_VENDOR_IDS;

CREATE OR REPLACE FUNCTION MANU_APP.Update_Vendor_Ids 

RETURN NUMBER

IS

  /*********************************************
  Converson Only 
  
  will convert Vendor Ids for SITE_MATL_SUPPLIER_XREF table
  Item codes to the latest material code 
  
  J.Phillipson 23 Aug 2004 
  
  *********************************************/
  
   success NUMBER;
  
   vcount NUMBER;
   vold NUMBER;
   vnew NUMBER;
   vvndr NUMBER;
   
   /* declare package cursor specification */
   CURSOR c1 IS 
   SELECT DISTINCT vndr_nmbr FROM SITE_MATL_SUPPLIER_XREF x, VNDR_XREF m
   WHERE x.vndr_nmbr = m.old_code --AND plant = 'AU10'
   ORDER BY 1;
  
   CURSOR c2 IS
   SELECT TO_NUMBER(m.vndr_code) FROM  VNDR_XREF m
   WHERE  old_code  = TO_CHAR(vold);
  
   
   
BEGIN
    vcount := 1;
    OPEN c1;
    DBMS_OUTPUT.PUT_LINE('VALUE OK  ');
    LOOP
       FETCH c1 INTO vold;
       EXIT WHEN c1%NOTFOUND;
          OPEN c2;
              FETCH c2 INTO vnew;
              EXIT WHEN c2%NOTFOUND;
              SELECT COUNT(*) INTO vvndr  FROM SITE_MATL_SUPPLIER_XREF 
              WHERE  vndr_nmbr = TO_CHAR(vnew);
              IF vvndr = 0 THEN
                  UPDATE SITE_MATL_SUPPLIER_XREF SET vndr_nmbr = TO_CHAR(vnew)
                  WHERE vndr_nmbr = TO_CHAR(vold);
              END IF;

              --DBMS_OUTPUT.PUT_LINE('VALUE OK new ' || vnew || ' old ' || vold || ' changed? ' || SQL%rowcount);
              vcount := vcount + 1;
       CLOSE c2;
    END LOOP;
    CLOSE c1;
    success := vcount;
    DBMS_OUTPUT.PUT_LINE('Converted No.' || vcount);
   RETURN success;
END;
/


DROP PUBLIC SYNONYM UPDATE_VENDOR_IDS;

CREATE PUBLIC SYNONYM UPDATE_VENDOR_IDS FOR MANU_APP.UPDATE_VENDOR_IDS;


