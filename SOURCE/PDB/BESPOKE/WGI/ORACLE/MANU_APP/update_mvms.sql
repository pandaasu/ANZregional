DROP PROCEDURE MANU_APP.UPDATE_MVMS;

CREATE OR REPLACE PROCEDURE MANU_APP."UPDATE_MVMS" IS

/******************************************************************************
   NAME:       Update_MVMS
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        7/03/2005   Jeff Phillipson 1. Created this procedure.

   NOTES      This procedure will run every hour to update all FG (TDUs) to MPO links
              The table is required for Shiftlog to be able to define MPOs required for
              any FG (SKU code)
              
              Plant NZ11 was added so that all MPOs from that site will be incorporated
              under NZ11 the UOM is 'SB'
              under NZ01 the UOM is 'PCE'
  
******************************************************************************/
    V_matl                VARCHAR2(8); 
                                                                             
    CURSOR c_mvms
    IS
    SELECT DISTINCT material_code 
      FROM material_plan
     WHERE material_type = 'FERT'
       AND TDU_CODE = 'X' 
       AND plant IN ('NZ01','NZ11') 
       AND plant_sts = '20'
     ORDER BY 1;
    
    rcd c_mvms%ROWTYPE;
    
     CURSOR c_MPO 
     IS
     --SELECT DISTINCT material, LEVEL lvl,   sub_matl, qty,uom
     --        FROM bom 
     --        WHERE   (uom = 'PCE' OR uom = 'SB')
     --        START WITH MATERIAL = v_matl AND alternate = Get_Alternate(MATERIAL) AND eff_start_date = Get_Alternate_Date(MATERIAL)
     --        CONNECT BY PRIOR sub_matl = MATERIAL;
             
     SELECT r.* FROM (
     SELECT material, LEVEL lvl,   sub_matl, qty,uom, ROWNUM id
       FROM bom  
      START WITH MATERIAL = v_matl AND alternate = Get_Alternate(MATERIAL) AND eff_start_date = Get_Alternate_Date(MATERIAL) 
    CONNECT BY PRIOR sub_matl = MATERIAL AND alternate = Get_Alternate(MATERIAL) AND eff_start_date = Get_Alternate_Date(MATERIAL) 
            ) r 
      WHERE (r.uom = 'PCE' OR r.uom = 'SB');
             
     rcd1 c_mpo%ROWTYPE;
     
     
    
    NAME               CONSTANT VARCHAR2(100) := 'UPDATE_MVMS ';
    i_success          NUMBER;
    v_message          VARCHAR2(2000);
    v_material         VARCHAR2(8);
    v_count            NUMBER;
    v_desc             VARCHAR2(120);
    v_wght             NUMBER;
    v_uom              VARCHAR2(9);
    
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
   
   
    OPEN c_mvms;
       LOOP
          FETCH c_mvms INTO rcd;
          EXIT WHEN c_mvms%NOTFOUND;
              i_success := Mvms_Count(rcd.material_code);
              
              IF i_success > 0 THEN  -- MVMS product so save in table 
                  BEGIN
                      -- found an MVMS product so save in table 
                      v_material := rcd.material_code;
                      --dbms_output.put_line(i_success || rcd.material_code);
                      SELECT material_desc, gross_wght, dclrd_uom 
                        INTO v_desc, v_wght, v_uom
                        FROM material
                       WHERE material_code = v_material;
                  
                    
                      SELECT COUNT(*) 
                        INTO v_count
                        FROM site_mvms_pllt 
                       WHERE matl_code = v_material;
                      
                      
                      
                      IF v_count = 0 THEN
                          INSERT INTO site_mvms_pllt
                          VALUES (rcd.material_code, i_success, v_desc, v_wght, v_uom);
                      ELSE
                          --dbms_output.put_line(i_success || ' matl ' || rcd.material_code || ' uom ' || v_wght);
                          UPDATE site_mvms_pllt
                             SET units_per_case = i_success,
                                 matl_desc = v_desc,
                                 gross_wght = v_wght,
                                 gross_wght_uom = v_uom
                           WHERE matl_code = v_material;
                      END IF;
                      COMMIT;
                  EXCEPTION
                      WHEN OTHERS THEN
                          raisenotification (NAME || CHR(13) || 'Problems updateing table SITE_MVMS_PLLT ' || CHR(13) ||SUBSTR(SQLERRM, 1, 512));
                          ROLLBACK;        
                  END;
                    
                  V_matl := v_material;
                  
                  -- now check the sub componets and add to SITE_MPO table 
                 
                  BEGIN
                      DELETE FROM SITE_MPO
                           WHERE matl_code = V_matl;
                         
                      OPEN c_mpo;
                          LOOP
                              FETCH c_mpo INTO rcd1;
                              EXIT WHEN c_mpo%NOTFOUND;
                              -- dbms_output.put_line('FG-' || V_matl || ' MPO-' || rcd1.sub_matl); 
                              INSERT INTO SITE_MPO
                                  VALUES (V_matl, rcd1.sub_matl, rcd1.qty);
                             
                          END LOOP;
                      CLOSE c_mpo;
                      COMMIT;
                  EXCEPTION
                      WHEN OTHERS THEN
                          CLOSE c_mpo;
                          raisenotification (NAME || CHR(13) || 'Problems updateing table SITE_MPO ' || CHR(13) || SUBSTR(SQLERRM, 1, 512));
                          ROLLBACK; 
                          --dbms_output.put_line ('error '  || SUBSTR(SQLERRM, 1, 512));        
                  END;
                  
              END IF;
         
       END LOOP;
    CLOSE c_mvms;
    
    
    
EXCEPTION
       WHEN OTHERS THEN
	   
            v_message := 'Error has occured in UPDATE_MVMS procedure. Material code = ' ||  v_material || CHR(13) || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512);
            
            
       		DBMS_OUTPUT.PUT_LINE(v_message);
			
			-- rollback the transaction
			ROLLBACK;
            
          
			
			--Raise an error 
         	raiseNotification(NAME || CHR(13) || v_message || CHR(13)  || ' Sql Error ' || SUBSTR(SQLERRM, 1, 512));

END Update_Mvms;
/


GRANT EXECUTE ON MANU_APP.UPDATE_MVMS TO APPSUPPORT;

