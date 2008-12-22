DROP PROCEDURE MANU_APP.UPDATE_MATL_SUPPLIER_TABLE;

CREATE OR REPLACE PROCEDURE MANU_APP.Update_Matl_Supplier_Table 


IS

  /********************************************************
  This procedure is desgned to run under a scheduled job 
  It will add cross reference data for vendor and material 
  as they apear in a purchase order .
  
  This table has to be maintained this way since Purchase Orders
  will be removed when several months old from the Lads Tables
  
  J Phillipson 1 Sep 2004 
  **********************************************************/
  
  
   success NUMBER;
   vcount  NUMBER;
   vold    NUMBER;
   vnew    NUMBER;
   
   /* declare package cursor specification */
   CURSOR c1 IS 
   SELECT * FROM food_dmr_po
   WHERE plant = 'AU10'
   AND vndr_nmbr NOT IN (SELECT vndr_nmbr FROM site_matl_supplier_xref)
   AND matl_code NOT IN (SELECT matl_code FROM site_matl_supplier_xref);
   
   r1 food_dmr_po%ROWTYPE;

   
    /*********************************************
     RAISE email notification OF error
     **********************************************/
     PROCEDURE raiseNotification(message IN VARCHAR2)
     IS
     
         vmessage VARCHAR2(4000);
         
     BEGIN
          vmessage := message;
          Mailout(vmessage);
     EXCEPTION
         WHEN OTHERS THEN
         vmessage := message;
     END;
     
     
   
BEGIN
    vcount := 0;
    
    -- DBMS_OUTPUT.PUT_LINE('Start insert of new records in SITE_MATL_SUPPLIER_XREF table ');
    OPEN c1;
    LOOP
       FETCH c1 INTO r1;
       EXIT WHEN c1%NOTFOUND;
         INSERT INTO site_matl_supplier_xref
         VALUES (
               LTRIM(r1.vndr_nmbr,'0'),
               r1.vndr_name,
               r1.prchsng_org,
               r1.prchsng_group,
               r1.matl_code,
               r1.base_uom,
               r1.plant);
              
         -- DBMS_OUTPUT.PUT_LINE('New entry - vendor ' || r1.vndr_nmbr || ' material ' || r1.matl_code);
          vcount := vcount + 1;
   
    END LOOP;
    CLOSE c1;
    success := vcount;
    DBMS_OUTPUT.PUT_LINE('Update_Matl_Supplier_Table  completed Sucsesfully on ' || SYSDATE || ' Records updated ' || vcount);
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
         raiseNotification('MANU_APP.Update_Matl_Supplier_Table - Unable to update record because of: '|| SUBSTR(SQLERRM, 1, 512) || 'Vendor No.-' || r1.vndr_nmbr);     
  
END;
/


DROP PUBLIC SYNONYM UPDATE_MATL_SUPPLIER_TABLE;

CREATE PUBLIC SYNONYM UPDATE_MATL_SUPPLIER_TABLE FOR MANU_APP.UPDATE_MATL_SUPPLIER_TABLE;


